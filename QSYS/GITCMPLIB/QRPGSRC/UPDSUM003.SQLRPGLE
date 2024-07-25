      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM003  Update SUM003 file
     *             Used by Route Estimated Completion Summary report
     *
     *  09 April 2015
     *  Retha Davis
     *
     *  Revisions
     *
700 A*    04/09/15  RBD  7.00
     *      - Created.
     *
700bA*    07/10/15  DAS  7.00b
     *      - Revised to create a departure date/time when it is zero
     *        and pPgm = 'TSTUPDSUM3'.
     *
700cA*    09/15/15  RBD  7.00c
     *      - Fix: Changed logic for calculating pcs for printed routes.
     *        This program isn't being used anywhere yet so to keep it
     *        clean and readable I did not mod mark the 700c changes.
     *
700dA*    10/25/15  DAS  7.00d
     *      - Fix: Revised to not include zero Emp# in printed count.
     *
700eA*    10/25/15  DAS  7.00e
     *      - Revised to handle multiple in-process transactions for
     *        a single user.
     *      - Revised to handle Indirect time during an in-process
     *        transaction.
     *
700fA*    10/25/15  DAS  7.00f
     *      - Added 'Add' stamp field to file SUM003. This is for
     *        demo purposes and will allow us to manipulate the
     *        departure time and recalculate.
     *      - Replaced %timestamp with groupstamp filed. We want
     *        all calculations for all routes to use same timestamp,
     *        which will also be put into the new add stamp field.
     *
700gA*    10/26/15  DAS  7.00g
     *      - Added more options for demo.
     *
700hA*    08/11/16  DAS  7.00h
     *      - Added new special condition 32/32 to create random
     *        departure when blank.
     *
730aA*    03/12/19  RBD  7.30a
     *      - Recompile only.  Changed remaining hours, smhrsrem,
     *        from 3-2 to 3-1 ... was blowing up at Merit.
730b *    05/01/19  RTR  7.30b
     *      - Changed to handle a minremaining value greater than
     *        999, sets it to 999 if larger.
730c *    08/20/19  JCJ  7.30c
     *      - Changed to handle a minremaining value less than
     *        -999, sets it to 0 if smaller.
730d *    08/31/19  RTR  7.30d
     *      - Changed to handle a division remainder greater than 99.9.
     *
730eA*    09/06/19  RBD  7.30e
     *      - Fix: removed merge pieces logic from rteprinted subr,
     *        should not have been there.
     *
740ea*    02/28/20  DAS  7.40a
     *      - Added warehouse to some Select statements.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Demo Notes
     *
     *    pMinBefDep = 999
     *      - Turn pMinAftDep into 5 decimals.
     *      - Copy recs that start with smsessid = 5 digit pMinAftDep.
     *
     *    pMinBefDep = 888
     *      - Copy recs with smsessid = '888'
     *
     *    pMinBefDep = 31 and pMinAftDep = 31
     *      - Copy recs with smsessid = '888'
     *
700hA*    pMinBefDep = 32 and pMinAftDep = 32
700hA*      - Create random departure when blank.
     *
     *    pUser starts with DEMO and pMinBefDep <> 999
     *      - Copy recs with smsessid = '888'
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fordhm2    if   e           k disk
     Fpiruser1  if   e           k disk
     Frtehed2   if   e           k disk
     Fsum003    uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /copy qcopysrc,id#sgc

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

     D ptrec         E ds                  extname(pirtran) inz(*EXTDFT)
     D ptdrec        E ds                  extname(pirtrand) inz(*EXTDFT)
     D ordh          E ds                  extname(ordh) inz(*EXTDFT)
     D ordd          E ds                  extname(ordd) inz(*EXTDFT)

     d frmtnmCmd       s              8
     d inclIdle        s              1

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z
     D h_deptimst      s               z
     D h_esttimst      s               z
     D h_ts            s               z
     D h_smddte        s               D
     D h_smdtim        s               T
     D h_smedte        s               D
     D h_smetim        s               T
     d h_ptrtpo        s              5
     d minremaining    s              3s 0
     d minyymmdd       s              6s 0
     d minStamp        s               z
     D ohrteInd        s              2b 0
     d orddpcs         s              7p 0
     D orddpcsInd      s              2b 0
     d sec             s              7p 0
     d tempDate        s               d
     d tempTime        s               t

     d recType         s              3
     d ttlgrspcs       s              7p 0
     d ttlgrsmrg       s              7p 0
     d ttlgrsblk       s              7p 0
     d ttlpcs          s              7p 0
     d ttlmrgpcs       s              7p 0
     d ttlblkpcs       s              7p 0
     d ttlsec          s              9p 0
     d ttlidlesec      s              9p 0
     d ttlrsordp       s              7p 0
     d ttlrspckp       s              7p 0
     D recCount        s              7p 0
     D recCountInd     s              2b 0
     d SelMrgPcs       s              1
     d SelMrgBlk       s              1
     d SelIdle         s              1

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d ind1            s              5i 0
     d ind2            s              5i 0

