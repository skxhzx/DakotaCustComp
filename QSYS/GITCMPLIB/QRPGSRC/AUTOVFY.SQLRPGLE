500gA /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *
     *  AUTOVFY     Auto verify slot
     *  19 August 2008
     *  Dave Sommerville
     *
      *
      *  To compile:
      *
      *             CRTSQLRPGI PGM(XXX/SQL003RG) SRCFILE(XXX/QRPGLESRC)
      *
      *
      * COMPILING. In order to compile this program you will need
      *            to use options which allow it to work correctly
      *            between machines. These options are---
      *
      *               COMMIT = *NONE
      *               RDB    = Machine name that you will connect to.
710   *               CLOSQLCSR = *ENDMOD
      *               DLYPRP = *YES
      *               SQLPKG = The name & library that you want to
      *                        use for the package. This will put the
      *                        package on the RDB machine that you
      *                        specify.
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    08/19/08  DAS  5.20
     *      - Created
     *
610 A*    09/06/09  MLB  6.10
     *      - Enh: Added client custom code support to program.
     *
640 A*    08/31/11  MLB  6.40
     *      - Enh: Converted program to SQLRPGLE program.
640aA*    07/15/11  RH   6.40a
     *      - Enh: Do not zero SPCL slots if overflow exists.
640bA*    01/10/12  RH   6.40b
     *      - Enh: Move client code from VERIFYALL to seperate s/r
650aA*    07/29/14  MLB/RH  6.50a
     *      - Fix: Select in VERIFYALLICB for SPCL order, was setting
     *        SPCL slots to 'Z' not checking quantity.
650bA*    08/29/14  LMC  6.50b
     *      - Fix: Select in VERIFYALLICB for Z status was falling
     *        thru the SPCL slot logic and the record was not getting
     *        verified. Separate this into their own When selections.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval Foods
     *
SVL A*    09/06/09  MLB  SVL
     *      - Revised program to check that all qty fields are zero
     *        for pick slots with designation SPCL. If all zero,
     *        then chain to SLOT1 and set SLSTAT=Z so that the DRISLOT
     *        pgm can zero verify the slot and remove it from the system.
     *        This is necessary because CHKSTAT pgm was revised to not
     *        change the status of virtual pick slots to Zero status.
SVLaA*    04/27/10  MLB  SVLa
     *      - Revised program to allow slots that are not at Zero status
     *        to be processed.  Currently, program is skipping SPCL
     *        slots that are active.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Springfield Grocery
     *
SGC A*    05/18/09  MLB  SGC
     *      - Revised program so that only slots at Zero status
     *        with SPCL, SPCLC designation are auto-verified.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SouthWest Traders
     *
SWTa *    06/11/19  GJA  SWTa
     *      - Revised program so ALL slots at Zero status  atus
     *        are auto-verified.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Inter County Bakers
     *
ICB A*    07/10/12  RH   ICB
     *      - Revised program so ALL slots at Zero status
     *        are auto-verified.
ICBbA*    07/17/12  GJA/MLB  ICBb
     *      - Revised program to add support to auto verify slots
     *        with designation code STAGE. Items placed into slot
     *        E999 are virtual pick slots that hold product from other
     *        whse. Once picking is done, then virtual slots need to
     *        be cleaned up.
ICBcA*    07/20/12  MLB  ICBc
     *      - Revised program add ICB to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: European Imports
     *
EI  A*    08/31/11  MLB  EI
     *      - Revised program to check that all qty fields are zero
     *        for pick slots with designation SPCL. If all zero,
     *        then chain to SLOT1 and set SLSTAT=Z so that the DRISLOT
     *        pgm can zero verify the slot and remove it from the system.
     *        This is necessary because CHKSTAT pgm was revised to not
     *        change the status of virtual pick slots to Zero status.
     *      - Added EI to SVL mod.
EIa A*    08/31/11  MLB  EIa
     *      - Revised program to allow slots that are not at Zero status
     *        to be processed.  Currently, program is skipping SPCL
     *        slots that are active.
     *      - Added EIa to SVLa mod.
EIb A*    08/31/11  MLB  EIb
     *      - Revised program to run SQL statement looking for any
     *        label rcds that are not at C=Closed status. If 1 or more
     *        labels are found, skip auto zero verify of SPCL slot.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier Foods
     *
GFCa *    06/09/10  MLB  GFCa *Temp only until Go Live *
     *      - Revised program to zero verify and delete all virtual
     *        pick slots that are at Zero status.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
     *
GMM A*    09/05/12  RH   GMM
     *      - Add to SGC mod so that only slots at Zero status
     *        with SPCL, SPCLC designation are auto-verified.
GMMbA*    02/07/13  MLB  GMMb
     *      - Revised GMM mod. Revised pgm to call routine VERIFYALLICB
     *        instead of VERIFYALLSGC. The new routine verifies all Zero
     *        slots, not just SPCL/SPCLC designated slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey Foodservice
     *
HAL A*    07/18/17  MLB/RH  HAL
     *      - Revised program so ALL slots at Zero status
     *        are auto-verified.
     *      - Added HAL to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    03/14/13  MLB  CWD
     *      - Revised pgm to call routine VERIFYALLICB. The new routine
     *        The new routine verifies all Zero slots, not just SPCL/
     *        SPCLC designated slots.
     *      - Added CWD to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    02/17/11  RH   DRYa
     *      - Revised program to verify slots with location=999
     *      - created client specific VERIFYALLDRY
