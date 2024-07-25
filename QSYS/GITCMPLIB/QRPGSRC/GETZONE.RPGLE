      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETZONE   Determine a zone for a slot
     *  28 February 2009
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
520 A*    02/28/09  DAS  5.20  P#00150
     *      -  Created
     *
520aA*    03/06/09  GJA  5.20a
     *      -  Per Roxanne, remove processing for Palmer
     *
520bA*    04/02/09  DAS  5.20b
     *      -  Revised look4Match routine to work properly with tote
     *         zones whether or not the Host sends a tote flag with
     *         the item. Before, if the host was not sending a tote
     *         flag, then an item would never get assigned to a
     *         tote zone.
     *
520cA*    08/12/09  JCJ  5.20c
     *      -  Add Batch pick processing
     *
620aA*    12/14/10  DAS  6.20a
     *      -  Zone detail entry now allows the department and section
     *         to be optional.
     *
640aA*    04/27/11  RBD  6.40a
     *      -  Fix: Found never ending loop in getZonePRE, changed
     *         'not %found' to '%eof' after reade to ZONEH.
     *
640bA*    07/20/11  DAS  6.40b
     *      -  Revised to only work with 'B' (Batch) zones when 'B'
     *         is sent in $ZTYPE and ignore 'B' zones when it is not.
     *
700aA*    11/04/15  DAS  7.00a
     *      -  Added AMP code
     *
650aA*    03/07/13  JCJ  6.50a
     *      -  Added code to populate the 'Truck Zone' & 'Generation'
     *         fields for Batch pick pallets.  This will replace
     *         the custom code subroutines for batch pick clients.
     *
710aA*    08/19/15  DAS  7.10a (was originally created as 700a on Cheney box)
     *      -  Added CBI logic. Each warehouse has their own override
     *         routine.
     *      -  Added file ORDH and routine GetOrdh because CBI needs it.
     *      -  Brought in commets from Riviera version.
     *      -  Brought in override code for Ocala but did not bring in
     *         and comments from Ocala version.
     *
710bA*    02/15/17  MLB  7.10b
     *      -  Enh: Revised pgm to not force labels into Fixed zone
     *         and Gen 1 if found in specific pick zone when $pstyp = X.
     *
720aA*    10/14/18  DAS  7.20a
     *      -  Enh: Added To aisle, To level, activity code and
     *         class code.
     *      -  Added ITEMCLS file
     *
720bA*    10/25/18  DAS  7.20b
     *      -  Enh: Added slot type (pick, overflow)
     *
760aA*    04/05/22  DAS  7.60a
     *      -  Fix: Revised ITEMCLS lookup.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
     *
CBI A*    06/20/03  MLB  CBI
     *      -  ** Special mod for Cheney Bros. **
     *      -  Hard-coded to assign zone 'ICE' and compartment 'I' to
     *         items with build code of 'IC'.
     *      -  Hard-coded to assign zone 'PKxxx' and compartment '1,2,3'
     *         for items being ordered in eaches. LWUTYP = '1'.
CBIaA*    07/17/03  MLB  CBIa
     *      -  Revised mod CBI to not assign items in aisle ' HZ' to
     *         PKxxx pallets.
CBIbA*    08/07/03  MLB  CBIb
     *      -  Revised program to force zone to DRY999 or FRZ999 for
     *         item numbers greater or equal to '997000'. This is only
     *         for items in department DRY or FRZ.
CBIcA*    08/19/03  DAS  CBIc
     *      -  Revised mod CBI to assign PK items in aisles DX, DY,
     *         CX, FX and FY to special PK zones.
CBIdA*    08/20/03  DAS  CBId
     *      -  Revised to include BREAKERS truck with special PK
     *         selection.
CBIeA*    08/27/03  DAS  CBIe
     *      -  Revised to assign ice cream PK items (build code UI,
     *         aisles FX, FY) to zone ICEPIR.
CBIfA*    09/10/03  DAS  CBIf
     *      -  Revised to assign meat inspection items to zone CLR.
CBIgA*    10/07/03  DAS  CBIg
     *      -  Removed CBIf change. Instead, OR610 hard codes a slot
     *         number for meat inspection items, so let this program
     *         assign a zone normally, according to the slot number.
CBIhA*    10/14/03  DAS  CBIh
     *      -  Revised so the special zone logic is not applied to
     *         Meat Insp and Pre-Pick items. Thus, the zone will be
     *         assigned based on the slot number that is assigned to
     *         these items in OR610.
CBIiA*    10/14/03  DAS  CBIi
     *      -  Revised so 999 ice cream items will be merged into
     *         an ice cream truck pallet, not a freezer truck pallet.
CBIjA*    11/10/03  DAS  CBIj
     *      -  Removed PKFRZ. PKFPIR remains.
CBIkA*    03/04/04  HNK  CBIk
     *      -  Revised to assign special PK zone for aisle CY.
CBIl *    04/13/04  HNK  CBIl
     *      -  Revised to assign special PK zone for 'CONTAINER' truck
CBImA*    05/08/06  RH   CBIm
     *      -  Added PKPPIR.
CBInA*    05/15/06  MLB  CBIn
     *      -  Corrected line 378.00 to change field back to @FPZON
     *         from @PPZON. Corrected dept for CBIm mod to PRD from CLR.
     *      -  Revised CBIm mod. Moved If test for aisle CT code above
     *         with previously added code for CLR eaches processing.
CBIoA*    05/17/06  MLB  CBIo
     *      -  Revised CBIm mod to remove all location selections and
     *         change selection to be dept CLR and lwutyp='1' and aisle
     *         is CT, put in zone PKPPIR.
CBIpA*    05/12/08  HNK  CBIp
     *      -  Revised to undo special processing for DRY999 items.
CBIQA*    06/09/08  HNK  CBIQ
     *      -  Revised to force DRYPIR zone to 999 items, if not in DX
     *         or DY aisles.
CBIrA*    10/29/10  MLB  CBIr
     *      -  Revised to force Each items in aisle DK location 261
     *         to 275 to print in PIR zone FLRPIR.
     *
CBIsA*    05/23/11  JGD  CBIs
     *      - Revised to replace the hard coded items number range
     *      - 997 to 999 series comparison with the validation of
     *      - the value loaded in Piritem/Itactv field,if the value
     *      - found is "99" the item is within series 997 to 999.
     *
CBItA*    06/07/14  MLB  CBIt  P#01218
     *      - Revised pgm to put all PK's (LWUTYP = '1') into pick
     *        zone PKCPIR for all warehouse department CLR/FRZ items
     *        for new warehouse, GWB.
     *
CBIuA*    06/16/14  DAS  CBIu
     *      - For GWB, put all items for buyer 92 & 94 into zone CUT.
     *      - For GWB, put all items for buyer 95 into zone GRIND.
     *      - Both of these include PK's and ignore the CBIt change.
     *
CBIvA*    10/05/15  JCJ  CBIv
     *      - Added Punta Gorda client copy specs.
     *
CBIwA*    10/20/15  JCJ  CBIw
     *      - exclude DRY999/FRZ999/ICE999 processing from punta
     *        gorda.
     *
CBIxA*    09/02/16  JCJ  CBIx
     *      - exclude all hard coded zones from Ocala.
     *
CBIyA*    11/22/16  JCJ  CBIy
     *      - exclude PKCPIR/PKPPIR/PKCLR processing from riviera.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    02/28/11  MLB  CPC
     *      -  Revised program to add Crumbley to Batch Pick processing
     *         support.
CPCbA*    08/08/11  RH   CPCb
     *      -  Revised ZONECPC to use compartment 'B' for batch picks
     *         full system.                                           g
     *         For full system batch pick, define template with DRYB
     *         zone with compartment 'B' and the truck with no 'B'
     *         compartment, will cause batch picks to be on 71 pallets
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
SLB A*    08/26/11  MLB  SLB
     *      -  Revised program to add Silberman to Batch Pick processing
     *         support.
     *----------------------------------------------------------------
     *  Client Custom Revisions: AJ Silberman
     *
NCSaA*    11/14/11  JCJ  NCSa
     *      -  Revised program to add Nicholas to Batch Pick processing
     *         support.
NCSbA*    11/22/11  MLB/JCJ  NCSb
     *      -  Revised program to add support for compartment H=Chemical
     *         zone processing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: TPD
     *
TPCaA*    11/08/07  DAS  TPCa
     *      - Revised to force all 'OK-' items into zone PROD.
TPCbA*    08/11/17  JCJ  TPCb
     *      - Revised to use first 2 positions of location when
     *        determining Odd / Even sides of a slot.
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fzoned1    if   e           k disk
     Fzoned2    if   e           k disk
     Fzoneh     if   e           k disk
     Fworkzon1  if   e           k disk
     Foptionz   if   e           k disk
530 AFtruckh    if   e           k disk
700aAFampxref6  if   e           k disk
CBIhAFordh      if   e           k disk
720aAFitemcls   if   e           k disk

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

      /COPY QCOPYSRC,ID#ALLEN
      /COPY QCOPYSRC,ID#HARBOR
      /COPY QCOPYSRC,ID#TPC
      /COPY QCOPYSRC,ID#JORDANO
      /COPY QCOPYSRC,ID#PALMER
      /COPY QCOPYSRC,ID#CHENEY
      /COPY QCOPYSRC,ID#CHENEYO
      /COPY QCOPYSRC,ID#CHENEYR
