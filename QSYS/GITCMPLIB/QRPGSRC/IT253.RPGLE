      /copy *libl/qcopysrc,hspecs
     H dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  IT253  Automatic UCI Tracking Inventory transfer - Change
     *  03 May 2014
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *    05/03/17  LMC
     *      - Originally copied from IT252.
     *        This program will be used when user is trying to do an
     *        adjustment, and we find the uci in a different slot.
     *        We will do a transfer behind the scenes.
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
720aA*    05/03/17  LMC  7.20a
     *      - Created - copied from IT252.
     *      - Removed any warning edits, because we want this to
     *        process behind the scene without any interaction from
     *       the user.
     *
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
     *
     *----------------------------------------------------------------
      *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYbA*    11/05/09  RH   HSYb
     *      - Display pick slot on SC1
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    08/04/09  RH   SVLa
     *      - Enh: Use Custom 16 X 20 screens for RF 16 line.
SVLbA*    08/19/09  RH   SVLb
     *      - Enh: Use 1,9 for Y,N because of handheld RF keys.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
     *
SGCaA*    05/22/09  DAS  SGCa
     *      - Enh:  If willow default to LP7, if Kansas default to LP8
SGCbA*    02/20/13  JCJ  SGCb
     *      - Enh:  Changed label set name from sato to zebra format
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*    04/09/13  LMC  GLPA
     *      - Enh: Use 1,9 for Y,N because of handheld RF keys.
SVLbA*    08  same as saval mod SLVb.
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPR A*    04/21/15  MLB  FPR
     *      - Revised pgm to use 5.30a mod that added support for
     *        capture of catchweight being transferred. Needed to send
     *        back to Retalix.
FPRaA*    05/05/15  LMC  FPRa
     *      - Enh: Protect normal uom qty when normal UOM = MP.
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    01/22/16  RH   SBRa
     *      - Enh: Allow transfer to OSS using generic license, not   .
     *        system generated/printed.                               .
SBRb *    02/03/17  LMC  SBRb
     *      - Enh: Require new license on all transfers from OSS.     .

     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  59        User changed item number during transfer.
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
     Fit253fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fslotstat  if   e           k disk
     Fkititem   if   e           k disk
     Funmesr    if   e           k disk
     Foptiond   if   e           k disk
     Foptions   if   e           k disk
     FworkUsr3  uf a e           k disk
     FLabel     o  a e           k disk
     Fitemadj   o  a e           k disk
     Fitmexcp   o    e           k disk
     Fworkoss   uf a e           k disk
     Fworkoss1  uf   e           k disk
     F                                     rename(worec:worec1)
     Fplined    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
     D desc            s             50    dim(6) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
     D prdslt          S              3    dim(100)
     *----------------------------------------------------------------
     *  Customer id
     *
     D @getcl          c                   const('GETCLIENT')
     *
      /COPY QCOPYSRC,ID#BIRITE
      /COPY QCOPYSRC,ID#SGC
      /COPY QCOPYSRC,ID#SAVAL
      /COPY QCOPYSRC,ID#HALSEY
      /COPY QCOPYSRC,ID#EGF
      /copy qcopysrc,id#citywho
      /copy qcopysrc,id#cdi
      /copy qcopysrc,id#coastal
      /COPY QCOPYSRC,Id#Eastlan
      /COPY QCOPYSRC,ID#GLP
      /copy qcopysrC,id#fpr
      /copy qcopysrC,id#westsid
      /COPY QCOPYSRC,ID#SBR

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#SLOTDEF
     D saveVer#        s                   like($slver#)
     D save$slot       s                   like($slot)

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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pdispto              39     50
     D  $puomtype             51     51
     D  $plcns                54     68

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
     D  $ttoslot       s             12
     D  $tpartime      s               Z
     D  $tUCI          s            100
     D $uDiffItem      s              1
     D $uCube          s              9  3
     D $uDisp          s             12
     D $uItem          s             15
     D $uPieces        s              5  0
     D $uRecs          s              3  0
     D $uRsrv          s              1
     D $uWhdp          s              5
     D $uWhse          s              3  0
     D $uEntDte        s              8  0
     D $uExpDte        s              8  0
     D $uDiffEntd      s              1
     D $uDiffExpd      s              1
     D  wkType         s              3    INZ('TFR')

     *----------------------------------------------------------------
     *  Time variables
     *----------------------------------------------------------------

     D CurrStamploc    s               z
     D CurrStampsys    s               z
     D CurrStampuc     s               z

     D bfcoffset       s              3  0 inz(0)
     *----------------------------------------------------------------
     *  Phrase Variables
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrasvar
     D  currFile       s             10
     D  currRoutine    s             20
     D  lastnxtscr     s              3
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)

     *----------------------------------------------------------------
     *  Phrases
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

      /copy qcopysrc,p.bfcdteti

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  *DATEOPT  -  Expiration/Entered date options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLTDN  -  Letdown transactions.  <1-3>
     *    OPODRP  -  On-demand replenishment transactions. <1-3>
     *    OPSLTF  -  Slot transfer transactions. <1-3>
     *    OPPARC  -  Product put-away - Receiving transactions. <1-3>
     *    OPPART  -  Product put-away - Returns transactions. <1-3>
     *
     *     Destination options:
     *       1=Use From Slot date.
     *       2=Use oldest date.
     *       3=Use From Slot date if To Slot available qty is zero.
     *
     *     Note: For Receiving/Returns, substitute date captured during
     *           receiving/returns processing for From Slot date.
     *
     * Data structure
     *
     D opdta1          ds
     D  opltdn                 1      1
     D  opodrp                 2      2
     D  opsltf                 3      3
     D  opparc                 4      4
     D  oppart                 5      5
     D  opendd               117    117
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPNXTP  -  Next pallet number.
     *    OPBPCK  -  Bulk pick definition.
     *    OPPCUB  -  Maximum cube for PIR.
     *    OPFPAL  -  Pallets on fixed fork lift.
     *    OPFCUB  -  Maximum cube per fixed pallet.
     *    OPFSTP  -  Maximum stops per fixed pallet.
     *    OPINCL  -  Include PIR in fixed cube.
     *    OPSRCH  -  Number of previous pallets to search for space.
     *    OPFBLD  -  Fixed pallet building method.
     *                1 = By piece without concern for splitting stop.
     *                2 = By stop without splitting stop between plts.
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
     D  opnxtp                 1      7  0 inz(0)
     D  oppcub                10     14  2 inz(0)
     D  opfpal                15     15  0 inz(0)
     D  opfcub                16     20  2 inz(0)
     D  opincl                22     22
     D  opsrch                23     24  0 inz(0)
     D  opfstp                25     26  0 inz(0)
     D  opfbld                27     27  0 inz(0)
     D  opbpck                28     30  0 inz(0)
     D  oppbrk                31     33
     D  opmput                34     34
     D  opdend               117    117
     *
     *----------------------------------------------------------------
     *  *VIRTUAL  -  Virtual Slot options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPVALL  -  Always create Virtual slot. (Y/N)
     *    OPVPCK  -  Allow Virtual pick slots to be created.  (Y/N)
     *    OPVSLT  -  Create Virtual slot for item when base slot and
     *               corresponding Virtual slot(s) item(s) are different.
     *               Always Yes.
     *    OPVEXP  -  Create Virtual slot when item exists and
     *               expiration date is different.  (Y/N)
     *    OPVEND  -  Create Virtual slot when item exists and
     *               entered date is different.  (Y/N)
     *    OPVSAM  -  Merge product when entered/expiration dates
     *               are the same.  (Y/N)
     *    OPVEDF  -  Merge product when entered dates are different and
     *               expiration dates are the same.  (Y/N)
     *
     * Data structure
     *
     D opdtav          ds
     D  opvall                 1      1
     D  opvpck                 2      2
     D  opvslt                 3      3
     D  opvexp                 4      4
     D  opvend                 5      5
     D  opvsam                 6      6
     D  opvedf                 7      7
     D  optenv               117    117
     *
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *    OPIMPI  -  Import item fields from host.(Y,N).
     *    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
     *
     * Data structure
     *
     D opdat2          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opmpck                14     14
     D  opten2               117    117
     *----------------------------------------------------------------
     *  *REPLEN  -  Replenishment options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
     *    OPOQRP  -  Order qty replenishment (Y/N).
     *    OPRPEX  -  Allow replenishment on expired items.
     *               1=Allow, 2=Don't allow, 3=Warn
     *    OPRPFI  -  Allow replenishments out of FIFO order.
     *               1=Allow, 3=Warn
     *    OPLMTS  -  Limit Specific Slot replenishment program to
     *               to display only one overflow location at a
     *               time. (Y/N)
     *    OPCQTY  -  Check quantity of "To Slot" during replenish/
     *               letdown/transfer. (Y/N)
     *
     * Data structure
     *
     D opdta3          ds
     D  oprplb                 1      8
     D  opoqrp                 9      9
     D  oprpex                10     10
     D  oprpfi                11     11
     D  oplmts                12     12
     D  opcqty                13     13
     D  opcend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjtd          c                   const('ADJTSKDET')
     D @addtr          c                   const('ADDSTDTRN')
     D @llptr          c                   const('UPDLLPTRK')
