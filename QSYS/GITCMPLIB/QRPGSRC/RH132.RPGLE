     *----------------------------------------------------------------
     *   Copyright (C) 1997 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RH132     Route Notes Maintenance
     *  05 Sep 2007
     *  Lynn McMahon
     *
     *  Revisions
     *
510a *   09/05/07  LMC  5.10
     *     - Created
     *
     *  Notes
     *
     *    - This program should only be called with *CHANGE or *VIEW.
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
     Frh132fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Frtenote   uf a e           k disk
     F                                     rename(rnrec:record)
     Fwarehs    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(1) ctdata perrcd(1)
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
     D  $prte                 22     26
     D  $prtid                27     31
     D  $ptruk                32     41
     D  $pstat                42     42
     D  $ptype                43     43
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
     D  $lwhse                19     21  0
     D  $ltruk                22     31
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

     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
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
     D forevr          s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
     D line            s              3  0
     D lstlin          s              3  0
     D fstlin          s              3  0
     D note            s             75
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
     *  Get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm01          begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
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
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCKACTION Check for correct action to take
     *
     C     zzckaction    begsr
     c                   if        line < fstlin or line > lstlin
     c                   exsr      zzckdel
     c                   else
     c                   exsr      zzckupd
     c                   endif
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKDEL  Check to see if exsting note should be deleted
     *
     C     zzckdel       begsr
     c     fileky1       chain     record
     c                   if        %found
     c                   delete    record
     c                   endif

     c     endckdel      endsr
     *----------------------------------------------------------------
     *
     *  ZZCKLN   Determine last notes line for loading blank lines to file
     *
     C     zzckln        begsr
     c                   eval      fstlin = 0
     c                   Select
     c                   When      w1nt01 <> *blanks
     c                   eval      fstlin = 01
     c                   When      w1nt02 <> *blanks
     c                   eval      fstlin = 02
     c                   When      w1nt03 <> *blanks
     c                   eval      fstlin = 03
     c                   When      w1nt04 <> *blanks
     c                   eval      fstlin = 04
     c                   When      w1nt05 <> *blanks
     c                   eval      fstlin = 05
     c                   When      w1nt06 <> *blanks
     c                   eval      fstlin = 06
     c                   When      w1nt07 <> *blanks
     c                   eval      fstlin = 07
     c                   When      w1nt08 <> *blanks
     c                   eval      fstlin = 08
     c                   When      w1nt09 <> *blanks
     c                   eval      fstlin = 09
     c                   When      w1nt10 <> *blanks
     c                   eval      fstlin = 10
     c                   endsl
     c                   eval      lstlin = 0
     c                   Select
     c                   When      w1nt10 <> *blanks
     c                   eval      lstlin = 10
     c                   When      w1nt09 <> *blanks
     c                   eval      lstlin = 09
     c                   When      w1nt08 <> *blanks
     c                   eval      lstlin = 08
     c                   When      w1nt07 <> *blanks
     c                   eval      lstlin = 07
     c                   When      w1nt06 <> *blanks
     c                   eval      lstlin = 06
     c                   When      w1nt05 <> *blanks
     c                   eval      lstlin = 05
     c                   When      w1nt05 <> *blanks
     c                   eval      lstlin = 04
     c                   When      w1nt03 <> *blanks
     c                   eval      lstlin = 03
     c                   When      w1nt02 <> *blanks
     c                   eval      lstlin = 02
     c                   When      w1nt01 <> *blanks
     c                   eval      lstlin = 01
     c                   endsl
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCKUPD  Check to see if note needs to be added or updated
     *
     C     zzckupd       begsr
     c     fileky1       chain     record
     c                   if        %found
      * see if notes have changed
     c                   if        note = rnnote
      * record has not changed
     c                   unlock    rtenote
     c                   goto      endckupd
     c                   endif

     C                   time                    rnchgts
     c                   eval      rnchgusr = #user
     c                   eval      rnchgjob = #job
     c                   eval      rnchgnbr = #jobn
     c                   eval      rnnote = note
     c                   update    record
     c                   endif

      * add new notes
     c                   if        not %found
     c                   eval      rnwhse   = $pwhse
     c                   eval      rnrtid   = $prtid
     c                   eval      rnline   = line
     c                   eval      rnnote   = note
     C                   time                    rnaddts
     C                   eval      rnchgts  = rnaddts
     c                   eval      rnaddusr = #user
     c                   eval      rnaddjob = #job
     c                   eval      rnaddnbr = #jobn
     c                   eval      rnchgusr = #user
     c                   eval      rnchgjob = #job
     c                   eval      rnchgnbr = #jobn
     c                   write     record
     c                   endif
     c     endckupd      endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     c                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     c                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     c                   Eval      w1nt01 = ' '
     c                   Eval      w1nt02 = ' '
     c                   Eval      w1nt03 = ' '
     c                   Eval      w1nt04 = ' '
     c                   Eval      w1nt05 = ' '
     c                   Eval      w1nt06 = ' '
     c                   Eval      w1nt07 = ' '
     c                   Eval      w1nt08 = ' '
     c                   Eval      w1nt09 = ' '
     c                   Eval      w1nt10 = ' '
     c                   clear                   screen1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     c                   select
     c                   when      rnline = 01
     c                   eval      w1nt01 = rnnote
     c                   when      rnline = 02
     c                   eval      w1nt02 = rnnote
     c                   when      rnline = 03
     c                   eval      w1nt03 = rnnote
     c                   when      rnline = 04
     c                   eval      w1nt04 = rnnote
     c                   when      rnline = 05
     c                   eval      w1nt05 = rnnote
     c                   when      rnline = 06
     c                   eval      w1nt06 = rnnote
     c                   when      rnline = 07
     c                   eval      w1nt07 = rnnote
     c                   when      rnline = 08
     c                   eval      w1nt08 = rnnote
     c                   when      rnline = 09
     c                   eval      w1nt09 = rnnote
     c                   when      rnline = 10
     c                   eval      w1nt10 = rnnote
     c                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1B  Fill remaining lines on screen one with default value
     *
     c     zzfil1b       begsr
     c                   dow       rnline < 10
     c* initialize remaining note lines
     c                   eval      rnline = rnline + 1
     C                   select
     c                   when      rnline = 1
     c                   eval      w1nt01 = ' '
     c                   when      rnline = 2
     c                   eval      w1nt02 = ' '
     c                   when      rnline = 3
     c                   eval      w1nt03 = ' '
     c                   when      rnline = 4
     c                   eval      w1nt04 = ' '
     c                   when      rnline = 5
     c                   eval      w1nt05 = ' '
     c                   when      rnline = 6
     c                   eval      w1nt06 = ' '
     c                   when      rnline = 7
     c                   eval      w1nt07 = ' '
     c                   when      rnline = 8
     c                   eval      w1nt08 = ' '
     c                   when      rnline = 9
     c                   eval      w1nt09 = ' '
     c                   when      rnline = 10
     c                   eval      w1nt10 = ' '
     c                   endsl
     c                   enddo
     c                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
     c                   eval      rnline = 0
     c     fileky        setll     record
     c                   dow       forevr = forevr
     C     fileky        reade(n)  record
     c                   if        %eof
     c                   exsr      zzfil1b
     c                   leave
     c                   endif
     c                   exsr      zzfil1
     c                   enddo
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
     C                   kfld                    $prtid
     *
     C     fileky1       klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    line
     *
     C                   eval      $lprg = #prog
     C                   eval      forevr = *off
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
     *   Init the screen
     *
     C                   eval      w1nt01 = ' '
     C                   eval      w1nt02 = ' '
     C                   eval      w1nt03 = ' '
     C                   eval      w1nt04 = ' '
     C                   eval      w1nt05 = ' '
     C                   eval      w1nt06 = ' '
     C                   eval      w1nt07 = ' '
     C                   eval      w1nt08 = ' '
     C                   eval      w1nt09 = ' '
     C                   eval      w1nt10 = ' '
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Identify first & last line of notes to handle blanks records
     *
     c                   exsr      zzckln
     *  Move screen fields to record fields
     c                   If        w1nt01 = ' '
     c                   eval      line = 001
     c                   eval      note = w1nt01
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt01 <> ' '
     c                   eval      line = 001
     c                   eval      note = w1nt01
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt02 = ' '
     c                   eval      line = 002
     c                   eval      note = w1nt02
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt02 <> ' '
     c                   eval      line = 002
     c                   eval      note = w1nt02
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt03 = ' '
     c                   eval      line = 003
     c                   eval      note = w1nt03
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt03 <> ' '
     c                   eval      line = 003
     c                   eval      note = w1nt03
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt04 = ' '
     c                   eval      line = 004
     c                   eval      note = w1nt04
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt04 <> ' '
     c                   eval      line = 004
     c                   eval      note = w1nt04
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt05 = ' '
     c                   eval      line = 005
     c                   eval      note = w1nt05
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt05 <> ' '
     c                   eval      line = 005
     c                   eval      note = w1nt05
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt06 = ' '
     c                   eval      line = 006
     c                   eval      note = w1nt06
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt06 <> ' '
     c                   eval      line = 006
     c                   eval      note = w1nt06
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt07 = ' '
     c                   eval      line = 007
     c                   eval      note = w1nt07
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt07 <> ' '
     c                   eval      line = 007
     c                   eval      note = w1nt07
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt08 = ' '
     c                   eval      line = 008
     c                   eval      note = w1nt08
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt08 <> ' '
     c                   eval      line = 008
     c                   eval      note = w1nt08
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt09 = ' '
     c                   eval      line = 009
     c                   eval      note = w1nt09
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt09 <> ' '
     c                   eval      line = 009
     c                   eval      note = w1nt09
     c                   exsr      zzckupd
     c                   endif
     c                   If        w1nt10 = ' '
     c                   eval      line = 010
     c                   eval      note = w1nt10
     c                   exsr      zzckaction
     c                   endif
     c                   if        w1nt10 <> ' '
     c                   eval      line = 010
     c                   eval      note = w1nt10
     c                   exsr      zzckupd
     c                   endif

     c
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
