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
750 A*    07/30/21  KDE  7.50
     *      - Added code to support On Demand Transaction sequencing
     *        along with new dynamic key based on the General System
     *        option setting to Order Route Dashboard/On Demand Assignment
     *      - Changed to use Generic Procedure
     *      - Add pUserx to get non-varying length field for pUser since
     *        a compare exist that is expecting at least 4 characters.  This
     *        became varying after calling with FGENFNC.
     *      - Add monitor statement around calculating SMMINFRDEP.  This
     *        is only 5.0 in SUM0031 and fails if test data is too old
     *
750aA*    09/15/21  KDE  7.50a
     *      - Add field SMAASN to show whether route is auto assigned or not
     *
750bA*    12/10/21  NLK  7.50b
     *      - FIX: when routes aren't closed the total seconds (SUM)ed is
     *        extremely high.  This should only happen in TEST.
     *        ttsec is 9.0 / sec is 7.0, don't let ttsec go over 9999999
     *
760 A*    05/03/22  KDE  7.60
     *      - FIX: always use warehouse zero for *SYSTEM record
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
750 DF*sum003    uf a e           k disk
750 MFsum0031   uf a e           k disk

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
700bA /copy qcopysrc,p.random2
750aA /copy qcopysrc,p.exrtehed

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
750 Ad flgCnt          s              6p 0
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
750 Ad optrna          s              1
750 Ad opsrta          s              1
750 Ad optall          s              1
     d orddpcs         s              7p 0
     D orddpcsInd      s              2b 0
     d sec             s              7p 0
     d tempDate        s               d
     d tempTime        s               t
750 Ad LdrUser         s              1
750 Ad wkKeyf          s             50
750 Ad wkStat          s              1
750 Ad wkStsD          s              8  0
750 Ad wkStsT          s              6  0
750 Ad wkDdte          s              8  0
750 Ad wkDtim          s              6  0

     d recType         s              3
750 Ad today           s              8s 0
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
750 AD pparmStr1       s           1024    varying
750 AD pOutStr         s           1024    varying

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

750 A*----------------------------------------------------------------
750 A*  Translation strings
750 A*----------------------------------------------------------------

750 AD   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
750 AD   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
750 Md  pSessId        s             40    varying
750 Md  pUser          s             10    varying
750 Md  pPgm           s             10    varying
750 Md  pDict          s             10    varying
     d  pWhse          s              3p 0
750aAd  pAasn          s              1
750 Ad  pUserx         s             10
     d  pMinBefDep     s              3p 0
     d  pMinAftDep     s              3p 0
     d  pSelMrgPcs     s              1
     d  pSelMrgBlk     s              1
     d  pSelIdle       s              1
     d  pSortOpt       s              1

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
750 Ad updRteSeq       pr
     d WriteRec        pr

750 Ad ConvertField    pr
750 Ad  parmCount                     3  0
750 Ad  parmName                     10    varying
750 Ad  parmValue                   100    varying

750 Ad ExtractParms    pr

750 Ad ExtractParmStr  pr
750 Ad  parmStr                     999    varying

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
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
     c                   parm                    pSessId
     c                   parm                    pUser
750 Ac                   parm                    pdict
     c                   parm                    pPgm
750 Dc*                  parm                    pWhse
750 Dc*                  parm                    pMinBefDep
750 Dc*                  parm                    pMinAftDep
750 Dc*                  parm                    pSelMrgPcs
750 Dc*                  parm                    pSelMrgBlk
750 Dc*                  parm                    pSelIdle
750 AC                   parm                    pparmStr1
750 AC                   parm                    poutstr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = '';

750 A   // Extract parameters from delimited string

750 A   ExtractParms();

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
         //   SUM0031 rebuilt and not have to use the demo environment.

750 A   pUserx = pUser;
750 M   if %subst(pUserx: 1: 4) = 'DEMO'
700gA      or pMinBefDep=888
700gA      or pMinBefDep=999
           or (pMinBefDep=31 and pMinAftDep=31);
          CopyRecs();
        else;
           AddRecs();
        endif;

750 A   // Return Json String
750 A   if pErrMsg <> *blanks;
750 A     pOutStr = '{"errMsg":"' + %trim(pErrMsg) + '"}';
750 A   else;
750 A     pOutStr = '{"priset":"' + %trim(opsrta) +  '",' +
                     '"optrna":"' + %trim(optrna) +  '",' +
                     '"optall":"' + %trim(optall) +  '"}';