740bAD @prtpg          c                   const('BFCPRTLBL')
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
     D  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lcode                19     20
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
     D  $litm                 22     36
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $ldsg                 19     23
     D  $ltyp                 24     24
     *
     D  $lwhse2               19     21  0
     D  $lwhdp2               22     26
     D  $ldisp2               27     38
     D  $litem2               39     53
     *----------------------------------------------------------------
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
     *----------------------------------------------------------------
     *  API programs
     *
     D @apics          c                   const('APICVTSLT ')
     *
     *----------------------------------------------------------------
     *  Working fields.
     *
     D                 ds
     D  lottrk                 1      4
     D  lictrk                 5      8
     D  llptp1                 9     16
     D  llptp2                17     24
     D  llptp3                25     32
     D  savllp                33     47
     D  newllp                48     62
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erqty                  1     10
     D  eritem                11     25
     D  erfrom                26     37
     D  erto                  38     49
     *
     D  erdisp                 1     12
     *
     D  erfsts                 1      2
     D  ertsts                 3      4
     *
     D  ernpck                 1      3p 0
     D  erapck                 4      6p 0
     *
     D  eritdp                 1      5
     D  erslds                 6     17
     D  ersldp                18     22
     D  eritsc                23     23
     D  erslsc                24     24
     *
     D  erdmsg                 1     60
     D  erdrtn                61     70
     D  erdcmd                71     80
     D  erdsub                81     90
     *----------------------------------------------------------------
     *  Working variables.
     *
     D  bkdwn1                 1      4    inz('*NO ')
     D  bkdwn2                 5      8    inz('*NO ')
     D  avlqty                 9     17  0 inz(0)
     D  chkqty                18     26  0 inz(0)
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
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
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $ptrn#          s              7  0
     D $puci           s            100
     D $rtncd          s              8
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10

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
     D #fromslpos      s                   like($sdpos)
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

     D #toslwhdp       s                   like($slwhdp)
     D #tosldisp       s                   like($sldisp)
     D #tosldispnew    s                   like($sldisp)
     D #toslaisl       s                   like($slaisl)
     D #toslloc        s                   like($slloc)
     D #toslrlvl       s                   like($slrlvl)
     D #toslhand       s                   like($slhand)
     D #toslstat       s                   like($slstat)
     D #toslpick       s                   like($slpick)
     D #toslitem       s                   like($slitem)
     D #toslsdef       s                   like($slsdef)

     D #fromititem     s                   like($ititem)
     D #fromittype     s                   like($ittype)
     D #fromitdesc     s                   like($itdesc)
     D #fromitpdsc     s                   like($itpdsc)
     D #fromithead     s             70
     D #fromitwhdp     s                   like($itwhdp)
     D #fromitstyp     s                   like($itstyp)
     D #fromitdesg     s                   like($itdesg)
     D #fromitum1      s                   like($itum1)
     D #fromitflg1     s                   like($itflg1)
     D #fromitum2      s                   like($itum2)
     D #fromitumq2     s                   like($itumq2)
     D #fromitflg2     s                   like($itflg2)
     D #fromitum3      s                   like($itum3)
     D #fromitumq3     s                   like($itumq3)
     D #fromitnrpk     s                   like($imnrpk)
     D #fromitflgd     s                   like($itflgd)
     D #fromitcube     s                   like($itcube)
     D #fromitswgt     s                   like($itswgt)
     D #fromitcwgt     s                   like($itcwgt)
     D #fromitmitem    s                   like($itmitem)
     D #fromitsdef     s                   like($idsdef)
     D #fromittie      s                   like($idtie)
     D #fromithigh     s                   like($idhigh)
     D #fromimltrk     s                   like($imltrk)

     D #fromssbititem  s                   like($ititem)
     D #fromssbittype  s                   like($ittype)
     D #fromssbitdesc  s                   like($itdesc)
     D #fromssbitpdsc  s                   like($itpdsc)
     D #fromssbitwhdp  s                   like($itwhdp)
     D #fromssbitstyp  s                   like($itstyp)
     D #fromssbitdesg  s                   like($itdesg)
     D #fromssbitum1   s                   like($itum1)
     D #fromssbitum2   s                   like($itum2)
     D #fromssbitumq2  s                   like($itumq2)
     D #fromssbitum3   s                   like($itum3)
     D #fromssbitumq3  s                   like($itumq3)
     D #fromssbimltrk  s                   like($imltrk)

     D #newfromititem  s                   like($ititem)
     D #newfromittype  s                   like($ittype)
     D #newfromitdesc  s                   like($itdesc)
     D #newfromitpdsc  s                   like($itpdsc)
     D #newfromitwhdp  s                   like($itwhdp)
     D #newfromithead  s             70
     D #newfromitstyp  s                   like($itstyp)
     D #newfromitdesg  s                   like($itdesg)
     D #newfromitum1   s                   like($itum1)
     D #newfromitflg1  s                   like($itflg1)
     D #newfromitum2   s                   like($itum2)
     D #newfromitumq2  s                   like($itumq2)
     D #newfromitflg2  s                   like($itflg2)
     D #newfromitum3   s                   like($itum3)
     D #newfromitumq3  s                   like($itumq3)
     D #newfromitnrpk  s                   like($imnrpk)
     D #newfromitflgd  s                   like($itflgd)
     D #newfromitcube  s                   like($itcube)
     D #newfromitswgt  s                   like($itswgt)
     D #newfromitcwgt  s                   like($itcwgt)
     D #newfromitmitm  s                   like($itmitem)
     D #newfromitsdef  s                   like($idsdef)
     D #newfromittie   s                   like($idtie)
     D #newfromithigh  s                   like($idhigh)
     D #newfromimltrk  s                   like($imltrk)

     D #newssbititem   s                   like($ititem)
     D #newssbittype   s                   like($ittype)
     D #newssbitdesc   s                   like($itdesc)
     D #newssbitpdsc   s                   like($itpdsc)
     D #newssbitwhdp   s                   like($itwhdp)
     D #newssbitstyp   s                   like($itstyp)
     D #newssbitdesg   s                   like($itdesg)
     D #newssbitum1    s                   like($itum1)
     D #newssbitum2    s                   like($itum2)
     D #newssbitumq2   s                   like($itumq2)
     D #newssbitum3    s                   like($itum3)
     D #newssbitumq3   s                   like($itumq3)
     D #newssbimltrk   s                   like($imltrk)

     D Ypickslot       s               n

     D abort           s              4
     D a58             s             58
     D brkq1           s              5  0
     D bszero          s              1
     D cancel          s              1
     D odrslot         s             12
     D chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
     D curlic#         s                   like($tlic#)
     D curtrn#         s              7  0
     D curtsk          s              6
     D curtyp          s              1
     D dfchk           s              1
     D drierr          s              1
     D dteofl          s              1
     D dteold          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
     D error           s               n
     D exist           s              1
     D exwgfm          s                   like(w2cwt)
     D fmcwgt          s                   like($itcwgt)
     D fmdisp          s                   like($sldisp)
     D fmitem          s             15
     D fmpick          s              1
     D fmqmq2          s              5  0
     D fmtype          s              1
     D fmumq2          s                   like($itumq2)
     D fmwhdp          s              5
     D forever         s               n
     D forevr          s              1
     D found           s              1
     D help            s              5  0
     d hldprdDisp      s             12
     D i               s              2  0
     D itdtyp          s                   like($ltyp)
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
     D kywhdp          s                   like(lbwhdp)
     D kywhse          s                   like($pwhse)
     D lock            s              1
     D msgk            s              4  0
     D newtrn          s              4
     D nxtscr          s              3
     D odisp           s                   like($sldisp)
     D ossDisp         s             12
     D ovrrid          s              1
     D partial         s               n
     D prdtfr          s               n
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtnToOrig       s               n
     D sclear          s              1
     D skipLT210       s               n
     D skpslt          s              1
     D sldtyp          s                   like($ltyp)
     D sltc            s              3  0
     D ssbflg          s              1
     D newssbflg       s              1
     D svtrn1          s              7  0
     D svtrn2          s              7  0
     D svtrn3          s              7  0
     D tempa2          s              2
     D tfr2usrDate     s                   like(today)
     D tfr2usrTime     s              6  0
     D tfroutflag      s               n
     D tocwgt          s                   like($itcwgt)
     D today           s              8  0
     D todisp          s             12
     D toitem          s             15
     D topick          s              1
     D toqty1          s                   like($cqty1)
     D toslup          s              1
     D totype          s              1
     D toumq2          s              5  0
     D towhdp          s              5
     D umq2            s              5  0
     D usesc           s              1  0
     D verifyzero      s               n
     D vfyslt          s              4
     D vrtslt          s              1
     D*warn            s              1
     D whse            s              3  0
     d wkaisl          s              3
     D w1task          s              6
     D w1whdp          s              5
     D w2qty           s              7
     D w2um1           s              5
     D w2um2           s              5
     D w2um3           s              5
     D zmsflag         s               n
     D #rcvarea        s              6
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
     C                   parm                    $puci
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      stackCount = 0
     C                   eval      currRoutine = 'main'
     C                   exsr      phpgmV1V2V3s

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zzwodltjob
     C                   exsr      zsclr
     C                   exsr      zzzdriclose
     C                   exsr      phpgmV1V2V3e
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
     *   Write tracking phrase of which screen is being displayed.
     *
     C                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   select
     C                   when      $pcmd = '*PCKSWAP'
     C                   eval      W1QT01 = $slavl1
     C                   eval      W1QT02 = $slavl2
     C                   eval      W1QT03 = $slavl3
     C                   when      #lline = '16' and client = saval
     C                   exfmt     screen71                             50
     c                   when      $pprg = 'IT222' and error = *off
     C                   other
     C                   exfmt     screen1                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   select
     C                   when      #lline = '16' and client = saval
     C                   exfmt     screen72                             50
     c                   when      $pprg = 'IT222' and error = *off
     C                   other
     C                   exfmt     screen2                              50
     C                   endsl
     C                   endif
     *
     C                   if        nxtscr = '03 '
     C                   select
     C                   when      $pcmd = '*PCKSWAP'
     C                   eval      W3ZERO = 'Y'
     C                   when      #lline = '16' and client = saval
     C                   exfmt     screen73                             50
     C                   other
     C                   exfmt     screen3                              50
     C                   endsl
     C                   endif
     *
     *   Write tracking phrase of what was pressed.
     *
     C                   exsr      phV2onV1
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
     C                   move      '01 '         nxtscr
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
     C                   eval      toslup = *off
     C                   eval      w3zero = ' '
     C                   move      '*NO '        vfyslt
     C                   move      '*NO '        abort
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
     *    Only reset flag when user has NOT been prompted
     *    to verify From slot.
     C                   if        vfyslt <> '*YES'
     C                   eval      toslup = *off
     C                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   move      '*NO '        newtrn
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   eval      toslup = *off
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C                   endif
     *
     C     end03i        endsr
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     C                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                             and $pcmd <> '*PCKSWAP'
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     C                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C                   if        cmdtkn = *on
     C                   write     clrbtm
     C                   endif
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C     cancel        cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     C                   if        $pcmd = '*PCKSWAP'
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine.
     *
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
     *
     *    Verify slot screen previously displayed, return there.
     C                   move      'EOJ'         nxtscr
     *
     *    Only run Abort when user has NOT been prompted
     *    to verify From slot.
     C                   exsr      zzcancel2
     C                   exsr      zzcancel
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     *
     *    Verify slot screen previously displayed, return there.
     C                   move      'EOJ'         nxtscr
     *
     *    Only run Abort when user has NOT been prompted
     *    to verify From slot.
     C                   exsr      zzcancel2
     C                   exsr      zzcancel
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                             or $pcmd = '*PCKSWAP'
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C     redspl        cabeq     *on           endsc2
     C                   endif
     *
     *  Create and close Label records.
     *
     *
     *  Close Transaction record and start IDLE task.
     *
     *
     *  Get option to check TO slot.
     C                   if        opcqty = 'Y'
     *  Call program to verify slot quantity.
     C                   eval      $pdisp = w2disp
     C                   eval      $pwhdp = w1whdp
     C                   eval      whse = $pwhse
     C                   call      'SL635'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
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
     C                   move      '01 '         nxtscr
     C                   exsr      zzcancel2
     C                   eval      $prtn = '*EXIT   '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr03i
     C                   endif
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      '01 '         nxtscr
     C                   exsr      zzcancel2
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endsc3
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                             or $pcmd = '*PCKSWAP'
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     C                   endif
     *
     C     endsc3        endsr
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
     C                   move      *on           sclear
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
     C                   move      #msgf         $msgf
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
     *    IT27004  Slot designation not same as item.
     *
     C     zm7004        begsr
     C                   move      'IT27004'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
     C                   eval      #msgid = 'PIR0109'
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     *   PIR0201  Code must be entered for create.
     *
     C     zm0201        begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Field cna't be blank.
     *
     C     zm0203        begsr
     C                   move      'PIR0203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   move      'PIR1005'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM01  No linked record for item.
     *
     C     zm01          begsr
     C                   move      'IT12001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12216  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   move      'IT12216'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   move      'IT12215'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   move      'IT12217'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   move      'IT12273'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12274  Adjustment not completed - Record locked.
     *
     C     zm74          begsr
     C                   move      'IT12274'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15201  Transfer completed successfully.
     *
     C     zm1521        begsr
     C                   move      'IT15201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT15202  From and To slot cannot be same.
     *
     C     zm1522        begsr
     C                   move      'IT15202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15203  To slot contains a different item.
     *
     C     zm1523        begsr
     C                   move      'IT15203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   move      'IT15204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR2007  Invalid slot, slot inactive.
     *
     C     zm2007        begsr
     C                   move      'PIR2007'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25201  Date sensitive item exists in to slot with dif dte
     *
     C     zm2521        begsr
     C                   move      'IT25201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25202  WARNING:
     *              Date Sensitive item exists in to slot with dif dte
     *
     C     zm2522        begsr
     C                   move      'IT25202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25203  Slot and Item department do not match.
     *
     C     zm2523        begsr
     C                   move      'IT25203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25204  Qty entered cannot be > available qty in FROM slot
     *
     C     zm5204        begsr
     C                   move      'IT25204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25207  Slot and Item section do not match.
     *
     C     zm5207        begsr
     C                   move      'IT25207'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25208  Invalid item type, use base item.
     *
     C     zm5208        begsr
     C                   move      'IT25208'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25209  Invalid quantity, not multiple of base/brk qty.
     *
     C     zm5209        begsr
     C                   move      'IT25209'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT29007  Wrong license plate scanned.
     *
     C     zm9007        begsr
     C                   move      'IT29007'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *     IT29008  Lic#/Lot# found. Try again.
     *
     C     zm9008        begsr
     C                   move      'IT29008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   endsr
     *----------------------------------------------------------------
     *   IT35201   No brk qty defined for base item.
     *
     C     zm3521        begsr
     C                   move      'IT35201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *  ZZCANCEL   User canceled from screen 1.
     *----------------------------------------------------------------

     C     zzcancel      begsr

     *  If TFROUT has already been done, reverse it.

     C                   if        tfroutflag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = #fromslitem
     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = wuUsrWhdp
     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp  = wuUsrDisp
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = w1itm
     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1 = wuRemQty1
     C                   eval      $saqty2 = wuRemQty2
     C                   eval      $saqty3 = wuRemQty3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = curtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = wuPulLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = wuUsrLcns
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

     C                   eval      $saexcdU = *on
     C                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   endif

     C                   endif

     *  Close transaction.

     *  Note: the start time of this tran is sent back in order to
     *        be used as the start time of the following Idle tran.

     C                   call      'ADJTRAN2'
     C                   parm      '*ABORT'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     *  Delete work record(s).

     C                   exsr      zzwrkinz

     *  Start idle.

     *  Note: The start time for this tran is taken from the start
     *        time of the tran just aborted.

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm                    @ppcs             5 0
     C                   parm                    @paisl            5 0
     C                   parm                    @pqty1            5 0
     C                   parm                    @pqty2            5 0
     C                   parm                    @pqty3            5 0
     C                   parm                    @prte             5
     C                   parm                    @ppo              9
     C                   parm                    @pgrp1            1
     C                   parm                    @pgrp2            1
     C                   parm                    @pdate            8 0
     C                   parm                    @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm                    @prtn             8
     C                   parm                    @pmsg             4

     *  Return pallets to slot (pulled in ZZINZ2).

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd   = '*PULRTN'
     C                   eval      $twhse  = $pwhse
     C                   eval      $twhdp  = #fromslwhdp
     C                   eval      $tslot  = #fromsldisp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = #fromToLcns
     C                   exsr      zzzcall$lt210

     C                   endsr

     *----------------------------------------------------------------
     *  ZZCANCEL2  User canceled from screen 2.
     *----------------------------------------------------------------

     C     zzcancel2     begsr

     *  If TFROUT has already been done, reverse it.

     C                   if        tfroutflag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = #fromslitem
     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = wuUsrWhdp
     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp  = wuUsrDisp
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu  = *on

     C                   eval      $saqty1 = wuRemQty1
     C                   eval      $saqty2 = wuRemQty2
     C                   eval      $saqty3 = wuRemQty3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = curtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = wuPulLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'
     C                   eval      $saFrmLcnsU = *on
     C                   eval      $saFrmLcns = wuUsrLcns
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

     C                   eval      $saexcdU = *on
     C                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   endif

     C                   endif

     *    Return quantity that was put into transit.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PUTAWYA'
     C                   eval      $tnexttask= 'PUTAWAY'
     C                   eval      $tlic#    = curlic#
     C                   eval      $tinlic#  = curlic#
     C                   eval      $toutlic# = curlic#
     C                   eval      $twhse    = $pwhse
     C                   eval      $twhdp    = #fromslwhdp
     C                   eval      $tslot    = #fromsldisp
     C                   eval      $titem    = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tpartial = *off
     C                   eval      $tqty1    = w1qt01
     C                   eval      $tqty2    = w1qt02
     C                   eval      $tqty3    = w1qt03
     C                   eval      $tnorm1   = w1qt01
     C                   eval      $tnorm2   = w1qt02
     C                   eval      $tnorm3   = w1qt03
     C                   exsr      zzzcall$lt210

     *    Pull pallet back down, but don't ask user any questions.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*NQDROP'
     C                   eval      $twhse = $pwhse
     C                   eval      $twhdp = #fromslwhdp
     C                   eval      $tslot = #fromsldisp
     C                   eval      $titem = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = curlic#
     C                   eval      $tinlic#  = curlic#
     C                   eval      $toutlic# = curlic#
     C                   exsr      zzzcall$lt210
     C                   eval      curlic# = $tlic#

     *  Delete work record(s).

     C                   exsr      zzwrkinz

     C                   eval      tfroutflag = *off
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   move      *off          error
     *
     *  Verify quantity is greater than zero.
     *
     C                   if        (w1qt01=0 and w1qt02=0 and w1qt02=0)
     C                             or w1qt01 < 0
     C                             or w1qt02 < 0
     C                             or w1qt03 < 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(3)       errmsg
     C                   exsr      zm0009
     C                   goto      endck1
     C                   endif

     *  When transfering from a USR slot, qty entered must
     *  match USR slot qty.

     C                   if        #fromslaisl = 'USR'
     C                   if        w1qt01 <> #fromslavl1
     C                             or w1qt02 <> #fromslavl2
     C                             or w1qt03 <> #fromslavl3
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = 'Entire qty must be taken '
     C                                    + 'for a USR slot'
     C                   exsr      zm0105
     C                   goto      endck1
     C                   endif
     C                   endif

     *  Use DRI interface to do most of the verifications.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = w1itm

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYTFOCHG'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   exsr      zm0001
     C                   goto      endck1
     C                   endif
     *
     C     endck1        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C*   DFCHK Flags are used to force F20 for each test
     C*   Values: Flag = 0 Do check.
     C*           Flag = 1 Check was done, ok.
     C*           Flag = 2 Warning condition.
     C*
     C                   eval      error = *off
      /free
         // if production slot ensure virtual is created for to slot
                         prdtfr = *off;
                         sltc = 0;
                         //wkaisl = ' ';
                         //if w2disp > ' ';
                         //wkaisl = %subst(%trim(w2disp):1:3);
                           wkaisl = %subst(w2disp:1:3);
                         //endif;
                         sltc = %lookup(wkaisl:prdslt:1);
                         if sltc <> 0 and wkaisl <> ' ';
                            prdtfr = *on;
                            exsr clr$slot;
                            $slwhseu = *on;
                            $slwhse  = $pWhse;
                            $slwhdpu = *on;
                            $slwhdp  = #newfromitwhdp;
                            $slitemu = *on;
                            $slitem  = w1itm;
                            $sldispu = *on;
                            $sldisp  = w2disp;
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
      /end-free
     C                   move      w2disp        odisp
     *
     *
     *  "To Slot" can't be blank.
     *
     C                   if        w2disp = *blanks
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0203
     C                   goto      endck2
     C                   endif
     *
     *  If transfer to represents a Repack Item verify on-demand slot
     *  exists
     *
      /free
         if #newfromitType = 'R';
            chain ($pWhse:w1itm) kititem;
            if not %error and %found;
               if kidisp <> ' ';
                  exsr clr$slot;
                  $slwhseu = *on;
                  $slwhse  = $pWhse;
                  $slwhdpu = *on;
                  $slwhdp  = #newfromitwhdp;
                  $slitemu = *on;
                  $slitem  = w1itm;
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
      /end-free
     *
     *  Call API for slot.
     *
     C                   call      @apics
     C                   parm                    w2disp
     C                   parm      6             worow
     C                   parm      11            wocol
     C                   parm                    @artn             8
     C                   if        @artn = '*REDSPLY'
     C                   move      *on           redspl
     C                   goto      endck2
     C                   endif

     *  If slot starts with 'OS' then it must match ossDisp.
     *  (ossDisp is generated with F9=OSS.

     C                   if        %subst(w2disp:1:2)='OS'
     C                             and w2disp <> ossDisp
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(6)       errmsg
     C                   exsr      zm0105
     C                   goto      endck2
     C                   endif
     *
     *  Verify "To Slot" number.
     *

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #newfromitwhdp
     C                   eval      $sldispu  = *on
     c                   if        prdtfr
     C                   eval      $sldisp   = hldprdDisp
     c                   else
     C                   eval      $sldisp   = w2disp
     c                   endif
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = w1itm
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = wuUsrWhdp
     C                   eval      $sacdspu  = *on
     C                   eval      $sacdsp   = wuUsrDisp

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'

     C                   if        w2disp = ossDisp
     C                   eval      $sapullwhdpu = *on
     C                   eval      $sapullwhdp  = #newfromitwhdp
     C                   eval      $sapulldispu = *on
     C                   eval      $sapulldisp  = w2disp
     C                   eval      $sapullbaseu = *on
     C                   eval      $sapullbase  = 'OSS' + #rcvarea
     C                   eval      $sapulllcnsu = *on
     C                   eval      $sapulllcns  = ossLcns
     C                   else
     C                   eval      $sapullwhdpu = *on
     C                   eval      $sapullwhdp  = wuPulWhdp
     C                   eval      $sapulldispu = *on
     C                   eval      $sapulldisp  = wuPulDisp
     C                   eval      $sapullbaseu = *on
     C                   eval      $sapullbase  = wuPulBase
     C                   eval      $sapulllcnsu = *on
     C                   eval      $sapulllcns  = wuPulLcns
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYTFICHG'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endck2
     C                   endif

     C                   eval      #toslwhdp = $slwhdp
     C                   eval      #tosldisp = $sldisp
     C                   eval      #toslaisl = $slaisl
     C                   eval      #toslloc  = $slloc
     C                   eval      #toslrlvl = $slrlvl
     C                   eval      #toslhand = $slhand
     C                   eval      #toslpick = $slpick
     C                   eval      #toslsdef = $slsdef
     C                   eval      #toslstat = $slstat

     *  See if something alread in slot location.

     C                   if        opmput = 'N'
     C                   call      'CHKUSAGE'
     C                   parm      $slwhse       $uWhse
     C                   parm      $slwhdp       $uWhdp
     C                   parm      $sldisp       $uDisp
     C                   parm      $slrsrv       $uRsrv
     C                   parm      $saitem       $uItem
     C                   parm      $slentd       $uEntDte
     C                   parm      $slexpd       $uExpDte
     C                   parm      0             $uPieces
     C                   parm      0             $uRecs
     C                   parm      ' '           $uDiffItem
     C                   parm      ' '           $uDiffEntd
     C                   parm      ' '           $uDiffExpd

     *  For directed putaway, To slot cannot have different item.

     C                   select
     C                   when      client = westside
     C                   if        opmput = 'N' and $uDiffItem = 'Y'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm1523
     C                   goto      endck2
     C                   endif
     C                   endsl
     *
     C                   endif


     *  Save tie/high info if defined for item.

     C                   eval      #newfromitsdef = ' '
     C                   eval      #newfromittie  = 0
     C                   eval      #newfromithigh = 0
     C     1             do        5             i
     C                   if        $idsdef(i) = #toslsdef
     C                   eval      #newfromitsdef = $idsdef(i)
     C                   eval      #newfromittie  = $idtie(i)
     C                   eval      #newfromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
     *

     *  Set override to check slot status change (to / from inactive)
     C                   if        dfchk  = '0' and
     C                             ovrrid = *on
     C                   eval      ovrrid = *off
     C                   endif
     C
     C                   if        dfchk  = '2' and
     C                             ovrrid = *on
     C                   eval      dfchk  = '1'
     C                   endif
     *
     C     endck2        tag
     C                   if        error = *on
     C                   move      odisp         w2disp
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     C                   if        client = saval
     C                             or client = greenleaf
     C                   if        w3zero = '1'
     C                   eval      w3zero  = 'Y'
     C                   endif
     C                   if        w3zero = '9'
     C                   eval      w3zero = 'N'
     C                   endif
     C                   endif
     *
     *    Verify Zero, Y,N
     *
     C                   if        w3zero <> 'Y'  and
     C                             w3zero <> 'N'
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1005
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   move      *off          cmdtkn
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     *
     *      F21 - Item Tie/High Maintenance.
     *
     C                   if        *inkv
     C                   eval      cmdtkn = *on
     C                   z-add     $pwhse        whse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    w1itm
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   exsr      zzcmd1
     *
     *      F8 - View item slot information.
     *
     *      Code removed to allow 650a F8 mods.
     *      F8 - View linked item pick slots
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhse = $pwhse
     C                   eval      $litm = w1itm
     C                   call      'IT233'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   call      'IT234'
     C                   parm                    $luky
     C                   parm                    $lrtn
     C                   endif
     *
     *  Test for F9  - Offsite Storage License Print
     *
     C                   if        *inki
     C                   eval      cmdtkn = *on
     C                   exsr      zzextstg
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   move      *on           ovrrid
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCRTL   Create Label records.
     *
     C     zzcrtl        begsr
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = $pwhdp
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
     C                   eval      fmcwgt = #fromitcwgt
     *
     *    Create label records for case transfer.
     *
     C                   select
     C                   when      w1qt01 <> 0
     C                   eval      lbucod = #fromitum1
     C                   eval      lbqalc = w1qt01
     C                   eval      lbqpck = w1qt01
     C                   eval      lbucub = #fromitcube
     C     lbucub        mult      w1qt01        lbcube
     C                   eval      lbuwgt = #fromitswgt
     C     lbuwgt        mult      w1qt01        lbswgt
     *
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     C                   eval      lbtie = #fromittie
     C                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
     C                   eval      tocwgt = #newfromitcwgt
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = #toslwhdp
     C                   eval      towhdp = #toslwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = #tosldisp
     C                   eval      lbrte = *blanks
     C                   eval      toitem = w1itm
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
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      toitem        lbitem
     C                   move      towhdp        lbwhdp
     C                   move      todisp        lbdisp
     C                   move      fmdisp        lbdsp2
     C                   eval      lbucod = #newfromitum1
     C                   eval      lbqalc = toqty1
     C                   eval      lbqpck = toqty1
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
     C                   write     lbrec
     C                   eval      svtrn1 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C                   exsr      zztrnupdate
     *
     C                   endsl
     *
     *    Create transfer record for breakdown 1 qty.
     *
     C                   select
     C                   when      w1qt02 <> 0
     C                   eval      lbucod = #fromitum2
     C                   eval      lbqalc = w1qt02
     C                   eval      lbqpck = w1qt02
     C                   if        #fromitumq2 > 0
     C     #fromitcube   div(h)    #fromitumq2   lbucub
     C     #fromitswgt   div(h)    #fromitumq2   lbuwgt
     C                   else
     C                   eval      lbuwgt = #fromitswgt
     C                   eval      lbucub = #fromitcube
     C                   endif
     C     lbucub        mult      w1qt02        lbcube
     C     lbuwgt        mult      w1qt02        lbswgt
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     *
     C                   eval      lbtie = #fromittie
     C                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
     C                   eval      tocwgt = #newfromitcwgt
     *
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = #toslwhdp
     C                   eval      towhdp = #toslwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = #tosldisp
     C                   eval      lbrte = *blanks
     C                   move      w1itm         toitem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = *on
     C                   if        newtrn = '*YES'
     C                   exsr      zztrnclose
     C                   exsr      zztrnstart
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
     C                   write     lbrec
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
     C                   write     lbrec
     C                   eval      svtrn2 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C                   exsr      zztrnupdate
     *
     C                   endsl
     *
     *    Create transfer record for breakdown 2 qty.
     *
     C                   select
     C                   when      w1qt03 <> 0
     C                   eval      lbucod = #fromitum3
     C                   eval      lbqalc = w1qt03
     C                   eval      lbqpck = w1qt03
     C                   if        #fromitumq3 > 0
     C     #fromitcube   div(h)    #fromitumq3   lbucub
     C     #fromitswgt   div(h)    #fromitumq3   lbuwgt
     C                   else
     C                   eval      lbuwgt = #fromitswgt
     C                   eval      lbucub = #fromitcube
     C                   endif
     C     lbucub        mult      w1qt03        lbcube
     C     lbuwgt        mult      w1qt03        lbswgt
     *    Save extended weight for item adjustment record.
     C                   add       lbswgt        exwgfm
     *
     C                   eval      lbtie = #fromittie
     C                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
     C                   eval      tocwgt = #newfromitcwgt
     *
     C                   eval      lbwhs2 = $pwhse
     C                   eval      lbwhd2 = #toslwhdp
     C                   eval      towhdp = #toslwhdp
     C                   eval      lbasl2 = #toslaisl
     *
     C                   eval      lbloc2 = #toslloc
     C                   eval      lblvl2 = #toslrlvl
     C                   eval      lbhnd2 = #toslhand
     C                   eval      todisp = #tosldisp
     C                   eval      lbrte = *blanks
     C                   move      w1itm         toitem
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = '2'
     C                   if        newtrn = '*YES'
     C                   exsr      zztrnclose
     C                   exsr      zztrnstart
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
     C                   write     lbrec
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
     C                   write     lbrec
     C                   eval      svtrn3 = curtrn#
     C                   move      '*YES'        newtrn
     *
     *     - Update current transaction.
     *
     C                   exsr      zztrnupdate
     *
     C                   endsl
     *
     *  Close current transaction.
     *
     C                   exsr      zztrnclose
     *
     *
     C     endcrl        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT3   Get default values for add.
     *
     C     zzdft3        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr
     C                   move      $slitem       w1item
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg            10
     *
     C                   eval      $cqty1 = $slavl1
     C                   eval      $cqty2 = $slavl2
     C                   eval      $cqty3 = $slavl3
     *
     C                   call      'CVTQTY'
     C                   parm                    $ccmd             8
     C                   parm                    $cprg            10
     C                   parm                    $cqty1            7 0
     C                   parm                    $cqty2            7 0
     C                   parm                    $cqty3            7 0
     C                   parm                    $cum1             2
     C                   parm                    $cum2             2
     C                   parm                    $cum3             2
     C                   parm                    $cqstr           10
     C                   parm                    $custr           17
     C                   parm                    $crtn             8
     C                   parm                    $cerm
     C                   movel     $cqstr        w1curq
     C                   if        $slalc1 <> 0
     C                             or $slalc2 <> 0
     C                             or $slalc3 <> 0
     C                             or $slpck1 <> 0
     C                             or $slpck2 <> 0
     C                             or $slpck3 <> 0
     C                   eval      *in42 = *on
     C                   eval      w1pend = 'PEND'
     C                   else
     C                   eval      *in42 = *off
     C                   eval      w1pend = '    '
     C                   endif
     *
     *  Get status description.
     *
     C     $slstat       chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
     C                   movel     $slstat       ssdesc
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Get Unit of measure fields
     *
     C                   eval      fmtype = *blanks
     C                   eval      totype = *blanks
     C                   eval      umq2 = 0
     C                   eval      fmqmq2 = 0
     C                   eval      toumq2 = 0
     *
     *   Get item record.
     *
     C                   eval      fmumq2 = #fromitumq2
     C                   eval      $iitem = #fromititem
     *
     C                   eval      $idesc = #fromitdesc
     C                   eval      $ipdsc = #fromitpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      w1item = *blanks
     C                   movel     $istr         w1item
     C                   movel     $istr         w61itm
     C                   eval      w1itm = #fromititem
     C**
     C**  Get SSB item, if one exists
     C**
     C                   eval      w1lbls = *blanks
     C                   eval      w1itms = *blanks
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   if        ssbflg = *on
     C                   movel     'SSB ('       w1lbls
     C     w1lbls        cat       w1um2:0       w1lbls
     C     w1lbls        cat       ')':0         w1lbls
     C                   move      ':'           w1lbls
     *
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #fromssbititem
     C                   parm                    #fromssbitdesc
     C                   parm                    #fromssbitpdsc
     C                   parm                    $istr
     C                   movel     $istr         w1itms
     *
     C                   endif
     *
     C                   move      #fromitwhdp   w1whdp
     *
     C                   eval      w1pslt = *blanks
     *
     *    Retrieve pick slot.
     *
     C                   if        client = halsey
     C                   eval      $scmd = '*FIRST  '
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse            3 0
     C                   parm      $iitem        $sitem           15
     C                   parm      *blanks       woslot           12
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm      *blanks       $srtn             8
     *
     C                   if        $srtn = '*OKPICK '
     C                   eval      w1pslt = woslot
     C                   else
     C                   eval      w1pslt = '*NONE       '
     C                   endif
     C                   endif
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
      /free
        if $pprg = 'IT222';
          select;
            when $puomtype = '2';
              w1qt03 = 1;
            when $puomtype = '1';
              w1qt02 = 1;
            other;
              w1qt01 = 1;
          endsl;
        endif;
      /end-free
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
     C                   move      $sldisp       fmdisp
     C                   eval      w1itm = $slitem
     *
     C                   eval      wofrom = $pdisp
     * protect normal qty if normal uom = 'MP'
      /free
        if client = foodpro;
          if #fromitum1 = 'MP' and #fromitum2 <> ' ';
            *in41 = *on;
          else;
            *in41 = *off;
          endif;
        endif;
      /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr

     *  Call LT210 before getting the To slot.
     *  Re: Normally, a user will put a pallet into a slot, then
     *  scan the slot. Before, we would then ask for a new
     *  license under certain conditions. But, the license is now
     *  way up in the air and may not be scanable anymore.
     *  Therefore, we want to ask for the license now, before the
     *  screen is displayed asking for the license.

     C                   eval      skipLT210 = *off

     *    Determine if we are returning qty to original slot.
     *    (If this logic is changed, also change in ZZUPD2)

     C                   if        #toslwhdp = wuPulWhdp
     C                             and #tosldisp = wuPulDisp
     C                             and w1itm = wuPulItem
     C                   eval      rtnToOrig = *on
     C                   else
     C                   eval      rtnToOrig = *off
     C                   endif

     *    Call license tracking for putaway - Before update
     *    Only call when not returning to original slot.

     C                   if        rtnToOrig = *off

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PUTAWYB'
     C                   eval      $tlic#    = wuUsrLcns
     C                   eval      $tpartial = partial
     C                   eval      $twhse    = $pwhse
     C                   eval      $twhdp    = #toslwhdp
     C                   eval      $tslot    = #tosldisp
     C                   eval      $titem    = w1itm
     C                   eval      $titemdsc = #newfromithead
     C                   eval      $tqty1    = toqty1
     C                   eval      $tqty2    = w1qt02
     C                   eval      $tqty3    = w1qt03
     C                   eval      $tnorm1   = toqty1
     C                   eval      $tnorm2   = w1qt02
     C                   eval      $tnorm3   = w1qt03
     C                   eval      $tuci     = $puci
     *    Force new license if tranfer from pick slot.
     C                   if        Ypickslot = *on
     C                             and partial = *off
     c                             or #FROMSLAISL = 'OSS'
     c                             and partial = *off
     c                             and client = SBertram
     C                   eval      $tlic#    = '*MULTIPLE'
     C                   endif
     C                   exsr      zzzcall$lt210
     *    If *CANCEL sent back,
     C                   if        $treturn = '*CANCEL'
     C                   exsr      zzcancel2
     C                   exsr      zzcancel
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     C                   goto      endfl2
     C                   endif
     *
     *    If *OK sent back,
     *      Set flag to skip LT210 call in ZZUPD2.
     *    Otherwise,
     *      Let the program continue and LT210 will be called again
     *      in ZZUPD2.
     *
     C                   if        $treturn = '*OK'
     C                   eval      skipLT210 = *on
     C                   endif

     C                   endif
     *
     *   Initialize entry fields
     *
     C                   eval      w2qty = *blanks
     C                   eval      w2disp = $pdispto
     C                   eval      w2pslt = *blanks
     C                   eval      w2cwt = *zero
     C                   eval      w2adj = *blanks
     *
     *   Get item record.
     *
     C                   eval      $iitem = w1itm
     *
     C                   eval      $idesc = #newfromitdesc
     C                   eval      $ipdsc = #newfromitpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem
     C                   parm                    $idesc
     C                   parm                    $ipdsc
     C                   parm                    $istr
     C                   eval      w2item = *blanks
     C                   movel     $istr         w2item
     C                   movel     $istr         w62itm
     *
     *    Retrieve hard/soft item designation code.
     *
     C                   eval      $scmd = '*FIRST  '
     C                   call      'GETPSLT'
     C                   parm                    $scmd             8
     C                   parm      $itwhse       $swhse            3 0
     C                   parm      $iitem        $sitem           15
     C                   parm      *blanks       woslot           12
     C                   parm      *blanks       $saisl            3
     C                   parm      *zeros        $sloc             3 0
     C                   parm      *zeros        $srlvl            2 0
     C                   parm      *blanks       $shand            2
     C                   parm      *blanks       $srtn             8
     *
     C                   if        $srtn = '*OKPICK '
     C                   eval      w2pslt = woslot
     C                   else
     C                   eval      w2pslt = '*NONE       '
     C                   endif
     *
     *    Retrieve hard/soft item designation code.
     *
     C                   eval      itdtyp = *blanks
     C                   if        $itdesg > *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ldsg = $itdesg
     C                   call      'DS900'
     C                   parm                    $lparm
     C                   select
     C                   when      $lrtn = '*OK     '
     C                   move      $ltyp         itdtyp
     C                   when      $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   when      $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endsl
     C                   endif
     *
     *   Get SSB item, if one exists
     *
     C                   eval      w2lbls = *blanks
     C                   eval      w2itms = *blanks
     *
     C                   if        newssbflg = *on
     C                   eval      w2um1 = *blanks
     C                   eval      w2um2 = *blanks
     C                   eval      w2um3 = *blanks
     C                   exsr      zzuomnew
     C                   movel     'SSB ('       w2lbls
     C     w2lbls        cat       w2um2:0       w2lbls
     C     w2lbls        cat       ')':0         w2lbls
     C                   move      ':'           w2lbls
     *
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #newfromititem
     C                   parm                    #newfromitdesc
     C                   parm                    #newfromitpdsc
     C                   parm                    $istr
     C                   movel     $istr         w2itms
     *
     C                   endif
     *  Show the qty from screen 1
     C                   eval      $cqty1 = w1qt01
     C                   eval      $cqty2 = w1qt02
     C                   eval      $cqty3 = w1qt03
     *
     C                   call      'CVTQTY'
     C                   parm                    $ccmd
     C                   parm                    $cprg
     C                   parm                    $cqty1
     C                   parm                    $cqty2
     C                   parm                    $cqty3
     C                   parm                    $cum1
     C                   parm                    $cum2
     C                   parm                    $cum3
     C                   parm                    $cqstr
     C                   parm                    $custr
     C                   parm                    $crtn
     C                   parm                    $cerm
     C                   movel     $cqstr        w2curq
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     C                   eval      w3item = w1item
     C                   eval      w3lbls = w1lbls
     C                   eval      w3itms = w1itms
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr

     *  Use DRI interface to get slot information.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKVX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt1
     C                   endif

     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
     C                   eval      #fromslstat = $slstat
     C                   eval      #fromslrsrv = $slrsrv
     C                   eval      #fromslentd = $slentd
     C                   eval      #fromslexpd = $slexpd
     C                   eval      #fromslslfd = $slslfd
     C                   eval      #fromslactv = $slactv
     C                   eval      #fromslbld  = $slbld
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslsdef = $slsdef
     C                   eval      #fromslvirt = $sfvirt
     C                   eval      #fromslstk1 = $slstk1
     C                   eval      #fromslstk2 = $slstk2
     C                   eval      #fromslstk3 = $slstk3
     C                   eval      #fromslalc1 = $slalc1
     C                   eval      #fromslalc2 = $slalc2
     C                   eval      #fromslalc3 = $slalc3
     C                   eval      #fromsltfr1 = $sltfr1
     C                   eval      #fromsltfr2 = $sltfr2
     C                   eval      #fromsltfr3 = $sltfr3
     C                   eval      #fromslpck1 = $slpck1
     C                   eval      #fromslpck2 = $slpck2
     C                   eval      #fromslpck3 = $slpck3
     C                   eval      #fromslrcv1 = $slrcv1
     C                   eval      #fromslrcv2 = $slrcv2
     C                   eval      #fromslrcv3 = $slrcv3
     C                   eval      #fromslphy1 = $slphy1
     C                   eval      #fromslphy2 = $slphy2
     C                   eval      #fromslphy3 = $slphy3
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
     C                   eval      #fromslavl3 = $slavl3
     C                   eval      #fromToLcns = $saToLcns
     C                   eval      #fromToPos  = $saToPos
     C                   eval      #fromOLcns = $saOLcns

     C                   eval      #frombasesldsp = $sacdsp

     *
     *  Slot does not contain an item.
     *
     C                   if        $slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
     C                   goto      endgt1
     C                   endif

     *  Use DRI interface to get slot definition.

     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #fromslpos = $sdpos

     *  Use DRI interface to get item.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt1
     C                   endif

     C                   eval      #fromititem = $ititem
     C                   eval      #fromittype = $ittype
     C                   eval      #fromitdesc = $itdesc
     C                   eval      #fromitpdsc = $itpdsc
     C                   eval      #fromitwhdp = $itwhdp
     C                   eval      #fromitstyp = $itstyp
     C                   eval      #fromitdesg = $itdesg
     C                   eval      #fromitum1  = $itum1
     C                   eval      #fromitflg1 = $itflg1
     C                   eval      #fromitum2  = $itum2
     C                   eval      #fromitumq2 = $itumq2
     C                   eval      #fromitflg2 = $itflg2
     C                   eval      #fromitum3  = $itum3
     C                   eval      #fromitumq3 = $itumq3
     C                   eval      #fromitnrpk = $imnrpk
     C                   eval      #fromitflgd = $itflgd
     C                   eval      #fromitcube = $itcube
     C                   eval      #fromitswgt = $itswgt
     C                   eval      #fromitcwgt = $itcwgt
     C                   eval      #fromitmitem = $itmitem
     C                   eval      #fromimltrk = $imltrk
     C                   eval      #fromitsdef = ' '
     C                   eval      #fromittie  = 0
     C                   eval      #fromithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead

     *  Save tie/high info if defined for item.

     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo

     *  Use DRI interface to get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      ssbflg  = *off
     C                   eval      #fromssbititem = ' '
     C                   eval      #fromssbittype = ' '
     C                   eval      #fromssbitdesc = ' '
     C                   eval      #fromssbitpdsc = ' '
     C                   eval      #fromssbitwhdp = ' '
     C                   eval      #fromssbitstyp = ' '
     C                   eval      #fromssbitdesg = ' '
     C                   eval      #fromssbitum1  = ' '
     C                   eval      #fromssbitum2  = ' '
     C                   eval      #fromssbitumq2 = 0
     C                   eval      #fromssbitum3  = ' '
     C                   eval      #fromssbitumq3 = 0
     C                   eval      #fromssbimltrk = 'L'
     C                   else
     C                   eval      ssbflg  = *on
     C                   eval      #fromssbititem = $ititem
     C                   eval      #fromssbittype = $ittype
     C                   eval      #fromssbitdesc = $itdesc
     C                   eval      #fromssbitpdsc = $itpdsc
     C                   eval      #fromssbitwhdp = $itwhdp
     C                   eval      #fromssbitstyp = $itstyp
     C                   eval      #fromssbitdesg = $itdesg
     C                   eval      #fromssbitum1  = $itum1
     C                   eval      #fromssbitum2  = $itum2
     C                   eval      #fromssbitumq2 = $itumq2
     C                   eval      #fromssbitum3  = $itum3
     C                   eval      #fromssbitumq3 = $itumq3
     C                   eval      #fromssbimltrk = $imltrk
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr

     *  Get new item information.

     *    When item number didn't change.

     c*  took out the if we don't pass in $pitem but want to set
     c*  these fields if needed.
     C*                  if        w1itm = $pitem
     C                   eval      #newfromititem = #fromititem
     C                   eval      #newfromittype = #fromittype
     C                   eval      #newfromitdesc = #fromitdesc
     C                   eval      #newfromitpdsc = #fromitpdsc
     C                   eval      #newfromithead = #fromithead
     C                   eval      #newfromitwhdp = #fromitwhdp
     C                   eval      #newfromitstyp = #fromitstyp
     C                   eval      #newfromitdesg = #fromitdesg
     C                   eval      #newfromitum1  = #fromitum1
     C                   eval      #newfromitflg1 = #fromitflg1
     C                   eval      #newfromitum2  = #fromitum2
     C                   eval      #newfromitumq2 = #fromitumq2
     C                   eval      #newfromitflg2 = #fromitflg2
     C                   eval      #newfromitum3  = #fromitum3
     C                   eval      #newfromitumq3 = #fromitumq3
     C                   eval      #newfromitnrpk = #fromitnrpk
     C                   eval      #newfromitflgd = #fromitflgd
     C                   eval      #newfromitcube = #fromitcube
     C                   eval      #newfromitswgt = #fromitswgt
     C                   eval      #newfromitcwgt = #fromitcwgt
     C                   eval      #newfromitmitm = #fromitmitem
     C                   eval      #newfromitsdef = #fromitsdef
     C                   eval      #newfromittie  = #fromittie
     C                   eval      #newfromithigh = #fromithigh
     C                   eval      newssbflg  = ssbflg
     C                   eval      #newssbititem = #fromssbititem
     C                   eval      #newssbittype = #fromssbittype
     C                   eval      #newssbitdesc = #fromssbitdesc
     C                   eval      #newssbitpdsc = #fromssbitpdsc
     C                   eval      #newssbitwhdp = #fromssbitwhdp
     C                   eval      #newssbitstyp = #fromssbitstyp
     C                   eval      #newssbitdesg = #fromssbitdesg
     C                   eval      #newssbitum1  = #fromssbitum1
     C                   eval      #newssbitum2  = #fromssbitum2
     C                   eval      #newssbitumq2 = #fromssbitumq2
     C                   eval      #newssbitum3  = #fromssbitum3
     C                   eval      #newssbitumq3 = #fromssbitumq3
     C                   goto      endgt2
     C*                  endif

     *    When item number changed.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt2
     C                   endif

     *    When item number changed is an SSB item - must use case item
     c
     c                   if        $ittype = 'S'
     c                   eval      w1itm = $itmitem
     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt2
     C                   endif
     c                   endif

     C                   eval      #newfromititem = $ititem
     C                   eval      #newfromittype = $ittype
     C                   eval      #newfromitdesc = $itdesc
     C                   eval      #newfromitpdsc = $itpdsc
     C                   eval      #newfromitwhdp = $itwhdp
     C                   eval      #newfromitstyp = $itstyp
     C                   eval      #newfromitdesg = $itdesg
     C                   eval      #newfromitum1  = $itum1
     C                   eval      #newfromitflg1 = $itflg1
     C                   eval      #newfromitum2  = $itum2
     C                   eval      #newfromitumq2 = $itumq2
     C                   eval      #newfromitflg2 = $itflg2
     C                   eval      #newfromitum3  = $itum3
     C                   eval      #newfromitumq3 = $itumq3
     C                   eval      #newfromitnrpk = $imnrpk
     C                   eval      #newfromitflgd = $itflgd
     C                   eval      #newfromitcube = $itcube
     C                   eval      #newfromitswgt = $itswgt
     C                   eval      #newfromitcwgt = $itcwgt
     C                   eval      #newfromitmitm = $itmitem
     C                   eval      #newfromimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #newfromititem
     C                   parm                    #newfromitdesc
     C                   parm                    #newfromitpdsc
     C                   parm      ' '           #newfromithead

     *  Use DRI interface to get corresponding SSB item, if any.

     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      newssbflg  = *off
     C                   eval      #newssbititem = ' '
     C                   eval      #newssbittype = ' '
     C                   eval      #newssbitdesc = ' '
     C                   eval      #newssbitpdsc = ' '
     C                   eval      #newssbitwhdp = ' '
     C                   eval      #newssbitstyp = ' '
     C                   eval      #newssbitdesg = ' '
     C                   eval      #newssbitum1  = ' '
     C                   eval      #newssbitum2  = ' '
     C                   eval      #newssbitumq2 = 0
     C                   eval      #newssbitum3  = ' '
     C                   eval      #newssbitumq3 = 0
     C                   eval      #newssbimltrk = 'L'
     C                   else
     C                   eval      newssbflg  = *on
     C                   eval      #newssbititem = $ititem
     C                   eval      #newssbittype = $ittype
     C                   eval      #newssbitdesc = $itdesc
     C                   eval      #newssbitpdsc = $itpdsc
     C                   eval      #newssbitwhdp = $itwhdp
     C                   eval      #newssbitstyp = $itstyp
     C                   eval      #newssbitdesg = $itdesg
     C                   eval      #newssbitum1  = $itum1
     C                   eval      #newssbitum2  = $itum2
     C                   eval      #newssbitumq2 = $itumq2
     C                   eval      #newssbitum3  = $itum3
     C                   eval      #newssbitumq3 = $itumq3
     C                   eval      #newssbimltrk = $imltrk
     C                   endif
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     C     endgt3        endsr
     *----------------------------------------------------------------
     *  getcurrstamp  Get current timestamps
     *----------------------------------------------------------------

     C     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for options file.
     *
     C     keyopd        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for options file, System values.
     *
     C     optsky        klist
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define full key for WORKTFR file.
     *
     C*    wktkey        klist
     C*                  kfld                    #curruser
     C*                  kfld                    #fromsldisp
     *
     *  Define partial key for WORKTFR file.
     *
     C     wktkeyu       klist
     C                   kfld                    #curruser
     *
     *  Define full Key For WORKUSR3
     *
     C     keyUsr3a      klist
     C                   kfld                    wkType
     C                   kfld                    #emp#
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    $pdisp
     *
     *  Define Partial Key For WORKUSR3
     *
     C     keyUsr3b      klist
     C                   kfld                    wkType
     C                   kfld                    #emp#
     *
     *  Define key for WORKOSS file.
     *
     C     keywo         klist
     C                   kfld                    $pwhse
     C                   kfld                    osslcns
     *
     *  Define partial key for WORKOSS1 file.
     *
     C     keywo1        klist
     C                   kfld                    #curruser
     C                   kfld                    #job
     C                   kfld                    #jobnbr
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   move      *off          forevr
     C                   move      '*NO '        newtrn
     C                   move      *off          dteold
     C                   move      *off          dteofl
     C                   move      *off          toslup
     C                   move      *off          skpslt
     C                   if        client = saval
     c                             or client = greenleaf
     C                   eval      woyn = '(1,9)'
     C                   else
     C                   eval      woyn = '(Y,N)'
     C                   endif
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   eval      currRoutine = 'zzinz2'
     C                   exsr      phpgmV1V2V3s
     C                   move      '0'           dfchk
     C                   eval      tfroutflag = *off
     C                   eval      ossDisp = ' '
     C                   eval      ossLcns = ' '
     *
     C                   eval      worow = 0
     C                   eval      wocol = 0
     *
     *  Do not allow the transfer from a RCV/STG file.
     *
     C                   if        %subst($pdisp:1:3) = 'RCV'
     C                             or %subst($pdisp:1:3) = 'STG'
     C                   eval      error = *on
     C                   eval      errmsg = 'RCV/STG slot not allowed '
     C                                    + '- use Putaway'
     C                   exsr      zm0105s
     C                   eval      nxtscr = 'EOJ'
     C                   leavesr
     C                   endif
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     *    - Get default values for the user.
     *
     C                   call      'GETUSER'
     C                   parm                    #curruser
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
     C                   parm                    e$bpu             1
     C                   parm                    e$lng             2
     C                   if        #rtn <> '*OK'
     C                   eval      e$lng = 'EN'
     C                   endif
     *
     *   Clear work file for user.
     *
     C                   exsr      zzwrkinz
     C                   exsr      zzwodltjob
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     *
     *    Retrieve Check "To Slot" quantity option.
     *
     C                   exsr      zzcqty
     *
     *   Get system options.
     *
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*SYSTEM '
     C     optsky        chain     options                            79
     C                   if        *in79
     C                   eval      opmpck = 'N'
     C                   else
     C                   eval      opdat2 = opdata
     C                   endif
     *
     *
     *   Get department description.
     *
     C     keywd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C     keywd         chain     whdept                             79
     C                   if        *in79
     C                   eval      wdcode = *blanks
     C                   eval      wddesc = *blanks
     C                   endif
     *
     *   Get department Options.
     *
     C                   move      '*PICK   '    kycode
     C     keyopd        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     *
     *   Select first screen to display.
     *
     C                   eval      odisp = *blanks
     C                   eval      vfyslt = *blanks
     C                   eval      vrtslt = *off
     C                   eval      lock = *off
     C                   eval      exist = *off
     C                   eval      usesc = 1
     C                   exsr      scr01i
     C                   eval      odisp = *blanks

     *   If an error didn't occur and we are staying in this pgm
     *  and license not passed in...

     C                   if        nxtscr <> 'EOJ'
     C                   select
     C                   when      $plcns = *blanks

     C                   eval      curlic# = #fromToLcns

     *    Call program that will (if necessary) ...
     *      - Prompt user to pull pallet.
     *      - Have user verify license being pulled.
     *      - Update license information.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PULDROP'
     C                   eval      $twhse = $pwhse
     C                   eval      $twhdp = #fromslwhdp
     C                   eval      $tslot = #fromsldisp
     C                   eval      $titem = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = #fromToLcns
     C                   exsr      zzzcall$lt210

     C                   if        $treturn = '*CANCEL'
     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   if        $treturn = '*NOTFND'

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd   = '*PULRTN'
     C                   eval      $twhse  = $pwhse
     C                   eval      $twhdp  = #fromslwhdp
     C                   eval      $tslot  = #fromsldisp
     C                   eval      $titem  = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic# = #fromToLcns
     C                   exsr      zzzcall$lt210

     C                   eval      nxtscr = 'EOJ'
     C                   endif

     C                   other
     C                   eval      curlic# = $plcns
     C                   endsl
     C                   endif

     *    Start transaction.
     *    Add record to work file.

     C                   if        nxtscr <> 'EOJ'
     C                   eval      lbwhdp = #fromslwhdp
     C                   eval      lbstyp = #fromslstyp
     C                   exsr      zztrnstart
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCQTY   Retrieve Check "To Slot" quantity option.
     *
     C     zzcqty        begsr
     *
     C                   eval      kywhse = $pwhse
     C                   eval      opcode = '*REPLEN '
     C     optsky        chain     options                            79
     *
     *    Record not found. Set defaults to No
     *
     C                   if        *in79
     C                   eval      opcqty = 'N'
     *
     *    Record found. Load file data structure.
     C                   else
     C                   eval      opdta3 = opdata
     *
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *  ZZCHKZROVFY   See if we should ask user to zero verify slot.
     *----------------------------------------------------------------

     C     zzchkzrovfy   begsr

     *  See if zero verify flag should be set.

     C                   eval      verifyzero = *off
     C                   dow       forever = forever

     *      Ask the user to zero verify slot if ...

     *      ... the slot only has 1 pallet position.

     C                   if        #fromslpos > 1
     C                   leave
     C                   endif

     *      ... the slot doesn't have a virtual slot associated with it.

     C                   if        #fromslvirt = 'Y'
     C                   leave
     C                   endif

     *      ... %TFR2USR, which is called just before calling this
     *          routine, says the slot is empty.

     C                   if        wuPulVfy <> 'Y'
     C                   leave
     C                   endif

     *      ... slot is either not a virtual slot or
     *          it is the only virtual and the base slot is empty.

     C                   if        #fromslrsrv = 'V'

     *            Get base slot info.

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #frombasesldsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   leave
     C                   endif

     *            Status must be 'Z' or 'V'

     C                   if        $slstat <> 'V' and $slstat <> 'Z'
     C                   leave
     C                   endif

     *            See if any other virtuals are associated with slot.

     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp = $sldisp
     C                   eval      $sldisp = ' '
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTVSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   dow       forever = forever
     C                   exsr      zzzdricop
     C                   if        error or $drireturn = 'EOF'
     C                   eval      error = *off
     C                   leave
     C                   endif
     C                   if        $sldisp = #fromsldisp
     C                   iter
     C                   endif
     C                   leave
     C                   enddo
     C                   if        $drireturn <> 'EOF'
     C                   leave
     C                   endif

     C                   endif

     *      Whew! We have finally determined that we can have the user
     *         verify if the slot is physically empty.

     C                   eval      verifyzero = *on

     C                   leave
     C                   enddo


     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCVDT  Convert date to proper format.
     *
     C     zzcvdt        begsr
     *
     *    Convert date into proper format.
     *
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     *
     C     endcvd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZEXCP Write item exception record to file.
     *
     C     zzexcp        begsr
     *
     *    Write an item exception record.
     C                   eval      exwhse = $pwhse
     C                   eval      exwhdp = $pwhdp
     C                   eval      exstyp = #fromslstyp
     C                   eval      exitem = #fromslitem
     C                   eval      exfdis = #fromsldisp
     C                   eval      extdis = *blanks
     C                   eval      extask = 'TFRMOV'
     *    Get todays date.
     C                   eval      $cvcmd = '*CURCMD '
     C                   exsr      zzcvdt
     C                   eval      exgdte = $cvd8o
     C                   time                    exgtim
     C                   eval      exgby = #curruser
     C                   eval      exesta = '1 '
     C                   write     exrec
     *
     C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZEXTSTG   Offsite Storage Label creation
     *
     C     zzextstg      begsr
     C                   eval      w9dev  = '*JOB'
     C                   eval      w9stg  = 'E'

     *  Springfield setup defaults for screen

     C                   if        client = sgc
     C                   if        #newfromitwhdp = 'DRY  '
     C                   eval      w9stg = 'K'
     C                   eval      w9dev  = 'LP8'
     C                   else
     C                   eval      w9stg = 'W'
     C                   eval      w9dev  = 'LP7'
     C                   endif
     C                   endif

     C                   if        client = eastland
     C                   if        #newfromitwhdp = 'CB   '
     C                   eval      w9stg = 'G'
     C                   else
     C                   eval      w9stg = 'F'
     C                   endif
     C                   endif
     *  Process window to produce license plates for external storage

     C                   dow       forevr = forevr
     C                   exfmt     WEXTSTG
     C                   if        *inkl = *on
     C                   leave
     C                   endif

     *     No errors, create slot and print label

     C                   exsr      zzextstg2
     C                   if        not error
     C                   eval      w2disp = ossdisp
     C                   endif
     C                   leave

     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZEXTSTG2  Create OSS slot
     *
     C     zzextstg2     begsr

     *  Set #rcvarea to apppropriate OSS area.

     C                   select

     C                   when      client = sgc
     C                             and w9stg = 'K'
     C                   eval      #rcvarea = 'KANSAS'

     C                   when      client = sgc
     C                             and w9stg = 'W'
     C                   eval      #rcvarea = 'WILLOW'

     C                   when      client = eastland
     C                             and w9stg = 'G'
     C                   eval      #rcvarea = 'CGEN'

     C                   when      client = eastland
     C                             and w9stg = 'F'
     C                   eval      #rcvarea = 'CFROZ'

     C                   other
     C                   eval      #rcvarea = w9stg

     C                   endsl
     *  Use generic license OR create special license
     C                   select
     C                   when      client = SBertram

     *    Call license tracking for putaway - Before update
     *    to force new license.


     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PUTAWYB'
     C                   eval      $tlic#    = wuUsrLcns
     C                   eval      $tpartial = partial
     C                   eval      $twhse    = $pwhse
     C                   eval      $twhdp    = #toslwhdp
     C                   eval      $tslot    = #tosldisp
     C                   eval      $titem    = w1itm
     C                   eval      $titemdsc = #newfromithead
     C                   eval      $tqty1    = toqty1
     C                   eval      $tqty2    = w1qt02
     C                   eval      $tqty3    = w1qt03
     C                   eval      $tnorm1   = toqty1
     C                   eval      $tnorm2   = w1qt02
     C                   eval      $tnorm3   = w1qt03
     C                   eval      $tuci     = $puci
     *    Force new license if tranfer to OSS
     C                   eval      $tlic#    = '*MULTIPLE'
     C                   exsr      zzzcall$lt210
     *
     C                   eval      ossLcns = $tinlic#

     C                   other
     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm                    $pwhse
     C                   parm                    w9stg
     C                   parm      ' '           ossLcns          15
     C                   endsl

     *  Initialize slot fields

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #newfromitwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1itm
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #newfromitstyp
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = #fromslentd
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = #fromslexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1itm

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = 0
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = 0
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = ossLcns
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = ossLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif

     C                   eval      ossDisp = $sldisp

     *  Create workoss record

     C                   eval      wowhse  = $slwhse
     C                   eval      wowhdp  = $slwhdp
     C                   eval      wodisp  = $sldisp
     C                   eval      wolcns  = ossLcns
     C                   eval      woaddts   = %timestamp()
     C                   eval      woaddcusr = #curruser
     C                   eval      woaddjob  = #job
     C                   eval      woaddnbr  = #jobnbr
     C                   write(e)  worec

     *  Print label

     *  Don't print if using Generic license
     C                   select
     C                   when      client = SBertram
     *
     C                   other
     C                   eval      $plfmt = 'STORAGE'
     C                   if        client = sgc
     C                   eval      $plset = 'ZBRSF2'
     C                   else
     C                   eval      $plfmt = 'PLBL40'
     C                   endif
     *  *** testing purposes ***

     C                   if        w9dev <> '*JOB'
     C                   eval      $pdev  = w9dev
     C                   endif

     C                   eval      $pexpda = %editc(#fromslexpd:'X')
     C                   eval      $pindta = %editc(#fromslentd:'X')

740bMC                   call      @PRTPG
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      $pwhse        $plwhse           3 0
     C                   parm                    $pwhsd           30
     C                   parm                    $slwhdp
     C                   parm                    $sldisp
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    ossLcns
     C                   parm                    $plcn2           15
     C                   parm                    $slitem
     C                   parm                    $pbrnd           10
     C                   parm                    $ppdesc          15
     C                   parm                    $itdesc          30
     C                   parm                    $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
     C                   endsl

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWODLTJOB     Delete WORKOSS records for current job
     *
     C     zzWoDltJob    begsr

     C     keywo1        setll     workoss1

     C                   dow       forevr = forevr
     C     keywo1        reade     workoss1
     C                   if        %eof(workoss1)
     C                   leave
     C                   endif

     *    Delete oss slot that was created.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = wowhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = wowhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = wodisp

     *    Note: Action must be OSS for DRISLOT to delete licactive rec.
     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%DELETEX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *    Delete workoss record.

     C                   delete(e) workoss1

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  ZZTRNCLOSE  Close a transaction
     *----------------------------------------------------------------

     C     zztrnclose    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZTRNIDLE   Start and IDLE transaction.
     *----------------------------------------------------------------

     C     zztrnidle     begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *  ZZTRNSTART  Start a transaction
     *----------------------------------------------------------------

     C     zztrnstart    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'TFRMOV'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'T'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

     *----------------------------------------------------------------
     *  ZZTRNUPDATE  Update transaction pcs, cube and weight.
     *----------------------------------------------------------------

     C     zztrnupdate   begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
     C                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
     C                   eval      bkdwn1 = '*NO '
     C                   eval      bkdwn2 = '*NO '
     C                   eval      *in92 = *off
     C                   if        #fromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
      /free
                         if %lookup(%subst($pdisp:1:3):prdslt) > 0;
                            if #fromitum2<>' ';
                               #fromitflg1 = 'Y';
                            endif;
                            if #fromitum3<>' ';
                               #fromitflg2 = 'Y';
                            endif;
                         endif;
      /end-free
     C                   if        #fromitflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
     C                   if        #fromitflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             #fromitflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             #fromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     #fromitum1    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
     *
     *    Breakdown 1  qty's supported.
     C                   if        #fromitumq2 > *zeros
     C                   eval      bkdwn1 = '*YES'
     C                   endif
     C     #fromitum2    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     *
     *    Breakdown 2  qty's supported.
     C                   if        #fromitumq3 > *zeros
     C                   eval      bkdwn2 = '*YES'
     C                   endif
     C     #fromitum3    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUOMNEW   Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuomnew      begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     C                   eval      bkdwn1 = '*NO '
     C                   eval      bkdwn2 = '*NO '
     C                   eval      *in92 = *off
     C                   if        #newfromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduomnew
     C                   else
     C                   if        #newfromitflg1 = 'N'  and
     C                             newssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
     C                   if        #newfromitflg2 = 'N'  and
     C                             newssbflg = *off  or
     C                             #newfromitflg2 = 'N'  and
     C                             newssbflg = *on  and
     C                             #newfromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     #newfromitum1 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um1 = umshrt
     C                   else
     C                   eval      w2um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
     *
     *    Breakdown 1  qty's supported.
     C                   if        #newfromitumq2 > *zeros
     C                   eval      bkdwn1 = '*YES'
     C                   endif
     C     #newfromitum2 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um2 = umshrt
     C                   else
     C                   eval      w2um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
     *
     *    Breakdown 2  qty's supported.
     C                   if        #newfromitumq3 > *zeros
     C                   eval      bkdwn2 = '*YES'
     C                   endif
     C     #newfromitum3 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um3 = umshrt
     C                   else
     C                   eval      w2um3 = *blanks
     C                   endif
     C                   endif
     C     enduomnew     endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     *
     *   Item changed, set flag for adjustment code entry.
     C                   eval      *in59 = *off
     C                   eval      *in60 = *off
     C*
     C                   if        client = FoodPro
     C*
     C                   if           #fromitcwgt = 'Y'
     C                             or #newfromitcwgt = 'Y'
     C                   eval      *in60 = *on
     C                   else
     C                   eval      *in60 = *off
     C                   endif
     C*
     C                   endif
     *
     *  Set partial quantity flag.
     *
     *    These values were recalculated and sent back from
     *    the VFYTFOCHG command. If all of the original #FROM
     *    buckets were zero and the new Avail quantities are
     *    zero, then the entire quantity is being taken.
     *
     C                   if        $slavl1 = 0 and
     C                             $slavl2 = 0 and
     C                             $slavl3 = 0 and
     C                             #fromslalc1 = 0 and
     C                             #fromslalc2 = 0 and
     C                             #fromslalc3 = 0 and
     C                             #fromslrcv1 = 0 and
     C                             #fromslrcv2 = 0 and
     C                             #fromslrcv3 = 0 and
     C                             #fromslpck1 = 0 and
     C                             #fromslpck2 = 0 and
     C                             #fromslpck3 = 0 and
     C                             #fromsltfr1 = 0 and
     C                             #fromsltfr2 = 0 and
     C                             #fromsltfr3 = 0
     C                   eval      partial = *off
     C                   else
     C                   eval      partial = *on
     C                   endif

     *  License plate tracking item. Update to show in transit.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd     = '*PULTRAN'
     C                   eval      $tlic#    = curlic#
     C                   eval      $tnewlic# = curlic#
     C                   eval      $twhse    = $pwhse
     C                   eval      $titem    = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tpartial = partial
     C                   eval      $tqty1    = w1qt01
     C                   eval      $tqty2    = w1qt02
     C                   eval      $tqty3    = w1qt03
     C                   eval      $tnorm1   = w1qt01
     C                   eval      $tnorm2   = w1qt02
     C                   eval      $tnorm3   = w1qt03
     C                   exsr      zzzcall$lt210

     C                   if        $treturn <> '*OK'
     C                   endif

     C                   eval      curlic# = $tinlic#

     *  Use DRI interface to update From slot.
     *    Note: The $sl info was retrieved in ZZGET1.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem

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
     C                   eval      $saOLcns = wuPulolcns

     *     Set item change flag


     C                   eval      $dricommand = '*SLOT'

     *     Do Reverse transfer if Pick slot and item didn't change.

     C                   if        #fromslpick = 'Y'
     C                             and #fromslitem = w1itm
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
     C                   goto      endup1
     C                   endif
     C                   eval      tfr2usrDate = today
     C                   time                    tfr2usrTime
     C                   eval      tfroutflag = *on
     C                   eval      curlic# = $saToLcns
     C                   eval      $tinlic# = $saToLcns

     *  Override $saFrmEmpty for an empty Pick slot.
     *  Re: We want to ask a user if the slot is empty just in case he is
     *  moving the item to another Pick slot and we are allow to auto verify.

     C                   if        Ypickslot   = *on
     C                             and partial = *off
     C                   eval      $saFrmEmpty = 'Y'
     C                   endif
     *
     *  Create work record.
     *
     C                   exsr      zzwrkadd

     *    Then tell user to put back an pulled pallets.
     *         and move on to the putaway process.

     C                   exsr      zzzclr$lt210
     C                   eval      $tcmd  = '*PULRTN'
     C                   eval      $twhse = $pwhse
     C                   eval      $twhdp = #fromslwhdp
     C                   eval      $tslot = #fromsldisp
     C                   eval      $titem = #fromslitem
     C                   eval      $titemdsc = #fromithead
     C                   eval      $tlic#    = $saToLcns
     C                   exsr      zzzcall$lt210
     C                   if        $treturn <> '*OK'
     C                   endif

     *  Check if slot can be verified after transfer complete.

     C                   exsr      zzchkzrovfy
     C                   if        verifyzero
     C                   exsr      scr03i
     C                   else
     C                   exsr      scr02i
     C                   endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   move      *off          error
     C                   move      *off          dteold
     C                   move      *off          dteofl
     *   Change quantity to breakdown quantity if needed.
     *
     C                   eval      toqty1 = w1qt01

     *    Determine if we are returning qty to original slot.

     C                   if        #toslwhdp = wuPulWhdp
     C                             and #tosldisp = wuPulDisp
     C                             and w1itm = wuPulItem
     C                   eval      rtnToOrig = *on
     C                   else
     C                   eval      rtnToOrig = *off
     C                   endif

     *    Call license tracking for putaway - Before update
     *    Only call when not returning to original slot.

     C                   select

     C                   when      w2disp = ossDisp
     C                   eval      $tinlic# = ossLcns
     C                   eval      $tslotpos = wuPulPos
     C                   eval      $toutlic# = wuUsrLcns

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
     C                   eval      $twhse    = $pwhse
     C                   eval      $twhdp    = #toslwhdp
     C                   eval      $tslot    = #tosldisp
     C                   eval      $titem    = w1itm
     C                   eval      $titemdsc = #newfromithead
     C                   eval      $tqty1    = toqty1
     C                   eval      $tqty2    = w1qt02
     C                   eval      $tqty3    = w1qt03
     C                   eval      $tnorm1   = toqty1
     C                   eval      $tnorm2   = w1qt02
     C                   eval      $tnorm3   = w1qt03
     C                   eval      $tuci     = $puci
     C                   exsr      zzzcall$lt210
     *
     C                   if        $treturn <> '*OK'
     C                   eval      redspl = *on
     C                   eval      error = *on
     C                   eval      errmsg = $terrmsg
     C                   exsr      zm0105
     C                   goto      endup2
     C                   endif

     C                   endif

     C                   endsl

     *  Use DRI interface to tfr qty from USR slot to To slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #toslwhdp
     C                   eval      $sldispu  = *on
     c                   if        prdtfr
     C                   eval      $slstatu  = *on
     C                   eval      $slstat   = 'PR'
     C                   eval      $sldisp   = hldprdDisp
     c                   else
     C                   eval      $sldisp   = #tosldisp
     c                   endif
     C                   eval      $slentdu  = *on
     C                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = w1itm
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C*
     C                   if        client = FoodPro
     C*
     C                   if           #fromitcwgt    = 'Y'
     C                             or #newfromitcwgt = 'Y'
     C                   eval      $sacwtau = '1'
     C                   eval      $sacwta = w2cwt
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

     C                   if        w2disp = ossDisp
     C                   eval      $sapullwhdpu = *on
     C                   eval      $sapullwhdp  = #toslwhdp
     C                   eval      $sapulldispu = *on
     C                   eval      $sapulldisp  = #tosldisp
     C                   eval      $sapullbaseu = *on
     C                   eval      $sapullbase  = 'OSS' + #rcvarea
     C                   eval      $sapulllcnsu = *on
     C                   eval      $sapulllcns  = ossLcns
     C                   else
     C                   eval      $sapullwhdpu = *on
     C                   eval      $sapullwhdp  = wuPulWhdp
     C                   eval      $sapulldispu = *on
     C                   eval      $sapulldisp  = wuPulDisp
     C                   eval      $sapullbaseu = *on
     C                   eval      $sapullbase  = wuPulBase
     C                   eval      $sapulllcnsu = *on
     C                   eval      $sapulllcns  = wuPulLcns
     C                   endif

     *     Set changed item flag if necessary.


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
     C                   goto      endup2
     C                   endif

     *  Update #TO slot info in case item was put into a virtual slot.

     C                   eval      #toslhand = $slhand
     C                   eval      #tosldisp = $sldisp
     c                   if        prdtfr
     C                   eval      #toslstat = 'PR'
     c                   else
     C                   eval      #toslstat = $slstat
     c                   endif

     *  Delete workoss records

     C                   if        w2disp = ossDisp
     C     keywo         chain     workoss
     C                   if        %found(workoss)
     C                   delete(e) workoss
     C                   endif
     C                   endif
      **
      ** Use DRI interface to update From slot.
      **

      ** Use DRI interface to zero verify From slot if needed.

     *    Call license tracking for putaway - After update
     *      Values are left over from "Before" call.

     C                   eval      $tcmd     = '*PUTAWYA'
     C                   eval      $twhdp    = #toslwhdp
     C                   eval      $tslot    = #tosldisp
     C                   exsr      zzzcall$lt210
     *
     C                   if        $treturn <> '*OK'
     C                   endif
      **
      **   If #to slot not the same as the #from slot,
      **     Then see if a zero lichist rec needs to be removed.
      **
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

     *  Use DRI interface to zero verify From slot if needed.

     C                   if        verifyzero and w3zero = 'Y'
     C                             or $pcmd = '*PCKSWAP'
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ZEROVFY'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
     C                   endif

     *  Start idle tran.

     C                   exsr      zztrnidle
     *
     *   Send back info message.
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      errmsg = *blanks
     C                   move      w2qty         erqty
     C                   move      #fromslitem   eritem
     C                   move      fmdisp        erfrom
     C                   eval      erto = w2disp
     C                   exsr      zm1521
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update record.
     *
     C     zzupd3        begsr
     C                   move      *off          error
     *
     *    If user says that the slot is not empty, log an exception.
     *    System says slot should be empty.
     C                   if        w3zero = 'N'
     C                   eval      exerid = 'NOTEMTY'
     *
     C                   if        w1qt01 > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   z-add     w1qt01        exqty
     C                   endif
     *
     C                   exsr      zzexcp
     C                   endif
     *
     C                   exsr      scr02i
     *
     C     endup3        endsr

     *----------------------------------------------------------------
     *  zzwrkadd   Add record to work file for user.
     *----------------------------------------------------------------

     C     zzwrkadd      begsr



     C                   exsr      zzgetcurrstamp
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
     C                   eval      wuNewItem = w1itm

     C                   eval      wuRemQty1 = w1qt01
     C                   eval      wuRemQty2 = w1qt02
     C                   eval      wuRemQty3 = w1qt03

     C                   eval      wuPullCns = $toutlic#
     C                   eval      wuUsrLcns = $tinlic#

     C                   eval      wuRecType = wkType
     C                   eval      wuaddts  = currstampsys
     C                   eval      wuadduc  = currstampuc
     C                   eval      wuaddpgm = #pgm
     C                   eval      wuaddemp = #emp#
     C                   eval      wuaddeusr = #curruser
     C                   eval      wuaddjusr = #user
     C                   eval      wuaddjob = #job
     C                   eval      wuaddnbr = #jobnbr
     c*
     C                   write     wuRec

     C                   endsr

     *----------------------------------------------------------------
     *  zzwrkdel   Delete work file record
     *----------------------------------------------------------------

     C     zzwrkdel      begsr


     C     keyUsr3a      chain(e)  workusr3
     C                   if        %found
     C                   delete    wuRec
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zzwrkinz   Delete existing work records for user.
     *             Don't try to put anything back.
     *----------------------------------------------------------------

     C     zzwrkinz      begsr
     *
     C     keyUsr3b      setll     workUsr3
     C                   dow       forever = forever
     C     keyUsr3b      reade     workUsr3
     C                   if        %eof(workUsr3)
     C                   leave
     C                   endif
     C                   delete    wuRec
     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *  zzwrkupd   Update work file record
     *----------------------------------------------------------------

     C     zzwrkupd      begsr
      *
     C     keyUsr3a      chain(e)  workUsr3
     C                   if        not %found
     C                   eval      i = i
     C                   endif

     C                   eval      wuUsrWhdp = $slwhdp
     C                   eval      wuUsrDisp = $sldisp
     C                   eval      wuNewItem = w1itm

     C                   eval      wuRemQty1 = w1qt01
     C                   eval      wuRemQty2 = w1qt02
     C                   eval      wuRemQty3 = w1qt03

     C                   eval      wuPullcns = $toutlic#
     C                   eval      wuUsrLcns = $tinlic#

     C                   update    wuRec

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
     C                   clear                   $item2
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
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  clr$slotdef  Clear $slotdef data structure fields
     *----------------------------------------------------------------

     C     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
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

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
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
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
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
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
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

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'TFR'         $ttype
     C                   parm      'Transfer'    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
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
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
     C                   parm                    $ttoslot
     C                   parm                    $tpartime
     C                   parm                    $tUCI

     C                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Phrase Routines
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  pushRoutine  -  Add routine to stack
     *----------------------------------------------------------------

      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  popRoutine  -  Remove routine from stack
     *----------------------------------------------------------------

      /free
       begsr popRoutine;

         for i = 1 to stackCount-1;
           eval aRoutine(i) = aRoutine(i+1);
         endfor;

         aRoutine(stackCount) = ' ';
         stackCount -= 1;
         currRoutine = aRoutine(1);

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phClearVars  - Clear phrase variables
     *----------------------------------------------------------------

      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


     *----------------------------------------------------------------
     *  zzWrtPhrase  - Write logging phrase
     *----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = 0;
         pEmp# = #emp#;
         pUser = #curruser;
         pPgm  = #pgm;
         pItem = ' ';
         pWhdp = ' ';
         pLocation = ' ';
         pTrn# = 0;
         pLcns = ' ';
         pLtrn = 0;

      /end-free
     C                   call      'WRTPHRASE'
     c                   parm                    pPhraseId
     c                   parm                    pWhse
     c                   parm                    pEmp#
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm                    pItem
     c                   parm                    pWhdp
     c                   parm                    pLocation
     c                   parm                    pTrn#
     c                   parm                    pLcns
     c                   parm                    pLtrn
     c                   parm                    v1
     c                   parm                    v2
     c                   parm                    v3
     c                   parm                    v4
     c                   parm                    v5
      /free

         if %error;
           eval error = error;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phV2onV1
     *----------------------------------------------------------------

      /free
       begsr phV2onV1;

         pPhraseId = V2onV1;

         exsr phClearVars;
         v1 = nxtscr;

         select;
           when status = rollup;
             v2 = 'PageDn';
           when status = rolldn;
             v2 = 'PageUp';
           when status = comand;
             select;
               when *inka;
                 v2 = 'F1';
               when *inkb;
                 v2 = 'F2';
               when *inkc;
                 v2 = 'F3';
               when *inkd;
                 v2 = 'F4';
               when *inke;
                 v2 = 'F5';
               when *inkf;
                 v2 = 'F6';
               when *inkg;
                 v2 = 'F7';
               when *inkh;
                 v2 = 'F8';
               when *inki;
                 v2 = 'F9';
               when *inkj;
                 v2 = 'F10';
               when *inkk;
                 v2 = 'F11';
               when *inkl;
                 v2 = 'F12';
               when *inkm;
                 v2 = 'F13';
               when *inkn;
                 v2 = 'F14';
               when *inkp;
                 v2 = 'F15';
               when *inkq;
                 v2 = 'F16';
               when *inkr;
                 v2 = 'F17';
               when *inks;
                 v2 = 'F18';
               when *inkt;
                 v2 = 'F19';
               when *inku;
                 v2 = 'F20';
               when *inkv;
                 v2 = 'F21';
               when *inkw;
                 v2 = 'F22';
               when *inkx;
                 v2 = 'F23';
               when *inky;
                 v2 = 'F24';
               other;
                 v2 = 'Unknown Command Key';
             endsl;
           other;
             v2 = 'ENTER';
         endsl;

         exsr phWrtPhrase;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phScrV1pgmV2
     *----------------------------------------------------------------

      /free
       begsr phScrV1pgmV2;

         pPhraseId = scrV1pgmV2;

         exsr phClearVars;

         v1 = nxtscr;
         select;
           when nxtscr <> lastnxtscr;
             v2 = 'displayed';
           when error = *on;
             v2 = 'redisplayed with error';
           other;
             v2 = 'redisplayed';
         endsl;
         lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phPgmV1V2V3e
     *----------------------------------------------------------------

      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  phPgmV1V2V3s
     *----------------------------------------------------------------

      /free
       begsr phPgmV1V2V3s;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'Start';

         exsr phWrtPhrase;

         exsr pushRoutine;

       endsr;
      /end-free

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Adjustment Type
Transfer Quantity
Verify Zero
F10 not allowed - Mult Lic Exist
Invalid OSS slot - Print new label
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
