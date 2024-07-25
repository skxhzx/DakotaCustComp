600 A /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   P.O. Box 1957
     *   Batavia, IL 606510
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT132     Item slot maintenance - Change
     *  08 September, 1994
     *  Hemant Kapadia
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
416a *    02/06/02  RH   4.16a
     *      - Remove User id field, will use #USER.
     *
DRI A*    02/22/02  DAS  4.16
     *      - Total rewrite. Changed to use DRI interface programs.
     *
416bA*    06/11/02  DAS  4.16b
     *      - Recompiled because of change to C#SLOT.
     *
416cA*    06/11/03  DAS  4.16c
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
     *
417 A*    04/05/04  DAS  4.17
     *      - Added $saby to fill$adj routine.
     *
417aA*    04/21/04  DAS  4.17a
     *      - Fix: Revised ZZUOM routine to initialize ind 92 & 93.
     *      - Fix: Revised ZZINZ2 routine to initialize ssbflg
     *
500 A*    03/30/05  DAS  5.00
     *      - Enh: Added logic for license tracking.
     *
500aA*    04/30/05  DAS  5.00a
     *      - Enh: Added $tnorm1/2/3 parms.
     *
500bA*    11/07/05  RH   5.00b
     *      - ENH: Revised ZZCHK1 to allow F20 override for ITEMDEF
     *        and Expiration date < today error.
     *
510 A*    09/07/06  JCJ  5.10
     *      - Enh: Revised program to add support for Client id
510aA*    11/07/06  MLB  5.10a
     *      - Fix: Revised ZZDFT1, ZZFIL1 to initialize W1EXPDC and
     *        W1ENTDC to zeros. Expiration date from was being carried
     *        over and applied to slots that were not date sensitive.
510bA*    01/04/07  MLB  5.10b
     *      - Fix: Revised ZZDFT1 to initialize W1CWTR to zeros.
     *        Catchweight was being carried over to non-catchweight
     *        items.
510cA*    07/13/07  RH   5.10c
     *      - Fix: Revised to send SLPICK for VERIFYCHG, DRISLOT needs
     *        to allow calc pick slots when status changes to 'A'
     *
520 A*    06/16/08  RBD  5.20  I#00026
     *      - Fix: Adjustment type and qty were being blanked out if
     *        user prompted (F4) on Reason Code.  User received a
     *        dec data error when prompting on slot or status.
     *        Screen parms being passed to CW133 were being overlaid
     *        with blanks when calling anything other than CW133.
     *        Fixed by passing hold fields rather than screen fields,
     *        and populating them before calling CW133.
520aA*    06/04/08  RH   5.20a
     *      - Fix: Revised to pass SLPICK if status is changing, will
     *        process the same when status changes using SL110cl
520bA*    10/14/08  RH   5.20b
     *      - Enh: Add call to GETALSW to select alias item to be
     *        adjusted on host.  Will be exported in ITEMADJ &
     *        ITEMADJM.
520cA*    12/22/08  RH   5.20c  (not needed in ver 6.00)
     *      - Fix: Call UPDSLTDTE with *FIX to correct qty in SLOTDTE
     *        is wrong if slot had negative stock before put away.
520dA*    04/24/09  RH   5.20d
     *      - Enh: If qty and catch weight are both entered, both must
     *        the same sign (positive or negative).
     *        Renamed IT132FM to IT13201
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - 500/500a added from Jordano's code.
     *
600aA*    01/20/09  DAS  6.00a
     *      - Recompiled because of changes to C#SLOT.
     *
600bA*    01/11/09  DAS  6.00b
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Changed all #user to #curruser.
     *
600cA*    05/27/09  DAS  6.00c
     *      - Revised to not allow adjustment to RCV slot.
     *
600dA*    06/06/09  DAS  6.00d
     *      - Revised fill$slotchg to initialize license fields.
     *
600eA*    06/15/09  DAS  6.00e
     *      - Implemented 520d changes.
     *      - Removed slot position for now.
     *
610a *    04/28/10  GJA  6.10a      P#00243
     *      - Enh: Change UCI to be option driven.  OPUCI
610b *    05/11/10  GJA  6.10b      P#00243
     *      - Fix: Change UCI position.
530aA*    07/12/10  RH   5.30a
     *      - Fix: Changed to use IT13202.  Fix UOM labels to display.
640aA*    02/14/11  RH   6.40a
     *      - Enh: Changed to use IT13203, to allow for DRYB mod.
640bA*    08/16/11  RH   6.40b
     *      - Enh: Changed to get PO/Seq# using DRILICENSE and
     *      - DRILICINFO.
640cA*    01/19/12  RH   6.40c
     *      - Fix: Increase PO Seq# WOSEQ to 5.0, seq# to large
     *        causing receiver value too small error.f woseq
640dA*    09/10/12  RH   6.40d
     *      - Fix: Tie/hi override was not working only on F20.
     *
650aA*    01/16/13  RH   6.50a
     *      - Fix: Changed to use IT13204, change to W1STAT to use
     *        *IN89 in place of *IN95, already used for W1CWTR
     *
650bA*    05/01/14  RBD  6.50b
     *      - Fix: Rev 610a data structure should be opdata, not opddta.
650cA*    05/27/14  RH   6.50c
     *      - ENH: Change to use IT13205, add W1FIFO to addjust oldesta.
     *        or newest license.  Use cmd ADJSLTREV for LIFO
     *
700 A*    07/15/15  JCJ  7.00
     *      - Fix: Temporary code to exclude non JDE warehouses from
     *        DRYe & DRYf variance checks.
     *
700aA*    05/05/15  LMC  7.00a
     *      - Display file changed to IT13206
700bA*    03/23/16  LMC  7.00b
     *      - Enh: Adding logic for Metric.
     *      - Fix: zzerrind was executing using $sa values that were
     *        not populated, so error indicators were not turning on
     *        correctly. Moved that code to after the $slot/$slot2
     *        values are populated.
710aA*    04/26/17  LMC  7.10a
     *      - Enh: Do not allow adjustment to aisle RTN, Returns are
     *        now put into RTNDOCK verses RCVDOCK.
720aA*    04/18/18  RH   7.20a
     *      - Enh: Change to default to NOT displaying Tie/Hi missing
     *        error.
720bA*    04/26/18  LMC  7.20b
     *      - Enh: Added validation of adjustment code beforer going
     *        to drislot. We now do not allow users to select our BFC
     *        system generated codes.
720cA*    08/03/18  NLK  7.20c
     *      - FIX: Div by zero error, same as partial 700a in IT122
     *
720dA*    08/03/18  LMC  7.20d
     *      - Enh: Added UCI Tracking.
     *      - For UCI Tracked items, this program will no longer all
     *        Inventory adjustments. UCI Tracking requires scanning
     *        UCI's to make adjustments. Fields will Non-Display
730aA*    02/06/19  LMC  7.30a
     *      - Enh: Change display file to IT13209, breakdown 2 uom was
     *        not displaying.
730bA*    09/24/19  LMC  7.30b
     *      - Enh: Do not allow adjustment to aisle RWO.
     *        Receipt with no PO will put product
     *        into RWODOCK verses RCVDOCK.
750aA*    04/26/21  LMC  7.50a
     *      - Enh: We have a client that uses aisl STG, but not for
     *        staging, so our edits fail. We should only edit on RCV,
     *        STG and slots like this if the SLDESG = BFC
     *      - Enh: removed copysrc for id#drycinc,id#dryla,id#drylv
     *        id#drysf.
750bA*    12/06/21  LMC/RH  7.50b
     *      - Fix: Change FILL$ADJ to load expiration date like
     *        Fill$slotchg.
750cA*    01/21/22  LMC/RH  7.50c
     *      - Fix: Change to force date entry, was skipping check when
     *        date was not entered.
770aA*    07/28/23  DAS  7.70a
     *      - Fix: "2 = Replace" was not working because the 600b
     *        change I made. ZZCHK1 used $slstk1 to calculate the adj
     *        qty for the Replace. However, all the $sl fields were
     *        cleared before getting there because of the 660b change
     *        I made to FILL$SLOTCHG.
     *----------------------------------------------------------------
CWa A*  Client Custom Revisions: City Wholesale
CWa A*    12/05/07  RH   CWa
     *      - Disable tie hi check.
     *----------------------------------------------------------------
JSLa *  Client Custom Revisions: Julius Silvert
     *    07/22/15  GJA  JSLa
     *      - Disable tie hi check.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRYaA*    01/21/11  RH   DRYa
     *      - Enh: Bypass  NO TIE HI.
DRYbA*    02/14/11  RH   DRYb
     *      - Enh: Add screen1C to display host qty and host wt.
DRYcA*    02/18/11  RH   DRYc
     *      - Enh: Do not allow adjustment type 2=replace.
DRYdA*    02/25/11  MLB  DRYd
     *      - Enh: Revised program to always display catchwgt entry
     *        field for catchwgt and non-catchwgt items.
     *      - Removed test for zero catchwgt entered.
DRYeA*    12/19/13  RBD  DRYe
     *      - Enh: Added catchweight variance check, hard halt if error.
DRYfA*    06/10/14  RBD  DRYf
     *      - Enh: Only do catchweight variance check if a qty is also
     *        entered. Sometimes they will enter a c/w adjustment with
     *        no qty to adjust the c/w on the host. In that case, DRYe
     *        was causing a divide by zero error.
DRYgA*    07/18/18  MLB  DRYg
     *      - Enh: Revised pgm to remove Bronx and Hanover additional
     *        edit checks. Branches are now on JDE. Ref 7.00a.
DRYhA*    08/25/18  MLB  DRYh
     *      - Enh: Revised pgm to remove whse 040 Cincinnati edit checks.
     *        Branch is now on JDE. Ref 7.00a.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
EGFaA*    01/11/10  RH   EGFa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
EIa A*    08/16/11  RH   EIa  #P1050
     *      - Enh: Call DRILICENSE to get slot license, write
     *        Lot code (PO/SEQ) from original license to IAMEMO.
