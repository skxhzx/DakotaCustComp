650aA /copy *libl/qcopysrc,hspecs
500 A*----------------------------------------------------------------
500 A*  Multilingual Verision
500 A*  Every screen and message has a corresponding Spanish version.
500 A*  Any changes must be made to both languages.
500 A*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  US112     User Code Table Maintenance - Change
     *  07 July, 1994
     *  Hemant Kapadia
     *
     *  SK112 - 1.01
     *
     *  Revisions
     *
     *    01/10/96  DAS  2.10e
     *      - Revised to work with EPM version of PIRUSER file.
     *
     *    11/19/96  RH   2.17
     *      - Revised to work with PIRUSER file for EPM or not.
     *        If not EPM, fields are non-display and protected.
     *
500 A*    03/22/05  DAS  5.00
     *      - Added file PIRUSERA.
     *      - Added belt printer user option (W1BPU)
     *
500aA*    05/24/05  DAS  5.00a
     *      - Added Language option (W1LNG)
     *
500bA*    06/04/06  JCJ  5.00b
     *      - Added Multilingual logic.
     *
640aA*    02/06/12  RTR  6.40a
     *      - Converted to ILE.
     *      - Added update of GLOUSR.
     *
650aA*    03/21/14  RBD  6.50a
     *      - Fix: Corrected 640a logic: if the user was already in
     *        GLOUSR it was changing the whse to the w1whse rather
     *        than checking to see if it was a different whse and
     *        needed to be added to guvalue or if it was the same
     *        and gurel and guvalue should remain unchanged.
     *      - Also added logic when searching guvalue to first determine
     *        whether the whse being added/updated is a length of 1,
     *        2 or 3.  For example, if whse=5, we must check to see if
     *        it's in pos 1 of guvalue by searching with '5 ', and if
     *        it's not in pos 1, then search with ' 5 '.  Without this
     *        logic, whse 5 would give a false positive if whse 25
     *        were the last whse listed in guvalue.
     *
650aA*    12/19/17  MR
     *      - Recompiled due to database change to PIRUSERA.
     *
750 A*    05/12/21  KDE   7.50
     *      - Allow Bluetooth printer type for Belt Printer
     *
750aA*    06/21/21  DAS   7.50a
     *      - Added Blutooth/Peel-Off option 'P'
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
217 A*  95        PROTECT & NONDISPLAY EPM FIELDS
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
750 DF*us112fm   cf   e             workstn
750 MFus11201   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fpiruser   uf a e           k disk
     F                                     rename(usrec:record)
     Fpiruser1  if   e           k disk
500 AFpirusera  uf a e           k disk
640aAFglousr    uf a e           k disk    usropn
     Foptione   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
500 D**                  DESC    1   2 20
500aD**                  DESC    1   3 20
500aMD desc            s             20    dim(4) ctdata perrcd(1)
500bAD descsp          s             20    dim(4) ctdata perrcd(1)
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
     D  $pcode                19     28
217 AD  $pepmf                29     29
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
     D  $lwhdp                22     26
     D  $lshft                27     32
     *
     D  $lcrew                22     27
     *
     D  $lwhs                 19     21  0
     D  $lshf                 22     27
     D  $lcrw                 28     33
     *----------------------------------------------------------------
     *
     D opedta          ds
     D  opman                  1      1
     D  opnxte                 2      6  0 inz(0)
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $cvtdt          ds
     D  $cvdop                 1      8
     D  $cvdd6                 9     14  0
     D  $cvdd8                15     22  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
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
     D $MSGF           s             10
     D #MSGID          s              7
     D #MSGTP          s              7
     D #PGMQ           s             10
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
     D E               s              2  0
     D ECODE           s                   like(OPECOD)
     D ENTER           s              5  0
     D ERROR           s              1
     D EWHDP           s                   like(OPEWDP)
     D EWHSE           s                   like(OPEWHS)
     D HELP            s              5  0
     D MSGK            s              4  0
     D NXTSCR          s              3
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
     D SCLEAR          s              1
     D WARN            s              1
640aAD webupdate       s              1n
650aAD whsLength       S              3s 0
640aAD wkwhse          s              4a
650aDD*svwhse          s              4a
650aMD svwhse          s             30a
640aAD wkpos           s              5s 0
650aAD wkwhs1B         s              2a
650aAD wkwhsB1B        s              3a
650aAD wkwhs2B         s              3a
650aAD wkwhsB2B        s              4a
650aAD wkwhs3B         s              4a
650aAD wkwhsB3B        s              5a
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new record.
     *              *EDIT    - Edit record.
     *              *DELETE  - Delete record.
     *              *PRINT   - Print record edit listing.
     *              *POST    - Post record.
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
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   move      'EOJ'         nxtscr
     C                   endif
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
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn1sp                              50
500bAC                   other
     C                   exfmt     screen1                              50