700gAD                 ds
700gAD  temp5a                 1      5
700gAD  temp5n                 1      5  0
700gAD  stop5a                 6     10
700gAD  stop5n                 6     10  0

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40
     d  pUser          s             10
     d  pPgm           s             20
     d  pObjLoc        s             10
     d  pWhse          s              3p 0
     d  pMinBefDep     s              3p 0
     d  pMinAftDep     s              3p 0
     d  pSelMrgPcs     s              1
     d  pSelMrgBlk     s              1
     d  pSelIdle       s              1

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d AddRecs         pr
     d CopyRecs        pr
     d DeleteRecs      pr
700bAd GetRandomDate   pr

700eAd GetSimCount     pr             5p 0
700eAd  emp#                          5p 0 const
700eAd  startTS                        z   const

     d GetVoicePcs     pr
     d RteOpnBlt       pr
     d RtePrinted      pr
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
     *      pMinBefDep  Minutes before departure
     *      pMinAftDep  Minutes after departure
     *      pSelMrgPcs  Selection Include Non-Bulk Merge pieces (Y,N)
     *      pSelMrgBlk  Selection Include Bulk Merge pieces (Y,N)
     *      pSelIdle    Selection Include Idle time (Y,N)
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
     c                   parm                    pMinBefDep
     c                   parm                    pMinAftDep
     c                   parm                    pSelMrgPcs
     c                   parm                    pSelMrgBlk
     c                   parm                    pSelIdle

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

         selMrgPcs  = pSelMrgPcs;
         selMrgBlk  = pSelMrgBlk;
         selIdle    = pSelIdle;

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add records

         //   Special handling when user begins with "DEMO" or minutes before
         //   and after departure = 31.  If either condition is true we don't
         //   want to rebuild SUM001, instead we want to use the records that
         //   are already there.  This way when Lyle is doing a demo it will
         //   always look the same.  And for testing purposes, we can use 31
         //   for minutes before and after to play with the GUI without having
         //   SUM003 rebuilt and not have to use the demo environment.

        if %subst(pUser: 1: 4) = 'DEMO'
