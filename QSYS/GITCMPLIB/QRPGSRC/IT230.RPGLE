      /copy qcopysrc,hspecs
500bA*----------------------------------------------------------------
500bA*  Multilingual Version
500bA*  Every screen and message has a corresponding Spanish version.
500bA*  Any changes must be made to both languages.
500bA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT230     Item Lookup - RF
     *  17 April, 1997
     *  Roxanne Harrison
     *
     *  Notes
     *       Created using IT120
     *       8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions
     *
223 A*    07/08/97  RH   2.23
     *      - Add item field to SC1.
     *
415 A*    06/13/01  DAS  4.15
     *      - Revised to CLRSCR upon return from calling IT231.
416aA*    03/27/02  RH   4.16a
     *      - Add Mfg/Vend item # to screen.
417aA*    04/14/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
417bA*    09/09/03  RH   4.17b
     *      - Enh: Add screen2 for description and pack.
500aA*    03/18/05  RH   5.00a
     *      - Enh: Add call to APICVTITM to strip leading blanks.
     *
500bA*    05/25/06  DAS  5.00b
     *      - Added Multilingual logic.
     *
510aA*    03/19/07  DAS  5.10a
     *      - Change screen 1 w1upc field length 20 to
     *        w1up50 length 50.
     *      - Revised zzchk1 to send w1up50 to cvtbar and put the
     *        result itno w1upc.
510bA*    04/04/07  MLB  5.10b
     *      - Enh: Added client custom code support to program.
520aA*    03/26/08  RH   5.20a
     *      - Enh: Added ITEMLNK files to find linked items.
700aA*    03/22/16  MR   7.00a
     *      - Enh: Add Inventory Quantities to Item Lookup.
     *      - Convert to RPGLE.
700bA*    05/20/16  LMC  7.00b
     *      - Enh: Add Brand from ITEMMSC
700cA*    09/19/16  LMC  7.00c
     *      - Fix: Changed the display file to IT23003.
     *        Text field changed from Tfr to Ina, so it matches
     *        Item Qty from Item maintenance.
     *
700dA*    11/03/16  LMC  7.00d
     *      - Enh: UPC file has a database change. Recompile only.
720  *    09/23/18  KDE  7.20
     *      - Fix: Correct how quantity is shown when negative
     *        Breakdown.  Currently shows as -1. positive breakdown
     *        Should show as -0.5 if negative 5 breakdowns
730a *    01/18/19  KDE  7.30a
     *      - Fix: Force 1 on breakdowns when 0
730b *    10/16/19  KDE  7.30b
     *      - Fix: Add F8 to print item identification label (Chefs first)
     *        when Belt Printer is available
     *      - Also changed to use screen IT23005
740a *    05/11/20  LMC  7.40a
     *      - Enh: Spanish screen still had small upc field.
740b *    06/09/20  DAS  7.40b
     *      - Enh: Revised to use IT23007.
     *      - No other changes in this program.
740c *    10/02/20  DAS  7.40c
     *      - Fix: Increase NEWQTY1/2 to 9.0 from 5.0.
     *        Large Normal qty blew up rollup routine.
740d *    01/05/21  JCJ  7.40d
     *      - added *NOMORE to return from CVTBAR
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
AFS A*    04/04/07  MLB  AFS
     *      - Revised ZZCHK1 to allow processing to continue even
     *        if CVTBAR comes back with *INVALID. If UPC code is
     *        on file in UPC, its a good code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques
     *
MQSa *    02/13/19  GJA  MQSa
     *      - Revised ZZCHK1 to allow processing to continue even
     *        if CVTBAR comes back with *INVALID. If UPC code is
     *        on file in UPC, its a good code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    12/04/19  KDE  DRY
     *      - Revised to show F8 for printing item label for
     *        orphand stock
     *
     *  Client Custom Revisions: Eastland Food Corp.
     *
EFC A*    01/12/12  RH   EFC
     *      - FIX: Add IF to AFS mod, W1UPC code was blank if invalid
     *      - Enh: Added to AFS mod to allow processing of invalid
     *        UPC code. If UPC code is on file in UPC its a good code
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordanos Foodservice
JORaA*    03/26/08  RH   JORa
     *      - Enh: Added message to SC2 if item has linked item.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
