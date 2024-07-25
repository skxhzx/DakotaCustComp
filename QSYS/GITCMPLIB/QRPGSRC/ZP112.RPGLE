     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  ZP112     Device Group maintenance
     *  04 January, 2007
     *  Jeffrey Jahnke
     *
     *  Revisions
     *
     *    xx/xx/xx  xxx
     *      - xxxxxxxxxxxxxxxxxxxx.
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
     Fzp112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fdevgrph   uf a e           k disk
     F                                     rename(dvrec:record)
     Fdevgrpd1  uf a e           k disk
     F                                     rename(ddrec:record1)
     Fdevgrpd   if   e           k disk
     Fwarehs    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     d a10             s              1    dim(10)
     d optlst          s              2    dim(24)
     d cmdlst          s              2    dim(24)
     d zopt            s              2    dim(20) ctdata perrcd(20)
     d optln           s             75    dim(1) ctdata perrcd(1)
     d cmdln           s             79    dim(1) ctdata perrcd(1)
     d desc            s             60    dim(8) ctdata perrcd(1)
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
     D  $pcode                22     31
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
     D  $ldwhs                19     20  0
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
     *----------------------------------------------------------------

     D clear           s              5  0
     D comand          s              5  0
     D enter           s              5  0
     D help            s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D posrec          s              4  0
     D reccnt          s              4  0
     D recno           s              4  0
     D msgk            s              4  0
     D e               s              2  0
     D $msgf           s             10
     D #pgmq           s             10
     D cmdchk          s              8
     D svcmd           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D nxtscr          s              3
     D cmdtkn          s              1
     D error           s              1
     D forevr          s              1
     D redspl          s              1
     D sclear          s              1
     D stop            s              1
     D warn            s              1
     D prefix          s              1    inz('<')
     D pstfix          s              1    inz('>')
     D kycode          s                   like(dvhgrp)
     D lstseq          s                   like(dvdseq)
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
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
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
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     c                   setoff                                       kckekf
     c                   setoff                                       kl
     *
     *   Overlay screen with title
     *
     c                   write     title
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exsr      sfldsp
     C                   read      dspsfc                                 50
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
     C                   eval      redspl = *off
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
     C                             $pcmd = '*CHANGE '  or
     C                             $pcmd = '*UPDATE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     redspl        cabeq     *on           endsc1
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $pcmd = svcmd
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
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   write     dspsfl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   write     dspsfc
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     **                   WRITEPOSTNREC
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   if        reccnt > 12
     C                   eval      posrec = reccnt
     C                   endif
     C                   eval      recno = posrec
     C                   write     dspsfc
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7871  Error in writing a record.
     *
     C     zm7871        begsr
     C                   eval      #msgid = 'PIR7871'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7872  Error in updating a record.
     *
     C     zm7872        begsr
     C                   eval      #msgid = 'PIR7872'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
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
     C                   if        w1hgrp = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0105
     c                   goto      endck1
     C                   endif
     *
     *    Group code must be surounded with <xxxxxxxxxx>
     *
     c     prefix        scan      w1hgrp:1
     c                   if        not %found
     c                   eval      error = *on
     c                   eval      *in21 = *on
     c                   movea     desc(3)       errmsg
     c                   exsr      zm0105
     c                   goto      endck1
     c                   endif
     *
     c     pstfix        scan      w1hgrp:2
     c                   if        not %found
     c                   eval      error = *on
     c                   eval      *in21 = *on
     c                   movea     desc(4)       errmsg
     c                   exsr      zm0105
     c                   goto      endck1
     c                   endif
     *
     *    Make sure group code doesn't already exist.
     *
     c                   eval      $pcode = w1hgrp
     c     fileky        chain     record
     c                   if        %found(devgrph)
     c                   eval      error = *on
     c                   eval      *in21 = *on
     c                   movea     desc(5)       errmsg
     c                   exsr      zm0105
     c                   goto      endck1
     c                   endif
     c                   endif
     *
     *    Verify printer device code.
     *
     c                   if        wddev <> *blanks
     c                   call      'UT880CL'
     c                   parm                    wddev
     c                   parm                    $lrtn
     c                   if        $lrtn = '*ERROR '
     c                   eval      error = *on
     c                   eval      *in03 = *on
     c                   eval      *in23 = *on
     c                   movea     desc(6)       errmsg
     c                   exsr      zm0105
     c                   goto      endck1
     c                   endif
     c                   endif
     *
     *    Verify that printer device code does not already exist
     *
     c     ddkey1        chain(n)  record1
     c                   if        %found(devgrpd1)
     c                   eval      error = *on
     c                   eval      *in03 = *on
     c                   eval      *in23 = *on
     c                   movea     desc(8)       errmsg
     c                   exsr      zm0105
     c                   goto      endck1
     c                   endif
     *
     *    Make sure group code description is entered.
     *
     c                   if        w1hdsc = *blanks
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movea     desc(2)       errmsg
     C                   exsr      zm0105
     C                   endif
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     dspsfl                                 79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in05 = *off
     C                   eval      *in25 = *off
     C                   eval      *in85 = *on
      *
      *    Verify changed printer devise
      *
     C                   if        w1ddev <> *blanks
     c                   call      'UT880CL'
     c                   parm                    w1ddev
     c                   parm                    $lrtn
     c                   if        $lrtn = '*ERROR '
     c                   eval      error = *on
     c                   eval      *in05 = *on
     c                   eval      *in25 = *on
     c                   movea     desc(6)       errmsg
     c                   exsr      zm0105
     c                   endif
     C                   endif
     C                   eval      *in85 = *on
     C                   update    dspsfl
     C                   if        posrec = *zeros
     C                   if        *in25

     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     C                   eval      *in20 = *off
     C                   eval      *in21 = *off
     C                   eval      *in22 = *off
     C                   eval      *in23 = *off
     C                   eval      *in24 = *off
     C                   eval      *in25 = *off
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
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     Build code.
     *
     C                   select
     C                   when      row# = 12
     *
     *     Left definition for add.
     *
     C                   when      row# = 15
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
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
     C                   eval      w1hgrp = *blanks
     C                   eval      w1hdsc = *blanks
     C                   eval      w1dseq = *zeros
     C                   eval      w1ddev = *blanks
     C                   eval      lstseq = *zeros
     *
     C                   exsr      sflclr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1hgrp = dvhgrp
     C                   eval      w1hdsc = dvhdsc
     *
     C                   eval      lstseq = *zeros
     C                   eval      w1dseq = *zeros
     C                   eval      w1ddev = *blanks
     C                   exsr      sflclr
     C     ddkeyp        setll     devgrpd
     C                   eval      stop = *off
     C                   dou       stop = *on
     C     ddkeyp        reade(n)  devgrpd
     C                   if        %eof(devgrpd)
     C                   eval      stop = *on
     C                   leave
     C                   endif

     C                   eval      w1dseq = dvdseq
     C                   eval      w1ddev = dvddev
     C                   exsr      sfladd
     C                   eval      lstseq = dvdseq

     C                   enddo
     C                   eval      posrec = 1
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
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
     C                   goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
     C                   goto      endgt1
     C                   endif
     C     endgt1        endsr
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
     C                   kfld                    $pcode
     *
     *  Define key for main file.
     *
     C     wdkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1hgrp
     *
     *  Define key for main file.
     *
     C     ddkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1hgrp
     C                   kfld                    dvdseq
     *
     *  Define key for main file.
     *
     C     ddkey1        klist
     C                   kfld                    $pwhse
     C                   kfld                    wddev
     *
     *  Define partial key for main file.
     *
     C     ddkeyp        klist
     C                   kfld                    $pwhse
     C                   kfld                    w1hgrp
     *
     *  Setup option and command display lines.
     *
     c                   move      optln(1)      optln1
     c                   move      cmdln(1)      cmdln1
      *
     C                   eval      $lprg = #prog
     C                   eval      forevr = *off
     C                   eval      svcmd = $pcmd
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs
     C                   if        not %found(warehs)
     C                   eval      whdesc = *blanks
     C                   endif
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
     *  ZZUSUB   Update using subfile records.
     *
     C     zzusub        begsr
     C                   eval      error = *off
     *
     *   Loop through changed subfile records and add/update file.
     *
     C                   eval      *in77 = *off
     C                   dou       *in77
     C                   readc     dspsfl                                 77
     C                   if        *in77
     C                   leave
     C                   endif
     *
     *     Get detail record.
     *
     C                   eval      dvdseq = w1dseq
     C     ddkey         chain     record1                            7978
     *
     *     Record locked. Tell user to try again.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   update    dspsfl
     C                   movel     desc(7)       errmsg
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Initialize record fields before trying to add or update.
     *
     C                   eval      dvdwhs = $pwhse
     C                   eval      dvdgrp = w1hgrp
     C                   eval      dvdseq = w1dseq
     C                   eval      dvddev = w1ddev
     *
     C                   if        not %found(devgrpd1) and
     C                             w1ddev = *blanks
     C                   iter
     C                   endif
     *
     *     Record not found. Try adding record.
     *
     C                   if        not %found(devgrpd1) and
     C                             w1ddev <> *blanks
     C                   write     record1                              76
     *
     C                   if        not *in76
     C                   iter
     C                   endif
     *
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   update    dspsfl
     C                   movel     desc(7)       errmsg
     C                   exsr      zm7871
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     *     Record found. Try updating record.
     *
     C                   if        w1ddev = *blanks
     C                   delete    record1
     c                   else
     C                   update    record1                              76
     C                   endif
     C                   if        *in76
     C                   eval      error = *on
     C                   eval      *in85 = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   update    dspsfl
     C                   movel     desc(7)       errmsg
     C                   exsr      zm7872
     C                   exsr      sfldsp
     C                   leave
     C                   endif
     *
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to record fields
     *
     C                   eval      dvhwhs = $pwhse
     C                   eval      dvhgrp = w1hgrp
     C                   eval      dvhdsc = w1hdsc
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     C                   write     record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   eval      $pcmd = '*UPDATE '
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C     wdkey         chain     record                             79
     *
     C                   eval      dvhdsc = w1hdsc
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *  If user is adding a detail record ...
     *    - add it to subfile and return to entry screen
     *    - do not update files
     *
     C                   if        wddev <> *blanks
     c                   eval      lstseq = lstseq + 1
     c                   eval      w1dseq = lstseq
     c                   eval      w1ddev = wddev
     c                   eval      *in85 = *on
     c                   exsr      sfladd
     c                   eval      wddev = *blanks
     c                   eval      *in17 = *on
     c                   eval      redspl = *on
     C                   endif
     *
     *  Otherwise, update files and return.
     *
     *     Move screen fields to record fields.
     *
     C                   clear                   record
     C                   eval      dvdwhs = $pwhse
     C                   eval      dvdgrp = w1hgrp
     C                   eval      dvdseq = w1dseq
     C                   eval      dvddev = w1ddev
     *
     *  Update detail first.
     *
     C                   if        reccnt > 0
     C                   exsr      zzusub
     C     error         cabeq     *on           endupd
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pcode = w1hgrp
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**  ZOPT - Valid options

**  OPTLN - Option display line

**  CMDLN - Command display line
F3=Exit  F5=Refresh  F12=Cancel
**
Group Code entry required
Group Code description required
Group Code format error.  Must begin with '<'.
Group Code format error.  Must end with '>'.
Group Code already exists.
Printer Device not found.
Printer Device
Printer Device Already entered.