750 A   endif;

        return;

      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);
750 A
750 A    // get options for On Demand Transaction Assignment
750 A    exec sql select optrna,opsrta,optall into :optrna, :opsrta, :optall
750 A                  from opssystem
760 A              where opwhse=0;
750 A    if sqlstt<>'00000';
750 A      optrna='N';
750 A      opsrta='F';
           optall='S';
750 A    else;
           if optall<>'A' and optall<>'S';
             optall='S';
           endif;
750 A      if optrna<>'Y' and optrna<>'N';
750 A        // this sequence is found under System General GUI options
750 A        optrna='N';
750 A      endif;
750 A      if opsrta<>'F' and opsrta<>'P' and opsrta<>'D';
750 A        // If route dashboard sequence is not set then
750 A        // default to "F" for Printed Date/time
750 A        // P - Priority Sequence from MRC Drag/Drop Screen
750 A        // D - Departure Date/Time coming from ORDM HMMSC4
750 A        // this sequence is found under System General GUI options
750 A        opsrta='F';
750 A      endif;
750 A    endif;
750 A
750 A    // determine if using Loader Module
750 A    LdrUser = 'N';
750 A    exec sql select substring(opdata,15,1) into :LdrUser
750 A              from options
750 A           where opwhse=:pWhse and opcode='*RUNNER';
750 A    if sqlstt <> '00000';
750 A      LdrUser = 'N';
750 A    endif;

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
750 D           //+   'rhwhse, rhrtid, rhrte, rhstat '
750 M           +   'rhwhse, rhrtid, rhrte, rhstat, rhprtd, rhprtt '
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
750 D              //into :rhwhse, :rhrtid, :rhrte, :rhstat;
750 M              into :rhwhse, :rhrtid, :rhrte, :rhstat, :rhprtd, :rhprtt;

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

750aA     // get Auto Assign flag for Route
          if optall='A' and optrna='Y';    // Assign ALL routes
            smaasn='Y';
          else;
            // Assign only routes selected from Dashboard screen
750aA       exWhse = rhwhse;
750aA       rhatbtype = *blanks;
750aA       rhaasn = *blanks;
750aA       exrtehed('*GET': exRtnCode: exRtnMsg: exWhse: rhrtid: rhatbtype:
750aA                           rhardypp: rhaasn);
750aA       if exRtnCode = '*OK';
750aA         smaasn=rhaasn;
750aA       else;
750aA         smaasn='N';
750aA       endif;
          endif;

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
750 A
750 A   // when option selected to sort Route Dashboard by
750 A   // PRIORITY SEQUENCE update the dynamic key with said
750 A   // id from the RTEHEDSEQ file.  This is updated via a Drag/Drop
750 A   // screen in MRC from I053xx
750 A   updRteSeq();

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
750 D     //setll (temp5a) sum003;
750 M     setll (temp5a) sum0031;
700gA     dow forever = forever;
750 D       //read sum003;
750 M       read sum0031;
750 D       //if %eof(sum003)
750 M       if %eof(sum0031)
700gA          or smsessid >= stop5a;
700gA            return;
700gA       endif;
700gA       smsessid = pSessId;
700gA       write(e) smrec;
700gA     enddo;
700gA   endif;

700gA   // Otherwise, grab all records with sessionid = 888.

750 D   //setll ('888') sum003;
750 M   setll ('888') sum0031;

        dow forever = forever;

750 D     //reade ('888') sum003;
750 M     reade ('888') sum0031;

750 D     //if %eof(sum003);
750 M     if %eof(sum0031);
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

750 D   //exec sql delete from sum003
750 M   exec sql delete from sum0031
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;
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

750 A   smpdte = *zeros;
750 A   smptim = *zeros;

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

750 A   smpdte = rhprtd;
750 A   smptim = rhprtt;

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

750 A*----------------------------------------------------------------
750 A*  updRteSeq    Update file RTEHEDSEQ to keep defined sequence
750 A*               when user is doing auto assigned selections
750 A*               transactions
750 A*----------------------------------------------------------------

750 Ap updRteSeq       b
750 Ad updRteSeq       pi