700aD*IT230FM CF  E                    WORKSTN
700bDF*it23001   cf   e             workstn
700cDF*it23002   cf   e             workstn
730bDF*it23003   cf   e             workstn
730bDF*it23004   cf   e             workstn
740aDF*it23005   cf   e             workstn
740bDF*t23006   cf   e             workstn
740bMFit23007   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fupc       if   e           k disk
700aAFitemqty   if   e           k disk
730bAfslot3     if   e           k disk
416aAFpiritem4  if   e           k disk
417bAFoptions   if   e           k disk
730bAfequip2    if   e           k disk
417bAFitemdsc   if   e           k disk
520aAFitemlnk   if   e           k disk
520aAFitemlnk1  if   e           k disk
     F                                     rename(ilrec:recd1)
417bAFpiritem   if   e           k disk
     F                                     rename(itrec:record)
700bAFitemmsc   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
416aAD desc            s             50    dim(1) ctdata perrcd(1)
500bAD descsp          s             50    dim(1) ctdata perrcd(1)

610bA*----------------------------------------------------------------
610bA*  DRI parameters
610bA*----------------------------------------------------------------

610bA /COPY *libl/qcopysrc,C#DRIPARMS

610bA*----------------------------------------------------------------
610bA*  Data Formats
610bA*----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#EQUIPT

510bA*----------------------------------------------------------------
510bA*  Client id's for custom mods.
510bA*----------------------------------------------------------------
510bA*
     D @getcl          c                   const('GETCLIENT')
510bA*
510bA /COPY QCOPYSRC,ID#ANDREWS
730bA /COPY QCOPYSRC,ID#DAIRYLA
520aA /COPY QCOPYSRC,ID#JORDANO
EFCaA /COPY QCOPYSRC,ID#EASTLAN
MQSaA /COPY QCOPYSRC,ID#MQS
510bA*
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
     D  $litm1                22     36
     *
417a D  $lupc                 22     41
417a D  $litem                42     56
     *
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
     *
500aA*----------------------------------------------------------------
500aA*  API programs
500aA*
     D @apici          c                   const('APICVTITM ')
     *----------------------------------------------------------------
