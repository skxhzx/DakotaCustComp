      /copy *libl/qcopysrc,hspecs
740aAh dftactgrp(*no)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  UT961    Save QTEMP/*ALL and send to PIRTFR on BFCDEV
     *  January 6, 2017
     *  Rod Roller
     *
     *  NOTE: Compile with DFTACTGRP(*NO)
     *
     *----------------------------------------------------------------
     *  Revisions
     *
740a *    11/06/20  RTR  7.40a
     *      - Changed to put date in description, change DEV2 to BFCDEV.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  Binding Directories
     h bnddir('BFCFTPBND')
     *----------------------------------------------------------------
     *  File Specs
     fut961fm   cf   e             workstn
     f                                     infds(infds)
     f                                     sfile(msgrec:msgk)
     *----------------------------------------------------------------
     *  Table and array definitions
     d ermsg           s             30    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Function prototypes
      /copy qcopysrc,p.ftpapi
     *----------------------------------------------------------------
     *  Called Program Prototypes
     d RunCmd          pr                  extpgm('QCMDEXC')
     d  parmcmd                     250
     d  parmlen                      15  5
     *----------------------------------------------------------------
     *  Standard variables and constants
      /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Program info data structure
      /copy qcopysrc,c#pgminfds
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10a
     D #msgid          s              7a
     D #msgtp          s              7a
     D #pgmq           s             10a
     D clear           s              5  0
     D cmdstr          S            250a
     D cmdlen          S             15p 5
     D cmdchk          s              8a
     D cmdtkn          s              1a
     D comand          s              5  0
     D e               s              2  0
     D ftp             S             10i 0
     D ftpreturn       S             10i 0
     D ftppwd          s             30a
     D ftppath         s             32a
     D ftpserver       s             30a   inz('173.15.82.115')
     D ftpuser         s             30a
     D ftplocal        s            256a
     D ftpremote       s            256a
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3a
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtnmsg          s            100a
     D sclear          s              1a
     D userok          s               n
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1    100
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   eval      *inlr = *on
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endsl
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       219198
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *  Screen 01 initialization
      /free
        begsr scr01i;

          nxtscr = '01 ';
740aD   //w1desc = %trim(w1user) + ' QTEMP save';
740aM     w1desc = %char(%dec(%date():*iso)) + ' QTEMP save';

        endsr;  // scr01i
      /end-free
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   eval      error = *off
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
      /free
        begsr zzchk1;
          error = *off;

          if w1file = *blanks;
            error = *on;
            *in21 = *on;
            *in01 = *on;
            errmsg = ermsg(1);
            exsr zm0105;
          endif;

          if w1user = *blanks;
            error = *on;
            *in22 = *on;
            *in02 = *on;
            errmsg = ermsg(2);
            exsr zm0105;
          endif;

          if w1pwd = *blanks;
            error = *on;
            *in23 = *on;
            *in03 = *on;
            errmsg = ermsg(3);
            exsr zm0105;
          endif;

        endsr;  // zzchk1
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZSEND   Connects to FTP Server and sends file
     *
      /free
        begsr zzSend;

          // Create local save file
          cmdstr = 'CRTSAVF FILE(PIRTFR/' + %trim(w1file)
                 + ') TEXT(' + quote + %trim(w1desc)
                 + quote + ') AUT(*ALL)';
          cmdlen = %len(%trim(cmdstr));
          monitor;
            RunCmd ( cmdstr : cmdlen );
          on-error;
            rtnmsg = 'Error creating local PIRTFR save file. See job log.';
            leavesr;
          endmon;

          // Log FTP to joblog
          ftp_log(*On);

          // Connect to server
          ftp = ftp_conn(%trim(ftpserver): %trim(ftpuser): %trim(ftppwd));
          if ftp < 0;
            // return error
            rtnmsg = 'Error connecting to server. See job log.';
            leavesr;
          endif;

          // make sure binary for save file
          ftp_binary(*on);

          // create matching DEV2 save file
          ftpreturn = ftp_rmtcmd(ftp: cmdstr);
          if ftpreturn < 0;
            rtnmsg = 'Error creating save file on DEV2. See job log.';
            leavesr;
          endif;

          // save QTEMP in save file
          cmdstr = 'SAVOBJ OBJ(*ALL) LIB(QTEMP) DEV(*SAVF) SAVF(PIRTFR/'
                 + %trim(w1file) + ') TGTRLS(*PRV)';
          cmdlen = %len(%trim(cmdstr));
          monitor;
            RunCmd ( cmdstr : cmdlen );
          on-error;
            rtnmsg = 'Error saving objects in QTEMP.';
            leavesr;
          endmon;

          // send local save file to DEV2
          ftplocal = '/QSYS.LIB/PIRTFR.LIB/' + %trim(w1file) + '.FILE';
          ftpremote = '/QSYS.LIB/PIRTFR.LIB/' + %trim(w1file) + '.FILE';
          ftpreturn = ftp_put(ftp: %trim(ftplocal): %trim(ftpremote));
          if ftpreturn < 0;
            rtnmsg = 'Error sending save file to DEV2. See job log.';
            leavesr;
          endif;

          // delete local save file
          cmdstr = 'DLTF FILE(PIRTFR/' + %trim(w1file) + ')';
          cmdlen = %len(%trim(cmdstr));
          monitor;
            RunCmd ( cmdstr : cmdlen );
          on-error;
            rtnmsg = 'Error deleting local PIRTFR save file. See job log.';
            leavesr;
          endmon;

        endsr;  // zzSend
      /end-free

     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      *in91 = *on
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     C                   exsr      scr01i
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     C                   eval      ftpuser = w1user
     C                   eval      ftppwd = w1pwd
     C                   exsr      zzsend
     *
     C                   if        rtnmsg <> *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = rtnmsg
     C                   exsr      zm0105
     C
     C                   else
     C                   endif
     *
     C     endupd        endsr

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Save file name cannot be blank.
User name cannot be blank.
Password cannot be blank.
