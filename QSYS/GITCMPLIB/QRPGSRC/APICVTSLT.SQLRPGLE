     F*----------------------------------------------------------------
     F*   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     F*----------------------------------------------------------------
     F*
     F*  APICVTSLT   API to covert scanned slot
     F*  22 June 2000
     F*  Dave Sommerville
     F*
     F*----------------------------------------------------------------
     F*  Revisions
     F*
520aAF*   02/21/08  DAS  5.20a
     F*     - Added client code.
     F*     - Made hyphen logic standard.
     F*     - Made repositioning logic standard.
     F*     - Added in custom Cheney logic.
     F*
530aAF*   05/05/10  DAS  5.30a
     F*     - Added DRKa mod.
640aAF*   12/19/11  RH   6.40a
     F*     - Enh: Add Client location parm to GETCLIENT
710aAF*   01/27/17  RH/MLB   7.10a
     F*     - Fix: Was setting $PCOL one positon to right.
     F*
     F*----------------------------------------------------------------

     F*----------------------------------------------------------------
     F*  Custom Revisions - Cheney
     F*
CHY AF*    07/25/00  DAS  CHY
     F*      - Revised to add 1 to column position if = 5.
     F*        This was done because Symbol scanners only scan into
     F*        the first position of a field instead of where the
     F*        cursor lies. Therefore, in order to do double scanning
     F*        the slot field had to be split into two parts with 1
     F*        character inbetween.
     F*
CHY AF*    08/02/00  DAS  CHY2
     F*      - Revised to remove imbedded blanks from slot number.
     F*        This was done because Symbol scanners would not allow
     F*        overflowing to second fields. Therefore, we needed to
     F*        make the first field 7-characters in order to accommodate
     F*        a single scan.
     F*      - Revised to add 3 to column position if = 5.
CBI AF*    09/08/15  MLB  CBI
     F*      - Revised CHY mod. Program uses single input field. Revised
     F*        program to position scanned data + 1 after first scan.
     F*        First scan: co095. Second scan:co0951 rack level is added
     F*        and then dashes are inserted to send slot back as
     F*        CO-095-1.
CBIaAF*    09/08/15  MLB  CBIa
     F*      - Revised CHY mod. Punta Gorda slot barcodes have dash em-
     F*        bedded. Need to revise slot length tests to look for 6
     F*        as well as 5.
CBIbAF*    03/01/17  MLB  CBIb
     F*      - Revised pgm to add support for new Pate Dawson warehouses
     F*        that have non-std format BFC slots. Need to insert dash
     F*        into slot display value as BC-12-34.
CBIcAF*    08/16/17  MLB  CBIc
     F*      - Revised CBIc mod to add support to Goldsboro, Greensboro
     F*        whses for std format BFC slots and to not insert dashes.
     F*        Scanned value will have dashes already inserted.
     F*        CBI proj# 2017144.
CBIdAF*    09/17/17  MLB  CBId
     F*      - Revised CBIc mod to add support to Goldsboro, Greensboro
     F*        whses for std format BFC slots and to not insert dashes.
     F*        Scanned value will have dashes already inserted.
     F*        CBI proj# 2017144.
CBIeAF*    11/03/17  MLB  CBIe
     F*      - Revised CBIc mod to add support for Greensboro
     F*        whses for std format BFC slots and to not insert dashes.
CBIfAF*    04/06/18  MLB  CBIf  P# 2018053
     F*      - Revised CBIc mod to allow for embedded dashes to be re-
     F*        moved and re-positioned for scanning rack level.
     F*
     F*----------------------------------------------------------------

     F*----------------------------------------------------------------
     F*  Custom Revisions - City Wholesale
     F*
CTYaAF*    02/26/08  DAS  CTYa
     F*      - Temporary change to allow a mix of slot with and
     F*        without dashes.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Coastal Sunbelt Produce
     F*
CSP AF*    04/22/10  MLB  CSP
     F*      - Revised program to check length of slot, then treat
     F*        scanned data as slot with single character aisle
     F*        else treat scanned data as having double character aisle.

     F*----------------------------------------------------------------
     F*  Custom Revisions - Dierk's Waukesha
     F*
DRKaAF*    05/04/10  DAS  DRKa
     F*      - Created special method for determining double scan.
DRKbAF*    05/04/11  DAS  DRKb
     F*      - Enh: changed to do single scans for the following
     F*        aisle D5, D6, D7, D8, D9, R9, F1, F2 and F3.
     F*----------------------------------------------------------------
     F*  Custom Revisions - CDI
     F*
CDIa F*    12/19/11  RH   CDIa
     F*      - Change to scan dashes and remove them from slot for
     F*        JAX whse 1.
CDIb F*    12/28/11  RH   CDIb
     F*      - Change to add ' ' after aisle for 5 long slot,  for
     F*        JAX whse 1.
CDIc F*    12/28/11  RH   CDIc
     F*      - If edited slot is 5 long, add ' ' after aisle,  for
     F*        JAX whse 1.
CDId F*    04/16/13  RH   CDId
     F*      - Fix: Revised pgm for Jax to handle special situations
     F*        in DRY dept with embedded blanks in char 2 of aisle
CDIe F*    07/10/14  MLB  CDIe
     F*      - Enh: Revised pgm to accept scanned value and return to
     F*        calling pgm.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Crumbley
     F*
CPCa F*    04/25/11  GJA  CPCa
     F*      - Do NOT process for any slots, no edit needed.
CPCbAF*    06/20/11  MLB  CPCb
     F*      - Revised program to allow it to scan for dashes
     F*        and remove them, if found. No 2nd scan required.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Glazier
     F*
GFCaAF*    07/20/11  GJA  GFCa
     F*      - Do NOT process for any slots, no edit needed.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - H&M Wagner
     F*