500bAC                   endsl
500bD**                   EXFMTSCREEN1                50
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
     C                   move      '01 '         nxtscr
     C                   setoff                                       61
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
500 AC     *loval        setll     pirusera
     C                   move      'EOJ'         nxtscr
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
500 AC     *loval        setll     pirusera
     C                   move      'EOJ'         nxtscr
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
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
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
     C                   move      'EOJ'         nxtscr
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      $msgf = #msgsp
500bAC                   other
     C                   eval      $msgf = #msgf
500bAC                   endsl
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
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   move      #msgsp        $msgf
500bAC                   other
     C                   move      #msgf         $msgf
500bAC                   endsl
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
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*   PIR1005  Value must be 'Y' or 'N'
500 A*
500 AC     zm1005        begsr
     C                   move      'PIR1005'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   US11201  Invalid section entered.
     *
     C     zm1201        begsr
     C                   move      'US11201'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure code was entered.
     *
     C                   if        w1code = *blanks
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(1)     errmsg
500bAC                   other
     C                   movel     desc(1)       errmsg
500bAC                   endsl
     C                   exsr      zm01
     C                   endif
     *
     *    Make sure code doesn't already exist.
     *
     C                   eval      $pcode = w1code
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   move      *on           error
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(1)     errmsg
500bAC                   other
     C                   movel     desc(1)       errmsg
500bAC                   endsl
     C                   exsr      zm02
     C                   endif
     *
     *    Make sure employee number was entered.
     *
217 AC                   if        not *in95  and
217 MC                             w1emp# = 0
217 D*R         W1EMP#    IFEQ 0
     C                   move      *on           error
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(2)     errmsg
500bAC                   other
     C                   movel     desc(2)       errmsg
500bAC                   endsl
     C                   exsr      zm01
     C                   endif
     *
     *  Make sure, employee number doesn't already exists.
     *
217 AC                   if        not *in95
     C     us1key        chain     piruser1                           79
     C                   if        not *in79
     C                   move      *on           error
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(2)     errmsg
500bAC                   other
     C                   movel     desc(2)       errmsg
500bAC                   endsl
     C                   exsr      zm02
     C                   endif
217 AC                   endif
     C                   endif
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      '1'           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
217 A*    Only check if EPM is used.
     *
217 AC                   if        not *in95
     *    Make sure valid department was enterd.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *    Make sure section was entered.
     *
     C                   if        w1styp <> 'F'  and
     C                             w1styp <> 'P'
     C                   move      *on           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   exsr      zm1201
     C                   endif
     *
     *    Make sure valid shift code was enterd.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = *blanks
     C                   eval      $lshft = w1shft
     C                   call      'SH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *    Make sure valid crew code was enterd.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhs = w1whse
     C                   eval      $lshf = w1shft
     C                   eval      $lcrw = w1crew
     C                   call      'CR901'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
217 AC                   endif
500 A*
500 A*    Make sure valid belt printer user option entered.
500 A*
500 AC                   if        w1bpu <> 'Y'  and
500 AC                             w1bpu <> 'N'  and
750 AC                             w1bpu <> 'B'  and
750AAC                             w1bpu <> 'P'
500 AC                   move      *on           error
500 AC                   eval      *in32 = *on
500 AC                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(3)     errmsg
500bAC                   other
500 AC                   movel     desc(3)       errmsg
500bAC                   endsl
750 A /free
750 A                    errmsg = %trim(errmsg) + ' must be Y/N/B/P'   ;
750 A /end-free
750 DC*                  exsr      zm1005
750 MC                   exsr      zm0105
500 AC                   endif
500aA*
500aA*    Make sure valid language option entered.
500aA*
500aAC                   if        w1lng <> 'EN'  and
500aAC                             w1lng <> 'SP'
500aAC                   move      *on           error
500aAC                   eval      *in33 = *on
500aAC                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   movel     descsp(4)     errmsg
500bAC                   other
500aAC                   movel     desc(4)       errmsg
500bAC                   endsl
750 A /free
750 A                    errmsg = %trim(errmsg) + ' must be Y, N, or B';
750 A /end-free
750 DC*                  exsr      zm1005
750 MC                   exsr      zm0105
500aAC                   endif
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   move      '0'           cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      '1'           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse code.
     *
     C                   when      row# = 13
     C                   eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Warehouse department.
     *
     C                   when      row# = 14
217 AC                   if        not *in95
     C                   eval      *in07 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
     C                   endif
217 AC                   endif
     *
     *     Shift code.
     *
     C                   when      row# = 16
217 AC                   if        not *in95
     C                   eval      *in09 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = *blanks
     C                   eval      $lshft = w1shft
     C                   call      'SH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1shft = $lshft
     C                   endif
