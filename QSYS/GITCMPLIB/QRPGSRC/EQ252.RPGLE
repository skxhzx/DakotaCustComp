     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  EQ252     Equipment Misc question maintenance - Change
     *  26 March 2014
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
     *
     *  Program Modification History
     *    03/26/14  RH   6.50
     *      - Created using EQ212
     *
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
     Feq252fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fequipm    uf a e           k disk
     F                                     rename(emrec:record)
     Fequipy    if   e           k disk
     Fequipq1   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             50    dim(5) ctdata perrcd(1)
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
     D  $pwhs                 19     21
     D  $ptype                22     27
     D  $pio                  28     28
     *                                      25  290$PSEQ#
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
     D  $llevl                22     25
     D  $ltype                26     28
     D  $ltypedesc            29     53
     D  $llook                54     63
     D  $lentry               64     64
     D  $lusrctl              65     65
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
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D $pwhse          s              3  0
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D displayall      s               n
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D kseq#           s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D nxtsq           s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D warn            s              1
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
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   eval      *in02 = *on
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
     *  Test for other command keys
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
     C                   eval      forevr = *off
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
     *   PIR0203  Value can not be blank.
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
417 D**                   MOVEADESC      ERRMSG
     C                   movea     errmsg        $md(1)
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
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
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
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     *
     *    Make sure Status was entered.
     *
     C                   if        w1stat = *blanks
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   eval      *in04 = *on
     C                   eval      *in24 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Status A/I.
     *
     C                   if        w1stat <> *blanks
     C                   if        w1stat <> 'A'  and
     C                             w1stat <> 'I'
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(5)
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     *    Make sure User Question level was entered.
     *
     C                   if        w1ulvl = *blanks
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   eval      *in02 = *on
     C                   eval      *in22 = *on
     C                   exsr      zm03
     C                   endif
     *
     *
     *    Make sure Question type was entered
     *
     C                   if        w1utyp = *blanks
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   exsr      zm03
     C                   endif
     *
     *
     *    Make sure check in/out was entered.
     *
     C                   if        w1io = *blanks
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Check in/out I/O.
     *
     C                   if        w1io <> *blanks
     C                   if        w1io <> 'I'  and
     C                             w1io <> 'O'
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm1001
     C                   endif
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
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
     *     Question Type.
     *
     C                   when      row# = 08 and $pcmd = '*ADD'
     C                   eval      $lcmd = '*SELECT '
     C                   eval      $lwhse = $pwhse
     c                   eval      $lusrctl = 'Y'
     C                   call      'HB900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1utyp = $ltype
     C                   eval      w1ulvl = $llevl
     c                   eval      displayall = *on
     C                   endif
     c                   endsl
     C                   endif
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1ulvl = *blanks
     C                   eval      w1utyp = *blanks
     C                   eval      w1io = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   eval      w1stat = emstat
     C                   eval      w1utyp = emutyp
     C                   eval      w1ulvl = emulvl
     C                   eval      w1io = emio
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
     C                   move      $pwhs         $pwhse
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ptype
     C                   kfld                    $pio
     *
     C     sqkey         klist
     C                   kfld                    kseq#
     *
     *  Get last sequence #.
     *
     C                   exsr      zzseq1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get Equipment type description.
     *
     C     $ptype        chain     equipy                             79
     C                   if        *in79
     C                   eval      wotdsc = *blanks
     C                   else
     C                   eval      wotdsc = eydesc
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     **                   MOVE *BLANKS   $PCODE
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSEQ1   Get last sequence #.
     *
     C     zzseq1        begsr
     *  Get last sequence #.
     *
     C                   eval      kseq# = 99999
     C     sqkey         setll     equipq1
     C                   dow       forevr = forevr
     C                   readp     equipq1                                79
     C                   if        *in79
     C                   leave
     C                   else
     C                   eval      nxtsq = euseq#
     C                   leave
     C                   endif
     C                   enddo
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     C                   if        $pcmd = '*ADD    '
     ***                  EXSR ZZSEQ1
     C                   endif
     *
     *  Move screen fields to record fields
     *
     C                   eval      emwhse = $pwhse
     C                   eval      emtype = $ptype
     C                   eval      emstat = w1stat
     C                   eval      emutyp = w1utyp
     C                   eval      emulvl = w1ulvl
     C                   eval      emio = w1io
     *
     *   Add record
     *
     C                   if        $pcmd = '*ADD    '
     ***        NXTSQ     ADD  1         EUSEQ#
     C                   write     record                               79
     ***                  Z-ADDEUSEQ#    $PSEQ#
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm71
     C                   goto      endupd
     C                   endif
     C                   else
     *
     *   -OR- Update record (it was read and locked in ZZGET2)
     *
     C                   update    record                               79
     C                   if        *in79
     C                   eval      error = *on
     C                   exsr      zm72
     C                   goto      endupd
     C                   endif
     C                   endif
     *
     *   Move key values to parameters
     *
     C                   eval      $pio = emio
     *R                   MOVE EMTYPE    $PCODE
     C     endupd        endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Equip Misc Level
Equip Misc Type
Check in/out
Display Warning
Status
