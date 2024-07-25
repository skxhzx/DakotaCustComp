600 A /copy *libl/qcopysrc,hspecs
720aAH dftactgrp(*NO) actgrp(*NEW)
730aAH bnddir('QC2LE')
500 AF*----------------------------------------------------------------
500 AF*  Multilingual Verision
500 AF*  Every screen and message has a corresponding Spanish version.
500 AF*  Any changes must be made to both languages.
500 AF*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *
     *
     *   CHANGE IT122 IF ANY CHANGES ARE MADE TO THIS PROGRAM
     *
     *
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT222     RF Inventory adjustments - Change
     *  16 April, 1997
     *  Roxanne Harrison
     *
     *  Notes:
     *       Created using IT122
     *       8 X 20 Screens for hand held scanners
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
413 A*    09/26/99  DAS 4.13
     *      - Revised ZZFIL1 to get SSB item if one exists.
     *      - Revised logic to non-display/protect breakdown Qty's.
     *      - Revised screen2 to display 'SSB' next to the Brk1 qty
     *        for an SSB item.
413bA*    02/02/00  MLB  4.13b
     *      - Revised routine ZZUPD to correct IF statements from
     *        $PRTN to $ARTN.
     *      - Revised routine ZZUPD to correct statements from
     *        $PMSG to $AMSG.
414aA*    08/03/00  RRH  4.14a
     *      - Add OPTIONS, ITEMMSC to check multiple pick options.
     *      - Note: IMNRPK can = 0 to allow no pick slots.
414bA*    09/07/00  RH   4.14b
     *      - Revised to check for corresponding SSB record. If one
     *        exists, two records are written to ITEMADJ.
414cA*    09/07/00  RH   4.14c
     *      - Calculate catch weight for each item adjust. record.
     *      - Fix, lost slot record after execute CHKPCK.
415 A*    12/07/00  HNK  4.15
     *      - Incorporate 4.09,4.10,4.11,4.14a,b,c mods from IT122.
415aA*    12/27/00  RH   4.15a
     *      - Round up catch weight for item if no breakdown item
     *        quantity was entered.
415bA*    02/14/01  RH   4.15b
     *      - Create an adjustment and label record for catch weight
     *        only entered.
415cA*    02/20/01  RH   4.15c
     *      - Convert warehouse qtys to smallest uom for compare.
415dA*    04/04/01  RH   4.15d
     *      - Remove 4.14a changes, not needed in this program.
     *
415eA*    06/14/01  DAS  4.15e
     *      - Created a 16-line version of SCREEN1-4 named SCREEN61-64
     *      - Add special message screens for 16-line display.
     *      - Added call to program to get screen size being used.
     *      - Added extra output fields to 16-line screens.
     *      - Revise DSPSCR routine to always write CLRSCR first.
415fA*    07/24/01  RH   4.15f
     *      - Do not allow "replace" if a quantity is pending.
     *      - Fix to calculate the adjustment quantity when replacing
     *        a negative quantity with a positive quantity.
415gA*    08/02/01  RH   4.15g
     *      - Change to allow + adjustment to negative slot qty.
     *
DRI A*    02/19/02  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416aA*    06/11/02  DAS  4.16a
     *      - Recompiled because of change to C#SLOT.
     *
416bA*    06/11/03  DAS  4.16b
     *      - Recompiled because of change to C#ITEM.
     *      - Note, this program doesn't use the second data
     *        parameter, $item2, because the fields are not used.
     *
417 A*    06/25/03  MLB  4.17
     *      - Fix: Revised ZZUPD3 to not allow exit if return from
     *        update was NOT successful.
417 A*    11/13/03  RH   4.17b
     *      - Fix: Added $saby to fill$adj routine.
     *
500 A*    05/24/06  JCJ  5.00
     *      - Added Multilingual logic.
     *
510 A*    07/11/06  JCJ  5.10
     *      - Enh: add warning message if the department of the item
     *             does not match the department of the slot.
     *
510aA*    09/27/06  RAH  5.10a
     *      - Enh: Revised program to add support for Client id
520bA*    10/14/08  RH   5.20b
     *      - Enh: Add call to GETALSW to select alias item to be
     *        adjusted on host.  Write to ITEMADJM and export.
520dA*    04/24/09  RH   5.20d
     *      - Enh: If qty and catch weight are both entered, both must
     *        the same sign (positive or negative).
     *        Renamed IT222FM to IT22201
     *
600 A*    04/28/08  DAS  6.00  P#00045
     *      - License Tracking
     *
600aA*    04/28/08  DAS  6.00a P#00045
     *      - License tracking additions. 500/500a in Jordanos version
     *
600bA*    01/11/09  DAS  6.00b
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Changed all #user to #curruser.
     *
600cA*    05/27/09  DAS  6.00c
     *      - Revised to not allow the scanning of an RCV/STG slot. These
     *        slots are tied to open receiving transaction sot they
     *        need to be handled through the putaway program.
610aA*    08/24/09  RH   6.10a
     *      - Revised to allow F4 lookup on Adj code for 16 line screen
610b *    04/28/10  GJA  6.10b     P#00243
     *      - Enh: Change UCI to be option driven.  OPUCI
610c *    05/11/10  GJA  6.10c     P#00243
     *      - Fix: Change UCI position.
640bA*    08/16/11  RH   6.40b
     *      - Enh: Changed to get PO/Seq# using DRILICENSE and
     *      - DRILICINFO.
     *
650 A*    02/27/13  MLB  6.50
     *      - Enh: Changed to use IT22202, to allow for BIR mod.
     *
650aA*    05/01/14  RBD  6.50a
     *      - Fix: Rev 610b data structure should be opdata, not opddta.
     *
700aA*    05/05/15  LMC  7.00a
     *      - Display file changed to IT22203
     *
700bA*    03/30/16  MR   7.00b
     *      - Add Pounds/Kilograms functionality
700cA*    07/07/16  RH   7.00c
     *      - Change msg DESC / DESCSP to only use 5 messages
710aA*    04/26/17  LMC  7.10a
     *      - Revised to not allow the scanning of an RTN slot. These
     *        slots are tied to open return transaction sot they
     *        need to be handled through the putaway program.
720aA*    08/18/16  LMC  7.20a
     *      - Add UCI Tracking.
     *      - Screem Format changed to IT22205
720bA*    01/07/19  LMC  7.20b
     *      - Don't display and edit for weight if item is not a
     *        catch weigth item.
730aA*    01/31/19  LMC  7.30a
     *      - Remove the *multiple check on uci adjustment type 3
     *        User is asking to scan all uci's in the slot
     *      - do not protect catch weight field, if the weigh was
     *        not extracted from the uci.
     *      - do not do the automatic transfer unless we are trying
     *        to adjust the pick slot.
730bA*    04/04/19  LMC  7.30b
     *      - Fix - uiautyp was not being loaded correctly when adding
     *        a uci during an adjustment.
730cA*    06/19/19  LMC  7.30c
     *      - Fix - if no wieght is entered and its Dairyland get
     *        divide by zero error.
730dA*    09/24/19  LMC  7.30d
     *      - Revised to not allow the scanning of an RWO slot. These
     *        slots are tied to open receipt with no PO transaction
     *        so they need to be handled through the putaway program.
740aA*    03/19/20  RH   7.40a
     *      - Change msg DESC / DESCSP to only use 6 messages
     *        Previous 700b change was missed.
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
EIa A*    08/16/11  RH   EIa  #P1050
     *      - Enh: Call DRILICENSE to get slot license, write
     *        Lot code (PO/SEQ) from original license to IAMEMO.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYaA*    10/20/09  RH   HSYa
     *      - Do not allow adjustment type 2=replace.
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
MJKaA*    10/16/08  RH   MJKa
     *      - Enh: Must enter alias item for base, write to ITEMADJM
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
     *
PCK A*    09/27/06  RAH  PCK
     *      - Enh: Add call to CW133 for Catch
     *             Weight Items, change paramaters passed
     *
PCKaA*    11/28/06  JCJ  PCK
     *      - Enh: Protect Catch Weight field and do not edit if
     *             client is Packers.  Packers will be entering UCI
     *             number instead.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    02/27/13  MLB  BIR
     *      - Enh: Revise pgm to read/write SCREEN3B, SCREEN63B. Screens
     *        revised to add | marker under Memo fld for where to key
     *        p/o nbr.
     *
     *----------------------------------------------------------------
DRYaA*  Client Custom Revisions: Dairyland
     *
     *    12/16/13  RBD  DRYa
     *      - Enh: Added catchweight variance check, hard halt if error.
     *
     *----------------------------------------------------------------
ADFaA*  Client Custom Revisions: A&D Foods
     *    04/20/17  RH   ADFa
     *      - Do not allow entry of CI code.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRaA*    05/05/15  LMC  FPRa
     *      - Enh: Protect normal uom qty when normal UOM = MP.
FPRbA*    07/07/16  RH   FPRb
     *      - Enh: Do not allow adjustment codes 14,41,HY,HN.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit
MRTaA*    09/10/18  RH   MRTa
     *      - Enh: Bypass catch weight entry check
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  31        Pounds/Kilograms Toggle functionality
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
720aA*----------------------------------------------------------------
720aA*  Binding Directories
720aA*----------------------------------------------------------------
720aA
720aAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520dDF*t222fm   cf   e             workstn
650 DF*it22201   cf   e             workstn
700aDF*it22202   cf   e             workstn
700bDF*it22203   cf   e             workstn
720aDF*it22204   cf   e             workstn
730aDF*it22205   cf   e             workstn
730aMFit22206   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Funmesr    if   e           k disk
600bDF*lotdef   if   e           k disk
415eAFslotstat  if   e           k disk
520bAFitemlnk1  if   e           k disk
520bAFitemadjm  o    e             disk
520bAFpiritem   if   e           k disk
610bAFoptions   if   e           k disk
DRYaAFitemmsc   if   e           k disk
720aAFupc2      if   e           k disk
720aAFplined    if   e           k disk
720aAFkititem   if   e           k disk
720aAFworkUsr3  uf a e           k disk
720aAFLabel     o  a e           k disk
730aAFlicactive1if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
510 D**desc            s             50    dim(3) ctdata perrcd(1)
520bDD*desc            s             50    dim(4) ctdata perrcd(1)
520bDD*desc            s             50    dim(5) ctdata perrcd(1)
720aDD*desc            s             50    dim(6) ctdata perrcd(1)
740aDD*desc            s             50    dim(7) ctdata perrcd(1)
740aMD desc            s             50    dim(6) ctdata perrcd(1)
510 D**descsp          s             50    dim(3) ctdata perrcd(1)
520bDD*descsp          s             50    dim(4) ctdata perrcd(1)
520bMD*descsp          s             50    dim(5) ctdata perrcd(1)
720adD*descsp          s             50    dim(6) ctdata perrcd(1)
740aDD*descsp          s             50    dim(7) ctdata perrcd(1)
740aMD descsp          s             50    dim(6) ctdata perrcd(1)
720aAD prdslt          S              3    dim(100)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
700bA /copy qcopysrc,p.getimuom
720aA /copy qcopysrc,p.cvtbar

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

720aA /COPY *libl/qcopysrc,C#BARCODE
720aA /COPY *libl/qcopysrc,C#CVTPARMS
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
640bA /COPY *libl/qcopysrc,C#LICENSE
640bA /COPY *libl/qcopysrc,C#LICINFO
600bA /COPY *libl/qcopysrc,C#SLOTDEF
720aA /COPY *libl/qcopysrc,C#UCIINFO
600bAD saveVer#        s                   like($slver#)

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*----------------------------------------------------------------

510aA /copy qcopysrc,id#packers
mjkaA /copy qcopysrc,id#mjkelln
HSYaA /copy qcopysrC,id#halsey
EIa A /copy qcopysrc,id#ei
BIR A /copy qcopysrc,id#birite
DRYaA /copy qcopysrc,id#dairyla
FPRaA /copy qcopysrC,id#fpr
MRTaA /copy qcopysrC,id#mrt
ADFaA /copy qcopysrC,id#adf
720aA /COPY QCOPYSRC,Id#Eastlan

410 AD*slotds        e ds                  extname(slot)

600aA*----------------------------------------------------------------
600aA*  LT210 parameters
600aA*----------------------------------------------------------------

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
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

520b D $awhse          s                   like($pwhse)
520b D $aitem          s                   like($iitem)
520b D $asitm          s                   like($iitem)
520b D $artn           s                   like($prtn)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
DRYaAD caltol          s             13  4
     D chgqt1          s                   like($saqty1)
     D chgqt2          s                   like($saqty2)
     D chgqt3          s                   like($saqty3)
600bAD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
DRYaAD errng           s              3  1
     D error           s               n
DRYaAD exwgt           s              9  2
DRYaAD exwgt1          s              9  2
DRYaAD exwgt2          s              9  2
DRYaAD exwgt3          s              9  2
520b D forevr          s              1
     D help            s              5  0
DRYaAD hirng           s              9  2
DRYaAD hivar           s              9  2
DRYaAD lwrng           s              9  2
DRYaAD lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
DRYaAD prg1c           s              4  3
DRYaAD prg2c           s              4  3
     D rolldn          s              5  0
     D rollup          s              5  0
     D refrsh          s               n
     D savav1          s                   like($slavl1)
     D savav2          s                   like($slavl2)
     D savav3          s                   like($slavl3)
     D savst           s                   like($slstat)
     D sclear          s              1
     D ssbflg          s               n
520b D svalis          s                   like($iitem)
     D temp            s             20
     D usesc           s              1  0
     D warn            s               n
DRYaAD wgtDiff         s             11  4
     D whse            s              3  0
640bAD wocode          s             10
     D woitem          s             50
640bAD worpo           s              9
640bAD woseq           s              3  0
     D wostyp          s              5
     D wowhse          s             40
     D W1excq          s             10
     D W1incq          s             10
     D w1qty1          s                   like($cqty1)
     D w1qty2          s                   like($cqty2)
     D w1qty3          s                   like($cqty3)
     D W1sdes          s             30
     D W1slds          s             30
     D zmsflag         s               n
510aAD client          s             10
700bAD KiloLbs         s              1
700bAD BegKiloLbs      s              1
700bAD kgs2lbs         c                   2.20462262
700bAD CnvWgt          s              9  2
700bAD IMUOM           s              3

720aAD  $ppartime      s               Z
720aDD* uciqty         s              5  0
720aAD  uciqty1        s              5  0
720aAD  uciqty2        s              5  0
720aAD  uciqty3        s              5  0
720aAD  uciwgt         s              9  2
720aAD kyupc           s                   like(upupc)
720aAD today           s              8  0

720aAD sltc            s              3  0
720aAd hldprdDisp      s             12
720aAD prdtfr          s               n
720aAd wkaisl          s              3
720aAD odrslot         s             12
720aAD #frombasesldsp  s                   like($sldisp)

720aAD #fromslwhdp     s                   like($slwhdp)
720aAD #fromslstyp     s                   like($slstyp)
720aAD #fromsldisp     s                   like($sldisp)
720aAD #fromslaisl     s                   like($slaisl)
720aAD #fromslloc      s                   like($slloc)
720aAD #fromslpseq     s                   like($slpseq)
720aAD #fromslrlvl     s                   like($slrlvl)
720aAD #fromslhand     s                   like($slhand)
720aAD #fromslstat     s                   like($slstat)
720aAD #fromslrsrv     s                   like($slrsrv)
720aAD #fromslentd     s                   like($slentd)
720aAD #fromslexpd     s                   like($slexpd)
720aAD #fromslslfd     s                   like($slslfd)
720aAD #fromslactv     s                   like($slactv)
720aAD #fromslbld      s                   like($slbld)
720aAD #fromslpick     s                   like($slpick)
720aAD #fromslitem     s                   like($slitem)
720aAD #fromslsdef     s                   like($slsdef)
720aAD #fromslpos      s                   like($sdpos)
720aAD #fromslvirt     s                   like($sfvirt)
720aAD #fromslstk1     s                   like($slstk1)
720aAD #fromslstk2     s                   like($slstk2)
720aAD #fromslstk3     s                   like($slstk3)
720aAD #fromslalc1     s                   like($slalc1)
720aAD #fromslalc2     s                   like($slalc2)
720aAD #fromslalc3     s                   like($slalc3)
720aAD #fromsltfr1     s                   like($sltfr1)
720aAD #fromsltfr2     s                   like($sltfr2)
720aAD #fromsltfr3     s                   like($sltfr3)
720aAD #fromslpck1     s                   like($slpck1)
720aAD #fromslpck2     s                   like($slpck2)
720aAD #fromslpck3     s                   like($slpck3)
720aAD #fromslrcv1     s                   like($slrcv1)
720aAD #fromslrcv2     s                   like($slrcv2)
720aAD #fromslrcv3     s                   like($slrcv3)
720aAD #fromslphy1     s                   like($slphy1)
720aAD #fromslphy2     s                   like($slphy2)
720aAD #fromslphy3     s                   like($slphy3)
720aAD #fromslavl1     s                   like($slavl1)
720aAD #fromslavl2     s                   like($slavl2)
720aAD #fromslavl3     s                   like($slavl3)
720aAD #fromToLcns     s                   like($saToLcns)
720aAD #fromToPos      s                   like($saToPos)
720aAD #fromOLcns      s                   like($saOLcns)

720aAD partial         s               n
720aAD curlic#         s                   like($tlic#)
720aAD tfroutflag      s               n
720aAD tfr2usrDate     s              8  0
720aAD tfr2usrTime     s              6  0
720aAD Ypickslot       s               n
720aAD curtrn#         s              7  0
720aAD fmcwgt          s                   like($itcwgt)
720aAD fmdisp          s                   like($sldisp)
720aAD fmitem          s             15
720aAD fmwhdp          s              5
720aAD newtrn          s              4
720aAD exwgfm          s              9  2
720aAD svtrn1          s              7  0
720aAD svtrn2          s              7  0
720aAD svtrn3          s              7  0
720aAd #TOSLAISL       s                   like($slaisl)
720aAd #TOSLHAND       s                   like($slhand)
720aAd #TOSLLOC        s                   like($slloc)
720aAd #TOSLRLVL       s                   like($slrlvl)
720aAd #TOSLSTAT       s                   like($slstat)
730aAd #TOSLPICK       s                   like($slpick)
720aAD tocwgt          s                   like($itcwgt)
720aAD todisp          s             12
720aAD toitem          s             15
720aAD toqty1          s                   like($cqty1)
720aAD towhdp          s              5
720aAD  $ttoslot       s             12
720aAD  $tpartime      s               Z
720aAD  wkType         s              3    INZ('TFR')
720aAD redspl          s              1
720aAD rtnToOrig       s               n
720aAD skipLT210       s               n
720aAD  $tUCI          s            100
720aA*----------------------------------------------------------------
720aA*  Time variables
720aA*----------------------------------------------------------------
720aA
720aAD CurrStamploc    s               z
720aAD CurrStampsys    s               z
720aAD CurrStampuc     s               z
720aA
720aAD bfcoffset       s              3  0 inz(0)
720aA*----------------------------------------------------------------
720aA* Function prototypes.
720aA*----------------------------------------------------------------
720aA
720aA /copy qcopysrc,p.bfcdteti

730aA*  Prototype to pause execution
730aAD sleep           PR            10I 0 extproc('sleep')
730aAD   seconds                     10U 0 value
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
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $puser                39     48
720aAD  $SlotLcns             49     63
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
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
pck AD @cwght          c                   const('CW133')
520bAD @gtals          c                   const('GETALSW')
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
     D  $lcode                19     20
PCK AD  $lwhseu               19     21  0
PCK AD  $litemu               22     36
PCK AD  $lcodeu               37     38
PCK AD  $w1type               39     39
PCK AD  w1qt01                40     44  0
PCK AD  w1qt02                45     47  0
PCK AD  w1qt03                48     50  0
PCK AD  w1cwtr                51     59  2
PCK AD  $ldate                60     64p 0
PCK AD  $ltime                65     68p 0
720aAD  $lwhseTfr             19     21  0
720aAD  $lwhdpTfr             22     26
720aAD  $ldispTfr             27     38
720aAD  $ldispTfrTo           39     50
720aAD  $luomTfr              51     51
720aAD  $llcnsTfr             54     68
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
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  eridsg                 1      5
     D  ersdsg                 6     10
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
500 AD #msgfsp         c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
     *----------------------------------------------------------------
     *  Program info data structure
     *