CBItA /COPY QCOPYSRC,ID#CHENEYG
CBIvA /COPY QCOPYSRC,id#cheneyp
520cA /COPY QCOPYSRC,ID#MATT
CPC A /COPY QCOPYSRC,ID#cpc
SLB A /copy qcopysrc,id#silberm
NCSaA /copy qcopysrc,id#nichola

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
     D saveVer#        s                   like($itver#)

     *----------------------------------------------------------------
     *  OPTIONZ data structure
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
     *    OPPBRK  -  Aisle to start new pallet.
     *    OPPBLD  -  Pallet building method.
     *                1 = By stop then slot location.
     *                2 = By slot location then stop.
     *                3 = By descening stop, then slot location.
     *    OPSELM  -  Selection method.
     *                1 = Single pass (By location).
     *                2 = Multiple pass (By stop).
     *    OPSPLT  -  Allow stop to be split across pallets (Y/N).
     *    OPBMRG  -  Allow merge onto bulk pick pallets (Y/N).
     *    OPNWPL  -  Start new pallet when aisle changes if build method
     *               is 2=Location.
520cA*    OPFORD  -  Maximum orders per pallet.
     *    OPPTYP  -  Pallet type (P=Pallet, T=Tote).
520cA*    OPFTOT  -  Maximum totes per pallet.
520cA*    OPTECB  -  External tote cube.
520cA*    OPTICB  -  Internal tote cube.
520cA*    OPTSTP  -  Maximum stops per tote.
520cA*    OPTORD  -  Maximum orders per tote.
520cA*    OPTPCS  -  Maximum pieces per fixed pallet.
520cA*    OPSTOP  -  Honor *SP flag (Y=Yes, N=No).
520cA*    OPGCDE  -  USF Group Code (0-9). **** USF ONLY****
520cA*    OPPKUP  -  Picked up by (S=Selector, L=Loader).
520cA*    OPSPAL  -  Merge pallet should only contain
520cA*               items for single truck pallet (Y=Yes, N=No).
520cA*    OPPITM  -  Maximum items per pallet.
520cA*
520cA* Data structure
520cA*
     D opzdta          ds
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
     D  oppbld                34     34
     D  opselm                35     35
     D  opsplt                36     36
     D  opbmrg                37     37
     D  opnwpl                38     38
     D  opford                39     40  0 inz(0)
     D  opptyp                41     41
     D  opftot                42     43  0 inz(0)
     D  optecb                44     48  2 inz(0)
     D  opticb                49     53  2 inz(0)
     D  optstp                54     55  0 inz(0)
     D  optord                56     57  0 inz(0)
     D  optpcs                58     60  0 inz(0)
     D  opstop                61     61
520cAD  oppkup                62     62
520cAD  opspal                63     63
520cAD  oppitm                64     67  0 inz(0)
     D  opzend               117    117

     D dftzopt         ds                  likeds(opzdta)

TPCbA*
TPCbAD                 ds
TPCbAD  temp3                  1      3  0
TPCbAD  tpcloc                 1      2  0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

600eA /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

700aAD ampBox          s               n
700aAD ampSlot         s               n
     D chk4err         s               n
     D count           s              3  0
     D dftcomp         s                   like(zhcomp)
     D dftgen          s                   like(zhgen )
     D dftpzon         s                   like(zhzone)
     D dftszon         s                   like(zhzone)
     D dfttruk         s                   like(zhtruk)
     D dfttzon         s                   like(zhzone)
     D dummy           s              3  0
     D error           s               n
     D forever         s               n
     D itemFlag        s               n
     D kycode          s                   like(opzcod)
     D kyzone          s                   like(zdzone)
CBIhAD lstord          s                   like(ohord) inz(-1)
     D lastZone        s                   like(zdzone)
     D matchCount      s              3  0
     D matchFound      s               n
620aAD preZoneFound    s               n
     D side            s              1  0
     D svstyp          s              1
     D temp3a          s              3
     D zonehFound      s               n
     D zmflag          s               n
     D zmsflag         s               n
530 AD $ptmpl          s             10

     D b92cmp          s                   like(zwcomp)
     D b92gen          s                   like(zwgen)
     D b92pzn          s                   like(zwpzon)
     D b92tzn          s                   like(zwtzon)
     D b95cmp          s                   like(zwcomp)
     D b95gen          s                   like(zwgen)
     D b95pzn          s                   like(zwpzon)
     D b95tzn          s                   like(zwtzon)
     D ccomp           s                   like(zwcomp)
     D cgen            s                   like(zwgen)
     D comp            s                   like(zwcomp)
     D cpzone          s                   like(zwpzon)
     D ctzone          s                   like(zwtzon)
     D dcomp           s                   like(zwcomp)
     D dgen            s                   like(zwgen)
     D dpzone          s                   like(zwpzon)
     D dp9zon          s                   like(zwpzon)
     D dtzone          s                   like(zwtzon)
     D dt9zon          s                   like(zwtzon)
     D d9comp          s                   like(zwcomp)
     D d9gen           s                   like(zwgen)
     D fcomp           s                   like(zwcomp)
     D fgen            s                   like(zwgen)
     D fpzone          s                   like(zwpzon)
     D fp9zon          s                   like(zwpzon)
     D ftzone          s                   like(zwtzon)
     D ft9zon          s                   like(zwtzon)
     D f9comp          s                   like(zwcomp)
     D f9gen           s                   like(zwgen)
     D icomp           s                   like(zwcomp)
     D igen            s                   like(zwgen)
     D ipzone          s                   like(zwpzon)
     D ip9zon          s                   like(zwpzon)
     D itzone          s                   like(zwtzon)
     D it9zon          s                   like(zwtzon)
     D i9comp          s                   like(zwcomp)
     D i9gen           s                   like(zwgen)
     D pcomp           s                   like(zwcomp)
     D pgen            s                   like(zwgen)
     D ppzone          s                   like(zwpzon)
     D ptzone          s                   like(zwtzon)
     D pzone           s                   like(zwpzon)
     D rcomp           s                   like(zwcomp)
     D rgen            s                   like(zwgen)
     D rpzone          s                   like(zwpzon)
     D rtzone          s                   like(zwtzon)

CBI A*----------------------------------------------------------------
CBI A*  Define Ice Cream Build code and zone
CBI A*
     D @icbld          c                   const('IC')
     D @iczon          c                   const('ICE   ')
     D @ipzon          c                   const('ICEPIR')
     D @iczn9          c                   const('ICE999')
     D @clzon          c                   const('PKCLR ')
     D @drzon          c                   const('PKDRY ')
     D @cpzon          c                   const('PKCPIR')
     D @dpzon          c                   const('PKDPIR')
     D @fpzon          c                   const('PKFPIR')
     D @ppzon          c                   const('PKPPIR')
     D @drzn9          c                   const('DRY999')
     D @frzn9          c                   const('FRZ999')
     D @rfzon          c                   const('CLR   ')
     D @drpzn          c                   const('DRYPIR')
     D @b92zn          c                   const('CUT   ')
     D @b95zn          c                   const('GRIND ')
CBIl *----------------------------------------------------------------
     D @cntnr          c                   const('CONTAINER')
CBIhA*----------------------------------------------------------------
CBIhA*  Order Header OHMISC Data Structure
CBIhA*
CBIhAD                 ds
CBIhAD  dsmisc                 1     20
CBIhAD  dssdte                 1      8
CBIhAD  dsspcl                 9     11
CBIhAD  dsrpck                12     12
CBIhAD  dxdoor                13     14
CBIhAD  dsmeat                15     15
CBIhAD  prepck                17     17

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PTRUK  Truck
     *      $PRTID  Route id
     *      $POTYP  Order type
     *      $PWHSE  Warehouse
     *      $PWHDP  Department
     *      $PDISP  Slot display (either send this or individual fields)
     *      $PSTYP  Section Type
     *      $PAISL  Aisle
     *      $PLOC   Location
     *      $PHAND  Handstack
     *      $PRLVL  Rack Level
     *      $PITEM  Item
     *      $PDESG  Designation
     *      $PUTYP  UM Type
520cD****** $PTOTE  Tote item flag (Y,N)
520cM*      $ZTYPE  Zone item flag (Y-Tote)
520cM*                             (B-Batch Pick)
710aA*      $PORD   Order number
720bA*      $PACTV  Slot activity code
720bA*      $PPICK  Pick slot
     *    Returned Parameters
     *      $PSZON  Slot Zone
     *      $PPZON  Parent Zone
     *      $PTZON  Truck Zone
     *      $PCOMP  Compartment
     *      $PGEN   Generation
     *      $PZOPT  OPTIONZ data structure
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $ptruk           10
     C                   parm                    $prtid            5
     C                   parm                    $potype           1
     C                   parm                    $pwhse            3 0
     C                   parm                    $pwhdp            5
     C                   parm                    $pdisp           12
     C                   parm                    $pstyp            1
     C                   parm                    $paisl            3
     C                   parm                    $ploc             3 0
     C                   parm                    $prlvl            2 0
     C                   parm                    $phand            2
     C                   parm                    $pitem           15
     C                   parm                    $pdesg            5
     C                   parm                    $putyp            1