DRYbA*    02/27/11  RH   DRYb
     *      - Revised program to verify slots with aisle TRL or 036
DRYcA*    05/05/14  KDE  DRYc
     *      - Revised program to verify slots with aisle PAR, PRD,
     *        WIp or MIN as defined in PLINED file for Production
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
GFS A*    03/02/13  MLB  GFS
     *      - Add to SGC mod so that only slots at Zero status
     *        with SPCL, SPCLC designation are auto-verified.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    08/22/13  MLB  GLP
     *      - Revised pgm to call routine VERIFYALLICB.
     *        The new routine verifies all Zero
     *        slots, not just SPCL/SPCLC designated slots.
GLPaA*    08/22/13  MLB  GLPa
     *      - Revised program add GLPa to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: CDI
     *
CDI A*    11/06/13  MLB  CDI
     *      - Revised pgm to call routine VERIFYCDI.
     *        The new routine verifies selected aisles only.
CDIaA*    08/22/13  MLB  CDIa
     *      - Revised program add CDIa to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Fischer Foods
     *
FFC A*    12/12/14  MLB  FFC
     *      - Revised pgm to call routine VERIFYALLICB.
     *        The new routine verifies all Zero
     *        slots, not just SPCL/SPCLC designated slots.
FFCaA*    08/22/13  MLB  FFCa
     *      - Revised program add FFCa to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    01/12/15  MLB  HMW
     *      - Revised pgm to call routine VERIFYALLICB.
     *        The new routine verifies all Zero
     *        slots, not just SPCL/SPCLC designated slots.
HMWaA*    01/12/15  MLB  HMWa
     *      - Revised program add FFCa to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    05/06/15  MLB  FPR
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added FPR to ICB mod.
FPRaA*    02/07/18  MLB  FPRa
     *      - Revised VERIFYALLICB to set virtual slots at SR status to
     *        zero status if all qty fields are zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
     *
WIL A*    05/20/15  MLB  WIL
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added WIL to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S Bertram
     *
SBR A*    02/04/16  MLB  SBR
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added SBR to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Bros
     *
CBIaA*    09/23/16  NK   CBIa
CBIaA* all clientloc of cheneyocala, cheneyriviera, and cheneypntgr
     *      - Revised program so slots at Zero status
     *        are auto-verified.
CBIbA*    01/18/17  NK   CBIb
     *      - setll using Z stat to make more efficient
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGL A*    06/14/17  MLB  FGL
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added FGL to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SPI A*    09/15/17  MLB  SPI
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added SPI to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos Foods
     *
PAN A*    10/03/17  MLB  PAN
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. email dated 10.03.2017.
     *      - Added PAN to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: T&T Produce
     *
TNT A*    12/10/17  MLB  TNT
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. skype dated 12.15.2017.
     *      - Added TNT to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Farm Boy Foods
     *
FBY A*    02/05/18  MLB  FBY
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. voicemsg dated 02.05.2018.
     *      - Added FBY to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    02/24/18  MLB  SFP
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 02.24.2018.
     *      - Added SFP to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQS A*    03/22/18  MLB  MQS
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 03.22.2018.
     *      - Added MQS to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFI A*    05/17/18  MLB  CFI
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 05.17.2018.
     *      - Added CFI to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit Foods
     *
MRT A*    07/18/19  MLB  MRT
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots.
     *      - Added MRT to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco & Sons
     *
GRC A*    08/06/18  MLB  GRC
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 05.17.2018.
     *      - Added GRC to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    11/02/18  RTR  EOPa
     *      - Revised pgm to call routine VERIFYALLICB to verify all.
     *        Added EOP to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
ACC A*    11/14/18  MLB  ACC
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 11.13.2018.
     *      - Added ACC to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BAD A*    08/26/19  MLB  BAD
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 11.13.2018.
     *      - Added BAD to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vitco Foods
     *
VFI A*    01/06/20  MLB  VFI
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. text msg dated 01.06.2020.
     *      - Added VFI to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
     *
HPC A*    01/27/20  MLB  HPC
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. phone call dated 01.27.2020.
     *      - Added HPC to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
JOR A*    10/23/20  MLB  JOR
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Per Roxanne H. email dated 10.23.2020.
     *      - Added JOR to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise Foods
     *
SUNa *    08/19/20  RTR  SUNa
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Added SUN to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Global Import
     *
GIG A*    11/16/21  MLB  GIG
     *      - Revised pgm to call routine VERIFYALLICB to verify all
     *        slots. Added GIG to ICB mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFC A*    01/04/16  MLB  PFC
     *      - Revised pgm to call routine VERIFYALLICB.
     *        The new routine verifies all Zero
     *        slots, not just SPCL/SPCLC designated slots.
PFCaA*    01/04/16  MLB  PFCa
     *      - Revised program add PFCa to SVL mod to open SLOT1.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     fslot2     if   e           k disk
SVL Afslot1     uf   e           k disk    usropn
SVL AF                                     rename(slrec : slrec1)
640aAfslot3     if   e           k disk
640aAf                                     rename(slrec:slrec3)
CBIaAfslot5     if   e           k disk    usropn
CBIaAF                                     rename(slrec : slrec5)
DRYcAfplined    if   e           k disk
CBIaAfdesigsp1  if   e           k disk    usropn

