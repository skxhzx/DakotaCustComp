     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK112     Dock door maint - Change
     *  05 November 2001
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    11/05/01  DAS  4.16
     *      - Created.
     *
     *----------------------------------------------------------------

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

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdk112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fdocdoor   uf a e           k disk
     F                                     rename(ddrec:record)
     Fwarehs    if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
     D desc            s             20    dim(2) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80

     *   Redefine key

     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdoor                27     29  0

     *----------------------------------------------------------------
     *  Called program parameters
     *----------------------------------------------------------------

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
     D error           s               n
     D fillscreen      s              3
     D forevr          s               n
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erpo#                  1      5p 0
     D  eritem                 6     20
     D                 ds
     D  $ec                    1      2p 0

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Workstation exception data structure
     *----------------------------------------------------------------

     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371

     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *----------------------------------------------------------------

     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4

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

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $parms

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = '1'
     C                   move      'EOJ'         nxtscr
 1E  C                   endif

 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
 2E  C                   endcs
 1E  C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr

     *   Set ON alarm indicator if error occured

 1B  C                   if        error = '1'
     C                   eval      *in98 = *on
 1E  C                   endif

     *   Overlay screen with error messages

     C                   exsr      zmdmsg

     *  Overlay screen with screen to be processed.

 1B  C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
 1E  C                   endif

     *   Initialize error indicators and fields

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

     *   Initialize error subfile

     C                   exsr      zmcmsg

     C                   endsr

     *----------------------------------------------------------------
     *     Screen initialization and wrap-up routines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Screen 01 initialization
     *----------------------------------------------------------------

     C     scr01i        begsr
     C                   move      '01 '         nxtscr

 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
 1E  C                   endif

     *  Get field defaults if this is an add.

 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 1X  C                   else

     *  Otherwise get existing record(s).

     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 1E  C                   endif
     C     end01i        endsr

     *----------------------------------------------------------------
     *              Screen Processing Routines
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

     C     sc1           begsr

     *  Test for F3 - Exit

 1B  C                   if        *inkc
     C     *loval        setll     record
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto C                   goto      endsc1
 1E  C                   endif

     *  Test for F5 - Refresh

 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
 2E  C                   endif
goto C                   goto      endsc1
 1E  C                   endif

     *  Test for F12 - Previous

 1B  C                   if        *inkl
     C     *loval        setll     record
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto C                   goto      endsc1
 1E  C                   endif

     *  Test for other command keys BEFORE verification and update.

     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Some other key pressed.

     *     Check input and write/update record.

 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zzupd
     C     error         cabeq     '1'           endsc1
 1E  C                   endif

     *  Test for other command keys AFTER verification and update.

     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1

     *  Everything went fine so get out of program.

     C                   move      'EOJ'         nxtscr
     C     endsc1        endsr

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Initialize special keys

     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125

     *  Initialize message handling

     C                   exsr      zmimsg

     *   Call user added initialization routine.

     C                   exsr      zzinz
     C                   endsr

     *---------------------------------------------------------------
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *---------------------------------------------------------------

     *---------------------------------------------------------------
     *    ZMCMSG  Clear message record subfile
     *---------------------------------------------------------------

     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMDMSG  Display message record subfile
     *---------------------------------------------------------------

     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
 1E  C                   endif
     C                   endsr

     *---------------------------------------------------------------
     *    ZMIMSG  Initialization necessary for message subfile
     *---------------------------------------------------------------

     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr

     *---------------------------------------------------------------
     *    ZMPMSG  Add message record to subfile
     *---------------------------------------------------------------

     C     zmpmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
 1E  C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
 1B  C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
 1E  C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *---------------------------------------------------------------
     *    ZMQMSG  Add message record to subfile from program queue
     *---------------------------------------------------------------

     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr

     *---------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   move      *on           sclear
     C                   endsr

     *---------------------------------------------------------------
     *    ZMSMSG  Send program message to a different program msgq
     *---------------------------------------------------------------

     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
 1E  C                   endif
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

     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *----------------------------------------------------------------

     C     zm01          begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *----------------------------------------------------------------

     C     zm02          begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *----------------------------------------------------------------

     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *----------------------------------------------------------------

     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *----------------------------------------------------------------

     C     zm73          begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *----------------------------------------------------------------

     C     zm74          begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *----------------------------------------------------------------

     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *----------------------------------------------------------------

     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   move      '0'           error

     *  When adding ....

 1B  C                   if        $pcmd = '*ADD    '

     *    Make sure code was entered.

 2B  C                   if        w1whdp = ' '  and w1door = 0
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm01
     C                   goto      endck1
 2E  C                   endif

     *    Make sure code doesn't already exist.

     C                   eval      $pwhdp = w1whdp
     C                   eval      $pdoor = w1door
     C     fileky        chain(n)  record
 2B  C                   if        %found
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   exsr      zm02
 2E  C                   endif
 1E  C                   endif

     *  Verify department.

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*PGMQ'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 4E  C                   endif

     *  Verify status.

     C                   if        %scan(w1stat : 'AI') = 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(2)
     C                   exsr      zm1001
     C                   goto      endck1
     C                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

 1B  C                   if        cmdchk = '*BEFORE '

     *  Test for F4 - Lookup

 2B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
 3B  C                   select

     *     Warehouse department.

 3X  C                   when      row# = 10
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
 4E  C                   endif

 3X  C                   other

     *     Cursor not on a valid lookup field.

     C                   move      *on           error
     C                   exsr      zm9905
 3E  C                   endsl
