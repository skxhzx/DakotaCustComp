      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM001C  Update SUM001 file  - More parameters
     *              Based on UPDSUM001B. All previous mod markers kept.
     *              Added Transfers.
     *  20 December 2016
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
650gA*    03/11/15  DAS  6.50g
     *      - Started UPDSUM001A.
     *      - Added sel, put, rpl and rcv params to control the
     *        value to be plotted, if idle time should be included
     *        and if merge pcs should be included.
     *
650hA*    03/18/15  DAS  6.50h
     *      - If no records found for a section, try previous day.
     *        This was done because the same shift code was used for
     *        Sel, Put and Rpl. So, when Putaway starts their day,
     *        thus changing the date in the SHIFTDTE file, the selection
     *        info from the previous day would be lost, showing an
     *        empty section. Real solution should be to move selectors
     *        into their own shift codes.
     *
700aA*    10/08/15  DAS  7.00a
     *      - Revised to handle multiple in-process transactions for
     *        a single user.
     *      - Revised to handle Indirect time during an in-process
     *        transaction.
700b *    01/25/16  RTR  7.00b
     *      - Fixed to prevent zero returned from GetSimCount.
700c *    02/03/16  LMC  7.00c
     *      - Enh to exclude replenishment transfers from ReplRecs.
     *
700dA*    04/11/16  LMC  7.00d
     *      - Started UPDSUM001B.
     *      - Added tfr to control the value to be plotted.
700e *    06/17/16  LMC  7.00e
     *      - Fix: Fake putaways for large pieces will cause
     *        an error in writerec when calculating SMPPH.
     *        Added Monitor - set the field to 0 if error.
700f *    12/30/16  DAS  7.00f
     *      - Enh Added Loader section
     *      - Enh Added ability to exlude employees (see notes)
700g *    01/10/17  DAS  7.00f
     *      - Fix: Revised LodRecs routine to sum ptdload, not ptdtfr.
     *      - Fix: Revised AddRecs to set ttltrn2 = 0 before calling
     *        each Recs routine. Re: This will help prevent forgetting
     *        to do this in the future.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield
SFGaA*    11/12/14  DAS  SFGa
     *      - Set inclMerge = *on
     *----------------------------------------------------------------

     *----------------------------------------------------------------
700eA* Notes
     *
700eA*   As of 700e, employees can be excluded from a graph section.
700eA*   This is done by adding the employee number to file SUM001EX
700eA*   using a GUI maintenance program. The graph section codes
700eA*   can be found in file GLOSUM1GT.
     *
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

650gDd*inclIdle        s               n
650gMd inclIdle        s              1
650gDd*inclMerge       s               n
650gDd*inclBulk        s               n
650gDd*grossPcs        s               n

     d groupStamp      s               z
650aAd minyymmdd       s              6s 0
650bAd minStamp        s               z
650bAd savshftday      s                   like(shdshftday)
650bAd prvshftday      s                   like(shdshftday)
650hAd tempDate        s               d

     d recType         s              3
     d ttlgrspcs       s              7p 0
     d ttlgrsmrg       s              7p 0
     d ttlgrsblk       s              7p 0
     d ttlpcs          s              7p 0
     d ttlmrgpcs       s              7p 0
     d ttlblkpcs       s              7p 0
     d ttlsec          s              9p 0
     d ttlidlesec      s              9p 0
650gAd ttltrn1         s              7p 0
650gAd ttltrn2         s              7p 0
650bAD recCount        s              7p 0
650bAD recCountInd     s              2b 0
650gAD plotValue       s              3
650gAd SelPlotVal      s              1
650gAd SelMrgPcs       s              1
650gAd SelMrgBlk       s              1
650gAd SelIdle         s              1
650gAd PutPlotVal      s              1
650gAd PutIdle         s              1
650gAd RplPlotVal      s              1
650gAd RplIdle         s              1
650gAd RcvPlotVal      s              1
650gAd RcvIdle         s              1
700dAd TfrPlotVal      s              1
700dAd TfrIdle         s              1
700fAd LodPlotVal      s              1
700fAd LodIdle         s              1

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
650gAd  pSelPlotVal    s              1
650gAd  pSelMrgPcs     s              1
650gAd  pSelMrgBlk     s              1
650gAd  pSelIdle       s              1
650gAd  pPutPlotVal    s              1
650gAd  pPutIdle       s              1
650gAd  pRplPlotVal    s              1
650gAd  pRplIdle       s              1
650gAd  pRcvPlotVal    s              1
650gAd  pRcvIdle       s              1
700dAd  pTfrPlotVal    s              1
700dAd  pTfrIdle       s              1
700fAd  pLodPlotVal    s              1
700fAd  pLodIdle       s              1

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d AddRecs         pr
650fAd CopyRecs        pr
     d DeleteRecs      pr

