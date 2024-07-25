700cA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Any changes made to this program should also be made to II295S
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II295     FTP - Import item updates - Ver 4
     *  22 February 2007
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Notes:
     *
     *      For add or change, can not update ITEMDEF records,
     *      user will need to make any changes in item maintenance.
     *
     *      This program is a mirror of II285.
     *      - Uses IMPFITM4 to process ITEMMSC fields added in 4.16.
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
511aA*   02/23/07  DAS  5.11a
     *     - Created
     *     - This was intentionally coded as 511 instead of 510 in
     *       order to keep the current 510 changes from II285 and
     *       still mark the new additions for Repack with 511.
     *
511bA*   02/24/07  DAS  5.11b
     *     - Added logic to automatically try and create a Repack slot
     *       for a Repack item.
     *
511cA*   02/28/07  DAS  5.11c
     *     - Revised check for Repack item from <>'R' to ='R'.
     *
520 A*    02/17/09  MLB  5.20
     *      - Enh: Revised program to add support for stand catchweight
     *        items. IUCWGT = 'S'
     *
600aA*    03/01/09  DAS  6.00a  P#00065
     *     - Enh: Revised to not hardcode IMLTRK license tracking value.
     *     - Enh: Revised to call LT002 at the end of the program to
     *       to set license tracking value of all items that do not
     *       have a valid value.
     *
610 A*    09/03/09  MLB  6.10
     *     - Fix: Revised to padd short unit of measure with blanks
     *        when UoM not found in table.
     *
530 A*    11/20/09  MLB  5.30
     *      - Fix: Revised program to set IMLOT to N=No if OPLOT = N.
530aA*    03/15/10  MLB  5.30a
     *     - Fix: Revised program to update program so that IUODAY
     *        - # of Days Out is defaulted to 360 days for date
     *        sensitive items when IMODAY=0. If Host sends a value in
     *        IUODAY, then that value will be updated in IMODAY.
530bA*    05/25/07  MLB  5.30b
     *      - Fix: Corrected errors with 4.17f fix. Several ITEMMSC
     *        fields were being cleared when a item was added.
     *      - This patch was missed for this pgm. See 5.10j in II285.
     *
640aA*    04/18/11  RH/MLB  6.40a
     *      - Fix: Revised program to update # of pick slots on update
640bA*    04/21/11  MLB  6.40b
     *     - Fix: Revised program when item cube is not updated from
     *        host and item dimensions are imported, to update item cube
     *        when the new computed cube is different from the cube on
     *        file.
640c *    10/18/12  LMC  6.40c
     *      ITEMFLD database change - requires recompile.
640eA*     08/09/12  MLB  6.40e
     *       - Fix: Revised program to cause pgm to compute item cube
     *         opcube=Y and IUCUBE = 0.000. Pgm was not computing cubebe
     *         item when dimensions sent, but zero cube imported.
     *
650 A*    02/21/13  MLB  6.50
     *      - Enh: Recompiled pgm due to change in import file keys.
     *
650aA*    03/19/13  MLB  6.50a
     *      - Enh: Revised pgm to add Key sort to PIRITEM f-spec.
650bA*    04/11/13  MLB  6.50b
     *      - Enh: Revised pgm to add record to ITEMFLD file only when
     *        item doesn't exist. Initialize following new fields:
     *        IFUCICDE, IFRCVMTH, IFSLTMTH and IFBRDFLG.
650cA*    06/14/13  KDE  6.50c
     *      - Enh: If KITCOMP key change sent update correctly
650dA*    06/17/13  MLB  6.50d
     *      - Fix: Revised program to set ITFLGD to N=No if OPFLGD = N.
     *      - Fix: Revised program to set IMMFLG to N=No if OPMFLG = N.
650eA*    06/22/13  MLB  6.50e
     *      - Fix: Revised program to unlock record when chaining to
     *        UNMESR, ACTIVITY and BLDCODE.
650fA*    03/22/13  KDE  6.50f
     *      - Enh: Changed to add blanks for DISP field in KITCOMP and
     *       changed to add KITITEM with default values for new Repack
     *       KIT format.  I am ONLY adding defaults to KITITEM until we
     *       add more fields to the incoming import
650gA*    08/10/13  MLB  6.50g
     *      - Fix: Revised program to unlock record when chaining to
     *        DESIG.
650hA*    08/28/13  KDE  6.50g
     *      - Enh: Changed Itemlnk key to now have ilitm2 in the primary
     *       key
650iA*    12/12/13  RTR  6.50i
     *      - Fix: If empty member in IMPFITMM program was trying to
     *        write empty record to ITEMEXT1. Change to not attempt
     *        to write if empty fields.
650jA*    05/29/14  MLB  6.50j
     *      - Fix: Revised pgm to set ITCWGT = 'N' if ITCWGT = ' '
     *        when OPCWGT = N'.
650k *    02/18/15  RTR  6.50k
     *      - Fix: Convert special chars to blanks in item description.
     *
700a *    07/23/15  RTR  7.00a
     *      - Fix: Add mod 610 to brkdwn 1 & 2 also.
700b *    03/03/16  RTR  7.00b
     *      - Enh: Skip blank records.
     *      - Enh: Uppercase item numbers.
700cA*    06/11/16  DAS  7.00c
     *      - Enh - Revised to delete *EACH records from
     *        ITEMAVG, ITEMSLS.
700dA*    11/02/16  LMC  7.00d
     *      - Recompile only - UPC file changed.
     *
720a *    04/24/18  RTR  7.20a
     *      - Enh: Left justify all text fields.
730a *    01/21/19  RTR  7.30a
     *      - Enh: Uppercase department.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's Provision
     *
PAK A*    09/13/06  MLB  PAK
     *      - Revise program to convert IUWHDP code to DRY, FRZ or REF.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Capitol City Produce
     *
CCP A*    04/12/10  MLB  CCP
     *      - Revise program to set IMODAY=30 days instead of 360 for
     *        new items. Per Roxanne H. IM
CCPaA*    04/13/10  MLB  CCPa
     *      - Revise program to not process any updates for type R=Repack
     *        items.  Only add or deletes will be processed for Repack
     *        iotems.
CCPbA*    04/15/10  MLB  CCPb
     *      - Revise program to set Notice Days to 1/2 of of Shelf
     *        life days. Per Roxanne H.
CCPcA*    07/19/16  MLB  CCPc
     *      - Revise program to retrieve PIRITEM rcd.If item type A=Alias
     *        then set IUTYPE=A so that item is not converted from Alias
     *        to Normal item.  CCP's system cannot identify Alias items.
     *      - Added CCPc to CSPb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    04/12/10  MLB  CSP
     *      - Revise program to set IMODAY=30 days instead of 360 for
     *        new items. Per Roxanne H. IM
     *      - Added CSP to CCP mod.
CSPaA*    04/13/10  MLB  CSPa
     *      - Revise program to not process any updates for type R=Repack
     *        items.  Only add or deletes will be processed for Repack
     *        items.
     *      - Added CSP to CCPa mod.
CSPbA*    04/22/10  MLB  CSPb
     *      - Revise program to retrieve PIRITEM rcd.If item type A=Alias
     *        then set IUTYPE=A so that item is not converted from Alias
     *        to Normal item.  CSP's system cannot identify Alias items.
CSPcA*    04/28/10  MLB  CSPc
     *      - Revise program to compute Breakdown 2 quantity for items
     *        that have both Breakdown 1 and Breakdown 2 values imported.
     *        Breakdown 2 needs to be converted to number of units in
     *        Breakdown 1 instead of number of units in full unit.
     *        Ex: item# CUC01 has brkdwn 1=2 units, brkdwn 2=55 units.
     *        After update brkdwn 1=2 units, brkdwn 2=28 units.
CSPdA*    12/30/10  MLB  CSPd
     *      - Revise program to retrieve category code for items and
     *        bypass update of breakdown 1, 2 information for items
     *        with category code ODR.
     *      - Added file ITEMFLD.
CSPeA*    11/15/11  MLB  CSPe
     *      - Revise program to not update item catchwgt variances
     *        for existing items. Per email from Hemant on 11/15/11.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Andrews Foodservice
     *
AFS A*    04/21/11  MLB  AFS
     *      - Revise program to default computed cube to 0.100 if zero.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Crumbley Paper & Foodservice
     *
CPC A*    07/11/11  MLB  CPC
     *      - Revise program to update ITUM2, ITUMQ2 and ITFLG1 when
     *        IUFLG1 = 'Y' and OPxxx = N.
CPCaA*    09/01/11  MLB  CPCa
     *      - Revise program to retrieve PIRITEM rcd.If item type A=Alias
     *        then set IUTYPE=A so that item is not converted from Alias
     *        to Normal item.  CSP's system cannot identify Alias items.
     *      - Added CPCa to CSPb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMWaA*    11/20/13  RTR  HMWa
     *      - Revised to convert departments from 1,2,3 for Aspen
     *        host system.
HMWbA*    12/23/14  RTR  HMWb
     *      - Changed to set IUMFLG = 'N' when IUMDAY = 1 per email from
     *        Roxanne on 12/22/14 to handle Aspen not having IUMFLG.
HMWcA*    01/05/15  RTR  HMWc
     *      - Check for update to parent item to prevent UOM removal.
HMWdA*    01/06/15  RTR  HMWd
     *      - Fix for ITUMQ2 populated by Aspen when ITUM2 blank and
     *        ITFLG1 = 'N'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Stern Produce
     *
SPI A*    12/14/12  MLB  SPI
     *      - Revise program to set IMODAY=30 days instead of 360 for
     *        new items.
     *      - Added SPI to CCP mod.
SPIaA*    12/14/12  MLB  SPIa
     *      - Revise program to not process any updates for type R=Repack
     *        items.  Only add or deletes will be processed for Repack
     *        items.
     *      - Added SPIa to CCP mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLP A*    04/11/13  MLB  GLP
     *      - Revise program to update value sent in IUACTV and update
     *        into Category Code for item. Per Roxanne skype 04/11/13.
     *      - Value sent in Activity Zone will NOT be updated in field
     *        in PIRITEM.
     *      - Revised pgm to ctivity Zone will NOT be updated in field
     *        in PIRITEM.
GLPaA*    04/12/13  MLB  GLPa
     *      - Revise program to retrieve PIRITEM rcd.If item type A=Alias
     *        then set IUTYPE=A so that item is not converted from Alias
     *        to Normal item.  GLP's system cannot identify Alias items.
GLPbA*    04/21/13  MLB  GLPb
     *      - Revise program to call GETUSER to retrieve buyer number
     *        stored in the PIR User table as employee number. Buyer
     *        number will be updated to IMBNBR.
GLPcA*    06/14/13  RH   GLPc
     *      - Fix: revise to update ITFLG1, ITUMQ2 and ITUM2 to allow
     *        ODR item that is parent and child to be adjusted.
GLPdA*    02/07/14  RTR  GLPd
     *      - Fix: revise
GLPeA*    02/10/14  KDE  GLPe
     *      - Fix: Prevent Item Maintenance upload from adding RPK
     *        work order slots since only ODR items are used and
     *        work order system will add as needed if they ever use
     *----------------------------------------------------------------
     *  Client Custom Revisions: Get Fresh Sales
     *
GFSaA*    02/26/13  MLB  GFSa
     *      - Revise program to not update KITCOMP for type R=Repack
     *        items.  Only additions/deletions will be processed for
     *        Repack items.
GFSbA*    06/14/13  MLB  GFSb
     *      - Revise program to move Minimum Order Qty from IUBLNK in
     *        to field ITRCVD.  This field is needed for converting
     *        splits items into units from ordered pounds.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    01/21/15  RTR  SBRa
     *      - Revise to uppercase DEPT and default blank dept to BLANK.
SBRb *    02/10/15  RTR  SBRb
     *      - Don't replace dept with a blank value.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
     *
FGLa *    03/03/16  RTR  FGLa
     *      - Convert zone to department.
FGLb *    05/10/16  RTR  FGLb
     *      - Set 999 items to designation SPCL.
FGLc *    05/11/16  RTR  FGLc
     *      - FDS doesn't do PIR. If existing item is PIR,
     *        do not update section type for Foods Galore.
FGLd *    11/03/16  RTR  FGLd
     *      - For items with breakdown UOM1 blank and qty>0, set to EA, Y.
FGLe *    01/12/16  RTR  FGLe
     *      - Change FDS Designation NSTK to NSTK*.
     *      - Set number of pick slots to 1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCaA*    10/03/14  RTR  PFCa
     *      - Uppercase item numbers.
PFCbA*    10/07/14  RTR  PFCb
     *      - If description begins with * set designation = SPCL.
PFCcA*    10/29/14  RTR  PFCc
     *      - Uppercase UOM.
PFCdA*    10/30/14  RTR  PFCd
     *      - If * and BOX in description, make NOT SPCL designation.
     *        NOTE: this mod will probably be removed after new racks
     *        installed.
PFCe *    02/05/15  RTR  PFCe
     *      - Changed PFCd to only look for * or ***. ** is not special
     *        order item.
PFCf *    02/24/15  RTR  PFCf
     *      - Enh: for Presto, if Vendor Item exists do not update it.
     *        Once ITVIT# is populated only update from PO vendor item
     *        or item maintenance screens.
PFCg *    03/03/15  RTR  PFCg
     *      - Changed PFCe. '***' now NOT special per email from Rhonda.
PFCh *    06/03/15  RTR  PFCh
     *      - Change to handle repack item setup. If Vendor Item Desc =
     *        'REPACK', set type=R and positions 7-12 of Vnd Itm Desc
     *        to Master Item.
PFCiA*    12/04/15  MLB  PFCi  P#01482
     *      - Enh: Revised pgm to default ITSTYP = 'F' when new items
     *        are added. Presto switching dept DRY, aisle J25 to PIR.
     *        Items for J25 will be manually maintained on Dakota.
     *        Host system cannot send F=Fixed or P=PIR for Section Type
     *        at this time.
PFCjA*    05/12/17  MLB  PFCj
     *      - Revise program to retrieve PIRITEM rcd.If item type A=Alias
     *        then set IUTYPE=A so that item is not converted from Alias
     *        to Normal item.  PFC's system cannot identify Alias items.
     *      - Added PFCj to CSPb mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    05/02/18  RTR  CFIa
     *      - Default Section Type to F.
CFIb *    05/19/18  RTR  CFIb
     *      - Temp mod to turn off date sensitive for DRY/FRZ.
CFIc *    05/31/18  RTR  CFIc
     *      - Temp mod to set breakdown 1 sell flag to N for LB breakdowns.