EIb A*    08/16/11  RH   EIb
     *      - Enh: Bypass  NO TIE HI.
EIc A*    01/19/12  RH   EIc
     *      - Fix: Change to write last 3 digits of PO/SEQ to IAMEMO
     *        WOSEQ increased with mod 640b.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
GLPaA*    05/08/13  RH   GLPa
     *      - Enh: Bypass  NO TIE HI.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh
GFSaA*    03/03/13  RH   GFSa
     *      - Enh: Bypass  NO TIE HI.
     *----------------------------------------------------------------
     *  Client Custom Revisions: H&M Wagner
HMWaA*    10/18/14  RH   HMWa
     *      - Enh: Do not allow adjustment type 2=replace.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYaA*    10/20/09  RH   HSYa
     *      - Enh: Do not allow adjustment type 2=replace.
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
HKWaA*    01/16/13  RH   HKWa
     *      - Enh: Bypass  NO TIE HI.
HKWbA*    01/30/13  RH   HKWb
     *      - Enh: Bypass catch weight entry check
     *
     *----------------------------------------------------------------
ICBaA*  Client Custom Revisions: Inter Country Bakers
ICBaA*    03/05/12  RH   ICBa
     *      - Disable tie hi check.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: MJ Kellner
     *
MJKaA*    10/16/08  RH   MJKa
     *      - Enh: Must enter alias item for base, write to ITEMADJM
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
     *
PCK A*    09/07/06  JCJ  PCK
     *      - Enh: Add call to UCI Maintenance for Catch Weight items
PCK b*    10/02/06  RAH  PCK
     *      - Enh: Change call from UI110 to CW133.  Pass addtl parms.
PCK c*    10/06/06  JCJ  PCK
     *      - Enh: Do not perform catch weight edit if packers
PCKdA*    10/17/06  JCJ  PCKd
     *      - Enh: Added disposition code to CW133 parm list.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi Brothers
     *
RNZaA*    07/23/08  RH   RNZa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foodservice
     *
SVLaA*    08/12/09  RH   SVLa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S. Bertram
     *
SBRaA*    01/08/16  RH   SBRa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
GMM A*    08/29/12  MLB  GMM
     *      - Enh: Bypass  NO TIE HI.
     *      - Added GMM to SVLa mod.
GMMaA*    08/30/12  RH   GMMa
     *      - Enh: Do not allow adjustment type 2=replace.
     *      - Added GMM to DRYc mod.
     *----------------------------------------------------------------
     *  Client Custom Revisions: West Side Foods
     *
WST1A*    08/12/99  DAS  WST1 (temp change for West Side)
     *      - Setting on ind 95 whne status code is 'TI'.  This will
     *        protect the field from being changed.
WSa A*    06/25/03  RH   WSa  (NOT APPLIED in UPDATE)
     *      - Reverse 416a, put user id field back on screen.
WSb A*    07/11/05  RH   WSb
     *      - Default W1TYPE to '1' do not allow to be changed.
     *        Change to SELECT statement.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WILaA*    09/22/14  RH   WILa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
YHAaA*  Client Custom Revisions: YHata
YHAaA*    12/06/07  RH   YHAa
     *      - Disable tie hi check.
YHAbA*    12/20/07  RH   YHAb
     *      - Do not allow entry of MV code.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
     *
BIR A*    02/27/13  MLB  BIR
     *      - Enh: Revise pgm to read/write SCREEN1B. Screen revised
     *        to add | marker under Memo fld for where to key p/o nbr.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
CWD A*    04/23/13  MLB  CWD
     *      - Disable tie hi check. Per Hemant skype msg 04/23/13.
     *      - Added CWD to CTW mod.
     *
     *----------------------------------------------------------------
CBIaA*  Client Custom Revisions: Cheney Brothers
CBIaA*    06/24/16  RH   CBIa
     *      - Disable tie hi check.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
FGLaA*    06/27/16  RH   FGLa
     *      - Enh: Bypass  NO TIE HI.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
KHLaA*    08/20/14  LMC  KHLa
     *      - Enh: Bypass  NO TIE HI.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
FFCaA*    12/02/14  RH   FFCa
     *      - Enh: Bypass  NO TIE HI.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPR A*    03/26/15  RH   FPR
     *      - Enh: Bypass  NO TIE HI.
FPRaA*    05/05/15  LMC  FPRa
     *      - Enh: Protect normal uom qty when normal UOM = MP.
FPRbA*    07/07/16  RH   FPRb
     *      - Enh: Do not allow adjustment codes 14,41,HY,HN.
     *----------------------------------------------------------------
JDOaA*  Client Custom Revisions: Jordanos
JDOaA*    08/08/16  RH   JDOa
     *      - Enh: Position cursor to quantity field.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy
FBYa *    11/02/16  RTR  FBYa
     *      - Disable tie hi check.
     *----------------------------------------------------------------
    A*  Client Custom Revisions: Royal
RYLaA*    03/08/17  RH   RYLa
     *      - Disable tie hi check.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    03/03/21 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
     *----------------------------------------------------------------
    A*  Client Custom Revisions: Merit
MRTaA*    09/10/18  RH   MRTa
     *      - Enh: Bypass catch weight entry check
     *----------------------------------------------------------------
     *  Indicator usage                                              2
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520dDF*t132fm   cf   e             workstn
530aD *it13201   cf   e             workstn
640aDF*t13202   cf   e             workstn
650aDF*t13203   cf   e             workstn
650cDF*t13204   cf   e             workstn
700aDF*it13205   cf   e             workstn
700bDF*it13206   cf   e             workstn
720dDF*it13207   cf   e             workstn
730aDF*it13208   cf   e             workstn
730aMFit13209   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fslotstat  if   e           k disk
     Funmesr    if   e           k disk
216 AFitemdef   if   e           k disk
520bAFitemlnk1  if   e           k disk
520bAFitemadjm  o    e             disk
520bAFpiritem   if   e           k disk
520cDF*****slot2     if   e           k disk
610aAFoptions   if   e           k disk
DRYeAFitemmsc   if   e           k disk

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

413 AD a3              s              1    dim(3)
     D a10             s              1    dim(10)
520bDD*desc            s             50    dim(6) ctdata perrcd(1)
520bMD*desc            s             50    dim(7) ctdata perrcd(1)
YHAbDD*desc            s             50    dim(8) ctdata perrcd(1)
650cMD desc            s             50    dim(9) ctdata perrcd(1)
700bAD cmdln           s             79    dim(4)ctdata perrcd(1)

700bA*----------------------------------------------------------------
700bA* Function prototypes.
700bA*----------------------------------------------------------------

700bA /copy qcopysrc,p.getimuom

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
640bA /COPY *libl/qcopysrc,C#LICENSE
640bA /COPY *libl/qcopysrc,C#LICINFO

510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*----------------------------------------------------------------

CWa A /copy qcopysrc,id#citywho
510 A /copy qcopysrc,id#packers
520 A /copy qcopysrc,id#mjkelln
520 A /copy qcopysrc,id#renzi
520aA /copy qcopysrc,id#yhata
610 A /copy qcopysrc,id#saval
HSYaA /copy qcopysrC,id#halsey
530aA /copy qcopysrC,id#egf
DRYaA /copy qcopysrC,id#dairyla
700 A /copy qcopysrC,id#drybron
700 A /copy qcopysrC,id#drycol
700 A /copy qcopysrC,id#dryhano
700 A /copy qcopysrC,id#drymia
700 A /copy qcopysrC,id#dryport
700 A /copy qcopysrC,id#dryqchi
700 A /copy qcopysrC,id#dryqnj
700 A /copy qcopysrC,id#dryqsf
EIa A /copy qcopysrc,id#ei
ICBaA /copy qcopysrC,id#icb
GMM A /copy qcopysrC,id#gmm
WSb A /copy qcopysrC,id#westsid
HKWaA /copy qcopysrC,id#hkw
BIR A /copy qcopysrC,id#birite
GFSaA /copy qcopysrC,id#gfs
GLPaA /copy qcopysrC,id#glp
KHLaA /copy qcopysrC,id#khl
CWD A /copy qcopysrC,id#cashwa
HMW A /copy qcopysrC,id#hmwagne
CBIaA /copy qcopysrC,id#cheney
FFCaA /copy qcopysrC,id#fischer
WILaA /copy qcopysrC,id#wil
JSLaA /copy qcopysrC,id#jsl
SBRaA /copy qcopysrC,id#sbr
FGLaA /copy qcopysrC,id#fgl
FPRaA /copy qcopysrC,id#fpr
JDOaA /copy qcopysrC,id#jordano
FBYaA /copy qcopysrc,id#fby
RYLaA /copy qcopysrC,id#royal
PFCaA /copy qcopysrc,id#pfc
MRTaA /copy qcopysrC,id#mrt

     D savever#        s                   like($slver#)
     D saveaisl        s                   like($slaisl)
     D saveloc         s                   like($slloc)
     D saverlvl        s                   like($slrlvl)
     D savehand        s                   like($slhand)
510d D savepick        s                   like($slpick)
770aAD save$slot       s                   like($slot)
770aAD save$slot2      s                   like($slot2)
600bDD*slotds        e ds                  extname(slot)

500 A*----------------------------------------------------------------
500 A*  LT210 parameters
500 A*----------------------------------------------------------------

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
500aAD  $tnorm1        s              5  0
500aAD  $tnorm2        s              3  0
500aAD  $tnorm3        s              3  0
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

PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
PFCaAd aptsk1          c                   '*RETURN   '
PFCaAd logapt          s               n   inz(*on)
PFCaA
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

520b D $awhse          s                   like($pwhse)
520b D $aitem          s                   like($pitem)
520b D $asitm          s                   like($pitem)
520b D $artn           s                   like($prtn)
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
     D adjflg          s               n