HMWaAF*    09/10/12  GJA  HMWa
     F*      - Do NOT process for any slots, no edit needed.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Accardi
     F*
ACCa F*    04/17/19  GJA  ACCa
     F*      - Revised pgm to check for embedded dashes in slot and if
     F*        not found, insert them and send back updated slot.
     F*        Temporary fix for OR400 missing dash on keyboard
     F*----------------------------------------------------------------
     F*  Custom Revisions - Jordanos
     F*
JDOaAF*    09/07/10  RH   JDOa
     F*      - Do NOT process for any slots, no edit needed.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Jack Palmer
     F*
JPFaAF*    09/11/17  RH   JPF
     F*      - Do NOT process for any slots, no edit needed.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Menu Maker
     F*
GMMa F*    06/14/12  GJA  GMMa
     F*      - Do NOT process for any slots, no edit needed.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Presto
     F*
PFCa F*    09/15/14  GJA  PFCa
     F*      - Created special method for determining double scan.
PFCb F*    10/05/18  DAS  PFCb
     F*      - Moved PFCa logic to after logic to add hyphens.
     F*        PFC added new racks and barcodes don't include hyphens.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Royal
     F*
RYLaAF*    08/12/10  RH   RYLa
     F*      - Do NOT add missing '-' for slot, they have OPPOFFICE
     F*        slots and want to enter as displayed.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - ISupply
     F*
ISYaAF*    07/15/11  GJA  ISYa
     F*      - Add missing '-' for slot.
     F*----------------------------------------------------------------
     F*  Custom Revisions - European Imports
     F*
EI  AF*    07/27/11  MLB  EI
     F*      - Do NOT process for any slots, no edit needed.
EIa AF*    08/15/11  MLB  EIa  P#01047
     F*      - Disabled above mod. Use value passed into slot to
     F*        find Dakota slot info using slot cross-ref file.
     F*        If scanned data not found in slot cross-ref, then
     F*        pass back scanned value.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Fischer
     F*
FSHa F*    12/08/14  GJA  FSHa
     F*      - Do NOT add missing '-' for slot display less than 5 long
FSHb F*    02/10/15  RH   FSHb
     F*      - Fix: Change to not add '-' for slot display starting
     F*        with alpha.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Avalon Foodservice
     F*
AVL AF*    10/12/11  MLB  AVL
     F*      - Use value passed into pgm to find Dakota slot info
     F*        using slot cross-ref file.
     F*        If scanned data not found in slot cross-ref, then
     F*        pass back scanned value.
     F*      - Added AVL to EIa mod.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - VIP
     F*
VIPaAF*    05/25/12  RH   VIPa
     F*      - Do NOT process for any slots, no edit needed.
     F*
     F*----------------------------------------------------------------
     F*  Client Custom Revisions - Greenleaf Produce
     F*
GLP AF*    04/08/13  MLB  GLP
     F*      - Revised pgm to insert dash in 5th position of scanned
     F*        data. 1234A ====> 1234-A.
     F*
GLPaAF*    08/08/13  KDE  GLPa
     F*      - Revised change GLP above to only do this when the
     F*        scanned slot is not blanks
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Saval Foods
     F*
SVL AF*    07/21/09  MLB  SVL
     F*      - Revised program to not alter the slot display value
     F*        as passed into the program.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Sofo
     F*
SOFa F*    01/14/15  JCJ  SOFa
     F*      - Do NOT process for any slots, no edit needed.
     F*----------------------------------------------------------------
SGC  F*  Custom Revisions - Springfield Grocer
     F*    01/16/12  RH   SGCa
     F*      - Do NOT process for any slots, no edit needed.
     F*    01/26/17  MLB  SGCb
     F*      - Temporary change to allow a mix of slot with and
     F*        without dashes.
     F*      - Disabled SGCa mod.
     F*      - Added SGCb to CTYa mod.
     F*
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Kohl Wholesale
     F*
KHL  F*    07/30/14  RTR  KHL
     F*      - Do NOT process for any slots, no edit needed.
     F*        Add to MenuMaker mod.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Will Foods
     F*
WIL  F*    08/31/14  RTR  WIL
     F*      - Do NOT process for any slots, no edit needed.
     F*        Add to MenuMaker mod.
WILaAF*    09/10/14  MLB  WILa
     F*      - Removed above mod.
     F*      - Revised pgm to check for embedded dashes in slot and if
     F*        not found, insert them and send back updated slot.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Jordanos
     F*
FPR AF*    02/17/15  MLB  FPR
     F*      - Do NOT process for any slots, no edit needed.
     F*      - Added FPR to JDOa mod.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Panos Foods
PAN AF*    03/13/17  RH   PANa
     F*      - Add to CBI mods. Positon scanned data + 1 after first
     F*        scan. Secon scan rack level is added.  Has dash embedded
PANbAF*    04/27/17  MLB  PANb
     F*      - Revised PANa mod. Revised pgm to add support for scanning/
     F*        entering slots for repack replenishments. RPK-101-1xx.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Seashore Fruit & Produce
SFP AF*    02/19/18  MLB  SFP
     F*      - Revised pgm to add support for non-std BFC slots.
     F*        Need to insert dash into slot display value as 02-17-A.
SFPaAF*    02/22/18  DAS  SFPa
     F*      - Revised to handle slots like 02-17-AB.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - CPJ Caribbean Producers Jamaica
CPJaAF*    02/04/20  RH   CPJa
     F*      - Revised pgm to add support for non=std BFC slots.
     F*        Need to insert dash into slot display value as AA-101-1
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Greco
GRCa F*    05/29/18  RH   GRCa
     F*      - Do NOT process for any slots, no edit needed.
     F*        Add to MenuMaker mod.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Holt Paper Company