600bA /Copy qcopysrc,c#pgminfds
600bAD**              sds
600bAD**#prog            *proc
600bAD**#job                 244    253
600bAD**#user                254    263
600bAD**#jobn                264    269
600bAD**#jobdt               276    281  0
600bAD**#jobtm               282    287  0
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
610bA*----------------------------------------------------------------
610bA*  *SYSTEM  -  System options.
610bA*----------------------------------------------------------------
610bA*
610bA* Fields
610bA*
DRYaA*    OPRG1C  -  Catch weight low variance percentage.
DRYaA*    OPRG2C  -  Catch weight high variance percentage.
610bA*    OPUCI   -  Use UCI processing (Y,N)
610bA*
610bA* Data structure
610bA*
650aDD*opddta          ds
650aMD opdata          ds
DRYaAD  oprg1c                 6      8  1
DRYaAD  oprg2c                 9     11  1
610cDD**opuci                 33     33
610cMD  opuci                 36     36
610bAD  optendj              117    117
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
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
720aAC                   eval      *in96 = *off
720aAC                   eval      *in94 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
 1B  C                   if        error = *on
     C                   move      'EOJ'         nxtscr
 1E  C                   endif
     *
 1B  C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
 2B  C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
720aAC     nxtscr        caseq     '06 '         sc6
720aAC     nxtscr        caseq     '07 '         sc7
 2E  C                   endcs
 1E  C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     C                   write     clrscr
     *
     *   Set ON alarm indicator if error occured
     *
 1B  C                   if        error = *on
     C                   eval      *in98 = *on
 1E  C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
 1B  C                   if        nxtscr = '01 '
 2B  C                   select
500 AC                   when      e$lng = 'SP' and #lline = '16'
500 AC                   exfmt     scrn61sp                             50
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn1sp                              50
500 DC**                 when      #lline = '16'
500 MC                   when      e$lng = 'EN' and #lline = '16'
     C                   exfmt     screen61                             50
500 DC**                 other
500 MC                   when      e$lng = 'EN'
     C                   exfmt     screen1                              50
 2E  C                   endsl
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '02 '
 2B  C                   select
500 AC                   when      e$lng = 'SP' and #lline = '16'
500 AC                   exfmt     scrn62sp                             50
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn2sp                              50
500 DC**                 when      #lline = '16'
500 MC                   when      e$lng = 'EN' and #lline = '16'
     C                   exfmt     screen62                             50
500 DC**                 other
500 MC                   when      e$lng = 'EN'
     C                   exfmt     screen2                              50
 2E  C                   endsl
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '03 '
 2B  C                   select
500 AC                   when      e$lng = 'SP' and #lline = '16'
500 AC                   exfmt     scrn63sp                             50
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn3sp                              50
500 DC**                 when      #lline = '16'
500 MC                   when      e$lng = 'EN' and #lline = '16'
BIR A*
BIR AC                   select
BIR AC                   when      client = Birite
BIR AC                   exfmt     screen63b
BIR AC                   other
BIR A*
     C                   exfmt     screen63                             50
BIR AC                   endsl
BIR A*
500 DC**                 other
500 MC                   when      e$lng = 'EN'
BIR A*
BIR AC                   select
BIR AC                   when      client = Birite
BIR AC                   exfmt     screen3b
BIR AC                   other
BIR A*
     C                   exfmt     screen3                              50
BIR AC                   endsl
BIR A*
 2E  C                   endsl
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '04 '
 2B  C                   select
500 AC                   when      e$lng = 'SP' and #lline = '16'
500 AC                   exfmt     scrn64sp                             50
500 AC                   when      e$lng = 'SP'
500 AC                   exfmt     scrn4sp                              50
500 DC**                 when      #lline = '16'
500 MC                   when      e$lng = 'EN' and #lline = '16'
     C                   exfmt     screen64                             50
500 DC**                 other
500 MC                   when      e$lng = 'EN'
     C                   exfmt     screen4                              50
 2E  C                   endsl
 1E  C                   endif
720aAC                   if        nxtscr = '06 '
720aAC                   select
720aAC                   when      e$lng = 'SP' and #lline = '16'
720aAC                   exfmt     scrn66sp                             50
720aAC                   when      e$lng = 'SP'
720aAC                   exfmt     scrn6sp                              50
720aAC                   when      e$lng = 'EN' and #lline = '16'
720aAC                   exfmt     screen66                             50
720aAC                   when      e$lng = 'EN'
720aAC                   exfmt     screen6                              50
720aAC                   endsl
720aAC                   endif

720aAC                   if        nxtscr = '07 '
720aAC                   select
720aAC                   when      e$lng = 'SP' and #lline = '16'
720aAC*                  exfmt     scrn66sp                             50
720aAC                   exfmt     screen7                              50
720aAC                   when      e$lng = 'SP'
720aAC*                  exfmt     scrn6sp                              50
720aAC                   exfmt     screen7                              50
720aAC                   when      e$lng = 'EN' and #lline = '16'
720aAC*                  exfmt     screen66                             50
720aAC                   exfmt     screen7                              50
720aAC                   when      e$lng = 'EN'
720aAC                   exfmt     screen7                              50
720aAC                   endsl
720aAC                   endif
     *
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       10
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
     *  Refresh screen fields if requested.
     *
 1B  C                   if        refrsh = *on
     *
     *  Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 2X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 2E  C                   endif
 1E  C                   endif
     C                   eval      refrsh = *off
510 AC                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *  Refresh screen fields if requested.
     *
 1B  C                   if        refrsh = *on
     *
     *  Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
 2X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
 2E  C                   endif
 1E  C                   endif
720aA * for uci tracked items auto fill the screen fields from the
720aA * information scanned - Qty/weight
720aA /free
720aA   if $imltrk = 'U';
720bA     if $itcwgt <> 'Y';
720bA       *in95 = *on;
720bA     else;
720bA       *in95 = *off;
720bA     endif;
720aA     Select;
720aA       when w6type = '1';
720aA         //w1qt01 = uciqty;
720aA         w1qt01 = uciqty1;
720aA         w1qt02 = uciqty2;
720aA         w1qt03 = uciqty3;
720aA         w1cwtr = uciwgt;
720aA         *in96 = *on;
730aA         if w1cwtr > 0;
720aA           *in94 = *on;
730aA         endif;
720aA       when w6type = '2';
720aA         //w1qt01 = uciqty;
720aA         w1qt01 = uciqty1;
720aA         w1qt02 = uciqty2;
720aA         w1qt03 = uciqty3;
720aA         w1cwtr = uciwgt;
720aA         *in96 = *on;
730aA         if w1cwtr < 0;
720aA           *in94 = *on;
730aA         endif;
720aA       when w6type = '3';
720aA         //w1qt01 = ($slavl1 - uciqty) *-1;
720aA         w1qt01 = ($slavl1 - uciqty1) *-1;
720aA         w1qt02 = ($slavl2 - uciqty2) *-1;
720aA         w1qt03 = ($slavl3 - uciqty3) *-1;
730aA         w1cwtr = uciwgt;
720aA         *in96 = *on;
720aA       when w6type = '4';
720aA         *in96 = *on;
720aA         w1qt01 =- $slavl1;
720aA         w1qt02 =- $slavl2;
720aA         w1qt03 =- $slavl3;
730aA         w1cwtr = uciwgt;
720aA     endsl;
720aA   endif;
720aA /end-free
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     *  Refresh screen fields if requested.
     *
 1B  C                   if        refrsh = *on
     *
     *  Get field defaults if this is an add.
     *
 2B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft3
 2X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget3
     C                   exsr      zzfil3
 2E  C                   endif
 1E  C                   endif
     C                   eval      refrsh = *off
     C                   eval      ovrrid = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
     *
     *
     *  Get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget4
     C                   exsr      zzfil4
     C                   eval      ovrrid = *off
     C     end04i        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  Screen 06 initialization
720aA*
720aAC     scr06i        begsr
720aAC                   move      '06 '         nxtscr
720aA*
720aA*
720aA*  Get field defaults.
720aA*
720aAC                   exsr      zzdft6
720aA*
720aAC                   eval      refrsh = *off
720aAC                   eval      ovrrid = *off
720aAc                   eval      uciqty = 0
720aAc                   eval      uciqty1= 0
720aAc                   eval      uciqty2= 0
720aAc                   eval      uciqty3= 0
720aAc                   eval      uciwgt = 0
720aAC     end06i        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  Screen 07 initialization
720aA*
720aAC     scr07i        begsr
720aAC                   move      '07 '         nxtscr
720aA*
720aA*
720aA*  Get field defaults.
720aA*
720aAC                   exsr      zzdft7
720aA*
720aAC                   eval      refrsh = *off
720aAC                   eval      ovrrid = *off
720aAC     end07i        endsr
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
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr01i
 2E  C                   endif
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc1
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     C                   move      *off          refrsh
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr02i
 2E  C                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
720aAC                   if        $imltrk = 'U'  and w6type <> '4'
720aAc                                            and w6type <> '2'
720aAc                                            and w6type <> '1'
720aAC                   exsr      scr07i
720aAC                   else
730aAC                   exsr      AdjCancel
     C                   exsr      scr01i
720aAC                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *  zzchk2
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
 1E  C                   endif
     *
     C                   move      *off          refrsh
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr03i
 2E  C                   endif
goto Csr                 goto      endsc3
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr02i
goto Csr                 goto      endsc3
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
 1E  C                   endif
     *
     C                   move      *off          refrsh
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
 1B  C                   if        *inkc
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F5 - Refresh
     *
 1B  C                   if        *inke
 2B  C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr04i
 2E  C                   endif
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      *off          refrsh
     C                   exsr      scr03i
goto Csr                 goto      endsc4
 1E  C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
 1E  C                   endif
     *
     C                   move      *off          refrsh
     C     endsc4        endsr
     *----------------------------------------------------------------
720aA*
720aA*  SC6  -  Screen 6
720aA*
720aAC     sc6           begsr
720aA*
720aA*  Test for F3 - Exit
720aA*
720aAC                   if        *inkc
720aAC                   move      'EOJ'         nxtscr
720aAC                   eval      $prtn = '*EXIT   '
720aAC                   goto      endsc6
720aAC                   endif
720aA*
720aA*  Test for F5 - Refresh
720aA*
720aAC                   if        *inke
720aAC                   if        $pcmd <> '*VIEW   '
720aAC                   move      *on           refrsh
720aAC                   exsr      scr06i
720aAC                   endif
720aAC                   goto      endsc6
720aAC                   endif
720aA*
720aA*  Test for F12 - Previous
720aA*
720aAC                   if        *inkl
720aAC                   move      *off          refrsh
720aAC                   exsr      scr01i
720aAC                   goto      endsc6
720aAC                   endif
720aA*
720aA*  Test for other command keys BEFORE verification and update.
720aA*
720aAC                   exsr      zzcmd6
720aAC     cmdtkn        cabeq     *on           endsc6
720aA*
720aA*  Some other key pressed.
720aA*
720aA*     Check input and write/update record.
720aA*
720aAC                   if        $pcmd = '*ADD    '  or
720aAC                             $pcmd = '*CHANGE '
720aAC                   exsr      zzchk6
720aAC     error         cabeq     *on           endsc6
720aAC                   exsr      zzupd6
720aAC     error         cabeq     *on           endsc6
720aAC                   endif
720aA*
720aAC                   move      *off          refrsh
720aAC     endsc6        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  SC7  -  Screen 7
720aA*
720aAC     sc7           begsr
720aA*
720aA*  if User cancels out of this screen, need to delete any uci's
720aA*  that were added while doing this adjustment.
720aA*  They will have the time stamp and a license of *BFCADJADD
720aA*
720aA*
720aA*  Test for F3 - Exit
720aA*
720aAC                   if        *inkc
720aAC                   move      'EOJ'         nxtscr
720aAC                   eval      $prtn = '*EXIT   '
720aAC                   exsr      AdjCancel
720aAC                   goto      endsc7
720aAC                   endif
720aA*
720aA*  Test for F5 - Refresh
720aA*
720aAC                   if        *inke
720aAC                   if        $pcmd <> '*VIEW   '
720aAC                   move      *on           refrsh
720aAC                   exsr      scr07i
720aAC                   endif
720aAC                   goto      endsc7
720aAC                   endif
720aA*
720aA*  Test for F12 - Previous
720aA*
720aAC                   if        *inkl
720aAC                   move      *off          refrsh
720aAC                   exsr      AdjCancel
720aAC                   exsr      scr06i
720aAC                   goto      endsc7
720aAC                   endif
720aA*
720aA*  Test for other command keys BEFORE verification and update.
720aA*
720aAC                   exsr      zzcmd7
720aAC     cmdtkn        cabeq     *on           endsc7
720aA*
720aA*  Some other key pressed.
720aA*
720aA*     Check input and write/update record.
720aA*
720aAC                   if        $pcmd = '*ADD    '  or
720aAC                             $pcmd = '*CHANGE '
720aAC                   exsr      zzchk7
720aAC     error         cabeq     *on           endsc7
720aAC                   exsr      zzupd7
720aAC     error         cabeq     *on           endsc7
720aAC                   endif
720aA*
720aAC                   move      *off          refrsh
720aA * when uci tracking and removing a individual uci we will
720aA * process them thru one at a time, because the uci could be
720aA * in multiple slots, and we will adjust the slot the uci is
720aA * currently identifed in the system
720aAc                   if        w6type = '2'
720aAc                   exsr      scr02i
720aAc                   endif
720aA * when uci tracking and adding a individual uci we will
720aA * process them thru one at a time, because the uci could be
720aA * in multiple slots, and we will adjust the slot the uci is
720aA * currently identifed in the system
720aA * if the uci is identified in a slot currently, we will do
720aA * a transfer instead of an adjustment.
720aAc                   if        w6type = '1' and nxtscr <> 'EOJ'
720aAc                   exsr      scr02i
720aAc                   endif
720aAC     endsc7        endsr
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
520b C                   eval      forevr = *off
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
720aA*
720aA*  Convert today's date into century format.
720aA*
720aAC                   eval      $cvcmd = '*CURCMD '
720aAC                   call      @cvtdt
720aAC                   parm                    $cvtdt
720aAC                   eval      today = $cvd8o
720aA*
510aA*
510aA* Get client id.
510aA*
510aAC                   call      'GETCLIENT'
510aAC                   parm                    client
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ADJCANCEL  Remove any uci records added during this adjustment
720aA*             used when the user cancels out of the adjustment
720aA*             Remove timestamp for any uci scanned.
720aA*
720aAC     adjcancel     begsr
720aA*
720aA*
720aA /free
720aA   exsr clr$uciinfo;

720aA   $uiWhse = $pwhse;
720aA   $uiapartlts = $ppartime;
720aA   $uilcns = '*BFCADJADD';

720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%ADJCANCEL';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA /end-free

720aAC                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16ctl
 1X  C                   other
     C                   write     msgctl
 1E  C                   endsl
     C                   eval      msgk = *zeros
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16clr
 1X  C                   other
     C                   write     msgclr
 1E  C                   endsl
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
 1B  C                   if        msgk > 0
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16ctl
 2X  C                   other
     C                   write     msgctl
 2E  C                   endsl
     C                   eval      msgk = *zeros
 1E  C                   endif
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
 1B  C                   if        $msgf = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      $msgf = #msgfsp
500 AC                   other
     C                   eval      $msgf = #msgf
500 AC                   endsl
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
 2B  C                   select
 2X  C                   when      #lline = '16'
     C                   write     m16rec
 2X  C                   other
     C                   write     msgrec
 2E  C                   endsl
 1E  C                   endif
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
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   write     m16rec
 1X  C                   other
     C                   write     msgrec
 1E  C                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
 1B  C                   if        $msgf = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   move      #msgfsp       $msgf
500 AC                   other
     C                   move      #msgf         $msgf
500 AC                   endsl
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
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105s Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ'
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
     C                   move      'PIR0009'     #msgid
     C                   move      '*DIAG  '     #msgtp
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp        errmsg
500 AC                   other
     C                   movea     desc          errmsg
500 AC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm0201        begsr
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp        errmsg
500 AC                   other
     C                   movea     desc          errmsg
500 AC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   movea     descsp        errmsg
500 AC                   other
     C                   movea     desc          errmsg
500 AC                   endsl
     C                   movea     errmsg        $md(1)
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
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM10  Can't replace, quantity is pending.
     *
     C     zm10          begsr
     C                   move      'IT13210'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
520dA*----------------------------------------------------------------
520d *     ZM11  Qty and wt must be same sign (both + or -)
520d *
520d C     zm11          begsr
520d C                   move      'IT13211'     #msgid
520d C                   move      '*DIAG  '     #msgtp
520d C                   movea     errmsg        $md(1)
520d C                   exsr      zmpmsg
520dAC                   endsr
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
     *     IT12275  Not enough warehouse available qty.
     *
     C     zm2275        begsr
     C                   move      'IT12275'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.

     C     zzchk1        begsr
     C                   eval      error = *off

HSYa C                   if        client = halsey and
HSYa C                             w1type <> '1'
HSYa C                   eval      error = *on
HSYa C                   eval      *in21 = *on
HSYa C                   eval      *in01 = *on
HSYaAC                   select
HSYaAC                   when      e$lng = 'SP'
HSYaAC                   eval      errmsg = descsp(2)
HSYaAC                   other
HSYa C                   eval      errmsg = desc(2)
HSYaAC                   endsl
HSYa C                   exsr      zm1001
HSYaAC                   else
     *   Verify adjustment type.

 1B  C                   if        w1type <> '1'  and
     C                             w1type <> '2'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(2)
500 AC                   other
     C                   eval      errmsg = desc(2)
500 AC                   endsl
     C                   exsr      zm1001
 1E  C                   endif
HSYa C                   endif

     *   Can not replace if quantity is pending.

 1B  C                   if        w1type = '2'
 2B  C                   if        $slalc1 <> 0  or
     C                             $slalc2 <> 0  or
     C                             $slalc3 <> 0  or
     C                             $sltfr1 <> 0  or
     C                             $sltfr2 <> 0  or
     C                             $sltfr3 <> 0  or
     C                             $slpck1 <> 0  or
     C                             $slpck2 <> 0  or
     C                             $slpck3 <> 0  or
     C                             $slrcv1 <> 0  or
     C                             $slrcv2 <> 0  or
     C                             $slrcv3 <> 0
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   exsr      zm10
 2E  C                   endif
 1E  C                   endif

     *   Verify adjustment code.

     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w1code
     C                   call      'AD900'
     C                   parm                    $lparm
 1B  C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
 1X  C                   else
 2B  C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
 2E  C                   endif
 1E  C                   endif
FPRb *  Do not allow adjustment code(14, 41, HY, HN) for on hold
FPRb
FPRb C                   select
FPRb C                   when      client = FoodPro
FPRb C                   if        w1code = '14' or
FPRb C                             w1code = '41' or
FPRb C                             w1code = '13' or
FPRb C                             w1code = '31' or
FPRb C                             w1code = '32' or
FPRb C                             w1code = 'HY' or
FPRb C                             w1code = 'HN'
FPRb C                   move      *on           error
FPRb C                   eval      *in23 = *on
FPRb C                   eval      *in03 = *on
FPRb C                   eval      errmsg = desc(2)
FPRb C                   exsr      zm1001
FPRb C                   goto      endck1
FPRb C                   endif
FPRb C                   endsl

     *  If error has occured then skip the rest of the checks.

ADFa *  Do not allow adjustment code 'CI' can only be used for
ADFa *  change item thru program.
ADFa C                   if        client = AandDFoods and
ADFa C                             w1code = 'CI'
ADFa C                   move      *on           error
ADFa C                   eval      *in25 = *on
ADFa C                   eval      *in05 = *on
ADFa C                   eval      errmsg = desc(2)
ADFa C                   exsr      zm1001
ADFa C                   goto      endck1
ADFa C                   endif
     C     error         cabeq     *on           endck1

     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error

     C                   eval      w1qty1 = w1qt01
     C                   eval      w1qty2 = w1qt02
     C                   eval      w1qty3 = w1qt03

     *   Verify catchweight.

     *   UCI tracked items will load CW from scan so this field can
     *   be blank.
 1B  C                   if        not *in95  and
MRTaAC                             client <> merit and
730aAc                             $imltrk <> 'U' and
     C                             w1cwtr = 0
     C                   move      *on           error
     C                   eval      *in33 = *on
     C                   eval      errmsg = *blanks
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(3)
500 AC                   other
     C                   eval      errmsg = desc(3)
500 AC                   endsl
     C                   exsr      zm0110
 1E  C                   endif

510 A*   Verify department of item matches the department of slot.

510 AC                   if        $itwhdp <> $slwhdp and
510 AC                             ovrrid  = *off
510 AC                   eval      error = *on
510 AC                   eval      errmsg = desc(4)
510 AC                   exsr      zm0105
510 AC                   endif