750 A*  Local Variables
750 AD nxtId           s              4s 0
750 AD wkSeq           s              4s 0
750 AD wkRte           s              5
750 AD wkRtid          s              5

750 A /free

750 A       // delete anything in RTEHEDSEQ with status beyond 5 (Closed)
750 A       exec sql delete from rtehedseq
750 A            where (select count(*) from sum0031 where
750 A                     rswhse=smwhse and smsessid=:pSessid
750 A                     and rsrtid=smrtid and smrtestat<'6')=0;

750 A       // ensure remaining records in RTEHEDSEQ are sequenced 1-9999
750 A       SqlStmt = 'select '
750 A               +   'rsid,rsrte,rsrtid,rhstat,rhstsd,rhstst,smddte,smdtim '
750 A               + 'from rtehedseq,rtehed,sum0031 '
750 A               + 'where smsessid=' + sq + %trim(pSessId) + sq + ' and '
750 A               +   'rswhse = ' + %char(pWhse) + ' '
                    +   'and rhwhse=rswhse and rhrtid=rsrtid '
                    +   'and smwhse=rswhse and smrtid=rsrtid and smrte=rsrte '
                    +   'and smrtestat<' + sq + '6' + sq
750 A               +   ' order by rsid, rsrte,rsrtid';
750 A
750 A       exec sql prepare seqStmt from :SqlStmt;
750 A       exec sql declare seqCsr cursor for seqStmt;
750 A       exec sql open seqCsr;

750 A       nxtId = 1;
750 A       dow forever = forever;

750 A         exec sql fetch next from seqCsr
750 A                  into :wkSeq,:wkrte,:wkrtid,:wkstat,:wkstsd,:wkstst,
                            :wkddte,:wkdtim;

750 A         if sqlStt <> sqlSuccess;
750 A           leave;
750 A         endif;

              if opsrta = 'F' or opsrta = 'D';
                //get reverse status to put most advanced routes
                //status wise closer to the top.  In other words
                // a route at status 4 will come before a route
                //at status 1 since we subtract the status from 9
                // leaving the smaller number or early status
                monitor;
                  if wkstat='6';
                    // force Exported routes to the bottom of screen
                    wkKeyf='9';
                  else;
                    wkKeyf = %editc(9 - %dec(wkstat:1:0):'X');
                  endif;
                on-error;
                  // force invalid status to bottom of screen
                  wkKeyf = '9';
                endmon;
                if opsrta = 'F';
                  // when sequence is Printed Date/Time then put zero
                  // in for nxtId, and use status date and time.  We
                  // also use the inverse of status from 9 to pull later
                  // status routes to the top of the list
                  wkKeyf = %trim(wkKeyf) + '0' + %editc(wkstsd:'X') +
750 A                      %editc(wkstst:'X') + %trim(wkRte) + %trim(wkRtid);
                else;
                  // When Departure Date/Time sequence we will do the same
                  // as we do above for the Printed Date/Time but replace
                  // Printed with Departure.
                  wkKeyf = %trim(wkKeyf) + '0' + %editc(wkddte:'X') +
750 A                      %editc(wkdtim:'X') + %trim(wkRte) + %trim(wkRtid);
                endif;
              else;
                // just put zero for everything if set for Priority Sequence
                wkkeyf='0' + %editc(nxtId:'X') + wkrte + wkrtid;
              endif;

750 A         exec sql update rtehedseq set rsid=:nxtid, rskeyf=:wkkeyf
750 A                where rswhse=:pWhse and
750 A            rsid=:wkSeq and rsrte=:wkRte and rsrtid=:wkRtid;
750 A         exec sql update sum0031 set smkeyf=:wkKeyf
750 A                where smwhse=:pWhse  and smsessid=:pSessid and
750 A            smrte=:wkRte and smrtid=:wkRtid;
750 A         nxtId = nxtId + 1;

750 A       enddo;
750 A       exec sql close seqCsr;

750 A       // now add any new routes missing in RTEHEDSEQ
750 A       SqlStmt = 'select '
750 A               +   'smrte,smrtid,rhstat,rhstsd,rhstst,smddte,smdtim '
750 A               + 'from sum0031,rtehed '
750 A               + 'where smsessid=' + sq + %trim(pSessId) + sq + ' and '
750 A               +   'smwhse = ' + %char(pWhse) + ' '
                    +   'and rhwhse=smwhse and rhrtid=smrtid '
