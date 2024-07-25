      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     ****  No longer updated                                      ****
     ****  As of 3/11/15 Realtime Task Dashboard uses UPDSUM001A  ****
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM001   Update SUM001 file
     *  22 August 2014
     *  Dave Sommerville
     *
     *  Revisions
     *
650 A*    08/22/14  DAS  6.50
     *      - Created.
     *
650aA*    09/03/14  DAS  6.50a
     *      - Revised to skip shiftdte records that are more
     *        than 2 days old.
     *      - Revised WriteRec routine to check for divide by zero.
     *
650bA*    09/12/14  DAS  6.50b
     *      - Added parameter pDropHrs.
     *      - Revised to skip shifts that do not have a transaction
     *        that was started within pDropHrs.
     *      - Added routine RcvRecs.
     *
650cA*    10/13/14  DAS  6.50c
     *      - Revised WriteRec to make sure ttlPcs not gt 99,999
     *        because smpcs is only 5.0.
     *
650dA*    10/15/14  DAS  6.50d
     *      - Revised 999 hours to include everything
     *
650eA*    11/12/14  DAS  6.50e
     *      - Added client logic
     *
650fA*    11/12/14  DAS  6.50f
     *      - When hours = 888
     *          - Copy records session 888 records instead of
     *            creating new records from PIRTRAND file.
     *
700aA*    06/17/16  LMC  7.00a
     *      - Fix: Fake putaways for large pieces will cause
     *        an error in writerec when calculating SMPPH.
     *        Added Monitor - set the field to 0 if error.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
SFGaA*    11/12/14  DAS  SFGa
     *      - Set inclMerge = *on
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fshiftdte  if   e           k disk
650fDF*um001    o    e           k disk
650fMFsum001    uf a e           k disk

650eA*----------------------------------------------------------------
650eA* Function prototypes.
650eA*----------------------------------------------------------------
650eA
650eA /copy qcopysrc,p.getclien
650eA
650eA*----------------------------------------------------------------
650eA*  Customer id
650eA*----------------------------------------------------------------
650eA
SFGaA /copy qcopysrc,id#sgc

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D ptdrec        E ds                  extname(pirtrand) inz(*EXTDFT)

     d inclIdle        s               n
     d inclMerge       s               n
     d inclBulk        s               n
     d grossPcs        s               n

     d groupStamp      s               z
650aAd minyymmdd       s              6s 0
650bAd minStamp        s               z

     d recType         s              3
     d ttlgrspcs       s              7p 0
     d ttlgrsmrg       s              7p 0
     d ttlgrsblk       s              7p 0
     d ttlpcs          s              7p 0
     d ttlmrgpcs       s              7p 0
     d ttlblkpcs       s              7p 0
     d ttlsec          s              9p 0
     d ttlidlesec      s              9p 0
650bAD recCount        s              7p 0
650bAD recCountInd     s              2b 0

650eAD client          s             10
650eAD clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0
650bAd  pDropHrs       s              3p 0

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d AddRecs         pr
650fAd CopyRecs        pr
     d DeleteRecs      pr
     d GetVoicePcs     pr
     d PutawayRecs     pr
     d ReplRecs        pr
650bAd RcvRecs         pr
     d SelectionRecs   pr
     d Selection2      pr
     d WriteRec        pr

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pWhse       Warehouse
650bA*      pDropHrs    Drop shift if last tran not started within hrs
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pErrMsg
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pObjLoc
     c                   parm                    pWhse
650bAc                   parm                    pDropHrs

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

         inclIdle = *on;

SFGaA    if client = sgc;
SFGaA      inclMerge = *on;
SFGaA    endif;

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add records
650fA    //   Special handling when hours = 888

650fA   if pDropHrs = 888;
650fA     CopyRecs();
650fA   else;
           AddRecs();
650fA   endif;

         return;

      /end-free

650eA*----------------------------------------------------------------
650eA*  *INZSR  Initialization subrotine
650eA*----------------------------------------------------------------
650eA
650eA /free
650eA  begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

      /free

650bD   //minyymmdd = %dec(%date(groupStamp - %days(2)):*ymd);

650dA   if pDropHrs = 999;
650dA     minStamp = noStamp;
650dA   else;
650bA     minStamp = groupStamp - %hours(pDropHrs);
650dA   endif;

        setll (pWhse) shiftdte;

        dow forever = forever;

          reade (pWhse) shiftdte;

          if %eof(shiftdte);
            leave;
          endif;

650bD     //if shdshftday < minyymmdd;
650bD     //  iter;
650bD     //endif;

          SelectionRecs();
          PutawayRecs();
          ReplRecs();
650bA     RcvRecs();

       enddo;

      /end-free

     p AddRecs         e

     *----------------------------------------------------------------
     *  CalcSeconds   Calculate seconds between timestamps
     *----------------------------------------------------------------

     p CalcSeconds     b
     d CalcSeconds     pi             7p 0
     d  fromTS                         z   const
     d  toTS                           z   const

     *  Local Variables

     D seconds         s              7p 0

      /free

        select;
          when fromTS = noStamp;
            seconds = 0;
          when toTS = noStamp;
            seconds = 0;
          when fromTS > toTS;
            seconds = 0;
          other;
            monitor;
              seconds = %diff(toTS: fromTS: *SECONDS);
            on-error;
              seconds = 0;
            endmon;
        endsl;

        return seconds;

      /end-free

     p CalcSeconds     e