610 A*----------------------------------------------------------------
610 A*  Customer id
610 A*----------------------------------------------------------------
SVL A /copy qcopysrc,id#saval
SGCaA /COPY *libl/qcopysrc,id#sgc
EI  A /copy qcopysrc,id#ei
GFCaA /copy qcopysrc,id#glazier
ICBaA /copy qcopysrc,id#icb
GMMaA /copy qcopysrc,id#gmm
HAL A /copy qcopysrc,id#halsey
CWD A /copy qcopysrc,id#cashwa
DRYaA /copy qcopysrc,id#dairyla
GFS A /copy qcopysrc,id#gfs
GLP A /copy qcopysrc,id#glp
CDI A /copy qcopysrc,id#cdi
CDI A /copy qcopysrc,id#cdiatl
CDI A /copy qcopysrc,id#cdijax
FFC A /copy qcopysrc,id#fischer
HMW A /copy qcopysrc,id#hmwagne
FPR A /copy qcopysrc,id#fpr
WIL A /copy qcopysrc,id#wil
SBR A /copy qcopysrc,id#sbr
CBIaA /copy qcopysrc,id#cheney
CBIaA /copy qcopysrc,id#cheneyo
CBIaA /copy qcopysrc,id#cheneyr
CBIaA /copy qcopysrc,id#cheneyp
FGL A /copy qcopysrc,id#fgl
SPI A /copy qcopysrc,id#spi
PAN A /copy qcopysrc,id#pan
TNT A /copy qcopysrc,id#tnt
FBY A /copy qcopysrc,id#fby
SFP A /copy qcopysrc,id#sfp
MQS A /copy qcopysrc,id#mqs
CFI A /copy qcopysrc,id#cfi
MRT A /copy qcopysrc,id#mrt
GRC A /copy qcopysrc,id#grc
EOPaA /copy qcopysrc,id#eop
ACC A /copy qcopysrc,id#acc
SWTaA /copy qcopysrc,id#swt
BAD A /copy qcopysrc,id#bad
VFI A /copy qcopysrc,id#vfi
HPC A /copy qcopysrc,id#hpc
SUNaA /copy qcopysrc,id#sun
GIG A /copy qcopysrc,id#gig
JOR A /copy qcopysrc,id#jordano
PFCaA /copy qcopysrc,id#pfc

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS
500dA
500dA*----------------------------------------------------------------
500dA*  Data Formats
500dA*----------------------------------------------------------------
500dA
500dA /COPY *libl/qcopysrc,C#SLOT
500dAD saveVer#        s                   like($slver#)
SVL A
SVL A*----------------------------------------------------------------
SVL A*  Date Conversion DS
SVL A*----------------------------------------------------------------
SVL A
SVL AD @cvtdt          c                   const('CVTDTE')
SVL A*
SVL AD $cvtdt          ds
SVL AD  $cvcmd                 1      8
SVL AD  $cvprg                 9     18
SVL AD  $cvd6i                19     24
SVL AD  $cvd8i                25     32
SVL AD  $cvd6o                33     38  0
SVL AD  $cvd8o                39     46  0
SVL AD  $cvsto                47     64
SVL AD  $cvrtn                65     72
SVL AD  $cverm                73    132
SVL AD  $cvmsg                73     76

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
CDI AD kyAisl          s                   like(slaisl)
     D pWhse#          s                   like(slwhse)
     D kyWhse          s                   like(slwhse)
     D kyWhdp          s                   like(slwhdp)
     D kyDisp          s                   like(sldisp)
640aAD k3Item          s                   like(slitem)
640aAD k3Stat          s                   like(slstat)
CBIbAD kzStat          s                   like(slstat)
640aAD k3Pick          s                   like(slpick)
CBIaAD k5whdp          s                   like(slwhdp)
CBIaAD k5desg          s                   like(sldesg)
640aAD nbrovr          s              5  0
SVL AD today           s                   like(slsdte)
     D error           s               n
     D forever         s               n
     D drierr          s               n
EIb AD unbropnlbl      s              7s 0 inz(0)

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
500dAD  #pgm             *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
500dAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------
     C     *entry        plist
     C                   parm                    pCmd              8
     C                   parm                    pWhse             3
     C                   parm                    pWhdp             5
     C                   parm                    pDisp            12

     C                   move      pWhse         pWhse#

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     * Get out if proper command is not sent in.

     C                   select

     C                   when      pCmd = '*ONE'
     C                   eval      kyWhse = pWhse#
     C                   eval      kyWhdp = pWhdp
     C                   eval      kyDisp = pDisp
     C                   exsr      verifyOne

     C                   other
