500 A /copy *libl/qcopysrc,hspecs
720 MH DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *   Copyright (C) 2008 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PRTLBL       Print label on Zebra printer
     *  04 February, 2008
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    02/04/08  JCJ  5.20 P#00008
     *      - Created.
     *
520aA*    12/19/08  JCJ  5.20a
     *      - do not close printer file if printing license until the
     *        last label prints.
     *
530aA*    02/02/09  GJA  5.30a
     *      - ENH:  added parameters for off site storage usage
     *
530bA*    08/12/09  JCJ  5.30b
     *      - ENH:  added variable 315.
     *
610aA*    08/14/09  GJA  6.10a
     *      - ENH:  added parameters for produce labels
     *
610bA*    09/24/09  GJA  6.10b
     *      - ENH:  change so that a single spool file is created
     *              instead of individual spool files for each label
     *
530 A*    11/05/09  JCJ  5.30
     *      - ENH:  added variable 154 & 1.
     *
640a *    04/02/12  GJA  6.40a
     *      - ENH:  added client code
     *
640bA*    12/26/12  JCJ  6.40b
     *      - ENH:  add HRACK1 processing
     *
650aA*    04/17/13  LMC  6.50a
     *      - ENH:  add GS1-99 label printing parm
     *
650bA*    12/02/14  JCJ  6.50b
     *      - ENH:  add HRACK processing
     *
700aA*    07/28/15  JCJ  7.00a
     *      - ENH:  add HLEGEND processing
     *
700bA*    08/23/16  NLK  7.00b
     *      - ENH:  add CERT processing
     *
700cA*    11/15/16  MR   7.00c
     *      - ENH:  Add logic for OP5NUM for 5 digit check digit.
     *
720 A*    10/28/18  MLB  7.20
     *      - ENH:  Revised pgm to change hspec activation group to
     *        *CALLER from *NEW. Was causing pgm to generate individual
     *        splf's for each label instead of 1 splf for all labels.
     *
720aA*    10/18/18  LMC  7.20a
     *      - ENH:  add BOXLBLC/BOXLABE procsssing
720bA*    12/20/18  LMC  7.20b
     *      - ENH:  Do not seton lr for pcmd = '*BOXLBL '
     *      - Added *BOXEND To close.
730aA*    02/15/19  JCJ  7.30a
     *      - ENH:  add uom
730bA*    08/01/19  LMC  7.30b
     *      - ENH:  add GS1 Labeler for Canopy Receiving
730cA*    09/01/19  JCJ  7.30
     *      - ENH:  replaced variable 154 with variable 4.
740aA*    03/20/20  LMC  7.40a
     *      - ENH:  Adding var 325 for box labeler. This will be
     *        for clients who need a unique barcode on their product.
740bA*    04/22/20  JCJ  7.40b
     *      - ENH:  add HLEGEND1 processing  (1 Check Digit)
     *----------------------------------------------------------------
     *  Client Custom Revisions: MenuMaker
     *
GMMa *    04/02/12  GJA  GMMa
     *      - ENH:  create 5 digit check digit for rack label
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRa *    03/23/15  JCJ  FPRa
     *      - ENH:  Changed printer override.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SFGa *    10/07/16  NLK  SFGa
     *      - ENH:  John Dawson req to CENTER any TEXT they type
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D
     *
ADFa *    09/22/17  LMC  ADFa
     *      - ENH:  Client needs two copies of the off site storage
     *        license
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earls Organic Produce
     *
EOPa *    10/15/18  LMC  EOPa
     *      - ENH:  Set Variable 305 to their special 5 digit Julian
     *        date for produce labels. 2xx7x.
EOPb *    11/14/18  RTR  EOPb
     *      - Enh:  Set Variable 77 to their organic certifier code
     *        from ITEMEXT field IKMSC4.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (Very temporary usage)
     *
EOPaA*----------------------------------------------------------------
EOPaA*  Binding Directories
EOPaA*----------------------------------------------------------------
EOPaA
EOPaAHbnddir('BFCBND')
     *----------------------------------------------------------------
     *  File Specs
     *
     Flblfmth   if   e           k disk
     Flblfmtd   if   e           k disk
     Flblfmtv   if   e           k disk
     Flblfmtt   if   e           k disk
     Foptions   if   e           k disk
     Fzbrlogf   uf a e           k disk
     Fzbrlogs   uf a e           k disk
     Fpfmtpr    o    f  198        printer oflind(*in90)
     F                                     usropn
610aAFslotdgt   if   e           k disk
610aAFslot2     if   e           k disk
610aAFvslot1    if   e           k disk
EOPbAfitemext1  if   e           k disk
      *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a12             s              1    dim(12)
     D a40             s              1    dim(40)
     D a50             s              1    dim(50)
     D a58             s              1    dim(58)
     D a80             s              1    dim(80)
     D sti             s              1    dim(75)
     D sto             s              1    dim(198)
ADFaDD*ovrprt          s             80    DIM(1) CTDATA PERRCD(1)
FPRaDD*ovrprt          s             80    DIM(2) CTDATA PERRCD(1)
FPRaMD ovrprt          s             80    DIM(3) CTDATA PERRCD(1)

      *----------------------------------------------------------------
      *  Called programs
      *----------------------------------------------------------------
     D @CVTDT          C                   CONST('CVTDTE')
640aAD @getcl          C                   CONST('GETCLIENT')
     *----------------------------------------------------------------
     *  Customer id
     *