750 A               +   'and (select count(*) from rtehedseq where '
750 A               +   'rswhse=smwhse and rsrte=smrte '
750 A               +   'and rsrtid=smrtid)=0 and smrtestat<' + sq + '6' + sq
750 A               +   ' order by smrte,smrtid';

750 A       exec sql prepare newStmt from :SqlStmt;
750 A       exec sql declare newSeq cursor for newStmt;
750 A       exec sql open newSeq;

750 A       dow forever = forever;

750 A         exec sql fetch next from newSeq
750 A                  into :wkrte,:wkrtid,:wkstat,:wkstsd,:wkstst,
                            :wkddte,:wkdtim;

750 A         if sqlStt <> sqlSuccess;
750 A           leave;
750 A         endif;

750 A         // add as new Priority Sequence record for sorting by user
750 A         exec sql select max(rsid) into :nxtId from rtehedseq;
750 A         if sqlstt <> '00000';
750 A           nxtId = 1;
750 A         else;
750 A           nxtId = nxtId + 1;
              endif;
750 A         monitor;
                if opsrta = 'F' or opsrta = 'D';
                  //get reverse status to put most advanced routes
                  //status wise closer to the top.  In other words
                  // a route at status 4 will come before a route
                  //at status 1 since we subtract the status from 9
                  // leaving the smaller number or early status
                  monitor;
                    if wkstat='6';
                      // force Exported routes to the bottom of screen
                      wkKeyf='9';
                    else;
                      wkKeyf = %editc(9 - %dec(wkstat:1:0):'X');
                    endif;
                  on-error;
                    // force invalid status to bottom of screen
                    wkKeyf = '9';
                  endmon;
                  if opsrta = 'F';
                    // when sequence is Printed Date/Time then put zero
                    // in for nxtId, and use status date and time.  We
                    // also use the inverse of status from 9 to pull later
                    // status routes to the top of the list
                    wkKeyf = %trim(wkKeyf) + '0' + %editc(wkstsd:'X') +
750 A                        %editc(wkstst:'X') + %trim(wkRte) + %trim(wkRtid);
                  else;
                    // When Departure Date/Time sequence we will do the same
                    // as we do above for the Printed Date/Time but replace
                    // Printed with Departure.
                    wkKeyf = %trim(wkKeyf) + '0' + %editc(wkddte:'X') +
750 A                        %editc(wkdtim:'X') + %trim(wkRte) + %trim(wkRtid);
                  endif;
                else;
                  // just put zero for everything if set for Priority Sequence
                  wkkeyf='0' + %editc(nxtId:'X') + wkrte + wkrtid;
                endif;
750 A           exec sql insert into rtehedseq
750 A                    values(:nxtId,:pWhse,:wkrte,:wkrtid,:wkkeyf);
750 A           exec sql update sum0031 set smkeyf=:wkKeyf
750 A                  where smwhse=:pWhse and smsessid=:pSessid and
750 A              smrte=:wkRte and smrtid=:wkRtid;
750 A         on-error;
750 A         endmon;

750 A       enddo;
750 A       exec sql close newSeq;
750 A
750 A       // Lastly, look to see if the user has overridden the system sequence
750 A       // setting.  If they have we will update the dynamic key in sum0031.
750 A       // The reason we do this at the end is so we can keep RTEHEDSEQ updated
750 A       // properly with the Auto Assign Transaction sequence if used

750 A       if pSortOpt = ' ';
750 A         // When System/Auto Assign Sort is used return.
750 A         // No need to override SUM0031 sort key
750 A         return;
750 A       endif;

750 A       SqlStmt = 'select '
750 A               +   'smrte,smrtid,rhstat,rhstsd,rhstst,smddte,smdtim '
750 A               + 'from sum0031,rtehed '
750 A               + 'where smsessid=' + sq + %trim(pSessId) + sq + ' and '
750 A               +   'smwhse = ' + %char(pWhse) + ' '
750 A               +   'and rhwhse=smwhse and rhrtid=smrtid '
750 A               +   'and smrtestat<' + sq + '6' + sq
750 A               +   ' order by smrte,smrtid';

750 A       exec sql prepare usrStmt from :SqlStmt;
750 A       exec sql declare usrSeq cursor for usrStmt;
750 A       exec sql open usrSeq;

