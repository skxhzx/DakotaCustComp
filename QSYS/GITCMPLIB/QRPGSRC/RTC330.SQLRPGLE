      /copy *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*CALLER)
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2019 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  RTC330   RF  RTC Inventory entry
     *  26 March, 2019
     *  Lynn McMahon
     *
     *  Revisions:
730  *    03/26/19  LMC  7.30
     *      - Created.
730a *    10/10/19  LMC  7.30a
     *      - Send command UPDATE to UPDRTCHSTH from screen14 on all
     *        types.
730b *    10/28/19  LMC  7.30b
     *      - Fix - when user tries to count a closed scope. Leavesr
     *        after loading the error.
     *
740a *    05/01/20  LMC  7.40a
     *      - Fix - Need to execute clr$license & clr$licinfo if the
     *        license is invalid. The update process uses those fields
     *        and if the  screen field is blanked out, those fields
     *        will need to be cleared also.
     *      - Enh - Add additional parms to calls to CVTBAR
     *      - Process workrtcs by seq# which is based on the sort seq
     *        from the options.
740b *    09/03/20  LMC  7.40b
     *      - Fix - Display error if virtual slot is keyed for first
     *        slot.  Must start count on base slot.
740c *    09/24/20  LMC  7.40c
     *      - Enh - If user takes F12 on screen5 need to close the
     *        count, the same way we do on f12 from screen8
740d *    09/25/20  LMC  7.40d
     *      - Enh - If scope was created without page options. We
     *        don't want to display page screen. The user would not
     *        know that we use 99999 as a default when page# are not
     *        used based on the options.
750a *    03/08/21  LMC  7.50a
     *      - Fix - Change to use correct field for Add item to slot
     *        for scope count.
750b *    10/19/21  LMC  7.50b
     *      - Fix - If there is no item found in the slot, do not
     *        goto screen 11 asking for upc scan or license scan.
750c *    10/20/21  LMC  7.50c
     *      - Enh:  Adding exception logging.
     *        Adding F9 to skip upc verification on screen11.
     *        Removed the ability to enter x in the uci/upc field,
     *        user will now use f9 so we can log the exception.
750d *    12/27/21  LMC  7.50d
     *      - Enh:  When counting scope with no pages, page 99999 is
     *        assigned, once all the slots in the scope have been
     *        counted, display screen3 for next scope.
765aA*    08/25/22  Jothi 7.65a
     *      - Enh: For any edits that have the RCV,STG,OSS,XDK
     *      - USR,RTN,RPA aisle as part of an edit ,add the check
     *        for SLDESG ='BFC'
760a *    11/08/22  RH   7.60a
     *      - Enh:  Capture exp/mfg date when add item to slot and
     *        don't scan license to add.
     *        Change screen to RTC33002
     *----------------------------------------------------------------
     *  Custom
PAKaA*    08/23/06  RH    PAKa
     *      - Enh:Do not capture CW.
JORaA*    06/07/07  RH    JORa
     *      - Fix:Reverse 500e call to GETUSER for spanish until 5.00 update
     *        is in place.
SGCaA*    12/01/09  RH    SGCa
     *      - Enh:Default screen count to slot count.
EIaaA*    Custom - European Imports
EIaaA*    09/12/11  RH    EIa
     *      - Enh:Default screen count to slot count.
CDIaA *    Custom - CDI
      *    04/17/08  RH    CDIa
      *      - Enh: Add mfg item#, can replace pack desc on screen 3
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    01/16/15  LMC  PFCa
     *      -  Enh: Add the '.' to the end of the next virtual slot
     *         to have counts entered.
PFCb *    02/17/22  LMC  PFCb
     *      -  disable PFCa. This don't not work in RTC, like it would
     *         in legacy cycle counts.
     *
     *----------------------------------------------------------------
KFSaA*    Custom - Kelly's Foodservice
KFSaA*    09/12/18  RH    KFSa
     *      - Enh:Add to CDIb, don't exclude slots with pending qty
     *        per Kelly's request 9-7-18 for full system Dakota
     *
     *----------------------------------------------------------------
CPJaA*    Custom - CPJ Caribbean Producers Jamaica
CPJaA*    05/27/21  LMC   CPJa
     *      - Enh: Allow the client to violate our number of pick
     *        slot edit while adding an item to a slot.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  31        Pounds/Kilograms Toggle
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------

     Hbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
750cDF*RTC330fm  cf   e             workstn
760aDF*RTC33001  cf   e             workstn
760aMFRTC33002  cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fitemmsc   if   e           k disk
     Foptions   if   e           k disk
     Funmesr    if   e           k disk
     Flabel90   if a e           k disk
     Flicense   if a e           k disk
     f*ucicw
     Fupc       if a e           k disk
     Fupc2      if   e           k disk    rename(uprec:uprec2)
     Frtchstd   uf a e           k disk
     Frtchstl   o  a e           k disk
     Fkititem   if   e           k disk
     FworkUsr3  uf a e           k disk
     Flicactive1if   e           k disk
     Flicactive9if   e           k disk    rename(larec:larec9)
     Fpiritem4  if   e           k disk
     Fslot3     if   e           k disk
     Fworkrtci  uf a e           k disk
     Fworkrtcs  uf a e           k disk
750cAFrtcexcp   if a e           k disk
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti
      /copy qcopysrc,p.getclien
      /copy qcopysrc,p.updrtch
760aA /copy qcopysrc,p.caldktex
     *  Prototype to pause execution
     D sleep           PR            10I 0 extproc('sleep')
     D   seconds                     10U 0 value
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     D*
      /COPY QCOPYSRC,ID#PACKERS
      /COPY QCOPYSRC,ID#SGC
      /COPY QCOPYSRC,ID#GLAZIER
      /COPY QCOPYSRC,ID#EI
      /COPY QCOPYSRC,ID#CDI
      /COPY QCOPYSRC,ID#PFC
      /COPY QCOPYSRC,ID#KFS
FPRaA /copy qcopysrC,id#fpr
      /copy qcopysrc,p.getimuom
      /copy qcopysrc,id#icb
CPJaA /copy qcopysrC,id#cpj
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
     D desc            s             20    dim(11) ctdata perrcd(1)
     D descsp          s             20    dim(11) ctdata perrcd(1)
     D prdslt          S              3    dim(100)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------
      /copy qcopysrc,p.cvtbar
     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#BARCODE
      /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#UCIINFO
      /COPY *libl/qcopysrc,C#LICENSE
      /COPY *libl/qcopysrc,C#LICINFO
     D saveVer#        s                   like($slver#)
     D bfr$Slot        ds                  likeds($slot)
     D bfr$Slot2       ds                  likeds($slot2)

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  files
     *----------------------------------------------------------------

     D rtchrec       E Ds                  Extname(rtchsth)
     D wksrec1       E Ds                  Extname(workrtcs)
     D RTCSREC       E Ds                  Extname(RTCSCPD)
     *----------------------------------------------------------------
     *  Tracking variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#trackvar

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)

     *----------------------------------------------------------------
     *  Called program parameters
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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $puser                39     48
     D  $SlotLcns             49     63
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
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
     D  $luser                19     28
     *
     D  $ldsp1                27     38
     D  $lusr1                54     63
     D  $litmmfg              37     51
     *
     D  $lteam                27     36
     D  $lcupc                37     37
     D  $lcadd                38     38
     D  $lccwt                39     39
     *
     D  $lcode                19     20
     *
     D  $lwhseTfr             19     21  0
     D  $lwhdpTfr             22     26
     D  $ldispTfr             27     38
     D  $ldispTfrTo           39     50
     D  $luomTfr              51     51
     D  $llcnsTfr             54     68
     D  $lmfg                 22     36
     *
     D  $lupc                 22     41
     D  $litm1                42     56
     D* $litm1                39     53
     *
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
     *                                       1   8 $CVDOP
     *                                       9  140$CVDD6
     *                                      15  220$CVDD8

     *----------------------------------------------------------------
     *  LT210 parameters
     *----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
     D  $titem         s             15
     D  $titemdsc      s             65
     D  $twhdp         s              5
     D  $tslot         s             12
     D  $tslotpos      s              3  0
     D  $templ#        s              5  0
     D  $ttran#        s              7  0
     D  $tlic#         s             15
     D  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
     D  $tnorm1        s              5  0
     D  $tnorm2        s              3  0
     D  $tnorm3        s              3  0
     D  $tpartial      s               n
     D  $tpulled       s              3  0
     D  $tinslot       s              1
     D  $tsamepos      s              1
     D  $tdiffpos      s              1
     D  $tpsplit       s              1
     D  $tinlic#       s             15
     D  $toutlic#      s             15
     D  $tnexttask     s             10
     D  $treturn       s              8
     D  $terrmsg       s             60
     D  $tmsgid        s              4

     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     *
     D  erdisp                 1     12
     D  erdate                 1      6  0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgsp          c                   const('PIRMSGFSP ')
     D #msgfc          c                   const('QCPFMSG   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /Copy qcopysrc,c#pgminfds
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

     D #toititem       s                   like($ititem)
     D #toittype       s                   like($ittype)
     D #toitdesc       s                   like($itdesc)
     D #toitpdsc       s                   like($itpdsc)
     D #toithead       s             70
     D #toitwhdp       s                   like($itwhdp)
     D #toitstyp       s                   like($itstyp)
     D #toitdesg       s                   like($itdesg)
     D #toitum1        s                   like($itum1)
     D #toitflg1       s                   like($itflg1)
     D #toitum2        s                   like($itum2)
     D #toitumq2       s                   like($itumq2)
     D #toitflg2       s                   like($itflg2)
     D #toitum3        s                   like($itum3)
     D #toitumq3       s                   like($itumq3)
     D #toitnrpk       s                   like($imnrpk)
     D #toitflgd       s                   like($itflgd)
760aAD #toitmflg       s                   like($immflg)
     D #toitcube       s                   like($itcube)
     D #toitswgt       s                   like($itswgt)
     D #toitcwgt       s                   like($itcwgt)
     D #toitvit#       s                   like($itvit#)
     D #toitmitem      s                   like($itmitem)
     D #toitsdef       s                   like($idsdef)
     D #toittie        s                   like($idtie)
     D #toithigh       s                   like($idhigh)

     D #tossbititem    s                   like($ititem)
     D #tossbittype    s                   like($ittype)
     D #tossbitdesc    s                   like($itdesc)
     D #tossbitpdsc    s                   like($itpdsc)
     D #tossbitwhdp    s                   like($itwhdp)
     D #tossbitstyp    s                   like($itstyp)
     D #tossbitdesg    s                   like($itdesg)
     D #tossbitum1     s                   like($itum1)
     D #tossbitum2     s                   like($itum2)
     D #tossbitumq2    s                   like($itumq2)
     D #tossbitum3     s                   like($itum3)
     D #tossbitumq3    s                   like($itumq3)
     D #tossbitvit#    s                   like($itvit#)

     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D addcount        s              5  0
     D additem         s               n
     D baseDisp        s                   like($sldisp)
760aAD calcExpDate     s              8  0
     D cancel          s               n
     D chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D e$bpu           s              1
     D e$lng           s              2
     D enter           s              5  0
     D error           s               n
     D excode          s              1
     D exwgt           s              9  2
     D exwg2           s              7  2
     D firstSlotEnt    s                   like($sldisp)
     D forevr          s               n
     D forever         s               n
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D hvskp           s              1
     D ihrng           s              9  2
     D ihvar           s              9  2
     D ilrng           s              9  2
     D ilvar           s              9  2
     D initSC10        s               n
     D inprocess       s               n
760aAD itemIsMfg       s               n
760aAD itemIsExp       s               n
     D kylic           s                   like(lilcns)
     D*kyuci           s                   like(w6uci)
     D kyupc           s                   like(upupc)
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nomore          s               n
     D noupc           s              1
     D nsctr           s              1  0
     D nxtscr          s              3
     D ovrrid          s              1
     D pass            s              1  0
     D pdisp           s                   like(w8disp)
     D prg1c           s              4  3
     D prg2c           s              4  3
     D pwhdp           s                   like(w1dept)
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D scode           s              2
     D slchk           s              1
     D ssbflg          s               n
     D save$slphy1     s                   like($slphy1)
     D save$slphy2     s                   like($slphy2)
     D save$slphy3     s                   like($slphy3)
     D svdisp          s                   like($sldisp)
     D svpick          s                   like(slpick)
     D svstat          s                   like(slstat)
     D svstyp          s                   like(slstyp)
     D swgt2           s              7  2
     D teamsused       s              1
     D temp2A          s              2
     D touched         s              5  0
     D touchedList     s           2106
     D trackLevel      s              1
     D upcctr          s              3  0
     D ucilength       s              3  0
     D mfgctr          s              3  0
     D useSlot         s               n
     D warn            s              1
     D wkcode          s              8
     D wkwhse          s                   like($lwhse)
     D woidte          s              8  0
     D woqt01          s              5  0
     D woqt02          s              3  0
     D woqt03          s              3  0
     D woupc           s                   like(upupc)
     D wtchk           s              1
     D w10work         s             15
     D zmsflag         s               n
     D KiloLbs         s              1
     D BegKiloLbs      s              1
     D kgs2lbs         c                   2.20462262
     D CnvWgt          s              9  2
     D IMUOM           s              3
     D  $ppartime      s               Z
     D  uciwgttot      s              9  2
     D  w1cwtr         s              9  2
     D today           s              8  0

     D #frombasesldsp  s                   like($sldisp)
     D #fromslwhdp     s                   like($slwhdp)
     D #fromslstyp     s                   like($slstyp)
     D #fromsldisp     s                   like($sldisp)
     D #fromslaisl     s                   like($slaisl)
     D #fromslloc      s                   like($slloc)
     D #fromslpseq     s                   like($slpseq)
     D #fromslrlvl     s                   like($slrlvl)
     D #fromslhand     s                   like($slhand)
     D #fromslstat     s                   like($slstat)
     D #fromslrsrv     s                   like($slrsrv)
     D #fromslentd     s                   like($slentd)
     D #fromslexpd     s                   like($slexpd)
     D #fromslslfd     s                   like($slslfd)
     D #fromslactv     s                   like($slactv)
     D #fromslbld      s                   like($slbld)
     D #fromslpick     s                   like($slpick)
     D #fromslitem     s                   like($slitem)
     D #fromslsdef     s                   like($slsdef)
     D*#fromslpos      s                   like($sdpos)
     D #fromslvirt     s                   like($sfvirt)
     D #fromslstk1     s                   like($slstk1)
     D #fromslstk2     s                   like($slstk2)
     D #fromslstk3     s                   like($slstk3)
     D #fromslalc1     s                   like($slalc1)
     D #fromslalc2     s                   like($slalc2)
     D #fromslalc3     s                   like($slalc3)
     D #fromsltfr1     s                   like($sltfr1)
     D #fromsltfr2     s                   like($sltfr2)
     D #fromsltfr3     s                   like($sltfr3)
     D #fromslpck1     s                   like($slpck1)
     D #fromslpck2     s                   like($slpck2)
     D #fromslpck3     s                   like($slpck3)
     D #fromslrcv1     s                   like($slrcv1)
     D #fromslrcv2     s                   like($slrcv2)
     D #fromslrcv3     s                   like($slrcv3)
     D #fromslphy1     s                   like($slphy1)
     D #fromslphy2     s                   like($slphy2)
     D #fromslphy3     s                   like($slphy3)
     D #fromslavl1     s                   like($slavl1)
     D #fromslavl2     s                   like($slavl2)
     D #fromslavl3     s                   like($slavl3)
     D #fromToLcns     s                   like($saToLcns)
     D #fromToPos      s                   like($saToPos)
     D #fromOLcns      s                   like($saOLcns)

     d wkaisl          s              3
     D prdtfr          s               n
     d hldprdDisp      s             12
     D odrslot         s             12
     D sltc            s              3  0
     D  $tpartime      s               Z
     D  $tUCI          s            100
     d #TOSLAISL       s                   like($slaisl)
     d #TOSLHAND       s                   like($slhand)
     d #TOSLLOC        s                   like($slloc)
     d #TOSLRLVL       s                   like($slrlvl)
     d #TOSLSTAT       s                   like($slstat)
     d #TOSLPICK       s                   like($slpick)
     D tocwgt          s                   like($itcwgt)
     D todisp          s             12
     D toitem          s             15
     D*toqty1          s                   like($cqty1)
     D towhdp          s              5
     D  $ttoslot       s             12
     D  wkType         s              3    INZ('TFR')
     D rtnToOrig       s               n
     D skipLT210       s               n
     D Ypickslot       s               n
     D curlic#         s                   like($tlic#)
     D partial         s               n
     D tfroutflag      s               n
     D tfr2usrDate     s              8  0
     D tfr2usrTime     s              6  0
     D curtrn#         s              7  0
     D fmcwgt          s                   like($itcwgt)
     D fmdisp          s                   like($sldisp)
     D fmitem          s             15
     D fmwhdp          s              5
     D newtrn          s              4
     D exwgfm          s              9  2
     D svtrn1          s              7  0
     D svtrn2          s              7  0
     D svtrn3          s              7  0
     D WTQTY1          S                   like($litorqty1)
     D WTQTY2          S                   like($litorqty2)
     D WTQTY3          S                   like($litorqty3)
     D W1code          S                   like($sacode)
     d licwgt          s              7  2
     d totslotwgt      s              7  2
     D  uciqty1        s              5  0
     D  uciqty2        s              5  0
     D  uciqty3        s              5  0
     D  uciwgt         s              9  2
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D nbrpck          s              5  0
     D  pwhse          s              3p 0
     D  pcmd           s             10
     D  pid            s              7p 0
     D  pcnttype       s              2p 0
     D  workingId      s              7p 0
740aAD  alphadate      s              8
740aAD  yr             s              4  0
740aAD  mn             s              2  0
740aAD  da             s              2  0
760aAd perrmsg         s             99
760aAd psessid         s             40
760aAd pdpcombo        s             20
760aAd calpwhse        s              3  0
760aAd calpentdate     s              8  0
760aAd calpdktexpd     s              8  0
760aAd BuildItem       s             15
      *----------------------------------------------------------------
     I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
     *
     * Data structure
     *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
     D  optend               117    117
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  *RTC     -  Realtime Inventory Count Options
     *
     * Fields
     *
     *    OPASGNP -  Assign Slots to Page Id
     *    OPPGLVL -  Assign Page Id for each Level Break
     *    OPCADJ  -  Create Adjustment for zero Quantity
     *    OPMSLT  -  Max Slots per Page when assigning Page Id's
     *    OPSRT1  -  Sort pages by Dept, Aisle, Side Descending, Level, Location, Hand
     *    OPSRT2  -  Sort pages by Dept, Aisle, Side Descending, Location, Level, Hand
     *    OPSRT3  -  Sort pages by Dept, Slot (F or P),Aisle,Side Descending,Location,Level,Hand
     *    OPSRT4  -  Sort pages by Dept, Slot (F or P), Aisle, Side Descending, Location, Hand
     *    OPCUPC  -  Scan UPC to confirm item counted
     *    OPCADD  -  RF add item in slot
     *    OPCSCN  -  RF Scan UPC or License to add item
     *    OPCKIN  -  RF key in item to add item
     *    OPCCWT  -  Capture catch weight
     *    OPDQTY  -  Show current inventory
     *    OPCCWV  -  Catch weight variance check
     *
     * Data structure
     *
     D opdat1          ds
     D  opasgnp                1      1
     D  oppglvl                2      2
     D  opcadj                 3      3
     d  opmslt                 4      6  0
     D  opsrt1                 7      7
     D  opsrt2                 8      8
     D  opsrt3                 9      9
     D  opsrt4                10     10
     d  opcupc                11     11
     d  opcadd                12     12
     d  opcscn                13     13
     d  opckin                14     14
     d  opccwt                15     15
     d  opdqty                16     16
     d  opccwv                17     17
     D  op1end               117    117
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
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
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
     C     nxtscr        caseq     '09 '         sc9
     C     nxtscr        caseq     '10 '         sc10
     C     nxtscr        caseq     '11 '         sc11
     C     nxtscr        caseq     '12 '         sc12
     C     nxtscr        caseq     '13 '         sc13
     C     nxtscr        caseq     '14 '         sc14
     C     nxtscr        caseq     '15 '         sc15
     C     nxtscr        caseq     '16 '         sc16
     C     nxtscr        caseq     '17 '         sc17
     C     nxtscr        caseq     '18 '         sc18
     C     nxtscr        caseq     '19 '         sc19
     C     nxtscr        caseq     '20 '         sc20
760aAC     nxtscr        caseq     '21 '         sc21
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   exsr      zzzdriclose
     C                   eval      *inlr = *on
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
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn1sp                              50
     C*                  other
     C                   exfmt     screen1                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '02 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn2sp                              50
     C*                  other
     C                   exfmt     screen2                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '03 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn3sp                              50
     C*                  other
     C                   exfmt     screen3                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '04 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn4sp                              50
     C*                  other
740dAc                   if        w4page <> 99999
740dAc                             or error
     C                   exfmt     screen4                              50
740dAc                   endif
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '05 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn5sp                              50
     C*                  other
     C                   exfmt     screen5                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '06 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn6sp                              50
     C*                  other
     C                   exfmt     screen6                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '07 '
     C*                  select
     C*                  when      e$lng = 'SP'
     C*                  exfmt     scrn7sp                              50
     C*                  other
     C                   exfmt     screen7                              50
     C*                  endsl
     C                   endif
     C                   if        nxtscr = '08 '
     C                   exfmt     screen8                              50
     C                   endif
     C                   if        nxtscr = '09 '
     C                   exfmt     screen9                              50
     C                   endif
     C                   if        nxtscr = '10 '
     C                   exfmt     screen10                             50
     C                   endif
     C                   if        nxtscr = '11 '
     C                   exfmt     screen11                             50
     C                   endif
     C                   if        nxtscr = '12 '
     C                   exfmt     screen12                             50
     C                   endif
     C                   if        nxtscr = '13 '
     C                   exfmt     screen13                             50
     C                   endif
     C                   if        nxtscr = '14 '
     C                   exfmt     screen14                             50
     C                   endif
     C                   if        nxtscr = '15 '
     C                   exfmt     screen15                             50
     C                   endif
     C                   if        nxtscr = '16 '
     C                   exfmt     screen16                             50
     C                   endif
     C                   if        nxtscr = '17 '
     C                   exfmt     screen17                             50
     C                   endif
     C                   if        nxtscr = '18 '
     C                   exfmt     screen18                             50
     C                   endif
     C                   if        nxtscr = '19 '
     C                   exfmt     screen19                             50
     C                   endif
     C                   if        nxtscr = '20 '
     C                   exfmt     screen20                             50
     C                   endif
