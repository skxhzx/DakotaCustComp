      /copy *libl/qcopysrc,hspecs
     H Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  UPDSUM017  Update SUM017 file
     *             Used by Goal Performance Reporting
     *
     *  23 March 2022
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*    03/23/22  KDE  7.50
     *      - Created.
     *
760 A*    04/29/22  KDE  7.60
     *      - Include on employees that had selection transaction activity
     *        since that is all we measure at this point.
     *
760aA*    05/03/22  KDE  7.60a
     *      - Calculate actual time on non selection transaction activity
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fsum017    uf a e           k disk
     Fpiruser1  if   e           k disk
     flabeldo2  if   e           k disk
     flabel7    if   e           k disk
     felsstddtl1if   e           k disk
     fpirTrand  if   e           k disk
     fpirTrand5 if   e           k disk    rename(ptdrec:ptdrec5)
     f                                     prefix(p_)
     fmultran3  if   e           k disk    rename(murec:murec3)

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.frmtnm
      /copy qcopysrc,p.random2

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

     d frmtnmCmd       s              8
     d inclIdle        s              1
     d wkTrnKey        s             64
     D wkActualSecs    s             13  0
     D passSecs        s             13s 0
     D wkHours         s              2  0
     D wkMinutes       s              2  0
     D wkSeconds       s              2  0
     d empStrTS        s               z   inz(z'0001-01-01-00.00.00.000000')
     d shftStrTS       s               z   inz(z'0001-01-01-00.00.00.000000')
     d maxEmpts        s               z   inz(z'0001-01-01-00.00.00.000000')
     d maxShftts       s               z   inz(z'0001-01-01-00.00.00.000000')
     d wksts           s               z   inz(z'0001-01-01-00.00.00.000000')
     d hldEmpnum       s              5  0
     d hldShftDay      s              6  0
     d goalLBO         s               n
     D pos             s              3  0
     d comma           s              1    inz(',')
     d rplcomma        s              3
     d wkStart         s               z
     d wkSdte          s              8  0
     d wkStim          s              6  0
     d wkEdte          s              8  0
     d wkEtim          s              6  0

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D cntEmpTran      s              3p 0
     D cntEmpTrand     s              3p 0
     d groupStamp      s               z

     D client          s             10
     D clientloc       s             10

     d noStamp         s               z   inz(z'0001-01-01-00.00.00.000000')

     d NullInds        s              5i 0 dim(1)
     d NullValue       s                   like(NullInds) inz(-1)

     d sqlWheres       s           5000

760 AD inclEmpSD       s             11     dim(50000)
     D lblList         s              7  0  dim(100)
     d lblc            s              3  0

     D dateconv        ds
     D  tsdatetime             1     26
     D  tsyear                 1      4
     d                         5      5    inz('-')
     D  tsmonth                6      7
     d                         8      8    inz('-')
     D  tsday                  9     10
     d                        11     11    inz('-')
     D  tshour                12     13
     d                        14     14    inz('.')
     D  tsmin                 15     16
     d                        17     17    inz('.')
     D  tssec                 18     19
     d                        20     20    inz('.')
     D  tsmsec                21     26

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     d  pErrMsg        s             99
     d  pSessId        s             40    varying