DRYeAD caltol          s             13  4
     D chgqt1          s                   like($saqty1)
     D chgqt2          s                   like($saqty2)
     D chgqt3          s                   like($saqty3)
600bAD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
700bAD CnvWgt          s              9  2
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
DRYeAD errng           s              3  1
     D error           s               n
DRYeAD exwgt           s              9  2
DRYeAD exwgt1          s              9  2
DRYeAD exwgt2          s              9  2
DRYeAD exwgt3          s              9  2
520b D forevr          s              1
     D help            s              5  0
DRYeAD hirng           s              9  2
DRYeAD hivar           s              9  2
700bAD kgs2lbs         c                   2.20462262
700bAD KiloLbs         s              1
700bAD IMkilolbs       s              1
700bAD IMUom           s              3
DRYeAD lwrng           s              9  2
DRYeAD lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
     D ovrrid          s              1
DRYeAD prg1c           s              4  3
DRYeAD prg2c           s              4  3
     D rolldn          s              5  0
     D rollup          s              5  0
     D savav1          s                   like($slavl1)
     D savav2          s                   like($slavl2)
     D savav3          s                   like($slavl3)
     D savst           s                   like($slstat)
     D savew1disp      s                   like(w1disp)
     D savew1entd      s                   like(w1entd)
     D savew1expd      s                   like(w1expd)
     D savew1prty      s                   like(w1prty)
     D savew1stat      s                   like(w1stat)
     D sclear          s              1
     D ssbflg          s               n
520b D svalis          s                   like($pitem)
     D usesc           s              1  0
     D warn            s               n
DRYeAD wgtDiff         s             11  4
     D whse            s              3  0
640bAD wocode          s             10
640bAD worpo           s              9
640cDD*woseq           s              3  0
640cMD woseq           s              5  0
     D w1entdc         s              8  0
     D w1expdc         s              8  0
500b D dtchk           s              1
500b D dfchk           s              1
500b D expd            s              8  0
500b D today           s              8  0
     D w1qty1          s                   like($cqty1)
     D w1qty2          s                   like($cqty2)
     D w1qty3          s                   like($cqty3)
     D zmsflag         s               n
510 AD client          s             10
700 AD cliloc          s             10
720bAD $vcode          s                   like(w1code)
720bAD $vsys           s              1
DRYbA*
DRYbAD                 ds
DRYbAD  $hwhse                 1      3  0 inz(0)
DRYbAD  $hqty                  4     11  2 inz(0)
DRYbAD  $hwt                  12     19  2 inz(0)
DRYbAD  $hitem                20     44    inz(' ')

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
     D  $pitem                39     53
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
     D @fmtwh          c                   const('FRMTWH')
     D @fmtit          c                   const('FRMTIT')
pckbDD*@cwght          c                   const('UI110')
pckbMD @cwght          c                   const('CW133')
DRYbAD @hwhsr          c                   const('BFCWHS01R')
520bAD @gtals          c                   const('GETALSW')
520cDD***** @sltdt          c                   const('UPDSLTDTE')
520cDD***** @tlsdt          c                   const('TOTSLTDTE')
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
     *
PCKbAD  $lwhseu               19     21  0
PCKbAD  $litemu               22     36
PCKbAD  $lcodeu               37     38
PCKbA** w1type                39     39       ** 520 D
PCKbA** w1qt01                40     44  0    ** 520 D
PCKbA** w1qt02                45     47  0    ** 520 D
PCKbA** w1qt03                48     50  0    ** 520 D
PCKbA** w1cwtr                51     59  2    ** 520 D
520 MD  $l_w1type             39     39
520 MD  $l_w1qt01             40     44  0
520 MD  $l_w1qt02             45     47  0
520 MD  $l_w1qt03             48     50  0
520 MD  $l_w1cwtr             51     59  2
PCKbAD  $ldate                60     64p 0
PCKbAD  $ltime                65     68p 0
     *
     D  $lstat                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lst                  59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
216 AD  $lwhs                 19     21  0
216 AD  $lwhd                 22     26
216 AD  $ldis                 27     38
216 AD  $litm                 39     53
     *
213 AD  $luser                19     28
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
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  eritem                 1     15
     *
     D  erdisp                16     27
     *
     D  ersdpt                28     32
     D  erstyp                33     33
     D  ersdsg                34     38
     *
     D  eridpt                39     43
     D  erityp                44     44
     D  eridsg                45     49
     *
     D  erslot                 1     12
     D  erstat                13     42
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
600bA /Copy qcopysrc,c#pgminfds
600bDD**              sds
600bDD**#prog            *proc
600bDD**#status               11     15
600bDD**#stmt                 21     28  0
600bDD**#pgmmsg               91    170
600bDD**#job                 244    253
600bDD**#user                254    263
600bDD**#jobn                264    269
600bDD**#jobdt               276    281  0
600bDD**#jobtm               282    287  0
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
610aA*----------------------------------------------------------------
610aA*  *SYSTEM  -  System options.
610aA*----------------------------------------------------------------
610aA*
610aA* Fields
610aA*
DRYeA*    OPRG1C  -  Catch weight low variance percentage.
DRYeA*    OPRG2C  -  Catch weight high variance percentage.
610aA*    OPUCI   -  Use UCI processing (Y,N)
610aA*
610aA* Data structure
610aA*
650bDD*opddta          ds
650bMD opdata          ds
DRYeAD  oprg1c                 6      8  1
DRYeAD  oprg2c                 9     11  1
610bDD**opuci                 33     33
610bMD  opuci                 36     36
610aAD  optendj              117    117
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
BIR AC                   select
BIR AC                   when      client = birite
BIR AC                   exfmt     screen1B                             50
DRYbMC                   when      client = dairyland
DRYb C                   exfmt     screen1C                             50
BIR MC                   other
     C                   exfmt     screen1                              50
BIR MC                   endsl
 1E  C                   endif
     *
 1B  C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
 1E  C                   endif
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
     C                   move      '01 '         nxtscr
     *
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
 1E  C                   endif
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
 1E  C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     *
 1B  C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
 1E  C                   endif
     *
     *  Get field defaults if this is an add.
     *
 1B  C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
 1X  C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
 1E  C                   endif
     C                   eval      ovrrid = *off
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
700bA*     Setup converted weight field.
700bAC                   exsr      zzcnvwgt
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
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
     C                   exsr      scr02i
 2E  C                   endif
goto Csr                 goto      endsc2
 1E  C                   endif
     *
     *  Test for F12 - Previous
     *
 1B  C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
goto Csr                 goto      endsc2
 1E  C                   endif
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
 1B  C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc2
 1E  C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
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
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client
700 AC                   parm                    cliloc
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
 1B  C                   if        msgk > 0
     C                   write     msgctl
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
     C                   eval      $msgf = #msgf
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
     C                   write     msgrec
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
     C                   eval      $pdisp = w1disp
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
 1B  C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
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
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0109  Number can not be negative.
     *
     C     zm0109        begsr
     C                   move      'PIR0109'     #msgid
     C                   move      '*DIAG  '     #msgtp
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
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   move      'PIR0112'     #msgid
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
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   move      'PIR1008'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
500b *----------------------------------------------------------------
500b *    PIR1009  Date must be > today's date.
500b *
500b C     zm1009        begsr
500b C                   move      'PIR1009'     #msgid
500b C                   move      '*DIAG  '     #msgtp
500b C                   movea     errmsg        $md
500b C                   exsr      zmpmsg
500b C                   endsr
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
     *     ZM02  Slot cannot be verified or zero.
     *
     C     zm02          begsr
     C                   move      'IT13202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM03  Slot must be a verified slot.
     *
     C     zm03          begsr
     C                   move      'IT13203'     #msgid
     C                   move      '*DIAG  '     #msgtp
600bMC                   eval      erslot = $sldisp
     C                   eval      erstat = ssdesc
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM04     Slot record does not exist.
     *
     C     zm04          begsr
     C                   move      'IT13204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      erdisp = w1disp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM07  Warning - No record exists in Tie/High def. file.
     *
     C     zm07          begsr
     C                   move      'IT13207'     #msgid
     C                   move      '*DIAG  '     #msgtp
600bMC                   eval      erdisp = $sldisp
600bMC                   eval      eritem = $slitem
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
     *     ZM15  Slot does not contian item.
     *
     C     zm15          begsr
     C                   move      'IT12215'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     ZM16  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   move      'IT12216'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM17  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   move      'IT12217'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM21  Invalid item type entered.
     *
     C     zm21          begsr
     C                   move      'IT11021'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM71  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM72  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM73  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   move      'IT12273'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     ZM74  Adjustment not completed - Record locked.
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
     *
     C     zzchk1        begsr
500b C*
500b C*   DTCHK, DFCHK Flags are used to force F20 for each test
500b C*   Values: Flag = 0 Do check.
500b C*           Flag = 1 Check was done, ok.
500b C*           Flag = 2 Warning condition.
500b C*
     C                   eval      error = *off

     *  Verify record exists in itemdef (tie/high) file.
     *  If no record is found, display warning message.

500b C                   if        dfchk  = '0' and
500b C                             ovrrid = *on
500b C                   eval      ovrrid = *off
500b C                   endif
500b C
500b C                   if        dfchk  = '2' and
500b C                             ovrrid = *on
500b C                   eval      dfchk  = '1'
500b C                   endif
500b C
500b C*                  if        ovrrid = *off
640dDC*                  if        dfchk = '0'
640dMC                   if        dfchk <> '1'
640dAC                   eval      dfchk = '1'
     C     idkey         chain     itemdef                            79
