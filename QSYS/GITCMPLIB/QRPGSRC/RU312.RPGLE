     H copyright('(c) Copyright BFC Software, Inc - 2006')
     H option(*nodebugio)
     *---------------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *---------------------------------------------------------------------
     *
     *  RU312     RF - Runner Flag Catchweight entry
     *  06 February 2006
     *  Jeffrey Jahnke
     *
     *---------------------------------------------------------------------
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *      16 X 20 Screens for hand held scanners
     *
     *---------------------------------------------------------------------
     *  Revisions
     *
500 A*    02/16/06  JCJ  5.00
     *      - Created.
     *
500aA*    05/16/06  JCJ  5.00a
     *      - Enh: bypass variance logic if high / low variance is 0.
     *
510aA*    10/06/06  RAH  5.10a
     *      - Enh: On F3 or F12, if number of weights entered
     *             is less than the quantity, display WARNING msg.
     *             On subsequent F3 or F12, allow exit.
     *      - Enh: Changed Item Description load
530a *    08/08/10  GJA  5.30a
     *      - Fix: F13 was exiting screen.
650aA*    03/15/13  LMC  6.50a
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
700aA*    04/05/16  LMC  7.00a
     *      - Enh: Adding logic for Metric.
700bA*    12/19/16  MLB  7.00b
     *      - Fix: Revised program to not allow user to press F13=Done
     *        without warning user that wgts are missing or out of
     *        tolerance like F3/F12 do. Was allowing user to exit pgm
     *        without entering any weights.
700cA*    12/23/16  MLB  7.00c
     *      - Enh: Added client location parm to GETCLIENT call.
700dA*    12/23/16  MLB  7.00d
     *      - Enh: Renamed RU31201 to RU31202 as part of CBI mod.
700eA*    12/23/16  MLB  7.00e
     *      - Enh: Changed edit code used on wgt cnt error to show zero.
740aA*    02/20/20  LMC  7.40a
     *      - Fix: Once the override for the f13 normore warning      o.
     *        is taken. We are done.                                  o.
     *
     *---------------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
     *
CBI A*    12/23/16  MLB  CBI
     *      - Revised program to not allow user to press F3, F12 or F13
     *        unless weight line has word, EXIT entered and WARN flag has
     *        been turned on. Users were exiting pgm before c/wgts were
     *        being entered.
     *
     *---------------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  92 - 93   VIEW MODE (PROTECT INPUT FIELDS)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *---------------------------------------------------------------------
     *  File Specs
     *---------------------------------------------------------------------

700aDF*ru312fm   cf   e             workstn
700dDF*ru31201   cf   e             workstn
700dMFru31202   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Flabel     if   e           k disk
     Fordc      if a e           k disk

700aA*----------------------------------------------------------------
700aA*  Table and array definitions
700aA*----------------------------------------------------------------

700aAD cmdln           s             79    dim(3)ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Client ID's for custom mods
     *----------------------------------------------------------------

     D @getcl          c                   const('GETCLIENT')
CBI A /COPY *libl/qcopysrc,id#cheney

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
650aA /COPY *libl/qcopysrc,C#CWLOG

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
     *  Redefine key
     *
     D  $pwhse                19     21  0
     D  $plbl#                22     28  0
     D  $pqyfd                29     33  0
     D  $phcwgt               34     40  2
     D  $plcwgt               41     47  2
     D  $perror               48     48

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
     D  $lord                 22     28  0
     D  $lseq                 29     33  0
     D  $litem                34     48
     D  $lrtid                49     53
     D  $lpbat                54     60  0
     D  $llbl#                61     67  0
     *
     D  $lwhs2                19     21  0
     D  $litm2                22     36
     D  $lwhd2                37     41
     D  $ldsp2                42     53

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
650aA*----------------------------------------------------------------
650aA*  Prototypes
650aA*----------------------------------------------------------------
650aA /copy qcopysrc,p.cw800
650aA /copy qcopysrc,p.getuser
700aA /copy qcopysrc,p.getimuom

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