650fA*----------------------------------------------------------------
650fA*  CopyRecs    Copy 888 recs
650fA*----------------------------------------------------------------
650fA
650fAp CopyRecs        b
650fAd CopyRecs        pi

      /free

        setll ('888') sum001;

        dow forever = forever;

          reade ('888') sum001;

          if %eof(sum001);
            leave;
          endif;

          smsessid = pSessId;
          write(e) smrec;

        enddo;

      /end-free

     p CopyRecs        e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum001
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e

     *----------------------------------------------------------------
     *  GetVoicePcs   Get Pieces picked with voice
     *----------------------------------------------------------------

     p GetVoicePcs     b
     d GetVoicePcs     pi

     *  Local Variables

     D pcs             s              5p 0
     D pcsInd          s              2b 0
     D short           s              5p 0
     D shortInd        s              2b 0

      /free

        // Calculate non-merge pcs picked via voice

        exec sql select sum(lboqty), sum(lboqtys)
                 into :pcs :pcsInd,
                      :short :shortInd
                 from labeldo
                 where lbowhse = :ptdwhse
                   and lbotrn# = :ptdtran
                   and lboemp# = :ptdempnum
650aM              and (lboltype = 'O' or lboltype = 'B');

        if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
        endif;

640iA   // Calculate merge pcs picked via voice not associated with bulk pick

        if inclMerge;

          exec sql select sum(lboqty), sum(lboqtys)
                   into :pcs :pcsInd,
                        :short :shortInd
                   from labeldo
640iA              left outer join label m on m.lblbl# = lbolbl#
640iA              left outer join label b on b.lblbl# = m.lbctr#
                   where lbowhse = :ptdwhse
                     and lbotrn# = :ptdtran
                     and lboemp# = :ptdempnum
                     and lboltype = 'M'
640iA                and b.lbtype <> 'B';

          if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
          endif;

        endif;

640iA   // Calculate merge pcs picked via voice associated with bulk pick

        if inclMerge;
640iA
640iA     exec sql select sum(lboqty), sum(lboqtys)
640iA              into :pcs :pcsInd,
640iA                   :short :shortInd
640iA              from labeldo
640iA              left outer join label m on m.lblbl# = lbolbl#
640iA              left outer join label b on b.lblbl# = m.lbctr#
                   where lbowhse = :ptdwhse
640iA                and lbotrn# = :ptdtran
640iA                and lboemp# = :ptdempnum
640iA                and lboltype = 'M'
640iA                and b.lbtype = 'B';
640iA
          if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
          endif;

        endif;

      /end-free

     p GetVoicePcs     e

     *----------------------------------------------------------------
     *  PutawayRecs    Add Putaway records
     *----------------------------------------------------------------

     p PutawayRecs     b
     d PutawayRecs     pi

      /free

        recType = 'PUT';

650bA   // See if any records exist within min timestamp
650bA
650bA   if pDropHrs > 0;
650bA
650bA     exec sql select count(*) into :recCount :recCountInd
650bA              from pirtrand
650bA              where ptdwhse = :pwhse
650bA                and ptdshft = :shdcode
650bA                and ptdshftday = :shdshftday
650bA                and (ptdrcvputi = 1 or ptdrtnputi = 1)
650bA                and ptdsts >= :minStamp;
650bA
650bA     if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650bA       return;
650bA     endif;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and (ptdrcvputi = 1 or ptdrtnputi = 1) '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare putStmt from :SqlStmt;
        exec sql declare putCsr cursor for putStmt;
        exec sql open putCsr;

        dow forever = forever;

          exec sql fetch next from putCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
                        :ttlsec, :ttlidlesec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          writeRec();

        enddo;

        exec sql close putCsr;

      /end-free

     p PutawayRecs     e

     *----------------------------------------------------------------
     *  ReplRecs       Add Replenishment records
     *----------------------------------------------------------------

     p ReplRecs        b
     d ReplRecs        pi

      /free

        recType = 'RPL';

650bA   // See if any records exist within min timestamp
650bA
650bA   if pDropHrs > 0;
650bA
650bA     exec sql select count(*) into :recCount :recCountInd
650bA              from pirtrand
650bA              where ptdwhse = :pwhse
650bA                and ptdshft = :shdcode
650bA                and ptdshftday = :shdshftday
650bA                and (ptdrpli = 1 or ptdrpltfi = 1)
650bA                and ptdsts >= :minStamp;
650bA
650bA     if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650bA       return;
650bA     endif;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and (ptdrpli = 1 or ptdrpltfi = 1) '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare rplStmt from :SqlStmt;
        exec sql declare rplCsr cursor for rplStmt;
        exec sql open rplCsr;

        dow forever = forever;

          exec sql fetch next from rplCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
                        :ttlsec, :ttlidlesec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          writeRec();

        enddo;

        exec sql close rplCsr;

      /end-free

     p ReplRecs        e