750 A       dow forever = forever;

750 A         exec sql fetch next from usrSeq
750 A                  into :wkrte,:wkrtid,:wkstat,:wkstsd,:wkstst,
                            :wkddte,:wkdtim;

750 A         if sqlStt <> sqlSuccess;
750 A           leave;
750 A         endif;
750 A         monitor;
                if pSortOpt = 'D';
                  opsrta = 'D';
                  //get reverse status to put most advanced routes
                  //status wise closer to the top.  In other words
                  // a route at status 4 will come before a route
                  //at status 1 since we subtract the status from 9
                  // leaving the smaller number or early status
                  monitor;
                    if wkstat='6';
                      // force Exported routes to the bottom of screen
                      wkKeyf='9';
                    else;
                      wkKeyf = %editc(9 - %dec(wkstat:1:0):'X');
                    endif;
                  on-error;
                    // force invalid status to bottom of screen
                    wkKeyf = '9';
                  endmon;
                  // When Departure Date/Time sequence we setup dynamic key
                  // to start with inverse of status (9-status), then 0 for
                  // Priority Seq, and finally depart date/time and route
                  wkKeyf = %trim(wkKeyf) + '0' + %editc(wkddte:'X') +
                           %editc(wkdtim:'X') + %trim(wkRte) + %trim(wkRtid);
                else;
                  // sort purely by Route
                  wkkeyf=wkrte + wkrtid;
                  opsrta = 'R';
                endif;
750 A           exec sql update sum0031 set smkeyf=:wkKeyf
750 A                  where smwhse=:pWhse and smsessid=:pSessid and
750 A              smrte=:wkRte and smrtid=:wkRtid;
              on-error;
              endmon;

750 A       enddo;
750 A       exec sql close usrSeq;

750 A   return;
750 A /end-free

750 Ap updRteSeq       e

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

750bA     // in TEST routes aren't closed for days
750bA   if ttlsec > 9999999;
750bA     ttlsec = 9999999;
750bA   endif;

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
750 A     monitor;
700fM       smMinFrDep = %diff(h_deptimst: groupStamp: *minutes);
750 A     on-error;
750 A       smMinFrDep = 99999;
750 A     endmon;
        endif;

750 A   // Set Shorts Flag
750 A   flgCnt = 0;
750 A   smflgshrts='N';
750 A   exec sql select count(*) into :flgCnt
750 A             from rtehed,ordh,label,runner
750 A        where ohwhse=rhwhse and ohrte=rhrtid and
750 A              lbwhse=ohwhse and lbrte=ohrte and
750 A              ruwhse=lbwhse and rulbl#=lblbl# and
750 A              lbstat<>'C' and lbgrp1='S' and rhrtid=:smrtid
750 A              and rustat<>'L' and rustat<>'C';
750 A   if sqlstt <> '00000' or flgCnt = 0;
750 A     smflgshrts='N';
750 A   else;
750 A     smflgshrts='Y';
750 A     if LdrUser = 'Y';
750 A       // if Loader module user and open short
750 A       // that is not "L" status we should also
750 A       // show loader flag
750 A       smflgldr='Y';
750 A     endif;
750 A   endif;

750 A   // Set Loader Flag
750 A   flgCnt = 0;
750 A   smflgldr='N';
750 A   exec sql select count(*) into :flgCnt
750 A             from rtehed,ordh,label,runner
750 A        where ohwhse=rhwhse and ohrte=rhrtid and
750 A              lbwhse=ohwhse and lbrte=ohrte and
750 A              ruwhse=lbwhse and rulbl#=lblbl# and
750 A              lbstat<>'C' and lbgrp1='S' and rhrtid=:smrtid
750 A              and rustat='L';
750 A   if sqlstt <> '00000' or flgCnt = 0;
750 A     smflgldr='N';
750 A   else;
750 A     smflgldr='Y';
750 A   endif;

750 A   // Set Customer Audit Flag
750 A   smflgaud='N';
750 A   flgCnt = 0;
750 A   exec sql select count(*) into :flgCnt
750 A             from rtehed,ordh,ordhexa
750 A        where ohwhse=rhwhse and ohrte=rhrtid and
750 A              ohwhse=ohawhse and ohord=ohaord and
750 A              ohaaudcmp<>'Y' and ohrte=:smrtid;
750 A   if sqlstt <> '00000' or flgCnt = 0;
750 A     smflgaud='N';
750 A   else;
750 A     smflgaud='Y';
750 A   endif;