217 AC                   endif
     *
     *     Crew code.
     *
     C                   when      row# = 17
217 AC                   if        not *in95
     C                   eval      *in10 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhs = w1whse
     C                   eval      $lshf = w1shft
     C                   eval      $lcrw = w1crew
     C                   call      'CR901'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1crew = $lcrw
     C                   endif
217 AC                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   move      '1'           error
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1code = *blanks
     *
     C                   move      '*USER   '    ecode
     C                   eval      ewhse = 0
     C                   eval      ewhdp = *blanks
217 AC                   if        not *in95
     C     opkey         chain     optione                            79
     C                   if        opman = 'Y'
     C                   eval      w1emp# = 0
     C                   else
     C                   call      'PIREMP# '
     C                   parm                    w1emp#
     C                   seton                                        61
     C                   endif
217 AC                   else
217 AC                   call      'PIREMP# '
217 AC                   parm                    w1emp#
217 A*R                   Z-ADD0         W1EMP#
217 AC                   endif
     *
     C                   eval      w1fnam = *blanks
     C                   eval      w1init = *blanks
     C                   eval      w1lnam = *blanks
     C                   eval      w1whse = 0
     C                   eval      w1whdp = *blanks
     C                   eval      w1styp = *blanks
     C                   eval      w1shft = *blanks
     C                   eval      w1crew = *blanks
     C                   eval      w1nhrs = 0
500 AC                   eval      w1bpu = 'N'
500aAC                   move      'EN'          w1bpu
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1code = uscode
     C                   eval      w1emp# = usemp#
     C                   eval      w1fnam = usfnam
     C                   eval      w1init = usinit
     C                   eval      w1lnam = uslnam
     C                   eval      w1whse = uswhse
650aDC**                 eval      svwhse = %char(uswhse)
     C                   eval      w1whdp = uswhdp
     C                   eval      w1styp = usstyp
     C                   eval      w1shft = usshft
     C                   eval      w1crew = uscrew
     C                   eval      w1nhrs = usnhrs
500 AC                   eval      w1bpu = usabpu
500aAC                   eval      w1lng = usalng
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
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
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt2
     C                   endif
500 A*
500 A*   Get record from PIRUSERA file.
500 A*
500 AC                   if        $pcmd = '*VIEW   '
500 AC     fileky        chain(n)  pirusera                           7978
500 AC                   else
500 AC     fileky        chain     pirusera                           7978
500 AC                   endif
500 AC                   if        *in79
500 AC                   clear                   usarec
500 AC                   endif
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
     C                   kfld                    $pcode
     *
     *  Define key for PIRUSER1 file.
     *
     C     us1key        klist
     C                   kfld                    w1emp#
     *
     *  Define key for OPTIONE file.
     *
     C     opkey         klist
     C                   kfld                    ecode
     C                   kfld                    ewhse
     C                   kfld                    ewhdp
     *