700aAd GetSimCount     pr             5p 0
700aAd  emp#                          5p 0 const
700aAd  startTS                        z   const

     d GetVoicePcs     pr
     d PutawayRecs     pr
     d ReplRecs        pr
650bAd RcvRecs         pr
     d SelectionRecs   pr
     d Selection2      pr
700dAd TfrRecs         pr
700fAd LodRecs         pr
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
650gA*      pSelPlotVal Selection plot value
650gA*                  N = Net pieces (default)
650gA*                  G = Gross pieces
650gA*                  T = Transactions
650gA*      pSelMrgPcs  Selection Include Non-Bulk Merge pieces (Y,N)
650gA*      pSelMrgBlk  Selection Include Bulk Merge pieces (Y,N)
650gA*      pSelIdle    Selection Include Idle time (Y,N)
650gA*      pPutPlotVal Putaway plot value (same as selection)
650gA*      pPutIdle    Putaway Include Idle time (Y,N)
650gA*      pRplPlotVal Replenishment plot value (same as selection)
650gA*      pRplIdle    Replenishment Include Idle time (Y,N)
650gA*      pRcvPlotVal Receiving plot value (same as selection)
650gA*      pRcvIdle    Receiving Include Idle time (Y,N)
700dA*      pTfrPlotVal Transfer plot value (same as replenishment)
700dA*      pTfrIdle    Transfer Include Idle time (Y,N)
700fA*      pLodPlotVal Loader plot value (same as replenishment)
700fA*      pLodIdle    Loader Include Idle time (Y,N)
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
650gAc                   parm                    pSelPlotVal
650gAc                   parm                    pSelMrgPcs
650gAc                   parm                    pSelMrgBlk
650gAc                   parm                    pSelIdle
650gAc                   parm                    pPutPlotVal
650gAc                   parm                    pPutIdle
650gAc                   parm                    pRplPlotVal
650gAc                   parm                    pRplIdle
650gAc                   parm                    pRcvPlotVal
650gAc                   parm                    pRcvIdle
700dAc                   parm                    pTfrPlotVal
700dAc                   parm                    pTfrIdle
700fAc                   parm                    pLodPlotVal
700fAc                   parm                    pLodIdle

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

650gD    //if client = sgc;
650gD      //inclMerge = *on;
650gD    //endif;

650gD    //inclIdle = *on;

650gA    selPlotVal = pSelPlotVal;
650gA    selMrgPcs  = pSelMrgPcs;
650gA    selMrgBlk  = pSelMrgBlk;
650gA    selIdle    = pSelIdle;
650gA    putPlotVal = pPutPlotVal;
650gA    putIdle    = pPutIdle;
650gA    rplPlotVal = pRplPlotVal;
650gA    rplIdle    = pRplIdle;
650gA    rcvPlotVal = pRcvPlotVal;
650gA    rcvIdle    = pRcvIdle;
700dA    tfrPlotVal = pTfrPlotVal;
700dA    tfrIdle    = pTfrIdle;
700fA    lodPlotVal = pLodPlotVal;
700fA    lodIdle    = pLodIdle;

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

650hA     // Save current shift date and calculate previous date
650hA     savshftday = shdshftday;
650hA     tempDate = %date(shdshftday:*YMD) - %days(1);
650hA     prvshftday = %dec(%char(tempDate:*YMD0):6:0);

          SelectionRecs();

650hA     shdshftday = savshftday;
700gA     ttltrn2 = 0;
          PutawayRecs();

650hA     shdshftday = savshftday;
700gA     ttltrn2 = 0;
          ReplRecs();

650hA     shdshftday = savshftday;
700gA     ttltrn2 = 0;
650bA     RcvRecs();

700dA     shdshftday = savshftday;
700gA     ttltrn2 = 0;
700dA     TfrRecs();

