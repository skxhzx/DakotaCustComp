      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RP320    Batch Reports - Run Scheduled Reports
     *  12 December 2012
     *  Rod Roller
     *
640 A*    12/12/12  RTR  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   uf   e           k disk
     Fbfcdebug  o  a e           k disk

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  File information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#file1ds

     *----------------------------------------------------------------
     *  Program information data structure
     *----------------------------------------------------------------

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  File field data structures
     *----------------------------------------------------------------

     D schrec        e ds                  extname(BATRPTSCH) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     d batrpt          s              1a
     d currdate        s               d   datfmt(*iso)
     d currtime        s               t
     d currruntime     s              4a
     d daywk           s              1s 0
     d dayweek         s              4a
     d debugflag       s              1a
     d lastruntime     s              4a
     d endrun          s              1a
     D pRunTyp         s             10a
     D pRptId          s             20a
     D pUser           s             10a
     D pOutq           s             10a
     D pParm           s            200a
     D pParm1          s             20a
     D pParm2          s             20a
     D pParm3          s             20a
     D pParm4          s             20a
     D pParm5          s             20a
     D pRetrn          s             10a
     D pMsgTxt         s            100a
     d nextmins        s              4s 0
     d nextruntime     s              4a
     d nexttime        s               t
     D $Retrn          s             10a
     D $MsgTxt         s            100a

     *----------------------------------------------------------------
     * Constants
     *----------------------------------------------------------------

     d quot            C                   ''''
     d semi            C                   ';'

     *----------------------------------------------------------------
     * Called Programs
     *----------------------------------------------------------------

     D runrpt          pr                  extpgm('RP300CL')
     D   pRunTyp                     10
     D   pRptId                      20
     D   pUser                       10
     D   pOutq                       10
     D   pParm                      200
     D   pRetrn                      10
     D   pMsgTxt                    100

     *----------------------------------------------------------------
     * Program Parms
     *----------------------------------------------------------------

     D rp320           pr                  extpgm('RP320')
     D   pNxtRun                      6
     D rp320           pi
     D   pNxtRun                      6

     *----------------------------------------------------------------
     * Parameters
     *
     *     pNxtRun - Returns time for next run
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------
      /free

        // Select reports needing to be run since last run
        SqlStmt = 'select * from batrptsch '
                + 'where brsdow IN(' + sq + '*ALL' + sq
                + ', ' + sq + %trim(dayweek) + sq + ')'
                + ' and brstime > ' + lastruntime
                + ' and brstime <= ' + currruntime;

        exec sql prepare rptstmt from :SqlStmt;
        exec sql declare rptcsr cursor for rptstmt;
        exec sql open rptcsr;

        exec sql fetch next from rptcsr
                 into :schrec;

        if sqlstt <> sqlSuccess;
          $Retrn = '*OK      ';
          $MsgTxt = 'No reports found for time range.';
        endif;

        dow sqlstt = sqlSuccess;

          $Retrn = '*OK      ';
          $MsgTxt = 'Reports submitted.';

          // Submit report
          pRunTyp = '*EMAILLIST';
          pRptId = brsrptid;
          pUser = brsusrid;
          pOutq = *blanks;
          pParm = *blanks;
          if brspar1 <> *blanks;
            pParm = '&' + %trim(brspar1);
            if brspar2 <> *blanks;
              pParm = %trim(pParm) + '&' + %trim(brspar2);
              if brspar3 <> *blanks;
                pParm = %trim(pParm) + '&' + %trim(brspar3);
                if brspar4 <> *blanks;
                  pParm = %trim(pParm) + '&' + %trim(brspar4);
                  if brspar5 <> *blanks;
                    pParm = %trim(pParm) + '&' + %trim(brspar5);
                  endif;
                endif;
              endif;
            endif;
          endif;
          pRetrn = *blanks;
          pMsgTxt = *blanks;
          callp runrpt(pRunTyp: PRptId: pUser: pOutq:
                       pParm: pRetrn: pMsgTxt);

          exec sql fetch next from rptcsr
                   into :schrec;
        enddo;

        exec sql close rptcsr;

        exsr wrtLastRun;
        exsr wrtDebug;

        pNxtRun = nextruntime + '00';
        *inlr = *on;

      /end-free

     *----------------------------------------------------------------
     *  wrtDebug  Write out debug record
     *
      /free
        begsr wrtDebug;

          if debugflag = 'Y';

            bdaddts = %timestamp();
            bdaddpgm = #pgm;
            bdaddcusr = #curruser;
            bdaddjusr = #user;
            bdaddjob = #job;
            bdaddnbr = #jobnbr;
            bdtype = $Retrn;
            bdvalues = $MsgTxt;
            write(e) bdrec;

          endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  wrtLastRun  Write last run time
     *
      /free
        begsr wrtLastRun;

        // Update Option record with run time
        chain (0:'*BATRPTD') options;
        if %found(options);
          %subst(opdata:30:4) = currruntime;
          update oprec;
        endif;

        nextruntime = %subst(%char(nexttime):1:2)
                    + %subst(%char(nexttime):4:2);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  *INZSR  Initialization subroutine
     *
      /free
        begsr *inzsr;

          // Get flags from OPTIONS
          chain (0:'*BATRPT ') options;
          if %found(options);
            batrpt = %subst(opdata:5:1);
            endrun = %subst(opdata:11:1);
            debugflag = %subst(opdata:19:1);
          else;
            batrpt = 'N';
            endrun = 'Y';
            debugflag = 'Y';
          endif;

          // If not configured for batch reports, exit.
          if batrpt <> 'Y';
            $Retrn = '*ERROR   ';
            $MsgTxt='Not configured for Batch Reports. Set up OPTIONS records.';
            exsr wrtDebug;
            *inlr = *on;
            return;
          endif;

          // If flagged to end, end.
          if endrun = 'Y';
            %subst(opdata:11:1) = 'N';
            update oprec;
            pNxtRun = '*END';
            $Retrn = '*ENDOK   ';
            $MsgTxt = 'Batch Process ended normally.';
            exsr wrtDebug;
            *inlr = *on;
            return;
          endif;

          // Set current run date/time
          currdate = %date();
          currtime = %time();
          currruntime = %subst(%char(currtime):1:2)
                      + %subst(%char(currtime):4:2);

          // Get run times from OPTIONS
          chain (0:'*BATRPTD') options;
          if %found(options);
            lastruntime = %subst(opdata:30:4);
            nextmins = %dec(%subst(opdata:44:4):4:0);
          else;
            lastruntime = %subst(%char(currtime):1:2)
                        + %subst(%char(currtime):4:2);
            nextmins = 5;
          endif;

          // If hasn't been run since prior day, only run since midnight
          if lastruntime > currruntime;
            lastruntime = '0000';
          endif;

          // Compute next run time to return to CL
          nexttime = %time() + %minutes(nextmins);

          // Determine the current day of week for selection
          daywk = %rem (%diff (%date(): d'1800-01-05': *days): 7);
          select;
            when daywk = 0;
              dayweek = '*SUN';
            when daywk = 1;
              dayweek = '*MON';
            when daywk = 2;
              dayweek = '*TUE';
            when daywk = 3;
              dayweek = '*WED';
            when daywk = 4;
              dayweek = '*THU';
            when daywk = 5;
              dayweek = '*FRI';
            when daywk = 6;
              dayweek = '*SAT';
          endsl;

        endsr;
      /end-free