700gA      or pMinBefDep=888
700gA      or pMinBefDep=999
           or (pMinBefDep=31 and pMinAftDep=31);
          CopyRecs();
        else;
           AddRecs();
        endif;

         return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRecs   Add records
     *----------------------------------------------------------------

     p AddRecs         b
     d AddRecs         pi

     *  Local Variables

     D hmmsc4Ind       s              2b 0

      /free

        SqlStmt = 'select '
                +   'rhwhse, rhrtid, rhrte, rhstat '
                + 'from rtehed2 '
                + 'where '
                +   'rhwhse = ' + %char(pWhse) + ' '
                +   'and rhtype <> ' + sq + 'W' + sq + ' '
                +   'and rhstat in (1,2,3,4) '
                +   'order by rhstat, rhtype, rhrte, rhrtid ';

        exec sql prepare rteStmt from :SqlStmt;
        exec sql declare rteCsr cursor for rteStmt;
        exec sql open rteCsr;

        dow forever = forever;

          exec sql fetch next from rteCsr
                   into :rhwhse, :rhrtid, :rhrte, :rhstat;

          if sqlstt = sqlNoMoreData;
            leave;
          endif;

          eval smrte  = *blanks;
          eval smrtid = *blanks;
          eval smrtestat = *blanks;
          eval smedte = 0;
          eval smetim = 0;
          eval smminfrdep = 0;
          eval smpcspck = 0;
          eval smpcsrem = 0;
          eval smpcsttl = 0;
          eval smemp# = 0;
          eval smempnam = *blanks;
          eval smpph = 0;
          eval smhrsrem = 0;
          eval smtrnopn = 0;
          eval smtrnstr = 0;
          eval smtrnend = 0;
          eval smtrncls = 0;
          eval smtrnttl = 0;

          chain (rhwhse:rhrtid) ordhm2;
          if not %found;
            smddte = 0;
            smdtim = 0;
            h_smddte = *loval;
            h_smdtim = *loval;
            h_deptimst = nostamp;

          else;

         // Departure date and time

         //  Initialize dates and times if departure date/time not numeric
            if %check('0123456789' : %subst(hmmsc4:1:12)) <> 0;
              smddte = 0;
              smdtim = 0;
              h_smddte = *loval;
              h_smdtim = *loval;
              h_deptimst = nostamp;

            else;

         //  Convert alpha date and time to numeric
            smddte = %dec(%subst(hmmsc4:1:8):8:0);
            smdtim = %dec(%subst(hmmsc4:9:4):4:0);
            smdtim = smdtim * 100;

         //  Convert date and time to timestamp
            h_smddte = %date(smddte);
            h_smdtim = %time(smdtim);
            h_deptimst = h_smddte + h_smdtim;

            endif;

          endif;

700bA     // If departure date is zero and pPgm = 'TSTUPDSUM3'
700hA     //   or 32/32
700bA     // Then create a random departure date/time.
700bA
700hD     //if smddte = 0 and pPgm = 'TSTUPDSUM3';
700hM     if smddte = 0;
700bA       if pPgm = 'TSTUPDSUM3'
700hA         or (pMinBefDep=32 and pMinAftDep=32);
700bA            GetRandomDate();
700hA       endif;
700bA     endif;


          select;
            when rhstat = '1' or rhstat = '2' or rhstat = '3';
              RteOpnBlt();
            when rhstat = '4';
              RtePrinted();
          endsl;

        enddo;

        exec sql close rteCsr;

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

     *----------------------------------------------------------------
     *  CopyRecs    Copy 888 recs
     *----------------------------------------------------------------

     p CopyRecs        b
     d CopyRecs        pi

      /free

700gA   // Process 999 by matching pass number of session id.
700gA   // Program TSTUPDSUM3 creates a special session id
700gA   // that includes a pass number in the first 5 characters.
700gA
700gA   if pMinBefDep = 999;
700gA     temp5n = pMinAftDep;
700gA     stop5n = pMinAftDep + 1;
700gA     setll (temp5a) sum003;
700gA     dow forever = forever;
700gA       read sum003;
700gA       if %eof(sum003)
700gA          or smsessid >= stop5a;
700gA            return;
700gA       endif;
700gA       smsessid = pSessId;
700gA       write(e) smrec;
700gA     enddo;
700gA   endif;

700gA   // Otherwise, grab all records with sessionid = 888.

        setll ('888') sum003;

        dow forever = forever;

          reade ('888') sum003;

          if %eof(sum003);
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

        exec sql delete from sum003
                 where smsessid = :pSessId;

      /end-free

     p DeleteRecs      e

700bA*----------------------------------------------------------------
700bA*  GetRandomDate  Calculate a randome departure date/time
700bA*----------------------------------------------------------------
700bA
700bAp GetRandomDate   b
     d GetRandomDate   pi

     *  Local Variables

     D randomNum       s              6p 0
     D minOffset       s              3p 0

      /free

        if rhstat <= '3';
          // Create time from 1 to 4 hours from now.
          random2(0: 2: 8: randomNum);
          minOffset = randomNum * 30;
        else;
          // Create time from -1 to +2 hours from now.
          random2(0: 0: 6: randomNum);
          minOffset = (randomNum - 2) * 30;
        endif;