GMMaA /COPY QCOPYSRC,id#gmm
FPRaA /COPY QCOPYSRC,id#fpr
SFGaA /COPY QCOPYSRC,id#sgc
ADFaA /COPY QCOPYSRC,id#adf
EOPaA /COPY QCOPYSRC,id#eop
      *----------------------------------------------------------------
      *  Called program parameters
      *----------------------------------------------------------------
     D $CVTDT          DS
     D  $CVCMD                 1      8
     D  $CVPRG                 9     18
     D  $CVD6I                19     24
     D  $CVD8I                25     32
     D  $CVD6O                33     38  0
     D  $CVD8O                39     46  0
     D  $CVSTO                47     64
     D  $CVRTN                65     72
     D  $CVERM                73    132
     D  $CVMSG                73     76
     D  $CVDR1               133    140
     D  $CVVL1               141    145  0
     D  $CVDR2               146    153
     D  $CVVL2               154    158  0
     D  $CVDR3               159    166
     D  $CVVL3               167    171  0
     D  $CVDR4               172    179
     D  $CVVL4               180    184  0

     *----------------------------------------------------------------
     *  Program parameters
     *
     *
     *   Redefine key
     *
     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D curdate         s              8  0
     D @var            s              3  0
     D @len            s              3  0
     D ln              s              3  0
     D i               s              3  0
     D j               s              3  0
610aAD wrkdate         s              8
     D wrklcn#         s             30
SFGaAD wrktxt          s             60
     D $pitem          s             15
     D wkprtf          s             10
     D wkform          s             10
     D wkdev           s             10
GMMa D work5           s              5
EOPbAd work10          s             10a
530 AD temp2a          s              2
730aAD uom             s              2
     D vflag           s              1
     D logzebra        s               n
     D forever         s               n
     D GoodHit         s              1    Inz('0')
     D $pszon          s              6    Inz('XXXXXX')
SFGaAD $plen           s              3  0 inz(15)
EOPaAD curdatejul      s              7  0 inz(0)
EOPaAD curdatejulA     s              7

EOPaA*----------------------------------------------------------------
EOPaA*  Time variables
EOPaA*----------------------------------------------------------------
EOPaA
EOPaAD CurrStamploc    s               z
EOPaAD CurrStampsys    s               z
EOPaAD CurrStampuc     s               z
EOPaA
EOPaAd bfcoffset       s              3  0 inz(0)
EOPaA*----------------------------------------------------------------
EOPaA* Function prototypes.
EOPaA*----------------------------------------------------------------
EOPaA
EOPaA /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *
     D                 ds
     D  dssdte                 1      6
     D  dsmm                   1      2
     D  dsdd                   3      4
     D  dsyy                   5      6
     *
610aAD                 ds
610aAD  wkdesc                 1     30
610aAD  wkd1to9                1      9
610aAD  wkd10to18             10     18
610aAD  wkd1to7                1      7
610aAD  wkd8to16               8     16
     *
     D                 ds
     D  wksdte                 1      8
     D  wkmm                   1      2
     D  wksl1                  3      3
     D  wkdd                   4      5
     D  wksl2                  6      6
     D  wkyy                   7      8
      *----------------------------------------------------------------
     D opdata          DS
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opten2               117    117
     *
700cAD opdata2         DS
700cAD  op5num                55     55
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
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *
     *    Returned Parameters
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhsd           30
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    $plcn#           15
     C                   parm                    $plcn2           15
     C                   parm                    $pitm#           15
     C                   parm                    $pbrnd           10
     C                   parm                    $ppdesc          15
     C                   parm                    $pidesc          30
     C                   parm                    $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
530aAC                   parm                    $pexpd            8
530aAC                   parm                    $pindt            8
730bDC*                  parm                    $gs1fmt          23
730bMC                   parm                    $gs1fmt          48
730bMC                   parm                    $wgt              7
     *
     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------
     *
     * Do zbrlog initialization
     *
     C                   exsr      zzzInzZbrLog
     *
     C     keylfh        chain     lblfmth
     C                   if        not %found
     C                   eval      lfhslg = *blanks
     C                   endif
     * Open printer file
     C                   exsr      opnprt
     *
     * Check to see if this is only a test.
     *
     C                   if        $pcmd = '*TEST1  '
     C                   exsr      test1
     C                   goto      bottom
     C                   endif
     *
     C                   select
700bA* Print Certificate label of qty requested
700bAC                   when      $plfmt = 'CERT   '
700bAC                   eval      kyfmt = $plfmt
700bAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'RACKCHK'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
700aA* Print legend Rack label
700aAC                   when      $plfmt = 'HLEGEND'
700aAC                             and $pcmd = '*RACK   '
700aAC                   eval      kyfmt = $plfmt
700aAC                   exsr      fillb1
740bA* Print legend Rack label
740bAC                   when      $plfmt = 'HLEGEND1'
740bAC                             and $pcmd = '*RACK   '
740bAC                   eval      kyfmt = $plfmt
740bAC                   exsr      fillb1
650bA* Print Rack label
650bAC                   when      $plfmt = 'HRACK  '
650bAC                             and $pcmd = '*RACK   '
650bAC                   eval      kyfmt = $plfmt
650bAC                   exsr      fillb1
     * Print Rack Check digit
640bAC                   when      $plfmt = 'HRACK1 '
640bAC                             and $pcmd = '*RACK   '
640bAC                   eval      kyfmt = $plfmt
640bAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'HRACK5 '
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'HRACK5R'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'HRACK5L'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'HRACK5U'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'HRACK5D'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'URACK5 '
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'URACK5U'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'URACK5D'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'URACK5L'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack Check digit
GMMaAC                   when      $plfmt = 'URACK5R'
GMMaAC                             and $pcmd = '*RACK   '
GMMaAC                   eval      kyfmt = $plfmt
GMMaAC                   exsr      fillb1
     * Print Rack label
     C                   when      $plfmt = 'CBIRACK'