640bAC                   select
640bAC                   when      client = Savalfoods
640bAC                   exsr      verifyAllS
640bAC                   when      client = SGC
GFS AC                             or client = getfresh
640bAC                   exsr      verifyAllSGC
640bAC                   when      client = EI
640bAC                   exsr      verifyAllEI
ICBaAC                   when      client = ICB
HAL AC                             or client = Halsey
ICBaAC                   exsr      verifyAllICB
GMMaAC                   when      client = menumaker
GMMbDC*                  exsr      verifyAllSGC
GMMbMC                   exsr      verifyAllICB
CWD A*
CWD AC                   when      client = cashwa
CWD AC                   exsr      verifyAllICB
SWTaA*
SWTaAC                   when      client = swt
SWTaAC                   exsr      verifyAllICB
CWD A*
CBIaAC                   when      client = cheney
CBIaAC                   exsr      verifyCBI
DRYaA*
DRYaAC                   when      client = dairyland
DRYaAC                   exsr      verifyAllDRY
CDI A*
CDI AC                   when      client = Cdi
CDI AC                   exsr      verifyCdi
DRYaA*
GLP AC                   when      client = Greenleaf
GLP AC                   exsr      verifyAllICB
FFC A*
FFC AC                   when      client = Fischerfoods
FFC AC                   exsr      verifyAllICB
HMW A*
HMW AC                   when      client = HMWagner
HMW AC                   exsr      verifyAllICB
FPR A*
FPR AC                   when      client = FoodPro
FPR AC                   exsr      verifyAllICB
WIL A*
WIL AC                   when      client = WillFoods
WIL AC                   exsr      verifyAllICB
SBR A*
SBR AC                   when      client = SBertram
SBR AC                   exsr      verifyAllICB
FGL A*
FGL AC                   when      client = FoodsGalore
FGL AC                   exsr      verifyAllICB
SPI A*
SPI AC                   when      client = SternProduce
SPI AC                   exsr      verifyAllICB
PAN A*
PAN AC                   when      client = Panos
PAN AC                   exsr      verifyAllICB
TNT A*
TNT AC                   when      client = TnTProduce
TNT AC                   exsr      verifyAllICB
FBY A*
FBY AC                   when      client = FarmBoy
FBY AC                   exsr      verifyAllICB
SFP A*
SFP AC                   when      client = Seashore
SFP AC                   exsr      verifyAllICB
MQS A*
MQS AC                   when      client = Marques
MQS AC                   exsr      verifyAllICB
CFI A*
CFI AC                   when      client = Colony
CFI AC                   exsr      verifyAllICB
MRT A*
MRT AC                   when      client = Merit
MRT AC                   exsr      verifyAllICB
GRC A*
GRC AC                   when      client = Greco
GRC AC                   exsr      verifyAllICB
EOPaA*
EOPaAC                   when      client = EarlsOrganic
EOPaAC                   exsr      verifyAllICB
ACC A*
ACC AC                   when      client = Accardi
ACC AC                   exsr      verifyAllICB
BAD A*
BAD AC                   when      client = BigApple
BAD AC                   exsr      verifyAllICB
VFI A*
VFI AC                   when      client = Vitco
VFI AC                   exsr      verifyAllICB
HPC A*
HPC AC                   when      client = HoltPaper
HPC AC                   exsr      verifyAllICB
SUNaA*
SUNaAC                   when      client = Sunrise
SUNaAC                   exsr      verifyAllICB
GIG A*
GIG AC                   when      client = Globalimport
GIG AC                   exsr      verifyAllICB
JOR A*
JOR AC                   when      client = Jordanos
JOR AC                   exsr      verifyAllICB
FPR A*
PFC AC                   when      client = PrestoFoods
PFC AC                   exsr      verifyAllICB
PFC A*
640bAC                   other
     C                   exsr      verifyAll
640b C                   endsl

     C                   endsl

     * Bye, Bye.

     C                   eval      *inlr = *on

     *------------------------------------------------------------------
     * *INZSR
     *------------------------------------------------------------------

     C     *inzsr        begsr
610 A*
610 A* Get client id.
610 A*
610 AC                   call      'GETCLIENT'
610 AC                   parm                    client           10
610 AC                   parm                    clientloc        10
610 A*
SVL AC                   if        client = Savalfoods
EI  AC                             or client = EI
SGCaAC                             or client = SGC
ICBcAC                             or client = ICB
GMMaAC                             or client = Menumaker
GFS AC                             or client = Getfresh
CWD AC                             or client = Cashwa
GLPaAC                             or client = Greenleaf
FFCaAC                             or client = Fischerfoods
CDIaAC                             or client = Cdi
HMWaAC                             or client = HMWagner
FPR AC                             or client = FoodPro
WIL AC                             or client = WillFoods
SBR AC                             or client = SBertram
CBIaAC                             or client = cheney
SPI AC                             or client = SternProduce
PAN AC                             or client = Panos
TNT AC                             or client = TnTProduce
FBY AC                             or client = FarmBoy
SFP AC                             or client = Seashore
MQS AC                             or client = Marques
CFI AC                             or client = Colony
MRT AC                             or client = Merit
GRC AC                             or client = Greco
EOPaAC                             or client = EarlsOrganic
ACC AC                             or client = Accardi
SWTaAC                             or client = swt
BAD AC                             or client = BigApple
VFI AC                             or client = Vitco
HPC AC                             or client = HoltPaper
SUNaAC                             or client = Sunrise
GIG AC                             or client = Globalimport
JOR AC                             or client = Jordanos
PFCaAC                             or client = PrestoFoods
SVL AC                   if        not %open(slot1)
SVL AC                   open      slot1
SVL AC                   endif
SVL A*
SVL AC                   endif
CBIaA*
CBIaAC                   if        client = cheney
CBIaAC                   if        not %open(slot5)
CBIaAC                   open      slot5
CBIaAC                   endif
CBIaAC                   if        not %open(desigsp1)
CBIaAC                   open      desigsp1
CBIaAC                   endif
CBIaAC                   endif
SVL A*
SVL A*      Compute today's date.
SVL AC                   eval      $cvcmd = '*CURCMD '
SVL AC                   call      @cvtdt
SVL AC                   parm                    $cvtdt
SVL AC                   eval      today  = $cvd8o
SVL A*
     C     keySL2        klist
     C                   kfld                    kyWhse
