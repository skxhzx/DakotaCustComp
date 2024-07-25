      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *  Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *  BFC Software, Inc.
     *  245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *  West Chicago, IL  60185
     *  (630) 562-0375
     *----------------------------------------------------------------
     *
     *  LB310   Rack labels - options
     *  28 December 2007
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    06/30/2008  JCJ
     *      - Validate From and to slot.
     *      - Remove Level from print field for slot if upright rack
     *        label.
     *
520 A*    01/15/00  JCJ  520 A
     *      - Revised to produce 1 label spool file instead of several
     *
520aA*    04/13/09  JCJ  520aA
     *      - Added department to read loop or slot range.
     *
520bA*    09/02/09  JCJ  520bA
     *      - Add handstack to slot printed on Horizontal rack label.
     *
520cA*    10/08/09  JCJ  520cA
     *      - Changed to not remove leading zero of location.
     *
520dA*    10/20/09  JCJ  520dA
     *      - Soft coded label set.
     *
520eA*    11/02/09  JCJ  520eA
     *      - Do not print virtual slots.
     *
520fA*    11/04/09  JCJ  520fA
     *      - Print rack level and hand stack on upright rack label.
     *
640a *    03/28/12  GJA  6.40a
     *      - Add check digit ability.
     *
640b *    05/24/12  GJA  6.40b
     *      - Add arrow ability.
     *
640cA*    12/26/12  JCJ  6.40c
     *      - Add HRACK1 processing.
     *
650aA*    12/16/13  JCJ  6.50a
     *      - Added EI to default printer logic.
     *
650bA*    12/01/14  JCJ  6.40c
     *      - Add HRACK processing.
     *
700a *    07/07/15  GJA  7.00a
     *      - Add W1LEGN for legend printing.
     *      - Renamed format to LB31002
700bA*    10/19/15  MLB  7.00b
     *      - Fix: Revised pgm to clear $pchkd1,$pckhd2 and $pchkd3
     *        when check digit not found for pick slot.
     *
740aA*    04/30/20  JCJ  7.40a
     *      - Removed the Arrow option.  Per Hemant
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
CBI A*  Client Custom Revisions: CBI
     *
CBI A*    11/04/09  JCJ  CBI A
     *      - Do not print rack level and hand stack on upright rack
     *        label.
     *
CBIaA*    09/16/15  JCJ  CBIaA
     *      - Add Punta Gorda copy spec.
CBIbA*    03/01/17  JCJ  CBIbA
     *      - Add Pate Dawson copy spec.
CBIcA*    06/15/18  JCJ  CBIcA
     *      - Add Tifton copy spec.
CBIcA*    09/26/18  JCJ  CBIcA
     *      - Enh:  Load all of the slot into variable $pdispb.
CBIdA*    06/15/18  JCJ  CBIdA
     *      - Add Tifton copy spec.
CBIxA*    03/30/20  JCJ  CBIxA
     *      - Add Crazy Fish copy spec.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRaA*    03/17/15  JCJ  FPRa
     *      - Added Food Pro to default printer logic.
     *
     *----------------------------------------------------------------
FSH  *  Client Custom Revisions: Fischer Foods
     *
FSHa *    09/15/16  GJA  FSHa
     *      - Force ZEB02 for device
     *----------------------------------------------------------------
GMM  *  Client Custom Revisions: Fischer Foods
     *
GMMb *    05/07/18  NLK  GMMb
     *      - Check Digit needs to be '5' to use HRACK5
     *        automatically move '5' for them in zzfil1
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (Reverse Display)
     *  90        View mode (Protect input fields)
     *  91        Change mode (Protect key)
     *  97        Always ON (Used for SFLEND Keyword)
     *  98        Error on screen (Sound buzzer)
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640bDF*lb310fm   cf   e             workstn
700aMF*lb31001   cf   e             workstn
740aMF*lb31002   cf   e             workstn
740aMFlb31003   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslot2     if   e           k disk
520dAFlblfmtd   if   e           k disk
     Fslotdgta  if   e           k disk
     Fslotdgt   if   e           k disk
     FReports   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
