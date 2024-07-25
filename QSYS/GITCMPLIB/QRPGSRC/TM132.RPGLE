      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   24 N. Washington Ave #203
     *   Batavia, IL 60510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TM132     Truck pallet detail maintenance - Change
     *  30 May, 1997
     *  Roxanne Harrison
     *
     *  Revisions
     *
406 A*    09/24/97  RH   4.06
     *      - Don't allow duplicate unload seq # for a compartment.
413 A*    02/07/00  RH   4.13
     *      - Recompile to for 4.06 change.
     *
416 A*    02/11/02  MLB  4.16
     *      - Revised to call correct program. Should call
     *        TM910 instead of TP900.
     *      - Revised to add warehouse to key for TRKCOMP.
510aA*    07/05/06  RH   5.10a
     *      - ENH: Change code for JAVA conversion to loop to start
     *        of IF for UPAGN1 and UPAGN2 tag. Add UPAGN3 and UPAGN4
     *
510bA*    07/06/06  DAS  5.10b
     *      - Revised the 510a code to make it movre Java compatible.
     *
510CA*    01/18/07  JCJ  5.10c
     *      - Revised to not allow unload sequence greater than 50.
     *
510dA*    09/10/07  LMC  5.10d
     *      - Added edit for unload sequence = 0
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
     *  File Specs
     *
     Ftm132fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Ftruckd    uf a e           k disk
     F                                     rename(tdrec:record)
     Fwarehs    if   e           k disk
     Ftrkcomp   if   e           k disk
406 AFtruckd1   if   e           k disk
     *RUCKD  IF  E           K        DISK
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(3) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
     *
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $ptruk                22     31
     D  $prow                 32     33  0
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd6i                19     24
     D  $cvd8i                25     32
     D  $cvd6o                33     38  0
     D  $cvd8o                39     46  0
     D  $cvsto                47     64
     D  $cvrtn                65     72
     D  $cverm                73    132
     D  $cvmsg                73     76
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     *
416 D*                                      19  19 $LCOMP
416 MD  $lcomp                22     22
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertruk                 1     10
     D  erdesc                11     30
     *
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
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
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
     * Work Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D $pprg1          s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D count           s              1  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D kycomp          s                   like(tpcode)
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D svcom1          s                   like(w1com1)
     D svcom2          s                   like(w1com2)
     D svcub1          s                   like(w1cub1)
     D svcub2          s                   like(w1cub2)
     D svseq1          s                   like(w1seq1)
     D svseq2          s                   like(w1seq2)
     D ukrow           s                   like($prow)
     D ukwhse          s                   like($pwhse)
     D warn            s              1
     D wocom           s                   like(w1com1)
     D woseq           s                   like(w1seq1)
     D w1col           s              1  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *IBEFORE - Insert new row before row #.
     *              *IAFTER  - Insert new row after row #.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303132
     C                   setoff                                       333435
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
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
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C     end02i        endsr
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
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
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
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
221 D*R         $PCMD     OREQ '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     '1'           endsc1
     C                   endif
     *
     C                   if        $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so get out of program.
     *
221 AC                   if        $pcmd = '*ADD    '
221 AC                   add       1             ukrow
221 AC                   add       1             worow
221 AC                   exsr      scr01i
221 AC                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     '1'           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     '1'           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
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
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     C                   eval      $pprg = #prog
     C                   eval      $pprg1 = #prog
     C                   eval      $lprg = #prog
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
     C                   parm                    #pgmq
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
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = desc(1)
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  TRUCK cannot be blank
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc(1)       errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7982  Record changed by another user before update.
     *
     C     zm82          begsr
     C                   eval      #msgid = 'PIR7982'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
406 A*----------------------------------------------------------------
406 A*   TM13201  Unload sequence already exists for compartment.
406 A*
406 AC     zm3201        begsr
406 AC                   eval      #msgid = 'TM13201'
406 AC                   eval      #msgtp = '*DIAG  '
406 AC                   eval      $md = *blanks
404 AC                   movea     errmsg        $md(1)
406 AC                   exsr      zmpmsg
406 AC                   endsr
510dA*----------------------------------------------------------------
510dA*   PIR0147  Unload sequence 0 is invalid
510dA*
510dAC     zm0147        begsr
510dAC                   eval      #msgid = 'PIR0147'
510dAC                   eval      #msgtp = '*DIAG  '
510dAC                   eval      $md = *blanks
510dAC                   movea     errmsg        $md(1)
510dAC                   exsr      zmpmsg
510dAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
     *
     *    Make sure code was entered.
     *
