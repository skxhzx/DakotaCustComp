     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IC112     UCI Catch Weight maintenance - Change
     *  04 August  2006
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
510 A*    08/04/06  JCJ  5.10
     *      - Created
     *
510aA*    09/07/06  JCJ  5.10a
     *      - Enh: Added UCIADJ file processing
510bA*    09/29/06  RAH  5.10b
     *      - Enh: Added UCILOG file processing
510cA*    01/29/07  RAH  5.10c
     *      - Enh: Corrected loading of the stock flag as well as the pick
     *             and return flags.
510dA*    04/28/07  DAS  5.10d
     *      - Revised zzfil1 to set w1sts to A when ucists is A.
     *      - Revised to verify w1sts is Y or N.
     *      - Revised to update ucists from w1sts instead of
     *        setting to 'A'.
     *      - Revised to load picking tran and label.
     *
700aA*    08/30/16  LMC  700a
     *      - Enh: UCILOG file was renamed to PUCILOG, so we could
     *             reuse UCILOG for our uci tracking.
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
     Fui112fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fucicw     uf a e           k disk    rename(ucirec:record)
     Fucicw3    if   e           k disk    rename(ucirec:record3)
     Fpiritem   if   e           k disk
510aAFuciadj    o    e             disk
700aDF*ucilog    o    e             disk
700aMFpucilog   o    e             disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
510dDD*desc            s             20    dim(4) ctdata perrcd(1)
510dMD desc            s             20    dim(5) ctdata perrcd(1)
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
     D  $pitem                22     36
     D  $ucinb                57     66
510aAD  $lcode                67     68
     *----------------------------------------------------------------
     *  Called Program parameters
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
     D currstamp       s               z
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
     *
     D today           s              8  0
     D curtim          s              6  0
     D clear           s              5  0
     D comand          s              5  0
     D enter           s              5  0
     D help            s              5  0
     D rolldn          s              5  0
     D rollup          s              5  0
     D msgk            s              4  0
     D e               s              2  0
     D $msgf           s             10
510bAD @Caller         S             10
510bAD @Counter        S             15  5
     D #pgmq           s             10
     D $ucmd           s              8
     D #msgid          s              7
     D #msgtp          s              7
     D nxtscr          s              3
     D cmdtkn          s              1
     D error           s              1
     D sclear          s              1
     D warn            s              1
510aAD $ptype          s              1
     D curtime         s               z
     D isoDate         s               d   datfmt(*ISO)
     D mdyDate         s               d   datfmt(*MDY)

     D $cbbar          s            100
     D $cbcmd          s              8
     D $cbcod          s              3  0
     D $cbdec          s              1  0
     D $cbdsc          s             30
     D $cbpos          s              3  0
     D $cbtyp          s              1  0
     D $cbv1           s             11  3
     D $cbv2           s             50
     D $cbrtn          s              8
     D $cberm          s             60

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new UCI Code.
510aA*               *ADDADJ - Add Adustment.
     *              *EDIT    - Edit batch.
     *              *DELETE  - UCI Delete.
510aA*               *DLTADJ - Delete Adjustment
     *              *View    - View batch.
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
510aAC                   parm                    $ptype
     *
510bAC     UI866P        Plist
510bAC                   Parm                    @Caller
510bAC                   Parm                    @Counter
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   if        $pcmd = 'VIEW  '
     C                   eval      *in90 = *on
     C                   endif
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
     *  Initialize error indicators and fields
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
     *  Initialize error subfile
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
     *  Test for other command keys
     *
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
     *
510bA * Determine Calling program
510bA
510bAC                   Eval      @Counter = 4
510bAC                   Eval      @Caller  = *Blanks

510bAC                   Call      'UI866'       UI866P
     *
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
     C                   movea     desc(4)       errmsg
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
     *    PIR0105  Generic error.
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
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
     *   PIR1012  Value must be 'Y' or 'N'
     *----------------------------------------------------------------
     C     zm1012        begsr
     C                   eval      #msgid = 'PIR1012'
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
     *  When adding ....
     *
     C                   if        $pcmd = '*ADD    '
     *
     *    Make sure code doesn't already exist.
     *
     C     uciky         chain     record
     C                   if        %found(ucicw)
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm02
     C                   endif
     C                   endif

     *  Verify catch weight

     C                   movel(P)  w1wgt         $cbbar
     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd
     C                   parm                    $cbbar
     C                   parm      *zeros        $cbcod
     C                   parm      *zeros        $cbdec
     C                   parm      *blanks       $cbdsc
     C                   parm      *zeros        $cbpos
     C                   parm      *zeros        $cbtyp
     C                   parm      *zeros        $cbv1
     C                   parm      *blanks       $cbv2
     C                   parm      *blanks       $cbrtn
     C                   parm      *blanks       $cberm

     C                   if        $cbrtn <> '*OK'
     C                   move      *on           error
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg    = $cberm
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Verify receive date

     C                   if        w1rdt <> *zeros
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1rdt         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Verify experation date

     C                   if        w1edt <> *zeros
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1edt         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     *    Pick Flag edit.
     *
     C                   if        w1pck <> 'Y' and
     C                             w1pck <> 'N'
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       errmsg
     C                   exsr      zm1005
     C                   endif
     *
     *    Returns Flag edit.
     *
     C                   if        w1rts <> 'Y' and
     C                             w1rts <> 'N'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       errmsg
     C                   exsr      zm1005
     C                   endif

     *  Verify returns date

     C                   if        w1rde <> *zeros
     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1rde         $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
     C                   endif
     C                   endif
