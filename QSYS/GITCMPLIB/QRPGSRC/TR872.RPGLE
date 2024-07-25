      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TR872     Trax Merged Routes maintenance - Change
     *  29 December, 2011
     *  Retha Davis
     *
     *  Revisions
     *
     *  12/29/11  RBD  6.40
     *    - Created.
     *
650 A*  09/11/14 RBD  6.50
     *    - Changed screen format to TR87201.
     *    - Added route lookup and selection.
     *    - When child is added and it's at printed status or higher:
     *      if its parent has a trailer assigned in loader header then
     *      assign that same trailer to child in loader header.
     *
650aA*  11/20/14 RBD  6.50a
     *    - Added display of multi route group Id.
     *    - Added multi route flag designation for children.
     *
720aA*  01/24/18 RBD  7.20a
     *    - Changed screen format to TR87203.
     *    - Commented out multi route group Id for parent
     *      and multi route flag for children.
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
     *  File Specs
     *
650 DF*tr872fm   cf   e             workstn
650aDF*tr87201   cf   e             workstn
720aDF*tr87202   cf   e             workstn
720aMFtr87203   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
650 AFldrhdr3   uf   e           k disk
650 AFpiruser   if   e           k disk
     Frtehed    if   e           k disk
720aDF*ttgrp     uf a e           k disk
     Fttlog     if   e           k disk
     Fttmerg    uf a e           k disk
     fttmerg2   if   e           k disk    rename(ttmrec:ttmrec2)
     f                                     prefix(t_)
     Fwarehs    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
650aDD*desc            s             50    dim(5) ctdata perrcd(1)
650aMD desc            s             50    dim(6) ctdata perrcd(1)
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
     D  $pprti                22     26
     D  $pcrti                27     31
650aAD  $pggid                32     36  0
     *----------------------------------------------------------------
     *  Called programs
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
     D  $lprti                22     26
     D  $lcrti                27     31
     *----------------------------------------------------------------
650 A*  Partial key redefinition
650 A*
650 AD $prtky          ds
650 AD  $len50                 1     50
650 AD  $kwhse                 1      3  0
650 AD  $krte                  4      8
650 AD  $krtid                 9     13
     *----------------------------------------------------------------
     *
     D @cvtdt          c                   const('CVTDTE')
     D $cvtdt          ds
     D  $cvcmd                 1      8
     D  $cvprg                 9     18
     D  $cvd80                39     46  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
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
650aAD cnt             s              1  0
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D erm             s             60
     D error           s              1
     D forevr          s              1
650aAD grpid           s              5  0
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtn             s              8
     D sclear          s              1
650 AD sav_lhtrlr      s                   like(lhtrlr)
     D warn            s              1
     D whse30          s              3  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
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
     C                   eval      *in97 = '1'
     C                   eval      *in90 = '0'
     C                   eval      *in91 = '0'
     C                   eval      error = '0'
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
     C                   eval      *in98 = '1'
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
     C                   eval      warn = '0'
     C                   eval      error = '0'
     C                   eval      cmdtkn = '0'
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
     C                   eval      *in90 = '1'
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
     C                   eval      *in91 = '1'
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
     C     *loval        setll     ttmrec
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
650 A*  TEST FOR CMD8 - Route lookup
650 A*
650 AC                   if        *inkh
650 AC                   eval      $lcmd = '*SELECT '
650 AC                   eval      $kwhse = $pwhse
650 AC                   call      'TR900'
650 AC                   parm                    $lcmd
650 AC                   parm                    $lprg
650 AC                   parm                    $prtky
650 AC                   parm                    $lrtn
650 AC                   parm                    $lerm
650 AC                   parm                    $lmsg
650 AC                   if        $lrtn <> '*PGMQ   '  and
650 AC                             $lrtn <> '*CANCEL '
650 AC                   eval      w1crte = $krte
650 AC                   eval      w1crti = $krtid
720aDC**                 eval      *in03 = '1'
650 AC                   endif
650 AC                   goto      endsc1
650 AC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C     *loval        setll     ttmrec
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     '1'           endsc1
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
     C     cmdtkn        cabeq     '1'           endsc1
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
     C                   eval      *in97 = '0'
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
     C                   eval      *in97 = '1'
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
     C                   eval      sclear = '1'
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
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm02          begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
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
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
720aD*----------------------------------------------------------------
720aD**
720aD** ZZADDGRP   Add child to multi route group file, and parent
720aD**            too if it's not already there.
720aD**
720aDC**   zzaddgrp      begsr
720aD**
720aD** Check for parent route in TTGRP.
720aDC**   ttgrpky       chain     ttgrp                              7978