700fD   //h_deptimst = %timestamp() + %minutes(minOffset);
700fM   h_deptimst = groupStamp + %minutes(minOffset);

        smddte = %dec(%date(h_deptimst):*iso);
        smdtim = %dec(%time(h_deptimst):*hms);

        return;

      /end-free

     p GetRandomDate   e

700eA*----------------------------------------------------------------
700eA*  GetSimCount   Get simultaneous transaction count
700eA*----------------------------------------------------------------
700eA
700eAp GetSimCount     b
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
740aD            //where ptemp# = :emp#
740aA            where ptwhse = :pWhse
740aM              and ptemp# = :emp#
                   and ptsdte = :startDate
                   and ptstim = :startTime;

        if sqlstt <> sqlSuccess;
          count = 1;
        endif;

        // Protect against extra large sim count.

        if count > 999;
          count = 999;
        endif;

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
                   and (lboltype = 'O' or lboltype = 'B');

        if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
        endif;

        // Calculate merge pcs picked via voice not associated with bulk pick

        // if inclMerge;
        if selMrgPcs = 'Y';

          exec sql select sum(lboqty), sum(lboqtys)
                   into :pcs :pcsInd,
                        :short :shortInd
                   from labeldo
                   left outer join label m on m.lblbl# = lbolbl#
                   left outer join label b on b.lblbl# = m.lbctr#
                   where lbowhse = :ptdwhse
                     and lbotrn# = :ptdtran
                     and lboltype = 'M'
                     and b.lbtype <> 'B';

          if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
          endif;

        endif;

        // Calculate merge pcs picked via voice associated with bulk pick

        // if inclMerge;
        if selMrgBlk = 'Y';

          exec sql select sum(lboqty), sum(lboqtys)
                   into :pcs :pcsInd,
                        :short :shortInd
                   from labeldo
                   left outer join label m on m.lblbl# = lbolbl#
                   left outer join label b on b.lblbl# = m.lbctr#
                   where lbowhse = :ptdwhse
                     and lbotrn# = :ptdtran
                     and lboltype = 'M'
                     and b.lbtype = 'B';

          if sqlstt = sqlSuccess;
            ttlGrsPcs += pcs + short;
            ttlPcs += pcs;
          endif;

        endif;

      /end-free

     p GetVoicePcs     e

     *----------------------------------------------------------------
     *  RteOpnBlt  Open, allocated and built routes
     *----------------------------------------------------------------

     p RteOpnBlt       b
     d RteOpnBlt       pi

      /free

        eval orddpcs = 0;

        exec sql select ohrte, sum(odqor1 + odqor2 + odqor3)
                 into :ohrte :ohrteInd,
                      :orddpcs :orddpcsInd
                 from ordh
                 left outer join ordd on ohwhse = odwhse and ohord = odord
                 where ohwhse = :pWhse
                   and ohrte = :rhrtid
                 group by ohrte
                 order by ohrte;

        if orddpcs > 99999;
          orddpcs = 99999;
        endif;

        smpcspck = 0;
        smpcsrem = orddpcs;
        smpcsttl = orddpcs;
        smemp# = 0;
        smempnam = *blanks;

        writeRec();

      /end-free

     p RteOpnBlt       e

     *----------------------------------------------------------------
     *  RtePrinted    Printed route
     *----------------------------------------------------------------

     p RtePrinted      b
     d RtePrinted      pi

     *  Local Variables

     D count           s              5p 0
     D countInd        s              2b 0
     D maxEmp#         s              5p 0

      /free

        // Count Open transactions

        exec sql select max(ptemp#),  count(*)
                 into :maxEmp# :ind1,
                      :smTrnOpn
                 from pirtran
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
                   and ptstat = '1';

        if sqlstt <> sqlSuccess;
          smTrnOpn = 0;
        endif;

        // Count Started transactions

        exec sql select max(ptemp#),  count(*)
                 into :maxEmp# :ind1,
                      :smTrnStr
                 from pirtran
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
                   and ptstat = '2';

        if sqlstt <> sqlSuccess;
          smTrnStr = 0;
        endif;

        // Count Ended transactions

        exec sql select max(ptemp#),  count(*)
                 into :maxEmp# :ind1,
                      :smTrnEnd
                 from pirtran
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
                   and ptstat = '3';

        if sqlstt <> sqlSuccess;
          smTrnEnd = 0;
        endif;

        // Count Closed transactions

        exec sql select max(ptemp#),  count(*)
                 into :maxEmp# :ind1,
                      :smTrnCls
                 from pirtran
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
                   and ptstat = '4';

        if sqlstt <> sqlSuccess;
          smTrnCls = 0;
        endif;

        // Total up all transactions

        smTrnTtl = smTrnOpn + smTrnStr + smTrnEnd + smTrnCls;


        // Get count of number of employees in pirtrand for this route

        exec sql select count(*)
                 into :cntEmpTrand :countInd
                 from pirtran
                 inner join pirtrand on ptwhse=ptdwhse
                                and pttrn#=ptdtran and ptemp#<>ptdempnum
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
700dA              and ptemp# <> 0;

        // Get count of number of employees in pirtran for this route

        exec sql select count(distinct ptemp#)
                 into :cntEmpTran :countInd
                 from pirtran
740aD            //where ptrtpo = :rhrtid
740aA            where ptwhse = :pWhse
740aM              and ptrtpo = :rhrtid
700dA              and ptemp# <> 0;

        // Get and format employee name
        smempnam = *blanks;
        frmtnmCmd = '*FML    ';
        if cntEmpTrand > 0 or cntEmpTran > 1;
          smempnam = '*MULTIPLE';
        else;
          chain (smemp#) piruser1;
          if %found(piruser1);
            frmtnm(frmtnmCmd: usfnam: usinit: uslnam: smempnam);
          endif;
        endif;

        // Get total pieces from order detail

        eval orddpcs = 0;

        exec sql select ohrte, sum(odqor1 + odqor2 + odqor3)
                 into :ohrte :ohrteInd,
                      :orddpcs :orddpcsInd
                 from ordh
                 left outer join ordd on ohwhse = odwhse and ohord = odord
                 where ohwhse = :pWhse
                   and ohrte = :rhrtid
                 group by ohrte
                 order by ohrte;

        if orddpcs > 99999;
          orddpcs = 99999;
        endif;

        select;

          // Routes with NO started, ended or closed transactions

          when smTrnStr = 0 and smTrnEnd = 0 and smTrnCls = 0;

            smpcspck = 0;
            smpcsrem = orddpcs;
            smpcsttl = orddpcs;
            smemp# = 0;
            smempnam = *blanks;

          // Routes with 1 OR MORE started, ended or closed transactions -
          // Get pieces picked from PIRTRAND and LABELDO

          when smTrnStr > 0 or smTrnEnd > 0 or smTrnCls > 0;

            SqlStmt = 'select '
                    +   'ptrtpo, '
                    +   'sum(ptdgrspcs), sum(ptdgrsmrg), sum(ptdgrsblk), '
                    +   'sum(ptdpcs), sum(ptdmrgpcs), sum(ptdblkpcs), '
                    +   'sum(ptdsec), sum(ptdidlesec) '
                    + 'from pirtran '
                    + 'left outer join pirtrand on ptdwhse=ptwhse '
                    +  'and ptdtran=pttrn# '
                    + 'where '
                    +   'ptwhse = ' + %char(pWhse) + ' '
                    +   'and ptrtpo=' + sq + %trimr(rhrtid) + sq + ' '
                    +   'and ptdseli = 1 '
                    + 'group by '
                    +   'ptrtpo';

            exec sql prepare selStmt from :SqlStmt;
            exec sql declare selCsr cursor for selStmt;
            exec sql open selCsr;

            dow forever = forever;

              exec sql fetch next from selCsr
                       into :ptrtpo,
                            :ttlgrspcs, :ttlgrsmrg, :ttlgrsblk,
                            :ttlpcs, :ttlmrgpcs, :ttlblkpcs,
                            :ttlsec, :ttlidlesec;

              if sqlstt <> sqlSuccess;
                leave;
              endif;

730eD     //  if selMrgPcs = 'Y';
730eD     //    ttlgrspcs += ttlgrsmrg;
730eD     //    ttlpcs += ttlmrgpcs;
730eD     //  endif;

730eD     //  if selMrgBlk = 'Y';
730eD     //    ttlgrspcs += ttlgrsblk;
730eD     //    ttlpcs += ttlblkpcs;
730eD     //  endif;

              // Calculate voice pieces for started selection tran

              Selection2();

              inclIdle = selIdle;
              smemp# = maxemp#;
              smpcspck = ttlpcs;
              smpcsttl = orddpcs;
              smpcsrem = orddpcs - smpcspck;

            enddo;

            exec sql close selCsr;

          other;

        endsl;

        // Write selection recs to file

        writeRec();

      /end-free

     p RtePrinted      e

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
700eD           //+   'ptdtran, ptdsts '
700eM           +   'ptdtran, ptdsts, ptdempnum '
                + 'from pirtrand '
                + 'where '
                +   'ptdwhse = ' + %char(pWhse) + ' '
                +   'and ptdseli = 1 '
                +   'and ptdtran = ' + %char(pttrn#) + ' '
                +   'and ptdstat = 2 ';

        exec sql prepare sel2Stmt from :SqlStmt;
        exec sql declare sel2Csr cursor for sel2Stmt;
        exec sql open sel2Csr;

        dow forever = forever;

          exec sql fetch next from sel2Csr
700eD              //into :ptdtran, :ptdsts;
700eM              into :ptdtran, :ptdsts, :ptdempnum;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

          // Calculate voice pieces for started selection tran

          GetVoicePcs();

700eA     // Get simultaneous transactions for user
700eA
700eA     simTran = GetSimCount(ptdempnum: ptdsts);

          // Calculate elapsed seconds for transaction

700eD     //ttlsec += CalcSeconds(ptdsts: groupStamp);
700eM     eval(h) voiceSec = CalcSeconds(ptdsts: groupStamp) / simTran;
700eA     ttlsec += voiceSec;

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
        smwhse   = pWhse;
        smrte     = rhrte;
        smrtid    = rhrtid;
        smrtestat = rhstat;

        if inclIdle = 'Y';
          sec = ttlsec + ttlidlesec;
        else;
          sec = ttlsec;
        endif;

        if smpcsttl = 0 or sec = 0;
          smpph = 0;
        else;
          smpph = (smpcsttl/(sec/3600)) + 0.5;
        endif;

        select;
          when smtrnttl = 0 or smpph = 0;
            smedte = 0;
            smetim = 0;
          when smpcsrem = 0;
            smedte = %dec(%date);
            smetim = %dec(%time);
          other;
730dD     //smhrsrem = smpcsrem / smpph;
730dA       select;
730dA        when smpcsrem / smpph > 99.9;
730dA         smhrsrem = 99.9;
730dA        when smpcsrem / smpph < -99.9;
730dA         smhrsrem = -99.9;
730dA        other;
730dM         smhrsrem = smpcsrem / smpph;
730dA       endsl;
730cA       Select;
730bA       when smhrsrem * 60 > 999;
730bA         minremaining = 999;

730cA       when smhrsrem * 60 < -999;
730cA         minremaining = 0;
730bA       other;
              eval(h) minremaining = smhrsrem * 60;
730bD    // endif;
730bM       endsl;
700fD       //h_esttimst = %timestamp() + %minutes(minremaining);
700fM       h_esttimst = groupStamp + %minutes(minremaining);
            h_smedte = %date(h_esttimst);
            h_smetim = %time(h_esttimst);
            smedte = %dec(h_smedte);
            smetim = %dec(h_smetim);
        endsl;

        if h_deptimst = *loval;
          smMinFrDep = 0;
        else;
700fD     //smMinFrDep = %diff(h_deptimst: %timestamp: *minutes);
700fM     smMinFrDep = %diff(h_deptimst: groupStamp: *minutes);
        endif;

700fA   smaddts = groupStamp;
        write(e) smrec;

      /end-free

     p WriteRec        e