520cD ***                parm                    $ptote            1
520cMC                   parm                    $ztype            1
     C                   parm                    $pszon            6
     C                   parm                    $ppzon            6
     C                   parm                    $ptzon            6
     C                   parm                    $pcomp            1
     C                   parm                    $pgen             1 0
     C                   parm                    $pzopt          117
710aAC                   parm                    $pord             7 0
720bAC                   parm                    $pactv            2
720bAC                   parm                    $ppick            1

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   if        $pcmd = '*CLOSE'
     C                   eval      *inlr = *on
     C                   return
     C                   endif

     C                   if        dfttruk <> $ptruk
     C                   exsr      getDefault
     C                   endif

     C                   eval      itemFlag = *off

     C                   eval      matchFound = *off
     C                   eval      matchCount = 0

     C                   eval      $pszon = dftszon
     C                   eval      $ppzon = dftpzon
     C                   eval      $ptzon = dfttzon
     C                   eval      $pcomp = dftcomp
     C                   eval      $pgen  = dftgen
     C                   eval      $pzopt = dftzopt

     *  Get individual slot fields if necessary.

     C                   if        $paisl = ' '
     C                             and $pdisp <> ' '
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   return
     C                   endif
     C                   eval      $pstyp = $slstyp
     C                   eval      $paisl = $slaisl
     C                   eval      $ploc  = $slloc
     C                   eval      $prlvl = $slrlvl
     C                   eval      $phand = $slhand
     C                   eval      $pdesg = $sldesg
     C                   endif

     *    Change section 'X' (cross dock) to 'F'.

     C                   eval      svstyp = $pstyp
     C                   if        $pstyp = 'X'
     C                   eval      $pstyp = 'F'
     C                   endif

     *  First, look for hard coded custom zone definition

     C                   select

     C                   when      client = cheney
     C                             and clientloc = cbigwb
     C                   exsr      zoneCBIg

     C                   when      client = cheney
     C                             and clientloc = cbiocl
CBIxD ***                exsr      zoneCBIo

     C                   when      client = cheney
     C                             and clientloc = cbiriv
CBIxD ***                exsr      zoneCBIr

     C                   when      client = cheney
     C                             and clientloc = cbipntgr
     C                   exsr      zoneCBIp

     C                   when      client = harbor
     C                   exsr      zoneHAR

     C                   when      client = jordanos
     C                   exsr      zoneJOR

     C                   when      client = tpc
     C                   exsr      zoneTPC

520dAC                   when      client = mattfd
520dAC                             and $ztype = 'B'
520dAC                   exsr      zoneMAT
CPC A
CPC AC                   when      client = cpc
CPC AC                             and $ztype = 'B'
CPC AC                   exsr      zoneCPC
SLB A
SLB AC                   when      client = silberman
SLB AC                             and $ztype = 'B'
SLB AC                   exsr      zoneSLB
NCSaA
NCSaAC                   when      client = nicholas
NCSaAC                             and $ztype = 'B'
NCSaAC                   exsr      zoneNCS

     C                   endsl

     *  If found, return home

     C                   if        matchFound
     C                   return
     C                   endif
620aA
620aA*  Next, check for prepick zone.
620aA
620aAC                   exsr      zonePrepick
620aA
620aA*  If found, return home
620aA
620aAC                   if        matchFound
620aAC                   return
620aAC                   endif
700aA
700aA*  Check if slot is part of an AMP box
700aA
700aAC                   exsr      AMPBoxChk

     *  If custom zone not found,
     *    Then loop through zone detail records for department

     C                   eval      lastZone = *hival
     C     keyzd2        setll     zoned2

     C                   dow       forever = forever
     C     keyzd2        reade     zoned2
     C                   if        %eof(zoned2)
     C                   leave
     C                   endif

     *      When zone changes, get zone information.

     C                   if        zdzone <> lastZone
     C                   eval      kyZone = zdzone
     C                   exsr      getZoneH
     C                   if        not zonehFound
     C                   iter
     C                   endif
     C                   endif
640bA
640bA*      If $ZTYPE is 'B' then zone must be 'B'.
640bA*      If $ZTYPE is not 'B' then zone must not be 'B'.
640bA
640bAC                   if        ($ztype = 'B' and opptyp <> 'B')
640bAC                             or ($ztype <> 'B' and opptyp = 'B')
640bAC                   iter
640bAC                   endif
700aA
700aA*      Ignore Tote zones if AMP slot, but not part of a box.
700aA
700aAC                   if        ampSlot
700aAC                             and not ampBox
700aAC                             and opptyp = 'T'
700aAC                   iter
700aAC                   endif

     *      See if parms match zone detail.

     C                   exsr      look4Match

     C                   enddo

     *    Set fields if Cross Dock.
710bA*    Cross Dock now allowed in Child zones.

     C                   eval      $pstyp = svstyp
     C                   if        $pstyp = 'X'
710bAC                             and MatchFound = '0'
     C                   eval      $pszon = $ptzon
     C                   eval      $ppzon = *blanks
     C                   eval      $pgen = 1
     C                   endif

     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     * Get client id.

     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientLoc        10
530 A*
530 A*    Get truck information.
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl = thztmp
530 AC                   else
530 AC                   eval      $ptmpl = $ptruk
530 AC                   endif

     *  Define key for OPTIONZ file.

     C     keyopz        klist
     C                   kfld                    kycode
     C                   kfld                    zhwhse
530 D ***                kfld                    zhtruk
530 AC                   kfld                    $ptmpl
     C                   kfld                    zhzone

     *  Define key for WORKZON1 file.

     C     keywz1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     C                   kfld                    zhzone

     *  Define key for ZONEH file.

     C     keyzh         klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl
     C                   kfld                    kyzone

     *  Define partial key for ZONEH file.

     C     keyzhp        klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl

     *  Define partial key for ZONED1 file.

     C     keyzd1p       klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl
     C                   kfld                    zhzone

     *  Define key for ZONED2 file.

     C     keyzd2        klist
     C                   kfld                    $pwhse
530 D ***                kfld                    $ptruk
530 AC                   kfld                    $ptmpl
     C                   kfld                    $pwhdp