417bA* Data structure
417bA*
417bAD opdata          ds
417bAD  opstyp                 1      1
417bAD  opwhdp                 2      6
417bAD  opum1                  7      8
417bAD  opdum                  9     23
417bAD  opcum                 24     43
417bAD  opcdiv                44     52  2
417bAD  opcaut                53     53
417bAD  opcwrn                54     54
417bAD  opcrng                55     57  1
417bAD  opwum                 58     72
417bAD  opxdsc                73     73
417bAD  optend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
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
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D $prtdev         s             10
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D forevr          s              1
     D help            s              5  0
     D kyvmfg          s                   like(itvit#)
     D msgk            s              4  0
720 Ad Newqtyn         s              5  0
740cDd*Newqty1         s              5  0
740cMd Newqty1         s              9  0
740cDd*Newqty2         s              5  0
740cMd Newqty2         s              9  0
730bAd numTries        s              3  0
     D nxtscr          s              3
     D ocode           s              8
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
730bAD saveVer#        s                   like($etver#)
     D sclear          s              1
     D upcctr          s              3  0
     D warn            s              1
     D wsitem          s             15
730bAd rtnmsg          s             50
     D w1upc           s             20

    *----------------------------------------------------------------
    * Prototypes
    *----------------------------------------------------------------

730bA*  Call Print program for Item Lookup Label
730bAD itemLookLabel   PR                  EXTPGM('PRTPRDLBL')
730bAD  $pCmd                         8    const
730bAD  $plSet                        6    const
730bAd  $plfmt                        8    const
730bAd  $pWhsec                       3    const
730bAd  $pitem                       15
730bAd  $pslot                       12
730bAd  $pord                         7  0 const
730bAd  $pnote1                      50
730bAd  $pnote2                      50    const
730bAd  $pnote3                      50    const
730bAd  $pnote4                      50    const
730bAd  $pnote5                      50    const
730bAd  $pnote6                      50    const
730bAd  $pucode                       2
730bAd  $pgs1fmt                     48    const
730bAd  $pdev                        10
730bAd  $pform                       10    const
730bAd  $pcust                       46    const
730bAd  $pdate                        5    const
730bAd  $pwgt                         6    const
730bAd  $plcns#                      15    const
730bAd  $pCaseUci                    50    const
730bAd  $pLotSer                     30    const
     *
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *  Let the show begin .....
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     *
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
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
     C                   if        error = *on
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
     C                   endif
     C                   if        nxtscr = '02 '
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   exfmt     scrn2sp                              50
500bAC                   other
417bMC                   exfmt     screen2                              50
500bAC                   endsl
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
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

500nA*----------------------------------------------------------------
500nA*  clr$equipt  Clear $equipt data structure fields
500nA*----------------------------------------------------------------
500nA
500nAC     clr$equipt    begsr
     C                   eval      savever# = $etver#
     C                   clear                   $equipt
     C                   eval      $etver# = savever#
     C                   endsr

730bA*---------------------------------------------------------------
730bA*  GetChkOut  Get check out for printer
730bA*---------------------------------------------------------------
730bAC     GetChkOut     BegSr
730bA /free
730bA                       exsr getEmplInfo;
730bA                       $etcode='*NONE';
730bA                       exsr clr$equipt;
730bA                       $etwhseu = *on;
730bA                       $etwhse  = $whse;
730bA                       $etemp#u = *on;
730bA                       $etemp#  = e$emp#;
730bA                       $etcodeu = *on;
730bA                       $etcode  = 'BLTPRT';
730bA                       $dricommand = '*EQUIPT';
730bA                       $drisubcmd  = '%GETCHKOUT';
730bA                       $drisys2upd = 'D';
730bA                       exsr zzzdricop;
730bA /end-free
730bAC                   Endsr
730bA*---------------------------------------------------------------
730bA*  GetEmplInfo  Get employee info.
730bA*---------------------------------------------------------------
730bAC     GetEmplInfo   BegSr

     C                   call      'GETEMPL'
     C                   parm      e$emp#        $emp#             5 0
     C                   parm      0             $whse             3 0
     C                   parm                    $code            10
     C                   parm                    $fnam            15
     C                   parm                    $init             1
     C                   parm                    $lnam            20
     C                   parm                    $whdp             5
     C                   parm                    $styp             1
     C                   parm                    $shft             6
     C                   parm                    $crew             6
     c                   parm      0             $nhrs             3 1
     C                   parm                    $rtn              8
     C                   parm                    $bpu              1
     C                   parm                    $lng              2
     C                   parm                    $email            1
     C                   parm                    $pics             1

     C                   if        $rtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      $whse = 0
     C                   eval      $code = ' '
     C                   endif

730bAC                   Endsr

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
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   if        refrsh = *on
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
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
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
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
     *  The after update redisplay screen. The only way out is F3.
417b *  Change to display screen 2.
417b C                   exsr      scr02i
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
730bAc                   write     clrscr
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
510bA*
510bA* Get client id
510bA*
510bAC                   call      @getcl
510bAC                   parm                    client           10
510bAC                   parm                    cliloc           10
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
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
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
223 A*   PIR0204  Enter only one value.
223 A*
223 AC     zm0204        begsr
223 AC                   eval      #msgid = 'PIR0204'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
223 A*----------------------------------------------------------------
223 A*   PIR0205  Must enter one value.
223 A*
223 AC     zm0205        begsr
223 AC                   eval      #msgid = 'PIR0205'
223 AC                   eval      #msgtp = '*DIAG  '
223 AC                   eval      $md = *blanks
223 AC                   exsr      zmpmsg
223 AC                   endsr
416a *----------------------------------------------------------------
416a *    PIR1001  Invalid option entered.
416a *
416a C     zm1001        begsr
416a C                   eval      #msgid = 'PIR1001'
416a C                   eval      #msgtp = '*DIAG  '
416a C                   movea     errmsg        $md
416a C                   exsr      zmpmsg
416a C                   endsr
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
     *    LP11022  License not on file.
     *
     C     zm022         begsr
     C                   eval      #msgid = 'PO20029'
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
416aAC                   eval      wsitem = *blanks
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   else
     *R                   Z-ADDPHWHSE    $KWHSE
     *R                   Z-ADDW1WHSE    WHCODE
220 D*R                   MOVEL$LERM     WHDESC
     C                   endif
     C                   endif
416a *  This error check was moved to code that verifies each field.
416aD*  Enter only one, either item or UPC.
416aD*
416aD*R         W1ITEM    IFNE *BLANKS
416aD*R         W1UPC     ANDNE*BLANKS
416aD*R                   MOVE *ON       ERROR
416aD*R                   MOVE *ON       *IN22
416aD*R                   MOVE *ON       *IN02
416aD*R                   MOVE *ON       *IN23
416aD*R                   MOVE *ON       *IN03
416aD*R                   EXSR ZM0204
416aD*R                   ENDIF
     *
223 A*  Must enter one, either item or UPC or MFG #
223 A*
223 AC                   if        w1item = *blanks  and
510aD**         W1UPC     ANDEQ*BLANKS
510aMC                             w1up50 = *blanks  and
416aAC                             w1vmfg = *blanks
223 AC                   eval      error = *on
223 AC                   eval      *in22 = *on
223 AC                   eval      *in02 = *on
223 AC                   eval      *in23 = *on
223 AC                   eval      *in03 = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
223 AC                   exsr      zm0205
223 AC                   endif
     *
     *  Verify UPC
     *
510aAC                   eval      w1upc = *blanks
416a *
416aAC                   select
416a *  UPC entered
510aD**         W1UPC     WHNE *BLANKS
510aMC                   when      w1up50 <> *blanks
416aAC                   if        w1item = *blanks  and
416aAC                             w1vmfg = *blanks
416a *
416aAC                   eval      $cbcmd = '*UPC    '
510aD**                   MOVELW1UPC     $CBBAR
510aMC                   movel     w1up50        $cbbar
416aAC                   call      'CVTBAR'
416aAC                   parm                    $cbcmd            8
416aAC                   parm                    $cbbar          100
416aAC                   parm                    $cbcod            3 0
416aAC                   parm                    $cbdec            1 0
416aAC                   parm                    $cbdsc           30
416aAC                   parm                    $cbpos            3 0
416aAC                   parm                    $cbtyp            1 0
416aAC                   parm                    $cbv1            11 3
416aAC                   parm                    $cbv2            50
416aAC                   parm                    $cbrtn            8
416aAC                   parm                    $cberm           60
416a *
416aAC                   if        $cbrtn = '*OK'  or
510aAC                             $cbrtn = '*UPCWARN' or
740dAC                             $cbrtn = '*NOMORE'
EFCaAC                   movel     $cbv2         w1upc
EFCaAC                   else
AFS A*
AFS A*     Treat all returns from CVTBAR as good.
AFS A*     If code is found in UPC file, its good.
EFC AC                   if        client = eastln  or
MQSaAC                             client = Marques or
AFS AC                             client = andrew
AFS A*
EFCaD*R                   MOVEL$CBV2     W1UPC
EFCaMC                   movel     $cbbar        w1upc
EFCaAC                   endif
416aAC                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w1upc         $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w1upc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
417a C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   exsr      zm022
416aAC                   goto      endck1
     C                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = w1whse
417a C                   eval      $lupc = w1upc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
417a C                   eval      *in24 = *on
417a C                   eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litem
     *
417a C                   endif
416aAC                   eval      wsitem = upitem
416aAC                   else
416aA*  Error, more than one value entered.
416aAC                   eval      error = *on
416aAC                   eval      *in22 = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in02 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   exsr      zm0204
416aAC                   goto      endck1
416aAC                   endif
     *
416aAC                   endsl
     *
416a *
416a *  Verify Mfg code/vendor item.
416a *
416aAC                   if        w1vmfg <> *blanks
416aAC                   if        w1upc = *blanks  and
416aAC                             w1item = *blanks
416aAC                   eval      kyvmfg = w1vmfg
416aAC     mfgkey        chain     piritem4                           79
416aAC                   if        *in79
416aAC                   eval      error = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   eval      errmsg = *blanks
500bAC                   select
500bAC                   when      e$lng = 'SP'
500bAC                   eval      errmsg = descsp(1)
500bAC                   other
416aAC                   eval      errmsg = desc(1)
500bAC                   endsl
416aAC                   exsr      zm1001
416aAC                   goto      endck1
416aAC                   else
416aAC                   eval      wsitem = ititem
416aAC                   endif
416aAC                   else
416aA*  Error, more than one value entered.
416aAC                   eval      error = *on
416aAC                   eval      *in22 = *on
416aAC                   eval      *in23 = *on
416aAC                   eval      *in24 = *on
416aAC                   eval      *in04 = *on
416aAC                   eval      errmsg = *blanks
416aAC                   exsr      zm0204
416aAC                   goto      endck1
416aAC                   endif
416bAC                   endif
     *
416a *  Get item # from other field entered.
     *
416aAC                   if        w1item = *blanks  and
416aAC                             wsitem <> *blanks
416aAC                   eval      w1item = wsitem
416aAC                   endif
     *
223 A*  Verify ITEM
223 A*
223 AC                   if        w1item <> *blanks
500aA*  Call API for item.
500aA*
500aAC                   call      @apici
500aAC                   parm                    w1item
500aAC                   parm      6             worow             3 0
500aAC                   parm      7             wocol             3 0
500aAC                   parm                    @artn             8
500aAC                   if        @artn = '*REDSPLY'
500aAC                   endif
500aA*
223 AC                   eval      $lcmd = '*VERIFY '
223 AC                   eval      $lwhse = w1whse
223 AC                   eval      $litm1 = w1item
223 AC                   call      'IT900'
223 AC                   parm                    $lparm
223 AC                   if        $lrtn = '*ERROR  '
223 AC                   eval      error = *on
223 AC                   eval      *in23 = *on
223 AC                   eval      *in03 = *on
223 AC                   movel     $lerm         errmsg
223 AC                   exsr      zm0105
223 AC                   else
223 AC                   if        $lrtn = '*PGMQ   '
223 AC                   eval      error = *on
223 AC                   eval      *in23 = *on
223 AC                   eval      *in03 = *on
223 AC                   eval      #msgk = $lmsg
223 AC                   exsr      zmqmsg
223 AC                   endif
223 AC                   endif
223 AC                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
730bA*
730bA*  When CMD8 pressed, ensure we have belt printer defined to print label
730bA*
730bA /free
730bA                    if *inkh;
730bA                       if *in70=*off;
730bA                         error=*on;
730bA                         leavesr;
730bA                       endif;
730bA                       exsr getChkOut;
730bA                       if $drireturn='*NOTFOUND';
730bA                          $etcode='*NONE';
730bA                          // since no belt printer assigned prompt for one
730bA /end-free
730bAc                   call      'EQ410CL'
730bA /free
730bA                          exsr getChkOut;
730bA                          if $drireturn='*NOTFOUND';
730bA                             // if no belt printer still assigned return error
730bA                             $etcode='*NONE';
730bA                          endif;
730bA                       endif;
                            // if no printer was found or selected return error
                            if $etcode='*NONE';
                               error=*on;
                               write clrscr;
                               nxtscr='01';
                               errmsg='** No Printer ** ';
                               exsr zmcmsg;
                               exsr zm0105;
                            endif;
730bA                    endif;
730bA /end-free
     *
     *
     C     endck2        endsr
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
     C                   select
     *
     *     Warehouse.
     *
416aD**         ROW#      WHEQ 7
416aMC                   when      row# = 2
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
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
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
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
     C                   select
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
     C                   eval      w1upc = *blanks
510AAC                   eval      w1up50 = *blanks
416aAC                   eval      w1vmfg = *blanks
223 AC                   eval      w1item = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
417bAC                   eval      w2dsc1 = *blanks
417bAC                   eval      w2dsc2 = *blanks
417bAC                   eval      w2pack = *blanks
520aAC                   eval      *in81 = *off
700bAC                   eval      w2brnd = *blanks
700bAC                   eval      *in53 = *off
     *
417bAC                   eval      w2item = w1item
     *
     *
417BAC                   eval      ocode = '*ITEMMNT'
417bAC     opkey         chain     options                            79
417bAC                   if        *in79
417bAC                   eval      opxdsc = 'N'
417bAC                   endif
     *
417bAC                   if        opxdsc = 'Y'
417bAC     idkey         chain     itemdsc                            79
417bAC                   if        not *in79
417bAC                   eval      w2dsc1 = ixdsc1
417bAC                   eval      w2dsc2 = ixdsc2
417bAC                   endif
417bAC     itkey         chain     piritem                            78
417bAC                   if        not *in78
417bAC                   eval      w2pack = itpdsc
417bAC                   endif
     *
700aAC     itkey         chain     itemqty                            78
700aAC                   if        not *in78
720 Ac                   exsr      zzrollup
700aAC                   eval      iqavl1 = iqstk1 - iqalc1
700aAC                   eval      iqavl2 = iqstk2 - iqalc2
700aAC                   eval      iqavl3 = iqstk3 - iqalc3
700aAC                   if        iqhld1 > 0
700aAC                   eval      iqavl1 = iqavl1 - iqhld1
700aAC                   endif
700aAC                   if        iqhld2 > 0
700aAC                   eval      iqavl2 = iqavl2 - iqhld2
700aAC                   endif
700aAC                   if        iqhld3 > 0
700aAC                   eval      iqavl3 = iqavl3 - iqhld3
700aAC                   endif
700aAC                   endif
     *
417bAC                   else
417bAC     itkey         chain     piritem                            78
417bAC                   if        not *in78
417bAC                   movel     itdesc        w2dsc1
417bAC                   eval      w2pack = itpdsc
417bAC                   endif
     *
700aAC     itkey         chain     itemqty                            78
700aAC                   if        not *in78
720 Ac                   exsr      zzrollup
700aAC                   eval      iqavl1 = iqstk1 - iqalc1
700aAC                   eval      iqavl2 = iqstk2 - iqalc2
700aAC                   eval      iqavl3 = iqstk3 - iqalc3
700aAC                   if        iqhld1 > 0
700aAC                   eval      iqavl1 = iqavl1 - iqhld1
700aAC                   endif
700aAC                   if        iqhld2 > 0
700aAC                   eval      iqavl2 = iqavl2 - iqhld2
700aAC                   endif
700aAC                   if        iqhld3 > 0
700aAC                   eval      iqavl3 = iqavl3 - iqhld3
700aAC                   endif
700aAC                   endif
417bAC                   endif
JORaA*   Check for linked items.
700aDC*                  if        client = jordan
700aMC                   if        client = jordanos
JORa C     ilkey         setll     itemlnk1
JORa C     ilkey         reade     itemlnk1                               79
JORa C                   if        not *in79  and
JORa C                             ilitm2 = ititem
JORa C                   eval      *in81 = *on
JORaAC                   else
JORa C     ilkey         setll     itemlnk
JORa C     ilkey         reade     itemlnk                                79
JORa C                   if        not *in79  and
JORa C                             ilitem = ititem
JORa C                   eval      *in81 = *on
JORaAC                   endif
JORaAC                   endif
     *
JORaAC                   endif
700bA /free
700bA   // see if brand exist in the ITEMMSC
700bA   chain (itwhse: ititem) itemmsc;
700bA   if %found(itemmsc);
700bA     if imbrnd <> ' ';
700bA       w2brnd = imbrnd;
700bA       *in53 = *on;
700bA   endif;
700bA   endif;
730bA                    // only show cmdkey to print item label for Chefs
730bA                    if client = dairyland;
730bA                      // do not show f8 if no belt printers defined
730bA                      setll ($lWhse:'BLTPRT') equip2;
730bA                      reade ($lWhse:'BLTPRT') equip2;
730bA                      if %found(equip2);
730bA                        *in70=*on;
730bA                      else;
730bA                        *in70=*off;
730bA                      endif;
730bA                    endif;
730bA                    exsr getEmplInfo;
730bA                    $etcode='*NONE';
730bA                    // Belt Printer User

700bA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
417a C                   eval      forevr = *off
     *R                   MOVE #PROG     $PPRG
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C     upckey        klist
     C                   kfld                    w1whse
     C                   kfld                    w1upc
     *
223 AC     itkey         klist
223 AC                   kfld                    w1whse
223 AC                   kfld                    w1item
     *
520aAC     ilkey         klist
520aAC                   kfld                    itwhse
520aAC                   kfld                    ititem
416aA*
416aAC     mfgkey        klist
416aAC                   kfld                    w1whse
416aAC                   kfld                    kyvmfg
     *
417bA*     OPTIONS
417bA*
417bAC     opkey         klist
417bAC                   kfld                    $lwhse
417bAC                   kfld                    ocode
417bA*
417bA*     EXTENDED ITEM DESCRIPTION
417bA*
417bAC     idkey         klist
417bAC                   kfld                    $lwhse
417bAC                   kfld                    w1item
     *
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
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   eval      $lwhse = w1whse
223 AC                   if        w1upc <> *blanks
     C                   eval      $litm1 = upitem
223 AC                   else
223 AC                   eval      $litm1 = w1item
223 AC                   endif
417b **  Move call to ZZUPD2
417b *R                   CALL 'IT231'
220  *R                   PARM           $LPARM
417b *R                   PARM           $LUKY
417b *R                   PARM           $LRTN
417bA**                   WRITECLRSCR
417bD**                   EXSR SCR01I
     C     endup1        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
      /free
              if *inkh;
                 // since label print requested go find pick slot.
                 // if no pick slot then find first overflow
                 setll ($whse:w1item:'A':'Y') slot3;
                 reade ($whse:w1item:'A':'Y') slot3;
                 if not %equal(slot3) or %eof(slot3);
                    setll ($whse:w1item:'A':'N') slot3;
                    reade ($whse:w1item:'A':'N') slot3;
                    if not %equal(slot3) or %eof(slot3);
                       sldisp='Not_Found';
                    endif;
                 endif;
                 // print label to selected belt printer
                 // and return to screen one
                 $prtdev=$etcode;
                 itemLookLabel(' ':'ZBRDRY':'ITMLKUP':
                    %char($whse):w1item:sldisp:
                    *zeros:rtnmsg:' ':' ':' ':' ':' ':itum1:
                    ' ':$prtdev:'*LABEL':' ':' ':
                    ' ':' ':' ':' ');
                 write clrscr;
                 nxtscr='01';
                 error=*on;
                 if rtnmsg ='nolbl';
                   errmsg='** Lbl Fmt Missing **';
                 else;
                   errmsg='** Label Printed **';
                 endif;
                 exsr zmcmsg;
                 exsr zm0105;
                 leavesr;
              endif;
      /end-free
     *
417b **  Moved call from ZZUPD1
417b C                   call      'IT231'
417b C                   parm                    $luky
417b C                   parm                    $lrtn
417bAC                   write     clrscr
     C                   exsr      scr01i
     *
     C     endup2        endsr

720 A *----------------------------------------------------------------
720 A *  ZZROLLUP      Rollup Breakdown Quantities
720 A *----------------------------------------------------------------
720 A
720 AC     zzrollup      begsr
720 A
720 A /free
720 A   // Ensure everything rolled correctly with Breakdowns
720A   // Stock Quantity first
730aD      //if iqstk2<>0 or iqstk3<>0;
730aA      if (iqstk2<>0 and itumq2<>0) or (iqstk3<>0 and itumq3<>0);
720 A        select;
720 A         when iqstk3 <> 0;
720A    //First, take to lowest level quantity based on breakdowns
720 A            newqty2 = ((iqstk1 * itumq2 * itumq3) +
720 A                       (iqstk2 * itumq3) +
720 A                        iqstk3);
720 A            newqty1=*zeros;
720 A            newqtyn=*zeros;
720 A         when iqstk2 <> 0;
720 A            newqty1 = ((iqstk1 * itumq2) +
720 A                        iqstk2);
720 A            newqtyn=*zeros;
720 A        endsl;
720A   //Next, roll back up with breakdown structure
720 A        exsr zzupQty;
720 A        iqstk1 = newqtyn;
720 A        iqstk2 = newqty1;
720 A        iqstk3 = newqty2;
720 A      endif;
720A   // Allocated Quantity next
720 A      if iqalc2<>0 or iqalc3<>0;
720 A        select;
720 A         when iqalc3 <> 0;
720A    //First, take to lowest level quantity based on breakdowns
720 A            newqty2 = ((iqalc1 * itumq2 * itumq3) +
720 A                       (iqalc2 * itumq3) +
720 A                        iqalc3);
720 A            newqty1=*zeros;
720 A            newqtyn=*zeros;
720 A         when iqstk2 <> 0;
720 A            newqty1 = ((iqalc1 * itumq2) +
720 A                        iqalc2);
720 A            newqtyn=*zeros;
720 A        endsl;
720A   //Next, roll back up with breakdown structure
720 A        exsr zzupQty;
720 A        iqalc1 = newqtyn;
720 A        iqalc2 = newqty1;
720 A        iqalc3 = newqty2;
720 A      endif;
720A   // Then Hold Quantity
720 A      if iqhld2<>0 or iqhld3<>0;
720 A        select;
720 A         when iqhld3 <> 0;
720A    //First, take to lowest level quantity based on breakdowns
720 A            newqty2 = ((iqhld1 * itumq2 * itumq3) +
720 A                       (iqhld2 * itumq3) +
720 A                        iqhld3);
720 A            newqty1=*zeros;
720 A            newqtyn=*zeros;
720 A         when iqhld2 <> 0;
720 A            newqty1 = ((iqhld1 * itumq2) +
720 A                        iqhld2);
720 A            newqtyn=*zeros;
720 A        endsl;
720A   //Next, roll back up with breakdown structure
720 A        exsr zzupQty;
720 A        iqhld1 = newqtyn;
720 A        iqhld2 = newqty1;
720 A        iqhld3 = newqty2;
720 A      endif;
720A   // Lastly, Available Quantity
720 A      if iqavl2<>0 or iqavl3<>0;
720 A        select;
720 A         when iqavl3 <> 0;
720A    //First, take to lowest level quantity based on breakdowns
720 A            newqty2 = ((iqavl1 * itumq2 * itumq3) +
720 A                       (iqavl2 * itumq3) +
720 A                        iqavl3);
720 A            newqty1=*zeros;
720 A            newqtyn=*zeros;
720 A         when iqavl2 <> 0;
720 A            newqty1 = ((iqavl1 * itumq2) +
720 A                        iqavl2);
720 A            newqtyn=*zeros;
720 A        endsl;
720A   //Next, roll back up with breakdown structure
720 A        exsr zzupQty;
720 A        iqavl1 = newqtyn;
720 A        iqavl2 = newqty1;
720 A        iqavl3 = newqty2;
720 A      endif;
720 A /end-free
720 AC                   endsr
720 A
720 A *----------------------------------------------------------------
720 A *  ZZUPQTY       Up quantity
720 A *----------------------------------------------------------------
720 A
720 AC     zzupqty       begsr
720 A
720 A /free
720 A       // check for negative quantities
720 A       *in49=*off;
720 A       if newqtyn<0;
720 A          *in49=*on;
720 A          newqtyn = %abs(newqtyn);
720 A       endif;
720 A       if newqty1<0;
720 A          *in49=*on;
720 A          newqty1 = %abs(newqty1);
720 A       endif;
720 A       if newqty2<0;
720 A          *in49=*on;
720 A          newqty2 = %abs(newqty2);
720 A       endif;
720 A /end-free
720 A
720 AC                   dow       itumq3 > 0 and +
720 AC                               newqty2 >= itumq3
720 AC                   eval      newqty2 -= itumq3
720 AC                   eval      newqty1 += 1
720 AC                   enddo
720 A
720 AC                   dow       itumq2 > 0 and +
720 AC                               newqty1 >= itumq2
720 AC                   eval      newqty1 -= itumq2
720 Ac                   eval      newqtyn += 1
720 AC                   enddo
720 A
720 A /free
720 A                    if *in49;
720 A                       newqtyn = newqtyn * -1;
720 A                       newqty1 = newqty1 * -1;
720 A                       newqty2 = newqty2 * -1;
720 A                    endif;
720 A /end-free
720 A
720 AC                   endsr

730bA*----------------------------------------------------------------
730bA*  zzzdricop  Call DRICOP
730bA*----------------------------------------------------------------
730bA
730bAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*EQUIPT'
     C                   eval      $dridata = $equipt
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgmq         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C                   select

     C                   when      %error
     C                   eval      error = *on
     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   endsl

     C                   select
     C                   when      $dricommand = '*EQUIPT'
     C                   eval      $equipt = $dridata
     C                   endsl

     C     enddricop     endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Mfg Code/Vendor item#
** Descsp
Codigo de Mfc/#producto de vendedor