CFIdA*    05/20/21  MLB  CFId
     *      - Disabled CBIb mod per Paul B response in zd# 4311. Date
     *        sensitive items will be managed from Aspen for DRY/FRZ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
ACCa *    05/27/18  RTR  ACCa
     *      - Default Section Type to F.
ACCb *    11/09/18  RTR  ACCb
     *      - Divide breakdown 2 by breakdown 1.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    02/18/10  JCJ  DRY
     *      - Revise program to set flag IMWRNC to Y/N based on value in
     *        IUBLNK where IUBLNK=0=N or =1=Y. This flag will be used
     *        in CW112 to control whether 1 total wgt or multiple
     *        individual wgts are entered.
DRYaA*    01/11/12  MLB  DRYa
     *      - Revise program to update ITWHDP for new items only even
     *        though OPWHDP = N. Item will be defaulted to Host depart-
     *        ment when item is added. After that, individual warehouse
     *        locations will maintain the department. This mod is being
     *        done because not all of Dairyland's warehouses store an
     *        item in the same warehouse area. This mod will allow each
     *        warehouse to control where they store an item.
DRYbA*    06/08/15  MLB  DRYb
     *      - Revise program to update IMODAY to 720 days for items with
     *        ITWHDP = 'DRY'. All other items will default to 360.
     *      - Per Kelly R email dated 06/05/2015.
DRYcA*    09/22/15  MLB  DRYc
     *      - Revise DRYa mod. Revise pgm to update ITWHDP when OPWHDP=N
     *        and item on file, but ITWHDP = ' '.
DRYdA*    11/07/16  MLB  DRYd
     *      - Revise program to update item c/wgt variance fields for new
     *        items and update if variances are zero and update has
     *        positive values.
