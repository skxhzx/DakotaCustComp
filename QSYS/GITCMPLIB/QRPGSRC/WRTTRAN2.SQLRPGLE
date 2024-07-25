      /copy qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *
     *  WRTTRAN2   Realtime gateway to WRTTRAND
     *  30 August 2012
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    08/30/12  DAS  6.40
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  File data data structure
     *----------------------------------------------------------------

     D ltdrec        E ds                  extname(logtrand) inz(*EXTDFT)

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

      /copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D  gMessage       s                   like(ltdmsg)
     D  gWait          s              2p 0
     D  jType          s              1
     D  return         s             10

     *----------------------------------------------------------------
     *  Data Queue Variables
     *----------------------------------------------------------------

     D  dqname         s             10
     D  dqlib          s             10
     D  dq2data        s            500
     D  dq3data        s             10
     D  dqlen          s              5  0
     D  dqwait         s              5  0
     D  dqorder        s              2
     D  dqkeylen       s              3  0
     D  dqkey          s              1
     D  dqsenderlen    s              3  0 inz(44)

     D  dqsenderinf    ds
     D    dqbytesrtn                  7p 0
     D    dqbytesavl                  7p 0
     D    dqjobname                  10
     D    dquser                     10
     D    dqjobnum                    6
     D    dqcurruser                 10

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z
     D ts              s               z

     D bfcoffset       s              3  0 inz(0)
     D ucOffset        s              3  0

     *----------------------------------------------------------------
     *  Data Queue Field Data Structure
     *----------------------------------------------------------------

     D  gdqParms       ds
     D   qCmd                        10
     D   qWait                        2s 0
     D   qWhse                        3s 0
     D   qTran#                       7s 0
     D   qFromDate                    8s 0
     D   qToDate                      8s 0
     D   qEmp#                        5s 0
     D   qFileType                    1
     D   qSentTS                       z

     *----------------------------------------------------------------
     *  Sub-procedure prototypes
     *----------------------------------------------------------------

     D CallWrtTran     pr

     d DQ3Clear        pr
     d DQ2Read         pr             1p 0
     d DQ3Read         pr             1p 0

     d GetCurrStamp    pr

     d LogIt           pr

     D QuitWrtTran     pr

     *----------------------------------------------------------------
     *  Called program prototypes
     *----------------------------------------------------------------

     D ChkActJob2      pr                  extpgm('CHKACTJOB2')
     D   pJobName                    10
     D   pReturn                     10

     D GetJType        pr                  extpgm('GETJTYPE')
     D   pJType                       1

     D WrtTranD        pr                  extpgm('WRTTRAND')
     D   pCmd                         8
     D   pWait                        2p 0
     D   pWhse                        3p 0
     D   pTran#                       7p 0
     D   pFromDate                    8p 0
     D   pToDate                      8p 0
     D   pEmp#                        5p 0
     D   pSentTS                       z

     D WrtTranP        pr                  extpgm('WRTTRANP')
     D   pCmd                         8
     D   pWait                        2p 0
     D   pWhse                        3p 0
     D   pTran#                       7p 0
     D   pFromDate                    8p 0
     D   pToDate                      8p 0
     D   pEmp#                        5p 0
     D   pSentTS                       z

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      none
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free
        *inlr = *on;

        gMessage = 'WRTTRAN2 (' + %trimr(#job) + ') started';
        LogIt();

        // We only want one instance of this job to be running.
        // Therefore, if it exists multiple times (this and another),
        // Then end the program by getting out.
        // We are assuming this was submitted by WRTTRAN1 with a specific job name.
        // Only check if running in batch.

        GetJType(jtype);
        if jType = '0';
          ChkActJob2(#job: return);
          if return = '*MULTIPLE';
            gMessage = 'WRTTRAN2 (' + %trimr(#job)
                     + ') ended - Already running';
            LogIt();
            return;
          endif;
        endif;

        // Clear any left over commands from WRTTRAN3 data queue.

        DQ3Clear();

        // Now we go into a loop waiting for something to do.

        // Set initiail wait time to 5 minutes
        // Can be changed by sending WAITmm to WRTTRAND3 data queue.

        gWait = 5;

        dow forever = forever;

          // Look for entry to send to WRTTRAND

          // Read timed out waiting for entry - Shut down program

          if DQ2Read() < 0;
            gMessage = 'WRTTRAN2 (' + %trimr(#job)
                     + ') ended - Wait time out (' + %char(gWait) + ')';
            LogIt();
            leave;
          endif;

          // Send entry to WRTTRAND for processing
          // 'READQ3' is sent by program TDEND2 to force us to read
          // the QUIT command sent to the WRTTRAND3 data queue. Without,
          // doing this, we may have to wait until the read timed out
          // before moving on to reading WRTTRAND3.

          if qCmd <> 'READQ3';
            CallWrtTran();
          endif;

          // See if we should shut down

          if DQ3Read() < 0;
            gMessage = 'WRTTRAN2 (' + %trimr(#job)
                     + ') ended - QUIT sent';
            LogIt();
            leave;
          endif;

        enddo;

        QuitWrtTran();

        return;

      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                      Sub Procedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  CallWrtTran   Call WRTTRAND or WRTTRANP
     *----------------------------------------------------------------

     p CallWrtTran     b
     d CallWrtTran     pi

     *  Local Variables

     D   pCmd          s             10
     D   pWait         s              2p 0
     D   pWhse         s              3p 0
     D   pTran#        s              7p 0
     D   pFromDate     s              8p 0
     D   pToDate       s              8p 0
     D   pEmp#         s              5p 0
     D   pSentTS       s               z

      /free

        pCmd       = qCmd;
        pWait      = qWait;
        pWhse      = qWhse;
        pTran#     = qTran#;
        pFromDate  = qFromDate;
        pToDate    = qToDate;
        pEmp#      = qEmp#;
        pSentTS    = qSentTs;

        if qFileType = 'P';
          WrtTranP (pCmd: pWait: pWhse: pTran#: pFromDate: pToDate:
                    pEmp#: pSentTS);
        else;
          WrtTranD (pCmd: pWait: pWhse: pTran#: pFromDate: pToDate:
                    pEmp#: pSentTS);
        endif;

      /end-free

     p CallWrtTran     e

     *----------------------------------------------------------------
     *  DQ2Read     Read WRTTRAND2 data queue
     *
     *    This queue is used to receive an entry to be passed on to
     *    the WRTTRAND program.
     *
     *----------------------------------------------------------------

     p DQ2Read         b
     d DQ2Read         pi             1p 0

     *  Local Variables

     D tempWait        s              5p 0
     D value           s                   like(dq2data)

      /free

        // Convert sent wait time into seconds.

        tempWait = gWait * 60;

        // Read entry from WRTTRAND2 data queue

      /end-free

     C                   call      'QRCVDTAQ'
     C                   parm      'WRTTRAND2'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dq2data
     C                   parm      tempWait      dqwait
     C                   parm      ' '           dqorder
     C                   parm      0             dqkeylen
     C                   parm      ' '           dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf

      /free

        // No entry found

        if dqlen = 0;
          return -1;
        endif;

        // Entry found - Check for special command

        qCmd = %subst(dq2data: 1 : dqlen);
        if qCmd = 'READQ3';
          return 0;
        endif;

        // Otherwise, move entry into data structure

        value = %subst(dq2data: 1 : dqlen);

        monitor;
          gdqParms = value;
        on-error;
          gMessage = 'Data error from WRTTRAND2: ' + value;
          LogIt();
        endmon;

        return 0;

      /end-free

     p DQ2Read         e

     *----------------------------------------------------------------
     *  DQ3Clear    Clear WRTTRAND3 data queue
     *----------------------------------------------------------------

     p DQ3Clear        b
     d DQ3Clear        pi

     C                   dou       dqlen = 0

     C                   call      'QRCVDTAQ'
     C                   parm      'WRTTRAND3'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dq3data
     C                   parm      0             dqwait

     C                   enddo

     p DQ3Clear        e

     *----------------------------------------------------------------
     *  DQ3Read     Read WRTTRAND3 data queue
     *
     *    This queue is used to bypass the parameter queue so we can
     *    end the program without needing to wait for everything on
     *    the parameter queue to be processed.
     *
     *----------------------------------------------------------------

     p DQ3Read         b
     d DQ3Read         pi             1p 0

     *  Local Variables

     D quitSent        s               n
     D value           s                   like(dq3data)
     D waitValue       s              2p 0

      /free

        quitSent = *off;

        // Start read loop for data queue

        dow forever = forever;

      /end-free

     C                   call      'QRCVDTAQ'
     C                   parm      'WRTTRAND3'   dqname
     C                   parm      '*LIBL'       dqlib
     C                   parm                    dqlen
     C                   parm                    dq3data
     C                   parm      0             dqwait
     C                   parm      ' '           dqorder
     C                   parm      0             dqkeylen
     C                   parm      ' '           dqkey
     C                   parm                    dqsenderlen
     C                   parm                    dqsenderinf

      /free

          // No entry found

          if dqlen = 0;
            if quitSent;
              return -1;
            else;
              return 0;
            endif;
          endif;

          // Entry found - Extract data

          value = %subst(dq3data: 1 : dqlen);

          // If QUIT is sent, set flag.
          // Don't return because we want to read everything from this queue

          if value = 'QUIT';
            quitSent = *on;
          endif;

          // If WAIT is sent, change global wait value
          // Don't return because we want to read everything from this queue

          if %subst(value:1:4) = 'WAIT';
            if %subst(value:5:2) <> ' ';
              monitor;
                waitValue = %dec(%subst(value:5:2):2:0);
              on-error;
              endmon;
              if waitValue > 0;
                gWait = waitValue;
              endif;
            endif;
          endif;

        enddo;

      /end-free

     p DQ3Read         e

     *----------------------------------------------------------------
     *  GetCurrStamp  Get current timestamps
     *----------------------------------------------------------------

     p GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p GetCurrStamp    e

     *----------------------------------------------------------------
     *  LogIt     Write/Update log record
     *----------------------------------------------------------------

     p LogIt           b
     d LogIt           pi

     *  Local Variables

     d zone            s              6
     d saveStamploc    s               z
     d saveStampsys    s               z
     d saveStampuc     s               z
     d nowSys          s               z
     d nowUC           s               z

      /free

        // Get current stamp

        GetCurrStamp();

        clear ltdrec;
        ltdnewrec = 1;
        ltdmsg = gMessage;
        ltdttlbeg = currStampSys;
        ltdttlbegu = currStampUC;
        ltduser = #user;
        ltdjob = #job;
        ltdjobnbr = #jobnbr;
        exec sql insert into logtrand values(:ltdrec);
        if sqlstt <> sqlSuccess;
        endif;

        return;

      /end-free

     p LogIt           e

     *----------------------------------------------------------------
     *  QuitWrtTran   Call WRTTRAND or WRTTRANP with *QUIT
     *----------------------------------------------------------------

     p QuitWrtTran     b
     d QuitWrtTran     pi

     *  Local Variables

     D   pCmd          s             10
     D   pWait         s              2p 0
     D   pWhse         s              3p 0
     D   pTran#        s              7p 0
     D   pFromDate     s              8p 0
     D   pToDate       s              8p 0
     D   pEmp#         s              5p 0
     D   pSentTS       s               z

      /free

        pCmd       = '*QUIT';

        if qFileType = 'P';
          WrtTranP (pCmd: pWait: pWhse: pTran#: pFromDate: pToDate:
                    pEmp#: pSentTS);
        else;
          WrtTranD (pCmd: pWait: pWhse: pTran#: pFromDate: pToDate:
                    pEmp#: pSentTS);
        endif;

      /end-free

     p QuitWrtTran     e