640bDD*desc            s             60    dim(11) ctdata perrcd(1)
700aDD*desc            s             60    dim(13) ctdata perrcd(1)
700aMD desc            s             60    dim(14) ctdata perrcd(1)

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

740bMD @prtpg          c                   const('BFCPRTLBL')
520dD *** @lblset         c                   const('ZBRCBI')
     D @plfmtu         c                   const('CBIRACK ')
     D @plfmtucbi      c                   const('CBIRACK ')
     D @plfmthcbi      c                   const('CBIRACKH')
640aAD @plfmtr         c                   const('RACKCHK ')
640bAD @plfmth         c                   const('HRACK   ')
640bAD @plfmth0u       c                   const('HRACK0U ')
640bAD @plfmth0d       c                   const('HRACK0D ')
640bAD @plfmth0l       c                   const('HRACK0L ')
640bAD @plfmth0r       c                   const('HRACK0R ')
640bAD @plfmth1        c                   const('HRACK1  ')
640bAD @plfmth1u       c                   const('HRACK1U ')
640bAD @plfmth1d       c                   const('HRACK1D ')
640bAD @plfmth1l       c                   const('HRACK1L ')
640bAD @plfmth1r       c                   const('HRACK1R ')
640bAD @plfmth2        c                   const('HRACK2  ')
640bAD @plfmth2u       c                   const('HRACK2U ')
640bAD @plfmth2d       c                   const('HRACK2D ')
640bAD @plfmth2l       c                   const('HRACK2L ')
640bAD @plfmth2r       c                   const('HRACK2R ')
640bAD @plfmth3        c                   const('HRACK3  ')
640bAD @plfmth3u       c                   const('HRACK3U ')
640bAD @plfmth3d       c                   const('HRACK3D ')
640bAD @plfmth3l       c                   const('HRACK3L ')
640bAD @plfmth3r       c                   const('HRACK3R ')
640bAD @plfmth5        c                   const('HRACK5  ')
640bAD @plfmth5u       c                   const('HRACK5U ')
640bAD @plfmth5d       c                   const('HRACK5D ')
640bAD @plfmth5l       c                   const('HRACK5L ')
640bAD @plfmth5r       c                   const('HRACK5R ')
640bAD @plfmtuxx       c                   const('URACK   ')
640bAD @plfmtu0u       c                   const('URACK0U ')
640bAD @plfmtu0d       c                   const('URACK0D ')
640bAD @plfmtu0l       c                   const('URACK0L ')
640bAD @plfmtu0r       c                   const('URACK0R ')
640bAD @plfmtu1        c                   const('URACK1  ')
640bAD @plfmtu1u       c                   const('URACK1U ')
640bAD @plfmtu1d       c                   const('URACK1D ')
640bAD @plfmtu1l       c                   const('URACK1L ')
640bAD @plfmtu1r       c                   const('URACK1R ')
640bAD @plfmtu2        c                   const('URACK2  ')
640bAD @plfmtu2u       c                   const('URACK2U ')
640bAD @plfmtu2d       c                   const('URACK2D ')
640bAD @plfmtu2l       c                   const('URACK2L ')
640bAD @plfmtu2r       c                   const('URACK2R ')
640bAD @plfmtu3        c                   const('URACK3  ')
640bAD @plfmtu3u       c                   const('URACK3U ')
640bAD @plfmtu3d       c                   const('URACK3D ')
640bAD @plfmtu3l       c                   const('URACK3L ')
640bAD @plfmtu3r       c                   const('URACK3R ')
640bAD @plfmtu5        c                   const('URACK5  ')
640bAD @plfmtu5u       c                   const('URACK5U ')
640bAD @plfmtu5d       c                   const('URACK5D ')
640bAD @plfmtu5l       c                   const('URACK5L ')
640bAD @plfmtu5r       c                   const('URACK5R ')
700aAD @plfmtled       c                   const('HLEGEND ')
740aAD @plfmtled1      c                   const('HLEGEND1')

     *----------------------------------------------------------------
     *  Program parameters
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
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ernam1                 1     20
     D  ernam2                21     40
     D  erval1                41     42P 0
     D  erval2                43     44P 0
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
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
640aAD @getckdgt       c                   const('GETCHKDGT')
     *