720aD** Record locked.
720aDC**                 if        *in78
720aDC**                 eval      error = '1'
720aDC**                 eval      $prtn = '*PGMQ   '
720aDC**                 exsr      zm74
720aDC**                 goto      endaddgrp
720aDC**                 endif

720aDC**                 if        not %found(ttgrp)
720aDC**                 eval      ttgwhs = $pwhse
720aDC**                 eval      ttgrid = w1prti
720aDC**                 call      'PIRTTGRPID'
720aDC**                 parm                    grpid
720aDC**                 eval      ttggid = grpid
720aDC**                 write     ttgrec                               79
720aD** Error writing record.
720aDC**                 if        *in79
720aDC**                 eval      error = '1'
720aDC**                 exsr      zm71
720aDC**                 goto      endaddgrp
720aDC**                 endif
720aDC**                 endif

720aDC**                 eval      ttgrid = w1crti
720aDC**                 write     ttgrec                               79
720aD** Error writing record.
720aDC**                 if        *in79
720aDC**                 eval      error = '1'
720aDC**                 exsr      zm71
720aDC**                 goto      endaddgrp
720aDC**                 endif

720aDC**   endaddgrp     endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = '0'
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *  Child route and child route id are required.
     *
     C                   if        w1crte = *blanks
     C                             or w1crti = *blanks
     C                   eval      error = '1'
     C                   eval      *in21 = '1'
     C                   eval      *in01 = '1'
     C                   eval      errmsg = desc(1)
     C                   exsr      zm01
     C                   goto      endck1
     C                   endif
     *
     *    Verify route.
     *
     C     rteky         chain     rtehed
     C                   if        not %found
     C                             or w1crte <> rhrte
     C                   eval      error = '1'
     C                   eval      *in21 = '1'
     C                   eval      *in01 = '1'
     C                   eval      errmsg = desc(2)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     *
     *    Make sure this child isn't already assigned to this parent
     *    or any other parent.
     *
     C     rteky         setll     ttmerg2
     C                   dow       forevr = forevr
     C     rteky         reade     ttmerg2
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      error = '1'
     C                   eval      *in21 = '1'
     C                   eval      *in01 = '1'
     C                   eval      errmsg = %trimr(desc(4)) + ' '
     C                             + t_ttmprt + '/' + t_ttmpri
     C                   exsr      zm0105
     C                   goto      endck1
     C                   enddo
     *
     *    Make sure this child isn't already assigned as a parent.
     *
     C     rteky         setll     ttmerg
     C                   dow       forevr = forevr
     C     rteky         reade     ttmerg
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      error = '1'
     C                   eval      *in21 = '1'
     C                   eval      *in01 = '1'
     C                   eval      errmsg = desc(5)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   enddo
     *
     *    Make sure child route hasn't been downloaded.
     *
     C     rteky         setll     ttlog
     C                   dow       forevr = forevr
     C     rteky         reade     ttlog
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        ttlstatus = '3'
     C                             or ttlstatus = '4'
     C                   eval      error = '1'
     C                   eval      *in21 = '1'
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   enddo
     *
     C                   endif
     *