520dA*  Verify qty and cw are same sign (both positive or negative)
520d
520d C                   select
520d C                   when      w1qty1 < 0  or
520d C                             w1qty2 < 0  or
520d C                             w1qty3 < 0
520d C                   if        w1cwtr > 0
520d C                   move      *on           error
520d C                   eval      *in33 = *on
520d C                   if        w1qty1 <> 0
520d C                   eval      *in22 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck2
520d C                   endif
520d
520d C                   when      w1qty1 > 0  or
520d C                             w1qty2 > 0  or
520d C                             w1qty3 > 0
520d C                   if        w1cwtr < 0
520d C                   move      *on           error
520d C                   eval      *in33 = *on
520d C                   if        w1qty1 <> 0
520d C                   eval      *in22 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck2
520d C                   endif

520d C                   endsl
DRYaA
DRYaA*   Verify catchweight variances for specific client/s
DRYaA
DRYaAC                   select
DRYaA
DRYaAC                   when      client = Dairyland
DRYaAC                             and not *in95
DRYaAC                   eval      exwgt  = 0
DRYaAC                   eval      exwgt1 = 0
DRYaAC                   eval      exwgt2 = 0
DRYaAC                   eval      exwgt3 = 0
DRYaA
DRYaAC                   if        w1qt01 <> 0
DRYaAC                   eval      exwgt1 = w1qt01 * $itswgt
DRYaAC                   endif
DRYaA
DRYaAC                   if        w1qt02 <> 0
DRYaAC                   eval      exwgt2 = ($itswgt/$itumq2) * (w1qt02)
DRYaAC                   endif
DRYaA
DRYaAC                   if        w1qt03 <> 0
DRYaAC                   eval      exwgt3 = $itswgt/$itumq2
DRYaAC                   eval      exwgt3 = (exwgt3/$itumq3) * (w1qt03)
DRYaAC                   endif
DRYaA
DRYaAC                   eval      exwgt  = exwgt1 + exwgt2 + exwgt3
DRYaA
DRYaAC                   eval      prg1c = 0
DRYaAC                   eval      prg2c = 0
DRYaAC                   eval      lwrng = 0
DRYaAC                   eval      hirng = 0
DRYaA
DRYaA*    Use item variance % if it exists
DRYaAC     keyil1        chain     itemmsc
DRYaAC                   if        %found(itemmsc)
DRYaAC                   if        imrg1c <> 0
DRYaAC     imrg1c        div       100           prg1c
DRYaAC                   endif
DRYaAC                   if        imrg2c <> 0
DRYaAC     imrg2c        div       100           prg2c
DRYaAC                   endif
DRYaAC                   endif
DRYaA
DRYaA*    Use system variance % if item variance % is zero
DRYaAC                   if        prg1c = 0
DRYaAC     oprg1c        div       100           prg1c
DRYaAC                   endif
DRYaAC                   if        prg2c = 0
DRYaAC     oprg2c        div       100           prg2c
DRYaAC                   endif
DRYaA
DRYaAC                   if        prg1c > 0
DRYaAC     exwgt         mult      prg1c         lwvar
DRYaAC                   eval      lwrng = exwgt - lwvar
DRYaAC                   endif
DRYaAC                   if        prg2c > 0
DRYaAC     exwgt         mult      prg2c         hivar
DRYaAC                   eval      hirng = exwgt + hivar
DRYaAC                   endif
DRYaA*
DRYaAC                   if        %abs(w1cwtr) <= %abs(lwrng)
DRYaAC                   eval      error = *on
DRYaAC                   eval      *in33 = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   eval      errng = prg1c * 100
DRYaAC                   eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
730cAc                   if        exwgt <> 0
DRYaAC                   eval      caltol = wgtDiff / %abs(exwgt)
730cAc                   endif
DRYaAC                   eval      caltol = caltol * 100
DRYaA* If wgt entered and low range are equal, force calc tolerance to
DRYaA* be the same value as low tolerance, otherwise, sometimes you will
DRYaA* end up with something like "Wgt tol% 29.99 >= 30.0'.
DRYaAC                   if        w1cwtr = lwrng
DRYaAC                   eval      caltol = errng
DRYaAC                   endif
DRYaAC                   eval      errmsg = 'Wgt tol% '
DRYaAC                                      + %triml(%editc(caltol:'3'))
DRYaAC                                      + ' >= var% '
DRYaAC                                      + %triml(%editc(errng:'3'))
DRYaAC                   exsr      zm0105
DRYaAC                   goto      endck2
DRYaAC                   endif
DRYaA
DRYaAC                   if        %abs(w1cwtr) >= %abs(hirng)
DRYaAC                   eval      error = *on
DRYaAC                   eval      *in33 = *on
DRYaAC                   eval      errmsg = *blanks
DRYaAC                   eval      errng = prg2c * 100
DRYaAC                   eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
DRYaAC                   eval      caltol = wgtDiff / %abs(exwgt)
DRYaAC                   eval      caltol = caltol * 100
DRYaA* If wgt entered and high range are equal, force calc tolerance to
DRYaA* be the same value as high tolerance, otherwise, sometimes you will
DRYaA* end up with something like "Wgt tol% 29.99 >= 30.0'.
DRYaAC                   if        w1cwtr = hirng
DRYaAC                   eval      caltol = errng
DRYaAC                   endif
DRYaAC                   eval      errmsg = 'Wgt tol% '
DRYaAC                                      + %triml(%editc(caltol:'3'))
DRYaAC                                      + ' >= var% '
DRYaAC                                      + %triml(%editc(errng:'3'))
DRYaAC                   exsr      zm0105
DRYaAC                   goto      endck2
DRYaAC                   endif
DRYaA
DRYaAC                   endsl

     *  If error has occured then skip the rest of the checks.

     C     error         cabeq     *on           endck2

     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     *
     *  Calculate change quantities.
     *
 1B  C                   select
     *
     *     Increasing/Decreasing quantity.
     *
 1X  C                   when      w1type = '1'
     C                   eval      chgqt1 = w1qty1
     C                   eval      chgqt2 = w1qty2
     C                   eval      chgqt3 = w1qty3
     *
     *     Replacing quantity.
     *
 1X  C                   other
     C                   eval      chgqt1 = w1qty1 - $slstk1
     C                   eval      chgqt2 = w1qty2 - $slstk2
     C                   eval      chgqt3 = w1qty3 - $slstk3
 1E  C                   endsl

     *   Call interface to do verification.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp
600bAC                   eval      $saitemu = *on
600bAC                   eval      $saitem  = $ititem
600bA
600bAC                   eval      $saqtyu  = *on
600bAC                   eval      $saqty1  = chgqt1
600bAC                   eval      $saqty2  = chgqt2
600bAC                   eval      $saqty3  = chgqt3
600bA
600bAC                   eval      $sacwtau = *on
600bAC                   eval      $sacwta  = w1cwtr
600bA
600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = w1code
600bA
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = w1memo
600bA
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = #curruser

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFY'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
MJKaAC                   if        client = mjkellner
520b C                   eval      svalis = *blanks
520b *  Check if alias item exists for base.
520b C     keyil1        setll     itemlnk1
520b C     forevr        doweq     forevr
520b C     keyil1        reade     itemlnk1                               77
520b C     *in77         ifeq      *on
520b C                   leave
520b C                   endif
520b C*      Get item record.
520b C*
520b C     keyit         chain     piritem
520b C                   if        not %found
520b C                   iter
520b C                   endif
520b C*
520b C*      Looking for Alias item.
520b C*
520b C     ittype        ifne      'A'
520b C                   iter
520b C                   endif
520b C*
520b C*      Found Alias item, call program to select Alias
520b C*
520bAC                   eval      $awhse    = $pwhse
520bAC                   eval      $aitem    = $iitem
520bAC                   eval      $asitm    = *blanks
520bAC                   eval      $artn     = *blanks
520bAC                   call      @gtals
520bAC                   parm                    $awhse
520bAC                   parm                    $aitem
520bAC                   parm                    $asitm
520bAC                   parm                    $artn
520bAC                   eval      svalis = $asitm
MJKaAC*                  if        client = mjkellner
520b C                   if        $artn  <> '*FOUND' or
520b C                             $asitm = *blanks
520b C                   move      *on           error
520b C*                  eval      *in22 = *on
520b C*                  eval      *in12 = *on
520b C                   eval      errmsg = *blanks
520b C                   eval      errmsg = desc(5)
520b C                   exsr      zm1001
520b C                   endif
MJKaAC*                  endif
520b C                   leave
520bAC                   enddo
520b C     error         cabeq     *on           endck3
MJKaAC                   endif

     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     *
     C     endck4        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCHK6   Screen 6 error checking.
720aA
720aAC     zzchk6        begsr
720aAC                   eval      error = *off
720aA
720aA*   Verify UCI Tracking Type
720aA
720aAC                   if        w6type <> '1'  and
720aAC                             w6type <> '2'  and
720aAC                             w6type <> '3'  and
720aAC                             w6type <> '4'
720aAC                   eval      error = *on
720aAC                   eval      *in35 = *on
720aAC                   eval      *in01 = *on
720aAC                   select
720aAC                   when      e$lng = 'SP'
740aMC                   eval      errmsg = descsp(6)
740aDC*                  eval      errmsg = descsp(7)
720aAC                   other
740aMC                   eval      errmsg = desc(6)
740aDC*                  eval      errmsg = desc(7)
720aAC                   endsl
720aAC                   exsr      zm1001
720aAC                   endif
720aA
720aA
720aA*  If error has occured then skip the rest of the checks.
720aA
720aAC     error         cabeq     *on           endck6
720aA
720aAC     endck6        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCHK7   Screen 7 error checking.
720aA
720aAC     zzchk7        begsr
720aAC                   eval      error = *off
720aA
720aA*   Verify UCI scannin Rules
720aA
720aAC                   if        w7uci = ' '
720aAC                   eval      error = *on
720aAC                   eval      *in35 = *on
720aAC                   eval      *in01 = *on
720aAC                   select
720aAC                   when      e$lng = 'SP'
720aAC*                  eval      errmsg = descsp(7)
720aAC                   eval      errmsg = 'uci'
720aAC                   other
720aAC*                  eval      errmsg = desc(7)
720aAC                   eval      errmsg = 'uci must be scanned'
720aAC                   endsl
720aAC                   exsr      zm0105
720aAc                   leavesr
720aAC                   endif
720aA
720aA /free
720aA   // has the uci already been scanned for this adjustment
720aA   w7uci = %TrimL(w7uci);
720aA   exsr clr$uciinfo;

720aA   $uiWhse = $pwhse;
720aA   $uiuci  = w7uci;
720aA   $uiapartlts = $ppartime;

720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%VFYCURMV';
720aA   $drisys2upd = 'D';
720aA   exsr zzzdricop;
720aA   // if return is *OK we can continue
720aA   if $drireturn <> '*OK';
720aA     error = *on;
720aA     *in21 = *on;
720aA     *in01 = *on;
720aA     errmsg = $drimessage;
720aA     exsr zm0105;
720aA     leavesr;
720aA   endif;
720aA   // is the UCI active in the system
720aA   exsr clr$uciinfo;

720aA   $uiWhse = $pwhse;
720aA   $uiuci  = w7uci;
720aA   $uiitem = $slitem;

720aA   $dricommand = '*UCIINFO';
720aA   $drisubcmd  = '%CHK4ADJ';
720aA   $drisys2upd = 'D';
720aA   //chk4err = *on;
720aA   exsr zzzdricop;

720aA   select;
720aA     // user has selected 1 to add uci or the adjustment
720aA     when w6type = '1';
720aA       select;

720aA         // return= *OK, that means the uci is already in uciinfo
720aA         when $drireturn = '*OK';
720aA           error = *off;
720aA           // if the uci is attached to the license being adjusted
720aA           // it can not be scanned for an add adjustment

720aA           // adjustment to pick slot could have *MULTIPLE in
720aA           // $slotlcns - this will need a further check to
720aA           // determine if the uci is already in the pick slot
720aA           //if $slotlcns = '*MULTIPLE';
720aA             exsr clr$license;
730aA             // Only executes if uci is attached to a license
730aA             if $uilcns <> ' ';
720aA               $liToWhseU = *on;
720aA               $liToWhse = $pWhse;
720aA               $liToWhdpU = *on;
720aA               $liToWhdp = $slwhdp;
720aA               $liToDispU = *on;
720aA               $liToDisp = $pdisp;
720aA               $liToLcnsU = *on;
720aA               $liToLcns = $uilcns;
720aA               $dricommand = '*LICENSE';
720aA               $drisubcmd  = '%GETLCNS';
720aA               $drisys2upd = 'D';
720aA               chk4err = *on;
720aA               exsr zzzdricop;
730aA             endif;
720aA             if $pdisp = $LITOdisp;
720aA               errmsg = 'UCI Is Already in this Slot';
720aA               error = *on;
720aA               exsr zm0105;
720aA               leavesr;
720aA             endif;
720aA             // should have the licative slot for the license
720aA             // the uci is attached to, if it is the slot being
720aA             // adjusted - this is an error.
720aA           //endif;

720aA           if $slotLcns = $uilcns;
720aA             errmsg = 'UCI Is Already in this Slot';
720aA             error = *on;
720aA             exsr zm0105;
720aA             leavesr;
720aA           endif;
720aA           // at this point if we will be doing a transfer we
720aA           // need to do a few more edit for an automatic transfer
720aA           // these edits came from IT252 - zzchk1
730aD           //if $litodisp <> ' ';
730aM           if $litodisp <> ' ' and #TOSLPICK = 'Y';
720aA             exsr zzchktfr;
720aA           endif;
720aA           $uiaction = 'ADJSTART';