HPCa F*    12/06/19  RTR  HPCa
     F*      - Do NOT process for any slots, no edit needed.
     F*        Add to MenuMaker mod.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Sunrise
SUNa F*    08/19/20  RTR  SUNa
     F*      - Add missing '-' for slot.
     F*----------------------------------------------------------------
     F*  Custom Revisions - Balford
BALa F*    06/30/21  RH   BALa
     F*      - Do NOT process for any slots, no edit needed.
     F*
     F*----------------------------------------------------------------
     F*  Custom Revisions - Dependable
DFCa F*    07/15/20  RH   DFCa
     F*      - Change to add '-' after aisle, have 1 or 3 char aisles.
DFCb F*        pos 2 for slot 5 long, pos 4 for slot > 5 positions
     F*    07/15/21  RH   DFCb
     F*      - Change to add '-' after aisle, have 1,2 or 3 char aisles
     F*
     F*----------------------------------------------------------------

     C*----------------------------------------------------------------
     C*  Notes
     C*
     C*    This program is called from RF programs that allow the
     C*    scanning of a slot. In most situations there is nothing extra
     C*    that need to be done. However, in some situations, a client
     C*    may need to revise this program in order to add hyphens to
     C*    the scanned slot number.
     C*
     C*    Any program calling this API allows the repositioning of
     C*    the cursor within the slot entry field. This would be used
     C*    when a user must do a double scan to get the complete slot
     C*    number. For example, the first scan would get the aisle and
     C*    location. The second scan would get the level and handstack.
     C*    In that situation, you would want to identify that only the
     C*    first part of the slot was scanned and then reposition the
     C*    cursor just after those characters, waiting for the second
     C*    scan.
     C*
     C*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

CTYaAFslotcw    if   e           k disk    usropn

500aA *----------------------------------------------------------------
500aA *  Customer id
500aA *----------------------------------------------------------------
500aA /copy qcopysrc,id#cheney
CBIaA /copy qcopysrc,id#cheneyp
CTYaA /copy qcopysrc,id#citywho
CSP A /copy qcopysrc,id#coastal
500aA /copy qcopysrc,id#royal
JDOaA /copy qcopysrc,id#jordano
JPFaA /copy qcopysrc,id#palmer
CPCaA /copy qcopysrc,id#cpc
ISYaA /copy qcopysrc,id#isupply
EI  A /copy qcopysrc,id#ei
CDIaA /copy qcopysrc,id#cdi
CDIeA /copy qcopysrc,id#cdijac
GFCaA /copy qcopysrc,id#glazier
AVL A /copy qcopysrc,id#avalon
VIPaA /copy qcopysrc,id#vip
GMMaA /copy qcopysrc,id#gmm
HMWaA /copy qcopysrc,id#hmwagne
GLP A /copy qcopysrc,id#glp
SVL A /copy qcopysrc,id#saval
SGC A /copy qcopysrc,id#sgc
KHL A /copy qcopysrc,id#khl
WIL A /copy qcopysrc,id#wil
PFCaA /copy qcopysrc,id#pfc
SOFaA /copy qcopysrc,id#sofo
FSHaA /copy qcopysrc,id#fischer
FPR A /copy qcopysrc,id#fpr
PAN A /copy qcopysrc,id#pan
SFP A /copy qcopysrc,id#sfp
GRCaA /copy qcopysrc,id#grc
ACCaA /copy qcopysrc,id#acc
VFIaA /copy qcopysrc,id#vfi
CPJaA /copy qcopysrc,id#cpj
HPCaA /copy qcopysrc,id#hpc
SUNaA /copy qcopysrc,id#sun
BALaA /copy qcopysrc,id#bal
DFCaA /copy qcopysrc,id#dfc

     D*----------------------------------------------------------------
     D*  Variable definitions
     D*----------------------------------------------------------------
CHY2AD A12A            S              1A   Dim(12)
CHY2AD A12B            S              1A   Dim(12)
CHY2AD Forever         S              1S 0
CHY2AD I               S              3P 0
CHY2AD J               S              3P 0
     D SlotLength      S              3P 0
DRKaAD period          S              3P 0
DRKaAD hyphen          S              3P 0
DRKaAD singleScan      S               n

DRKaA *----------------------------------------------------------------
DRKaA *  File data data structure
DRKaA *----------------------------------------------------------------
DRKaA
DRKaAD slot          E ds
EIa AD slotxrf2      E ds

DRKaA *----------------------------------------------------------------
DRKaA*  Standard SQL variables and constants
DRKaA*----------------------------------------------------------------
DRKaA
DRKaA /copy qcopysrc,c#stdsql

     C*----------------------------------------------------------------
     C*  Parameters
     C*
     C*    Input Parameters
     C*      $PSlot     Slot number entered on screen
     C*      $PRow      Row position of slot on input screen.
     C*      $PCol      Column position of slot on input screen.
     C*
     C*    Returned Parameters
     C*      $PSlot     Converted slot (optional)
     C*      $PRow      Row to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PCol      Column to reposition the cursor.
     C*                   If zero, no repositioning is done.
     C*      $PReturn   *OK       Everything is ok. Move on.
     C*                 *REDSPLY  Redisplay with cusor positioning.
     C*
     C*----------------------------------------------------------------
     C*  Let the show begin .....
     C*
     C     *ENTRY        PLIST
     C                   PARM                    $PSlot           12
     C                   PARM                    $PRow             3 0
     C                   PARM                    $PCol             3 0
     C                   PARM                    $PReturn          8

DRKaAC                   eval      $PReturn = '*OK'
     C*----------------------------------------------------------------
     C* Main line