goto C                   goto      endcm1
 2E  C                   endif
 1E  C                   endif

     *  Command keys to check AFTER verification and update.

 1B  C                   if        cmdchk = '*AFTER  '
 1E  C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZDFT1   Get default values for add.
     *----------------------------------------------------------------

     C     zzdft1        begsr
     C                   eval      w1whdp = *blanks
     C                   eval      w1door = 0
     C                   eval      w1maxc = 0
     C                   eval      w1stat = 'A'
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr
     C                   move      ddwhdp        w1whdp
     C                   move      dddoor        w1door
     C                   move      ddmaxc        w1maxc
     C                   move      ddstat        w1stat
     C                   endsr

     *----------------------------------------------------------------
     *  ZZGET1   Get record(s) for screen 1.
     *----------------------------------------------------------------

     C     zzget1        begsr

     *   Get record from main file.

 1B  C                   if        $pcmd = '*VIEW   '
     C     fileky        chain(n)  record                             7978
 1X  C                   else
     C     fileky        chain     record                             7978
 1E  C                   endif

     *  Record locked.

 1B  C                   if        *in78
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm74
goto C                   goto      endgt2
 1E  C                   endif

     *  Record not found.

 1B  C                   if        *in79
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm73
goto C                   goto      endgt2
 1E  C                   endif
     C     endgt2        endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr

     *  Define key for main file.

     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pdoor
     C                   kfld                    $pwhdp

     C                   move      *off          forevr
     C                   eval      $lprg = #prog
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr

     *   Get warehouse description.

     C     $pwhse        chain     warehs                             79
 1B  C                   if        *in79
     C                   eval      whdesc = *blanks
 1E  C                   endif

     *   Select first screen to display.

 1B  C                   if        $pcmd = '*ADD    '
     C                   eval      $pwhdp = *blanks
     C                   eval      $pdoor = 0
 1E  C                   endif
     C                   exsr      scr01i
     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD    Update record.
     *----------------------------------------------------------------

     C     zzupd         begsr
     C                   move      '0'           error

     *  Move screen fields to record fields

     C                   eval      ddwhse = $pwhse
     C                   eval      ddwhdp = w1whdp
     C                   eval      dddoor = w1door
     C                   eval      ddmaxc = w1maxc
     C                   eval      ddstat = w1stat

     *   Add record

 1B  C                   if        $pcmd = '*ADD    '
     C                   write(e)  record
 2B  C                   if        %error
     C                   eval      error = *on
     C                   exsr      zm71
goto C                   goto      endupd
 2E  C                   endif
 1X  C                   else

     *   -OR- Update record (it was read and locked in ZZGET2)

     C                   update(e) record
 2B  C                   if        %error
     C                   eval      error = *on
     C                   exsr      zm72
goto C                   goto      endupd
 2E  C                   endif
 1E  C                   endif

     *   Move key values to parameters

     C                   eval      $pwhdp = ddwhdp
     C                   eval      $pdoor = dddoor
     C     endupd        endsr

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Dock Door
Status