520aAC                             and $pcmd = '*RACK   '
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print Rack label
     C                   when      $plfmt = 'CBIRACKH'
520aAC                             and $pcmd = '*RACK   '
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print Check digit - large
     C                   when      $plfmt = 'CDLARGE1'
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print Check digit - small
     C                   when      $plfmt = 'CDSMALL1'
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print license label
     C                   when      $plfmt = 'LICENSE'
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print return license label
     C                   when      $plfmt = 'RETURNS'
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print text label
     C                   when      $plfmt = 'TEXT   '
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print trailer label
     C                   when      $plfmt = 'TRAILER'
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print item location label
     C                   when      $plfmt = 'ITEMLOC'
GMMaAC                             and $pcmd = '*LOCATE '
     C                   eval      kyfmt = $plfmt
     C                   exsr      fillb1
     * Print external storage label
530aAC                   when      $plfmt = 'STORAGE'
530aAC                   eval      kyfmt = $plfmt
530aAC                   exsr      fillb1
     * Print produce label
610aAC                   when      $plfmt = 'PRODUCE'
610bAC                             and $pcmd <> '*PRODEND'
610aAC                   eval      kyfmt = $plfmt
610aAC                   exsr      fillb1
     * Print gs1-99 label
650aAC                   when      $plfmt = 'GS1_99  '
650aAC                             and $pcmd = '*GS1    '
650aAC                   eval      kyfmt = $plfmt
650aAC                   exsr      fillb1
720aA* Print Box Labeler label
720aAC                   when      $plfmt = 'BOXLBLC'
720bAc                             and $pcmd <> '*BOXEND'
720aAc                             or $plfmt = 'BOXLBLE'
720bAc                             and $pcmd <> '*BOXEND'
720aAC                   eval      kyfmt = $plfmt
720aAC                   exsr      fillb1
730bA* Print GS1 Labeler canopy receiving
730bAC                   when      $plfmt = 'CANGS1'
730bAc                             and $pcmd <> '*CANEND'
730bAC                   eval      kyfmt = $plfmt
730bAC                   exsr      fillb1
     *
     C                   endsl
     C     bottom        tag
520aAC                   select
520aAC                   when      $pcmd <> '*LICENSE'
520aAC                             and $pcmd <> '*RETURN '
520aAC                             and $pcmd <> '*CHECKS '
520aAC                             and $pcmd <> '*CHECKR '
520aAC                             and $pcmd <> '*TEXT   '
520aAC                             and $pcmd <> '*TRAILER'
520aAC                             and $pcmd <> '*LOCATE '
520aAC                             and $pcmd <> '*RACK   '
610bAC                             and $pcmd <> '*PRODUCE'
610bAC                             and $pcmd <> '*GS1'
720bAC                             and $pcmd <> '*BOXLBL '
730bAC                             and $pcmd <> '*CANGS1 '
     C                   eval      *inlr = *on
     *
     * Close up shop and return home.
     *
     C                   if        opened = *on
     C                   close     pfmtpr
     C                   endif
     *
520aAC                   when      $pcmd =  '*LICENSE'
520aAC                             or $pcmd =  '*RETURN '
520aAC                             or $pcmd =  '*CHECKS '
520aAC                             or $pcmd =  '*CHECKR '
520aAC                             or $pcmd =  '*TEXT   '
520aAC                             or $pcmd =  '*TRAILER'
520aAC                             or $pcmd =  '*LOCATE '
520aAC                             or $pcmd =  '*RACK   '
610bAC                             or $pcmd =  '*PRODUCE'
650aAC                             or $pcmd =  '*GS1'
720bAC                             or $pcmd =  '*BOXLBL '
730bAC                             or $pcmd =  '*CANGS1 '
     C                   return
     C                   endsl
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
     *
     *   Define key for LBLFMTH
     *
     C     keylfh        klist
     C                   kfld                    $plset
     *
     *   Define key for LBLFMTD file.
     *
     C     *like         define    lfdfmt        kyfmt
     C     keylfd        klist
     C                   kfld                    $plset
     C                   kfld                    kyfmt
     *
     *   Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode
     *
     *  Define partial key for ZBRLOGF/S files.
      *
     C     keyzbr        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid            5
     *
     *   Define key for SLOTDGT
     *
610aAC     keycdgt       klist
610aAC                   kfld                    $pwhse
610aAC                   kfld                    $pwhdp
610aAC                   kfld                    woslot
     *
     *   Define key for ITEMEXT
     *
EOPbAC     keyitext      klist
EOPbAC                   kfld                    $pwhse
EOPbAC                   kfld                    $pitm#
     *
     *  Define key for LBLFMTV file.
     *
     C     *like         define    lfvnum        kyvnum
     C     keylfv        klist
     C                   kfld                    kyvnum
     * Convert today's date into century format.
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
700cA*
700cA*   Get check digit options
700cA*
700cA /Free
700cA     chain ($pwhse:'*CHKDGT') OPTIONS;
700cA     if %found;
700cA     eval opdata2 = opdata;
700cA     endif;
700cA /End-Free
     *
     *   Get system options
     *
     C                   z-add     0             opwhse
     C                   move      '*SYSTEM '    opcode
     C
     C     opkey         chain     options                            79
     C                   if        *in79 = *on
     C                   eval      opletd = 'Y'
     C                   endif

     C                   eval      wkprtf = 'PFMTPR    '
     C                   eval      wkform = $pform
     C                   eval      wkdev = $pdev
     C
     C                   Move      *On           Forevr            1
     C                   Move      *Off          opened            1
     C                   z-add     75            maxsti            2 0
     C                   z-add     198           maxsto            3 0
     *
     *  Get zebra logging flag.
     *
     C     *DTAARA       define    zbrlog        logzebra
     C                   in(e)     logzebra
     C                   if        %error
     C                   eval      logzebra = *off
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  OPNPRT   Open printer file.
     *
     C     opnprt        begsr
     *
     C                   if        opened <> *on