700fA   smaddts = groupStamp;
        write(e) smrec;

      /end-free

     p WriteRec        e

750 A*----------------------------------------------------------------
750 A*  ConvertField   Convert incoming field to DRI field
750 A*----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'WHSE';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'BEFDEP';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMinBefDep =  %dec(parmValue: 3: 0);

           when parmName = 'AFTDEP';
             if parmValue = '';
               parmValue = '0';
             endif;
             pMinAftDep =  %dec(parmValue: 3: 0);

750aA      when parmName = 'AASN';
750aA       pAasn = %trim(parmValue);

           when parmName = 'MRGPCS';
            pSelMrgPcs = %trim(parmValue);

           when parmName = 'MRGBLK';
            pSelMrgBlk = %trim(parmValue);

           when parmName = 'SELIDLE';
            pSelIdle = %trim(parmValue);

           when parmName = 'SORTOPT';
            pSortOpt = %trim(parmValue);

         endsl;

       on-error;

         pErrMsg  = 'Error extracting parameter '
                  + %char(parmCount) + ' '
                  + parmName + ' '
                  + '(' + parmValue + ')'
                  + '('
                  + %trimr(#Job) + '/'
                  + %trimr(#JobNbr) + '/'
                  + %trimr(#user)
                  + ')';

       endmon;

       return;

      /end-free

750 Ap                 e

750 A*----------------------------------------------------------------
750 A*  ExtractParms   Extract parms from parameter string
750 A*----------------------------------------------------------------

750 Ap ExtractParms    b
750 Ad ExtractParms    pi

     * Local Variables

     d parmStr         s            999    varying

      /free

         // Error if first parameter string is blank

         if pParmStr1 = '';
           pErrMsg  = 'Error: Parameter string is empty '
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           return;
         endif;

         // Extract parms for string 1

         parmStr = %trim(pParmStr1);
         ExtractParmStr(parmStr);

         if pErrMsg  <> '';
           return;
         endif;

         if pErrMsg  <> '';
           return;
         endif;

       return;

      /end-free

750 Ap                 e

750 A*----------------------------------------------------------------
750 A*  ExtractParmStr   Extract parms from single parameter string
750 A*----------------------------------------------------------------

750 Ap ExtractParmStr  b
750 Ad ExtractParmStr  pi
750 Ad  parmStr                     999    varying

     * Local Variables

     D parmCount       s              3  0
     D parmGroup       s            200    varying
     D parmLen         s              5  0
     D parmName        s             10    varying
     D parmStrLen      s              5  0
     D parmValue       s            100    varying
     D pos             s              5  0
     D start           s              5  0

      /free

       // Parameters are separated by '|'

       start = 1;
       parmStrLen = %len(parmStr);
       parmCount = 0;

       dow start <= parmStrLen;

         // Extract parameter ('fldname=value')

         pos = %scan('|': parmStr: start);

         parmCount += 1;

         if pos = 0;
           parmGroup = %subst(parmStr: start);
           start = parmStrLen + 1;
         else;
           parmLen = pos - start;
           parmGroup = %subst(parmStr: start: parmLen);
           start = pos + 1;
         endif;

         // Extract parameter name

         pos = %scan('=': parmGroup: 1);

         // If no '=' found, invalid group.

         if pos = 0;
           pErrMsg  = 'Error: Invalid parameter group '
                    + %char(parmCount) + ' '
                    + '(' + parmGroup + ')'
                    + '('
                    + %trimr(#Job) + '/'
                    + %trimr(#JobNbr) + '/'
                    + %trimr(#user)
                    + ')';
           leave;
         endif;

         parmName = %subst(parmGroup: 1: pos - 1);

         // Extract parameter value

         parmLen = %len(parmGroup);

         if parmLen = pos;
           parmValue = '';
         else;
           parmValue = %subst(parmGroup: pos + 1);
         endif;

         // Convert extracted value and put into DRI field

         ConvertField(parmCount: parmName: parmValue);
         if pErrMsg  <> '';
           leave;
         endif;

       enddo;

       return;

      /end-free

750 Ap                 e