720aAC*    Default to NOT checking for Tie/Hi value
720aMC                   if        client = *blanks
RNZacC**                 if        client <> renzi and
YHAa C**                           client <> yhata and
HSYa C**                           client <> halsey and
CWa AC**                           client <> citywh and
EGFa C**                           client <> egf and
DRYa C**                           client <> dairyland and
EIb  C**                           client <> ei and
ICBaAC**                           client <> icb and
CBIaAC**                           client <> cheney and
HKWa C**                           client <> hkw and
GFSa C**                           client <> getfresh and
GLPa C**                           client <> grnlef and
KHLa C**                           client <> kohl   and
FFCa C**                           client <> fischr and
CWD AC**                           client <> Cashwa and
WIL AC**                           client <> Willfoods and
FGLaAC**                           client <> foodsgalore and
SBRaAC**                           client <> sbertram and
GMM AC**                           client <> menumaker and
RYLa C**                           client <> royal and
SVLa C**                           client <> saval and
FBYa C**                           client <> farmboy and
JSLa C**                           client <> jsilvert
 2B  C                   if        *in79
     C                   eval      error = *on
500b C                   eval      dfchk = '2'
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm07
     C                   goto      endck1
 2E  C                   endif
 720aC                   endif
 1E  C                   endif

     *  Verify adjustment type.

WSb AC                   select
HSYa C                   when      client = halsey
WSa  C                             or client = westside
GMMa C                             or client = menumaker
HMWa C                             or client = hmwagner
HSYa C                   if        w1type <> '1'
WSb DC**                 if        client = halsey and
WSb DC**                           w1type <> '1'
HSYa C                   eval      error = *on
HSYa C                   eval      *in21 = *on
HSYa C                   eval      *in01 = *on
HSYa C                   eval      errmsg = desc(2)
HSYa C                   exsr      zm1001
WSb DC**                 else
HSYaAC                   endif
WSb  C                   other
 1B  C                   if        w1type <> '1'  and
     C                             w1type <> '2'
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = desc(4)
     C                   exsr      zm1001
     C                   goto      endck1
 1E  C                   endif
WSb DC**                 endif
WSb  C                   endsl
650c
650c *  Verify FIFO or LIFO method.
650c
650c C                   if        w1fifo <> 'Y'  and
650c C                             w1fifo <> 'N'
650c C                   move      *on           error
650c C                   eval      *in34 = *on
650c C                   eval      *in14 = *on
650c C                   eval      errmsg = desc(9)
650c C                   exsr      zm1001
650c C                   goto      endck1
650c C                   endif

     *  If none of the standard fields changed, skip checks.
750c *  so not skip if date sensitive and date is 0.

     C                   if        w1disp = savew1disp and
     C                             w1stat = savew1stat and
     C                             w1prty = savew1prty and
     C                             w1expd = savew1expd and
750cMC                             w1entd = savew1entd and
750cAC                             (*in96 = *off and
750cAC                             w1expd <> 0)
     C                   goto      skipfldchk
     C                   endif

     *   Verify slot for *ADD

     C                   if        $pcmd = '*ADD'

600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = w1disp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
 1B  C                   if        error
goto C                   goto      endck1
     C                   else
     C                   eval      saveaisl = $slaisl
     C                   eval      saveloc  = $slloc
     C                   eval      saverlvl = $slrlvl
     C                   eval      savehand = $slhand
 1E  C                   endif

 1E  C                   endif

     *  Verify expired date (optional)

 1B  C                   if        not *in96

 2B  C                   if        w1expd = 0
     C                   eval      error = *on
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm1008
     C                   goto      endck1
 2E  C                   endif

     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
 4B  C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
 4X  C                   else
     C                   eval      w1expd = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1expd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expdc = $cvd8o
500b C                   eval      expd = $cvd8o
 4X  C                   endif

500b C                   if        dtchk  = '0' and
500b C                             ovrrid = *on
500b C                   eval      ovrrid = *off
500b C                   endif
500b C
500b C                   if        dtchk  = '2' and
500b C                             ovrrid = *on
500b C                   eval      dtchk  = '1'
500b C                   endif
500b C
500b C                   if        dtchk = '0'
500b C                   if        expd < today
500b C                   eval      error = *on
500b C                   eval      dtchk = '2'
500b C                   eval      *in27 = *on
500b C                   eval      *in07 = *on
500b C                   eval      warn = *on
500b C                   eval      errmsg = *blanks
500b C                   exsr      zm1009
500b C                   goto      endck1
500b C                   endif
500b C                   endif

 4X  C                   endif

     *  Verify entered date

     C                   eval      $cvcmd = '*MDYEDT '
     C                   move      w1entd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
 2B  C                   if        $cvrtn = '*PGMQ   '
     C                   move      '1'           error
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      #msgk = $cvmsg
     C                   exsr      zmqmsg
     C                   goto      endck1
 2X  C                   else
     C                   eval      w1entd = $cvd6o
     C                   eval      $cvcmd = '*MDYCMD '
     C                   move      w1entd        $cvd6i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entdc = $cvd8o
 1E  C                   endif
770aA
770aA*  Save slot info
770aA
770aA        save$slot  = $slot;
770aA        save$slot2 = $slot2;

     *  Verify changes to slot fields.

 1X  C                   if        $pcmd = '*ADD    '
     C                   exsr      fill$slotadd
     C                   else
     C                   exsr      fill$slotchg
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFYCHG'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   if        error
     C                   goto      endck1
     C                   endif
770aA
770aA*  Restore slot info
770aA
770aA        $slot  = save$slot;
770aA        $slot2 = save$slot2;

     *  Get status description.

     C                   if        savew1stat <> w1stat
     C     $slstat       chain     slotstat                           79
 2B  C                   if        *in79
     C                   eval      ssdesc = *blanks
 2E  C                   endif
 2E  C                   endif

     *  Status cannot be changed to 'V' or 'Z'

     C                   if        savew1stat <> w1stat
 1B  C                   if        w1stat = 'V '  or
     C                             w1stat = 'Z '  or
     C                             w1stat = '  '
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in12 = *on
     C                   exsr      zm02
     C                   goto      endck1
 1E  C                   endif
 2E  C                   endif

     *  Quantity adjustment checks ...

     C     skipfldchk    tag

     *  See if user is making an adjustment

 1B  C                   if        w1type = '2'  or
     C                             w1qt01 <> 0  or
     C                             w1qt02 <> 0  or
     C                             w1qt03 <> 0  or
     C                             w1cwtr <> 0
     C                   eval      adjflg = *on
 1X  C                   else
     C                   eval      adjflg = *off
 1E  C                   endif

     *  If not adjusting quantities skip the rest of the checks.

     C     adjflg        cabeq     *off          endck1
600cA
600cA*  Not allowed to adjust an RCV/STG slot.
600cA
750aAC                   if        $sldesg = 'BFC'and (
750aDC*                  if        %subst($sldisp:1:3) = 'RCV'
750aMC                             %subst($sldisp:1:3) = 'RCV'
600cAC                             or %subst($sldisp:1:3) = 'STG'
710aAC                             or %subst($sldisp:1:3) = 'RTN'
750aDC*                            or %subst($sldisp:1:3) = 'RWO'
750aMC                             or %subst($sldisp:1:3) = 'RWO' )
600cAC                   move      *on           error
600cAC                   eval      *in23 = *on
600cAC                   eval      *in03 = *on
710aDC*                  eval      errmsg = 'RCV/STG slot not allowed '
710aDC*                                   + '- use Putaway'
710aMC                   eval      errmsg = 'RCV/STG/RTN slot not '
710aMC                                    + 'allowed - use Putaway'
600cAC                   exsr      zm0105
600cAC                   goto      endck1
600cAC                   endif

     *   Can not replace if quantity is pending.

 1B  C                   if        w1type = '2'
600bMC                   if        $slalc1 <> 0  or
600bMC                             $slalc2 <> 0  or
600bMC                             $slalc3 <> 0  or
600bMC                             $sltfr1 <> 0  or
600bMC                             $sltfr2 <> 0  or
600bMC                             $sltfr3 <> 0  or
600bMC                             $slpck1 <> 0  or
600bMC                             $slpck2 <> 0  or
600bMC                             $slpck3 <> 0  or
600bMC                             $slrcv1 <> 0  or
600bMC                             $slrcv2 <> 0  or
600bMC                             $slrcv3 <> 0
     C                   move      *on           error
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   exsr      zm10
     C                   goto      endck1
 2E  C                   endif
 1E  C                   endif

     *   Verify catchweight.  4.13 - Only when adjusting

PCK cC                   if        client <> packers
DRYdAC                             and client <> Dairyland
MRTaAC                             and client <> merit
HKWbAC                             and client <> hkw
 1B  C                   if        adjflg = *on
 2B  C                   if        not *in95  and
     C                             w1cwtr = 0
     C                   eval      error = *on
     C                   eval      *in33 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(6)
     C                   exsr      zm0110
     C                   goto      endck1
 2E  C                   endif
 1E  C                   endif
PCK cC                   endif

     *   Set working quantities.

 1B  C                   if        usesc = 1
     C                   eval      w1qty1 = w1qt01
     C                   eval      w1qty2 = w1qt02
     C                   eval      w1qty3 = w1qt03
 1E  C                   endif

     *     Convert string to quantities.

 1B  C                   if        usesc = 2  and
     C                             w2qty <> *blanks
     C                   eval      $ccmd = '*STR2QTY'
     C                   eval      $cprg = #prog
     C                   move      w2qty         $cqstr
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
 2B  C                   if        $crtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      #msgk = $cmsg
     C                   exsr      zmqmsg
 2E  C                   endif
     C                   z-add     $cqty1        w1qty1
     C                   z-add     $cqty2        w1qty2
     C                   z-add     $cqty3        w1qty3
 2E  C                   endif
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
520d C                   eval      *in24 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck1
520d C                   endif
520d
520d C                   when      w1qty1 > 0  or
520d C                             w1qty2 > 0  or
520d C                             w1qty3 > 0
520d C                   if        w1cwtr < 0
520d C                   move      *on           error
520d C                   eval      *in33 = *on
520d C                   if        w1qty1 <> 0
520d C                   eval      *in24 = *on
520d C                   endif
520d C                   if        w1qty2 <> 0
520d C                   eval      *in29 = *on
520d C                   endif
520d C                   if        w1qty3 <> 0
520d C                   eval      *in30 = *on
520d C                   endif
520d C                   exsr      zm11
520d C                   goto      endck1
520d C                   endif