SVL A*
SVL AC     keySL1        klist
SVL AC                   kfld                    slwhse
SVL AC                   kfld                    slwhdp
SVL AC                   kfld                    slaisl
SVL AC                   kfld                    slloc
SVL AC                   kfld                    slrlvl
SVL AC                   kfld                    slhand
CDI A*
CDI AC     keySL1cdi     klist
CDI AC                   kfld                    kywhse
CDI AC                   kfld                    kywhdp
CDI AC                   kfld                    kyaisl
640aA*
640aAC     keyS3         klist
640aAC                   kfld                    kyWhse
640aAC                   kfld                    k3Item
640aAC                   kfld                    k3Stat
640aAC                   kfld                    k3Pick
CBIaA*
CBIaAC     keySL5        klist
CBIaAC                   kfld                    kyWhse
CBIaAC                   kfld                    k5whdp
CBIaAC                   kfld                    k5desg
CBIbAC                   kfld                    kzstat
    A*
     C                   endsr

640a *------------------------------------------------------------------
640a * chkovr - Check for overflow slots for item.
     *------------------------------------------------------------------

640a C     chkovr        begsr

640a C                   eval      kyWhse = pWhse#
640a C                   eval      k3Item = slitem
640a C                   eval      k3Stat = 'A '
640a C                   eval      k3Pick = 'N'
640a C     keyS3         setll     slot3
640a C                   eval      nbrovr = 0

640a C                   dow       forever = forever

640a C     keyS3         reade     slot3
640a C                   if        %eof
640a C                   leave
640a C                   else
640a C                   eval      nbrovr = nbrovr + 1
640a C                   endif
640a C                   enddo

640aAC                   endsr
     *------------------------------------------------------------------
     * verifyOne
     *------------------------------------------------------------------

     C     verifyOne     begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = kyWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = kyWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = kyDisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ZEROVFY'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   endif

     C                   endsr

     *------------------------------------------------------------------
     * verifyAll  - Verify all SPCL slots
     *------------------------------------------------------------------

     C     verifyAll     begsr

     C                   eval      kyWhse = pWhse#
     C     keySL2        setll     slot2

     C                   dow       forever = forever

     C     keySL2        reade     slot2
     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        sldesg <> 'SPCL'
     C                             or slstat <> 'Z'
     C                   iter
     C                   endif

     C                   if        sldesg = 'SPCL'
     C
     C                   if            slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C                             and slalc1 = 0
     C                             and slalc2 = 0
     C                             and slalc3 = 0
     C                             and slpck1 = 0
     C                             and slpck2 = 0
     C                             and slpck3 = 0
     C                             and slrcv1 = 0
     C                             and slrcv2 = 0
     C                             and slrcv3 = 0
     C                             and sltfr1 = 0
     C                             and sltfr2 = 0
     C                             and sltfr3 = 0
640aA* Do not zero SPCL slots if overflow exists.
640aAC                   if        slpick = 'Y'
640aAC                             and sldesg = 'SPCL'
640aAC                   exsr      chkovr
640aAC                   if        nbrovr > 0
640aAC                   iter
640aAC                   endif
640aAC                   endif
     *      Update slot status to Zero so that DRISLOT
     *      can process the SPCL and Zero Verify from the system.
     C     keysl1        chain     slot1
     C                   if        %found(slot1)
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   update    slrec1
     C                   endif
     C
     C                   endif
     C
     C                   endif
     C
     C                   eval      kyWhse = slWhse
     C                   eval      kyWhdp = slWhdp
     C                   eval      kyDisp = slDisp
     C                   exsr      verifyOne

     C                   enddo

     C                   endsr
     *------------------------------------------------------------------
     * verifyCBI  - Verify all SPCL slots - CheneyBros
     *------------------------------------------------------------------

CBIaAC     verifyCBI     begsr

CBIbAC                   eval      kzstat = 'Z'
     C                   eval      kyWhse = pWhse#

CBIaAC                   dow       forever = forever

CBIaAC                   read      desigsp1
CBIaAC                   if        %eof(desigsp1)
CBIaAC                   leave
CBIaAC                   else
CBIaAC                   eval      k5whdp = dsswhd
CBIaAC                   eval      k5desg = dsscde
CBIaAC                   endif

CBIaAC     keySL5        setll     slot5

     C                   dow       forever = forever

CBIaAC     keySL5        reade     slot5
CBIaAC                   if        %eof(slot5)
     C                   leave
     C                   endif

     C
     C                   if            slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C                             and slalc1 = 0
     C                             and slalc2 = 0
     C                             and slalc3 = 0
     C                             and slpck1 = 0
     C                             and slpck2 = 0
     C                             and slpck3 = 0
     C                             and slrcv1 = 0
     C                             and slrcv2 = 0
     C                             and slrcv3 = 0
     C                             and sltfr1 = 0
     C                             and sltfr2 = 0
     C                             and sltfr3 = 0