530 A*
530 A*  Define key for truck file.
530 A*
530 AC     keyth         klist
530 AC                   kfld                    $pwhse
530 AC                   kfld                    $ptruk
CBI A*
CBI A*  Get info for Ice Cream zone.
CBI A*
CBI AC                   eval      itzone = *blanks
CBI AC                   eval      ipzone = *blanks
CBI AC                   eval      icomp = *blanks
CBI AC                   eval      igen = 0
CBI A*
CBI AC                   eval      kyzone = @iczon
CBI AC                   exsr      getZoneH
CBI AC                   if        zonehFound
CBI AC                   eval      itzone = zwtzon
CBI AC                   eval      ipzone = zwpzon
CBI AC                   eval      icomp = zwcomp
CBI AC                   eval      igen = zwgen
CBI AC                   endif
CBI A*
CBI A*  Get info for CLR Eaches zone.
CBI A*
CBI AC                   eval      ctzone = *blanks
CBI AC                   eval      cpzone = *blanks
CBI AC                   eval      ccomp = *blanks
CBI AC                   eval      cgen = *zeros
CBI A*
CBI AC                   eval      kyzone = @clzon
CBI AC                   exsr      getZoneH
CBI AC                   if        zonehFound
CBI AC                   eval      ctzone = zwtzon
CBI AC                   eval      cpzone = zwpzon
CBI AC                   eval      ccomp = zwcomp
CBI AC                   eval      cgen = zwgen
CBI AC                   endif
CBI A*
CBI A*  Get info for DRY Eaches zone.
CBI AC                   eval      dtzone = *blanks
CBI AC                   eval      dpzone = *blanks
CBI AC                   eval      dcomp = *blanks
CBI AC                   eval      dgen = *zeros
CBI A*
CBI AC                   eval      kyzone = @drzon
CBI AC                   exsr      getZoneH
CBI AC                   if        zonehFound
CBI AC                   eval      dtzone = zwtzon
CBI AC                   eval      dpzone = zwpzon
CBI AC                   eval      dcomp = zwcomp
CBI AC                   eval      dgen = zwgen
CBI AC                   endif
CBI A*
CBI A*  Get info for FRZ Eaches zone.
CBI AC                   eval      ftzone = *blanks
CBI AC                   eval      fpzone = *blanks
CBI AC                   eval      fcomp = *blanks
CBI AC                   eval      fgen = *zeros
CBI A*
CBIjMC                   eval      kyzone = @fpzon
CBI AC                   exsr      getZoneH
CBI AC                   if        zonehFound
CBI AC                   eval      ftzone = zwtzon
CBI AC                   eval      fpzone = zwpzon
CBI AC                   eval      fcomp = zwcomp
CBI AC                   eval      fgen = zwgen
CBI AC                   endif
CBImA*
CBImA*  Get info for PRD Eaches zone.
CBImAC                   eval      ptzone = *blanks
CBImAC                   eval      ppzone = *blanks
CBImAC                   eval      pcomp = *blanks
CBImAC                   eval      pgen = *zeros
CBImA*
CBImMC                   eval      kyzone = @ppzon
CBImAC                   exsr      getZoneH
CBImAC                   if        zonehFound
CBImAC                   eval      ptzone = zwtzon
CBImAC                   eval      ppzone = zwpzon
CBImAC                   eval      pcomp = zwcomp
CBImAC                   eval      pgen = zwgen
CBImAC                   endif
CBIbA*
CBIbA*  Get info for DRY '999' Items zone.
CBIbAC                   eval      dt9zon = *blanks
CBIbAC                   eval      dp9zon = *blanks
CBIbAC                   eval      d9comp = *blanks
CBIbAC                   eval      d9gen = *zeros
CBIbA*
CBIqAC                   eval      kyzone = @drpzn
CBIqAC                   exsr      getZoneH
CBIqAC                   if        zonehFound
CBIqAC                   eval      dt9zon = zwtzon
CBIqAC                   eval      dp9zon = zwpzon
CBIqAC                   eval      d9comp = zwcomp
CBIqAC                   eval      d9gen = zwgen
CBIqAC                   endif
CBSt *
CBIbA*  Get info for FRZ '999' Items zone.
CBIbAC                   eval      ft9zon = *blanks
CBIbAC                   eval      fp9zon = *blanks
CBIbAC                   eval      f9comp = *blanks
CBIbAC                   eval      f9gen = *zeros
CBIbA*
CBIbAC                   eval      kyzone = @frzn9
CBIbAC                   exsr      getZoneH
CBIbAC                   if        zonehFound
CBIbAC                   eval      ft9zon = zwtzon
CBIbAC                   eval      fp9zon = zwpzon
CBIbAC                   eval      f9comp = zwcomp
CBIbAC                   eval      f9gen = zwgen
CBIbAC                   endif
CBIiA*
CBIiA*  Get info for ICE '999' Items zone.
CBIiAC                   eval      it9zon = *blanks
CBIiAC                   eval      ip9zon = *blanks
CBIiAC                   eval      i9comp = *blanks
CBIiAC                   eval      i9gen = *zeros
CBIbA*
CBIbAC                   eval      kyzone = @iczn9
CBIbAC                   exsr      getZoneH
CBIbAC                   if        zonehFound
CBIbAC                   eval      it9zon = zwtzon
CBIbAC                   eval      ip9zon = zwpzon
CBIbAC                   eval      i9comp = zwcomp
CBIbAC                   eval      i9gen = zwgen
CBIbAC                   endif
CBIuA*
CBItA*  Get info for CLR/FRZ PK's Zone.
CBItA*
CBItAC                   eval      rtzone = *blanks
CBItAC                   eval      rpzone = *blanks
CBItAC                   eval      rcomp = *blanks
CBItAC                   eval      rgen = *zeros
CBItA*
CBItAC                   eval      kyzone = @rfzon
CBItAC                   exsr      getZoneH
CBItAC                   if        zonehFound
CBItAC                   eval      rtzone = zwtzon
CBItAC                   eval      rpzone = zwpzon
CBItAC                   eval      rcomp = zwcomp
CBItAC                   eval      rgen = zwgen
CBItAC                   endif
CBIuA*
CBIuA*  Get info for CUT Zone (Buyer 92 & 94)
CBIuA*
CBIuAC                   eval      b92tzn = *blanks
CBIuAC                   eval      b92pzn = *blanks
CBIuAC                   eval      b92cmp = *blanks
CBIuAC                   eval      b92gen = *zeros
CBIuA*
CBIuAC                   eval      kyzone = @b92zn
CBItAC                   exsr      getZoneH
CBItAC                   if        zonehFound
CBIuAC                   eval      b92tzn = zwtzon
CBIuAC                   eval      b92pzn = zwpzon
CBIuAC                   eval      b92cmp = zwcomp
CBIuAC                   eval      b92gen = zwgen
CBIuAC                   endif
CBIuA*
CBIuA*  Get info for GRIND Zone (Buyer 95)
CBIuA*
CBIuAC                   eval      b95tzn = *blanks
CBIuAC                   eval      b95pzn = *blanks
CBIuAC                   eval      b95cmp = *blanks
CBIuAC                   eval      b95gen = *zeros
CBIuA*
CBIuAC                   eval      kyzone = @b95zn
CBItAC                   exsr      getZoneH
CBItAC                   if        zonehFound
CBIuAC                   eval      b95tzn = zwtzon
CBIuAC                   eval      b95pzn = zwpzon
CBIuAC                   eval      b95cmp = zwcomp
CBIuAC                   eval      b95gen = zwgen
CBIuAC                   endif

     C                   endsr

700aA*----------------------------------------------------------------
700aA*  AMPBoxChk    Check if slot is part of AMP box
700aA*----------------------------------------------------------------
700aA
700aAC     AMPBoxChk     begsr
      /free

         ampSlot = *off;
         ampBox = *off;

         chain ($pwhse: $prtid: $pwhdp: $paisl: $ploc: $prlvl: $phand)
               ampxref6;
         if not %found(ampxref6);
           leavesr;
         endif;

         // Slot is an AMP slot

         ampSlot = *on;

         // Set flag if slot is part of a box.

         if axaboxid > 0;
           ampBox = *on;
         endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getDefault   Get default zone
     *----------------------------------------------------------------

     *  First, look for a zone that has no detail.

     C     getDefault    begsr
530 A*
530 A*    Get truck information.
530 A*
530 AC     keyth         chain     truckh
530 AC                   if        %found(truckh)
530 AC                             and thtype = 'T'
530 AC                   eval      $ptmpl = thztmp
530 AC                   else
530 AC                   eval      $ptmpl = $ptruk
530 AC                   endif

     C     keyzhp        setll     zoneh
     C                   eval      dfttruk = $ptruk

     C                   dow       forever = forever

     C     keyzhp        reade     zoneh
     C                   if        %eof(zoneh)
     C                   leave
     C                   endif

     C     keyzd1p       setll     zoned1
     C                   if        not %equal(zoned1)
     C                   eval      kyZone = zhzone
     C                   exsr      getZoneH
     C                   if        not zonehFound
     C                   iter
     C                   endif
640bA
640bA*      If $ZTYPE is 'B' then zone must be 'B'.
640bA*      If $ZTYPE is not 'B' then zone must not be 'B'.
640bA
640bAC                   if        ($ztype = 'B' and opptyp <> 'B')
640bAC                             or ($ztype <> 'B' and opptyp = 'B')
640bAC                   iter
640bAC                   endif
640bA
     C                   eval      dftszon = zhzone
     C                   eval      dftpzon = zhpzon
     C                   eval      dfttzon = zwtzon
     C                   eval      dftcomp = zwcomp
     C                   eval      dftgen  = zwgen
     C                   eval      dftzopt = opzdta
     C                   leavesr
     C                   endif

     C                   enddo

     *  If a zone with no detail is found,
     *    Then ZZZZZZ will be the default zone.

     C                   eval      dftszon = 'ZZZZZZ'
     C                   eval      dftpzon = ' '
     C                   eval      dfttzon = 'ZZZZZZ'
     C                   eval      dftcomp = 'Z'
     C                   eval      dftgen  = 1
     C                   eval      opfcub = 60
     C                   eval      opbpck = 999
     C                   eval      dftzopt = opzdta

     C                   endsr

     *----------------------------------------------------------------
     *  getItem     Get Item record
     *----------------------------------------------------------------

     C     getItem       begsr

     C                   if        not itemFlag
     C                   exsr      clr$item
     C                   eval      $itwhse  = $pwhse
     C                   eval      $ititem  = $pitem
     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif
     C                   eval      itemFlag = *on
     C                   endif

     C                   endsr

710aA*----------------------------------------------------------------
710aA*  getOrdh     Get Order Header
710aA*----------------------------------------------------------------
710aA
710aAC     getOrdh       begsr
      /free

         if %parms < 23;
           ohmisc = '';
           leavesr;
         endif;

CBIhA    if $pord <> lstord;
CBIhA      chain ($pwhse:$pord) ordh;
CBIhA      if not %found(ordh);
CBIhA        ohmisc = *blanks;
CBIhA      endif;
CBIhA      dsmisc = ohmisc;
CBIhA      lstord = $pord;
CBIhA    endif;

      /end-free
     C                   endsr

     *----------------------------------------------------------------
     *  getZoneH    Get ZONEH record
     *----------------------------------------------------------------

     C     getZoneH      begsr

     C                   eval      zonehFound = *off

     *  Get ZONEH record

     C     keyzh         chain     zoneh
     C                   if        not %found(zoneh)
     C                   leavesr
     C                   endif

     *  Get OPTIONZ record

     C                   eval      kycode = '*PICK'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C                   leavesr
     C                   endif

     *  Get WORKZON1 record if route id sent in

     C                   eval      zwtzon = ' '
     C                   eval      zwcomp = ' '
     C                   eval      zwgen  = 0
     C                   if        $prtid = ' '
     C                   eval      zwcomp = zhcomp
     C                   else
     C     keywz1        chain     workzon1
     C                   if        not %found(workzon1)
     C                   eval      zwcomp = zhcomp
     C                   endif
     C                   endif

     C                   eval      zonehFound = *on

     C                   endsr

620aA*----------------------------------------------------------------
620aA*  getZonePRE  Get ZONEH record for prepick 'S' zone.
620aA*              Is is assumed there is only one 'S' zone.
620aA*----------------------------------------------------------------
620aA
620aAC     getZonePRE    begsr

     C                   eval      preZoneFound = *off

     *  Get ZONEH record

     C     keyzhp        setll     zoneh
     C                   dow       forever = forever

     C     keyzhp        reade     zoneh