FPRa C                   select
FPRa C                   when      client = Foodpro
FPRa C                   movea     ovrprt(3)     a80
FPRa C                   movea     wkdev         a80(27)
FPRa C                   movea     wkform        a80(48)
ADFaA* A&D needs two copies of off site storage
ADFaAc                   when      client = AandDFoods
ADFaAc                             and $plfmt = 'STORAGE'
ADFaAC                   movea     ovrprt(2)     a80
FPRa C                   other
     C                   movea     ovrprt(1)     a80
     C                   movea     wkdev         a80(37)
     C                   movea     wkform        a80(58)
FPRa c                   endsl
     C                   movea     a80           qcmd
     C                   call      'QCMDEXC'
     C                   parm                    qcmd             80
     C                   parm      80            qlen             15 5
     * Open printer file
     C                   open      pfmtpr
     C                   eval      opened = *on
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  PRINT    Output string to printer.
     *
     C     print         begsr
     *
     C                   move      *off          prtflg            1
     C                   movea     sto           @outpt          198
     C                   except    #str
     C                   eval      sto = *blanks
     C                   z-add     0             op
     *
     C                   endsr

     *----------------------------------------------------------------
     *  FILLB1   Process script for single label format.
     *----------------------------------------------------------------
     C     fillb1        begsr
     *
     C                   eval      sto = *blanks
     C                   z-add     0             op                3 0
     *
     C                   eval      GoodHit = '0'
     *
     *   Initialize zebra logging fields.
     *
     C                   eval      zfwhse = $pwhse
     C                   eval      zfrte  = *blanks
     C                   eval      zfrtid = *blanks
     C                   eval      zfseq# = zfseq# + 1
     C                   eval      zfline = *zeros
     C                   eval      zflset = $plset
     C                   eval      zflfmt = kyfmt
     C                   eval      zftrn# = *zeros
     C                   eval      zflbl# = *zeros
     C                   eval      zfcomp = *blanks
     C                   eval      zftzon = *blanks
     C                   eval      zfgen  = *zeros
     C                   eval      zfszon = $pszon
     C                   eval      zftruk = *blanks
     C                   eval      zffnum = 0
     C                   eval      zffnam = ' '
     C                   eval      zffval = ' '
     C                   time                    zfts
      *
     C                   eval      zswhse = $pwhse
     C                   eval      zsrte  = *blanks
     C                   eval      zsrtid = *blanks
     C                   eval      zsseq# = zsseq# + 1
     C                   eval      zsline = *zeros
     C                   eval      zslset = $plset
     C                   eval      zslfmt = kyfmt
     C                   eval      zstrn# = *zeros
     C                   eval      zslbl# = *zeros
     C                   eval      zscomp = *blanks
     C                   eval      zstzon = *blanks
     C                   eval      zsgen  = *zeros
     C                   eval      zsszon = $pszon
     C                   eval      zstruk = *blanks
     C                   eval      zsparm = ' '
     C                   eval      zsts   = zfts
     *
     C     keylfd        setll     lblfmtd
     C     forevr        doweq     forevr
     C     keylfd        reade     lblfmtd
     C                   if        %eof(lblfmtd)
     C                   leave
     C                   endif
     *
     C                   eval      GoodHit = '1'
     *
     C                   if        lfdstr = *blanks
     C                   iter
     C                   endif
     *
     C                   movea     lfdstr        sti
     C                   z-add     0             ip                3 0
     *
     C                   eval      vflag = *off
     C                   eval      @var = *zeros
     C                   eval      @len = *zeros
     *
     * Loop through each character of label.
     *
     C     1             do        maxsti        ip                3 0
     *
     C                   select
     *
     *      Beginning of variable.
     *
     C                   when      sti(ip) = '<'
     C                             and  $pcmd <> '*TEST1  '
     C                   if        vflag = *on
     C                   exsr      fillb2
     C                   endif
     C                   eval      vflag = *on
     C                   eval      @var = *zeros
     C                   eval      @len = 1
     *
     *      End of variable.
     *
     C                   when      sti(ip) = '>'
     C                             and  vflag = *on
     C                   add       1             @len
     C                   exsr      fillb2
     C                   eval      vflag = *off
     *
     *      Within variable.
     *
     C                   when      vflag = *on
     C                   add       1             @len
     *
     *      Extract variable id number
     *
     C                   select
     C                   when      @len = 2
     C                             and  sti(ip) > '0'
     C                             and  sti(ip) <= '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   z-add     temp1n        @var
     C     @len          wheneq    3
     C     sti(ip)       andge     '0'
     C     sti(ip)       andle     '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   mult      10            @var
     C                   add       temp1n        @var
     C     @len          wheneq    4
     C     sti(ip)       andge     '0'
     C     sti(ip)       andle     '9'
     C                   move      sti(ip)       temp1a            1
     C                   move      temp1a        temp1n            1 0
     C                   mult      10            @var
     C                   add       temp1n        @var
     C                   endsl
     *
     *      Not within variable - Move character to output string
     *
     C                   other
     C                   add       1             op
     C                   move      sti(ip)       sto(op)
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif
     *
     C                   endsl
     *
     C                   enddo
     *
     *      Output variable if necessary.
     *
     C     vflag         ifeq      *on
     C                   exsr      fillb2
     C                   endif
     *
     C                   exsr      print
     *
     C                   enddo
     *
     *   Write ZBRLOGS record.
     *
     C                   if        logzebra and GoodHit = '1'
     C                   write(e)  zsrec
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  FILLB2   Added variable to output string.
     *----------------------------------------------------------------
     C     fillb2        begsr
     *
     *   Initialize zebra logging fields.
     *
     C                   eval      zffnum = @var
     C                   eval      zffnam = ' '
     C                   eval      zffval = ' '
     *
     C                   if        $pcmd = '*TEST2  '
     C                   eval      kyvnum = @var
     C     keylfv        chain     lblfmtv
     C                   if        not %found(lblfmtv)
     C                   goto      endfi2
     C                   endif
     C                   endif
     *
     C                   select