CTYaA
CTYaAC*  The following custom logic for City Wholesale should be
CTYaAC*  temporary. This logic was added to allow City Wholesale
CTYaAC*  to handle a mix of slot displays, some that have dashes
CTYaAC*  and some that don't. Temporary logical file SLOTCW was
CTYaAC*  created to verify the slot sent in because we do not
CTYaAC*  have a warehouse or department being sent in.
CTYaA
CTYaAC                   if        client = citywholesale
SGCaAC                             or client = sgc
CTYaA
CTYaAC*    If slot exists, return.
CTYaAC*    Otherwise, process input using normal formatting logic.
CTYaA
CTYaAC                   if        not %open(slotcw)
CTYaAC                   open      slotcw
CTYaAC                   endif
CTYaAC*
CTYaAC     $pSlot        chain     slotcw
CTYaAC                   if        %found
CTYaAC                   eval      $PRow = 0
CTYaAC                   eval      $PCol = 0
CTYaAC                   eval      $PReturn = '*OK'
CTYaAC                   goto      bottom
CTYaAC                   endif
CTYaA
CTYaAC                   endif

JDOaAC                   if        client = jordanos
SGCbDC*                            or client = sgc
GFCaDC                             or client = glazier
CDIaAC                             or client = cdi
CDIaAC                             and clientloc = 'CDIATL'
CDIeAC                             or client = cdi
CDIeAC                             and clientloc = cdijacksonms
HMWaAC                             or client = hmwagner
CPCbDC*                            or client = cpc
EIa DC*                            or client = ei
VIPaAC                             or client = vip
GMMaAC                             or client = menumaker
SOFaAC                             or client = sofo
KHL AC                             or client = kohl
FPR AC                             or client = FoodPro
HPCaAC                             or client = HoltPaper
JPFaAC                             or client = palmer
GRCaAC                             or client = Greco
BALaAC                             or client = balford
JDOaAC*  Don't need to position cursor so set Row/Col to zero.
JDOaAC*
JDOaAC                   eval      $PRow = 0
JDOaAC                   eval      $PCol = 0
JDOaAC*
JDOaAC                   eval      $PReturn = '*OK'
JDOaAC                   goto      Bottom
JDOaAC                   endif
CDI  C*
CDIbAC*  Check if scan needs blank added after aisle to match sldisp
CDIbAC*
CDIbAC                   if        client = cdi
CDIbAC                             and clientloc = 'CDIJAX'
CDIdAC*  Replace char 2 '-' with ' '
CDIdAC                   if        %Subst($PSlot:2:1) = '-'
CDIdAC                   eval      $PSlot = %Subst($Pslot:1:1) + ' ' +
CDIdAC                                      %Subst($PSlot:3:10)
CDIdAC                   endif
CDIdAC*
CDIbAC                   eval      SlotLength = %Len(%Trim($PSlot))
CDIbAC                   if        SlotLength = 5
CDIbAC                   eval      $PSlot = %Subst($PSlot:1:1) + ' ' +
CDIbAC                                      %Subst($PSlot:2:4)
CDIbAC*  Don't need to position cursor so set Row/Col to zero.
CDIbAC*
CDIbAC                   eval      $PRow = 0
CDIbAC                   eval      $PCol = 0
CDIbAC*
CDIbAC                   eval      $PReturn = '*OK'
CDIbAC                   goto      Bottom
CDIbAC                   endif
CDIbAC                   endif
FSHa C*
FSHaAC*  Check if slot is less than 5, if not add missing dashes
FSHbAC*  Check if slot starts with alpha, if not add missing dashes
FSHaAC*
FSHaAC                   if        client = FischerFoods
FSHaAC*
FSHaAC                   eval      SlotLength = %Len(%Trim($PSlot))
FSHaAC*      If slot length is <= 4, then do not add "-"
FSHbAC**                 if        SlotLength <= 5
FSHaAC*  Don't need to position cursor so set Row/Col to zero.
FSHbAC                   monitor
FSHbAC                   eval      I = %dec(%subst($Pslot:1:1):3:0)
FSHbAC                   on-error
FSHaAC*
FSHaAC                   eval      $PRow = 0
FSHaAC                   eval      $PCol = 0
FSHaAC                   eval      $PReturn = '*OK'
FSHaAC                   goto      Bottom
FSHbMC                   endmon
FSHbDC**                 endif
FSHaAC                   endif
GLP  C*
GLP AC*  Check if scan needs dash added in 5th position of sldisp
GLP AC*
GLP AC                   if        client = greenleaf
GLPaAC                               and $PSlot <> ' '
GLPaAC                               and %Subst($PSlot:1:3)<>'RPK'
GLP AC*
GLP AC                   eval      SlotLength = %Len(%Trim($PSlot))
GLP AC                   if        %subst($pslot:5:1) <> '-'
GLP AC                   eval      $PSlot = %Subst($PSlot:1:4) + '-' +
GLP AC                                      %Subst($PSlot:5:8)
GLP AC*  Don't need to position cursor so set Row/Col to zero.
GLP AC*
GLP AC                   eval      $PRow = 0
GLP AC                   eval      $PCol = 0
GLP AC*
GLP AC                   eval      $PReturn = '*OK'
GLP AC                   goto      Bottom
GLP AC                   endif
GLP AC*
GLP AC                   endif
WILaAC*
WILaAC*  Check if scan needs dashes added to sldisp.
WILaAi*
WILaAC                   if        client = Willfoods
WILaAC                   exsr      zzcvtslotwil
WILaAC                   eval      $PReturn = '*OK'
WILaAC                   goto      Bottom
WILaAC                   endif
ACCaAC*
ACCaAC*  Check if scan needs dashes added to sldisp.
ACCaAi*
ACCaAC                   if        client = Accardi
ACCaAC                   exsr      zzcvtslotACC
ACCaAC                   eval      $PReturn = '*OK'
ACCaAC                   goto      Bottom
ACCaAC                   endif
SFP AC*
SFP AC*  Check if scan needs dashes added to sldisp.
SFP Ai*
SFP AC                   if        client = Seashore
SFP AC                   exsr      zzcvtslotsfp
SFP AC                   eval      $PReturn = '*OK'
SFP AC                   goto      Bottom
SFP AC                   endif
CPJaAC*
CPJaAC*  Check if scan needs dashes added to sldisp.
CPJaAi*
CPJaAC                   if        client = CPJ
CPJaAC                   exsr      zzcvtslotcpj
CPJaAC                   eval      $PReturn = '*OK'
CPJaAC                   goto      Bottom
CPJaAC                   endif
DFCaAC*
DFCaAC*  Check if scan needs dashes added to sldisp.
DFCaAi*
DFCaAC                   if        client = dependable
DFCaAC                   exsr      zzcvtslotdfc
DFCaAC                   eval      $PReturn = '*OK'
DFCaAC                   goto      Bottom
DFCaAC                   endif
CHY2AC*
CHY2AC*  Remove imbeded blanks from slot number.
CHY2AC*
CHY2AC                   movea     $PSlot        A12A
CHY2AC                   movea     *Blanks       A12B
CHY2AC                   eval      J = 0
CHY2AC     1             do        12            I
CHY2AC                   if        A12A(I) <> ' '
CPCbAC                             and client <> cpc
CDIaAC                             and client <> cdi
CDIaAC                             and clientloc <> 'CDIJAX'
CBIaAC                             and client <> Cheney
PANaAC                             and client <> panos
CPCbAC*
CPCbAC*  Remove imbeded dashes from slot number.
CPCbAC                             or (A12A(I) <> ' '
CPCbAC                             and A12A(I) <> '-')
CPCbAC                             and client = cpc
CPCbAC*
CDIaAC*
CDIaAC*  Remove imbeded dashes from slot number.
CDIdDC*                            or (A12A(I) <> ' '
CDIdDC*                            and A12A(I) <> '-')
CDIdMC                             or A12A(I) <> '-'
CDIaMC                             and (client = cdi
CDIaAC                             and clientloc = 'CDIJAX'
PANaAC                              or  client = panos
CBIeMC                              or  client = Cheney)
CBIeDC**                           and clientloc <> cbigr)
CBIdDC**                           and clientloc <> cbigo)
CDIaAC*
CHY2AC                   eval      J = J + 1
CHY2AC                   eval      A12B(J) = A12A(I)
CHY2AC                   endif
CHY2AC                   enddo
CBIcAC*
CBIfDC*                  if             client = Cheney
CBIfDC*                            and (clientloc = cbigr)
CBIdDC**                            or  clientloc = cbigo)
CBIcAC*
CBIfDC*                  else
CBIcAC*
CHY2AC                   movea     A12B          $PSlot
CBIfDC*                  endif
CDIc C*
CDIcAC*  If edited slot is 5 long, needs ' ' after aisle to = sldisp
CDIcAC*
CDIcAC                   if        client = cdi
CDIcAC                             and clientloc = 'CDIJAX'
CDIcAC                   eval      SlotLength = %Len(%Trim($PSlot))
CDIcAC                   if        SlotLength = 5
CDIcAC                   eval      $PSlot = %Subst($PSlot:1:1) + ' ' +
CDIcAC                                      %Subst($PSlot:2:4)
CDIcAC*  Don't need to position cursor so set Row/Col to zero.
CDIcAC*
CDIcAC                   eval      $PRow = 0
CDIcAC                   eval      $PCol = 0
CDIcAC*
CDIcAC                   eval      $PReturn = '*OK'
CDIcAC                   goto      Bottom
CDIcAC                   endif
CDIcAC                   endif
EIa AC*
EIa AC                   if        client = EI
AVL AC                             or client = Avalon
EIa AC                   exsr      SlotCrossRef
EIa AC                   goto      Bottom
EIa AC                   endif
CPCbAC*
CPCbAC                   if        client = cpc
CDIaAC                             or client = cdi
CDIaAC                             and clientloc = 'CDIJAX'
CPCbAC*  Don't need to position cursor, so set Row/Col to zero.
CPCbAC                   eval      $PRow = 0
CPCbAC                   eval      $PCol = 0
CPCbAC                   goto      Bottom
CPCbAC*
CPCbAC                   endif
414 AC*
414 AC*  First check length. If <= 5 the reposition.
414 AC*
CSP AC                   if        client = CoastalSunbelt
SUNaAc                             or client = Sunrise
CSP AC*         Skip this portion.
CSP AC                   else
     C                   eval      SlotLength = %Len(%Trim($PSlot))
     C                   if        SlotLength <= 5
     C                   eval      $PCol = $PCol + SlotLength