DRYeA*    03/02/22  MLB  DRYe
     *      - Revise DRYd mod to correct update for c/wgt variance 2 field.
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *  61        - Special order (Customer # > 0)
     *  79        - EOF for IMPITM4
     *  91        - Overflow indicator
     *
     *----------------------------------------------------------------
     * File Specs
     *
650aDF*impfitm4  uf   e             disk
650aMFimpfitm4  uf   e           k disk
510cAFimpfitmm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpiritem   uf a e           k disk
     Fitemdsc   uf a e           k disk
     Fitemdef   uf a e           k disk
650bDF*itemfld   if   e           k disk    usropn
650bMFitemfld   uf a e           k disk
     Fitemlnk   uf a e           k disk
     Fitemlnk1  if   e           k disk
     F                                     rename(ilrec:record1)
     Fitemmsc   uf a e           k disk
510cAFitemext1  uf a e           k disk
510dAFitemsls   uf   e           k disk    usropn
510dAFitemavg   uf   e           k disk    usropn
     Foptions   if   e           k disk
     Fitemqty   uf a e           k disk
     Fii265pr   o    e             printer oflind(*in91)
     Fwhdept    if   e           k disk
     Fdesig     uf a e           k disk
     Factivity  uf a e           k disk
     Funmesr    uf a e           k disk
     Fbldcode   uf a e           k disk
     Fslot3     uf   e           k disk
     Fupc1      uf   e           k disk
511aAFkitcomp   uf a e           k disk
650fAFkititem   uf a e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
PAK A /COPY QCOPYSRC,ID#packers
CCP A /COPY QCOPYSRC,ID#capitol
CSP A /COPY QCOPYSRC,ID#coastal
AFS A /COPY QCOPYSRC,ID#andrews
CPC A /COPY QCOPYSRC,ID#cpc
HMWaA /COPY QCOPYSRC,ID#hmwagne
SPI A /COPY QCOPYSRC,ID#spi
GLP A /COPY QCOPYSRC,ID#glp
GFSaA /COPY QCOPYSRC,ID#gfs
SBRaA /COPY QCOPYSRC,ID#sbr
FGLaA /COPY QCOPYSRC,ID#fgl
PFCaA /COPY QCOPYSRC,ID#pfc
CFIaA /COPY QCOPYSRC,ID#cfi
ACCaA /COPY QCOPYSRC,ID#acc
DRY A /copy qcopysrc,id#dairyla
510bA*
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     *                   DESC    1  44 30
510fDD*desc            s             30    dim(45) ctdata perrcd(1)
510fMD*desc            s             30    dim(46) ctdata perrcd(1)
HMWcMD desc            s             30    dim(47) ctdata perrcd(1)
     D cdsc            s             30    dim(1) ctdata perrcd(1)
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
     D  $lsdef                22     23
     D  $lwhdp                22     26
     D  $litem                22     36
     *
     D  $ldesg                19     23
     *
     D  $lactv                19     20
     *
     D  $lum                  19     20
     *
     D  $lbc                  19     20
     *
     D  $lwhs1                19     21  0
     D  $litm1                22     36
     D  $lwhd1                37     41
     D  $lsty1                42     42
     D  $lst1                 43     44
     D  $lpal1                45     50
     D  $lovr1                51     53  2
     *
     D  $lwhs2                19     21  0
     D  $lwhd2                22     26
     D  $litm2                27     41
     D  $lcnt                 42     44  0
     D  $lrepl                45     45
     D  $lulen                46     50  2
     D  $luwdt                51     55  2
     D  $lstyp                56     56
     *----------------------------------------------------------------
     *  *ITEMMNT  -  Item maintenance options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTYP  -  Default section type
     *    OPWHDP  -  Default warehouse department
     *    OPUM1   -  Default normal unit of measure
     *    OPDUM   -  Unit of measure for dimensions
     *    OPCUM   -  Unit of measure for cube
     *    OPCDIV  -  Divisor for cube
     *    OPCAUT  -  Automaticaly calculate cube when zero (Y/N)
     *    OPCWRN  -  Display cube warning (Y/N)
     *    OPCRNG  -  Display cube warning range percentage
     *    OPWUM   -  Unit of measure for weight
     *
     * Data structure
     *
     *PDATA      DS
     D opdat1          ds
     *                                       1   1 OPSTYP
     *                                       2   6 OPWHDP
     *                                       7   8 OPUM1
     D  opdum                  9     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  3
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
     *----------------------------------------------------------------
     *  *IMPITEM  -  Import Item options.
     *----------------------------------------------------------------
     *
     *    Y = Maintained by Host, imported to FSWMS
     * Fields
     *
     *    OPITYP  -  Item type
     *    OPDESC  -  Item description
     *    OPWHDP  -  Warehouse department
     *    OPSTYP  -  Section type
     *    OPWHDP  -  Default warehouse department
     *    OPDESG  -  Designation
     *    OPACTV  -  Activity
     *    OPBLD   -  Build code
     *    OPVEN#  -  Vendor number
     *    OPVIT#  -  Vendor item number
     *    OPPDSC  -  Pack description
     *    OPUM1   -  Normal unit of measure
     *    OPUM2   -  Breakdown 1 unit of measure
     *    OPUMQ2  -  Breakdown 1 UM quantity
     *    OPFLG1  -  Allow Breakdown 1 Sale
     *    OPUM3   -  Breakdown 2 unit of measure
     *    OPUMQ3  -  Breakdown 2 UM quantity
     *    OPFLG2  -  Allow Breakdown 2 Sale
     *    OPULEN  -  Unit length
     *    OPUWDT  -  Unit width
     *    OPUHGT  -  Unit height
     *    OPCUBE  -  Cube/Unit
     *    OPSWGT  -  Shipping weight
     *    OPCWGT  -  Catch weight
     *    OPREPL  -  Replenish level
     *    OPFLGD  -  Date sensitive
     *    OPFLGB  -  Allow bulk pick
     *    OPSLIF  -  Shelf life days
     *    OPNDAY  -  Notice days
     *    OPTIE   -  Mfr. Tie
     *    OPHIGH  -  Mfr. High
     *    OPMFLG  -  Manufacturing date
     *    OPDDAY  -  Distributor days
     *    OPUDAY  -  End user days
     *    OPMDAY  -  Mfr. shelf life days
     *    OPMITM  -  Master item number
     *    OPCITM  -  Contract Base item #
     *    OPNSLT  -  Non-slotted item
     *    OPXDCK  -  Crossdock item
     *    OPBNBR  -  Buyer number
     *    OPBNAM  -  Buyer name
     *    OPVNAM  -  Vendor name
     *    OPBRND  -  Brand
     *    OPLOT   -  Lot code item
     *    OPLTRK  -  Track by license
     *
     * Data structure
     *
     D opdat2          ds
     D  opityp                 1      1
     D  opdesc                 2      2
     D  opwhdp                 3      3
     D  opstyp                 4      4
     D  opdesg                 5      5
     D  opactv                 6      6
     D  opbld                  7      7
     D  opven#                 8      8
     D  opvit#                 9      9
     D  oppdsc                10     10
     D  opum1                 11     11
     D  opum2                 12     12
     D  opumq2                13     13
     D  opflg1                14     14
     D  opum3                 15     15
     D  opumq3                16     16
     D  opflg2                17     17
     D  opulen                18     18
     D  opuwdt                19     19
     D  opuhgt                20     20
     D  opcube                21     21
     D  opswgt                22     22
     D  opcwgt                23     23
     D  oprepl                24     24
     D  opflgd                25     25
     D  opflgb                26     26
     D  opslif                27     27
     D  opnday                28     28
     D  optie                 29     29
     D  ophigh                30     30
     D  opmflg                31     31
     D  opdday                32     32
     D  opuday                33     33
     D  opmday                34     34
     D  opmitm                35     35
     D  opcitm                36     36
     D  opnslt                37     37
     D  opxdck                38     38
     D  opbnbr                39     39
     D  opbnam                40     40
     D  opvnam                41     41
     D  opbrnd                42     42
     D  oplot                 43     43
     D  opltrk                44     44
     D  opten2               117    117
650kA*----------------------------------------------------------------
650kA*  Constants
650kA*----------------------------------------------------------------
650kAD okchar          c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ+
650kAD                                      abcdefghijklmnopqrstuvwxyz+
650kAD                                      0123456789+
650kAD                                      .%/- ()*&$#!?='

510bA*----------------------------------------------------------------
510bA*  Working Variables
510bA*
     D actcub          s                   like(itcube)
     D addflg          s              1
     D a2nflg          s              1
     D chgflg          s              1
650aAD chkpos          s              3  0
650aAD chkstr          s             80a
     D count           s              3  0
700cAD dltItem         s                   like(ititem)
     D eofd            s              1
     D eofi            s              1
     D eofl            s              1
     D error           s              1
     D first           s              1
     D forevr          s              1
     D grdord          s              5  0
700cAD i               s              3  0
     D impdte          s              8  0
     D imptim          s              6  0
     D itumq3          s              3  0
     D itum2           s              2
     D itum3           s              2
     D kysdef          s              2
     D kywhse          s              3  0
     D len             s              1  0
     D linppg          s              3  0
510cAD miscitmupd      s              4    inz('*NO ')
510cAD opnimpitmm      s              1    inz('0')
     D opcode          s              8
     D pflag           s              1
     D pos             s              1  0
PFCdAD pos2            s              2  0
     D pxflg           s              1
     D svactv          s              2
     D svapck          s              1
     D svbld           s              2
     D svbnam          s             40
     D svbnbr          s              3  0
     D svbrnd          s             10
     D svcube          s              7  3
     D svcwgt          s              1
     D svdday          s              3  0
     D svdesg          s              5
     D svflgb          s              1
     D svflgd          s              1
     D svflg1          s              1
     D svflg2          s              1
     D svhigh          s              2  0
     D svitem          s             15
     D svlot           s              1
     D svltrk          s              1
     D svmday          s              3  0
     D svmflg          s              1
     D svmhig          s              2  0
     D svmtie          s              4  0
     D svnday          s              3  0
     D svnrpk          s              3  0
     D svnslt          s              1
     D svoday          s              3  0
     D svpref          s              1
     D svrcvd          s              8  0
     D svreor          s              5  0
     D svrepl          s              5  0
     D svrg1c          s              3  1
     D svrg2c          s              3  1
     D svsdef          s              2
     D svslif          s              3  0
     D svstyp          s              1
     D svswgt          s              7  2
     D svtie           s              4  0
     D svuday          s              3  0
     D svuhgt          s              5  2
     D svulen          s              5  2
     D svum            s              1
     D svumq2          s              3  0
     D svumq3          s              3  0
     D svum1           s              2
     D svum2           s              2
     D svum3           s              2
     D svupc           s             15
     D svuwdt          s              5  2
     D svven#          s             10  0
     D svvit#          s             15
     D svvnam          s             40
     D svwhdp          s              5
     D svwhse          s              3  0
     D svwrnc          s              1
     D svxdck          s              1
     D tmpcub          s             15  6
     D today           s              8  0
     D work3a          s              3
700bAD lower           c                   'abcdefghijklmnopqrstuvwxyz'
700bAD UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
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
     *  Parameters
     *
     *    Input Parameters
     *      None
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     * Main line
     *
     * Whip through all the download Update Item records
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0
     C                   dou       eofi = *on
     *
     C                   read      impfitm4                               79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
     C                   goto      enddiu
     C                   endif
     *
700bAC                   if        iuutyp = *blanks
700bAC                             and iuwhse = 0
700bAC                             and iuitem = *blanks
700bAC                   goto      enddiu
700bAC                   endif
700bA*
700bA* Make sure item and master item are uppercase.
700bAC                   eval      iuitem = %xlate(lower:UPPER:iuitem)
700bAC                   eval      iumitm = %xlate(lower:UPPER:iumitm)
720aA*
720aA* Left justify text fields.
720aAC                   eval      iuitem = %triml(iuitem)
720aAC                   eval      iudesc = %triml(iudesc)
720aAC                   eval      iuwhdp = %triml(iuwhdp)
720aAC                   eval      iudesg = %triml(iudesg)
720aAC                   eval      iuvit# = %triml(iuvit#)
720aAC                   eval      iupdsc = %triml(iupdsc)
720aAC                   eval      iumitm = %triml(iumitm)
720aAC                   eval      iucitm = %triml(iucitm)
720aAC                   eval      iubnam = %triml(iubnam)
720aAC                   eval      iuvnam = %triml(iuvnam)
720aAC                   eval      iubrnd = %triml(iubrnd)
730aA* Make sure department is uppercase.
730aAC                   eval      iuwhdp = %xlate(lower:UPPER:iuwhdp)
PAK A*
PAK AC                   select
PAK AC                   when      client = Packers
PAK A*
PAK AC                   select
PAK AC                   when      iuwhdp = 'Z1   '
PAK AC                   eval      iuwhdp = 'FRZ  '
PAK AC                   when      iuwhdp = 'Z2   '
PAK AC                   eval      iuwhdp = 'REF  '
PAK AC                   when      iuwhdp = 'Z3   '
PAK AC                   eval      iuwhdp = 'DRY  '
PAK AC                   endsl
PAK A*
CSPdAC                   when      client = Coastalsunbelt
CSPdA*      Retrieve Category Code for item.
650bDC*    ifkey         chain     itemfld
650bMC     ifkey         chain (n) itemfld
CSPdAC                   if        not %found(itemfld)
CSPdAC                   clear                   ifcat
CSPdAC                   endif
CSPdA*
SBRaAC                   when      client = SBertram
SBRaA*      For Aspen Host coversion, map departments to Dakota
SBRaAC                   select
SBRaAC                   when      iuwhdp = 'Dry  '
SBRaAC                   eval      iuwhdp = 'DRY  '
SBRaAC                   when      iuwhdp = 'Coole'
SBRaAC                   eval      iuwhdp = 'REF  '
SBRaAC                   when      iuwhdp = 'Freez'
SBRaAC                   eval      iuwhdp = 'FRZ  '
SBRaAC*                  when      iuwhdp = *blank
SBRaAC*                  eval      iuwhdp = 'BLANK'
SBRaAC                   endsl
SBRaA*
CFIaA*      Colony Foods changes before edits.
CFIaAc                   when      client = Colony
CFIaAc**                 if        iuwhdp = *blanks
CFIaAc**                 iter
CFIaAc**                 endif
CFIaAc                   if        iustyp = ' '
CFIaAc                   eval      iustyp = 'F'
CFIaAc                   endif
CFIaAc                   if        iumflg = 'Y'
CFIaAc                   eval      iuflgd = 'Y'
CFIaAc                   endif
CFIdDc*                  if        iuwhdp = 'DRY'
CFIdDc*                            or iuwhdp = 'FRZ'
CFIdDc*                  eval      iuflgd = 'N'
CFIdDc*                  eval      iumflg = 'N'
CFIdDc*                  endif
CFIcAc                   if        iuum2 ='LB'
CFIcAc                   eval      iuflg1 = 'N'
CFIcAc                   endif
CFIaA
ACCaA*      Accardi Foods changes before edits.
ACCaAc                   when      client = Accardi
ACCaAc                   if        iuwhdp = *blanks
ACCaAc                   iter
ACCaAc                   endif
ACCaAc                   if        iustyp = ' '
ACCaAc                   eval      iustyp = 'F'
ACCaAc                   endif
ACCaAc                   if        iuwhdp = 'Dry'
ACCaAc                   eval      iuwhdp = 'DRY'
ACCaAc                   endif
ACCaAc                   if        iuwhdp = 'Refri'
ACCaAc                   eval      iuwhdp = 'REF'
ACCaAc                   endif
ACCaAc                   if        iuwhdp = 'Froze'
ACCaAc                   eval      iuwhdp = 'FRZ'
ACCaAc                   endif
ACCbAc                   if        iuumq2 > 0
ACCbAc                   eval      iuumq3 = iuumq3 / iuumq2
ACCbAc                   endif
ACCaA
HMWaAC                   when      client = HMWagner
HMWaA*
HMWaAC                   select
HMWaA*
HMWaA*      For Aspen Host coversion, map department numbers to alpha names
HMWaAC                   when      iuwhdp = '1    '
HMWaAC                   eval      iuwhdp = 'DRY  '
HMWaAC                   when      iuwhdp = '2    '
HMWaAC                   eval      iuwhdp = 'CLR  '
HMWaAC                   when      iuwhdp = '3    '
HMWaAC                   eval      iuwhdp = 'FRZ  '
HMWaAC                   endsl
HMWaA*
FGLaA*      For Foods Galore, convert department,
FGLbA*        and set 999 items to SPCL.
FGLaAC                   when      client = FoodsGalore

FGLdAC                   if        iutype = 'B'
FGLdAC                   iter
FGLdAC                   endif

FGLaAC                   select
FGLaAC*                  when      iubld  = '1B'
FGLaAC*                            or iubld  = '21'
FGLaAC*                            or iubld  = 'CO'
FGLaAC*                            or iubld  = 'DO'
FGLaAC*                            or iubld  = 'EU'
FGLaAC*                            or iubld  = 'IM'
FGLaAC*                            or iubld  = 'LO'
FGLaAC*                            or iubld  = 'MI'
FGLaAC*                  eval      iuwhdp = 'FRZ  '
FGLaAC                   when      iuwhdp = 'FRO  '
FGLaAC                   eval      iuwhdp = 'FRZ  '

FGLaAC*                  when      iubld  = 'IZ'
FGLaAC*                            or iubld  = 'CZ'
FGLaAC*                            or iubld  = 'EZ'
FGLaAC*                            or iubld  = 'GZ'
FGLaAC*                            or iubld  = 'JZ'
FGLaAC*                  eval      iuwhdp = 'REF  '

FGLaAC*                  when      iubld  = '00'
FGLaAC*                            or iubld  = '20'
FGLaAC*                            or iubld  = '28'
FGLaAC*                            or iubld  = 'BZ'
FGLaAC*                            or iubld  = 'DZ'
FGLaAC*                            or iubld  = 'FZ'
FGLaAC*                            or iubld  = 'HZ'
FGLaAC*                            or iubld  = 'JE'
FGLaAC*                            or iubld  = 'MH'
FGLaAC*                            or iubld  = 'OF'
FGLaAC*                            or iubld  = 'PO'
FGLaAC*                            or iubld  = 'SP'
FGLaAC*                            or iubld  = 'ST'
FGLaAC*                            or iubld  = 'TR'
FGLaAC*                  eval      iuwhdp = 'DRY  '

FGLaAC*                  other
FGLaAC*                  eval      iuwhdp = iubld
FGLaAC                   endsl
FGLaAC*                  eval      iubld  = *blanks
FGLbA*
FGLbAC                   if        %subst(iuitem:1:3) = '999'
FGLbAC                   eval      iudesg = 'SPCL'
FGLbAC                   endif
FGLaA*
FGLeAC                   if        iudesg = 'NSTK'
FGLeAC                   eval      iudesg = 'NSTK*'
FGLeAC                   endif
FGLeA*
FGLdAC                   if        iuumq2 > 0
FGLdAC                             and iuum2 = *blanks
FGLdAC                   eval      iuum2 = 'EA'
FGLdAC                   eval      iuflg1 = 'Y'
FGLdAC                   endif
FGLdA*
PAK AC                   endsl
PAK A*
510cA*
510cA*  Retrieve Import Item Update Misc. file.
510cAC                   if        miscitmupd = '*YES'
510cAC     itkey         chain     impfitmm
510cAC                   if        not %found(impfitmm)
510cAC                   clear                   impgrp
510eAC                   clear                   imppnt
510cAC                   clear                   impvar
510cAC                   clear                   impcat
510cAC                   clear                   impms1
510cAC                   clear                   impms2
510cAC                   clear                   impms3
510cAC                   clear                   impms4
510cAC                   clear                   impms5
510cAC                   endif
510cAC                   endif
     *
     *  First time through
     *
     C                   if        first = *on
     C                   exsr      zzinz2
     C                   eval      first = *off
     C                   endif
     *
     *  Print report heading if necessary.
     *
     C                   if        pflag = *on  or
     C                             count >= linppg
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
PFCaA*
PFCaAC                   select
PFCaAC                   when      client = prestofoods
PFCaAC                   eval      iuitem = %xlate(lower:UPPER:iuitem)
PFChAC*                  if        %subst(iuvit#:1:6) = 'REPACK'
PFChAC*                  eval      iutype = 'R'
PFChAC*                  eval      iumitm = %subst(iuvit#:8:8)
PFChAC*                  endif
PFCaAC                   endsl
     *
     *    Make sure item was entered.
     *
     C                   if        iuitem = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(26)
     C                   goto      enddiu
     C                   endif
     *
     *    Make sure warehouse was entered.
     *
     C                   if        iuwhse = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(1)
     C                   goto      enddiu
     C                   endif
     *
     * DELETE RECORD OR ERROR CHECK FOR UPDATE/ADD
     C                   if        iuutyp = 'D'
     C                   exsr      zzdeli
     C                   else
     C                   exsr      zzchki
     C                   endif
     *
     C                   if        error = *off  and
     C                             iuutyp <> 'D'
CCPaA*
CCPaAC                   if        client = CapitolCity
CSPaAC                             or client = CoastalSunBelt
SPIaAC                             or client = SternProduce
GFSaAC                             or client = GetFresh
CCPaA*
CCPaAC     itkey         setll     piritem
CCPaA*      If Repack item sent in for update, has record on file in
CCPaA*      PIRITEM and Update Code = A or C, skip all updates.
CCPaA*      Cap City is doing all maintenance on Repack items on Dakota.
CCPaAC                   if        %equal(piritem)
CCPaAC                             and iutype = 'R'
CCPaAC                             and (iuutyp = 'A'
CCPaAC                             or   iuutyp = 'C')
CCPaAC                   iter
CCPaAC                   endif
CCPaA*
CCPaAC                   endif
CCPaA*
     C                   eval      addflg = *off
     C                   eval      chgflg = *off
     C                   exsr      zzupd
     C                   endif
     *
     C                   if        error = *on
     **         CHGFLG    OREQ *ON
     **         ADDFLG    OREQ *ON
     C                   write     detail
     C                   add       1             count
     C                   endif
     *
     *
     *       Delete detail record from download file
     *
     C                   delete    iurec
510cA*
510cA*      Import Item Updates Misc file record imported.
510cAC                   if        miscitmupd = '*YES'
510cAC                             and %found(impfitmm)
510cAC                   delete    imprec
510cAC                   endif
     *
     C     enddiu        tag
     C                   enddo
     *
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
     C                   if        count >= linppg
     C                   write     head1
     C                   endif
     C                   write     grndttl
     C                   endif
600aA
600aA*  Set all invalid item license tracking levels.
600aA
600aAC                   call(e)   'LT002'
600aAC                   parm      '*INVALID'    ltCmd             8
600aAC                   parm      iuwhse        ltWhse            3 0
600aAC                   parm                    ltDummy           1
     *
     *  We are finished so get out
     *
     C                   eval      *inlr = *on
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
510bA* Get client id.
510bA*
510bAC                   call      'GETCLIENT'
510bAC                   parm                    client           10
510bAC                   parm                    clientloc        10
510bA*
510cA*
510cA* Open IMPFORDHM file.
510cAC                   if        opnimpitmm <> *on
510cAC                   open      impfitmm                             67
510cAC                   if        *in67 = *off
510cAC                   eval      opnimpitmm = *on
510cAC                   eval      miscitmupd = '*YES'
510cAC                   else
510cAC                   eval      miscitmupd = '*NO '
510cAC                   endif
510cAC                   endif
510cA*
650bD* Open ITEMFLD file.
650bDC*                  if        client = coastalsunbelt
650bD*
650bDC*                  if        not %open(itemfld)
650bDC*                  open      itemfld
650bDC*                  endif
650bD*
650bDC*                  endif
650bD*
     * Key definitions
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem

700cAC     keyitdel      klist
700cAC                   kfld                    iuwhse
700cAC                   kfld                    dltItem
     *
     *  Define key for PIRITEM file for base item.
     *
     C     itkeyb        klist
     C                   kfld                    iuwhse
     C                   kfld                    #bitem
     *
     *  Define key for PIRITEM file using Master Item.
     *
     C     itkey2        klist
     C                   kfld                    iuwhse
     C                   kfld                    iumitm
     *
     *  Define key for PIRITEM file using Contract Base item.
     *
     C     itkey4        klist
     C                   kfld                    iuwhse
     C                   kfld                    iucitm
     *
     *  Define key for PIRITEM file using Linked Item.
     *
     C     itkey3        klist
     C                   kfld                    iuwhse
     C                   kfld                    ilitem
     **                   KFLD           ILITM2
CSPdA*
CSPdA*  Define key for ITEMFLD file.
CSPdA*
CSPdAC     ifkey         klist
CSPdAC                   kfld                    iuwhse
CSPdAC                   kfld                    iuitem
     *
     *  Define key for ITEMLNK file.
     *
     C     ilkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
650hAC                   kfld                    iumitm
     *
     *  Define key for ITEMLNK1 file.
     *
     C     il1key        klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Define key for ITEMDSC file.
     *
     C     ixkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Define key for ITEMDEF file.
     *
     C     idkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     C                   kfld                    kysdef
     *
     *  Define key for ITEMDEF file for master item.
     *
     C     idkey2        klist
     C                   kfld                    iuwhse
     C                   kfld                    iumitm
     C                   kfld                    kysdef
     *
     *
     *  Define key for item misc info file.
     *
     C     imkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *
     *  Define key for options file.
     *
     C     optnky        klist
     *R                   KFLD           IUWHSE
     C                   kfld                    kywhse
     C                   kfld                    opcode
     *
     *  Define key for UPC file.
     *
     C     upkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem
     *
     *  Variables and constants.
     *
     C                   eval      forevr = *off
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKI   Item update error checking.
     *
     C     zzchki        begsr
     C                   eval      error = *off
     *
     *  Begin specific checks when adding a record.
     *
     *R         IUUTYP    IFEQ 'A'
     *
     *  For base item, master item must be blank.
     *
     C                   if        iutype = ' '  and
     C                             iumitm <> *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(41)
     C                   goto      endcki
     C                   endif
510fA*
510fA*  Invalid Item Type,
510fA*
510fAC                   if            iutype <> ' '
510fAC                             and iutype <> 'A'
510fAC                             and iutype <> 'B'
510fAC                             and iutype <> 'S'
511aAC                             and iutype <> 'R'
510fAC                   eval      error = *on
510fAC                   eval      detmsg = %trim(desc(46))
510fAC                                      + iutype
510fAC                                      + ''''
510fAC                   goto      endcki
510fAC                   endif
     *
     *  For Alias, Brkdown, Contract, and Same slot Brkdown,
511aA*  and Repack,
     *  Master item can't be blank.
     *
     C                   if        iutype = 'A'  or
     C                             iutype = 'B'  or
510fDC*                            iutype = 'C'  or
511aMC                             iutype = 'S'  or
511aAC                             iutype = 'R'
     C                   if        iumitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
HMWcA*  For H&M Wagner, if update to parent item, can't change UOM 2
HMWcAC                   if        client = hmwagner
HMWcAC                             and iuutyp = 'C'
HMWcAC                             and ittype = ' '
HMWcAC     itkey         chain(n)  piritem
HMWcAC                   if        %found(piritem)
HMWcAC     il1key        chain     itemlnk1
HMWcAC                   if        %found(itemlnk1)
HMWcAC                   if        iuum2 <> itum2
HMWcAC                             and iuum2 = *blank
HMWcAC                             or iuumq2 <> itumq2
HMWcAC                             and iuumq2 = 0
HMWcAC                   eval      error = *on
HMWcAC                   eval      detmsg = desc(47)
HMWcAC                   goto      endcki
HMWcAC                   endif
HMWcAC                   endif
HMWcAC                   endif
HMWcAC                   endif
     *
510fD*  For Contract breakdown item, Contract base item can't be
510fD*  blank.
510fD*
510fDC*                  if        iutype = 'C'
510fDC*    itkey2        chain(n)  piritem                            76
510fDC*                  if        ittype = 'B'  and
510fDC*                            iucitm = *blanks
510fDC*                  eval      error = *on
510fDC*                  eval      detmsg = desc(43)
510fDC*                  goto      endcki
510fDC*                  endif
510cA*
510cA*      Retrieve item extension file record.
510fDC*    itkey2        chain(n)  itemext1
510fDC*                  if        not %found(itemext1)
510fDC*                  clear                   ikrec
510fDC*                  endif
510cA*
510fDC*                  endif
     *
     *  For same slot brkdown, base breakdown must be defined.
     *
     C                   if        iutype = 'S'
     C     itkey2        chain(n)  piritem                            76
     C                   if        itum2 = *blanks  and
     C                             itum3 = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(42)
     C                   goto      endcki
     C                   endif
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey2        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     C                   if        itflg1 = 'Y'  or
     C                             itflg2 = 'Y'
     **         ITFLG2    ANDEQ'Y'
     C                   eval      error = *on
     C                   eval      detmsg = desc(42)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *R                   ENDIF
     *
     *
     *  Verify section type.
     *
     C                   if        opstyp = 'Y'
     C                   if        iustyp <> 'F'  and
     C                             iustyp <> 'P'
     C                   eval      error = *on
     C                   eval      detmsg = desc(2)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify warehouse department.
     *
     C                   if        opwhdp = 'Y'
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = iuwhse
     C                   eval      $lwhdp = iuwhdp
     *R                   CALL 'WD900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keywd         chain     whdept                             75
     C                   if        *in75
     C                   eval      error = *on
     C                   eval      detmsg = desc(3)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify designation area (optional).
     *
     C                   if        opdesg = 'Y'  and
     C                             iudesg <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ldesg = iudesg
     *R                   CALL 'DS900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyds         chain     desig                              75
     C                   if        *in75
     C                   eval      dscode = iudesg
     C                   eval      dsdesc = cdsc(1)
     C                   write     dsrec                                77
     C                   add       1             newdsg
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,4    DETMSG
     *R                   GOTO ENDCKI
650gAC                   else
650gAC                   unlock    desig
     C                   endif
     C                   endif
     *
     *  Verify activity zone (optional).
     *
     C                   if        opactv = 'Y'  and
     C                             iuactv <> *blanks
GLP A*
GLP AC                   if        client = Greenleaf
GLP A*      Class code sent in field. Do not update.
GLP AC                   else
GLP A*
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lactv = iuactv
     *R                   CALL 'AC900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyac         chain     activity                           75
     C                   if        *in75
     C                   eval      accode = iuactv
     C                   eval      acdesc = cdsc(1)
     C                   write     acrec                                77
     C                   add       1             newact
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,5    DETMSG
     *R                   GOTO ENDCKI
650eAC                   else
650eAC                   unlock    activity
     C                   endif
GLP A*
GLP AC                   endif
GLP A*
     C                   endif
     *
     *  Verify Date Sensitive option.
     *
     C                   if        opflgd = 'Y'
     C                   if        iuflgd <> 'Y'  and
     C                             iuflgd <> 'N'
     C                   eval      iuflgd = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,6    DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify Allow Bulk Pick option.
     *
     C                   if        opflgb = 'Y'
     C                   if        iuflgb <> 'Y'  and
     C                             iuflgb <> 'N'
     C                   eval      iuflgb = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,7    DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify vendor number is within range.
     *
     C                   if        opven# = 'Y'
     C                   if        iuven# < 0  or
     C                             iuven# > 9999999999
     C                   eval      error = *on
     C                   eval      detmsg = desc(33)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify replenishment level is within range.
     *
     C                   if        oprepl = 'Y'
     C                   if        iurepl < 0  or
     C                             iurepl > 99999
     C                   eval      error = *on
     C                   eval      detmsg = desc(34)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify master item was entered.
     *
     *R         ITTYPE    IFEQ 'B'
     *R         ITTYPE    OREQ 'A'
     *R         ITTYPE    OREQ 'C'
     *R         ITTYPE    OREQ 'S'
     C                   if        iutype = 'B'  or
     C                             iutype = 'A'  or
510fDC*                            iutype = 'C'  or
511aMC                             iutype = 'S'  or
511aAC                             iutype = 'R'
     C                   if        iumitm = *blanks
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify full case item.
     *
     C                   if        opmitm = 'Y'
     C                   if        iumitm <> *blanks
     *  Full case item number must be different from broken case item.
     C                   if        iumitm = iuitem
     C                   eval      error = *on
     C                   eval      detmsg = desc(10)
     C                   goto      endcki
     C                   endif
     *  Get full case item.
     C     itkey2        chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(8)
     C                   goto      endcki
     C                   endif
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey2        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     *
     *  Brk 1 quantity must be >0.
     C                   if        not *in79  and
     C                             itumq2 <= 0
     C                   if        iutype = 'B'  or
     C                             iutype = 'S'
     *R         ITUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *  Full case item number must be different from broken case item.
     *R         IUMITM    IFEQ IUITEM
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,10   DETMSG
     *R                   GOTO ENDCKI
     *R                   ENDIF
     C                   endif
     C                   endif
     *
     *  Brk 1 quantity must be >0 if UOM is entered.
     C                   if        opum2 = 'Y'
CPC A*
CPC A*    Import breakdown UoM 2 info
CPC AC                             or client = CPC
CPC AC                             and opum2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
     C                   if        iuum2 <> *blanks  and
     C                             iuumq2 < 0
     *R         IUUMQ2    ANDLE0
     C                   eval      error = *on
     C                   eval      detmsg = desc(9)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  UOM must be entered if Brk1 qty is entered.
     **         OPUMQ2    IFEQ 'Y'
     **         IUUMQ2    IFNE 0
     **         IUUM2     ANDEQ*BLANKS
     **                   MOVE *ON       ERROR
     **                   MOVE DESC,9    DETMSG
     **                   GOTO ENDCKI
     **                   ENDIF
     **                   ENDIF
     *
     *  Verify Contract Base item for contract broken case item.
     *
     C                   if        opcitm = 'Y'  and
     C                             iucitm <> *blanks
     C     itkey4        chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(44)
     C                   goto      endcki
     C                   endif
510cA*
510cA*      Retrieve item extension file record.
510cAC     itkey4        chain(n)  itemext1
510cAC                   if        not %found(itemext1)
510cAC                   clear                   ikrec
510cAC                   endif
510cA*
     C                   endif
     *
     *
     *  Verify Mfg date flag.
     *
     C                   if        opmflg = 'Y'
HMWbAC                   if        client = hmwagner
HMWbAC                             and iumday = 1
HMWbAC                   eval      iumflg = 'N'
HMWbAC                   endif
     C                   if        iumflg <> 'Y'  and
     C                             iumflg <> 'N'
     C                   eval      iumflg = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,11   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify date sensitive flag, if Mfg date flag = 'Y'.
     *
     C                   if        opmflg = 'Y'
     C                   if        opflgd = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iuflgd <> 'Y'
     C                   eval      error = *on
     C                   eval      detmsg = desc(12)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify mfg shelf life days, if Mfg date flag = 'Y'.
     *
     C                   if        opmday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iumday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(13)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify distributor days, if Mfg date flag = 'Y'.
     *
     C                   if        opdday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iudday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(14)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify user days, if Mfg date flag = 'Y'.
     *
     C                   if        opuday = 'Y'
     C                   if        iumflg = 'Y'  and
     C                             iuuday = 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(15)
     C                   goto      endcki
     C                   endif
     C                   endif
     C                   endif
     **************
     *
     *  Verify catch weight.
     *
     C                   if        opcwgt = 'Y'
     C                   if        iucwgt <> 'Y'  and
     C                             iucwgt <> 'N'
520 AC                             and iucwgt <> 'S'
     C                   eval      iucwgt = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,16   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify normal unit of measure.
     *
PFCcAC                   select
PFCcAC                   when      client = prestofoods
PFCcAC                   eval      iuum1 = %xlate(lower:UPPER:iuum1)
PFCcAC                   eval      iuum2 = %xlate(lower:UPPER:iuum2)
PFCcAC                   eval      iuum3 = %xlate(lower:UPPER:iuum3)
PFCcAC                   endsl
PFCcA*
     C                   if        opum1 = 'Y'  and
     C                             iuum1 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum1
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum1
610 DC*                  movel     iuum1         umshrt
610 MC                   movel (p) iuum1         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     C                   add       1             newum
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
650eAC                   else
650eAC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 unit of measure.
     *
     C                   if        opum2 = 'Y'  and
     C                             iuum2 <> *blanks
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opum2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC AC                             and iuum2 <> *blanks
CPC A*
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum2
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum2
700aDC*                  movel     iuum2         umshrt
700aMC                   movel (p) iuum2         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     C                   add       1             newum
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
650eAC                   else
650eAC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 unit of measure quantity.
     *
     C                   if        opumq2 = 'Y'
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opumq2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
     C                   if        iuumq2 < 0  or
     C                             iuumq2 > 999
     C                   eval      error = *on
     C                   eval      detmsg = desc(18)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify breakdown 1 Info Only option.
     *
     C                   if        opflg1 = 'Y'
     C                   if        iuflg1 <> 'Y'  and
     C                             iuflg1 <> 'N'
     C                   eval      iuflg1 = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,19   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 unit of measure.
     *
     C                   if        opum3 = 'Y'  and
     C                             iuum3 <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lum = iuum3
     *R                   CALL 'UM900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keyum         chain     unmesr                             75
     C                   if        *in75
     C                   eval      umcode = iuum3
700aDC*                  movel     iuum3         umshrt
700aMC                   movel (p) iuum3         umshrt
     C                   eval      umdesc = cdsc(1)
     C                   write     umrec                                77
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,17   DETMSG
     *R                   GOTO ENDCKI
650eAC                   else
650eAC                   unlock    unmesr
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 unit of measure quantity.
     *
     C                   if        opumq3 = 'Y'
     C                   if        iuumq3 < 0  or
     C                             iuumq3 > 999
     C                   eval      error = *on
     C                   eval      detmsg = desc(18)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify breakdown 2 Info Only option.
     *
     C                   if        opflg2 = 'Y'
     C                   if        iuflg2 <> 'Y'  and
     C                             iuflg2 <> 'N'
     C                   eval      iuflg2 = 'N'
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,19   DETMSG
     *R                   GOTO ENDCKI
     C                   endif
     C                   endif
     *
     *  Dimensions must be within range.
     *
     C                   if        opulen = 'Y'
     C                   if        iuulen < 0  or
     C                             iuulen > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     C                   if        opuwdt = 'Y'
     C                   if        iuuwdt < 0  or
     C                             iuuwdt > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     C                   if        opuhgt = 'Y'
     C                   if        iuuhgt < 0  or
     C                             iuuhgt > 999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(20)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *
     *  Verify shipping weight is within range.
     *
     C                   if        opswgt = 'Y'
     C                   if        iuswgt < 0  or
     C                             iuswgt > 99999.99
     C                   eval      error = *on
     C                   eval      detmsg = desc(22)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Verify build code.(Optional)
     *
     C                   if        opbld = 'Y'  and
     C                             iubld <> *blanks
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lbc = iubld
     *R                   CALL 'BC900'
     *R                   PARM           $LPARM
     *R         $LRTN     IFEQ '*ERROR  '
     C     keybc         chain     bldcode                            75
     C                   if        *in75
     C                   eval      bccode = iubld
     C                   eval      bcseq = 0
     C                   eval      bcdesc = cdsc(1)
     C                   write     bcrec                                77
     C                   add       1             newbld
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,23   DETMSG
     *R                   GOTO ENDCKI
650eAC                   else
650eAC                   unlock    bldcode
     C                   endif
     C                   endif
     *
     *  Shelf life must must be >= 0.
     *
     C                   if        opslif = 'Y'
     C                   if        iuslif < 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(24)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  Notice days must be >= 0.
     *
     C                   if        opnday = 'Y'
     C                   if        iunday < 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(25)
     C                   goto      endcki
     C                   endif
     C                   endif
     *
     *  See if item type is changing and if it is ok to do so.
     *
     C                   if        opityp = 'Y'
     C                   exsr      zzchkt
     C     error         cabeq     *on           endcki
     C                   endif
     *
     C     endcki        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHKT   Check if item type can be changed.
     *
     C     zzchkt        begsr
     C                   eval      a2nflg = *off
     *
     *  See if import item exists in PIRITEM file.
     *
     C     itkey         chain(n)  piritem                            79
     *
     *  If it doesn't, move on.
     *
     C     *in79         cabeq     *on           endckt
     *
     *  If type didn't change, move on.
     *
     C     iutype        cabeq     ittype        endckt
     *
     *  Only allowed to change from 'A' to ' '.
     *
     C                   if        ittype = 'A'  and
     C                             iutype = ' '
CSPbA*
CSPbAC                   if        client = CoastalSunbelt
CPCaAC                             or client = CPC
GLPaAC                             or client = Greenleaf
CCPcAC                             or client = CapitolCity
PFCjAC                             or client = PrestoFoods
CSPbA*      Force item type back to Alias.
CSPbAC                   eval      iutype = 'A'
CSPbA*      Load Parent item for Alias.
CSPbAC     itkey         chain (n) itemlnk
CSPbAC                   if        %found(itemlnk)
CSPbAC                   eval      iumitm = ilitm2
CSPbAC                   endif
CSPbAC                   else
     C                   eval      a2nflg = *on
     C                   goto      endckt
CSPbAC                   endif
CSPbA*
     C                   endif
PFChA*
PFChA*  For Presto, allow changes to Repack.
PFChAC                   if        client = PrestoFoods
PFChAC                             and iutype = 'R'
PFChAC                   goto      endckt
PFChAC                   endif
     *
     *  For now, everthing else is an error.
     *
     C                   eval      error = *on
     C                   movea     desc(45)      a30
     C                   eval      a30(22) = ittype
     C                   eval      a30(29) = iutype
     C                   movea     a30           detmsg
     *
     C     endckt        endsr
     *----------------------------------------------------------------
     *
     *  ZZDELI   Item delete.
     *
     C     zzdeli        begsr
     C                   eval      error = *off
     *
     C     itkey         chain(n)  piritem                            79
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(36)
     C                   goto      enddel
     C                   endif
     *
     *   Cannot delete, link record exists.
     *
     *R                   SELEC
     *R         IUTYPE    WHEQ ' '
     *R         IUTYPE    OREQ 'B'
     *
     C     il1key        setll     itemlnk1                           79
     C                   if        not *in79
     C     il1key        reade     itemlnk1                               79
     C                   if        not *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(38)
     C                   goto      enddel
     C                   endif
     C                   endif
     *R                   ENDSL
     C     ittype        cabeq     'A'           skip1
     *
     *   Get corresponding base item.
     *
     C                   exsr      zzgetb
     *
     *R                   SELEC
     *R         IUTYPE    WHEQ ' '
     *R         IUTYPE    OREQ 'B'
     *R         IUTYPE    OREQ 'C'
     *
     *   Get item quantity record.
     *      for Base item.
     *
     *R         ITKEY     CHAINITEMQTY              7978
     C     itkeyb        chain     itemqty                            7978
     C                   select
     C                   when      *in78
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     *
     C                   when      not *in79
     *
     *      Cannot delete if a quantity exists for item.
     *
     *      Only check break quantities for breakdown item
     C                   if        ittype = 'S'
     *
     C                   if        iqstk2 <> 0  or
     C                             iqstk3 <> 0  or
     C                             iqalc2 <> 0  or
     C                             iqalc3 <> 0  or
     C                             iqhld2 <> 0  or
     C                             iqhld3 <> 0  or
     C                             iqtri2 <> 0  or
     C                             iqtri3 <> 0  or
     C                             iqtro2 <> 0  or
     C                             iqtro3 <> 0  or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     C                   endif
     C                   else
     *
     *      check all quantities for other item types.
     C                   if        iqstk1 <> 0  or
     C                             iqstk2 <> 0  or
     C                             iqstk3 <> 0  or
     C                             iqalc1 <> 0  or
     C                             iqalc2 <> 0  or
     C                             iqalc3 <> 0  or
     C                             iqhld1 <> 0  or
     C                             iqhld2 <> 0  or
     C                             iqhld3 <> 0  or
     C                             iqtri1 <> 0  or
     C                             iqtri2 <> 0  or
     C                             iqtri3 <> 0  or
     C                             iqtro1 <> 0  or
     C                             iqtro2 <> 0  or
     C                             iqtro3 <> 0  or
     C                             iqord1 <> 0
     C                   eval      error = *on
     C                   eval      detmsg = desc(39)
     C                   goto      enddel
     C                   endif
     C                   endif
     *
     *      Delete item quantity record.
     *
     *       Don't do delete for 'A' and 'S' items
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   delete    iqrec                                77
     C                   endif
     *
     C                   endsl
     *R                   ENDSL
     *
     *   Delete ITEMDEF records.
     *
     C     itkey         setll     itemdef
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     itemdef                              7879
     *
     *     If record is locked then send message back and abort.
     *
     C                   if        *in78
     C                   eval      error = *on
     C                   eval      detmsg = desc(40)
     C                   goto      enddel
     C                   endif
     *
     *     Otherwise, delete record.
     *
     C                   if        not *in79
     C                   delete    idrec                                77
     C                   endif
     *
     C                   enddo
     *
     *     Delete ITEMDSC extended description rec.
     *
     C     ixkey         chain     itemdsc                            79
     C                   if        not *in79
     C                   delete    ixrec
     C                   endif
     *
     *     Delete ITEMMSC misc  record
     *
     C     itkey         chain     itemmsc                            79
     C                   if        not *in79
     C                   delete    imrec
     C                   endif
     *
     C     skip1         tag
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'B'  or
510fDC*                            ittype = 'C'  or
511aMC                             ittype = 'S'  or
511aAC                             ittype = 'R'
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     C                   endif
510dA
510dA*  Delete ITEMSLS records.
510dA
510dAC                   if        not %open(itemsls)
510dAC                   open      itemsls
510dAC                   endif
700cA
700cAC                   for       i = 1 to 2
700cA
700cAC                   if        i = 1
700cAC                   eval      dltItem = iuitem
700cAC                   else
700cAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700cAC                   endif
510dA
700cDC**   itkey         setll     itemsls
700cMC     keyitdel      setll     itemsls
510dA
510dAC                   dow       forevr = forevr
700cDC**   itkey         reade (e) itemsls
700cMC     keyitdel      reade (e) itemsls
510dAC                   if        %eof(itemsls)
510dAC                   leave
510dAC                   endif
510dA*     If record is locked then send skip record.
510dAC                   if        %status = 01218
510dAC                   iter
510dAC                   endif
510dA*     Otherwise, delete record.
510dAC                   delete(e) ihrec
510dAC                   if        %error
510dAC                   iter
510dAC                   endif
510dA
510dAC                   enddo
700cA
700cAC                   endfor
510dA
510dA*  Delete ITEMAVG record
510dA*
510dAC                   if        not %open(itemavg)
510dAC                   open      itemavg
510dAC                   endif
700cA
700cAC                   for       i = 1 to 2
700cA
700cAC                   if        i = 1
700cAC                   eval      dltItem = iuitem
700cAC                   else
700cAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700cAC                   endif
510dA
700cDC**   itkey         chain (e) itemavg
700cMC     keyitdel      chain (e) itemavg
510dA*     If record is locked then send skip record.
510dA
510dAC                   if        %status = 01218
510dAC                   else
510dAC                   if        %found(itemavg)
510dAC                   delete(e) igrec
510dAC                   if        %error
510dAC                   endif
510dAC                   endif
510dAC                   endif
700cA
700cAC                   endfor
     *
     C     upkey         setll     upc1
     C                   dow       forevr = forevr
     C     upkey         reade     upc1                                   79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   delete    uprec
     C                   enddo
     *
     *   Update SLOT3 records. Change slot status to Zero.
     *
     C     itkey         setll     slot3
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     slot3                                7879
     *
     *     If record is locked then skip slot.
     *
     C                   if        *in78
     C                   iter
     C                   endif
     *
     *     Otherwise, Change status to Zero.
     *
     C                   if        not *in79  and
     C                             slstat <> 'Z '
     C                   eval      slstat = 'Z '
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   update    slrec                                77
     C                   endif
     *
     C                   enddo
510cA*
510cA*      Delete Item Extension Misc. record.
510cAC     itkey         chain     itemext1
510cAC                   if        %found(itemext1)
510cAC                   delete    ikrec
510cAC                   endif
     *
     C     itkey         chain     piritem                            79
     C                   if        not *in79
     C                   delete    itrec
     C                   endif
     *
     C     enddel        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill Item fields.
     *
     C     zzfil1        begsr
     *
PFCbAC*
PFCbA    // Set special order item status for Presto.
PFCbA /free
PFCeA    select;
PFCbA      when client = PrestoFoods;
PFCeA        select;
PFCbA          when iudesg = 'SPEC';
PFCbA              iudesg = 'SPCL';
PFCgD    //    when %subst(iudesc:1:3) = '***'
PFCgD    //      and %subst(iudesc:4:1) <> '*';
PFCgD    //        iudesg = 'SPCL';
PFCdA          when %subst(iudesc:1:2) = '**'
PFCeA            and %subst(iudesc:3:1) <> '*';
PFCbA              iudesg = 'DISC';
PFCbA          when %subst(iudesc:1:1) = '*'
PFCeA            and %subst(iudesc:2:1) <> '*';
PFCbA              iudesg = 'SPCL';
PFCdA              pos2 = %scan('BOX':iudesc);
PFCdA              if pos2 > 0;
PFCdA                iudesg = *blank;
PFCdA              endif;
PFCdA        endsl;
PFCbA    endsl;
PFCbA /end-free
PFCbAC*
     *
     C                   if        opwhdp = 'Y'  and
     C                             iuwhdp <> itwhdp
     C                   eval      detmsg = desc(29)
     C                   eval      chgflg = *on
     C                   endif
FGLcAC                   select
FGLcAC                   when      client = FoodsGalore
FGLcAC*** skip, always comes as F and do not change if P in Dakota
FGLcAC                   other
     C                   if        opstyp = 'Y'  and
     C                             iustyp <> itstyp
     C                   eval      detmsg = desc(30)
     C                   eval      chgflg = *on
     C                   endif
FGLcAC                   endsl
     C                   if        opdesg = 'Y'  and
     C                             iudesg <> itdesg
     C                   eval      detmsg = desc(31)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opulen = 'Y'  and
     C                             iuulen <> itulen
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opuwdt = 'Y'  and
     C                             iuuwdt <> ituwdt
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opuhgt = 'Y'  and
     C                             iuuhgt <> ituhgt
     C                   eval      detmsg = desc(32)
     C                   eval      chgflg = *on
     C                   endif
     *
     *  Move fields from download file to PIRITEM fields
     *
     C                   if        opityp = 'Y'
     C                   eval      ittype = iutype
     C                   endif
     C                   if        opdesc = 'Y'
     C                   movel     iudesc        itdesc
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = itdesc
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      itdesc = chkstr
     C                   endif
     C                   if        opstyp = 'Y'
FGLcAC                   select
FGLcAC                   when      client = FoodsGalore
FGLcAC                   if        itstyp <> 'P'
FGLcAC                   eval      itstyp = iustyp
FGLcAC                   endif
FGLcAC                   other
     C                   eval      itstyp = iustyp
FGLcAC                   endsl
PFCiAC                   else
PFCiA*
PFCiAC                   if        client = Prestofoods
PFCiA*      Default Section Type to value from Host for new items.
PFCiAC                   if        itstyp = ' '
PFCiAC                   eval      itstyp = iustyp
PFCiAC                   endif
PFCiAC                   endif
PFCiA*
     C                   endif
     C                   if        opwhdp = 'Y'
DRYaA*
DRYaA*      Update department for Dairyland on new items only.
DRYaAC                             or  client = Dairyland
DRYcMC                             and (opwhdp = 'N'
DRYaAC                             and *in79 = '1'
DRYcA*
DRYcAC                             or opwhdp = 'N'
DRYcAC                             and *in79 = '0'
DRYcAC                             and itwhdp = ' ')
DRYaA*
SBRb C                   if        client = sbertram
SBRb C                             and iuwhdp = 'BLANK'
SBRb C                             and itwhdp <> 'BLANK'
SBRb C                   else
     C                   eval      itwhdp = iuwhdp
SBRb C                   endif
     C                   endif
     C                   if        opdesg = 'Y'
     C                   eval      itdesg = iudesg
     C                   endif
     C                   if        opactv = 'Y'
GLP A*
GLP AC                   if        client = Greenleaf
GLP A*      Class code sent in field. Do not update.
GLP AC                   else
GLP A*
     C                   eval      itactv = iuactv
GLP AC                   endif
GLP A*
     C                   endif
     C                   if        opflgd = 'Y'
     C                   eval      itflgd = iuflgd
650dAC                   else
650dAC                   if        itflgd = ' '
650dAC                   eval      itflgd = 'N'
650dAC                   endif
     C                   endif
     C                   if        opflgb = 'Y'
     C                   eval      itflgb = iuflgb
     C                   endif
     C                   eval      itupc = *blanks
     C                   if        opven# = 'Y'
     C                   eval      itven# = iuven#
     C                   endif
     C                   if        opvit# = 'Y'
PFCfAC*
PFCfA    // Decide on vendor item number for Presto.
PFCfA /free
PFCfA    select;
PFCfA      when client = PrestoFoods
PFCfA       and itvit# <> *blanks;
PFCfA        // do nothing, don't update itvit#
PFCfA      other;
PFCfA /end-free
     C                   eval      itvit# = iuvit#
PFCfAC                   endsl
     C                   endif
     C                   if        oprepl = 'Y'
HMWcA*
HMWcAC                   select
HMWcAC                   when      client = HMWagner
HMWcA*
HMWcAC                   if        iurepl = 0
HMWcAC                   eval      itrepl = 2
HMWcAC                   else
HMWcAC                   eval      itrepl = iurepl
HMWcAC                   endif
HMWcA*
HMWcAC                   other
     C                   eval      itrepl = iurepl
HMWcAC                   endsl
     C                   endif
     C                   if        oppdsc = 'Y'
     C                   eval      itpdsc = iupdsc
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = itpdsc
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      itpdsc = chkstr
     C                   endif
     C                   if        opum1 = 'Y'
     C                   eval      itum1 = iuum1
     C                   endif

511aAC*     Clear UM2/3 fields for Repack items because they are not used.
511aA
511cDC**                 if        iutype <> 'R'
511cMC                   if        iutype = 'R'
GLPcMC                             and client <> Greenleaf
511aAC                   eval      iuum2  = ' '
511aAC                   eval      iuumq2 = 0
511aAC                   eval      iuum3  = ' '
511aAC                   eval      iuumq3 = 0
511aAC                   endif
511aA
     C                   if        opum2 = 'Y'
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opum2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdA*      Skip update
GLPdAC                   else
CSPdA*
     C                   eval      itum2 = iuum2
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     *
     C                   if        opumq2 = 'Y'
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opumq2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdA*      Skip update.
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdAC                   else
CSPdA*
HMWdA*     For Wagner, clear bogus UOM from host.
HMWdAC                   if        client = hmwagner
HMWdAC                             and iuum2 = *blank
HMWdAC                             and iuumq2 <> 0
HMWdAC                             and iuflg1 <> 'Y'
HMWdAC                   eval      iuumq2 = 0
HMWdAC                   endif
HMWdA*
     C                   eval      itumq2 = iuumq2
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   if        opflg1 = 'Y'
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opflg1 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
     C                   if        iuum2 = ' '
     C                   eval      itflg1 = 'N'
     C                   else
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdA*      Skip update.
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdAC                   else
CSPdA*
     C                   eval      itflg1 = iuflg1
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   endif
     *
     C                   if        opum3 = 'Y'
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdA*      Skip update.
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdAC                   else
CSPdA*
     C                   eval      itum3 = iuum3
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   if        opumq3 = 'Y'
CSPcAC*
CSPcAC                   if        client = CoastalSunbelt
CSPcAC*
CSPcAC*      Convert Brkdown 2 into number of units in Brkdown 1
CSPcAC*      instead of number of units in full case.
CSPcAC                   if            iuumq2 > 0
CSPcAC                             and iuumq3 > 0
CSPcAC                             and iuflg1 = 'Y'
CSPcAC                             and iuflg2 = 'Y'
CSPdAC                             and ifcat  <> 'ODR'
CSPcAC                   eval (h)  iuumq3 = iuumq3 / iuumq2
CSPcAC                   endif
CSPcAC*
CSPcAC                   endif
CSPcAC*
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdA*      Skip update.
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdAC                   else
CSPdA*
     C                   eval      itumq3 = iuumq3
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   if        opflg2 = 'Y'
     C                   if        iuum3 = ' '
     C                   eval      itflg2 = 'N'
     C                   else
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
CSPdA*      Skip update.
CSPdAC                   else
GLPdA*      Skip update.
GLPdAC                   if        client = Greenleaf
GLPdAC                             and iutype = 'R'
GLPdAC                   else
CSPdA*
     C                   eval      itflg2 = iuflg2
GLPdAC                   endif
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   endif
     *
SBRb C                   select
SBRb * for S.Bertram, don't update dimensions if department is blank
SBRb C                   when      client = sbertram
SBRb C                             and iuwhdp = 'BLANK'
SBRb C                   eval      iucube = 0
SBRb C                   other
     *
     C                   if        opulen = 'Y'
     C                   eval      itulen = iuulen
     C                   endif
     C                   if        opuwdt = 'Y'
     C                   eval      ituwdt = iuuwdt
     C                   endif
     C                   if        opuhgt = 'Y'
     C                   eval      ituhgt = iuuhgt
     C                   endif
     *
SBRb C                   endsl
     *
     C                   if        opcube = 'Y' and
640eAC                             iucube <> 0
     C                   eval      itcube = iucube
     C                   else
     C                   if        opulen = 'Y'  and
     C                             opuwdt = 'Y'  and
     C                             opuhgt = 'Y'
     *  Calculate actual cube according to dimensions entered.
     *
     C                   if        opcdiv = 0
     C                   eval      actcub = 0
     C                   else
     C                   eval      tmpcub = itulen * ituwdt
     C                   mult      ituhgt        tmpcub
     C     tmpcub        div(h)    opcdiv        actcub
     C                   endif
AFS A*
AFS AC                   if        client = Andrews
AFS A*
AFS A*      Force default cube so that an item always has cube.
AFS AC                   if        actcub = 0
AFS AC                   eval      actcub = 0.100
AFS AC                   endif
AFS A*
AFS AC                   endif
     *
     *   Use calculated cube if ...
     *      Auto calculate option is 'Y'
     *      and Cube is zero
     *      and Cube is not imported from host.
640bA*      or Cube not imported from host and computed cube chg'd.
     *
     C                   if        opcaut = 'Y'  and
640bDC*                            itcube = 0
640bMC                             (itcube = 0
640bAC                             or itcube <> actcub)
     C                   eval      itcube = actcub
     C                   endif
     C                   endif
     C                   endif
     *
     C                   if        opswgt = 'Y'
     C                   eval      itswgt = iuswgt
     C                   endif
     C                   if        opcwgt = 'Y'
     C                   eval      itcwgt = iucwgt
     C                   endif
650jA*
650jAC                   if        opcwgt = 'N'
650jAC                   if        itcwgt = ' '
650jAC                   eval      itcwgt = 'N'
650jAC                   endif
650jAC                   endif
650jA*
     C                   if        opbld = 'Y'
     C                   eval      itbld = iubld
     C                   endif
     C                   if        opslif = 'Y'
     C                   eval      itslif = iuslif
CCPbA*
CCPbAC                   if        client = capitolCity
CCPbAC                   if        iuslif > 0
CCPbAC                   eval (h)  itnday = iuslif / 2
CCPbAC                   else
CCPbAC                   eval      itnday = 0
CCPbAC                   endif
CCPbAC                   endif
CCPbA*
     C                   endif
     C                   if        opnday = 'Y'
     C                   eval      itnday = iunday
     C                   endif
     *
GFSbAC                   if        client = Getfresh
GFSbA*      Transfer item minimum order qty into last rcv'd date fld.
GFSbA*      Last received date not used by BFC at this time.
GFSbAC                   eval      itrcvd = iublnk
GFSbAC                   endif
GFSbA*
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill Item fields.
     *
     C     zzfil2        begsr
     *
     C                   if        opityp = 'Y'
     C                   eval      ittype = iutype
     C                   endif
     *   Fill PIRITEM using saved base item fields.
     C                   eval      itwhdp = svwhdp
     C                   eval      itstyp = svstyp
     C                   eval      itdesg = svdesg
     C                   eval      itactv = svactv
     C                   eval      itupc = svupc
     C                   eval      itbld = svbld
     C                   eval      itven# = svven#
     C                   eval      itvit# = svvit#
     C                   eval      itum1 = svum1
     C                   eval      itum2 = svum2
     C                   eval      itumq2 = svumq2
     C                   eval      itflg1 = svflg1
     C                   eval      itum3 = svum3
     C                   eval      itumq3 = svumq3
     C                   eval      itflg2 = svflg2
     C                   eval      itulen = svulen
     C                   eval      ituwdt = svuwdt
     C                   eval      ituhgt = svuhgt
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
     C                   eval      itcwgt = svcwgt
     C                   eval      itreor = svreor
     C                   eval      itrepl = svrepl
     C                   eval      itrcvd = svrcvd
     C                   eval      itflgd = svflgd
     C                   eval      itflgb = svflgb
     C                   eval      itslif = svslif
     C                   eval      itnday = svnday
     *
     *R                   MOVE IUDESC    ITDESC
     C                   movel     iudesc        itdesc
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = itdesc
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      itdesc = chkstr
     C                   eval      itpdsc = iupdsc
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETB   Get base item to use for checking ITEMQTY.
     *
     C     zzgetb        begsr
     *
     *  Initialize base item info with current item.
     *
     C                   eval      #bitem = ititem
     *
     *  If Alias or SSB Item
     *   Then get Base item.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
     *
     C                   call      'GETBASE'
     C                   parm      itwhse        $gwhse            3 0
     C                   parm      ititem        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bityp            1
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum             2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn             8
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *  Define key for ACTIV file.
     *
     C     keyac         klist
     C                   kfld                    iuactv
     *
     *  Define key for BUILD file.
     *
     C     keybc         klist
     C                   kfld                    iubld
     *
     *  Define key for DESIG file.
     *
     C     keyds         klist
     C                   kfld                    iudesg
     *
     *  Define key for UNMSR file.
     *
     C     keyum         klist
     C                   kfld                    $lum
     *
     *  Define key for WHDEPT file.
     *
     C     keywd         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuwhdp
     *
     * Get import date/time.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      impdte = $cvd8o
     C                   time                    imptim
     *
     * Get report heading.
     *
     C                   eval      w1head = *blanks
     *                    MOVEL'II235PR' RPPRTF
     C                   movel     'II265PR'     rpprtf
     C     rpprtf        chain     reports                            79
     C                   if        not *in79
     C                   movel     rpdesc        $pstr
     C                   else
     C                   eval      $pstr = *blanks
     C                   endif
     C                   eval      $plen = 50
     *
     C                   call      'CENTER'
     C                   parm                    $pstr            60
     C                   parm                    $plen             3 0
     C                   movel     $pstr         w1head
     *
     *   Get warehouse description.
     *
     C     iuwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     *
     *   Create warehouse heading.
     *
     C                   move      iuwhse        work3a
     C     ' 0'          check     work3a        pos
     C                   eval      len = 4 - pos
     C     len           subst     work3a:pos    whhead
     C     whhead        cat       '-':1         whhead
     C     whhead        cat       whdesc:1      whhead
     C                   call      'CENTER'
     C                   parm      whhead        $cstr            60
     C                   parm      40            $clen             3 0
     C                   movel     $cstr         whhead
     *
     * Initialize grand total fields
     *
     C                   eval      grdord = 0
     C                   eval      grdlin = 0
     *                    Z-ADD0         PREOH
     *                    Z-ADD0         PREOD
     C                   eval      noitem = 0
     C                   eval      badbrk = 0
     C                   eval      newdsg = 0
     C                   eval      newact = 0
     C                   eval      newbld = 0
     C                   eval      newum = 0
     *
     *   Get item maintenance options.
     *
     C                   exsr      zzxopt
     *
     *   Get import item fields options.
     *
     C                   eval      kywhse = 0
     C                   eval      opcode = '*IMPITEM'
     C     optnky        chain     options                            79
     C                   if        not *in79
     C                   eval      opdat2 = opdata
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZSVIT   Save PIRITEM fields.
     *
     C     zzsvit        begsr
     *
     *   Save base item fields.
     C                   eval      svwhse = itwhse
     C                   eval      svitem = ititem
     C                   eval      svstyp = itstyp
     C                   eval      svwhdp = itwhdp
     C                   eval      svdesg = itdesg
     C                   eval      svactv = itactv
     C                   eval      svupc = itupc
     C                   eval      svbld = itbld
     C                   eval      svven# = itven#
     C                   eval      svvit# = itvit#
     C                   eval      svum1 = itum1
     C                   eval      svum2 = itum2
     C                   eval      svumq2 = itumq2
     C                   eval      svflg1 = itflg1
     C                   eval      svum3 = itum3
     C                   eval      svumq3 = itumq3
     C                   eval      svflg2 = itflg2
     C                   eval      svulen = itulen
     C                   eval      svuwdt = ituwdt
     C                   eval      svuhgt = ituhgt
     C                   eval      svcube = itcube
     C                   eval      svswgt = itswgt
     C                   eval      svcwgt = itcwgt
     C                   eval      svreor = itreor
     C                   eval      svrepl = itrepl
     C                   eval      svrcvd = itrcvd
     C                   eval      svflgd = itflgd
     C                   eval      svflgb = itflgb
     C                   eval      svslif = itslif
     C                   eval      svnday = itnday
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update for item type.
     *
     C     zzupd         begsr
     *
     C                   select
     *
     *  Base or Broken item type
     C                   when      iutype = ' '  or
511aMC                             iutype = 'B'  or
511aAC                             iutype = 'R'
     *  Get PIRITEM record
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   clear                   itrec
     C                   eval      itwhse = iuwhse
     C                   eval      ititem = iuitem
     C                   endif
     *
     C                   exsr      zzfil1
     C                   exsr      zzupd1
     *
     *  Alias and Contract item type
     C                   when      iutype = 'A'  or
510fDC*                            iutype = 'C'  or
     C                             iutype = 'S'
     *
     *          IUUTYP    IFEQ 'A'
     *  For Add, Get PIRITEM record for Base item
     *
     *
     *  If 'S' type record and Normal UOM is not blank
     *    Then get base item record for later update.
     *    Otherwise get base item record as non-update.
     *
     C                   if        iutype = 'S'  and
     C                             iuum1 <> ' '
     C     itkey2        chain     piritem                            79
     C                   else
     C     itkey2        chain(n)  piritem                            79
     C                   endif
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      detmsg = desc(37)
     C                   goto      endupd
     C                   else
     *
     *     If 'S' type record and Normal UOM is not blank
     *        force 'S' item UM1 into base UM2
     *        force 'S' item UM2 into base UM3
     *        force 'S' item UM2 QTY into base UM3 QTY
     *        update base item record.
     *
     C                   if        iutype = 'S'  and
     C                             iuum1 <> ' '
     C                   eval      itum2 = iuum1
     C                   eval      itum3 = iuum2
     C                   eval      itumq3 = iuumq2
     C                   update    itrec
     C                   endif
     C                   exsr      zzsvit
     C                   endif
     *  For Add, Get ITEMMSC record for Base item
     C     itkey2        chain(n)  itemmsc                            79
     *   Save base record for ITEMMSC file
     C                   if        *in79
     C                   eval      svmtie = 0
     C                   eval      svmhig = 0
     C                   eval      svmflg = *zeros
     C                   eval      svdday = 0
     C                   eval      svuday = 0
     C                   eval      svmday = 0
DRY AC                   if           client = Dairyland
DRY A
DRY AC                   if        iublnk = 1
DRY AC                   eval      svwrnc = 'Y'
DRY AC                   else
DRY AC                   eval      svwrnc = 'N'
DRY AC                   endif
DRY A
DRY AC                   else
DRY A
     C                   eval      svwrnc = *zeros
DRY AC                   endif
DRY A
     C                   eval      svrg1c = 0
     C                   eval      svrg2c = 0
     C                   eval      svapck = *zeros
     C                   eval      svnrpk = 0
     C                   eval      svnslt = 'N'
     C                   eval      svxdck = 'N'
     C                   eval      svbnbr = 0
     C                   eval      svbnam = *zeros
     C                   eval      svvnam = *zeros
     C                   eval      svbrnd = *zeros
     C                   eval      svlot = 'N'
     *                    MOVE 'N'       SVLTRK
     C                   eval      svltrk = 'L'
     C                   else
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
     C                   eval      svwrnc = imwrnc
     C                   eval      svrg1c = imrg1c
     C                   eval      svrg2c = imrg2c
     C                   eval      svapck = imapck
     C                   eval      svnrpk = imnrpk
     C                   eval      svnslt = imnslt
     C                   eval      svxdck = imxdck
     C                   eval      svbnbr = imbnbr
     C                   eval      svbnam = imbnam
     C                   eval      svvnam = imvnam
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = imbrnd
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      imbrnd = chkstr
     C                   eval      svbrnd = imbrnd
     C                   eval      svlot = imlot
     C                   eval      svltrk = imltrk
     **                   ENDIF
     C                   endif
     *
     C     itkey         chain     piritem                            79
     *          IUUTYP    IFEQ 'A'
     *          *IN79     ANDEQ*OFF
     *R                   MOVE *ON       ERROR
     *R                   MOVE DESC,27   DETMSG
     *R                   GOTO ENDUPD
     *                    ENDIF
     C                   if        *in79
     C                   clear                   itrec
     C                   eval      itwhse = iuwhse
     C                   eval      ititem = iuitem
     C                   endif
     *
     C                   exsr      zzfil2
     C                   exsr      zzupd2
     *
     C                   endsl
510cA*
510cA*      Extended Item Misc. update.
510cAC                   if        miscitmupd = '*YES'
650iAC                             and impwhs <> 0
650iAC                             and impitm <> *blank
510cAC     itkey         chain     itemext1
510cAC                   eval      ikgrp = impgrp
510eAC                   eval      ikplnt= imppnt
510cAC                   eval      ikvar = impvar
510cAC                   eval      ikcat = impcat
510cAC                   eval      ikmsc1= impms1
510cAC                   eval      ikmsc2= impms2
510cAC                   eval      ikmsc3= impms3
510cAC                   eval      ikmsc4= impms4
510cAC                   eval      ikmsc5= impms5
510cA*
510cAC                   if        not %found(itemext1)
510cAC                   eval      ikwhse= impwhs
510cAC                   eval      ikitem= impitm
510cAC                   write     ikrec
510cAC                   else
510cAC                   update    ikrec
510cAC                   endif
510cA*
510cAC                   endif
510cA*
     *
     C     endupd        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update files for item type ' ' or 'B'
     *
     C     zzupd1        begsr
     *
     *   Add record
     *
     C                   if        *in79
     C                   write     itrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(27)
510 MC                   goto      endupi
510 DC*                  goto      endup1
     C                   endif
     *
     C                   eval      addflg = *on
     C                   eval      detmsg = desc(28)
     *
     *       Add record to item quantity file.
     *
     C                   clear                   iqrec
     C                   eval      iqwhse = iuwhse
     C                   eval      iqitem = iuitem
     C                   write     iqrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(35)
510 MC                   goto      endupi
510 DC*                  goto      endup1
     C                   endif
     *
     C                   else
     C                   update    itrec
     C                   endif
     *
     *   Add record to item quantity file when type changes.
     *     If error occurs, assume record already exists.
     *
     C                   if        a2nflg = *on
     C                   clear                   iqrec
     C                   eval      iqwhse = iuwhse
     C                   eval      iqitem = iuitem
     C                   write     iqrec                                77
     C                   endif
     *
     *
     *   Add record to ITEMDSC file.
     *
     C                   if        opdesc = 'Y'  and
     C                             pxflg = '1'
     C     ixkey         chain     itemdsc                            76
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = iudesc
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      iudesc = chkstr
     C                   movel     iudesc        ixdsc1
     C                   move      iudesc        ixdsc2
     C                   if        not *in76
     C                   update    ixrec
     C                   else
     C                   eval      ixwhse = itwhse
     C                   eval      ixitem = ititem
     C                   write     ixrec
     C                   endif
     C                   endif
     *
     *   Add/Change record to ITEMMSC file.
     *
     C     imkey         chain     itemmsc                            79
     C                   if        optie = 'Y'
     C                   eval      imtie = iutie
     C                   endif
     C                   if        ophigh = 'Y'
     C                   eval      imhigh = iuhigh
     C                   endif
     C                   if        opmflg = 'Y'
     C                   eval      immflg = iumflg
650dAC                   else
650dAC                   if        immflg = ' '
650dAC                   eval      immflg = 'N'
650dAC                   endif
     C                   endif
     C                   if        opdday = 'Y'
     C                   eval      imdday = iudday
     C                   endif
     C                   if        opuday = 'Y'
     C                   eval      imuday = iuuday
     C                   endif
     C                   if        opmday = 'Y'
     C                   eval      immday = iumday
     C                   endif
DRY A
DRY AC                   if           client = Dairyland
DRY A
DRY AC                   if        iublnk = 1
DRY AC                   eval      imwrnc = 'Y'
DRY AC                   else
DRY AC                   eval      imwrnc = 'N'
DRY AC                   endif
DRY A
DRY AC                   endif
DRY A
     C                   if        opnslt = 'Y'
     C                   eval      imnslt = iunslt
     C                   endif
     C                   if        opxdck = 'Y'
     C                   eval      imxdck = iuxdck
     C                   endif
     C                   if        opbnbr = 'Y'
     C                   eval      imbnbr = iubnbr
     C                   endif
     C                   if        opbnam = 'Y'
GLPbA*
GLPbAC                   if        client = Greenleaf
GLPbA*
GLPbA*      Retrieve buyer number from PIR User table.
GLPbAC                   eval      #buyerid = %subst(iubnam:1:7)
GLPbAC                   call      'GETUSER'
GLPbAC                   parm                    #buyerid         10
GLPbAC                   parm      0             #whse             3 0
GLPbAC                   parm      0             #emp#             5 0
GLPbAC                   parm                    #fnam            15
GLPbAC                   parm                    #init             1
GLPbAC                   parm                    #lnam            20
GLPbAC                   parm                    #whdp             5
GLPbAC                   parm                    #styp             1
GLPbAC                   parm                    #shft             6
GLPbAC                   parm                    #crew             6
GLPbAC                   parm      0             #nhrs             3 1
GLPbAC                   parm                    #rtn              8
GLPbA*      Update buyer number for item.
GLPbAC                   if        #rtn = '*OK'
GLPbAC                   eval      imbnbr = #emp#
GLPbAC                   else
GLPbAC                   eval      imbnbr = 0
GLPbAC                   endif
GLPbA*
GLPbAC                   endif
GLPbA*
     C                   eval      imbnam = iubnam
     C                   endif
     C                   if        opvnam = 'Y'
     C                   eval      imvnam = iuvnam
     C                   endif
     C                   if        opbrnd = 'Y'
650kAC                   eval      chkstr = *blanks
650kAC                   eval      chkstr = iubrnd
650kAC                   exsr      zzzspcl2spc
650kAC                   eval      iubrnd = chkstr
     C                   eval      imbrnd = iubrnd
     C                   endif
     C                   if        oplot = 'Y'
     C                   eval      imlot = iulot
     C                   endif
640 A*
640 AC                   select
PFCiAC                   when          client = PrestoFoods
PFCiAC                             and itstyp = 'P'
PFCiA*
640 AC                   when      iustyp = 'P'
640 AC                   eval      imnrpk = *zeros
640 A*
640 AC                   when      iustyp = 'F' and
640 AC                             imnrpk = 0
640 AC                   eval      imnrpk = 1
640 AC                   endsl
640 A*
FGLeAC                   if        client = FoodsGalore
FGLeAC                   eval      imnrpk = 1
FGLeAC                   endif
FGLeA
600aDC**                 if        opltrk = 'Y'
600aDC**                 eval      imltrk = iultrk
600aDC**                 endif
530aDC*                  eval      imoday = iuoday
530aAC*
530aAC                   select
530aA*    Install update from Host for Date Sensitive items.
530aAC                   when          iuoday > 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
530aAC                   eval      imoday = iuoday
530aA*
530aA*    Force Days Out to 360 for Date Sensitive items.
530aAC                   when          imoday = 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
CCP A*
CCP AC                   if        client = capitolcity
CSP AC                             or client = CoastalSunBelt
SPI AC                             or client = SternProduce
CCP AC                   eval      imoday = 30
CCP AC                   else
530aAC                   eval      imoday = 360
CCP AC                   endif
CCP A*
530aAC                   endsl
530aAC*
     **                   MOVE 'Y'       IMWRNC
CSPeA*
CSPeAC                   if        client = CoastalSunbelt
CSPeA*      Only update item c/wgt variances on add.
CSPeAC                   else
CSPeA*
DRYdAC                   if        client = Dairyland
DRYdAC                   if            imrg1c <> iurg1c
DRYdAC                             and iurg1c > 0
DRYdAC                   eval      imrg1c = iurg1c
DRYdAC                   endif
DRYdA*
DRYdAC                   if            imrg2c <> iurg2c
DRYdAC                             and iurg2c > 0
DRYeMC                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA*
DRYdAC                   else
     C                   eval      imrg1c = iurg1c
     C                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA
CSPeAC                   endif
CSPeA*
     **                   MOVE 'N'       IMAPCK
     **                   Z-ADD0         IMNRPK
01   C                   if        not *in79
     C                   update    imrec
     C                   else
DRY A
DRY AC                   if           client = Dairyland
DRY A
DRY AC                   if        iublnk = 1
DRY AC                   eval      imwrnc = 'Y'
DRY AC                   else
DRY AC                   eval      imwrnc = 'N'
DRY AC                   endif
DRY A
DRY AC                   else
DRY A
     C                   eval      imwrnc = 'Y'
DRY AC                   endif
DRY A
DRYdAC                   if        client = Dairyland
DRYdAC                   if            imrg1c <> iurg1c
DRYdAC                             and iurg1c > 0
DRYdAC                   eval      imrg1c = iurg1c
DRYdAC                   endif
DRYdA*
DRYdAC                   if            imrg2c <> iurg2c
DRYdAC                             and iurg2c > 0
DRYeMC                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA*
DRYdAC                   else
     C                   eval      imrg1c = iurg1c
     C                   eval      imrg2c = iurg2c
DRYdAC                   endif
DRYdA
     C                   eval      imapck = 'N'
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
02   C                   if        iustyp = 'F'
     C                   eval      imnrpk = 1
     C                   else
     C                   eval      imnrpk = *zeros
02   C                   endif
530bAC                   if        iunslt = ' '
     C                   eval      imnslt = 'N'
530bAC                   endif
530bAC                   if        iuxdck = ' '
     C                   eval      imxdck = 'N'
530bAC                   endif
530bAC                   if        iubnbr = 0
     C                   eval      imbnbr = 0
530bAC                   endif
530bAC                   if        iubnam = ' '
     C                   eval      imbnam = *blanks
530bAC                   endif
530bAC                   if        iuvnam = ' '
     C                   eval      imvnam = *blanks
530bAC                   endif
530bAC                   if        iubrnd = ' '
     C                   eval      imbrnd = *blanks
530aAC                   endif
530 AC                   if        iulot = ' '
530 AC                             or oplot = 'N'
     C                   eval      imlot = 'N'
530 AC                   endif
     *                    MOVE 'N'       IMLTRK
600aDC*                  eval      imltrk = 'L'
530aDC*                  eval      imoday = iuoday
530aAC*
530aAC                   select
530aA*    Install update from Host for Date Sensitive items.
530aAC                   when          iuoday > 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
530aAC                   eval      imoday = iuoday
530aA*
530aA*    Force Days Out to 360 for Date Sensitive items.
530aAC                   when      imoday = 0
530aAC                             and itflgd = 'Y'
530aAC                             and immflg = 'N'
CCP A*
CCP AC                   if        client = capitolcity
CSP AC                             or client = CoastalSunBelt
SPI AC                             or client = SternProduce
CCP AC                   eval      imoday = 30
CCP AC                   else
530aAC                   eval      imoday = 360
CCP AC                   endif
CCP A*
530aAC                   endsl
530aAC*
     C                   write     imrec
     C                   endif
     *   Save base record for ITEMMSC file
     C                   eval      svmtie = imtie
     C                   eval      svmhig = imhigh
     C                   eval      svmflg = immflg
     C                   eval      svdday = imdday
     C                   eval      svuday = imuday
     C                   eval      svmday = immday
     C                   eval      svwrnc = imwrnc
     C                   eval      svrg1c = imrg1c
     C                   eval      svrg2c = imrg2c
     C                   eval      svapck = imapck
     C                   eval      svnrpk = imnrpk
     C                   eval      svnslt = imnslt
     C                   eval      svxdck = imxdck
     C                   eval      svbnbr = imbnbr
     C                   eval      svbnam = imbnam
     C                   eval      svvnam = imvnam
     C                   eval      svbrnd = imbrnd
     C                   eval      svlot = imlot
     C                   eval      svltrk = imltrk
     C                   eval      svoday = imoday
650bA*
650bA*
650bA*   Add record to ITEMFLD file.
650bAC     ifkey         chain     itemfld
650bAC                   if        not %found(itemfld)
650bAC                   eval      ifwhse    = iuwhse
650bAC                   eval      ifitem    = iuitem
GLP A*
GLP AC                   if        client = Greenleaf
GLP AC                   if        iuactv > ' '
GLP AC                   eval      ifcat = iuactv
GLP AC                   endif
GLP AC                   else
GLP A*
650bAC                   eval      ifcat     = ' '
GLP AC                   endif
GLP A*
650bAC                   eval      ifcaseovf = 'N'
650bAC                   eval      ifodrslot = ' '
650bAC                   eval      ifucicde  = '1'
650bAC                   eval      ifrcvmth  = '1'
650bAC                   eval      ifsltmth  = '1'
650bAC                   eval      ifbrdflg  = 'N'
650bAC                   write     ifrec
650bA*
650bAC                   else
650bA*
GLP AC                   if        client = Greenleaf
GLP AC                   if        iuactv > ' '
GLP AC                   eval      ifcat = iuactv
GLP AC                   endif
GLP AC                   update    ifrec
GLP AC                   else
650bAC                   unlock    itemfld
GLP AC                   endif
GLP A*
650bAC                   endif
     *
     *
     *   Add record to ITEMLNK file.
     *     for Brokencase item.
511aA*         and Repack item.
     *
     C                   select
     C                   when      iutype = 'B'
650hMC                             or iutype = 'R'
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm <> *blanks
     C     ilkey         chain     itemlnk                            79
     C                   eval      ilitm2 = iumitm
     C                   if        *in79
     C                   eval      ilwhse = iuwhse
     C                   eval      ilitem = iuitem
     C                   write     ilrec
     C                   else
     C                   update    ilrec
     C                   endif
     C                   endif
     *
     *   Delete record from ITEMLNK file.
     *     for Normal item.
     *
     C                   other
     *
     *R         OPMITM    IFEQ 'Y'
     *R         IUMITM    ANDEQ*BLANKS
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     *R                   ENDIF
     *
     C                   endsl
511aA*
511aA*   Create KITCOMP record for Repack item.
511aA*
511aAC                   if        iutype = 'R'
511aAC     itkey         chain     kitcomp                            79
CCPaA*
CCPaAC                   if        client = CapitolCity
CSPaAC                             or client = CoastalSunBelt
SPIaAC                             or client = SternProduce
PFChAC                             or client = PrestoFoods
CCPaA*      Only update Parent Repack Qty on Add.
CCPaAC                   if        *in79 = '1'
650fAc                   eval      kcdisp = ' '
CCPaAC                   eval      kcqty1 = iupqn1
CCPaAC                   eval      kcqty2 = iupqn2
CCPaAC                   eval      kcqty3 = iupqn3
CCPaAC                   endif
CCPaAC                   else
CCPaA*
511aAC                   eval      kcqty1 = iupqn1
511aAC                   eval      kcqty2 = iupqn2
511aAC                   eval      kcqty3 = iupqn3
CCPaAC                   endif
CCPaA*
511aAC                   if        *in79
511aAC                   eval      kcwhse = iuwhse
511aAC                   eval      kcitem = iuitem
511aAC                   eval      kccitm = iumitm
650fAc                   eval      kcdisp = ' '
511aAC                   write     kcrec
511aAC                   else
650cc*  if parent item changes then delete old record and add new
650cAc                   if        kccitm <> iumitm
650cAc                   delete    kcrec
650cAC                   eval      kcwhse = iuwhse
650cAC                   eval      kcitem = iuitem
650cAC                   eval      kccitm = iumitm
650cAC                   eval      kcqty1 = iupqn1
650cAC                   eval      kcqty2 = iupqn2
650cAC                   eval      kcqty3 = iupqn3
650cAC                   write     kcrec
650cAc                   else
650cc*  else simply update quantities from what was sent
511aAC                   update    kcrec
650cAc                   endif
511aAC                   endif
650fA
650fAc*   add code to maintain KITITEM file with Repack item master
650fAc*    only adds KITITEM thru this interface for the time, no upds
650fAC     itkey         chain     kititem                            79
650fA*
650fAC                   if        client = CapitolCity
650fAC                             or client = CoastalSunBelt
650fAC                             or client = SternProduce
650fA*      Only update Parent Repack Qty on Add.
650fAC                   if        *in79 = '1'
650fAc                   eval      kidisp = ' '
650fAc                   eval      kirptp = '1'
650fAC                   eval      kiqty1 = 1
650fAC                   eval      kiqty2 = 0
650fAC                   eval      kiqty3 = 0
650fAC                   endif
650fAC                   else
650fA*
650fAC                   if        *in79 = '1'
650fAc                   eval      kirptp = '1'
650fAC                   eval      kiqty1 = 1
650fAC                   eval      kiqty2 = 0
650fAC                   eval      kiqty3 = 0
650fAC                   endif
650fAC                   endif
650fA*
650fAC                   if        *in79
650fAC                   eval      kiwhse = iuwhse
650fAC                   eval      kiitem = iuitem
650fAc                   eval      kidisp = ' '
650fAC                   write     kirec
650fAC                   else
650fDC                   unlock    kititem
650fAC                   endif
511aAC                   endif
511aA*
511aA*   Create Repack slot for Repack item.
511aA*
511aAC                   if        iutype = 'R'
GLPeAC                             and client <> Greenleaf
511aAC                   call      'CRTWRKORD'
511aAC                   parm      '*CRTRPKSLT'  $rcmd            10
511aAC                   parm      iuwhse        $rwhse            3 0
511aAC                   parm      iuitem        $ritem           15
511aAC                   parm      0             $rqty             5 0
511aAC                   parm      ' '           $rby              1
511aAC                   parm      ' '           $rref            15
511aAC                   parm      ' '           $rrtn            10
511aAC                   parm      ' '           $rmsg            60
511aAC                   endif
     *
     *   Update any dependent file if update type = Change
     *
     C                   select
     C                   when      iuutyp = 'C'
     *   Save base item fields.
     C                   exsr      zzsvit
     C                   eval      eofl = *off
650hDC*    ilkey         setll     itemlnk1
650hAC     il1key        setll     itemlnk1
     C                   dou       eofl = *on
     *
650hDC*    ilkey         reade     itemlnk1                               75
650hAC     il1key        reade     itemlnk1                               75
     C                   if        *in75
     C                   eval      eofl = *on
510 MC                   iter
510 DC*                  goto      endup1
     C                   else
     *
     C     itkey3        chain     piritem                            79
     C                   if        *in79
510 MC                   iter
510 DC*                  goto      endup1
     C                   endif
     C                   if        ittype = 'A'  or
510fDC*                            ittype = 'C'  or
     C                             ittype = 'S'
     *   Create PIRITEM using saved base item fields.
     C                   eval      itwhdp = svwhdp
     C                   eval      itstyp = svstyp
     C                   eval      itdesg = svdesg
     C                   eval      itactv = svactv
     C                   eval      itupc = svupc
     C                   eval      itbld = svbld
     C                   eval      itven# = svven#
     C                   eval      itvit# = svvit#
     C                   eval      itum1 = svum1
     C                   eval      itum2 = svum2
     C                   eval      itumq2 = svumq2
     C                   eval      itflg1 = svflg1
     C                   eval      itum3 = svum3
     C                   eval      itumq3 = svumq3
     C                   eval      itflg2 = svflg2
     C                   eval      itulen = svulen
     C                   eval      ituwdt = svuwdt
     C                   eval      ituhgt = svuhgt
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
     C                   eval      itcwgt = svcwgt
     C                   eval      itreor = svreor
     C                   eval      itrepl = svrepl
     C                   eval      itrcvd = svrcvd
     C                   eval      itflgd = svflgd
     C                   eval      itflgb = svflgb
     C                   eval      itslif = svslif
     C                   eval      itnday = svnday
     C                   update    itrec
     *
     C     itkey3        chain     itemmsc                            79
     C                   if        *in79
510 MC                   iter
510 DC*                  goto      endup1
     C                   endif
     *   Create ITEMMSC using saved base item fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
     C                   eval      imwrnc = svwrnc
     C                   eval      imrg1c = svrg1c
     C                   eval      imrg2c = svrg2c
     C                   eval      imapck = svapck
     C                   eval      imnrpk = svnrpk
     C                   eval      imnslt = svnslt
     C                   eval      imxdck = svxdck
     C                   eval      imbnbr = svbnbr
     C                   eval      imbnam = svbnam
     C                   eval      imvnam = svvnam
     C                   eval      imbrnd = svbrnd
     C                   eval      imlot = svlot
600aDC**                 eval      imltrk = svltrk
     C                   eval      imoday = svoday
     C                   endif
     *
     C                   endif
     C     endup1        tag
     C                   enddo
     C                   endsl
510 MC     endupi        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update files for item type 'A' or 'C'
     *
     C     zzupd2        begsr
     *
     *   Add record
     *
     C                   if        *in79
     C                   write     itrec                                77
     C                   if        *in77
     C                   eval      error = *on
     C                   eval      detmsg = desc(27)
     C                   goto      endup2
     C                   endif
     *
     C                   eval      addflg = *on
     C                   eval      detmsg = desc(28)
     *
     C                   else
     C                   update    itrec
     C                   endif
     *
     *
     *   Add record to ITEMDSC file.
     *
     C                   if        opdesc = 'Y'  and
     C                             pxflg = '1'
     C     ixkey         chain     itemdsc                            76
     C                   movel     iudesc        ixdsc1
     C                   move      iudesc        ixdsc2
     C                   if        not *in76
     C                   update    ixrec
     C                   else
     C                   eval      ixwhse = itwhse
     C                   eval      ixitem = ititem
     C                   write     ixrec
     C                   endif
     C                   endif
     *
     *   Add/Change record to ITEMMSC file.
     *
     C     itkey         chain     itemmsc                            79
     *R         *IN79     IFEQ *ON
     C                   eval      imwhse = iuwhse
     C                   eval      imitem = iuitem
     *   create using saved base fields.
     C                   eval      imtie = svmtie
     C                   eval      imhigh = svmhig
     C                   eval      immflg = svmflg
     C                   eval      imdday = svdday
     C                   eval      imuday = svuday
     C                   eval      immday = svmday
     C                   eval      imwrnc = svwrnc
     C                   eval      imrg1c = svrg1c
     C                   eval      imrg2c = svrg2c
     C                   eval      imapck = svapck
     C                   eval      imnrpk = svnrpk
     C                   eval      imnslt = svnslt
     C                   eval      imxdck = svxdck
     C                   eval      imbnbr = svbnbr
     C                   eval      imbnam = svbnam
     C                   eval      imvnam = svvnam
     C                   eval      imbrnd = svbrnd
     C                   eval      imlot = svlot
600aDC**                 eval      imltrk = svltrk
     *
     C                   if        *in79
     C                   eval      imnrpk = *zeros
     C                   write     imrec
     C                   else
     C                   update    imrec
     C                   endif
     **
     *   Add record to ITEMDEF file using base fields.
     *
     *     First, delete an existing ITEMDEF records.
     *
     C     itkey         setll     itemdef
     C                   eval      *in79 = *off
     C                   dou       *in79
     C     itkey         reade     itemdef                                79
     C                   if        not *in79
     C                   delete    idrec                                77
     C                   endif
     C                   enddo
     *
     *     Then add the ITEMDEF records.
     *
     C                   eval      eofd = *off
     C     itkey2        setll     itemdef
     C                   dou       eofd = *on
     *
     C     itkey2        reade(n)  itemdef                                75
     C                   if        *in75
     C                   eval      eofd = *on
     C                   goto      enddu2
     C                   endif
     *   Save ITEMDEF base item fields.
     *R                   Z-ADDIDWHSE    SVWHSE  30
     *R                   MOVE IDITEM    SVITEM 15
     C                   eval      svsdef = idsdef
     C                   move      idtie         svtie
     C                   move      idhigh        svhigh
     C                   eval      svum = idum
     C                   eval      svpref = idpref
     C                   eval      kysdef = svsdef
     C     idkey         chain     itemdef                            75
     C                   eval      idwhse = iuwhse
     C                   eval      iditem = iuitem
     C                   eval      idsdef = svsdef
     C                   move      svtie         idtie
     C                   move      svhigh        idhigh
     C                   eval      idum = svum
     C                   eval      idpref = svpref
     C                   if        *in75
     C                   write     idrec
     C                   else
     C                   update    idrec
     C                   endif
     *
     C     idkey2        setgt     itemdef
     C     enddu2        tag
     C                   enddo
     *
     *   Add record to ITEMLNK file.
     *
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm <> *blanks
     C     ilkey         chain     itemlnk                            79
     C                   eval      ilitm2 = iumitm
     C                   if        *in79
     C                   eval      ilwhse = iuwhse
     C                   eval      ilitem = iuitem
     C                   write     ilrec
     C                   else
     C                   update    ilrec
     C                   endif
     C                   endif
     *
     *   Delete record from ITEMLNK file.
     *
     C                   if        opmitm = 'Y'  and
     C                             iumitm = *blanks
     C     ilkey         chain     itemlnk                            79
     C                   if        not *in79
     C                   delete    ilrec
     C                   endif
     C                   endif
     *
     *       Add record to item quantity file for Contract item.
     *
510fDC*                  if        iutype = 'C'
     **         IUUTYP    ANDEQ'A'
510fDC*    itkey         chain     itemqty                            79
510fDC*                  if        *in79
510fDC*                  clear                   iqrec
510fDC*                  eval      iqwhse = iuwhse
510fDC*                  eval      iqitem = iuitem
510fDC*                  write     iqrec                                77
510fDC*                  if        *in77
510fDC*                  eval      error = *on
510fDC*                  eval      detmsg = desc(35)
510fDC*                  goto      endup2
510fDC*                  endif
510fDC*                  endif
510fDC*                  endif
     *
     C     endup2        tag
     *
     C                   endsr
     *
     *
     *----------------------------------------------------------------
     *
     *  ZZXOPT   Get use extended description option
     *
     C     zzxopt        begsr
     *
     *   Get extended description option.
     C                   eval      kywhse = iuwhse
     C                   eval      pxflg = *off
     C                   eval      opcode = '*ITEMMNT'
     *
     C     optnky        chain     options                            79
     C                   if        not *in79
     C                   eval      opdat1 = opdata
     C                   if        opxdsc = 'Y'
     *R                   MOVE '1'       UXFLAG  1
     C                   eval      pxflg = *on
     C                   endif
     C                   endif
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZRHEAD   Print report headings.
     *
     C     zrhead        begsr
     *
     C                   if        count >= linppg
     C                   seton                                        81
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   setoff                                       81
     C                   endif
     *
     C                   endsr
650kA*----------------------------------------------------------------
650kA*  zzzspcl2spc  Remove unallowed characters.
650kA*----------------------------------------------------------------
650kA
650kAC     zzzspcl2spc   begsr
650kA
650kAC                   eval      chkpos = 0
650kA
650kAC                   dou       chkpos = 0 or chkpos + 1 > 80
650kAC                   eval      chkpos = %check(okchar:chkstr:chkpos+1)
650kAC                   if        chkpos > 0
650kAC                   eval      %subst(chkstr:chkpos:1) = ' '
650kAC                   endif
650kAC                   enddo
650kA
650kAC                   eval      chkstr = %triml(chkstr)
650kA
650kAC                   endsr

     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
*INVALID WAREHOUSE
*INVALID SECTION
*INVALID DEPARTMENT
*INVALID DESIGNATION
*INVALID ACTIVITY
*INVALID DATE SENSITIVE
*INVALID BULK PICK OPT.
*INVALID MASTER ITEM
*INVALID BREAKDOWN QTY
*INVALID ITEM & MASTER
*MANUFACTURER DATE FLAG
*INVALID DATE SENSITIVE
*INVALID MFG SHELF DAYS
*INVALID DIST. DAYS
*INVALID USER DAYS
*INVALID CATCH WEIGHT
*INVALID UNIT MEASURE
*INVALID UOM QUANTITY
*INVALID ALLOW BRK SALE
*INVALID DIMENSIONS
*INVALID CUBE
*INVALID SHIP WEIGHT
*INVALID BUILD CODE
*INVALID SHELF LIFE
*INVALID NOTICE DAYS
*INVALID ITEM
*ERROR ADDING RECORD
*ADDED RECORD
*DEPT CHANGED
*SECTION CHANGED
*DESIGNATION CHANGED
*DIMENSIONS CHANGED
*INVALID VENDOR #
*INVALID REPLENISHMENT LEVEL
*ERROR ADDING ITEMQTY RECORD
*DELETE RECORD NOT FOUND
*MISSING MASTER ITEM
*ERROR DELETING-ITEMLNK EXISTS
*ERROR DELETING-ITEMQTY EXISTS
*ERROR DELETING ITEMDEF RECORD
*MASTER ITEM MUST BE BLANK
*BREAKDOWN NOT DEFINED
*CONTRACT BASE ITEM MISSING
*INVALID CONTRACT BASE ITEM
*CANT CHG TYPE FROM 'X' TO 'Y'
*INVALID ITEM TYPE '
*CANT CHG BRKDWN UOM ON PARENT
**
*Auto created by item update*