CBI   /COPY QCOPYSRC,id#cheneyo
CBI   /COPY QCOPYSRC,id#cheneyr
CBIa  /COPY QCOPYSRC,id#cheneyp
GMMa  /COPY QCOPYSRC,id#gmm
EI a  /COPY QCOPYSRC,id#ei
FPRa  /COPY QCOPYSRC,id#fpr
CBIb  /COPY QCOPYSRC,id#cheney
FSHa  /COPY QCOPYSRC,id#fischer

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
     D msgk            s              4  0
     D $plen           s              3  0
     D wkwhse          s              3  0
     D w1whse          s              3  0
     D e               s              2  0
     D $pstr           s             60
520 AD wkdisp          s             12
520 AD wkdispb         s             12
     D $msgf           s             10
     D #pgmq           s             10
     D wkprtf          s             10
     D @plfmt          s              8
     D #msgid          s              7
     D #msgtp          s              7
520dAD @lblset         s              6
     D wkwhdp          s              5
     D nxtscr          s              3
     D wrkaisl1        s              3
     D cmdtkn          s              1
     D error           s              1
     D forevr          s              1    inz('1')
     D sclear          s              1
     D warn            s              1
     D wkstyp          s              1
     D work1a          s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      $PRTN   *EXIT    - CMD3 was entered
     *              *CANCEL  - CMD12 was entered
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $whse             3
     C                   parm                    $prtn             8
     C                   parm                    $fslot           12
     C                   parm                    $tslot           12
     C                   parm                    $stype            1
     C                   parm                    $side             1
     C                   parm                    $flev             2 0
     C                   parm                    $tlev             2 0
     C                   parm                    $ltype            1
     C                   parm                    $ckdgt            1
     C                   parm                    $arw              1
     C                   parm                    $dev             10
     C                   parm                    $form            10
700aAC                   parm                    $legn             1
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
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
     C                   eval      *inlr = *on
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
     C                   setoff                                       0111
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       3031
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
     *  Get existing record.
     *
     C                   exsr      zzfil1
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
     C                   eval      $prtn = '*EXIT   '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
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
     C                   exsr      zzchk1
     C     error         cabeq     '1'           endsc1
     C                   exsr      zznxt1
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
     * Get client id.
     *
     C                   call      @getcl
     C                   parm                    client           10
     C                   parm                    clientloc        10
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
     C                   eval      sclear = *on
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
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
     *      0105 - Program supplied
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0110 - From / To Level Range
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0113 - From / To Level Range
     *
     C     zm0113        begsr
     C                   eval      #msgid = 'PIR0113'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0149 - Slot type
     *
     C     zm0149        begsr
     C                   eval      #msgid = 'PIR0149'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0150 - Side
     *
     C     zm0150        begsr
     C                   eval      #msgid = 'PIR0150'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0151 - Label type
     *
     C     zm0151        begsr
     C                   eval      #msgid = 'PIR0151'
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
     *    PIR1006  Invalid jobq option for view report option.
     *
     C     zm1006        begsr
     C                   eval      #msgid = 'PIR1006'
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
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = $lerm
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg =  $lerm
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify From slot.
     *
     C                   if        w1fslot = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = desc(1)
     C                   exsr      zm1001
     C                   endif
520 A*
520 AC                   if        w1fslot <> *blanks
520 AC     slotky        chain     slot2
520 AC                   if        not %found(slot2)
520 AC                   eval      error = *on
520 AC                   eval      *in21 = *on
520 AC                   eval      *in01 = *on
520 AC                   eval      errmsg = desc(10)
520 AC                   exsr      zm0105
520 AC                   endif
520 AC                   endif
     *
     *  Verify To slot.
     *
     C                   if        w1tslot = *blanks
     C                   eval      w1tslot = w1fslot
     C*                  eval      error = *on
     C*                  eval      *in22 = *on
     C*                  eval      *in02 = *on
     C*                  eval      errmsg = desc(2)
     C*                  exsr      zm1001
     C                   endif