500 A*----------------------------------------------------------------
500 A*  *SYSTEM  -  System options.
500 A*----------------------------------------------------------------
500 A*
500 A* Fields
500 A*
500 A*    OPEPM   -  Using EPM module (Y,N).
500 A*    OPRF    -  Using RF module (Y,N).
500 A*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
500 A*    OPLETD  -  Print letdown labels (Y,N).
500 A*    OPWRNC  -  Perform catch weight variance check (Y,N).
500 A*    OPRG1C  -  Catch weight low variance percentage.
500 A*    OPRG2C  -  Catch weight high variance percentage.
500 A*    OPIMPI  -  Import item fields from host.(Y,N).
500 A*    OPICW   -  Individual catch weight entry (Y,N).
500 A*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
500 A*    OPRCDY  -  Number of days to keep receiving logs.
500 A*    OPMPCK  -  Number of days to keep picking logs.
500 A*    OPRTHS  -  Number of weeks - exported routes to keep.
500 A*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
500 A*    OPPOHS  -  Number of weeks - exported p/o's to keep.
500 A*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
500 A*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
500 A*
500 A* Data structure
500 A*
500 AD opdata          ds
500 AD  opepm                  1      1
500 AD  oprf                   2      2
500 AD  opcapc                 3      3
500 AD  opletd                 4      4
500 AD  opwrnc                 5      5
500 AD  oprg1c                 6      8  1
500 AD  oprg2c                 9     11  1
500 AD  opimpi                12     12
500 AD  opicw                 13     13
500 AD  opmpck                14     14
500 AD  oprcdy                15     15  0
500 AD  oppkdy                16     16  0
500 AD  oprths                17     19  0
500 AD  opcrhs                20     22  0
500 AD  oppohs                23     25  0
500 AD  opiahs                26     28  0
500 AD  opmshs                29     31  0
500 AD  optend               117    117

     *----------------------------------------------------------------
     *  Working variables
     *----------------------------------------------------------------

     D $cbv1           s             11  3
     D curdate         s              8  0
     D kyplic          s              7  0
     D curtime         s              6  0
     D lasttime        s              6  0 inz(999999)
     D rolldn          s              5  0
     D rollup          s              5  0
     D help            s              5  0
     D i               s              5  0
     D enter           s              5  0
     D clear           s              5  0
     D comand          s              5  0
     D pickcount       s              5  0
     D msgk            s              4  0
     D $cbcod          s              3  0
     D $cbpos          s              3  0
     D e               s              2  0
     D savever#        s              2  0
     D $cbdec          s              1  0
     D $cbtyp          s              1  0
     D $cbbar          s            100
     D $istr           s             70
     D $cberm          s             60
     D $cbv2           s             50
     D $cbdsc          s             30
     D $idesc          s             30
     D $iitem          s             15
     D $ipdsc          s             15
     D wodisp          s             12
     D $msgf           s             10
     D client          s             10
700cAD clientloc       s             10
     D $cbrtn          s              8
     D #lcmd           s              8
     D $cbcmd          s              8
     D cmdchk          s              8
     D #msgid          s              7
     D #msgtp          s              7
     D #lcol           s              3
     D nxtscr          s              3
     D #lline          s              2
     D redspl          s              1
     D refrsh          s              1
     D cmdtkn          s              1
     D sclear          s              1
     D warn            s              1
740aAD f13warn         s              1
     D ovrrid          s              1
510aAD f3ovr           s              1
510aAD f3qty           s              5  0
     D vrchk           s              1
     D error           s               n
650aAD CWcmd           s             10
650aAD CWpgm           s             10
650aAD CWrtn           s             10
650aAD CWmsg           s             60
650aAD CWdata          s            512
650aAD processstatus   s             10
650aAD e$whse          s              3  0
650aAD e$emp#          s              5  0
650aAD e$fnam          s             15
650aAD e$init          s              1
650aAD e$lnam          s             20
650aAD e$whdp          s              5
650aAD e$styp          s              1
650aAD e$shft          s              6
650aAD e$crew          s              6
650aAD e$nhrs          s              3  1
650aAD e$rtn           s              8
650aAD e$bpu           s              1
650aAD e$lng           s              2