520d C                   endsl
DRYeA
DRYeA*   Verify catchweight variances for specific client/s
DRYeA
DRYeAC                   select
DRYeA
DRYeAC                   when      client = Dairyland
DRYgDC*                            and cliloc <> drybronx
DRYhDC*                            and cliloc <> drycincy
700aAC                             and cliloc <> drysanfran
DRYgDC*                            and cliloc <> dryhanover
700aAC                             and cliloc <> drylosangeles
700aAC                             and cliloc <> drylv
DRYeAC                             and $itcwgt = 'Y'
DRYfAC                             and ((w1qt01 + w1qt02 + w1qt03) <> 0)
DRYeAC                   eval      exwgt  = 0
DRYeAC                   eval      exwgt1 = 0
DRYeAC                   eval      exwgt2 = 0
DRYeAC                   eval      exwgt3 = 0
DRYeA
DRYeAC                   if        w1qt01 <> 0
DRYeAC                   eval      exwgt1 = w1qt01 * $itswgt
DRYeAC                   endif
DRYeA
DRYeAC                   if        w1qt02 <> 0
DRYeAC                   eval      exwgt2 = ($itswgt/$itumq2) * (w1qt02)
DRYeAC                   endif
DRYeA
DRYeAC                   if        w1qt03 <> 0
DRYeAC                   eval      exwgt3 = $itswgt/$itumq2
DRYeAC                   eval      exwgt3 = (exwgt3/$itumq3) * (w1qt03)
DRYeAC                   endif
DRYeA
DRYeAC                   eval      exwgt  = exwgt1 + exwgt2 + exwgt3
DRYeA
DRYeAC                   eval      prg1c = 0
DRYeAC                   eval      prg2c = 0
DRYeAC                   eval      lwrng = 0
DRYeAC                   eval      hirng = 0
DRYeA
DRYeA*    Use item variance % if it exists
DRYeAC     keyil1        chain     itemmsc
DRYeAC                   if        %found(itemmsc)
DRYeAC                   if        imrg1c <> 0
DRYeAC     imrg1c        div       100           prg1c
DRYeAC                   endif
DRYeAC                   if        imrg2c <> 0
DRYeAC     imrg2c        div       100           prg2c
DRYeAC                   endif
DRYeAC                   endif
DRYeA
DRYeA*    Use system variance % if item variance % is zero
DRYeAC                   if        prg1c = 0
DRYeAC     oprg1c        div       100           prg1c
DRYeAC                   endif
DRYeAC                   if        prg2c = 0
DRYeAC     oprg2c        div       100           prg2c
DRYeAC                   endif
DRYeA
DRYeAC                   if        prg1c > 0
DRYeAC     exwgt         mult      prg1c         lwvar
DRYeAC                   eval      lwrng = exwgt - lwvar
DRYeAC                   endif
DRYeAC                   if        prg2c > 0
DRYeAC     exwgt         mult      prg2c         hivar
DRYeAC                   eval      hirng = exwgt + hivar
DRYeAC                   endif
DRYeA*
700bDC*                  if        %abs(w1cwtr) <= %abs(lwrng)
700bMC                   if        %abs(cnvwgt) <= %abs(lwrng)
DRYeAC                   eval      error = *on
DRYeAC                   eval      *in33 = *on
DRYeAC                   eval      errmsg = *blanks
DRYeAC                   eval      errng = prg1c * 100
700bDC*                  eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
700bMC                   eval      wgtDiff = %abs(exwgt) - %abs(cnvwgt)
720cAc                   if        %abs(exwgt) <> 0
DRYeAC                   eval      caltol = wgtDiff / %abs(exwgt)
720cAc                   endif
DRYeAC                   eval      caltol = caltol * 100
DRYeA* If wgt entered and low range are equal, force calc tolerance to
DRYeA* be the same value as low tolerance, otherwise, sometimes you will
DRYeA* end up with something like "Wgt tol% 29.99 >= 30.0'.
700bDC*                  if        w1cwtr = lwrng
700bMC                   if        cnvwgt = lwrng
DRYeAC                   eval      caltol = errng
DRYeAC                   endif
DRYeAC                   eval      errmsg = 'Wgt tol% '
DRYeAC                                      + %triml(%editc(caltol:'3'))
DRYeAC                                      + ' >= var% '
DRYeAC                                      + %triml(%editc(errng:'3'))
DRYeAC                   exsr      zm0105
DRYeAC                   goto      endck1
DRYeAC                   endif
DRYeA
700bDC*                  if        %abs(w1cwtr) >= %abs(hirng)
700bMC                   if        %abs(cnvwgt) >= %abs(hirng)
DRYeAC                   eval      error = *on
DRYeAC                   eval      *in33 = *on
DRYeAC                   eval      errmsg = *blanks
DRYeAC                   eval      errng = prg2c * 100
700bDC*                  eval      wgtDiff = %abs(exwgt) - %abs(w1cwtr)
700bMC                   eval      wgtDiff = %abs(exwgt) - %abs(cnvwgt)
720cAc                   if        %abs(exwgt) <> 0
DRYeAC                   eval      caltol = wgtDiff / %abs(exwgt)
720cAc                   endif
DRYeAC                   eval      caltol = caltol * 100
DRYeA* If wgt entered and high range are equal, force calc tolerance to
DRYeA* be the same value as high tolerance, otherwise, sometimes you will
DRYeA* end up with something like "Wgt tol% 29.99 >= 30.0'.
700bDC*                  if        w1cwtr = hirng
700bMC                   if        cnvwgt = hirng
DRYeAC                   eval      caltol = errng
DRYeAC                   endif
DRYeAC                   eval      errmsg = 'Wgt tol% '
DRYeAC                                      + %triml(%editc(caltol:'3'))
DRYeAC                                      + ' >= var% '
DRYeAC                                      + %triml(%editc(errng:'3'))
DRYeAC                   exsr      zm0105
DRYeAC                   goto      endck1
DRYeAC                   endif
DRYeA
DRYeAC                   endsl

     *  Calculate change quantities.

 1B  C                   select

     *     Increasing/Decreasing quantity.

 1X  C                   when      w1type = '1'
     C                   eval      chgqt1 = w1qty1
     C                   eval      chgqt2 = w1qty2
     C                   eval      chgqt3 = w1qty3

     *     Replacing quantity.

 1X  C                   other
     C                   eval      chgqt1 = w1qty1 - $slstk1
     C                   eval      chgqt2 = w1qty2 - $slstk2
     C                   eval      chgqt3 = w1qty3 - $slstk3
 1E  C                   endsl
720bAc
720bA*   Call to validate adjustment coce.
720bAC                   call(e)   'VFYADJC'
720bAC                   parm      '*NOTBFC'     $vcommand
720bAC                   parm      '*NONE'       $vprg
720bAC                   parm      w1code        $vcode
720bAC                   parm      ' '           $vsys
720bAC                   parm      ' '           $vdesc
720bAC                   parm      ' '           $vreturn
720bAC                   parm      ' '           $vmessage
720bAC                   parm      ' '           $vmsgk

720bAC                   if        $vreturn <> '*OK'
720bAC                   eval      error = *on
720bAC                   eval      *in25 = *on
720bAC                   eval      *in05 = *on
720bAC                   eval      errmsg    = $vmessage
720bAC                   exsr      zm0105
720bAC                   goto      endck1
720bAc                   endif

     *   Call interface to do verification.

     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VERIFY'
     C                   eval      $drisys2upd = 'D'
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
520bAC                   eval      $aitem    = $pitem
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
520b C                   eval      errmsg = desc(7)
520b C                   exsr      zm1001
520b C                   endif
MJKaAC*                  endif
520b C                   leave
520bAC                   enddo
520b C     error         cabeq     *on           endck1
MJKaAC                   endif
YHAb *  Do not allow adjustment code 'MV'
YHAb
YHAa C                   if        client = yhata and
YHAb C                             w1code = 'MV'
YHAb C                   move      *on           error
YHAb C                   eval      *in25 = *on
YHAb C                   eval      *in05 = *on
YHAb C                   eval      errmsg = desc(8)
YHAb C                   exsr      zm1001
YHAb C                   goto      endck1
YHAb C                   endif
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
FPRb C                   eval      *in25 = *on
FPRb C                   eval      *in05 = *on
FPRb C                   eval      errmsg = desc(8)
FPRb C                   exsr      zm1001
FPRb C                   goto      endck1
FPRb C                   endif
FPRb C                   endsl
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   exsr      zzchk1
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
 1B  C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
 2B  C                   select
     *
     *     Slot.
     *
 2X  C                   when      row# = 12
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*VRFYZRO'
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = $pwhdp
     C                   eval      $litem = $pitem
     C                   eval      $ldisp = *blanks
     C                   eval      $ldesg = $itdesg
     C                   eval      $lst = 'V '
     C                   eval      $lsdef = *blanks
     C                   eval      $lactv = *blanks
     C                   call      'SL900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1disp = $ldisp
 3E  C                   endif
     *
     *     Status code.
     *
 2X  C                   when      row# = 13
     C                   eval      *in12 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lstat = w1stat
     C                   call      'SS900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1stat = $lstat
 3E  C                   endif
     *
     *     Reason code.
     *
 2X  C                   when      row# = 17
     C                   eval      *in05 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lcode = w1code
     C                   call      'AD900'
     C                   parm                    $lparm
 3B  C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
 3E  C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
 2X  C                   other
     C                   move      *on           error
     C                   exsr      zm9905
 2E  C                   endsl
goto Csr                 goto      endcm1
 1E  C                   endif