640aA* Do not zero SPCL slots if overflow exists.
640aAC                   if        slpick = 'Y'
640aAC                   exsr      chkovr
640aAC                   if        nbrovr > 0
640aAC                   iter
640aAC                   endif
640aAC                   endif
     *      Update slot status to Zero so that DRISLOT
     *      can process the SPCL and Zero Verify from the system.
     C     keysl1        chain     slot1
     C                   if        %found(slot1)
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   update    slrec1
     C                   endif
     C
CBIaAC                   else
CBIaAC                   iter
     C                   endif
     C
     C                   eval      kyWhse = slWhse
     C                   eval      kyWhdp = slWhdp
     C                   eval      kyDisp = slDisp
     C                   exsr      verifyOne

     C                   enddo

CBIaAC                   enddo

     C                   endsr
ICB  *------------------------------------------------------------------
ICB  * verifyAllICB  - Verify all slots
ICB  *------------------------------------------------------------------
ICB
ICB  C     verifyAllICB  begsr

     C                   eval      kyWhse = pWhse#
     C     keySL2        setll     slot2

     C                   dow       forever = forever

     C     keySL2        reade     slot2
     C                   if        %eof
     C                   leave
     C                   endif

ICB  C**                 if        sldesg <> 'SPCL'
ICBbDC*                  if        slstat <> 'Z'
ICBbDC*                  iter
ICBbDC*                  endif

ICBbAC                   select
ICBbDC*                  if        sldesg = 'SPCL'
650bA*      This when statement was moved below the SPCL logic
ICBbA*      Verify all slots at Zero status.
650bDC*                  when          slstat = 'Z'
ICBbA*
ICBbA*      Verify active slots with SPCL or STAGE, if all qty's zero.
650bDC*                            or (sldesg = 'SPCL'
650bMC                   When      (sldesg = 'SPCL'
650aMC                             or  sldesg = 'STAGE')
650aDC*                            or  sldesg = 'STAGE'
     C
ICBbDC*                  if            slstk1 = 0
ICBbMC                             and slstk1 = 0
     C                             and slstk2 = 0
     C                             and slstk3 = 0
     C                             and slalc1 = 0
     C                             and slalc2 = 0
     C                             and slalc3 = 0
     C                             and slpck1 = 0
     C                             and slpck2 = 0
     C                             and slpck3 = 0
     C                             and slrcv1 = 0
     C                             and slrcv2 = 0
     C                             and slrcv3 = 0
     C                             and sltfr1 = 0
     C                             and sltfr2 = 0
650aMC                             and sltfr3 = 0
650aDC*                            and sltfr3 = 0)
ICBbDC*                            and sltfr3 = 0
640aA* Do not zero SPCL slots if overflow exists.
640aAC                   if        slpick = 'Y'
640aAC                             and sldesg = 'SPCL'
640aAC                   exsr      chkovr
640aAC                   if        nbrovr > 0
640aAC                   iter
640aAC                   endif
650aAC*
650aAC                   else
650aAC*     all others are to be ignored.
650aAC                   iter
ICBbA*
640aAC                   endif
ICBbA*
     *      Update slot status to Zero so that DRISLOT
     *      can process the SPCL and Zero Verify from the system.
ICBbAC                   if        slstat <> 'Z'
ICBbA*
     C     keysl1        chain     slot1
     C                   if        %found(slot1)
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   update    slrec1
     C                   endif
     C
     C                   endif
     C
ICBbDC**                 endif
     C
     C                   eval      kyWhse = slWhse
     C                   eval      kyWhdp = slWhdp
     C                   eval      kyDisp = slDisp
     C                   exsr      verifyOne
650bA*      Moved from above
650bM*      Verify all slots at Zero status.
650bMC                   when          slstat = 'Z'
650bAC                   eval      kyWhse = slWhse
650bAC                   eval      kyWhdp = slWhdp
650bAC                   eval      kyDisp = slDisp
650bAC                   exsr      verifyOne
FPRaA*
FPRaA*      Verify FoodPro Store Slots with Zero Quantity onhand
FPRaA*      Only for Virtual slots.
FPRaAC                   When      Client = FoodPro
FPRaAC                             and slstat = 'SR'
FPRaAC                             and slrsrv = 'V'
FPRaAC                             and slstk1 = 0
FRPaAC                             and slstk2 = 0
FPRaAC                             and slstk3 = 0
FRPaAC                             and slalc1 = 0
FPRaAC                             and slalc2 = 0
FRPaAC                             and slalc3 = 0
FPRaAC                             and slpck1 = 0
FPRaAC                             and slpck2 = 0
FPRaAC                             and slpck3 = 0
FPRaAC                             and slrcv1 = 0
FPRaAC                             and slrcv2 = 0
FRPaAC                             and slrcv3 = 0
FPRaAC                             and sltfr1 = 0
FPRaAC                             and sltfr2 = 0
FPRaAC                             and sltfr3 = 0
FPRaA*
FPRaAC     keysl1        chain     slot1
FPRaAC                   if        %found(slot1)
FPRaAC                   eval      slstat = 'Z '
FPRaAC                   eval      slsdte = today
FPRaAC                   time                    slstim
FPRaAC                   update    slrec1
FPRaAC
FPRaAC                   eval      kyWhse = slWhse
FPRaAC                   eval      kyWhdp = slWhdp
FPRaAC                   eval      kyDisp = slDisp
FPRaAC                   exsr      verifyOne
FPRaAC                   endif
FPRaA
ICBbAC                   endsl

     C                   enddo

     C                   endsr

     *------------------------------------------------------------------
     * verifyAllEI - Verify all SPCL slots - European Imports
     *------------------------------------------------------------------