510dA*
510dA*    Stock Code edit.
510dA*
510dAC                   if        w1sts <> 'Y' and
510dAC                             w1sts <> 'N'
510dAC                   eval      error = *on
510dAC                   eval      *in37 = *on
510dAC                   eval      *in17 = *on
510dAC                   eval      errmsg = *blanks
510dAC                   movel     desc(4)       errmsg
510dAC                   exsr      zm1005
510dAC                   endif

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   eval      w1inbr = *blanks
510cMC                   eval      w1sts  = 'Y'
510cDC*                  eval      w1sts  = 'Active '
     C                   eval      w1item = $pitem
     C                   eval      w1lcn  = *blanks
     C                   eval      w1lot  = *blanks
     C                   eval      w1wgt  = *zeros
     C                   eval      w1inb  = *blanks
     C                   eval      w1out  = *blanks

     C                   move      today         isodate
     C                   move      isodate       mdydate
     C                   move      mdydate       w1rdt

     C                   eval      w1rtm  = *zeros

     C                   move      mdydate       w1edt

     C                   eval      w1pck  = 'N'
     C                   eval      w1rts  = 'N'

     C                   move      mdydate       w1rde

     C                   eval      w1rcd  = 'N'
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

510cAC                   eval      w1pck  = *blank
510cAC                   eval      w1rts  = *blank

     C                   select
510cDC*                  when      ucists = 'A'
510cDC*                  eval      w1sts = 'Active '
510cDC*                  when      ucists = 'D'
510cDC*                  eval      w1sts = 'Deleted'
510dAC                   when      ucists = 'A'
510dAC                   eval      w1sts = 'A'
510cMC                   when      ucists = 'Y'
510cMC                   eval      w1sts = 'Y'
510cMC                   when      ucists = 'N'
510cMC                   eval      w1sts = 'N'
510cAc                   if        ucipck = *blank
510cAc                   eval      w1pck = 'N'
510cAc                   endif
510cAc                   if        ucirts = *blank
510cAc                   eval      w1rts = 'N'
510cAc                   endif
     C                   other
510cMC                   eval      w1sts = 'Y'
510cDC*                  eval      w1sts = 'Active '
     C                   endsl

     C                   eval      w1inbr = ucinbr

     C                   eval      w1item = uciitm
     C                   eval      w1ides = *blanks
     C     itemky        chain     piritem
     C                   if        %found(piritem)
     C                   eval      w1ides = itdesc
     C                   endif

     C                   eval      w1wgt  = uciwgt
     C                   eval      w1lcn  = ucilcn
     C                   eval      w1lot  = ucilot
     C                   eval      w1inb  = uciinb
     C                   eval      w1out  = uciout

     C                   if        ucirdt = *zeros
     C                   eval      w1rdt  = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ucirdt        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1rdt  = $cvd6o
     C                   endif

     C                   eval      w1rtm  = ucirtm

     C                   if        uciedt = *zeros
     C                   eval      w1edt  = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      uciedt        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1edt  = $cvd6o
     C                   endif

510cAc                   if        ucipck <> *blank
     C                   eval      w1pck  = ucipck
510cAc                   endif
510cAc                   if        ucirts <> *blank
     C                   eval      w1rts  = ucirts
510cAc                   endif

     C                   if        ucirde = *zeros
     C                   eval      w1rde  = *zeros
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      ucirde        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1rde  = $cvd6o
     C                   endif

     C                   eval      w1rcd  = ucircd
510dAC                   eval      w1pkt  = ucipkt
510dAC                   eval      w1rtt  = ucirtt
510dAC                   eval      w1lbl  = ucilbl
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
     C     fileky        klist
     C                   kfld                    $pwhse
     C                   kfld                    $ucinb
     *
     *  Define key for piritem
     *
     C     itemky        klist
     C                   kfld                    $pwhse
     C                   kfld                    uciitm
     *
     *  Define key for piritem
     *
     C     uciky         klist
     C                   kfld                    $pwhse
     C                   kfld                    w1inbr
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    curtim
     *