760aAC                   if        nxtscr = '21 '
760aAC                   exfmt     screen21                             50
760aAC                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       303234
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cancel = *off
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
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzfil3
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   exsr      zzfil5
     C                   eval      refrsh = *off
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   eval      nxtscr = '06 '
     C                   exsr      zzfil6
     C                   eval      refrsh = *off
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   move      '07 '         nxtscr
     *
     *
     *  Get field defaults.
     *
     C                   exsr      zzfil7
     *
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   eval      nxtscr = '08 '
     C                   exsr      zzfil8
     C                   eval      refrsh = *off
     C     end08i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   eval      nxtscr = '09 '
     C                   exsr      zzfil9
     C                   eval      refrsh = *off
     C     end09i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 10 initialization
     *
     C     scr10i        begsr
     C                   eval      nxtscr = '10 '
     C                   exsr      zzfil10
     C                   eval      refrsh = *off
     C     end10i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 11 initialization
     *
     C     scr11i        begsr
     C                   eval      nxtscr = '11 '
     C                   exsr      zzfil11
     C                   eval      refrsh = *off
     C     end11i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 12 initialization
     *
     C     scr12i        begsr
     C                   eval      nxtscr = '12 '
     C                   exsr      zzfil12
     C                   eval      refrsh = *off
     C     end12i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 13 initialization
     *
     C     scr13i        begsr
     C                   eval      nxtscr = '13 '
     C                   exsr      zzfil13
     C                   eval      refrsh = *off
     C     end13i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 14 initialization
     *
     C     scr14i        begsr
     C                   eval      nxtscr = '14 '
     C                   exsr      zzfil14
     C                   eval      refrsh = *off
     C     end14i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 15 initialization
     *
     C     scr15i        begsr
     C                   eval      nxtscr = '15 '
     C                   exsr      zzfil15
     C                   eval      refrsh = *off
     C     end15i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 16 initialization
     *
     C     scr16i        begsr
     C                   eval      nxtscr = '16 '
     C                   exsr      zzfil16
     C                   eval      refrsh = *off
     C     end16i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 17 initialization
     *
     C     scr17i        begsr
     C                   eval      nxtscr = '17 '
     C                   exsr      zzfil17
     C                   eval      refrsh = *off
     C     end17i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 18 initialization
     *
     C     scr18i        begsr
     C                   eval      nxtscr = '18 '
     C                   exsr      zzfil18
     C                   eval      refrsh = *off
     C     end18i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 19 initialization
     *
     C     scr19i        begsr
     C                   eval      nxtscr = '19 '
     C                   exsr      zzfil19
     C                   eval      refrsh = *off
     C     end19i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 20 initialization
     *
     C     scr20i        begsr
     C                   eval      nxtscr = '20 '
     C                   exsr      zzfil20
     C                   eval      refrsh = *off
     C     end20i        endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  Screen 21 initialization
760aA*
760aAC     scr21i        begsr
760aAC                   eval      nxtscr = '21 '
760aAC                   exsr      zzfil21
760aAC                   eval      refrsh = *off
760aAC     end21i        endsr
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
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      refrsh = *off
     C*                  exsr      zzinz2
     c                   eval      nxtscr = '01 '
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
     C     redspl        cabeq     *on           endsc2
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
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C     cancel        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
750dDC**                 if        opcupc = 'Y'
750dDC**                 exsr      scr06i
750dDC**                 else
     C                   exsr      scr03i
750dDC**                 endif
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
740cA /free
740cA   // update rtchsth
740cA   pwhse = w1whse;
740cA   pcnttype = %dec(w2ctyp:2:0);
740cA   if w2ctyp = '1';
740cA     pid = wksuid;
740cA   else;
740cA     pid = workingId;
740cA   endif;
740cA   pcmd = 'FINISH';
740cA   updrtch(pwhse: pcmd: pid: pcnttype);
740cA /end-free
     C                   exsr      scr02i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr06i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
     C                   exsr      scr03i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C*                  exsr      scr07i
     C*                  goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *off
      /free
        // update rtchsth
        pwhse = w1whse;
        pcnttype = %dec(w2ctyp:2:0);
        if w2ctyp = '1';
          pid = wksuid;
        else;
          pid = workingId;
        endif;
        pcmd = 'FINISH';
        updrtch(pwhse: pcmd: pid: pcnttype);
      /end-free
     C                   exsr      scr02i
     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
      /free
        // update rtchsth
        pwhse = w1whse;
        pcnttype = %dec(w2ctyp:2:0);
        if w2ctyp = '1';
          pid = wksuid;
        else;
          pid = workingId;
        endif;
        pcmd = 'FINISH';
        updrtch(pwhse: pcmd: pid: pcnttype);
      /end-free
     C                   exsr      scr02i
     C                   goto      endsc8
     C                   endif

     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     c     redspl        cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc8        endsr
     *----------------------------------------------------------------
     *
     *  SC9  -  Screen 9
     *
     C     sc9           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      *in20 = *off
     C                   exsr      scr09i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
      /free
        if *inkl;
          select;
            when w2ctyp = '3' and inprocess = *off;
              // update header
              pwhse = w1whse;
              pcnttype = %dec(w2ctyp:2:0);
              pid = workingId;
              pcmd = 'CANCEL';
              updrtch(pwhse: pcmd: pid: pcnttype);
              exsr scr07i;
              leavesr;
            //when w2ctyp = '1' and inprocess = *off;
              // update header
              //pwhse = w1whse;
              //pcnttype = %dec(w2ctyp:2:0);
              //pid = rtchuid;
              //pcmd = 'CANCEL';
              //updrtch(pwhse: pcmd: pid: pcnttype);
              //exsr scr04i;
              //leavesr;
            when w2ctyp = '3' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '1' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '4' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '4' and inprocess = *off;
              // update header
              pwhse = w1whse;
              pcnttype = %dec(w2ctyp:2:0);
              pid = workingId;
              pcmd = 'CANCEL';
              updrtch(pwhse: pcmd: pid: pcnttype);
              exsr scr08i;
              leavesr;
            other;
              exsr scr01i;
              leavesr;
          endsl;
        endif;
      /end-free
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     c     redspl        cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc9        endsr
     *----------------------------------------------------------------
     *
     *  SC10 -  Screen 10
     *
     C     sc10          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc10
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr10i
     C                   goto      endsc10
     C                   endif
     *
     *  Test for F12 - Previous
     *
      /free
        if *inkl;
          select;
            when w2ctyp = '3' and inprocess = *off;
              exsr scr09i;
              leavesr;
            when w2ctyp = '1' and inprocess = *off;
              exsr scr09i;
              leavesr;
            when w2ctyp = '3' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '1' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '4' and inprocess = *on;
              errmsg = 'Finish counting slot';
              error = *on;
              exsr zm0105;
              leavesr;
            when w2ctyp = '4' and inprocess = *off;
              // update header
              pwhse = w1whse;
              pcnttype = %dec(w2ctyp:2:0);
              pid = workingId;
              pcmd = 'CANCEL';
              updrtch(pwhse: pcmd: pid: pcnttype);
              exsr scr08i;
              leavesr;
            other;
              nxtscr = '01 ';
              leavesr;
          endsl;
        endif;
      /end-free
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk10
     C     error         cabeq     *on           endsc10
     C                   exsr      zzupd10
     C     error         cabeq     *on           endsc10
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc10       endsr
     *----------------------------------------------------------------
     *
     *  SC11 -  Screen 11
     *
     C     sc11          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C*                  goto      endsc11
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr11i
     C*                  goto      endsc11
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '01 '
     C                   goto      endsc11
     C                   endif

750cAC                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd11
     C     cmdtkn        cabeq     *on           endsc11
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk11
     C     error         cabeq     *on           endsc11
     C                   exsr      zzupd11
     C     error         cabeq     *on           endsc11
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc11       endsr
     *----------------------------------------------------------------
     *
     *  SC12 -  Screen 12
     *
     C     sc12          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc12
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr12i
     C                   goto      endsc12
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '10 '
     C                   goto      endsc12
     C                   endif
     C                   exsr      zzcmd12
     C     cmdtkn        cabeq     *on           endsc12
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk12
     C     error         cabeq     *on           endsc12
     C                   exsr      zzupd12
     C     error         cabeq     *on           endsc12
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc12       endsr
     *----------------------------------------------------------------
     *
     *  SC13 -  Screen 13
     *
     C     sc13          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc13
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr13i
     C                   goto      endsc13
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '12 '
     C                   goto      endsc13
     C                   endif
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd13
     C     cmdtkn        cabeq     *on           endsc13
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk13
     C     error         cabeq     *on           endsc13
     C                   exsr      zzupd13
     C     error         cabeq     *on           endsc13
     *
     *  The after update redisplay screen. The only way out is F3.
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd13
     C     cmdtkn        cabeq     *on           endsc13
     *
     C     endsc13       endsr
     *----------------------------------------------------------------
     *
     *  SC14 -  Screen 14
     *
     C     sc14          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc14
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr13i
     C                   goto      endsc14
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      nxtscr = '12 '
     C                   goto      endsc14
     C                   endif
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd14
     C     cmdtkn        cabeq     *on           endsc14
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk14
     C     error         cabeq     *on           endsc14
     C                   exsr      zzupd14
     C     error         cabeq     *on           endsc14
     *
     *  The after update redisplay screen. The only way out is F3.
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd14
     C     cmdtkn        cabeq     *on           endsc14
     *
     C     endsc14       endsr
     *----------------------------------------------------------------
     *
     *  SC15 -  Screen 15
     *
     C     sc15          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc15
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      *in20 = *off
     C*                  exsr      scr13i
     C                   goto      endsc15
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '14 '
     C                   goto      endsc15
     C                   endif
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd15
     C     cmdtkn        cabeq     *on           endsc15
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk15
     C     error         cabeq     *on           endsc15
     C                   exsr      zzupd15
     C     error         cabeq     *on           endsc15
     *
     *  The after update redisplay screen. The only way out is F3.
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd15
     C     cmdtkn        cabeq     *on           endsc15
     *
     C     endsc15       endsr
     *----------------------------------------------------------------
     *
     *  SC16 -  Screen 16
     *
     C     sc16          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc16
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr16i
     C                   goto      endsc16
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      refrsh = *on
     C                   exsr      scr15i
     C                   goto      endsc16
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd16
     C     cmdtkn        cabeq     *on           endsc16
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk16
     C     error         cabeq     *on           endsc16
     C     redspl        cabeq     *on           endsc16
     C                   exsr      zzupd16
     C     error         cabeq     *on           endsc16
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd16
     C     cmdtkn        cabeq     *on           endsc16
     *
     C     endsc16       endsr
     *----------------------------------------------------------------
     *
     *  SC17 -  Screen 17
     *
     C     sc17          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc17
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr17i
     C                   goto      endsc17
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      refrsh = *off
     C*                  exsr      zzinz2
     c*                  eval      nxtscr = '01 '
     C                   goto      endsc17
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd17
     C     cmdtkn        cabeq     *on           endsc17
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk17
     C     error         cabeq     *on           endsc17
     C     redspl        cabeq     *on           endsc17
     C                   exsr      zzupd17
     C     error         cabeq     *on           endsc17
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd17
     C     cmdtkn        cabeq     *on           endsc17
     *
     C     endsc17       endsr
     *----------------------------------------------------------------
     *
     *  SC18 -  Screen 18
     *
     C     sc18          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc18
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr18i
     C                   goto      endsc18
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
      /free
        select;
          when additem = *on and $imltrk = 'U';
            nxtscr = '10 ';
            leavesr;
          other;
            nxtscr = '12 ';
            leavesr;
        endsl;
      /end-free
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd18
     C     cmdtkn        cabeq     *on           endsc18
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk18
     C     error         cabeq     *on           endsc18
     C     redspl        cabeq     *on           endsc18
     C                   exsr      zzupd18
     C     error         cabeq     *on           endsc18
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd18
     C     cmdtkn        cabeq     *on           endsc18
     *
     C     endsc18       endsr
     *----------------------------------------------------------------
     *
     *  SC19 -  Screen 19
     *
     C     sc19          begsr
     *  if User cancels out of this screen, need to delete any uci's
     *  that were added while doing this adjustment.
     *  They will have the time stamp and a license of *BFCADJADD
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc19
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C*                  eval      refrsh = *on
     C*                  exsr      scr19i
     C                   goto      endsc19
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C*                  eval      refrsh = *off
     c                   exsr      scr18i
     c*                  eval      nxtscr = '18 '
     C                   exsr      AdjCancel
     C                   goto      endsc19
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd19
     C     cmdtkn        cabeq     *on           endsc19
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk19
     C     error         cabeq     *on           endsc19
     C     redspl        cabeq     *on           endsc19
     C                   exsr      zzupd19
     C     error         cabeq     *on           endsc19
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd19
     C     cmdtkn        cabeq     *on           endsc19
     *
     C     endsc19       endsr
     *----------------------------------------------------------------
     *
     *  SC20 -  Screen 20
     *
     C     sc20          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C*                  eval      nxtscr = 'EOJ'
     C                   goto      endsc20
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   goto      endsc20
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = '19 '
     C                   goto      endsc20
     C                   endif
     C                   exsr      zzcmd20
     C     cmdtkn        cabeq     *on           endsc20
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk20
     C     error         cabeq     *on           endsc20
     C                   exsr      zzupd20
     C     error         cabeq     *on           endsc20
     *
     *  The after update redisplay screen. The only way out is F3.
     *
     C     endsc20       endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  SC21 -  Screen 21
760aA*
760aAC     sc21          begsr
760aA*
760aA*  Test for F3 - Exit
760aA*
760aAC                   if        *inkc
760aAC*                  eval      nxtscr = 'EOJ'
760aAC                   goto      endsc21
760aAC                   endif
760aA*
760aA*  Test for F5 - Refresh
760aA*
760aAC                   if        *inke
760aAC                   goto      endsc21
760aAC                   endif
760aA*
760aA*  Test for F12 - Previous
760aA*
760aAC                   if        *inkl
760aAC                   eval      nxtscr = '16 '
760aAC                   goto      endsc21
760aAC                   endif
760aAC                   exsr      zzcmd21
760aAC     cmdtkn        cabeq     *on           endsc21
760aA*
760aA*  Some other key pressed.
760aA*
760aA*     Check input and write/update record.
760aA*
760aAC                   exsr      zzchk21
760aAC     error         cabeq     *on           endsc21
760aAC                   exsr      zzupd21
760aAC     error         cabeq     *on           endsc21
760aA*
760aA*  The after update redisplay screen. The only way out is F3.
760aA*
760aAC     endsc21       endsr
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
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ADDSLTITM  Add item to the slot
     *
     C     addsltitm     begsr
     *
     *  Call license tracking - Before
     *  UNLESS I HAVE A LICENSE ALREADY

     C                   if        $lnlcns = ' '
     C                   if        tracklevel = tLow
     C                   eval      $tlic# = '*CC'
     C                   eval      $tinlic# = '*CC'
     C                   else
     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*GETNEW'
     C                   eval      $twhse    = w1whse
     C                   eval      $titem    = w16item
     C                   eval      $titemdsc = w16item
     C                   eval      $tlic#    = ' '
     C                   exsr      zzzcall$lt210
     C
     C                   if        $treturn <> '*OK'
     C                   eval      cancel = *on
     C                   leavesr
     C                   endif

     C                   endif
     c                   else
     C                   eval      $tinlic# = $lnlcns
     C                   endif

     *  Put qty in slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = W1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = W1DEPT
     C                   eval      $sldispu = *on
      /free
        select;
          when w2ctyp = '1';
            $sldisp = w9disp;
          when w2ctyp = '3';
            $sldisp = w9disp;
          when w2ctyp = '4';
            $sldisp = w8disp;
          other;
        endsl;
      /end-free
     C                   eval      $slstatu = *on
     C                   if        svstat <> 'Z '  and
     C                             svstat <> 'V '
     C                   eval      $slstat = svstat
     C                   else
     C                   eval      $slstat = 'A '
     C                   endif

     C                   if        $litodisp <> ' '
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = $liToEntD
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = $liToExpD
     C                   endif

     C                   if        $lnlcns <> ' '
740aA /free
740aA    yr        = %subdt($lnaddts:*years);
740aA    mn        = %subdt($lnaddts:*months);
740aA    da        = %subdt($lnaddts:*days);
740AA    alphadate = %char(yr) + %editc(mn:'X') + %editc(da:'X');
740aA /end-free
     C*****              eval      $slentdu = *on
     C*****              eval      $slentd  = $liToEntD
740aAC                   eval      $slentdu = *on
740aAC                   eval      $slentd  = %dec(alphadate:8:0)
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = $lnexpdate
     C                   endif

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #toititem
     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'CNT'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = $tinlic#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'Y'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'
     C                   if        $tinlic# <>  ' '
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = $tinlic#
     C                   endif

760aAc                   if        w21edte <> 0
760aAC                   eval      $cvcmd = '*MDYCMD '
760aAC                   move      w21edte       $cvd6i
760aAC                   call      @cvtdt
760aAC                   parm                    $cvtdt
760aAC                   eval      calcExpDate = $cvd8o
760aAc                   endif
760aA /free
760aA   if #toitflgd = 'Y';
760aA     $slexpdu = *on;
760aA     $slexpd  = calpdktexpd;
760aA   endif;
760aA /end-free
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%QTY2PUT0'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ADJCANCEL  Remove any uci records added during this adjustment
     *             used when the user cancels out of the adjustment
     *             Remove timestamp for any uci scanned.
     *
     C     adjcancel     begsr
     *
     *
      /free
        exsr clr$uciinfo;

        $uiWhse = w1whse;
        $uiapartlts = $ppartime;
        $uilcns = '*BFCADJADD';

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%ADJCANCEL';
        $drisys2upd = 'D';
        exsr zzzdricop;
      /end-free

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
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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
     *    ZMPCPF  Add CPF message record to subfile
     *
     C     zmpcpf        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgfc
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
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      $msgf = #msgsp
     C                   other
     C                   eval      $msgf = #msgf
     C                   endsl
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

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
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
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *      0105s
     *
     C     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *      0110
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
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
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Code must be entered.
     *
     C     zm03          begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0204  Enter only one value.
     *
     C     zm04          begsr
     C                   move      'PIR0204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm05          begsr
     C                   move      'PIR0205'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1008  Date can't be blank.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV21201  Qty entered without item.
     *
     C     zm1201        begsr
     C                   eval      #msgid = 'IV21201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PT13021  Warning: Entered catch wt not within +/- range.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PT13021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33001  No team defined for date.
     *
     C     zm3001        begsr
     C                   eval      #msgid = 'IV33001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33002  Slot not in inventory scope.
     *
     C     zm3002        begsr
     C                   eval      #msgid = 'IV33002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   IV33003  Slot already entered.
     *
     C     zm3003        begsr
     C                   eval      #msgid = 'IV33003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *  IV33004   Option not set to add item to slot
     *
     C     zm3004        begsr
     C                   eval      #msgid = 'IV33004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
510fA*     IV33005  # of pick slots exceeds # allowed.
510fA*
510fAC     zm3005        begsr
510fAC                   eval      #msgid = 'IV33005'
510fAC                   eval      #msgtp = '*DIAG  '
510fAC*                  eval      erdisp = imnrpk
510fAC                   movea     errmsg        $md(1)
510fAC                   exsr      zmpmsg
510eAC                   endsr
     *----------------------------------------------------------------
     *  IV33006   Qty entered without item confirmation entered.
     *
     C     zm3006        begsr
     C                   eval      #msgid = 'IV33006'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *  IV33007   Print Sheet option must be run before count entry.
     *
     C     zm3007        begsr
     C                   eval      #msgid = 'IV33007'
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
     *   CPF9898  Generic error message
     *
     C     zm9898        begsr
     C                   eval      #msgid = 'CPF9898'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpcpf
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
     *    PIR9906  Invalid date entered.
     *
     C     zm9906        begsr
     C                   eval      #msgid = 'PIR9906'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PO20029  UPC not on file.
     *----------------------------------------------------------------

     C     zm29          begsr
     C                   eval      #msgid = 'PO20029'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *    Make sure WHSE was entered.
     *
     C                   if        w1whse = *zero
     C                   eval      error = *on
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(1)     errmsg
     C                   other
     C                   movel     desc(1)       errmsg
     C                   endsl
     C                   exsr      zm03
     C                   endif
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
     C                   endif
     C                   endif
     *
     *    Make sure Dept was entered.
     *
     C                   if        w1dept = *blanks
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1DEPT
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *    Make sure Selection is entered and valid
     *
     C                   if        w2ctyp <> '1'
     c                             and w2ctyp <> '2'
     c                             and w2ctyp <> '3'
     c                             and w2ctyp <> '4'
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(9)     errmsg
     C                   other
     C                   movel     desc(9)       errmsg
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     *
      /free
        // temporary code - remove when ready
        if w2ctyp = '2';
          error = *on;
          *in03 = *on;
          *in23 = *on;
          errmsg = 'Feature is unavailable at this time';
          exsr zm0105;
        endif;
      /end-free
     *
     C*    enderr        tag
     *
     *   Save screen fields.
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
      /free
        // scope id must be entered
        if w3scope = 0;
          error = *on;
          errmsg = 'Invalid Scope Id';
          exsr zm0105;
          leavesr;
        endif;
        error = *off;
        // validate scope id
        exec sql select * into :rtchrec
             from rtchsth
             where rtchwhse = :w1Whse
               and rtchsts  = '1'
               and rtchtype = 1
               and rtchsid = :w3scope;

        If sqlstt =  sqlNoData;
          error = *on;
          errmsg = 'Invalid Scope Id';
          exsr zm0105;
730bA     leavesr;
        endif;
        // get adjustment code for scope
        exec sql select * into :rtcsrec
             from rtcscpd
             where rtcswhs = :rtchwhse
               and rtcsuid = :rtchuid;
        If sqlstt =  sqlNoData;
          error = *on;
          errmsg = 'Invalid Adjustment CD';
          exsr zm0105;
        endif;
      /end-free
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
      /free
        error = *off;
        // validate page number
        exec sql select * into :wksrec1
             from workrtcs
             where wkswhs = :w1Whse
               and wkswhdp  = :w1dept
               and wkspage  = :w4page
               and wksuid = :rtchuid;

        If sqlstt =  sqlNoData;
          error = *on;
          errmsg = 'Invalid Page #';
          exsr zm0105;
        endif;
      /end-free
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     *
     *
     *    Make sure Adjustment code was entered.
     *
     C                   if        w5adjcd = *blanks
     C                   eval      error = *on
     C                   eval      *in06 = *on
     C                   eval      *in26 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(10)    errmsg
     C                   other
     C                   movel     desc(10)      errmsg
     C                   endsl
     C                   exsr      zm03
     C                   endif
     *
     *  Verify Adjustment Code
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w5adjcd
     C                   call      'AD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 6 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
     *
     C     endck6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 7 error checking.

     C     zzchk7        begsr
     *
      /free
        error = *off;
        // validate item
        $slitem = w7item;
        exsr zzgetitem;
        if error;
          leavesr;
        endif;
        // does item exist in any slots
        setll (w1whse: w7item) slot3;
        dow forevr = forevr;
          reade (w1whse: w7item) slot3;
          if %eof(slot3);
            error = *on;
            errmsg = 'Item not found in ' + %trimr(w1dept) + ' Department';
            exsr zm0105;
            leave;
          endif;
          if slstat = 'V' or
             slstat = 'Z';
            iter;
          endif;
          if slwhdp <> w1dept;
            iter;
          endif;