221 D*R         W1HTRU    IFEQ *BLANKS
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN21
     *R                   EXSR ZM01
     *R                   END
     *
     *    Make sure code doesn't already exist.
     *
     *R                   MOVE W1HTRU    $PTRUK
     *R         FILEKY    CHAINRECORD              N79
     *R         *IN79     IFEQ *OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE *ON       *IN21
     *R                   EXSR ZM02
     *R                   END
     *R                   END
     *
     C                   endif
     *
     *    Make sure compartment was entered.
     *
     C                   if        w1com1 = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Compartment code.
     *
     C                   if        w1com1 <> *blanks
416 AC                   eval      kycomp = w1com1
416 D*R         W1COM1    CHAINTRKCOMP              79
416 MC     tpkey         chain     trkcomp                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     *    Make sure compartment was entered.
     *
     C                   if        w1com2 = *blanks
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Compartment code.
     *
     C                   if        w1com2 <> *blanks
416 AC                   eval      kycomp = w1com2
416 D*R         W1COM2    CHAINTRKCOMP              79
416 MC     tpkey         chain     trkcomp                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
     C                   endif
510dA*
510dA*  Unload sequence can not be zero
510dA*
510dAC                   if        w1seq1 = 0
510dAC                   eval      error = *on
510dAC                   eval      *in24 = *on
510dAC                   eval      *in04 = *on
510dAC                   move      ' '           errmsg
510dAC                   exsr      zm0147
510dAC                   endif
510dA*
510dAC                   if        w1seq2 = 0
510dAC                   eval      error = *on
510dAC                   eval      *in27 = *on
510dAC                   eval      *in07 = *on
510dAC                   move      ' '           errmsg
510dAC                   exsr      zm0147
510dAC                   endif
406 A*
406 A*  Verify Unload sequence's entered for row aren't the same.
406 A*
406 A*    For SEQ# 1
406 AC                   if        w1seq1 = w1seq2  and
406 AC                             w1com1 = w1com2
406 AC                   eval      error = *on
406 AC                   eval      *in24 = *on
406 AC                   eval      *in27 = *on
406 AC                   eval      *in04 = *on
406 AC                   eval      errmsg = *blanks
406 AC                   exsr      zm3201
406 AC                   endif
406 A*
406 A*  Verify Unload sequence for compartment doesn't exist.
406 A*
406 A*    For SEQ# 1
406 AC                   if        w1seq1 <> 0
510cAC                   if        w1seq1 > 50
510cAC                   eval      error = *on
510cAC                   eval      *in24 = *on
510cAC                   eval      *in04 = *on
510cAC                   eval      errmsg = *blanks
510cAC                   eval      errmsg = desc(2)
510cAC                   exsr      zm0105
510cAC                   goto      endck1
510cAC                   endif
406 AC                   eval      wocom = w1com1
406 AC                   eval      woseq = w1seq1
406 AC     tseqky        setll     truckd1
406 AC                   dow       forevr = forevr
406 AC     tseqky        reade     truckd1                                79
406 AC                   if        *in79
406 AC                   leave
406 AC                   else
406 AC                   if        tdrow = worow
406 AC                   iter
406 AC                   else
406 AC                   eval      error = *on
406 AC                   eval      *in24 = *on
406 AC                   eval      *in04 = *on
406 AC                   eval      errmsg = *blanks
406 AC                   exsr      zm3201
406 AC                   leave
406 AC                   endif
406 AC                   endif
406 AC                   enddo
406 AC                   endif
406 A*
406 A*
406 A*    For SEQ# 2
406 AC                   if        w1seq2 <> 0
510cAC                   if        w1seq2 > 50
510cAC                   eval      error = *on
510cAC                   eval      *in27 = *on
510cAC                   eval      *in07 = *on
510cAC                   eval      errmsg = *blanks
510cAC                   eval      errmsg = desc(2)
510cAC                   exsr      zm0105
510cAC                   goto      endck1
510cAC                   endif
406 AC                   eval      wocom = w1com2
406 AC                   eval      woseq = w1seq2
406 AC     tseqky        setll     truckd1
406 AC                   dow       forevr = forevr
406 AC     tseqky        reade     truckd1                                79
406 AC                   if        *in79
406 AC                   leave
406 AC                   else
406 AC                   if        tdrow = worow
406 AC                   iter
406 AC                   else
406 AC                   eval      error = *on
406 AC                   eval      *in27 = *on
406 AC                   eval      *in07 = *on
406 AC                   eval      errmsg = *blanks
406 AC                   exsr      zm3201
406 AC                   leave
406 AC                   endif
406 AC                   endif
406 AC                   enddo
406 AC                   endif
     *
     C                   if        $pcmd = '*CHANGE '
     *
     *  Check if record was changed since we read.
     *
     C                   eval      w1col = 1
     C     fileky        chain(n)  record                             79
     *
     *    Record not found.
     *
     C                   if        *in79
     C                   eval      tdcomp = *blanks
     C                   eval      tdcube = 0
     C                   eval      tdpick = 0
     C                   endif
     *
     *    See if fields changed.
     *
     C                   if        ovrrid = *off
     C                   if        tdcomp <> svcom1  or
     C                             tdcube <> svcub1  or
     C                             tdpick <> svseq1
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   exsr      zm82
     C                   goto      endck1
     C                   endif
     C                   endif