520 A*
520 AC                   if        w1tslot <> *blanks
520 AC     slotky2       chain     slot2
520 AC                   if        not %found(slot2)
520 AC                   eval      error = *on
520 AC                   eval      *in22 = *on
520 AC                   eval      *in02 = *on
520 AC                   eval      errmsg = desc(11)
520 AC                   exsr      zm0105
520 AC                   endif
520 aC                   endif
     *
     *  Verify slot type.
     *
     C                   if        w1stype <> 'P' and w1stype <> 'O'
     C                                            and w1stype <> 'B'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = desc(3)
     C                   exsr      zm0149
     C                   endif
     *
     *  Verify side.
     *
     C                   if        w1side <> 'O' and w1side <> 'E'
     C                                           and w1side <> 'B'
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm0150
     C                   endif
     *
     *  Verify From level.
     *
     C                   if        w1flev <= *zeros
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = desc(5)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify To level.
     *
     C                   if        w1tlev <= *zeros
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      errmsg = desc(6)
     C                   exsr      zm0110
     C                   endif
     *
     *  Verify From Level is less than To Level
     *
     C                   if        w1flev > w1tlev
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      ernam1 = desc(5)
     C                   eval      ernam2 = desc(6)
     C                   eval      erval1 = w1flev
     C                   eval      erval2 = w1tlev
     C                   exsr      zm0113
     C                   endif
     *
     *  Verify Label type.
     *
     C                   if        w1ltype <> 'H' and w1ltype <> 'U'
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = desc(7)
     C                   exsr      zm0151
     C                   endif
     *
     *  Verify Check Digit
     *
     C                   if        w1ckdgt <> 'N'
     C                             and w1ckdgt <> '1'
     C                             and w1ckdgt <> '2'
     C                             and w1ckdgt <> '3'
     C                             and w1ckdgt <> '5'
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = desc(12)
     C                   exsr      zm0151
     C                   endif
     *
     *  Verify Arrow
     *
     C                   if        w1arw <> ' '
     C                             and w1arw <> 'L'
     C                             and w1arw <> 'U'
     C                             and w1arw <> 'D'
     C                             and w1arw <> 'R'
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      *in13 = *on
     C                   eval      errmsg = desc(13)
     C                   exsr      zm0151
     C                   endif
     *
700aA*  Verify Legend
     *
     C                   if        w1legn <> 'N'
     C                             and w1legn <> 'Y'
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      errmsg = desc(14)
     C                   exsr      zm0151
     C                   endif
     *
     *  Verify default device
     *
     C                   movel     w1dev         work1a
     C                   if        work1a = '*'  and
     C                             w1dev <> '*SYSVAL'  and
     C                             w1dev <> '*JOB'  or
     C                             w1dev = *blanks
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(8)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     *  Verify default form type
     *
     C                   movel     w1form        work1a
     C                   if        work1a = '*'  and
     C                             w1form <> '*STD'  or
     C                             w1form = *blanks
     C                   eval      error = *on
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(9)       errmsg
     C                   exsr      zm1001
     C                   endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
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
     *     Prompt
     *
     C                   select
     *
     *     Warehouse number.
     *
     C                   when      row# = 7  and
     C                             col# >= 21
     C                   eval      *in01 = *on
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
 3X  C                   when      row# = 8
500eAC                             and col#>=21 and col#<=25
     C                   eval      *in04 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1whdp
     C                   call      'WD900'
     C                   parm                    $lparm
 4B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1whdp = $lwhdp
 4E  C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *      Get warehouse for user.
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     C                   eval      wkwhse = w1whse
     *
     C                   eval      w1fslot = *blanks
     C                   eval      w1tslot = *blanks
     C                   eval      w1stype = 'P'
     C                   eval      w1side = 'B'
     C                   eval      w1flev = 1
     C                   eval      w1tlev = 99
     C                   eval      w1ltype = 'H'
     C                   eval      w1dev = *blanks
     C                   eval      w1form = *blanks

GMMbAC                   select
GMMbAC                   when      client = MenuMaker
GMMbAC                   eval      w1ckdgt = '5'
GMMbAC                   other
     C                   eval      w1ckdgt = 'N'
GMMbAC                   endsl

700aAC                   eval      w1legn = 'N'
     *
     *   Initialize printer device/form
     *
     C                   eval      wkprtf = 'RACKLBL   '
     C     Rpkey         Chain     reports
     C                   If        %Found(reports)
     C                   eval      w1dev = rpdev
     C                   eval      w1form = rpform
     C                   else
650aAC                   select
FSHaMC                   when      client = fischr
FSHaAC                   eval      w1dev = 'ZEB02   '
GMMaMC                   when      client = MenuMaker
GMMaAC                   eval      w1dev = 'ZEBRA1  '
650aAC                   when      client = EI
650aAC                   eval      w1dev = 'ZEBRA3  '
FPRaAC                   when      client = foodpro
FPRaAC                   eval      w1dev = 'LABELPRT3'
GMMaMC                   other
     C                   eval      w1dev = '*JOB    '
GMMaMC                   endsl
     C                   eval      w1form = '*STD    '
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define keys
     *
     C     slotky        klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1fslot
     *
     C     slotky2       klist
     C                   kfld                    w1whse
     C                   kfld                    w1whdp
     C                   kfld                    w1tslot
520aA*
520aAC     slotky3       klist
520aAC                   kfld                    w1whse
520aAC                   kfld                    w1whdp
GMMaA*
GMMaA*  Define key for SLOTDGTA file.
GMMaA*
GMMaAC     cdkey         Klist
GMMaAC                   Kfld                    slwhse
GMMaAC                   Kfld                    slwhdp
GMMaAC                   Kfld                    sldisp
     *
     *  Define key for REPORTS file.
     *
     C     Rpkey         Klist
     C                   Kfld                    wkprtf
     *
     C                   eval      $pstr  = 'Rack Label options'
     *
     C                   call      'CENTER'
     C                   parm                    $pstr
     C                   parm      40            $plen
     C                   eval      rptttl = $pstr
     C                   eval      $lprg  = #prog
     *
520dAC     *loval        setll     lblfmtd
520dAC                   dou       %eof(lblfmtd)
520dAC                   read      lblfmtd
520dAC                   if        not %eof(lblfmtd)
520dAC                   if        lfdfmt = @plfmtu
520dAC                             or lfdfmt = @plfmth
640cAC                             or lfdfmt = @plfmth1
640cAC                             or lfdfmt = @plfmthcbi
640cAC                             or lfdfmt = @plfmtucbi
520dAC                   eval      @lblset = lfdset
520dAC                   leave
520dAC                   endif
520dAC                   endif
520dAC                   enddo
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZNXT1   What to do next when screen 1 input is ok.
     *
     C     zznxt1        begsr
     *
530fAC                   eval      $pchkd1 = *blanks
530fAC                   eval      $pchkd2 = *blanks
     *
     C     slotky        setll     slot2
1B   C                   dow       forevr = *on
520aD ***                read      slot2
520aMC     slotky3       reade     slot2
     C                   select
2B   C                   when      %eof(slot2)
     C                   leave
     *
2X   C                   other
     * out of slot range
3B   C                   if        sldisp > w1tslot
     C                   leave
3E   C                   endif
520eA* no virtual slots
520eAC                   if        slrsrv = 'V'
520eAC                   iter
520eAC                   endif
     * slot type
     C                   select
     C                   when      w1stype = 'P'
     C                             and slpick <> 'Y'
     C                   iter
     C                   when      w1stype = 'O'
     C                             and slpick <> 'N'
     C                   iter
     C                   when      w1stype = 'B'
     C                   endsl
     * side
     C                   select
     C                   when      w1side = 'O'
     C                             and slside <> 1
     C                   iter
     C                   when      w1side = 'E'
     C                             and slside <> 0
     C                   iter
     C                   when      w1side = 'B'
     C                   endsl
     * rack level
     C                   select
     C                   when      slrlvl < w1flev
     C                   iter
     C                   when      slrlvl > w1tlev
     C                   iter
     C                   endsl
     * label type
     C                   select
     * horizontal - CBI
     C                   when      w1ltype = 'H'
CBI AC                             and clientloc = cbiriv
CBIx C                             or w1ltype = 'H'
CBIxAC                             and clientloc = cbicfr
CBIa C                             or w1ltype = 'H'
CBI AC                             and clientloc = cbiocl
CBIaAC                             or w1ltype = 'H'
CBIaAC                             and clientloc = cbipntgr
CBIbAC                             or w1ltype = 'H'
CBIbAC                             and clientloc = cbigr
CBIbAC                             or w1ltype = 'H'
CBIbAC                             and clientloc = cbigo
CBIbAC                             or w1ltype = 'H'
CBIbAC                             and clientloc = cbist
CBIcAC                             or w1ltype = 'H'
CBIcAC                             and clientloc = cbitif
CBIdAC                             or w1ltype = 'H'
CBIdAC                             and clientloc = cbigwb
     C                   eval      @plfmt = @plfmthcbi
520 A ***                eval      wkdispb = %trim(slaisl) + %char(slloc)
640aM ***                eval      wkdispb = %trim(slaisl) + %editc(slloc:'X')
520 A ***                                                  + %char(slrlvl)
520bA ***                                                  + %trim(slhand)
700aMC                   eval      wkdispb = %trim(sldisp)
     C                   eval      wkdisp  = %trim(sldisp)
     C                   eval      $pdispa = %subst(wkdisp:1:1)
     C                   eval      $pdispb = %subst(wkdisp:2:11)
     * upright - cbi
     C                   when      w1ltype = 'U'
CBI AC                             and clientloc = cbiriv
CBI AC                             or w1ltype = 'U'
CBI AC                             and clientloc = cbiocl
CBIaAC                             or w1ltype = 'U'
CBIaAC                             and clientloc = cbipntgr
CBIbAC                             or w1ltype = 'U'
CBIbAC                             and clientloc = cbigr
CBIbAC                             or w1ltype = 'U'
CBIbAC                             and clientloc = cbigo
CBIbAC                             or w1ltype = 'U'
CBIbAC                             and clientloc = cbist
CBIcAC                             or w1ltype = 'U'
CBIcAC                             and clientloc = cbitif
CBIdAC                             or w1ltype = 'H'
CBIdAC                             and clientloc = cbigwb
     C                   eval      @plfmt = @plfmtucbi
     * slot barcode
520cD ****               eval      wkdispb = %trim(slaisl) + %char(slloc)
520cMC                   eval      wkdispb = %trim(slaisl) + %editc(slloc:'X')
     * readable
520 AC                   eval      wkdisp  = %trim(slaisl) + '-'
520cD ***                                                  + %char(slloc)
520cMC                                                     + %editc(slloc:'X')
     C                   eval      $pdispa = %subst(wkdisp:1:1)
CBIcD *                  eval      $pdispb = %subst(wkdisp:2:11)
CBIcMC                   eval      $pdispb = %subst(wkdisp:1:11)
640bA* Upright label, no check digit, no arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmtu
640bA* Upright label, no check digit, up arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmtu0u
640bA* Upright label, no check digit, left arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmtu0l
640bA* Upright label, no check digit, right arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmtu0r
640bA* Upright label, no check digit, down arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmtu0d
640bA* Upright label, one check digit, no arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmtu1
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, one check digit, up arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmtu1u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, one check digit, left arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmtu1l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, one check digit, right arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmtu1r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, one check digit, down arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmtu1d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, two check digit, no arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmtu2
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, two check digit, up arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmtu2u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, two check digit, left arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmtu2l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, two check digit, right arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmtu2r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, two check digit, down arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmtu2d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, three check digit, no arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmtu3
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, three check digit, up arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmtu3u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, three check digit, left arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmtu3l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, three check digit, right arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmtu3r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, three check digit, down arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmtu3d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, five check digit, no arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmtu5
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, five check digit, up arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmtu5u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, five check digit, left arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmtu5l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, five check digit, right arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmtu5r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Upright label, five check digit, down arrow
640bAC                   when      w1ltype = 'U' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmtu5d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
700aA* Horizontal label, no check digit, no arrow, legend
700aAC                   when      w1ltype = 'H'
700aAC                             and w1ckdgt = 'N'
700aAC                             and w1arw   = ' '
700aAC                             and w1legn  = 'Y'
700aAC                   eval      wkdispb = sldisp
700aAC                   eval      @plfmt = @plfmtled
650bA* Horizontal label, no check digit, no arrow
650bAC                   when      w1ltype = 'H' and
650bAC                             w1ckdgt = 'N' and
650bAC                             w1arw   = ' '
650bAC                   eval      wkdispb = sldisp
650bAC                   eval      @plfmt = @plfmth
640bA* Horizontal label, no check digit, up arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmth0u
640bA* Horizontal label, no check digit, left arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmth0l
640bA* Horizontal label, no check digit, right arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmth0r
640bA* Horizontal label, no check digit, down arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = 'N' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmth0d
640bA* Horizontal label, one check digit, no arrow, no legend
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = ' ' and
740aAC                             w1legn  = 'N'
640bAC                   eval      @plfmt = @plfmth1
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, one check digit, no arrow, legend
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = ' ' and
740aAC                             w1legn  = 'Y'
640bAC                   eval      @plfmt = @plfmtled1
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, one check digit, up arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmth1u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, one check digit, left arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmth1l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, one check digit, right arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmth1r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, one check digit, down arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '1' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmth1d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, two check digit, no arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmth2
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, two check digit, up arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmth2u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, two check digit, left arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmth2l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, two check digit, right arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmth2r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, two check digit, down arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '2' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmth2d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, three check digit, no arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmth3
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, three check digit, up arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmth3u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, three check digit, left arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmth3l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, three check digit, right arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmth3r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, three check digit, down arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '3' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmth3d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, five check digit, no arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = ' '
640bAC                   eval      @plfmt = @plfmth5
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, five check digit, up arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'U'
640bAC                   eval      @plfmt = @plfmth5u
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, five check digit, left arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'L'
640bAC                   eval      @plfmt = @plfmth5l
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, five check digit, right arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'R'
640bAC                   eval      @plfmt = @plfmth5r
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
640bA* Horizontal label, five check digit, down arrow
640bAC                   when      w1ltype = 'H' and
640bAC                             w1ckdgt = '5' and
640bAC                             w1arw   = 'D'
640bAC                   eval      @plfmt = @plfmth5d
640bAC                   eval      wkdisp  = %trim(sldisp)
640bAC                   eval      wkdispb = %trim(sldisp)
530 A* horizontal - everybody else
530 AC                   when      w1ltype = 'H'
530 AC                   eval      @plfmt = @plfmth
530 AC                   eval      wkdispb = %trim(sldisp)
530 AC                   eval      wkdisp  = %trim(sldisp)
530 AC                   eval      $pdispa = %subst(wkdisp:1:1)
530 AC                   eval      $pdispb = %subst(wkdisp:2:11)
530fA* upright - everybody else
530fAC                   when      w1ltype = 'U'
530fAC                   eval      @plfmt = @plfmtu
530fA* slot barcode
530fAC                   eval      wkdispb = %trim(sldisp)
530fA* readable
530fAC                   eval      wkdisp  = %trim(sldisp)
530fAC                   eval      $pdispa = %subst(wkdisp:1:1)
CBIcD *                  eval      $pdispb = %subst(wkdisp:2:11)
CBIcMC                   eval      $pdispb = %subst(wkdisp:1:11)
530fAC                   eval      $pchkd1 = %char(slloc)
530fAC                   eval      $pchkd2 = %char(slrlvl)
     C                   endsl
     *
520 AC                   eval      $pcmd = '*RACK   '
     *
640aAC                   if        slpick = 'Y'
GMMaAC     cdkey         chain     slotdgt
GMMaAC                   if        %found(slotdgt)
640aAC                   eval      $pchkd1 = %editc(scddgt:'X')
     *
GMMaAC     cdkey         chain     slotdgta
GMMaAC                   if        %found(slotdgta)
GMMaAC                   eval      $pchkd2 = %editc(scddgt2:'X')
GMMaAC                   eval      $pchkd3 = %editc(scddgt3:'X')
GMMaAC                   else
GMMaAC                   eval      $pchkd2 = *blanks
GMMaAC                   eval      $pchkd3 = *blanks
GMMaAC                   endif
700bA*
700bAC                   else
700bAC                   eval      $pchkd1 = *blanks
700bAC                   eval      $pchkd2 = *blanks
700bAC                   eval      $pchkd3 = *blanks
GMMaAC                   endif
700bA*
640aAC                   else
640aAC                   eval      $pchkd1 = *blanks
640aAC                   eval      $pchkd2 = *blanks
640aAC                   eval      $pchkd3 = *blanks
640aAC                   endif
     *
     C                   call      @prtpg
     C                   parm                    $pcmd             8
     C                   parm      @lblset       $plset            6
     C                   parm      @plfmt        $plfmt            8
     C                   parm      w1whse        $pwhse            3 0
     C                   parm      *blanks       $pwhsd           30
     C                   parm      w1whdp        $pwhdp            5
     C                   parm      wkdispb       $pdisp           12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
530 MC                   parm                    $pchkd1           3
530 MC                   parm                    $pchkd2           3
640aDC*****              parm      *blanks       $pchkd3           3
640aMC                   parm                    $pchkd3           3
     C                   parm      *blanks       $plcn#           15
     C                   parm      *blanks       $plcn2           15
     C                   parm      *blanks       $pitm#           15
     C                   parm      *blanks       $brand           10
     C                   parm      *blanks       $ppdsc           15
     C                   parm      *blanks       $pdesc           30
     C                   parm      *blanks       $ptxt1           30
     C                   parm      *blanks       $ptxt2           30
     C                   parm      *blanks       $ptxt3           30
     C                   parm      *blanks       $ptrail           8
     C                   parm      *blanks       $psize            3
     C                   parm      w1dev         $pdev            10
     C                   parm      w1form        $pform           10
     *
2E   C                   endsl
     *
1E   C                   enddo
     *
520 AC                   call      @prtpg
520 AC                   parm      '*RACKEND'    $pcmd             8
520 AC                   parm      @lblset       $plset            6
520 AC                   parm      @plfmt        $plfmt            8
520 AC                   parm      w1whse        $pwhse            3 0
520 AC                   parm      *blanks       $pwhsd           30
520 AC                   parm      *blanks       $pwhdp            5
520 AC                   parm      *blanks       $pdisp           12
520 AC                   parm      *blanks       $pdispa           1
520 AC                   parm      *blanks       $pdispb          11
520 AC                   parm      *blanks       $pchkd1           3
520 AC                   parm      *blanks       $pchkd2           3
520 AC                   parm      *blanks       $pchkd3           3
520 AC                   parm      *blanks       $plcn#           15
520 AC                   parm      *blanks       $plcn2           15
520 AC                   parm      *blanks       $pitm#           15
520 AC                   parm      *blanks       $brand           10
520 AC                   parm      *blanks       $ppdsc           15
520 AC                   parm      *blanks       $pdesc           30
520 AC                   parm      *blanks       $ptxt1           30
520 AC                   parm      *blanks       $ptxt2           30
520 AC                   parm      *blanks       $ptxt3           30
520 AC                   parm      *blanks       $ptrail           8
520 AC                   parm      *blanks       $psize            3
520 AC                   parm      w1dev         $pdev            10
520 AC                   parm      w1form        $pform           10
     C                   eval      nxtscr = 'EOJ'
     C                   endsr
     *
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
From Slot
To Slot
Slot type
Side
From level
To level
Label type
Printer device
Form type
Invalid from Slot
Invalid to Slot
Check Digit
Arrow
Legend