720aA         // return= *NOTACTIVE is a good return, proceed to update
720aA         // means the uci does not exist as active in the warehouse
720aA         when $drireturn = '*NOTACTIVE';
720aA           error = *off;
720aA           // need to convert the barcode to extract the GTIN
720aA           cvtbar('*ALL': w7UCI:
720aA             $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
720aA             $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
720aA           $barcode = $cvtdata;
720aA           $barcode2 = $cvtdata2;
720aA           // make sure the gtin is for the item being adjusted
720aA           if $bcgtinsent;
720aA /end-free
720aA*   Right adjust UPC code for edit.
720aA*
720aAC                   eval      $cstr = *blanks
720aAC                   movel     $bcgtin       $cstr
720aAC                   call      'ADJUST'
720aAC                   parm      '*RIGHT  '    $ccmd             8
720aAC                   parm                    $cstr            30
720aAC                   move      $cstr         kyupc
720aA /free
720aA             chain ($pwhse: $slitem: kyupc) upc2;
720aA             if not %found(upc2);
720aA               errmsg = 'UCI does not match Item';
720aA               error = *on;
720aA               exsr zm0105;
720aA               leavesr;
720aA             endif;
720aA           endif;

720aA           $uiaction = 'ADJADD';
720aA           // because of additions of transfers to this program need
720aA           // to clear the $license data structures that may have info
720aA           // from a previously found uci.
720aA           exsr clr$license;
720aA           leavesr;
720aA         other;
720aA           errmsg = $drimessage;
720aA           error = *on;
720aA           exsr zm0105;
720aA           leavesr;
720aA       endsl;
720aA     when w6type = '2';
720aA       select;

720aA       // adjustments removing uci's from the system
720aA       // 1- uci currently in slot being adjusted - good to go
720aA       // 2- uci currently in a different slot - we will change
720aA       // 2- the slot being adjusted to the slot the uci is in.
720aA       // 3- uci isn't active in system - exception but allow
720aA       // return= *OK, that means the uci is already in uciinfo
720aA         when $drireturn = '*OK';
720aA           error = *off;

720aA           exsr clr$license;
730aA           if $uilcns <> ' ';
720aA             $liToWhseU = *on;
720aA             $liToWhse = $pWhse;
720aA             //$liToWhdpU = *on;
720aA             //$liToWhdp = $slwhdp;
720aA             //$liToDispU = *on;
720aA             //$liToDisp = $pdisp;
720aA             $liToLcnsU = *on;
720aA             $liToLcns = $uilcns;
720aA             $dricommand = '*LICENSE';
720aA             $drisubcmd  = '%GETLCNS';
720aA             $drisys2upd = 'D';
720aA             chk4err = *on;
720aA             exsr zzzdricop;
730aA           else;
730aA             // uci is not currently active in the system, do not
730aA             // adjust inventory. User needs to count the slot.
730aA             errmsg = 'Count Slot-UCI is not active';
730aA             error = *on;
730aA             exsr zm0105;
730aA             leavesr;
730aA           endif;
730aA           if $LITOdisp = ' ';
730aA             // uci is not currently active in the system, do not
730aA             // adjust inventory. User needs to count the slot.
730aA             errmsg = 'Count Slot-UCI is not active';
730aA             error = *on;
730aA             exsr zm0105;
730aA             leavesr;
730aA           endif;
720aA           if $pdisp = $LITOdisp;
720aA             // uci and slot match - good to go
720aA           endif;
720aA           if $pdisp <>  $LITOdisp;
720aA             // change the slot beinbg adjusted.
720aA             // we will adjust the slot the uci is currently in.
720aA             $pdisp = $litodisp;
720aA           endif;

720aA           $uiaction = 'ADJSTART';

720aA         // return= *NOTACTIVE is a good return, proceed to update
720aA         // means the uci does not exist as active in the warehouse
720aA         when $drireturn = '*NOTACTIVE';
730aA           // we decided in this situation you should be asked
730aA           // to scan all the boxes in the slot. Since you are
730aA           // trying to remove a UCI that we don't know about.
730aA           // this would imply that your current count/uci's are
730aA           // not in sync.
730aA           // uci is not currently active in the system, do not
730aA           // adjust inventory. User needs to count the slot.
730aA           errmsg = 'Count Slot-UCI is not active';
730aA           error = *on;
730aA           exsr zm0105;
730aA           leavesr;
730aD           //error = *off;
730aD           // need to convert the barcode to extract the GTIN
730aD           //cvtbar('*ALL': w7UCI:
730aD           //$cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
730aD           //$cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
730aD           //$barcode = $cvtdata;
730aD           //$barcode2 = $cvtdata2;
730aD           // make sure the gtin is for the item being adjusted
730aD           //if $bcgtinsent;
720aA /end-free
730aD*   Right adjust UPC code for edit.
730aD*
730aDC*                  eval      $cstr = *blanks
730aDC*                  movel     $bcgtin       $cstr
730aDC*                  call      'ADJUST'
730aDC*                  parm      '*RIGHT  '    $ccmd             8
730aDC*                  parm                    $cstr            30
730aDC*                  move      $cstr         kyupc
720aA /free
730aD      //       chain ($pwhse: $slitem: kyupc) upc2;
730aD      //       if not %found(upc2);
730aD      //         errmsg = 'UCI does not match Item';
730aD      //         error = *on;
730aD      //         exsr zm0105;
730aD      //         leavesr;
730aD      //       endif;
730aD      //     endif;

730aD           //$uiaction = 'ADJDLT';
730aD           //leavesr;
720aA         other;
720aA           errmsg = $drimessage;
720aA           error = *on;
720aA           exsr zm0105;
720aA           leavesr;
720aA       endsl;
720aA     when w6type = '3';
720aA       select;

720aA         // return= *OK, that means the uci is already in uciinfo
720aA         when $drireturn = '*OK';
720aA           error = *off;
720aA           // if the uci is attached to the license being adjusted
720aA           // it can not be scanned for an add adjustment

720aA           // adjustment to pick slot could have *MULTIPLE in
720aA           // $slotlcns - this will need a further check to
720aA           // determine if the uci is already in the pick slot
720aA           if $slotlcns = '*MULTIPLE';
720aA             exsr clr$license;
730aA             if $uilcns <> ' ';
720aA               $liToWhseU = *on;
720aA               $liToWhse = $pWhse;
720aA               $liToWhdpU = *on;
720aA               $liToWhdp = $slwhdp;
720aA               $liToDispU = *on;
720aA               $liToDisp = $pdisp;
720aA               $liToLcnsU = *on;
720aA               $liToLcns = $uilcns;
720aA               $dricommand = '*LICENSE';
720aA               $drisubcmd  = '%GETLCNS';
720aA               $drisys2upd = 'D';
720aA               chk4err = *on;
720aA               exsr zzzdricop;
730aA             endif;
720aA           endif;

720aA           $uiaction = 'ADJSTART';

720aA         // return= *NOTACTIVE is a good return, proceed to update
720aA         // means the uci does not exist as active in the warehouse
720aA         when $drireturn = '*NOTACTIVE';
720aA           error = *off;
720aA           // need to convert the barcode to extract the GTIN
720aA           cvtbar('*ALL': w7UCI:
720aA             $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
720aA             $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: $cbwhse);
720aA           $barcode = $cvtdata;
720aA           $barcode2 = $cvtdata2;
720aA           // make sure the gtin is for the item being adjusted
720aA           if $bcgtinsent;
720aA /end-free
720aA*   Right adjust UPC code for edit.
720aA*
720aAC                   eval      $cstr = *blanks
720aAC                   movel     $bcgtin       $cstr
720aAC                   call      'ADJUST'
720aAC                   parm      '*RIGHT  '    $ccmd             8
720aAC                   parm                    $cstr            30
720aAC                   move      $cstr         kyupc
720aA /free
720aA             chain ($pwhse: $slitem: kyupc) upc2;
720aA             if not %found(upc2);
720aA               errmsg = 'UCI does not match Item';
720aA               error = *on;
720aA               exsr zm0105;
720aA               leavesr;
720aA             endif;
720aA           endif;

720aA           $uiaction = 'ADJADD';
720aA           leavesr;
720aA         other;
720aA           errmsg = $drimessage;
720aA           error = *on;
720aA           exsr zm0105;
720aA           leavesr;
720aA       endsl;
720aA   endsl;
720aA /end-free
720aA
720aA*  If error has occured then skip the rest of the checks.
720aA
720aAC     error         cabeq     *on           endck7
720aA
720aAC     endck7        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCHKTFR Additional edit checks for auto transfer
720aA
720aAC     zzchktfr      begsr
720aA /free
720aA   // uci is attached to a license in a different slot
720aA   if $litodisp <> $pdisp;
720aA     // uci attached to an open putaway
720aA     if $litoaisl = 'RCV' or
720aA       $litoaisl = 'RTN' or
730dA       $litoaisl = 'RWO' or
720aA       $litoaisl = 'STG';
720aA       errmsg = 'Open Putaway - uci must be put away first';
720aA       error = *on;
720aA       exsr zm0105;
720aA       leavesr;
720aA     endif;
720aA     // uci attached to a usr slot - must use transfer
720aA     if $litoaisl = 'USR';
720aA       errmsg = 'UCI is in a USR slot - use Transfer';
720aA       error = *on;
720aA       exsr zm0105;
720aA       leavesr;
720aA     endif;
720aA     // Use DRI interface to get slot information
720aA     exsr clr$slot;
720aA     $slwhseu = *on;
720aA     $slwhse  = $pwhse;
720aA     $slwhdpu = *on;
720aA     $slwhdp  = $litowhdp;
720aA     $sldispu = *on;
720aA     $sldisp  = $litodisp;

720aA     $dricommand = '*SLOT';
720aA     $drisubcmd  = '%GETCHKVX';
720aA     $drisys2upd = 'D';
720aA     chk4err = *on;
720aA     zmsflag = *on;
720aA     exsr zzzdricop;
720aA     if error;
720aA       $prtn = '*PGMQ   ';
720aA       leavesr;
720aA     endif;

720aA     #fromslwhdp = $slwhdp;
720aA     #fromslstyp = $slstyp;
720aA     #fromsldisp = $sldisp;
720aA     #fromslaisl = $slaisl;
720aA     #fromslloc  = $slloc;
720aA     #fromslpseq = $slpseq;
720aA     #fromslrlvl = $slrlvl;
720aA     #fromslhand = $slhand;
720aA     #fromslstat = $slstat;
720aA     #fromslrsrv = $slrsrv;
720aA     #fromslentd = $slentd;
720aA     #fromslexpd = $slexpd;
720aA     #fromslslfd = $slslfd;
720aA     #fromslactv = $slactv;
720aA     #fromslbld  = $slbld;
720aA     #fromslpick = $slpick;
720aA     #fromslitem = $slitem;
720aA     #fromslsdef = $slsdef;
720aA     #fromslvirt = $sfvirt;
720aA     #fromslstk1 = $slstk1;
720aA     #fromslstk2 = $slstk2;
720aA     #fromslstk3 = $slstk3;
720aA     #fromslalc1 = $slalc1;
720aA     #fromslalc2 = $slalc2;
720aA     #fromslalc3 = $slalc3;
720aA     #fromsltfr1 = $sltfr1;
720aA     #fromsltfr2 = $sltfr2;
720aA     #fromsltfr3 = $sltfr3;
720aA     #fromslpck1 = $slpck1;
720aA     #fromslpck2 = $slpck2;
720aA     #fromslpck3 = $slpck3;
720aA     #fromslrcv1 = $slrcv1;
720aA     #fromslrcv2 = $slrcv2;
720aA     #fromslrcv3 = $slrcv3;
720aA     #fromslphy1 = $slphy1;
720aA     #fromslphy2 = $slphy2;
720aA     #fromslphy3 = $slphy3;
720aA     #fromslavl1 = $slavl1;
720aA     #fromslavl2 = $slavl2;
720aA     #fromslavl3 = $slavl3;
720aA     #fromToLcns = $saToLcns;
720aA     #fromToPos  = $saToPos;
720aA     #fromOLcns = $saOLcns;
720aA     #frombasesldsp = $sacdsp;
720aA     // Use DRI interface to do most of the verifications
720aA     exsr clr$slot;
720aA     $slwhseu  = *on;
720aA     $slwhse   = $pwhse;
720aA     $slwhdpu  = *on;
720aA     $slwhdp   = $liToWhdp;
720aA     $sldispu  = *on;
720aA     $sldisp   = $liToDisp;
720aA     $saitemu  = *on;
720aA     $saitem   = $ititem;
720aA     $saqtyu   = *on;
720aA     select;
720aA       when $uiautyp = '2';
720aA         $saqty3 = 1;
720aA       when $uiautyp = '1';
720aA         $saqty2 = 1;
720aA       other;
720aA         $saqty1 = 1;
720aA     endsl;
720aA     $sacitemu = *on;
720aA     $sacitem  = $ititem;

720aA     $dricommand = '*SLOT';
720aA     $drisubcmd  = '%VFYTFOCHG';
720aA     $drisys2upd = 'D';
720aA     chk4err = *on;
720aA     zmsflag = *off;
720aA     exsr zzzdricop;
720aA     if error;
720aA       exsr zm0001;
720aA       leavesr;
720aA     endif;

720aA     // these edits came from it252 - zzchk2
720aA     // if production slot ensure virtual is created
720aA     // for the slot being adjustest, transferred to.
720aA     prdtfr = *off;
720aA     sltc = 0;
720aA     wkaisl = %subst($pdisp:1:3);
720aA     sltc = %lookup(wkaisl:prdslt:1);
720aA     if sltc <> 0 and wkaisl <> ' ';
720aA       prdtfr = *on;
720aA       exsr clr$slot;
720aA       $slwhseu = *on;
720aA       $slwhse  = $pWhse;
720aA       $slwhdpu = *on;
720aA       $slwhdp  = $pwhdp;
720aA       $slitemu = *on;
720aA       $slitem  = $ititem;
720aA       $sldispu = *on;
720aA       $sldisp  = $pdisp;
720aA       $slstatu = *on;
720aA       $slstat  = 'PR';

720aA       $dricommand = '*SLOT';
720aA       $drisubcmd  = '%CRTPROD';
720aA       $drisys2upd = 'D';
720aA       chk4err = *on;
720aA       exsr zzzdricop;
720aA       hldprdDisp = $sldisp;
720aA       error = *off;
720aA     endif;
720aA     // To Slot can't be blank - which is the original slot
720aA     // the user had selected to adjust - which should never
720aA     // be blank at this point - but we will double check.
720aA     if $pdisp = *blanks;
720aA       error = *on;
720aA       errmsg = 'Blank adjustment Slot';
720aA       exsr zm0105;
720aA       leavesr;
720aA     endif;
720aA     // if transfer to represents a Repack Item verify
720aA     // on-demand slot exist.
720aA     if $ittype = 'R';
720aA       chain ($pWhse:$ititem) kititem;
720aA       if not %error and %found;
720aA         if kidisp <> ' ';
720aA           exsr clr$slot;
720aA           $slwhseu = *on;
720aA           $slwhse  = $pWhse;
720aA           $slwhdpu = *on;
720aA           $slwhdp  = $pWhdp;
720aA           $slitemu = *on;
720aA           $slitem  = $ititem;
720aA           $sldispu = *on;
720aA           $sldisp  = kidisp;

720aA           $dricommand = '*SLOT';
720aA           $drisubcmd  = '%CRTREPAKD';
720aA           $drisys2upd = 'D';
720aA           chk4err = *on;
720aA           exsr zzzdricop;
720aA           odrSlot = $sldisp;
720aA           error = *off;
720aA         endif;
720aA       endif;
720aA     endif;
720aA     // I exclude the oss check from it252 because they would not
720aA     // be doing an adjustment to an oss location and scanning the
720aA     // UCI to add, we would not want to auto transfer
720aA     if %subst($liToDisp:1:3) = 'OSS';
720aA       error = *on;
720aA       errmsg = 'UCI Is attached to license at Outside '
720aA              + 'Storage';
720aA       exsr zm0105;
720aA       leavesr;
720aA     endif;

720aA   endif;
720aA /end-free
720aAC     endcktfr      endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
 1B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
 2B  C                   select
     *
     *     Reason code.
     *
 2X  C                   when      row# = 5
     C                   eval      *in03 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w1code
     C                   call      'AD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
 3E  C                   endif
610a *
610aAC                   when      row# = 9 and
610aAC                             e$lng = 'EN' and #lline = '16'
610aAC                   eval      *in03 = *on
610aAC                   eval      $lcmd = '*LOOKUP '
610aAC                   eval      $lcode = w1code
610aAC                   call      'AD900'
610aAC                   parm                    $lparm
610aAC                   if        $lrtn = '*SELECT '
610aAC                   eval      w1code = $lcode
610aAC                   endif
     *
     *     Cursor not on a valid lookup field.
     *
 2X  C                   other
     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm1
 1E  C                   endif
     *
     *      F9 - View slot quantities.
     *
 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   z-add     $pwhse        whse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    $pdisp
 1E  C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *      F10 - Accept Warning.
     *
510 AC                   if        *inkj
510 AC                   move      *on           ovrrid
510 AC                   endif
700bA*
700bA*      F7 - kilograms/Pounds Toggle
700bA*
700bAC                   if        *inkg
700bAC                   eval      cmdtkn = *on
700bAC                   if        KiloLbs = 'P'
700bAC                   eval      KiloLbs = 'K'
700bAC                   eval      w1um4   = 'Kgs'
700bAC                   Eval      *in31 = *off
700bAC                   else
700bAC                   eval      KiloLbs = 'P'
700bAC                   eval      W1um4   = 'Lbs'
700bAC                   Eval      *in31 = *on
700bAC                   endif
700bAC                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *      F20 - Accept Warning.
     *
 1B  C                   if        *inku
     C                   move      *on           ovrrid
 1E  C                   endif
     *
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *      F10 - Accept Warning.
     *
 1B  C                   if        *inkj
     C                   move      *on           ovrrid
     C                   move      *on           cmdtkn
     C                   exsr      zzchk3
     C                   exsr      zzupd3
 1E  C                   endif
     *
     C     endcm4        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCMD6   User defined command keys for screen 6.
720aA*
720aAC     zzcmd6        begsr
720aAC                   eval      cmdtkn = *off
720aA*
720aA*  Test for F4 - Lookup
720aA*
720aAC                   if        *inkd
720aAC                   eval      cmdtkn = *on
720aAC                   z-add     0             row#
720aAC                   eval      row = rowin
720aAC                   z-add     0             col#
720aAC                   eval      col = colin
720aA*
720aAC                   goto      endcm6
720aAC                   endif
720aA*
720aAC     endcm6        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCMD7   User defined command keys for screen 7.
720aA*
720aAC     zzcmd7        begsr
720aAC                   eval      cmdtkn = *off
720aA*
720aA*  Test for F4 - Lookup
720aA*
720aAC                   if        *inkd
720aAC                   eval      cmdtkn = *on
720aAC                   z-add     0             row#
720aAC                   eval      row = rowin
720aAC                   z-add     0             col#
720aAC                   eval      col = colin
720aA*
720aAC                   goto      endcm7
720aAC                   endif
720aA*
720aA*      F22 - Done scanning.
720aA*
720aAC                   if        *inkw
720aAC                   eval      cmdtkn = *on
720aAc                   exsr      scr02i
720aAC                   endif
720aA*
720aAC     endcm7        endsr
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

720aA*----------------------------------------------------------------
720aA*
720aA*  ZZDFT6   Get default values.
720aA*
720aAC     zzdft6        begsr
720aA*
720aAc                   eval      w6type = ' '
720aA*
720aAC                   endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZDFT7   Get default values.
720aA*
720aAC     zzdft7        begsr
720aA*
720aAc                   eval      w7uci  = ' '
720aA*
720aAC                   endsr
     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     C                   if        $sacodee = '1'
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $saqty2e = '1'
     C                   eval      *in29 = *on
     C                   eval      *in09 = *on
     C                   endif

     C                   if        $saqty3e = '1'
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   endif

     C                   if        $sacwtae = '1'
     C                   eval      *in33 = *on
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1  heading fields.
     *
     C     zzfil0        begsr

     *      Convert available quantity to string.

     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     C                   eval      $cqty1 = $slavl1
     C                   eval      $cqty2 = $slavl2
     C                   eval      $cqty3 = $slavl3

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
     C                   eval      w1incq = $cqstr
     C                   eval      w1avlq = $cqstr

     *      Convert adjustable quantity to string.

     C                   eval      $cqty1 = $sladj1
     C                   eval      $cqty2 = $sladj2
     C                   eval      $cqty3 = $sladj3

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
     C                   eval      w1excq = $cqstr
     C                   eval      w1adjq = $cqstr

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
     *   Get item description.

600bAC                   exsr      clr$item
600bAC                   eval      $itwhse  = $pwhse
600bAC                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop

 1B  C                   if        error
     C                   eval      $itdesc = *blanks
     C                   eval      $itpdsc = *blanks
     C                   eval      $itumq2 = 0
     C                   eval      $itumq3 = 0
 1E  C                   endif
     C                   eval      $iitem = $slitem
 1B  C                   select
 1X  C                   when      #lline = '16'
     C                   eval      $idesc = *blanks
     C                   eval      w1desc = $itdesc
 1X  C                   other
     C                   eval      $idesc = $itdesc
 1E  C                   endsl
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      woitem = *blanks
     C                   movel     $istr         woitem
     C                   movel     $istr         w1item
     *
     *   Get SSB item, if one exists
     *
     C                   move      *off          ssbflg
     C                   eval      wossb = *blanks
 1B  C                   if        $ittype = ' '
     C                   call      'GETSSB'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     *
 2B  C                   if        #brtn = '*FOUND  '
     C                   move      *on           ssbflg
     C                   eval      wossb = 'SSB'
 2E  C                   endif
     *
 1E  C                   endif
     *
     *   Expand slot seciton type.
     *
 1B  C                   if        $slstyp = 'P'
     C                   eval      wostyp = 'PIR  '
 1X  C                   else
     C                   eval      wostyp = 'Fixed'
 1E  C                   endif
     *
     *   Initialize entry fields
     *
     C                   eval      w1type = *on
     C                   eval      w1code = *blanks
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
     C                   z-add     $slavl1       savav1
     C                   z-add     $slavl2       savav2
     C                   z-add     $slavl3       savav3
     C                   eval      savst = $slstat
     *
     *   Slot display/department/section
     *
     C                   eval      temp = *blanks
     C     $sldisp       cat       '/':2         temp
     C     temp          cat       $slwhdp:0     temp
     C     temp          cat       '/':0         temp
     C     temp          cat       $slstyp:0     temp
     C                   move      temp          w1sdsp

     *   Slot definition

600bAC                   exsr      clr$slotdef
600bAC                   eval      $sdwhse  = $slwhse
600bAC                   eval      $sdcode  = $slsdef
600bA
600bAC                   eval      $dricommand = '*SLOTDEF'
600bAC                   eval      $drisubcmd  = '%GET'
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *off
600bAC                   eval      zmsflag = *off
600bAC                   exsr      zzzdricop
600bAC                   eval      w1sdef = $slsdef
600bAC                   eval      w1sdes = $sddesc

     *   Slot status

     C     $slstat       chain     slotstat                           79
 1B  C                   if        *in79
     C                   eval      ssdesc = *blanks
 1E  C                   endif
     C                   eval      w1slds = ssdesc
     C                   eval      w1slst = $slstat
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get Unit of measure fields
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     *
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     C                   eval      w1qty1 = 0
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1cwtr = 0
     *
 1B  C                   if        $itcwgt <> 'Y'
     C                   eval      *in95 = *on
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif
PCKaA*
PCKaAC                   if        client = packers and
PCKaAC                             $itcwgt = 'Y'
PCKaAC                   eval      *in95 = *on
PCKaAC                   endif
     *
     *   Create adjustment type/code string.
     *
 1B  C                   if        w1type = '1'
     C                   eval      wotype = 'Inc/Dec'
 1X  C                   else
     C                   eval      wotype = 'Replace'
 1E  C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *
     *   Initialize entry fields
     *
     C                   eval      w1memo = *blanks
     C                   eval      w1mem1 = *blanks
     C                   eval      w1mem2 = *blanks
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     *
 1B  C                   if        error
500 AC                   select
500 AC                   when      e$lng = 'SP'
500 AC                   eval      errmsg = descsp(1)
500 AC                   other
     C                   eval      errmsg = desc(1)
500 AC                   endsl
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm7973
goto C                   goto      endgt1
 1E  C                   endif
     *
     *  Slot does not contain an item.
     *
 1B  C                   if        $slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
goto Csr                 goto      endgt1
 1E  C                   endif
720aAc* hold some fields for possible transfer
720aAc                   eval      #toslaisl = $slaisl
720aAc                   eval      #toslhand = $slhand
720aAc                   eval      #toslloc  = $slloc
720aAc                   eval      #toslrlvl  = $slrlvl
720aAc                   eval      #toslstat  = $slstat
730aAc                   eval      #toslpick  = $slpick
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     *
     C     endgt2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get record(s) for screen 3.
     *
     C     zzget3        begsr
     *
     *
     C     endgt3        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET4   Get record(s) for screen 4.
     *
     C     zzget4        begsr
     *
     *
     C     endgt4        endsr
720aA*----------------------------------------------------------------
720aA*  getcurrstamp  Get current timestamps
720aA*----------------------------------------------------------------
720aA
720aAC     zzgetcurrstampbegsr

720aAC                   callp     getmicrotime(currstampuc:currstampsys)
720aAC     currstampsys  adddur    bfcoffset:*H  currstamploc

720aAC                   endsr
610bA*----------------------------------------------------------------
610bA*
610bA*  ZZGETSYOP  Get System Options record.
610bA*
610bAC     zzgetsyop     begsr
610bA*
610bAC                   eval      opcode = '*SYSTEM '
610bA*
610bAC                   eval      opwhse = *zeros
610bA*
610bAC     opkey         chain     options
610bAC                   if        not %found(options)
DRYaAC                   eval      oprg1c = 0
DRYaAC                   eval      oprg2c = 0
610bAC                   eval      opuci  = 'N'
610bAC                   endif
610bA*
610bAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
520b *
520b *  Define key for itemlnk1 file.
520b *
520b C     keyil1        klist
520b C                   kfld                    $pwhse
520b C                   kfld                    $iitem
520b *
520b *  Define key for PIRITEM file.
520b *
520b C     keyit         klist
520b C                   kfld                    ilwhse
520b C                   kfld                    ilitem
     *
     *  Define key for WHDEPT file.
     *
     C     keywd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     *
     *  Define key for OPTIONS file.
     *
610bAC     opkey         klist
610bAC                   kfld                    opwhse
610bAC                   kfld                    opcode
     *
     C                   eval      $lprg = #prog
PCK AC                   eval      w1qty1 = *zero
pck AC                   eval      w1qty2 = *zero
pck AC                   eval      w1qty3 = *zero
pck AC                   eval      w1cwtr = *zero
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
720aA   // setup array to verify production slots for WIP and Lines
720aA /free
720aA   sltc = 1;
720aA   dow sltc < 101;
720aA     prdslt(sltc) = '   ';
720aA     sltc = sltc +1;
720aA   enddo;
720aA
720aA   setll (*zeros:*zeros) plined;
720aA   read plined;
720aA   dow not %eof(plined);
720aA
720aA     sltc = 1;
720aA     // look for raw material aisle location
720aA     dow sltc < 101;
720aA       if prdslt(sltc) = '   '
720aA          or prdslt(sltc) = inRcvAisl;
720aA         leave;
720aA       endif;
720aA       sltc = sltc +1;
720aA     enddo;
720aA     // if comes out blank it means we should
720aA     // add to the array of prod slot aisles
720aA     if prdslt(sltc) = '   ';
720aA       prdslt(sltc) = inRcvAisl;
720aA     endif;
720aA
720aA     sltc = 1;
720aA     // look for WIP Stock aisle location
720aA     dow sltc < 101;
720aA       if prdslt(sltc) = '   '
720aA          or prdslt(sltc) = inWipAisl;
720aA         leave;
720aA       endif;
720aA       sltc = sltc +1;
720aA     enddo;
720aA     // if comes out blank it means we should
720aA     // add to the array of prod slot aisles
720aA     if prdslt(sltc) = '   ';
720aA       prdslt(sltc) = inWipAisl;
720aA     endif;
720aA
720aA     read plined;
720aA   enddo;
720aA /end-free
600cA*
600cA*  Do not allow the transfer from a RCV file.
600cA*
600cAC                   if        %subst($pdisp:1:3) = 'RCV'
600cAC                             or %subst($pdisp:1:3) = 'STG'
710aAC                             or %subst($pdisp:1:3) = 'RTN'
730dAC                             or %subst($pdisp:1:3) = 'RWO'
600cAC                   eval      error = *on
710aDC*                  eval      errmsg = 'RCV/STG slot not allowed '
710aDC*                                   + '- use Putaway'
730dDC*                  eval      errmsg = 'RCV/STG/RTN slot not '
730dDC*                                   + 'allowed - use Putaway'
730dMC                   eval      errmsg = 'RCV/STG/RTN/RWO slot not '
730dMC                                    + 'allowed - use Putaway'
600cAC                   exsr      zm0105s
600cAC                   eval      nxtscr = 'EOJ'
600cAC                   leavesr
600cAC                   endif
500 A*
500 A*   Get employee options.
500 A*
500 AC                   call      'GETUSER'
500 AC                   parm      #curruser     E$CODE           10
500 AC                   parm                    E$WHSE            3 0
500 AC                   parm                    E$EMP#            5 0
500 AC                   parm                    E$FNAM           15
500 AC                   parm                    E$INIT            1
500 AC                   parm                    E$LNAM           20
500 AC                   parm                    E$WHDP            5
500 AC                   parm                    E$STYP            1
500 AC                   parm                    E$SHFT            6
500 AC                   parm                    E$CREW            6
500 AC                   parm                    E$NHRS            3 1
500 AC                   parm                    E$RTN             8
500 AC                   parm                    E$BPU             1
500 AC                   parm                    E$LNG             2
500 AC                   if        E$RTN <> '*OK'
500 AC                   eval      E$LNG = 'EN'
500 AC                   endif
     *
     *   Get screen size being used.
     *
     C                   call      'PIRRFSCR'
     C                   parm      '*GET'        #lcmd             8
     C                   parm                    #lline            2
     C                   parm                    #lcol             3
     *
     *   Get warehouse description.
     *
     C                   eval      wowhse = *blanks
     C                   eval      $cstr = *blanks

     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $pwhse        $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   when      $vreturn <> '*OK'
     C                   endsl
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd
     C                   parm                    $cstr            30
     *
     *   Put warehouse and department together.
     *
     C                   eval      wowhse = %trim($cstr) + '/'
     C                                    + %trim($pwhdp) + ' - '
     C                                    + %trim($vdesc)
     *
610bAC                   exsr      zzgetsyop
     *
700bA /free
700bA    getimuom(e$whse: BegKilolbs: IMUom);
700bA    select;
700bA      when Begkilolbs = 'K';
700bA        KiloLbs = 'K';
700bA        eval *In31 = *off;
700bA        W1UM4  = IMUom;
700bA      other;
700bA        kiloLbs = 'P';
700bA        eval *In31 = *on;
700bA        W1UM4  = 'Lbs';
700bA    endsl;
700bA /end-free
     *   Select first screen to display.
     *
     C                   move      *on           refrsh
     C                   exsr      scr01i
     C                   endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZTFR    Initiate the transfer for UCI tracking.
720aA*
720aAC     zztfr         begsr
720aA /free
720aA   $lcmd = '*CHANGE ';
720aA   $lwhseTfr = $pwhse;
720aA   $lwhdpTfr = $pwhdp;
720aA   $ldispTfr = $litodisp;
720aA   $ldispTfrTo = $pdisp;
720aA   $luomtfr = $uiautyp;
720aA   $llcnsTfr = $uilcns;
720aA   //$puci = w7uci;
720aA /end-free
720aA ********
720aA*
720aA * transfer to the usr slot
720aAC                   move      *off          error
720aA*
720aA*   Item changed, set flag for adjustment code entry.
lmc   **** what is *in59
720aAC                   eval      *in59 = *off
720aAC*
720aAC                   if        client = FoodPro
720aAC                   if           $itcwgt = 'Y'
720aAC                   eval      w1cwtr = uciwgt
720aAC                   endif
720aAC                   endif
720aA*
720aA*  Set partial quantity flag.
720aA*
720aA*    These values were recalculated and sent back from
720aA*    the VFYTFOCHG command. If all of the original #FROM
720aA*    buckets were zero and the new Avail quantities are
720aA*    zero, then the entire quantity is being taken.
720aA*
720aAC                   if        $slavl1 = 0 and
720aAC                             $slavl2 = 0 and
720aAC                             $slavl3 = 0 and
720aAC                             #fromslalc1 = 0 and
720aAC                             #fromslalc2 = 0 and
720aAC                             #fromslalc3 = 0 and
720aAC                             #fromslrcv1 = 0 and
720aAC                             #fromslrcv2 = 0 and
720aAC                             #fromslrcv3 = 0 and
720aAC                             #fromslpck1 = 0 and
720aAC                             #fromslpck2 = 0 and
720aAC                             #fromslpck3 = 0 and
720aAC                             #fromsltfr1 = 0 and
720aAC                             #fromsltfr2 = 0 and
720aAC                             #fromsltfr3 = 0
720aAC                   eval      partial = *off
720aAC                   else
720aAC                   eval      partial = *on
720aAC                   endif
720aA
720aA*  License plate tracking item. Update to show in transit.
720aA
720aAC                   exsr      zzzclr$lt210
720aAC                   eval      $tcmd     = '*PULTRAN'
720aAC                   eval      $tlic#    = $litolcns
720aAC                   eval      $tnewlic# = $litolcns
720aAC                   eval      $twhse    = $pwhse
720aAC                   eval      $titem    = #fromslitem
720aAC                   eval      $titemdsc = $itdesc
720aAC                   eval      $tpartial = partial
720aAc                   select
720aAc                   when      $uiautyp = '2'
720aAc                   eval      w1qt01 = 0
720aAc                   eval      w1qt02 = 0
730ADc*                  eval      w1qt03 = uciqty3
730AMc                   eval      w1qt03 = 1
720aAc                   when      $uiautyp = '1'
720aAc                   eval      w1qt01 = 0
730aDc*                  eval      w1qt02 = uciqty2
730aMc                   eval      w1qt02 = 1
720aAc                   eval      w1qt03 = 0
720aAc                   other
730aDc*                  eval      w1qt01 = uciqty1
730aMc                   eval      w1qt01 = 1
720aAc                   eval      w1qt02 = 0
720aAc                   eval      w1qt03 = 0
720aAc                   endsl
720aAC                   eval      $tqty1    = w1qt01
720aAC                   eval      $tqty2    = w1qt02
720aAC                   eval      $tqty3    = w1qt03
720aAC                   eval      $tnorm1   = w1qt01
720aAC                   eval      $tnorm2   = w1qt02
720aAC                   eval      $tnorm3   = w1qt03
730aAc                   if        w7uci = ' '
730aAc                   if        $uiuci <> ' '
730aAc                   eval      $tuci = w7uci
730aAc                   else
730aAc                   eval      $tuci = ' '
730aAc                   endif
730aAc                   else
720aAc                   eval      $tuci = w7uci
730aAc                   endif
720aAC                   exsr      zzzcall$lt210
720aA
720aAC                   if        $treturn <> '*OK'
720aAC                   endif
720aA
720aAC                   eval      curlic# = $tinlic#
720aA
720aA*  Use DRI interface to update From slot.
720aA*    Note: The $sl info was retrieved in ZZGET1.
720aA
720aAC                   exsr      clr$slot
720aAC                   eval      $slwhseu  = *on
720aAC                   eval      $slwhse   = $pwhse
720aAC                   eval      $slwhdpu  = *on
720aAC                   eval      $slwhdp   = $pwhdp
720aAC                   eval      $sldispu  = *on
720aAC                   eval      $sldisp   = $litodisp
720aAC                   eval      $saitemu  = *on
720aAC                   eval      $saitem   = $ititem
720aAC                   eval      $saqtyu   = *on
720aAC                   eval      $saqty1   = w1qt01
720aAC                   eval      $saqty2   = w1qt02
720aAC                   eval      $saqty3   = w1qt03
720aAC                   eval      $sacitemu = *on
720aAC                   eval      $sacitem  = $ititem
720aA
720aAC                   eval      $satasku = *on
720aAC                   eval      $satask  = 'TFRMOV'
720aA
720aAC                   eval      $saActionU = *on
720aAC                   eval      $saAction = 'TFR'
720aAC                   eval      $saTrn#U = *on
720aAc*                  exsr      zztrnstart
720aAC                   eval      $saTrn# = curtrn#
720aAC                   eval      $saETrn#U = *on
720aAC                   eval      $saETrn# = 0
720aAC                   eval      $saToLcnsU = *on
720aAC                   eval      $saToLcns = $tinlic#
720aAC                   eval      $saToPosU = *on
720aAC                   eval      $saToPos = $tslotpos
720aAC                   eval      $saToVrfyU = *on
720aAC                   eval      $saToVrfy = 'N'
720aAC                   eval      $saToCodeu = *on
720aAC                   eval      $saToCode = 'U'
720aAC                   eval      $saToAreaU = *on
720aAC                   eval      $saToArea = 'User'
720aAC                   eval      $saFrmLcnsU = *on
720aAC                   eval      $saFrmLcns = $toutlic#
720aAC                   eval      $saOLcnsU = *on
720aAC                   eval      $saOLcns = $litolcns
720aA
720aA*     Set item change flag
720aA
720aA
720aAC                   eval      $dricommand = '*SLOT'
720aA
720aA*     Do Reverse transfer if Pick slot and item didn't change.
720aA
720aAC                   if        #fromslpick = 'Y'
720aAC                             and #fromslitem = $ititem
720aAC                   eval      Ypickslot   = *on
720aA **   If FROM slot is pick, save data just in case TO slot
720aA
720aAC                   eval      $drisubcmd  = '%TFR2USRR'
720aAC                   else
720aAC                   eval      $drisubcmd  = '%TFR2USR'
720aAC                   endif
720aAC                   eval      $drisys2upd = 'D'
720aAC                   eval      chk4err = *on
720aAC                   eval      zmsflag = *off
720aAC                   exsr      zzzdricop
720aAC                   if        error
720aAC                   goto      endtfr
720aAC                   endif
720aAC                   eval      tfr2usrDate = today
720aAC                   time                    tfr2usrTime
720aAC                   eval      tfroutflag = *on
720aAC                   eval      curlic# = $saToLcns
720aAC                   eval      $tinlic# = $saToLcns
720aA
720aA*  Override $saFrmEmpty for an empty Pick slot.
720aA*  Re: We want to ask a user if the slot is empty just in case he is
720aA*  moving the item to another Pick slot and we are allow to auto verify.
720aA
720aAC                   if        Ypickslot   = *on
720aAC                             and partial = *off
720aAC                   eval      $saFrmEmpty = 'Y'
720aAC                   endif
720aA*
720aA*  Create work record.
720aA*
720aAC                   exsr      zzwrkadd
720aA
720aA*    Then tell user to put back an pulled pallets.
720aA*         and move on to the putaway process.
720aA
720aAC                   exsr      zzzclr$lt210
720aAC                   eval      $tcmd  = '*PULRTN'
720aAC                   eval      $twhse = $pwhse
720aAC                   eval      $twhdp = #fromslwhdp
720aAC                   eval      $tslot = #fromsldisp
720aAC                   eval      $titem = #fromslitem
720aAC                   eval      $titemdsc = $itdesc
720aAC                   eval      $tlic#    = $saToLcns
720aAC                   exsr      zzzcall$lt210
720aAC                   if        $treturn <> '*OK'
720aAC                   endif
720aA **** now for the rest of the stuff from it252 zzupd2
720aAC                   move      *off          error
720aAC*****              move      *off          dteold
720aAC*****              move      *off          dteofl
720aA*   Change quantity to breakdown quantity if needed.
720aA ************ what if adjusting a breakdown
720aAC                   eval      toqty1 = w1qt01
720aA*
720aA
720aA*    Determine if we are returning qty to original slot.
720aA
720aAC                   if        $pwhdp    = wuPulWhdp
720aAC                             and $pdisp = wuPulDisp
720aAC                             and $ititem = wuPulItem
720aAC                   eval      rtnToOrig = *on
720aAC                   else
720aAC                   eval      rtnToOrig = *off
720aAC                   endif
720aA
720aA*    Call license tracking for putaway - Before update
720aA*    Only call when not returning to original slot.
720aA
720aAC                   select
720aA
720aA
720aAC                   when      rtnToOrig = *on
720aA
720aAC                   eval      $tinlic# = wuPulLcns
720aAC                   eval      $tslotpos = wuPulPos
720aAC                   eval      $toutlic# = wuUsrLcns
720aA
720aAC                   other
720aA
720aAC                   if        not skipLT210
720aA
720aAC                   exsr      zzzclr$lt210
720aAC                   eval      $tcmd     = '*PUTAWYB'
720aAC                   eval      $tlic#    = wuUsrLcns
720aAC                   eval      $tpartial = partial
720aAC                   eval      $twhse    = $pwhse
720aAC                   eval      $twhdp    = $pwhdp
720aAC                   eval      $tslot    = $pdisp
720aAC                   eval      $titem    = $ititem
720aAC                   eval      $titemdsc = $itdesc
720aAC                   eval      $tqty1    = toqty1
720aAC                   eval      $tqty2    = w1qt02
720aAC                   eval      $tqty3    = w1qt03
720aAC                   eval      $tnorm1   = toqty1
720aAC                   eval      $tnorm2   = w1qt02
720aAC                   eval      $tnorm3   = w1qt03
730aAC                   if        w7uci = ' '
730aAc                   if        $uiuci <> ' '
730aAc                   eval      $tuci = $uiuci
730aAc                   else
730aAc                   eval      $tuci = ' '
730aAc                   endif
730aAc                   else
720aAC                   eval      $tuci     =  w7uci
730aAc                   endif
720aAC                   exsr      zzzcall$lt210
720aA*
720aAC                   if        $treturn <> '*OK'
720aAC                   eval      redspl = *on
720aAC                   eval      error = *on
720aAC                   eval      errmsg = $terrmsg
720aAC                   exsr      zm0105
720aAC                   goto      endtfr
720aAC                   endif
720aA
720aAC                   endif
720aA
720aAC                   endsl
720aA
720aA*  Use DRI interface to tfr qty from USR slot to To slot.
720aA
720aAC                   exsr      clr$slot
720aAC                   eval      $slwhseu  = *on
720aAC                   eval      $slwhse   = $pwhse
720aAC                   eval      $slwhdpu  = *on
720aAC                   eval      $slwhdp   = $pwhdp
720aAC                   eval      $sldispu  = *on
720aAc                   if        prdtfr
720aAC                   eval      $slstatu  = *on
720aAC                   eval      $slstat   = 'PR'
720aAC                   eval      $sldisp   = hldprdDisp
720aAc                   else
720aAC                   eval      $sldisp   = $pdisp
720aAc                   endif
720aAC                   eval      $slentdu  = *on
720aAC                   eval      $slentd   = #fromslentd
720aAC                   eval      $slexpdu  = *on
720aAC                   eval      $slexpd   = #fromslexpd
720aAC                   eval      $saitemu  = *on
720aAC                   eval      $saitem   = $ititem
720aAC                   eval      $saqtyu   = *on
720aAC                   eval      $saqty1   = w1qt01
720aAC                   eval      $saqty2   = w1qt02
720aAC                   eval      $saqty3   = w1qt03
720aAC*
720aAC                   if        client = FoodPro
720aAC*
720aAC                   if           $itcwgt        = 'Y'
720aAC                   eval      $sacwtau = '1'
720aAC                   eval      $sacwta = uciwgt
720aAC                   else
720aAC                   eval      $sacwtau = '0'
720aAC                   endif
720aAC*
720aAC                   endif
720aAC*
720aAC                   eval      $sacitemu = *on
720aAC                   eval      $sacitem  = #fromslitem
720aAC                   eval      $sacdspu  = *on
720aAC                   eval      $sacwhdu = *on
720aAC                   eval      $sacwhd  = wuUsrWhdp
720aAC                   eval      $sacdsp   = wuUsrDisp
720aAC                   eval      $saToPosu = *on
720aAC                   eval      $saToPos  = $tslotpos
720aA
720aAC                   eval      $saActionU = *on
720aAC                   eval      $saAction = 'TFR'
720aAC                   eval      $saTrn#U = *on
720aAC                   eval      $saTrn# = curtrn#
720aAC                   eval      $saETrn#U = *on
720aAC                   eval      $saETrn# = 0
720aAC                   eval      $saToLcnsU = *on
720aAC                   eval      $saToLcns = $tinlic#
720aAC                   eval      $saToPosU = *on
720aAC                   eval      $saToPos = $tslotpos
720aAC                   eval      $saToVrfyU = *on
720aAC                   eval      $saToVrfy = 'N'
720aAC                   eval      $saToCodeu = *on
720aAC                   eval      $saToCode = 'S'
720aAC                   eval      $saToAreaU = *on
720aAC                   eval      $saToArea = 'Slot'
720aAC                   eval      $saFrmLcnsU = *on
720aAC                   eval      $saFrmLcns = $toutlic#
720aAC                   eval      $saOLcnsU = *on
720aAC                   eval      $saOLcns = wuPulolcns
720aA
720aAC                   eval      $sapullwhdpu = *on
720aAC                   eval      $sapullwhdp  = wuPulWhdp
720aAC                   eval      $sapulldispu = *on
720aAC                   eval      $sapulldisp  = wuPulDisp
720aAC                   eval      $sapullbaseu = *on
720aAC                   eval      $sapullbase  = wuPulBase
720aAC                   eval      $sapulllcnsu = *on
720aAC                   eval      $sapulllcns  = wuPulLcns
720aA
720aA*     Set changed item flag if necessary.
720aA
720aAC                   if        #fromslitem <> $ititem
720aAC                   eval      $saItmChgU = *on
720aAC                   eval      $saItmChg = 'Y'
720aAC                   endif
720aA
720aAC                   if        rtnToOrig = *on
720aAC                   eval      $saexcdU = *on
720aAC                   eval      $saexcd  = 'RTNORIG'
720aAC                   endif
720aA
720aA
720aAc                   if        $tpartial = *on
720aAc                   eval      $saUCIts = $tpartime
720aAc                   eval      $saUCItsU = *on
720aAc                   endif
720aA
720aAC                   eval      $dricommand = '*SLOT'
720aAC                   eval      $drisubcmd  = '%USR2PUT'
720aAC                   eval      $drisys2upd = 'D'
720aAC                   eval      chk4err = *on
720aAC                   eval      zmsflag = *off
720aAC                   exsr      zzzdricop
720aAC                   if        error
720aAC                   eval      *in21 = *on
720aAC                   eval      *in01 = *on
720aAC                   goto      endtfr
720aAC                   endif
720aA
720aA*  Update #TO slot info in case item was put into a virtual slot.
720aA
720aAC                   eval      #toslhand = $slhand
720aAC                   eval      $pdisp    = $sldisp
720aAc                   if        prdtfr
720aAC                   eval      #toslstat = 'PR'
720aAc                   else
720aAC                   eval      #toslstat = $slstat
720aAc                   endif
720aA
720aAC***                endif
720aA
720aA*    Call license tracking for putaway - After update
720aA*      Values are left over from "Before" call.
720aA
720aAC                   eval      $tcmd     = '*PUTAWYA'
720aAC                   eval      $twhdp    = $pwhdp
720aAC                   eval      $tslot    = $pdisp
720aAC                   exsr      zzzcall$lt210
720aA*
720aAC                   if        $treturn <> '*OK'
720aAC                   endif
720aA ** Use DRI interface to update From slot.
720aA **
720aAC                   if        Ypickslot = *on
720aAC                             and $slpick = 'Y'
720aAC                             and $slstat <> 'RP'
720aAC                             and $slstyp = 'F'
720aAC                   exsr      clr$slot
720aAC                   eval      $slwhseu  = *on
720aAC                   eval      $slwhse   = $pwhse
720aAC                   eval      $slwhdpu  = *on
720aAC                   eval      $slwhdp   = #fromslwhdp
720aAC                   eval      $sldispu  = *on
720aAC                   eval      $sldisp   = #fromsldisp
720aAC                   eval      $slitemu  = *on
720aAC                   eval      $slitem   = #fromslitem
720aAC                   eval      $slstatu  = *off
720aAC                   eval      $slstat   = #fromslstat
720aAC                   eval      $dricommand = '*SLOT'
720aAC                   eval      $drisubcmd  = '%SETSTAT  '
720aAC                   eval      $drisys2upd = 'D'
720aAC                   eval      chk4err = *on
720aAC                   eval      zmsflag = *off
720aAC                   exsr      zzzdricop
720aAC                   eval      Ypickslot = *off
720aAC                   if        $drireturn = 'NOTZROSTAT'
720aAC                   eval      error = *off
720aAC                   endif
720aAC                   if        error
720aAC                   eval      *in21 = *on
720aAC                   eval      *in01 = *on
720aAC                   endif
720aAC                   endif
720aAC                   eval      Ypickslot = *off
720aA
720aA
720aA*  Create label(s), create extra trans, close trans.
720aA
720aAC                   exsr      zzcrtl
720aA
720aA
720aA*  Delete work record
720aA
720aAC                   exsr      zzwrkdel
720aA
720aA*  Start idle tran.
720aA
720aAC*                  exsr      zztrnidle
720aA
720aA
720aAc****** this is the end of zzupd from it252
720aAC     endtfr        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZCRTL   Create Label records.
720aA*
720aAC     zzcrtl        begsr
720aA*
720aAC                   clear                   lbrec
720aAC                   eval      lbwhse = $pwhse
720aAC                   eval      lbwhdp = $pwhdp
720aAC                   eval      exwgfm = *zeros
720aA*
720aA*  FROM Slot.
720aA*
720aAC                   eval      lbaisl = #fromslaisl
720aAC                   eval      lbloc = #fromslloc
720aAC                   eval      lbrlvl = #fromslrlvl
720aAC                   eval      lbhand = #fromslhand
720aAC                   eval      lbpseq = #fromslpseq
720aAC                   eval      lbstyp = #fromslstyp
720aAC                   if        lbstyp = 'P'
720aAC                   eval      lbqryf = 1
720aAC                   else
720aAC                   eval      lbqryf = 0
720aAC                   endif
720aAC                   eval      fmwhdp = #fromslwhdp
720aAC                   eval      fmdisp = #fromsldisp
720aAC                   eval      fmitem = #fromslitem
720aA*
720aA* FROM ITEM
720aA*
720aAC                   eval      fmcwgt = $itcwgt
720aAC                   if        #fromslitem <> $ititem
720aAC                   if        $itumq2 <> 0
720aAC                   endif
720aAC                   endif
720aA*
720aA*    Create label records for case transfer.
720aA*
720aAC                   select
720aAC                   when      w1qt01 <> 0
720aAC                   eval      lbucod = $itum1
720aAC                   eval      lbqalc = w1qt01
720aAC                   eval      lbqpck = w1qt01
720aAC                   eval      lbucub = $itcube
720aAC     lbucub        mult      w1qt01        lbcube
720aAC                   eval      lbuwgt = $itswgt
720aAC     lbuwgt        mult      w1qt01        lbswgt
720aA*
720aA*    Save extended weight for item adjustment record.
720aAC                   add       lbswgt        exwgfm
720aAC                   eval      lbtie = 0
720aAC                   eval      lbhigh = 0
720aA*
720aA* TO Slot.
720aA*
720aAC                   eval      tocwgt = $itcwgt
720aAC                   eval      lbwhs2 = $pwhse
720aAC                   eval      lbwhd2 = $pwhdp
720aAC                   eval      towhdp = $pwhdp
720aAC                   eval      lbasl2 = #toslaisl
720aA*
720aAC                   eval      lbloc2 = #toslloc
720aAC                   eval      lblvl2 = #toslrlvl
720aAC                   eval      lbhnd2 = #toslhand
720aAC                   eval      todisp = $pdisp
720aAC                   eval      lbrte = *blanks
720aAC                   eval      toitem = $ititem
720aAC                   eval      lbpbat = 0
720aAC                   eval      lbutyp = 'N'
720aAC                   eval      lbtrn# = curtrn#
720aAC                   eval      lbctr# = 0
720aA*     - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      fmitem        lbitem
720aAC                   move      fmdisp        lbdisp
720aAC                   move      todisp        lbdsp2
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'A'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aAc                   endif
720aA*
720aA*     - Create second label record
720aA*         - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      toitem        lbitem
720aAC                   move      towhdp        lbwhdp
720aAC                   move      todisp        lbdisp
720aAC                   move      fmdisp        lbdsp2
720aAC                   eval      lbucod = $itum1
720aAC                   eval      lbqalc = toqty1
720aAC                   eval      lbqpck = toqty1
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'B'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aAc                   endif
720aAC                   eval      svtrn1 = curtrn#
720aAC                   move      '*YES'        newtrn
720aA*
720aA*     - Update current transaction.
720aA*
720aAC*                  exsr      zztrnupdate
720aA*
720aAC                   endsl
720aA*
720aA*    Create transfer record for breakdown 1 qty.
720aA*
720aAC                   select
720aAC                   when      w1qt02 <> 0
720aAC                   eval      lbucod = $itum2
720aAC                   eval      lbqalc = w1qt02
720aAC                   eval      lbqpck = w1qt02
720aAC                   if        $itumq2 > 0
720aAC     $itcube       div(h)    $itumq2       lbucub
720aAC     $itswgt       div(h)    $itumq2       lbuwgt
720aAC                   else
720aAC                   eval      lbuwgt = $itswgt
720aAC                   eval      lbucub = $itcube
720aAC                   endif
720aAC     lbucub        mult      w1qt02        lbcube
720aAC     lbuwgt        mult      w1qt02        lbswgt
720aA*    Save extended weight for item adjustment record.
720aAC                   add       lbswgt        exwgfm
720aA*
720aAC                   eval      lbtie = 0
720aAC                   eval      lbhigh = 0
720aA*
720aA* TO Slot.
720aA*
720aAC                   eval      tocwgt = $itcwgt
720aA*
720aAC                   eval      lbwhs2 = $pwhse
720aAC                   eval      lbwhd2 = $pwhdp
720aAC                   eval      towhdp = $pwhdp
720aAC                   eval      lbasl2 = #toslaisl
720aA*
720aAC                   eval      lbloc2 = #toslloc
720aAC                   eval      lblvl2 = #toslrlvl
720aAC                   eval      lbhnd2 = #toslhand
720aAC                   eval      todisp = $pdisp
720aAC                   eval      lbrte = *blanks
720aAC                   move      $ititem       toitem
720aAC                   eval      lbpbat = 0
720aAC                   eval      lbutyp = *on
720aAC                   if        newtrn = '*YES'
720aAC*                  exsr      zztrnclose
720aAC*                  exsr      zztrnstart
720aAC                   endif
720aA*
720aAC                   eval      lbtrn# = curtrn#
720aAC                   eval      svtrn2 = curtrn#
720aAC                   eval      lbctr# = 0
720aA*     - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      fmitem        lbitem
720aAC                   move      fmdisp        lbdisp
720aAC                   move      todisp        lbdsp2
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'A'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aAc                   endif
720aA*
720aA*     - Create second label record
720aA*         - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      toitem        lbitem
720aAC                   move      todisp        lbdisp
720aAC                   move      fmdisp        lbdsp2
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'B'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aaC                   endif
720aAC                   eval      svtrn2 = curtrn#
720aAC                   move      '*YES'        newtrn
720aA*
720aA*     - Update current transaction.
720aA*
720aAC*                  exsr      zztrnupdate
720aA*
720aAC                   endsl
720aA*
720aA*    Create transfer record for breakdown 2 qty.
720aA*
720aAC                   select
720aAC                   when      w1qt03 <> 0
720aAC                   eval      lbucod = $itum3
720aAC                   eval      lbqalc = w1qt03
720aAC                   eval      lbqpck = w1qt03
720aAC                   if        $itumq3 > 0
720aAC     $itcube       div(h)    $itumq3       lbucub
720aAC     $itswgt       div(h)    $itumq3       lbuwgt
720aAC                   else
720aAC                   eval      lbuwgt = $itswgt
720aAC                   eval      lbucub = $itcube
720aAC                   endif
720aAC     lbucub        mult      w1qt03        lbcube
720aAC     lbuwgt        mult      w1qt03        lbswgt
720aA*    Save extended weight for item adjustment record.
720aAC                   add       lbswgt        exwgfm
720aA*
720aAC                   eval      lbtie = 0
720aAC                   eval      lbhigh = 0
720aA*
720aA* TO Slot.
720aA*
720aAC                   eval      tocwgt = $itcwgt
720aA*
720aAC                   eval      lbwhs2 = $pwhse
720aAC                   eval      lbwhd2 = $pwhdp
720aAC                   eval      towhdp = $pwhdp
720aAC                   eval      lbasl2 = #toslaisl
720aA*
720aAC                   eval      lbloc2 = #toslloc
720aAC                   eval      lblvl2 = #toslrlvl
720aAC                   eval      lbhnd2 = #toslhand
720aAC                   eval      todisp = $pdisp
720aAC                   eval      lbrte = *blanks
720aAC                   move      $ititem       toitem
720aAC                   eval      lbpbat = 0
720aAC                   eval      lbutyp = '2'
720aAC                   if        newtrn = '*YES'
720aAC*                  exsr      zztrnclose
720aAC*                  exsr      zztrnstart
720aAC                   endif
720aA*
720aAC                   eval      lbtrn# = curtrn#
720aAC                   eval      svtrn3 = curtrn#
720aAC                   eval      lbctr# = 0
720aA*     - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      fmitem        lbitem
720aAC                   move      fmdisp        lbdisp
720aAC                   move      todisp        lbdsp2
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'A'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aAc                   endif
720aA*
720aA*     - Create second label record
720aA*         - Get new label number.
720aAC                   call      'PIRLBL#'
720aAC                   parm                    lblbl#
720aAC                   move      toitem        lbitem
720aAC                   move      todisp        lbdisp
720aAC                   move      fmdisp        lbdsp2
720aAC                   if        fmitem = toitem
720aAC                   eval      lbgrp1 = *on
720aAC                   else
720aAC                   eval      lbgrp1 = '2'
720aAC                   endif
720aAC                   eval      lbgrp2 = 'B'
720aAC                   eval      lbtype = 'T'
720aAC                   eval      lbstat = 'C'
720aAC                   eval      lbsdte = today
720aAC                   time                    lbstim
720aAC                   eval      lbrdte = today
720aAc** at this point we will not write label & transaction records
720aAc                   if        1 <> 1
720aAC                   write     lbrec
720aAc                   endif
720aAC                   eval      svtrn3 = curtrn#
720aAC                   move      '*YES'        newtrn
720aA*
720aA*     - Update current transaction.
720aA*
720aAC*                  exsr      zztrnupdate
720aA*
720aAC                   endsl
720aA*
720aA*  Close current transaction.
720aA*
720aAC*                  exsr      zztrnclose
720aA*
720aAC     endcrl        endsr
720aA*----------------------------------------------------------------
720aA*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
720aA*----------------------------------------------------------------
720aA
720aAC     zztrnupdate   begsr
720aA
720aAC                   call      'ADJTRAN2'
720aAC                   parm      '*INCTTL'     @pcmd            10
720aAC                   parm      #pgm          @pprg            10
720aAC                   parm      '*BATCH'      @ptype            8
720aAC                   parm      lbtrn#        @ptrn#            7 0
720aAC                   parm      ' '           @ptask            6
720aAC                   parm      0             @pwhse            3 0
720aAC                   parm      ' '           @pwhdp            5
720aAC                   parm      ' '           @pstyp            1
720aAC                   parm      lbcube        @pcube            9 3
720aAC                   parm      lbswgt        @pswgt            9 2
720aAC                   parm      lbqpck        @ppcs             5 0
720aAC                   parm      0             @paisl            5 0
720aAC                   parm      0             @pqty1            5 0
720aAC                   parm      0             @pqty2            5 0
720aAC                   parm      0             @pqty3            5 0
720aAC                   parm      ' '           @prte             5
720aAC                   parm      ' '           @ppo              9
720aAC                   parm      ' '           @pgrp1            1
720aAC                   parm      ' '           @pgrp2            1
720aAC                   parm      0             @pdate            8 0
720aAC                   parm      0             @ptime            6 0
720aAC                   parm      #curruser     @puser           10
720aAC                   parm      ' '           @prtn             8
720aAC                   parm      ' '           @pmsg             4
720aA
720aAC                   endsr
720aA*----------------------------------------------------------------
720aA*  ZZTRNCLOSE  Close a transaction
720aA*----------------------------------------------------------------
720aA
720aAC     zztrnclose    begsr
720aA
720aAC                   call      'ADJTRAN2'
720aAC                   parm      '*CLOSE'      @pcmd            10
720aAC                   parm      #pgm          @pprg            10
720aAC                   parm      '*BATCH'      @ptype            8
720aAC                   parm      curtrn#       @ptrn#            7 0
720aAC                   parm      ' '           @ptask            6
720aAC                   parm      0             @pwhse            3 0
720aAC                   parm      ' '           @pwhdp            5
720aAC                   parm      ' '           @pstyp            1
720aAC                   parm      0             @pcube            9 3
720aAC                   parm      0             @pswgt            9 2
720aAC                   parm      0             @ppcs             5 0
720aAC                   parm      0             @paisl            5 0
720aAC                   parm      0             @pqty1            5 0
720aAC                   parm      0             @pqty2            5 0
720aAC                   parm      0             @pqty3            5 0
720aAC                   parm      ' '           @prte             5
720aAC                   parm      ' '           @ppo              9
720aAC                   parm      ' '           @pgrp1            1
720aAC                   parm      ' '           @pgrp2            1
720aAC                   parm      0             @pdate            8 0
720aAC                   parm      0             @ptime            6 0
720aAC                   parm      #curruser     @puser           10
720aAC                   parm      ' '           @prtn             8
720aAC                   parm      ' '           @pmsg             4
720aA
720aAC                   endsr
720aA
720aA*----------------------------------------------------------------
720aA*  zzwrkadd   Add record to work file for user.
720aA*----------------------------------------------------------------
720aA
720aAC     zzwrkadd      begsr
720aA
720aAC                   exsr      zzgetcurrstamp
720aAC*
720aAC                   clear                   wuRec
720aA
720aAC                   eval      wutrn# = curtrn#
720aAC                   eval      wuwhse = $pwhse
720aAC                   eval      wuscannbr = #fromToLcns
720aAC                   eval      wuscantype = 'P'
720aAC                   eval      wupulwhdp = #fromslwhdp
720aAC                   eval      wupulbase = #frombasesldsp
720aAC                   eval      wupuldisp = #fromsldisp
720aAC                   eval      wupulitem = #fromslitem
720aAC                   eval      wupullcns = #fromToLcns
720aAC                   eval      wupulolcns = #fromOLcns
720aAC                   eval      wupulvfy   = $saFrmEmpty
720aA
720aAC                   eval      wuUsrWhdp = $slwhdp
720aAC                   eval      wuUsrDisp = $sldisp
720aAC                   eval      wuNewItem = #fromslitem
720aA
720aAC                   eval      wuRemQty1 = w1qt01
720aAC                   eval      wuRemQty2 = w1qt02
720aAC                   eval      wuRemQty3 = w1qt03
720aA
720aAC                   eval      wuPullCns = $toutlic#
720aAC                   eval      wuUsrLcns = $tinlic#
720aA
720aAC                   eval      wuRecType = 'TFR'
720aAC                   eval      wuaddts  = currstampsys
720aAC                   eval      wuadduc  = currstampuc
720aAC                   eval      wuaddpgm = #pgm
720aAC                   eval      wuaddemp = E$EMP#
720aAC                   eval      wuaddeusr = #curruser
720aAC                   eval      wuaddjusr = #user
720aAC                   eval      wuaddjob = #job
720aAC                   eval      wuaddnbr = #jobnbr
720aAc*
720aAC                   write     wuRec
720aA
720aAC                   endsr
720aA
720aA*----------------------------------------------------------------
720aA*  zzwrkdel   Delete work file record
720aA*----------------------------------------------------------------
720aA
720aAC     zzwrkdel      begsr
720aA
720aAC*    wktkey        chain(e)  worktfr
720aAC*                  delete    wktrec
720aA
720aA /free
730aD   //chain (wktype: E$EMP#: $pwhse: $pwhdp: $pdisp) workusr3;
730aM   chain (wktype: E$EMP#: $pwhse: $pwhdp: #fromsldisp) workusr3;
720aA /end-free
720aAC                   if        %found
720aAC                   delete    wuRec
720aAC                   endif
720aA
720aAC                   endsr
720aA
720aA*----------------------------------------------------------------
720aA*  ZZTRNSTART  Start a transaction
720aA*----------------------------------------------------------------
720aA
720aAC     zztrnstart    begsr
720aA
720aAC                   call      'ADJTRAN2'
720aAC                   parm      '*CRTSTRT'    @pcmd            10
720aAC                   parm      #pgm          @pprg            10
720aAC                   parm      '*BATCH'      @ptype            8
720aAC                   parm      0             @ptrn#            7 0
720aAC                   parm      'TFRMOV'      @ptask            6
720aAC                   parm      $pwhse        @pwhse            3 0
720aAC                   parm      lbwhdp        @pwhdp            5
720aAC                   parm      lbstyp        @pstyp            1
720aAC                   parm      0             @pcube            9 3
720aAC                   parm      0             @pswgt            9 2
720aAC                   parm      0             @ppcs             5 0
720aAC                   parm      0             @paisl            5 0
720aAC                   parm      0             @pqty1            5 0
720aAC                   parm      0             @pqty2            5 0
720aAC                   parm      0             @pqty3            5 0
720aAC                   parm      ' '           @prte             5
720aAC                   parm      ' '           @ppo              9
720aAC                   parm      'T'           @pgrp1            1
720aAC                   parm      ' '           @pgrp2            1
720aAC                   parm      0             @pdate            8 0
720aAC                   parm      0             @ptime            6 0
720aAC                   parm      #curruser     @puser           10
720aAC                   parm      ' '           @prtn             8
720aAC                   parm      ' '           @pmsg             4
720aA
720aAC                   eval      curtrn# = @ptrn#
720aAC                   endsr

720aA*----------------------------------------------------------------
720aA*  ZZTRNIDLE   Start and IDLE transaction.
720aA*----------------------------------------------------------------
720aA
720aAC     zztrnidle     begsr
720aA
720aAC                   call      'ADJTRAN2'
720aAC                   parm      '*CRTSTRT'    @pcmd            10
720aAC                   parm      #pgm          @pprg            10
720aAC                   parm      '*BATCH'      @ptype            8
720aAC                   parm      0             @ptrn#            7 0
720aAC                   parm      'IDLE'        @ptask            6
720aAC                   parm      $pwhse        @pwhse            3 0
720aAC                   parm      ' '           @pwhdp            5
720aAC                   parm      ' '           @pstyp            1
720aAC                   parm      0             @pcube            9 3
720aAC                   parm      0             @pswgt            9 2
720aAC                   parm      0             @ppcs             5 0
720aAC                   parm      0             @paisl            5 0
720aAC                   parm      0             @pqty1            5 0
720aAC                   parm      0             @pqty2            5 0
720aAC                   parm      0             @pqty3            5 0
720aAC                   parm      ' '           @prte             5
720aAC                   parm      ' '           @ppo              9
720aAC                   parm      ' '           @pgrp1            1
720aAC                   parm      ' '           @pgrp2            1
720aAC                   parm      0             @pdate            8 0
720aAC                   parm      0             @ptime            6 0
720aAC                   parm      #curruser     @puser           10
720aAC                   parm      ' '           @prtn             8
720aAC                   parm      ' '           @pmsg             4
720aA
720aAC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN91=Protect & non-display breakdown1 unit of measure
     *    *IN92=Protect & non-display breakdown2 unit of measure

600bDC**                 exsr      clr$item
600bDC**                 eval      $itwhse  = $pwhse
600bDC**                 eval      $ititem  = $slitem
600bD **
600bDC**                 eval      $dricommand = '*ITEM'
600bDC**                 eval      $drisubcmd  = '%GETMAIN'
600bDC**                 eval      $drisys2upd = 'D'
600bDC**                 exsr      zzzdricop
600bD **
600bDC**                 if        error
600bMC                   if        $itdesc = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
 2B  C                   if        $itflg1 = 'N'  and
     C                             ssbflg = *off
     C                   eval      *in92 = *on
 2E  C                   endif
 2B  C                   if        $itflg2 = 'N'  and
     C                             ssbflg = *off  or
     C                             $itflg2 = 'N'  and
     C                             ssbflg = *on  and
     C                             $itum3 = *blanks
     C                   eval      *in93 = *on
 2E  C                   endif
     C                   endif
     *
     C     $itum1        chain     unmesr                             75
 1B  C                   if        not *in75
     C                   eval      w1um1 = umshrt
 1X  C                   else
     C                   eval      w1um1 = *blanks
 1E  C                   endif
     *
 1B  C                   if        not *in92
     C     $itum2        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um2 = umshrt
 2X  C                   else
     C                   eval      w1um2 = *blanks
 2E  C                   endif
 1E  C                   endif
     *
 1B  C                   if        not *in93
     C     $itum3        chain     unmesr                             75
 2B  C                   if        not *in75
     C                   eval      w1um3 = umshrt
 2X  C                   else
     C                   eval      w1um3 = *blanks
 2E  C                   endif
 1E  C                   endif
FPRaA* protect normal qty if normal uom = 'MP'
FPRaA /free
FPRaA   if client = foodpro;
FPRaA     if $itum1 = 'MP' and $itum2 <> ' ';
FPRaA       *in41 = *on;
FPRaA     else;
FPRaA       *in41 = *off;
FPRaA     endif;
FPRaA   endif;
FPRaA /end-free
     C     enduom        endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZADJIN  Adjust in the slot uci not currently in inventory
730aA*
730aAC     zzadjin       begsr
730aAC                   move      *off          error

730aA*   Fill interface data structure fields.

730aAC                   exsr      clr$slot
730aAC                   eval      $slwhseu = *on
730aAC                   eval      $slwhse  = $pwhse
730aAC                   eval      $slwhdpu = *on
730aAC                   eval      $slwhdp  = $pwhdp
730aAC                   eval      $sldispu = *on
730aAC                   eval      $sldisp  = $pdisp
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
730aAC                   eval      $sacwta  = cnvwgt * 1
730aAC                   eval      $sacodeu = *on
730aAC                   eval      $sacode  = w1code
730aAC                   eval      $samemou = *on
730aAC                   eval      $samemo  = w1memo
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w6type <> '4'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w6type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U' and w6type = '2'
730aAc*                  if        $imltrk = 'U'
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
730aA /free
730aA   sleep(1);
730aA /end-free

730aAC     endadjin      endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZADJOUT Adjust out of the slot uci is currently located.
730aA*
730aAC     zzadjout      begsr
730aAC                   move      *off          error

730aA*   Fill interface data structure fields.

730aAC                   exsr      clr$slot
730aAC                   eval      $slwhseu = *on
730aAC                   eval      $slwhse  = $pwhse
730aAC                   eval      $slwhdpu = *on
730aAC                   eval      $slwhdp  = $pwhdp
730aAC                   eval      $sldispu = *on
730aAC                   eval      $sldisp  = $pdisp
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
730aAC*                  exsr      zzcnvwgt
730aAC                   eval      $sacwta  = $uiwgtlbs * -1
730aAC                   eval      $sacodeu = *on
730aAC                   eval      $sacode  = w1code
730aAC                   eval      $samemou = *on
730aAc                   if        w6type = '3'
730aAC                   eval      $samemo  = 'No Scan Type 3 All'
730aAc                   else
730aAC                   eval      $samemo  = w1memo
730aAc                   endif
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w6type <> '4'
730aAC                                           and w6type <> '3'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w6type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aAc*                  if        $imltrk = 'U' and w6type = '2'
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
730aA /free
730aA   sleep(1);
730aA /end-free

730aAC     endadjout     endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZINTOUT Adjust out of the slot uci is currently located.
730aA*           this is an internal adjustment.
730aA*
730aAC     zzintout      begsr
730aAC                   move      *off          error

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
730aAC                   eval      $samemo  = w1memo
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w6type <> '4'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w6type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aAc*                  if        $imltrk = 'U' and w6type = '2'
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
730aA /free
730aA   sleep(1);
730aA /end-free

730aAC     endintout     endsr
730aA*----------------------------------------------------------------
730aA*
730aA*  ZZINTIN  Adjust in the slot the user says the uci is
730aA*           physically in. This is an internal adjustment.
730aA*           Used to locate the uci in the correct overflow slot.
730aA*
730aAC     zzintin       begsr
730aAC                   move      *off          error

730aA*   Fill interface data structure fields.

730aAC                   exsr      clr$slot
730aAC                   eval      $slwhseu = *on
730aAC                   eval      $slwhse  = $Pwhse
730aAC                   eval      $slwhdpu = *on
730aAC                   eval      $slwhdp  = $pwhdp
730aAC                   eval      $sldispu = *on
730aAC                   eval      $sldisp  = $pdisp
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
730aAC                   eval      $samemo  = w1memo
730aAC                   eval      $sabyu   = *on
730aAC                   eval      $saby    = #curruser
730aA
730aAC                   eval      $saActionU = *on
730aAC                   eval      $saAction = 'ADJ'
730aAC                   eval      $saETrn#U = *on
730aAC                   eval      $saETrn# = 0
730aAc                   if        $imltrk = 'U' and w6type <> '4'
730aAc                   eval      $saUCIts = $ppartime
730aAc                   eval      $saUCItsU = *on
730aAc                   else
730aAc                   eval      $saUCIts = *loval
730aAc                   eval      $saUCItsU = *on
730aAc                   endif
730aAc                   if        $imltrk = 'U'
730aAc                   eval      $saUCItype = w6type
730aAc                   eval      $saUCItypeU = *on
730aAc                   endif
730aAc*                  if        $imltrk = 'U' and w6type = '2'
730aAc*                  if        $imltrk = 'U'
730aAc*                  eval      $satolcns = $litolcns
730aAc*                  eval      $satolcnsu = *on
730aAc*                  endif
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
730aA   sleep(1);
730aA /end-free

730aAC     endintin      endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error

EIa A*   Call interface to get license info for lot code
EIa AC                   if        client = ei
640bAC                   exsr      clr$license
640bAC                   eval      $liToWhseU = *on
640bAC                   eval      $liToWhse = $pWhse
640bAC                   eval      $liToWhdpU = *on
640bAC                   eval      $liToWhdp = $slwhdp
640bAC                   eval      $liToDispU = *on
640bAC                   eval      $liToDisp = $pdisp
640bAC                   eval      $dricommand = '*LICENSE'
640bAC                   eval      $drisubcmd  = '%GETSLTLIC'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                             or $drireturn <> '*OK'
640bAC                             or $liToLcns = '*NONE'
640bAC                   else
640bA*  Get receiving information  - PO & Seq
640bA
640bAC                   exsr      clr$licinfo
640bA
640bAC                   eval      $lnemp# = 0
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr  = #jobn
640bA
640bAC                   eval      $lnwhse  = $Pwhse
640bAC                   eval      $lntype  = 'P'
640bAC                   eval      $lnlcns  = $liOLcns
640bA
640bA*     PO number
640bA
640bAC                   eval      $lncodeu(1) = *on
640bAC                   eval      $lncode(1) = '*PO'
640bAC                   eval      $lncseq(1) = 1
640bA
640bA*     PO Seq number
640bA
640bAC                   eval      $lncodeu(2) = *on
640bAC                   eval      $lncode(2) = '*POSEQ'
640bAC                   eval      $lncseq(2) = 1
640bA
640bAC                   eval      $dricommand = '*LICINFO'
640bAC                   eval      $drisubcmd  = '%GET'
640bAC                   eval      $drisys2upd = 'D'
640bAC                   eval      chk4err = *on
640bAC                   exsr      zzzdricop
640bAC                   if        error
640bAC                   endif
640bA
640bA*  Now process the return information
640bA
640bA*     PO number
640bA
640bAC                   if        $lncodee(1) = $driok
640bAC                             and $lnvalchr(1) <> ' '
640bAC                   eval      wOrpo = %trim($lnvalchr(1))
640bAC                   else
640bAC                   if        %subst($liOLcns:1:3) = '*RT'
640bAC                   eval      wOrpo = '<return>'
640bAC                   else
640bAC                   eval      wOrpo = ' '
640bAC                   endif
640bAC                   endif
640bA*     PO Seq number
640bA
640bAC                   if        $lncodee(2) = $driok
640bAC                             and $lnvalnum(2) <> 0
640bAC                   eval      wOseq = $lnvalnum(2)
640bAC                   else
640bAC                   eval      wOseq = 0
640bAC                   endif
640bA
640bAC                   endif
EIa A
EIa AC                   eval      wocode = %trim(worpo) +
EIa AC                                      %trim(%editc(woseq:'X'))
EIa AC                   eval      w1memo=%replace(wocode:w1memo:21:10)
EIa AC                   endif
     *   Fill interface data structure fields.

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = $pdisp
600bAC                   eval      $saitemu = *on
600bAC                   eval      $saitem  = $ititem
600bA
600bAC                   eval      $saqtyu  = *on
600bAC                   eval      $saqty1  = chgqt1
600bAC                   eval      $saqty2  = chgqt2
600bAC                   eval      $saqty3  = chgqt3
600bA
600bAC                   eval      $sacwtau = *on
700bAC                   exsr      zzcnvwgt
700bMC                   eval      $sacwta  = cnvwgt
700bDC*                  eval      $sacwta  = w1cwtr
600bAC                   eval      $sacodeu = *on
600bAC                   eval      $sacode  = w1code
600bAC                   eval      $samemou = *on
600bAC                   eval      $samemo  = w1memo
600bAC                   eval      $sabyu   = *on
600bAC                   eval      $saby    = #curruser
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'ADJ'
600bAC**                 eval      $saTrn#U = *on
600bAC**                 eval      $saTrn# = curtrn#
600bAC                   eval      $saETrn#U = *on
600bAC                   eval      $saETrn# = 0
600bAC**                 eval      $saLbl#U = *on
600bAC**                 eval      $saLbl# = lblbl#
600bAC**                 eval      $saToLcnsU = *on
600bAC**                 eval      $saToLcns = wkPulLcns
600bAC**                 eval      $saToPosU = *on
600bAC**                 eval      $saToPos = $tslotpos
600bAC**                 eval      $saToVrfyU = *on
600bAC**                 eval      $saToVrfy = 'N'
600bAC**                 eval      $saToCodeu = *on
600bAC**                 eval      $saToCode = 'S'
600bAC**                 eval      $saToAreaU = *on
600bAC**                 eval      $saToArea = 'Slot'
600bAC**                 eval      $saFrmLcnsU = *on
600bAC**                 eval      $saFrmLcns = wkUsrLcns
600bAC**                 eval      $saOLcnsU = *on
600bAC**                 eval      $saOLcns = wkpulolcns
720aAc                   if        $imltrk = 'U' and w6type <> '4'
720aAc                   eval      $saUCIts = $ppartime
720aAc                   eval      $saUCItsU = *on
720aAc                   else
720aAc                   eval      $saUCIts = *loval
720aAc                   eval      $saUCItsU = *on
720aAc                   endif
720aAc                   if        $imltrk = 'U'
720aAc                   eval      $saUCItype = w6type
720aAc                   eval      $saUCItypeU = *on
720aAc                   endif
720aDc                   if        $imltrk = 'U' and w6type = '2'
730aAc*                  if        $imltrk = 'U'
720aAc                   eval      $satolcns = $litolcns
720aAc                   eval      $satolcnsu = *on
720aAc                   endif

     *   Call interface to do update.

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *on
600bAC                   eval      zmsflag = *off
     C                   exsr      zzzdricop
600bD **
600bD **  Adjust license.
600bD **
600bDC**                 exsr      zzzclr$lt210
600bDC**                 eval      $tcmd  = '*ADJUST'
600bDC**                 eval      $twhse = $pwhse
600bDC**                 eval      $twhdp = $pwhdp
600bDC**                 eval      $tslot = $pdisp
600bDC**                 eval      $titem = $slitem
600bDC**                 eval      $tqty1 = chgqt1
600bDC**                 eval      $tqty2 = chgqt2
600bDC**                 eval      $tqty3 = chgqt3
600bDC**                 eval      $tnorm1 = chgqt1
600bDC**                 eval      $tnorm2 = chgqt2
600bDC**                 eval      $tnorm3 = chgqt3
600bDC**                 exsr      zzzcall$lt210

MJKaAC                   if        client = mjkellner and
520bAC                             svalis <> *blank
520bAC                   eval      inwhse = $pwhse
520bAC                   eval      initem = $ititem
520bAC                   eval      indate = $sadate
520bAC                   eval      intime = $satime
520bAC                   eval      inby   = #user
520bAC                   eval      inwhdp = $pwhdp
520bAC                   eval      indisp = $pdisp
520bAC                   eval      inudte = *zeros
520bAC                   eval      inutim = *zeros
520bAC                   eval      inmsc1 = svalis
520bAC                   write     inrec
MJKaAC                   endif

PCK AC*****              if        client = packers and
610bAC                   if        opuci = 'Y'      and
PCK AC                             $itcwgt = 'Y'
PCK AC                   select
PCK AC                   when      w1qt01 > *zeros
PCK AC                   eval      $lcmd   = '*ADDADJ '
PCK AC                   when      w1qt01 < *zeros
PCK AC                   eval      $lcmd   = '*DLTADJ '
PCK AC                   endsl
PCK AC                   eval      $lwhseu = $pwhse
PCK AC                   eval      $litemu = $ititem
PCK AC                   eval      $lcodeu = w1code
PCK AC*                  eval      $ltypeu = 'A'
PCK Ac                   eval      $ldate = $sadate
PCK Ac                   eval      $ltime = $satime
PCK AC                   call      @cwght
PCK AC                   parm                    $lparm
PCK AC                   parm      *zero         $batch            7 0
PCK AC                   parm      *blanks       $delvry           9
PCK AC                   parm      *blanks       $bildoc          10
PCKaAC                   parm      *blanks       $dspcde           5
PCK AC                   endif

     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     C                   move      *on           refrsh
720aAc                   if        $imltrk = 'U'
720aAC                   exsr      scr06i
720aAc                   else
     C                   exsr      scr02i
720aAc                   endif
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   move      *off          error
     C                   move      *on           refrsh
     C                   exsr      scr03i
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   move      *off          error
     C                   move      *on           refrsh
     C                   eval      w1memo = *blanks
     C                   movel     w1mem1        w1memo
     C                   move      w1mem2        w1memo
720aA*   If the uci being added is attached to a different slot/license
720aA*   We will be doing a transfer instead of an adjustment.
720aA*   This is where the fun begins.
720aA /free
730aD   //if w6type = '1' and $litodisp <> ' ';
730aM   if w6type = '1' and $litodisp <> ' ' and #TOSLPICK = 'Y';
720aA     // uci is currently attached to a license in a different slot
720aA     if $litodisp <> $pdisp;
720aA       nxtscr = 'EOJ';
720aA       exsr zztfr;
720aA       leavesr;
720aA     endif;
720aA   endif;

720aA /end-free
730aA*   If the uci being added is attached to a different slot/license
730aA*   And the slot is an overflow slot, we need to do an adjustment
730aA*   not a transfer like we do to the pick slot.
730aA*   here we will adjust out of the slot the system currently
730aA*   shows the UCI located.
730aA*   Then we will let the possitive adjustment occur in zzupd.
730aA /free
730aA   if w6type = '1' and $litodisp <> ' ' and #TOSLPICK <> 'Y';
730aA     // uci is currently attached to a license in a different slot
730aA     if $litodisp <> $pdisp;
730aA       //nxtscr = 'EOJ';
730aA       exsr zzintout;
730aA     endif;
730aA   endif;

720aA /end-free
730aA*   On Type 3 - we will need to handle each uci one at a time
730aA*   to determine the proper function. will we transfer, do an
730aA*   internal or external adjustment.
730aA /free
730aA   if w6type = '3';
730aA     // Now lets deal with any missing uci's for this slot/license
730aA     exsr clr$uciinfo;

730aA     $uiWhse = $pwhse;
730aA     $uiapartlts = $ppartime;
730aA     // Before we start processing what they did scan.
730aA     // We need to remove the uci's attached to any licenses for
730aA     // the slot they are updating that they didn't scan.
730aA     // Loop thru the licative for this slot, send the license and the
730aA     // and the scan time to driuciinfo.
730aA     // Will need to bring back one at a time in order to adjust
730aA     // the uci out of the system.
730aA     setll ($pwhse: $pwhdp: $pdisp) licactive1;
730aA     dow forevr = forevr;
730aA       reade ($pwhse: $pwhdp: $pdisp) licactive1;
730aA       if %eof(licactive1);
730aA         leave;
730aA       endif;
730aA       $uilcns = lalcns;
730aA       // now we have a license for the slot being adjusted
730aA       // do we have any uci's that were not scanned?
730aA       dow forevr = forevr;
730aA         $dricommand = '*UCIINFO';
730aA         $drisubcmd  = '%GETMISUCI';
730aA         $drisys2upd = 'D';
730aA         exsr zzzdricop;
730aA         if $drireturn  = '*OK';
730aA           // need to adjust out this uci.
730aA           exsr zzadjout;
730aA           // if we encounter any errors from Drislot - get out
730aA           if $drireturn  <> '*OK';
730aA             leave;
730aA           endif;
730aA         else;
730aA           leave;
730aA         endif;
730aA       enddo;
730aA     enddo;

730aA     // now lets process what they did scan
730aA     // let's process each uci one at a time.
730aA     dow forevr = forevr;
730aA       exsr clr$uciinfo;

730aA       $uiWhse = $pwhse;
730aA       $uiapartlts = $ppartime;
730aA       $dricommand = '*UCIINFO';
730aA       $drisubcmd  = '%GETADJUCI';
730aA       $drisys2upd = 'D';
730aA       exsr zzzdricop;
730aA       if $drireturn  = '*OK';
730aA         // PICK SLOT?
730aA         select;
730aA           when #TOSLPICK = 'Y';

730aA             // is the uci already in this slot?
730aA             select;
730aA               when $SlotLcns = $uilcns;
730aA                 // just remove time stamp from the uci nothing needs
730aA                 // to be adjusted for this uci.
730aA                 $dricommand = '*UCIINFO';
730aA                 $drisubcmd  = '%RMVADJTIM';
730aA                 $drisys2upd = 'D';
730aA                 exsr zzzdricop;
730aA                 if $drireturn  = '*OK';
730aA                 endif;
730aA                 iter;
730aA               when $uilcns = '*BFCADJADD' or
730aA                    $uilcns = ' ';
730aA                 // these are not currently showing in inventory
730aA                 // adjust in qty of 1 and send to host
730aA                 exsr zzadjin;
730aA                 // now remove time stamp from the uci that was
730aA                 // just transferred.
730aA                 $dricommand = '*UCIINFO';
730aA                 $drisubcmd  = '%RMVADJTIM';
730aA                 $drisys2upd = 'D';
730aA                 exsr zzzdricop;
730aA                 if $drireturn  = '*OK';
730aA                 endif;
730aA                 iter;
730aA               when $slotlcns <> $uilcns;
730aA                 // transfer to slot
730aA                 exsr clr$license;
730aA                 $liToWhseU = *on;
730aA                 $liToWhse = $pWhse;
730aA                     //$liToWhdpU = *on;
730aA                     //$liToWhdp = $slwhdp;
730aA                     //$liToDispU = *on;
730aA                     //$liToDisp = $pdisp;
730aA                 $liToLcnsU = *on;
730aA                 $liToLcns = $uilcns;
730aA                 $dricommand = '*LICENSE';
730aA                 $drisubcmd  = '%GETLCNS';
730aA                 $drisys2upd = 'D';
730aA                 chk4err = *on;
730aA                 exsr zzzdricop;
730aA                 if $pdisp = $LITOdisp;
730aA                   // already working with this display. should not
730aA                   // need to do anything. this should only happen for
730aA                   // pick slots.
730aA                   // just remove time stamp from the uci nothing needs
730aA                   // to be adjusted for this uci.
730aA                   $dricommand = '*UCIINFO';
730aA                   $drisubcmd  = '%RMVADJTIM';
730aA                   $drisys2upd = 'D';
730aA                   exsr zzzdricop;
730aA                   if $drireturn  = '*OK';
730aA                   endif;
730aA                   iter;
730aA                 else;
730aA                   // will need to transfer uci to the slot/license
730aA                   exsr zzchktfr;
730aA                   exsr zztfr;
730aA                   // now remove time stamp from the uci that was
730aA                   // just transferred.
730aA                   $dricommand = '*UCIINFO';
730aA                   $drisubcmd  = '%RMVADJTIM';
730aA                   $drisys2upd = 'D';
730aA                   exsr zzzdricop;
730aA                   if $drireturn  = '*OK';
730aA                   endif;
730aA                   iter;
730aA                 endif;
730aA             endsl;
730aA           when #TOSLPICK <> 'Y';
730aA             // is the uci already in this slot?
730aA             select;
730aA               when $SlotLcns = $uilcns;
730aA                 // just remove time stamp from the uci nothing needs
730aA                 // to be adjusted for this uci.
730aA                 $dricommand = '*UCIINFO';
730aA                 $drisubcmd  = '%RMVADJTIM';
730aA                 $drisys2upd = 'D';
730aA                 exsr zzzdricop;
730aA                 if $drireturn  = '*OK';
730aA                 endif;
730aA                 iter;
730aA               when $uilcns = '*BFCADJADD' or
730aA                    $uilcns = ' ';
730aA                 // these are not currently showing in inventory
730aA                 // adjust in qty of 1 and send to host
730aA                 exsr zzadjin;
730aA                 // now remove time stamp from the uci that was
730aA                 // just transferred.
730aA                 $dricommand = '*UCIINFO';
730aA                 $drisubcmd  = '%RMVADJTIM';
730aA                 $drisys2upd = 'D';
730aA                 exsr zzzdricop;
730aA                 if $drireturn  = '*OK';
730aA                 endif;
730aA                 iter;
730aA               when $slotlcns <> $uilcns;
730aA                 exsr clr$license;
730aA                 $liToWhseU = *on;
730aA                 $liToWhse = $pWhse;
730aA                 $liToLcnsU = *on;
730aA                 $liToLcns = $uilcns;
730aA                 $dricommand = '*LICENSE';
730aA                 $drisubcmd  = '%GETLCNS';
730aA                 $drisys2upd = 'D';
730aA                 chk4err = *on;
730aA                 exsr zzzdricop;
730aA                 if $pdisp = $LITOdisp;
730aA                   // already working with this display. should not
730aA                   // need to do anything. this should only happen for
730aA                   // pick slots.
730aA                   // just remove time stamp from the uci nothing needs
730aA                   // to be adjusted for this uci.
730aA                   $dricommand = '*UCIINFO';
730aA                   $drisubcmd  = '%RMVADJTIM';
730aA                   $drisys2upd = 'D';
730aA                   exsr zzzdricop;
730aA                   if $drireturn  = '*OK';
730aA                   endif;
730aA                   iter;
730aA                 else;
730aA                   // We need to make internal adjustments out/in e
730aA                   exsr zzintout;
730aA                   exsr zzintin;
730aA                   // now remove time stamp from the uci that was
730aA                   // just transferred.
730aA                   $dricommand = '*UCIINFO';
730aA                   $drisubcmd  = '%RMVADJTIM';
730aA                   $drisys2upd = 'D';
730aA                   exsr zzzdricop;
730aA                   if $drireturn  = '*OK';
730aA                   endif;
730aA                   iter;
730aA                 endif;
730aA             endsl;
730aA         endsl;
730aA       endif;
730aA       // we are done get out of here
730aA       nxtscr = 'EOJ';
730aA       leavesr;
730aA     enddo;
730aA   endif;
730aA   if w6type = '4';
730aA     // lets remove any uci's attached to the slot
730aA     exsr clr$uciinfo;

730aA     $uiWhse = $pwhse;
730aA     $uiapartlts = $ppartime;
730aA     // We need to remove the uci's attached to any licenses for
730aA     // the slot they are updating.
730aA     // Loop thru the licative for this slot, send the license and the
730aA     // and the scan time to driuciinfo.
730aA     // Will need to bring back one at a time in order to adjust
730aA     // the uci out of the system.
730aA     setll ($pwhse: $pwhdp: $pdisp) licactive1;
730aA     dow forevr = forevr;
730aA       reade ($pwhse: $pwhdp: $pdisp) licactive1;
730aA       if %eof(licactive1);
730aA         leave;
730aA       endif;
730aA       $uilcns = lalcns;
730aA       // now we have a license for the slot being adjusted
730aA       // do we have any uci's that were not scanned?
730aA       dow forevr = forevr;
730aA         $dricommand = '*UCIINFO';
730aA         $drisubcmd  = '%GETMISUCI';
730aA         $drisys2upd = 'D';
730aA         exsr zzzdricop;
730aA         if $drireturn  = '*OK';
730aA           // need to adjust out this uci.
730aA           exsr zzadjout;
730aA           // if we encounter any errors from Drislot - get out
730aA           if $drireturn  <> '*OK';
730aA             leave;
730aA           endif;
730aA         else;
730aA           leave;
730aA         endif;
730aA       enddo;
730aA     enddo;
730aA     // we are done get out of here
730aA     nxtscr = 'EOJ';
730aA     leavesr;

730aA   endif;
730aA
720aA /end-free
     C                   exsr      zzupd
417 AC     error         cabeq     *on           endup3
417 AC*
     C                   move      'EOJ'         nxtscr
     C     endup3        endsr

     *----------------------------------------------------------------
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     *
     C     endup4        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZUPD6   Update for screen 6.
720aA*
720aAC     zzupd6        begsr
720aAC                   move      *off          error
720aAC                   move      *on           refrsh
720aAC                   time                    $ppartime
720aA * w6type = 4 - remove all inventory/uci for slot
720aAc                   if        w6type = '4'
720aAC                   exsr      scr02i
720aAc                   else
720aAC                   exsr      scr07i
720aAc                   endif
720aAC     endup6        endsr
720aA*----------------------------------------------------------------
720aA*
720aA*  ZZUPD7   Update for screen 7.
720aA*
720aAC     zzupd7        begsr
720aAC                   move      *off          error
720aAC                   move      *on           refrsh

720aA /free
720aA   Select;
720aA     When w6type = '1';
720aA       // are we updating an existing uci

720aA       if $uiaction = 'ADJSTART';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;

720aA         // Lets add some more stuff for tracking
720aA         $uiAolcns = $uiaolcns;
720aA         $uiAoseq = $uiaoseq;
720aA         $uiscan = 'Y';
720aA         $dricommand = '*UCIINFO';
720aA         $drisubcmd  = '%UPDPARTL';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 + 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 + 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 + 1;
720aA           other;
720aA             uciqty1 = uciqty1 + 1;
720aA         endsl;
720aA         uciqty = uciqty + 1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt + $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt + $uiwgtkgs;
730aD         //endif;
720aA       endif;

720aA       // are we adding a new uci
720aA       if $uiaction = 'ADJADD';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;
720aA         // load up any additional information extracted from barcode
720aA         if $bcgtinsent;
720aA           $uiagtin = %dec($bcgtin:14:0);
720aA         endif;
720aA         if $bclotsent;
720aA           $uialot = $bclot;
720aA         endif;
720aA         if $bcSer#Sent;
720aA           $uiserial = $bcSer#;
720aA         endif;
720aA         if $bcPNtLbSent;
720aA           $uiWgtlbs = $bcPNtLb;
720aA         endif;
720aA         if $bcPNtKgSent;
720aA           $uiWgtKgs = $bcPNtKg;
720aA         endif;
730bA         $uiautyp = uputyp;
730bA         $uiaslutyp = uputyp;

720aA         // Lets add some more stuff for tracking
720aA         $uicrtby = 'B';
720aA         $uiaolcns = '*BFCADJADD';
720aA         $uialcns = '*BFCADJADD';
720aA         $uilcns = '*BFCADJADD';
720aA         $uiaentd = today;
720aA         //$uioseq = $uiseq;
720aA         $uiscan = 'Y';
720aA         // load some exception data since we don't know how
720aA         // this uci got in the warehouse
720aA         $uiexccode = 'UNKNWORG';
720aA         $uiexcstat = '1';
720aA         $dricommand = '*UCIINFO';
720aA         //$drisubcmd  = '%UPDPARTL';
720aA         $drisubcmd  = '%ADD';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 + 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 + 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 + 1;
720aA           other;
720aA             uciqty1 = uciqty1 + 1;
720aA         endsl;
720aA         uciqty = uciqty + 1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt + $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt + $uiwgtkgs;
730aD         //endif;
720aA
720aA       endif;
720aA       // if the uci being added is attached to a different slot/
720aA       // license we will be doing a transfer instead of an
720aA       // adjustment.  This is where the  fun begins.
730aD       //if $litodisp <> ' ';
730aM       if $litodisp <> ' ' and #TOSLPICK = 'Y';
720aA         // uci is attached to a license in a different slot
720aA         if $litodisp <> $pdisp;
720aA           nxtscr = 'EOJ';
720aA           exsr zztfr;
720aA           leavesr;
720aA         endif;
720aA       endif;
720aA     When w6type = '2';
720aA       if $uiaction = 'ADJSTART';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;

720aA         // Lets add some more stuff for tracking
720aA         $uiAolcns = $uiAolcns;
720aA         $uiAoseq = $uiAoseq;
720aA         $uiscan = 'Y';
720aA         $dricommand = '*UCIINFO';
720aA         $drisubcmd  = '%UPDPARTL';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 - 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 - 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 - 1;
720aA           other;
720aA             uciqty1 = uciqty1 - 1;
720aA         endsl;
720aA         uciqty = uciqty - 1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt - $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt - $uiwgtkgs;
730aD         //endif;
720aA       endif;
720aA       // are we removing a uci from the warehouse but it doesn't
720aA       // exist currently, so we temporarily add it for the adjustment
720aA       if $uiaction = 'ADJDLT';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;
720aA         // load up any additional information extracted from barcode
720aA         if $bcgtinsent;
720aA           $uiagtin = %dec($bcgtin:14:0);
720aA         endif;
720aA         if $bclotsent;
720aA           $uialot = $bclot;
720aA         endif;
720aA         if $bcSer#Sent;
720aA           $uiserial = $bcSer#;
720aA         endif;
720aA         if $bcPNtLbSent;
720aA           $uiWgtlbs = $bcPNtLb;
720aA         endif;
730aD         //if $bcPNtKgSent;
730aD           //$uiWgtKgs = $bcPNtKg;
730aD         //endif;
730bA         $uiautyp = uputyp;
730bA         $uiaslutyp = uputyp;

720aA         // Lets add some more stuff for tracking
720aA         $uicrtby = 'B';
720aA         $uiaolcns = '*BFCADJADD';
720aA         $uialcns = '*BFCADJADD';
720aA         $uilcns = '*BFCADJADD';
720aA         $uiaentd = today;
720aA         //$uioseq = $uiseq;
720aA         $uiscan = 'Y';
720aA         // load some exception data since we don't know how
720aA         // this uci got in the warehouse
720aA         $uiexccode = 'UNKNWORG';
720aA         $uiexcstat = '1';
720aA         $dricommand = '*UCIINFO';
720aA         //$drisubcmd  = '%UPDPARTL';
720aA         $drisubcmd  = '%ADD';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 - 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 - 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 - 1;
720aA           other;
720aA             uciqty1 = uciqty1 - 1;
720aA         endsl;
720aA         uciqty = uciqty -1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt - $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt - $uiwgtkgs;
730aD         //endif;
720aA
720aA       endif;
720aA     When w6type = '3';
720aA       // are we updating an existing uci

720aA       if $uiaction = 'ADJSTART';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;

720aA         // Lets add some more stuff for tracking
720aA         $uiAolcns = $uiAolcns;
720aA         $uiAoseq = $uiAoseq;
720aA         $uiscan = 'Y';
720aA         $dricommand = '*UCIINFO';
720aA         $drisubcmd  = '%UPDPARTL';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 + 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 + 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 + 1;
720aA           other;
720aA             uciqty1 = uciqty1 + 1;
720aA         endsl;
720aA         uciqty = uciqty + 1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt + $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt + $uiwgtkgs;
730aD         //endif;
720aA       endif;

720aA       // are we adding a new uci
720aA       if $uiaction = 'ADJADD';
720aA         $uiWhse = $pwhse;
720aA         $uiuci  = w7uci;
720aA         $uiapartlts = $ppartime;
720aA         // load up any additional information extracted from barcode
720aA         if $bcgtinsent;
720aA           $uiagtin = %dec($bcgtin:14:0);
720aA         endif;
720aA         if $bclotsent;
720aA           $uialot = $bclot;
720aA         endif;
720aA         if $bcSer#Sent;
720aA           $uiserial = $bcSer#;
720aA         endif;
720aA         if $bcPNtLbSent;
720aA           $uiWgtlbs = $bcPNtLb;
720aA         endif;
730aD         //if $bcPNtKgSent;
730aD           //$uiWgtKgs = $bcPNtKg;
730aD         //endif;
730bA         $uiautyp = uputyp;
730bA         $uiaslutyp = uputyp;

720aA         // Lets add some more stuff for tracking
720aA         $uiaolcns = '*BFCADJADD';
720aA         $uialcns = '*BFCADJADD';
720aA         $uilcns = '*BFCADJADD';
720aA         $uiaentd = today;
720aA         //$uioseq = $uiseq;
720aA         $uiscan = 'Y';
720aA         // load some exception data since we don't know how
720aA         // this uci got in the warehouse
720aA         $uiexccode = 'UNKNWORG';
720aA         $uiexcstat = '1';
720aA         $dricommand = '*UCIINFO';
720aA         //$drisubcmd  = '%UPDPARTL';
720aA         $drisubcmd  = '%ADD';
720aA         $drisys2upd = 'D';
720aA         exsr zzzdricop;
720aA         // if return is *OK we updated the uci record
720aA         if $drireturn <> '*OK';
720aA           error = *on;
720aA           *in21 = *on;
720aA           *in01 = *on;
720aA           errmsg = 'problem updating uci';
720aA           exsr zm0105;
720aA           leavesr;
720aA         endif;
720aA         select;
720aA           when $uiautyp = 'N';
720aA             uciqty1 = uciqty1 + 1;
720aA           when $uiautyp = '1';
720aA             uciqty2 = uciqty2 + 1;
720aA           when $uiautyp = '2';
720aA             uciqty3 = uciqty3 + 1;
720aA           other;
720aA             uciqty1 = uciqty1 + 1;
720aA         endsl;
720aA         uciqty = uciqty + 1;
720aA         if $uiwgtlbs > 0;
720aA           uciwgt = uciwgt + $uiwgtlbs;
720aA         endif;
730aD         //if $uiwgtkgs > 0;
730aD           //uciwgt = uciwgt + $uiwgtkgs;
730aD         //endif;
720aA
720aA       endif;
720aM       w7uci = ' ';
720aA   endsl;
720aA /end-free
720aAC     endup7        endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*                     DRI SUBROUTINES
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  clr$item  Clear $item data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

640bA*----------------------------------------------------------------
640bA*  clr$license  Clear $license data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$license   begsr
640bAC                   eval      savever# = $liver#
640bAC                   clear                   $license
640bAC                   eval      $liver# = savever#
640bAC                   eval      $liemp# = 0
640bAC                   eval      $liuser = #curruser
640bAC                   eval      $lipgm  = #pgm
640bAC                   eval      $lijob  = #job
640bAC                   eval      $lijobn = #jobnbr
640bAC                   eval      $liTowhse = $pwhse
640bAC                   eval      $liTowhseu = *on
640bAC                   endsr
640bA
640bA*----------------------------------------------------------------
640bA*  clr$licinfo  Clear $licinfo data structure fields
640bA*----------------------------------------------------------------
640bA
640bAC     clr$licinfo   begsr
640bAC                   eval      savever# = $lnver#
640bAC                   clear                   $licinfo
640bAC                   eval      $lnver# = savever#
640bA
640bAC                   eval      $lnuser = #user
640bAC                   eval      $lnpgm  = #prog
640bAC                   eval      $lnjob  = #job
640bAC                   eval      $lnjobnbr = #jobn
640bA
640bAC                   endsr
640b
600bA*----------------------------------------------------------------
600bA*  clr$slot  Clear $slot data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr

600bA*----------------------------------------------------------------
600bA*  clr$slotdef  Clear $slotdef data structure fields
600bA*----------------------------------------------------------------
600bA
600bAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr

720aA*----------------------------------------------------------------
720aA*  clr$uciinfo  Clear $uciinfo data structure fields
720aA*----------------------------------------------------------------

720aAC     clr$uciinfo   begsr
720aAC                   eval      savever# = $uiver#
720aAC                   clear                   $uciinfo
720aAC                   clear                   $uciinfo2
720aAC                   eval      $uiver# = savever#
720aAC                   eval      $uiaddemp = e$emp#
720aAC                   eval      $uiaddusr = #user
720aAC                   eval      $uiaddpgm  = #prog
720aAC                   eval      $uiaddjob  = #job
720aAC                   eval      $uiaddnbr = #jobn
720aAC                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
600bAC                   when      $dricommand = '*SLOTDEF'
600bAC                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
600bAC                   eval      $dridata2 = $item2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $dridata = $license
640bAC                   eval      $dridata2 = $license2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $dridata = $licinfo
720aAC                   when      $dricommand = '*UCIINFO'
720aAC                   eval      $dridata = $uciinfo
720aAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

600bAC                   if        $dricommand = '*ITEM'
600bAC                             or $dricommand = '*SLOT'
640bAC                             or $dricommand = '*LICENSE'
720aAC                             or $dricommand = '*UCIINFO'
600bAC                   call(e)   'DRICOP'
600bAC                   parm                    $dricommand
600bAC                   parm                    $drisubcmd
600bAC                   parm                    $drisys2upd
600bAC                   parm      #prog         $driprogram
600bAC                   parm      ' '           $drireturn
600bAC                   parm      ' '           $drimessage
600bAC                   parm                    $dridata
600bAC                   parm                    $dridata2
600bAC                   else
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
600bAC                   endif

     C                   select

600bMC                   when      chk4err and %error
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

600bMC                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C                   exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bAC                   eval      $slot2 = $dridata2
600bAC                   when      $dricommand = '*SLOTDEF'
600bAC                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
600bAC                   eval      $item2 = $dridata2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $license = $dridata
640bAC                   eval      $license2 = $dridata2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $licinfo = $dridata
720aAC                   when      $dricommand = '*UCIINFO'
720aAC                   eval      $uciinfo = $dridata
720aAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
600bAC                   eval      chk4err = *off
     C     enddricop     endsr

600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------
600aA*  License Plate Tracking Routines
600aA*----------------------------------------------------------------
600aA*----------------------------------------------------------------

600aA*----------------------------------------------------------------
600aA*  ZZZCLR$LT210  -  Clear LT210 parameters.
600aA*----------------------------------------------------------------
600aA
600aAC     ZZZCLR$LT210  begsr

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
720aAC                   clear                   $ttoslot
720aAC                   clear                   $tpartime
720aAC                   clear                   $tUCI

     C                   endsr

600aA*----------------------------------------------------------------
600aA*  ZZZCALL$LT210  -  Call LT210 program.
600aA*----------------------------------------------------------------
600aA
600aAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'ADJ'         $ttype
     C                   parm      'Adjustment'  $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      e$emp#        $templ#
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
720aAC                   parm                    $ttoslot
720aAC                   parm                    $tpartime
720aAC                   parm                    $tUCI

     C                   endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZCNVWGT  Setup converted weight field.
700bA*
700bAC     zzcnvwgt      begsr
700bA*
700bA*
700bA* If item options is setup as kgs and user enters kgs no conversion
700bA* If item options is setup as kgs and user enters lbs need conversion
700bA* If item options is setup as lbs and user enters lbs no conversion
700bA* If item options is setup as lbs and user enters kgs need conversion
700bA /free
700bA   select;
700bA     when Begkilolbs = 'K';
700bA       if KiloLbs = 'K';
700bA         eval cnvwgt = w1cwtr;
700bA       else;
700bA         eval(h) cnvwgt = w1cwtr / kgs2lbs;
700bA       endif;
700bA     other;
700bA       if KiloLbs = 'K';
700bA         eval(h) cnvwgt = w1cwtr * kgs2lbs;
700bA       else;
700bA         eval cnvwgt = w1cwtr;
700bA       endif;
700bA   endsl;
700bA /end-free

700bAC                   endsr

     *----------------------------------------------------------------
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------
** desc
Slot
Adjustment Type
Catch weight
Item/Slot Dept mismatch
No parent for Alias
Tracking type
** descsp
Slot
Adjustipo de tment
Catch peso
No coincide el dept de ranura de artículo
Sin padre para alias
Tipo de seguimiento