765aD    // if slaisl = 'RCV' or
765aA     if sldesg ='BFC' and (slaisl = 'RCV' or
             slaisl = 'RTN' or
             slaisl = 'USR' or
             slaisl = 'OSS' or
             slaisl = 'RPA' or
             slaisl = 'XDK' or
765aM        slaisl = 'STG');
            iter;
          endif;
          leave;
        enddo;
      /end-free
     *
     C     endck7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8   Screen 8 error checking.
     *
     C     zzchk8        begsr
     C                   eval      error = *off
     *   this was in zzchk2
     *   SLCHK, Flags are used to force F20 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
      * need to skip slot conversion if svdisp = w3scan and override is on
     c                   if        svdisp <> w8disp
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w8disp
     C                   parm      4             worow
     C                   parm      08            wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   eval      redspl = *on
     C                   goto      endck8
     C                   endif
     c                   endif

     *  Get slot information.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1dept
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w8disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   goto      endck8
     C                   endif
740bAc                   if        w8disp <> $sacdsp
740bAC                   eval      *in29 = *on
740bAC                   eval      *in09 = *on
740bAc                   eval      error = *on
740bAC                   eval      errmsg = 'Scan Base Slot'
740bAc                   exsr      zm0105
740bAC                   goto      endck8
740bAc                   endif

     C                   eval      baseDisp = $sacdsp
      /free
        // scope selected
        if w2ctyp = '1';
          exsr zzchk8scope;
        endif;
      /end-free
     *
     *   Save screen fields.
      /free
        svdisp = w8disp;
        svpick = $slpick;
        svstat = $slstat;
        svstyp = $slstyp;
      /end-free
     *   this was in zzchk2
     *
     C     endck8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8SCOPE   Screen 8 scope error checking.
     *
     C     zzchk8scope   begsr
     *
     C     endck8scope   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK9   Screen 9 error checking.
     *
     C     zzchk9        begsr
     C                   eval      error = *off
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w9disp
     C                   parm      5             worow
     C                   parm      13            wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                             and w9disp <> *blanks
     C                   move      *on           redspl
     C                   goto      endck9
     C                   endif
     *
      /free
        if w9disp <> w9slot;
          errmsg = 'Wrong Slot';
          error = *on;
          exsr zm0105;
        endif;
        svdisp = w9disp;
750aA   if w2ctyp = '1';
750aA   svpick = wkspick;
750aA   svstat = wksstat;
750aA   svstyp = wksstyp;
750aA   else;
        svpick = wkipick;
        svstat = wkistat;
        svstyp = wkistyp;
750aA   endif;
      /end-free
     C     endck9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK10  Screen 10 error checking.
     *
     C     zzchk10       begsr
     C                   eval      error = *off
     *
     C     endck10       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK11  Screen 11 error checking.
     *
     C     zzchk11       begsr
     C                   eval      error = *off
     C                   eval      woupc = *blanks
     *
     ** Enter only one, either license or uci.
     C                   if        w11lcns <> *blanks  and
     C                             w11uci <> *blanks
     C                   move      *on           error
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm04
     C                   endif
     *
     *    Must enter one value License, UCI, UPC.
     *
     C                   if        w11lcns = *blanks  and
     C                             w11uci = *blanks
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm05
     C                   endif
     *  Skip check if X is entered.
750cDC*                  if        w11uci = 'X'
750cDC*                  eval      woupc = w11uci
750cDC*                  goto      endck11
750cDC*                  endif
     *    License entered
     C                   if        w11lcns <> *blanks
     *  Left justify license.
     C                   eval      $cstr = *blanks
     C                   move      w11lcns       $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         kylic
     *
     *  Verify license plate number.
     *
     C     likey         setll     license
     C     likey         reade     license
     C                   if        not %eof
     C     lbkey         setll     label90
     C     lbkey         reade     label90
     C                   if        not %eof
     C                   if        lbitem = w11item
     C                   goto      endck11
     C                   endif
     C                   endif
     C                   endif
     *  Invalid license-not found in LICENSE or LABEL or not for item
     C                   eval      error = *on
     C                   eval      *in32 = *on
     C                   eval      *in12 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(11)    errmsg
     C                   other
     C                   movel     desc(11)      errmsg
     C                   endsl
     C                   exsr      zm9898
     C                   goto      endck11
     C                   endif
     *
     *  UPC entered
     *
     C                   if        w11uci <> *blanks
     *
     *     UPC code not on file.
     *
     C                   eval      $cbcmd = '*UPC    '
     C                   movel     w11uci        $cbbar
     C                   call      'CVTBAR'
     C                   parm                    $cbcmd            8
     C                   parm                    $cbbar          100
     C                   parm                    $cbcod            3 0
     C                   parm                    $cbdec            1 0
     C                   parm                    $cbdsc           30
     C                   parm                    $cbpos            3 0
     C                   parm                    $cbtyp            1 0
     C                   parm                    $cbv1            11 3
     C                   parm                    $cbv2            50
     C                   parm                    $cbrtn            8
     C                   parm                    $cberm           60
     *
     C                   if        $cbrtn = '*OK'
     C                   eval      w11uci = $cbv2
     C                   endif
     *
     *   Right adjust UPC code for file.
     *
     C                   eval      $cstr = *blanks
     C                   movel     w11uci        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         kyupc
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, UPC found,
     C                   eval      upcctr = 0
     C     upckey        setll     upc
     C                   dow       forevr = forevr
     C     upckey        reade     upc                                    79
     *
     C                   if        *in79
     C                   leave
     C                   else
     C                   if        w11item = upitem
     C                   add       1             upcctr
     C                   leave
     C                   endif
     C                   endif
     *
     C                   enddo
     * UPC not found for item
     C                   if        upcctr = 0
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      errmsg = *blanks
     C                   eval      w11uci = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(8)     errmsg
     C                   other
     C                   movel     desc(8)       errmsg
     C                   endsl
     C                   exsr      zm9898
     C                   goto      endck11
     C                   endif
     *
     C                   endif
     *

     C     endck11       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK12  Screen 12 error checking.
     *
     C     zzchk12       begsr
     C                   eval      error = *off
     *
     C     endck12       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK13  Screen 13 error checking.
     *
     C     zzchk13       begsr
     C                   eval      error = *off
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
     C                   z-add     0             taddw             7 2
     c                   exsr      zzcnvwgt
     C                   eval      taddw = cnvwgt
     *
     *   WTCHK, Flags are used to force F8 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     * Set flag
     C                   if        wtchk = '2' and
     C                             ovrrid = *on
     C                   eval      wtchk = '1'
     C                   endif
     *  Verify catch weight.
     C                   if        wtchk <> '1'
     C                   eval      wtchk = '1'
     *
     C                   if        opccwv = 'Y'
     C                   if        lvskp = *off and
     C                             taddw < lwrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in37 = *on
     C                   eval      *in17 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     lwrng         erlrng
     *
     C                   if        hvskp  = *on
     C                   z-add     0             erhrng
     C                   else
     C                   z-add     hirng         erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   if        hvskp  = *off and
     C                             taddw  > hirng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   eval      wtchk = '2'
     C                   eval      *in37 = *on
     C                   eval      *in17 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   if        lvskp = *on
     C                   z-add     0             erlrng
     C                   else
     C                   z-add     lwrng         erlrng
     C                   endif
     C                   z-add     hirng         erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     exwgt         erexwt
     C                   exsr      zm21
     C                   endif
     *
     C                   endif
     C                   endif
     *
     *
     C     endck13       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK14  Screen 14 error checking.
     *
     C     zzchk14       begsr
     C                   eval      error = *off
     *
     C     endck14       endsr
     C**---------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK15  Screen 15 error checking.
     *
     C     zzchk15       begsr
     C                   eval      error = *off
      /free
610aA   if w15uci = *blanks and
610aA      w15lcns = *blanks and
610aA      opckin = 'Y';
740aA      exsr clr$license;
740aA      exsr clr$licinfo;
610aA     leavesr;
610aa   endif;
610aA   if w15uci = *blanks and
610aA      w15lcns = *blanks and
610aA      opckin <> 'Y';
          errmsg = 'Scan License or UCI';
          error = *on;
          exsr zm0105;
740aA     exsr clr$license;
740aA     exsr clr$licinfo;
610aA     leavesr;
610aa   endif;

        if w15lcns <> ' ';
          // license entered
          exsr clr$license;

          $liToLcnsU = *on;
          $liToLcns = w15lcns;

          $dricommand = '*LICENSE';
          $drisubcmd  = '%GETLCNS';
          $drisys2upd = 'D';
          exsr zzzdricop;
          if $drireturn <> '*OK';
            // not found in licactive, do we have licinfo record
            exsr clr$licinfo;

            $lnwhse  = w1whse;
            $lnlcns  = w15lcns;
            $lnseq  = 1;

            $dricommand = '*LICINFO';
            $drisubcmd  = '%GET';
            $drisys2upd = 'D';
            exsr zzzdricop;
            if $drireturn <> '*OK';
              errmsg = $drimessage;
              error = *on;
              exsr zm0105;
              leavesr;
            endif;
          endif;
          // Verify To Slot
          if $litodisp <> ' ';
            exsr clr$slot;
            $slwhseu = *on;
            $slwhse  = w1whse;
            $slwhdpu = *on;
            $slwhdp = $litowhdp;
            $sldispu  = *on;
            if prdtfr;
              $sldisp   = hldprdDisp;
            else;
              $sldisp   = w14disp;
            endif;
            $slexpdu  = *on;
            $slexpd   = $liToExpD;
            $saitemu  = *on;
            $saitem   = $litoitem;
            $saqtyu   = *on;
            $saqty1   = $LITORQTY1;
            $saqty2   = $LITORQTY2;
            $saqty3   = $LITORQTY3;
            $sacitemu = *on;
            $sacitem  = #fromslitem;
            $sacdspu  = *on;
            $sacdsp   = $litodisp;

            $saActionU = *on;
            $saAction = 'TFR';

            $dricommand = '*SLOT';
            $drisubcmd  = '%VFYTFICHG';
            $drisys2upd = 'D';
            chk4err = *on;
            zmsflag = *off;
            exsr zzzdricop;
            if error;
            //*in21 = *on
            //*in01 = *on
              leavesr;
            endif;
          endif;
          // does it exist in licative  - that would be a transfer
          if $litodisp <> ' ';
765aA       exsr clr$slot;
765aA       $slwhseu = *on;
765aA       $slwhse  = w1whse;
765aA       $slwhdpu = *on;
765aA       $slwhdp = $litowhdp;
765aA       $sldispu  = *on;
765aA       $sldisp   = $litodisp;
765aA       $dricommand = '*SLOT';
765aA       $drisubcmd  = '%GET';
765aA       $drisys2upd = 'D';
765aA       chk4err = *on;
765aA       zmsflag = *off;
765aA       exsr zzzdricop;
            exsr zzchktfr;
          endif;

          // does it exist in licinfo but not licactive
          // need to adjust using the license.
          if $lnlcns <> ' ';
            exsr clr$slot;
            $slwhseu = *on;
            $slwhse  = w1whse;
            $slwhdpu = *on;
            $slwhdp = w1dept;
            $sldispu  = *on;
            $sldisp   = w14disp;
            $slexpdu  = *on;
            $slexpd   = $lnexpdate;
            $saitemu  = *on;
            $saitem   = $lnitem;
            $saqtyu   = *on;
            $saqty1   = 1;
            $saqty2   = 0;
            $saqty3   = 0;
            $sacitemu = *on;
            $sacitem  = ' ';
            $sacdspu  = *on;
            $sacdsp   = ' ';

            $saActionU = *on;
            $saAction = 'TFR';

            $dricommand = '*SLOT';
            $drisubcmd  = '%VFYTFICHG';

            $drisys2upd = 'D';
            chk4err = *on;
            zmsflag = *off;
            exsr zzzdricop;
            if error;
              errmsg = $drimessage;
              exsr zm0105;
              leavesr;
            endif;
            leavesr;
          endif;

        endif;

        // uci tracked with license, do I do a transfer of this one box
        // not uci tracked use uci to get the item number
        // check upc code if entered.
        if w15uci <> *blanks;
          exsr clr$license;
          exsr clr$licinfo;
          clear $barcode;
          clear $barcode2;
          // lets check for a gtin fist from gs1
          uciLength = %Len(%Trim(w15uci));
          if ucilength > 14;