510aAC                   if        $pcmd = '*ADDADJ '
510aAC                   eval      $ucmd = '*ADDADJ '
510aAC                   eval      $pcmd = '*ADD    '
510aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get warehouse description
     *
     C                   eval      w1desc = *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn <> '*ERROR  ' and
     C                             $lrtn <> '*PGMQ   '
     C                   eval      w1desc = $lerm
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   if        $pcmd = '*ADD    '
     C                   endif
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     C
     C                   if        $pcmd = '*ADD    '
     C                   eval      ucisq2 = 00001
     C                   endif
     *
     *  Move screen fields to record fields
     *
     C                   eval      uciwhs = $pwhse
     C                   eval      ucinbr = w1inbr
     C                   eval      uciitm = w1item
     C                   eval      ucilcn = w1lcn
     C                   eval      uciwgt = w1wgt
     C                   eval      ucilot = w1lot
     C                   eval      uciinb = w1inb
     C                   eval      uciout = w1out
      * receipt date
     C                   if        w1rdt  = *Zeros
     C                   eval      ucirdt = *Zeros
     C                   else
     C                   move      w1rdt         mdydate
     C                   move      mdydate       isodate
     C                   move      isodate       ucirdt
     C                   endif
     C                   eval      ucirtm = w1rtm
      * expiration date
     C                   if        w1edt  = *Zeros
     C                   eval      uciedt = *Zeros
     C                   else
     C                   move      w1edt         mdydate
     C                   move      mdydate       isodate
     C                   move      isodate       uciedt
     C                   endif
     C                   eval      uciqty = 1
     C                   eval      ucipck = w1pck
     C                   eval      ucirts = w1rts
      * returns date
     C                   if        w1rde  = *Zeros
     C                   eval      ucirde = *Zeros
     C                   else
     C                   move      w1rde         mdydate
     C                   move      mdydate       isodate
     C                   move      isodate       ucirde
     C                   endif
     C                   eval      ucircd = w1rcd
510dDC**                 eval      ucists = 'A'
510dMC                   eval      ucists = w1sts
510dAC                   eval      ucipkt = w1pkt
510dAC                   eval      ucirtt = w1rtt
510dAC                   eval      ucilbl = w1lbl
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

510aAC                   if        $ucmd = '*ADDADJ '
510aAC                   eval      uawhse = $pwhse
510aAC                   eval      uainbr = ucinbr
510aAC                   eval      uacode = 'A'
510aAC                   eval      uarscd = $lcode
510aAC                   eval      uaapgm = 'UI112'
510aAC                   eval      uatype = $ptype
510aAC                   eval      uaoitm = *blanks
510aAC                   eval      uanitm = uciitm
510aAC                   eval      uaowgt = *zeros
510aAC                   eval      uanwgt = uciwgt
510aAC                   eval      uadate = Today
510aAC                   eval      uatime = curtim
510aAC                   eval      uaedat = *zeros
510aAC                   eval      uaetim = *zeros
510aAC                   write     uacrec
510bAc                   eval      ultflg = 'ADD   '
510bAc                   exsr      writeucilog
510aAC                   endif

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
     C     endupd        endsr
     *
     O*----------------------------------------------------------------*********
510bA *
510bA *  Write PUCILOG record.
510bA
510bAC     writeucilog   begsr
510bA
510bAc                   eval      ulwhse = $pwhse
510bAc                   eval      ulinbr = ucinbr
510bAc                   eval      uliitm = uciitm
510bAc                   eval      ulcpgm = @caller
510bAc                   eval      ulcwgt = uciwgt
510bAc                   eval      uladte = ucirdt
510bAc                   eval      ulatim = ucirtm
510bAc                   eval      uluser = #user
510bAC                   eval      uljob  = #job
510bAc                   eval      uljnbr = #jobn
510bAc                   eval      ultype = *blank
510bAc                   eval      ulptyp = *blank
510bAc                   eval      ulupgm = 'UI112'
510bAc                   eval      ulpo = *blanks
510bAc                   eval      ulseq# = *zeros
510bAc                   eval      ulptrn = *zeros
510bAc                   eval      ullcn# = ucilcn
510bAc                   eval      ulord  = *zeros
510bAc                   eval      uloseq = *zeros
510bAc                   eval      ulstrn = *zeros
510bAc                   eval      ullbl# = *zeros
510bAc                   eval      ulcode = *blanks
510bA
510bAc                   write     ulrec
510bA
510bAC                   endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Item Category
Pick Flag
Returns Flag
UCI Number
Stock Code