EIb AC     verifyAllEI   begsr
EIb A
EIb AC                   eval      kyWhse = pWhse#
EIb AC     keySL2        setll     slot2
EIb A
EIb AC                   dow       forever = forever
EIb A
EIb AC     keySL2        reade     slot2
EIb AC                   if        %eof
EIb AC                   leave
EIb AC                   endif
EIb A
EIb AC                   if        sldesg <> 'SPCL'
EIb AC                             or slstat <> 'Z'
EIb AC                   iter
EIb AC                   endif
EIb A
EIb A*
EIb AC                   if        sldesg = 'SPCL'
EIb A*
EIb AC                   eval      unbropnlbl = 0
EIb AC                   exsr      zzckopnlbl
EIb A*      If one or more open labels, skip zero verify.
EIb AC                   if        unbropnlbl >= 1
EIb AC                   iter
EIb AC                   endif
EIb AC
EIb AC                   if            slstk1 = 0
EIb AC                             and slstk2 = 0
EIb AC                             and slstk3 = 0
EIb AC                             and slalc1 = 0
EIb AC                             and slalc2 = 0
EIb AC                             and slalc3 = 0
EIb AC                             and slpck1 = 0
EIb AC                             and slpck2 = 0
EIb AC                             and slpck3 = 0
EIb AC                             and slrcv1 = 0
EIb AC                             and slrcv2 = 0
EIb AC                             and slrcv3 = 0
EIb AC                             and sltfr1 = 0
EIb AC                             and sltfr2 = 0
EIb AC                             and sltfr3 = 0
EIb A*
EIb A*      Update slot status to Zero so that DRISLOT
EIb A*      can process the SPCL and Zero Verify from the system.
EIb AC     keysl1        chain     slot1
EIb AC                   if        %found(slot1)
EIb AC                   eval      slstat = 'Z '
EIb AC                   eval      slsdte = today
EIb AC                   time                    slstim
EIb AC                   update    slrec1
EIb AC                   endif
EIb AC
EIb AC                   endif
EIb AC
EIb AC                   endif
EIb AC
EIb AC                   eval      kyWhse = slWhse
EIb AC                   eval      kyWhdp = slWhdp
EIb AC                   eval      kyDisp = slDisp
EIb AC                   exsr      verifyOne
EIb A
EIb AC                   enddo
EIb A
EIb AC                   endsr
EIb A*------------------------------------------------------------------
     * verifyAllS - Verify all SPCL slots - Saval
     *------------------------------------------------------------------

640bAC     verifyAllS    begsr
SVL A
SVL AC                   eval      kyWhse = pWhse#
SVL AC     keySL2        setll     slot2
SVL
SVL AC                   dow       forever = forever
SVL
SVL AC     keySL2        reade     slot2
SVL AC                   if        %eof
SVL AC                   leave
SVL AC                   endif
SVL
SVL AC                   if        sldesg <> 'SPCL'
SVL AC                             or slstat <> 'Z'
SVL AC                   iter
SVL AC                   endif
SVL
SVL AC                   if        client = Savalfoods
SVL AC
SVL AC                   if        sldesg = 'SPCL'
SVL AC
SVL AC                   if            slstk1 = 0
SVL AC                             and slstk2 = 0
SVL AC                             and slstk3 = 0
SVL AC                             and slalc1 = 0
SVL AC                             and slalc2 = 0
SVL AC                             and slalc3 = 0
SVL AC                             and slpck1 = 0
SVL AC                             and slpck2 = 0
SVL AC                             and slpck3 = 0
SVL AC                             and slrcv1 = 0
SVL AC                             and slrcv2 = 0
SVL AC                             and slrcv3 = 0
SVL AC                             and sltfr1 = 0
SVL AC                             and sltfr2 = 0
SVL AC                             and sltfr3 = 0
SVL A*
SVL A*      Update slot status to Zero so that DRISLOT
SVL A*      can process the SPCL and Zero Verify from the system.
SVL AC     keysl1        chain     slot1
SVL AC                   if        %found(slot1)
SVL AC                   eval      slstat = 'Z '
SVL AC                   eval      slsdte = today
SVL AC                   time                    slstim
SVL AC                   update    slrec1
SVL AC                   endif
SVL AC
SVL AC                   endif
SVL AC
SVL AC                   endif
SVL AC
SVL AC                   endif
SVL AC
     C                   eval      kyWhse = slWhse
     C                   eval      kyWhdp = slWhdp
     C                   eval      kyDisp = slDisp
     C                   exsr      verifyOne

     C                   enddo

SVL  C                   endsr
    A
SGC A*------------------------------------------------------------------
640b * verifyAllSGC - Verify all SPCL slots - Springfield Grocer
     *------------------------------------------------------------------