700bA*
700bA*      F7 - kilograms/Pounds toggle
700bA*
700bAC                   if        *inkg
700bAC                   eval      cmdtkn = *on
700bAC                   if        KiloLbs = 'P'
700bAC                   eval      KiloLbs = 'K'
700bAC                   eval      W1KgLb  = 'Kgs'
700bAC                   else
700bAC                   eval      KiloLbs = 'P'
700bAC                   eval      W1KgLb  = 'Lbs'
700bAC                   endif
700bAc                   exsr      zzsetcmdln1
700bAC                   goto      endcm1
700bAC                   endif

     *
     *      F8 - View item slot information.
     *
 1B  C                   if        *inkh
     C                   move      *on           cmdtkn
     C                   eval      $lwhs = $pwhse
     C                   eval      $lwhd = $pwhdp
     C                   eval      $ldis = w1disp
     C                   eval      $litm = $pitem
     C                   eval      $lcmd = '*VIEW   '
     C                   call      'IT135'
     C                   parm                    $lparm
 1E  C                   endif
     *
     *      F9 - View slot quantities.
     *
 1B  C                   if        *inki
     C                   move      *on           cmdtkn
     C                   eval      whse = $pwhse
     C                   call      'SL810'
     C                   parm                    whse
     C                   parm                    $pwhdp
     C                   parm                    w1disp
 1E  C                   endif
     *
     *      F20 - Accept Warning.
     *
 1B  C                   if        *inku
     C                   move      *on           ovrrid
 1E  C                   endif
     *
     *      F21 - Item Tie/High Maintenance.
     *
 1B  C                   if        *inkv
     C                   move      *on           cmdtkn
     C                   eval      whse = $pwhse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    $pitem
 1E  C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   exsr      zzcmd1
     *
     C     endcm2        endsr
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
700bA     when IMkilolbs = 'K';
700bA       if KiloLbs = 'K';
700bA         eval cnvwgt = w1cwtr;
700ba       else;
700bA         eval(h) cnvwgt = w1cwtr / kgs2lbs;
700bA       endif;
700bA     other;
700bM       if KiloLbs = 'K';
700bM         eval(h) cnvwgt = w1cwtr * kgs2lbs;
700bM       else;
700bM         eval cnvwgt = w1cwtr;
700bM       endif;
700bA   endsl;
700bA /end-free

700bAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     C                   eval      savst = *blanks
600bMC                   eval      $sldisp = *blanks
     C                   eval      w1type = *on
650cAC                   eval      w1fifo = 'Y'
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     C                   eval      w1qty1 = 0
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1code = *blanks
     C                   eval      w1memo = *blanks
     C                   eval      ssdesc = *blanks
     C                   eval      w1curq = *blanks
     C                   eval      w1disp = *blanks
     C                   eval      w1stat = 'A '
     C                   eval      w1prty = 0
     C                   eval      w1expd = 0
510aAC                   eval      w1expdc= 0
510aAC                   eval      w1entdc= 0
510bAC                   eval      w1cwtr = 0
     C                   eval      w1entd = udate

     *   Save entry fields.

     C                   eval      savew1disp = w1disp
     C                   eval      savew1stat = w1stat
     C                   eval      savew1prty = w1prty
     C                   eval      savew1expd = w1expd
     C                   eval      savew1entd = w1entd

     *  Get Unit of Measures

     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom

     *   Format item.

     C                   exsr      zzfmti
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     C                   eval      w2qty = *blanks
     C                   exsr      zzdft1
     *
     C                   endsr

     *----------------------------------------------------------------
     *  zzerrind    Set error indicators from DRI call.
     *----------------------------------------------------------------

     C     zzerrind      begsr

     C                   if        $sldispe = '1'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   endif

     C                   if        $slstate = '1'
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   endif

     C                   if        $slprtye = '1'
     C                   eval      *in26 = *on
     C                   eval      *in06 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   endif

     C                   if        $slexpde = '1'
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   endif

     C                   if        $sacodee = '1'
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   endif

     C                   if        $saqty1e = '1'
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
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
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
600bMC                   eval      $cqty1 = $slavl1
600bMC                   eval      $cqty2 = $slavl2
600bMC                   eval      $cqty3 = $slavl3
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
     C                   movel     $cqstr        w1curq
     *
     *  Get status description.
     *
600bMC     $slstat       chain     slotstat                           79
 1B  C                   if        *in79
     C                   eval      ssdesc = *blanks
 1E  C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr

     *   Get Unit of measure fields

     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom

     *   Format item.

     C                   exsr      zzfmti
500 A
500 A*   Slot position.
500 A
600eDC**                 eval      w1slp = 'Pos: '
600eDC**                                 + %trim(%editc($satoPos:'3'))
     *
     *   Initialize entry fields
     *
     C                   eval      w1type = '1'
650cAC                   eval      w1fifo = 'Y'
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     C                   eval      w1qty1 = 0
     C                   eval      w1qty2 = 0
     C                   eval      w1qty3 = 0
     C                   eval      w1cwtr = 0
     C                   eval      w1code = *blanks
     C                   eval      w1memo = *blanks
600bMC                   eval      w1stat = $slstat
600bMC                   eval      w1prty = -($slprty)
     *
600bMC                   if        $slexpd = 0
     C                   eval      w1expd = 0
510aAC                   eval      w1expdc= 0
 1X  C                   else
     C                   eval      $cvcmd = '*CMDMDY '
600bMC                   move      $slexpd       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1expd = $cvd6o
 1E  C                   endif
     *
600bMC                   if        $slentd = 0
     C***                eval      w1entd = udate
     C                   eval      w1entd = 0
510aAC                   eval      w1entdc= 0
 1X  C                   else
     C                   eval      $cvcmd = '*CMDMDY '
600bMC                   move      $slentd       $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      w1entd = $cvd6o
 1E  C                   endif
     *
 1B  C                   if        $itcwgt <> 'Y'
DRYdA*
DRYdAC                   if        client = Dairyland
DRYdAC                   eval      *in95 = '0'
DRYdAC                   else
DRYdA*
     C                   eval      *in95 = *on
DRYdAC                   endif
DRYdA*
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
600bMC                   move      $slstat       savst
WSt1A *   If status is 'TI', protect field so it can't be changed.
WSt1AC                   if        client = westside
WSt1AC                             and $lstat = 'TI'
WSt1DC**                 if        $lstat = 'TI'
650aMC                   eval      *in89 = *on
WSt1AC**                 eval      *in95 = *on
WSt1AC                   else
650aMC                   eval      *in89 = *off
WS1tAC**                 eval      *in95 = *off
WS1tAC                   endif
     *
     *   Save entry fields.
     *
     C                   eval      savew1disp = w1disp
     C                   eval      savew1stat = w1stat
     C                   eval      savew1prty = w1prty
     C                   eval      savew1expd = w1expd
     C                   eval      savew1entd = w1entd

DRYbAC                   if        client = dairyland
DRYbAC                   eval      $hwhse = $itwhse
DRYbAC                   eval      $hitem = $ititem
DRYbAC                   eval      $hqty = 0
DRYbAC                   eval      $hwt = 0
DRYbAC                   call (e)  @hwhsr
DRYbAC                   parm                    $hwhse
DRYbAC                   parm                    $hitem
DRYbAC                   parm                    $hqty
DRYbAC                   parm                    $hwt
DRYbAC                   eval      w1hqty = $hqty
DRYbAC                   eval      w1hwt = $hwt
DRYbAC                   endif
700bAc                   exsr      zzsetcmdln1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Initialize entry fields
     *
     C                   eval      w2qty = *blanks
     C                   exsr      zzfil1
     C                   endsr

     *----------------------------------------------------------------
     *  ZZFMTI   Format item.
     *----------------------------------------------------------------

     C     zzfmti        begsr

     *   Format item description.

     C                   eval      $iitem = $ititem
     C                   eval      $idesc = $itdesc
     C                   eval      $ipdsc = $itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70

     C                   eval      w1item = $istr

     *   Get SSB item, if one exists

     C                   move      *off          ssbflg
     C                   eval      w1lbls = *blanks
     C                   eval      w1sitm = *blanks
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
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C                   movel     'SSB ('       w1lbls
     C     w1lbls        cat       w1um2:0       w1lbls
     C     w1lbls        cat       ')':0         w1lbls
     C                   move      ':'           w1lbls
     *
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    #bitem
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    $istr

     C                   eval      w1sitm = $istr

 2E  C                   endif

 1E  C                   endif

     *   Set indicator for expiration date.

 1B  C                   if        $itflgd <> 'Y'
     C                   eval      *in96 = *on
 1X  C                   else
     C                   eval      *in96 = *off
 1E  C                   endif

     *   Set indicator for catchweight

 1B  C                   if        $itcwgt <> 'Y'
DRYdA*
DRYdAC                   if        client = Dairyland
DRYdAC                   eval      *in95 = '0'
DRYdAC                   else
DRYdA*
     C                   eval      *in95 = *on
DRYdAC                   endif
DRYdA*
 1X  C                   else
     C                   eval      *in95 = *off
 1E  C                   endif

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
600bAC                   exsr      clr$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = $pwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = $pwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = w1disp


     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     *
 1B  C                   if        error
     C                   eval      errmsg = desc(1)
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm04
goto C                   goto      endgt1
goto C                   else
     C                   eval      saveaisl = $slaisl
     C                   eval      saveloc  = $slloc
     C                   eval      saverlvl = $slrlvl
     C                   eval      savehand = $slhand
510d C                   eval      savepick = $slpick
 1E  C                   endif
     *
     *  Slot does not contain an item.
     *
600bMC                   if        $slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
goto Csr                 goto      endgt1
 1E  C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
     C                   exsr      zzget1
     *
     C     endgt2        endsr