640aDC*                  if        not %found(zoneh)
640aMC                   if        %eof(zoneh)
     C                   leavesr
     C                   endif

     *  Get OPTIONZ record

     C                   eval      kycode = '*PICK'
     C     keyopz        chain     optionz
     C                   if        not %found(optionz)
     C                   iter
     C                   endif

     C                   if        opptyp = 'S'
     C                   leave
     C                   endif

     C                   enddo

     *  Get WORKZON1 record if route id sent in

     C                   eval      zwtzon = ' '
     C                   eval      zwcomp = ' '
     C                   eval      zwgen  = 0
     C                   if        $prtid = ' '
     C                   eval      zwcomp = zhcomp
     C                   else
     C     keywz1        chain     workzon1
     C                   if        not %found(workzon1)
     C                   eval      zwcomp = zhcomp
     C                   endif
     C                   endif

     C                   eval      preZoneFound = *on

     C                   endsr

     *----------------------------------------------------------------
     *  look4Match  See if zone detail record matches incoming data
     *----------------------------------------------------------------

     C     look4Match    begsr

     C                   eval      error = *off
     C                   eval      count = 0
520bD **
520bD ** Skip if Tote / Item type mismatch
520bD **
520bDC**                 if        opptyp = 'T' and $ptote <> 'Y'
520bDC**                           or opptyp <> 'T' and $ptote = 'Y'
520bDC**                 leavesr
520bDC**                 endif
520bA
520bA*  If host is sending in a tote flag for an item
520cM*  and that flag is 'Y' ($ztype='Y')
520bA*    Then give more weight to a Tote zone.
520bA
520bA*  Note, we will allow a tote item to go into a non-tote zone,
520bA*  if a Tote zone is not found for the item. However, if a
520bA*  Tote zone is found for the item, this added weight should
520bA*  ensure the non-tote zone is chosen.
700aA*  Correction, this should ensure the 'tote' zone is chosen.
520bA
520cD ***                if        $ptote = 'Y' and opptyp = 'T'
520bAC                   if        $ztype = 'Y' and opptyp = 'T'
520bAC                   eval      count += 100
520bAC                   endif
700aA
700aA*  Add more weight to a Tote zone when working with an AMP box
700aA
700aAC                   if        opptyp = 'T' and ampBox
520bAC                   eval      count += 100
520bAC                   endif

     *  Compare department

     C                   if        $pwhdp <> zdwhdp
     C                   leavesr
     C                   endif
     C                   eval      count += 1

     *  Compare section type

     C                   if        zdstyp <> ' '
     C                   if        $pstyp <> zdstyp
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif
720bA
720bA*  Compare slot type (pick, overflow)
720bA
720bAC                   if        %parms >= 25
720bAC                   if        zdpckovf <> ' '
720bAC                   if        (zdpckovf = 'P' and $ppick <> 'Y')
720bAC                             or (zdpckovf = 'O' and $ppick = 'Y')
720bAC                   leavesr
720bAC                   else
720bAC                   eval      count += 1
720bAC                   endif
720bAC                   endif
720bAC                   endif

     *  Compare aisle
720aA*    Added optional To Aisle for an aisle range

720aDC**                 if        zdaisl <> ' '
720aDC**                 if        $paisl <> zdaisl
720aMC                   if        zdaisl <> '' or zdaisl2 <> ''
720aMC                   if        (zdaisl2 = '' and $paisl <> zdaisl)
720aMC                             or (zdaisl2 <> '' and $paisl < zdaisl)
720aMC                             or (zdaisl2 <> '' and $paisl > zdaisl2)
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  Compare level
720aA*    Added optional To Level for a level range

720aDC**                 if        zdrlvl <> 0
720aDC**                 if        $prlvl <> zdrlvl
720aMC                   if        zdrlvl <> 0 or zdrlvl2 <> 0
720aMC                   if        (zdrlvl2 = 0 and $prlvl <> zdrlvl)
720aMC                             or (zdrlvl2 <> 0 and $prlvl < zdrlvl)
720aMC                             or (zdrlvl2 <> 0 and $prlvl > zdrlvl2)
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  Compare location

     C                   if        zdloc1 <> 0 or zdloc2 <> 0
     C                   if        $ploc < zdloc1 or $ploc > zdloc2
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  Compare handstack

     C                   if        zdhnd1 <> ' ' or zdhnd2 <> ' '
     C                   if        $phand < zdhnd1 or $phand > zdhnd2
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  Compare designation

     C                   if        zddesg <> ' '
     C                   exsr      getItem
     C                   if        error
     C                   leavesr
     C                   endif
     C                   if        $itdesg <> zddesg
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif
720aA
720aA*  Compare activity zone
720aA
720aAC                   if        zdactv <> ' '
720aAC                   exsr      getItem
720aAC                   if        error
720aAC                   leavesr
720aAC                   endif
720aAC                   if        $itactv <> zdactv
720aAC                   leavesr
720aAC                   else
720aAC                   eval      count += 1
720aAC                   endif
720aAC                   endif

     *  Compare category

     C                   if        zdcat <> ' '
     C                   exsr      getItem
     C                   if        error
     C                   leavesr
     C                   endif
     C                   if        $ifcat <> zdcat
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif
720aA
720aA*  Compare class
720aA
720aA /free
720aA   if zdclcde <> '';
760aD     //setll ($pwhse: $pitem: zdclcde) itemcls;
760aD     //dow forever = forever;
760aD     //  reade ($pwhse: $pitem: zdclcde) itemcls;
760aD     //  if %eof(itemcls);
760aD     //    leavesr;
760aD     //  else;
760aD     //    count += 1;
760aD     //  endif;
760aD     //enddo;
760aA     chain ($pwhse: $pitem: zdclcde) itemcls;
760aA     if not %found(itemcls);
760aA       leavesr;
760aA     endif;
760aA     count += 1;
720aA   endif;
720aa /end-free

     *  Compare uom type

     C                   if        zdutyp <> ' '
     C                   if        $putyp <> zdutyp
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  Compare side

TPCbAC                   select
TPCbAC                   when      client = tpc
TPCbAC                   eval      temp3  = $ploc
TPCbAC     tpcloc        div       2             dummy
TPCbAC                   mvr                     side
TPCbAC                   other
     C     $ploc         div       2             dummy
     C                   mvr                     side
TPCbAC                   endsl

     C                   if        zdside = 'O'
     C                   if        side <> 1
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     C                   if        zdside = 'E'
     C                   if        side <> 0
     C                   leavesr
     C                   else
     C                   eval      count += 1
     C                   endif
     C                   endif

     *  We have a match !!!
     *  Select the zone with the highest number of matches.

     C                   eval      matchFound = *on
     C                   if        count > matchCount
     C                   eval      matchCount = count
     C                   eval      $pszon = zhzone
     C                   eval      $ppzon = zhpzon
     C                   eval      $ptzon = zwtzon
     C                   eval      $pcomp = zwcomp
     C                   eval      $pgen  = zwgen
650aAC                   if        ($ztype = 'B' and opptyp = 'B')
650aAC                   eval      $ptzon = $pszon
650aAC                   eval      $pgen  = 1
650aAC                   endif
     C                   eval      $pzopt = opzdta
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zoneCBIg      Look for hard coded custom def for Cheney GWB
     *----------------------------------------------------------------

     C     zoneCBIg      begsr

CBIuA*    Special override for buyers 92 & 94
CBIuAC                   if        $imbnbr = 92  or
CBIuAC                             $imbnbr = 94
CBIuAC                   eval      $pszon = @b92zn
CBIuAC                   eval      $ptzon = b92tzn
CBIuAC                   eval      $ppzon = b92pzn
CBIuAC                   eval      $pcomp = b92cmp
CBIuAC                   eval      $pgen = b92gen
     C                   eval      matchFound = *on
CBIuAC                   leavesr
CBIuAC                   endif
CBIuA*
CBIuA*    Special override for buyer 95
CBIuAC                   if        $imbnbr = 95
CBIuAC                   eval      $pszon = @b95zn
CBIuAC                   eval      $ptzon = b95tzn
CBIuAC                   eval      $ppzon = b95pzn
CBIuAC                   eval      $pcomp = b95cmp
CBIuAC                   eval      $pgen = b95gen
     C                   eval      matchFound = *on
CBIuAC                   leavesr
CBIuAC                   endif
CBItA*
CBItA*    Special override for CLR Eaches items.
CBItAC                   if        $pwhdp = 'CLR  '  and
CBItAC                             $putyp = '1'  or
CBItA*
CBItA*    Special override for REF Eaches items.
CBItAC                             $pwhdp = 'REF  '  and
CBItAC                             $putyp = '1'  or
CBItA*
CBItA*    Special override for FRZ Eaches items.
CBItAC                             $pwhdp = 'FRZ  '  and
CBItAC                             $putyp = '1'
CBItAC                   eval      $pszon = @cpzon
CBItAC                   eval      $ptzon = rtzone
CBItAC                   eval      $ppzon = rtzone
CBItAC                   eval      $pcomp = rcomp
CBItAC                   eval      $pgen = 2
     C                   eval      matchFound = *on