700fA     shdshftday = savshftday;
700gA     ttltrn2 = 0;
700fA     LodRecs();

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

700aA*----------------------------------------------------------------
700aA*  GetSimCount   Get simultaneous transaction count
700aA*----------------------------------------------------------------
700aA
700aAp GetSimCount     b
     d GetSimCount     pi             5p 0
     d  emp#                          5p 0 const
     d  startTS                        z   const

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D startDate       s              8s 0
     D startTime       s              6s 0

      /free

        // Return 1 if zero stamp

        if startTS = noStamp;
          count = 1;
          return count;
        endif;

        // Split stamp into date/time fields

        startDate = %dec(%date(startTS):*iso);
        startTime = %dec(%time(startTS):*hms);

        // Calculate non-merge pcs picked via voice

        exec sql select count(*)
                 into :count :countInd
                 from pirtran
                 where ptemp# = :emp#
                   and ptsdte = :startDate
                   and ptstim = :startTime;

        if sqlstt <> sqlSuccess;
          count = 1;
        endif;

        // Protect against extra large sim count.

        if count > 999;
          count = 999;
        endif;

700bA   if count <= 0;
700bA     count = 1;
700bA   endif;

        return count;

      /end-free

     p GetSimCount     e

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

650gD   //if inclMerge;
650gM   if selMrgPcs = 'Y';

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

650gD   //if inclMerge;
650gM   if selMrgBlk = 'Y';
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
650hA     for i = 1 to 2;
650hA
650bA       exec sql select count(*) into :recCount :recCountInd
650bA                from pirtrand
650bA                where ptdwhse = :pwhse
650bA                  and ptdshft = :shdcode
650bA                  and ptdshftday = :shdshftday
650bA                  and (ptdrcvputi = 1 or ptdrtnputi = 1)
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;
650bA
650bA       if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650hA         if i = 2;
650bA           return;
650hA         else;
650hA           shdshftday = prvshftday;
650hA           iter;
650hA         endif;
650bA       endif;
650hA
650hA       leave;
650hA     endfor;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
650gA           +   'sum(ptdrcvput), sum(ptdrtnput) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and (ptdrcvputi = 1 or ptdrtnputi = 1) '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare putStmt from :SqlStmt;
        exec sql declare putCsr cursor for putStmt;
        exec sql open putCsr;

        dow forever = forever;

          exec sql fetch next from putCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
650gM                   :ttlsec, :ttlidlesec,
650gA                   :ttltrn1, :ttltrn2;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

650gA     plotValue = putPlotVal;
650gA     inclIdle = putIdle;

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
650hA     for i = 1 to 2;
650hA
650bA       exec sql select count(*) into :recCount :recCountInd
650bA                from pirtrand
650bA                where ptdwhse = :pwhse
650bA                  and ptdshft = :shdcode
650bA                  and ptdshftday = :shdshftday
700cD                  //and (ptdrpli = 1 or ptdrpltfi = 1)
700cM                  and ptdrpli = 1
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;
650bA
650bA       if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650hA         if i = 2;
650bA           return;
650hA         else;
650hA           shdshftday = prvshftday;
650hA           iter;
650hA         endif;
650bA       endif;
650hA
650hA       leave;
650hA     endfor;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
650gA           +   'sum(ptdrpl), sum(ptdrpltf) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
700cD           //+   'and (ptdrpli = 1 or ptdrpltfi = 1) '
700cM           +   'and ptdrpli = 1 '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare rplStmt from :SqlStmt;
        exec sql declare rplCsr cursor for rplStmt;
        exec sql open rplCsr;

        dow forever = forever;

          exec sql fetch next from rplCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
650gM                   :ttlsec, :ttlidlesec,
650gA                   :ttltrn1, :ttltrn2;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

650gA     plotValue = rplPlotVal;
650gA     inclIdle = rplIdle;

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
650hA     for i = 1 to 2;
650hA
650bA       exec sql select count(*) into :recCount :recCountInd
650bA                from pirtrand
650bA                where ptdwhse = :pwhse
650bA                  and ptdshft = :shdcode
650bA                  and ptdshftday = :shdshftday
650bA                  and ptdrcvi = 1
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;
650bA
650bA       if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650hA         if i = 2;
650bA           return;
650hA         else;
650hA           shdshftday = prvshftday;
650hA           iter;
650hA         endif;
650bA       endif;
650hA
650hA       leave;
650hA     endfor;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
650gA           +   'sum(ptdrcv) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdrcvi = 1 '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';

        exec sql prepare rcvStmt from :SqlStmt;
        exec sql declare rcvCsr cursor for rcvStmt;
        exec sql open rcvCsr;

        dow forever = forever;

          exec sql fetch next from rcvCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
