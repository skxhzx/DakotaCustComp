      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2014 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  TR122    Trax Options by Customer - change
     *  05 Dec 2014
     *  Retha Davis
     *
     *----------------------------------------------------------------
     *  Revisions
     *
650 A*    12/05/14  RBD  6.50
     *      - Created.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 42   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Ftr122FM   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Foptionc   uf a e           k disk
     F                                     rename(opcrec:record)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(16) ctdata perrcd(1)
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
     D  $pcust                22     32  0
     *
     *----------------------------------------------------------------
     *  *TRAX  -  TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCCWR  -  Catch weight required
     *    OPCBDA  -  Breakdowns allowed
     *    OPCGBD  -  Generic breakdown allowed
     *    OPCRTQ  -  Pre-trip questions
     *    OPCOTQ  -  Post-trip questions
     *    OPCCCE  -  Credit card enabled
     *    OPCSIG  -  Signature enabled
     *    OPCPIV  -  Print invoice
     *    OPCSDA  -  Send data after stop
     *    OPCARE  -  Add return enabled
     *    OPCPAL  -  Pallets enabled
     *    OPCBUL  -  Bulk items enabled
     *    OPCGSS  -  GS1 scanning
     *    OPCGSU  -  GS1 unique
     *    OPCNSR  -  Non scan reason prompt.
     *    OPCFBD  -  Filter by department.
     *
     * Data structure
     *
     D opcdta          ds
     D  opccwr                 5      5
     D  opcbda                14     14
     D  opcgbd                15     15
     D  opcrtq                16     16
     D  opcotq                17     17
     D  opccce                18     18
     D  opcsig                19     19
     D  opcpiv                20     20
     D  opcsda                21     21
     D  opcare                76     76
     D  opcpal                79     79
     D  opcbul                82     82
     D  opcgss                89     89
     D  opcgsu                90     90
     D  opcnsr               100    100
     D  opcfbd               101    101
     D  opcend               117    117
     *----------------------------------------------------------------
     *  *TRAX1    -  More TRAX options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPCER   -  Email receipt.
     *    OPCREF  -  Receipt email from.
     *    OPCRES  -  Receipt email subject.
     *
     * Data structure
     *
     D opcdta1         ds
     D  opcer                  1      1
     D  opcref                 2     61
     D  opcres                62    116
     D  opcend1              117    117
     *
     *----------------------------------------------------------------
     *  Called program parameters
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  erUser                 1     10
     D  erAction              11     40
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
     *  Variables
     *
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D tmpflg          s              1
     D w3trdtAlpha     s              4
     D warn            s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *CHANGE  - Change record.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains unique key for everything but *ADD.
     *
     *    Returned Parameters
     *      $PUKY   Contains new unique key for *ADD.
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
     *
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     'WIN'         scWin
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
     C                   when      nxtscr = '05 '
     C                   exfmt     screen5                              50
     C                   when      nxtscr = 'WIN'
     C                   exfmt     delwdw                               50
     C                   endsl
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
     C                   setoff                                       394041
     C                   setoff                                       424344
     C                   setoff                                       454647
     C                   setoff                                       4849
     C                   setoff                                       5152
     C                   setoff                                       5354
     C                   setoff                                       555657
     C                   setoff                                       606162
     C                   setoff                                       636465
     C                   setoff                                       66
     C                   setoff                                       676869
     C                   setoff                                       707172
     C                   setoff                                       737475
     C                   setoff                                       767780
     C                   setoff                                       818283
     C                   setoff                                       8485
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
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     *
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft5
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget5
     C                   exsr      zzfil5
     C                   endif
     C     end05i        endsr
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
     *  Test for F10 - Delete customer options.
     *
     C                   if        *inkj
     C                   eval      nxtscr = 'WIN'
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
     C                             $pcmd = '*CHANGE '
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
     *  Display screen 5.
     C                   exsr      scr05i
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr05i
     C                   endif
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     record
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     C                   endif
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SCWIN  -  Screen window
     *
     C     scWin         begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endscWin
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endscWin
     C                   endif
     *
     *  Some other key pressed.
     *
     *     Delete record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzupdWin
     C     error         cabeq     *on           endscWin
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endscWin      endsr
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
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
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7975  Error while deleting record.
     *
     C     zm75          begsr
     C                   eval      #msgid = 'PIR7975'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR9803  Deleted record successfully.
     *
     C     zm9803        begsr
     C                   eval      #msgid = 'PIR9803'
     C                   eval      #msgtp = '*DIAG  '
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0148  User not authorized to use ...
     *
     C     ZM0148        BEGSR
     C                   MOVE      'PIR0148'     #MSGID
     C                   MOVE      '*DIAG  '     #MSGTP
     C                   MOVEA     ERRMSG        $MD(1)
     C                   EXSR      ZMPMSG
     C                   ENDSR
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify breakdowns allowed.
     *
     C                   if            w1tbda <> 'Y'
     C                             and w1tbda <> 'N'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify send data after stop.
     *
     C                   if            w1tsda <> 'Y'
     C                             and w1tsda <> 'N'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify add return enabled.
     *
     C                   if            w1tare <> 'Y'
     C                             and w1tare <> 'N'
     C                   eval      error = *on
     C                   eval      *in49 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify catchweight required.
     *
     C                   if            w1tcwr <> 'Y'
     C                             and w1tcwr <> 'N'
     C                   eval      error = *on
     C                   eval      *in40 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify generic breakdown allowed.
     *
     C                   if            w1tgbd <> 'Y'
     C                             and w1tgbd <> 'N'
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Pallets enabled.
     *
     C                   if            w1tpal <> 'Y'
     C                             and w1tpal <> 'N'
     C                   eval      error = *on
     C                   eval      *in53 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify pre-trip questions.
     *
     C                   if            w1trtq <> 'Y'
     C                             and w1trtq <> 'N'
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify Bulk items enabled.
     *
     C                   if            w1tbul <> 'Y'
     C                             and w1tbul <> 'N'
     C                   eval      error = *on
     C                   eval      *in56 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify post-trip questions.
     *
     C                   if            w1totq <> 'Y'
     C                             and w1totq <> 'N'
     C                   eval      error = *on
     C                   eval      *in37 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify GS1 scanning.
     *
     C                   if            w1tgss <> 'Y'
     C                             and w1tgss <> 'N'
     C                   eval      error = *on
     C                   eval      *in63 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify credit card enabled.
     *
     C                   if            w1tcce <> 'Y'
     C                             and w1tcce <> 'N'
     C                   eval      error = *on
     C                   eval      *in38 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify GS1 unique.
     *
     C                   if            w1tgsu <> 'Y'
     C                             and w1tgsu <> 'N'
     C                   eval      error = *on
     C                   eval      *in64 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify signature enabled.
     *
     C                   if            w1tsig <> 'Y'
     C                             and w1tsig <> 'N'
     C                   eval      error = *on
     C                   eval      *in39 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify non scan reason prompt.
     *
     C                   if            w1tnsr  <> 'Y'
     C                             and w1tnsr  <> 'N'
     C                   eval      error = *on
     C                   eval      *in72 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify print invoice.
     *
     C                   if            w1tpiv <> 'Y'
     C                             and w1tpiv <> 'N'
     C                   eval      error = *on
     C                   eval      *in42 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     *  Verify filter by department.
     *
     C                   if            w1tfbd  <> 'Y'
     C                             and w1tfbd  <> 'N'
     C                   eval      error = *on
     C                   eval      *in73 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     *
     *  Verify Email receipt.
     *
     C                   if            w5ter <> 'Y'
     C                             and w5ter <> 'N'
     C                   eval      error = *on
     C                   eval      *in74 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   endif
     *
     C     endck5        endsr
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
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
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
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     C                   eval      opcbda = 'N'
     C                   eval      opcsda = 'N'
     C                   eval      opcare = 'Y'
     C                   eval      opccwr = 'N'
     C                   eval      opcgbd = 'N'
     C                   eval      opcpal = 'N'
     C                   eval      opcrtq = 'N'
     C                   eval      opcbul = 'Y'
     C                   eval      opcotq = 'N'
     C                   eval      opcgss = 'N'
     C                   eval      opccce = 'N'
     C                   eval      opcgsu = 'N'
     C                   eval      opcsig = 'N'
     C                   eval      opcnsr = 'N'
     C                   eval      opcpiv = 'N'
     C                   eval      opcfbd = 'N'
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT5   Get default values for add.
     *
     C     zzdft5        begsr
     *
     C                   eval      opcdta1= *blanks
     C                   eval      opcer= 'N'
     C                   eval      opcref= 'trax@DoNotReply.com'
     C                   eval      opcres= 'TraxPODSystemReceipt'
     C                   eval      opcdta= opcdta1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   eval      w1tbda = opcbda
     C                   eval      w1tsda = opcsda
     C                   eval      w1tare = opcare
     C                   eval      w1tcwr = opccwr
     C                   eval      w1tgbd = opcgbd
     C                   eval      w1tpal = opcpal
     C                   eval      w1trtq = opcrtq
     C                   eval      w1tbul = opcbul
     C                   eval      w1totq = opcotq
     C                   eval      w1tgss = opcgss
     C                   eval      w1tcce = opccce
     C                   eval      w1tgsu = opcgsu
     C                   eval      w1tsig = opcsig
     C                   eval      w1tnsr = opcnsr
     C                   eval      w1tpiv = opcpiv
     C                   eval      w1tfbd = opcfbd
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     *
     C                   eval      w5ter  = opcer
     C                   eval      w5tref = opcref
     C                   eval      w5tres = opcres
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     C                   eval      opcwhs = $pwhse
     C                   eval      opccus = $pcust
     C                   eval      opccod = '*TRAX   '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt1        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft1
     C                   write     record
     C                   goto      beggt1
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET5   Get record(s) for screen 5.
     *
     C     zzget5        begsr
     *
     C                   eval      opcwhs = $pwhse
     C                   eval      opccus = $pcust
     C                   eval      opccod = '*TRAX1  '
     *
     C                   eval      tmpflg = *off
     *
     C     beggt5        tag
     *
     *   Get record from main file.
     *
     C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
     C                   else
     C     fileky        chain     record                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt5
     C                   endif
     *
     *  Record not found - Create it.
     *
     C                   if        *in79
     C                   if        tmpflg = *off
     C                   eval      tmpflg = *on
     C                   exsr      zzdft5
     C                   write     record
     C                   goto      beggt5
     C                   else
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt5
     C                   endif
     C                   endif
     *
     C                   eval      opcdta1 = opcdta
     *
     C     endgt5        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     C     fileky        klist
     C                   kfld                    opccod
     C                   kfld                    opcwhs
     C                   kfld                    opccus
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get and verify warehouse description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lprg = $pprg
     C                   eval      $lwhse = $pwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '  or
     C                             $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      $prtn = $lrtn
     C                   eval      $perm = $lerm
     C                   goto      endin2
     C                   else
     C                   eval      whcode = $pwhse
     C                   movel     $lerm         whdesc
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      $lprg = #prog
     C                   exsr      scr01i
     C     endin2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record with screen1 fields.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opcbda = w1tbda
     C                   eval      opcsda = w1tsda
     C                   eval      opcare = w1tare
     C                   eval      opccwr = w1tcwr
     C                   eval      opcgbd = w1tgbd
     C                   eval      opcpal = w1tpal
     C                   eval      opcrtq = w1trtq
     C                   eval      opcbul = w1tbul
     C                   eval      opcotq = w1totq
     C                   eval      opcgss = w1tgss
     C                   eval      opccce = w1tcce
     C                   eval      opcgsu = w1tgsu
     C                   eval      opcsig = w1tsig
     C                   eval      opcnsr = w1tnsr
     C                   eval      opcpiv = w1tpiv
     C                   eval      opcfbd = w1tfbd
     *
     *   Update record (it was read and locked in ZZGET1)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update record with screen5 fields.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      opcer  = w5ter
     C                   eval      opcref = w5tref
     C                   eval      opcres = w5tres
     *
     C                   eval      opcdta = opcdta1
     *
     *   Update record (it was read and locked in ZZGET5)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endup5
     C                   endif
     *
     C     endup5        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPDWIN   Delete record.
     *
     C     zzupdWin      begsr
     C                   eval      error = *off
     *
     *   Delete *TRAX record
     *
     C                   delete    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endUpdWin
     C                   endif
     *
     *   Delete *TRAX1 record
     *
     C                   eval      opccod = '*TRAX1  '
     C     fileky        chain     optionc
     C                   if        %found(optionc)
     C                   delete    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm75
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endUpdWin
     C                   endif
     C                   endif
     *
     C     endUpdWin     endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Days to keep Trax export data
Valid entries are A, N, or B
Please enter Y or N
Valid range is 1 - 31
Valid entries are PROD, TEST, or DEV
Valid entry: MC75
Valid entry: WM6
Valid entry: 480
Valid entry: 640
Valid entries are 0 or 10-60
Valid entries are 1, 2, or 3
0000-2345 in 15 min increments: 00,15,30,45
Must be N=Near or F=Far
Must be A=Auto or F=Fixed
Must be Y=Yes, N=No, or P=Prompt
Timeout must be entered when Use = Y