CBItAC                   leavesr
CBItAC                   endif

     *  All Riviera custom def's apply to GWB

     C                   if        not matchFound
     C                   exsr      zoneCBIr
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zoneCBIo      Look for hard coded custom def for Cheney Ocala
     *----------------------------------------------------------------

     C     zoneCBIo      begsr

     C                   exsr      getitem

     C                   exsr      getORDH

CBIxD*
CBIxD*    Special processing for only regular orders.
CBIxD*      and BREAKERS truck.
CBIxD*
CBIxD*    Note: Do not use special processing on Meat Insp or
CBIxD*          Pre-Pick items.
CBIxD*
CBIxD ***                select
CBIxD*
CBIxD ***                when      dsmeat = 'Y'  or
CBIxD ***                          prepck = 'Y'
CBIxD*           * Ignore Special Processing *
CBIxD ***                leavesr

CBIxD ***                when      $potype <> 'W'  or
CBIxD ***                          $ptruk = 'BREAKERS'  or
CBIxD ***                          $ptruk = @cntnr

CBIxD ***                select
CBIxD*    Special override for CLR Eaches items.
CBIxD ***                when      $pwhdp = 'CLR  '  and
CBIxD ***                          $putyp = '1'  or
CBIxD ***                          $pwhdp = 'REF  '  and
CBIxD ***                          $putyp = '1'
CBIxD ***                if        $paisl = ' CX'  or
CBIxD ***                          $paisl = ' CY'
CBIxD ***                eval      $pszon = @cpzon
CBIxD ***                eval      $ptzon = ctzone
CBIxD ***                eval      $ppzon = ctzone
CBIxD ***                eval      $pcomp = ccomp
CBIxD ***                eval      $pgen = 2
CBIxD ***                else
CBIxD ***                eval      $pszon = @clzon
CBIxD ***                eval      $ptzon = ctzone
CBIxD ***                eval      $ppzon = cpzone
CBIxD ***                eval      $pcomp = ccomp
CBIxD ***                eval      $pgen = cgen
CBIxD ***                endif
CBIxD ***                eval      matchFound = *on
CBIxD ***                leavesr
CBIxD*
CBIxD*    Special override for DRY Eaches items.
CBIxD ***                when      $pwhdp = 'DRY  '  and
CBIxD ***                          $paisl <> ' HZ'  and
CBIxD ***                          $putyp = '1'
CBIxD ***                eval      $pszon = @drzon
CBIxD ***                eval      $ptzon = dtzone
CBIxD ***                eval      $ppzon = dpzone
CBIxD ***                eval      $pcomp = dcomp
CBIxD ***                eval      $pgen = dgen
   xD ***                eval      matchFound = *on
CBIxD ***                leavesr
CBIxD*
CBIxD*    Special override for FRZ '999' items
CBIxD ***                when      $pwhdp = 'FRZ  '
CBIxD ***                          and $itactv = '99'
CBIxD ***                if        $itbld = @icbld
CBIxD ***                eval      $pszon = @iczn9
CBIxD ***                eval      $ptzon = it9zon
CBIxD ***                eval      $ppzon = ip9zon
CBIxD ***                eval      $pcomp = i9comp
CBIxD ***                eval      $pgen = i9gen
   xD ***                eval      matchFound = *on
CBIxD ***                leavesr
CBIxD ***                endif
CBIxD*
CBIxD*    Special override for Ice Cream items.
CBIxD ***                when      $itbld = @icbld
CBIxD ***
CBIxD ***                if        $paisl = ' FX'
CBIxD ***                          or $paisl = ' FY'
CBIxD ***                eval      $pszon = @ipzon
CBIxD ***                eval      $ptzon = itzone
CBIxD ***                eval      $ppzon = itzone
CBIxD ***                eval      $pcomp = icomp
CBIxD ***                eval      $pgen = 2
CBIxD ***                else
CBIxD ***                eval      $pszon = @iczon
CBIxD ***                eval      $ptzon = itzone
CBIxD ***                eval      $ppzon = ipzone
CBIxD ***                eval      $pcomp = icomp
CBIxD ***                eval      $pgen = igen
CBIxD ***                endif
CBIxD ***                eval      matchFound = *on
CBIxD ***                leavesr
CBIxD ***                endsl

CBIxD ***                endsl

     C                   endsr

     *----------------------------------------------------------------
     *  zoneCBIr      Look for hard coded custom def for Cheney Riviera
     *----------------------------------------------------------------

     C     zoneCBIr      begsr

     C                   exsr      getitem

     C                   exsr      getORDH

CBI A*
CBI A*    Special processing for only regular orders.
CBIdA*      and BREAKERS truck.
CBI A*
CBIhA*    Note: Do not use special processing on Meat Insp or
CBIhA*          Pre-Pick items.
CBIhA*
CBI A ***                select
CBIhA*
CBIhA ***                when      dsmeat = 'Y'  or
CBIhA ***                          prepck = 'Y'
CBIhA*           * Ignore Special Processing *
CBIhA ***                leavesr
CBIhA*
CBI A ***                when      $potype <> 'W'  or
CBIdA ***                          $ptruk = 'BREAKERS'  or
CBIl  ***                          $ptruk = @cntnr
CBI A*
CBI A ***                select
CBI A*    Special override for CLR Eaches items.
CBIyD ***                when      $pwhdp = 'CLR  '  and
CBIyD ***                          $putyp = '1'  or
CBIyD ***                          $pwhdp = 'REF  '  and
CBIyD ***                          $putyp = '1'
CBIyD ***                if        $paisl = ' CX'  or
CBIyD ***                          $paisl = ' CY'
CBIyD ***                eval      $pszon = @cpzon
CBIyD ***                eval      $ptzon = ctzone
CBIyD ***                eval      $ppzon = ctzone
CBIyD ***                eval      $pcomp = ccomp
CBIyD ***                eval      $pgen = 2
CBIyD ***                else
CBIyD*
CBIyD ***                if        $paisl = ' CT'
CBIyD*
CBIyD ***                eval      $pszon = @ppzon
CBIyD ***                eval      $ptzon = ptzone
CBIyD ***                eval      $ppzon = ptzone
CBIyD ***                eval      $pcomp = pcomp
CBIyD ***                eval      $pgen = 2
CBIyD ***                else
CBIyD ***                eval      $pszon = @clzon
CBIyD ***                eval      $ptzon = ctzone
CBIyD ***                eval      $ppzon = cpzone
CBIyD ***                eval      $pcomp = ccomp
CBIyD ***                eval      $pgen = cgen
CBIyD ***                endif
CBIyD ***                endif
   yD ***                eval      matchFound = *on
CBIyD ***                leavesr
CBI A*
CBI A*    Special override for DRY Eaches items.
CBI A ***                when      $pwhdp = 'DRY  '  and
CBIaA ***                          $paisl <> ' HZ'  and
CBIrA ***                          $paisl <> ' DK'  and
CBI A ***                          $putyp = '1'  or
CBIrA*
CBIrA ***                          $pwhdp = 'DRY  '  and
CBIrA ***                          $paisl = ' DK'  and
CBIrA ***                          $ploc < 261  and
CBIrA ***                          $putyp = '1'  or
CBIrA*
CBIrA ***                          $pwhdp = 'DRY  '  and
CBIrA ***                          $paisl = ' DK'  and
CBIrA ***                          $ploc > 275  and
CBIrA ***                          $putyp = '1'
CBIrA*
CBIcA ***                if        $paisl = ' DX'  or
CBIcA ***                          $paisl = ' DY'
CBIcA ***                eval      $pszon = @dpzon
CBIcA ***                eval      $ptzon = dtzone
CBIcA ***                eval      $ppzon = dtzone
CBIcA ***                eval      $pcomp = dcomp
CBIcA ***                eval      $pgen = 2
CBIcA ***                else
CBI A ***                eval      $pszon = @drzon
CBI A ***                eval      $ptzon = dtzone
CBI A ***                eval      $ppzon = dpzone
CBI A ***                eval      $pcomp = dcomp
CBI A ***                eval      $pgen = dgen
CBIcA ***                endif
      ***                eval      matchFound = *on
CBI A ***                leavesr
CBI A*
CBI A*    Special override for FRZ Eaches items.
CBIjA*      Non-PIR FRZ Eaches are now being treated normally.
CBI A ***                when      $pwhdp = 'FRZ  '  and
CBI A ***                          $putyp = '1'  and
CBIeA ***                          $itbld <> @icbld
CBIcA ***                if        $paisl = ' FX'  or
CBIcA ***                          $paisl = ' FY'
CBInM ***                eval      $pszon = @fpzon
CBIcA ***                eval      $ptzon = ftzone
CBIcA ***                eval      $ppzon = ftzone
CBIcA ***                eval      $pcomp = fcomp
CBIcA ***                eval      $pgen = 2
      ***                eval      matchFound = *on
CBIjA ***                leavesr
CBIcA ***                else
CBIjA ***                leavesr
CBIcA ***                endif
CBIbA*
CBIbA*    Special override for DRY '999' items
CBIq  ***                when      $pwhdp = 'DRY  '  and
CBIsM ***                          $itactv = '99'
CBIq  ***                eval      $pszon = @drpzn
CBIq  ***                eval      $ptzon = dt9zon
CBIq  ***                eval      $ppzon = dp9zon
CBIq  ***                eval      $pcomp = d9comp
CBIq  ***                eval      $pgen = d9gen
      ***                eval      matchFound = *on
