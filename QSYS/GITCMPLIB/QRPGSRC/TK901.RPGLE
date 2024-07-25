      /copy qcopysrc,hspecs
750fAH dftactgrp(*NO) actgrp(*CALLER)
750fMH bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  TK901     Task code lookup/verify by cat
     *  19 December, 2013
     *  Lynn McMahon
     *
     *  Copied from TK900
     *
     *  Revisions
650aA* 12/19/13  LMC  6.50a
     *   - Created.
     *
700aA* 11/30/16  MR   7.00a
     *   - Convert to ILE.
     *   - Change display for cursor to position on
     *     Postion To field.
     *   - Change functionality for indirect tasks for SpeakEasy.
     *
720aA* 07/24/18  LMC  7.20a
     *   - Only display indirect MISC category task
     *   - Change to display file - move pos to field for easier use
     *     with the RF devices.
750fA*    04/18/21  DAS  7.50f
     *     - Enh:  Revised to work with SelectPrime (WT6000)
     *     - Used 750f because that is what was used in OR400
     *     - Added optional pJsonStr parameter
     *     - Changed screen format to be usropn
     *     - Sending in commands *SPLIST and *SPENTRY
750gA*    07/02/21 LMC   7.50g
     *     - Enh:  base the file open on electPrime (WT6000)
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  20        POSITION CURSOR
     *  21 - 29   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  79        CHAIN INDICATOR
     *  90        PROTECT INPUT FIELDS FOR DELETE DISPLAY
     *  91        PROTECT "POSITION TO" FIELD #1
     *  92        PROTECT "POSITION TO" FIELD #2
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *

750fA*----------------------------------------------------------------
750fA*  Binding Directories
750fA*----------------------------------------------------------------
750fA
750fDH*bnddir('QC2LE':'QUSAPIBD':'BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
700aD*TK901FM CF  E                    WORKSTN
720aDF*tk90101   cf   e             workstn
750fAF*****
750fAF***** If format name changes, change it in *INZSR ***
750fAF*****
720aMFtk90102   cf   e             workstn
750fAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(dspsfl:recno)
     F                                     sfile(msgrec:msgk)
     Fworkopt   uf a e           k disk
700aAFtask      if   e           k disk
720aDF*task1     if   e           k disk
720aAFtask3     if   e           k disk
     F                                     rename(tkrec:record)
750fAFbfcsktlog o    e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D optlst          s              2    dim(24)
     D cmdlst          s              2    dim(24)
     D desc            s             20    dim(1) ctdata perrcd(1)


750fA*----------------------------------------------------------------
750fA*  YAJL Header
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,yajl_h
750fAd yajlerr         s            500    varying
750fAd docNode         s                   like(yajl_val)
750fAd node            s                   like(yajl_val)
750fAd yajlRtnStatus   s             10i 0
750fAd yajlLen         s             10i 0

750fAd stdNode         s                   like(yajl_val)
750fAd stdPointer      s               *   inz(%addr(stdBuffer))
750fAd stdBuffer       s           2048
750fAd stdLen          s             10i 0

750fAd inputNode       s                   like(yajl_val)
750fAd inputPointer    s               *   inz(%addr(inputBuffer))
750fAd inputBuffer     s           1024
750fAd inputLen        s             10i 0

750fAd bufArray        s           3072
750fAd bufArrayPtr     s               *   inz(%addr(bufArray))
750fAd bufArrayLen     s             10i 0

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
     D  $lcat                 19     24
720aMD  $lttyp                25     25
720aMD  $lcode                26     31
720aMD  $lsub                 32     37
     *----------------------------------------------------------------
     *  Data structure for FKEY and UKEY
     *
     D                 ds
     D  dskey                  1     50
     D  tkcat                  1      6
     D  tktype                 7      7
     D  tkcode                 8     13
     *----------------------------------------------------------------
     *  Data structure for PgUp/Dn routines
     *
     D $postn          ds
     D  $pocmd                 1      8
     D  $poprg                 9     18
     D  $pofky                19     68
     D  $pouky                69    118
     D  $podsc               119    307
     D                                     DIM(3)
     D  $popt1               308    322
     D  $popt2               323    335
     D  $portn               336    343
     D  $poerm               344    403
     D  $pomsg               336    339
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  errcl1                 1     10
     D  errcl2                11     16
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
750fAD #msgtext        s            100
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
     *  Program info data structure
     *
750fA /Copy qcopysrc,c#pgminfds
     D*               sds
     D* #prog            *proc
     D* #job                 244    253
     D* #user                254    263
     D* #jobn                264    269
     D* #jobdt               276    281  0
     D* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $wkof           s                   like(wkokyf)
     D $wkou           s                   like(wkokyu)
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D bot             s              1
     D cancel          s              1
     D clear           s              5  0
     D comand          s              5  0
     D dsplyd          s              2  0
     D e               s              2  0
     D enter           s              5  0
750fDD*error           s              1
750fMD error           s               n
     D forceb          s              1
     D goback          s              2  0
     D help            s              5  0
     D msgk            s              4  0
     D nomore          s              1
     D nxtscr          s              3
     D otaken          s              1
     D p               s              2  0
     D pagcmd          s              8
     D recno           s              4  0
     D repos           s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D stop            s              1
     D top             s              1
     D warn            s              1
     D x               s              3  0
     D y               s              3  0
750fAD pCmd            s             10
750fAD usingScreen     s               n
750fAD displayScreen   s               n
750fAD prime           s               n
750fAD exfmtScreen     s               n
750fAD jType           s              1
750fAD alphaSLEXPD     s              8
750fAD alphaSLENTD     s              8

750fAd  spApp          s             20
750fAd  spUser         s             10
750fAd  spWhereFrom    s             20
750fAd  spUid          s             32
750fAd  spWhouse       s              3
750fAd  spF1F24Flags   s             24
750fAd  spBtnFlags     s             10
750fAD  spBtnClick     s             10
750fAd  errmsg500      s            500    varying
750fAd  jsonStr        s           4096    varying
750fAd  pJsonStr       s           4096    varying

750fA*----------------------------------------------------------------
750fA*  Time variables
750fA*----------------------------------------------------------------
750fA
750fAD CurrStamploc    s               z
750fAD CurrStampsys    s               z
750fAD CurrStampuc     s               z
750fAD FromStamp       s               z
750fAD ToStamp         s               z
750fAD oldeststamp     s               z
750fAD ts              s               z
750fA
750fAD Duration        s              7  2
750fAD TtlMin          s              5  0
750fAD TtlMinSec       s              9  0
750fAD TtlSec          s              9  0
750fAD RemSec          s              3  0
750fA
750fAD bfcoffset       s              3  0 inz(0)
750fAD ucOffset        s              3  0

750fA*----------------------------------------------------------------
750fA*  Sub-procedure prototypes
750fA*----------------------------------------------------------------

750fAd CreateRtnError  pr

750fAd LoadJson        pr

750fAd $InzFuncKeys    pr

750fAd $InzPgmVar      pr

750fAd $SetNxtScr      pr

750fAd WriteVoiceLog   pr
750fAd  type                               const like(slgtyp)
750fAd  buffer                             const like(slgbuf)

750fAd GetCurrStamp    pr

750fAd UpperToLower    pr         65535A   varying
750fAd  value                     65535A   varying const

750fAd SetPgmField     pr
750fAd  key                          50A   varying const
750fAd  value                              like(yajl_val) const

750fA*----------------------------------------------------------------
750fA*  Called program prototypes
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,p.bfcdteti
750fA
750fAD GetJType        pr                  extpgm('GETJTYPE')
750fAD   jobType                      1

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $LCMD   *SELECT  - Selection lookup.
     *              *VERIFY  - Verify key.
     *      $LPRG   Program to send messages back to.
     *      $LUKY   Contains key to be verified.
     *
     *    Returned Parameters
     *      $LUKY   Contains first key selected.
     *      $LRTN   blank    - No problem encountered.
     *              *OK      - Unique key exists for *VERIFY
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *              -or- Description of verified code.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $lparm
750fAC                   parm                    pJsonStr
     *
     *  Define keys
     *
     *     WORKOPT  (Unique key)
     *
     C     wkounq        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    wkokyf
     C                   kfld                    wkokyu
     *
     *     WORKOPT  (Partial key)
     *
     C     wkoprt        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     *
     *     WORKOPT  (Save key for top record on delete display)
     *
     C     deltop        klist
     C                   kfld                    #user
     C                   kfld                    #prog
     C                   kfld                    $wkof
     C                   kfld                    $wkou
     *----------------------------------------------------------------
     *  Main line
     *
750fA /free
750fA   if prime;
750fA     errmsg = '';
750fA     recno = 1;
750fA     spF1F24Flags = '';
750fA     spBtnFlags = '';
750fA     slgbuf = '<Begin> cmd= ' + $lcmd + ' ' +  pjsonstr;
750fA     WriteVoiceLog('Inf': slgbuf);
750fA
750fA     // See if we should shut down
750fA     // pCmd is initialized in *INZSR
750fA
750fA     if pJsonStr = '*SHUTDOWN';
750fA       *inlr = *on;
750fA       return;
750fA     endif;
750fA
750fA     // Load JSON string and get pointers to sections
750fA
750fA     LoadJson();
750fA     if error;
750fA       return;
750fA     endif;
750fA
750fA     // Get Std field
750fA
750fA     jsonGetFields(stdNode);
750fA
750fA   endif;
750fA /end-free
     C                   eval      *in97 = *on
     C                   eval      $lrtn = *blanks
750fAC                   if        not prime
750fAC                             or $lcmd = '*SPLIST'
     C                   exsr      zzinz2
750fAC                   endif
750fA
750fA /free
750fA
750fA   // For Prime, initialize inputs.
750fA
750fA   if prime;
750fA     $InzPgmVar();
750fA     if error;
750fA       errmsg500 = %trim(errmsg);
750fA       CreateRtnError();
750fA       return;
750fA     endif;
750fA   endif;
750fA
750fA   // Set flag for dspscr
750fA   // For Prime, we only call pgm with *SPLIST because no extra
750fA   // verification is done when code is selected.
750fA
750fA   if not prime;
750fA     displayScreen = *on;
750fA   else;
750fA     if $lcmd = '*SPLIST';
750fA       displayScreen = *on;
750fA     else;
750fA       displayScreen = *off;
750fA     endif;
750fA   endif;
750fA   exfmtScreen = *off;
750fA
750fA /end-free
     C                   if        $lcmd = '*VERIFY '
     C                   exsr      zzvrfy
     C                   eval      nxtscr = 'EOJ'
     C                   else
     C                   exsr      clrsch
     C                   exsr      scr01i
     C                   endif

     C                   dow       nxtscr <> 'EOJ'
750fA
750fAC                   if        displayScreen
     C                   exsr      dspscr
750fAC                   endif
750fA
750fAC                   eval      displayScreen = *on
750fA
750fAC*    For Prime, we want to get out if a screen was displayed.
750fA
750fAC                   if        prime and exfmtScreen
750fAC                   leave
750fAC                   endif

     C     nxtscr        caseq     '01 '         sc1
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr

750fA /free
750fA    if prime;
750fA      if errmsg <> '';
750fA       errmsg500 = %trim(errmsg);
750fA       CreateRtnError();
750fA      endif;
750fA      $SetNxtScr();
750fA    endif;
750fA
750fA     if prime;
750fA       slgbuf = '<End> '
750fA              + 'error=' + error + ' '
750fA              + 'nxtscr=' + %trimr(nxtscr)
750fA              +  %trim(pJsonStr);
750fA       WriteVoiceLog ('Inf': slgbuf);
750fA     endif;
750fA
750fA /end-free

     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
750fAC                   eval      exfmtScreen = *off
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = '1'
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Set OFF command key indicators
     *
     C                   setoff                                       kckekf
     C                   setoff                                       kl
     *
     *   Overlay screen with title
     *
750fAC                   if        usingScreen
     C                   write     title
750fAC                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *   Overlay screen with subfile screen
     *
     C                   if        nxtscr = '01 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exsr      sfldsp
     C                   read      postnrec                               50
750fAC                   endif
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       2021
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
750fAC                   if        usingScreen
     C                   read      dspsfc                                 50
750fAC                   endif
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
     C                   move      *loval        fkey
     C                   move      *loval        ukey
750fAC                   if        usingScreen
     C                   write     clr0306
750fAC                   endif
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     C     status        caseq     rollup        roll01
     C     status        caseq     rolldn        roll01
     C     status        caseq     comand        cmd01
     C                   cas                     ent01
     C                   endcs
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
750fA /free
750fA
750fA   // Open screen if running interactively
750fA
750fA   GetJType (usingScreen);
750gD   //if jType = '1';
750fA   if usingScreen = '1';
750fA     open tk90102;
750fA   endif;
750fA
750fA   // See if called with SelectPrime
750fA
750fA   if not usingScreen and %parms >= 2;
750fA     prime = *on;
750fA     slgbuf = '<*Inzsr> cmd= ' + $lcmd + ' ' +  pjsonstr;
750fA     WriteVoiceLog('Inf': slgbuf);
750fA
750fA   else;
750fA     prime = *off;
750fA   endif;
750fA /end-free

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
     *  Initialize subfile (DSPSFL) record
     *
     C                   eval      recno = 1
750fAC                   if        usingScreen
     C                   write     dspsfl                               79
750fAC                   endif
     *
     *   Make sure option work file is empty.
     *
     C                   exsr      clrsch
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CLRSCH   Clear everything out of work file
     *
     C     clrsch        begsr
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                              7979
     C                   dow       not *in79
     C                   delete    wkorec
     C     wkoprt        reade     workopt                              7979
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  CMD01    Screen 1 command key routine
     *
     C     cmd01         begsr
     *
     *  TEST FOR CMD3 - EXIT
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*EXIT   '
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD12 - PREVIOUS
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $lrtn = '*CANCEL '
     C                   goto      cmd01e
     C                   endif
     *
     *  EXECUTE COMMAND KEYS THAT DON'T NEED THE OPTIONS VERIFIED
     *
     *     TEST FOR CMD5 - REFRESH
     *
     C                   if        *inke
     C                   exsr      clrsch
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   move      '  '          option
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   eval      pagcmd = '*REFRESH'
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  VERIFY AND SAVE ANY OPTIONS THAT WERE ENTERED
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           cmd01e
     *
     *  EXECUTE COMMAND KEYS THAT DID NEED THE OPTIONS VERIFIED
     *
     *  TEST FOR CMD10 - MOVE RECORD THAT CUSOR IS ON TO TOP
     *
     C                   if        *inkj
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     *     MAKE SURE CURSOR IS ON ONE OF THE DISPLAYED RECORDS
     *
     C                   sub       10            row#
     C                   if        row# < 1  or
     C                             row# > dsplyd
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0106
     C                   goto      cmd01e
     C                   endif
     *
     *     REPOSITION RECORD THAT CURSOR IS ON TO THE TOP
     *
     C                   eval      $pocmd = '*POSTN2U'
     C                   eval      $pouky = ukey(row#)
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       CMD01E
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD17 - REPOSITION TO TOP OF DISPLAY
     *
     C                   if        *inkr
     C                   eval      pagcmd = '*TOP    '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     *
     *  TEST FOR CMD18 - REPOSITION TO BOTTOM OF DISPLAY
     *
     C                   if        *inks
     C                   eval      pagcmd = '*BOTTOM '
     C                   exsr      pag01
     C                   goto      cmd01e
     C                   endif
     C     cmd01e        endsr
     *----------------------------------------------------------------
     *
     *  ENT01    Screen 1 enter key routine
     *
     C     ent01         begsr
     *
     *  VERIFY AND SAVE OPTIONS
     *
     C                   exsr      savopt
     C     error         cabeq     '1'           ent01e
     *
     *  SEE IF USER IS TRYING TO POSITION TO A CERTAIN SPOT
     *
     C                   eval      repos = *off
     C                   exsr      zzpos
700aAc                   if        nxtscr = 'EOJ'
700aAC                   goto      ent01e
700aAC                   endif
     C                   if        repos = *on
     C                   eval      $pofky = dskey
     C                   eval      $pocmd = '*POSTN2 '
     C                   exsr      fgtway
     C                   eval      pagcmd = '*REPOS  '
     C                   exsr      pag01
     C                   goto      ent01e
     C                   endif
     *
     *  IF NOT POSITIONING THEN EXECUTE THE ENTERED OPTIONS
     *
     C                   exsr      optns
     *
     *  IF OPTION WAS NOT TAKEN THEN RETURN LIKE CMD12 WAS ENTERED
     *
     C                   if        otaken = '0'
     C                   eval      $lrtn = '*CANCEL '
     C                   else
     C                   eval      $lrtn = '*SELECT '
     C                   endif
     C                   eval      nxtscr = 'EOJ'
     C     ent01e        endsr
     *----------------------------------------------------------------
     *
     *  FGTWAY   Gateway to file handling routines
     *
     *    Input Parameters
     *      $POCMD   *INIT    - Initialize and return
     *               *GET     - Get record for $POUKY value
     *               *GETNEXT - Get next record
     *               *GETPREV - Get previous record
     *               *WRITPOS - Write position record to display
     *               *READPOS - Read position record
     *               *POSTN2  - Position to $POFKY
     *               *POSTN2U - Position to $POUKY
     *               *TOP     - Position to top of file
     *               *BOTTOM  - Position to bottom of file
     *      $POFKY   Key for positioning within file
     *      $POUKY   Unique key used for change/delete operations
     *
     *    Returned Parameters
     *      $PORTN   *NOMORE  - Beginning/End of file was reached
     *               *NOTFND  - Record not found on a GET
     *               *FOUND   - Record found
     *               *REPOS   - Repositioning took place
     *               *ERROR   - Error occured
     *      $POERM   Error message
     *
     C     fgtway        begsr
     C                   eval      $portn = *blanks
     C     $pocmd        caseq     '*GET    '    fget
     C     $pocmd        caseq     '*GETNEXT'    fgetn
     C     $pocmd        caseq     '*GETPREV'    fgetp
     C     $pocmd        caseq     '*POSTN2 '    fpos2
     C     $pocmd        caseq     '*POSTN2U'    fpos2u
     C     $pocmd        caseq     '*TOP'        zzpos2
     C     $pocmd        caseq     '*BOTTOM'     zzpos2
     C                   endcs
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGET     Get record using file with unique key
     *
     *              In this case the lookup file and the unique key
     *              file are the same.
     *
     C     fget          begsr
     C                   eval      dskey = $pouky
     C     fileky        chain     record                             79
     C                   if        *in79
     C                   eval      $portn = '*NOTFND '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETN    Get next record
     *
     C     fgetn         begsr
     C                   exsr      zzfgtn
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FGETP    Get previous record
     *
     C     fgetp         begsr
     C                   exsr      zzfgtp
     C                   if        *in79
     C                   eval      $portn = '*NOMORE '
     C                   eval      $pouky = *blanks
     C                   else
     C                   eval      $portn = '*FOUND  '
     C                   exsr      zzkeyf
     C                   exsr      zzkeyu
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2    Position to record
     *
     C     fpos2         begsr
     C                   eval      dskey = $pofky
     C     fileky        setll     record
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FPOS2U   Position to record using unique key
     *
     C     fpos2u        begsr
     *
     *  GET RECORD FOR UNIQUE KEY
     *
     C                   exsr      fget
     *
     *  POSITION TO RECORD IN LOOKUP FILE
     *
     C                   exsr      fpos2
     C                   endsr
     *----------------------------------------------------------------
     *
     *  OPTNS    Perform options that user entered
     *
     C     optns         begsr
     *
     *  Move first selected value to $LUKY  parameter and set
     *     the option taken flag.
     *
     C                   eval      otaken = *off
     C     wkoprt        setll     workopt
     C     wkoprt        reade     workopt                                79
     C                   if        not *in79
     C                   eval      otaken = *on
     C                   eval      $luky = wkokyu
     C                   endif
     C     optnse        endsr
     *----------------------------------------------------------------
     *
     *  PAG01    Screen 1 page routines
     *
     C     pag01         begsr
750fA /free
750fA   // For Prime, we will be creating a JSON array
750fA   // Therefore, we start the array here and end
750fA   // it at the end of the this subroutine.
750fA
750fA      yajl_genOpen(*off);
750fA      yajl_beginObj();
750fA        yajl_beginArray('list');
750fA /end-free
     *
     *  NEXT PAGE
     *
     C                   if        pagcmd = '*NEXT   '
     C                   exsr      pag1fw
     C                   else
     *
     *  PREVIOUS PAGE
     *
     C                   if        pagcmd = '*PREV   '
     C                   exsr      pag1bk
     C                   else
     *
     *  TOP
     *
     C                   if        pagcmd = '*TOP    '
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  BOTTOM
     *
     C                   if        pagcmd = '*BOTTOM '
     C                   eval      bot = *on
     C                   eval      dsplyd = 0
     C                   exsr      pag1bk
     C                   else
     *
     *  REFRESH SCREEN
     *
     C                   if        pagcmd = '*REFRESH'
     C                   if        fkey(1) = *loval
     C                   eval      $pocmd = '*TOP    '
     C                   else
     C                   eval      $pocmd = '*POSTN2 '
     C                   eval      $pofky = fkey(1)
     C                   endif
     C                   exsr      fgtway
     *R         CLERR     CABEQ'1'       PAG01E
     C                   eval      bot = *off
     C                   exsr      pag1fw
     C                   else
     *
     *  REPOSITIONING
     *
     C                   if        pagcmd = '*REPOS  '
     C                   eval      bot = *off
     C                   eval      forceb = *off
     C                   exsr      pag1fw
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     C                   eval      pagcmd = *blanks
750fA /free
750fA   // For Prime, wrap up the JSON array.
750fA
750fA        yajl_endArray();
750fA      yajl_endObj();
750fA
750fA   // The array will look like the following:
750fA   //    {"list":[{"key":"val", "key":"val"},{"key":"val", "key":"val"},... ]}
750fA   // However, $SetNxtScr only needs the following:
750fA   //    [{"key":"val", "key":"val"},{"key":"val", "key":"val"},... ]
750fA   // Therefore, we remove the excess characters
750fA
750fA      yajlLen = YAJL_copyBuf(0: bufArrayPtr: %len(bufArray): bufArrayLen);
750fA      bufArray = %subst(bufArray: 9: bufArrayLen-9);
750fA      bufArrayLen = %len(%trim(bufArray));
750fA
750fA   // Do some YAJL cleanup
750fA
750fA      yajl_genClose();
750fA /end-free
     C     pag01e        endsr
     *----------------------------------------------------------------
     *
     *  PAG1FW   Let's see that next page of records
     *
     C     pag1fw        begsr
     *
     *  IF WE ARE AT THE BOTTOM THEN DO NOTHING
     *
     C     bot           cabeq     '1'           endf
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   exsr      sflclr
     C                   move      *loval        fkey
     C                   move      *loval        ukey
     C                   eval      bot = *off
     C                   eval      top = *off
     C                   eval      stop = *off
     C                   eval      p = 0
     *
     *  GET 10 RECORDS TO DISPLAY
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETNEXT'
     C                   exsr      fgtway
     *
     *  OUT OF RECORDS - INFORM USER AND SET FLAG
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   goto      endfac
     C                   endif
     *
     *  RECORD READ - STOP AFTER 10 GOOD RECORDS
     *
     C                   add       1             p
     C                   exsr      sfladd
     C                   if        p >= 10
750fAC                             and not prime
     C                   eval      stop = *on
     C                   if        forceb = '1'
     C                   eval      bot = *on
     C                   eval      moreln = 'Bottom '
     C                   else
     C                   eval      moreln = 'More...'
     C                   endif
     C                   endif
     C     endfac        tag
     C                   enddo
     *
     *  SAVE NUMBER OF RECORDS THAT HAVE BEEN DISPLAYED
     *
     C                   eval      dsplyd = p
     C                   eval      forceb = *off
     C     endf          endsr
     *----------------------------------------------------------------
     *
     *  PAG1BK   Let's see the previous page
     *
     C     pag1bk        begsr
     *
     *  IF WE ARE AT THE TOP THEN DO NOTHING
     *
     C     top           cabeq     '1'           endb
     C                   eval      forceb = *off
     *
     *  CALCULATE HOW MANY RECORDS TO GO BACKWARDS
     *
     C     dsplyd        add       10            goback
     C                   if        bot = '1'
     C                   if        goback = 10
     C                   eval      forceb = *on
     C                   endif
     C                   eval      $pocmd = '*BOTTOM '
     C                   exsr      fgtway
     C                   add       1             goback
     C                   endif
     *
     *  INITIALIZE VARIABLES FOR LOOKUP
     *
     C                   eval      p = 0
     C                   eval      top = *off
     C                   eval      bot = *off
     C                   eval      stop = *off
     *
     *  READ SPECIFIED FLITCHES FILE
     *
     C                   dou       stop = '1'
     C                   eval      $pocmd = '*GETPREV'
     C                   exsr      fgtway
     *
     *  HIT TOP OF FILE
     *
     C                   if        $portn = '*NOMORE '
     C                   eval      stop = *on
     C                   eval      top = *on
     C                   goto      endbk
     C                   endif
     *
     *  RECORD READ - STOP AFTER READING 'GOBACK' NUMBER OF GOOD RECS
     *
     C                   add       1             p
     C                   if        p >= goback
     C                   eval      stop = *on
     C                   endif
     C     endbk         tag
     C                   enddo
     *
     * IF THE TOP WAS REACHED THEN POSITION POINTER TO TOP OF FILE
     *
     C                   if        top = '1'
     C                   eval      $pocmd = '*TOP    '
     C                   exsr      fgtway
     C                   endif
     C                   exsr      pag1fw
     C     endb          endsr
     *----------------------------------------------------------------
     *
     *  ROLL01   Screen 1 roll up/down routine
     *
     C     roll01        begsr
     *
     *  TEST FOR ROLLUP
     *
     C                   if        status = rollup
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*NEXT   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     *
     *  TEST FOR ROLLDOWN
     *
     C                   if        status = rolldn
     C                   exsr      savopt
     C     error         cabeq     '1'           rol01e
     C                   eval      pagcmd = '*PREV   '
     C                   exsr      pag01
     C                   goto      rol01e
     C                   endif
     C     rol01e        endsr
     *----------------------------------------------------------------
     *
     *  SAVOPT   Verify and save options that were entered
     *
     C     savopt        begsr
     *
     *  Read only the changed options.
     *
     C                   eval      nomore = *off
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
     C                   dou       nomore = '1'
     C                   eval      *in21 = *off
     C                   readc     dspsfl                                 79
     C                   if        *in79
     C                   eval      nomore = *on
     C                   goto      enddo1
     C                   endif
     *
     *  Display error if option is not valid.
     *
     C                   if        option <> *blanks  and
     C                             option <> '1'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm0108
     C                   endif
     *
     *  Save option
     *
     C                   z-add     recno         y
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C     wkounq        chain     workopt                            79
     C                   if        not *in79
     C                   if        option = *blanks
     C                   delete    wkorec
     C                   else
     C                   move      option        wkoopt
     C                   move      *in21         wkoerr
     C                   update    wkorec
     C                   endif
     C                   else
     C                   if        option <> *blanks
     C                   eval      wkousr = #user
     C                   eval      wkopgm = #prog
     C                   eval      wkokyf = fkey(y)
     C                   eval      wkokyu = ukey(y)
     C                   move      option        wkoopt
     C                   move      *in21         wkoerr
     C                   write     wkorec
     C                   endif
     C                   endif
     C     enddo1        tag
     C                   enddo
     C                   endsr
700aA*----------------------------------------------------------------
700aA*
700aA*  SAVINDOPT   Verify and save indirect options
700aA*
700aAC     savindopt     begsr
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
700aA*
700aA*
700aA*  Save option
700aA*
700aAC                   eval      wkokyf = dskey
700aAC                   eval      wkokyu = dskey
700aAc                   eval      option = '1'
700aAC     wkounq        chain     workopt                            79
700aAC                   if        not *in79
700aAC                   if        option = *blanks
700aAC                   delete    wkorec
700aAC                   else
700aAC                   move      option        wkoopt
700aAC                   move      *in21         wkoerr
700aAC                   update    wkorec
700aAC                   endif
700aAC                   else
700aAC                   if        option <> *blanks
700aAC                   eval      wkousr = #user
700aAC                   eval      wkopgm = #prog
700aAC                   move      option        wkoopt
700aAC                   move      *in21         wkoerr
700aAC                   write     wkorec
700aAC                   endif
700aAC                   endif
700aAC                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
750fDC**                 if        recno < 11
750fMC                   if        recno < 11 or prime
     C                   add       1             recno
     C                   z-add     recno         y
     *
     *  SAVE FILE AND UNIQUE KEYS
     *
750fAC                   if        usingScreen
     C                   eval      fkey(y) = $pofky
     C                   eval      ukey(y) = $pouky
750fAC                   endif
     *
     *  WRITE DISPLAY LINE TO SUBFILE
     *
     C                   exsr      zzfill
750fAC                   if        usingScreen
     C                   write     dspsfl
750fAC                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      *in01 = *off
     C                   write     dspsfc
     C                   eval      recno = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
     *
     *  WRITE OPTION AND COMMAND LINES TO DISPLAY
     *
     C                   write     optrec
     C                   write     cmdrec
     *
     *  WRITE 'BOTTOM/MORE...' FIELD TO DISPLAY
     *
     C                   write     morrec
     *
     *  WRITE POSITION TO FIELD TO DISPLAY
     *
     C                   write     postnrec
     *
     *  GET ANY EXISTING VALUES FOR THE OPTIONS
     *
     C                   exsr      sflopt
     *
     *  POSITION CURSOR TO FIRST OPTION WHEN NO ERRORS EXIST
     *
     C                   if        error <> '1'
     C     1             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      *in20 = *on
     C                   update    dspsfl
     C                   endif
     C                   endif
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   eval      *in01 = *on
     C                   eval      recno = 1
     C                   write     dspsfc
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLOPT   Initialize options for subfile
     *
     C     sflopt        begsr
750fAC                   if        not usingScreen
750fAC                   leavesr
750fAC                   endif
     C     1             do        10            x
     C     x             chain     dspsfl                             79
     C                   if        not *in79
     C                   eval      wkokyf = fkey(x)
     C                   eval      wkokyu = ukey(x)
     C     wkounq        chain     workopt                            78
     C                   if        not *in78
     C                   move      wkoopt        option
     C                   eval      *in21 = wkoerr
     C                   eval      *in20 = wkoerr
     C                   else
     C                   eval      option = *blanks
     C                   eval      *in21 = *off
     C                   eval      *in20 = *off
     C                   endif
     C                   update    dspsfl
     C                   endif
     C                   enddo
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
750fAC                   if        usingScreen
     C                   write     msgctl
750fAC                   endif
     C                   eval      msgk = *zeros
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
750fAC                   if        usingScreen
     C                   write     msgclr
750fAC                   endif
     C                   eval      *in97 = *on
     C                   if        msgk > 0
750fAC                   if        usingScreen
     C                   write     msgctl
750fAC                   endif
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
750fAC                   if        usingScreen
     C                   exsr      zmcmsg
750fAC                   endif
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
     C                   parm      #prog         #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
750fAC                   if        usingScreen
     C                   write     msgrec
750fAC                   else
750fAC                   call      'GETMSG2'
750fAC                   parm                    #msgk
750fAC                   parm                    #pgmq
750fAC                   parm                    #msgtext
750fAC                   eval      errmsg = #msgtext
750fAC                   endif
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
750fAC                   if        usingScreen
     C                   write     msgrec
750fAC                   endif
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     *R                   WRITECLRSCR
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
     C                   parm      $lprg         #pgmq
     C                   parm                    #msgk
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0104  Pressed an invalid key.
     *
     C     zm0104        begsr
     C                   eval      #msgid = 'PIR0104'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *      0106  Invalid cursor position.
     *
     C     zm0106        begsr
     C                   eval      #msgid = 'PIR0106'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0107  Invalid value for "position To"
     *
     C     zm0107        begsr
     C                   eval      #msgid = 'PIR0107'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0108  Invalid Option.
     *
     C     zm0108        begsr
     C                   eval      #msgid = 'PIR0108'
     C                   eval      #msgtp = '*DIAG  '
     C                   movel     option        errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR1001  Invalid code.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $lmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTN   Get next record
     *
     C     zzfgtn        begsr
     C     try1          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *R                   READ RECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        reade     record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFGTP   Get previous record
     *
     C     zzfgtp        begsr
     C     try2          tag
     *
     *    Code to use when we are not using a partial key.
     *
     *                    READPRECORD                   79
     *
     *    Code to use when we do have a partial key to use.
     *
     C     partky        readpe    record                                 79
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFILL   Fill display line with values that need
     *           to be converted.
     *
     C     zzfill        begsr
      /free
750fA
750fA    // For Prime, add to JSON array
750fA
         if prime and tkcode <> '';
           yajl_beginObj();
             yajl_addChar('tkcode': %trim(tkcode));
             yajl_addChar('tkdesc': %trim(tkdesc));
           yajl_endObj();
         endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for main file.
     *
     *
     *  Define full key for main file.
     *
     C     fileky        klist
     C                   kfld                    tkcat
720aAc                   kfld                    tktype
720aMC                   kfld                    tkcode
720aDC*                  kfld                    tksub
     *
     *  Define partial key for main file (if needed).
     *
     C     partky        klist
     C                   kfld                    $lcat
720aAC                   kfld                    $lttyp
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Initialization every time program is called.
     *
     C     zzinz2        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYF   Create key for file being used
     *
     C     zzkeyf        begsr
     C                   eval      $pofky = dskey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZKEYU   Create unique key for file
     *             (to be used in delete and change programs)
     *
     C     zzkeyu        begsr
     C                   eval      $pouky = dskey
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS    Position to a different record.
     *
     C     zzpos         begsr
     *
     *  See if user is trying to position to a certain spot
     *
     C                   if        ptinp1 <> *blanks
     C                   eval      tkcat = ptinp1
700aA /Free
700aA    chain (ptinp1) task;
720aM    if %found and tkcat = 'MISC'
720aA              and tktype = 'I';
700aA    eval $lcat = tkcat;
700aA    eval $lsub = tksub;
700aA    eval $lcode = tkcode;
700aA    eval $lttyp = tktype;
700aA    eval $lrtn = '*SELECT ';
700aA    eval nxtscr = 'EOJ';
700aA    exsr savindopt;
700aA    endif;
700aA /end-free
     C                   eval      ptinp1 = *blanks
     C                   eval      repos = *on
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPOS2   Position to record
     *
     C     zzpos2        begsr
     *
     *    Code to use when we are not using a partial key.
     *
     *R         $POCMD    IFEQ '*TOP'
     *R         *LOVAL    SETLLRECORD
     *R                   ELSE
     *R         $POCMD    IFEQ '*BOTTOM'
     *R         *HIVAL    SETLLRECORD
     *R                   END
     *R                   END
     *
     *    Code to use when we do have a partial key to use.
     *
     C                   if        $pocmd = '*TOP'
     C     partky        setll     record
     C                   else
     C                   if        $pocmd = '*BOTTOM'
     C     partky        setgt     record
     C                   endif
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZVRFY   Verify unique key.
     *
     C     zzvrfy        begsr
     C                   eval      dskey = $luky
     C     fileky        chain     record                             79
     C                   if        not *in79
     C                   eval      $lrtn = '*OK     '
     C                   movel     tkcode        $lerm
     C                   else
     C                   eval      $lrtn = '*PGMQ   '
     C                   exsr      zm1001
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  CreateRtnError    Create return JSON error string
     *----------------------------------------------------------------

     p CreateRtnError  b
     d CreateRtnError  pi

      /free


         yajl_genOpen(*Off);

           yajl_beginObj();

             // Grab Std section that was sent in and added it

             yajl_addPreformattedPtr('Std': stdPointer: stdLen);

             // Add Output section

             yajl_beginObj('Output');
               yajl_addchar('errmsg': errmsg500);
               yajl_addchar('spoken': errmsg500);
             yajl_endObj();

         yajl_endObj();

           pJsonStr = YAJL_copyBufStr();

         yajl_genClose();

DAM      slgbuf = '<Error> ' + pjsonstr;
DAM      WriteVoiceLog('Err': slgbuf);


      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzFuncKeys   Initialize function keys for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzFuncKeys    b
     d $InzFuncKeys    pi

      /free

         *inka = *off;
         *inkb = *off;
         *inkc = *off;
         *inkd = *off;
         *inke = *off;
         *inkf = *off;
         *inkg = *off;
         *inkh = *off;
         *inki = *off;
         *inkj = *off;
         *inkk = *off;
         *inkl = *off;
         *inkm = *off;
         *inkn = *off;
         *inkp = *off;
         *inkq = *off;
         *inkr = *off;
         *inks = *off;
         *inkt = *off;
         *inku = *off;
         *inkv = *off;
         *inkw = *off;
         *inkx = *off;
         *inky = *off;

         // Ignore incoming function keys when requesting a list
         // Reason: The keys are actually for OR400 to call this program.

         if $lcmd = '*SPLIST';
           return;
         endif;

         select;

           when spBtnClick = 'S01'
             or %subst(spF1F24Flags: 1: 1) = '1';
               *inka = *on;

           when spBtnClick = 'S02'
             or %subst(spF1F24Flags: 2: 1) = '1';
               *inkb = *on;

           when spBtnClick = 'S03'
             or %subst(spF1F24Flags: 3: 1) = '1';
               *inkc = *on;

           when spBtnClick = 'S04'
             or %subst(spF1F24Flags: 4: 1) = '1';
               *inkd = *on;

           when spBtnClick = 'S05'
             or %subst(spF1F24Flags: 5: 1) = '1';
               *inke = *on;

           when spBtnClick = 'S06'
             or %subst(spF1F24Flags: 6: 1) = '1';
               *inkf = *on;

           when spBtnClick = 'S07'
             or %subst(spF1F24Flags: 7: 1) = '1';
               *inkg = *on;

           when spBtnClick = 'S08'
             or %subst(spF1F24Flags: 8: 1) = '1';
               *inkh = *on;

           when spBtnClick = 'S09'
             or %subst(spF1F24Flags: 9: 1) = '1';
               *inki = *on;

           when spBtnClick = 'S10'
             or %subst(spF1F24Flags: 10: 1) = '1';
               *inkj = *on;

           when spBtnClick = 'S11'
             or %subst(spF1F24Flags: 11: 1) = '1';
               *inkk = *on;

           when spBtnClick = 'S12'
             or %subst(spF1F24Flags: 12: 1) = '1';
               *inkl = *on;

           when spBtnClick = 'S13'
             or %subst(spF1F24Flags: 13: 1) = '1';
               *inkm = *on;

           when spBtnClick = 'S14'
             or %subst(spF1F24Flags: 14: 1) = '1';
               *inkn = *on;

           when spBtnClick = 'S15'
             or %subst(spF1F24Flags: 15: 1) = '1';
               *inkp = *on;

           when spBtnClick = 'S16'
             or %subst(spF1F24Flags: 16: 1) = '1';
               *inkq = *on;

           when spBtnClick = 'S17'
             or %subst(spF1F24Flags: 17: 1) = '1';
               *inkr = *on;

           when spBtnClick = 'S18'
             or %subst(spF1F24Flags: 18: 1) = '1';
               *inks = *on;

           when spBtnClick = 'S19'
             or %subst(spF1F24Flags: 19: 1) = '1';
               *inkt = *on;

           when spBtnClick = 'S20'
             or %subst(spF1F24Flags: 20: 1) = '1';
               *inku = *on;

           when spBtnClick = 'S21'
             or %subst(spF1F24Flags: 21: 1) = '1';
               *inkv = *on;

           when spBtnClick = 'S22'
             or %subst(spF1F24Flags: 22: 1) = '1';
               *inkw = *on;

           when spBtnClick = 'S23'
             or %subst(spF1F24Flags: 23: 1) = '1';
               *inkx = *on;

           when spBtnClick = 'S24'
             or %subst(spF1F24Flags: 24: 1) = '1';
               *inky = *on;

         endsl;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzPgmVar     Initialize program variables for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzPgmVar      b
     d $InzPgmVar      pi

      /free

         errmsg = '';
         errmsg500 = '';

         // Extract Input fields

         jsonGetFields(inputNode);

         // Set function keys

         $InzFuncKeys();

         // Set screen fields

         nxtscr = '01 ';

      /end-free

     p                 e

750fA*****************************************************************
750fA* Set output for next screen
750fA*****************************************************************
750fAp $SetNxtScr      b
     d $SetNxtScr      pi

     d  i              s              3  0

      /free
       spF1F24Flags = '000000000000000000000000';
       spbtnFlags = '0000000000';


       // Initialize JSON buffer

       yajl_genOpen(*Off);

       // Begin main JSON object

       yajl_beginObj();         // Begin JSON string

       // Grab Std section that was sent in and added it

       yajl_addPreformattedPtr('Std': stdPointer: stdLen);

       // Begin Ouput section

       yajl_beginObj('Output');

       // Put error message at beginning

       yajl_addchar('errmsg': %trim(errmsg));

       // Now add screen output

       Select;

       When nxtscr = '01 ';
         yajl_addchar('nxtscr': 'TK901.' + %trim(nxtscr));
         yajlRtnStatus = yajl_addPreformattedPtr('listary':
                                                  bufArrayPtr: bufArrayLen);
         yajl_addchar('spoken': 'select task');
         %subst(spF1F24Flags: 5: 1) = '1';
         %subst(spF1F24Flags: 12: 1) = '1';

       Endsl;

       // Add function key display
       yajl_addchar('f1f24flags': spf1f24flags);
       yajl_addchar('btnflags': spBtnFlags);

       yajl_endObj();                 // End Output section
       yajl_endObj();                 // End entire JSON string
       pJsonStr = YAJL_copyBufStr();  // Copy JSON string into parameter
       yajl_genClose();               // Close and cleanup JSON processing

      /END-FREE
     p                 e

750fA*----------------------------------------------------------------
750fA*  WriteVoiceLog    Write record to voice log BFCSKTLOG
750fA*----------------------------------------------------------------
750fA
750fAp WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       GetCurrStamp();

       slgTyp = type;

       //slgbuf = spWhereFrom
       //       + '        '
       //       + '- ' + #pgm + %trim(buffer);
       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #job;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  GetCurrStamp  Get current timestamps
750fA*----------------------------------------------------------------
750fA
750fAp GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p                 e

     *----------------------------------------------------------------
     * UpperToLower   Convert uppercase to lowercase
     *----------------------------------------------------------------

     p UpperToLower    b
     d UpperToLower    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(uppercase: lowercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * SetPgmField      Set program field
     *----------------------------------------------------------------

     p SetPgmField     b
     d SetPgmField     pi
     d  key                          50A   varying const
     d  val                                like(yajl_val) const

     d lowkey          s             50A   varying

      /free

        // Force keys to lowercase to eliminate case errors

        lowkey = UpperToLower(key);

         // Move value into screen field

         monitor;

           select;

             // Standard Fields

             when lowkey = 'app';
               spApp = yajl_get_string(val);

             when lowkey = 'user';
               spUser = yajl_get_string(val);

             when lowkey = 'uid';
               spUid = yajl_get_string(val);

             when lowkey = 'wherefrom';
               spWhereFrom = yajl_get_string(val);

             when lowkey = 'whouse';
               spWhouse = yajl_get_string(val);

             // Input screen fields

             when lowkey = 'f1f24flags';
               spF1F24Flags = yajl_get_string(val);

             when lowkey = 'btnflags';
               spBtnFlags = yajl_get_string(val);

             when lowkey = 'tkcode';
               tkcode = yajl_get_string(val);

           endsl;

         on-error;

           error = *on;
           errmsg = 'Error extracting field ' + %trim(key);
           return;

         endmon;

      /end-free
     p                 e

750fA*----------------------------------------------------------------
750fA*  LoadJson   Load JSON into memory
750fA*----------------------------------------------------------------
750fA
750fAp LoadJson        b
     d LoadJson        pi

      /free

        // Load JSON string into memory and get pointer to root node/object

        docNode = yajl_string_load_tree( pJsonStr : yajlerr );
        if yajlerr <> '';
          error = *on;
          errmsg500 = 'Error loading JSON string - ' + yajlerr;
          CreateRtnError();
          return;
        endif;

        // Get pointer to Std section

        stdNode = yajl_object_find(docNode: 'Std');
        if stdNode = *null;
          error = *on;
          errmsg500 = 'Error loading Std section';
          CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;


        stdLen = YAJL_stringify(stdNode: stdPointer: %len(stdBuffer));

        // Get pointer to Input section

        inputNode = yajl_object_find(docNode: 'Input');
        if inputNode = *null;
          error = *on;
          errmsg500 = 'Error loading Input section';
          CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;

        inputLen = YAJL_stringify(inputNode: inputPointer: %len(inputBuffer));

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JSON Subprocedures
     *----------------------------------------------------------------

      /copy qcopysrc,$jsonstr


     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Task code