650gM                   :ttlsec, :ttlidlesec,
650gA                   :ttltrn1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

650gA     ttltrn2 = 0;

650gA     plotValue = rcvPlotVal;
650gA     inclIdle = rcvIdle;

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
650hA     for i = 1 to 2;
650hA
650bA       exec sql select count(*) into :recCount :recCountInd
650bA                from pirtrand
650bA                where ptdwhse = :pwhse
650bA                  and ptdshft = :shdcode
650bA                  and ptdshftday = :shdshftday
650bA                  and ptdseli = 1
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;
650bA
650bA       if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
650hA         if i = 2;
650bA           return;
650hA         else;
650hA           shdshftday = prvshftday;
650hA           iter;
650hA         endif;
650bA       endif;
650hA
650hA       leave;
650hA     endfor;
650bA
650bA   endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdgrsmrg), sum(ptdgrsblk), '
                +   'sum(ptdpcs), sum(ptdmrgpcs), sum(ptdblkpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
650gA           +   'sum(ptdsel) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdseli = 1 '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
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
650gM                   :ttlsec, :ttlidlesec,
650gA                   :ttltrn1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

650gA     ttltrn2 = 0;

650gD     //if inclMerge;
650gM     if selMrgPcs = 'Y';
            ttlgrspcs += ttlgrsmrg;
            ttlpcs += ttlmrgpcs;
          endif;

650gD     //if inclBulk;
650gM     if selMrgBlk = 'Y';
            ttlgrspcs += ttlgrsblk;
            ttlpcs += ttlblkpcs;
          endif;

          // Calculate voice pieces for started selection tran

          Selection2();

650gA     plotValue = selPlotVal;
650gA     inclIdle = selIdle;

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

700aA*  Local Variables
700aA
700aAD simTran         s              5p 0
700aAD voiceSec        s              9p 0

      /free

        SqlStmt = 'select '
700aD           // +   'ptdtran, ptdsts '
700aM           +   'ptdtran, ptdsts, ptdempnum '
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
700aD              // into :ptdtran, :ptdsts;
700aM              into :ptdtran, :ptdsts, :ptdempnum;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Calculate voice pieces for started selection tran

          GetVoicePcs();

700aA     // Get simultaneous transactions for user
700aA
700aA     simTran = GetSimCount(ptdempnum: ptdsts);

          // Calculate elapsed seconds for transaction

700aD     //ttlsec += CalcSeconds(ptdsts: groupStamp);
700aM     eval(h) voiceSec = CalcSeconds(ptdsts: groupStamp) / simTran;
700aA     ttlsec += voiceSec;

        enddo;

        exec sql close sel2Csr;

      /end-free

     p Selection2      e

700dA*----------------------------------------------------------------
700dA*  TfrRecs       Add Transfer records
700dA*----------------------------------------------------------------

     p TfrRecs         b
     d TfrRecs         pi

      /free

        recType = 'TFR';

        // See if any records exist within min timestamp

        if pDropHrs > 0;

          for i = 1 to 2;

            exec sql select count(*) into :recCount :recCountInd
                     from pirtrand
                     where ptdwhse = :pwhse
                       and ptdshft = :shdcode
                       and ptdshftday = :shdshftday
                       and ptdtfri = 1
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;

            if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
              if i = 2;
                return;
              else;
                shdshftday = prvshftday;
                iter;
              endif;
            endif;

            leave;
          endfor;

        endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
                +   'sum(ptdtfr) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdtfri = 1 '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare tfrStmt from :SqlStmt;
        exec sql declare tfrCsr cursor for tfrStmt;
        exec sql open tfrCsr;

        dow forever = forever;

          exec sql fetch next from tfrCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
                        :ttlsec, :ttlidlesec,
                        :ttltrn1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          plotValue = tfrPlotVal;
          inclIdle = tfrIdle;

          writeRec();

        enddo;

        exec sql close tfrCsr;

      /end-free

     p TfrRecs         e