510cAC                   if        w1seq1 > 50
510cAC                   eval      error = *on
510cAC                   eval      *in24 = *on
510cAC                   eval      *in04 = *on
510cAC                   eval      errmsg = *blanks
510cAC                   eval      errmsg = desc(2)
510cAC                   exsr      zm0105
510cAC                   goto      endck1
510cAC                   endif
     *
     C                   eval      w1col = 2
     C     fileky        chain(n)  record                             79
     *
     *    Record not found.
     *
     C                   if        *in79
     C                   eval      tdcomp = *blanks
     C                   eval      tdcube = 0
     C                   eval      tdpick = 0
     C                   endif
     *
     *    See if fields changed.
     *
     C                   if        ovrrid = *off
     C                   if        tdcomp <> svcom2  or
     C                             tdcube <> svcub2  or
     C                             tdpick <> svseq2
     C                   eval      warn = *on
     C                   eval      error = *on
     C                   exsr      zm82
     C                   goto      endck1
     C                   endif
     C                   endif
510cAC                   if        w1seq2 > 50
510cAC                   eval      error = *on
510cAC                   eval      *in27 = *on
510cAC                   eval      *in07 = *on
510cAC                   eval      errmsg = *blanks
510cAC                   eval      errmsg = desc(2)
510cAC                   exsr      zm0105
510cAC                   goto      endck1
510cAC                   endif
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Truck compartment 1
     *
     C                   when      row# = 10  and
416 AC                             col# = 28
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
416 AC                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1com1
416 D*R                   CALL 'TP900'
416 MC                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1com1 = $lcomp
     C                   endif
     *
     *     Truck compartment 2
     *
416 D*R         ROW#      WHEQ 13
416 MC                   when      row# = 10  and
416 AC                             col# = 51
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
416 AC                   eval      $lwhse = $pwhse
     C                   eval      $lcomp = w1com1
416 D*R                   CALL 'TP900'
416 MC                   call      'TM910'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1com2 = $lcomp
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   goto      endcm1
     C                   endsl
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1com1 = *blanks
     C                   eval      w1cub1 = 0
     C                   eval      w1seq1 = 0
     C                   eval      w1com2 = *blanks
     C                   eval      w1cub2 = 0
     C                   eval      w1seq2 = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     *R         $PCMD     IFEQ '*VIEW   '
     *R         FILEKY    CHAINRECORD              N7978
     *R                   ELSE
     *R         FILEKY    CHAINRECORD               7978
     *R                   ENDIF
     *
     *  Record locked.
     *
     *R         *IN78     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   MOVE '*PGMQ   '$PRTN
     *R                   EXSR ZM74
     *R                   GOTO ENDGT1
     *R                   END
     *
     *  Record not found.
     *
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   MOVE '*PGMQ   '$PRTN
     *R                   EXSR ZM73
     *R                   GOTO ENDGT1
     *R                   END
     *******************
221 A*    Code to use to read two records and display as one.
     C                   eval      w1col = 1
     C     fileky        chain(n)  record                             79
     C                   if        not *in79
     C                   eval      w1com1 = tdcomp
     C                   eval      w1cub1 = tdcube
     C                   eval      w1seq1 = tdpick
     C                   eval      ukwhse = tdwhse
     C                   eval      ukrow = tdrow
     C                   else
     C                   eval      w1com1 = *blanks
     C                   eval      w1cub1 = 0
     C                   eval      w1seq1 = 0
     C                   endif
     *R
     C                   eval      w1col = 2
     C     fileky        chain(n)  record                             79
     C                   if        not *in79
     C                   eval      w1com2 = tdcomp
     C                   eval      w1cub2 = tdcube
     C                   eval      w1seq2 = tdpick
     C                   else
     C                   eval      w1com2 = *blanks
     C                   eval      w1cub2 = 0
     C                   eval      w1seq2 = 0
     C                   endif
     C                   eval      svcom1 = w1com1
     C                   eval      svcub1 = w1cub1
     C                   eval      svseq1 = w1seq1
     C                   eval      svcom2 = w1com2
     C                   eval      svcub2 = w1cub2
     C                   eval      svseq2 = w1seq2