650fA       cvtbar('*ALL': w15UCI:
650fA          $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740aD        //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
740aM          $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740aA          $cbkilolbsSent: $cbitem);
650fA       $barcode = $cvtdata;
650fA       $barcode2 = $cvtdata2;
          endif;
          $cstr = *blanks;
          select;
            when $bcGtinSent;
              $cstr = $bcgtin;
            other;
              $cstr = w15uci;
          endsl;

      /end-free
     c*   // right adjust upc code for file
     c**                 eval      $cstr = *blanks
     c**                 movel     w15uci        $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         w2up20           20
     *   Check if mulitple items exist for one UPC code.
     *    UPCCTR = 0, error, upc code not found.
     *    UPCCTR = 1, only one upc found, process for item.
     *    UPCCTR > 1, multiple upc found, need to select item.
      /free
        upcctr = 0;
        setll (w1whse: w2up20) upc;
        dow forevr = forevr;
          reade (w1whse: w2up20) upc;
          if %eof(upc);
            leave;
          else;
            upcctr = upcctr + 1;
          endif;
        enddo;
        if upcctr = 0;
          error = *on;
          errmsg = 'UPC not found';
          exsr zm0105;
          leavesr;
        endif;
        if upcctr > 1;
      /end-free
     *
     *   Multiple items exist for UPC
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   move      w2up20        $lupc
     C                   call      'UC920'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C*                  eval      *in30 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C*                  eval      *in30 = *on
     C                   eval      errmsg = $lmsg
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endif
     C                   endif
     C                   eval      upitem = $litm1
     *
      /free
        endif;
        if upitem <> ' ';
          exsr clr$slot;
          $slwhseu = *on;
          $slwhse  = w1whse;
          $slwhdpu = *on;
          $slwhdp = w1dept;
          $sldispu  = *on;
          $sldisp   = w14disp;
          $saitemu  = *on;
          $saitem   = upitem;
          $saqtyu   = *on;
          $saqty1   = 1;
          $saqty2   = 0;
          $saqty3   = 0;
          $sacitemu = *on;
          $sacitem  = ' ';
          $sacdspu  = *on;
          $sacdsp   = ' ';

          $saActionU = *on;
          $saAction = 'TFR';

          $dricommand = '*SLOT';
          $drisubcmd  = '%VFYTFICHG';

          $drisys2upd = 'D';
          chk4err = *on;
          zmsflag = *off;
          exsr zzzdricop;
          if error;
            errmsg = $drimessage;
            exsr zm0105;
            leavesr;
          endif;
          leavesr;
        endif;
      /end-free
     *
     *
     C                   endif
     *
     C     endck15       endsr
     C**---------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK16  Screen 16 error checking.
     *
     C     zzchk16       begsr
     C                   eval      error = *off
     *
     *    Make sure item or mfg item is entered
     *
      /free
        if w16item = *blanks and
           w16mfg# = *blanks;
          error = *on;
          *in23 = *on;
          *in03 = *on;
          errmsg = 'Item or Mfg# must be entered';
          exsr zm0105;
          leavesr;
        endif;
      /end-free
     *
     *    Get item # if Mfg item # was entered.
     *
     *   Check if mulitple items exist for one MFG code.
     *    mfgCTR = 0, error, mfg code not found.
     *    mfgCTR = 1, only one mfg found, process for item.
     *    mfgCTR > 1, multiple mfg found, need to select item.
      /free
        if w16mfg# <> ' ';
          mfgctr = 0;
          setll (w1whse: w16mfg#) piritem4;
          dow forevr = forevr;
            reade (w1whse: w16mfg#) piritem4;
            if %eof(piritem4);
              leave;
            endif;
            mfgctr = mfgctr + 1;
          enddo;
          if mfgctr = 0;
            error = *on;
            *in23 = *on;
            errmsg = 'No Item Found for the MFG# Entered';
            exsr zm0105;
            leavesr;
          endif;
      /end-free
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = $pwhse
     C                   move      w16mfg#       $lmfg
     c                   eval      $litmmfg = ' '
     C                   call      'IT930'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = $lmsg
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endif
     C                   endif
     *
     C                   eval      w16item = $litmmfg
     *
     C                   endif
      /free
        if w16mfg# <> *blanks and w16item = ' ';
            error = *on;
            *in23 = *on;
            errmsg = 'No Item Found for the MFG# Entered';
            exsr zm0105;
            leavesr;
        endif;
      /end-free

     *    Verify item.
     *  Use DRI interface to get item.
     *  We now verify the item by getting its correpsonding slot item.
      /free
         exsr clr$item;
         $itwhse  = $pwhse;
         $ititem  = w16item;

         $dricommand = '*ITEM';
         $drisubcmd  = '%GETSLOT';
         $drisys2upd = 'D';
         chk4err = *on;
         zmsflag = *off;
         exsr zzzdricop;
         if error;
           *in23 = *on;
           errmsg = 'Invalid Item';
           exsr zm0105;
           leavesr;
         endif;

         #toititem = $ititem;
         #toittype = $ittype;
         #toitdesc = $itdesc;
         #toitpdsc = $itpdsc;
         #toitwhdp = $itwhdp;
         #toitstyp = $itstyp;
         #toitdesg = $itdesg;
         #toitum1  = $itum1;
         #toitflg1 = $itflg1;
         #toitum2  = $itum2;
         #toitumq2 = $itumq2;
         #toitflg2 = $itflg2;
         #toitum3  = $itum3;
         #toitumq3 = $itumq3;
         #toitnrpk = $imnrpk;
         #toitflgd = $itflgd;
         #toitmflg = $immflg;         //760a
         #toitcube = $itcube;
         #toitswgt = $itswgt;
         #toitcwgt = $itcwgt;
         #toitmitem = $itmitem;
         //wsitem = $ititem;
         tracklevel = $imltrk;

         // for  a low tracked item, see if it is already in slot
         if tracklevel = tLow;

           exsr clr$slot;
           $slwhseu = *on;
           $slwhse  = w1whse;
           $slwhdpu = *on;
           $slwhdp  = w1dept;
           $sldispu = *on;
           select;
             when w2ctyp = '1';
               $sldisp = w9disp;
             when w2ctyp = '3';
               $sldisp = w9disp;
             when w2ctyp = '4';
               $sldisp = w8disp;
             other;
           endsl;
           $saitemu = *on;
           $saitem  = $ititem;

           $dricommand = '*SLOT';
           $drisubcmd  = '%VFYINSLOT';
           $drisys2upd = 'D';
           chk4err = *off;
           zmsflag = *off;
           exsr zzzdricop;
           if $drireturn = 'ITMFOUND';
             error = *on;
             *in23 = *on;
             errmsg = 'Item already in slot';
             exsr zm0105;
             leavesr;
           endif;

         endif;
      /end-free
     *
     *    If slot is pick slot, check if # of pick slots.
     *
      /free
         if svpick = 'Y' and svstyp = 'F';
           // count # of pick slots.
           exsr chkpck;
           nbrpck = nbrpck + 1;

           // Error if new # of pick slots is > number allowed.
           // ICB* If Pick slot is active, skip ck for # of pick slots
           select;
             when client = icb;
               if svpick = 'Y' and svstat = 'A';
                 nbrpck = imnrpk;
               endif;
           endsl;

CPJaA      Select;
CPJaA        when client = CPJ;
CPJaA        other;
               if nbrpck > imnrpk;
                 k3stat = 'A ';
                 k3pick = 'Y ';
                 setll (w1whse: $ititem: k3stat: k3pick) slot3;
                 reade (w1whse: $ititem: k3stat: k3pick) slot3;
                 if %found(slot3);
                   erdisp = sldisp;
                 endif;
                 error = *on;
                 *in23 = *on;
                 exsr zm3005;
               endif;
CPJaA      endsl;
         endif;
         //              endif;
      /end-free
     *
     *   Save screen fields.
     C     endck16       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK17  Screen 17 error checking.
     *
     C     zzchk17       begsr
     C                   eval      error = *off
     *
     *    Make sure
     *
     C***                if        w2ctyp <> '1'
     c***                          and w2ctyp <> '2'
     c***                          and w2ctyp <> '3'
     c***                          and w2ctyp <> '4'
     C***                eval      error = *on
     C***                eval      *in03 = *on
     C***                eval      *in23 = *on
     C***                eval      errmsg = *blanks
     C***                select
     C***                when      e$lng = 'SP'
     C***                movel     descsp(9)     errmsg
     C***                other
     C***                movel     desc(9)       errmsg
     C***                endsl
     C***                exsr      zm0105
     C***                endif
     *
     *
     *
     *   Save screen fields.
     C     endck17       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK18  Screen 18 error checking.
     *
     C     zzchk18       begsr
     C                   eval      error = *off
     *
     *    Make sure Selection is entered and valid
     *
     C                   if        w18type <> '3'
     c                             and w18type <> '4'
     C                   eval      error = *on
     C                   eval      *in03 = *on
     C                   eval      *in23 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descsp(9)     errmsg
     C                   other
     C                   movel     desc(9)       errmsg
     C                   endsl
     C                   exsr      zm0105
     C                   endif
     *
     C     endck18       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK19  Screen 19 error checking.
     *
     C     zzchk19       begsr
     C                   eval      error = *off
     *
     *   Verify UCI scannin Rules

     C                   if        w19uci = ' '
     C                   eval      error = *on
     C                   eval      *in35 = *on
     C                   eval      *in01 = *on
     C                   select
     C                   when      e$lng = 'SP'
     C                   eval      errmsg = 'uci'
     C                   other
     C                   eval      errmsg = 'uci must be scanned'
     C                   endsl
     C                   exsr      zm0105
     c                   leavesr
     C                   endif

      /free
        // has the uci already been scanned for this adjustment
        w19uci = %TrimL(w19uci);
        exsr clr$uciinfo;

        $uiWhse = W1whse;
        $uiuci  = w19uci;
        $uiapartlts = $ppartime;

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%VFYCURMV';
        $drisys2upd = 'D';
        exsr zzzdricop;
        // if return is *OK we can continue
        if $drireturn <> '*OK';
          error = *on;
          *in21 = *on;
          *in01 = *on;
          errmsg = $drimessage;
          if errmsg = 'UCI has already been scanned for movement';
            errmsg = 'UCI has already been scanned for count';
          endif;
          exsr zm0105;
          leavesr;
        endif;
        // is the UCI active in the system
        exsr clr$uciinfo;

        $uiWhse = W1whse;
        $uiuci  = w19uci;
        $uiitem = $slitem;

        $dricommand = '*UCIINFO';
        $drisubcmd  = '%CHK4ADJ';
        $drisys2upd = 'D';
        exsr zzzdricop;

        select;
          when w18type = '3';
            select;

              // return= *OK, that means the uci is already in uciinfo
              when $drireturn = '*OK';
                error = *off;
                // if the uci is attached to the license being adjusted
                // it can not be scanned for an add adjustment

                // adjustment to pick slot could have *MULTIPLE in
                // $slotlcns - this will need a further check to
                // determine if the uci is already in the pick slot
                if $slotlcns = '*MULTIPLE';
                  exsr clr$license;
                  if $uilcns <> ' ';
                    $liToWhseU = *on;
                    $liToWhse = W1Whse;
                    $liToWhdpU = *on;
                    $liToWhdp = W1DEPT;
                    $liToDispU = *on;
                    $liToDisp = W10SLOT;
                    $liToLcnsU = *on;
                    $liToLcns = $uilcns;
                    $dricommand = '*LICENSE';
                    $drisubcmd  = '%GETLCNS';
                    $drisys2upd = 'D';
                    chk4err = *on;
                    exsr zzzdricop;
                  endif;
                endif;

                $uiaction = 'ADJSTART';

              // return= *NOTACTIVE is a good return, proceed to update
              // means the uci does not exist as active in the warehouse
              when $drireturn = '*NOTACTIVE';
                error = *off;
                // need to convert the barcode to extract the GTIN
                cvtbar('*ALL': w19UCI:
                  $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740aD           //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
740aM             $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse:
740aA             $cbkilolbsSent: $cbitem);
                $barcode = $cvtdata;
                $barcode2 = $cvtdata2;
                // make sure the gtin is for the item being adjusted
                if $bcgtinsent;
      /end-free
     *   Right adjust UPC code for edit.
     *
     C                   eval      $cstr = *blanks
     C                   movel     $bcgtin       $cstr
     C                   call      'ADJUST'
     C                   parm      '*RIGHT  '    $ccmd             8
     C                   parm                    $cstr            30
     C                   move      $cstr         kyupc
      /free
                  chain ($pwhse: $slitem: kyupc) upc2;
                  if not %found(upc2);
                    errmsg = 'UCI does not match Item';
                    error = *on;
                    exsr zm0105;
                    leavesr;
                  endif;
                endif;

                $uiaction = 'ADJADD';
                leavesr;
              other;
                errmsg = $drimessage;
                error = *on;
                exsr zm0105;
                leavesr;
            endsl;
        endsl;
      /end-free

     *   Save screen fields.
     C     endck19       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK20  Screen 20 error checking.
     *
     C     zzchk20       begsr
     C                   eval      error = *off
     *
     C     endck20       endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  ZZCHK21  Screen 21 error checking.
760aA*
760aAC     zzchk21       begsr
760aAC                   eval      error = *off
760aAc                   if        w21edte <> 0
760aAC                   eval      $cvcmd = '*MDYCMD '
760aAC                   move      w21edte       $cvd6i
760aAC                   call      @cvtdt
760aAC                   parm                    $cvtdt
760aAC                   eval      calcExpDate = $cvd8o
760aAc                   endif
760aA /free
760aA   // If item is Mfg then date must be < today
760aA   if itemIsMfg and calcExpDate >= today;
760aA     errmsg = 'Mfg Date must be less than today';
760aA     error = *on;
760aA     exsr zm0105;
760aA   endif;

760aA   // If item is Exp then date must be >= to today
760aA   if itemIsExp and calcExpDate < today;
760aA     errmsg = 'Exp Date must be at least today';
760aA     error = *on;
760aA     exsr zm0105;
760aA   endif;

760aA   // now calculate the dakota expiration date, issue error if expired
760aA   BuildItem = $ititem;
        pWhse = $itwhse;
760aA   caldktexp(perrmsg: psessid: #user: pdpcombo:
760aA             pWhse: BuildItem: calcExpDate: calpdktexpd);
760aA   if calpdktexpd < today;
760aA     errmsg = 'Dakota Exp Date must be at least today';
760aA     error = *on;
760aA     exsr zm0105;
760aA   endif;
760aA /end-free

760aA*
760aAC     endck21       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKTFR Additional edit checks for auto transfer

     C     zzchktfr      begsr
      /free
        select;
          when w2ctyp = '1';
            w14disp = w9disp;
          when w2ctyp = '3';
            w14disp = w9disp;
          when w2ctyp = '4';
            w14disp = w8disp;
          other;
        endsl;
        if $litodisp <> w8disp and w2ctyp = '4' or
           $litodisp <> w9disp and w2ctyp = '3';
          // uci attached to an open putaway
765aD    // if $litoaisl = 'RCV' or
765aA       if $sldesg = 'BFC' and ($litoaisl = 'RCV' or
            $litoaisl = 'RTN' or
765aM       $litoaisl = 'STG');
            errmsg = 'Open Putaway - license must be put away first';
            error = *on;
            exsr zm0105;
            leavesr;
          endif;
          // uci attached to a usr slot - must use transfer
765aD    // if $litoaisl = 'USR';
765aD       if $sldesg = 'BFC' and $litoaisl = 'USR';
            errmsg = 'License is in a USR slot - use Transfer';
            error = *on;
            exsr zm0105;
            leavesr;
          endif;

          // Use DRI interface to get slot information
          exsr clr$slot;
          $slwhseu = *on;
          $slwhse  = w1whse;
          $slwhdpu = *on;
          $slwhdp  = $litowhdp;
          $sldispu = *on;
          $sldisp  = $litodisp;

          $dricommand = '*SLOT';
          $drisubcmd  = '%GETCHKVX';
          $drisys2upd = 'D';
          chk4err = *on;
          zmsflag = *on;
          exsr zzzdricop;
          if error;
            $prtn = '*PGMQ   ';
            leavesr;
          endif;

          exsr zzgetitem;
          #fromslwhdp = $slwhdp;
          #fromslstyp = $slstyp;
          #fromsldisp = $sldisp;
          #fromslaisl = $slaisl;
          #fromslloc  = $slloc;
          #fromslpseq = $slpseq;
          #fromslrlvl = $slrlvl;
          #fromslhand = $slhand;
          #fromslstat = $slstat;
          #fromslrsrv = $slrsrv;
          #fromslentd = $slentd;
          #fromslexpd = $slexpd;
          #fromslslfd = $slslfd;
          #fromslactv = $slactv;
          #fromslbld  = $slbld;
          #fromslpick = $slpick;
          #fromslitem = $slitem;
          #fromslsdef = $slsdef;
          #fromslvirt = $sfvirt;
          #fromslstk1 = $slstk1;
          #fromslstk2 = $slstk2;
          #fromslstk3 = $slstk3;
          #fromslalc1 = $slalc1;
          #fromslalc2 = $slalc2;
          #fromslalc3 = $slalc3;
          #fromsltfr1 = $sltfr1;
          #fromsltfr2 = $sltfr2;
          #fromsltfr3 = $sltfr3;
          #fromslpck1 = $slpck1;
          #fromslpck2 = $slpck2;
          #fromslpck3 = $slpck3;
          #fromslrcv1 = $slrcv1;
          #fromslrcv2 = $slrcv2;
          #fromslrcv3 = $slrcv3;
          #fromslphy1 = $slphy1;
          #fromslphy2 = $slphy2;
          #fromslphy3 = $slphy3;
          #fromslavl1 = $slavl1;
          #fromslavl2 = $slavl2;
          #fromslavl3 = $slavl3;
          #fromToLcns = $saToLcns;
          #fromToPos  = $saToPos;
          #fromOLcns = $saOLcns;
          #frombasesldsp = $sacdsp;
          // Use DRI interface to do most of the verifications
          exsr clr$slot;
          $slwhseu  = *on;
          $slwhse   = w1whse;
          $slwhdpu  = *on;
          $slwhdp   = $liToWhdp;
          $sldispu  = *on;
          $sldisp   = $liToDisp;
          $slitemu  = *on;
          $slitem   = $litoItem;
          $saitemu  = *on;
          $saitem   = $litoItem;
          $saqtyu   = *on;
          if $imltrk = 'U';
            select;
              when $uiautyp = '2';
                $saqty3 = 1;
              when $uiautyp = '1';
                $saqty2 = 1;
              other;
                $saqty1 = 1;
            endsl;
          endif;
          $sacitemu = *on;
          $sacitem  = $litoitem;

          $dricommand = '*SLOT';
          $drisubcmd  = '%VFYTFOCHG';
          $drisys2upd = 'D';
          chk4err = *on;
          zmsflag = *off;
          exsr zzzdricop;
          if error;
            exsr zm0001;
            leavesr;
          endif;


          exsr zzgetitem;
          // these edits came from it252 - zzchk2
          // if production slot ensure virtual is created
          // for the slot being adjustest, transferred to.
          prdtfr = *off;
          sltc = 0;
          select;
            when w2ctyp = '1';
              wkaisl = %subst(w9disp:1:3);
            when w2ctyp = '3';
              wkaisl = %subst(w9disp:1:3);
            when w2ctyp = '4';
              wkaisl = %subst(w8disp:1:3);
            other;
          endsl;
          sltc = %lookup(wkaisl:prdslt:1);
          if sltc <> 0 and wkaisl <> ' ';
            prdtfr = *on;
            exsr clr$slot;
            $slwhseu = *on;
            $slwhse  = w1Whse;
            $slwhdpu = *on;
            $slwhdp  = w1dept;
            $slitemu = *on;
            $slitem  = $litoItem;
            $sldispu = *on;
            $sldisp  = w14disp;
            $slstatu = *on;
            $slstat  = 'PR';

            $dricommand = '*SLOT';
            $drisubcmd  = '%CRTPROD';
            $drisys2upd = 'D';
            chk4err = *on;
            exsr zzzdricop;
            hldprdDisp = $sldisp;
            error = *off;
          endif;
          // To Slot can't be blank - which is the original slot
          // the user had selected to adjust - which should never
          // be blank at this point - but we will double check.
          if w8disp = *blanks and w2ctyp = '4' or
             w9disp = *blanks and w2ctyp = '3';
            error = *on;
            errmsg = 'Blank adjustment Slot';
            exsr zm0105;
            leavesr;
          endif;
          // if transfer to represents a Repack Item verify
          // on-demand slot exist.
          if $ittype = 'R';
            chain (w1Whse:$litoItem) kititem;
            if not %error and %found;
              if kidisp <> ' ';
                exsr clr$slot;
                $slwhseu = *on;
                $slwhse  = w1Whse;
                $slwhdpu = *on;
                $slwhdp  = w1dept;
                $slitemu = *on;
                $slitem  = $litoitem;
                $sldispu = *on;
                $sldisp  = kidisp;

                $dricommand = '*SLOT';
                $drisubcmd  = '%CRTREPAKD';
                $drisys2upd = 'D';
                chk4err = *on;
                exsr zzzdricop;
                odrSlot = $sldisp;
                error = *off;
              endif;
            endif;
          endif;
          // I exclude the oss check from it252 because they would not
          // be doing an adjustment to an oss location and scanning the
          // UCI to add, we would not want to auto transfer
          if %subst($liToDisp:1:3) = 'OSS';
            error = *on;
            errmsg = 'License is at Outside '
                   + 'Storage';
            exsr zm0105;
            leavesr;
          endif;

        endif;
      /end-free
     C     endcktfr      endsr
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
     C                   when      row# = 3
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *
     *     Warehouse department.
     *
     C                   when      row# = 4
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1dept
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1dept = $lwhdp
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
     *     Warehouse department.
     *
     C                   when      row# = 3
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $lwhdp = w1dept
     C                   call      'WD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1dept = $lwhdp
     C                   endif
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
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  F6 - Add item.
     *
     C                   if        *inkf
     *  Check option to allow add item.
     C                   if        opcadd <> 'Y'
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm3004
     C                   else
     *
     C                   if        w1dept = *blanks
     C                   eval      error = *on
     C                   eval      *in05 = *on
     C                   eval      *in25 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm03
     C                   else
     C*                  eval      cmdtkn = *on
     C*                  eval      $lcmd = '*CREATE '
     C*                  eval      $lprg = #prog
     C*                  eval      $lwhdp = w1dept
     C*                  eval      $lteam = ivttem
     C*                  eval      $lcupc = opcupc
     C*                  eval      $lcadd = opcadd
     C*                  eval      $lccwt = opccwt
     C*                  call      'IV333'
     C*                  parm                    $lparm
     C                   goto      endcm2
     C                   endif
     C                   endif
     C                   endif
     *
     *  F8 - Override Slot already entered error, accept warning
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C                   else
     C                   move      *off          ovrrid
     C                   endif
     *
     *
     *  Test for F10 - EXCEPTION - SLOT
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     *
     *  Call edit routine before logging exception.
     *
     C*                  if        w2disp <> *blanks
     C*                  exsr      zzck2a
     C*                  if        error = *on  or
     C*                            redspl = *on
     C*                  goto      endcm2
     C*                  endif
     C*                  endif
     *
     C*                  eval      cmdtkn = *on
     C*                  eval      excode = *on
     C*                  exsr      zzexcp
     C*                  eval      scode = 'X '
     C*                  exsr      zzTouch
     C*                  exsr      scr02i
     C*                  goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
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
     C                   goto      endcm3
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - EXCEPTION - ITEM
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   eval      excode = '2'
     C                   exsr      zzexcp
     C                   eval      scode = 'X '
     C                   exsr      zzTouch
     C                   exsr      scr02i
     C                   goto      endcm3
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
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
     C                   goto      endcm4
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - EXCEPTION - BREAKDOWN QTY
     *
     C*                  if        *inkj
     C*                  eval      cmdtkn = *on
     C*                  eval      excode = '3'
     C*                  exsr      zzexcp
     C*                  eval      scode = 'X '
     C*                  exsr      zzTouch
     C*                  exsr      scr02i
     C*                  goto      endcm4
     C*                  endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C*                  if        cmdchk = '*AFTER  '
     C*                  endif
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
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
     *     Adjustment Code
     *
     C                   when      row# = 3
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w5adjcd
     C                   call      'AD900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w5adjcd = $lcode
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm5
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 6.
     *
     C     zzcmd6        begsr
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
     C                   goto      endcm6
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 7.
     *
     C     zzcmd7        begsr
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
     C                   goto      endcm7
     C                   endif
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD8   User defined command keys for screen 8.
     *
     C     zzcmd8        begsr
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
     C                   goto      endcm8
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD9   User defined command keys for screen 9.
     *
     C     zzcmd9        begsr
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
     C                   goto      endcm9
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD10  User defined command keys for screen 10.
     *
     C     zzcmd10       begsr
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
     C                   goto      endcm10
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm10       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD11  User defined command keys for screen 11.
     *
     C     zzcmd11       begsr
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
     C                   goto      endcm11
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
750cA*
750cA*  Test for F9  - Skip UPC verification
750cA*
750cAC                   if        *inki
750cAC                   eval      cmdtkn = *on
750cAC                   move      'SKPUPC '     rtcerid
750cAC                   exsr      zzexcp
750cAC                   exsr      scr12i
750cAC                   goto      endcm11
750cAC                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm11       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD12  User defined command keys for screen 12.
     *
     C     zzcmd12       begsr
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
     C                   goto      endcm12
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm12       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD13  User defined command keys for screen 13.
     *
     C     zzcmd13       begsr
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
     C                   goto      endcm13
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *
     *  Test for F8 - EXCEPTION - Catch Weight Override
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C                   eval      excode = '4'
     C                   exsr      zzexcp
     C                   eval      scode = '  '
     C                   goto      endcm13
     C                   else
     C                   move      *off          ovrrid
     C                   endif
     *
     *      F7 - kilograms/Pounds Toggle
     *
     C                   if        *inkg
     C                   eval      cmdtkn = *on
     C                   if        KiloLbs = 'P'
     C                   eval      KiloLbs = 'K'
     C                   eval      W13LBKG = 'Kgs'
     C                   Eval      *in40 = *off
     C                   else
     C                   eval      KiloLbs = 'P'
     C                   eval      W13LBKG = 'Lbs'
     C                   Eval      *in40 = *on
     C                   endif
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm13       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD14  User defined command keys for screen 14.
     *
     C     zzcmd14       begsr
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
     C                   goto      endcm14
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *
     *  F6 - Add item.
     *
     C                   if        *inkf
     *  Check option to allow add item.
     C                   if        opcadd <> 'Y'
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm3004
     C                   else
     *
     C                   if        w1dept = *blanks
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      e$lng = 'SP'
     C                   movel     descSP(5)     errmsg
     C                   other
     C                   movel     desc(5)       errmsg
     C                   endsl
     C                   exsr      zm03
     C                   else
     c                   exsr      scr15i
     C                   eval      cmdtkn = *oN
     C                   goto      endcm14
     C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm14       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD15  User defined command keys for screen 15.
     *
     C     zzcmd15       begsr
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
     C                   goto      endcm15
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     c                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     c                   endif
     C     endcm15       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD16  User defined command keys for screen 16.
     *
     C     zzcmd16       begsr
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
     C                   goto      endcm16
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm16       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD17  User defined command keys for screen 17.
     *
     C     zzcmd17       begsr
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
     C                   goto      endcm17
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm17       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD18  User defined command keys for screen 18.
     *
     C     zzcmd18       begsr
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
     C                   goto      endcm18
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm18       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD19  User defined command keys for screen 19.
     *
     C     zzcmd19       begsr
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
     C                   goto      endcm19
     C                   endif
     *
     *      F22 - Done scanning.
     *
     C                   if        *inkw
     C                   eval      cmdtkn = *on
      **** need to do the update
     c                   exsr      scr20i
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm19       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD20  User defined command keys for screen 20.
     *
     C     zzcmd20       begsr
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
     C                   goto      endcm20
     C                   endif
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm20       endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  ZZCMD21  User defined command keys for screen 21.
760aA*
760aAC     zzcmd21       begsr
760aAC                   eval      cmdtkn = *off
760aA*
760aA*  Test for F4 - Lookup
760aA*
760aAC                   if        *inkd
760aAC                   eval      cmdtkn = *on
760aAC                   z-add     0             row#
760aAC                   eval      row = rowin
760aAC                   z-add     0             col#
760aAC                   eval      col = colin
760aA*
760aAC                   select
760aA*
760aAC                   other
760aA*
760aA*     Cursor not on a valid lookup field.
760aA*
760aAC                   eval      error = *on
760aAC                   exsr      zm9905
760aAC                   endsl
760aAC                   goto      endcm21
760aAC                   endif
760aA*
760aA*  Command keys to check BEFORE verification and update.
760aA*
760aAC                   if        cmdchk = '*BEFORE '
760aA*
760aAC                   endif
760aA*
760aA*  Command keys to check AFTER verification and update.
760aA*
760aAC                   if        cmdchk = '*AFTER  '
760aAC                   endif
760aAC     endcm21       endsr
     *----------------------------------------------------------------
     *
     *  ZZCWGT   Calculate catch weight variance values.
     *
     C     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
     C                   if        opccwv = 'Y'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             exwg2
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     C                   z-add     0             swgt2
     *   Calc extended wt.
     C     woqt01        mult      #toitswgt     exwgt
     *   Calc extended wt for each item.
     C                   if        #toitumq2 <> 0
     C     #toitswgt     div       #toitumq2     swgt2
     C     woqt02        mult      swgt2         exwg2
     C                   add       exwg2         exwgt
     C                   endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
     C     #toitswgt     mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
     C     #toitswgt     sub       ilvar         ilrng
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
     C     #toitswgt     mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
     C     #toitswgt     add       ihvar         ihrng
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Create Exception record.
     *
     C     zzexcp        begsr
     C*                  eval      ivewhs = ivswhs
     C*                  eval      ivepag = ivspag
     C*                  eval      ivedsp = ivsdsp
     C*                  if        excode = '4'
     C*                  eval      ivesta = '4'
     C*                  else
     C*                  eval      ivesta = *on
     C*                  endif
     C*                  eval      ivewhd = ivswhd
     C*                  eval      iveasl = ivsasl
     C*                  eval      iveloc = ivsloc
     C*                  eval      ivelvl = ivslvl
     C*                  eval      ivehnd = ivshnd
     C*                  eval      ivestp = ivsstp
     C*                  eval      $cvcmd = '*CURCMD '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      iveedt = $cvd8o
     C*                  time                    iveetm
     C*                  eval      iveeby = ivttem
     C*                  eval      iveecd = excode
     C*                  write     iverec                               79
     C*                  if        *in79
     C*                  eval      error = *on
     C*                  exsr      zm71
     C*                  goto      endexc
     C*                  endif
750cA /free
750cA   // adding new exception file process - RTCEXCP
750cA   rtcewhse = w1whse;
750cA   if w2ctyp = '1';
750cA     rtceuid  = wksuid;
750cA   else;
750cA     rtceuid  = workingId;
750cA   endif;
750cA   rtcewhdp = $slwhdp;
750cA   rtcedisp = $sldisp;
750cA   rtceitem = $slitem;
750cA   rtcests = '1';
750cA   exsr zzgetcurrstamp;
750cA   rtcegdts  = currstampsys;
750cA   rtcegby  = #user;
750cA   rtcecdts = *loval;
750cA   rtcecby  = ' ';
750cA   write rtcerec;
750cA /end-free
     C     endexc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     C                   call      'GETWHSE'
     C                   parm                    #user
     C     w1whse        parm      0             #whse             3 0
     *
     C                   eval      w1dept = e$whdp

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Clear display field if necessary.
      /free
        w2ctyp = ' ';
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
      /free
        w3scope = 0;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
      /free
        w4page = 0;
740dA   setll (rtchuid: w1dept: w4page) workrtcs;
740dA   dow forevr = forevr;
740dA     reade(n) (rtchuid: w1dept) workrtcs;
740dA     if %eof(workrtcs);
740dA       leave;
740dA     endif;
740dA     if wkspage = 99999;
740dA       w4page = 99999;
740dA     endif;
740dA   enddo;
      /end-free
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     *
     *   Initialize entry fields
      /free
        w5adjcd = ' ';
      /end-free
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *
     C     zzfil6        begsr
     *
     *   Initialize entry fields
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 7 fields
     *
     C     zzfil7        begsr
     *
      /free
        w7item = ' ';
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *
     C     zzfil8        begsr
     *
     *   Initialize entry fields
     *
      /free
        w8disp = ' ';
        svdisp = ' ';
        pass = 1;
        touchedList = ' ';
        firstSlotEnt = ' ';
        trackLevel = ' ';
        additem = *off;
        initSC10 = *on;
        inprocess = *off;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL9   Fill screen 9 fields with info from file.
     *
     C     zzfil9        begsr
     *
     *   Initialize entry fields
     *
      /free
        svdisp = ' ';
        pass = 1;
        touchedList = ' ';
        firstSlotEnt = ' ';
        trackLevel = ' ';
        additem = *off;
        nomore = *off;
        // this is the scan slot field
        w9disp = ' ';
        w9slot  = ' ';
        select;
          when w2ctyp = '1';
            exsr zzgetworkrtcs;
            if nomore;
              exsr scr17i;
              leavesr;
            else;
              w9slot = wksbase;
              basedisp = w9slot;
            endif;
          when w2ctyp = '3';
            exsr zzgetworkrtci;
            if nomore;
              exsr scr17i;
              leavesr;
            else;
              w9slot = wkibase;
              basedisp = w9slot;
            endif;
          other;
        endsl;
        inprocess = *off;
        initSC10 = *off;

      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL10  Fill screen 10 fields with info from file.
     *
     C     zzfil10       begsr
     *
      /free
        w10item = ' ';
        w10slot = ' ';
        w10lcns = ' ';
        w10work = ' ';
        w10itema = ' ';
        w10itemb = ' ';
        select;
          when additem = *on;
            w10item = w16item;
            select;
              when w2ctyp = '1';
                w10slot = w9disp;
              when w2ctyp = '3';
                w10slot = w9disp;
              when w2ctyp = '4';
                w10slot = w8disp;
              other;
            endsl;
            w10work = %subst(#toitdesc:1:15);
            w10itema = %subst(#toitdesc:16:15);
            w10item = %TrimR(w10item) + '-'
                    + %TrimR(w10work);
            w10itemb = #toitpdsc;
            select;
              when $lnlcns <> ' ';
                w10lcns  = $lnlcns;
              other;
                w10lcns  = '*NONE';
            endsl;
          other;
            if not initSC10;
              exsr zzgetslot;
              if nomore;
                exsr scr14i;
                leavesr;
              else;
                w10item = $slitem;
PFCbD           //Select;
PFCbD             //when client = presto;
PFCbD             //  w10slot = %trim($sldisp) + '.';
PFCbD             //other;
                    w10slot = $sldisp;
PFCbD           //endsl;
              endif;
            else;
              w10slot = $sldisp;
              if ($slstat = 'V' or $slstat = 'Z');
                w10item = 'ITEM NOT FOUND';
                #toititem = ' ';
              else;
                w10item = $slitem;
              endif;
            endif;

            // initialize entry fields
            if $slstat = 'Z' or
               $slstat = 'V';
              exsr zztouch;
            else;
              w10work = %subst(#toitdesc:1:15);
              w10itema = %subst(#toitdesc:16:15);
              w10item = %TrimR(w10item) + '-'
                      + %TrimR(w10work);
              w10itemb = #toitpdsc;
CDIaA         if Client = cdi;
CDIaA           w10itemb = #toitvit#;
CDIaA         endif;
            endif;

            if trackLevel = tLow;
              w10lcns = 'n/a - Low';
            else;
              w10lcns = $saToLcns;
            endif;

            initSC10 = *off;
        endsl;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL11  Fill screen 11 fields with info from file.
     *
     C     zzfil11       begsr
     *
     *   Initialize entry fields
     *
      /free
        w11item = $slitem;
        w11uci = ' ';
        w11lcns = ' ';
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL12  Fill screen 12 fields with info from file.
     *
     C     zzfil12       begsr
     *
     *   Initialize entry fields
      /free
        if additem = *on;
          $slphy1 = 0;
          $slphy2 = 0;
          $slphy3 = 0;
        endif;
SGCaA   if Client = SGC
SGCaA      or client = glazier
EIa A      or client = EI;
SGCaA     w12qty1 = $slphy1;
SGCaA     w12qty2 = $slphy2;
SGCaA     w12qty3 = $slphy3;
SGCaA   else;
          w12qty1 = 0;
          w12qty2 = 0;
          w12qty3 = 0;
SGCaA   endif;
        w12uom1 = ' ';
        w12uom2 = ' ';
        w12uom3 = ' ';
        exsr zzuom;
        if opdqty = 'Y';
          w12stk1 = %trim(%editc($slphy1:'L'));
          w12stk2 = %trim(%editc($slphy2:'L'));
          w12stk3 = %trim(%editc($slphy3:'L'));
        endif;
      /end-free
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL13  Fill screen 13 fields with info from file.
     *
     C     zzfil13       begsr
     *
     *   Initialize entry fields
     *
      /free
        w13cwgt = 0;
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL14  Fill screen 14 fields with info from file.
     *
     C     zzfil14       begsr
     *
     *   Initialize entry fields
     *
      /free
        additem = *off;
        inprocess = *off;
        select;
          when w2ctyp = '1';
            w14disp = w9disp;
          when w2ctyp = '3';
            w14disp = w9disp;
          when w2ctyp = '4';
            w14disp = w8disp;
          other;
        endsl;
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL15  Fill screen 15 fields with info from file.
     *
     C     zzfil15       begsr
     *
     *   Initialize entry fields
     *
      /free
        w15lcns = ' ';
        w15uci = ' ';
        //additem = *on;
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL16  Fill screen 16 fields with info from file.
     *
     C     zzfil16       begsr
     *
     *   Clear display field if necessary.
      /free
        w16item = ' ';
        w16mfg# = ' ';
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL17  Fill screen 17 fields with info from file.
     *
     C     zzfil17       begsr
     *
     *   Clear display field if necessary.
      /free
        additem = *off;
        inprocess = *off;
        select;
          when w2ctyp = '1';
            w17text = 'Page ' + %char(w4page);
          when w2ctyp = '3';
            w17text = 'Item ' + w7item;
          other;
            w17text = ' ';
        endsl;
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL18  Fill screen 18 fields with info from file.
     *
     C     zzfil18       begsr
     *
     *   Clear display field if necessary.
      /free
        select;
          when additem = *On and $imltrk= 'U';
            w18type = '3';
          other;
            if w12qty1 = 0 and
               w12qty2 = 0 and
               w12qty3 = 0;
              w18type = '4';
            else;
              w18type = '3';
            endif;
        endsl;
        uciqty = 0;
        uciqty1= 0;
        uciqty2= 0;
        uciqty3= 0;
        uciwgt = 0;
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL19  Fill screen 19 fields with info from file.
     *
     C     zzfil19       begsr
     *
     *   Clear display field if necessary.
      /free
        w19uci = ' ';
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL20  Fill screen 20 fields with info from file.
     *
     C     zzfil20       begsr
     *
     *   Clear display field if necessary.
      /free
        w12qty1 = uciqty1;
        w12qty2 = uciqty2;
        w12qty3 = uciqty3;
      /end-free

     *
     C                   endsr
     *----------------------------------------------------------------
760aA*
760aA*  ZZFIL21  Fill screen 21 fields with info from file.
760aA*
760aAC     zzfil21       begsr
760aA*
760aA*   Clear display field if necessary.
760aA /free
760aA     select;
760aA       when #toitmflg = 'Y';
760aA         w21dteo = 'MFG Date';
760aA       other;
760aA         w21dteo = 'EXP Date';
760aA     endsl;
760aA   w21edte = *zero;
760aA /end-free
760aA*
760aAC                   endsr
     *----------------------------------------------------------------
     *  zzgetitem   Get item info
     *----------------------------------------------------------------

     C     zzgetitem     begsr

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
      /free
        if w2ctyp = '3';
          leavesr;
        endif;
      /end-free
     C                   eval      error = *off
     C                   eval      $itdesc = 'ITEM NOT FOUND'
     C                   eval      $imltrk = 'L'
     C                   endif

     C                   eval      #toititem = $ititem
     C                   eval      #toittype = $ittype
     C                   eval      #toitdesc = $itdesc
     C                   eval      #toitpdsc = $itpdsc
     C                   eval      #toitwhdp = $itwhdp
     C                   eval      #toitstyp = $itstyp
     C                   eval      #toitdesg = $itdesg
     C                   eval      #toitum1  = $itum1
     C                   eval      #toitflg1 = $itflg1
     C                   eval      #toitum2  = $itum2
     C                   eval      #toitumq2 = $itumq2
     C                   eval      #toitflg2 = $itflg2
     C                   eval      #toitum3  = $itum3
     C                   eval      #toitumq3 = $itumq3
     C                   eval      #toitnrpk = $imnrpk
     C                   eval      #toitflgd = $itflgd
760aAC                   eval      #toitmflg = $immflg
     C                   eval      #toitcube = $itcube
     C                   eval      #toitswgt = $itswgt
     C                   eval      #toitcwgt = $itcwgt
     C                   eval      #toitmitem = $itmitem
     C                   eval      #toitvit# = $itvit#

     C                   if        svpick  = 'Y'
     C                             or ($imltrk <> tlow
     C                                 and $imltrk <> tmedium
     C                                 and $imltrk <> thigh
     C                                 and $imltrk <> tUCI)
     C                   eval      trackLevel = tLow
     C                   else
     C                   eval      trackLevel = $imltrk
     C                   endif

     *  Use DRI interface to get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = w1whse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      ssbflg  = *off
     C                   eval      #tossbititem = ' '
     C                   eval      #tossbittype = ' '
     C                   eval      #tossbitdesc = ' '
     C                   eval      #tossbitpdsc = ' '
     C                   eval      #tossbitwhdp = ' '
     C                   eval      #tossbitstyp = ' '
     C                   eval      #tossbitdesg = ' '
     C                   eval      #tossbitum1  = ' '
     C                   eval      #tossbitum2  = ' '
     C                   eval      #tossbitumq2 = 0
     C                   eval      #tossbitum3  = ' '
     C                   eval      #tossbitumq3 = 0
     C                   eval      #tossbitvit# = ' '
     C                   else
     C                   eval      ssbflg  = *on
     C                   eval      #tossbititem = $ititem
     C                   eval      #tossbittype = $ittype
     C                   eval      #tossbitdesc = $itdesc
     C                   eval      #tossbitpdsc = $itpdsc
     C                   eval      #tossbitwhdp = $itwhdp
     C                   eval      #tossbitstyp = $itstyp
     C                   eval      #tossbitdesg = $itdesg
     C                   eval      #tossbitum1  = $itum1
     C                   eval      #tossbitum2  = $itum2
     C                   eval      #tossbitumq2 = $itumq2
     C                   eval      #tossbitum3  = $itum3
     C                   eval      #tossbitumq3 = $itumq3
     C                   eval      #tossbitvit# = $itvit#
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETSLOT   Get next slot
     *----------------------------------------------------------------

     C     zzGetSlot     begsr
     C                   eval      nomore = *on

     *  Save the first slot that was entered.

      /free
        if firstSlotEnt = ' ';
          select;
            when w2ctyp = '1';
              firstSlotEnt = w9disp;
            when w2ctyp = '3';
              firstSlotEnt = w9disp;
            other;
              firstSlotEnt = w8disp;
          endsl;
        endif;
      /end-free

     *  Multiple pass loop (pass is initialized in zzfil2)

     *    Pass 1 - Low tracked items or empty base slot.
     *    Pass 2 - Medium/High tracked items with non-'*' license.
     *    Pass 2 - Medium/High tracked items with '*' license.

     C                   dou       pass > 3

     *    First, check the first slot that was entered.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1dept
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = firstSlotEnt
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET2'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn <> '*OK'
     C                   leavesr
     C                   endif

     C                   exsr      zzGetSlotChk
     C                   if        useSlot
     C                   eval      nomore = *off
     C                   leavesr
     C                   endif

     *    If first slot entered is not a base slot, then grab it and leave.

      /free
        select;
          when w2ctyp= '1';
          when w2ctyp= '3';
          other;
            if w8disp = firstSlotEnt
               and w8disp <> baseDisp;
              nomore = *off;
              leavesr;
            endif;
        endsl;
      /end-free

     *    Otherwise, loop through the rest of the slots.

     *      Note, we do not clear the slot fields because we
     *      want to start with the one read above.


     C                   dow       forever = forever

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   if        $drireturn <> '*OK'
     C                             or $sacdsp <> baseDisp
     C                   eval      pass += 1
     C                   leave
     C                   endif

     C                   exsr      zzGetSlotChk
     C                   if        useSlot
     C                   eval      nomore = *off
     C                   leavesr
     C                   endif

     C                   enddo

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZGETSLOTCHK   Check if we can use slot
     *----------------------------------------------------------------

     C     zzGetSlotChk  begsr
     C                   eval      useSlot = *off

     *  See if slot has already been touched this round.
     *  If it has, leave.

     C                   eval      temp2A = $slhand

     C                   if        %subst(temp2A:1:1) = ' '
     C                   eval      %subst(temp2A:1:1) = '.'
     C                   endif

     C                   if        %subst(temp2A:2:1) = ' '
     C                   eval      %subst(temp2A:2:1) = '.'
     C                   endif

     C                   eval      touched = %scan('.'+temp2a: touchedList)
     C                   if        touched > 0
     C                   leavesr
     C                   endif

     *  Get item information.

      /free
        if ($slstat <> 'Z' and $slstat <> 'V');
          exsr zzgetitem;
        endif;
        if error = *on and $sldisp = basedisp and $satolcns = '*NONE';
          exsr zmcmsg;
          error = *off;
          exsr zztouch;
          leavesr;
        endif;
      /end-free

     *  If Pass 1 and slot is first entered slot and not a base slot,
     *    Then use slot.

     C                   if        pass = 1
     C                             and $sldisp = firstSlotEnt
     C                             and $sldisp <> baseDisp
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 1 and empty base slot,
     *    Then use slot.
      *  NO longer display on first pass if slot is Z or V

     C                   if        pass = 1
     C                             and $sldisp = baseDisp
     C                             and $slphy1 = 0
     C                             and $slphy2 = 0
     C                             and $slphy3 = 0
     c                             and $slstat <> 'Z'
     c                             and $slstat <> 'V'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 1 and Low tracking item,
     *    Then use slot.

     C                   if        pass = 1
     C                             and trackLevel = tLow
     c                             and $slstat <> 'Z'
     c                             and $slstat <> 'V'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 2 and Medium/High tracking item and non-'*' license,
     *    Then use slot.
     *  Treat tUCI just like high tracking item and non-'*' license,

     C                   if        pass = 2
     C                             and (trackLevel = tMedium
     C                                  or trackLevel = tUCI
     C                                  or trackLevel = tHigh)
     C                             and %subst($saToLcns:1:1) <> '*'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 3 and Medium/High tracking item and '*' license,
     *    Then use slot.
     *  Treat tUCI just like high tracking item and non-'*' license,

     C                   if        pass = 3
     C                             and (trackLevel = tMedium
     C                                  or trackLevel = tUCI
     C                                  or trackLevel = tHigh)
     C                             and %subst($saToLcns:1:1) = '*'
     c                             and $saToLcns <> '*NONE'
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     *  If Pass 3 and no vituals were counted we at least need them
     *    to count the base slot.
     *    tracking level blank implies no slot

     C                   if        pass = 3
     C                             and trackLevel = ' '
     C*                            and (trackLevel = tMedium
     C*                                 or trackLevel = tUCI
     C*                                 or trackLevel = tHigh
     C*                                 or trackLevel = ' ')
     C                             and %subst($saToLcns:1:1) = '*'
     c                             and $saToLcns = '*NONE'
     C                             and $sldisp = baseDisp
     C                             and touchedlist = ' '
     C                   eval      useSlot = *on
     C                   leavesr
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzgetuciwgt Get weights for each license from uciinfo
     *----------------------------------------------------------------

     C     zzgetuciwgt   begsr

      /free
        w13cwgt =0;
        setll (w1whse: w1dept: w10slot) licactive1;
        dow forevr = forevr;
          reade (w1whse: w1dept: w10slot) licactive1;
          if %eof(licactive1);
            leave;
          endif;
          exsr clr$uciinfo;
          licwgt = 0;
          $uiwhse  = w1whse;
          $uilcns = lalcns;
          $dricommand = '*UCIINFO';
          $drisubcmd  = '%GETLICWGT';
          $drisys2upd = 'D';
          exsr zzzdricop;
          if $drireturn = '*LICWGT';
            licwgt = %dec($drimessage:7:0) * .01;
            w13cwgt = w13cwgt + licwgt;
          endif;
        enddo;
      /end-free

     C                   endsr

     *----------------------------------------------------------------
     *  zzgetworkrtci  get slots from workrtci
     *----------------------------------------------------------------

     C     zzgetworkrtci begsr
      /free
        setll (#user: w7item) workrtci;
        dow forevr = forevr;
          reade(n) (#user: w7item) workrtci;
          if %eof(workrtci);
            nomore = *on;
            leave;
          endif;
          if wkicount = 'Y';
            iter;
          endif;
          leave;
        enddo;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *  zzgetworkrtcs  get slots from workrtcs
     *----------------------------------------------------------------

     C     zzgetworkrtcs begsr
      /free
        setll (rtchuid: w1dept: w4page) workrtcs;
        dow forevr = forevr;
          reade(n) (rtchuid: w1dept: w4page) workrtcs;
          if %eof(workrtcs);
            nomore = *on;
            leave;
          endif;
          if wkscount = 'Y';
            iter;
          endif;
          leave;
        enddo;
      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *     INVSCW file -
     C*    cwkey         klist
     C*                  kfld                    w1whse
     C*                  kfld                    ivswhd
     C*                  kfld                    ivsdsp
     C*                  kfld                    ivsitm
     *     ITEMMSC file -
     *
     C     imkey         klist
     C                   kfld                    w1whse
     C                   kfld                    $slitem
     *  Define key for LABEL90 file
     *
     C     lbkey         klist
     C                   kfld                    w1whse
     C                   kfld                    litrn#
     *
     *  Define key for License file
     *
     C     likey         klist
     C                   kfld                    w1whse
     C                   kfld                    kylic
     *
     *     OPTIONS file
     C     opkeys        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *
     *
     *  Define key for UCI file.
     *
     C*    keyuci        klist
     C*                  kfld                    w1whse
     C*                  kfld                    kyuci
     *  Define key for UPC file.
     *
     C     upckey        klist
     C                   kfld                    w1whse
     C                   kfld                    kyupc
     *
     *  Define partial key for INVTEAM file.
     *
     C*    vtkey         klist
     C*                  kfld                    w1whse
     C*                  kfld                    woidte
     C*                  kfld                    w1team
     *
     C                   eval      $pprg = #prog
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Get employee options.
     *
     *  Set language to english until Jordano's is updated to V5.0
     C                   eval      e$lng = 'EN'
     C                   call      'GETUSER'
     C                   parm      #user         e$code           10
     C                   parm                    e$whse            3 0
     C                   parm                    e$emp#            5 0
     C                   parm                    e$fnam           15
     C                   parm                    e$init            1
     C                   parm                    e$lnam           20
     C                   parm                    e$whdp            5
     C                   parm                    e$styp            1
     C                   parm                    e$shft            6
     C                   parm                    e$crew            6
     C                   parm                    e$nhrs            3 1
     C                   parm                    e$rtn             8
     C                   if        e$rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     C                   eval      worow = *zeros
     C                   eval      wocol = *zeros
     *   Get options
     C                   exsr      zzoptn
     *
     *   Select first screen to display.
     *
     C                   exsr      scr01i
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZOPTN   Get options
     *
     C     zzoptn        begsr
     *   Get Inv count options.
     C                   eval      wkcode = '*RTC    '
     C                   eval      wkwhse = e$whse
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcupc = 'N'
     C                   eval      opcadd = 'N'
     C                   eval      opccwt = 'N'
     C                   eval      opcadj = 'N'
     C                   eval      opccwv = 'N'
     C                   else
     C                   move      opdata        opdat1
      * temporary until options are created
     c                   if        opcadj = ' '
     C                   eval      opcadj = 'Y'
     c                   endif
     c                   if        opccwv = ' ' and opccwt = 'Y'
     C                   eval      opccwv = 'Y'
     c                   endif
     C                   endif
     C*
     *   Get Item Maint Options
      /free
         getimuom(e$whse: BegKilolbs: IMUom);
         select;
           when Begkilolbs = 'K';
             KiloLbs = 'K';
             eval *In40 = *off;
             W13LBKG =IMUom;
           other;
             kiloLbs = 'P';
             eval *In40 = *on;
             W13LBKG ='Lbs';
         endsl;
      /end-free
     *
     *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
     C                   endif
     C*
     C                   endsr

     *----------------------------------------------------------------
     *  ZZTOUCH        Mark slot as touched
     *----------------------------------------------------------------

     C     zzTouch       begsr

     c                   if        additem = *on
     C                   eval      temp2A = bfr$slot.$slhand
     c                   else
     C                   eval      temp2A = $slhand
     c                   endif

     C                   if        %subst(temp2A:1:1) = ' '
     C                   eval      %subst(temp2A:1:1) = '.'
     C                   endif

     C                   if        %subst(temp2A:2:1) = ' '
     C                   eval      %subst(temp2A:2:1) = '.'
     C                   endif

     C                   eval      touched = %scan('.'+temp2a: touchedList)
     C                   if        touched > 0
     C                   leavesr
     C                   endif
     C                   eval      touchedList = %trim(touchedList)
     C                                         + '.' + temp2A

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure
     *
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     *
     C                   if        #toititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
     C                   if        ssbflg = *off and
     C                             #toitflg1 = 'N'
     C                   eval      *in92 = *on
     C                   endif
     C                   if        ssbflg = *off and
     C                             #toitflg2 = 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     C                   if        #toitum2 = *blanks
     C                   eval      *in92 = *on
     C                   endif
     C                   if        #toitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     *
     C     #toitum1      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      W12UOM1 = umshrt
     C                   else
     C                   eval      W12UOM1 = ' '
     C                   endif
     *
     C                   if        not *in92
     C     #toitum2      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      W12UOM2 = umshrt
     C                   else
     C                   eval      W12UOM2 = ' '
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     C     #toitum3      chain     unmesr                             75
     C                   if        not *in75
     C                   eval      W12UOM3 = umshrt
     C                   else
     C                   eval      W12UOM3 = ' '
     C                   endif
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPCK   Create Inventory Check record
     *
     C     zzupck        begsr
     C*                  eval      ivcwhs = ivswhs
     C*                  eval      ivcdsp = ivsdsp
     C*                  eval      ivcsta = *on
     C*                  eval      ivcwhd = ivswhd
     C*                  eval      ivcasl = ivsasl
     C*                  eval      ivcloc = ivsloc
     C*                  eval      ivclvl = ivslvl
     C*                  eval      ivchnd = ivshnd
     C*                  eval      ivcstp = ivsstp
     C*                  eval      $cvcmd = '*CURCMD '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      ivcsdt = $cvd8o
     C*                  time                    ivcstm
     C*                  eval      ivceby = ivttem
     C*                  eval      ivcedt = $cvd8o
     C*                  movel     '*PNDQTY'     ivcrsn
     C*                  write     ivcrec                               79
     C*                  if        *in79
     C*                  eval      error = *on
     C*                  exsr      zm71
     C*                  goto      endckc
     C*                  endif
     C     endckc        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     *
     *  Move screen fields to parameter fields.
     *
     C                   eval      $pwhse = w1whse
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     *
     *   Convert date and save.
     C*                  eval      $cvcmd = '*MDYCMD '
     C*                  move      w1idte        $cvd6i
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      woidte = $cvd8o
     *
     *
     c                   eval      $pwhse = w1whse
     C                   exsr      scr02i
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
      * we need to call the program to create the new uid
      /free
        refrsh = *on;
        select;
          when w2ctyp = '1';
            exsr scr03i;
          other;
            // create header
            pwhse = w1whse;
            pcnttype = %dec(w2ctyp:2:0);
            pid = 0;
            pcmd = 'ADD';
            updrtch(pwhse: pcmd: pid: pcnttype);
            workingId = pid;
            exsr scr05i;
        endsl;
      /end-free

     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
      /free
        error = *off;
        refrsh = *on;
        // we are using pages
        exsr scr04i;
      /end-free

     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     *
      /free
        error = *off;
        refrsh = *on;
        exsr scr09i;
      /end-free
     C     endup4        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
      /free
        select;
          when w2ctyp = '1';
            exsr scr04i;
          when w2ctyp = '2';
          when w2ctyp = '3';
            exsr scr07i;
          when w2ctyp = '4';
            exsr scr08i;
        endsl;
      /end-free

     C     endup5        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 6.
     *
     C     zzupd6        begsr
     C                   eval      error = *off
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C     endup6        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD7   Update for screen 7.
     *
     C     zzupd7        begsr
      /free
        error = *off;
        refrsh = *on;
        exsr buildworkrtci;
        exsr scr09i;
      /end-free
     C     endup7        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD8   Update for screen 8.
     *
     C     zzupd8        begsr
      /free
        error = *off;
        if firstSlotEnt = ' ';
          exsr zzGetSlot;
          if nomore;
            initSC10 = *on;
            exsr scr14i;
            leavesr;
          endif;
        endif;

        initSC10 = *on;
        exsr scr10i;

      /end-free
     C     endup8        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
      /free
        exsr scr10i;
      /end-free

     C     endup9        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD10  Update for screen 10.
     *
     C     zzupd10       begsr
      /free
        refrsh = *on;
        woupc = *blanks;
        *in94 = *on;
        select;
          when additem = *on and $imltrk = 'U';
            exsr scr18i;
          other;
750bD       //if opcupc = 'Y';
750bM       if opcupc = 'Y'
750bA          and w10item <> 'ITEM NOT FOUND';
              exsr scr11i;
            else;
              exsr scr12i;
            endif;
        endsl;
      /end-free

     C     endup10       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD11  Update for screen 11.
     *
     C     zzupd11       begsr
     C                   exsr      scr12i

     C     endup11       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD12  Update for screen 12.
     *
     C     zzupd12       begsr
     *
      /free
        if $imltrk = 'U'
           and (w12qty1 <> $slphy1 or
                w12qty2 <> $slphy2 or
                w12qty3 <> $slphy3);
          exsr scr18i;
        else;
      /end-free
     *  Capture CW if catch weight item if option = Y and
     *  item is cw item.
      /free
        woqt01 = W12QTY1;
        woqt02 = W12QTY2;
        woqt03 = W12QTY3;
        Select;
          //when $imltrk = 'U';
            // get uci's and post adjustment
            // then check for more to count for the slot
          when client = packers;
            // post adjustment
            // then check for more to count for the slot
          when opccwt = 'Y' and
               #toitcwgt = 'Y';
            // if the qty is zero don't ask for weight
            if w12qty1 = 0 and
               w12qty2 = 0 and
               w12qty3 = 0 or
               $imltrk = 'U'
                and (w12qty1 = $slphy1 and
                     w12qty2 = $slphy2 and
                     w12qty3 = $slphy3);
              // uci tracked will get the weight, for adjustment.
              exsr zzgetuciwgt;
              // post adjustment
              exsr zzadjust;
              exsr zzTouch;
              inprocess = *on;
              // then check for more to count for the slot
              if additem = *on;
                exsr scr14i;
              else;
                exsr scr10i;
              endif;
            else;
              // get weight
              exsr scr13i;
            endif;
          when opccwt = 'Y' and
               #toitcwgt <> 'Y'
               or opccwt = 'N';
            // post adjustment
            exsr zzadjust;
            exsr zzTouch;
            inprocess = *on;
            // then check for more to count for the slot
            if additem = *on;
              exsr scr14i;
            else;
              exsr scr10i;
            endif;
          other;
        endsl;
        endif;
      /end-free


     C     endup12       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD13  Update for screen 13.
     *
     C     zzupd13       begsr
      /free
        exsr zzadjust;
        exsr zzTouch;
        error = *off;
        ovrrid = *off;
        wtchk = *off;
        refrsh = *on;
        w13cwgt = 0;
        lwrng = 0;
        hirng = 0;
        inprocess = *on;
        // then check for more to count for the slot
        if additem = *on;
          exsr scr14i;
        else;
          exsr scr10i;
        endif;
      /end-free

     C     endup13       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD14  Update for screen 14.
     *
     C     zzupd14       begsr
      /free
        select;
          when w2ctyp = '3';
            chain (#user: w7item: basedisp) workrtci;
            if %found(workrtci);
              wkicount = 'Y';
              update wkirec;
            endif;
730aA       // update rtchsth
730aA       pwhse = w1whse;
730aA       pcnttype = %dec(w2ctyp:2:0);
730aA       //pid = wksuid;
730aA       pcmd = 'UPDATE';
730aA       updrtch(pwhse: pcmd: pid: pcnttype);
            exsr scr09i;
          when w2ctyp = '1';
740aD       //chain (rtchuid: w1dept: w4page: basedisp) workrtcs;
740aM       chain (rtchuid: w1dept: w4page: wksseq) workrtcs;
            if %found(workrtcs);
              wkscount = 'Y';
              update wksrec;
            endif;
            // update rtchsth
            pwhse = w1whse;
            pcnttype = %dec(w2ctyp:2:0);
            pid = wksuid;
            pcmd = 'UPDATE';
            updrtch(pwhse: pcmd: pid: pcnttype);
            exsr scr09i;
          other;
730aA       // update rtchsth
730aA       pwhse = w1whse;
730aA       pcnttype = %dec(w2ctyp:2:0);
730aA       //pid = wksuid;
730aA       pcmd = 'UPDATE';
730aA       updrtch(pwhse: pcmd: pid: pcnttype);
            exsr scr08i;
        endsl;
      /end-free

     C     endup14       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD15  Update for screen 15.
     *
     C     zzupd15       begsr
      /free
        select;
          when $litodisp <> ' ';
            // THIS DOES TRANSFER, THEN goto screen10                  i
            exsr zztfr;
            pass = 1;
            // i was turning off until 5/9
            initSC10 = *on;
            exsr scr10i;
          when $lnlcns <> ' ';
            // license wasn't found - will need to adjust in and send the
            // license to lt210 hopefully
            additem = *on;
            w16item = $lnitem;
            $slitem = $lnitem;
            $saToLcns = $lnlcns;
            exsr zzgetitem;
            pass = 1;
            initSC10 = *on;
            exsr scr10i;
          when w15uci <> ' ';
            additem = *on;
            w16item = upitem;
            $slitem = upitem;
            exsr zzgetitem;
            pass = 1;
            initSC10 = *on;
            exsr scr10i;
          other;
            exsr scr16i;
            leavesr;
        endsl;
      /end-free

     C     endup15       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD16  Update for screen 16.
     *
     C     zzupd16       begsr
760aA * if Item is date sensitive, display screen21 to get date
      /free
760aA   itemIsMfg = *off;
760aA   itemIsExp = *off;
760aA   select;
760aA     when #toitflgd = 'Y';
760aA       select;
760aA         when #toitmflg = 'Y';
760aA           itemIsMfg = *on;
760aA         other;
760aA           itemIsExp = *on;
760aA       endsl;
760aA       refrsh = *on;
760aA       exsr scr21i;
760aA     other;
      //we need to call the program to create the new uid
        refrsh = *on;
        additem = *on;
        exsr scr10i;
760aA   endsl;
      /end-free

     C     endup16       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD17  Update for screen 17.
     *
     C     zzupd17       begsr
     C                   eval      refrsh = *on
      /free
        select;
          when w2ctyp = '1';
            // update rtchsth
            pwhse = w1whse;
            pcnttype = %dec(w2ctyp:2:0);
            pid = wksuid;
            pcmd = 'UPDATE';
            updrtch(pwhse: pcmd: pid: pcnttype);
750dA       if w4page = 99999;
750dA         exsr scr03i;
750dA       else;
              exsr scr04i;
750dA       endif;
          when w2ctyp = '3';
            exsr scr07i;
        endsl;
      /end-free

     C     endup17       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD18  Update for screen 18.
     *
     C     zzupd18       begsr
      * we need to call the program to create the new uid
     C                   time                    $ppartime
      /free
        refrsh = *on;

        if w18type = '3';
          exsr scr19i;
        else;
          // adjust out all the uci's attached to the licenses in the slot
          // lets remove any uci's attached to the slot
          exsr clr$uciinfo;

          $uiWhse = w1whse;
          $uiapartlts = $ppartime;
          // We need to remove the uci's attached to any licenses for
          // the slot they are updating.
          // Loop thru the licative for this slot, send the license and the
          // and the scan time to driuciinfo.
          // Will need to bring back one at a time in order to adjust
          // the uci out of the system.
          setll (w1whse: w1dept: w10slot) licactive1;
          dow forevr = forevr;
            reade (w1whse: w1dept: w10slot) licactive1;
            if %eof(licactive1);
              leave;
            endif;
            $uilcns = lalcns;
            // now we have a license for the slot being adjusted
            // do we have any uci's that were not scanned?
            dow forevr = forevr;
              $dricommand = '*UCIINFO';
              $drisubcmd  = '%GETMISUCI';
              $drisys2upd = 'D';
              exsr zzzdricop;
              if $drireturn  = '*OK';
                // need to adjust out this uci.
                exsr zzadjout;
                // if we encounter any errors from Drislot - get out
                if $drireturn  <> '*OK';
                  leave;
                endif;
              else;
                leave;
              endif;
            enddo;
          enddo;
          // we are done get out of here
          exsr zzTouch;
          // then check for more to count for the slot
          exsr scr10i;
        endif;
      /end-free

     C     endup18       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD19  Update for screen 19.
     *
     C     zzupd19       begsr
      * we need to call the program to create the new uid
     C                   move      *off          error
     C                   eval      refrsh = *on
      /free
        Select;
          When W18type = '3';
            // are we updating an existing uci

            if $uiaction = 'ADJSTART';
              $uiWhse = W1whse;
              $uiuci  = w19uci;
              $uiapartlts = $ppartime;

              // Lets add some more stuff for tracking
              $uiAolcns = $uiAolcns;
              $uiAoseq = $uiAoseq;
              $uiscan = 'Y';
              $dricommand = '*UCIINFO';
              $drisubcmd  = '%UPDPARTL';
              $drisys2upd = 'D';
              exsr zzzdricop;
              // if return is *OK we updated the uci record
              if $drireturn <> '*OK';
                error = *on;
                *in21 = *on;
                *in01 = *on;
                errmsg = 'problem updating uci';
                exsr zm0105;
                leavesr;
              endif;
              select;
                when $uiautyp = 'N';
                  uciqty1 = uciqty1 + 1;
                when $uiautyp = '1';
                  uciqty2 = uciqty2 + 1;
                when $uiautyp = '2';
                  uciqty3 = uciqty3 + 1;
                other;
                  uciqty1 = uciqty1 + 1;
              endsl;
              uciqty = uciqty + 1;
              if $uiwgtlbs > 0;
                uciwgt = uciwgt + $uiwgtlbs;
              endif;
            endif;

            // are we adding a new uci
            if $uiaction = 'ADJADD';
              $uiWhse = W1whse;
              $uiuci  = w19uci;
              $uiapartlts = $ppartime;
              // load up any additional information extracted from barcode
              if $bcgtinsent;
                $uiagtin = %dec($bcgtin:14:0);
              endif;
              if $bclotsent;
                $uialot = $bclot;
              endif;
              if $bcSer#Sent;
                $uiserial = $bcSer#;
              endif;
              if $bcPNtLbSent;
                $uiWgtlbs = $bcPNtLb;
              endif;
              //if $bcPNtKgSent;
                //$uiWgtKgs = $bcPNtKg;
              //endif;
              $uiautyp = uputyp;
              $uiaslutyp = uputyp;

              // Lets add some more stuff for tracking
              $uiaolcns = '*BFCADJADD';
              $uialcns = '*BFCADJADD';
              $uilcns = '*BFCADJADD';
              $uiaentd = today;
              $uiscan = 'Y';
              // load some exception data since we don't know how
              // this uci got in the warehouse
              $uiexccode = 'UNKNWORG';
              $uiexcstat = '1';
              $dricommand = '*UCIINFO';
              //$drisubcmd  = '%UPDPARTL';
              $drisubcmd  = '%ADD';
              $drisys2upd = 'D';
              exsr zzzdricop;
              // if return is *OK we updated the uci record
              if $drireturn <> '*OK';
                error = *on;
                *in21 = *on;
                *in01 = *on;
                errmsg = 'problem updating uci';
                exsr zm0105;
                leavesr;
              endif;
              select;
                when $uiautyp = 'N';
                  uciqty1 = uciqty1 + 1;
                when $uiautyp = '1';
                  uciqty2 = uciqty2 + 1;
                when $uiautyp = '2';
                  uciqty3 = uciqty3 + 1;
                other;
                  uciqty1 = uciqty1 + 1;
              endsl;
              uciqty = uciqty + 1;
              if $uiwgtlbs > 0;
                uciwgt = uciwgt + $uiwgtlbs;
              endif;
              //if $uiwgtkgs > 0;
                //uciwgt = uciwgt + $uiwgtkgs;
              //endif;

            endif;
            w19uci = ' ';
        endsl;
      /end-free

     C     endup19       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD20  Update for screen 20.
     *
     C     zzupd20       begsr
     *   On Type 3 - we will need to handle each uci one at a time
     *   to determine the proper function. will we transfer, do an
     *   internal or external adjustment.
      /free
        addcount = 0;
        if w18type = '3';
          // Now lets deal with any missing uci's for this slot/license
          exsr clr$uciinfo;

          $uiWhse = w1whse;
          $uiapartlts = $ppartime;
          // Before we start processing what they did scan.
          // We need to remove the uci's attached to any licenses for
          // the slot they are updating that they didn't scan.
          // Loop thru the licative for this slot, send the license and the
          // and the scan time to driuciinfo.
          // Will need to bring back one at a time in order to adjust
          // the uci out of the system.
          // do not do this part if additem = *on
          if additem = *off;
            setll (w1whse: w1dept: w10slot) licactive1;
            dow forevr = forevr;
              reade (w1whse: w1dept: w10slot) licactive1;
              if %eof(licactive1);
                leave;
              endif;
              $uilcns = lalcns;
              // now we have a license for the slot being adjusted
              // do we have any uci's that were not scanned?
              dow forevr = forevr;
                $dricommand = '*UCIINFO';
                $drisubcmd  = '%GETMISUCI';
                $drisys2upd = 'D';
                exsr zzzdricop;
                if $drireturn  = '*OK';
                  // need to adjust out this uci.
                  exsr zzadjout;
                  // if we encounter any errors from Drislot - get out
                  if $drireturn  <> '*OK';
                    leave;
                  endif;
                else;
                  leave;
                endif;
              enddo;
            enddo;
          endif;

          // now lets process what they did scan
          // let's process each uci one at a time.
          addcount = 0;
          dow forevr = forevr;
            exsr clr$uciinfo;

            $uiWhse = w1whse;
            $uiapartlts = $ppartime;
            $dricommand = '*UCIINFO';
            $drisubcmd  = '%GETADJUCI';
            $drisys2upd = 'D';
            exsr zzzdricop;
            if $drireturn  = '*OK';
              // is the license for this uci already in the slot
              chain (w1whse: w1dept: w10slot: $uilcns) licactive9;
              if %found(licactive9);
              else;
                lalcns = ' ';
              endif;
              // PICK SLOT?
              select;
                when svpick   = 'Y';

                  select;
                  // is the uci already in this slot?
                    when lalcns    = $uilcns and lalcns <> ' ';
                      // just remove time stamp from the uci nothing needs
                      // to be adjusted for this uci.
                      $dricommand = '*UCIINFO';
                      $drisubcmd  = '%RMVADJTIM';
                      $drisys2upd = 'D';
                      exsr zzzdricop;
                      if $drireturn  = '*OK';
                      endif;
                      iter;
                    when $uilcns = '*BFCADJADD' or
                         $uilcns = ' ';
                      // these are not currently showing in inventory
                      // adjust in qty of 1 and send to host
                      exsr zzadjin;
                      // now remove time stamp from the uci that was
                      // just transferred.
                      $dricommand = '*UCIINFO';
                      $drisubcmd  = '%RMVADJTIM';
                      $drisys2upd = 'D';
                      exsr zzzdricop;
                      if $drireturn  = '*OK';
                      endif;
                      iter;
                    when lalcns    <> $uilcns;
                      // transfer to slot
                      exsr clr$license;
                      $liToWhseU = *on;
                      $liToWhse = w1Whse;
                      $liToLcnsU = *on;
                      $liToLcns = $uilcns;
                      $dricommand = '*LICENSE';
                      $drisubcmd  = '%GETLCNS';
                      $drisys2upd = 'D';
                      chk4err = *on;
                      exsr zzzdricop;
                      if w10slot = $LITOdisp;
                        // already working with this display. should not
                        // need to do anything. this should only happen for
                        // pick slots.
                        // just remove time stamp from the uci nothing needs
                        // to be adjusted for this uci.
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%RMVADJTIM';
                        $drisys2upd = 'D';
                        exsr zzzdricop;
                        if $drireturn  = '*OK';
                        endif;
                        iter;
                      else;
                        // will need to transfer uci to the slot/license
765aA                   exsr clr$slot;
765aA                   $slwhseu = *on;
765aA                   $slwhse  = w1whse;
765aA                   $slwhdpu = *on;
765aA                   $slwhdp = lawhdp;
765aA                   $sldispu  = *on;
765aA                   $sldisp   = ladisp;
765aA                   $dricommand = '*SLOT';
765aA                   $drisubcmd  = '%GET';
765aA                   $drisys2upd = 'D';
765aA                   chk4err = *on;
765aA                   zmsflag = *off;
765aA                   exsr zzzdricop;

                        exsr zzchktfr;
                        exsr zztfr;
                        // now remove time stamp from the uci that was
                        // just transferred.
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%RMVADJTIM';
                        $drisys2upd = 'D';
                        exsr zzzdricop;
                        if $drireturn  = '*OK';
                        endif;
                        iter;
                      endif;
                  endsl;
                when svpick    <> 'Y';
                  // is the uci already in this slot?
                  select;
                    when lalcns    = $uilcns and lalcns <> ' ';
                      // just remove time stamp from the uci nothing needs
                      // to be adjusted for this uci.
                      $dricommand = '*UCIINFO';
                      $drisubcmd  = '%RMVADJTIM';
                      $drisys2upd = 'D';
                      exsr zzzdricop;
                      if $drireturn  = '*OK';
                      endif;
                      iter;
                    when $uilcns = '*BFCADJADD' or
                         $uilcns = ' ';
                      // these are not currently showing in inventory
                      // adjust in qty of 1 and send to host
                      exsr zzadjin;
                      // now remove time stamp from the uci that was
                      // just transferred.
                      $dricommand = '*UCIINFO';
                      $drisubcmd  = '%RMVADJTIM';
                      $drisys2upd = 'D';
                      exsr zzzdricop;
                      if $drireturn  = '*OK';
                      endif;
                      iter;
                    when lalcns    <> $uilcns;
                      exsr clr$license;
                      $liToWhseU = *on;
                      $liToWhse = w1Whse;
                      $liToLcnsU = *on;
                      $liToLcns = $uilcns;
                      $dricommand = '*LICENSE';
                      $drisubcmd  = '%GETLCNS';
                      $drisys2upd = 'D';
                      chk4err = *on;
                      exsr zzzdricop;
                      if w10slot = $LITOdisp;
                        // already working with this display. should not
                        // need to do anything. this should only happen for
                        // pick slots.
                        // just remove time stamp from the uci nothing needs
                        // to be adjusted for this uci.
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%RMVADJTIM';
                        $drisys2upd = 'D';
                        exsr zzzdricop;
                        if $drireturn  = '*OK';
                        endif;
                        iter;
                      else;
                        // We need to make internal adjustments out/in e
                        exsr zzintout;
                        exsr zzintin;
                        // now remove time stamp from the uci that was
                        // just transferred.
                        $dricommand = '*UCIINFO';
                        $drisubcmd  = '%RMVADJTIM';
                        $drisys2upd = 'D';
                        exsr zzzdricop;
                        if $drireturn  = '*OK';
                        endif;
                        iter;
                      endif;
                  endsl;
              endsl;
            endif;
            // we are done get out of here
            exsr zztouch;
            //exsr zzrtchstd;
            if additem = *on;
              exsr scr14i;
            else;
              exsr scr10i;
            endif;
            leavesr;
          enddo;
        endif;
        if w18type = '4';
          // lets remove any uci's attached to the slot
          exsr clr$uciinfo;

          $uiWhse = w1whse;
          $uiapartlts = $ppartime;
          // We need to remove the uci's attached to any licenses for
          // the slot they are updating.
          // Loop thru the licative for this slot, send the license and the
          // and the scan time to driuciinfo.
          // Will need to bring back one at a time in order to adjust
          // the uci out of the system.
          setll (w1whse: w1dept: w10slot) licactive1;
          dow forevr = forevr;
            reade (w1whse: w1dept: w10slot) licactive1;
            if %eof(licactive1);
              leave;
            endif;
            $uilcns = lalcns;
            // now we have a license for the slot being adjusted
            // do we have any uci's that were not scanned?
            dow forevr = forevr;
              $dricommand = '*UCIINFO';
              $drisubcmd  = '%GETMISUCI';
              $drisys2upd = 'D';
              exsr zzzdricop;
              if $drireturn  = '*OK';
                // need to adjust out this uci.
                exsr zzadjout;
                // if we encounter any errors from Drislot - get out
                if $drireturn  <> '*OK';
                  leave;
                endif;
              else;
                leave;
              endif;
            enddo;
          enddo;
          // we are done get out of here
          exsr zztouch;
          //exsr zzrtchstd;
          if additem = *on;
            exsr scr14i;
          else;
            exsr scr10i;
          endif;
          leavesr;
        endif;

      /end-free

     C     endup20       endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  ZZUPD21  Update for screen 21.
760aA*
760aAC     zzupd21       begsr
760aA * we need to call the program to create the new uid
      /free
        refrsh = *on;
        additem = *on;
        exsr scr10i;
      /end-free

760aAC     endup21       endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDCW  Update INVSCW
     *
     C     zzupdcw       begsr

     C*    cwkey         chain     invscw                             75
     C*                  if        not *in75
     C*                  eval      $cvcmd = '*CURCMD '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      ivwedt = $cvd8o
     C*                  time                    ivwetm
     C*                  eval      ivweby = ivttem
     C*                  eval      ivwwgt = taddw
     c*                  eval      ivwlrg = lwrng
     c*                  eval      ivwhrg = hirng
     c*                  eval      ivwwtx = ovrrid
     C*                  update    ivwrec
     C*                  else
     C*                  eval      $cvcmd = '*CURCMD '
     C*                  call      @cvtdt
     C*                  parm                    $cvtdt
     C*                  eval      ivwedt = $cvd8o
     C*                  time                    ivwetm
     C*                  eval      ivweby = ivttem
     C*                  eval      ivwwhs = ivswhs
     C*                  eval      ivwdsp = ivsdsp
     C*                  eval      ivwwhd = ivswhd
     C*                  eval      ivwasl = ivsasl
     C*                  eval      ivwloc = ivsloc
     C*                  eval      ivwlvl = ivslvl
     C*                  eval      ivwhnd = ivshnd
     C*                  eval      ivwstp = ivsstp
     C*                  eval      ivwitm = ivsitm
     C*                  eval      ivwsid = ivssid
     C*                  eval      ivwwgt = taddw
     C*                  eval      ivwlrg = lwrng
     C*                  eval      ivwhrg = hirng
     C*                  eval      ivwwtx = ovrrid

     C*                  write     ivwrec
     C*                  endif
     C*                  if        %error
     C*                  goto      endupdcw
     C*                  endif

     C     endupdcw      endsr
     *---------------------------------------------------------------
     *  Retrieve number of pick slots for item and accumulate
     *  number of pick slots assigned to item.
     *
     C     chkpck        begsr
      /free
        chain (w1whse: w16item) itemmsc;
        if not %found(itemmsc);
          imnrpk = 1;
        endif;
      /end-free
     *
     *    Accumulate number of pick slots assigned to item.
     *
      /free
        k3stat = 'A ';
        k3pick = 'Y ';
        setll (w1whse: w16item: k3stat: k3pick) slot3;
        nbrpck = 0;
        dow forevr = forevr;
          reade (w1whse: w16item: k3stat: k3pick) slot3;
          if %eof(slot3);
            leave;
          endif;
          nbrpck = nbrpck + 1;
          iter;
        enddo;
      /end-free
     *
     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$item  Clear $item data structure fields
     *----------------------------------------------------------------

     C     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$license  Clear $license data structure fields
     *----------------------------------------------------------------

     C     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = 0
     C                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

     *----------------------------------------------------------------
     *  clr$licinfo  Clear $licinfo data structure fields
     *----------------------------------------------------------------

     C     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   clear                   $licinfo2
     C                   eval      $lnver# = savever#

     C                   eval      $lnuser = #user
     C                   eval      $lnemp# = e$emp#
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn

     C                   endsr

     *----------------------------------------------------------------
     *  clr$uciinfo  Clear $uciinfo data structure fields
     *----------------------------------------------------------------

     C     clr$uciinfo   begsr
     C                   eval      savever# = $uiver#
     C                   clear                   $uciinfo
     C                   clear                   $uciinfo2
     C                   eval      $uiver# = savever#
     C                   eval      $uiaddemp = e$emp#
     C                   eval      $uiaddusr = #user
     C                   eval      $uiaddpgm  = #prog
     C                   eval      $uiaddjob  = #job
     C                   eval      $uiaddnbr = #jobn
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*UCIINFO'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $dridata = $uciinfo
     C                   eval      $dridata2 = $uciinfo2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   eval      $dridata2 = $licinfo2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*UCIINFO'
     C                             or $dricommand = '*LICENSE'
     C                             or $dricommand = '*LICINFO'
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   parm                    $dridata2
     C                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
     C                   endif

     C                   select

     C                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*UCIINFO'
     C                   eval      $uciinfo = $dridata
     C                   eval      $uciinfo2 = $dridata2
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   eval      $licinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *
     *  ZZCNVWGT  Setup converted weight field.
     *
     C     zzcnvwgt      begsr
     *
     *
     * If item options is setup as kgs and user enters kgs no conversion
     * If item options is setup as kgs and user enters lbs need conversion
     * If item options is setup as lbs and user enters lbs no conversion
     * If item options is setup as lbs and user enters kgs need conversion
      /free
        select;
          when Begkilolbs = 'K';
            if KiloLbs = 'K';
              eval cnvwgt = w13cwgt;
            else;
              eval(h) cnvwgt = w13cwgt / kgs2lbs;
            endif;
          other;
            if KiloLbs = 'K';
              eval(h) cnvwgt = w13cwgt * kgs2lbs;
            else;
              eval cnvwgt = w13cwgt;
            endif;
        endsl;
      /end-free

     C                   endsr
     *----------------------------------------------------------------
     *  License Plate Tracking Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  ZZZCLR$LT210  -  Clear LT210 parameters.
     *----------------------------------------------------------------

     C     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
     C                   clear                   $tnorm1
     C                   clear                   $tnorm2
     C                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid
     C                   clear                   $ttoslot
     C                   clear                   $tpartime
     C                   clear                   $tUCI

     C                   endsr

     *----------------------------------------------------------------
     *  ZZZCALL$LT210  -  Call LT210 program.
     *----------------------------------------------------------------

     C     ZZZCALL$LT210 begsr

     C                   eval      $thead = 'Inv Count'

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'INV'         $ttype
     C                   parm                    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      0             $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
     C                   parm                    $tnorm1
     C                   parm                    $tnorm2
     C                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm      '*STUPID'     $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
     C                   parm                    $ttoslot
     C                   parm                    $tpartime
     C                   parm                    $tUCI

     C                   if        %error
     C                   eval      $treturn = $treturn
     C                   endif
     C                   endsr

     *----------------------------------------------------------------
     *  ZZADJUST       -  Make adjustment
     *----------------------------------------------------------------

     C     zzadjust      begsr
     C                   move      *off          error
      /free
        if additem = *on;
          exsr addsltitm;
        endif;
      /end-free
     C                   eval      bfr$Slot = $slot
     C                   eval      bfr$Slot2 = $slot2
     c                   eval      save$slphy1 = $slphy1
     c                   eval      save$slphy2 = $slphy2
     c                   eval      save$slphy3 = $slphy3
     C                   exsr      clr$slot
      /free
        // when there is no item in the slot don't attempt to process
        // an adjustment.
        if bfr$slot.$slitem <> ' ';
      /end-free

     *   Fill interface data structure fields.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1dept
     C                   eval      $sldispu = *on
     c                   if        additem = *on
     C                   eval      $sldisp  = bfr$slot.$sldisp
     c                   else
     C                   eval      $sldisp  = w10slot
     c                   endif
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = bfr$slot.$slitem

     C                   eval      $saqtyu  = *on
     c                   eval      $saqty1 = w12qty1 - save$slphy1
     c                   eval      $saqty2 = w12qty2 - save$slphy2
     c                   eval      $saqty3 = w12qty3 - save$slphy3

      /free
        // if the slot is at Z status and the user counted 0. No need
        // to process an adjustment.
        if bfr$slot.$slstat = 'Z' and
           $saqty1 = 0 and
           $saqty2 = 0 and
           $saqty3 = 0;
        else;
      /end-free
     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = w13cwgt
     C*                  exsr      zzcnvwgt
     C*                  eval      $sacwta  = cnvwgt * 1
     C                   eval      $sacodeu = *on
     c                   if        w2ctyp = '1'
     C                   eval      $sacode  = rtcsadjc
     c                   else
     C                   eval      $sacode  = w5adjcd
     c                   endif
     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'Cycle Count'
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'ADJ'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     c                   eval      $saUCIts = *loval
     c                   eval      $saUCItsU = *on

     *   create the adjustment even if no qty if the opcadj = 'Y'
     c                   select
     c                   when      $saqty1 = 0 and
     c                             $saqty2 = 0 and
     c                             $saqty3 = 0 and
     c                             opcadj <> 'Y'
     c                   other
     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     c                   endsl
      /free
        endif;
        endif;
      /end-free
     *   update/add history detail
     c                   exsr      zzrtchstd
     *   Write history detail log
     c                   exsr      zzrtchstl
     C     endadj        endsr

     *----------------------------------------------------------------
     *
     *  ZZADJIN  Adjust in the slot uci not currently in inventory
     *
     C     zzadjin       begsr
     C                   move      *off          error
      /free
        if additem = *on and addcount = 0;
          exsr addsltitm;
        endif;
        bfr$Slot = $slot;
        bfr$Slot2 = $slot2;
        save$slphy1 = $slphy1;
        save$slphy2 = $slphy2;
        save$slphy3 = $slphy3;
        addcount = 1;
      /end-free

     *   Fill interface data structure fields.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1dept
     C                   eval      $sldispu = *on
     c                   if        additem = *on
     C                   eval      $sldisp  = bfr$slot.$sldisp
     c                   else
     C                   eval      $sldisp  = w10slot
     c                   endif
     C                   eval      $saitemu = *on
     C****               eval      $saitem  = $ititem
     C                   eval      $saitem  = bfr$slot.$slitem
     c                   eval      $sarmuciu = *on
     c                   eval      $sarmUci = $uiuci

     C                   eval      $saqtyu  = *on
     c                   select
     c                   when      $uiautyp = 'N'
     C                   eval      $saqty1  = 1
     c                   when      $uiautyp = '1'
     C                   eval      $saqty2  = 1
     c                   when      $uiautyp = '2'
     C                   eval      $saqty3  = 1
     c                   other
     C                   eval      $saqty1  = 1
     c                   endsl

     C                   eval      $sacwtau = *on
     C*                  exsr      zzcnvwgt
     C                   eval      $sacwta  = $uiwgtlbs * 1
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w5adjcd
     C                   eval      $samemou = *on
     c                   if        w18type = '3'
     C                   eval      $samemo  = 'Type 3 Cycle Count'
     c                   else
     C                   eval      $samemo  = 'Type 4 Cycle Count'
     c                   endif
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'ADJ'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     c                   if        $imltrk = 'U' and w18type <> '4'
     c                   eval      $saUCIts = $ppartime
     c                   eval      $saUCItsU = *on
     c                   else
     c                   eval      $saUCIts = *loval
     c                   eval      $saUCItsU = *on
     c                   endif
     c                   if        $imltrk = 'U'
     c                   eval      $saUCItype = w18type
     c                   eval      $saUCItypeU = *on
     c                   endif

     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
      /free
        exsr zzrtchstd;
        exsr zzrtchstl;
        sleep(1);
      /end-free

     C     endadjin      endsr
     *----------------------------------------------------------------
     *
     *  ZZADJOUT Adjust out of the slot uci is currently located.
     *
     C     zzadjout      begsr
     C                   move      *off          error
     C                   eval      bfr$Slot = $slot
     C                   eval      bfr$Slot2 = $slot2
     c                   eval      save$slphy1 = $slphy1
     c                   eval      save$slphy2 = $slphy2
     c                   eval      save$slphy3 = $slphy3

     *   Fill interface data structure fields.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = w1whse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = w1dept
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w10slot
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $ititem
     c                   eval      $sarmuciu = *on
     c                   eval      $sarmUci = $uiuci

     C                   eval      $saqtyu  = *on
     c                   select
     c                   when      $uiautyp = 'N'
     C                   eval      $saqty1  = -1
     c                   when      $uiautyp = '1'
     C                   eval      $saqty2  = -1
     c                   when      $uiautyp = '2'
     C                   eval      $saqty3  = -1
     c                   other
     C                   eval      $saqty1  = -1
     c                   endsl

     C                   eval      $sacwtau = *on
     C                   eval      $sacwta  = $uiwgtlbs * -1
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w5adjcd
     C                   eval      $samemou = *on
     c                   if        w18type = '3'
     C                   eval      $samemo  = 'No Scan Type 3 All'
     c                   else
     C                   eval      $samemo  = 'Empty Slot - RTC'
     c                   endif
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'ADJ'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     c                   if        $imltrk = 'U' and w18type <> '4'
     C                                           and w18type <> '3'
     C                   eval      $saUCIts = $ppartime
     c                   eval      $saUCItsU = *on
     c                   else
     c                   eval      $saUCIts = *loval
     c                   eval      $saUCItsU = *on
     c                   endif
     c                   if        $imltrk = 'U'
     c                   eval      $saUCItype = w18type
     c                   eval      $saUCItypeU = *on
     c                   endif
     c                   if        $imltrk = 'U'
     c                   eval      $satolcns = $uilcns
     c                   eval      $satolcnsu = *on
     c                   endif

     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
      /free
        exsr zzrtchstd;
        exsr zzrtchstl;
        sleep(1);
      /end-free

     C     endadjout     endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZINTOUT Adjust out of the slot uci is currently located.
730aA*           this is an internal adjustment.
730aA*
730aAC     zzintout      begsr
730aAC                   move      *off          error
     C                   eval      bfr$Slot = $slot
     C                   eval      bfr$Slot2 = $slot2
     c                   eval      save$slphy1 = $slphy1
     c                   eval      save$slphy2 = $slphy2
     c                   eval      save$slphy3 = $slphy3

730aA*   Fill interface data structure fields.

730aAC                   exsr      clr$slot
730aAC                   eval      $slwhseu = *on
730aAC                   eval      $slwhse  = $litowhse
730aAC                   eval      $slwhdpu = *on
730aAC                   eval      $slwhdp  = $litowhdp
730aAC                   eval      $sldispu = *on
730aAC                   eval      $sldisp  = $litodisp
730aAC                   eval      $saitemu = *on
730aAC                   eval      $saitem  = $ititem
730aAc                   eval      $sarmuciu = *on
730aAc                   eval      $sarmUci = $uiuci
730aA
730aAC                   eval      $saqtyu  = *on
730aAc                   select
730aAc                   when      $uiautyp = 'N'
730aAC                   eval      $saqty1  = -1
730aAc                   when      $uiautyp = '1'
730aAC                   eval      $saqty2  = -1
730aAc                   when      $uiautyp = '2'
730aAC                   eval      $saqty3  = -1
730aAc                   other
730aAC                   eval      $saqty1  = -1
730aAc                   endsl
730aA
730aAC                   eval      $sacwtau = *on
730aAC                   exsr      zzcnvwgt
730aAC                   eval      $sacwta  = $uiwgtlbs  * -1
730aAC                   eval      $sacodeu = *on
730aAc                   eval      w1code = 'U1'
730aAC                   eval      $sacode  = w1code
730aAC                   eval      $samemou = *on
     c                   if        w18type = '3'
730aAC                   eval      $samemo  = 'Type 3 scan all RTC'
     c                   else
730aAC                   eval      $samemo  = 'Type 4 Remove All RTC'
     c                   endif
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w18type <> '4'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w18type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $satolcns = $litolcns
730aAc                   eval      $satolcnsu = *on
730aAc                   endif
730aA
730aA*   Call interface to do update.
730aA
730aAC                   eval      $dricommand = '*SLOT'
730aAC                   eval      $drisubcmd  = '%ADJUST'
730aAC                   eval      $drisys2upd = 'D'
730aAC                   eval      chk4err = *on
730aAC                   eval      zmsflag = *off
730aAC                   exsr      zzzdricop

730aAC     endintout     endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZINTIN  Adjust in the slot the user says the uci is
730aA*           physically in. This is an internal adjustment.
730aA*           Used to locate the uci in the correct overflow slot.
730aA*
730aAC     zzintin       begsr
730aAC                   move      *off          error
     C                   eval      bfr$Slot = $slot
     C                   eval      bfr$Slot2 = $slot2
     c                   eval      save$slphy1 = $slphy1
     c                   eval      save$slphy2 = $slphy2
     c                   eval      save$slphy3 = $slphy3

730aA*   Fill interface data structure fields.

730aAC                   exsr      clr$slot
730aAC                   eval      $slwhseu = *on
730aAC                   eval      $slwhse  = w1whse
730aAC                   eval      $slwhdpu = *on
730aAC                   eval      $slwhdp  = w1dept
730aAC                   eval      $sldispu = *on
730aAC                   eval      $sldisp  = w10slot
730aAC                   eval      $saitemu = *on
730aAC                   eval      $saitem  = $ititem
730aAc                   eval      $sarmuciu = *on
730aAc                   eval      $sarmUci = $uiuci
730aA
730aAC                   eval      $saqtyu  = *on
730aAc                   select
730aAc                   when      $uiautyp = 'N'
730aAC                   eval      $saqty1  = 1
730aAc                   when      $uiautyp = '1'
730aAC                   eval      $saqty2  = 1
730aAc                   when      $uiautyp = '2'
730aAC                   eval      $saqty3  = 1
730aAc                   other
730aAC                   eval      $saqty1  = 1
730aAc                   endsl
730aA
730aAC                   eval      $sacwtau = *on
730aAC                   exsr      zzcnvwgt
730aAC                   eval      $sacwta  = $uiwgtlbs * 1
730aAC                   eval      $sacodeu = *on
730aAc                   eval      w1code = 'U1'
730aAC                   eval      $sacode  = w1code
730aAC                   eval      $samemou = *on
     c                   if        w18type = '3'
730aAC                   eval      $samemo  = 'Type 3 scan all RTC'
     c                   else
730aAC                   eval      $samemo  = 'Type 4 Remove All RTC'
     c                   endif
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w18type <> '4'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w18type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aA
730aA*   Call interface to do update.
730aA
730aAC                   eval      $dricommand = '*SLOT'
730aAC                   eval      $drisubcmd  = '%ADJUST'
730aAC                   eval      $drisys2upd = 'D'
730aAC                   eval      chk4err = *on
730aAC                   eval      zmsflag = *off
730aAC                   exsr      zzzdricop
730aA /free
730aA /end-free

730aAC     endintin      endsr
     *----------------------------------------------------------------
     *  ZZRTCHSTD      -  Add/update records to RTCHSTD
     *----------------------------------------------------------------

     C     zzrtchstd     begsr
      /free
        rtcdwhse = w1whse;
        if w2ctyp = '1';
          rtcduid  = wksuid;
        else;
          rtcduid  = workingId;
        endif;
        rtcdwhdp = w1dept;
        rtcddisp = bfr$Slot.$sldisp;
        chain (rtcdwhse: rtcduid: rtcdwhdp: rtcddisp) rtchstd;
        rtcdbase = basedisp;
        rtcdpick = bfr$Slot.$slpick;
        rtcdwsid = bfr$Slot.$slside;
        rtcdwitm = bfr$Slot.$slitem;
        rtcdasl  = bfr$Slot.$slaisl;
        rtcdloc  = bfr$Slot.$slloc;
        rtcdlvl  = bfr$Slot.$slrlvl;
        rtcdhnd  = bfr$Slot.$slhand;
        rtcdbqty1 = bfr$Slot.$slstk1;
        rtcdadj1  = $saqty1;
        rtcdbqty2 = bfr$Slot.$slstk2;
        rtcdadj2  = $saqty2;
        rtcdbqty3 = bfr$Slot.$slstk3;
        rtcdadj3  = $saqty3;
        rtcdwwgt  = $sacwta;
        rtcdwlrg  = lwrng;
        rtcdwhrg  = hirng;
        rtcdwwtx  = ovrrid;
        rtcdslcnt  = 'Y';
        getmicrotime(currstampuc:currstampsys);
        currstamploc = currstampsys + %hours(bfcoffset);
        rtcdsltts = currstampsys;
        rtcdadj = $sacode;
        rtcddate = $sadate;
        rtcdtime = $satime;
        rtcdpage = 0;
        // need to get team from workfile
        rtcdtmcod = ' ';
        rtcdtmdte = ' ';
        rtcdaddts = currstampsys;
        rtcdadduc = currstampuc;
        rtcdaddcu = #curruser;
        rtcdaddju = #curruser;
        rtcdaddj  = #job;
        rtcdaddjn = #jobn;
        rtcdaddpgm = #pgm;
        rtcdpagts = *loval;
        rtcdpaguc = *loval;
        rtcdpagcu = ' ';
        rtcdpagju = ' ';
        rtcdpagj =  ' ';
        rtcdpagjn = ' ';
        rtcdpagpgm = ' ';
        rtcdadjts = currstampsys;
        rtcdadjuc = currstampuc;
        rtcdadjcu = #curruser;
        rtcdadjju = #curruser;
        rtcdadjj  = #job;
        rtcdadjjn = #jobn;
        rtcdadjpgm = #pgm;
        rtcdpstts = currstampsys;
        rtcdpstuc = currstampuc;
        rtcdpstcu = #curruser;
        rtcdpstju = #curruser;
        rtcdpstj  = #job;
        rtcdpstjn = #jobn;
        rtcdpstpgm = #pgm;
        // need to go get slot to get after adjustment stock qty
        exsr clr$slot;
        $slwhseu = *on;
        $slwhse  = w1whse;
        $slwhdpu = *on;
        $slwhdp  = w1dept;
        $sldispu = *on;
        if additem = *on;
        $sldisp  = bfr$slot.$sldisp;
        else;
        $sldisp  = w10slot;
        endif;

        $dricommand = '*SLOT';
        $drisubcmd  = '%GET';
        $drisys2upd = 'D';
        chk4err = *on;
        zmsflag = *off;
        exsr zzzdricop;
        rtcdaqty1 = $slstk1;
        rtcdaqty2 = $slstk2;
        rtcdaqty3 = $slstk3;
        if %found(rtchstd);
          update rtcdrec;
        else;
          write rtcdrec;
        endif;
      /end-free
     C     endrtchstd    endsr
     *----------------------------------------------------------------
     *  ZZRTCHSTL      -  Add records to RTCHSTL
     *----------------------------------------------------------------

     C     zzrtchstl     begsr
      /free
        rtclwhse = rtcdwhse;
        rtcluid  = rtcduid;
        rtclwhdp = rtcdwhdp;
        rtclbase = rtcdbase;
        rtcldisp = rtcddisp;
        rtclpick = rtcdpick;
        rtclwsid = rtcdwsid;
        rtclwitm = rtcdwitm;
        rtclasl  = rtcdasl;
        rtclloc  = rtcdloc;
        rtcllvl  = rtcdlvl;
        rtclhnd  = rtcdhnd;
        rtclbqty1 = rtcdbqty1;
        rtcladj1  = rtcdadj1;
        rtclbqty2 = rtcdbqty2;
        rtcladj2  = rtcdadj2;
        rtclbqty3 = rtcdbqty3;
        rtcladj3  = rtcdadj3;
        rtclwwgt  = rtcdwwgt;
        rtclwlrg  = rtcdwlrg;
        rtclwhrg  = rtcdwhrg;
        rtclwwtx  = rtcdwwtx;
        rtclslcnt = rtcdslcnt;
        rtclsltts = rtcdsltts;
        rtcladj =   rtcdadj;
        rtcldate =  rtcddate;
        rtcltime =  rtcdtime;
        rtclpage =  rtcdpage;
        rtcltmcod = rtcdtmcod;
        rtcltmdte = rtcdtmdte;
        rtcladdts = rtcdaddts;
        rtcladduc = rtcdadduc;
        rtcladdcu = rtcdaddcu;
        rtcladdju = rtcdaddju;
        rtcladdj  = rtcdaddj;
        rtcladdjn = rtcdaddjn;
        rtcladdpgm = rtcdaddpgm;
        rtclpagts = rtcdpagts;
        rtclpaguc = rtcdpaguc;
        rtclpagcu = rtcdpagcu;
        rtclpagju = rtcdpagju;
        rtclpagj  = rtcdpagj;
        rtclpagjn = rtcdpagjn;
        rtclpagpgm =rtcdpagpgm;
        rtcladjts = rtcdadjts;
        rtcladjuc = rtcdadjuc;
        rtcladjcu = rtcdadjcu;
        rtcladjju = rtcdadjju;
        rtcladjj  = rtcdadjj;
        rtcladjjn = rtcdadjjn;
        rtcladjpgm =rtcdadjpgm;
        rtclpstts = rtcdpstts;
        rtclpstuc = rtcdpstuc;
        rtclpstcu = rtcdpstcu;
        rtclpstju = rtcdpstju;
        rtclpstj  = rtcdpstj;
        rtclpstjn = rtcdpstjn;
        rtclpstpgm = rtcdpstpgm;
        rtclaqty1 = rtcdaqty1;
        rtclaqty2 = rtcdaqty2;
        rtclaqty3 = rtcdaqty3;
        write rtclrec;
      /end-free
     C     endrtchstl    endsr
     *----------------------------------------------------------------
     *
     *  ZZTFR    Initiate the transfer for UCI tracking.
     *
     C     zztfr         begsr
      /free
        $lcmd = '*CHANGE ';
        $lwhseTfr = w1whse;
        //$lwhdpTfr = w1dept;
        $lwhdpTfr = $litowhdp;
        $ldispTfr = $litodisp;
        $ldispTfrTo = w14disp;
        $luomtfr = $uiautyp;
        $llcnsTfr = w15lcns;
        //$puci = w19uci;
      /end-free
      ********
     *
      * transfer to the usr slot
     C                   move      *off          error
     *
     *   Item changed, set flag for adjustment code entry.
      **** what is *in59
     C                   eval      *in59 = *off
     C*
     C                   if        client = FoodPro
     C                   if           $itcwgt = 'Y'
     C                   eval      w1cwtr = uciwgt
     C                   endif
     C                   endif
     *
     *  Set partial quantity flag.
     *
     *    These values were recalculated and sent back from
     *    the VFYTFOCHG command. If all of the original #FROM
     *    buckets were zero and the new Avail quantities are
     *    zero, then the entire quantity is being taken.
     *
     c                   if        $imltrk = 'U' and (w18type = '3' or
     c                                                w18type = '4')
     C                   if        $slavl1 = 0 and
     C                             $slavl2 = 0 and
     C                             $slavl3 = 0 and
     C                             #fromslalc1 = 0 and
     C                             #fromslalc2 = 0 and
     C                             #fromslalc3 = 0 and
     C                             #fromslrcv1 = 0 and
     c                             #fromslrcv2 = 0 and
     C                             #fromslrcv3 = 0 and
     C                             #fromslpck1 = 0 and
     C                             #fromslpck2 = 0 and
     C                             #fromslpck3 = 0 and
     C                             #fromsltfr1 = 0 and
     C                             #fromsltfr2 = 0 and
     C                             #fromsltfr3 = 0
     C                   eval      partial = *off
     c                   else
     C                   eval      partial = *on
     C                   endif
     c                   else
      *    always force partial off, so it will move the license i want
      *    unless uci tracked item
     C                   eval      partial = *off
     C                   endif

     *  License plate tracking item. Update to show in transit.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PULTRAN'
     C                   eval      $tlic#    = $litolcns
     C                   eval      $tnewlic# = $litolcns
     C                   eval      $twhse    = w1whse
     C                   eval      $titem    = #fromslitem
     C                   eval      $titemdsc = $itdesc
     C                   eval      $tpartial = partial
     c                   if        $imltrk = 'U' and (w18type = '3' or
     c                                                w18type = '4')
     c                   select
     c                   when      $uiautyp = '2'
     c                   eval      wtqty1 = 0
     c                   eval      wtqty2 = 0
     c                   eval      wtqty3 = 1
     c                   when      $uiautyp = '1'
     c                   eval      wtqty1 = 0
     c                   eval      wtqty2 = 1
     c                   eval      wtqty3 = 0
     c                   other
     c                   eval      wtqty1 = 1
     c                   eval      wtqty2 = 0
     c                   eval      wtqty3 = 0
     c                   endsl
     c                   else
     c                   eval      wtqty1 = $litorqty1
     c                   eval      wtqty2 = $litorqty2
     c                   eval      wtqty3 = $litorqty3
     c                   endif
     C                   eval      $tqty1    = wtqty1
     C                   eval      $tqty2    = wtqty2
     C                   eval      $tqty3    = wtqty3
     C                   eval      $tnorm1   = wtqty1
     C                   eval      $tnorm2   = wtqty2
     C                   eval      $tnorm3   = wtqty3
     c                   if        $uiuci = ' '
     c                   if        $uiuci <> ' '
     c                   eval      $tuci = $uiuci
     c                   else
     c                   eval      $tuci = ' '
     c                   endif
     c                   else
     c                   eval      $tuci = $uiuci
     c                   endif
     C                   exsr      zzzcall$lt210

     C                   if        $treturn <> '*OK'
     C                   endif

     C                   eval      curlic# = $tinlic#

     *  Use DRI interface to update From slot.
     *    Note: The $sl info was retrieved in ZZGET1.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = w1whse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = $litowhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = $litodisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = $litoitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = wtqty1
     C                   eval      $saqty2   = wtqty2
     C                   eval      $saqty3   = wtqty3
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = $litoitem

     C                   eval      $satasku = *on
     C                   eval      $satask  = 'TFRMOV'

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = curtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = $tinlic#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = $tslotpos
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'U'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'User'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = $toutlic#
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = $litolcns

     *     Set item change flag


     C                   eval      $dricommand = '*SLOT'

     *     Do Reverse transfer if Pick slot and item didn't change.

     C                   if        #fromslpick = 'Y'
     C                             and #fromslitem = $litoitem
     C                   eval      Ypickslot   = *on
      **   If FROM slot is pick, save data just in case TO slot

     C                   eval      $drisubcmd  = '%TFR2USRR'
     C                   else
     C                   eval      $drisubcmd  = '%TFR2USR'
     C                   endif
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endtfr
     C                   endif
     C                   eval      tfr2usrDate = today
     C                   time                    tfr2usrTime
     C                   eval      tfroutflag = *on
     C                   eval      curlic# = $saToLcns
     C                   eval      $tinlic# = $saToLcns

     *  Override $saFrmEmpty for an empty Pick slot.
     *  Re: We want to ask a user if the slot is empty just in case he is
     *  moving the item to another Pick slot and we are allow to auto verify.

     C***                if        Ypickslot   = *on
     C***                          and partial = *off
     C***                eval      $saFrmEmpty = 'Y'
     C***                endif
     *
     *  Create work record.
     *
     C                   exsr      zzwrkadd

     *    Then tell user to put back an pulled pallets.
     *         and move on to the putaway process.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PULRTN'
     C                   eval      $twhse = w1whse
     C                   eval      $twhdp = #fromslwhdp
     C                   eval      $tslot = #fromsldisp
     C                   eval      $titem = #fromslitem
     C                   eval      $titemdsc = $itdesc
     C                   eval      $tlic#    = $saToLcns
     C                   exsr      zzzcall$lt210
     C                   if        $treturn <> '*OK'
     C                   endif
      **** now for the rest of the stuff from it252 zzupd2
     C                   move      *off          error
     *   Change quantity to breakdown quantity if needed.
      ************ what if adjusting a breakdown
     C***                eval      toqty1 = wtqty1
     *

     *    Determine if we are returning qty to original slot.

     C***                if        w1dept    = wuPulWhdp
     C***                          and $litodisp = wuPulDisp
     C***                          and $litoitem = wuPulItem
     C***                eval      rtnToOrig = *on
     C***                else
     C***                eval      rtnToOrig = *off
     C***                endif

     *    Call license tracking for putaway - Before update
     *    Only call when not returning to original slot.

     C                   select


     C                   when      rtnToOrig = *on

     C                   eval      $tinlic# = wuPulLcns
     C                   eval      $tslotpos = wuPulPos
     C                   eval      $toutlic# = wuUsrLcns

     C                   other

     C                   if        not skipLT210

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PUTAWYB'
     C                   eval      $tlic#    = wuUsrLcns
     C                   eval      $tpartial = partial
     C                   eval      $twhse    = w1whse
     C                   eval      $twhdp    = w1dept
     C                   eval      $tslot    = w14disp
     C                   eval      $titem    = $litoitem
     C                   eval      $titemdsc = $itdesc
     C                   eval      $tqty1    = wtqty1
     C                   eval      $tqty2    = wtqty2
     C                   eval      $tqty3    = wtqty3
     C                   eval      $tnorm1   = wtqty1
     C                   eval      $tnorm2   = wtqty2
     C                   eval      $tnorm3   = wtqty3
     C                   if        $uiuci = ' '
     c                   if        $uiuci <> ' '
     c                   eval      $tuci = $uiuci
     c                   else
     c                   eval      $tuci = ' '
     c                   endif
     c                   else
     C                   eval      $tuci     =  $uiuci
     c                   endif
     C                   exsr      zzzcall$lt210
     *
     C                   if        $treturn <> '*OK'
     C                   eval      redspl = *on
     C                   eval      error = *on
     C                   eval      errmsg = $terrmsg
     C                   exsr      zm0105
     C                   goto      endtfr
     C                   endif

     C                   endif

     C                   endsl

     *  Use DRI interface to tfr qty from USR slot to To slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = w1whse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = w1dept
     C                   eval      $sldispu  = *on
     c                   if        prdtfr
     C                   eval      $slstatu  = *on
     C                   eval      $slstat   = 'PR'
     C                   eval      $sldisp   = hldprdDisp
     c                   else
     C                   eval      $sldisp   = w14disp
     c                   endif
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = $litoitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = wtqty1
     C                   eval      $saqty2   = wtqty2
     C                   eval      $saqty3   = wtqty3
     C*
     C                   if        client = FoodPro
     C*
     C                   if           $itcwgt        = 'Y'
     C                   eval      $sacwtau = '1'
     C*                  eval      $sacwta = uciwgt
     C                   else
     C                   eval      $sacwtau = '0'
     C                   endif
     C*
     C                   endif
     C*
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $sacdspu  = *on
     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = wuUsrWhdp
     C                   eval      $sacdsp   = wuUsrDisp
     C                   eval      $saToPosu = *on
     C                   eval      $saToPos  = $tslotpos

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = curtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = $tinlic#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = $tslotpos
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = $toutlic#
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = wuPulolcns

     C                   eval      $sapullwhdpu = *on
     C                   eval      $sapullwhdp  = wuPulWhdp
     C                   eval      $sapulldispu = *on
     C                   eval      $sapulldisp  = wuPulDisp
     C                   eval      $sapullbaseu = *on
     C                   eval      $sapullbase  = wuPulBase
     C                   eval      $sapulllcnsu = *on
     C                   eval      $sapulllcns  = wuPulLcns

     *     Set changed item flag if necessary.

     C                   if        #fromslitem <> $litoitem
     C                   eval      $saItmChgU = *on
     C                   eval      $saItmChg = 'Y'
     C                   endif

     C                   if        rtnToOrig = *on
     C                   eval      $saexcdU = *on
     C                   eval      $saexcd  = 'RTNORIG'
     C                   endif


     c                   if        $tpartial = *on
     c                   eval      $saUCIts = $tpartime
     c                   eval      $saUCItsU = *on
     c                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endtfr
     C                   endif

     *  Update #TO slot info in case item was put into a virtual slot.

     C                   eval      #toslhand = $slhand
     C                   eval      $pdisp    = $sldisp
     c                   if        prdtfr
     C                   eval      #toslstat = 'PR'
     c                   else
     C                   eval      #toslstat = $slstat
     c                   endif

     C***                endif

     *    Call license tracking for putaway - After update
     *      Values are left over from "Before" call.

     C                   eval      $tcmd     = '*PUTAWYA'
     C                   eval      $twhdp    = $pwhdp
     C                   eval      $tslot    = $pdisp
     C                   exsr      zzzcall$lt210
     *
     C                   if        $treturn <> '*OK'
     C                   endif
      ** Use DRI interface to update From slot.
      **
     C                   if        Ypickslot = *on
     C                             and $slpick = 'Y'
     C                             and $slstat <> 'RP'
     C                             and $slstyp = 'F'
     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $slitemu  = *on
     C                   eval      $slitem   = #fromslitem
     C                   eval      $slstatu  = *off
     C                   eval      $slstat   = #fromslstat
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%SETSTAT  '
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   eval      Ypickslot = *off
     C                   if        $drireturn = 'NOTZROSTAT'
     C                   eval      error = *off
     C                   endif
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif
     C                   endif
     C                   eval      Ypickslot = *off


     *  Create label(s), create extra trans, close trans.

     C                   exsr      zzcrtl


     *  Delete work record

     C                   exsr      zzwrkdel



     c****** this is the end of zzupd from it252
     C     endtfr        endsr

     *----------------------------------------------------------------
     *  zzwrkadd   Add record to work file for user.
     *----------------------------------------------------------------

     C     zzwrkadd      begsr

     C                   exsr      zzgetcurrstamp
     C*
     C                   clear                   wuRec

     C                   eval      wutrn# = curtrn#
     C                   eval      wuwhse = $pwhse
     C                   eval      wuscannbr = #fromToLcns
     C                   eval      wuscantype = 'P'
     C                   eval      wupulwhdp = #fromslwhdp
     C                   eval      wupulbase = #frombasesldsp
     C                   eval      wupuldisp = #fromsldisp
     C                   eval      wupulitem = #fromslitem
     C                   eval      wupullcns = #fromToLcns
     C                   eval      wupulolcns = #fromOLcns
     C                   eval      wupulvfy   = $saFrmEmpty

     C                   eval      wuUsrWhdp = $slwhdp
     C                   eval      wuUsrDisp = $sldisp
     C                   eval      wuNewItem = #fromslitem

     C                   eval      wuRemQty1 = wtqty1
     C                   eval      wuRemQty2 = wtqty2
     C                   eval      wuRemQty3 = wtqty3

     C                   eval      wuPullCns = $toutlic#
     C                   eval      wuUsrLcns = $tinlic#

     C                   eval      wuRecType = 'TFR'
     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = E$EMP#
     C                   eval      wuaddeusr = #curruser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr
     c*
     C                   write     wuRec

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCRTL   Create Label records.
     *
     C     zzcrtl        begsr
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = w1dept
     C                   eval      exwgfm = *zeros
     *
     *  FROM Slot.
     *
     C                   eval      lbaisl = #fromslaisl
     C                   eval      lbloc = #fromslloc
     C                   eval      lbrlvl = #fromslrlvl
     C                   eval      lbhand = #fromslhand
     C                   eval      lbpseq = #fromslpseq
     C                   eval      lbstyp = #fromslstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
     C                   eval      fmwhdp = #fromslwhdp
     C                   eval      fmdisp = #fromsldisp
     C                   eval      fmitem = #fromslitem
     *
     * FROM ITEM
     *
     C                   eval      fmcwgt = $itcwgt
     C                   if        #fromslitem <> $ititem
     C                   if        $itumq2 <> 0
     C                   endif
     C                   endif
     *
     *    Create label records for case transfer.
     *
     C                   select
     C                   when      wtqty1 <> 0
     C                   eval      lbucod = $itum1
     C                   eval      lbqalc = wtqty1
     C                   eval      lbqpck = wtqty1
     C                   eval      lbucub = $itcube
     C     lbucub        mult      wtqty1        lbcube
     C                   eval      lbuwgt = $itswgt
     C     lbuwgt        mult      wtqty1        lbswgt
     *
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *
     * TO Slot.
     *
     C                   eval      tocwgt = $itcwgt
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = $pwhdp
     C                   eval      towhdp = $pwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = $pdisp
     C                   eval      lbrte = *blanks
     C                   eval      toitem = $ititem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = 'N'
     C                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      fmitem        lbitem
     C                   move      fmdisp        lbdisp
     C                   move      todisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     c                   endif
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      toitem        lbitem
     C                   move      towhdp        lbwhdp
     C                   move      todisp        lbdisp
     C                   move      fmdisp        lbdsp2
     C                   eval      lbucod = $itum1
     C                   eval      lbqalc = wtqty1
     C                   eval      lbqpck = wtqty1
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     c                   endif
     C                   eval      svtrn1 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C*                  exsr      zztrnupdate
     *
     C                   endsl
     *
     *    Create transfer record for breakdown 1 qty.
     *
     C                   select
     C                   when      wtqty2 <> 0
     C                   eval      lbucod = $itum2
     C                   eval      lbqalc = wtqty2
     C                   eval      lbqpck = wtqty2
     C                   if        $itumq2 > 0
     C     $itcube       div(h)    $itumq2       lbucub
     C     $itswgt       div(h)    $itumq2       lbuwgt
     C                   else
     C                   eval      lbuwgt = $itswgt
     C                   eval      lbucub = $itcube
     C                   endif
     C     lbucub        mult      wtqty2        lbcube
     C     lbuwgt        mult      wtqty2        lbswgt
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     *
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *
     * TO Slot.
     *
     C                   eval      tocwgt = $itcwgt
     *
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = $pwhdp
     C                   eval      towhdp = $pwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = $pdisp
     C                   eval      lbrte = *blanks
     C                   move      $ititem       toitem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = *on
     C                   if        newtrn = '*YES'
     C*                  exsr      zztrnclose
     C*                  exsr      zztrnstart
     C                   endif
     *
     C                   eval      lbtrn# = curtrn#
     C                   eval      svtrn2 = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      fmitem        lbitem
     C                   move      fmdisp        lbdisp
     C                   move      todisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     c                   endif
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      toitem        lbitem
     C                   move      todisp        lbdisp
     C                   move      fmdisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     C                   endif
     C                   eval      svtrn2 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C*                  exsr      zztrnupdate
     *
     C                   endsl
     *
     *    Create transfer record for breakdown 2 qty.
     *
     C                   select
     C                   when      wtqty3 <> 0
     C                   eval      lbucod = $itum3
     C                   eval      lbqalc = wtqty3
     C                   eval      lbqpck = wtqty3
     C                   if        $itumq3 > 0
     C     $itcube       div(h)    $itumq3       lbucub
     C     $itswgt       div(h)    $itumq3       lbuwgt
     C                   else
     C                   eval      lbuwgt = $itswgt
     C                   eval      lbucub = $itcube
     C                   endif
     C     lbucub        mult      wtqty3        lbcube
     C     lbuwgt        mult      wtqty3        lbswgt
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     *
     C                   eval      lbtie = 0
     C                   eval      lbhigh = 0
     *
     * TO Slot.
     *
     C                   eval      tocwgt = $itcwgt
     *
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = $pwhdp
     C                   eval      towhdp = $pwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = $pdisp
     C                   eval      lbrte = *blanks
     C                   move      $ititem       toitem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = '2'
     C                   if        newtrn = '*YES'
     C*                  exsr      zztrnclose
     C*                  exsr      zztrnstart
     C                   endif
     *
     C                   eval      lbtrn# = curtrn#
     C                   eval      svtrn3 = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      fmitem        lbitem
     C                   move      fmdisp        lbdisp
     C                   move      todisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     c                   endif
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      toitem        lbitem
     C                   move      todisp        lbdisp
     C                   move      fmdisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
     C                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     c** at this point we will not write label & transaction records
     c                   if        1 <> 1
     C                   write     lbrec
     c                   endif
     C                   eval      svtrn3 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C*                  exsr      zztrnupdate
     *
     C                   endsl
     *
     *  Close current transaction.
     *
     C*                  exsr      zztrnclose
     *
     C     endcrl        endsr

     *----------------------------------------------------------------
     *  zzwrkdel   Delete work file record
     *----------------------------------------------------------------

     C     zzwrkdel      begsr

     C*    wktkey        chain(e)  worktfr
     C*                  delete    wktrec

      /free
        //chain (wktype: E$EMP#: $pwhse: $pwhdp: $pdisp) workusr3;
        chain (wktype: E$EMP#: $pwhse: #fromslwhdp: #fromsldisp) workusr3;
      /end-free
     C                   if        %found
     C                   delete    wuRec
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *  buildworkrtci Build the workrtci file
     *----------------------------------------------------------------

     C     buildworkrtci begsr

      /free
        // clear workrtci for this user
        setll (#user) workrtci;
        dow forevr = forever;
          reade (#user) workrtci;
          if %eof(workrtci);
            leave;
          endif;
          delete wkirec;
        enddo;

        setll (w1whse: w7item) slot3;
        dow forevr = forevr;
          reade (w1whse: w7item) slot3;
          if %eof(slot3);
            leave;
          endif;
          if slstat = 'V' or
             slstat = 'Z';
            iter;
          endif;
765aD   //  if slaisl = 'RCV' or
765aA       if sldesg = 'BFC' and (slaisl = 'RCV' or
             slaisl = 'RTN' or
             slaisl = 'USR' or
             slaisl = 'OSS' or
             slaisl = 'RPA' or
             slaisl = 'XDK' or
765aM        slaisl = 'STG');
            iter;
          endif;

          exsr clr$slot;
          $slwhseu = *on;
          $slwhse  = w1whse;
          $slwhdpu = *on;
          $slwhdp  = w1dept;
          $sldispu = *on;
          $sldisp  = sldisp;

          $dricommand = '*SLOT';
          $drisubcmd  = '%GET';
          $drisys2upd = 'D';
          chk4err = *on;
          zmsflag = *off;
          exsr zzzdricop;

          // write workrtci
          chain (#user: w7item: $sacdsp) workrtci;
          if not %found(workrtci);
            wkiusr = #user;
            wkiitem = w7item;
            wkidisp = sldisp;
            wkibase = $sacdsp;
            wkipick = $slpick;
            wkistat = $slstat;
            wkistyp = $slstyp;
            wkicount = ' ';
            write wkirec;
          endif;
        enddo;

      /end-free
     C                   endsr
     *
     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Warehouse
Date
Team
Slot
Dept.
Weight
UPC
UPC not for item
Invalid Selection
Adjustment Code
Invalid License
** DESCSP
Almacen
Fecha
Equipo
Slot
Dept.
Weight
UPC
UPC no es para prdc.
Invalid Selection
Adjustment Code
Invalid License