750 Md  pUser          s             10    varying
750 Md  pPgm           s             10    varying
750 Md  pDict          s             10    varying
750 AD  pparmStr1      s           1024    varying
750 AD  pOutStr        s           1024    varying
     d  pWhse          s              3p 0
     d  pEmpnum        s            100
     d  pCrew          s            100
     d  pShft          s            100
     d  pTask          s            100
     d  pfrmDate       s              8  0
     d  ptoDate        s              8  0
     d  trnCnt         s              5  0

     *----------------------------------------------------------------
     *  Transaction Actual and Goal Time Array for
     *----------------------------------------------------------------
     D                 ds
     d trnH                                 dim(25000)
     D  trnkey                       64     overlay(trnH:*next)
     D  trnA                         13s 0  overlay(trnH:*next)
     D  trnG                         13s 0  overlay(trnH:*next)
     D  trnAHMS                       8a    overlay(trnH:*next)

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     d AddRecs         pr
     d DeleteRecs      pr
     d getTransHrs     pr
     d getGoalTime     pr

     d CalcSeconds     pr             7p 0
     d  fromTS                         z   const
     d  ToTS                           z   const

     d fmtActHMS       pr             8a
     d  iSecs                        13s 0

     d fmtStrInList    pr           100
     d  iParmVal                    100    value

     d ConvertField    pr
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

     d ExtractParms    pr

     d ExtractParmStr  pr
     d  parmStr                     999    varying

     D sleep           pr            10u 0 extproc('sleep')
     D   Interval                    10u 0 value

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pDict       Dictionary
     *      pPgm        Program
     *      pParmStr1   Parm String
     *
     *    Returned Parameters
     *      pOutStr     Return json String
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pDict
     c                   parm                    pPgm
     c                   parm                    pParmStr1
     c                   parm                    pOutStr

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

         *inlr = *on;
         pErrMsg = ' ';

750 A   // Extract parameters from delimited string

750 A   ExtractParms();

         groupStamp = %timestamp();

         // Delete existing records for session id

         DeleteRecs();

         // Add work records for Report Slots w/No Activity
        AddRecs();

        // Return Json String
        if pErrMsg <> *blanks;
          pOutStr = '{"errMsg":"' + %trim(pErrMsg) + '"}';
        else;
          pOutStr = '{"errMsg":"*OK"}';
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