700aAD KiloLbs         s              1
700aAD IMkilolbs       s              1
700aAD IMUom           s              3
700aAD wkwhse          s                   like(lbwhse)
     *----------------------------------------------------------------
     *  Catchweight Multiple-Occurence Data Structure
     *----------------------------------------------------------------

     D #cwmax          s              5  0 inz(100)
     D #cwprev         s              5  0

     D #cwentries      ds                  occurs(100)
     D  #cwentry                     50
     D  #cwweight                     7  3 inz(0)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')
510 AD @fmtit          c                   const('FRMTIT')

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

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *----------------------------------------------------------------

     D $mdt            ds
     D  errmsg                 1     50

     D  err01          c                   'Order not found'

     *----------------------------------------------------------------
     *  Message control
     *----------------------------------------------------------------

     D #msgf           c                   const('PIRMSGF   ')

     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)

     *----------------------------------------------------------------
     *  Let the show begin .....
     *
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
     C                   eval      w1cnt = 1
     C                   exsr      zzinz2
     C                   if        error = '1'
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo

     *   Do some clean up before leaving.

     C                   exsr      zsclr
     C                   return

     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *----------------------------------------------------------------

     C     dspscr        begsr
     C                   write     clrscr
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
     C                   select
     C                   when      #lline = '16'
     C                   exfmt     screen61                             50
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
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
     C                   eval      redspl = *off
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
     *----------------------------------------------------------------

     C     scr01i        begsr

     C                   eval      nxtscr = '01 '
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
510aAC                   eval      f3ovr = *off
740aAC                   eval      f13warn = *off
     C     end01i        endsr

     *----------------------------------------------------------------
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *  SC1  -  Screen 1
     *----------------------------------------------------------------

     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     *
510aA*  Check if they've entered all the weights
     *
510aAc                   eval      f3qty = w1cnt - 1
510aAc                   if        f3ovr = *off and
510aAc                             f3qty < w1qty
CBI A*
CBI Ac                             or client = Cheney
CBI Ac                             and f3ovr = *on
CBI Ac                             and f3qty < w1qty
CBI Ac                             and %trim(w1cw) <> 'EXIT'
CBI A*
510aAc                   move      *on           error
510aAc                   eval      *in21 = *on
510aAc                   eval      *in01 = *on
510aAc                   eval      errmsg = %trim('WARN') + ' ' +
700eMc                                      %trim(%editc(f3qty:'3')) +
510aAc                                      ' of ' +
510aAc                                      %trim(%editc(w1qty:'Z')) +
510aAc                                      ' entered'
510aA ***                eval      errmsg    = 'WARN - # entered < total.'
510aAc                   exsr      zm0105
510aAc                   eval      f3ovr = *on
510aAc                   goto      endsc1
510aAc                   endif
     *
     C                   move      'EOJ'         nxtscr
     C                   eval      $perror = *on
     C                   goto      endsc1
     *
     C                   endif
     *
     *  Test for F5 - Refresh

     C                   if        *inke
     C                   move      *on           refrsh
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous

     C                   if        *inkl
     *
510aA*  Check if they've entered all the weights
     *
510aAc                   eval      f3qty = w1cnt - 1
510aAc                   if        f3ovr = *off and
510aAc                             f3qty < w1qty
CBI A*
CBI Ac                             or client = Cheney
CBI Ac                             and f3ovr = *on
CBI Ac                             and f3qty < w1qty
CBI Ac                             and %trim(w1cw) <> 'EXIT'
CBI A*
510aAc                   move      *on           error
510aAc                   eval      *in21 = *on
510aAc                   eval      *in01 = *on
510aAc                   eval      errmsg = %trim('WARN') + ' ' +
700eMc                                      %trim(%editc(f3qty:'3')) +
510aAc                                      ' of ' +
510aAc                                      %trim(%editc(w1qty:'Z')) +
510aAc                                      ' entered'
510aA ***                eval      errmsg    = 'WARN - # entered < total.'
510aAc                   exsr      zm0105
510aAc                   eval      f3ovr = *on
510aAc                   goto      endsc1
510aAc                   endif
     *
     C                   move      'EOJ'         nxtscr
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.

     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
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
     *  Get client ID
     *
     C                   call      @getcl
     C                   parm                    client