650bA*----------------------------------------------------------------
650bA*  RcvRecs    Add Receiver records
650bA*----------------------------------------------------------------
650bA
650bAp RcvRecs         b
     d RcvRecs         pi

      /free

        recType = 'RCV';

650bA   // See if any records exist within min timestamp
650bA
650bA   if pDropHrs > 0;
650bA
650bA     exec sql select count(*) into :recCount :recCountInd
650bA              from pirtrand
650bA              where ptdwhse = :pwhse
650bA                and ptdshft = :shdcode
650bA                and ptdshftday = :shdshftday
650bA                and ptdrcvi = 1
650bA                and ptdsts >= :minStamp;
650bA
650bA     if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650bA       return;
650bA     endif;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdrcvi = 1 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare rcvStmt from :SqlStmt;
        exec sql declare rcvCsr cursor for rcvStmt;
        exec sql open rcvCsr;

        dow forever = forever;

          exec sql fetch next from rcvCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
                        :ttlsec, :ttlidlesec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          writeRec();

        enddo;

        exec sql close rcvCsr;

      /end-free

     p RcvRecs         e

     *----------------------------------------------------------------
     *  SelectionRecs   Add Selection records
     *----------------------------------------------------------------

     p SelectionRecs   b
     d SelectionRecs   pi

      /free

        recType = 'SEL';

650bA   // See if any records exist within min timestamp
650bA
650bA   if pDropHrs > 0;
650bA
650bA     exec sql select count(*) into :recCount :recCountInd
650bA              from pirtrand
650bA              where ptdwhse = :pwhse
650bA                and ptdshft = :shdcode
650bA                and ptdshftday = :shdshftday
650bA                and ptdseli = 1
650bA                and ptdsts >= :minStamp;
650bA
650bA     if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650bA       return;
650bA     endif;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdgrsmrg), sum(ptdgrsblk), '
                +   'sum(ptdpcs), sum(ptdmrgpcs), sum(ptdblkpcs), '
                +   'sum(ptdsec), sum(ptdidlesec) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdseli = 1 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare selStmt from :SqlStmt;
        exec sql declare selCsr cursor for selStmt;
        exec sql open selCsr;

        dow forever = forever;

          exec sql fetch next from selCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlgrsmrg, :ttlgrsblk,
                        :ttlpcs, :ttlmrgpcs, :ttlblkpcs,
                        :ttlsec, :ttlidlesec;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          if inclMerge;
            ttlgrspcs += ttlgrsmrg;
            ttlpcs += ttlmrgpcs;
          endif;

          if inclBulk;
            ttlgrspcs += ttlgrsblk;
            ttlpcs += ttlblkpcs;
          endif;

          // Calculate voice pieces for started selection tran

          Selection2();

          writeRec();

        enddo;

        exec sql close selCsr;

      /end-free

     p SelectionRecs   e

     *----------------------------------------------------------------
     *  Selection2      Add Selection records
     *----------------------------------------------------------------

     p Selection2      b
     d Selection2      pi

      /free

        SqlStmt = 'select '
                +   'ptdtran, ptdsts '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdseli = 1 '
                +   'and ptdempnum = ' + %char(ptdempnum) + ' '
                +   'and ptdstat = 2 ';

        exec sql prepare sel2Stmt from :SqlStmt;
        exec sql declare sel2Csr cursor for sel2Stmt;
        exec sql open sel2Csr;

        dow forever = forever;

          exec sql fetch next from sel2Csr
                   into :ptdtran, :ptdsts;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Calculate voice pieces for started selection tran

          GetVoicePcs();

          // Calculate elapsed seconds for transaction

          ttlsec += CalcSeconds(ptdsts: groupStamp);

        enddo;

        exec sql close sel2Csr;

      /end-free

     p Selection2      e

     *----------------------------------------------------------------
     *  WriteRec     Write record
     *----------------------------------------------------------------

     p WriteRec        b
     d WriteRec        pi

      /free

        smsessid = pSessId;
        smtype   = recType;
        smwhse   = ptdwhse;
        smshift  = ptdshft;
        smshiftday  = ptdshftday;
        smshiftdsp  = %char(%date(ptdshftday:*ymd):*mdy/);
        smempnum = ptdempnum;
        if grossPcs;
650cA     if ttlgrspcs > 99999;
650cA       smpcs = 99999;
650cA     else;
            smpcs = ttlgrspcs;
650cA     endif;
        else;
650cA     if ttlpcs > 99999;
650cA       smpcs = 99999;
650cA     else;
            smpcs = ttlpcs;
650cA     endif;
        endif;
        if inclIdle;
          smsec = ttlsec + ttlidlesec;
        else;
          smsec = ttlsec;
        endif;
        smgrpts = groupStamp;

650aa   if smpcs = 0 or smsec = 0;
650aA     smpph = 0;
650aA   else;
700aA     monitor;
            smpph = (smpcs/(smsec/3600)) + 0.5;
700aA     on-error;
700aA       smpph = 0;
700aA     endmon;
650aA   endif;

        write(e) smrec;

      /end-free

     p WriteRec        e