760 Ad wkEmpShftDay    s             11

      /free

        bldEmpList();

        SqlStmt = 'select '
                +   'ptdwhse, ptdempnum, ptdtask, ptdtran, ptdshftday, '
                +   'ptdsts, ptdets, ptdpcs, ptdnrmnv, ptdmrgpcs, '
                +   'ptdblkpcs, ptdmrgnv, ptdsec, ptddiri, ptdindi, '
                +   'ptdidlei, ptdrcvi, ptdstagei, ptdrpli, ptdtfri, ptdseli, '
                +   'ptdfixi, ptdpiri, ptdbulki, ptdrtni, ptdruni, ptdloadi, '
                +   'ptdotheri, ptdshft, ptdcrew '
                + 'from pirtrand';
        sqlWheres = 'where '
                +   'ptdwhse=' + %char(pWhse) + ' and ptdstat>=' + sq +
                      '3' + sq + ' and ptdempnum<>0';

        // Additional selections

        // From Date
        if pfrmDate <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and ptdshftday>=' + %char(pfrmDate);
        endif;

        if ptoDate <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and ptdshftday<=' + %char(ptoDate);
        endif;

        // Employee List
        if pEmpNum <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdEmpNum in(' +
                       %trim(pEmpNum) + ')';
        endif;

        // Shift List
        if pShft <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdShft in(' +
                       %trim(pShft) + ')';
        endif;

        // Crew List
        if pCrew <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdCrew in(' +
                       %trim(pCrew) + ')';
        endif;

        // Task List
        if pTask <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdTask in(' +
                       %trim(pTask) + ')';
        endif;

        sqlStmt = %trim(sqlStmt) + ' ' + %trim(sqlWheres);

        // Sort select data in Warehouse, EMployee, and Start timestamp order
        sqlStmt = %trim(sqlStmt) + ' order by ptdwhse,ptdempnum,ptdshftday' +
                                            ',ptdsts';

        exec sql prepare trnStmt from :SqlStmt;
        exec sql declare trnCsr cursor for trnStmt;
        exec sql open trnCsr;

        trnCnt=0;
        clear trnkey;
        clear trna;
        clear trng;
        clear trnAHMS;
        dow forever = forever;

          exec sql fetch next from trnCsr
                   into :ptdwhse,:ptdempnum,:ptdtask,:ptdtran,:ptdshftday,
                       :ptdsts,:ptdets,:ptdpcs,:ptdnrmnv,:ptdmrgpcs,
                       :ptdblkpcs,:ptdmrgnv,:ptdsec,:ptddiri,:ptdindi,
                       :ptdidlei,:ptdrcvi,:ptdstagei,:ptdrpli,:ptdtfri,:ptdseli,
                       :ptdfixi,:ptdpiri,:ptdbulki,:ptdrtni,:ptdruni,:ptdloadi,
                       :ptdotheri,:ptdshft,:ptdcrew;

          if sqlstt <> sqlSuccess;
            leave;
          endif;

760 A     // only include employees in array inclEmpSD
760 A     wkEmpShftDay = %editc(ptdEmpnum:'X') + %editc(ptdShftDay:'X');
760 A     if %lookup(wkEmpShftDay:inclEmpSD) = 0;
760 A       iter;
760 A     endif;

          // should not happen but cover in case
          if ptdsts > ptdets;
            ptdets = ptdsts;
          endif;

          // if Employee number changes we should change the default start TS for both
          // Employee and Shift Day
          if hldEmpnum <> ptdempnum;
            // Format greatest end time for last employee and update
            smendEmpF = %char(%time(maxEmpts) : *HMS:) + ' '               // hh:mm:ss
                      + %subst(%char(%time(maxEmpts): *USA): 7 : 2);       // AM or PM
            exec sql update SUM017 set smendempf=:smendEmpf
               where smsessid=:pSessId and smemp=:hldEmpnum and
                      smshftday=:hldshftday;
            hldEmpnum = ptdempnum;
            empStrTS = ptdsts;
            hldShftday = ptdshftday;
            shftStrTS = ptdsts;
          endif;

          // if only the shift day changes we should update the start time for the shift date
          if hldShftday <> ptdshftday;
            // Format greatest end time for last employee and update
            smendSDF = %char(%time(maxShftts) : *HMS:) + ' '               // hh:mm:ss
                      + %subst(%char(%time(maxShftts): *USA): 7 : 2);      // AM or PM
            exec sql update SUM017 set smendSDf=:smendSDf
               where smsessid=:pSessId and smemp=:hldEmpnum and
                      smshftday=:hldshftday;
            hldshftday = ptdshftday;
            shftStrTS = ptdsts;
          endif;

          maxEmpts = ptdets;
          maxShftts = ptdets;

          clear smrec;
          smsessid = pSessid;
          smaddts = %timestamp();
          smwhse = ptdwhse;
          smemp=ptdempnum;
          smtrn#=ptdtran;
          smshftday=ptdshftday;
          smsts=ptdsts;
          smets=ptdets;
          smtask=ptdtask;
          smshft=ptdshft;
          smcrew=ptdcrew;
          smnpcs=ptdpcs+ptdnrmnv+ptdmrgpcs+ptdblkpcs+ptdmrgnv;
          smendempf=*blanks;
          smendsdf=*blanks;

          // get Total Actual and Goal time for this transaction, employee,
          // start and end time
          wkTrnKey = %editc(ptdempnum:'X') + %char(ptdsts) +
                     %char(ptdets) + %editc(ptdTran:'X');

          if %lookup(wkTrnKey:trnKey) = 0;
            if ptdseli=1;
              // go load array with Actual Hours properly loaded for each
              // Transaction based on labeldo records when selection trans
              getTransHrs();
              // reset variable gettranshrs call
              wkTrnKey = %editc(ptdempnum:'X') + %char(ptdsts) +
                         %char(ptdets) + %editc(ptdTran:'X');
              if %lookup(wkTrnKey:trnKey) = 0;
                smsgoal=0;
                ptdsec=0;
760aD           //smacttimef = *blanks;
760aA           passSecs = ptdsec;
760aA           smacttimef = fmtActHMS(passSecs);
              else;
                smsgoal = trnG(%lookup(wkTrnKey:trnKey));
                ptdsec  = trnA(%lookup(wkTrnKey:trnKey));
                smacttimef = trnAHMS(%lookup(wkTrnKey:trnKey));
              endif;
            else;
              // when not selection transaction we do no goals yet
              // and just use actual in ptdsec
              smsgoal=0;
760aA         if ptdtask <> 'IDLE';
760aA           passSecs = ptdsec;
760aA           smacttimef = fmtActHMS(passSecs);
760aA         endif;
            endif;
          else;
            // Transaction already loaded from previous MultiTran call
            smsgoal = trnG(%lookup(wkTrnKey:trnKey));
            ptdsec  = trnA(%lookup(wkTrnKey:trnKey));
            smacttimef = trnAHMS(%lookup(wkTrnKey:trnKey));
          endif;

          // save seconds in appropriate bucket
          select;
            when ptdidlei=1;
              smidles = ptdsec;
            when ptdindi=1;
              smisecs = ptdsec;
            other;
              if ptdtask='ENDDAY';
                smdsecs = *zeros;
              else;
                smdsecs = ptdsec;
              endif;
          endsl;

          // get Employee Name
          chain (smemp) piruser1;
          if not %found(piruser1);
            smempnam = 'Invalid Employee';
          else;
            smempnam = %trim(usfnam) + ' ' + %trim(uslnam);
          endif;

          // format shift date mm/dd/yy
          monitor;
            smshftdtef = %subst(%editc(ptdshftday:'X'):3:2) + '/' +
                         %subst(%editc(ptdshftday:'X'):5:2) + '/' +
                         %subst(%editc(ptdshftday:'X'):1:2);
          on-error;
            smshftdtef = %char(ptdshftday);
          endmon;

          // Format Start and End times as hh:mm:ss AM/PM
          smstrTimeF = %char(%time(ptdsts) : *HMS:) + ' '               // hh:mm:ss
                     + %subst(%char(%time(ptdsts): *USA): 7 : 2);       // AM or PM
          smendTimeF = %char(%time(ptdets) : *HMS:) + ' '               // hh:mm:ss
                     + %subst(%char(%time(ptdets): *USA): 7 : 2);       // AM or PM

          // Format repeating start times for Employee and Shift
          smstrEmpF = %char(%time(empStrTS) : *HMS:) + ' '               // hh:mm:ss
                    + %subst(%char(%time(empStrTS): *USA): 7 : 2);       // AM or PM
          smStrSDF = %char(%time(shftStrTS) : *HMS:) + ' '               // hh:mm:ss
                   + %subst(%char(%time(shftStrTS): *USA): 7 : 2);       // AM or PM

          // Format Goal Time in hh:mm:ss format
          passSecs = smsgoal;
          smgoaltf = fmtActHMS(passSecs);

          // calculate performance percent
          if smdsecs <>0 and smsgoal<>0;
            smperf = %char(%dec((smsgoal / smdsecs) * 100:9:2)) + '%';
          else;
            smperf = *blanks;
          endif;

          // format all minute fields
          if smdsecs<>0;
            smdirectf = %char(%dec(smdsecs / 60:9:2));
          else;
            smdirectf=*blanks;
          endif;

          if smisecs<>0;
            smIndirf  = %char(%dec(smisecs / 60:9:2));
          else;
            smIndirf  = *blanks;
          endif;

          if smidles<>0;
            smIdlef   = %char(%dec(smidles / 60:9:2));
          else;
            smIdlef   = *blanks;
          endif;

          smtsecs=smdsecs+smisecs+smidles;
          passSecs = smtsecs;
          smTotalf = fmtActHMS(passSecs);

          // calculate and format Units per Hour
          if smdsecs<>0 and smsgoal<>0;
            smunthrf = %char(%dec((smnpcs/smdsecs)*3600:9:2));
          else;
            smunthrf = *blanks;
          endif;

          write smrec;

        enddo;

        // Format greatest end time for last employee for last employee processed
        smendEmpF = %char(%time(maxEmpts) : *HMS:) + ' '               // hh:mm:ss
                  + %subst(%char(%time(maxEmpts): *USA): 7 : 2);       // AM or PM
        exec sql update SUM017 set smendempf=:smendEmpf
           where smsessid=:pSessId and smemp=:hldEmpnum and
                  smshftday=:hldshftday;

        smendSDF = %char(%time(maxShftts) : *HMS:) + ' '               // hh:mm:ss
                  + %subst(%char(%time(maxShftts): *USA): 7 : 2);      // AM or PM
        exec sql update SUM017 set smendSDf=:smendSDf
           where smsessid=:pSessId and smemp=:hldEmpnum and
                  smshftday=:hldshftday;

        exec sql close trnCsr;

      /end-free


     p AddRecs         e

     *----------------------------------------------------------------
     *  bldEmpList  - Build List of Employees that performed selection
     *                for selections
     *----------------------------------------------------------------

     p bldEmpList      b
     d bldEmpList      pi

     *  Local Variables

     d  loopcnt        s              6  0

      /free

        SqlStmt = 'select '
                +   'distinct ptdEmpNum, ptdShftDay '
                + 'from pirtrand ';
        sqlWheres = 'where '
                +   'ptdwhse=' + %char(pWhse) + ' and ptdstat>=' + sq +
                      '3' + sq + ' and ptdempnum<>0 and ' +
                      '(ptdsel=1 or ptdseli=1)';

        // Additional selections

        // From Date
        if pfrmDate <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and ptdshftday>=' + %char(pfrmDate);
        endif;

        if ptoDate <> *zeros;
           sqlWheres = %trim(sqlWheres) + ' and ptdshftday<=' + %char(ptoDate);
        endif;

        // Employee List
        if pEmpNum <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdEmpNum in(' +
                       %trim(pEmpNum) + ')';
        endif;

        // Shift List
        if pShft <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdShft in(' +
                       %trim(pShft) + ')';
        endif;

        // Crew List
        if pCrew <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdCrew in(' +
                       %trim(pCrew) + ')';
        endif;

        // Task List
        if pTask <> *blanks;
           sqlWheres = %trim(sqlWheres) + ' and ptdTask in(' +
                       %trim(pTask) + ')';
        endif;

        sqlStmt = %trim(sqlStmt) + ' ' + %trim(sqlWheres);

        // Sort select data in Warehouse, EMployee, and Start timestamp order
        sqlStmt = %trim(sqlStmt) + ' order by ptdempnum';

        exec sql prepare empList from :SqlStmt;
        exec sql declare empLst cursor for empList;
        exec sql open empLst;

        loopCnt=0;
        clear inclEmpSD;

        dow forever = forever;

          exec sql fetch next from empLst
                   into :ptdempnum, :ptdShftDay;

          if sqlstt <> '00000';
            leave;
          endif;

          loopCnt = loopCnt + 1;
          inclEmpSD(loopCnt) = %editc(ptdEmpnum:'X') + %editc(ptdShftDay:'X');

        enddo;

        exec sql close empLst;

      /end-free

     p bldEmpList      e

     *----------------------------------------------------------------
     *  getTransHrs - Get Actual Hours from Labeldo and goal hours
     *                from ELSSTDDTL
     *----------------------------------------------------------------

     p getTransHrs     b
     d getTransHrs     pi

     *  Local Variables

     d badReadCnt      s              3  0
     d trnList         s           1000
     d trnTotalSecs    s             13  0
     d lboSecs         s             13  0

      /free
          trnList=*blanks;
          trnTotalSecs = 0;

          // convert start and end timestamps from pirtrand to
          // numeric values to look for MULTRAN record
          tsdatetime = %char(ptdsts);
          wksdte = %dec(tsyear+tsmonth+tsday:8:0);
          wkstim = %dec(tshour+tsmin+tssec:6:0);
          tsdatetime = %char(ptdets);
          wkedte = %dec(tsyear+tsmonth+tsday:8:0);
          wketim = %dec(tshour+tsmin+tssec:6:0);

          setll (ptdwhse:ptdEmpNum:wksdte:wkstim:wkedte:wketim) multran3;
          reade (ptdwhse:ptdEmpNum:wksdte:wkstim:wkedte:wketim) multran3;

          // if found in MULTRAN make sure start time for multran record
          // is not greater than end of pirtrand record originally read
          // before coming to gettranhrs

          if not %eof(multran3);

            // being in multitran does not mean there are multiple
            // transactions, however we will loop through all records
            // for this employee along with same start and end times.
            // We will then ensure each one of them are available in
            // PIRTRAND.  We build transaction list trnList which is
            // used in next step to go through labeldo to determine
            // exact time the way is
            setll (muwhse:muemp#:musdte:mustim:muedte:muetim) multran3;
            badReadCnt = 0;
            dow forever = forever;
              reade (muwhse:muemp#:musdte:mustim:muedte:muetim) multran3;
              if %eof(multran3);
                leave;
              endif;
              tsyear = %subst(%editc(musdte:'X'):1:4);
              tsmonth = %subst(%editc(musdte:'X'):5:2);
              tsday = %subst(%editc(musdte:'X'):7:2);
              tshour = %subst(%editc(mustim:'X'):1:2);
              tsmin = %subst(%editc(mustim:'X'):3:2);
              tssec = %subst(%editc(mustim:'X'):5:2);
              tsmsec='000000';
              wksts = %timestamp(tsdatetime);

              setll (muwhse:ptdshftday:mutrn#:muemp#:wksts) pirtrand5;
              dow forever = forever;
                reade (muwhse:ptdshftday:mutrn#:muemp#:wksts) pirtrand5;
                if %eof(pirtrand5);
                  sleep(1);
                  badReadCnt = badReadCnt + 1;
                  if badReadCnt > 20;
                    leave;
                  else;
                    setll (muwhse:ptdshftday:mutrn#:muemp#:wksts) pirtrand5;
                    iter;
                  endif;
                else;
                  // if record found, ensure it is proper
                  // status and has start and end timestamp
                  if p_ptdstat<'1' or p_ptdstat>'4' or p_ptdsts=noStamp or
                     p_ptdets=noStamp;
                    iter;
                  endif;
                endif;
                trnTotalSecs = trnTotalSecs + p_ptdsec;
                // Load transaction to be looped
                if trnList = *blanks;
                  trnList = %editc(p_ptdtran:'X');
                else;
                  trnList = %trim(trnList) + ',' + %editc(p_ptdtran:'X');
                endif;
                leave;
              enddo;     // ensure pirtrand exists and valid status
            enddo;   // loop multran
          else;
            // put just the one transaction in the trnList
            trnList = %editc(ptdtran:'X');
            trnTotalSecs = ptdsec;
            p_ptdempnum=ptdempnum;
            p_ptdets=ptdets;
            p_ptdsts=ptdsts;
          endif;

          // Now loop LABELDO for specific Transaction(s) for this
          // employee and this start and end time so we can loop and
          // determine true actual per each Transaction
          if ptdseli = 1;
            lboSecs = 0;
            // only selection currently is adding to ELSSTDDTL for Goal
            wkStart = p_ptdSts;
            setll (p_ptdempnum:p_ptdsts) labeldo2;
            dow forever = forever;
              reade (p_ptdempnum) labeldo2;
              if %eof(labeldo2);
                leave;
              endif;
              // when end time for transaction is exceeded we leave
              if lboaddts > p_ptdets;
                leave;
              endif;
              lboSecs = lboSecs + %diff(lboaddts:wkstart:*seconds);
              // now add to appropriate Transaction Totals in Array
              wkTrnKey = %editc(lboemp#:'X') + %char(p_ptdsts) +
                         %char(p_ptdets) + %editc(lbotrn#:'X');
              if %lookup(wkTrnKey:trnKey) = 0;
                trnCnt = trnCnt + 1;
                trnKey(trnCnt) = wkTrnKey;
                trnA(trnCnt)= %diff(lboaddts:wkstart:*seconds);
              else;
                trnA(%lookup(wkTrnKey:trnKey))= trnA(%lookup(wkTrnKey:trnKey))
                        + %diff(lboaddts:wkstart:*seconds);
              endif;
              // Format Actual Time in hh:mm:ss format
              trnAHMS(trnCnt) = fmtActHMS(trnA(%lookup(wkTrnKey:trnKey)));
              // loop ELSSTDDTL for goal time
              goalLBO = *on;
              getGoalTime();
            enddo;
            // Ensure lbo seconds match in total to sum of PIRTRAND
            // seconds.  Make adjustment to final transaction impacted
            // for this transaction/multi-transaction
            if lboSecs<>0 and lboSecs <> trnTotalSecs;
              trnA(%lookup(wkTrnKey:trnKey))= trnA(%lookup(wkTrnKey:trnKey))
                      + (trnTotalSecs - lboSecs);
              trnAHMS(%lookup(wkTrnKey:trnKey))=
                                fmtActHMS(trnA(%lookup(wkTrnKey:trnKey)));
            else;
              // When no labeldo time found we will just use the transaction
              // time and still calculate goal from transaction
              if lboSecs = 0;
                wkTrnKey = %editc(ptdempnum:'X') + %char(ptdsts) +
                           %char(ptdets) + %editc(ptdTran:'X');
                if %lookup(wkTrnKey:trnKey) = 0;
                  trnCnt = trnCnt + 1;
                  trnKey(trnCnt) = wkTrnKey;
                  trnA(trnCnt)= ptdsec;
                  trnAHMS(trnCnt)=fmtActHMS(trnA(trnCnt));
                  goalLBO = *off;
                  getGoalTime();
                else;
                  trnA(%lookup(wkTrnKey:trnKey))= trnA(%lookup(wkTrnKey:trnKey))
                                                  + ptdsec;
                  trnAHMS(%lookup(wkTrnKey:trnKey))=
                                    fmtActHMS(trnA(%lookup(wkTrnKey:trnKey)));
                endif;
              endif;
            endif;
          else;
            // will need to add code once we add other tasks to ELSSTDDTL
          endif;

      /end-free

     p getTransHrs     e

     *----------------------------------------------------------------
     *  getGoalTime - Get Goal Time for Ltrn/Label from Labeldo or
     *                only Transaction if not labeldo
     *----------------------------------------------------------------

     p getGoalTime     b
     d getGoalTime     pi

      /free
              if goalLBO;
                setll (lbowhse:lbotrn#:lbolbl#) elsstddtl1;
              else;
                setll (ptdwhse:ptdtran) elsstddtl1;
              endif;
              dow forever = forever;
                if goalLBO;
                  reade (lbowhse:lbotrn#:lbolbl#) elsstddtl1;
                else;
                  reade (ptdwhse:ptdtran) elsstddtl1;
                endif;
                if %eof(elsstddtl1);
                  leave;
                endif;
                // to be safe I do the lookup again but it should
                // be there from the actual just above so it should
                // fall to the else always at this point
                if %lookup(wkTrnKey:trnKey) = 0;
                  trnCnt = trnCnt + 1;
                  trnKey(trnCnt) = wkTrnKey;
                  trnG(trnCnt)= edsgoal + edrgoal;
                else;
                  trnG(%lookup(wkTrnKey:trnKey))= trnG(%lookup(wkTrnKey:trnKey))
                          + edsgoal + edrgoal;
                endif;
              enddo;
              // save last Labeldo time stamp to calculate difference
              // between it and next ending clock time
              if goalLBO;
                wkStart = lboaddts;
              else;
                wkStart = ptdets;
              endif;
      /end-free

     p getGoalTime     e

     *----------------------------------------------------------------
     *  fmtActHMS   Format Actual Seconds in HH:MM:SS
     *----------------------------------------------------------------

     p fmtActHMS       b
     d fmtActHMS       pi             8a
     d  iSecs                        13s 0

     *  Local Variables

     D hms             s              8

      /free
              // Format Actual Time in hh:mm:ss format
              wkSeconds=0;
              wkMinutes=0;
              wkHours=0;
              wkActualSecs = iSecs;
              monitor;
                wkHours = wkActualSecs/3600;
              on-error;
                wkHours=99;
              endmon;
              wkMinutes = (wkActualSecs - (wkHours * 3600)) / 60;
              wkSeconds = wkActualSecs - (wkHours*3600) - (wkMinutes*60);
              if wkHours<>0 or wkMinutes<>0 or wkSeconds<>0;
                hms = %editc(wkHours:'X') + ':'
                      + %editc(wkMinutes:'X') + ':'
                      + %editc(wkSeconds:'X');
              else;
                hms = *blanks;
              endif;

              return hms;

      /end-free

     p fmtActHMS       e

     *-----------------------------------------------------------------------
     *  fmtStrInList  -  Format incoming InList parm properly for iSeries SQL
     *-----------------------------------------------------------------------

     p fmtStrInList    b
     d fmtStrInList    pi           100
     d  iStrList                    100    value

     *  Local Variables

     D rtnList         s            100

      /free
              // Add quotes to incoming InList string from MRC
              if iStrList <> *blanks;
                // replace every occurrence of a comma with a ','
                // and lastly place a single quote on beginning
                // and end of string.  This ensures we have single
                // quotes around all the sent in character strings
                // in the list
                rtnList = iStrList;
                pos = %scan(comma: rtnList);
                rplcomma = sq + ',' + sq;
                dow pos > 0;
                  rtnList = %replace(rplcomma: rtnList: pos: 1) ;
                  if (pos+%len(rplcomma) > %len(rtnList));
                    pos = 0;
                  else;
                    pos = %scan(comma: rtnList: pos+%len(rplcomma));
                  endif;
                enddo;
              else;
                rtnList = *blanks;
              endif;

              // if string has non blank value then put single
              // quotes on begin and end of trimmed string
              if rtnList <> *blanks;
                rtnList = sq + %trim(rtnList) + sq;
              endif;

              return rtnList;

      /end-free

     p fmtStrInList    e

     *----------------------------------------------------------------
     *  DeleteRecs    Delete records for session id
     *----------------------------------------------------------------

     p DeleteRecs      b
     d DeleteRecs      pi

      /free

        exec sql delete from sum017
                 where smsessid = :pSessId or
                       smaddts < current timestamp - 360 MINUTES;

      /end-free

     p DeleteRecs      e

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
     *  ConvertField   Convert incoming field to DRI field
     *----------------------------------------------------------------

     p ConvertField    b
     d ConvertField    pi
     d  parmCount                     3  0
     d  parmName                     10    varying
     d  parmValue                   100    varying

      /free

       monitor;

         select;

           when parmName = 'whse';
             if parmValue = '';
               parmValue = '0';
             endif;
             pwhse =  %dec(parmValue: 3: 0);

           when parmName = 'frmdate';
             if parmValue = '';
               parmValue = '0';
             endif;
             pfrmDate =  %dec(parmValue: 8: 0);

           when parmName = 'todate';
             if parmValue = '';
               parmValue = '0';
             endif;
             ptoDate =  %dec(parmValue: 8: 0);

           when parmName = 'empnum';
            pEmpNum = %trim(parmValue);
            monitor;
              if %subst(pEmpNum:1:1)=',';
                %subst(pEmpNum:1:1)=' ';
                pEmpNum = %trim(pEmpNum);
              endif;
            on-error;
                pEmpnum = *blanks;
            endmon;

           when parmName = 'shft';
            pShft = fmtStrInlist(%trim(parmValue));
            monitor;
              if %subst(pShft:1:1)=',';
                pShft = %subst(pShft:2:%len(pShft));
              endif;
            on-error;
                pShft = *blanks;
            endmon;

           when parmName = 'crew';
            pCrew = fmtStrInList(%trim(parmValue));
            monitor;
              if %subst(pCrew:1:1)=',';
                pCrew = %subst(pCrew:2:%len(pCrew));
              endif;
            on-error;
                pCrew = *blanks;
            endmon;

           when parmName = 'task';
            pTask = fmtStrInList(%trim(parmValue));
            monitor;
              if %subst(pTask:1:1)=',';
                pTask = %subst(pTask:2:%len(pTask));
              endif;
            on-error;
                pTask = *blanks;
            endmon;

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

     p                 e

     *----------------------------------------------------------------
     *  ExtractParms   Extract parms from parameter string
     *----------------------------------------------------------------

     p ExtractParms    b
     d ExtractParms    pi

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

     p                 e

     *----------------------------------------------------------------
     *  ExtractParmStr   Extract parms from single parameter string
     *----------------------------------------------------------------

     p ExtractParmStr  b
     d ExtractParmStr  pi
     d  parmStr                     999    varying

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

     p                 e