CHY AC                   if        client = cheney
PANaAC                             or client = panos
CHY AC                   if        SlotLength = 5
CBIaAC                             and clientloc <> cheneypntgr
CBIaA*
CBIaAC                             or SlotLength = 6
CBIfMC                             and (clientloc = cheneypntgr
CBIfAC                             or clientloc = cbigr)
CBIaA*
CBI DC*                  eval      $PCol = $PCol + 3
CHY AC                   endif
CHY AC                   else
710aAC                   if        SlotLength > 0
     C                   eval      $PCol = $PCol + 1
710aAC                   endif
CHY AC                   endif
SVL AC*
SVL AC                   if        client <> SavalFoods
SVL AC                             and client <> Vitco
     C                   eval      $PReturn = '*REDSPLY'
     C                   goto      Bottom
SVL AC                   endif
     C                   endif
SVL AC*
CSP AC
CSP AC                   endif
DRKaAC*
DRKaAC*  Special handeling for Dierk's Waukesha
DRKaAC*
DRKaAC*    - Dierk's barcodes contain display value (DA-101-1)
DRKaAC*    - Level barcodes will contain the level followed by a period ('1.')
DRKaAC*    - If period is found, remove and treat as second scan.
DRKaAC*    - If period not found, treat as first scan.
DRKaAC*    - They have some slot defs they only want scanned once.
DRKaAC*
DRKaMC                   if        client = 'DIERKS'
PFCbDC**                           or client = 'PRESTOFOOD'
DRKaAC                   exsr      PeriodMethod
DRKaAC                   if        $PReturn = '*REDSPLY'
DRKaAC                   goto      Bottom
DRKaAC                   endif
DRKaAC                   endif
414 AC*
414 AC*  Add hyphens to slot, if needed.
414 AC*
414 AC*     Add hyphens if slot doesn't already contain them.
414 AC*
RYLaAC                   if        client <> royal
ISYaAC                             and client <> isupply
SVL AC                             and client <> SavalFoods
SUNaAc                             and client <> Sunrise
     C                   if        %Scan('-':$PSlot) = 0