700cAC                   parm                    clientloc
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
650aA /free
650aA    getUser(#user: e$whse: e$emp#: e$fnam: e$init: e$lnam:
650aA            e$whdp: e$styp: e$shft: e$crew: e$nhrs: e$rtn:
650aA            e$bpu: e$lng);
650aA /end-free
700aA*
700aA*   Get Item Maintenance options.
700aA*
700aA /free
700aA    wkwhse = $pwhse;
700aA    getimuom(wkwhse: IMkilolbs: IMUom);
700aA    select;
700aA      when IMkilolbs = 'K';
700aA        KiloLbs = 'K';
700aA        W1KgLb  = IMUom;
700aA      other;
700aA        kiloLbs = 'P';
700aA        W1KgLb  = 'Lbs';
700aA    endsl;
700aA /end-free
     C                   endsr
650aA*----------------------------------------------------------------
650aA*  clrCWLog     Clear $cwlog   data structure fields
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr ClrCWLog;

650aA     savever# = $cwver#;
650aA     clear $cwlog;
650aA     $cwver# = savever#;
650aA     $cwaddemp = e$emp#;
650aA     $cwaddusr = #user;
650aA     $cwaddpgm  = #prog;
650aA     $cwaddjob  = #job;
650aA     $cwaddnbr = #jobn;

650aA   endsr;
650aA /end-free

650aA*----------------------------------------------------------------
650aA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650aA*----------------------------------------------------------------

650aA /free
650aA   begsr processCWlog;
650aA     exsr clrCWLog;
650aA     $cwwhse = ocwhse;
650aA     $cwitem = ocitem;
650aA     $cwseltrn# = octran;
650aA     $cwsellbl# = oclbl#;
650aA     $cwselord  = ocord;
650aA     $cwselseq  = ocseq#;
650aA     $cwselcseq = ocseq;
650aA     $cwwgtlbs = occwgt;
650aA     $cwscan   = w1cw;
650aA     $cwentflg = 3;

650aA     cwdata = $cwlog;
650aA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650aA   endsr;
650aA /end-free
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
     C                   eval      msgk = *zeros
     C                   select
     C                   when      #lline = '16'
     C                   write     m16clr
     C                   other
     C                   write     msgclr
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16ctl
     C                   other
     C                   write     msgctl
     C                   endsl
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
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *---------------------------------------------------------------------
     *    ZSCLR   Clear screen
     *---------------------------------------------------------------------

     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   select
     C                   when      #lline = '16'
     C                   write     m16rec
     C                   other
     C                   write     msgrec
     C                   endsl
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001/2  Error returned from DRICOP.
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCHK1   Screen 1 error checking.
     *----------------------------------------------------------------

     C     zzchk1        begsr
     C                   eval      error = *off

740aAc                   if        w1cw <> ' '
740aAc                   eval      f13warn = *Off
740aAc                   endif
     *  Catchweight cannot be blank

     C                   if        w1cw = ' '
740aAc                             and f13warn <> *on
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = 'Catchweight cannot be blank'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Convert catchweight entry to a number.

     C                   call      'CVTBAR'
     C                   parm      '*CWGTLBS'    $cbcmd
     C                   parm      w1cw          $cbbar
     C                   parm                    $cbcod
     C                   parm                    $cbdec
     C                   parm                    $cbdsc
     C                   parm                    $cbpos
     C                   parm                    $cbtyp
     C                   parm                    $cbv1
     C                   parm                    $cbv2
     C                   parm                    $cbrtn
     C                   parm                    $cberm
700aAC                   parm      0             $cbven           10 0
700aAC                   parm                    $cvtdata        256
700aAC                   parm                    $cvtdata2       256
700aAC                   parm      $pwhse        $cbwhse           3 0
700aAC                   parm      kilolbs       $cbsent           1

     C                   if        $cbrtn <> '*OK'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = $cberm
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif

     *  Catchweight variance check

     C                   if        ovrrid = *off