720aD** Verify multi route flag.
720aD**
720aDC**                 if            w1mflg <> 'Y'
720aDC**                           and w1mflg <> 'N'
720aDC**                 eval      error = *on
720aDC**                 eval      *in23 = *on
720aDC**                 eval      *in03 = *on
720aDC**                 eval      errmsg = desc(6)
720aDC**                 exsr      zm0105
720aDC**                 endif
     *
     C     endck1        endsr
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
     C                   eval      cmdtkn = '1'
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Item.
     *
     C                   when      row# = 12
     C                   eval      *in02 = '1'
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C*                  eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C*                  eval      w1item = $litem
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = '1'
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
     *
     C     rteky1        chain     rtehed
     C                   if        not %found
     C                   eval      rhrte = *blanks
     C                   endif
     *
     C                   eval      w1prte = rhrte
     C                   eval      w1prti = $pprti
     C                   eval      w1crte = *blanks
     C                   eval      w1crti = *blanks
720aDC**                 eval      w1ggid = $pggid
720aDC**                 eval      w1mflg = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
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
     C     fileky        chain(n)  ttmrec                             7978
     C                   else
     C     fileky        chain     ttmrec                             7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   eval      error = '1'
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt2
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = '1'
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
     C                   kfld                    $pprti
     C                   kfld                    $pcrti
     *
     *  Define child route key.
     *
     C     rteky         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1crti
     *
     *  Define key for route header file.
     *
     C     rteky1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pprti
     *
720aD** Define key for ttgrp file.
720aD**
720aDC     ttgrpky       klist
720aDC                   kfld                    $pwhse
720aDC                   kfld                    w1prti
     *
     *  Define variables
     *
     C                   eval      $lprg = #prog
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
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      $pcrti = *blanks
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = '0'
     *
     *  Move screen fields to record fields
     *
     C                   eval      ttmwhs = $pwhse
     C                   eval      ttmprt = w1prte
     C                   eval      ttmpri = w1prti
     C                   eval      ttmcrt = w1crte
     C                   eval      ttmcri = w1crti
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   write     ttmrec                               79
     C                   if        *in79
     C                   eval      error = '1'
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
720aDC**                 if        w1mflg = 'Y'
720aDC**                 exsr      zzaddgrp
720aDC**                 if        error = '1'
720aDC**                 goto      endupd
720aDC**                 endif
720aDC**                 endif
     *
     *   Call pgm to create and delete xml files as necessary
     *
     C                   eval      whse30 = $pwhse
     C                   call      'TR873'
     C                   parm                    whse30
     C                   parm                    w1prti
     C                   parm                    rtn
     C                   parm                    erm
     *
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    ttmrec                               79
     C                   if        *in79
     C                   eval      error = '1'
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pprti = ttmpri
     C                   eval      $pcrti = ttmcri
720aDC**                 eval      $pggid = ttggid
     *
650 A*   If parent loader header has trailer assigned update child with
650 A*   the same trailer.
650 A*
650 AC                   if        rhstat >= '4'
650 AC     rteky1        chain     ldrhdr3
650 AC                   if        %found and lhtrlr <> *blanks
650 AC                   eval      sav_lhtrlr = lhtrlr
650 AC     rteky         chain     ldrhdr3
650 AC                   if        %found
650 AC                   eval      lhtrlr = sav_lhtrlr
650 AC                   eval      lhstat = '2'

650 A*  Move route starting loading date and time into Ldrhdr file.

650 AC                   move      '*CURCMD '    $cvcmd
650 AC                   call      @cvtdt
650 AC                   parm                    $cvtdt
650 AC                   eval      lhstrd = $cvd80
650 AC                   time                    lhstrt

650 A*  Get loader emp#

650 AC     #user         chain     piruser
650 AC                   if        %found
650 AC                   eval      lhemp# = usemp#
650 AC                   endif

650 AC                   update    lhrec
650 AC                   endif
650 AC                   endif
650 AC                   endif
650 A*
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Child Route and Child Route Id
Route/route id does not exist
Child route has already been downloaded
Child route is already assigned to
Child route has already been assigned as a parent
Please enter Y or N