217 A*  Set EPM flag and non-display indicator.
217 A*
217 AC                   if        $pepmf = '0'
217 AC                   eval      *in95 = *on
217 AC                   else
217 AC                   eval      *in95 = *off
217 AC                   endif
640aA*
640aA*  Try to open GLOUSR for Web Users.
640aA*
640aAC                   if        not %OPEN(GloUsr)
640aAC                   Open(e)   GloUsr
640aAC                   if        %Error()
640aAC                   eval      webupdate = *off
640aAC                   else
640aAC                   eval      webupdate = *on
640aAC                   endif
640aAC                   endif
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
500bA*
500bA*   Get employee options.
500bA*
500bAC                   call      'GETUSER'
500bAC                   parm      #user         e$code           10
500bAC                   parm                    e$whse            3 0
500bAC                   parm                    e$emp#            5 0
500bAC                   parm                    e$fnam           15
500bAC                   parm                    e$init            1
500bAC                   parm                    e$lnam           20
500bAC                   parm                    e$whdp            5
500bAC                   parm                    e$styp            1
500bAC                   parm                    e$shft            6
500bAC                   parm                    e$crew            6
500bAC                   parm                    e$nhrs            3 1
500bAC                   parm                    e$rtn             8
500bAC                   parm                    e$bpu             1
500bAC                   parm                    e$lng             2
500bAC                   if        e$rtn <> '*OK'
500bAC                   eval      e$lng = 'EN'
500bAC                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pcode = *blanks
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      '0'           error
     *
     *  Move screen fields to record fields
     *
     C                   eval      uscode = w1code
     C                   eval      usemp# = w1emp#
     C                   eval      usfnam = w1fnam
     C                   eval      usinit = w1init
     C                   eval      uslnam = w1lnam
     C                   eval      uswhse = w1whse
     C                   eval      uswhdp = w1whdp
     C                   eval      usstyp = w1styp
     C                   eval      usshft = w1shft
     C                   eval      uscrew = w1crew
     C                   eval      usnhrs = w1nhrs
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   write     record                               79
     C                   if        *in79
     C                   move      '1'           error
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   move      '1'           error
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
500 A*
500 A*   Add/Update PIRUSERA file.
500 A*
500 AC     fileky        chain     pirusera                           79
500 AC                   if        *in79
500 AC                   eval      usacod = uscode
500 AC                   eval      usabpu = w1bpu
500aAC                   eval      usalng = w1lng
500 AC                   write     usarec                               79
500 AC                   else
500 AC                   eval      usabpu = w1bpu
500aAC                   eval      usalng = w1lng
500 AC                   update    usarec                               79
500 AC                   endif
640aA*
640aA*   Add/Update GLOUSR file *IF OPEN*.
640aA*
640aAC                   if        webupdate = *on
640aAC     uscode        chain     glousr                             79
640aAC                   if        *in79
640aAC                   eval      guuser = uscode
640aAC                   eval      guemp# = w1emp#
640aAC                   eval      gufnam = w1fnam
640aAC                   eval      guinit = w1init
640aAC                   eval      gulnam = w1lnam
640aAC                   eval      gulang = w1lng
640aAC                   eval      gurel = 'EQ'
640aAC                   eval      guvalue = %char(w1whse)
640aAC                   write     gurec                                79
640aAC                   else
640aA*
640aA*** record found, if single warehouse is same, just update
650aMC                   eval      svwhse = %char(w1whse)
640aAC                   if        gurel = 'EQ'
650aMC                             and guvalue = svwhse
650aDC**                           or (gurel = 'LS'
650aDC**                           and guvalue = svwhse)
640aAC                   eval      gurel = 'EQ'
640aAC                   eval      guvalue = %char(w1whse)
640aAC                   eval      guemp# = w1emp#
640aAC                   eval      gufnam = w1fnam
640aAC                   eval      guinit = w1init
640aAC                   eval      gulnam = w1lnam
640aAC                   eval      gulang = w1lng
640aAC                   update    gurec                                79
640aAC                   else
640aA
640aA*** search values for warehouse,
650aDC**                 eval      wkwhse = %char(w1whse)
650aDC**                 eval      wkpos = %scan(wkwhse: guvalue)
650aAC                   eval      whsLength = %Len(%Trim(%char(w1whse)))

650aAC                   if        whsLength = 1
650aAC                   eval      wkwhs1B  = %trim(%char(w1whse))
650aAC                   eval      wkwhsB1B = ' ' + %trim(%char(w1whse)) + ' '
650aAC                   eval      wkpos = %scan(wkwhs1B: guvalue)
650aAC                   if        wkpos <> 1
650aAC                   eval      wkpos = %scan(wkwhsB1B: guvalue)
650aAC                   endif
650aAC                   endif

650aAC                   if        whsLength = 2
650aAC                   eval      wkwhs2B  = %trim(%char(w1whse))
650aAC                   eval      wkwhsB2B = ' ' + %trim(%char(w1whse)) + ' '
650aAC                   eval      wkpos = %scan(wkwhs2B: guvalue)
650aAC                   if        wkpos <> 1
650aAC                   eval      wkpos = %scan(wkwhsB2B: guvalue)
650aAC                   endif
650aAC                   endif

650aAC                   if        whsLength = 3
650aAC                   eval      wkwhs3B  = %trim(%char(w1whse))
650aAC                   eval      wkwhsB3B = ' ' + %trim(%char(w1whse)) + ' '
650aAC                   eval      wkpos = %scan(wkwhs3B: guvalue)
650aAC                   if        wkpos <> 1
650aAC                   eval      wkpos = %scan(wkwhsB3B: guvalue)
650aAC                   endif
650aAC                   endif

640aAC
640aA*** if not found, add to list
640aAC                   if        wkpos = 0
640aAC                   eval      gurel = 'LS'
640aAC                   eval      guvalue = %trim(guvalue) + ' '
650aMC                                       + %trim(%char(w1whse))
650aDC**                                     + %trim(wkwhse) + ' '
640aAC                   endif
640aAC
640aAC                   eval      guemp# = w1emp#
640aAC                   eval      gufnam = w1fnam
640aAC                   eval      guinit = w1init
640aAC                   eval      gulnam = w1lnam
640aAC                   eval      gulang = w1lng
640aAC                   update    gurec                                79
640aAC                   endif                                                  *** if gurel = EQ
640aAC                   endif                                                  *** if *in79
640aAC                   endif                                                  *** if webupdate *on
     *
     *   Move key values to parameters
     *
     C                   eval      $pcode = uscode
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
** DESC
User Code
Employee number
Belt Printer User
Language
** DESCSP
User Code
Employee number
Belt Printer User
Language