610aA*----------------------------------------------------------------
610aA*
610aA*  ZZGETSYOP  Get System Options record.
610aA*
610aAC     zzgetsyop     begsr
610aA*
610aAC                   eval      opcode = '*SYSTEM '
610aA*
610aAC                   eval      opwhse = *zeros
610aA*
610aAC     opkey         chain     options
610aAC                   if        not %found(options)
DRYeAC                   eval      oprg1c = 0
DRYeAC                   eval      oprg2c = 0
610aAC                   eval      opuci  = 'N'
610aAC                   endif
610aA*
610aAC                   endsr
     *
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
     C                   kfld                    $pwhdp
     C                   kfld                    $pdisp
     *
     C     slkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C                   kfld                    w1disp
     *
     *  Define key for itemdef file.
     *
     C     idkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
600bMC                   kfld                    $slsdef
520b *
520b *  Define key for itemlnk1 file.
520b *
520b C     keyil1        klist
520b C                   kfld                    $pwhse
520b C                   kfld                    $pitem
520b *
520b *  Define key for PIRITEM file.
520b *
520b C     keyit         klist
520b C                   kfld                    ilwhse
520b C                   kfld                    ilitem
     *
610aAC     opkey         klist
610aAC                   kfld                    opwhse
610aAC                   kfld                    opcode
     *
500b *  Convert today's date into century format.
500b *
500b C                   eval      $cvcmd = '*CURCMD '
500b C                   call      @cvtdt
500b C                   parm                    $cvtdt
500b C                   eval      today = $cvd8o
500b *
     *
500b *  Convert today's date into century format.
500b *
500b C                   eval      $cvcmd = '*CURCMD '
500b C                   call      @cvtdt
500b C                   parm                    $cvtdt
500b C                   eval      today = $cvd8o
500b *
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
PCKbAC                   eval      w1qty1 = *zero
PCKbAC                   eval      w1qty2 = *zero
PCKbAC                   eval      w1qty3 = *zero
PCKbAC                   eval      w1cwtr = *zero
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
417aAC                   eval      ssbflg = *off
500bAC                   move      '0'           dfchk
500bAC                   move      '0'           dtchk

     *   Position cursor to status for add.

 1B  C                   if        $pcmd = '*ADD    '
     C                   eval      *in12 = *on
 1X  C                   else
     C                   eval      *in02 = *on
JDOaAC                   if        client = jordanos
JDOaAC                   eval      *in04 = *on
JDOaAC                   endif
 1E  C                   endif

700bA*
700bA*   Get Item Maintenance options.
700bA*
700bA /free
700bA    whse = $pwhse;
700bA    getimuom(whse: IMkilolbs: IMUom);
700bA    select;
700bA      when IMkilolbs = 'K';
700bA        KiloLbs = 'K';
700bA        W1KgLb  = IMUom;
700bA      other;
700bA        kiloLbs = 'P';
700bA        W1KgLb  = 'Lbs';
700bA    endsl;
700bA /end-free
     *   Get warehouse description.

     C                   eval      wowhse = *blanks

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

     *   Put warehouse and department together.

     C                   eval      wowhse = %trim($cstr) + '/'
     C                                    + %trim($pwhdp) + ' - '
     C                                    + %trim($vdesc)
     *
     C                   eval      w1disp = $pdisp
500 A*
500 A*   Get default values for the user.
500 A*
500 AC                   call      'GETUSER'
600bMC                   parm                    #curruser
500 AC                   parm      0             #whse             3 0
500 AC                   parm      0             #emp#             5 0
500 AC                   parm                    #fnam            15
500 AC                   parm                    #init             1
500 AC                   parm                    #lnam            20
500 AC                   parm                    #whdp             5
500 AC                   parm                    #styp             1
500 AC                   parm                    #shft             6
500 AC                   parm                    #crew             6
500 AC                   parm      0             #nhrs             3 1
500 AC                   parm                    #rtn              8
     *
     *   Select first screen to display.
     *
     C                   eval      usesc = 1
 1B  C                   if        usesc = 1
     C                   exsr      scr01i
 1X  C                   else
     C                   exsr      scr02i
 1E  C                   endif
610aAC                   exsr      zzgetsyop
     C                   endsr
700bA*----------------------------------------------------------------
700bA*
700bA*  ZZSETCMDLN1  Setup the command keys
700ba*
700baC     zzsetcmdln1   begsr
700bA /free
700bA   Select;
700bA     when $itcwgt <> 'Y';
700bA       cmdln1 = cmdln(3);
700bA     when kilolbs  = 'K';
700bA       cmdln1 = cmdln(2);
700bA     when kilolbs  = 'P';
700bA       cmdln1 = cmdln(1);
700bA   endsl;
700bA   cmdln2 = cmdln(4);
700bA /end-free
700baC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
417aAC                   eval      *in92 = *off
417aAC                   eval      *in93 = *off

     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure

600bMC                   exsr      clr$item
600bAC                   eval      $itwhse  = $pwhse
600bAC                   eval      $ititem  = $pitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

 1B  C                   if        error
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
goto C                   goto      enduom
 1X  C                   else
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
 1E  C                   endif
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
720dA /free
720dA   if $imltrk = 'U';
720dA     *in71 = *on;
720dA   else;
720dA     *in71 = *off;
720dA   endif;
720dA /end-free
     C     enduom        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   move      *off          error

     *   Call interface to do update for non-quantity fields.

     C                   if        w1disp <> savew1disp or
     C                             w1stat <> savew1stat or
     C                             w1prty <> savew1prty or
     C                             w1expd <> savew1expd or
     C                             w1entd <> savew1entd

     C                   if        $pcmd = '*ADD'
     C                   exsr      fill$slotadd
     C                   else
     C                   exsr      fill$slotchg
     C                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CHANGE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
770aA
770aA*     Restore slot info
770aA
770aA        $slot  = save$slot;
770aA        $slot2 = save$slot2;

     C                   endif
EIa A*   Call interface to get license info for lot code
EIa AC                   if        client = ei
640bAC                   exsr      clr$license
640bAC                   eval      $liToWhseU = *on
640bAC                   eval      $liToWhse = $pWhse
640bAC                   eval      $liToWhdpU = *on
640bAC                   eval      $liToWhdp = $slwhdp
640bAC                   eval      $liToDispU = *on
640bAC                   eval      $liToDisp = w1disp
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
EIc MC                                      %trim(%subst(%editc(woseq:'X'):3:3))
EIc DC*                                     %trim(%editc(woseq:'X'))
EIa AC                   eval      w1memo=%replace(wocode:w1memo:21:10)
EIa AC                   endif

     *   Call interface to do quantity adjustment.

     C                   if        adjflg
     C                   exsr      fill$adj
     C                   eval      $dricommand = '*SLOT'
650cA*   Call with new subcmd to do LIFO adjustment.
650cAC                   if        w1fifo = 'Y'
     C                   eval      $drisubcmd  = '%ADJUST'
650cAC                   else
650cAC                   eval      $drisubcmd  = '%ADJUSTREV'
650cAC                   endif
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
600bD **
600bD **     Adjust license.
600bD **
600bDC**                 exsr      zzzclr$lt210
600bDC**                 eval      $tcmd  = '*ADJUST'
600bDC**                 eval      $twhse = $pwhse
600bDC**                 eval      $twhdp = $pwhdp
600bDC**                 eval      $tslot = $pdisp
600bDC**                 eval      $titem = $pitem
600bDC**                 eval      $tqty1 = chgqt1
600bDC**                 eval      $tqty2 = chgqt2
600bDC**                 eval      $tqty3 = chgqt3
600bDC**                 eval      $tnorm1 = chgqt1
600bDC**                 eval      $tnorm2 = chgqt2
600bDC**                 eval      $tnorm3 = chgqt3
600bDC**                 exsr      zzzcall$lt210

     C                   endif
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
610aAC                   if        opuci  = 'Y'     and
PCK AC                             $itcwgt = 'Y'
PCK AC                   select
PCK AC                   when      w1qt01 > *zeros
PCK AC                   eval      $lcmd   = '*ADDADJ '
PCK AC                   when      w1qt01 < *zeros
PCK AC                   eval      $lcmd   = '*DLTADJ '
PCK AC                   endsl
PCK AC                   eval      $lwhseu = $pwhse
PCK AC                   eval      $litemu = $pitem
PCK AC                   eval      $lcodeu = w1code
PCK AC*                  eval      $ltypeu = 'A'
PCKbAc                   eval      $ldate = $sadate
PCKbAc                   eval      $ltime = $satime
520 AC                   eval      $l_w1type = w1type
520 AC                   eval      $l_w1qt01 = w1qt01
520 AC                   eval      $l_w1qt02 = w1qt02
520 AC                   eval      $l_w1qt03 = w1qt03
700bDC*                  eval      $l_w1cwtr = w1cwtr
700bMC                   eval      $l_w1cwtr = cnvwgt
PCK AC                   call      @cwght
PCK AC                   parm                    $lparm
PCKbAC                   parm      *zero         $batch            7 0
PCKbAC                   parm      *blanks       $delvry           9
PCKbAC                   parm      *blanks       $bildoc          10
PCKdAC                   parm      *blanks       $disp             5
PCK AC                   endif

     *