500aDC**                 if        $cbv1 > $phcwgt or $cbv1 < $plcwgt
500aMC                   if        ($cbv1 > $phcwgt or $cbv1 < $plcwgt)
500aAC                             and $phcwgt <> *Zeros
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg    = 'Catchweight variance error '
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Save entry to data structure.

740aAc                   if        f13warn = *off
     C     w1cnt         occur     #cwentries
     C                   eval      #cwentry  = w1cw
     C                   eval      #cwweight = $cbv1
740aAc                   endif

     C     endck1        endsr

     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *----------------------------------------------------------------

     C     zzcmd1        begsr

     *  Command keys to check BEFORE verification and update.

     C                   if        cmdchk = '*BEFORE '

     *  Test for F7 - Previous

     C                   if        *inkg
     C                   move      *on           cmdtkn

     C                   if        w1cnt > 1
     C                   eval      w1cnt  = w1cnt - 1
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endif

     C                   endif
700aA*
700aA*      F19 - kilograms/Pounds toggle
700aA*
700aAC                   if        *inkt
700aAC                   eval      cmdtkn = *on
700aAC                   if        KiloLbs = 'P'
700aAC                   eval      KiloLbs = 'K'
700aAC                   eval      W1KgLb  = 'Kgs'
700aAC                   else
700aAC                   eval      KiloLbs = 'P'
700aAC                   eval      W1KgLb  = 'Lbs'
700aAC                   endif
700aAc                   exsr      zzsetcmdln1
700aAC                   goto      endcm1
700aAC                   endif

     *  F20 - Accept Warning.

     C                   if        *inkj
     C                   eval      ovrrid = *on
510aAC                   eval      f3ovr = *on
740aAc                   if        f13warn  = *On
740aAc                   if        w1cnt > 1
740aAc                   eval      w1cnt  = w1cnt - 1
740aAc                   endif
740aAc                   endif
     C                   endif

     *  Test for F13 - No More

     C                   if        *inkm
700bA*
700bA*  Check if they've entered all the weights
700bAc                   eval      f3qty = w1cnt - 1
700bAc                   if        f3ovr = *off and
700bAc                             f3qty < w1qty
CBI A*
CBI Ac                             or client = Cheney
CBI Ac                             and f3ovr = *on
CBI Ac                             and f3qty < w1qty
CBI Ac                             and %trim(w1cw) <> 'EXIT'
CBI A*
700bAc                   move      *on           error
700bAc                   eval      *in21 = *on
700bAc                   eval      *in01 = *on
700bAc                   eval      errmsg = %trim('WARN') + ' ' +
700bAc                                      %trim(%editc(f3qty:'3')) +
700bAc                                      ' of ' +
700bAc                                      %trim(%editc(w1qty:'Z')) +
700bAc                                      ' entered'
700bAc                   exsr      zm0105
700bAc                   eval      f3ovr = *on
740aAc                   eval      f13warn = *on
700bAC                   eval      cmdtkn = '1'
700bAC                   eval      error  = '1'
700bA*
700bAc                   else
700bA*
700bA*      Otherwise, okay to exit.
     C                   move      *on           cmdtkn
     C                   move      *on           *inkc
530aAC                   eval      nxtscr = 'EOJ'
700bAC                   endif
700bA*
     C                   endif

     C                   endif

     *  Command keys to check AFTER verification and update.

     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr

     *----------------------------------------------------------------
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *----------------------------------------------------------------

     C     zzfil1        begsr

     C     w1cnt         occur     #cwentries
     C                   eval      w1cw = #cwentry

     C                   if        w1cnt = 1
     C                   eval      w1last = *zeros
     C                   else
     C                   eval      #cwprev = w1cnt - 1
     C     #cwprev       occur     #cwentries
     C                   eval      w1last = #cwweight
     C                   endif