640b C     verifyAllSGC  begsr
SGC AC
SGC AC                   eval      kyWhse = pWhse#
SGC AC     keySL2        setll     slot2
SGC AC
SGC AC                   dow       forever = forever
SGC AC
SGC AC     keySL2        reade     slot2
SGC AC                   if        %eof
SGC AC                   leave
SGC AC                   endif
SGC AC
SGC AC
SGC AC                   if           (sldesg = 'SPCL'
SGC AC                              or sldesg =  'SPCLC')
SGC AC                             and slstk1 = 0
SGC AC                             and slstk2 = 0
SGC AC                             and slstk3 = 0
SGC AC*
SGC AC                             and slalc1 = 0
SGC AC                             and slalc2 = 0
SGC AC                             and slalc3 = 0
SGC AC*
SGC AC                             and sltfr1 = 0
SGC AC                             and sltfr2 = 0
SGC AC                             and sltfr3 = 0
SGC AC*
SGC AC                             and slpck1 = 0
SGC AC                             and slpck2 = 0
SGC AC                             and slpck3 = 0
SGC AC*
SGC AC                             and slrcv1 = 0
SGC AC                             and slrcv2 = 0
SGC AC                             and slrcv3 = 0
640aAC                   if        slpick = 'Y'
640aAC                   exsr      chkovr
640aAC                   if        nbrovr > 0
640aAC                   iter
640aAC                   endif
640aAC                   endif
SGC AC*     Allow slot to be Zero verified.
SGC AC     keysl1        chain     slot1
SGC AC                   if        %found(slot1)
SGC AC                   eval      slstat = 'Z '
SGC AC                   update    slrec1
SGC AC                   endif
SGC AC*
SGC AC                   else
SGC AC*     all others are to be ignored.
SGC AC                   iter
SGC2AC                   endif
SGC AC*
     C                   eval      kyWhse = slWhse
     C                   eval      kyWhdp = slWhdp
     C                   eval      kyDisp = slDisp
     C                   exsr      verifyOne

     C                   enddo

     C                   endsr
DRYaA*------------------------------------------------------------------
DRYaA* verifyAllDRY - Verify all SPCL slots - Dairyland
     *------------------------------------------------------------------

DRYaAC     verifyAllDRY  begsr

DRYaAC                   eval      kyWhse = pWhse#
DRYcA /free
DRYcA    // zero verify all production slots
DRYcA    setll (pwhse#) plined;
DRYcA    reade (pwhse#) plined;
DRYcA    if not %equal(plined);
DRYcA       inrcvaisl = 'LIN';
DRYcA       inpckaisl = 'PRD';
DRYcA       instkaisl = 'PAR';
DRYcA       inwipaisl = 'WIP';
DRYcA    endif;
DRYcA /end-free
DRYaAC     keySL2        setll     slot2

DRYaAC                   dow       forever = forever

DRYaAC     keySL2        reade     slot2
DRYaAC                   if        %eof
DRYaAC                   leave
DRYaAC                   endif

DRYaAC                   if        slstat <> 'Z'
DRYbAC                             and slaisl <> '036'
DRYbAC                             or slstat <> 'Z'
DRYbAC                             and slaisl <> 'TRL'
DRYbAC                             or slstat <> 'Z'
DRYaAC                             and slloc = 999
DRYaAC                   iter
DRYaAC                   endif

DRYaAC
DRYaAC                   eval      kyWhse = slWhse
DRYaAC                   eval      kyWhdp = slWhdp
DRYaAC                   eval      kyDisp = slDisp
DRYaAC                   exsr      verifyOne

DRYaAC                   enddo

DRYaAC                   endsr
CDI A*
CDI A*------------------------------------------------------------------
CDI A* verifyCDI - Verify Specific slots - CDI
CDI A*------------------------------------------------------------------

CDI AC     verifyCdi     begsr

CDI AC                   select
CDI AC                   When      clientloc = Cdiatl

CDI AC                   eval      kyWhse = pWhse#
CDI AC                   eval      kyWhdp = 'DRY  '
CDI AC                   eval      kyAisl = ' 19'
CDI AC     keySL1cdi     setll     slot1

CDI AC                   dow       forever = forever

CDI AC     keySL1cdi     reade (n) slot1
CDI AC                   if        %eof(slot1)
CDI AC                   leave
CDI AC                   endif

CDI AC                   if        slstat = 'Z'

CDI AC                   eval      kyWhse = slWhse
CDI AC                   eval      kyWhdp = slWhdp
CDI AC                   eval      kyDisp = slDisp
CDI AC                   exsr      verifyOne
CDI AC                   endif

CDI AC                   enddo

CDI AC                   endsl

CDI AC                   endsr
CDI A*
EIb A*------------------------------------------------------------------
EIb A* Check for any open labels linked to whse/whdp/disp.
EIb A*------------------------------------------------------------------
EIb A
EIb AC     zzckopnlbl    begsr
EIb A
EIb AC*  Count # of open labels in LABEL12 file.
EIb AC*
EIb AC/EXEC SQL
EIb AC+  SELECT COUNT(*)
EIb AC+         INTO :unbropnlbl
EIb AC+  FROM   LABEL12
EIb AC+  WHERE  LBWHSE = :SLWHSE AND LBWHDP = :SLWHDP and LBDISP = :SLDISP
EIb AC+       or LBWHS2 = :SLWHSE AND LBWHD2 = :SLWHDP and LBDSP2 = :SLDISP
EIb AC/END-EXEC
EIb A
EIb AC                   endsr

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdriclose   Close any open files or programs.
     *----------------------------------------------------------------

     C     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      drierr = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #pgm          $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata

     C*                  select
     C*                  when      chk4err and %error
     C*                  endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C     enddricop     endsr