221 D*R         TMKEY     SETGTRECORD
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 1.
     *
     C     zzget2        begsr
     *
     *   Get record from main file.
     *
     C     fileky        chain     record                             7978
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
221 D*R                   KFLD           $PROW
     C                   kfld                    ukrow
221 AC                   kfld                    w1col
     *
     *  Define partial key for main file.
     *
     C     partky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptruk
     *
406 A*  Define key for TRUCKD1 file.
406 A*
406 AC     tseqky        klist
406 AC                   kfld                    $pwhse
406 AC                   kfld                    $ptruk
406 AC                   kfld                    wocom
406 AC                   kfld                    woseq
416 A*
416 A*  Define key for TRKCOMP file.
416 A*
416 AC     tpkey         klist
416 AC                   kfld                    $pwhse
416 AC                   kfld                    kycomp
     *
     *R         *LIKE     DEFN TDROW     WOROW
     *
406 AC                   eval      forevr = *off
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     C                   eval      wotruk = $ptruk
     C                   select
     C                   when      $pcmd = '*IAFTER '
     C     $prow         add       1             worow
     *R
     C                   when      $pcmd = '*IBEFORE'
     C                   eval      worow = $prow
     *R
     C                   when      $pcmd = '*ADD    '
     C     $prow         add       1             worow
     *R
     C                   other
     C                   eval      worow = $prow
     C                   endsl
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     C                   eval      ukrow = $prow
     *
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZISRT   Insert new row, move necessary existing rows.
     *
     C     zzisrt        begsr
     *
     *   Increment existing rows to make space for insert row.
     *
     C                   if        $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
     C     partky        setgt     record
     C                   eval      stop = *off
     C                   dou       stop = '1'
     C     partky        readpe    record                                 79
     C                   if        *in79
     C                   eval      stop = *on
     C                   goto      endis
     C                   endif
     C                   if        tdrow < worow
     C                   eval      stop = *on
     C                   goto      endis
     C                   endif
     C                   add       1             tdrow
     C                   update    record                               76
     C                   if        *in76
     C                   eval      stop = *on
     C                   goto      endis
     C                   endif
     C     endis         tag
     C                   enddo
     C                   unlock    truckd                               97
     *R
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   if        $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
     C                   exsr      zzisrt
     C                   endif
     *
510bMC     1             do        2             count
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
510bD**                   Z-ADD0         TDCOL
     C                   eval      tdwhse = $pwhse
     C                   eval      tdtruk = $ptruk
     C                   eval      tdrow = worow
510bD**         UPAGN1    TAG
510bD**                   ADD  1         TDCOL
510bMC                   eval      tdcol = count
     C                   if        tdcol = 1
     C                   eval      tdcomp = w1com1
     C                   eval      tdcube = w1cub1
     C                   eval      tdpick = w1seq1
     C                   else
     C                   eval      tdcomp = w1com2
     C                   eval      tdcube = w1cub2
     C                   eval      tdpick = w1seq2
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*CHANGE '
510bD**         UPAGN2    TAG
510bD**                   ADD  1         W1COL
510bMC                   eval      w1col = count
     C     fileky        chain     record                             79
     C                   if        w1col = 1
     C                   eval      tdcomp = w1com1
     C                   eval      tdcube = w1cub1
     C                   eval      tdpick = w1seq1
     C                   else
     C                   eval      tdcomp = w1com2
     C                   eval      tdcube = w1cub2
     C                   eval      tdpick = w1seq2
     C                   endif
     C                   endif
     *
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*IBEFORE'  or
     C                             $pcmd = '*IAFTER '
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endup1
     C                   endif
510aD**         TDCOL     CABEQ1         UPAGN1
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup1
     C                   endif
510aD**         TDCOL     CABEQ1         UPAGN2
     C                   endif
     *
510bAC                   enddo
     *
     *   Move key values to parameters
     *
     C                   eval      $prow = tdrow
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Compartment
Unload sequence can not exceed 50.