700aAc                   exsr      zzsetcmdln1
     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *----------------------------------------------------------------

     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog

     *  Define partial key for ORDC file

     C     keyoc         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     C                   kfld                    lblbl#

     C                   eval      #pgmq = #prog

     C                   endsr

     *----------------------------------------------------------------
     *  ZZINZ2   Program initialization. Called from main line.
     *----------------------------------------------------------------

     C     zzinz2        begsr
     C                   setoff                                       kckl
     C                   move      *on           refrsh
     C                   exsr      zzlbl#

     * Get screen size being used.

     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd
     C                   parm                    #lline
     C                   parm                    #lcol

     C                   if        #lline = '00' and #lcol = '000'
     C                   eval      #lline  = '16'
     C                   eval      #lcol   = '020'
     C                   endif

     *      Initialize catchweight data structure.

     C                   exsr      zzcwinz

     C                   exsr      scr01i

     C                   endsr

     *----------------------------------------------------------------
     *  ZZLBL#   Get label record.
     *----------------------------------------------------------------

     C     zzlbl#        begsr

     *  Get label record.

     C     $plbl#        chain     label

     *  Get item information.

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $pwhse
     C                   eval      $ititem = lbitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     *  Fill in screen fields.

     C                   eval      woord  = lbord
     C                   eval      woline = lbseq
     C                   eval      woitem = lbitem
510 D***                 eval      wodesc = $itdesc
     C                   eval      woum  = lbucod

     C                   eval      w1qty = $pqyfd

510 A* format item desc
510 AC                   eval      $iitem = $ititem
510 AC                   eval      $idesc = $itpdsc
510 AC                   eval      $ipdsc = $itdesc
510 AC                   eval      $istr  = *blanks
510 AC                   call      @fmtit
510 AC                   parm                    $iitem
510 AC                   parm                    $idesc
510 AC                   parm                    $ipdsc
510 AC                   parm                    $istr
510 AC                   movel     $istr         woitem
     *

     C                   endsr

     *----------------------------------------------------------------
     *  ZZUPD1   Update for screen 1.
     *----------------------------------------------------------------

     C     zzupd1        begsr
     C                   eval      error = *off

     *  Determine what to do next.

     C                   select

     *    Get the next catchweight ...

     C                   when      w1cnt < w1qty and w1cnt < #cwmax
740aAc                             and f13warn = *off
     C                   eval      w1cnt  = w1cnt + 1
     C                   eval      refrsh = *on
     C                   exsr      scr01i

     C                   other

     *      Write catchweights to ORDC file.

     C     keyoc         setgt     ordc
     C     keyoc         readpe    ordc
     C                   if        %eof
     C                   eval      ocseq = 0
     C                   endif

     C                   eval      ocwhse = lbwhse
     C                   eval      ocord  = lbord
     C                   eval      ocseq# = lbseq
     C                   eval      ocitem = lbitem
     C                   eval      octran = lbtrn#
     C                   eval      oclbl# = lblbl#

     C                   do        w1cnt         i
     C     i             occur     #cwentries
     C                   eval      ocseq  = ocseq + 1
     C                   eval      occwgt = #cwweight
     C                   write     ocrec
650aAc                   eval      processstatus = '*ADD'
650aAc                   exsr      processCWLog
     C                   enddo

     *  Update pallet counts.

     *      Display "next step" screen.

     C                   eval      refrsh = *on
     C                   move      'EOJ'         nxtscr

     C                   endsl

     C     endup1        endsr

     *----------------------------------------------------------------
     *  ZZCWINZ   Initialize catchweight data structure
     *----------------------------------------------------------------

     C     zzcwinz       begsr

     C                   do        #cwmax        i
     C     i             occur     #cwentries
     C                   reset                   #cwentries
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      zm0105

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   exsr      zm0001

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   endsl

     C     enddricop     endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  ZZSETCMDLN1  Setup the command keys
700aa*
700aaC     zzsetcmdln1   begsr
700aA /free
700aA   Select;
700aA     when $itcwgt <> 'Y';
700aA         cmdln1 = cmdln(3);
700aA     when kilolbs  = 'K';
700aA         cmdln1 = cmdln(2);
700aA     when kilolbs  = 'P';
700aA         cmdln1 = cmdln(1);
700aA   endsl;
700aA /end-free
700aaC                   endsr
**  CMDLN - Command display line 700a
F7=Prv F10=Accept F13=No More F19=Kgs
F7=Prv F10=Accept F13=No More F19=Lbs
F7=Prv F10=Accept F13=No More