520cDC*****slkey         chain(n)  slot2                              79
520cDC*****              if        not *in79   and
520cDC*****                        slpick = 'Y'
520cDC*****              eval      $dqty1 = slstk1
520cDC*****              eval      $dqty2 = slstk2
520cDC*****              eval      $dqty3 = slstk3
520cDC*****              call      @tlsdt
520cDC*****              parm      '*FIX '       $dcmd             8
520cDC*****              parm      #prog         $dpgm            10
520cDC*****              parm      ' '           $dpgm2           10
520cDC*****              parm      slwhse        $dwhse            3 0
520cDC*****              parm      slwhdp        $dwhdp            5
520cDC*****              parm      sldisp        $dslot           12
520cDC*****              parm      slitem        $ditem           15
520cDC*****              parm                    $dqty1            5 0
520cDC*****              parm                    $dqty2            5 0
520cDC*****              parm                    $dqty3            5 0
520cDC*****              parm                    $drtn             5 0
520cDC*****              eval      $uqty1 = $dqty1
520cDC*****              eval      $uqty2 = $dqty2
520cDC*****              eval      $uqty3 = $dqty3
520cDC*****              call      @sltdt
520cDC*****              parm      '*FIX '       $ucmd             8
520cDC*****              parm      #prog         $upgm            10
520cDC*****              parm      ' '           $upgm2           10
520cDC*****              parm      slwhse        $uwhse            3 0
520cDC*****              parm      slwhdp        $uwhdp            5
520cDC*****              parm      sldisp        $uslot           12
520cDC*****              parm      slpick        $upick            1
520cDC*****              parm      slitem        $uitem           15
520cDC*****              parm      ' '           $unewi           15
520cDC*****              parm      slentd        $uentd            8 0
520cDC*****              parm      slexpd        $uexpd            8 0
520cDC*****              parm                    $uqty1            5 0
520cDC*****              parm                    $uqty2            5 0
520cDC*****              parm                    $uqty3            5 0
520cDC*****              parm                    $urtn             5 0
520cDC*****              endif
     *
PFCaAc*    Send receiving data to APT.
PFCaAc                   if        client = Presto
PFCaAc
PFCaAc                   move      aptsk1        apcmd
PFCaAc                   eval      apseq# = w1qt01 + w1qt02 + w1qt03
PFCaAc
PFCaAc                   monitor
PFCaAc                   eval      aplbl# = %dec(%subst(w1memo:1:7):7:0)
PFCaAc                   on-error
PFCaAc                   eval      aplbl# = 9999999
PFCaAc                   endmon
PFCaAc                   eval      aploc = $ititem
PFCaAc
PFCaAc                   select
PFCaAc                   when      w1code = ' 4'
PFCaAc                             or w1code = ' 8'
PFCaAc                   eval      aprte = '2'
PFCaAc                   exsr      zzapt
PFCaAc                   when      w1code = '22'
PFCaAc                   eval      aprte = 'D'
PFCaAc                   exsr      zzapt
PFCaAc                   other
PFCaAc                   endsl
PFCaAc
PFCaAc                   endif
     C*
     C     endupd        endsr

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
     C                   eval      $saemp# = #emp#
     C                   endsr

     *----------------------------------------------------------------
     *  fill$adj   Fill $slot data structure fields for adjustment.
     *----------------------------------------------------------------

     C     fill$adj      begsr

     *  Initialize data structure

600bMC                   exsr      clr$slot

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $pitem

     C                   eval      $saqtyu  = *on
     C                   eval      $saqty1  = chgqt1
     C                   eval      $saqty2  = chgqt2
     C                   eval      $saqty3  = chgqt3

     C                   eval      $sacwtau = *on
700bDC*                  eval      $sacwta  = w1cwtr
700bMC                   eval      $sacwta  = cnvwgt

     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = w1code

     C                   eval      $samemou = *on
     C                   eval      $samemo  = w1memo

417 AC                   eval      $sabyu   = *on
600bMC                   eval      $saby    = #curruser
600bA
750bAC                   if        w1expd <> savew1expd
750bAC                   eval      $slexpdu = *on
750bAC                   eval      $slexpd  = w1expdc
750bAC                   endif
750bA
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

     C                   endsr

     *----------------------------------------------------------------
     *  fill$slotadd  Fill $slot data structure fields for *ADD
     *----------------------------------------------------------------

     C     fill$slotadd  begsr

     *  Initialize data structure

600bMC                   exsr      clr$slot

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = saveaisl

     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = saveloc

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = saverlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand  = savehand

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $pitem

     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat

     C                   eval      $slprtyu = *on
     C                   eval      $slprty  = -(w1prty)

     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w1expdc

     C                   eval      $slentdu = *on
     C                   eval      $slentd  = w1entdc

     C                   endsr

     *----------------------------------------------------------------
     *  fill$slotchg  Fill $slot data structure fields for *CHANGE
     *----------------------------------------------------------------

     C     fill$slotchg  begsr

     *  Initialize data structure

600bMC                   exsr      clr$slot

     *  Move fields from record to data structure.

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp

     C                   eval      $slaislu = *on
     C                   eval      $slaisl  = saveaisl

     C                   eval      $sllocu  = *on
     C                   eval      $slloc   = saveloc

     C                   eval      $slrlvlu = *on
     C                   eval      $slrlvl  = saverlvl

     C                   eval      $slhandu = *on
     C                   eval      $slhand  = savehand

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = w1disp

     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $pitem

     C                   if        w1stat <> savew1stat
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = w1stat
520a C                   eval      $slpicku = *on
520a C*****************  eval      $slpick  = slpick
     C                   endif

     C                   if        w1prty <> savew1prty
     C                   eval      $slprtyu = *on
     C                   eval      $slprty  = -(w1prty)
     C                   endif

     C                   if        w1expd <> savew1expd
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd  = w1expdc
     C                   endif

     C                   if        w1entd <> savew1entd
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = w1entdc
     C                   endif

510d C                   eval      $slpick  = savepick
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'CHG'
600bAC                   eval      $saETrn#U = *on
600bAC                   eval      $saETrn# = 0

     C                   endsr

PFCaA*----------------------------------------------------------------
PFCaA*  ZZAPT   Call APT interface.
PFCaA
PFCaAc     zzapt         begsr
PFCaA
PFCaAc*    Create APT output record.
PFCaA
PFCaAc                   CALL      'APTMAIN'
PFCaAc                   PARM                    APCMD            10
PFCaAc                   PARM      #PROG         APPGM            10
PFCaAc                   PARM      $PWHSE        APWHSE            3 0
PFCaAc                   PARM                    APLBL#            7 0
PFCaAc                   PARM                    APTRN#            7 0
PFCaAc                   PARM      #USER         APUSER           10
PFCaAc                   PARM      #EMP#         APEMP#            5 0
PFCaAc                   PARM      *BLANKS       APRTID            5
PFCaAc                   PARM      *BLANKS       APRTE             5
PFCaAc                   PARM                    APLOC            20
PFCaAc                   PARM                    APSEQ#            5 0
PFCaAc                   PARM                    APRTN            10
PFCaAc                   PARM                    APMSG            60
PFCaA
PFCaAc                   endsr
PFCaA
     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600aAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416cAC                   eval      $dridata2 = $item2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $dridata = $license
640bAC                   eval      $dridata2 = $license2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $dridata = $licinfo
     C                   endsl

416cAC                   select

416cAC                   when      $dricommand = '*ITEM'
600aAC                             or $dricommand = '*SLOT'
640bAC                             or $dricommand = '*LICENSE'
416cAC                   call(e)   'DRICOP'
416cAC                   parm                    $dricommand
416cAC                   parm                    $drisubcmd
416cAC                   parm                    $drisys2upd
416cAC                   parm      #prog         $driprogram
416cAC                   parm      ' '           $drireturn
416cAC                   parm      ' '           $drimessage
416cAC                   parm                    $dridata
416cAC                   parm                    $dridata2
416cA
416cAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416cA
416cAC                   endsl

     C                   select

     C                   when      %error
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

700bA * moved to after the $slot fields are loaded
700bDC*                  when      $drireturn <> '*OK'
700bDC*                  eval      error = *on
700bDC*                  if        zmsflag
700bDC*                  exsr      zm0001s
700bDC*                  else
700bDC*                  exsr      zm0001
700bDC*                  exsr      zzerrind
700bDC*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600aAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416cAC                   eval      $item2 = $dridata2
640bAC                   when      $dricommand = '*LICENSE'
640bAC                   eval      $license = $dridata
640bAC                   eval      $license2 = $dridata2
640bAC                   when      $dricommand = '*LICINFO'
640bAC                   eval      $licinfo = $dridata
     C                   endsl
700bA * moved from above - fields for $slot were not populated
700bac                   select
700bAC                   when      $drireturn <> '*OK'
700bAC                   eval      error = *on
700baC                   if        zmsflag
700bAC                   exsr      zm0001s
700bAC                   else
700bAC                   exsr      zm0001
700bAC                   exsr      zzerrind
700bAC                   endif
700bA
700bAC                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     *pssr         begsr

     *  Make sure we don't get caught in an infinite loop

 1B  C                   if        pssrflag
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   eval      pssrflag = *on

     *  Ignore "Result field not large enough ..." error.

 1B  C***                if        #status = '00103'
     C***                eval      pssrflag = *off
     C***                goto      endpssr
     C***                endif

     *  Send message back to calling program.

     C                   eval      errmsg   = 'U:' + #status + '/'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   exsr      zm0105s
     C                   eval      *inlr = *on
 1E  C                   return

     C     endpssr       endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*  License Plate Tracking Routines
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  ZZZCLR$LT210  -  Clear LT210 parameters.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCLR$LT210  begsr

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
500aAC                   clear                   $tnorm1
500aAC                   clear                   $tnorm2
500aAC                   clear                   $tnorm3
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

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZZCALL$LT210  -  Call LT210 program.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCALL$LT210 begsr

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
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
500aAC                   parm                    $tnorm1
500aAC                   parm                    $tnorm2
500aAC                   parm                    $tnorm3
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

     C                   endsr

     *----------------------------------------------------------------     ****
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------     ****
**
Slot
Slot location
Slot level
Adjustment Type
Priority
Catch wt adjustment
Alias item
Adjustment Code
Adjust oldest product
**  CMDLN - Command display line 700b
F4=Prompt  F5=Refresh  F7=Kilogram  F8=View item/slot info.  F9=View slot qty
F4=Prompt  F5=Refresh  F7=Pounds    F8=View item/slot info.  F9=View slot qty
F4=Prompt  F5=Refresh  F8=View item/slot info.  F9=View slot qty
F12=Cancel  F20=Accept warning  F21=Tie/High maintenance
