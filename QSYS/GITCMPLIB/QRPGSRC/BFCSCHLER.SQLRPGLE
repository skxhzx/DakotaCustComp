     H copyright('(c) Copyright BFC Software, Inc - 2003')
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     F*----------------------------------------------------------------
     F*   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     F*   BFC Software, Inc.
     F*----------------------------------------------------------------
     F*
     F*  BFCSCHLER   Submit Report Scheduling Program
     F*  20 November 2018
     F*  Kenneth Elder
     F*
     F*  Revisions
     F*
720 AF*    11/20/18  KDE  7.20
     F*      - Created.
730 AF*    04/12/19  KDE  7.30
     F*      - Remove OPDEML since dropped from options
     *
     *----------------------------------------------------------------

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D oprec         E Ds                  Extname(Options)

      *------------------------------------------------------------------
      * Misc. Variables
      *------------------------------------------------------------------
710bAD sq              c                   Const('''')
     d cmdString       s          10000

     *----------------------------------------------------------------
    *  *MRCRPT  -  MRC Report Scheduling Options
     *----------------------------------------------------------------
    *
    * Fields
    *
    *    OPIP    -  IP address for Tomcat Server
    *    OPPORT  -  IP Port for Tomcat Server
    *    OPDPRT  -  Default Printer (Used when one not supplied)
    *    OPGSDV  -  Ghostscript Device
    *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
    *    OPCPRE  -  Customer Prefix (3 characters)
    *    OPMUSR  -  Mrc User.  Found on iSeries and in MRC Spring Context
    *    OPJOBD  -  Jod Description used for this submit
    *    OPDBSRC -  MRC Datasource for Report Calling to Use
     *
     *----------------------------------------------------------------

     D opdata1         ds
     D  opip                   1     15
     D  opport                16     20  0
     D  opdprt                21     30
     D  opgsdv                31     39
     D  opmusr                40     49
     d  opcpre                50     52
     d  opjobd                53     62
     d  opdbsrc               63     92
     *----------------------------------------------------------------
     *  Program info data structure
     *------------------------------------------------------------------
     D                SDS
     D  #PROG            *PROC
     D  #JOB                 244    253
     D  #USER                254    263
     D  #JOBN                264    269
     D  #JOBDT               276    281  0
     D  #JOBTM               282    287  0

      *----------------------------------------------------------------
      * Function prototypes.
      *----------------------------------------------------------------

     D GoCmd           PR            10I 0 Extproc('system')
     D   CmdString                     *   Value
     D                                     Options(*String)
     D NullString      C                   -1
     D Success         C                   0
     D ObjectNotFound  C                   'CPF3142'
     D ObjectInUse     C                   'CPF3156'
     D Errmsgid        S              7    Import('_EXCP_MSGID')
     D Returncode      S             10I 0
     *----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      pCommand   S-Start, E-End, I-Inquiry
     C*
     C*    Returned Parameters
     C*      pRetrn     necting port to use.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *entry        PLIST
     C                   PARM                    pCommand          1
     C                   PARM                    pReturn         100

      /free
         // Either Start, End or Display active job based on request
         // get option record for customer prefix
         exec sql select * into :oprec
                  from options
                   where opcode='*MRCRPT'
                 order by opwhse
                  fetch first row only;
         if sqlStt = '00000';
            opdata1 = opdata;
         endif;
         pReturn=*blanks;
         select;
           when pCommand = 'S';     //Start
              exsr strSchler;
           when pCommand = 'E';     //End
              exsr endSchler;
           when pCommand = 'I';     //Return Active Job
              exsr rtnJob;
         endsl;
         *inlr = *on;

      /end-free

      ****************************************************************************************
      **  strSchler - Start Scheduler                                                       **
      ****************************************************************************************
      /free
        begsr strSchler;
           // check whether running or not
           if sqlStt <> '00000';
              pReturn = 'MRC Reporting Options not found.  Please setup';
           else;
              if opcpre = *blanks;  // Customer Prefix to be used in Scheduled job
                 pReturn = 'MRC Reporting Options Customer prefix cannot be'
                         + ' blank';
              else;
                 exsr rtnJob;
                 if pStatus = '*NOTEXIST';
                    // submit report scheuler
                    cmdString = 'SBMJOB CMD(CALL PGM(MRCRPTSCH) PARM(X' + sq +
                      %editc(opWhse:'X') + 'F' + sq + ' ' + sq +
                      'SCHEDULER' + sq + ' ' + sq + ' ' + sq
                       + ' ' + sq + ' ' + sq
                       + ' ' + sq + ' ' + sq
                       + ' ' + sq + ' ' + sq + ')) JOB(' +
                       %trim(opcpre) + 'SCHLER) JOBQ(QSYSNOMAX)';
                       returnCode = GoCmd(%trim(cmdString));
                 else;
                   pReturn = ' MRC Report Scheduler is already running';
                 endif;
              endif;
           endif;
        endsr;
      /end-free

      ****************************************************************************************
      **  RtnJob - Return Active job if running                                             **
      ****************************************************************************************
      /free
        begsr rtnJob;
          // is job running?
      /end-free
     c                   eval      pJob = %trim(opcpre)
     c                   call      'CHKRPTSCH'
     c                   parm                    pJob             10
     c                   parm                    pStatus          10
      /free
        endsr;
      /end-free

      ****************************************************************************************
      **  endSchler - End Scheduler                                                         **
      ****************************************************************************************
      /free
        begsr endSchler;
          // End Scheduler if found
          exsr rtnJob;
          if pStatus = '*EXIST';
             // End job and send message as such
             pReturn = 'MRC Report Scheduler has been terminated';
              cmdString = 'CALL PGM(MRCRPTSCH) PARM(X' + sq +
                %editc(opWhse:'X') + 'F' + sq + ' ' + sq +
                '*END' + sq + ' ' + sq + ' ' + sq
                 + ' ' + sq + ' ' + sq
                 + ' ' + sq + ' ' + sq
                 + ' ' + sq + ' ' + sq + ')';
                 returnCode = GoCmd(%trim(cmdString));
          else;
             // Job not running.  Simply return message as such
             pReturn = 'MRC Report Scheduler is not running';
          endif;
        endsr;
      /end-free