530 A*  Rack level
530 AC                   when      @var = 1
530 AC                   eval      zffnam = 'LEVL'
530 AC                   if        $pcmd = '*TEST2  '
530 AC                   movel     lfvdta        a50
530 AC                   else
530 AC                   move      *blanks       a50
530 AC                   eval      temp2a = $pchkd2
530 AC                   movea(p)  temp2a        a50
530 AC                   endif
530 AC                   exsr      filchr
720aA*
720aAC                   when      @var = 2
720aAC                   eval      zffnam = 'WHSE'
720aAC                   if        $pcmd = '*TEST2  '
720aAC                   movel     lfvdta        $cstr
720aAC                   call      'ADJUST'
720aAC                   parm      '*RIGHT  '    $ccmd             8
720aAC                   parm                    $cstr            30
720aAC                   move      $cstr         $nanum
720aAC                   else
720aAC                   move      $pwhse        $nanum
720aAC                   endif
720aAC                   eval      $nadec = 0
720aAC                   exsr      filnum
730cA*  slot location
730cAC                   when      @var = 4
730cAC                   eval      zffnam = 'LOC '
730cAC                   if        $pcmd = '*TEST2  '
730cAC                   movel     lfvdta        a50
730cAC                   else
730cAC                   move      *blanks       a50
730cAC                   movea(p)  $pchkd1       a50
730cAC                   endif
730cAC                   exsr      filchr
     *  Slot number
     C                   when      @var = 11
     C                   eval      zffnam = 'SLOT'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
610aAC                   if        kyfmt= 'PRODUCE'
610aAC                   eval      zffnam = 'PickSlot'
610aAC                   call      'GETPSLT'
610aAC                   parm                    $scmd             8
610aAC                   parm      $pwhse        $swhse            3 0
610aAC                   parm      $pitm#        $sitem           15
610aAC                   parm                    woslot           12
610aAC                   parm                    $saisl            3
610aAC                   parm                    $sloc             3 0
610aAC                   parm                    $srlvl            2 0
610aAC                   parm                    $shand            2
610aAC                   parm                    $srtn             8
610aAC     keycdgt       chain     slot2
610aAC                   if        %found(slot2)
610aAC                   if        slrsrv='V'
610aAC     keycdgt       chain     vslot1
610aAC                   if        %found(vslot1)
610aAC                   move      vspdis        woslot
610aAC                   endif
610aAC                   endif
610aAC                   endif
610aAC                   move      woslot        $pdisp
610aAC                   endif
     C                   movea     $pdisp        a50
     C     ' '           checkr    $pdisp        ln
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   endif
     C                   exsr      filchr
730aA* UOM
730aAC                   when      @var = 13
     C                   eval      zffnam = 'UM'
     C                   if        $pcmd = '*TEST2  '
     C                   movea     lfvdta        a50
     C                   else
     C                   eval      uom = $pchkd1
     C                   movea(p)  uom           a50
     C                   endif
     C                   exsr      filchr
     *  Pack desc
     C                   when      @var = 15
     C                   eval      zffnam = 'PACK'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $ppdesc       a50
     C                   endif
     C                   exsr      filchr
     *  Item desc
     C                   when      @var = 16
     C                   eval      zffnam = 'DESC'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pidesc       a50
     C                   endif
     C                   exsr      filchr
     *  item number
     C                   when      @var = 17
     C                   eval      zffnam = 'ITEM'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pitm#        a50
     C                   endif