700fA*----------------------------------------------------------------
700fA*  LodRecs       Add Loader records
700fA*----------------------------------------------------------------

     p LodRecs         b
     d LodRecs         pi

      /free

        recType = 'LOD';

        // See if any records exist within min timestamp

        if pDropHrs > 0;

          for i = 1 to 2;

            exec sql select count(*) into :recCount :recCountInd
                     from pirtrand
                     where ptdwhse = :pwhse
                       and ptdshft = :shdcode
                       and ptdshftday = :shdshftday
                       and ptdloadi = 1
700fM                  and ptdsts >= :minStamp
700fA                  and (select count(*)
700fA                       from sum001ex
700fA                       where sm1eempnum = ptdempnum
700fA                         and sm1egraph = :recType) = 0;

            if sqlstt <> sqlSuccess or recCountInd < 0 or recCount = 0;
              if i = 2;
                return;
              else;
                shdshftday = prvshftday;
                iter;
              endif;
            endif;

            leave;
          endfor;

        endif;

        // Recs exist so write shift date recs to file

        SqlStmt = 'select '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum, '
                +   'sum(ptdgrspcs), sum(ptdpcs), '
                +   'sum(ptdsec), sum(ptdidlesec), '
700gM           +   'sum(ptdload) '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdshft = ' + sq + %trimr(shdcode) + sq + ' '
                +   'and ptdshftday = ' + %char(shdshftday) + ' '
                +   'and ptdloadi = 1 '
700fA           +   'and (select count(*) '
700fA           +        'from sum001ex '
700fA           +        'where sm1eempnum = ptdempnum '
700fA           +            'and sm1egraph = ' + sq + recType + sq + ') = 0 '
                + 'group by '
                +   'ptdwhse, ptdshft, ptdshftday, ptdempnum';


        exec sql prepare lodStmt from :SqlStmt;
        exec sql declare lodCsr cursor for lodStmt;
        exec sql open lodCsr;

        dow forever = forever;

          exec sql fetch next from lodCsr
                   into :ptdwhse, :ptdshft, :ptdshftday, :ptdempnum,
                        :ttlgrspcs, :ttlpcs,
                        :ttlsec, :ttlidlesec,
                        :ttltrn1;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          plotValue = lodPlotVal;
          inclIdle = lodIdle;

          writeRec();

        enddo;

        exec sql close lodCsr;

      /end-free

     p LodRecs         e

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
650gA
650gA   select;
650gA
650gA     when plotValue = 'T';
650gA       if (ttltrn1 + ttltrn2) > 99999;
650gA         smpcs = 99999;
650gA       else;
650gA         smpcs = ttltrn1 + ttltrn2;
650gA       endif;
650gA
650gA     when plotValue = 'G';
650gA       if ttlgrspcs > 99999;
650gA         smpcs = 99999;
650gA       else;
650gA         smpcs = ttlgrspcs;
650gA       endif;
650gA
650gA     other;
650gA       if ttlpcs > 99999;
650gA         smpcs = 99999;
650gA       else;
650gA         smpcs = ttlpcs;
650gA       endif;
650gA
650gA   endsl;
650gA
650gD   //if grossPcs;
650gD   //  if ttlgrspcs > 99999;
650gD   //    smpcs = 99999;
650gD   //  else;
650gD   //    smpcs = ttlgrspcs;
650gD   //  endif;
650gD   //else;
650gD   //  if ttlpcs > 99999;
650gD   //    smpcs = 99999;
650gD   //  else;
650gD   //    smpcs = ttlpcs;
650gD   //  endif;
650gD   //endif;

650gD   //if inclIdle;
650gM   if inclIdle = 'Y';
          smsec = ttlsec + ttlidlesec;
        else;
          smsec = ttlsec;
        endif;
        smgrpts = groupStamp;

650aa   if smpcs = 0 or smsec = 0;
650aA     smpph = 0;
650aA   else;
700eA     monitor;
            smpph = (smpcs/(smsec/3600)) + 0.5;
700eA     on-error;
700eA       smpph = 0;
700eA     endmon;
650aA   endif;

        write(e) smrec;

      /end-free

     p WriteRec        e