CSP AC*
CBIbAC                   select
CBIbMC                   when      client = CoastalSunbelt
CSP AC*
CSP AC                   eval      SlotLength = %Len(%Trim($PSlot))
CSP AC*      If slot length is <= 5, then this is a single character aisle.
CSP AC                   if        SlotLength <= 5
CSP AC                   eval      $PSlot = %Subst($PSlot:1:1) + '-' +
CSP AC                                      %Subst($PSlot:2:3) + '-' +
CSP AC                                      %Subst($PSlot:5:8)
CSP AC                   else
CSP AC*      If slot length is > 5, then this is a double character aisle.
CSP AC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
CSP AC                                      %Subst($PSlot:3:3) + '-' +
CSP AC                                      %Subst($PSlot:6:5)
CSP AC                   endif
CSP AC
PANbAC                   when      client = Panos
PANbAC                   if        %Subst($PSlot:1:3) = 'RPK'
PANbAC                   eval      $PSlot = %Subst($PSlot:1:3) + '-' +
PANbAC                                      %Subst($PSlot:4:3) + '-' +
PANbAC                                      %Subst($PSlot:7:6)
PANbAC                   else
PANbAC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
PANbAC                                      %Subst($PSlot:3:3) + '-' +
PANbAC                                      %Subst($PSlot:6:5)
PANbAC                   endif
PANbAC*

CBIbAC                   when          client = Cheney
CBIbAC                             and (clientloc = cbigr
CBIbAC                               or clientloc = cbigo
CBIbAC                               or clientloc = cbist)
CBIbAC                   exsr      cvt_cbipd
CBIbA
CBIbMC                   other
CSP AC
     C                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
     C                                      %Subst($PSlot:3:3) + '-' +
     C                                      %Subst($PSlot:6:5)
CBIbMC                   endsl
CSP AC
     C                   endif
RYLaAC                   endif
PFCbAC*
PFCbAC                   if        client = 'PRESTOFOOD'
PFCbAC                   exsr      PeriodMethod
PFCbAC                   if        $PReturn = '*REDSPLY'
PFCbAC                   goto      Bottom
PFCbAC                   endif
PFCbAC                   endif
ISYaAC*
ISYaAC*     Add hyphens if slot doesn't already contain them.
ISYaAC*
ISYaAC                   if        client = isupply
     C                   if        %Scan('-':$PSlot) = 0
     C                   if        SlotLength= 6
     C                   eval      $PSlot = %Subst($PSlot:1:1) + '-' +
     C                                      %Subst($PSlot:2:3) + '-' +
     C                                      %Subst($PSlot:5:2)
     C                   endif
     C                   if        SlotLength= 7
     C                   movel     $PSlot        SPDChk            3
     C                   if        SPDChk<> 'SPD'
     C                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
     C                                      %Subst($PSlot:3:3) + '-' +
     C                                      %Subst($PSlot:6:2)
     C                   else
     C                   eval      $PSlot = %Subst($PSlot:1:3) + '-' +
     C                                      %Subst($PSlot:4:3) + '-' +
     C                                      %Subst($PSlot:7:1)
     C                   endif
     C                   endif
     C                   endif
ISYaAC                   endif

SUNaA /free
SUNaA    if client = Sunrise and %Scan('-':$PSlot) = 0;
SUNaA      SlotLength = %Len(%Trim($PSlot));
SUNaA      select;
SUNaA        when SlotLength = 5;
SUNaA          $PSlot = %subst($PSlot:1:1) + '-' +
SUNaA                   %subst($PSlot:2:3) + '-' +
SUNaA                   %subst($PSlot:5:2);
SUNaA        when SlotLength = 6;
SUNaA          if %subst($PSlot:2:1) = '0';
SUNaA            $PSlot = %subst($PSlot:1:1) + '-' +
SUNaA                     %subst($PSlot:2:3) + '-' +
SUNaA                     %subst($PSlot:5:1) + '-' +
SUNaA                     %subst($PSlot:6:2);
SUNaA          else;
SUNaA            $PSlot = %subst($PSlot:1:2) + '-' +
SUNaA                     %subst($PSlot:3:3) + '-' +
SUNaA                     %subst($PSlot:6:1);
SUNaA          endif;
SUNaA        when SlotLength >= 7;
SUNaA          $PSlot = %subst($PSlot:1:3) + '-' +
SUNaA                   %subst($PSlot:4:3) + '-' +
SUNaA                   %subst($PSlot:7:2);
SUNaA      endsl;
SUNaA    endif;
SUNaA /end-free

     C*
     C*  Don't need to position cursor so set Row/Col to zero.
     C*
     C                   eval      $PRow = 0
     C                   eval      $PCol = 0
     C*
     C                   eval      $PReturn = '*OK'
     C     bottom        tag
     C                   Return

     C*----------------------------------------------------------------
     C* *INZSR  Initialization subroutine
     C*----------------------------------------------------------------
     C     *inzsr        begsr
      *
      * Get client id.
      *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
640aAC                   parm                    clientloc        10

     C                   endsr

DRKaAC*----------------------------------------------------------------
DRKaAC* chkSingleScan  Check for single scan slot
DRKaAC*----------------------------------------------------------------
DRKaA
DRKaA /free
DRkaA  begsr ChkSingleScan;

         singleScan = *off;

         // Get slot record.
         //   Assumptions:
         //     - single warehouse
         //     - slot numbers are unique within the warehouse.

         exec sql select * into :slot
                  from slot
                  where sldisp = :$pslot;

         // Leave if not found

         if sqlstt <> sqlSuccess;
           leavesr;
         endif;

         // Otherwise, see if it is a single scan definition

PFCaA    if client = 'DIERKS';
            if slsdef = 'XX'
            or slsdef = 'YY'
DRKbA       or slaisl = ' D5'
DRKbA       or slaisl = ' D6'
DRKbA       or slaisl = ' D7'
DRKbA       or slaisl = ' D8'
DRKbA       or slaisl = ' D9'
DRKbA       or slaisl = ' R9'
DRKbA       or slaisl = ' F1'
DRKbA       or slaisl = ' F2'
DRKbA       or slaisl = ' F3';
              singleScan = *on;
            endif;
PFCaA    endif;

       endsr;
      /end-free

CBIbAC*----------------------------------------------------------------
CBIbAC* Slot Conversion - Cheney Pate Dawson
CBIbAC*----------------------------------------------------------------

CBIbA /free
CBIbA  begsr cvt_cbipd;

CBIcA                    select;
CBIcA                    when          %subst($PSlot:4:1) = '-'
CBIcA                              and %subst($PSlot:8:1) = '-'
CBIeM                             or (clientloc = cbigo
CBIeA                             or  clientloc = cbigr)
CBIdA                             and %subst($PSlot:3:1) = '-'
CBIdA                             and %subst($PSlot:7:1) = '-';
CBIcA    // No changes needed. Slot already in correct format.

CBIcA    // Goldsboro. New BFC slot format. No dashes scanned. Insert them
CBIeM                    when     (clientloc = cbigo
CBIeA                             or  clientloc = cbigr)
CBIdA                             and %subst($PSlot:3:1) <> '-'
CBIdA                             and %subst($PSlot:7:1) <> '-';
CBIdA                    $PSlot = %Subst($PSlot:1:2) + '-' +
CBIdA                             %Subst($PSlot:3:3) + '-' +
CBIdA                             %Subst($PSlot:6:7);

CBIcA                    other;
CBIbA                    $PSlot = %Subst($PSlot:1:2) + '-' +
CBIbA                             %Subst($PSlot:3:2) + '-' +
CBIbA                             %Subst($PSlot:5:8);
CBIcA                    endsl;

CBIbA  endsr;
CBIbA /end-free

DRKaAC*----------------------------------------------------------------
DRKaAC* PeriodMethod  Double scan using period method
DRKaAC*----------------------------------------------------------------
DRKaA
DRKaA /free
DRkaA  begsr PeriodMethod;

         // Look for period in slot number.

         period = %scan('.': $pslot);

         // If period found,
         //   then this is second scan,
         //        so remove period and return.

         if period > 0;
           %subst($pslot: period: 1) = ' ';
           leavesr;
         endif;

         // Otherwise, this is the first scan ...

         // Check for single scan slot.

         exsr ChkSingleScan;
         if singleScan;
           leavesr;
         endif;

         // Set values for second scan.

         // Get second hyphen position

         hyphen = %scan('-': $pslot);
         if hyphen = 0;
           leavesr;
         endif;

         hyphen = %scan('-': $pslot: hyphen+1);
         if hyphen = 0;
           leavesr;
         endif;

         // Clear characters after second hyphen

         $pslot = %subst($pslot: 1: hyphen);

         // Set column position to after second hyphen

         $PCol = $pcol + hyphen;

         // Set return code to redisplay for second scan

         $PReturn = '*REDSPLY';

       endsr;
      /end-free

EIa AC*----------------------------------------------------------------
EIa AC* slotcrossref   Lookup Scanned Value in Slot Cross-Ref file.
EIa AC*----------------------------------------------------------------
EIa A
EIa A /free
EIa A  begsr SlotCrossRef;
EIa A
EIa A    // Get slot cross-ref record.
EIa A    //   Assumptions:
EIa A    //     - single warehouse
EIa A    //     - slot numbers are unique within the warehouse.
EIa A
EIa A    exec sql select * into :slotxrf2
EIa A             from slotxrf2
EIa A             where xfsltn = :$pslot;
EIa A
EIa A    // Leave if not found
EIa A
EIa A    if sqlstt <> sqlSuccess;
EIa A      $PReturn = '*OK';
EIa A      leavesr;
EIa A    endif;
EIa A
EIa A    // Otherwise, send back Dakota slot display value.
EIa A
EIa A      $PSlot = xfdisp;
EIa A
EIa A  endsr;
EIa A /end-free

WILaAC*----------------------------------------------------------------
WILaAC* ZZCvtSlotWIL   Scan and Insert Dashes if Needed.
WILaAC*----------------------------------------------------------------
WILaAC
WILaAC     ZZCvtSlotWIL  Begsr
WILaAC
WILaAC                   select
WILaAC*      Scanned value already has embedded dashes in slot.
WILaAC                   when      %Scan('-':$PSlot) > 0
WILaAC*        Nothing to change.
WILaAC                   other
WILaAC*
WILaAC                   eval      SlotLength = %Len(%Trim($PSlot))
WILaAC*      If slot length is <= 5, then this is a single character aisle.
WILaAC                   select
WILaAC                   when      SlotLength <= 5
WILaAC                   eval      $PSlot = %Subst($PSlot:1:1) + '-' +
WILaAC                                      %Subst($PSlot:2:3) + '-' +
WILaAC                                      %Subst($PSlot:5:8)
WILaAC                   other
WILaAC*      If slot length is > 5, then this is a double character aisle.
WILaAC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
WILaAC                                      %Subst($PSlot:3:3) + '-' +
WILaAC                                      %Subst($PSlot:6:5)
WILaAC                   endsl
WILaAC*
WILaAC                   endsl
WILaAC
WILaAC                   Endsr

ACCaAC*----------------------------------------------------------------
ACCaAC* ZZCvtSlotACC   Scan and Insert Dashes if Needed.
ACCaAC*----------------------------------------------------------------
ACCaAC
ACCaAC     ZZCvtSlotACC  Begsr
ACCaAC
ACCaAC                   select
ACCaAC*      Scanned value already has embedded dashes in slot.
ACCaAC                   when      %Scan('-':$PSlot) > 0
ACCaAC*        Nothing to change.
ACCaAC                   other
ACCaAC*
ACCaAC                   eval      $PSlot = %Subst($PSlot:1:3) + '-' +
ACCaAC                                      %Subst($PSlot:4:3) + '-' +
ACCaAC                                      %Subst($PSlot:7:6)
ACCaAC                   endsl
ACCaAC
ACCaAC                   Endsr

SFP AC*----------------------------------------------------------------
SFP AC* ZZCvtSlotSFP   Scan and Insert Dashes if Needed.
SFP AC*----------------------------------------------------------------
SFP AC
SFP AC     ZZCvtSlotSFP  Begsr
SFP AC
SFP AC                   select
SFP AC*      Scanned value already has embedded dashes in slot.
SFP AC                   when      %Scan('-':$PSlot) > 0
SFP AC*        Nothing to change.
SFP AC                   other
SFP AC*
SFP AC                   eval      SlotLength = %Len(%Trim($PSlot))
SFPaDC*****  If slot length is <= 5, then this is a single character aisle.
SFPaDC*      Assuming we always put a hyphen after characters 2 and 4.
SFP AC                   select
SFPaDC**                 when      SlotLength <= 5
SFPaMC                   when      SlotLength > 4
SFP AC*      If slot length is <= 5, then this is a double character aisle.
SFP AC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
SFP AC                                      %Subst($PSlot:3:2) + '-' +
SFP AC                                      %Subst($PSlot:5:8)
SFP AC                   endsl
SFP AC*
SFP AC                   endsl
SFP AC
SFP AC                   Endsr
CPJaAC*----------------------------------------------------------------
CPJaAC* ZZCvtSlotCPJ   Scan and Insert Dashes if Needed.
CPJaAC*----------------------------------------------------------------
CPJaAC
CPJaAC     ZZCvtSlotCPJ  Begsr
CPJaAC
CPJaAC                   select
CPJaAC*      Scanned value already has embedded dashes in slot.
CPJaAC                   when      %Scan('-':$PSlot) > 0
CPJaAC*        Nothing to change.
CPJaAC                   other
CPJaAC*
CPJaAC                   eval      SlotLength = %Len(%Trim($PSlot))
CPJaAC*      If slot length is <= 5, then this is a single character aisle.
CPJaAC                   select
CPJaAC                   when      SlotLength >= 5
CPJaAC*      If slot length is >= 5, then this is a double character aisle.
CPJaAC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
CPJaAC                                      %Subst($PSlot:3:3) + '-' +
CPJaAC                                      %Subst($PSlot:6:3)
CPJaAC                   endsl
CPJaAC*
CPJaAC                   endsl
CPJaAC
CPJaAC                   Endsr
DFCaAC*----------------------------------------------------------------
DFCaAC* ZZCvtSlotDFC   Scan and Insert Dashes if Needed.
DFCaAC*----------------------------------------------------------------
DFCaAC
DFCaAC     ZZCvtSlotDFC  Begsr
DFCaAC                   eval      SlotLength = %Len(%Trim($PSlot))
DFCbAC*      If slot length is <= 5, then this is a single character ai
DFCbDC*                  if        SlotLength <= 5
DFCbMC                   select
DFCbAC                   when      SlotLength <= 5
DFCaAC                   eval      $PSlot = %Subst($PSlot:1:1) + '-' +
DFCaAC                                      %Subst($PSlot:2:3) + '-' +
DFCaAC                                      %Subst($PSlot:5:2)
DFCbAC                   when      SlotLength = 6
DFCbAC                   eval      $PSlot = %Subst($PSlot:1:2) + '-' +
DFCbAC                                      %Subst($PSlot:3:3) + '-' +
DFCbAC                                      %Subst($PSlot:6:2)
DFCbDC*                  else
DFCbMC                   other
DFCaAC*      If slot length is = 7, then this is a triple character ais
DFCbAC                   eval      $PSlot = %Subst($PSlot:1:3) + '-' +
DFCbAC                                      %Subst($PSlot:4:3) + '-' +
DFCbAC                                      %Subst($PSlot:7:1)
DFCbDC*                  endif
DFCbMC                   endsl
DFCaAC*
DFCaAC
DFCaAC                   Endsr