610aAC                   eval      ln=%checkr(' ':$pitm#)
610aAC                   if        ln> *zeros
610aAC                   eval      @len = ln
610aAC                   endif
     C                   exsr      filchr
530aA*  entered date
530aAC                   when      @var = 20
530aAC                   eval      zffnam = 'Text6'
530aAC                   if        $pcmd = '*TEST2  '
530aAC                   movel     $pindt        a50
530aAC                   else
530aAC                   move      *blanks       a50
530aAC                   if        $pindt <> '00000000'
530aAC                   movea     $pindt        a50
530aAC                   endif
530aAC                   endif
530aAC                   exsr      filchr
EOPbA*  Organic Certifier
EOPbAc                   when      @var = 77
EOPbAc                   eval      zffnam = 'OrgCert'
EOPbAc                   if        $pcmd = '*TEST2  '
EOPbAc                   movel     lfvdta        a50
EOPbAc                   else
EOPbAc                   move      *blanks       a50
EOPbAc*
EOPbAc                   if        client = Earls
EOPbAc                                      and kyfmt= 'PRODUCE'
EOPbAc     keyitext      chain     itemext1
EOPbAc                   if        %found(itemext1)
EOPbAc                   eval      work10 = %subst(ikmsc4:1:10)
EOPbAc                   movea     work10        a50
EOPbAc                   endif
EOPbAc                   endif
EOPbAc                   endif
EOPbAc                   exsr      filchr
610aA* PO#
     C                   when      @var = 108
     C                   eval      zffnam = 'PO'
     C                   movea     $ptxt1        a50
     C                   exsr      filchr
730bA* weight
730bAC                   when      @var = 142
730bAC                   eval      zffnam = 'WEIGHT'
730bAC                   movea     $wgt          a50
730bAC                   exsr      filchr
530aA*  expiration date
530aAC                   when      @var = 151
530aAC                   eval      zffnam = 'Text7'
530aAC                   if        $pcmd = '*TEST2  '
530aAC                   movel     $pexpd        a50
530aAC                   else
530aAC                   move      *blanks       a50
530aAC                   if        $pexpd <> '00000000'
530aAC                   movea     $pexpd        a50
530aAC                   endif
530aAC                   endif
530aAC                   exsr      filchr
530 A*  slot location
530 AC                   when      @var = 154
530 AC                   eval      zffnam = 'LOC '
530 AC                   if        $pcmd = '*TEST2  '
530 AC                   movel     lfvdta        a50
530 AC                   else
530 AC                   move      *blanks       a50
530 AC                   movea(p)  $pchkd1       a50
530 AC                   endif
530 AC                   exsr      filchr
     * License number
     C                   when      @var = 173
     C                   eval      zffnam = 'License'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $plcn#        a50
     C                   endif
     C     ' '           checkr    $plcn#        ln
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
     * Trailer number
     C                   when      @var = 174
     C                   eval      zffnam = 'Trailer'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $ptrailr      a50
     C                   endif
     C     ' '           checkr    $ptrailr      ln
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
610aA* Current date
     C                   when      @var = 182
     C                   eval      zffnam = 'Date'
     C                   move      curdate       wrkdate
     C                   movea     wrkdate       a50
     C                   exsr      filchr
     *  Check digit1
     C                   when      @var = 305
     C                   eval      zffnam = 'Chkdgt'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     *
GMMaAC                   if        client = MenuMaker
700cAC                             or op5num = '5'
GMMaAC                   eval      work5 = $pchkd1 + %subst($pchkd3:2:2)
GMMaAC                   movea     work5         a50
GMMaAC                   endif
     *
610aAC                   if        kyfmt= 'PRODUCE'
610aAC     keycdgt       chain     slotdgt
610aAC                   if        %found(slotdgt)
610aAC                   move      scddgt        $pchkd1
610aAC                   endif
610aAC                   endif
GMMaAC                   if        client <> MenuMaker
700cAC                             or op5num <> '5'
     C                   movea     $pchkd1       a50
GMMaAC                   endif
EOPaAc                   if        client = Earls
EOPaAc                                      and kyfmt= 'PRODUCE'
EOPaAC                   callp     getmicrotime(currstampuc:currstampsys)
EOPaAc                   eval      curDateJul = %Int(%Char(%Date() :
EOPaAc                             *LongJul0))
EOPaAC                   eval      curdatejula = %char(curdatejul)
EOPaAC                   eval      work5 = '2' + %subst(curDateJula:5:2) +
EOPaAC                                     '7' + %subst(curDateJula:7:1)
EOPaAC                   movea     work5         a50
EOPaAc                   endif
     C                   endif
     C                   exsr      filchr
     *  Check digit2
     C                   when      @var = 306
     C                   eval      zffnam = 'Chkdgt'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     *
700cAC                   if        op5num = '5'
700cAC                   eval      work5 = $pchkd1 + %subst($pchkd3:2:2)
700cAC                   movea     work5         a50
700cAC     ' '           checkr    work5         ln
700cAc                   else
     C                   movea     $pchkd1       a50
     C     ' '           checkr    $pchkd1       ln
700cAC                   endif
700cA*
     C                   endif
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
     *  Trailer size
     C                   when      @var = 309
     C                   eval      zffnam = 'TrlrSz'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $psize        a50
     C                   endif
     C                   exsr      filchr
     *  item brand
     C                   when      @var = 310
     C                   eval      zffnam = 'Brand'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pbrnd        a50
     C                   endif
     C                   exsr      filchr
530bA* License number
530bAC                   when      @var = 315
530bAC                   eval      zffnam = 'License'
530bAC                   if        $pcmd = '*TEST2  '
530bAC                   movel     lfvdta        a50
530bAC                   else
530bAC                   exsr      zzloadlcn#
530bAC                   move      *blanks       a50
530bAC                   movea     wrklcn#       a50
530bAC                   endif
530bAC                   eval      ln = %checkr(' ':wrklcn#)
530bAC                   if        ln > *zeros
530bAC                   eval      @len = ln
530bAC                   endif
530bAC                   exsr      filchr
     *  license #2
     C                   when      @var = 318
     C                   eval      zffnam = 'License'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $plcn2        a50
     C                   endif
     C     ' '           checkr    $plcn2        ln
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
     * License number
     C                   when      @var = 330
     C                   eval      zffnam = 'License'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   exsr      zzloadlcn#
     C                   move      *blanks       a50
     C                   movea     wrklcn#       a50
     C                   endif
      **   '.'           checkr    wrklcn#       ln
     C                   eval      ln = %checkr(' ':wrklcn#)
     C                   if        ln > *zeros
     C                   eval      @len = ln
     C                   endif
     C                   exsr      filchr
     *  text line 1
     C                   when      @var = 331
     C                   eval      zffnam = 'Text1'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
SFGaAC                   move      *blanks       wrktxt

SFG  *  If Entering TEXT and If Springfield Grocery 'CENTER'
SFGaAC                   if        client = sgc
SFGaAC                   movel     $ptxt1        wrktxt
SFGaAC                   call      'CENTER'
SFGaAC                   parm                    wrktxt
SFGaAC                   parm      30            $plen
SFGaAC                   movel     wrktxt        $ptxt1
SFGaAC                   endif

     C                   movea     $ptxt1        a50
     C                   endif
     C                   exsr      filchr
     *  text line 2
     C                   when      @var = 332
     C                   eval      zffnam = 'Text2'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
SFGaAC                   move      *blanks       wrktxt

SFG  *  If Entering TEXT and If Springfield Grocery 'CENTER'
SFGaAC                   if        client = sgc
SFGaAC                   movel     $ptxt2        wrktxt
SFGaAC                   call      'CENTER'
SFGaAC                   parm                    wrktxt
SFGaAC                   parm      30            $plen
SFGaAC                   movel     wrktxt        $ptxt2
SFGaAC                   endif

     C                   movea     $ptxt2        a50
     C                   endif
     C                   exsr      filchr
     *  text line 3
     C                   when      @var = 333
     C                   eval      zffnam = 'Text3'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   move      *blanks       wrktxt

SFG  *  If Entering TEXT and If Springfield Grocery 'CENTER'
SFGaAC                   if        client = sgc
SFGaAC                   movel     $ptxt3        wrktxt
SFGaAC                   call      'CENTER'
SFGaAC                   parm                    wrktxt
SFGaAC                   parm      30            $plen
SFGaAC                   movel     wrktxt        $ptxt3
SFGaAC                   endif

     C                   movea     $ptxt3        a50
     C                   endif
     C                   exsr      filchr
     *  warehouse desc
     C                   when      @var = 334
     C                   eval      zffnam = 'Whdsc'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     lfvdta        a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pwhsd        a50
     C                   endif
     C                   exsr      filchr
     *  partial slot1
     C                   when      @var = 405
     C                   eval      zffnam = 'Pslot1'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     $pdispa       a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pdispa       a50
     C                   endif
     C                   exsr      filchr
610aA*  Split description 1-7
610aAC                   when      @var = 409
610aAC                   eval      wkdesc = $pidesc
610aAC                   eval      zffnam = 'Text7'
610aAC                   if        $pcmd = '*TEST2  '
610aAC                   movel     wkd1to9       a50
610aAC                   else
610aAC                   move      *blanks       a50
610aAC                   movea     wkd1to9       a50
610aAC                   endif
610aAC                   exsr      filchr
610aA*  Split description 8-16
610aAC                   when      @var = 410
610aAC                   eval      wkdesc = $pidesc
610aAC                   eval      zffnam = 'Text9'
610aAC                   if        $pcmd = '*TEST2  '
610aAC                   movel     wkd10to18     a50
610aAC                   else
610aAC                   move      *blanks       a50
610aAC                   movea     wkd10to18     a50
610aAC                   endif
610aAC                   exsr      filchr
     *  partial slot2
     C                   when      @var = 411
     C                   eval      zffnam = 'Pslot2'
     C                   if        $pcmd = '*TEST2  '
     C                   movel     $pdispb       a50
     C                   else
     C                   move      *blanks       a50
     C                   movea     $pdispb       a50
     C                   endif
     C                   exsr      filchr
650aA*  GS1-99
650aAC                   when      @var = 450
650aAC                   eval      zffnam = 'GS1  '
650aAC                   if        $pcmd = '*TEST2  '
650aAC                   movel     $gs1fmt       a50
650aAC                   else
650aAC                   move      *blanks       a50
650aAC                   if        $gs1fmt <> ' '
650aAC                   movea     $gs1fmt       a50
650aAC                   endif
650aAC                   endif
650aAC                   exsr      filchr
720aA*  GS1-99 48 pos
720aAC                   when      @var = 454
720aAC                   eval      zffnam = 'GS1  '
720aAC                   if        $pcmd = '*TEST2  '
720aAC                   movel     $gs1fmt       a50
720aAC                   else
720aAC                   move      *blanks       a50
720aAC                   if        $gs1fmt <> ' '
720aAC                   movea     $gs1fmt       a50
720aAC                   endif
720aAC                   endif
720aAC                   exsr      filchr
740aA*  GS1-99 48 use for client who need unique barcodes
740aAC                   when      @var = 325
740aAC                   eval      zffnam = 'GS1  '
740aAC                   if        $pcmd = '*TEST2  '
740aAC                   movel     $gs1fmt       a50
740aAC                   else
740aAC                   move      *blanks       a50
740aAC                   if        $gs1fmt <> ' '
740aAC                   movea     $gs1fmt       a50
740aAC                   endif
740aAC                   endif
740aAC                   exsr      filchr
     *  Certificate Number
700bAC                   when      @var = 458
700bAC                   eval      zffnam = 'CERT  '
700bAC                   if        $pcmd = '*TEST2  '
700bAC                   movel     $ptrailr      a50
700bAC                   else
700bAC                   move      *blanks       a50
700bAC                   movea     $ptrailr      a50
700bAC                   endif
700bAC                   exsr      filchr
     *
     C                   endsl
     *
     *   Write ZBRLOGF record.
     *
     C                   if        logzebra
     C                   write(e)  zfrec
     C                   endif
     *
     C     endfi2        endsr
     *
     *----------------------------------------------------------------
     *  FILCHR   Fill character variable.
     *----------------------------------------------------------------
     C     filchr        begsr
     *
     *  Move character string into output string.
     *
     C                   z-add     @len          lc                3 0
     C     1             do        lc            y                 3 0
700cAc                   if        @var = 305
700cAc                             or @var = 306
700cAc                   if        a50(y) <> ''
     C                   add       1             op
     C                   move      a50(y)        sto(op)
700cAc                   endif
700cAc                   else
700cAC                   add       1             op
700cAC                   move      a50(y)        sto(op)
700cAc                   endif
     C     op            ifeq      maxsto
     C                   exsr      print
     C                   endif
     C                   enddo
     *
     *   Move value into ZBRLOGF log field
     *
     C                   if        logzebra
     C                   movea     a50           temp50a          50
     C                   eval      zffval = %trim(temp50a)
     C                   endif
      *
      *   Add field to ZBRLOGS log field.
      *
     C                   if        logzebra
     C                   eval      zsparm = %trim(zsparm)
     C                                    + ' <'
     C                                    + %trim(%editc(@var:'Z'))
     C                                    + ':'
     C                                    + %trim(zffnam)
     C                                    + '>'
     C                                    + %trim(zffval)
     C                   endif
     *
     C                   endsr

     *
     *----------------------------------------------------------------
     *  FILLNUM  Fill numeric variable.
     *----------------------------------------------------------------
     C     filnum        begsr
     *
     *  Format number.
     *
     C                   exsr      editna
     *
     *  Find first character in array string.
     *
     C                   z-add     1             fc                3 0
     C     fc            doueq     13
     C     a12(fc)       ifne      *blanks
     C                   leave
     C                   endif
     C                   add       1             fc
     C                   enddo
     *
     *  Move formatted number into output string.
     *
     C                   move      *blanks       a50
     C                   z-add     @len          y
     C                   z-add     12            x                 3 0
     C     x             doueq     0
     C     y             oreq      0
     C                   move      a12(x)        a50(y)
     C                   sub       1             x
     C                   sub       1             y
     C                   enddo
     C                   exsr      filchr
     *
     C                   endsr

     *----------------------------------------------------------------
     *  EDITNA   Edit nemeric to alpha.
     *----------------------------------------------------------------

     C     editna        begsr

     C                   move      *blanks       a40
     C     $nanum        cabeq     0             ena01
     C                   move      *blanks       temp40           40
     C                   movel     $nanum        temp40
     C                   movea     temp40        a40
     C     12            sub       $nadec        dpos              2 0
     C     dpos          add       2             tenpos            2 0
     C                   z-add     12            ax                2 0
     C                   z-add     40            ay                2 0
     C     lna01         tag
     C                   sub       1             ax
     C     ax            cabeq     0             ena01
     C     ax            iflt      tenpos
     C                   move      a40(ax)       a40(ay)
     C                   sub       1             ay
     C                   else
     C     a40(ax)       ifgt      '0'
     C                   move      a40(ax)       a40(ay)
     C                   sub       1             ay
     C                   z-add     99            tenpos
     C                   endif
     C                   endif
     C     ax            ifeq      dpos
     C                   move      '.'           a40(ay)
     C                   sub       1             ay
     C                   endif
     C                   goto      lna01
     C     ena01         tag
     C                   z-add     28            ax
     C     lna02         tag
     C                   add       1             ax
     C     ax            comp      41                                     50
     C   50              goto      ena02
     C     a40(ax)       comp      '0'                                    50
     C  N50a40(ax)       comp      ' '                                    50
     C  N50              goto      ena02
     C                   move      ' '           a40(ax)
     C                   goto      lna02
     C     ena02         tag
     *
     C                   movea     a40(29)       a12
     C     ax            ifgt      40
     C                   z-add     12            $nafp             2 0
     C     ax            sub       28            $nafp
     C                   endif
     *
     C                   z-add     0             $nanum           11 0
     C                   z-add     0             $nadec            2 0
     C                   endsr

     *
     *----------------------------------------------------------------
     *
     *  zzloadlcn# - Space out license number
     *
     C     zzloadlcn#    begsr

     C                   eval      j = 1
     C                   do        15            i

     C                   if        %subst($plcn#:i:1) = ' '
     C                   leave
     C                   endif

     C                   eval      wrklcn# = %replace((%subst($plcn#:i:1
     C                             )):wrklcn#:j:1)

     C                   eval      j = j + 2

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  TEST1    Test 1 - Print label definitions
     *
     C     test1         begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINIT   Initialize fields.
     *
     C     zzinit        begsr
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzzInzZbrLog  Initialization for zbrlog.
     *
     C     zzzInzZbrLog  begsr

     *  Get out if not logging.

     C     logzebra      cabeq     *off          endInzZbrLog

     *  Delete existing zbrlogf records for route/szone

     C     keyzbr        setll     zbrlogf
     C                   dow       forever = forever
     C     keyzbr        reade(e)  zbrlogf
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zfszon <> $pszon
     C                   iter
     C                   endif
     C                   delete    zfrec
     C                   enddo

     *  Delete existing zbrlogs records for route/szone

     C     keyzbr        setll     zbrlogs
     C                   dow       forever = forever
     C     keyzbr        reade(e)  zbrlogs
     C                   if        %eof
     C                   leave
     C                   endif
     C                   if        zsszon <> $pszon
     C                   iter
     C                   endif
     C                   delete    zsrec
     C                   enddo

     *  Initialize sequence number.

     C                   eval      zfseq# = 0

     C     endInzZbrLog  endsr
     O*----------------------------------------------------------------
     O*  Output Specs
     O*
     Opfmtpr    e            #str           1
     O                       @outpt             198
     O*----------------------------------------------------------------
     O*
     O*  Compile time tables
     O*
**   OVRPRTF statment
OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
OVRPRTF FILE(PFMTPR) OUTQ(*DEV) DEV(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX) COPIES(2)
OVRPRTF FILE(PFMTPR) OUTQ(XXXXXXXXXX) FORMTYPE(XXXXXXXXXX)