CBIq  ***                leavesr
CBIbA*
CBIbA*    Special override for FRZ '999' items
CBIbA ***                when      $pwhdp = 'FRZ  '  and
CBIsM ***                          $itactv = '99'
CBIiA ***                if        $itbld = @icbld
CBIiA ***                eval      $pszon = @iczn9
CBIiA ***                eval      $ptzon = it9zon
CBIiA ***                eval      $ppzon = ip9zon
CBIiA ***                eval      $pcomp = i9comp
CBIiA ***                eval      $pgen = i9gen
CBIiA ***                else
CBIbA ***                eval      $pszon = @frzn9
CBIbA ***                eval      $ptzon = ft9zon
CBIbA ***                eval      $ppzon = fp9zon
CBIbA ***                eval      $pcomp = f9comp
CBIbA ***                eval      $pgen = f9gen
CBIiA ***                endif
      ***                eval      matchFound = *on
CBIbA ***                leavesr
CBI A*
CBI A*    Special override for Ice Cream items.
CBIeM ***                when      $itbld = @icbld
CBIeA ***                if        $paisl = ' FX'  or
CBIeA ***                          $paisl = ' FY'
CBIeA ***                eval      $pszon = @ipzon
CBIeA ***                eval      $ptzon = itzone
CBIeA ***                eval      $ppzon = itzone
CBIeA ***                eval      $pcomp = icomp
CBIeA ***                eval      $pgen = 2
CBIeA ***                else
CBI A ***                eval      $pszon = @iczon
CBI A ***                eval      $ptzon = itzone
CBI A ***                eval      $ppzon = ipzone
CBI A ***                eval      $pcomp = icomp
CBI A ***                eval      $pgen = igen
CBIeA ***                endif
      ***                eval      matchFound = *on
CBI A ***                leavesr
CBI A ***                endsl
CBI A ***                endsl

     C                   endsr

CBIv *----------------------------------------------------------------
CBIV *  zoneCBIp Look for hard coded custom def for Cheney Punta Gorda
CBUv *----------------------------------------------------------------

CBIv C     zoneCBIp      begsr

     C                   exsr      getitem

     C                   exsr      getORDH

     *
     *    Special processing for only regular orders.
     *      and BREAKERS truck.
     *
     *    Note: Do not use special processing on Meat Insp or
     *          Pre-Pick items.
     *
     C                   select
     *
     C                   when      dsmeat = 'Y'  or
     C                             prepck = 'Y'
     *           * Ignore Special Processing *
     C                   leavesr
     *
     C                   when      $potype <> 'W'  or
     C                             $ptruk = 'BREAKERS'  or
     C                             $ptruk = @cntnr
     *
     C                   select
     *    Special override for CLR Eaches items.
     C                   when      $pwhdp = 'CLR  '  and
     C                             $putyp = '1'  or
     C                             $pwhdp = 'REF  '  and
     C                             $putyp = '1'
     C                   if        $paisl = ' CX'  or
     C                             $paisl = ' CY'
     C                   eval      $pszon = @cpzon
     C                   eval      $ptzon = ctzone
     C                   eval      $ppzon = ctzone
     C                   eval      $pcomp = ccomp
     C                   eval      $pgen = 2
     C                   eval      matchFound = *on
     C                   else
     *
CBIwD ***                if        $paisl = ' CT'
     *
CBIwD ***                eval      $pszon = @ppzon
CBIwD ***                eval      $ptzon = ptzone
CBIwD ***                eval      $ppzon = ptzone
CBIwD ***                eval      $pcomp = pcomp
CBIwD ***                eval      $pgen = 2
CBIwD ***                else
CBIwD ***                eval      $pszon = @clzon
CBIwD ***                eval      $ptzon = ctzone
CBIwD ***                eval      $ppzon = cpzone
CBIwD ***                eval      $pcomp = ccomp
CBIwD ***                eval      $pgen = cgen
CBIwD ***                endif
     C                   endif
     C                   leavesr
     *
     *    Special override for DRY Eaches items.
CBIwD ***                when      $pwhdp = 'DRY  '  and
CBIwD ***                          $paisl <> ' HZ'  and
CBIwD ***                          $paisl <> ' DK'  and
CBIwD ***                          $putyp = '1'
CBIwD*
CBIwD ***                          $pwhdp = 'DRY  '  and
CBIwD ***                          $paisl = ' DK'  and
CBIwD ***                          $ploc < 261  and
CBIwD ***                          $putyp = '1'  or
CBIwD***
CBIwD ***                          $pwhdp = 'DRY  '  and
CBIwD ***                          $paisl = ' DK'  and
CBIwD ***                          $ploc > 275  and
CBIwD ***                          $putyp = '1'
     *
CBIwD ***                if        $paisl = ' DX'  or
CBIwD ***                          $paisl = ' DY'
CBIwD ***                eval      $pszon = @dpzon
CBIwD ***                eval      $ptzon = dtzone
CBIwD ***                eval      $ppzon = dtzone
CBIwD ***                eval      $pcomp = dcomp
CBIwD ***                eval      $pgen = 2
CBIwD ***                else
CBIwD ***                eval      $pszon = @drzon
CBIwD ***                eval      $ptzon = dtzone
CBIwD ***                eval      $ppzon = dpzone
CBIwD ***                eval      $pcomp = dcomp
CBIwD ***                eval      $pgen = dgen
CBIwD ***                endif
CBIwD ***                eval      matchFound = *on
CBIwD ***                leavesr
     *
     *    Special override for FRZ Eaches items.
     *      Non-PIR FRZ Eaches are now being treated normally.
CBIwD ***                when      $pwhdp = 'FRZ  '  and
CBIwD ***                          $putyp = '1'  and
CBIwD ***                          $itbld <> @icbld
CBIwD ***                if        $paisl = ' FX'  or
CBIwD ***                          $paisl = ' FY'
CBIwD ***                eval      $pszon = @fpzon
CBIwD ***                eval      $ptzon = ftzone
CBIwD ***                eval      $ppzon = ftzone
CBIwD ***                eval      $pcomp = fcomp
CBIwD ***                eval      $pgen = 2
CBIwD ***                eval      matchFound = *on
CBIwD ***                leavesr
CBIwD ***                else
CBIwD ***                leavesr
CBIwD ***                endif
     *
     *    Special override for DRY '999' items
CBIwD ***                when      $pwhdp = 'DRY  '  and
CBIwD ***                          $itactv = '99'
CBIwD ***                eval      $pszon = @drpzn
CBIwD ***                eval      $ptzon = dt9zon
CBIwD ***                eval      $ppzon = dp9zon
CBIwD ***                eval      $pcomp = d9comp
CBIwD ***                eval      $pgen = d9gen
CBIwD ***                eval      matchFound = *on
CBIwD ***                leavesr
     *
     *    Special override for FRZ '999' items
CBIwD ***                when      $pwhdp = 'FRZ  '  and
CBIwD ***                          $itactv = '99'
CBIwD ***                if        $itbld = @icbld
CBIwD ***                eval      $pszon = @iczn9
CBIwD ***                eval      $ptzon = it9zon
CBIwD ***                eval      $ppzon = ip9zon
CBIwD ***                eval      $pcomp = i9comp
CBIwD ***                eval      $pgen = i9gen
CBIwD ***                else
CBIwD ***                eval      $pszon = @frzn9
CBIwD ***                eval      $ptzon = ft9zon
CBIwD ***                eval      $ppzon = fp9zon
CBIwD ***                eval      $pcomp = f9comp
CBIwD ***                eval      $pgen = f9gen
CBIwD ***                endif
CBIwD ***                eval      matchFound = *on
CBIwD ***                leavesr
     *
     *    Special override for Ice Cream items.
CBIwD ***                when      $itbld = @icbld
CBIwD ***                if        $paisl = ' FX'  or
CBIwD ***                          $paisl = ' FY'
CBIwD ***                eval      $pszon = @ipzon
CBIwD ***                eval      $ptzon = itzone
CBIwD ***                eval      $ppzon = itzone
CBIwD ***                eval      $pcomp = icomp
CBIwD ***                eval      $pgen = 2
CBIwD ***                else
CBIwD ***                eval      $pszon = @iczon
CBIwD ***                eval      $ptzon = itzone
CBIwD ***                eval      $ppzon = ipzone
CBIwD ***                eval      $pcomp = icomp
CBIwD ***                eval      $pgen = igen
CBIwD ***                endif
CBIwD ***                eval      matchFound = *on
CBIwD ***                leavesr
     C                   endsl
     C                   endsl

CBIv C                   endsr
CPC A
CPC A*----------------------------------------------------------------
CPC A*  zoneCPC       Look for hard coded custom def for Crumbley Paper
CPC A*----------------------------------------------------------------
CPC A
CPC AC     zoneCPC       begsr
CPC A
CPC AC                   select
CPC AC                   when      $pwhdp = 'DRY  '
CPC AC                   eval      kyZone = 'DRYB'
CPC AC                   exsr      getZoneH
CPC AC                   if        zonehFound
CPC AC                   eval      matchFound = *on
CPC AC                   eval      $pszon = 'DRYB'
CPC AC                   eval      $ppzon = '    '
CPC AC                   eval      $ptzon = 'DRYB'
CPCbDC**                 eval      $pcomp = 'D'
CPCbMC                   eval      $pcomp = 'B'
CPC AC                   eval      $pgen  = 1
CPC AC                   eval      $pzopt = opzdta
CPC AC                   endif
CPC A
CPC AC                   endsl
CPC A
CPC AC                   endsr

     *----------------------------------------------------------------
     *  zoneHAR       Look for hard coded custom def for Harbor
     *----------------------------------------------------------------

     C     zoneHAR       begsr

     *  Force all dept 'T' items to be Tote items.

     C                   if        client = Harbor
     C                             and $pwhdp = 'T'
520cD ***                eval      $pTote = 'Y'
520cMC                   eval      $ztype = 'Y'
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zoneJOR       Look for hard coded custom def for Jordanos
     *----------------------------------------------------------------

     C     zoneJOR       begsr

     *   For Jordanos, if slot desg = 'CHEM', force into zone ZCHEM.

JORx C*                  if        $pdesg = 'CHEM'
     C*                  eval      kyZone = 'ZCHEM'
     C*                  exsr      getZoneH
     C*                  if        zonehFound
     C*                  eval      matchFound = *on
     C*                  eval      $pszon = zhzone
     C*                  eval      $ppzon = zhpzon
     C*                  eval      $ptzon = zwtzon
     C*                  eval      $pcomp = zwcomp
     C*                  eval      $pgen  = zwgen
     C*                  eval      $pzopt = opzdta
     C*                  leavesr
     C*                  endif
     C*                  endif

     C                   endsr

SLB A*----------------------------------------------------------------
SLB A*  zoneSLB       Look for hard coded custom def for Silberman
SLB A*----------------------------------------------------------------
SLB A
SLB AC     zoneSLB       begsr
SLB A
SLB AC                   select
SLB AC                   when      $pwhdp = 'DRY  '
SLB AC                   eval      kyZone = 'DRYB'
SLB AC                   exsr      getZoneH
SLB AC                   if        zonehFound
SLB AC                   eval      matchFound = *on
SLB AC                   eval      $pszon = 'DRYB'
SLB AC                   eval      $ppzon = '    '
SLB AC                   eval      $ptzon = 'DRYB'
SLB MC                   eval      $pcomp = 'B'
SLB AC                   eval      $pgen  = 1
SLB AC                   eval      $pzopt = opzdta
SLB AC                   endif
SLB A
SLB AC                   endsl
SLB A
SLB AC                   endsr

NCSaA*----------------------------------------------------------------
NCSaA*  zoneNCS       Look for hard coded custom def for Nicholas
NCSaA*----------------------------------------------------------------
NCSaA
NCSaAC     zoneNCS       begsr

NCSaAC                   select
NCSaA*  Dry Batch Pick
NCSaAC                   when      $pwhdp = 'D    '
NCSaAC                   eval      kyZone = 'DRYB'
NCSaAC                   exsr      getZoneH
NCSaAC                   if        zonehFound
NCSaAC                   eval      matchFound = *on
NCSaAC                   eval      $pszon = 'DRYB'
NCSaAC                   eval      $ppzon = '    '
NCSaAC                   eval      $ptzon = 'DRYB'
NCSaMC                   eval      $pcomp = 'X'
NCSaAC                   eval      $pgen  = 1
NCSaAC                   eval      $pzopt = opzdta
NCSaAC                   endif
NCSaA*  Freezer Batch Pick
NCSaAC                   when      $pwhdp = 'F    '
NCSaAC                   eval      kyZone = 'FRZB'
NCSaAC                   exsr      getZoneH
NCSaAC                   if        zonehFound
NCSaAC                   eval      matchFound = *on
NCSaAC                   eval      $pszon = 'FRZB'
NCSaAC                   eval      $ppzon = '    '
NCSaAC                   eval      $ptzon = 'FRZB'
NCSaMC                   eval      $pcomp = 'Y'
NCSaAC                   eval      $pgen  = 1
NCSaAC                   eval      $pzopt = opzdta
NCSaAC                   endif
NCSaA*  Cooler Batch Pick
NCSaAC                   when      $pwhdp = 'C    '
NCSaAC                   eval      kyZone = 'REFB'
NCSaAC                   exsr      getZoneH
NCSaAC                   if        zonehFound
NCSaAC                   eval      matchFound = *on
NCSaAC                   eval      $pszon = 'REFB'
NCSaAC                   eval      $ppzon = '    '
NCSaAC                   eval      $ptzon = 'REFB'
NCSaMC                   eval      $pcomp = 'Z'
NCSaAC                   eval      $pgen  = 1
NCSaAC                   eval      $pzopt = opzdta
NCSaAC                   endif
NCSbA*  Chemical Batch Pick
NCSbAC                   when      $pwhdp = 'H    '
NCSbAC                   eval      kyZone = 'CHEMB'
NCSbAC                   exsr      getZoneH
NCSbAC                   if        zonehFound
NCSbAC                   eval      matchFound = *on
NCSbAC                   eval      $pszon = 'CHEMB'
NCSbAC                   eval      $ppzon = '    '
NCSbAC                   eval      $ptzon = 'CHEMB'
NCSbMC                   eval      $pcomp = 'W'
NCSbAC                   eval      $pgen  = 1
NCSbAC                   eval      $pzopt = opzdta
NCSbAC                   endif

NCSaAC                   endsl

NCSaAC                   endsr
     *----------------------------------------------------------------
     *  zoneTPC       Look for hard coded custom def for TPC
     *----------------------------------------------------------------

     C     zoneTPC       begsr

     *   For TPC, if item starts with 'OK-', force into zone PROD.

     C                   movel     $pitem        temp3a
     C                   if        temp3a = 'OK-'
     C                   eval      kyZone = 'PROD'
     C                   exsr      getZoneH
     C                   if        zonehFound
     C                   eval      matchFound = *on
     C                   eval      $pszon = zhzone
     C                   eval      $ppzon = zhpzon
     C                   eval      $ptzon = zwtzon
     C                   eval      $pcomp = zwcomp
     C                   eval      $pgen  = zwgen
     C                   eval      $pzopt = opzdta
     C                   leavesr
     C                   endif
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  zoneMATT      Look for hard coded custom def for Mattingly
     *----------------------------------------------------------------

     C     zoneMAT       begsr

     C                   select
     C                   when      $pwhdp = '30   '
     C                   eval      kyZone = 'DRYB'
     C                   exsr      getZoneH
     C                   if        zonehFound
     C                   eval      matchFound = *on
     C                   eval      $pszon = 'DRYB'
     C                   eval      $ppzon = '    '
     C                   eval      $ptzon = 'DRYB'
     C                   eval      $pcomp = 'D'
     C                   eval      $pgen  = 1
     C                   eval      $pzopt = opzdta
     C                   endif

     C                   when      $pwhdp = '10   '
     C                   eval      kyZone = 'FRZB'
     C                   exsr      getZoneH
     C                   if        zonehFound
     C                   eval      matchFound = *on
     C                   eval      $pszon = 'FRZB'
     C                   eval      $ppzon = '    '
     C                   eval      $ptzon = 'FRZB'
     C                   eval      $pcomp = 'F'
     C                   eval      $pgen  = 1
     C                   eval      $pzopt = opzdta
     C                   endif

     C                   when      $pwhdp = '20   '
     C                   eval      kyZone = 'CLRB'
     C                   exsr      getZoneH
     C                   if        zonehFound
     C                   eval      matchFound = *on
     C                   eval      $pszon = 'CLRB'
     C                   eval      $ppzon = '    '
     C                   eval      $ptzon = 'CLRB'
     C                   eval      $pcomp = 'R'
     C                   eval      $pgen  = 1
     C                   eval      $pzopt = opzdta
     C                   endif
     C                   endsl

     C                   endsr

620aA*----------------------------------------------------------------
620aA*  zonePrepick   Look for prepick zone
620aA*----------------------------------------------------------------
620aA
620aAC     zonePrepick   begsr

     *   If aisle isn't PRE, get out.

     C                   if        $paisl <> 'PRE'
     C                   leavesr
     C                   endif

     *   Look for 'S' zone. Get out if not found.

     C                   exsr      getZonePRE

     C                   if        not preZoneFound
     C                   leavesr
     C                   endif

     *   Otherwise, we have a match.

     C                   eval      matchFound = *on
     C                   eval      $pszon = zhzone
     C                   eval      $ppzon = zhpzon
     C                   eval      $ptzon = zwtzon
     C                   eval      $pcomp = zwcomp
     C                   eval      $pgen  = zwgen
     C                   eval      $pzopt = opzdta

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
     C                   eval      $slver# = savever#
     C                   endsr

     *----------------------------------------------------------------
     *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

     C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   endsl

     C                   if        $dricommand = '*ITEM'
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
     C**                 eval      errmsg    = 'Error occured on call to '
     C**                                     + 'DRICOP'
     C**                                     + '/' + %trim($drisubcmd)
     C**                                     + ' from ' + #prog
     C**                 select
     C**                 when      zmsflag
     C**                 exsr      zm0105s
     C**                 when      zmflag
     C**                 exsr      zm0105
     C**                 endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C**                 select
     C**                 when      zmsflag
     C**                 exsr      zm0001s
     C**                 when      zmflag
     C**                 exsr      zm0001
     C**                 exsr      zzerrind
     C**                 endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr
