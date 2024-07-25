500gA /COPY *libl/qcopysrc,hspecs
     H DFTACTGRP(*NO) ACTGRP(*NEW)
     *----------------------------------------------------------------
     *  Binding Directories
     *----------------------------------------------------------------
     Hbnddir('BFCBND')

      *----------------------------------------------------------------
      *   Copyright (C) 2013 BFC Software, Inc. - All Rights Reserved
      *   BFC Software, Inc.
      *   (630) 562-0375
      *----------------------------------------------------------------
      *
      *  DRIPROD     Dakota realtime interface - Production
      *  Kenneth Elder
      *
     *    Kenneth Elder
     *      - Created
650aA*    03/26/15  KDE  6.50a
     *      - Add code to Allow Breakdown Replenishment
700 A*    04/10/15  KDE  7.00
     *      - Add code to support Box Breaker App
700aA*    11/05/15  KDE  7.00a
     *      - Add code to consider scrap for rm replens
700bA*    12/02/15  KDE  7.00b
     *      - Add breakdown rollup to prevent error when
     *        generating adjusts for rm with brk down 1 and 2
700cA*    12/13/15  KDE  7.00c
     *      - Fix normal breakdown rollup
700dA*    12/16/15  KDE  7.00d
     *      - Fix Delete WO where not flagging PWRKORDR records
700eA*    12/23/15  KDE  7.00e
     *      - Fix Update to PWRKORDRU to rollup breakdowns
     *        correctly when both Prod Qty and Normal BrkDwn
     *        used
700fA*    01/11/16  KDE  7.00f
     *      - Fix issue for breakdown replenishments
700g *    01/20/16  DLS  7.00g
     *      - Correct issue causing PWRKORDRU to remain open.
     *      - Root Cause: Fields inQty & currqty lack the precision needed to
     *      -             accurately calculate actual production quantity when
     *      -             raw material, Production Breakdown Quantity Needed
     *      -             in BOM defined with decimal.  ex. 12.5
700h *    01/17/16  KDE  7.00h
     *      - Fix issue where bill of material item with different
     *        department is not passing different dept to DRISLOT
700i *    02/06/16  KDE  7.00i
     *      - Verify that LIN slot exists for adjustment prior to
     *        actual adjustment
700j *    02/18/16  KDE  7.00j
700j *              DLS  In attendance with some input
     *      - Fix Breakdown/Rollup issue when no Breakdown exits
700k *    02/29/16  DLS  7.00k
     *      - Fixed bug introduced in 7.00c that compromised data integrity
     *        of WOSUM fields: squmq2 & squmq3.
700l *    03/04/16  DLS  7.00l
     *      - Changed $ppwhdp (represents dept of finished good)
     *        to $slwhdp (represents dept of raw material being replenished).
700m *    03/04/16  DLS  7.00m
     *      - Fixed bug introduced with 7.00f by commenting out the entire mod
     *        and adding 2 lines of conditional logic for breakdown replenishments.
700n *    03/04/16  DLS  7.00n
     *      - Double negative boolean field: noBrkDwn created by KDE 7.00j
     *        (made obsolescent by mod 7.00k) has been replaced using
     *        squmq2 & squmq3 for consistency & readibility.
700o *    08/21/16  KDE  7.00o
     *      - Retrun when error in creating Work Order Replens        .00j
700p *    11/18/16  KDE  7.00p
     *      - Only call PRDQTYCONV when both Raw MAterial and
     *        Bill of MAterial line use PRoduction UOM
700q *    11/28/16  KDE  7.00q
     *      - Changed to return Replen message when fails
710  *    12/26/16  KDE  7.10
     *      - Changed to perform additional code to incorporate Primal
     *        and SubPRimal definitions for meat processing
     *        Also reworked how replens are done using this new code
     *        in R130001
710a *    01/25/17  KDE  7.10a
     *      - Added command rmqtyext.  This command will set value
     *        WORMAVL in PWRKORD to Y if raw materials exist and
     *        N if any raw materials are short.  It returns the Y or N
     *        value in $ppRmAvl if single item sent using $ppITem.
710b *    01/25/17  TAB  7.10b
     *      - Added logic to check when releasing work order
    *        with item that should have original BOM, the
    *        original BOM exsist in PBOM file.
710c *    01/30/17  KDE  7.10c
     *      - Added logic to confirm BOM line is active on Work Order.
    *        If not we will look for active substitute in PBOMSUB
    *        Data will be moved into PBOM fields from PBOMSUB
    *        PRocedure chkForSub will be created to do these checks.
    *        Also added process to ensure records on current Work
    *        Order, not on current BOM will be added or deleted when
    *        doing Production Creation and Deletion when a Dynamic
    *        BOM is used.
    *      - Added code to add By-Products to Alternate item
    *        item selection when using raw materials for alternate
    *        Finished goods other than the primary item planned, and
    *        add logic where it will use the scanned weight instead
    *        of the BOM weight if only one line is BMTYPE "C" which
    *        stands for Waste product recorded.  If multiple lines
    *        are config to record waste we do not know quantities
    *        used other than through BOM.  This calls function
    *        scanWgt in WRTRMUSAGE routine.
    *      - Modified code to allow ALL entries on BOM to be processed.
    *        System use to only process items tagged as AUTO Replenishment.
    *        While it will still only generate replenishments automatically
    *        for raw materials on BOM tagged as auto replenishment it will
    *        now still add manual replenishments to pWrkOrdr and process
    *        as Auto entries.  An option was added to say whether a BOM
    *        entry was PRoduction Specific.  If unchecked (No) the
    *        system will only record usage per the BOM.  Also if more than
    *        one Production Specific raw material used it will record
     *        usage per BOM since has no way of knowing how much weight of
    *        recorded FG from scale goes to multiple raw materials
710d *    02/06/17  KDE  7.10d
     *      - Make sure all edits that can be performed in edit routine
    *        are there for each of the commands before the update routines
    *        are called
    *      - Create command whereisBOM to return value regarding which
    *        file has the BOM for given Work Order
    *      - Trim all DISP values to account for new way of padding with
    *        blanks for Production Aisles to match Dakota
    *      - Recompile for field addition PLRMUCI in Prodlog
    *      - add Entered date to Slot Adjust command for license creation
    *      - add Command *EXPIREDT to calculate expiration date.
    *        also pass expiration date for production quantities
    *      - Make sure we compare for like mfg line when looking up existing
    *        Work ORder in CHKFORWO.  If Mfg line different it should return *NF
710e *    02/17/17  LMC  7.10e
     *      - Added new command *IMPQTY, we are able to use much of   e
    *        existing *ADJQTY logic for the canopy import with the   tines
     *        new *IMPQTY, we can skip a few things that normal
    *        production currently does.
710f *    02/17/17  KDE  7.10f
     *      - Added code to override blank Action based on type slot
     *      - Add ead to Work Order Detail when Create Work Order
     *      - Do not call Expire Date routine when creating LINE slots
     *      - Add code to assign and create MultiDay line(s) as needed
     *      - Add code to delete MultiDay Production Date when WO deleted
     *      - Return Expiration date for Line Slot lookup
710g *    02/22/17  LMC  7.10g
     *      - When expiration date is sent on *IMPQTY send it on
    *        to drislot.
710h *    03/28/17  KDE  7.10h
     *      - Fix Fetch SQL statement
710i *    03/31/17  LMC  7.10i - reserved
710j *    04/19/17  KDE  7.10j
     *      - Add Suggestion commands in UPDRMWORK routine to correct
     *        issue where BOM was not being generated for Suggestion
710k *    04/24/17  KDE  7.10k
     *      - Add command *SPRDCOST - This command purpose is to spread
     *        cost for given Production date when called at EOD
710l *    04/24/17  KDE  7.10l
     *      - Fix issues with Alternate item.  Should always return
     *        at least Finished Good being analyzed
710m *    05/01/17  KDE  7.10m
     *      - Fix Change expiration date routine to add Mfg Shelf Life
     *        days to system date and subtract user and dist days.
     *      - Enh: Added client custom code support to program.
710n *    05/05/17  KDE  7.10n
     *      - Fix Change calls to R130002 to include all parms
     *        Needs parm for Mfg Line to ensure replenishments
     *        are correct for specific line versus another line.
     *        Replenishment process was changed to call R130002
     *        after Primal/SubPrimal code was added to prevent
     *        having to replicate code in that process as well
710o *    05/08/17  KDE  7.10o
     *      - Fix Change chkForSub to use function passed key fields
     *        instead of file fields
710p *    05/10/17  KDE  7.10p
     *      - Fix When applying daily usage at end of day, if an item
     *        is defined as having a PRoduction UOM quantity (IPPRDQ)
     *        the code is assuming the BOM used Production Quantities
     *        and when normal breakdowns were used it did not move the
     *        correct quantities into actual fields for PWRKORDRU.
     *        ** The code is in WRTRMUSAGE and after a comment that
     *        refers to PIU which is the End of Day Usage process **
710q *    05/24/17  KDE  7.10q
     *      - Fix Issue where cost routine CRTRMWORK was not applying
     *        correct cost to Waste based on percentage for Work Order
     *      - Also fix Alteritem issue of dup primary item
710r *    07/14/17  KDE  7.10r
     *      - Fix Use current date for Box Breaker Trans if no date setup
710s *    07/18/17  KDE  7.10s
     *      - Enh:  Do not generate inventory adjustment for Box Breaker
     *        transaction when no breakdown uom defined
710t *    07/20/17  KDE  7.10t
     *      - Enh: Add commands *STRLAB and *CLSLAB along with routines
     *        to generate labor as either Standard or Actual Labor
     *        for Production processes
     *      - Enh: Create routine zzStdTrans to generate Standard Labor
     *        transactions for Cost Spread
     *      - Change routine that writes Labor cost to use PIRTRAND files
     *        instead of pLabCstLne
     *      - Add logic to apply Actual Labor Cost after applying Standard
     *        Labor Cost in routine wrtLabCost
710u *    11/29/17  MR   7.10u
     *      - Enh: Add commands *MINMAX along with routines
720  *    01/19/18  KDE  7.20
     *      - Enh: Add command *AUTOWP along with routines
     *        These routines setup work orders for required
     *        WIP items for specific finished good requests
     *        Also changed to record PWRKORDRU (Usage) records
     *        for WIP types only adding to LIN Slots
     *      - Was removed in 7.30a
720a *    02/06/18  KDE  7.20a
     *      - Fix: Check Work ORder record if line passed as zero
     *        and Work Order Passed
720b *    07/11/18  KDE  7.20b
     *      - Fix: When Primal defined not generating Replenishment
720c *    10/16/18  KDE  7.20c
     *      - Fix: Prevent WIP Work Order from being generated when
     *        Line Stock is available for order
720d *    10/26/18  KDE  7.20d
     *      - Fix: Disable automatic creation of WIP Work Orders
     *      - Fix: Prevent Replenishment when raw material short
720e *    03/29/17  LMC  7.20e
     *      - change to send expiration date to drislot if it was
    *        sent in to driprod.
720f *    01/10/19  KDE  7.20f
     *      - Fix:  Af few misc. items fixed in testing some stuff for
     *        Get Fresh and Chefs
730a *    01/17/19  KDE  7.30a
     *      - Make changes to allow Work Order quantity to change after
     *        release
     *      - Create new Procedure that is called for any add, update or
     *        deletes for Work Orders.  This will loop through calls
     *        for the items per pBomLvl and then pass correct quantity
     *        and items to chkforwo (Check for Work Order), and either
     *        updprodwo(Update Work Order) or crtprodwo (Create Work Order).
     *        It will also re-analyze replenishments for those items
     *        afterwards
     *      - Add command *CALCNEED which calculates the need for a variable
     *        quantity passed in for specific Fg and Rm/Component.  This is
     *        used when determining up and down adjustment for components
     *        for multiple level bom.
     *      - Revised to call command *UPDLOOP to loop for any subsuquent
     *        Component items that need updates or additions based on what
     *        is being maintained
     *      - Removed AutoWP command and changes.  Never used and put in
     *        new code to handle components.
     *      - Total Autowp command since not used and cleanup
730bA*     01/30/19  KDE  7.30b
     *       - Enh: Recompile due to PWRKORD change
730cA*     02/04/19  LMC  7.30c
     *       - Enh: For Canopy production - before we do *get from
     *         drislot. Save the $satolcns to savelcns, in case the
     *         return of the $satolcns = *multiple.
730dA*     02/25/19  KDE  7.30d
     *       - Enh: Add pmake2 and pmake3 to track breakdown make quantities
     *         Mainly setup for components.  Also populate new uom fields from
     *         item master as added and use new component normal case quantity
     *         required per Work Order Demand
     *       - Enh: Also added woovr1 and woovr2 for breakdowns for make quantities
     *       - Enh: Add ounces to calcUsageQty and factors like used in updRmUsage
730eA*     03/14/19  KDE  7.30e
     *       - Enh: Remove factor subtraction in UPDRMWORK
     *       - Convert Production Quantity to normal quantity in UPDRMWORK
     *       - Delete should always adjust per what is required at that time
730fA*     06/25/19  LMC  7.30F
     *       - Enh: Added some additinal logic for canopy box breaker.
     *         send *BB instead of *PR for the license.
730gA*     08/20/19  KDE  7.30G
     *       - Enh: Added logic to use additional locations when all the
     *         virtuals for 101 are consumed for a specific aisle and level.
740 A*     08/26/19  KDE  7.40
     *       - Enh: Changed Production Replenishment type to 'O' so the
     *         new Drop Pick process for Chefs could use 'D'
740aA*     08/12/20  KDE  7.40
     *       - Fix: Issue with Expiration date being calculated
     *       - Fix: Send expiration from slot for delete transactions
     *       - Fix: Factor not calculated correctly for raw materials
750aA*     01/11/22  KDE  7.50a
     *       - Fix: Problem where rm flagged as back flush was not back flushing
750bA*     02/09/22  KDE  7.50b
     *       - Fix: Include By-Products for components
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRYaA*    05/01/17  KDE  DRYa
     *      - Revised Expiration Calculation routine to send zero
     *        expiration date when Mfg Shelf Life Days is either
     *        zero or Mfg Shelf Life Days is less than combination
     *        of User and Distribution days
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys Foods
     *
KFSaA*    02/08/22  KDE  KFSa
     *      - Revised to only create full case orders for component
     *        work orders
     *      - Also found a few bugs with component work order quantities.
     *----------------------------------------------------------------
      *----------------------------------------------------------------
      * Notes
      *
      *  - Logic has not been included to be called by a Host system.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *      *OPEN        Open program and return.
      *
      *      *CLOSE       Close program with *INLR = *ON
      *
      *
      *----------------------------------------------------------------
      *  Binding Directories
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      * File Specs
      *----------------------------------------------------------------

     fslot3     uf   e           k disk
650gAF                                     rename(slrec:slrec3)
     fslot2     uf   e           k disk
650gAF                                     rename(slrec:slrec2)
650aAFvslot1    if   e           k disk
650aAFplined    if   e           k disk
650aAFpbom      if   e           k disk
700rAFpbomsub   if   e           k disk
710cAFpbomvers  if   e           k disk
710cAfitemprdbp if   e           k disk
     Fpiritem   if   e           k disk
730aAFpbomLvlItmif   e           k disk
710bAFitemmsc   if   e           k disk
650aAFpcslot    uf a e           k disk
720 AfpBomi     if   e           k disk
     fpwrkord   uf a e           k disk    INFSR(*PSSR)
     FpWrkOrd1  uf a e           k disk    prefix(l_)
     F                                     rename(worec:worec1)
     F                                     INFSR(*PSSR)
     fpwrkordr  uf a e           k disk
     F                                     INFSR(*PSSR)
     fpwrkordru uf a e           k disk
     fitemprd   if   e           k disk
700rAfitemprdps if   e           k disk
700rAfpWrkOrdPs uf a e           k disk
710kAfpCostWom  uf a e           k disk
710kAfpLabCstLneif   e           k disk
710kAfpCostWol  uf a e           k disk
710kAfpCostWoo  uf a e           k disk
     fprmsum    uf a e           k disk
700 Afuciinfo   if   e           k disk
710tAfTask      if   e           k disk
710tAfpirTranP  uf a e           k disk
710tAfpirTranD13uf   e           k disk    prefix(d_)
730aAfpBomLvl   if   e           k disk
     fpalteritemuf a e           k disk
     fprddate1  uf a e           k disk
     fprddate   uf a e           k disk    rename(pdrec:pdrecp)
650aAFoptions   if   e           k disk
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

710 A*----------------------------------------------------------------
710 A*  Sub-procedure prototypes
710 A*----------------------------------------------------------------
730gA*  Used to add new Base Slot for Production Slots if needed
730gAD plinem          PR                  EXTPGM('PLINEM2')
730gAD  ceMsg                        99    const
730gAD  cSession                     40    const
730gAd  cUser                        10
730gAd  cPgm                         20    const
730gAd  cObjLoc                      10    const
730gAd  cSubCmd                      10    const
730gAd  cWhse                         3  0
730gAd  cMfgNo                        3  0
730gAd  cLinDesc                     30    const
730gAd  cRcv                          3
730gAd  cPrd                          3
730gAd  cPar                          3
730gAd  cWip                          3
730gAd  cStat                         1    const
730gAd  cDryAge                       1    const
730gAd  cLoc                          3  0
710 A***    Used to pause RPG cycle                        ***
     D sleep           pr            10u 0 extproc('sleep')
     D  Interval                     10u 0 value

710 A***    Used to Split delimited values into an Array   ***
710 Ad Split           pr            50    dim(50)
710 AD  strToSplit                 1000    const
710 AD  delimiter                     3    const

730aA***    Retrieve all components within Item structure
730aAd prcpBomLvl      pr          1000
     d  iWhse                         3  0 value
     d  iFgItm                       30    value
     d  iRmItm                       30    value
     d  iMakeQty                      4  0 value
     d  iMfgLine                      3  0 value
     d  ibomItems                  1000

730aA***    Return Remaining Quantity Open on Work Order
730aAd reMainingQty    pr            10  0
730aAd  icbd1                        10  0 value
730aAd  icbd2                        10  0 value
730aAd  iovrd                        10  0 value

730aA***    Return Adjust Quantity in full cases
730aAd adjustQtyprc    pr            10  0
730aAd  iqty1                         5  0 value
730aAd  iqty2                         5  0 value
730aAd  iqty3                         5  0 value

730aA***    Calculate Requirements based on deletion or adjustment
730aAd calcReq         pr

730aA***    Return Work Order Only Demand vs. Wo and User Overrides
730aAd woOnlyDmd       pr            10  0
730aAd  iwoqty1                       5  0 value
730aAd  iwoqty2                       5  0 value
730aAd  iwoqty3                       5  0 value

730aA***    Determine whether to use usage or need
730aAd getCorrectQty   pr

730aA***    Return combined lowest level quantity from string quantity in Prmsum
730aAd splitQty        pr            11  0
730aAd  iStrQty                      15    value

730aA***    Up Quantity through Unit of Measure structure
730aAd zzupQty         pr

710cA***    Used to determine whether normal, sub, or dynamic bom
710cAd chkForSub       pr             8
710cAD  chkWhse                       3  0 value
710cAD  chkWo#                       13    const
710cAd  chkRmi                       15    const
710cAd  chkFgi                       15    const
710cAd  chkLine                       3  0 value

710cA***    Used to Add/Subtract two Case/BD1/BD2 values to together
710cAd sumTwoGroups    pr
710cAD  chkGrp                       15    const
710cAD  chkaddsub                     1    const
710cAd  chkleftCase                  10  0 value
710cAd  chkleftbd1                   10  0 value
710cAd  chkleftbd2                   10  0 value
710cAd  chkrihtCase                  10  0 value
710cAd  chkrihtbd1                   10  0 value
710cAd  chkrihtbd2                   10  0 value

710cA***    Used to calculate material Cost
710kAd calcCost        pr             9  4
710kAD  cstWhse                       3  0 value
710kAD  cstResult                     9  4 value
710kAd  cstCost                       9  4 value
     d  cstNq                         5  0 value
     d  cstB1                         5  0 value
     d  cstB2                         5  0 value
     d  calcCost                      9  4 value
710kAd  cstPercent                    6  2 value
     d  cstType                       2    const

710cA***    Used to determine whether to use scale weight or bom weight
710cAd calcUsageQty    pr

710cA***    Used to determine weight factor based on scanned weight and item setup
710cAd calcFactor      pr
     d  iRmFgi                       15    value

710cA***    Create TimeStamp
     d CreateTS        pr              z
     d  date                          8p 0 const
     d  time                          6p 0 const
     ***    Used to Get time stamp values
     d GetCurrStamp    pr

     D GetMicroTime    pr
     D  $pmicrouc                      z
     D  $pmicrolocal                   z
      *----------------------------------------------------------------
      *  Customer id
      *----------------------------------------------------------------

650aA /copy qcopysrc,id#nichola
DRYaA /copy qcopysrc,ID#DAIRYLA
DRYaA /copy qcopysrc,ID#KFS

      *----------------------------------------------------------------
      *  DRI parameters
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

      *----------------------------------------------------------------
      *  Data Formats
      *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#ITEM
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#PROD
500gA /COPY *libl/qcopysrc,C#LICHIST
500gA /COPY *libl/qcopysrc,C#LICINFO
600fA /COPY *libl/qcopysrc,C#LICENSE
     D saveVer#        s                   like($ppver#)

610bA *----------------------------------------------------------------
610bA *  LT210 parameters
610bA *----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
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

      *----------------------------------------------------------------
      *  Standard variables and constants
      *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar
      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D slrec         E Ds                  Extname(Slot)
     d prdday        E Ds                  Extname(pWrkOrdru)
     d lcrecSql      E Ds                  Extname(pLabCstLne) prefix(s_)
710tAd ptdrecSql     e Ds                  extname(pirTrand) prefix(s_)
     d*

      *----------------------------------------------------------------
      *  Variables
      *----------------------------------------------------------------

     d addQty          s              7  0
730aAd allowUpdate     s               n
     d avl1            s                   like(avail1)
     d avl2            s                   like(avail2)
     d avl3            s                   like(avail3)
710 Ad bkRmITm         s             15
     d bomType         s              8
740aAd bomloc          s             10
720 Ad cc              s              3  0
     d changeRMMfg     s               n
     D CurrentTime     S               z
     D ClsTs           S               z
700g d* currQty         s              5  0
700g d currQty         s              9  4
     d date6           s              6  0
710kAd dayNbr          s             11p 0
     D ElapsedMin      S              5p 0
     D ElapsedSec      S              5p 0
730dAd fgType          s              1
730dAd fgBrk1          s              3  0
730dAd fgBrk2          s              3  0
730dAd fgUom1          s              2
730dAd fgUom2          s              2
730dAd fgUom3          s              2
     d linenum         s             10
710dAd sltExp          s              8  0
710dAd sltEnt          s              8  0
710 AD FPos            S              2  0 Inz
     D DisplayMin      S              5p 0
     D bfcoffset       s              3  0 inz(0)
710tAd costType        s              1
640jaD ucOffset        s              3  0
415aAD CurTime         s              6  0
500cAD CurrStamploc    s               z
500cAD CurrStampsys    s               z
500cAD CurrStampuc     s               z
     D CurrStampmn     s             26
     d dispHld         s                   like($sldisp)
     d loopCnt         s              2  0
     D dbgflgExists    s               n
710 AD Lpos            S              2  0 Inz
710 AD CaseQ_A         S              5    Inz
710 AD BrkD1_A         S              5    Inz
710 AD BrkD2_A         S              5    Inz
710 AD CaseQN          S              7  0 Inz
710 AD BrkD1N          S              7  0 Inz
710 AD BrkD2N          S              7  0 Inz
     D debug           s               n
710fAd openWo          s              3  0
     d wkumq2          s                   like(itumq2)
     d wkumq3          s                   like(itumq3)
710 Ad wkseq           s              5  0
     D DakotaCall      s               n
     D HostCall        s               n
     d bkitem          s             15
     d firstrec        s               n
710fAd hldMulti        s              3  0
730bAd skipbomext      s               n
     d numrecs         s              6  0
710cAd numWastelines   s              4  0
     d pIdle           s              1
730eAd prdItem         s             15
     d bkwhdp          s              5
     d bkwhse          s              3  0
700g d* inQty           s              5  0
700g d inQty           s              9  4
710p d inQtyNrm        s              9  4
710kAd qtyforLne       s              9  4
720 Ad MyfieldNull     s              5i 0
     d NetDifn         s              7  0
     d NetDif1         s              7  0
     d NetDif2         s              7  0
     d Newqtyn         s              7  0
     d Newqty1         s              7  0
     d Newqty2         s              7  0
     d Newqtyd         s              9  4
     d NewPrdq         s              9  4
     d newStat         s              1
     d opbrkr          s              1
710rAd opbxbu          s              1
730aAd opusecost       s              1
730aAd opcmprepln      s              1
710fAd pdateSql        s              8  0
     d pWhse           s              3p 0
     d pUser           s             10    varying
     d pPgm            s             20    varying
730aAd pRmItm          s             15    varying
730aAd pFgItm          s             15    varying
     D pObjLoc         s             10    varying
     d pOutStr         s           1024    varying
     d prddte          s              8  0
710tAd clsdte          s              8  0
710tAd clstim          s              6  0
     d pSessId         s             40    varying
710dAd recCnt          s              7  0
     D returnStatus    S             10I 0
     d rmExists        s               n
     d rmcntvalid      s               n
     d timeUser        s             10
650aAD wrtFlag         s               n
650aAD getMIN          s               n
     D hld_whse        s                   like(itwhse)
     D hld_item        s                   like(ititem)
     D hld_mfgno       s                   like($pplneno)
700j d hld_umq2        s                   like(itumq2)
700j d hld_umq3        s                   like(itumq3)
700nD **700j d noBrkDwn        s               n
     D LastTime        S               z
710tAD Non_Num_Posn    S              2  0 Inz(*Zero)
710tAD Numbers         C                   '0123456789'
     D wkDisp          s             12
700kD **700cAd wkqty2          s              5  0
730eAd weightFactor    s              3  0
     D wkLoc           s              3  0
730gAD nxtLoc          s              3  0
     d errmsg          s             50
     D StartTime       S               z   Inz(*Sys)
700rAd subUsed         s             15
     d sltcnt          s              3  0
710tAd qtycnt          s              3  0
710uAd qtyByLot        s              7  0
     d exccnt          s              3  0
710tAd qtyele          s              3  0
740aAd sumQtyn         s             10  0
740aAd sumQty1         s             10  0
740aAd sumQty2         s             10  0
740aAd sumPrdq         s             15  4
740aAd smumq2          s              3  0
740aAd smumq3          s              3  0
710tAd taskType        s              1
710uAd TotAvail        s              7  0
720 Ad total_open      s              6  0
     d Total_qtyn      s              7  0
     d Total_qty1      s              7  0
     d Total_qty2      s              7  0
     d Total_prdq      s              9  4
710kAd tAct_FgQty      s              7  0
710kAd tAct_qtyn       s              7  0
710kAd tAct_qty1       s              7  0
710kAd tACt_qty2       s              7  0
710kAd tAct_prdq       s              9  4
710kAd tAct_scnwg      s              9  3
710kAd tAct_tare       s              9  3
710kAd tAct_srap       s              9  3
710kAd tPrj_qtyn       s              7  0
710kAd tPrj_qty1       s              7  0
710kAd tPrj_qty2       s              7  0
710kAd tPrj_prdq       s              9  4
710kAd tPrj_scrp       s              5  4
     d tsum_qty        s              9  4
     d tu_type         s              2
     d tw_type         s              2
     d wkError         s               n
     d wkRerr2         s             50
     d wkCrtSlotErr    s             15
     d rmadj           s               n
     d Replenqty       s              5  0
     d BrkDwnQty       s              5  0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D wherelabel      s            300
710kAd iWo#            s              5i 0
710kAd iLine           s              5i 0
710kAd iTask           s              5i 0
710kAd iusnq           s              5i 0
710kAd iusb1           s              5i 0
710kAd iusb2           s              5i 0
710kAd iwsnq           s              5i 0
710kAd iwsb1           s              5i 0
710kAd iwsb2           s              5i 0
     D len             s              3  0
650aAD client          s             10
650aAD clientloc       s             10
     D CCYYMMDD        s               d   DATFMT(*ISO)
     D current_date    s              8S 0
650aAD saveLcns        s                   LIKE($saToLcns)
720eAD saveImpLcns     s                   LIKE($saToLcns)
650aAD hldsubcmd       s                   LIKE($psubcmd)
     d opnRepl         s              5  0
     d woFound         s               n
730dAd newWorkOrder    s               n
710tAd wkEmp           s              5  0
     d wkstat          s                   like(wostat)
     d wrkwo#          s             13
730bAd hldwo#          s             13
     d wrkwhse         s              3  0
     d wrkfgitm        s             15
710 Ad wkRmAvl         s              1
710 Ad wkItem          s             15
720 ad wipitem         s             15
720 aD wipwhse         s              3  0
710 Ad splitAry        s           1000    dim(50)
710kAd Nullind         s              5i 0 dim(21)
710kAd NullValue       s                   like(Nullind) inz(-1)
710 Ad wkLneNo         s              3  0
710nAd wkRplWo         s             13    varying
710tAd sqlTask         s              6
710tAd sqlLine         s              4
710tAd hldLine         s              4
710tAd sqlwo#          s             13
710tAd trnNeeded       s               n
710uAd qtyPerLot       s              8  0
730aAd itmLoop         s              4  0
730aAd nxtLoop         s              4  0
730aAd bomItems        s           1000
730aAd foundwo#        s             13
730aAd pMakeQty        s              6  0
730aAd pMakeQty1       s              6  0
730aAd pMakeQty2       s              6  0
730aAd adjLoop         s              4  0
730aAd pHoldQty        s              4  0
730aAd WrkOrdsUpd      s           1000
730aAd deleteOK        s               n
730aAd pWo#            s             13
730aAd reqQtyn         s              7  0
730aAd reqQty1         s              7  0
730aAd reqQty2         s              7  0
730aAd reqprdq         s              9  4
730aAd pMake           s              7  0
730aAd hldMakeQty      s              7  0
730dAd pMake1          s              7  0
730dAd pMake2          s              7  0
730dAd hldMakeQty1     s              7  0
730dAd hldMakeQty2     s              7  0
730aAd totalOpenWOQty  s             10  0
730aAd totalAdjustQty  s             10  0
730aAd totalWOOnlyQty  s             10  0
730aAd ovrQty          s              7  0
730aAd savPrdFlg       s              1
730aAd invAvail        s              7  0
730aAD wrkQtyn         s              7  0
730aAD wrkQty1         s              7  0
730aAD wrkQty2         s              7  0

      *  Division result and remainder data structure

     d divresult       ds
     d  result                       13  8
     d   intresult                    5  0 overlay(result)
     d   intdec                       8  0 overlay(result:*next)

      *  SQL Data Struction Record to loop through open Work Orders

     d wosum           ds           155
     d   sqitem                      15    overlay(wosum)
     d   sqfgi                       15    overlay(wosum:*next)
     d   sqmake                       4  0 overlay(wosum:*next)
     d   sqqtyp                       4  0 overlay(wosum:*next)
     d   sqrmavl                      1    overlay(wosum:*next)
     d   sqwost                       1    overlay(wosum:*next)
     d   sqqtyn                       4  0 overlay(wosum:*next)
     d   sqqty1                       4  0 overlay(wosum:*next)
     d   sqqty2                       4  0 overlay(wosum:*next)
     d   sqprdq                       9  4 overlay(wosum:*next)
     d   sqscrf                       5  4 overlay(wosum:*next)
     d   sqprimal                     1    overlay(wosum:*next)
     d   sqsubprme                    2  0 overlay(wosum:*next)
     d   sqwrst                       1    overlay(wosum:*next)
     d   sqdesc                      30    overlay(wosum:*next)
     d   squm2                        2    overlay(wosum:*next)
     d   squmq2                       3  0 overlay(wosum:*next)
     d   squm3                        2    overlay(wosum:*next)
     d   squmq3                       3  0 overlay(wosum:*next)
     d   sqpuom                       2    overlay(wosum:*next)
     d   sqippq                       9  4 overlay(wosum:*next)
     d   sqmfgno                      3  0 overlay(wosum:*next)
     d   sqcust                      11  0 overlay(wosum:*next)
     d   sqprio                       2  0 overlay(wosum:*next)
     d   sqtype                       1    overlay(wosum:*next)
     d   sqwo#                       13    overlay(wosum:*next)
     d   sqwhse                       3  0 overlay(wosum:*next)
     d   sqbrkr                       1    overlay(wosum:*next)

710kA
710kA *  SQL Data Struction Record to loop through open Work Orders
710kA
710kAd matCst          ds           176    Qualified
710kAD  mcwhse                        3  0 overlay(matcst)
710kAD  mcwo#                        13    overlay(matcst:*next)
710kAD  mcrmi                        15    overlay(matcst:*next)
710kAD  mcser                        20    overlay(matcst:*next)
710kAD  mcfgi                        15    overlay(matcst:*next)
710kAD  mcfgqty                       5  0 overlay(matcst:*next)
710kAD  mcprjnq                       5  0 overlay(matcst:*next)
710kAD  mcprjb1                       5  0 overlay(matcst:*next)
710kAD  mcprjb2                       5  0 overlay(matcst:*next)
710kAD  mcprjpq                       9  4 overlay(matcst:*next)
710kAD  mcactnq                       5  0 overlay(matcst:*next)
710kAD  mcactb1                       5  0 overlay(matcst:*next)
710kAD  mcactb2                       5  0 overlay(matcst:*next)
710kAD  mcactpq                       9  4 overlay(matcst:*next)
710kAD  mcscnwgt                      9  3 overlay(matcst:*next)
710kAD  mctare                        9  3 overlay(matcst:*next)
710kAD  mcprddte                      8  0 overlay(matcst:*next)
710kAD  mcstat                        1    overlay(matcst:*next)
710kAd  mcpocost                      9  4 overlay(matcst:*next)
710kAd  mcavgcost                     9  4 overlay(matcst:*next)
710kAd  mcstdcost                     9  4 overlay(matcst:*next)
710tAd  mcmfgno                       3  0 overlay(matcst:*next)
710kAd matcsthld       ds           176    Qualified
710kAD  mcwhse                        3  0 overlay(matcsthld)
710kAD  mcwo#                        13    overlay(matcsthld:*next)
710kAD  mcrmi                        15    overlay(matcsthld:*next)
710kAD  mcser                        20    overlay(matcsthld:*next)
710kAD  mcfgi                        15    overlay(matcsthld:*next)
710kAD  mcfgqty                       5  0 overlay(matcsthld:*next)
710kAD  mcprjnq                       5  0 overlay(matcsthld:*next)
710kAD  mcprjb1                       5  0 overlay(matcsthld:*next)
710kAD  mcprjb2                       5  0 overlay(matcsthld:*next)
710kAD  mcprjpq                       9  4 overlay(matcsthld:*next)
710kAD  mcactnq                       5  0 overlay(matcsthld:*next)
710kAD  mcactb1                       5  0 overlay(matcsthld:*next)
710kAD  mcactb2                       5  0 overlay(matcsthld:*next)
710kAD  mcactpq                       9  4 overlay(matcsthld:*next)
710kAD  mcscnwgt                      9  3 overlay(matcsthld:*next)
710kAD  mctare                        9  3 overlay(matcsthld:*next)
710kAD  mcprddte                      8  0 overlay(matcsthld:*next)
710kAD  mcstat                        1    overlay(matcsthld:*next)
710kAd  mcpocost                      9  4 overlay(matcsthld:*next)
710kAd  mcavgcost                     9  4 overlay(matcsthld:*next)
710kAd  mcstdcost                     9  4 overlay(matcsthld:*next)
710tAd  mcmfgno                       3  0 overlay(matcsthld:*next)
650iA *----------------------------------------------------------------
650iA *  Query used to determine what raw materials mfg line has stock
650iA *----------------------------------------------------------------
417bAD slrecrm         ds            21
417bAD  aryitm                       15
417bAD  arycnt                        6  0

650iA *----------------------------------------------------------------
650iA *  Query used to determine all finished goods using certain rm
650iA *----------------------------------------------------------------
417bAD fgrec           ds            21
417bAD  fgitm                        15
417bAD  fgcnt                         6  0

650iA *----------------------------------------------------------------
650iA *  Query used to find exception fg per certain rm
650iA *----------------------------------------------------------------
417bAD fgexc           ds            36
417bAD  exitm                        15
     d  exrmi                        15
417bAD  excnt                         6  0

710tA *----------------------------------------------------------------
710tA *  Query used to spread Daily Labor Cost for Standard Definition
710tA *----------------------------------------------------------------
710tAD TranCsRec       ds            68
710tAD  trnWhse                       3  0
710tAd  trnLine                       3
710tAD  trnStat                       1
710tAd  trnrate                       7  3
710tAd  trndywk                       7
710tAd  trnsecs                       7  0
710tAd  trnwo#                       13
710tAd  trntask                       6
710tAd  trnbenrt                      6  4
710tAd  trnohpct                      6  4
710tAD  trnEmp                        5  0
710tA
710tA *----------------------------------------------------------------
710tA *  Query used to spread Daily Labor Cost for Actual
710tA *----------------------------------------------------------------
710tAD TranActRec      ds            45
710tAD  trnaWhse                      3  0
710tAd  trnaLine                      3
710tAd  trnawo#                      13
710tAd  trnaTask                      6
710tAD  trnaStat                      1
710tAD  trnaEmp                       5  0
710tAD  trnaShft                      6
710tAd  trnasecs                      8  0
720 A
720 A *----------------------------------------------------------------
720 A *  Query used to tally demand for WIP item Array
720 A *----------------------------------------------------------------
720 AD WoHdr           ds            54
720 AD  w_wowhse                      3  0
720 Ad  w_woitem                     15
720 Ad  w_writem                     15
720 Ad  w_wrqtyn                      4  0
720 AD  w_wrqty1                      4  0
720 AD  w_wrqty2                      4  0
720 AD  w_wrqtyp                      9  4
720 A
650iA *----------------------------------------------------------------
650iA *  Production Work Order Data Structure
650iA *----------------------------------------------------------------
650iAD wkwo#           ds
650iAD  wkwodate               1      8
650iAD  wkwoseq                9     13  0
720 A
720 A *----------------------------------------------------------------
720 A *  WIP Item Total Required Array
720 A *----------------------------------------------------------------
720 AD                 ds
720 Ad wipary                               dim(300)
720 AD  wiparywhse                    3  0  overlay(wipary:*next)
720 AD  wiparyitem                   15     overlay(wipary:*next)
720 Ad  wiparynrm                     4  0  overlay(wipary:*next)
720 Ad  wiparybd1                     4  0  overlay(wipary:*next)
720 Ad  wiparybd2                     4  0  overlay(wipary:*next)
720 Ad  wiparyprd                     9  4  overlay(wipary:*next)
650iA
650iA *----------------------------------------------------------------
650iA *  Production Array to hold Raw Material numbers in current Line
650iA *----------------------------------------------------------------
650aAd                 ds
650aAd aryRMI                              dim(500)

650aAd  rmInvItm                     15    overlay(aryRMI:*next)
650iA
650iA *----------------------------------------------------------------
650iA *  Production Array to hold Alter Finished Goods
650iA *----------------------------------------------------------------
650aAd                 ds
650aAd aryFGI                              dim(500)

650aAd  fgInvItm                     15    overlay(aryFGI:*next)
710kA
710kA *----------------------------------------------------------------
710kA *  Production Array to hold completed jobs for Line/Production Date
710kA *----------------------------------------------------------------
710kAd                 ds
710kAd aryCJobs                            dim(500)

710kAd  compLne                       3  0 overlay(aryCJobs:*next)
710kAd  compItm                      15    overlay(aryCJobs:*next)
710kAd  compWo                       13    overlay(aryCJobs:*next)
710kAd  compQty                       9  4 overlay(aryCJobs:*next)
710tA
710tA *----------------------------------------------------------------
710tA *  Production Array to hold completed job Qty by Prod Line
710tA *----------------------------------------------------------------
710tAd                 ds
710tAd aryCLQty                            dim(99)
710tAd
710tAd  clneLne                       3  0 overlay(aryClQty:*next)
710tAd  clneQty                       9  4 overlay(aryClQty:*next)

     d*  Array to split out BOM Items called by proper order
730aAd bomIary         s             30    dim(500)

     d*  Array to keep up with whether down step in tree has been updated
     d*  from higher up item
730aAd bomXary         s              1    dim(500)

     d*  Array tracking Net Quantity required at each level Case Qty
730aAd bomNqty         s             10  4 dim(500)

     d*  Array tracking Net Quantity required at each level Brkdwn1
730dAd bomNqty1        s             10  4 dim(500)

     d*  Array tracking Net Quantity required at each level Brkdwn2
730dAd bomNqty2        s             10  4 dim(500)

     d*  Array tracking Gross Quantity required at each level Case Qty
730aAd bomGqty         s             10  4 dim(500)

     d*  Array tracking Gross Quantity required at each level Brkdwn1
730dAd bomGqty1        s             10  4 dim(500)

     d*  Array tracking Gross Quantity required at each level Brkdwn2
730dAd bomGqty2        s             10  4 dim(500)

730aAd*  Array to split out Required Quantities from Production Requirements
730aAd*  Splits fields from pRMsum like SMRMDQ, SMREQQ, etc..
730aAd bomQary         s             30    dim(500)

      *----------------------------------------------------------------
410aA *  *SYSTEM  -  System options.
      *
      * Fields
      *
      *    OPEPM   -  Using EPM module (Y,N).
      *    OPRF    -  Using RF module (Y,N).
      *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
      *    OPLETD  -  Print letdown labels (Y,N).
410 A *    OPWRNC  -  Perform catch weight variance check (Y,N).
410 A *    OPRG1C  -  Catch weight low variance percentage.
410 A *    OPRG2C  -  Catch weight high variance percentage.
411 A *    OPIMPI  -  Import item fields from host.(Y,N).
412 A *    OPICW   -  Individual catch weight $ntry (Y,N).
530aA *    OPUCI   -  Use UCI processing (Y,N) ntry (Y,N).
      *
      * Data structure
      *
     D opdata          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
410 AD  opwrnc                 5      5
410 AD  oprg1c                 6      8  1
410 AD  oprg2c                 9     11  1
411 AD  opimpi                12     12
412 AD  opicw                 13     13
530aAD  opuci                 36     36
     D  optend               117    117

      *----------------------------------------------------------------
      *  File information data structure
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------------

     D pssrflag        s               n

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600fAD  #curruser            358    367

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *      $pdata2    Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
      *      $pdata2    Data returned by command
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $psubcmd
     C                   parm                    $pprogram
     C                   parm                    $preturn
     C                   parm                    $pmessage
     C                   parm                    $pdata
     C                   parm                    $pdata2

      /free

700eA    // Set SQL default parms
700eA    exec sql
700eA      set Option Commit=*none, Dlyprp=*Yes,
700eA                 Closqlcsr = *ENDMOD;

         $pprod = $pdata;
         $pprod2 = $pdata2;
         $preturn = '*OK';
         $pmessage = ' ';
         pSessId = %trim($ppsessid);

          if dbgflgExists;
            chain(e) (#pgm) bfcdbgflg;
            if %found(bfcdbgflg);
              debug = (bdfflag = 1);
            else;
              debug = *off;
            endif;
          endif;


      /end-free

      *----------------------------------------------------------------
      * Main line
      *----------------------------------------------------------------

      /free

       dou 1=1; //bottom

         // See which system is calling the program.

         if %subst($psubcmd:1:1) = '%';
           DakotaCall = *on;
           HostCall = *off;
           %subst($psubcmd:1:1) = '*';
         else;
           HostCall = *on;
           DakotaCall = *off;
         endif;

         // See if we are just opening or closing program.

         select;

           when $psubcmd = '*OPEN';
             $preturn = '*OK';
             $pmessage = ' ';
             leave; //bottom

           when $psubcmd = '*CLOSE';
             $preturn = '*OK';
             $pmessage = ' ';
             exsr aaaclose;
             *inlr = *on;
             leave; //bottom

         endsl;

         // Otherwise, do some initialization and move on.

         exsr aaainit;
         error = *off;

         exsr chkZstat;

         // Do what user has requested.

         select;

           when $psubcmd = '*ADJQTY'
710eA        or $psubcmd = '*IMPQTY';
             exsr VerifyQty;
             if not error;
               exsr adjustQty;
             endif;

           when $psubcmd = '*AVGPRD'
             or $psubcmd = '*PRDQTY';
             exsr crtSugg;

710uA      when $psubcmd = '*MINMAX';
710uA        exsr crtMMSugg;

730aA      when $psubcmd = '*CALCNEED';
730aA        exsr calcneed;
           when $psubcmd = '*CHKFORWO';
             exsr chkforwo;

           when $psubcmd = '*CRTPRODWO';
             exsr crtProdWo;

           when $psubcmd = '*CRTWORPL';
             exsr verifyCrtRPL;
             if not error;
710 D       //  exsr crtworeplen;
720dA           rmExists=*on;
710 A           exsr crtworeplen1;
700qA           if $trtn <> ' ' and $trtn<>'*OK';
700qA              $preturn = $trtn;
700qA              $pMessage = $tmsg;
700qA           endif;
             endif;

           when $psubcmd = '*CLSWO';
             exsr verifyClo;
             if not error;
                exsr closeWo;
             endif;

710dA      when $psubcmd = '*EXPIREDT';
710eA         if $psubcmd <> '*IMPQTY'
710fA            and $psubcmd <> '*GETMIN'
710fA            and ($ppAction='PSC');
710dA           exsr calcExpireDt;
              endif;

           when $psubcmd = '*DELWO';
             exsr verifyDel;
             if not error;
                exsr delWorkOrder;
             endif;

           when $psubcmd = '*GENALTER';
             exsr genAlterItem;

           when $psubcmd = '*GETNXTWO';
             exsr getnxtpwo;

           when $psubcmd = '*GETSLOT';
             exsr VerifyPAR;
             if not error;
               loopCnt = 1;
               dow loopCnt < 50;
                  exsr getPrdSlot;
                  if $driReturn = 'ERRADDREC';
                     loopCnt = loopCnt + 1;
                  else;
                     leave;
                  endif;
               enddo;
             endif;

           when $psubcmd = '*GETMIN';
             exsr VerifyMIN;
             if not error;
               loopCnt = 1;
               dow loopCnt < 50;
                  getMin = *on;
                  exsr getPrdSlot;
                  getMin = *off;
                  if $driReturn = 'ERRADDREC';
                     loopCnt = loopCnt + 1;
                  else;
                     leave;
                  endif;
               enddo;
             endif;

710aA      when $psubcmd = '*RMQTYEXT';
710aA        wkItem = $ppItem;
710aA        wkLneNo = $ppLneno;
710aA        wkRmAvl = $ppRmAvl;
             rmExists = *on;
             exsr rmRdOpnQty;

710tA      when $psubcmd = '*STRLAB';
710tA         exsr zzEditLabor;
710tA         if not error;
710tA           exsr generateLabor;
710tA         endif;

710tA      when $psubcmd = '*CLSLAB';
710tA         exsr zzEditLabor;
710tA         if not error;
710tA            exsr generateLabor;
710tA         endif;

710kA      when $psubcmd = '*SPRDCOST';
             exsr zzStdTrans;
710kA        exsr sprdCost;

730aA      when $psubcmd = '*UPDLOOP';
730aA        exsr updLoop;

           when $psubcmd = '*UPDPRODWO';
             exsr updProdWo;

           when $psubcmd = '*UPDRMUSE';
             exsr updRmUsage;

           when $psubcmd = '*UPDRMUSE';
             exsr UpdRmUsage;

710dA      when $psubcmd = '*wheresbom';
710dA        exsr WheresBom;

           other;
             error = *on;
             $preturn = 'INVLDSBCMD';
             $pmessage = 'Invalid subcommand '
                       + '(' + %trim($psubcmd) + ') '
                       + 'sent to ' + %trim(#pgm);

         endsl;
         leave;

       enddo; //bottom

       // We are finished so get out

       $pdata = $pprod;
       $pdata2 = $pprod2;
       *inlr = *on;
       exsr unlockrec;
       return;

      /end-free

      *----------------------------------------------------------------
      *          SUBROUTINES IN ALPHABETICAL ORDER
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  *PSSR  Unexpected error handler
      *----------------------------------------------------------------

      /free
       begsr *pssr;

         // Make sure we don't get caught in an infinite loop

         if pssrflag;
           *inlr = *on;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program

         dump(a);
         $preturn = 'U:' + #status;
         $pmessage = 'U:'
                   + %trim(#pgm)
                   + '('
                   + %trim(%editc(#stmt:'Z'))
                   + ')-'
                   + #pgmmsg;
         *inlr = *on;
         return;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  aaainit   Pre-subcommand initialization.
      *----------------------------------------------------------------

      /free
       begsr aaainit;
      /end-free
KFSaA *   Move client code to top since I need earlier than it was running
710mAC*
710mAC*   Get Client Code
710mAC*
710mAC                   call      'GETCLIENT'
710mAC                   parm                    client           10
710mAC                   parm                    clientloc        10
      /free

KFSaA    // When Kellys Food Service we get flag stating whether
KFSaA    // component or not so we push component production directly
KFSaA    // to another LIN slot instead of PAR slot
KFSaA    if (client=Kellys and ($ppdest='P' or $ppdest='C'));
KFSaA      chain ($ppwhse:$ppitem) itemprd;
KFSaA      if not %found(itemprd);
KFSaA        // if not found then default to finished good
KFSaA        // ** should never happen **
KFSaA        ipPrdFlg = 'F';
KFSaA      endif;
KFSaA    endif;

         // get Production setting for Allow Planning Breakdown Replen
         chain ($ppwhse: '*PROD') options;
         if %found(options);
            opbrkr = %subst(opdata:23:1);
710rA       opbxbu = %subst(opdata:24:1);
730bA       opusecost = %subst(opdata:30:1);
730bA       opcmprepln = %subst(opdata:31:1);
         else;
            opbrkr = 'N';
710rA       opbxbu = 'N';
730bA       opusecost = 'N';
730bA       opcmprepln = 'N';
         endif;

         chain (0: '*SYSTEM') options;
         if not %found(options);
           opcapc = 'Y';
           opwrnc = 'N';
           oprg1c = 0;
           oprg2c = 0;
           opicw = 'N';
         endif;
710nA    wkLneNo = *zeros;
710nA    wkRplWo = *blanks;
      /end-free
      *
      *   Get default values for the user.
      *
     C                   call      'GETUSER'
     C                   parm                    $ppuser
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

      /free
720 A      // if mfg line is sent as zero check to see if item coming in has
720 A      // default line.
720 A      if $pplneno = *zeros;
720aA         select;
720aA         when $ppwo# <> *blanks;
720 A            chain ($ppwhse:$ppwo#) pwrkord;
720 A            if %found(pwrkord);
720 A               $pplneno = womfgno;
720 A            else;
720aA               if $ppitem <> *blanks;
720aA                  chain ($ppwhse:$ppitem) itemprd;
720 A                  if %found(itemprd);
720 A                     $pplneno = ipmfgno;
720 A                  else;
720 A                     $pplneno = 1;
720aA                  endif;
720aA               endif;
720 A            endif;
720aA         when $ppitem <> *blanks;
720 A            chain ($ppwhse:$ppitem) itemprd;
720 A            if %found(itemprd);
720 A               $pplneno = ipmfgno;
720 A            else;
720 A               $pplneno = 1;
720 A            endif;
720aA         endsl;
720 A      endif;
           // determine set Production Date
710dA      chain ($ppwhse:$pplneno) plined;
710tD      //if $pprogram <> 'OR610';
710tM      if $pprogram <> 'OR610' and $pprogram<>'SPRDPRDCST'
710tA            and $pSubCmd<>'*STRLAB' and $psubcmd<>'*CLSLAB';
710dD    //   chain ($ppwhse:$pplneno) plined;
              if %found(plined);
                 chain(n) ($ppwhse:$pplneno:'O') prddate1;
                 if %found(prddate1);
                    prddte = pddate;
                 else;
710rA               // if no Production Date defined and Box Breaker use current date
710rA               if opbxbu = 'B';     // Box Breaker Only
710aA                 prddte = %uns(%char(%Date():*Iso0));
710rA               else;
                       prddte = 0;
                       $pReturn = 'INVPRDDTE';
                       $pmessage = 'Invalid Production Date for Mfg Line';
                       exsr unlockrec;
                       return;
710rA               endif;
                 endif;
              else;
                 prdDte = 0;   // if cmd sent where required it will fail
              endif;
           else;           // OR610 returns current date for Prodlog
710tA         if $pprogram = 'OR610';
                 prdDte = %dec(%char(%date():*iso0):8:0);
710tA         else;
710tA            // When spreading cost (program SPRDPRDCST) use shift date passed
710tA            prdDte = $ppExpdt;
710tA         endif;
           endif;      // End for $pprogram = OR610
710sA      chain ($ppwhse:$ppitem) piritem;
710tA      costType = 'A';
730aA      itmLoop=*zeros;
       endsr;
      /end-free

      *----------------------------------------------------------------
      *  aaaclose   Close called programs
      *----------------------------------------------------------------

      /free
       begsr aaaclose;
       endsr;
      /end-free

      *----------------------------------------------------------------
      *  addSlot - Pass information to DRSLOT to add production slot
      *----------------------------------------------------------------

      /free
       begsr addSlot;
                // insert code to setup parms and call drislot to add
                // desired slot
                $slwhseu = *on;
                $slwhse  = $ppwhse;
                $slwhdpu = *on;
                $slwhdp  = $ppwhdp;

                $slstypu = *on;
                $slstyp = 'F';
                $slpicku = *on;
                $slpick = 'N';
                $slpsequ = *on;
                $slpseq = 999;
                $sllocu = *on;
                $slloc = wkLoc;
                $slrlvlu = *on;
                $slrlvl = $pplneno;
                $slhandu = *on;
                $slhand = ' ';
                $slrsrvu = *on;
                $slrsrv = 'N';
                $slstatu = *on;
                $slstat = 'PR';

                $slitemu = *on;
                $slitem  = $ppitem;

                $dricommand = '*SLOT';
                $drisubcmd = '%ADD';
                $drisys2upd = 'D';
                exsr zzDriCop2;
                if wkerror;
                   wkCrtSlotErr = '*SLTCRTER';
                   $pReturn = $drireturn;
                   $pMessage = $drimessage;
        //         $pMessage = 'Problem adding Slot ' + $sldisp +
        //                       '.  No replen created';
                   exsr unlockrec;
                   return;
                else;

                select;
                   when getmin;
710dM                $pprcvar = %trim($sldisp);
                   when $ppdest = 'C';       // customer
710dM                  $ppshpar = %trim($sldisp);
                      // ensure cross reference record not already here
                      chain(n) ($ppwhse:$ppcust:$ppitem) pcslot;
                      if not %found(pcslot);
                         // create cross refernece record
                         cswhse = $ppwhse;
                         cscust = $ppcust;
                         csitem = $ppitem;
710dM                    csdisp = %trim($ppshpar);
                         write csrec;
                      else;
                         unlock pcslot;
                      endif;
                   when $ppdest = 'P';       // PAR stock
                      $ppparar = %trim($sldisp);
                   other;
                endsl;

                endif;

       endsr;
      /end-free

710kA *----------------------------------------------------------------
710kA *  AccumRmQty - Accumulate quantities for raw material usage
710kA *               to spreadh cost at End of Day
710kA *----------------------------------------------------------------

710kA /free
710kA      begsr accumRmQty;
710kA
710kA         // Sum record by record values from pWrkOrdru
710kA         tPrj_qtyn = tPrj_qtyn + matcst.mcprjnq;
710kA         tPrj_qty1 = tPrj_qty1 + matcst.mcprjb1;
710kA         tPrj_qty2 = tPrj_qty2 + matcst.mcprjb2;
710kA         tPrj_prdq = tPrj_prdq + matcst.mcprjpq;
710kA         tAct_qtyn = tAct_qtyn + matcst.mcactnq;
710kA         tAct_qty1 = tAct_qty1 + matcst.mcactb1;
710kA         tAct_qty2 = tAct_qty2 + matcst.mcactb2;
710kA         tAct_prdq = tAct_prdq + matcst.mcactpq;
710kA         tAct_FgQty= tAct_FgQty+ matcst.mcFgQty;
710kA         tAct_scnwg= tAct_scnwg+ matcst.mcScnWgt;
710kA         tAct_Tare = tAct_Tare + matcst.mctare;
710kA
710kA      endsr;
710kA /end-free

      *----------------------------------------------------------------
      *  AdjustQty - Add quantity to nt slot for passed data
      *----------------------------------------------------------------

     c     adjustQty     begsr

      /free

710cA     // ensure rmqty if off from any previous run
710cA     rmadj = *off;

710dA     // Either setup or find and return respective production
710dA     // slot for this quantity adjustment
710dA     // DO NOT get slot if one was sent in
710dA     if not $ppshparu and not $pppararu
710dA        and $ppuci = '';
710dA        exsr getPrdSlot;
710dA     endif;

710dA     // Confirm that LIN slot still exists to prevent
710dA     // *** Box Breaker  ***
710dA     if $ppAction = 'BXB';
700iA        setll ($ppwhse) plined;
710dA        reade ($ppwhse) plined;
710dA        if not %equal(plined);
710dA           $pprcva = 'LIN';
710dA        else;
710dA           $pprcva = inrcvaisl;
700iA           $pprcva = 'LIN';
710dA        endif;
710dA        if getMin;
710dA           exsr getPrdSlot;
710dA        else;
710dA           // if getmin off turn on to verify LIN
710dA           // line slot still exists then turn off
710dA           getmin = *on;
710dA           exsr getPrdSlot;
710dA           getmin = *off;
710dA        endif;
710dA     endif;

       // Coming from VerifyQty lets update slot with requested adjustment
       // Initialize data structure

          if $drireturn = ' ' or $drireturn = '*OK'
               or $drireturn = 'INSLOT';
             savever# = $slver#;
             clear $slot;
             clear $slot2;
             $slver# = savever#;

       // Move fields to slot data structure for quantity adjustment

             $slwhseu = *on;
             $slwhse  = $ppwhse;

             $slwhdpu = *on;
             $slwhdp = $ppwhdp;

             $sldispu = *on;
700 A        if $ppuci <> '' and $ppdspbb <> '';
700 A           // if Box Breaker app used passed in pick slot
700 A           $ppdest = 'P';
710dM           $sldisp = %trim($ppdspbb);
700 A        else;
                if $ppdest = 'M'     // Raw Material Adjustment for Line
                   or getmin;
710dM              $sldisp = %trim($pprcvar);
                else;
                   if $ppdest = 'C';
710dM                 $sldisp = %trim($ppshpar);  // customer
                   else;
710dM                 $sldisp = %trim($ppparar);  // par stock
                   endif;
                endif;
700 A        endif;

             $saitemu = *on;
             $saitem  = $ppitem;

             if $ppqty1 <>0 or $ppqty2<>0 or $ppqty3<>0;
                $saqtyu = *on;
             endif;
700bA
700bA      // if item for adjustment has a breakdown qty
700bA      // defined then roll up to highest uom
700bA        exec sql
700bA             select itumq2,itumq3 into :squmq2,:squmq3
700bA                    from piritem
700bA                    where itwhse=:$ppwhse and
700bA                          ititem=:$ppitem;
700bA
700bA        if squmq2 <> *zeros or squmq3 <>*zeros;
700bA           newqtyn = $ppqty1;
700bA           newqty1 = $ppqty2;
700bA           newqty2 = $ppqty3;
700bA           zzupqty();
700bA           $ppqty1 = newqtyn;
700bA           $ppqty2 = newqty1;
700bA           $ppqty3 = newqty2;
700bA        endif;
700bA
             $saqty1 = $ppqty1;
             $saqty2 = $ppqty2;
             $saqty3 = $ppqty3;

             $sacwtau = *on;
             if $ppwgt < *zeros;
                $sacwta  = $ppwgt + $pptare;
             else;
                $sacwta  = $ppwgt - $pptare;
             endif;

             if $ppAction = 'PBF' or $ppAction = 'PSC';
                $saPRDSITMu = *on;
                $saPrdSitm  = $ppitem;
             else;
                $saPRDSITMu = *off;
                $saPrdSitm  = ' ';
             endif;

             $saMfgLneu = *on;
             $saMfgLne  = $ppLneno;

             if $ppgs1u = *on;
                $sags1u = *on;
                $sags1  = $ppgs1;
             endif;

             if $ppser#u = *on;
                $saser#u = *on;
                $saser#  = $ppser#;
             endif;

             if $ppwgtu = *on;
                $saprdwgtu = *on;
                $saprdwgt  = $ppwgt;
             endif;

             if $pptareu = *on;
                $satarewgtu = *on;
                $satarewgt  = $pptare;
             endif;

             if $ppcustu = *on;
                $saprdcustu = *on;
                $saprdcust  = $ppcust;
             endif;

             if $ppwo#u = *on;
                $saprdwou = *on;
                $saprdwo  = $ppwo#;
             endif;

             $sacodeu = *on;
             $sacode  = $ppadjcde;

             $samemou = *on;
             $samemo  = '';

             $sabyu   = *on;
             $saby    = $ppuser;

             $saemp#u = *on;
             $saemp# = #emp#;

             $saActionU = *on;
             $saAction = $ppAction;
             if $ppAction = ' ';
710fA           // if blank action from End of Day put PIU or PIW
710fA           // else use Scale transaction as PSC
710fA           select;
710fA              when $ppadjcde = 'P1' or $slAisl = inRcvAisl
710fA                                    or $slAisl = inWipAisl;
710fA                 $saAction = 'PIU';
710fA              when $ppadjcde = 'P2';
710fA                 $saAction = 'PIW';
710fA              other;
                     $saAction = 'PSC';
710fA           endsl;
             endif;
             $saToAreaU = *on;
             $saToArea = 'Slot';
             $saToLcnsU = *on;
730fA        if $ppAction = 'CBB';
730fA          $saToLcns = '*BB';
730fA        else;
               $saToLcns = '*PR';
730fA        endif;
             if $ppTrn#u;
                $saTrn#u = *on;
                $saTrn# = $ppTrn#;
             endif;

710dA        // pass Enter date from Slot lookup/create
710dA        $slEntd = sltEnt;
710dA        $slEntdU = *on;

710dA        // pass Expiration date from slot lookup/create
720eA        // when the expdirdation date is sent in for Canopy import
720eA        // use it instead of slot date.
720eA        if $psubcmd = '*IMPQTY';
720eA          if $ppExpdtU;
720eA            $slExpd = $ppExpdt;
720eA            $slExpDU = *on;
730fA            $slEntd = %uns(%char(%Date():*Iso0));
720eA          else;
710dA            $slExpd = sltExp;
710dA            $slExpDU = *on;
720eA          endif;
740aA        else;
740aA          $slExpd = sltExp;
740aA          $slExpDU = *on;
720eA        endif;

710fA        // pass in Raw MAterial UCI if MultiDay PRoduction
710fA        $saRmUci = $ppRmUci;
710fA        $saRmUciU = *on;

700 A        if $ppAction = 'BXB';
700 A           chain ($ppWhse:$ppUCI) uciinfo;
700 A           if %found(uciinfo);
700 A              $saOLcnsU = *on;
700 A              $saOLcns = uilcns;
700 A           endif;
700 A        endif;

             $dricommand = '*SLOT';
710eA        if $psubcmd = '*IMPQTY';
710eA          $drisubcmd  = '%ADJUSTIMP';
710eA        else;
               $drisubcmd  = '%ADJUST';
710eA        endif;
             $drisys2upd = 'D';
710sA        if $ppAction='BXB' and itum2=*blanks;
710sA           $pMessage = *blanks;
710sA           $preturn = '*BOXNOUOM';
710sA           $ppToLcns=*blanks;
710sA           $sldisp=*blanks;
710sA           leavesr;
710sA        else;
                exsr zzDriCop2;
710sA        endif;
             if wkerror;
                wkCrtSlotErr = '*ADJSTKERR';
                $pReturn = '*ADJSTKERR';
710aD        //   $pMessage = 'The qty adjust failed ' +
710aD        //        'for a qty of ' + %char($saqty1) + ', slot ' + %trim($sldisp);
710aA           $pMessage = $driMessage;
                exsr unlockrec;
                return;
             else;
650gA
             // update Production Quantity for Scale transactions
             // that produce or reverse production
             if $ppAction = 'PSC';
                chain ($ppwhse:$ppwo#) pWrkord;
                if %found(pWrkOrd);
                   if $ppItem = woitem;
                      woqtyp = woqtyp + $ppqty1;
                   else;
                      woqtys = woqtys + $ppqty1;
                   endif;
                   wostat = 'W';
                   update worec;
                endif;
             endif;

             // if this represents an End of Day transaction
             // call process to update and close open production
             // transactions
             if $ppAction = 'PIU';
                exsr WrtRmUsage;
             endif;
700 A
             $saOLcnsu = *on;
730cA        if $psubcmd = '*IMPQTY';
730cA          savelcns = $satolcns;
730cA        endif;
650gA        $dricommand = '*SLOT';
650gA        $drisubcmd  = '%GET';
650gA        $drisys2upd = 'D';
             exsr zzDriCop2;
             if wkerror;
                wkCrtSlotErr = '*LICERR';
                $pReturn = '*LICERR';
710aD      //   $pMessage = 'Unable to retrieve license for slot ' +
710aD      //         $sldisp;
710aA           $pMessage = $driMessage;
                exsr unlockrec;
                return;
             else;
                if $saToLcns <> *blanks;
730cA             if $satolcns = '*MULTIPLE' and $psubcmd = '*IMPQTY';
730cA               $ppToLcns = savelcns;
730cA             else;
                   saveLcns = $saToLcns;
                   $ppToLcns = $saToLcns;
730cA             endif;
                else;
                   $ppToLcns = $saOLcns;
                endif;
                if $slstat <> 'Z';
                   exsr backFlush;
                else;
                   $dricommand = '*SLOT';
                   $drisubcmd  = '%ZEROVFY';
                   $drisys2upd = 'D';
                   exsr zzDriCop2;
                   if wkerror;
                      wkCrtSlotErr = '*LICERR';
                      $pReturn = '*LICERR';
                      $pMessage = 'Unable to Zero verify slot ' +
710dM                    %trim($sldisp);
                   else;
                      // back flush last of raw material when fg slot goes
                      // to "Z" status
                      exsr backFlush;
                   endif;
                endif;
                if $ppdest = 'M';
                   $ppToLcns = $saToLcns;
                else;
                   $ppToLcns = saveLcns;
                endif;
             endif;
             endif;
           endif;

      /end-free
     c                   endsr

      *----------------------------------------------------------------
      *  Adjust Raw Materials per production and BOM
      *----------------------------------------------------------------

     c     adjustRM      begsr

      /free
       // Either setup or find and return respective raw material
       // slot for this quantity adjustment
             exsr getPrdSlot;

       // Put Quantity in respective production slot
       // Initialize data structure

       // get item master for raw material being processed for bom
             chain (bmwhse:bmrmi) piritem;

             savever# = $slver#;
             clear $slot;
             clear $slot2;
             $slver# = savever#;

             $slwhseu = *on;
             $slwhse  = bmwhse;

             $slwhdpu = *on;
             $slwhdp = itwhdp;

             $sldispu = *on;
710dM        $sldisp = %trim($pprcvar);

             $saitemu = *on;
             $saitem  = bmrmi;

             $saPRDSITMu = *on;
             $saPrdSitm  = bmfgi;

             $saMfgLneu = *on;
             $saMfgLne  = $ppLneno;

             if $ppgs1u = *on;
                $sags1  = $ppgs1;
             else;
                $sags1 = ' ';
             endif;

             if $ppser#u = *on;
                $saser#  = $ppser#;
             else;
                $saser# = ' ';
             endif;

             if $ppqty1 <>0;
                $saqtyu = *on;
             endif;
           // raw material quantities are performing the reverse sign
           // transaction.  In other words, since the person has created
           // a label as a postive 1 ($ppqty1) we are multiplying by what
           // was defined to make that one and then subtracting from the
           // raw materials used to make that 1 quantity.  We would do the
           // reverse if the user deletes one of the labels
             select;
             // quantity will always come to this routine in $ppqty1
             // since the label creation is calling this routine only
             // when back flushing is marked.  Therefore $ppqty1 has
             // the label count and is extended by the bill of material
             // requirements in connection with the lowest level of
             // unit of measure defined for the bill of material
             when bmqty2 <> 0;
730dA           // $ppQty1 is Label Count
730dA           // bmqtyx is requirement per bom
730dA           // itumq2 and itumq3 is item quantities per breakdown
730dA           // Extend Case Quantities with $ppQty1
                $saqty3 = (($ppqty1 * bmqtyn * itumq2 * itumq3) +
                           ($ppqty1 * bmqty1 * itumq3) +
                           ($ppqty1 * bmqty2) +
730dA           // Extend Brk1 Quantities with $ppQty2
730dA                      ($ppqty2 * bmqty1 * itumq3) +
730dA                      ($ppqty2 * bmqty2) +
730dA           // Extend Brk2 Quantities with $ppQty3
730dA                      ($ppqty3 * bmqty2));
750aA           $saQty3 = $saQty3 * -1;
730dA           $saQty2=0;
730dA           $saQty1=0;
             when bmqty1 <> 0;
730dA           // Extend Case Quantities with $ppQty1
                $saqty2 = (($ppqty1 * bmqtyn * itumq2) +
                           ($ppqty1 * bmqty1) +
730dA           // Extend Brk1 Quantities with $ppQty2
730dA                      ($ppqty2 * bmqty1));
750aA           $saQty2 = $saQty2 * -1;
730dA           $saQty3=0;
730dA           $saQty1=0;
             other;
                $saqty1  = ($ppqty1 * bmqtyn);
750aA           $saQty1 = $saQty1 * -1;
730dA           $saQty2=0;
730dA           $saQty3=0;
             endsl;

             $sacwtau = *on;
             $sacwta  = 0;

             $sacodeu = *on;
             $sacode  = $ppadjcde;

             $samemou = *on;
             $samemo  = '';

             $sabyu   = *on;
             $saby    = $ppuser;

             $saemp#u = *on;
             $saemp# = #emp#;

             $saActionU = *on;
             $saAction = $ppAction;
             // if $ppAction = ' ' or $ppAction='PSC';
                $saAction = 'PBF';
             // endif;
             $saToAreaU = *on;
             $saToArea = 'Slot';
             $saToLcnsU = *on;
             $saToLcns = '*PR';
             if $ppTrn#u;
                $saTrn#u = *on;
                $saTrn# = $ppTrn#;
             endif;
             // pass current date to Date Entered for license files
710dA        $slEntd = %uns(%char(%Date():*Iso0));
710dA        $slEntdU = *on;

             $dricommand = '*SLOT';
             $drisubcmd  = '%ADJUSTPRD';
             $drisys2upd = 'D';
             exsr zzDriCop2;
             if wkerror;
                wkCrtSlotErr = '*ADJSTKERR';
                $pReturn = '*ADJSTKERR';
710aD       //  $pMessage = 'The qty adjust failed ' +
710aD       //       'for a qty of ' + %char($saqty1) + ', slot ' + $sldisp;
710aA           $pMessage = $driMessage;
                exsr unlockrec;
                return;
             else;
650gA
             $saOLcnsu = *on;
650gA        $dricommand = '*SLOT';
650gA        $drisubcmd  = '%GET';
650gA        $drisys2upd = 'D';
             exsr zzDriCop2;
             if wkerror;
                wkCrtSlotErr = '*LICERR';
                $pReturn = '*LICERR';
710aD      //   $pMessage = 'Unable to retrieve license for slot ' +
710aD      //         $sldisp;
710aA           $pMessage = $driMessage;
                exsr unlockrec;
                return;
             else;
                if $slstat = 'Z';
                   $dricommand = '*SLOT';
                   $drisubcmd  = '%ZEROVFY';
                   $drisys2upd = 'D';
                   exsr zzDriCop2;
                   if wkerror;
                      wkCrtSlotErr = '*LICERR';
                      $pReturn = '*LICERR';
                      $pMessage = 'Unable to Zero verify slot ' +
710dM                    %trim($sldisp);
                   endif;
                endif;
                $ppToLcns = $saToLcns;
             endif;
             endif;

      /end-free
     c                   endsr

      *----------------------------------------------------------------
      *
      *  AVAIL   Calculate available quantities for slot.
      *
     C     avail         begsr
      *
      *  Call program to calculate availabe slot quantities.
      *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
      *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
      *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
      *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
      *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
      *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
      *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
640hA
640hA *  Call program to get open Directed Putaway quantity.
640hA
710dAc                   eval      sldisp = %trim(sldisp)
640hAC                   call      'CHKOPNDP'
640hAC                   parm      slwhse        dWhse             3 0
640hAC                   parm      slwhdp        dWhdp             5
640hAC                   parm      sldisp        dDisp            12
640hAC                   parm      slitem        dItem            15
640iAC                   parm                    dTotal            3 0
640iAC                   parm                    dItmTtl           3 0
640hAC                   parm                    dQty1             5 0
640hAC                   parm                    dQty2             5 0
640hAC                   parm                    dQty3             5 0
640hA
640hAC                   eval      avail1 += dQty1
640hAC                   eval      avail2 += dQty2
640hAC                   eval      avail3 += dQty3
640hA
      *  Set negative quantities to zero

411 AC                   if        avail1 < 0
411 AC                   eval      avail1 = 0
411 AC                   endif
411 AC                   if        avail2 < 0
411 AC                   eval      avail2 = 0
411 AC                   endif
411 AC                   if        avail3 < 0
411 AC                   eval      avail3 = 0
411 AC                   endif
     C                   endsr

      *----------------------------------------------------------------
      *  avlRm  - Calculate available raw material in line and opn replen
      *----------------------------------------------------------------
      /free

          begsr avlrm;
         // read availabilty from selected MFG Line slot for quantity
                newqtyn = 0;
                newqty1 = 0;
                newqty2 = 0;
                newPrdq = 0;
710dM           chain ($ppWhse:$ppwhdp:%trim($sldisp)) slot2;
710dM           chain ($ppWhse:$slwhdp:%trim($sldisp)) slot2;
                if %found(slot2);
                   unlock slot2;
                   exsr avail;
                   newqtyn = newqtyn + avail1;
                   newqty1 = newqty1 + avail2;
                   newqty2 = newqty2 + avail3;
                   zzupqty();
                endif;

               // delete any processed Production Replenishments
               exec sql delete from prplfil
740 D               //where prrplt = 'D' and prflag = 'D';
740 M               where prrplt = 'O' and prflag = 'D';

          endsr;
      /end-free

      *----------------------------------------------------------------
      *  backFlush - Back Flush any raw materials identied for FG
      *----------------------------------------------------------------

     c     backFlush     begsr

      /free
         // Process Bill of Material records for given FG being produced.
         // This routine processes both Backflushed items (at time of PRoduction)
         // or non backflushed (not closed until End of Day)   `
         chain ($ppWhse:$ppITem) itemprd;
         if ($ppdest <> 'M' and $ppdest <> 'W' and not getmin);
730aD         //%subst($ppItem:1:3)='WIP';
730aA         //ipPrdFlg='C';
            rmadj = *on;
            ccyymmdd = %date();
            current_date = %dec(%char(ccyymmdd:*iso0):8:0);
            // get LIN aisle for raw material adjustments
            setll ($ppwhse) plined;
            reade ($ppwhse) plined;
            if not %equal(plined);
               $pprcva = 'LIN';
            else;
               $pprcva = inrcvaisl;
            endif;
            // loop through Raw Materials defined for given Production item
710cA       // change to read primarily from pWrkordR which is the work order
710cA       // delete file.  The procedure below (chkForSub) will find item in
710cA       // either pBom, pBomSub, or pBomVers depending on whether it is a
710cA       // original BOM raw material or substitute or dynamic bom
710cD    //   setll ($ppwhse:$ppitem) pbom;
710cD    //   reade ($ppwhse:$ppitem) pbom;
710cD    //   if %equal(pbom) and not %eof(pbom);
710cA       setll ($ppwhse:$ppwo#) pwrkOrdr;
710cA       reade ($ppwhse:$ppwo#) pwrkOrdr;
710cA       if not %eof(pwrkORdr);
               dow forever = forever;
710cD    //       if %eof(pbom);
710cA             if %eof(pwrkORdr);
                     leave;
                  endif;
710aA             // Process all items on the BOM for this Work Order.  If the
710cA             // bom entry is set to BackFlush it will go ahead and process
710cA             // adjustment against LIN slot, otherwise it will generate a
710cA             // usage record to be adjusted at End of Day.

710cA             // *** NOTE *** Items such as Cartons, trays, etc., can be setup
710cA             // on the BOM as a normal production raw material but unchecking as
710cA             // Production Specific.  This will simply flush the quantity from the
710cA             // BOM regardless of scale activity.

710cA             // The procedure chkForSub loads BOM fields with the appropriate
710cA             // data from either PBOM, PBOMSUB or PBOMVERS depending on whether
                  // this Work ORder is derived from an original PBOM, has at least
                  // one substitution or was generated as a Dynamic BOM.

710cA             if (wrstat <> 'D' and wrstat <> 'C');
710cA                chkForSub(wrwhse:wrwo#:writem:wrfgi:wrmfgno);
                     // ensure active bom and should be backflushed
                     if bmeffd<=current_date and bmexpd >=current_date;
                        if bmbckf = 'Y';
                           exsr adjustRM;
                           if $preturn = ' ' or
750aA                         $preturn='*OK';
                              exsr wrtRMUsage;
                           endif;
                        else;
710cA                      // comes here to create non backflushed raw materials in
710cA                      // pWrkORdRU.
                           exsr wrtRMUsage;
                        endif;
                     endif;
710cA             endif;
710cD     //      reade ($ppwhse:$ppitem) pbom;
710cA             reade ($ppwhse:$ppwo#) pwrkORdr;
               enddo;
            endif;
         endif;
         rmadj = *off;
710cA    setll (*loval) pWrkORdr;
      /end-free

     c                   endsr

730aA *----------------------------------------------------------------
730aA *  Calcneed  Used to determine need of specific raw material or
730aA *            component passed in for specific finished good and
730aA *            and component when adjusting quantities for new and
730aA *            updated work orders with multiple level calls
730aA *----------------------------------------------------------------
730aA
730aAC     calcneed      begsr
730aA /free
730aA
        // Delete and Negative adjustments
730eM    if $ppDel='Y' or (((pMakeQty*squmq2*squmq3)+(pMakeqty1*squmq3)
730eM                      + pMakeqty2) < 0
730eM              and bomXary(itmLoop)<>'X');
730aA       if %subst(bomIary(itmLoop):16:15) <> *blanks;
730aA          // item in positions 16 for 15 indicates a component is being
730aA          // delete by a value above in tree and therefore should only
730aA          // adjust with Work Order Dependent demand
               exsr gettotreq;
               if reqQtyn<>0 or reqQty1<>0 or reqQty2<>0;
730aA             skipbomext=*on;
730dA             bomGqty(itmLoop) = reqQtyn;
730dA             bomGqty1(itmLoop) = reqQty1;
730dA             bomGqty2(itmLoop) = reqQty2;
730dA             bomNqty(itmLoop) = reqQtyn;
730dA             bomNqty1(itmLoop) = reqQty1;
730dA             bomNqty2(itmLoop) = reqQty2;
730aA             bomXary(itmloop)='X';
730aA             pMakeQty=bomGqty(itmLoop);
730dA             pMakeQty1=bomGqty1(itmLoop);
730dA             pMakeQty2=bomGqty2(itmLoop);
               else;
730aA             skipbomext=*on;
730dA             bomGqty(itmLoop) = 0;
730dA             bomGqty1(itmLoop) = 0;
730dA             bomGqty2(itmLoop) = 0;
730dA             bomNqty(itmLoop) = 0;
730dA             bomNqty1(itmLoop) = 0;
730dA             bomNqty2(itmLoop) = 0;
                  $ppcnrm=0;
                  $ppcbd1=0;
                  $ppcbd2=0;
730aA             bomXary(itmloop)='X';
730aA             pMakeQty=bomGqty(itmLoop);
730dA             pMakeQty1=bomGqty1(itmLoop);
730dA             pMakeQty2=bomGqty2(itmLoop);
730aA          endif;
730aA       else;
730aA          // when no item present in position 16 for 15 then it means
730aA          // delete at top level and overrides are also on the table
               exsr gettotreq;
               if reqQtyn<>0 or reqQty1<>0 or reqQty2<>0;
730dA             bomGqty(itmLoop) = reqQtyn;
730dA             bomGqty1(itmLoop) = reqQty1;
730dA             bomGqty2(itmLoop) = reqQty2;
730dA             bomNqty(itmLoop) = reqQtyn;
730dA             bomNqty1(itmLoop) = reqQty1;
730dA             bomNqty2(itmLoop) = reqQty2;
730aA             bomXary(itmloop)='X';
730aA             pMakeQty=bomGqty(itmLoop);
730dA             pMakeQty1=bomGqty1(itmLoop);
730dA             pMakeQty2=bomGqty2(itmLoop);
               else;
730aA             skipbomext=*on;
730dA             bomGqty(itmLoop) = 0;
730dA             bomGqty1(itmLoop) = 0;
730dA             bomGqty2(itmLoop) = 0;
730dA             bomNqty(itmLoop) = 0;
730dA             bomNqty1(itmLoop) = 0;
730dA             bomNqty2(itmLoop) = 0;
                  $ppcnrm=0;
                  $ppcbd1=0;
                  $ppcbd2=0;
730aA             bomXary(itmloop)='X';
730aA             pMakeQty=bomGqty(itmLoop);
730dA             pMakeQty1=bomGqty1(itmLoop);
730dA             pMakeQty2=bomGqty2(itmLoop);
730aA          endif;
730aA       endif;
            // When higher level component is changed be sure to override
            // the next level quantity required with what was at that level
730aA       nxtLoop = itmLoop + 1;
730aA       dow nxtLoop < 499 and %trim(bomIary(nxtLoop))<>'';
730aA           if %subst(bomIary(nxtLoop):1:15) =
730aA              %subst(bomIary(itmLoop):16:15);
730aA             bomGqty(nxtLoop) = bomGqty(itmLoop);
730dA             bomGqty1(nxtLoop) = bomGqty1(itmLoop);
730dA             bomGqty2(nxtLoop) = bomGqty2(itmLoop);
730aA             bomNqty(nxtLoop) = bomNqty(itmLoop);
730dA             bomNqty1(nxtLoop) = bomNqty1(itmLoop);
730dA             bomNqty2(nxtLoop) = bomNqty2(nxtLoop);
730aA             bomXary(nxtLoop)='X';
730aA           endif;
730aA           nxtLoop = nxtLoop + 1;
730aA       enddo;
730aA    else;
730aA       // if been set with previous level use that quantity instead of starting level qty
            select;
730aA         when ($ppDel<>'Y' and
730dA            %abs((bomNQty(itmLoop)*squmq2*squmq3)+
730dA                 (bomNQty1(itmLoop)*squmq3)+bomNQty2(itmLoop))<
730dA            %abs((pMakeQty*squmq2*squmq3)+
730dA                 (pMAkeQty1*squmq3)+pMakeQty2))
                 or $ppdel='Y';
730aA           pMakeQty=bomNqty(itmLoop);
730aA           pMakeQty1=bomNqty1(itmLoop);
730aA           pMakeQty2=bomNqty2(itmLoop);
730aA       endsl;
730aA    endif;
        // End of Delete and Negative Adjustments
730aA
730aA    // if component passed in then get current total requirements when new work order.
730aA    // Reason for this would be where stock exists for certain amount and then you
730aA    // exceed stock and need to produce.  This is why it gets full demand versus only
730aA    // this one work order demand
730aA    if %subst(bomIary(itmLoop):16:15) <> *blanks and ($ppWo#='*NF'
KFSaD       //or ((pMakeQty*squmq2*squmq3)+(pMakeQty1*squmq3)+pMakeQty2)>0)
KFSaM       or ((pMakeQty*squmq2*squmq3)+(pMakeQty1*squmq3)+pMakeQty2)<>0)
730dA       and $ppDel<>'Y';
730aA       pWo# = $ppWo#;
730aA       exsr gettotreq;
730aA       $ppWo# = pWo#;
730aA       if reqQtyn <> *zeros or reqQty1<>0 or reqQty2<>0;
730aA          // when gettotreq returns non zero that means there was negative inventory
730aA          // available.  Therefore, we take the absolute value as our need.  Otherwise,
730aA          // it returns zero since current stock covers need
730bA          skipbomext=*on;
730aA          bomGqty(itmLoop) = reqQtyn;
730aA          bomGqty1(itmLoop) = reqQty1;
730aA          bomGqty2(itmLoop) = reqQty2;
730aA          bomNqty(itmLoop) = reqQtyn;
730aA          bomNqty1(itmLoop) = reqQty1;
730aA          bomNqty2(itmLoop) = reqQty2;
730aA          pMakeQty = reqQtyn;
730aA          pMakeQty1 = reqQty1;
730aA          pMakeQty2 = reqQty2;
730aA          $ppQty1=reqQtyn;
730aA          $ppQty2=reqQty1;
730aA          $ppQty3=reqQty2;
730aA          nxtLoop = itmLoop + 1;
730aA          dow nxtLoop < 499 and %trim(bomIary(nxtLoop))<>'';
730aA              if %subst(bomIary(nxtLoop):1:15) =
730aA                 %subst(bomIary(itmLoop):16:15);
730aA                 bomGqty(nxtLoop) = reqQtyn;
730aA                 bomGqty1(nxtLoop) = reqQty1;
730aA                 bomGqty2(nxtLoop) = reqQty2;
730aA                 bomNqty(nxtLoop) = reqQtyn;
730aA                 bomNqty1(nxtLoop) = reqQty1;
730aA                 bomNqty2(nxtLoop) = reqQty2;
730aA              endif;
730aA              nxtLoop = nxtLoop + 1;
730aA          enddo;
            else;
730aA          pMakeQty=0;
730aA          pMakeQty1=0;
730aA          pMakeQty2=0;
730aA          $ppQty1=*zeros;
730aA          $ppQty2=*zeros;
730aA          $ppQty3=*zeros;
730aA          $ppmake=0;
730dA          $ppmake1=0;
730dA          $ppmake2=0;
730aA           // since stock exist for this component we should
730aA           // loop through remaining blow thru array of this
730aA           // bom and remove any items that are called by
730aA           // this item since stock exists
730aA           nxtLoop = itmLoop + 1;
730aA           dow nxtLoop < 499 and %trim(bomIary(nxtLoop))<>'';
730aA              if %subst(bomIary(nxtLoop):1:15) =
730aA                 %subst(bomIary(itmLoop):16:15);
730aA                 bomIary(nxtLoop) = bomIary(nxtLoop+1);
730aA                 bomNqty(nxtLoop) = 0;
730aA                 bomNqty1(nxtLoop) = 0;
730aA                 bomNqty2(nxtLoop) = 0;
730aA                 bomGqty(nxtLoop) = 0;
730aA                 bomGqty1(nxtLoop) = 0;
730aA                 bomGqty2(nxtLoop) = 0;
730aA              endif;
730aA              nxtLoop = nxtLoop + 1;
730aA           enddo;
730aA           leavesr;
730aA       endif;
730aA    endif;
730aA    // get available stock and reduce need if stock exist when an add
730aA    // 2252019 - May need to pull some of this block back from 225 DRIPROD copy
730aA    // calc need considering inventory from above
730aA    if %subst($pprogram:1:6)='M16500'
730aA       or %subst($pprogram:1:6)='M16400'
730aA       or %subst($pprogram:1:6)='LT120A'
730aA       or %subst($pprogram:1:5)='RH134'
730aA       or %subst($pprogram:1:5)='OR610';
730aA       $ppitem  = %subst(bomIary(itmLoop):1:15);
730aA       $ppToLcns = %subst(bomIary(itmLoop):16:15);
730aA       $ppQty1 = pMakeQty;
730aA       $ppQty2 = pMakeqty1;
730aA       $ppQty3=pMakeqty2;
730aA    endif;
730aA
730aA    // extend and rollup adjusted quantity times defined need per bom
730aA    // get bill and scrap information from bom level file
730aA    // Specific Component is passed in field $ppToLcns for this command
730aA
730aA    chain ($ppWhse:$ppItem:$ppToLcns) pBomLvlItm;
730aA    if %found(pBomLvlItm);
730aA
730aA       chain ($ppwhse:$pptoLcns) piritem;
730aA       if %found(piritem);
730aA          squmq2=itumq2;
730aA          squmq3=itumq3;
730aA       else;
730aA          squmq2=1;
730aA          squmq3=1;
730aA       endif;
730aA
730aA          // Get eqivalent case quantity with projected waste
730aA          if not skipbomext and $ppDel<>'Y';
730aA             // Extend Case Quantity needed by Recipe
730aA             newQtyn = ($ppQty1 * bmqtyn);
730aA             newQty1 = ($ppQty1 * bmqty1);
730aA             newQty2 = ($ppQty1 * bmQty2);
730aA             // Extend Brk1 Quantity needed by Recipe
730aA             newQty1 = newQty1 + ($ppQty2 * bmqty1);
730aA             newQty2 = newQty2 + ($ppQty2 * bmQty2);
730aA             // Extend Brk2 Quantity needed by Recipe
730aA             newQty2 = newQty2 + ($ppQty3 * bmQty2);
730dA             // Calculate Production UOM using factor
730dA             // Full case requests should simply add with waste factor
730dA             newPrdQ = ($ppQty1 * bmprdq);
730dA             select;
730dA               // Added Productions cases before select.  Now determine
730dA               // what percentage partials are to the full case and add
730dA               // that quantity to Production UOM required
730dA               when squmq3>1;
730dA                 // get factor for patrial case
730dA                 result = (($ppQty2*squmq3)+$ppQty3)/
730dA                                (squmq2*squmq3);
730dA                 newPrdq = newPrdq + (bmprdq*result);
730dA               when squmq2>1;
730dA                 // get factor for patrial case
730dA                 result = $ppQty2/squmq2;
730dA                 newPrdq = newPrdq + (bmprdq*result);
730dA             endsl;
730aA             // Add waste
KFSaD             //newQtyn = newQtyn / (1-bmscrf);
KFSaD             //newQty1 = newQty1 / (1-bmscrf);
KFSaD             //newQty2 = newQty2 / (1-bmscrf);
KFSaD             //newPrdq = newPrdq / (1-bmscrf);
KFSaM             newQtyn = newQtyn * (1+bmscrf);
KFSaM             newQty1 = newQty1 * (1+bmscrf);
730aA             newQty2 = newQty2 * (1+bmscrf);
730aA             newPrdq = newPrdq * (1+bmscrf);
730AA          else;
730aA             newQtyn = $ppQty1;
730aA             newQty1 = $ppQty2;
730aA             newQty2 = $ppQty3;
730aA             newPrdq = 0;
730aA          endif;
730aA
               if newPrdq<>0;
730aA            total_Prdq = newPrdq;
                 if %subst(bomIary(itmLoop):16:15) <> *blanks;
                    $ppItem = %subst(bomIary(itmLoop):16:15);
                 endif;
730eA            prdItem=$ppitem;
730eA            total_prdq=newPrdq;
730aA            exsr prdQtyConv;
                 if %subst(bomIary(itmLoop):16:15) <> *blanks;
                    $ppitem  = %subst(bomIary(itmLoop):1:15);
                 endif;
               endif;
730aA          // up lowest level quantity to highest levels
730aA          zzupqty();
730aA
730aA          $ppQty1 = newQtyn;
730aA          $ppQty2 = newQty1;
730aA          $ppQty3 = newQty2;
730aA      else;
730aA         $ppQty1=*zeros;
730aA         $ppQty2=*zeros;
730aA         $ppQty3=*zeros;
730aA      endif;
730aA
730aA    if %subst($pprogram:1:6)='M16500'
730aA       or %subst($pprogram:1:6)='M16400'
730aA       or %subst($pprogram:1:6)='LT120A'
730aA       or %subst($pprogram:1:5)='RH134'
730aA       or %subst($pprogram:1:5)='OR610';
730aA       $ppitem  = %subst(bomIary(itmLoop):16:15);
730aA       $ppToLcns = *blanks;
730aA    endif;
730aA
730aA /end-free
730aAC                   endsr

730aA *----------------------------------------------------------------
730aA *  chkAvail  Check for available active or Production stock before
730aA *            creating new Work Order
730aA *
730aA *    ***  This was moved from CRTSUGG routine so it could be called
730aA *         from both CRTSUGG and UPDLOOP.  UPDLOOP not only adds and
730aA *         updates the items you send but also confirms all components
730aA *         have the necessary stock to fulfill the request
730aA *----------------------------------------------------------------
730aA
730aAC     chkAvail      begsr
730aA /free
730aA                    invAvail=0;
730aA                    setll ($ppwhse:$ppitem) slot3;
730aA                    reade ($ppwhse:$ppitem) slot3;
730aA
730aA                    dow not %eof(slot3) and %equal(slot3);
730aA                       if $ppneed < 0;
730aA                          setll (*loval) slot3;
730aA                          $ppneed = 0;
730aA                          //leave;
730aA                       endif;
730aA                       if (slaisl = 'PAR' and slstat='PR')
730aA                          or (slaisl = 'LIN' and slstat='PR')
730aA                          or slstat = 'A';
730aA                          if sldesg <> 'BFC';
730aA                             exsr avail;
730aA                             invAvail = invAvail + avail1;
730aA                             $ppneed = $ppneed - avail1;
730aA                             if $ppneed < 0;
730aA                                setll (*loval) slot3;
730aA                                $ppneed = 0;
730aA                                //leave;
730aA                             endif;
730aA                          endif;
730aA                       endif;
730aA                       reade ($ppwhse:$ppitem) slot3;
730aA                    enddo;
730aA                    setll (*loval) slot3;
730aA /end-free
730aAc                   endsr

      *----------------------------------------------------------------
      *  chkforwor  Check to see if WO exist and return if found
      *   Added code after basic part of this command to handle new
      *   multi-level boms
      *----------------------------------------------------------------

     C     chkForWo      begsr
      /free

730bA     skipbomext=*off;
          woFound = *off;
          // check to see if a Work Order already exists for the
          // specific item, mfg line and customer or WO.  If one exists
          // this process will return the Work Order number in $ppwo#,
          // otherwise it will return *NF for not found
          setll ($ppwhse:$ppitem) pwrkord1;
          reade ($ppwhse:$ppitem) pwrkord1;

          dow not %eof(pwrkord1) and %equal(pwrkord1);
             // if same destination, customer, and mfg line
             // work order exists then update existing work
             // order instead of generating an addtional work order
             // also update if wo passed and match found
             if (%subst(%trim($ppSessId):1:5) = 'RH134'
                or %subst(%trim($ppSessId):1:5) = 'OR610');
               // when coming from the customer order process
               // (OR610) or the unallocate route program (RH134)
               // you will want to find a Work Order if it exists
               // for that one customer/customer po work order.  It
               // will only create one work order for that combination
                if l_wotype = $ppDest and l_wocust = $ppcust
                // and l_wocpo = $ppCustWo and l_wostat<>'C'
                   and l_wostat<>'C'
                   and l_wostat<>'D';
                   woFound = *on;
                   unlock pwrkord1;
                   leave;
                endif;
             else;
               // M16400F or M16500 will come here.  Both these screens
               // send all the key information so you either get a match
               // or send back not found
                if (l_wotype = $ppDest and l_wocust = $ppcust
                   and l_womfgno = $ppLneno) or l_wowo# = $ppWo#
                // and l_wocpo = $ppCustWo and l_wostat<>'C'
                   and (l_womfgno = $ppLneno or (l_womfgno <> $ppLneno
                        and l_wowo# = $ppWo#))
                   and l_wostat<>'C'
                   and l_wostat<>'D';
                   unlock pWrkOrd1;
                   woFound = *on;
                   leave;
                endif;
             endif;
             reade ($ppwhse:$ppitem) pwrkord1;
          enddo;

          // if found return work order number, otherwise return not found
          if woFound;
             $ppWo# = l_wowo#;
             pWo# = l_wowo#;
             $pplneno = l_womfgno;
             $ppprio = l_woprio;
             $ppcustwo = l_wocustwo;
             $ppcord = l_wocord;
             $ppcust = l_wocust;
             $ppdest = l_wotype;
             $pporig = l_woorig;
             $ppitem = l_woitem;
             $ppdmdq = l_wodmdq;
             $ppavlq = l_woavlq;
             $ppneed = l_woneed;
             $ppmake = l_womake;
             $ppmake1 = l_womake1;
             $ppmake2 = l_womake2;
             $ppqtyp = l_woqtyp;
             $pprmavl = l_wormavl;
             $ppstat = l_wostat;
             $ppcnrm = l_wocnrm;      // pulls back current Case Quantity required by WO demand
             $ppcbd1 = l_wocbd1;      // pulls back current breakdown Quantity required
             $ppcbd2 = l_wocbd2;
             $ppovrd = l_woovrd;
             $ppovr1 = l_woovr1;
             $ppovr2 = l_woovr2;
          else;
730dA        $ppcnrm = *zeros;
             $ppcbd1 = *zeros;
             $ppcbd2 = *zeros;
             $ppovrd = *zeros;
             $ppovr1 = *zeros;
             $ppovr2 = *zeros;
             $ppMake=*zeros;
730dA        $ppMake1=*zeros;
730dA        $ppMake2=*zeros;
             $ppWo# = '*NF';
          endif;
730aA
730aA      // New multi-leel code added below this line to end of subroutine
730aA
         allowUpdate=*on;
730aA    if $pSubCmd<>'*CHKFORWO';
730aA     if $ppWo#<>'*NF';
730aA        if %subst(bomIary(itmLoop):16:15) <> *blanks;
730aA           // if component calculate need adjustment from parent adjustment
                // positions 1-15 are calling finished good or component
                // positions 16-30 would be the component.  If blank it means
                // that level is what started the call.  When blank ONLY the
                // override quantities are impacted since someone is manually
                // changing quantity at that call level
730aA           exsr calcNeed;
730aA           totalOpenWOQty = reMainingQty($ppcbd1:$ppcbd2:$ppcnrm);
730aA           totalAdjustQty = adjustQtyprc($ppQty1:$ppQty2:$ppQty3);
730aA           totalWOOnlyQty = woOnlyDmd($ppcnrm:$ppcbd1:$ppcbd2);
730aA           if totalAdjustQty > 0;
                   sumTwoGroups('$ppcnrm':'+':$ppcnrm:$ppcbd1:$ppcbd2
                                             :$ppQty1:$ppQty2:$ppqty3);
730aA              if adjustQtyPrc($ppcnrm:$ppcbd1:$ppcbd2) >
                            splitQty(smreqq);
730aA                 // if additions have added extra rounding in actual
730aA                 // breakdowns required we should adjust so quantities
730aA                 // are properly accounted for as quantities are added.
730aA                 // SMREQQ comes from PRMSUM which is generated by R130002
730aA                 // to determine proper requirements.  Gets started in
730aA                 // GETTOTREQ. Procedure splitQty puts quantities in
730aA                 // in globally defined fields so can be used in either.
730dA                 $ppcnrm=wrkQtyn;
730aA                 $ppcbd1=wrkQty1;
730aA                 $ppcbd2=wrkQty2;
730aA              endif;
730dA              $ppQty1=0;
730aA              $ppQty2=0;
730aA              $ppQty3=0;
730aA              totalAdjustQty = 0;
                   //zero in make quantities will result in calculating make
                   // quantities via cnrm, cbd1, and cbd2 along with ovrd, ovr1, ovr2
730aA              pmake=0;
730aA              pmake1=0;
730aA              pmake2=0;
730aA           else;
                   if $ppstat<>'O' and $ppstat<>'P' and $ppstat<>'S';
                      // if Work Order is no longer in planning status
                      // you cannot reduce quantity or delete.  If you choose
                      // to close early you must do so via the Work Order
                      // Managment screen.  At this point we know we are trying
                      // to reduce or delete the Work Order.
                      allowUpdate=*off;
                      leavesr;
                   endif;
730aA              // now for either a Delete or reduction of Work Order
730aA              if %abs(totalAdjustQty)<
730aA                      adjustQtyprc($ppcnrm:$ppcbd1:$ppcbd2);
                      if totalAdjustQty=0;
                         // if total adjustment is zero skip
                         // adjustments.
                      else;
730aA                    // When total Adjustment is less than or equal
730aA                    // to the Work Order Demand quantity then simply
730aA                    // convert and clear the Total Adjustment
730aA                    getCorrectQty();
                         sumTwoGroups('$ppcnrm':'+':$ppcnrm:$ppcbd1:$ppcbd2
                                                   :$ppQty1:$ppQty2:$ppqty3);
                         if $ppdel='Y';
730aA                      exsr gettotreq;     // confirm proper qty based on remaining
                           if splitQty(smrmdq) < 0;
                              // if remaining quantity falls below zero we should show that absolute
                              // value as remaining, otherwise nothing is required
                              sumTwoGroups('$ppcnrm':'-':%abs(wrkQtyn)
                                                        :%abs(wrkQty1)
                                                        :%abs(wrkQty2)
                                                   :$ppovrd:$ppovr1:$ppovr2);
                           endif;
                         endif;
                      endif;
730aA                 if adjustQtyprc($ppcnrm:$ppcbd1:$ppcbd2) = 0;
730aA                    pMake =$ppovrd;
730dA                    pMake1=$ppovr1;
730dA                    pMake2=$ppovr2;
730aA                 else;
730aA                    // by forcing zero on pMake updprodwo will use combo
730aA                    // of $ppovrd and $ppcbd1 and 2 to determine wo qty
                         // by getting here it has ben decided the adjustment
                         // quantity is zero.  We should call gettotreq to
                         // confirm whether work order demand exist.  If not
                         // we should also zero work order demand fields
                         if $ppdel<>'Y';
                            exsr gettotreq;
                            if adjustQtyprc(reqQtyn:reqQty1:reqQty2) = 0;
                               $ppcnrm=0;
                               $ppcbd1=0;
                               $ppcbd2=0;
                            endif;
                         endif;
730aA                    pMake =0;
730dA                    pMake1=0;
730dA                    pMake2=0;
730aA                 endif;
730aA              else;
730aA                 // Otherwise the totalAdjustmentQty is greater than
730aA                 // just the Work Order Demand.  We should reduce Work
730aA                 // Order demand and then reduce remainder from Overrides
                      if totalAdjustQty<0;
730aA                    totalAdjustQty = totalAdjustQty +
730aA                          adjustQtyprc($ppcnrm:$ppcbd1:$ppcbd2);
                      else;
730aA                    totalAdjustQty = totalAdjustQty -
730aA                          adjustQtyprc($ppcnrm:$ppcbd1:$ppcbd2);
                      endif;
                      // substract normal work order demand from transaction
                      // quantity leaving only override quantity
                      // I do not think it will typically come past here with
                      // a non zero value in totalAdjustQty because you are
                      // only allowed to remove manual overrides manually as
                      // you manually applied.  Have code here in case something
                      // goes wrong it will handle to some extent
                      sumTwoGroups('$ppqty1':'-':$ppqty1:$ppqty2:$ppqty3
                                                :$ppcnrm:$ppcbd1:$ppcbd2);
730aA                 $ppcbd1=0;
730aA                 $ppcbd2=0;
730aA                 $ppcnrm=0;
730aA                 if %abs(totalAdjustQty) > *zeros;
730aA                    // after subtracting work order demand we should
730aA                    // reduce override quantity with remainder
                         sumTwoGroups('pmake':'+':woMake
                                                 :woMake1
                                                 :woMake2
                                              :$ppQty1:$ppQty2:$ppQty3);
                         sumTwoGroups('$ppovrd':'+':$ppovrd
                                                   :$ppovr1
                                                   :$ppovr2
                                              :$ppQty1:$ppQty2:$ppQty3);
730aA                 else;
730aA                    if $ppovrd > 0 or $ppovr1>0 or $ppovr2>0;
730aA                       pMake = $ppovrd;
730dA                       pMake1 =$ppovr1;
730dA                       pMake2 =$ppovr2;
730aA                    else;
730aA                       pMake = 0;
730dA                       pMake1 = 0;
730dA                       pMake1 = 0;
730aA                    endif;
730aA                 endif;
730aA              endif;
730aA           endif;
730aA        else;
                if $ppstat<>'O' and $ppstat<>'P' and $ppstat<>'S'
                  and ((pMakeqty*squmq2*squmq3)+(pMAkeqty1*squmq3)+pMakeqty2)<0;
                   // if Work Order is no longer in planning status
                   // you cannot reduce quantity or delete.  If you choose
                   // to close early you must do so via the Work Order
                   // Managment screen once order is released.
                   allowUpdate=*off;
                   leavesr;
                endif;
730aA           // when getting here it means the user us manually
730aA           // overriding a quantity for a component.  Since no
730aA           // specific demand exists to support this quantity
730aA           // we place it in a manual override quantity so it will
730aA           // be considered when other changes occur
730aA           if ipPrdFlg='C' and
                   ((pMakeqty*squmq2*squmq3)+(pMAkeqty1*squmq3)+pMakeqty2)<>0;
730aA              if ((pMakeqty*squmq2*squmq3)+(pMAkeqty1*squmq3)+pMakeqty2 +
                     // add breakdown overrides once added to pwrkord and c#prod
730aA                  ($ppovrd*squmq2*squmq3)+($ppovr1*squmq3)+$ppovr2) >= 0;
                      sumTwoGroups('$ppovrd':'+':$ppovrd
                                                :$ppovr1
                                                :$ppovr2
                                           :pMakeQty:pMakeQty1:pMakeQty2);
730aA              else;
730aA                 // force 0 to make no change and return error that
730aA                 // will show on line since manual override goes
730aA                 // beyond the manual overrides performed and gets
730aA                 // into the actual demand from other work orders
730aA                 if $ppDel='Y' or $ppDel='X';
730aA                    // Proper Message returned later in stream
                         exsr gettotreq;
                         if reqQtyn>0 or reqQty1>0 or reqQty2>0;
730aA                       $pMessage = 'Cannot delete.  Used by ' +
730aA                              'other Work Orders';
                            sumTwoGroups('pmake':'-':pMake
                                                    :pMake1
                                                    :pMake2
                                                 :pMakeQty:pMakeQty1:pMakeQty2);
730aA                       leavesr;
                         endif;
730aA                 else;
730aA                    $pMessage = 'Adjust Qty of (' +
730aA                           %trim(%editc(pMakeQty:'3'));
                                if squmq2>1;
                                  $pMessage = %trim($pMessage) + '.' +
730aA                               %trim(%editc(pMakeQty1:'3'));
                                endif;
                                if squmq3>1;
                                  $pMessage = %trim($pMessage) +  '.' +
730aA                             %trim(%editc(pMakeQty2:'3'));
                                endif;
                                $pMessage = %trim($pMessage) + ')' +
730aA                           ' exceeds manual overrides of (' +
730aA                           %trim(%editc($ppovrd:'3'));
                                if squmq2>1;
                                  $pMessage = %trim($pMessage) + '.' +
730aA                               %trim(%editc($ppovr1:'3'));
                                endif;
                                if squmq3>1;
                                  $pMessage = %trim($pMessage) +  '.' +
730aA                             %trim(%editc($ppovr2:'3'));
                                endif;
                                $pMessage = %trim($pMessage) + ')';
                          sumTwoGroups('pmake':'-':pMake
                                                  :pMake1
                                                  :pMake2
                                               :pMakeQty:pMakeQty1:pMakeQty2);
730aA                    leavesr;
730aA                 endif;
730aA              endif;
730aA           else;
730aA              // Make sure override demand is updated for top level
730aA              if ((pMakeQty*squmq2*squmq3) + (pMAkeQty1*squmq3) +
                        pMakeQty2)<>0;
                        sumTwoGroups('$ppovrd':'+':$ppovrd
                                                  :$ppovr1
                                                  :$ppovr2
                                             :pMakeQty:pMakeQty1:pMakeQty2);
730aA              endif;
730aA           endif;
730aA        endif;
730aA     else;
730aA        // Else to *NF from M16400F
730aA        if $ppDel<>'Y';   // No deletes since Work Order not exist
730aA           if %subst(bomIary(itmLoop):16:15) <> *blanks;
730aA              exsr calcNeed;
730aA              // Calcneed calculates the net difference needed for whatever
730aA              // Quantity is being added.  We send this quantity to store in
730aA              // Work Order record (PWRKORD) so we can easily adjust with
730aA              // adjustments during the life of the Work Order
                   sumTwoGroups('$ppcnrm':'+':$ppcnrm
                                             :$ppcbd1
                                             :$ppcbd2
                                        :$ppQty1:$ppQty2:$ppQty3);
730aA              $ppMake = *zeros;
730aA              $ppMake1 = *zeros;
730aA              $ppMake2 = *zeros;
730aA           else;
730aA              // otherwise we are adding top level
730aA              // item and should simply modify the
730aA              // make quantity per screen entry
730aA              // along with unsupported demand value.
730aA              // Sum of work order demand and unsupported
730aA              // demand should always balance to what is
730aA              // open
730aA              monitor;
                     sumTwoGroups('$ppovrd':'+':$ppovrd
                                               :$ppovr1
                                               :$ppovr2
                                          :pMakeQty:pMakeQty1:pMakeQty2);
730aA              on-error;
730aA              endmon;
730aA              monitor;
                     sumTwoGroups('$ppmake':'+':$ppMake
                                               :$ppMake1
                                               :$ppMake2
                                          :pMakeQty:pMakeQty1:pMakeQty2);
730aA              on-error;
730aA              endmon;
730aA           endif;
730aA        endif;
730aA     endif;
730aA    endif;
730aA
      /end-free
     C                   endsr

      *----------------------------------------------------------------
      *  closeWo  Close Work Order Header and Requirements
      *----------------------------------------------------------------

     C     closeWo       begsr
      /free

          chain ($ppWhse:$ppWo#) pWrkOrd;
          if %found(pWrkOrd);
             // loop through Raw Material requirements and close status
             setll ($ppWhse:$ppWo#) pWrkOrdr;
             reade ($ppWhse:$ppWo#) pWrkordr;
             dow not %eof(pWrkOrdr) and %equal(pwrkordr);
                wrstat = 'C';
                update wrrec; // mark work order requirements deleted
                reade ($ppWhse:$ppWo#) pWrkordr;
             enddo;
             wostat = 'C';
             update worec;   // mark work order header as deleted
          endif;

      /end-free
     C                   endsr

710 A *----------------------------------------------------------------
710 A *  confirmPS  Create or update pWrkordPS.  This file represents
710 A *             Primal and SubPrimal associated to BOM line
710 A *----------------------------------------------------------------
710 A
710 Ac     confirmPS     begsr
710 A /free
710 A         // Read Primal/SubPRimal definitions from ITEMPRDPS
710 A         // and write to pWrkORdPS per the Work ORder
710 A         setll (bmwhse:bmfgi:$ppLneno:bmrmi:$ppPRim:$ppSubPRim) itemprdps;
710 A         reade (bmwhse:bmfgi:$ppLneno:bmrmi:$ppPRim:$ppSubPRim) itemprdps;
710 A
710 A         // delete old pWrkORdps record
710 A          exec sql delete from pwrkordps
710 A                   where pswhse=:$ppWhse and pswo# = :$ppwo# and
710 A                         psItem=:bmfgi and psRMI=:bmrmi;
710 A            //           psItem=:bmfgi and psLine=:$ppLneno and
710 A           //            psRmi=:bmrmi;
710 A
710 A         dow not %eof(itemprdps);
710 A            if $ppPrimary = 'P' and isPRimary = 'Y';
710 A               // Primary was requested and we are setting on Primary to add
710 A               leave;
710 A            else;
710 A               // convert sequence and check for it
710 A               monitor;
710 A               wkseq = %len(%trim($ppPrimary));
710 A               select;
710 A                  when wkseq = 1;    // length of sequence
710 A                     $ppPrimary = '00' + %trim($ppPRimary);
710 A                  when wkseq = 2;    // length of sequence
710 A                     $ppPrimary = '0' + %trim($ppPRimary);
710 A                  when wkseq = 3;   // length of sequence
710 A               endsl;
710 A               wkseq = %dec($ppPrimary:3:0);
710 A               on-error 105;
710 A                  wkseq = 0;
710 A                  $pMessage = 'SubPrimal Sequence did not convert '
710 A                           + 'properly';
710 A                  error = *on;
710 A                  leavesr;
710 A               endmon;
710 A               // specific alternate was requested and we read until found
710 A            endif;
710 A            // above several statements wkseq has the proper numeric
710 A            // sequence passed from MRC.  Once this record is found we
710 A            // exit and write to pWrkordps.  If not found we either exit
710 A            // routine with error or do not write pwrkordps
710 A            if isseq = wkSeq;
710 A               leave;
710 A            endif;
710 A            reade (bmwhse:bmfgi:$ppLneno:bmrmi:
710 A                   $ppPRim:$ppSubPRim) itemprdps;
710 A         enddo;
710 A
710 A         if not %eof(itemprdps);
710 A               pswhse = iswhse;
710 A               pswo# = wowo#;
710 A               psitem = isitem;
710 A               psline = $ppLneno;
710 A               psrmi = subUsed;  // use instead isrmi.  could be subtitute
710 A               pspcde = ispcde;
710 A               psscde = isscde;
710 A               psseq = isseq;
710 A               write psrec;
710 A         endif;
710 A
710 A /end-free
710 Ac                   endsr

      *----------------------------------------------------------------
      *  convertCBD  Convert Component Breakdown Quantities to Cases
      *----------------------------------------------------------------

     C     convertCBD    begsr
      /free
             if ($ppMake = *zeros and $ppMake1=0 and $ppMake2=0) and
                ($ppcbd1<>0 or $ppcbd2<>0 or $ppovrd<>0 or $ppcnrm<>0
                or $ppovr1<>0 or $ppovr2<>0);

                sumTwoGroups('$ppmake':'+':$ppcnrm:$ppcbd1:$ppcbd2
                                          :$ppovrd:$ppovr1:$ppovr2);

             endif;
      /end-free
     c                   endsr

      *----------------------------------------------------------------
      *  crtProdWo  Create Prodcution Work Order
      *----------------------------------------------------------------

     C     crtProdWo     begsr
      /free

             // return without adding if nothing to add
             if $ppMake=0 and $ppovrd=0 and $ppcbd1=0 and $ppcbd2=0
730dA           and $ppcnrm=0 and $ppMake1=0 and $ppMake2=0 and
                $ppovr1=0 and $ppovr2=0;
                leavesr;
             endif;

730aA        exsr convertCBD;
710fA        // if MultiDay Line requested we should first find
710fA        // an available line and add one if necessary
710fA        if $ppMultiDy = 'Y';
710fA           exsr MultiDayLine;
710fA        endif;

KFSaA        if client = Kellys;
KFSaA          //if $ppMake1 <> 0 or $ppMake2 <> 0;
KFSaA          //  $ppMake = $ppMake + 1;
KFSaA          //  $ppMake1=0;
KFSaA          //  $ppMake2=0;
KFSaA          //endif;
KFSaA        endif;

730dM        netdifn = $ppMake;
730dA        netdif1 = $ppMake1;
730dA        netdif2 = $ppMake2;

             if $psubcmd <> '*AVGPRD' and $psubcmd <>'*PRDQTY';
                wkwo# = $ppwo#;
                wkstat = 'O';
                // get available inventory
                avl1=0;
                avl2=0;
                avl3=0;
                setll ($ppWhse:$ppitem) slot3;
                reade ($ppWhse:$ppitem) slot3;
                dow not %eof(slot3) and %equal(slot3);
                   if slstat = 'A ';
                      exsr avail;  // add to available stock from warehouse
                      avl1 += avail1;
                      avl2 += avail2;
                      avl3 += avail3;
                   endif;
                   reade ($ppWhse:$ppitem) slot3;
                enddo;
             endif;

             // All Quantity fields other than Make Quantity will only be
             // reported in Full Case values.  Therefore, when breakdowns
             // are sent for Make Quantities need and demand will be zero
             womake = $ppMake;
             womake1 = $ppMake1;
             womake2 = $ppMake2;
             woavlq = avl1;
             wodmdq = avl1 + $ppMake;
             woneed = avl1 - $ppMake;
             if woneed > 0;
                woneed = 0;
             else;
                woneed = %abs(woneed);
             endif;

             wowo# = wkwo#;
             wowhse = $ppwhse;
             woitem = $ppitem;
             wotype = $ppdest;
             wocust = $ppcust;
             woCustWo = $ppCustWo;
             // currently not writing but one record per customer/item
             // but we pass in Customer Order to write to XREF.  At some
             // point we might decide to write in key, but now just zero
             woCord = 0;
             womfgno = $pplneno;
             woorig = $pporig;
             woprio = $ppprio;
             woqtyp = 0;
             woqtys = 0;
             wostat = $ppstat;
             wormavl = $pprmavl;
             wodtetim = %char(%date():*iso0) + %char(%time():*hms0);
730dA        wocnrm=$ppcnrm;
730aA        wocbd1=$ppcbd1;
730aA        wocbd2=$ppcbd2;
730aA        woovrd = $ppovrd;
730dA        woovr1 = $ppovr1;
730dA        woovr2 = $ppovr2;
             chain ($ppwhse:$ppwo#) pwrkord;
             if %found(pWrkOrd);
                exsr getnxtpwo;
                wowo# = wkwo#;
             endif;
730aA
730aA        // if coming from automated process and not main item as called
730aA        // we should default in Production Message
730aA        if $pSubCmd = '*UPDLOOP';
                woButchMsg=*blanks;
730aA           if %subst(bomIary(itmLoop):16:15)<>*blanks and
730aA              %subst(bomIary(itmLoop):16:15)=woitem;
730aA              // add Production Message if one exist
730aA              chain (wowhse:woitem) pBomi;
730aA              if %found(pBomi);
730aA                 woButchMsg = biInst;
730aA              endif;
730aA           endif;
730aA        endif;
730aA
730dA        // setup item master uom info to be used for life of work order
730dA        woum1=itum1;
730dA        woum2=itum2;
730dA        woum3=itum3;
730dA        woumq2=itumq2;
730dA        woumq3=itumq3;
             write worec;
             newWorkOrder = *on;
             exsr updRmWork;

      /end-free
     C                   endsr

      *----------------------------------------------------------------
      *  crtprdslt   Create production slots
      *----------------------------------------------------------------

     C     crtprdslt     begsr

     C                   eval      error = *off
710dAc                   eval      sltExp = *zeros
710dAc                   eval      sltEnt = *zeros
730gAc                   eval      $driReturn = *blanks
730gAc*
730gAc*   "Do Until" enters loop first time.  If $driReturn failed in getting
730gAc*   a Virtual it basically adds one to the starting slot location
730gAc*   which typically is 101 until it finds an available virtual.  Routine
730gAc*   getPrdSlot sets the starting location by looking to see if an existing
730gAc*   production slot exists for the specified warehouse, department, Aisle,
730gAc*   and item.  As can be seen below if the call to DRISLOT using CRTPROD
730gAc*   or CRTPRODC returns with no virtual error it will add one to the nxtLoc
730gAc*   variable, call plinem to ensure base slot exist and then try that base.
730gAc*   It stays in this loop until it either finds an available virtual or finds
730gAc*   nothing through location 999 and then fails with error. That allows for
730gAc*   roughly 630,000 virtuals for each warehouse/department/Aisle/Level.  Aisle
730gAc*   is the LIN (Raw Materials), PRD (Customer Specific), PAR (Par Stock), and
730gAc*   WIP (Wip) and Level represents each line setup in file PLINED.  This should
730gAc*   prevent us from ever running out of virtuals for Production slots.
730gAc*
730gAc                   dou       $driReturn = *blanks or
730gAc                             $driReturn = '*OK' or
730gAc                             $driReturn = 'INSLOT'
730gAc*
730gAc                   if        $driReturn <> *blanks
730gAc                   eval      $driReturn = *blanks
730gAc                   select
730gAc                   when      nxtLoc < 999
730gAc                   eval      nxtLoc = nxtLoc + 1
730gAc                   other
730gAc*    Once all locations have been exhausted for specific level fail
730gAC                   eval      $preturn = 'VRTNOTALWU'
730gAC                   eval      $pmessage = 'No Virtual Slots Available'
730gAc                   goto      endcrtprdslt
730gAc                   endsl
730gAc*
730gAc*
730gAc                   eval      $sldisp = %trim($slaisl) + '-' +
730gAc                               %char(nxtLoc) + '-' + %char($ppLneno)
730gAc                   eval      $slloc = nxtLoc
730gAc*    call process to ensure base slot exists for this locaton
730gA /free
730gA                    wkLneno = $ppLneno;
730gA                    bkwhse=$slwhse;
730gA                    plinem(' ':
730gA                           %char(%timestamp):
730gA                           #user:
730gA                           'DRIPROD':
730gA                           'AFTERACT':
730gA                           '*ADDBASE':
730gA                           bkwhse:
730gA                           wkLneno:
730gA                           '.':
730gA                           inRcvAisl:
730gA                           inPckAisl:
730gA                           inStkAisl:
730gA                           inWipAisl:
730gA                           'A':
730gA                           'N':
730gA                           nxtLoc);
730gA /end-free
730gAc                   endif

      *    Create virtual slot

710dMc                   eval      dispHld = %trim($sldisp)
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $ppwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $ppwhdp
     C                   eval      $slitemu = *on
     c                   if        $psubcmd = '*CRTWORPL'
700hA /free
710 D       //           chain (bmwhse:bmrmi) piritem;
710 A                    chain (wrwhse:writem) piritem;
700hA /end-free
710 Ac                   eval      $slitem  = writem
700hAC                   eval      $slwhdp  = itwhdp
     c                   else
     C                   eval      $slitem  = $ppitem
     c                   endif
     c
     c*  if raw material adjustment then use pbom fields
      /free
                   if rmadj;
                         chain (bmwhse:bmrmi) piritem;
                      if not %found(piritem);
                         $preturn = '*CRTERR';
                         $pmessage = 'Raw Material ' + %trim(bmrmi) +
                                     'not found in Bill of Material';
                         exsr unlockrec;
                         return;
      /end-free
     C                   goto      endcrtprdslt
      /free
                      else;
                         bkitem = $ppitem;
                         bkwhdp = $ppwhdp;
                         bkwhse = $ppwhse;
                         $slwhdp = itwhdp;
                         $slwhse = bmwhse;
                         $slitem = bmrmi;
                         $ppwhdp = itwhdp;
                         $ppwhse = bmwhse;
                         $ppitem = bmrmi;
                      endif;
                   endif;

                   $saActionU = *on;
                   $saAction = $ppAction;
                   if $ppAction = ' ';
                      $saAction = 'PRM';
                   endif;
                   $saToAreaU = *on;
                   $saToArea = 'Slot';
                   $saToLcnsU = *on;
                   $saToLcns = '*PR';
710dA              $slEntd = sltEnt;
740aA              if $ppadjcde <> 'P4';
740aA                // for deletes send the slot Entered Date
710dA                $slEntd = %uns(%char(%Date():*Iso0));
740aA              else;
740aA                $slEntd = sltEnt;
740aA              endif;
710eA              if $psubcmd <> '*IMPQTY'
710fA                 and $psubcmd <> '*GETMIN'
710fA                 and ($ppAction='PSC');
710dA              // call routine to return expiration date
740aA                 if $ppadjcde <> 'P4';
710dA                   $ppExpDt = %uns(%char(%Date():*Iso0));
740aA                 else;
740aA                   $ppExpDt = sltExp;
740aA                 endif;
710dA                 exsr calcExpireDt;
710dA                 $slExpd = $ppExpdt;
710dA                 $slExpDU = *on;
710gA              else;
710gA                if $ppExpdtU;
710gA                  $slExpd = $ppExpdt;
710gA                  $slExpDU = *on;
710gA                else;
710dA                  $slExpd = *zeros;
710dA                  $slExpDU = *off;
710gA                endif;
710eA              endif;
      /end-free
     C                   eval      $slstatu = *on
     C                   eval      $slstat  = 'PR'
     C                   eval      $sldispu = *on
     c     tryAgain      tag
720bDc*                  if        $ppdest <> 'C'
720bAc                   if        $ppdest <> 'C' or getmin
     C                   eval      $drisubcmd  = '%CRTPROD'
     c                   eval      $samemo = ' '
     c                   else
     C                   eval      $drisubcmd  = '%CRTPRODC'
     c                   eval      $samemo = %editc($ppcust:'X')
     c                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzdricop2
     C                   if        wkerror
     C                             and $drireturn <> 'INSLOT'
730gAc*   Do not return error for no Virtual found at this point.
730gAc*   It only does that at top of DOU loop above once it has
730gAc*   exhausted all locations through 999 for given Aisle and Level
730gAC                             and $drireturn <> 'VRTNOTALWU'
     C*                  eval      $preturn = '*CRTERR'
     C                   eval      $preturn = $drireturn
     C                   eval      $pmessage = $drimessage
     c                   exsr      unlockrec
     C                   return
650aAc                   endif
730gA *  Try again with a different level if no virtual was found with current level
730gAc                   enddo
710dAc                   eval      sltExp = $slexpd
710fAc                   eval      $ppExpDt = $slexpd
710dAc                   eval      sltEnt = $slEntd

     C     endcrtprdslt  endsr

      *----------------------------------------------------------------
      *  crtRmReplen  Create Production Raw Material Replenishment
      *----------------------------------------------------------------

     C     crtRmReplen   begsr
      /free

             total_qtyn = 0;
             total_qty1 = 0;
             total_qty2 = 0;
             total_prdq = 0;

710A
710A        // this routine changed  for mod mark 7.10 to get all raw
710A        // material requirements by calling subroutine rmRdOpnQty.
710nM        // This routine calls function R130002 to determine replen
710A        // quantities along with other things.
710A
710 A        wkRmAvl = 'O';
710 A        wkItem = writem;
710 A        wkLneNo = wrmfgno;
710 A
710 A        exsr rmRdOpnQty;
710 A
710 A        // read record just created in PRMSUM to get demand quantities
720dA        if $ppRmAvl='Y';
710 A          setll ($ppSessId:wrwhse:writem:*hival) pRmSum;
710 A          readpe ($ppSessId:wrwhse:writem) pRmSum;
710 A          if not %eof(pRmSum) and smitem = writem;
710 A             exsr CvtBrkD;
710 A             exsr generateRpl;
710 A          endif;
720dA        else;
730aA    //    $trtn='*REPLERR';
730aA    //    $tMsg='No full cases available';
710 A        endif;
710 A
710 D        // update Work Order to Released
710 D     //   exec sql update pwrkord
710 D     //     set wostat = 'R'
710 D     //     where wowhse = :$ppwhse and wowo# = :$ppwo#;
710 D     //   $ppstat = 'R';
710 D
710 D        // setup SQL statement and cursor to get all
710 D        // requirements for this bill of material item.
710 D        // It will only be selected if status of work order
710 D        // is either Released or Working and matches the line.
710 D        // Use WOMAKE minus WOQTYP for back flushed items and
710 D        // it will use only WOMAKE for items not back flushed
710 D        // since raw materials would not be reduced automatically
710 D
710 D  //   sqlStmt = 'Select writem,wrfgi,womake,woqtyp,' +
710 D  //             'wormavl,wostat,wrqtyn,wrqty1,' +
710 D  //             'wrqty2,wrprdq,wrscrf,wrprimal,' +
710 D  //             'wrsubprme,wrstat,itdesc,itum2,' +
710 D  //             'itumq2,itum3,itumq3,ippuom,ipprdq,' +
710 D  //             'wrmfgno, wocust, woprio, wotype,' +
710 D  //             'wowo#,wrwhse,ipbrkr';
710 D  //   sqlStmt = %trim(sqlStmt) + ' from ' +
710 D  //             'pwrkOrd, pWrkOrdr, pirItem, itemprd ';
710 D
710 D     // build joins in Where Clause
710 D  //   wherelabel = 'where wowhse=wrwhse' +
710 D  //                ' and wowo#=wrwo# ' +
710 D  //                ' and wrwhse = itwhse ' +
710 D  //                ' and writem = ititem' +
710 D  //                ' and itwhse = ipwhse ' +
710 D  //                ' and ititem = ipitem ';
710 D
710 D     // append normal selections to where clause
710 D     // only include work order either released or
710 D     // already in working status to be considered
710 D     // this will return all demand that can be bouced
710 D     // off mfg inventory and unprocessed replenishments
710 D     // to determine proper update or addition of
710 D     // replenishments
710 D
710 D   //  wherelabel = %trim(wherelabel) +
710 D   //               ' and wrwhse = ' + %char($ppWhse) +
710 D   //               ' and womfgno = ' + %char($pplneno) +
710 D   //               ' and writem = ' + sq + bmrmi + sq +
710 D   //               ' and (wostat = ' + sq + 'R' + sq +
710 D   //               ' or wostat = ' + sq + 'W' + sq + ')';
710 D
710 D   //     SqlStmt = %trim(Sqlstmt) + ' ' + %trim(Wherelabel);
710 D
710 D   //     exec sql Prepare SelWo from :Sqlstmt;
710 D   //     exec sql Declare pwrkordr scroll cursor for SelWo;
710 D  //      Exec Sql Close pwrkordr;
710 D  //      exec sql Open pwrkordr;
710 D  //      exec sql Fetch first from pwrkordr into :wosum;
710 D
710 D  //      if Sqlstt = sqlsuccess;
710 D          // get break values for total
710 D   //        hld_whse = sqWhse;     // warehouse
710 D   //        hld_item = sqitem;     // raw material
710 D   //        hld_mfgno = sqmfgno;   // Mfg Line
710 D   //        hld_umq2 = squmq2;     // Breakdown 1
710 D   //        hld_umq3 = squmq3;     // Breakdown 2
710 D   //     endif;
710 D
710 D   //     dow Sqlstt = sqlsuccess;
710 D           // if item changes, write replenishment and setup for next
710 D           // item
710 D   //        if sqwhse <> hld_whse or sqitem <> hld_item
710 D   //            or sqmfgno <> hld_mfgno;
710 D   //            exsr generateRPL;
710 D   //        else;
710 D              // accumulate quantities to create replenishment
700c               // roll to lowest level, add scrap and
700c               // roll back up to highest uom
710 D
700nD  //--Comment 5 Lines--//
700j   //            if squmq3 = *zeros and squmq2 = *zeros;
700j   //               noBrkDwn = *on;
700j   //            else;
700j   //               noBrkDwn = *off;
700j   //            endif;
710 D
700k   //--Comment 9 Lines--//
700c   //            if squmq3=*zeros;
700c   //               squmq3=1;
700c   //            endif;
700c   //           if squmq2=*zeros;
700c   //             squmq2=1;
700c   //           endif;
700c   //           eval wkqty2 = sqqtyn*squmq2*squmq3;
700c   //           eval wkqty2 = wkqty2 + sqqty1*squmq3;
700c   //           eval wkqty2 = wkqty2 + sqqty2;
710 D
700k              // Calculate based on breakdowns defined
710 D  //         select;
700k                // No breakdown defined
710 D  //           when squmq2 = 0 and squmq3 = 0;
710 D  //             total_qtyn += sqqtyn * (1+sqscrf);
700k                // Breakdown2 defined
710 D   //          when squmq2 <> 0 and squmq3 = 0;
710 D  //             total_qty1 += ((sqqtyn*squmq2) + sqqty1) * (1+sqscrf);
700k                // Breakdown2 & breakdown3 defined
710 D  //           when squmq2 <> 0 and squmq3 <> 0;
710 D  //             total_qty2 += ((sqqtyn*squmq2*squmq3) + (sqqty1*squmq3)
710 D   //                           + sqqty2) * (1+sqscrf);
710 D  //         endsl;

700k   //Comment 6 lines
700c   //           eval sqqtyn=*zeros;
700c   //           eval sqqty1=*zeros;
700c   //           eval sqqty2=(wkqty2*(1+sqscrf));
700c   //           total_qtyn = (total_qtyn + (sqqtyn*(1+sqscrf)));
700c   //           total_qty1 = (total_qty1 + (sqqty1*(1+sqscrf)));
700c   //           total_qty2 = (total_qty2 + (sqqty2*(1+sqscrf)));
710 D   //        total_prdq = (total_prdq + (sqprdq*(1+sqscrf)));
710 D  //       endif;
710 D
710 D  //       exec sql Fetch next from pwrkordr into :wosum;
710 D  //    enddo;
710 D
710 D        // Process last break after last record read
710 D  //    if total_qtyn <> 0 or total_qty1<>0 or total_qty2<>0
710 D  //         or total_prdq<>0;
710 D  //       exsr generateRbegsr
710 D  //    endif;
710 D  //    Exec Sql Close pwrkordr;
710 D
710 D /end-free
     C                   endsr
      /free
710 D
710 A   //*----------------------------------------------------------
710 A   //*  CvtBrkD: Convert Breakdo from character to numeric
710 A   //*----------------------------------------------------------
710 A     BegSr CvtBrkD;
710 A   //*    {Inventory breakdown}  -------------------------------
710 A         clear splitAry;
710 A         // call procedure that splits normal qty text string into case and brkdwn qtys
710 A         splitARy = Split(SMREQQ:'.');
710 A         lpos = 1;
710 A         dow lpos < 4;
710 A            if splitAry(lpos) <> *blanks;
710 A               select;
710 A                  when lpos = 1;
710 A                     total_Qtyn  = %Dec(%trim(splitAry(lpos)):5:0);
710 A                  when lpos = 2;
710 A                     total_Qty1  = %Dec(%trim(splitAry(lpos)):5:0);
710 A                  when lpos = 3;
710 A                     total_Qty2  = %Dec(%trim(splitAry(lpos)):5:0);
710 A               endsl;
710 A            endif;
710 A            lpos = lpos + 1;
710 A         enddo;
710 A   //*    {Production Breakdown} -------------------------------
710 A         total_Prdq = %Dec(SMREQP:9:2);
710 A     EndSr;
710 A
710 A /end-free
      *----------------------------------------------------------------
      *  crtSugg  Create Production Suggestion
      *----------------------------------------------------------------

     C     crtSugg       begsr
      /free
                // routine called from LT120a which loops thru demand
                // for Production Finished Goods and passes demand
                // to this routine which reduces the need by what
                // what it finds in Warehouse slots and Production PAR
                // slots.  If anything remains at that point this routine
                // calls the appropriate routines to add additional
                // Suggestions

730aA                    exsr chkAvail;
650iA       // if quantity remains we should create a production sugg.
650iA                    if $ppneed > 0;
650iA                       // get default mfg line from item master
650iA                       chain ($ppwhse:$ppitem) itemprd;
650iA                       if %found(itemprd);
650iA                          $pplneno = ipmfgno;
650iA                       else;
650iA                          $pplneno = 1;
650iA                       endif;
650iA                       // This process will only add Suggestions.
650iA                       // If already moved on to another status this
650aI                       // process will not read, therefore we will
650iA                       // always add new records
730bD                       //exsr getNxtPWO;
730bD                       //$ppwo# = wkwo#;
                            $pporig = 'S';
                            $ppprio = 5;
650iA                       $ppavlq = $ppdmdq - $ppneed;
650iA                       $ppmake = $ppneed;
730dA                       $ppMake1=0;
730dA                       $ppMake2=0;
730aA                       $ppQty1 = $ppneed;
650iA                       $pprmavl = 'N';
650iA                       $ppdest = 'P';
650iA                       $ppstat = 'S';
730aA                       exsr updLoop;
                         else;
                            $pMessage = 'No Suggestion Required';
                            $pReturn = '*NOSUGG';
650iA                    endif;
      /end-free
     c                   endsr

710uA *----------------------------------------------------------------
710uA *  crtMMSugg  Create Production Suggestion using Min/Max/Lot
710uA *----------------------------------------------------------------
710uA
710uAC     crtMMSugg     begsr
710uA /free
710uA           // routine called from LT120a which loops thru demand
710uA           // for Production Finished Goods and passes demand
710uA           // to this routine which reduces the need by what
710uA           // what it finds in Warehouse slots and Production PAR
710uA           // slots.  If anything remains at that point this routine
710uA           // calls the appropriate routines to add additional
710uA           // Suggestions
710uA
710uA                    eval  totAvail=0;
710uA                    setll ($ppwhse:$ppitem) slot3;
710uA                    reade ($ppwhse:$ppitem) slot3;
710uA
710uA                    dow not %eof(slot3) and %equal(slot3);
710uA                       if (slaisl = 'PAR' and slstat='PR')
710uA                          or slstat = 'A';
710uA                          if sldesg <> 'BFC';
710uA                             exsr avail;
710uA                             totAvail = totAvail + avail1;
710uA                          endif;
710uA                       endif;
710uA                       reade ($ppwhse:$ppitem) slot3;
710uA                    enddo;
710uA                    setll (*loval) slot3;
710uA
710uA       //  Get Min/Max/Lot Values for Item
710uA                    chain ($ppwhse:$ppitem) itemprd;
710uA                    // get default mfg line from item master
710uA                    if %found(itemprd);
710uA                       $pplneno = ipmfgno;
710uA                    else;
710uA                       $pplneno = 1;
710uA                    endif;
710uA
710uA               //Min - Max Quantities
710uA                    if ipMinQt > 0 and ipMaxQt > 0;
710uA
710uA                    // if avail < min then don't go over max
710uA                       if totAvail < ipMinQt;
710uA                          $ppneed = ipMaxQt - totAvail;
710uA                       endif;
710uA
710uA                    // if avail >= max then nothing to produce.
710uA                       if totAvail >= ipMaxQt;
710uA                          $ppneed = 0;
710uA                       endif;
710uA
710uA                    // if avail is between min and max then don't
710uA                    //    go below min.
710uA                       if totAvail > ipMinQt
710uA                          and totAvail < ipMaxQt;
710uA                          $ppneed = totAvail - ipMinQt;
710uA                       endif;
710uA
710uA                    // Lot Check
710uA                       if ipLotQt > 0;
710uA                          qtyByLot = ipLotQt * ipMinQt;
710uA                          if totAvail >= qtyByLot;
710uA                             $ppneed = 0;
710uA                          endif;
710uA                          if totAvail < qtyByLot;
710uA                             $ppneed = qtyByLot - totAvail;
710uA                          endif;
710uA                       endif;
710uA                    endif;
710uA
710uA       // if quantity remains we should create a production sugg.
710uA                    if $ppneed > 0;
710uA
710uA            //Create Suggestion
710uA                       // This process will only add Suggestions.
710uA                       // If already moved on to another status this
710uA                       // process will not read, therefore we will
710uA                       // always add new records
710uA                       exsr getNxtPWO;
710uA                       $ppwo# = wkwo#;
710uA                       $pporig = 'S';
710uA                       $ppprio = 5;
710uA                       $ppavlq = $ppdmdq - $ppneed;
710uA                       $ppmake = $ppneed;
710uA                       $pprmavl = 'N';
710uA                       $ppdest = 'P';
710uA                       $ppstat = 'S';
710uA                       exsr crtprodwo;
710uA                    else;
710uA                       $pMessage = 'No Suggestion Required';
710uA                       $pReturn = '*NOSUGG';
710uA                    endif;
710uA /end-free
710uAc                   endsr
710uA
      *----------------------------------------------------------------
      *  crtwoReplen  Create Production Replenishment
      *----------------------------------------------------------------

710 DC*    crtwoReplen   begsr

710A **  This routine was discountinued with mod mark 7.10.  Now uses
710nM**  crtwoReplen1.  Was reworked to get demand from R130002 call to
710A **  take advantage of all changes their to incroporate primal definition

710 D       // free

              // loop through finished goods bom attached to this
              // work order.  We will then determine total released
              // for given item and what remains compared to what
              // is needed to generate the proper replenishment or
              // update an existing replenishment

710 D      //   setll ($ppWhse:$ppitem) pbom;
710 D      //   reade ($ppWhse:$ppitem) pbom;
710 D  //     dow not %eof(pbom) and %equal(pbom);
710 D  //        if bmtype <> 'I'
710 D  //           and bmeffd <= %uns(%char(%Date():*Iso0))
       //           and bmexpd >= %uns(%char(%Date():*Iso0));
710 D               // for each valid raw material we should
710 D               // look for all open requirements and
710 D               // determine how much as been issued
710 D               // versus those calculated requirements
710 D   //          if not error;
          // ensure Mfg Line Slot exist before creating replenishment
          // for each raw material processed.  Since many requests can
          // be sent close together when MANY work orders are being
          // released together it should do retries on duplicates up
          // to 50 times before returning with error
710 D  //              loopCnt = 1;
710 D  //              dow loopCnt < 50;
710 D  //                 getMin = *on;
710 D  //                 exsr getPrdSlot;
710 D  //                 getMin = *off;
710 D  //                 if ($driReturn = 'ERRADDREC' or wkError)
710 D    //                  and $drireturn <> 'INSLOT';
710 D    //                  loopCnt = loopCnt + 1;
710 D     //              else;
710 D     //                 exsr crtRmReplen;
700oA    //                  if $trtn = '*REPLERR';
700oA    //                     $preturn = '*REPLERR';
700oA    //                     $pMessage = $tmsg;
700oA    //                     *inlr = *on;
700oA    //                     return;
700oA    //                  endif;
710 D    //                  leave;
710 D    //               endif;
710 D    //            enddo;
710 D    //         endif;
710 D    //      endif;
710 D    //      reade ($ppWhse:$ppitem) pbom;
710 D    //   enddo;
710 D
710 D     //end free
710 DC*                  endsr
710 D
710 A *----------------------------------------------------------------
710 A *  crtwoReplen1  Create Production Replenishment
710 A *----------------------------------------------------------------
710 A
710 A*  Replaced crtwoReplen with mod mark 7.10
710 A
710 AC     crtwoReplen1  begsr
710 A /free
710 A
710 A         // loop through finished goods bom attached to this
710 A         // work order.  We will then determine total released
710 A         // for given item and what remains compared to what
710 A         // is needed to generate the proper replenishment or
710 A         // update an existing replenishment
710 A
710 A      //   setll ($ppWhse:$ppitem) pbom;
710 A      //   reade ($ppWhse:$ppitem) pbom;
710 A         setll ($ppWhse:$ppwo#) pwrkordr;
710 A         reade ($ppWhse:$ppwo#) pwrkordr;
720fD         //if sqlStt <> '00000';
720fA         if %eof(pwrkordr) or not %equal(pwrkordr);
710 A           // since very routine checks for this should never happen
710 A           error = *on;
710 A           $pMessage = 'Work Order not found in detail file';
710 A           $preturn = '*INVWHSE';
                exsr unlockrec;
710 A           return;
710 A         endif;
710 A         dow not %eof(pwrkordr);
710cA            chkForSub(wrwhse:wrwo#:writem:wrfgi:wrmfgno);
710nD    //      if wrstat = 'O' and bmtype='C';
710nA     // Make sure for generating replenishments we only consider open
710nA     // Work Order lines for the specific MFg Line associated to this
710nA     // Work ORder we are releasing
710nA            if wrstat = 'O' and bmtype='C' and wrMfgNo = $ppLneno;
710 A     // ensure Mfg Line Slot exist before creating replenishment
710 A     // for each raw material processed.  Since many requests can
710 A     // be sent close together when MANY work orders are being
710 A     // released together it should do retries on duplicates up
710 A     // to 50 times before returning with error
710 A               loopCnt = 1;
710 A               dow loopCnt < 50;
710 A                  getMin = *on;
710 A                  exsr getPrdSlot;
710 A                  getMin = *off;
710 A                  if ($driReturn = 'ERRADDREC' or wkError)
710 A                     and $drireturn <> 'INSLOT';
710 A                     loopCnt = loopCnt + 1;
710 A                  else;
710 A                     exsr crtRmReplen;
710 A                     if $trtn = '*REPLERR';
710 A                        $preturn = '*REPLERR';
710 A                        $pMessage = $tmsg;
710 A                        *inlr = *on;
                             exsr unlockrec;
710 A                        return;
710 A                     endif;
710 A                     leave;
710 A                  endif;
710 A               enddo;
710 A            endif;
710 A            reade ($ppWhse:$ppwo#) pwrkordr;
710 A         enddo;
710 A        // update Work Order to Released
710 A        exec sql update pwrkord
710 A             set wostat = 'R'
710 A             where wowhse = :$ppwhse and wowo# = :$ppwo#
730bA               and wostat<>'C' and wostat<>'D' and wostat<>'R'
730bA               and wostat<>'W';
710 A        exec sql select wostat into :$ppstat
730bA                 from pwrkord
710 A             where wowhse = :$ppwhse and wowo# = :$ppwo#;
710 A
710 A /end-free
710 AC                   endsr

      *----------------------------------------------------------------
      *  delWorkOrder  Delete Work Order Header and Requirements
      *----------------------------------------------------------------

     C     delWorkOrder  begsr
      /free

          chain ($ppWhse:$ppWo#) pWrkOrd;
          if %found(pWrkOrd);
710fA        // Look at Mfg Line to see if MultiDay Line.  If
710fA        // MultiDay Line and deleting the one and only
710fA        // Work ORder then delete the Production Date record
710fA        // so it would be available for other MultiDay WO
710fA        chain ($ppWhse:$ppLneno) plined;
710fA        if %found(pLined) and inDryAge='Y';
710fA           chain ($ppWhse:$ppLneNo:'O') prdDate1;
710fA           if %found(prdDate1);
710fA              delete pdrec;
710fA           endif;
710fA        endif;
             // loop through Raw Material requirements and delete
             setll ($ppWhse:$ppWo#) pWrkOrdr;
             reade ($ppWhse:$ppWo#) pWrkordr;
700dD     // dow not %eof(pWrkOrdr) and %equal(pwrkord);
700dA        dow not %eof(pWrkOrdr);
                wrstat = 'D';
                update wrrec; // mark work order requirements deleted
                reade ($ppWhse:$ppWo#) pWrkordr;
             enddo;
             wostat = 'D';
730aA        woovrd=0;
730aA        woovr1=0;
730aA        woovr2=0;
730aA        womake=0;
730aA        womake1=0;
730aA        womake2=0;
730aA        wocnrm=0;
730aA        wocbd1=0;
730aA        wocbd2=0;
             update worec;   // mark work order header as deleted
          endif;

      /end-free
     C                   endsr

650iA *----------------------------------------------------------------
650iA *  genAlterItem   Generate Alternate items for given Primary Item
650iA *----------------------------------------------------------------
650iA
650iAC     genAlterItem  begsr
650iA /free

            // determine all raw materials that are in the Primary
            // BOM and place in an array

            clear aryRMI;
            clear aryFGI;
710lA       // Always ensure main FG is in array to be written
710lA       // to pAlterItem file
710lA       aryFGI(1) = $ppitem;
            sltcnt =0;

750bA       if ipPrdFlg=*blanks;
750bA         chain ($ppWhse:$ppItem) itemprd;
750bA       endif;

750bA       if ipPrdFlg='C';
750bA         sltcnt=1;
750bA         aryRMI(1) = $ppitem;
750bA       endif;
710cD   //  setll ($ppwhse:$ppitem) pbom;
710cD   //  reade ($ppwhse:$ppitem) pbom;
710cD   //  dow %equal(pbom) and not %eof(pbom);
710cA       setll ($ppwhse:$ppwo#) pwrkORdr;
710cA       reade ($ppwhse:$ppwo#) pwrkOrdr;
710cA       dow not %eof(pwrkOrdr);
710cA          if wrstat <> 'D' and wrstat <> 'C';
710cA             // call procedure that ensures substitute is used if selected
710cA             // for given work order
710cA             chkForSub(wrwhse:wrwo#:writem:wrfgi:wrmfgno);
                  if bmtype <> 'I'
                     and bmeffd <= %uns(%char(%Date():*Iso0))
                     and bmexpd >= %uns(%char(%Date():*Iso0));
                     exccnt = %lookup(%trim(bmrmi):aryRMI);
                     if exccnt = 0;
                        sltcnt = sltcnt + 1;
                        aryRMI(sltcnt) = bmrmi;
                     endif;
                  endif;
710cA          endif;
710cD    //    reade ($ppwhse:$ppitem) pbom;
710cA          reade (wrwhse:wrwo#) pwrkORdr;
            enddo;
            setll (*loval) pwrkORdr;

            if sltcnt = 0;
               aryFGI(1) = $ppitem;
               exsr WrtAlterRec;
710cA          exsr WrtByProducts;
               leavesr;
            endif;

              // generate query that selects all finished goods
              // from the bill of material file that referenced the
              // raw materials found the the step above (aryRMI).

            sqlStmt = 'Select bmfgi,count(*) from pbom ' +
                 'where bmwhse = ' + %char($ppwhse) +
                   ' and bmtype <> ' + sq + 'I' + sq +
                   ' and bmeffd <= ' + %char(%Date():*Iso0) +
                   ' and bmexpd >= ' + %char(%Date():*Iso0);

            firstrec = *on;
            for sltcnt = 1 to 500;

               if %trim(aryRMI(sltcnt)) <> '';

                  if firstrec;
                      sqlStmt = %trim(sqlstmt) + ' and (';
                      firstrec = *off;
                  else;
                      sqlStmt = %trim(sqlStmt) + ' or';
                  endif;

                  sqlstmt = %trim(sqlstmt) +
                  ' bmrmi = ' + sq + %trim(aryRMI(sltcnt)) + sq;

               endif;
            endfor;

            if not firstrec;
            sqlstmt = %trim(sqlstmt) + ') group by bmfgi order by bmfgi';
            endif;

            exec sql PREPARE fg FROM :SqlStmt;
            exec sql DECLARE fgbom SCROLL CURSOR FOR fg;
            exec sql OPEN fgbom;
            firstrec = *on;

            exec sql fetch first from fgbom into :fgrec;

            // loop through all the finished that reference at least
            // one of the raw materials in array aryRMI built in this
            // routine.
            sqlStmt = 'Select bmfgi,bmrmi,count(*) from pbom ' +
                 'where bmwhse = ' + %char($ppwhse) +
                   ' and bmtype <> ' + sq + 'I' + sq +
                   ' and bmeffd <= ' + %char(%Date():*Iso0) +
                   ' and bmexpd >= ' + %char(%Date():*Iso0);

710lD    // exccnt = 0;
710lA       // retain primary finished good in array to ensure
710lA       // it is written to pAlteritem file
710lA       exccnt = 1;
            dow Sqlstt = sqlSuccess;
710qA          if fgitm <> aryFGI(1);
                  exccnt = exccnt + 1;
                  aryFGI(exccnt) = fgitm;

                  if firstrec;
                      sqlStmt = %trim(sqlstmt) + ' and (';
                      firstrec = *off;
                  else;
                      sqlStmt = %trim(sqlStmt) + ' or';
                  endif;

                  // append each returned finished good to next query
                  sqlstmt = %trim(sqlstmt) +
                   ' bmfgi = ' + sq + fgitm + sq;
710qA           endif;
               exec sql fetch next from fgbom into :fgrec;
            enddo;
            exec sql CLOSE fgbom;

            if not firstrec;
               sqlstmt = %trim(sqlstmt) + ')';
            endif;

            // if firstrec is on that means no finished goods
            // were found so we should exit
            if sltcnt = 0;
               exsr WrtAlterRec;
710cA          exsr WrtByProducts;
               leavesr;
            endif;

            // append not equal conditions to raw materials found
            // in step one of this routine.  This ends up giving
            // us finished goods that should be removed from step
            // two of this routine leaving only finished goods that
            // require raw materials found in either the mfg line
            // inventory or on the primary bill of material
            for sltcnt = 1 to 500;
               if %trim(aryRMI(sltcnt)) <> '';
                  sqlstmt = %trim(sqlstmt) +
                  ' and bmrmi <> ' + sq + %trim(aryRMI(sltcnt)) + sq;
               endif;
            endfor;
            SqlStmt=%trim(SqlStmt) +
                    ' group by bmfgi,bmrmi order by bmfgi,bmrmi';

            exec sql PREPARE ex FROM :SqlStmt;
            exec sql DECLARE fgexc SCROLL CURSOR FOR ex;
            exec sql OPEN fgexc;

            exec sql fetch first from fgexc into :fgexc;
            dow Sqlstt = sqlSuccess;
               // by getting this far it means the raw material
               // was not contained on the primary work order
               // item but it was on one of the finished goods
               // in the bom file (pbom) that also included the
               // item(s) from the primary bom.  In this case
               // we check to see if the raw material exist
               // currently in the repsective line. If it
               // exists leave this finished good in the
               // alternate item array, otherwise remove it
               exec sql
                 select count(*)
                 into :numrecs
                 from Slot
                 where slstat = 'PR' and slrlvl = :$pplneno
                       and slaisl = :$pprcva
                       and slitem = :exrmi
                       and slwhse = :$ppwhse;
               if Sqlstt = SqlSuccess and numrecs > 0;
                  sltcnt = 0;
                  sltcnt = %lookup(%trim(exitm):aryFGI);
710lD      //     if sltcnt <> 0;
710lA             // should always send back at least finished
710lA             // finished good on work order
710lA             if sltcnt <> 0 and sltcnt<>1;
                     // if the finished good is found in the array
                     // it should be blanked.  This means this finsihed
                     // good references raw materials not found in either
                     // the mfg line inventory or the primary bom
                     aryFGI(sltcnt) = '';
                  endif;
               endif;
               exec sql fetch next from fgexc into :fgexc;
            enddo;
            exec sql close fgexc;
            exsr WrtAlterRec;
710cA       exsr WrtByProducts;
            // for any finished goods we can use as alternate

650iA /end-free
650iAC                   endsr

730aA*----------------------------------------------------------------
730aA*  gettotreq   Ensure no requirement remains before deleting
730aA*----------------------------------------------------------------
730aA
730aA /free
730aA  begsr getTotReq;
730aA
730aA     // set item to search
730aA     if %subst(bomIary(itmLoop):16:15) = *blanks;
             $ppItem = %subst(bomIary(itmLoop):1:15);
730aA     else;
730aA        $ppItem = %subst(bomIary(itmLoop):16:15);
730aA     endif;
730aA
730aA     $ppLneNo = ipMfgNo;
730aA     $ppMAkeu=*off;
730aA     $ppLneNou = *on;
730aA     $ppRmAvl = *blanks;
730aA     $ppRmAvlu = *off;
730aA     $ppWo# = *blanks;
730aA     $ppWo#u = *off;
730aA
730aA     wkItem = $ppItem;
          // for deletes do not consider mfg line since multiple work orders
          // across multiple lines could be calling same component
          //if $ppDel<>'Y' and $ppDel<>'X';
          if $ppDel<>'Y' and $ppDel<>'X' and ipPrdFlg<>'C';
730aA        wkLneNo = $ppLneno;
          else;
730aA        hld_mfgno = $pplneno;
730aA        wkLneNo  = 0;
730aA        $ppLneNo = 0;
          endif;
730aA     wkRmAvl = $ppRmAvl;
730aA     rmExists = *on;
730aA     exsr rmRdOpnQty;
730aA
730aA     // replace Mfg Line
730aA     if $ppLneno=*zeros and hld_mfgno<>*zeros;
730aA        $ppLneNo=hld_mfgno;
730aA     endif;
730aA
730aA     // Replace blanked Work Order
730aA     $ppWo# = pWo#;
730aA
730aA     setll ($ppSessId:$ppWhse:pFgItm:*hival) pRmSum;
730aA     readpe ($ppSessId:$ppWhse:pFgItm) pRmSum;
730aA     if not %eof(pRmSum) and smitem = pFgItm;
730aA        if $ppDel='Y';
730aA           // If Raw Material Availability record exists
730aA           // either requirements have to be met with existing
730aA           // inventory or there must be zero requirements.
                chain ($ppWhse:$ppItem) piritem;
730aA           if ((splitQty(smreqp)<>0 or splitQty(smreqq)<>0)
730aA               and splitQty(smrmdp)>=0 and splitQty(smrmdq)>=0) or
730aA               (splitQty(smreqp)=0 and splitQty(smreqq)=0);
730aA              deleteok = *on;
730aA           else;
730aA              deleteok = *off;
730aA           endif;
730aA           // get proper value to reduce by per the deletion request
730aA           calcReq();
730aA        else;
                // get requirements per an adjustment plus or minus, pther than delete
730aA           calcReq();
730aA        endif;
730aA     else;
             // no demand is found but goes to calculate requirements in the case
             // where overrides exist
730aA        calcReq();
             if (reqQtyn=0 and reqQty1=0 and reqQty2=0 and
                 $ppovrd=0 and $ppovr1=0 and $ppovr2=0)
                or %subst(bomIary(itmLoop):16:15)=*blanks;
                // do not set for delete if any override quantity remains
730aA           deleteok = *on;
             else;
730aA           deleteok = *off;
             endif;
730aA     endif;
730aA
730aA  endsr;
730aA /end-free
730aA
710dA *----------------------------------------------------------------
710dA *  calcExpireDt  -  Calculate Expiration date
710dA *----------------------------------------------------------------
710dA
710dAC     calcExpireDt  begsr
710dA /free
710dA         // Base date, whether passed as current date or license date
710dA         // from original process will come in as ccyymmdd in prod
710dA         // structure field expiredt.  This routine will calculate
710dA         // a return Expiration date and place in expirtdt.
710dA
710dA         chain ($ppWhse:$ppItem) itemprd;
710dA         if not %found(itemprd);
710dA            $pMessage = 'Item not found in Prod Itm Master to perform'
710dA                       + ' Expiration Date Calculation';
710dA            $pReturn = '*INVLDITEM';
710dA            return;
710dA         endif;
710dA
710dA         chain ($ppWhse:$ppItem) pirItem;
710dA         if not %found(pirItem);
710dA            $pMessage = 'Item not found in Item Master to perform'
710dA                       + ' Expiration Date Calculation';
710dA            $pReturn = '*INVLDITEM';
710dA            return;
710dA         endif;
710dA
710dA         Chain ($ppWhse:$ppITem) itemmsc;
710dA         if not %found(pirItem);
710dA            imuday = *zeros;
710dA         endif;
710dA
710dA         if itflgd = 'N';
710dA            // If not flagged as Date Sensitive then put zeros in Expiration
710dA            // Date and Return
710dA            $ppExpDt = *zeros;
710dA            leavesr;
710dA         endif;
710dA
710MD      //   if imuday > ipmday;
DRYaA         if client <> 'DAIRYLAND';
DRYaA            // Dairyland has decided to allow Production to generate a Zero
DRYaA            // expiration date in this scenario instead of throwing an error
710mA            if (imuday+imdday) > ipmday;
710dA               $pMessage = 'Items user days(' + %char(imuday) +
710dA                            ') cannot exceed Mfg Shelf Life Days('
710dA                            + %char(ipmday) + ')';
710dA               $pReturn = '*INVLDUSRD';
710dA               return;
710dA            endif;
DRYaA         endif;
710dA
DRYaA         if client <> 'DAIRYLAND';
DRYaA            // Dairyland has decided to allow Production to generate a Zero
DRYaA            // expiration date in this scenario instead of throwing an error
710dA            if ipmday = *zeros;
710dA               $pMessage = 'Mfg Shelf Life has must exist if flagged ' +
710dA                            ' date sensitive';
710dA               $pReturn = '*NOMFGDAYS';
710dA               return;
710dA            endif;
DRYaA         endif;
710dA
DRYaA         if client = 'DAIRYLAND';
DRYaA            // if Dairyland and either Mfg Shelf Life Days is zero or
DRYaA            // the sum of Dist days and User Days exceed Mfg Shelf Life
DRYaA            // days then we should return a Zero Expiration.  The Mfg
DRYaA            // Shelf Life Days used for Production is found in ITEMPRD.
DRYaA            // The purpose of having the other field for Production is
DRYaA            // to allow for different shelf life for inhouse produced
DRYaA            // product versus purchased product.
DRYaA            if ipmday = *zeros;
DRYaA               $ppExpDt = *zeros;
DRYaA               leavesr;
DRYaA            else;
DRYaA               // since dist/user days are greater than mfg shelf life days
DRYaA               // we are putting today's date as expiration so it will bring
DRYaA               // attention to the issue
DRYaA               if (imuday+imdday) > ipmday;
DRYaA                  ipmday=*zeros;
DRYaA                  imuday=*zeros;
DRYaA                  imdday=*zeros;
DRYaA               endif;
DRYaA            endif;
DRYaA         endif;
DRYaA
710dA         // put item master checks here to insure nothing has changed
710dA         // or been corrupted
710dA         $ppExpDt = %dec(%char(
710mD         // %date($ppExpDt:*iso) + %days(ipmday-imuday) :*iso0):8:0);
740aD         //%date($ppExpDt:*iso) + %days(ipmday-imuday-imdday) :*iso0):8:0);
740aM         %date($ppExpDt:*iso) + %days(ipmday-imuday) :*iso0):8:0);
710dA
710dA /end-free
710dAC                   endsr

710fA *----------------------------------------------------------------
710fA *  chkForDate  -  Confirm Prod Date for Mfg Multi Day Line
710fA *----------------------------------------------------------------
710fA
710fAC     chkforDate    begsr
710fA /free
710fA         pDateSql = %uns(%char(%Date():*Iso0));
710fA         chain ($ppWhse:$ppLneno:'O') prdDate1;
710fA         if not %found(prdDate1);
710fA            pddate=$ppWhse;
710fA            pdLine=$ppLneno;
710fA            pddate=pDateSql;
710fA            pdStat='O';
710fA            write pdrec;
710fA         else;
710fA            unlock prdDate1;
710fA         endif;
710fA /end-free
710fAC                   endsr

650iA *----------------------------------------------------------------
650iA *  getNxtPWO   Get Production Work Order Number
650iA *----------------------------------------------------------------
650iA
650iAC     getNxtPWO     begsr
650iA /free
650iA                    wkwodate = %char(%date():*iso0);
650iA                    wkwoseq = 99999;
650iA                    setll ($ppwhse:wkwo#) pWrkOrd;
650iA                    readp pWrkOrd;
650iA
650iA                    if %eof(pWrkOrd) or
650iA                       wkwodate <> %subst(wowo#:1:8);
650iA                       wkwoseq = 00001;
                            setll (*loval) pWrkOrd;
650iA                    else;
650iA                       wkwoseq = 00001;
650iA                       setll ($ppwhse:wkwo#) pWrkOrd;
650iA                       reade ($ppwhse:wkwo#) pWrkOrd;
650iA                       dow not %eof(pWrkOrd);
650iA                          wkwoseq = wkwoseq + 1;
650iA                          if wkwoseq = 99999;
650iA                             leave;
650iA                          endif;
650iA                          reade ($ppwhse:wkwo#) pWrkOrd;
650iA                       enddo;
                            setll (*loval) pWrkOrd;
650iA                    endif;
                         $ppwo# = wkwo#;

730aA                    if itmLoop = 1;
730aA                       hldwo#=wkwo#;
730aA                    endif;

650iA
650iA /end-free
650i C                   endsr

710tA
710tA*----------------------------------------------------------------
710tA*  GenerateLabor  - Generate appropriate labor Transaction from
710tA*                   Production Module
710tA*----------------------------------------------------------------
710tA
710tAc     GenerateLabor begsr
710tA /free
710tA         clsDte = *zeros;
710tA         clsTim = *zeros;
710tA         taskType=*blanks;
              timeuser = $ppUser;
              // retrieve whether Direct or Indirect
710tA         exec sql select tktype into :taskType
710tA                 from task
710tA                 where tkcode=trim(:$ppCustwo)
710tA                 fetch first row only;
710tA         if sqlStt <> sqlSuccess;
                 taskType=*blanks;
              endif;
710tA         select;
710tA            when $pSubCmd = '*STRLAB';
710tA               if $ppTrn# <> *zeros;
710tA                  // if a transaction gets sent up with Start this means
710tA                  // previous transaction should be closed prior to starting
710tA                  // the latest transaction
710tA                  if taskType<>'I' and taskType<>' ';
710tA                     exsr zzTrnEndc;
710tA                  else;
710tA                     exsr zzTrnClsI;
710tA                  endif;
710tA               endif;
710tA               exsr zzTrnCrtStart;
710tA            when $pSubCmd = '*CLSLAB';
710tA               if taskType<>'I' and taskType<>' ';
710tA                  exsr zzTrnEndc;
710tA               else;
710tA                  exsr zzTrnClsI;
710tA               endif;
                    if $ppCustWo<>'ENDDAY';
710tA                  exsr zzTrnIdle;
                    endif;
710tA         endsl;
              $pptrn# = @pTrn#;
710tA /End-free
710tAc                   endsr
      *----------------------------------------------------------------
      *  generateRPL  Calculate quantities and generate Replenishment
      *----------------------------------------------------------------

     C     generateRPL   begsr
      /free
              // determine inventory currently available in Mfg
              // Line slots for this raw material as well as
              // any open replenishments for this line and item
710 A            squmq2 = itumq2;
710 A            squmq3 = itumq3;
                 exsr avlrm;
              // if item is in production uom convert to wh uom
710 D    //      if sqippq <> 0 and sqprdq <> 0;
710 D    //         exsr prdqtyconv;
710 D    //      endif;

700nD  //700j             if noBrkDwn;
710nA     // The 710nA mods in this routine were originally here from
710nA     // long ago and were commented out when we changed the replenishment
710nA     // process to call R130002 and use prmsum to determine needs as
710nA     // Work ORder releases were performed.  We quickly determined
710nA     // these lines were still needed to consider inventory already
710nA     // in the repsective Line Slot for particular Mfg Line
710nA            if squmq2 = 0 and squmq3 = 0; //No breakdowns defined
700k   //--Comment 1 Line--//
700j   //             total_qtyn = total_qty2;
710nA               total_qty2 = *zeros;
710nA               total_qty1 = *zeros;
710nA            endif;

710nA            if squmq2 = 0;
710nA               wkumq2 = 1;
710nA            else;
710nA               wkumq2 = squmq2;
710nA            endif;

710nA            if squmq3 = 0;
710nA               wkumq3 = 1;
710nA            else;
710nA               wkumq3 = squmq3;
710nA            endif;

710nA            if (((newqtyn * wkumq2 * wkumq3)+  // available inventory
710nA                 (newqty1 * wkumq3) +
710nA                  newqty2) >=
710nA               (((total_qtyn * wkumq2 * wkumq3)+ // required inventory
710nA                (total_qty1 * wkumq3) +
710nA                 total_qty2)) and
710nA                 (newqtyn+newqty1+newqty2+newprdq) <> 0);
710nA               newqtyn = 0;    // no need for replen when available
710nA               newqty1 = 0;    // covers the need
710nA               newqty2 = 0;
710nA               newprdq = 0;
710nA            else;
                   // when to few we roll to lowest level, roll up and
                   // take next higher case when breakdown remains

710nA               select;
700nD  //                     when squmq3 <> 0   // uses both bdwn 1 and 2
700nD  //700jA                       and not noBrkDwn;
710nA                 // Breakdown 2 & breakdown 3 defined
710nA                 when squmq2 <> 0 and squmq3 <> 0;
710nA                     newqty2 = (((total_qtyn * squmq2 * squmq3) +
710nA                                (total_qty1 * squmq3) +
710nA                                 total_qty2)) -
710nA                               ((newqtyn * squmq2 * squmq3) +
710nA                                (newqty1 * squmq3) +
710nA                                 newqty2);
710nA                     newqtyn = 0;
710nA                     newqty1 = 0;

700nD  //                      when squmq2 <> 0    // uses bdwn 1 only
700nD  // 700jA                       and not noBrkDwn;
710nA                 // Breakdown 2 defined - Breakdown 3 not defined
710nA                 when squmq2 <> 0 and squmq3 = 0;
710nA                     newqty1 = ((((total_qtyn) * squmq2) +
710nA                                 total_qty1)) -
710nA                               ((newqtyn * squmq2) +
710nA                                 newqty1);
710nA                     newqtyn = 0;
710nA                     newqty2 = 0;

710nA                  other;     // uses normal quantity only
710nA                     newqtyn =  (total_qtyn ) - newqtyn;
710nA                     newqty1 = 0;
710nA                     newqty2 = 0;
710nA               endsl;
710nA            endif;

                 // up lowest level quantity to highest levels
710nA            zzupqty();

650aA            // roll up needs based on whether we should generate
650aA            // case only replenishments or case and/or breakdown
650aA            // one replenishments
650aA
710nD     //     newqtyn = total_qtyn;
710nD     //     newqty1 = total_qty1;
710nD     //     newqty2 = total_qty2;
710nD     //     newprdq = total_prdq;
710 A            chain (wrwhse:writem) piritem;
710 A            chain (wrwhse:writem) itemprd;
710 M            if opBrkR = 'N';   // do not allow brkdwn replen
710 M               // roll everything up to case quantity
710 M               eval replenqty = newqtyn;
710 M               BrkDwnQty = 0;
710 M               if newqty1 <>0 or newqty2 <>0;
710 M                  replenqty = replenqty + 1;
710 M               endif;
710 M            else;
650aA               // if breakdown allowed for planning make sure
650aA               // this particular item is defined to allow
710 D     //        if sqbrkr = 'Y';
710 A               if ipbrkr = 'Y';
650aA                  eval replenqty = newqtyn;
650aA                  eval BrkDwnQty = newqty1;
650aA                  // rollup to breakdown 1 since settings allow
650aA                  if newqty2 <> 0;
650aA                     BrkDwnQty = BrkDwnQty + 1;
650aA                  endif;
650aA               else;
650aA                  // although system setting allows planning to
650aA                  // generate breakdown replenishments the raw
650aA                  // raw material is set to disallow.  therefore
650aA                  // rollup to case quantity only
700jA                  BrkDwnQty = 0;
650aA                  eval replenqty = newqtyn;
650aA                  if newqty1 <>0 or newqty2 <>0;
650aA                     replenqty = replenqty + 1;
700jD         //          BrkDwnQty = 0;
650aA                  endif;
650aA               endif;
650aA            endif;
      /end-free
     c*   Call process which calls DRIPRTYRPL to generate Replen
510aAC                   eval      $tmsg = *blanks
510aAC                   move      $ppWhse       $twhse            3
     c                   eval      prplbs = '*SINGLE'
710dAc                   eval      $sldisp=%trim($sldisp)
650aAC                   call      'LT110G'
650aAC                   parm                    $twhse
700lDC**                   parm                    $ppwhdp
700lAC                   parm                    $slwhdp
650aAC                   parm                    prplbs            8
710 DC**                 parm                    brrmi            15
710 AC                   parm                    writem           15
650aAc                   parm                    $sldisp
650aAc                   parm                    replenqty
650aAc                   parm                    BrkDwnQty
650aAC                   parm                    $trtn             8
650aAC                   parm      ' '           $tmsg            99
      *
     c                   if        $trtn <> ' ' and $trtn <> '*OK'
     c                   eval      $pMessage = $tmsg
     c                   endif

     C                   endsr

      *----------------------------------------------------------------
      *  getPrdSlot - Add/Locate current slot for passed data
      *----------------------------------------------------------------

     c     getPrdSlot    begsr

      /free
             wkLoc = 1;

             savever# = $slver#;
             clear $slot;
             clear $slot2;
             $slver# = savever#;


             $slstatu = *on;
             $slstat = 'PR';

             select;
                when getMin             // Receiving slot for MFG Line
                  or rmadj
                  or $ppdest = 'M'
KFSaA             or (client=Kellys and
KFSaA                 ipprdflg='C' and ($ppdest='P' or $ppdest='C'));
KFSaA              if $pprcva=*blanks;
KFSaA                // for Kelly foods we add Component Production into a LIN
KFSaA                // slot instead of a PAR slot.  Allows for direct compsumption
KFSaA                // when ready for next level without replenishment
KFSaA                $pprcva = inrcvaisl;
KFSaA              endif;
                   $slaisl = $pprcva;
730gA   // Get highest current slot location for this Aisle
730gA              nxtLoc=101;
730gA              exec sql select max(slloc) into :nxtLoc
730gA                         from slot1
730gA                        where slwhse=:$ppwhse and slwhdp=:itwhdp
730gA                          and slaisl=:$slaisl and slrlvl=:$pplneno
                               and slitem=:$ppitem;
730gD              //$sldisp = %trim($slaisl) + '-101-' + %char($pplneno);
730gA              $sldisp = %trim($slaisl) + '-' + %char(nxtLoc) +
730gA                        '-' + %char($pplneno);
                   exsr crtprdslt;
                when $ppdest = 'W';
                   $slaisl = $ppwipa;
730gA   // Get highest current slot location for this Aisle
730gA              nxtLoc=101;
730gA              exec sql select max(slloc) into :nxtLoc
730gA                         from slot1
730gA                        where slwhse=:$ppwhse and slwhdp=:itwhdp
730gA                          and slaisl=:$slaisl and slrlvl=:$pplneno
                               and slitem=:$ppitem;
730gD              //$sldisp = %trim($slaisl) + '-101-' + %char($pplneno);
730gA              $sldisp = %trim($slaisl) + '-' + %char(nxtLoc) +
730gA                        '-' + %char($pplneno);
                   exsr crtprdslt;
                when $ppdest = 'P';
                   $slaisl = $pppara;
730gA   // Get highest current slot location for this Aisle
730gA              nxtLoc=101;
730gA              exec sql select max(slloc) into :nxtLoc
730gA                         from slot1
730gA                        where slwhse=:$ppwhse and slwhdp=:itwhdp
730gA                          and slaisl=:$slaisl and slrlvl=:$pplneno
                               and slitem=:$ppitem;
730gD              //$sldisp = %trim($slaisl) + '-101-' + %char($pplneno);
730gA              $sldisp = %trim($slaisl) + '-' + %char(nxtLoc) +
730gA                        '-' + %char($pplneno);
                   exsr crtprdslt;
                when $ppdest = 'C';
                   exsr setcustslot;
                   $slaisl = $ppshpa;
710dM              $sldisp = %trim($slaisl) + '-101-' + %char($pplneno);
                   // if customer slot was found in setcustslot
                   // then simply pass that slot in
                   if ($driReturn = 'INSLOT' or $pMessage = ' ')
710dM                       and %trim($sldisp)<>' ';
                   else;
                      // otherwise look for the next virtual slot
                      // for given slot type
730gA   // Get highest current slot location for this Aisle
730gA                 nxtLoc=101;
730gA                 exec sql select max(slloc) into :nxtLoc
730gA                            from slot1
730gA                           where slwhse=:$ppwhse and slwhdp=:itwhdp
730gA                             and slaisl=:$slaisl and slrlvl=:$pplneno
                                  and slitem=:$ppitem;
730gD              //$sldisp = %trim($slaisl) + '-101-' + %char($pplneno);
730gA              $sldisp = %trim($slaisl) + '-' + %char(nxtLoc) +
730gA                        '-' + %char($pplneno);
                      exsr crtprdslt;
                   endif;
                   // ensure cross reference record in place
710dM              if %trim($sldisp)<>' ';
                      chain(n) ($ppwhse:$ppcust:$ppitem) pcslot;
                      if not %found(pcslot);
                         // create cross refernece record
                         cswhse = $ppwhse;
                         cscust = $ppcust;
                         csitem = $ppitem;
710dM                    csdisp = %trim($sldisp);
                         write csrec;
                      else;
                         unlock pcslot;
                      endif;
                   endif;
                endsl;

                // read virtual slot either found or created
                if $driReturn = 'INSLOT' or $pMessage = ' ';
710dM              if %trim($sldisp) <> ' ';
710dA                 $sldisp = %trim($sldisp);
                      exec sql      // if DRISLOT found slot in read
                       select *
                       into :slrec
                       from slot
                       where slwhse = :$ppwhse and slwhdp = :$ppwhdp and
                             slitem = :$ppitem and sldisp = :$sldisp and
                             slstat = :$slstat;
                   endif;
                else;
                   // force error condition
                   Sqlstt = '01000';
                endif;

             if Sqlstt = sqlSuccess;
                // if found current slot to use we are ready to adjust
                $sldispu = *on;
710dM           $sldisp = %trim(sldisp);

                select;
                when $ppdest = 'M'        // MFG Line Receiving Slot
                      or rmadj
                      or getmin;
710dM              $pprcvar = %trim($sldisp);
                when $ppdest = 'C';       // customer
710dM              $ppshpar = %trim($sldisp);
                when $ppdest = 'P';       // Par
710dM              $ppparar = %trim($sldisp);
                when $ppdest = 'W';       // WIP
710dM              $ppwipar = %trim($sldisp);
                endsl;

710 A        else;
710 A          // error = *on;
710 A          // $pMessage = 'Slot (' + %trim($sldisp) +
710 A          //                   ') not found in slot file';
710 A          // $preturn = '*INVWHSE';
710 A          // return;
             endif;

             // if a raw material issue return fg to prod data structure
             if rmadj;
                $ppwhse = bkwhse;
                $ppitem = bkitem;
                $ppwhdp = bkwhdp;
                bkwhse = 0;
                bkitem = ' ';
                bkwhdp = ' ';
             endif;

       endsr;
      /end-free

710fA *----------------------------------------------------------------
710fA *  MultiDayLine - Create/Assign MultiDay Line.  If one is
710fA *  available simply assign, otherwise add a new one.  Multiday
710fA *  day lines begin with 99 and go down.
710fA *----------------------------------------------------------------

710fA /free
710fA  begsr MultiDayLine;
710fA
710fA     // if an update and Mfg Line did not change do not go
710fA     // further in this routine bacuase it will change to
710fA     // Multi Line when not necessary
710fA     if $psubCmd = '*UPDPRODWO';
710fA        chain(n) ($ppWhse:$ppWo#) pWrkord;
710fA        if %found(pWrkORd);
710fA           chain (woWhse:woMfgno) pLined;
710fA           if %found(pLined) and inDryAge = 'Y';
710fA              $ppLneNo = woMfgno;
710fA              leavesr;
710fA           endif;
710fA        endif;
710fA     endif;
710fA
710fA     // loop through multiday lines already setup and see if
710fA     // one is available.  If none available then add new one
710fA     hldMulti = *zeros;
710fA     setgt (*hival) plined;
710fA     readp pLined;
710fA     dow not %eof(pLined);
710fA        if indryage = 'Y';   // MultiDay line
710fA           hldMulti = inLneNo;
710fA           // see if assigned to active Work Order
710fA           openWo = 0;
710fA           exec sql select count(*) into :openWo
710fA                    from pWrkOrd
710fA                 where not woStat in('C','D')
710fA                   and womfgno = :inLneNo;
710fA           if sqlStt <> sqlSuccess or openWo=0;
710fA              // if either no records or found or the
710fA              // sql fails use this line number and
710fA              // leave subroutine
710fA              $ppLneno = inLneNo;
710fA              exsr chkforDate;
710fA              leavesr;
710fA           endif;
710fA        endif;
710fA        readp pLined;
710fA     enddo;
710fA
710fA     // if code falls here it either means no MultiDay
710fA     // Mfg Lines exist or none are free of a Work Order.
710fA     // Therefore we need to add a line
710fA     // If no records default to Standard
710fA     if inRcvAisl = *blanks;
710fA        inRcvAisl = 'LIN';
710fA        inPckAisl = 'PCK';
710fA        inStkAisl = 'PAR';
710fA        inWipAisl = 'WIP';
710fA     endif;
710fA
710fA     if hldMulti = *zeros;      // No MultiDay lines were found
710fA        hldMulti = 99;
710fA     endif;
710fA
710fA     // Search until Mfg Line from 99 down is open to be added
710fA     // as Multi Day Line
710fA     setll ($ppWhse:hldMulti) pLined;
710fA     dow %equal(pLined);
710fA        if hldMulti = 1;
710fA          // If down to line one we have no more lines to use.
710fA          // Return an error stating our Multi Day lines are full
710fA           error = *on;
710fA           $pMessage = 'All Multi-Day lines are consumed';
710fA           $preturn = '*MULTDAY';
710fA           exsr unlockrec;
710fA           return;
710fA        endif;
710fA        hldMulti = hldMulti - 1;
710fA        setll ($ppWhse:hldMulti) pLined;
710fA     enddo;
710fA
710fA     $ppLneno = hldMulti;
          pDesc = 'MultiDay Line Auto';
          // call PLINEM1 to add necessary line and base slots
      /end-free
     c                   call      'PLINEM2'
     c                   parm                    $pMessage
     c                   parm                    $ppSessId
     c                   parm                    #user
     c                   parm      'DRIPROD'     pPgm
     c                   parm      'AFTERACT'    pobjloct         10
     c                   parm      'A'           pSubCmd          10
     c                   parm      $ppWhse       pwhsep            3 0
     c                   parm                    hldMulti
     c                   parm                    pDesc            40
     c                   parm                    inRcvAisl
     c                   parm                    inPckAisl
     c                   parm                    inStkAisl
     c                   parm                    inWipAisl
     c                   parm      'A'           pStat             1
     c                   parm      'Y'           pDrya             1
     c                   parm      101           nxtLoc
      /free
710fA     exsr chkforDate;
710fA
710fA  endsr;
710fA /end-free

      *----------------------------------------------------------------
      *  PrdQtyConv - Convert Production Quantity to Dakota Quantity
      *----------------------------------------------------------------

      /free
       begsr PrdQtyConv;

          // This routine converts Production Unit of Measure to normal
          // inventory uint of measures.  Production UOM is found in
          // the ITEMPRD file.

730eM    chain ($ppWhse:prditem) itemprd;
730eM    chain ($ppWhse:prditem) piritem;
         sqippq = ipprdq;
         squmq3 = itumq3;
         squmq2 = itumq2;
         total_qtyn=*zeros;
         total_qty1=*zeros;
         total_qty2=*zeros;

          if sqippq <> 0;

             // convert to lowest unit of measure per the
             // normal Dakota breakdowns
             select;
700mA          when squmq3 > 1;
                   eval(h) result = sqippq / (squmq3*squmq2);
                   if result <> 0;
                      result = total_prdq / result;
                      if intDec <> 0;
                         total_qty2 = intResult + 1;
                      else;
                         total_qty2 = intResult;
                      endif;
                      if result<0;
                         total_qty2 = %abs(total_qty2) * -1;
                      endif;
                   endif;
700mA        // Dakota with breakdown 1
700mA          when squmq2 > 1;
                   eval(h) result = sqippq / squmq2;
                   if result <> 0;
                      result = total_Prdq / result;
                      if intDec <> 0;
                         total_qty1 = intResult + 1;
                      else;
                         total_qty1 = intResult;
                      endif;
                      if result<0;
                         total_qty1 = %abs(total_qty1) * -1;
                      endif;
                   endif;
                other;
                   if sqippq <>0;
                      result = total_prdq / sqippq;
                      if intDec <> 0;
                         total_qtyn = intResult + 1;
                      else;
                         total_qtyn = intResult;
                      endif;
                      if result<0;
                         total_qtyn = %abs(total_qtyn) * -1;
                      endif;
                   endif;
             endsl;
          endif;

          // roll up quantities in normal quantity fields
          newQtyn=total_qtyn;
          newQty1=total_qty1;
          newQty2=total_qty2;

          zzupQty();

          total_qtyn = newQtyn;
          total_qty1 = newQty1;
          total_qty2 = newQty2;

       endsr;
      /end-free

710 A *------------------------------------------------------------------
710 A *  rmRdOpnQty - Loop through open Work ORder Details to calculate
710 A *               whether stock available for replen purposes and planning
710 A *------------------------------------------------------------------
710 A
710 A /free
710 A  begsr rmRdOpnQty;
710 A     sqlStmt = 'Select DISTINCT writem ' +
710 A               'from pwrkordr';
710 A
710 A     if wkRmAvl = 'O';
710 A        // If "O" is passed in look for only Work Orders either
710 A        // in Working or Released Status.  This is passed in when
710 A        // releasing Work ORders to know how much is required for
710 A        // order being released plus any already in work.  It can
710 A        // then compare total need to what is in LIN slots plus
710 A        // any open replenishments to understand what is required
710 A        sqlStmt = %trim(sqlStmt) + ' where wrstat=' +
710 A               sq + 'O' + sq;
710 A     else;
710 A        // other than replenishments we are looking for all open
710 A        // to understand if we have enough inventory for all
710 A        // released, working and planning orders
710 A        sqlStmt = %trim(sqlStmt) + ' where wrstat<>' +
710 A               sq + 'D' + sq + ' and ' +
710 A               'wrstat<>' + sq + 'C' + sq;
710 A     endif;
710 A
710 A     if wkItem <> *blanks;
710 A        // if raw material passed only process that one item
710 A        sqlStmt = %trim(sqlStmt) +
710 A                    ' and writem = ' + sq + wkItem + sq;
710 A     endif;
710 A
710 A     if $ppWo# <> *blanks and wkRmAvl=*blanks;
710 A        // if Work Order passed from planning with no item
710 A        sqlStmt = %trim(sqlStmt) +
710 A                    ' and wrwo# = ' + sq + $ppwo# + sq;
710 A     endif;
710 A
710 A     if wkLneNo <> *zeros;
710 A        sqlStmt = %trim(sqlStmt) + ' and wrmfgno=' + %char(wkLneno);
710 A     endif;
710 A
710 A     exec sql PREPARE rmQtysel FROM :SqlStmt;
710 A     exec sql DECLARE RMSummary SCROLL CURSOR FOR rmQtysel;
710 A     exec sql OPEN RMSummary;
710 A     exec sql fetch next from RMSummary into :pRmItm;
710 A
730dA     //if sqlStt <> '00000';
730aA     // exclude deletes and anything pass top level item for multi-level items
730aA     // itmLoop greater than one indicates a component call.  Those calls only
730aA     // loop through here to get requirements and should not stop because BOM
730aA     // is missing since that could be possible since stock for component could
730aA     // already exist.  For normal availablility checks itmLoop is zeroed in aaainit
730aA     if sqlStt <> '00000' and $ppDel<>'Y' and $ppDel<>'X'
730aA          and itmLoop <= 1;
710 A        // since very routine checks for this should never happen
710 A        error = *on;
710 A        $pMessage = 'Work Order has no open lines to release';
710 A        $preturn = '*INVWHSE';
             exsr unlockrec;
710 A        return;
710 A     endif;
710 A
710 A     dow sqlstt = '00000';
710 A       exsr rmQtyExists;
710 A       exec sql fetch next from RMSummary into :pRmItm;
710 A     enddo;
710 A     exec sql CLOSE RMSummary;
710 A
710 A     // if passing in single raw material we return a flag with Y if
710 A     // inventory is available and a N if no inventory is short
710 A     if ($ppItem <> *blanks and $ppItemu)
720aA        or ($ppWo# <> *blanks and $ppItem = *blanks);
710 A        $ppRmAvl = newStat;
710 A     endif;
710 A
710 A  endsr;
710 A /end-free
710 A
710 A *------------------------------------------------------------------
710 A *  rmQtyExists - Determine if raw materials exist for Work Order(s)
      *------------------------------------------------------------------

      /free
       begsr rmQtyExists;

          // get Session record for this Raw Material
          chain ($ppSessId:$ppWhse:pRmItm) pRmSum;
          if not %found(pRmSum);
             // update Raw Material Summary file for Planning
             pWhse = $ppWhse;
             pUser = %trim($ppUser);
             pPgm = %trim(#pgm);
      /end-free
720bA *
720bA *  if Creating Replenishment then send command to ensure
720bA *
720bAc                   if        $psubCmd = '*CRTWORPL'
720bAc                   eval      pObjLoc = '*CRTRPL'
     c                   eval      wkRplWo = $ppWo#
720bAc                   else
720bAc                   eval      pobjLoc = 'AFTERACT'
     c                   eval      wkRplWo = *blanks
720bAc                   endif
720bA *
710nDc*                  call      'R130001'
710nAc                   call      'R130002'
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
720bDc*                  parm      'AFTERACT'    pObjLoc
720bMc                   parm                    pObjLoc
     c                   parm                    pWhse
     c                   parm                    pRmItm
710nAc                   parm                    WkRplWo
710nAc                   parm                    wkLneNo
     c                   parm      ' '           poutstr
      /free
             // after trying to add look again.  should be there
             chain ($ppSessId:$ppWhse:pRmItm) pRmSum;
          endif;
          if %found(pRmSum);
             // record was found
             if (%check(' 0123456789.' : smrmdq) <> 0 or
                %check(' 0123456789.' : smrmdp) <> 0)
                  or rmExists = *off;
                // we should only turn off in this loop.  It comes
                // thru here for all raw materials on this bom.  If
                // one of them are short we should leave rmExists
                // turned off.
                rmExists = *off;
             else;
                rmExists = *on;
             endif;
          endif;

          // update all req. records for finished good with proper status
          if rmExists;
             newStat = 'Y';
          else;
             newStat = 'N';
          endif;

          // create cursor with selected records where we should change
         // raw material qty available flag
         sqlStmt = 'select wowhse, woitem, wowo#' +
           ' from pWrkOrd, pWrkordr ' +
           'where wowhse = wrwhse and woitem = wrfgi and writem = ' +
           sq + pRmItm + sq + ' and wostat<>' + sq + 'C' + sq +
           ' and wostat<>' + sq + 'D' + sq + ' and wowo#=wrwo# and ' +
           'wrstat<>' + sq + 'C' + sq + ' and wrstat<>' + sq + 'D' +
           sq;

          exec sql PREPARE sel FROM :SqlStmt;
          exec sql DECLARE RmQtyChg SCROLL CURSOR FOR SEL;
          exec sql OPEN RmQtyChg;

          exec sql fetch next from RmQtyChg into :wrkWhse, :wrkfgitm,
                                                      :wrkwo#;
          dow sqlstt = '00000';
             exec sql Update pWrkOrd
                    set wormavl = :newStat
                    where wowhse = :wrkWhse and woitem = :wrkfgitm
                               and wowo# = :wrkwo#;
             exec sql fetch next from RmQtyChg into :wrkWhse, :wrkfgitm,
                                                   :wrkwo#;
          enddo;
          exec sql close RmQtyChg;

       endsr;
710kA /end-free
710kA
710kA *---------------------------------------------------------------------
710kA *  SprdCost - Spread Material, LAbor and Overhead cost for Day Closed
710kA *---------------------------------------------------------------------
710kA
710kA /free
710kA
710kA  begsr SprdCost;
710kA
730bA      // if Costing is not turned on doing nothing and return
730bA      if opUseCost='N';
730bA         leavesr;
730bA      endif;
730bA
710kA     // This command/routine will get called when user closes given
710kA     // Production date.  This production date ($ppExpdt) is written
710kA     // to all files required to record cost information.  The first
710kA     // loop writes out material cost information and starts by looping
710kA     // the pWrkOrdRU (material used file by Work Order)
710kA
710kA     // First delete any cost records for given date to prevent duplication
        //if $ppPrimary = 'ALL';
710kA        exec sql delete from pCostWom where csmwhse=:$ppwhse and
710kA                                            csmprddate=:$ppExpdt;
        //else;
710kA   //   exec sql delete from pCostWom where csmwhse=:$ppwhse and
710kA   //                                       csmprddate=:$ppExpdt
710tA   //                                   and csmline=:$ppPrimary;
        //endif;
710kA
710kA     // now loop sql file to process all used material for the day
710kA     sqlStmt = 'select urwhse,urwo#,urrmi,urser,urfgi,urfgqty,' +
                    'urprjnq,urprjb1,urprjb2,urprjpq,uractnq,uractb1,' +
                    'uractb2,uractpq,urscnwgt,urtare,urprddte,urstat,' +
                    'icpocost,icavgcost,icstdcost,womfgno' +
710kA               ' from pWrkOrdRu left join itemcst ' +
710kA                           'on urwhse=icwhse and urrmi=icitem ' +
                       'left join pwrkord on urwhse=wowhse and ' +
                                'urwo#=wowo# ' +
710kA              'where urprddte=' + %char($ppExpdt) +
710kA              ' and urstat=' + sq + 'C' + sq +
710kA              ' order by urwhse,urwo#,urrmi';
710kA
710kA     exec sql PREPARE cstU FROM :SqlStmt;
710kA     exec sql DECLARE cstUsage SCROLL CURSOR FOR cstu;
710kA     exec sql OPEN cstUsage;
710kA
710kA     exec sql FETCH FIRST FROM cstUsage INTO :matCst:Nullind;
710kA     matCsthld = matCst;
          firstRec = *on;
710kA
710kA     dow sqlstt = sqlSuccess;
710kA        // check for No Cost values entered for item
710kA        exsr zzNullChk;
710kA        // If warehouse, work order or raw material change
710kA        // then write Material Cost record
710kA        if matcst.mcwhse <> matCsthld.mcwhse or
710kA           matcst.mcwo# <> matCsthld.mcwo#  or
710kA           matcst.mcrmi  <> matCsthld.mcrmi;
710kA           exsr wrtRMCost;     // Write Raw Material Cost record
710kA           exsr accumRMqty;    // Accumulate Raw Material Quantities used
710kA        else;
                firstrec=*off;
710kA           exsr accumRMqty;    // Accumulate Raw Material Quantities used
710kA        endif;
710kA        exec sql fetch next from cstUsage into :matCst:Nullind;
710kA     enddo;

          // if first Record is off this means a Raw MAterial was summed
          // and not written as last raw material.  It will write here.
          if not firstRec;
710kA        exsr wrtRMCost;     // Write Raw Material Cost record
          endif;
710kA     exsr wrtLabCost;       // Write Labor and Overhead Cost for Day
710kA
710kA  endsr;
710kA
710kA /end-free

      *----------------------------------------------------------------
      *  chkZstat  -   Zero Verify any Production Slots of "Z" status
      *                that were left behind for any reason.  This will
      *                keep these slots clean automaically as zeroed
      *----------------------------------------------------------------

      /free
       begsr chkZstat;

         // build sql to retrieve any left behind "Z" status
         // Production slots

         SqlStmt = 'select slot.* from slot,plined where  ' +
                    'slwhse=inwhse and slrlvl=inlneno and ' +
                    '(slaisl=inrcvaisl or slaisl=inpckaisl or ' +
                    'slaisl=instkaisl or slaisl=inwipaisl) ' +
                    ' and slstat = ' + sq + 'Z' + sq ;

         exec sql Prepare Selsl from :Sqlstmt;
         exec sql Declare Slotz scroll cursor for selsl;
         exec sql Open Slotz;
         exec sql Fetch first from Slotz into :slrec;

         if Sqlstt = sqlsuccess;
            dow Sqlstt = sqlsuccess;
               savever# = $slver#;
               clear $slot;
               clear $slot2;
               $slver# = savever#;

               $slwhseu = *on;
               $slwhse  = slwhse;

710aA          $slaislu = *on;
710aA          $slaisl  = slaisl;

               $slwhdpu = *on;
               $slwhdp = slwhdp;

               $sldispu = *on;
710dM          $sldisp = %trim(sldisp);

               $saitemu = *on;
               $saitem  = slitem;

               $sabyu   = *on;
               $saby    = $ppuser;

               $saemp#u = *on;
               $saemp# = #emp#;

               $saActionU = *on;
               $saAction = $ppAction;
               if $ppAction = ' ';
710fA           // if blank action from End of Day put PIU or PIW
710fA           // else use Scale transaction as PSC
710fA           select;
710fA              when $ppadjcde = 'P1' or $slAisl = inRcvAisl
710fA                                    or $slAisl = inWipAisl;
710fA                 $saAction = 'PIU';
710fA              when $ppadjcde = 'P2';
710fA                 $saAction = 'PIW';
710fA              other;
                     $saAction = 'PSC';
710fA           endsl;
               endif;
               $saToAreaU = *on;
               $saToArea = 'Slot';

               $dricommand = '*SLOT';
               $drisubcmd  = '%ZEROVFY';
               $drisys2upd = 'D';
               exsr zzDriCop2;
               $ppshparu = *off;
710hD    //    exec sql Fetch first from Slotz into :slrec;
710hA          exec sql Fetch next from Slotz into :slrec;
            enddo;
         endif;
         exec sql Close Slotz;

       endsr;

      /end-free
      *----------------------------------------------------------------
      *  setCustSlot  -  Locate/Set/Return Customer Item Slot
      *----------------------------------------------------------------

      /free
       begsr setCustSlot;

          chain ($ppwhse:$ppcust:$ppitem) pcslot;
          if %found(pcslot);
             // if slot found in xref file make sure it exists in slot file
             unlock pcslot;
710dM        chain ($ppwhse:$ppwhdp:%trim(csdisp)) slot2;
             if %found(slot2);
                // if found make sure status is correct and return disp
710dM           $ppshpar = %trim(sldisp);
710dM           $sldisp = %trim(sldisp);
                slstat = 'PR';
                update slrec2;
             else;
                // if not found add to slot file since found in cross
                // reference.  This means some customer orders could have
                // already allocated here
                unlock slot2;
                wkLoc = slrlvl;
710dM           $sldisp = %trim(sldisp);
710dM           $ppshpar = %trim(sldisp);
                exsr addSlot;
             endif;
          else;
             // if no cross reference set values for system to create on
             // return
             $ppshpar = ' ';
             $sldisp = ' ';
             wkLoc = 1;
          endif;

       endsr;
      /end-free

730aA *----------------------------------------------------------------
730aA *  updLoop - This now gets called from any process that needs to
730aA *            add, update to delete Work Orders.  All the code to
730aA *            handle multi-level Work Orders are called from here
730aA *----------------------------------------------------------------
730aA
730aAC     updLoop       begsr
730aA /free
730aA         clear woRec;
730aA         chain(n) ($ppWhse:$ppWo#) pWrkord;
730aA         if %found(pWrkOrd);
730dA            squmq2=woumq2;
730dA            squmq3=woumq3;
730aA            // Save Work Order for an update.  The first on an addition is
730aA            // saved in the GetNxtPwo for first addition
730aA            hldwo# = $ppwo#;
                 if $ppWipa = 'A';     // M16500 or LT120A sending in addition to existing
                    sumTwoGroups('$ppqty1':'+':$ppQty1:$ppQty2:$ppQty3
                                              :woMake:woMake1:woMake2);
                 endif;
730dA         else;
730dA            chain(n) ($ppWhse:$ppitem) piritem;
730dA            squmq2=itumq2;
730dA            squmq3=itumq3;
                 if squmq2=0;
                    squmq2=1;
                 endif;
                 if squmq3=0;
                    squmq3=1;
                 endif;
730aA         endif;

730aA         hldMakeQty  = $ppQty1; // Total Case Quantity
730dA         hldMakeQty1 = $ppQty3; // Total Breakdown 1 Qty
730dA         hldMakeQty2 = $ppQty2; // Total Breakdown 2 Qty
730aA         pMake       = $ppQty1; // Total Case Quantity
730dA         pMake1      = $ppQty2; // Total Breakdown 1 Quantity
730dA         pMake2      = $ppQty3; // Total Breakdown 2 Quantity
730aA         if pMake <> womake   //  Womake from file is what current wo has
730dA            or pMake1<>womake1
730dA            or pMake2<>womake2;
                 sumTwoGroups('pmakeqty':'-':pMake:pMAke1:pMake2
                                            :woMake:woMake1:woMake2);
730aA         else;
730aA            pMakeQty = pMake;
730aA            pMakeQty1 = pMake1;
730aA            pMakeQty2 = pMake2;
730aA         endif;
730aA
730aA         // if delete then reverse sign. no deletes come from M165002
730aA         if $ppDel='Y' or $ppDel='X';
730aA            hldMakeQty = -(hldMakeqty);
730aA            hldMakeQty1 = -(hldMakeqty1);
730aA            hldMakeQty2 = -(hldMakeqty2);
730aA            pMakeqty = -(pMakeQty);
730aA            pMakeqty1 = -(pMakeQty1);
730aA            pMakeqty2 = -(pMakeQty2);
730aA            pMake = -(pMake);
730aA            pMake1 = -(pMake1);
730aA            pMake2 = -(pMake2);
730aA         endif;
730aA
730aA         // define first level call in string holding multi-level calls in bom
730aA         pRmItm = *blanks;
730aA         bomItems = $ppItem + pRmItm + '|';
730aA
730aA         // call sub-procedure to get all calls on bom
730aA         bomItems =
730aA         prcpbomlvl($ppWhse:$ppItem:pRmItm:pMakeQty:$ppLneNo:bomItems);
730aA
730aA         // split returned item calls by bar character |
730aA         clear bomIary;
730aA         // call procedure that splits each called FG and Component into Array
730aA         bomIary = Split(bomItems:'|');
730aA         // Force top level quantity on all levels.  This will be
730aA         // changed once each level need is determined
730aA         clear bomNqty;
730aA         clear bomNqty1;
730aA         clear bomNqty2;
730aA         clear bomGqty;
730aA         clear bomGqty1;
730aA         clear bomGqty2;
730aA         clear bomXary;
730aA         itmLoop = 1;
730aA         dow itmLoop <501 and %trim(bomIary(itmLoop)) <> '';
730aA            bomNqty(itmLoop) = pMakeQty;
730aA            bomNqty1(itmLoop) = pMakeQty1;
730aA            bomNqty2(itmLoop) = pMakeQty2;
730aA            bomGqty(itmLoop) = hldMakeQty;
730aA            bomGqty1(itmLoop) = hldMakeQty1;
730aA            bomGqty2(itmLoop) = hldMakeQty2;
730aA            itmLoop = itmLoop + 1;
730aA         enddo;
730aA
730aA         // loop through all calls for Work Order in order via levels
730aA         wrkOrdsUpd = *blanks;
730aA         itmLoop = 1;
730aA         dow %trim(bomIary(itmLoop)) <> '' and itmLoop < 501;
730aA           if %subst(bomIary(itmLoop):16:15) = *blanks;
730aA              // main Work Order item will always start process with no Component
730aA              pFgItm  = %subst(bomIary(itmLoop):1:15);
730aA              $ppItem = %subst(bomIary(itmLoop):1:15);
730aA           else;
730aA              pFgItm  = %subst(bomIary(itmLoop):16:15);
730aA              $ppItem = %subst(bomIary(itmLoop):16:15);
730aA           endif;

730aA           // delete any records in RM Summary for this session
730aA           exec sql delete from PRMSUM
730aA                     where smSessid = :pSessId;

730aA           chain ($ppWhse:pFgItm) piritem;
730dA           if %found(piritem);
730dA              squmq2=itumq2;
730dA              squmq3=itumq3;
                   if squmq2=0;
                      squmq2=1;
                   endif;
                   if squmq3=0;
                      squmq3=1;
                   endif;
730dA           else;
730dA              squmq2=1;
730dA              squmq3=1;
730dA           endif;
730aA           chain ($ppWhse:pFgItm) itemprd;
730aA           if %found(itemprd);
                   if ipPrdFlg='C';
                      // can only have one open work order for a component at a time
                      // to keep track properly of what is needed compared to available
                      // and what is being produced
                      $ppcust=0;
                      $ppDest='P';
                      $ppOrig='P';
                   endif;
                   if $ppLneno = 0;
730aA                 $ppLneno = ipMfgno;
                   endif;
730aA           endif;

730aA           // force current mfgno on this change if one already exist
730aA           exec sql select woMfgno into :$ppLneno
730aA                from pWrkOrd where
730aA              wotype = :$ppDest and wocust = :$ppcust
730aA              and woitem = :$ppItem
730aA              and wostat<>'C'
730aA              and wostat<>'D'
                   fetch first row only;

                clear smrec;     // Clear record for RM Summary file
730aA           exsr chkforwo;   // calls DRIPROD to check  for Work Order
730aA
730aA           if $ppWo# <> '*NF' and $pMessage=*blanks and allowUpdate;
730aA              if $ppDel<>'Y' or ($ppDel='Y' and ipPrdflg='C' and
730aA                  %subst(bomIary(itmLoop):16:15) <> *blanks);
730aA                  // Only updates Work Order for Non Deletes transactions or
730aA                  // Deletes for top level call
730aA                  savever# = $ppver#;
730aA                  $ppver# = savever#;
730aA
730aA                  $ppmake = pMake;
730aA                  $ppmakeu = *on;
730dA                  $ppmake1 = pMake1;
730dA                  $ppmake1u = *on;
730dA                  $ppmake2 = pMake2;
730dA                  $ppmake2u = *on;
730aA                  if $ppstat='S';
730aA                     $ppstat = 'P';       // Status is Planning
730aA                  endif;
730aA                  $ppstatu = *on;
730aA
730aA                  savPrdFlg = ipPrdFlg;
730aA                  exsr updprodwo;
730aA                  ipPrdFlg = savPrdflg;
730aA
730aA                  if $ppDel = 'Y' or $ppDel = 'X';
730aA                     exsr gettotreq;
730aA                     // only delete when no other work orders are
730aA                     // calling and requirements are zero from prmsum
730aA                     if ipPrdflg='C' and ($ppstat='S' or $ppstat='P'
730aA                        or $ppStat='D') and deleteOK and
                             (($ppMake*squmq2*squmq3) + ($ppMake1*squmq3)
                                  + $ppMake2) <=0;
730aA                        exsr delWorkOrder;
730aA                     endif;
730aA                  endif;
730aA               else;
730aA                  // Delete Finished Good as requested by user
730aA                  if $ppDel='Y' and ($ppstat='S' or $ppstat='P'
730aA                        or $ppStat='D');
730aA                     if ipPrdFlg='C' and %subst(bomIary(itmLoop):16:15)
730aA                                = *blanks;
730aA                        exsr gettotreq;
730aA                        // only delete when no other work orders are
730aA                        // calling.
730aA                        if deleteOK;
730aA                          exsr delWorkOrder;
730aA                        else;
730aA                           $pMessage = 'Item ' + %trim(pFgItm) +
730aA                           ' has open ' + 'reqs and too little stock';
730aA                        endif;
730aA                     else;
730aA                        exsr delWorkOrder;
730aA                     endif;
730aA                  endif;
730aA               endif;
730aA            else;
730aA               // Else to <> *NF
730aA               if $pMessage = *blanks and $ppdel<>'Y' and $ppDel<>'X'
730aA                     and allowUpdate;
730aA                  exsr GetNxtPWO; // for new Work Order next WO number
730aA                  exsr crtProdWO;
730aA               endif;
730aA            endif;
730aA            if $pMessage <> *blanks;
730aA               $pReturn='*NOTOK';
730aA               leavesr;
730aA            endif;
730aA
730aA /end-free
730aAc     nextItem      tag
730aA /free
730aA           itmLoop = itmLoop + 1;
730aA           pMakeQty = bomNqty(itmLoop);
730dA           pMakeQty1 = bomNqty1(itmLoop);
730dA           pMakeQty2 = bomNqty2(itmLoop);
730aA
730aA         enddo;
730aA
730aA         // Return with beginning WO Number since a multi-level sends the first
730aA         // and updates all others
730aA         chain ($ppWhse:hldwo#) pWrkOrd;
              $ppWo# = hldwo#;
730aA         unlock pWrkOrd;
730aA
730aA /end-free
730aAC                   endsr

      *----------------------------------------------------------------
      *  updProdWo  Update Prodcution Work Order
      *----------------------------------------------------------------

     C     updProdWo     begsr
      /free

730dA        newWorkORder=*off;
730aA        exsr convertCBD;
730aA
710fA        // if MultiDay Line requested we should first find
710fA        // an available line and add one if necessary
710fA        if $ppMultiDy = 'Y';
710fA           exsr MultiDayLine;
710fA        endif;

             chain ($ppwhse:$ppWo#) pWrkOrd;
720 A        // if wip and current Work Order has zero Make Quantity then
720 A        // force zero on $ppMake to keep zero.  Do not use auto logic if
720 A        // user has overridden WIP order to zero
720 A        if ((womake*squmq2*squmq3) + (womake1*squmq3) + womake2)=0
                  and $pprogram<>'M16400F';
720 A           $ppMake = *zeros;
720 A           $ppMake1 = *zeros;
720 A           $ppMake2 = *zeros;
720 A        endif;

             $ppitem = woitem;
730dD        //if womake <> $ppMake
730dA        if (womake <> $ppMake or womake1<>$ppmake1 or womake2<>$ppmake2)
730aA           and wostat<>'R' and wostat<>'C' and wostat<>'D'
730aA           and wostat<>'W';
                $ppstat = 'P';
             endif;

             wkstat = wostat;
             wkwo# = wowo#;

730dA        // Breakdown difference into normal and breakdown
730dA        // based on uom definitions
730dA        squmq2=woumq2;
730dA        squmq3=woumq3;
730dA        sumTwoGroups('netdifn':'-':$ppMake
730dA                                  :$ppMAke1
730dA                                  :$ppMake2
730dA                                  :woMake:woMake1:woMake2);

KFSaA        if client = Kellys;
KFSaA          //if $ppMAke1 <> 0 or $ppMake2 <> 0;
KFSaA          //  $ppMake = $ppMake + 1;
KFSaA          //  $ppMake1=0;
KFSaA          //  $ppMake2=0;
KFSaA          //endif;
KFSaA        endif;

730dA        newQtyn = $ppMake;
730dA        newQty1 = $ppMake1;
730dA        newQty2 = $ppMake2;
730dA        zzUpQty();
730dA        womake = newQtyn;
730dA        womake1 = newQty1;
730dA        womake2 = newQty2;
730aA
730aA        // Remove any negatives so we can delete
730aA
730aA        if $ppMAke < 0;
730aA           $ppMake=0;
730aA        endif;
730aA
730dA        if $ppMAke1 < 0;
730dA           $ppMake1=0;
730dA        endif;
730aA
730dA        if $ppMAke2 < 0;
730dA           $ppMake2=0;
730dA        endif;
730aA
730aA        if $ppovrd < 0;
730aA           $ppovrd=0;
730aA        endif;
730aA
730aA        if $ppovr1 < 0;
730aA           $ppovr1=0;
730aA        endif;
730aA
730aA        if $ppovr2 < 0;
730aA           $ppovr2=0;
730aA        endif;
730aA
730dA        if $ppcnrm < 0;
730dA           $ppcnrm=0;
730dA        endif;
730aA
730aA        if $ppcbd1 < 0;
730aA           $ppcbd1=0;
730aA        endif;
730aA
730aA        if $ppcbd2 < 0;
730aA           $ppcbd2=0;
730aA        endif;

730dA        if (netdifn <> 0  or netdif1<>0 or netdif2<>0)
730aA           and wostat<>'R' and wostat<>'C' and wostat<>'D'
730aA           and wostat<>'W';
                wostat = 'P';
             endif;

             wodmdq = woavlq + $ppMake;
             woprio = $ppprio;
             woCustWo = $ppCustWo;

             // currently not writing but one record per customer/item
             // but we pass in Customer Order to write to XREF.  At some
             // point we might decide to write in key, but now just zero
             woCord = 0;
730aA        wocnrm=$ppcnrm;
730aA        wocbd1=$ppcbd1;
730aA        wocbd2=$ppcbd2;
730aA        woovrd = $ppovrd;
730aA        woovr1 = $ppovr1;
730aA        woovr2 = $ppovr2;
             update worec;
             if %error;
             endif;

730aA        // set flag to delete Work Order if dropped to zero quantity
730aA        if $ppmake=0 and $ppovrd=0 and $ppcbd1=0 and $ppcbd2=0 and
730aA           $ppmake1=0 and $ppcnrm=0 and $ppMake2=0 and $ppovr1=0
730dA           and $ppovr2=0;
730aA           //$ppDel='Y';
730aA           exsr delWorkOrder;
730aA        endif;

             // if Manufacturing line was changed in Header file
             // update in RM requirements file
             changeRmMfg = *off;
             if woMfgno <> $ppLneno or woCust <> $ppCust
                   or wotype <> $ppDest;
                changeRmMfg = *on;
                exec sql
                  update pWrkOrd
                  set woMfgNo = :$ppLneno, wocust = :$ppCust,
                      woType = :$ppDest
                  where wowhse = :$ppWhse
                     and wowo# = :$ppWo#;
             endif;

             exsr updRmWork;

      /end-free
     C                   endsr

      *----------------------------------------------------------------
      *  updRmUSAGE  Update Raw Material Requirements file for Qty Chg
      *----------------------------------------------------------------

      /free
       begsr updRmUsage;

          chain ($ppwhse:$ppwo#) pWrkOrd;
          if %found(pWrkOrd);
            // set several field values passed in from M16400F
             netdifn = womake - $ppMake;
             wkwo# = $ppWo#;
             $ppitem = woitem;
             unlock pWrkOrd;
             exsr updRmWork;
          endif;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  UpdRmWork  Update the Raw Materials Requirements file
      *----------------------------------------------------------------

      /free
       begsr updRmWork;


                      // if Manufacturing line was changed in Header file
          // change in rm requirements file
          if changeRmMfg;
             exec sql
                  update pWrkOrdr
                    set wrMfgNo = :$ppLneno
                       where wrwhse = :$ppWhse
                             and wrwo# = :$ppWo#;
          endif;
          avl1 = 0;
          avl2 = 0;
          avl3 = 0;
          // set current rm status before checking after changes
          rmExists = *on;
          // update raw materials requirement per the change
710cA     select;
730aM       when $psubcmd = '*CRTPRODWO' or $psubcmd = '*AVGPRD'
730aA             or ($psubcmd = '*UPDLOOP' and newWorkOrder)
710jA             or $psubcmd='*PRDQTY';
710cA          setll ($ppWhse:$ppitem) pbom;
710cA          reade ($ppWhse:$ppitem) pbom;
710cA       other;
710cA          setll ($ppWhse:$ppwo#) pwrkORdr;
710cA          reade ($ppWhse:$ppwo#) pwrkOrdr;
710cA       endsl;

710cA        dow 1=1;
710jA        if $psubcmd = '*CRTPRODWO' or $psubcmd='*AVGPRD'
710jA             or $psubcmd='*PRDQTY'
730aA             or ($psubcmd='*UPDLOOP' and newWorkOrder);
710cA           if %eof(pBom);
710cA              leave;
710cA           endif;
710cA        else;
710cA           if %eof(pwrkORdr);
710cA              leave;
710cA           else;
710cA              if wrstat= 'C' or wrstat= 'D';
710cA /end-free
710cAc                   goto      rdnext
710cA /free
710cA              endif;
710cA           endif;
710cA        endif;

710cA           // confirm whether raw material is on primary bom,
710cA           // substitution or dunamic bill
710jA           if $pSubCmd = '*CRTPRODWO' or $psubcmd='*AVGPRD'
710jA                or $psubcmd='*PRDQTY'
730aA                or ($psubcmd='*UPDLOOP' and newWorkORder);
710cA              chkForSub(bmwhse:$ppwo#:bmrmi:bmfgi:$ppLneno);
710fA              // this chain sets file IO for Work ORder Detail for adds
710fA              setll (bmwhse:$ppwo#:bmrmi:bmfgi:$ppLneno) pWrkOrdr;
710fA              reade (bmwhse:$ppwo#:bmrmi:bmfgi:$ppLneno) pWrkOrdr;
                   if %eof(pwrkordr) or not %equal(pwrkordr);
                      clear wrrec;
                   endif;
710cA           else;
710cA              chkForSub(wrwhse:wrwo#:writem:wrfgi:wrmfgno);
710cA           endif;

710cA           if bmtype <> ' '
                   and bmeffd <= %uns(%char(%Date():*Iso0))
                   and bmexpd >= %uns(%char(%Date():*Iso0));
                   // get addtional production item information
                   chain (bmWhse:bmRmi) piritem;
                   if %found(piritem);
                      chain (bmwhse:bmrmi) itemprd;
                      if %found(itemprd);
                        wrprimal = ipprim;
                         wrsubprme = ipsubp;
                      else;
                         wrprimal = ' ';
                         wrsubprme = 0;
                      endif;
                      // if quantity changed either add or update requirements
700rA
                         if %eof(pwrkordr);
                            // if no req. found zero variables
                            wrwhse = bmwhse;
                            wrwo# = wkwo#;
                            writem = bmrmi;
                            wrfgi = bmfgi;
                            wrmfgno = $ppLneno;
                            wrscrf = bmscrf;
                            wrqtyn = 0;
                            wrqty1 = 0;
                            wrqty2 = 0;
                            wrprdq = 0;
                         endif;

                         fgBrk1=0;
                         fgBrk2=0;
                         // Always gets uom quantities for level up
                         // to factor quantity needed if smaller portion
                         // needed than full quantity
                         exec sql select ipprdflg,itumq2,itumq3, itum2, itum3,
                                                                 itum1
                                into :fgType, :fgbrk1, :fgbrk2, :fgUom2,:fgUom3
                                                              , :fgUom1
                                    from piritem,itemprd
                                  where ipwhse=itwhse and ipitem=ititem
                                    and itwhse=:bmwhse and ititem=:bmfgi;

                         if fgBrk1=0;
                            fgBrk1=1;
                         endif;
                         if fgBrk2=0;
                            fgBrk2=1;
                         endif;

                         // add net difference of fg suggestion change
                         // to existing raw material req. taken to lowest
                         // level.  This will give new raw material req.
                         // in total and then it is brought back to highest
                        // level and updated in rm req. file (pwrkordr)
                         select;
                            when bmPrdq <> 0;
                               // When Production Unit of Measure and Case Adjustment
                               // simply extend Bill of Material need for a case
                               eval(h) newprdq  = (bmPrdq * netdifn) + wrPrdq;
730dA                          select;
730dA                             // Added Productions cases before select.  Now determine
730dA                             // what percentage partials are to the full case and add
730dA                             // that quantity to Production UOM required
730dA                            when fgBrk2>0;
730dA                              // when both breakdowns are defined consider
                                   // sum of both breakdown net differences divided
                                   // by the product of both breakdown values to
                                   // determine the percent of the defined case quantity
                                   // to apply based on the change
                                   result = ((netDif1*fgBrk2) +
730dA                                       netdif2)/(fgBrk1*fgBrk2);
730dA                              eval(h) newPrdq = newPrdq + (bmprdq*result);
730dA                            when fgBrk1>0;
                                   // when only one breakdown is defined simply
                                   // divide that breakdown by the defined breakdown
                                   // quantity to get the proper percent.  Full case
                                   // adjustments were made prior to select group above
730dA                              result = netdif1/fgBrk1;
730dA                              eval(h) newPrdq = newPrdq + (bmprdq*result);
730dA                          endsl;
                               newqtyn  = 0;
                               newqty1  = 0;
                               newqty2  = 0;
730eA                          prdItem=bmrmi;
730eA                          total_prdq=newPrdq;
730eA                          exsr prdQtyConv;
                            when itumq3 > 0;
                               newqtyn  = 0;
                               newqty1  = 0;
                               newprdq  = 0;
                               result = ((netDifn*fgBrk1*fgBrk2) +
                                         (netDif1*fgBrk2) +
730dA                                     netdif2)/(fgBrk1*fgBrk2);
                               newQty2 = (((bmqtyn * itumq2 * itumq3) +
                                           (bmqty1 * itumq3) +
                                             bmqty2)*result) +
                          // add current extended rm req. to lowest level
                                          ((wrqtyn * itumq2 * itumq3)+
                                           (wrqty1 * itumq3) +
                                            wrqty2);
                               if newQty2=0;
                                  newQty2=1;
                               endif;

                            when itumq2 > 0;
                               newprdq  = 0;
                               newqtyn  = 0;
                               newqty2  = 0;
730dA                          result = ((netdifn*fgBrk1) +
                                          netdif1)/(fgBrk1);
                               eval(h) newqty1= ((bmqtyn * itumq2) +
                                                 (bmqty1) *
                                                  result) +
                                                ((wrqtyn * itumq2) +
                                                  wrqty1);
                               if newQty1=0;
                                  newQty1=1;
                               endif;
                            other;
                               newprdq  = 0;
                               newqty2  = 0;
                               newqty1  = 0;
                               newqtyn =
                           // Case only adjustment
                                 (bmqtyn * netdifn) + wrqtyn;
                         endsl;

                         // if newqty exist then up to highest level
                         if newqtyn <> 0 or newqty1 <> 0 or newqty2 <> 0
                            or newPrdq <>0;
                            eval squmq3 = itumq3;
                            eval squmq2 = itumq2;
730aM                       zzupqty();
                            wrqtyn = newqtyn;
                            wrqty1 = newqty1;
                            wrqty2 = newqty2;
                            wrprdq = newprdq;
                            if wkstat <> 'C';
                               wrstat = 'O';
                            else;
                               wrstat = 'C';
                            endif;
                            // update raw material req. record with adj qty
                            pRmItm = writem;
                            if not %eof(pwrkordr);
                               update wrrec;
                            else;
                               write wrrec;
                            endif;
                         else;
                           // if quantity is now zero then delete rm req.
                           if %found(pwrkordr);
             //               wrstat = 'D';
                              wrqtyn = 0;
                              wrqty1 = 0;
                              wrqty2 = 0;
                              wrprdq = 0;
                              update wrrec;
                           endif;
                         endif;

                         // create pWRKORDPS records on Add Work ORder
                         // this file is used in PRimal/SubPrimal Processing
700rA                    exsr ConfirmPS;

                         // update Raw Material Summary file for Planning
                            pWhse = $ppWhse;
                            pUser = %trim($ppUser);
                            pPgm = %trim(#pgm);
      /end-free
700rDc*                  call      'R13000'
710nDc*                  call      'R130001'
710nAc                   call      'R130002'
     c                   parm                    pSessId
     c                   parm                    pUser
     c                   parm                    pPgm
     c                   parm      'AFTERACT'    pObjLoc
     c                   parm                    pWhse
     c                   parm                    pRmItm
710nAc                   parm      ' '           WkRplWo
710nAc                   parm                    wkLneNo
     c                   parm      ' '           poutstr
      /free
                      if rmExists = *on;
                         exsr rmQtyExists;
                      endif;
                   endif;  // item master found
                endif;  // BOM entry effective
710cA /end-free
710cAc     rdnext        tag
710cA /free
710jD    // if $pSubCmd = '*CRTPRODWO';
710jA     if $pSubCmd = '*CRTPRODWO' or $psubcmd='*AVGPRD'
710jA         or $psubcmd='*PRDQTY'
730aA         or ($psubcmd='*UPDLOOP' and newWorkORder);
             reade ($ppwhse:$ppitem) pBom;
710cA     else;
710cA        reade (wrwhse:wrwo#) pwrkORdr;
710cA     endif;

          enddo;
710jD   //  if $pSubCmd = '*CRTPRODWO' or $psubcmd='*AVGPRD'
710jA     if $pSubCmd = '*CRTPRODWO' or $psubcmd='*AVGPRD'
710jA         or $psubcmd='*PRDQTY'
730aA         or ($psubcmd='*UPDLOOP' and newWorkOrder);
710cA        setll (*loval) pBom;
710cA     else;
710cA     setll (*loval) pWrkOrdr;
710cA     endif;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  verifyClo - Verify Close Work Order data
      *----------------------------------------------------------------

      /free
       begsr verifyClo;

         // Verify Warehouse sent in
          if not $ppwhseu;
             error = *on;
             $pMessage = 'Warehouse must be sent';
             $preturn = '*INVWHSE';
          endif;

         // Verify Work Order
          chain ($ppwhse:$ppwo#) pWrkOrd;
          if not %found(pWrkOrd);
             error = *on;
             $pmessage = 'Invalid Work Order';
             $preturn = '*INVWO';
          else;
             if wostat ='C' or wostat = 'D';
                error = *on;
                $pmessage = 'Work Order either deleted or already closed';
                $preturn = '*INVSTAT';
             endif;
             unlock pWrkOrd;
          endif;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  verifyCrtRPL - Verify Create Raw Material Replenishment
      *----------------------------------------------------------------

      /free
       begsr verifyCrtRPL;

         // Verify Warehouse sent in
          if not $ppwhseu;
             error = *on;
             $pmessage = 'Warehouse must be sent';
             $preturn = '*INVWHSE';
          endif;

710bA     // confirm BOM exist for Work ORder before allowing release
720fD     //    chain (wrwhse:wrfgi) itemprd;
720fA           chain ($ppwhse:$ppitem) itemprd;
710bA             if ipprdflg = 'F';
710bA              chain (ipwhse:ipitem) pbom;
710bA                if not %found(pbom);
710bA                  $pMessage = 'No BOM has been setup (PBOM)';
710bA                  $preturn = '*NORMREQ';
710bA                  error = *on;
710bA                  leavesr;
710bA                EndIf;
710bA             endif;

         // Verify Work Order
          chain ($ppwhse:$ppwo#) pWrkOrd;
          if not %found(pWrkOrd);
             error = *on;
             $pmessage = 'Invalid Work Order';
             $preturn = '*INVWO';
          else;
730aD        //if wostat <> 'S' and wostat <> 'P';
730aA        if wostat <> 'S' and wostat <> 'P' and wostat<>'R' and wostat<>'W';
                error = *on;
                $pmessage = 'Work Order must be in planning stages';
                $preturn = '*INVSTAT';
             else;
                // verify raw requirements exist and open
                rmcntvalid = *off;
                setll ($ppwhse:$ppwo#) pWrkOrdr;
                reade ($ppwhse:$ppwo#) pWrkOrdr;
                dow not %eof(pWrkOrdr);
                   if wrstat = 'O';
                      rmcntvalid = *on;
                      leave;
                   endif;

                   reade ($ppwhse:$ppwo#) pWrkOrdr;
                enddo;
                unlock pWrkOrdr;
                if not rmCntValid;
                   error = *on;
                   $pmessage = 'No valid Raw Material Requirements' +
                                 ' (PWRKORDR)';
                   $preturn = '*NORMREQ';
                endif;
             endif;
             unlock pWrkOrd;
710nA
710nA     // Delete session records for PRMSUM so it will
710nA     // recreate for specific line associated to given
710nA     // Work Order release.  IT only does this delete
710nA     // in the CRTWORPL command
710nA     exec sql delete from PRMSUM
710nA          where smSessid = :pSessId;
          endif;

       endsr;
      /end-free

      *----------------------------------------------------------------
      *  verifyDel - Verify Delete Work Order
      *----------------------------------------------------------------

      /free
       begsr verifyDel;

         // Verify Warehouse sent in
          if not $ppwhseu;
             error = *on;
             $pmessage = 'Warehouse must be sent';
             $preturn = '*INVWHSE';
          endif;

         // Verify Work Order
          chain ($ppwhse:$ppwo#) pWrkOrd;
          if not %found(pWrkOrd);
             error = *on;
             $pmessage = 'Invalid Work Order';
             $preturn = '*INVWO';
          else;
             if wostat ='R' or wostat = 'W';
                error = *on;
                $pmessage = 'Work Order already Released or Working';
                $preturn = '*INVSTAT';
             endif;
             unlock pWrkOrd;
          endif;

       endsr;
      /end-free
      *----------------------------------------------------------------
      *  verifyMIN - Verify MIN MFG Line slot
      *----------------------------------------------------------------

      /free
       begsr verifyMIN;
       endsr;
      /end-free

      *----------------------------------------------------------------
      *  verifyPAR - Verify that item is valid production item
      *----------------------------------------------------------------

      /free
       begsr verifypar;
       endsr;
      /end-free

      *----------------------------------------------------------------
      *  verifyQty - Verify Quantity Adjustment prior to update
      *----------------------------------------------------------------

      /free
       begsr verifyqty;

710cA     // ensure rmqty if off from any previous run
710cA     rmadj = *off;

710dA     // Either setup or find and return respective production
710dA     // slot for this quantity adjustment
710dA     // DO NOT get slot if one was sent in
710dA     if not $ppshparu and not $pppararu
710dA        and $ppuci = '';
710dA        exsr getPrdSlot;
710dA     endif;

710dA     // Confirm that LIN slot still exists to prevent
710dA     // *** Box Breaker  ***
710dA     if $ppAction = 'BXB';
700iA        setll ($ppwhse) plined;
710dA        reade ($ppwhse) plined;
710dA        if not %equal(plined);
710dA           $pprcva = 'LIN';
710dA        else;
710dA           $pprcva = inrcvaisl;
700iA           $pprcva = 'LIN';
710dA        endif;
710dA        if getMin;
710dA           exsr getPrdSlot;
710dA        else;
710dA           // if getmin off turn on to verify LIN
710dA           // line slot still exists then turn off
710dA           getmin = *on;
710dA           exsr getPrdSlot;
710dA           getmin = *off;
710dA        endif;
710dA     endif;

710dA     // if errors occur in validating or creating slot return with error
710dA     if $drireturn <> ' ' and $drireturn <> '*OK'
710dA          and $drireturn <> 'INSLOT';
710dA        $pMessage = $drimessage;
710dA        $preturn = $drireturn;
710dA        error = *on;
710dA        leavesr;
710dA     endif;

710cA     // determine one time for each work order how many waste items are
710cA     // defined at a Work Order level.  In the calcUsageQty procedure
710cA     // called in wrtRmUSage routine later in this loop this value will
710cA     // determine whether to use BOM quantities or scale weight for usage
710cA     numWastelines = 0;
710cA     setll ($ppWhse:$ppwo#) pWrkORdr;
710cA     reade ($ppWhse:$ppwo#) pWrkORdr;
710cA     dow not %eof(pWrkORdr);
710cA        chkForSub(wrwhse:wrwo#:writem:wrfgi:wrmfgno);
710cA        if bmusep = 'Y';  // Waste Recorded
710cA           numWastelines = numWastelines + 1;
710cA        endif;
710cA        reade ($ppWhse:$ppwo#) pWrkORdr;
710cA     enddo;
       endsr;
      /end-free

710tA *----------------------------------------------------------------
710kA *  ZZEditLAbor  Edit Labor data to ensure all is good
710tA *----------------------------------------------------------------
710tA
710tAC     zzEditLabor   begsr
710tA /free
730bA         error = *off;
730bA         // ensure Costing is turned on
730bA         if opUseCost = 'N';
730bA            error = *on;
730bA            $preturn  = 'COSTOFF';
710tA            $pmessage = 'Costing is not turned on and configured';
730bA            leavesr;
730bA         endif;
730bA
710tA         error = *off;
710tA         // ensure passed Task Code is valid for this environment
710tA         // Use Customer WO field to pass Labor Task Code
710tA         chain (%trim($ppCustWo)) task;
710tA         if not %found(task);
710tA            error = *on;
710tA            $preturn  = 'INVLDTASK';
710tA            $pmessage = 'Task code ' + %trim(%trim($ppCustWo)) + ' is not'
710tA                        + ' in the Task File';
710tA            leavesr;
710tA         endif;
710tA
              // if Work ORder or Mfg Line make it here as *AL cut off instead of
              // *ALL convert to ALL for "All"
              if $ppWo#='*AL';
                 $ppWo#='ALL';
              endif;

              if $ppPRimary='*AL';
                 $ppPrimary='ALL';
              endif;

710tA         // File pWrkord and pLine are checked just prior to this in routine
710tA         // rtvScale.  Nothing else hits those records between there and here.
710tA         // Therefore, I am simply checking the status from there for errors
710tA         if %trim($ppWo#) <> 'ALL' and $ppwo#<>*blanks;
710tA            chain ($ppWhse:$ppWo#) pWrkord;
710tA            if not %found(pWrkOrd);
710tA               error = *on;
710tA               $preturn  = 'INVLDWO';
710tA               $pmessage = 'Work Order ' + %trim($ppWo#) + ' is no longer '
710tA                         + 'valid';
710tA               leavesr;
710tA            endif;
710tA         endif;
710tA
710tA         if %trim($ppPrimary) <> 'ALL' and $ppprimary<>*blanks;
710tA            Non_Num_Posn = %check(numbers:%trim($ppPrimary));
710tA            if Non_Num_Posn = *zeros;
710tA               hld_Mfgno = %dec(%trim($ppPrimary):3:0);
710tA               chain ($ppWhse:hld_mfgno) pLined;
710tA               if not %found(pLined);
710tA                  error = *on;
710tA                  $preturn  = 'INVLDLNE';
710tA                  $pmessage = 'Mfg Line ' + %trim($ppPrimary) + ' is'
710tA                            + ' not valid';
710tA                  leavesr;
710tA               endif;
710tA            else;
710tA               error = *on;
710tA               $preturn  = 'INVLDLNE';
710tA               $pmessage = 'Mfg Line ' + %trim($ppPrimary) + ' is'
710tA                         + ' not valid';
710tA               leavesr;
710tA            endif;
710tA         endif;
710tA
710tA /end-free
710tAC                   endsr

710tA *----------------------------------------------------------------
710tA *  ZZpirTranp  Write Production information for Transaction
710tA *              This is used to spread cost at End of Day
710tA *----------------------------------------------------------------
710tA
710tAC     zzpirTranp    begsr
710tAc*   Also Create record in PIRTRANP (Production Module) file
710tAc*   which tracks whether transaction should be spread across
710tAc*   one Mfg Line or all, and whether it is spread across
710tAc*   one Work Order or All Work Orders.  This record is used
710tAc*   in production to determine what lines and work orders
710tAc*   get this labor allocated to them
710tA /free

               // Make sure Line and Work Order are set to *ALL
               // if they come in blank
               if $ppPrimary = *blanks;
                  $ppPRimary = 'ALL';
               endif;

               if $ppWo# = *blanks;
                  $ppWo# = 'ALL';
               endif;

               // Convert Labor line
               If %trim($ppPrimary) <> 'ALL' and
                 %trim($ppPrimary) <> *Blanks;
                 monitor;
                    // if numeric we convert line 3 to 003
                    $ppPrimary = %editC(%Dec($ppPrimary:3:0):'X');
                 on-error;
                    // on error we do nothing and pass as is
                 endmon;
               EndIf;
710tA          chain(n) ($ppWhse:@ptrn#) pirTranp;
710tA          if not %found(pirTranp);
710tA             ppWhse = $ppWhse;
710tA             ppTrn# = @ptrn#;
710tA             ppwo# = %trim($ppWo#);
710tA             ppLine = %trim($ppPrimary);
710tA             ppctyp = costType;
                  // get shift date if available
                  exec sql select ptdshftday into :date6
                          from pirtrand where ptdwhse=:$ppWhse
                               and ptdtran= :@ptrn#
                               fetch first row only;
                  if sqlStt = sqlSuccess;
                     prddte = %dec(%char(%date(date6:*ymd):*iso0):8:0);
                  else;
                     prddte = %Int( %Char(%date() : *ISO0 ) );
                  endif;
710tA             // if *CLSLAB Close Production Transaction then
710tA             // it gets here by doing an idle transaction which
710tA             // will generate PIRTRANP record with ALL Work
710tA             // Orders time since no specific clock on Work Order
710tA             if $psubCmd = '*CLSLAB';
710tA                ppwo# = 'ALL';
710tA             endif;
710tA             GetCurrStamp();
710tA             ppSysts = currStampsys;
710tA             ppLocTs = currStampLoc;
710tA             ppUcTs = currStampUc;
710tA             ppJob = #job;
710tA             ppuser = #user;
710tA             ppJobNbr = #jobnbr;
710tA             write pprec;
710tA          endif;
710tA /end-free
710tAC                   endsr
710tA
710tA *----------------------------------------------------------------
710tA *  ZZStdTrans  Write Production Module Transactions for Standard
710tA *              Labor Defined in Production Module (M235xx)
710tA *----------------------------------------------------------------
710tA
710tAC     zzStdTrans    begsr
710tA /free
730aA      // if Costing is not turned on doing nothing and return
730aA      if opUseCost='N';
730aA         leavesr;
730aA      endif;
710kA
710kA      // Build array with Work Orders and Quantities closed for
710kA      // given Mfg Line and Production Date being closed
           hldLine = $ppPrimary;
710kA      clear aryCJobs;
710kA      clear compQty;
710kA      clear compLne;
710tA      clear clneLne;
710tA      clear clneQty;
710kA      recCnt = *zeros;
710kA      exec sql select count(*) into :recCnt
710kA                      from pWrkORdRu where urwhse=:$ppWhse
710kA                       and urprddte= :$ppExpDt and urstat<>'C'
710kA                       and urstat<>'D';
710kA
710kA      SqlStmt='select urwo#,urprddte,urwhse,urstat,womfgno,' +
710kA              'woqtyp+woqtys,woitem ' +
710kA              'from pWrkOrdRu,pwrkord where ' + %char($ppWhse) +
710kA              ' =urwhse and urprddte=' + %char($ppExpDt)  +
710kA              ' and urstat = ' + sq + 'C' + sq +
710kA              ' and urwhse=wowhse and urwo#=wowo#';
710kA
710kA      exec sql Prepare PrdCp from :Sqlstmt;
710kA      exec sql Declare ProdCp scroll cursor for PrdCp;
710kA      exec sql Open ProdCp;
710kA      exec sql Fetch first from ProdCp into :urwo#,:urprddte,:urwhse,
710kA                                            :urstat,:womfgno,:urfgqty,
710kA                                            :woitem;
710kA      sltcnt = 0;
710kA
710kA      dow sqlstt = sqlsuccess;
710kA         // load array with all Work Orders and Quantity
710kA         // produced for given line for given Production Date
710kA         exccnt = %lookup(urwo#:compWo:1);
710kA         if exccnt <> *zeros;
710kA            // add quantity produce to quantity element
                 // Total produced in each line so simply replace previous qty
710kA            compQty(exccnt) =  urFgQty;
710kA         else;
710kA            // since Work Order was not found setup in next array element
710kA            sltcnt = sltcnt + 1;
710kA            compLne(sltcnt) = womfgno;
710kA            compItm(sltcnt) = woITem;
710kA            compWo(sltcnt) = urwo#;
710kA            compQty(sltcnt) = urFgQty;
710kA         endif;
710tA
710kA         exec sql Fetch next from ProdCp into :urwo#,:urprddte,:urwhse,
710kA                                               :urstat,:womfgno,:urfgqty,
710kA                                               :woitem;
710kA      enddo;
710kA      exec sql Close ProdCp;

710tA      // get total per line for later spreading algorithms
           sltcnt=1;
           qtyele=0;
           dow sltcnt<501 and compLne(sltcnt)<>*zeros;
710tA         qtyele = %lookup(compLne(sltcnt):clneLne:1);
710tA         if qtyele <> *zeros;
710kA            clneQty(qtyele) = clneQty(qtyele) + compQty(sltcnt);
710tA         else;
710kA            qtycnt = qtycnt + 1;
710kA            clneLne(qtycnt) = complne(sltcnt);
710kA            clneQty(qtycnt) = compQty(sltcnt);
710tA         endif;
              sltcnt = sltcnt +1;
           enddo;

710tA   //  loop through Standard records for this day to ensure they
710tA   //  are removed if they exist.  User could be spreading cost
710tA   //  after making adjustments and original Standards spread
710tA   //  at EOD should be deleted first
710tA
710tA   //  $ppExpDt will have Shift Date passed.  When ran automatically
710tA   // it runs at 6am and uses previous day as close date
710tA   // as PIRTRANP records are written they use Shift date for Trans
710tA          SqlStmt = 'Select pirtrand.*' +
710tA             ' from pirtrand left outer join pirtranp ' +
710tA             ' on ptdwhse = ppwhse and ptdtran = pptrn# ' +
710tA             'where ppctyp=' + sq + 'S' + sq +
710tA             ' and ptdshftday=' + %subst(%char($ppExpdt):3:6);
710tA
710tA          exec sql Prepare DelCs from :Sqlstmt;
710tA          exec sql Declare DelCost scroll cursor for DelCs;
710tA          exec sql Open DelCost;
710tA          exec sql Fetch first from DelCost into :ptdRecSql;
710tA
710tA          // Remove Beginning Day and Endday but leave
710tA          // any other non Production Module Transactions
710tA          if sqlStt = sqlSuccess;

710tA             dow sqlStt = sqlSuccess;
710tA                setll (s_ptdwhse:s_ptdempnum:s_ptdshftday) pirtrand13;
710tA                reade (s_ptdwhse:s_ptdempnum:s_ptdshftday) pirtrand13;

710tA                dow not %eof(pirtrand13);
710tA                   if (d_ptdtask = 'ENDDAY' or d_ptdtask='BEGDAY')
                              and d_ptdtran<>*zeros;
710tA                      delete ptdrec;
710tA                   exec sql delete from pirtran where
710tA                         ptwhse=:d_ptdwhse and
710tA                         pttrn#=:d_ptdtran;
710tA                   endif;
710tA                   reade (s_ptdwhse:s_ptdempnum:s_ptdshftday) pirtrand13;
710tA                enddo;

710tA                // release record lock at end of loop
710tA                setll *loval pirtrand13;
710tA
710tA                   exsr zzTrnAbort;
710tA                   exec sql Fetch next from DelCost into :ptdRecSql;
710tA             enddo;
710tA             exec sql Close DelCost;
710tA          endif;
710tA
710tA   //  Delete any orphaned records in PIRTRANP
710tA          exec sql delete from pirtranp as a
710tA                where (select count(*) from pirtran as b
710tA                 where a.ppwhse=b.ptwhse and a.pptrn#=b.pttrn#)=0;
710tA
710tA   //  Create Labor Transactions for Production Module Standard
710tA   //  time defined at Closing.  Any records defined in
710tA   //  pLabCstLne with a cost type of "S" for Standard versus
710tA   //  "A" for Actaul will generate a respective Transaction for
710tA   //  the passed Shift date to be spread cost wise.  Otherwise
710tA   //  it will only spread cost clocked for actual transactions that
710tA   //  have PROD as category on Task
710tA          costType = 'S';
710tA          SqlStmt = 'Select * ' +
710tA                       ' from pLabCstLne' +
710tA                       ' where lcwhse=' + %char($ppWhse) +
710tA                       ' and lcctyp=' + sq + 'S' + sq + ' and lcstat=' +
710tA                       sq + 'A' + sq;
710tA
710tA          exec sql Prepare StdLb from :Sqlstmt;
710tA          exec sql Declare pLabCst scroll cursor for StdLb;
710tA          exec sql Open pLabCst;
710tA          exec sql Fetch first from pLabCst into :lcRecSql;
710tA
710tA          dow Sqlstt = sqlsuccess;
710tA             // prep parms to create Labor Transaction for Standard Def
710tA             // with punch in time
710tA             dayNbr = %rem(%diff(%date($ppexpdt):d'0001-01-01':*days):7);
710tA                If (dayNbr = 0 and %subst(s_lcdywk:2:1)='Y'   // Monday
710tA                 or dayNbr = 1 and %subst(s_lcdywk:3:1)='Y'   // Tuesday
710tA                 or dayNbr = 2 and %subst(s_lcdywk:4:1)='Y'   // Wednesday
710tA                 or dayNbr = 3 and %subst(s_lcdywk:5:1)='Y'   // Thursday
710tA                 or dayNbr = 4 and %subst(s_lcdywk:6:1)='Y'   // Friday
710tA                 or dayNbr = 5 and %subst(s_lcdywk:7:1)='Y'   // Saturday
710tA                 or dayNbr = 6 and %subst(s_lcdywk:1:1)='Y'); // Sunday
710tA                   // if the Standard line is defined for the day of
710tA                   // the week this day represents and it either matches
710tA                   // the line passed in or *ALL meaning it should be
710tA                   // spread across all Lines then we will create
710tA                  if %trim(s_lcline) <> '*ALL';
710tA                     Non_Num_Posn = %check(numbers:%trim(s_lcLine));
710tA                     if Non_Num_Posn = *zeros;
710tA                        // convert known numeric line to see if worked today
710tA                        qtyele = %lookup(%dec(%trim(s_lcLine):3:0):
710tA                                        clnelne:1);
710tA                     else;
710tA                        // if not numeric must be ALL defined to be counted
710tA /end-free
710tAc                   goto      nxtlcRec
710tA /free
710tA                     endif;
710tA                   endif;
710tA
710tA                   if qtyele = *zeros and %trim(s_lcline)<>'*ALL';
710tA                    // if qtyele is zero this means this numeric line had no
710tA                    // work today since nothing was in array element clneLne
710tA /end-free
710tAc                   goto      nxtlcRec
710tA /free
710tA                   endif;
710tA
710tA                   $ppCustwo = s_lctask;   // Task Code
710tA                   if s_lcbhr = *zeros;    // Beginning Hour of work
710tA                      $ppCord = 070000;
710tA                   else;
710tA                      $ppCord = s_lcbhr * 10000;
710tA                   endif;
710tA                   $ppWo# = 'ALL';   // Standards cannot specify specific Work Orders
710tA                   if s_lcline = '*ALL' or s_lcline=*blanks;
710tA                      $ppPrimary = 'ALL';
710tA                   else;
710tA                      if %trim(s_lcline) <> '*ALL';
710tA                         Non_Num_Posn = %check(numbers:%trim(s_lcline));
710tA                         if Non_Num_Posn = *zeros;
710tA                            hld_Mfgno = %dec(%trim(s_lcline):3:0);
710tA                            $ppPrimary = s_lcline;
710tA                            chain ($ppWhse:hld_mfgno) pLined;
710tA                            if not %found(pLined);
710tA                               error = *on;
710tA                               $preturn  = 'INVLDLNE';
710tA                               $pmessage = 'Mfg Line ' + %trim(lcline) +
710tA                                           ' is not valid';
710tA                            else;
710tA                               //$ppPrimary = 'ALL';
710tA                            endif;
710tA                         else;  // when passed line not ALL and not numeric
710tA                            $ppPrimary = 'ALL';
710tA                         endif;
710tA                      else; // when passed line is *ALL
710tA                         $ppPrimary = 'ALL';
710tA                      endif;
710tA                   endif;
710tA                   timeUser = s_lcucde;
710tA                   taskType='D';
710tA                   clsDte = $ppExpdt;
710tA                   clsTim = $ppCord;
710tA                   clsTs  = CreateTS(clsDte: clsTim);
710tA                   // plus one second ensures begday is created at or later
710tA                   // than begin of shift.  Otherwise endday transaction will
710tA                   // close GEN as 1 minute and put remaining time on ENDDAY
710tA                   $ppExpdt = %DEC(%CHAR(%date(clsTs):*ISO0):8:0);
710tA                   $ppCord =  %DEC(%CHAR(%time(clsTs):*ISO0):6:0);
710tA                   exsr zzTrnCrtStart;
710tA                   $pptrn# = @ptrn#;
710tA                   // Create Timestamp with begin time for shift, add hours
710tA                   // defined to work in Standard and then generate close
710tA                   clsDte = $ppExpdt;
710tA                   clsTim = $ppCord;
710tA                   clsTs  = CreateTS(clsDte: clsTim);
710tA                   clsTs  = clsTs + %hours(s_lchrsd);
710tA                   clsDte   = %DEC(%CHAR(%date(clsTs):*ISO0):8:0);
710tA                   clsTim  =  %DEC(%CHAR(%time(clsTs):*ISO0):6:0);
710tA                   timeUser = s_lcucde;
710tA                   //$pptrn#=*zeros;
710tA                   $ppCustWo = 'ENDDAY';
710tA                   exsr zzTrnEndc;
710tA                   clsDte = *zeros;
710tA                   clsTim = *zeros;
710tA                endif;
710tA /end-free
710tAc     nxtlcRec      tag
710tA /free
710tA
710tA             exec sql Fetch next from pLabCst into :lcRecSql;
710tA          enddo;
710tA          exec sql Close pLabCst;
710tA          taskType=' ';
               $ppPrimary = hldLine;
710tA
710tA /end-free
710tAc                   endsr
710tA *----------------------------------------------------------------
710tA *  ZZCHKTRAN  Check to confirm not a dup Trans to current Trans
710tA *----------------------------------------------------------------
710tA
710tAC     zzChkTran     begsr
710tA /free
710tA            exec sql
710tA              select t.pttask,p.ppwo#,p.ppline
710tA                     into :sqlTask indicator :iTask,
710tA                          :sqlwo# indicator :iwo#,
710tA                          :sqlline indicator :iLine
710tA                     from pirtran as t left outer join pirtranp as p
710tA                     on t.ptwhse=p.ppwhse and t.pttrn#=p.pptrn#
710tA                        left outer join piruser as u on
710tA                           t.ptemp#=u.usemp# where
710tA                     t.ptstat='2' and u.uscode=:timeuser
710tA                     fetch first row only;
710tA
710tA            if iTask<>*zeros or sqlStt<>sqlSuccess;
710tA               sqlTask=*blanks;
710tA            endif;
710tA
710tA            if iwo#<>*zeros or sqlStt<>sqlSuccess;
710tA               sqlwo#='ALL';
710tA            endif;
710tA
710tA            if iLine<>*zeros or sqlStt<>sqlSuccess;
710tA               sqlLine='ALL';
710tA            endif;
710tA
710tA            if sqlTask = $ppCustwo and
710tA               sqlLine = $ppPrimary and
710tA               sqlwo# = $ppwo#;
710tA               trnNeeded = *off;
710tA            else;
710tA               trnNeeded = *on;
710tA            endif;
710tA /end-free
710tAC                   endsr
710tA *----------------------------------------------------------------
710tA *  ZZTRNCLSI  Close Indirect Transaction
710tA *----------------------------------------------------------------
710tA
710tAC     zztrnclsi     begsr
710tA
710tAC                   call      'ADJTRAN2'
710tAC                   parm      '*CLOSEI'     @pcmd            10
710tAC                   parm      #pgm          @pprg            10
710tAC                   parm      '*BATCH'      @ptype            8
710tAC                   parm      $ppTrn#       @ptrn#            7 0
710tAC                   parm      ' '           @ptask            6
710tAC                   parm      0             @pwhse            3 0
710tAC                   parm      ' '           @pwhdp            5
710tAC                   parm      ' '           @pstyp            1
710tAC                   parm      0             @pcube            9 3
710tAC                   parm      0             @pswgt            9 2
710tAC                   parm      0             @ppcs             5 0
710tAC                   parm      0             @paisl            5 0
710tAC                   parm      0             @pqty1            5 0
710tAC                   parm      0             @pqty2            5 0
710tAC                   parm      0             @pqty3            5 0
710tAC                   parm      ' '           @prte             5
710tAC                   parm      ' '           @ppo              9
710tAC                   parm      ' '           @pgrp1            1
710tAC                   parm      ' '           @pgrp2            1
710tAC                   parm      clsdte        @pdate            8 0
710tAC                   parm      clstim        @ptime            6 0
710tAC                   parm      timeuser      @puser           10
710tAC                   parm      ' '           @prtn             8
710tAC                   parm      ' '           @pmsg             4
710tA
710tAC                   endsr
710tA *----------------------------------------------------------------
710tA *  ZZTRNENDC  End Current transaction
710tA *----------------------------------------------------------------
710tA
710tAC     zztrnendc     begsr
      *
     c                   select
     c                   when      $ppcustwo='ENDDAY'
     c                   eval      @ptask='ENDDAY'
     c                   eval      @pcmd='*ENDDAY'
     c                   when      $ppcustwo='CLOSE '
     c                   eval      @ptask='      '
     c                   eval      @pcmd='*CLOSE '
     c                   other
     c                   eval      @ptask=*blanks
     c                   eval      @pcmd='*ENDCUR'
     c                   endsl
710tA
710tAc                   exsr      zzchkTran
     c
710tAc                   if        trnNeeded
710tAC                   call      'ADJTRAN2'
710tAC                   parm                    @pcmd            10
710tAC                   parm      #pgm          @pprg            10
710tAC                   parm      '*BATCH'      @ptype            8
710tAC                   parm      $pptrn#       @ptrn#            7 0
710tAC                   parm                    @ptask            6
710tAC                   parm      0             @pwhse            3 0
710tAC                   parm      ' '           @pwhdp            5
710tAC                   parm      ' '           @pstyp            1
710tAC                   parm      0             @pcube            9 3
710tAC                   parm      0             @pswgt            9 2
710tAC                   parm      0             @ppcs             5 0
710tAC                   parm      0             @paisl            5 0
710tAC                   parm      0             @pqty1            5 0
710tAC                   parm      0             @pqty2            5 0
710tAC                   parm      0             @pqty3            5 0
710tAC                   parm      ' '           @prte             5
710tAC                   parm      ' '           @ppo              9
710tAC                   parm      ' '           @pgrp1            1
710tAC                   parm      ' '           @pgrp2            1
710tAC                   parm      clsdte        @pdate            8 0
710tAC                   parm      clstim        @ptime            6 0
710tAC                   parm      timeuser      @puser           10
710tAC                   parm      ' '           @prtn             8
710tAC                   parm      ' '           @pmsg             4
710tAc                   endif
710tA
710tAC                   endsr
710tA *----------------------------------------------------------------
710tA *  ZZTRNCRTSTART  Create and Start transaction
710tA *----------------------------------------------------------------
710tA
710tAC     zztrncrtstart begsr
710tA
710tAc                   exsr      zzchkTran
     c
710tAc                   if        trnNeeded
710tAC                   call      'ADJTRAN2'
710tAC                   parm      '*CRTSTRT'    @pcmd
710tAC                   parm      #pgm          @pprg
710tAC                   parm      '*BATCH'      @ptype
710tAC                   parm      0             @ptrn#
710tAC                   parm      $ppCustwo     @ptask
710tAC                   parm      $ppWhse       @pwhse
710tAC                   parm      ' '           @pwhdp
710tAC                   parm      ' '           @pstyp
710tAC                   parm      0             @pcube
710tAC                   parm      0             @pswgt
710tAC                   parm      0             @ppcs
710tAC                   parm      0             @paisl
710tAC                   parm      0             @pqty1
710tAC                   parm      0             @pqty2
710tAC                   parm      0             @pqty3
710tAC                   parm      ' '           @prte
710tAC                   parm      ' '           @ppo
710tAC                   parm      ' '           @pgrp1
710tAC                   parm      ' '           @pgrp2
710tAC                   parm      $ppExpDt      @pdate
710tAC                   parm      $ppCord       @ptime
710tAC                   parm      timeuser      @puser
710tAC                   parm      ' '           @prtn
710tAC                   parm      ' '           @pmsg
710tAc                   if        taskType<>'I' and taskType<>' '
710tAc                   exsr      zzPirtranp
710tAc                   endif
710tAc                   endif
710tAC                   endsr
710tA *----------------------------------------------------------------
710tA *  ZZTRNIDLE   Start and IDLE transaction.
710tA *----------------------------------------------------------------
710tA
710tAC     zztrnidle     begsr
710tA
710tA *   For Production defined employees in file PLABCSTLNE the
710tA *   system will always put them on their default task instead
710tA *   of IDLE.  The reason for this is to spread their cost at
710tA *   end of day instead of between operations going to indirect.
710tA *   This routine only gets called when a Close transaction is
710tA *   called from MRC instead of the CRTSTRT, and therefore no new
710tA *   task.
710tA *
710tA /free
710tA        // since this is production transaction, if IDLE is sent
710tA        // we look to see if default exist in production.  If so
710tA        // we place on default task per pLabCstLne.  If Idle Time
             // recorded is checked on pLabCstLne record we record IDLE
             // time
710tA        if %trim($ppCustWo) = 'IDLE';
                // first look for default task per employee.  If more than
                // one is found the first is used.  If no default task is
                // found then first task found for employee is used.  if
                // no definition is found at all then use IDLE
710tA           exec sql select lctask,lcidle into :@ptask,:pIdle
710tA                     from pLabCstLne
710tA                       where lcucde=:timeuser and lcdefault='Y'
710tA                      fetch first row only;
                if sqlstt <> sqlSuccess;
710tA              exec sql select lctask,lcidle into :@ptask,:pIdle
710tA                        from pLabCstLne
710tA                          where lcucde=:timeuser
710tA                          fetch first row only;
                endif;
710tA
710tA           if sqlStt <> sqlSuccess;
710tA              @pTask = 'IDLE';
                else;
                   // if found and defined to record idle force idle
                   if pIdle='Y';
                      @pTask='IDLE';
                   endif;
710tA           endif;
710tA
710tA        else;
710tA           // if not IDLE put on task passed in
710tA           @pTask = %trim($ppCustWo);
710tA        endif;
710tA /end-free
710tAc                   exsr      zzchkTran
     c
710tAc                   if        trnNeeded
710tAC                   call      'ADJTRAN2'
710tAC                   parm      '*CRTSTRT'    @pcmd
710tAC                   parm      #pgm          @pprg
710tAC                   parm      '*BATCH'      @ptype
710tAC                   parm      0             @ptrn#
710tAC                   parm                    @ptask
710tAC                   parm      $ppWhse       @pwhse
710tAC                   parm      ' '           @pwhdp
710tAC                   parm      ' '           @pstyp
710tAC                   parm      0             @pcube
710tAC                   parm      0             @pswgt
710tAC                   parm      0             @ppcs
710tAC                   parm      0             @paisl
710tAC                   parm      0             @pqty1
710tAC                   parm      0             @pqty2
710tAC                   parm      0             @pqty3
710tAC                   parm      ' '           @prte
710tAC                   parm      ' '           @ppo
710tAC                   parm      ' '           @pgrp1
710tAC                   parm      ' '           @pgrp2
710tAC                   parm      0             @pdate
710tAC                   parm      0             @ptime
710tAC                   parm      timeuser      @puser
710tAC                   parm      ' '           @prtn
710tAC                   parm      ' '           @pmsg
710tAc                   if        @pTask <> 'IDLE'
710tAc                             and taskType<>'I' and taskType<>' '
710tAc                   exsr      zzPirtranp
710tAc                   endif
710tAc                   endif
710tAC                   endsr

710tA*----------------------------------------------------------------
710tA*  ZZTRNABORT  Abort/Undo a transaction.
500dA*----------------------------------------------------------------
710tA
710tAC     zztrnabort    begsr
710tA
710tAC                   call      'ADJTRAN2'
710tAC                   parm      '*ABORT'      @pcmd            10
710tAC                   parm      #pgm          @pprg            10
710tAC                   parm      '*BATCH'      @ptype            8
710tAC                   parm      s_ptdtran     @ptrn#            7 0
710tAC                   parm      ' '           @ptask            6
710tAC                   parm      0             @pwhse            3 0
710tAC                   parm      ' '           @pwhdp            5
710tAC                   parm      ' '           @pstyp            1
710tAC                   parm      0             @pcube            9 3
710tAC                   parm      0             @pswgt            9 2
710tAC                   parm      0             @ppcs             5 0
710tAC                   parm      0             @paisl            5 0
710tAC                   parm      0             @pqty1            5 0
710tAC                   parm      0             @pqty2            5 0
710tAC                   parm      0             @pqty3            5 0
710tAC                   parm      ' '           @prte             5
710tAC                   parm      ' '           @ppo              9
710tAC                   parm      ' '           @pgrp1            1
710tAC                   parm      ' '           @pgrp2            1
710tAC                   parm      0             @pdate            8 0
710tAC                   parm      0             @ptime            6 0
710tAC                   parm      ' '           @puser           10
710tAC                   parm      ' '           @prtn             8
710tAC                   parm      ' '           @pmsg             4
710tA
710tAC                   endsr
      *----------------------------------------------------------------
      *  zzdricop2  Call DRICOP2
      *----------------------------------------------------------------

     c     zzDriCop2     begsr
      *
     c                   eval      wkError = *off
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   eval      $dridata = $slot
     c                   eval      $dridata2 = $slot2

     c                   endsl
      *
     c                   select
      *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP2'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP2'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     c                   eval      $slot2 = $dridata2
     c                   endsl

     c                   endsr

710dA *----------------------------------------------------------------
710dA *  wheresBom  -  Loop to determine where BOM is located
710dA *----------------------------------------------------------------
710dA
710dAC     wheresBom     begsr
710dA /free
710dA        // This command will return either BOM, SUBS or DYNB stating
710dA        // whether the Work Order BOM is located within the normal
710dA        // BOM file (PBOM), the Substitute BOM (PBOMSUB), or the
710dA        // PBOMVERS (Dynamic BOM).  If any entries are found in the
710dA        // Dynamic BOM file then it all is found there.  However, if
710dA        // anything is found in PBOMSUB it could indicate only one item
710dA        // but could be more than one.  Depends how many were subed.
710dA        setll ($ppwhse:$ppwo#) pWrkordr;
710dA        reade(n) ($ppwhse:$ppwo#) pWrkordr;
710dA        $ppCustWo = *blanks;
710dA        dow not %eof(pWrkORdr);
710dA           if (wrstat <> 'D' and wrstat <> 'C');
710dA              select;
710dA                 when chkForSub(wrwhse:wrwo#
710dA                                :writem:wrfgi:wrmfgno) = 'PBOM';
710dA                    if $ppCustWo <> 'PBOMSUB' and $ppCustWo<>'PBOMVERS';
710dA                       $ppCustWo = 'PBOM';
710dA                    endif;
710dA                 when chkForSub(wrwhse:wrwo#
710dA                                :writem:wrfgi:wrmfgno) = 'PBOMSUB';
710dA                    if $ppCustWo<>'PBOMVERS';
710dA                       $ppCustWo = 'PBOMSUB';
710dA                    endif;
710dA                 when chkForSub(wrwhse:wrwo#
710dA                                :writem:wrfgi:wrmfgno) = 'PBOMVERS';
710dA                    $ppCustWo = 'PBOMVERS';
                   endsl;
710dA           endif;
710dA           reade(n) ($ppwhse:$ppwo#) pWrkordr;
710dA        enddo;
710dA
710dA /end-free
710dAC                   endsr

710cA *----------------------------------------------------------------
710cA *  WrtByProducts  Generate any ByProducts as Alternate items to
710cA *                 be produced for given Work Order
710cA *----------------------------------------------------------------
710cA
710cAC     WrtByProducts begsr
710cA /free
710cA
710cA       // loop through raw material list to determine any byproducts
710cA       // allowed to be produced from given finished good on work order
710cA
710cA       sltcnt =1;
710cA       dow sltcnt < 501 and aryRMI(sltcnt)<>*blanks;
                // loop through any available ByProducts for primary raw material
                setll ($ppWhse:aryRMI(sltcnt)) itemprdbp;
                reade ($ppWhse:aryRMI(sltcnt)) itemprdbp;
               dow not %eof(itemprdbp);
750bA             chain ($ppSessid:$ppWhse:iybpitm) palteritem;
750bA             if not %found(palteritem);
                    alsessid = $ppSessId;
                    alwhse = $ppwhse;
                    alitem = iybpitm;
                    alwo = $ppwo#;
                    algrpts = %timestamp();
                    write alrec;
750bA             else;
750bA               unlock palteritem;
750bA             endif;
                  reade ($ppWhse:aryRMI(sltcnt)) itemprdbp;
710cA          enddo;
               sltcnt = sltcnt + 1;
710cA       enddo;
         endsr;
      /end-free

      *----------------------------------------------------------
      *  wrtRMUsage   Write Raw Material usage record by extending
      *               production quantity by bill of material qty
      *----------------------------------------------------------

      /free
       begsr wrtRMUsage;

        result=0;  // Used to determine factor with weight used
        if $ppadjcde <> 'P4';     // Prod Label Delete
          // if Scale and Back Flush action codes automatically add
          // record to this file.  End of Day Usage and Waste recording
          // update records that already exist and are open.  Function
          // RMQTY is called as values are entered.  It will not allow
          // Production quantities to exceed what is open production in
          // this file (sum of urprjxxx - uractxxx fields that have a
          // status of "O" for open).

          if $ppAction = 'PSC' or $ppAction = 'PBF';
             // see if defined to use Production Quantity
             // if a scale transaction it comes from a bill of material
             // loop, otherwise it uses the passed item
             chain (bmwhse:bmrmi) itemprd;
             if %found(itemprd);
                chain (bmwhse:bmrmi) piritem;
                if not %found(piritem);
                   itumq2 = 0;
                   itumq3 = 0;
                endif;
             else;
                ipprdq = 0;
             endif;
             // a create from the scale should always be an add but
             // I check just in case
             chain (bmwhse:$ppwo#:bmrmi:$ppser#) pWrkOrdRu;
             if not %found(pWrkOrdRu);
                clear urrec;
                urwhse = bmwhse;
                urwo# = $ppwo#;
                urser = $ppser#;        // serial number from label file
                urprddte = prddte;
                urrmi = bmrmi;
             endif;

             // now setup the add transaction
             urfgi = bmfgi;
             urfgqty = $ppqty1;
             if $ppqty1 < 0;
                urscnwgt = -1 * $ppwgt;
                urtare = -1 * $pptare;
             else;
                urscnwgt = $ppwgt;
                urtare = $pptare;
             endif;

710cA        // if raw material not used in actual product do not record scan weight
710cA        if ipusep <> 'Y';
710cA           urscnwgt = *zeros;
710cA        endif;

             // This part of routine is executed when scale transaction is generating
             // transactions.  Whatever we generate here as actual is what will be
             // recorded further down during backflush or either at end of day when
             // manually closing and applying.
             calcUsageQty();

             // if back flush go ahead and record same values in actual
             // since the back flush would have already impacted inventory.
             // otherwise make actual zero since that will be completed
             // manually by someone at end of day
             if bmbckf = 'Y';
                uractpq = urprjpq;
                uractnq = urprjnq;
                uractb1 = urprjb1;
                uractb2 = urprjb2;
                urstat = 'C';
             else;
                uractpq = 0;
                uractnq = 0;
                uractb1 = 0;
                uractb2 = 0;
                urstat = 'O';
             endif;

             write urrec;   // create usage record
710 A        if %error;
710 A        endif;

          else;

             // Look for records to update.  This else represents
             // action code PIU which is the end of day action code
             // for recording usage.  This routine will loop through
             // open transactions and close all that it takes to
             // consume the quantity used sent in to this routine.

             // see if defined to use Production Quantity
             // if a scale transaction it comes from a bill of material
             // loop, otherwise it uses the passed item
             chain ($ppwhse:$ppitem) itemprd;
             if %found(itemprd);
                chain ($ppwhse:$ppitem) piritem;
                if not %found(piritem);
                   itumq2 = 0;
                   itumq3 = 0;
                endif;
             else;
                ipprdq = 0;
             endif;
             wkumq2=itumq2;
             wkumq3=itumq3;
             if itumq2 = 0;
                wkumq2 = 1;
             endif;
             if itumq3 = 0;
                wkumq3 = 1;
             endif;

             // convert incoming quantity to lowest UOM
             // if production quantity used it is always converted
             // to normal warehouse quantity before updating inventory
             if ipprdq <> 0;
700eA           inQty = (($ppqty1*-1)*(wkumq2*wkumq3)) +
700eA                   (($ppqty2*-1)*(wkumq3)) +
700eA                     $ppqty3*-1;
710pA           // Save incoming quantity adjustment as normal quantity prior to
710pA           // being converted to Production.  It is possible that the item
710pA           // could be defined with Production Breakdown but the BOM is using
710pA           // a normal quantity breakdown.  The code below in this if statement
710pA           // is converting inQty to Production UOM quantity since IPPRDQ is defined.
710pA           // We will revert back to inQtyNrm is bom line is found to be normal
710pA           // quantity instead of Production.
710pA           inQtyNrm = inQty;
                select;
                   when itumq3 <> 0;
700eD   //            eval(h) inqty = (($ppqty3 * -1) *
700g    //700eA                 eval(h) inqty = inqty *
700g    //700eA                                 (ipprdq/(itumq2*itumq3))+.4999;
700eD   //                            (ipprdq/(itumq2*itumq3)))+.4999;
700g                 inQty = %dech(inQty * (ipprdq/(itumq2*itumq3)):9:4);
700g                 if inQty - %int(inQty) <> 0;     //Round any fraction up
700g                   inQty = %int(inQty) + 1;
700g                 endif;
                   when itumq2 <> 0;
700eD   //            eval(h) inqty = (($ppqty2 * -1) *
700g    //            eval(h) inqty = inqty *
700g    //700eA                                 (ipprdq/itumq2)+.4999;
700eD   //                            (ipprdq/itumq2))+.4999;
700g                 inQty = %dech(inqty * (ipprdq/itumq2):9:4);
700g                 if inQty - %int(inQty) <> 0;     //Round any fraction up
700g                   inQty = %int(inQty) + 1;
700g                 endif;
                   other;
700eD   //            eval(h) inqty = (($ppqty1 * -1) * ipprdq)+.4999;
700g    //700eA                 eval(h) inqty = (inqty * ipprdq)+.4999;
700g                 inQty = %dech(inqty * ipprdq:9:4);
700g                 if inQty - %int(inQty) <> 0;     //Round any fraction up
700g                   inQty = %int(inQty) + 1;
700g                 endif;
                endsl;
             else;
                inQty = (($ppqty1*-1)*(wkumq2*wkumq3)) +
                        (($ppqty2*-1)*(wkumq3)) +
                          $ppqty3*-1;
             endif;

             // build sql to retrieve daily production for selected
             // Raw Material for open production

             SqlStmt='select * ' +
                     'from pWrkOrdRu where  ' + %char($ppWhse) +
                     ' =urwhse and urrmi=' + sq + $ppitem + sq +
                     ' and urstat <> ' + sq + 'D' + sq +
                     ' and urstat <> ' + sq + 'C' + sq;

             exec sql Prepare Prdsl from :Sqlstmt;
             exec sql Declare ProdDy scroll cursor for Prdsl;
             exec sql Open ProdDy;
             exec sql Fetch first from ProdDy into :PrdDay;

             dow sqlstt = sqlsuccess;

710pA           // If item defined with PRoduction UOM but Work
710pA           // Work ORder is defined to use normal Dakota
710pA           // quantities we should force the use of normal quantities
710pA           if ipprdq <> 0 and urprjpq = 0;
710pA              ipprdq = 0;
710pA              inqty = inQtyNrm;
710pA           endif;
                // total production qty used at lowest level
                if ipprdq <> 0;   // production uom used?
                   currqty = urprjpq - uractpq;
                else;            // normal uom used...
                   currqty = ((urprjnq-uractnq)*(wkumq2*wkumq3)) +
                             ((urprjb1-uractb1)*(wkumq3)) +
                               urprjb2-uractb2;
                endif;

                // if quantity read(currqty) is smaller than requested
                // adjustment qty (inqty) then close transaction
                if inQty >= currqty;
                   // add full production quantity to actual since it is
                   // less than the requested adjustment
                   select;
                      when ipprdq <> 0;
                         uractpq = uractpq + currqty;
                      when itumq3 <> 0;
                         uractb2 = uractb2 + currqty;
                      when itumq2 <> 0;
                         uractb1 = uractb1 + currqty;
                      other;
                         uractnq = uractnq + currqty;
                   endsl;
                   inQty = inQty - currqty;
                else;
                   // when remaining adjustment is less than current
                   // production amount just take remaining adjustment
                   select;
                      when ipprdq <> 0;
                         uractpq = uractpq + inQty;
                      when itumq3 <> 0;
                         uractb2 = uractb2 + inQty;
                      when itumq2 <> 0;
                         uractb1 = uractb1 + inqty;
                      other;
                         uractnq = uractnq + inqty;
                   endsl;
                   inQty = 0;
                endif;

                if ipprdq <> 0;    // Production item ?
                   if uractpq >= urprjpq;
                      urstat = 'C';
                   else;
                      urstat = 'O';
                   endif;
                else;             // else using normal uom
                   if ((uractnq)*(wkumq2*wkumq3)) +
                      ((uractb1)*(wkumq3)) +
                        uractb2 >=   +
                      ((urprjnq)*(wkumq2*wkumq3)) +
                      ((urprjb1)*(wkumq3)) +
                        urprjb2;
                       urstat = 'C';
                   else;
                       urstat = 'O';
                   endif;
                endif;

                exec sql
                     update pWrkOrdru
                     set urstat = :urstat,
                         uractnq = :uractnq, uractb1 = :uractb1,
                         uractb2 = :uractb2, uractpq = :uractpq
                     where urwhse = :urwhse and urwo# = :urwo#
                       and urrmi = :urrmi and urser = :urser
                       and urstat = 'O';

                // if the full adjustment has been applied leave
                if inQty <0;
                   leave;
                endif;

                exec sql Fetch next from ProdDy into :PrdDay;

             enddo;

             // if remaining adjustment value exits after last record
             // then go back and apply remaining value to last record
             // processed.  This should only happen with Production UOM
             // records since rounding to a case can exceed actual usage.

             if inQty > 0;
                exec sql Fetch last from ProdDy into :PrdDay;
                select;
                   when ipprdq <>0;
                      uractpq = uractpq + inqty;
                   when itumq3 <>0;
                      uractb2 = uractb2 + inqty;
                   when itumq2 <>0;
                      uractb1 = uractb1 + inqty;
                   other;
                      uractnq = uractnq + inqty;
                endsl;
                urstat = 'C';
                exec sql
                     update pWrkOrdru
                     set urstat = :urstat,
                         uractnq = :uractnq, uractb1 = :uractb1,
                         uractb2 = :uractb2, uractpq = :uractpq
                     where urwhse = :urwhse and urwo# = :urwo#
                       and urrmi = :urrmi and urser = :urser;
             endif;

             exec sql Close ProdDy;

          endif;
        endif;

       endsr;
      /end-free

      *----------------------------------------------------------
      *  wrtAlterRec   Write Alternate Item Records for Work Ord
      *----------------------------------------------------------

      /free
       begsr wrtAlterRec;

          exec sql delete from pAlterItem
               where alSessid = :pSessId;

          for sltcnt = 1 to 500;
             if aryFGI(sltcnt) <> '';
                alsessid = $ppSessId;
                alwhse = $ppwhse;
                alitem = aryFGI(sltcnt);
                alwo = $ppwo#;
                algrpts = %timestamp();
                write alrec;
             endif;
          endfor;
          // kde - 01/29/2017 - I think we should add by-products associated with primary
          // BOM to the valid alternate items.  While this will be a raw material it should
          // be changed to allow since it will be valid to record by-products to produce
          // ground beef and stew meat.

       endsr;
      /end-free

      *----------------------------------------------------------
      *  UnlockRecs  -  Unlock records before leaving with error
      *----------------------------------------------------------

      /free
          begsr UnlockRec;
             unlock pcslot;
             unlock slot2;
             unlock slot3;
             unlock pwrkord;
             unlock pwrkordr;
             unlock pwrkord1;
             unlock pwrkordru;
             unlock pwrkordps;
             unlock prmsum;
             unlock palteritem;
             unlock prddate;
             unlock prddate1;
          Endsr;
      /END-FREE

710kA *----------------------------------------------------------------
710kA *  wrtLabCost - Build and Write Labor and Overhead Cost Data
710kA *----------------------------------------------------------------
710kA
710kA /free
710kA      begsr wrtLabCost;
710kA
          sleep(5);

710kA     // First delete any Labor cost for passed day to close
          if $ppPrimary = 'ALL';
710kA        exec sql delete from pCostWol where cslwhse=:$ppwhse and
710kA                                            cslprddate=:$ppExpdt;
          else;
710kA        exec sql delete from pCostWol where cslwhse=:$ppwhse and
710kA                                            cslprddate=:$ppExpdt
710tA                                        and cslline=:$ppPrimary;
          endif;
710kA      clear cslrec;
710kA
710tA      // Build SQL and Spread Standard Labor Cost First
710tA      SqlStmt='select ptdwhse,ppline,ptdstat,lcsrte,lcdywk,' +
710tA              'ptdsec,ppwo#,ptdtask,lcbenrt,lcohpct,lcempno ' +
710kA              'from pirtranp left outer join pirtrand on ' +
710tA              'ppwhse=ptdwhse and pptrn#=ptdtran left outer ' +
710tA              'join pLabCstLne on ppwhse=lcwhse and ptdtask=lctask ' +
                   ' and ptdempnum = lcempno ' +
710tA              'where ptdstat=' + sq +'4' + sq + ' and ptdshftday=' +
710tA               %subst(%char($ppExpdt):3:6) +
710tA               ' and lcctyp=' + sq + 'S' + sq;
710tA
710tA      exec sql Prepare TrnCs from :Sqlstmt;
710tA      exec sql Declare TranCs scroll cursor for TrnCs;
710tA      exec sql Open TranCs;
710tA      exec sql Fetch first from TranCs into :TranCsRec;
710tA
710tA      dow sqlstt = sqlSuccess;
710tA         if %trim(trnLine) <> 'ALL' and %trim(trnLine)<>*blanks;
710tA            Non_Num_Posn = %check(numbers:%trim(trnLine));
710tA            if Non_Num_Posn = *zeros;
710tA               // convert known numeric line to see if worked today
710tA               qtyele = %lookup(%dec(%trim(trnLine):3:0):clnelne:1);
710tA            else;
710tA               // if not numeric must be ALL defined to be counted
710tA               qtyele=*zeros;
710tA            endif;
710tA         endif;
710tA         if trnstat = '4' and (qtyele <> *zeros  or
710tA            (recCnt = *zeros and trnLine = 'ALL'));
710tA                // at this point we determine the line matches or is
710tA                // defined as all and the day of the week matches so
710tA                // we should apply that labor cost across all the
710tA                // respective Work Orders
710tA                cslwhse = $ppWhse;
710tA                cslprddate = $ppExpdt;
710tA                csltype = 'L';
710tA                cslempcnt = 1;
710tA                cslstdrate = trnRate;
710tA                cslseq = trnEmp;
710tA                cslcsdtwk = trndywk;
710tA                csltask = trnTask;
710tA                GetCurrStamp();
710tA                csllocts = CurrStampLoc;
710tA                cslsysts = CurrStampSys;
710tA                cslucts  = CurrStampUC;
710tA                csljob = #job;
710tA                csluser = #user;
710tA                csljobnbr = #jobnbr;
710tA                // loop thru each Work Order and apply percentage of
710tA                // total labor cost based on quantity produced for
710tA                // specific Work Order compared to total produced
710tA                // all day for either All if All or specific Mfg Line
710tA                // if specific Line
710tA                sltcnt=1;
710tA                dow compWo(sltcnt) <> *blanks and sltcnt <500;
710tA                   select;
710tA                      when trnline='ALL' and recCnt = 0;
710kA                         // write cost for *ALL records if all lines closed
710tA                         cslline = compLne(sltcnt);
710tA                         cslwo = compWo(sltcnt);
710tA                         cslfgitm = compItm(sltcnt);
710tA                         cslfgqty = compQty(sltcnt);
710tA                         cslwoqty = %xFoot(compQty);
710tA                         if %xFoot(compQty) = *zeros;
710tA                            cslcstasgn = *zeros;
710tA                            cslsecs = *zeros;
710tA                         else;
710tA                            cslcstasgn = ((trnrate/60/60)*trnsecs) *
710tA                                      (compQty(sltcnt) / %xFoot(compQty));
710tA                            cslsecs    = trnsecs *
710tA                                      (compQty(sltcnt) / %xFoot(compQty));
710tA                         endif;
710tA                         write cslrec;
710tA                      when trnline = %editc(compLne(sltcnt):'X');
710tA                         // write records for Line Specific cost records
710tA                         cslwo = compWo(sltcnt);
710tA                         cslline = compLne(sltcnt);
710tA                         cslfgitm = compItm(sltcnt);
710tA                         cslfgqty = compQty(sltcnt);
710tA                         qtyele = %lookup(compLne(sltcnt):clneLne:1);
710tA                         if qtyele <> *zeros;
710tA                            qtyforlne = clneQty(qtyele);
710tA                         else;
710tA                            qtyforlne = *zeros;
710tA                         endif;
710tA                         cslwoqty = qtyforlne;
710tA                         if qtyforlne = *zeros;
710tA                            cslcstasgn = *zeros;
710tA                            cslsecs = *zeros;
710tA                         else;
710tA                            cslcstasgn = ((trnRate/60/60)*trnsecs) *
710tA                                 (compQty(sltcnt) / qtyforlne);
710tA                            cslsecs    = trnsecs *
710tA                                 (compQty(sltcnt) / qtyforlne);
710tA                         endif;
710tA                         write cslrec;
710tA                   endsl;
710tA                   sltcnt = sltcnt + 1;
710tA                enddo;
710tA            // populate labor cost record for line based on definition
710tA            // and spread across all work orders for that line
710tA         endif;
710tA         exec sql Fetch next from TranCs into :TranCsRec;
710tA      enddo;
710tA      exec sql Close TranCs;
710kA
710tA      // Build SQL and Spread Actual Clocked Labor after Standards
710tA      SqlStmt='select ptdwhse,ppline,ppwo#,ptdtask,ptdstat,ptdempnum,' +
710tA              'ptdshft,sum(ptdsec) ' +
710kA              'from pirtranp left outer join pirtrand on ' +
710tA              'ppwhse=ptdwhse and pptrn#=ptdtran left outer ' +
710tA              'join task on ptdtask=tkcode ' +
710tA              'where ptdstat=' + sq +'4' + sq + ' and ptdshftday=' +
710tA               %subst(%char($ppExpdt):3:6) +
710tA               ' and tkcat=' + sq + 'PROD' + sq +
                    ' group by ptdwhse,ppline,ppwo#,ptdtask,ptdstat,ptdempnum' +
                    ',ptdshft';
710tA
710tA      exec sql Prepare TrnActCs from :Sqlstmt;
710tA      exec sql Declare TranActCs scroll cursor for TrnActCs;
710tA      exec sql Open TranActCs;
710tA      exec sql Fetch first from TranActCs into :TranActRec;
710tA
710tA      dow sqlstt = sqlSuccess;
710tA         if %trim(trnaLine) <> 'ALL' and %trim(trnaLine)<>*blanks;
710tA            Non_Num_Posn = %check(numbers:%trim(trnaLine));
710tA            if Non_Num_Posn = *zeros;
710tA               // convert known numeric line to see if worked today
710tA               qtyele = %lookup(%dec(%trim(trnaLine):3:0):clnelne:1);
710tA            else;
710tA               // if not numeric must be ALL defined to be counted
710tA               qtyele=*zeros;
710tA            endif;
710tA         endif;
710tA         if trnastat = '4' and (qtyele <> *zeros or
710tA            (recCnt = *zeros and trnaLine = 'ALL'));
                     // get Employee Rate.  Could be defined for only
                     // one task but clocking on different production
                     // tasks,  Starts with WH/Line/Emp/Task and goes back
                     clear lcRecSql;
710tA                wkEmp = trnaEmp;
                     exec sql select * into :lcRecSql
                         from pLabCstLne
                           where lcwhse=:trnawhse and lcline=:trnaline and
                                 lcempno=:wkEmp and lctask=:trnaTask and
                                 lcshft = :trnashft;
                     if sqlStt <> sqlSuccess;
                        exec sql select * into :lcRecSql
                            from pLabCstLne
                              where lcwhse=:trnawhse and lcline=:trnaline and
                                    lcempno=:wkEmp and lctask=:trnaTask;
                        if sqlStt <> sqlSuccess;
                           exec sql select * into :lcRecSql
                               from pLabCstLne
                                 where lcwhse=:trnawhse and lcline=:trnaline and
                                       lcempno=:wkEmp;
                           if sqlStt <> sqlSuccess;
                              exec sql select * into :lcRecSql
                                  from pLabCstLne
                                    where lcwhse=:trnawhse and
                                          lcempno=:wkEmp;
                           endif;
                        endif;
                     endif;
710tA                // if this represents a Standard Definition we should skip
710tA                // since Standard was written above.
710tA                if s_lcctyp<>'A';
710tA /end-free
710tAc                   goto      skiprec
710tA /free
710tA                endif;
710tA                // at this point we determine the line matches or is
710tA                // defined as All
                     // get labor rate based on available parms and what is
                     // defined
710tA                cslwhse = $ppWhse;
710tA                cslprddate = $ppExpdt;
710tA                csltype = 'L';
710tA                cslempcnt = 1;
710tA                cslstdrate = s_lcsrte;
710tA                cslcsdtwk = ' ';
710tA                csltask = trnaTask;
710tA                cslseq = trnaEmp;
710tA                GetCurrStamp();
710tA                csllocts = CurrStampLoc;
710tA                cslsysts = CurrStampSys;
710tA                cslucts  = CurrStampUC;
710tA                csljob = #job;
710tA                csluser = #user;
710tA                csljobnbr = #jobnbr;
710tA                // loop thru each Work Order and apply percentage of
710tA                // total labor cost based on quantity produced for
710tA                // specific Work Order compared to total produced
710tA                // all day for either All if All or specific Mfg Line
710tA                // if specific Line
710tA                sltcnt=1;
710tA                dow compWo(sltcnt) <> *blanks and sltcnt <500;
710tA                   select;
                           // Spread actual time across all lines and all work orders
710tA                      when trnaline='ALL';
710kA                         // write cost for *ALL records if all lines closed
                              // User cannot scan specific Work Order and put ALL
                              // on Mfg Line.  Therefore, if ALL Mfg Line must be
                              // All Work Orders
710tA                         cslwo = compWo(sltcnt);
710tA                         cslline = compLne(sltcnt);
710tA                         cslfgitm = compItm(sltcnt);
710tA                         cslfgqty = compQty(sltcnt);
710tA                         cslwoqty = %xFoot(compQty);
710tA                         if %xFoot(compQty) = *zeros;
710tA                            cslcstasgn = *zeros;
710tA                         else;
710tA                            cslcstasgn = ((s_lcsrte/60/60)*trnasecs) *
710tA                                      (compQty(sltcnt) / %xFoot(compQty));
710tA                            cslsecs    = trnasecs *
710tA                                      (compQty(sltcnt) / %xFoot(compQty));
710tA                         endif;
710tA                         write cslrec;
                           // Spread actual time across all Work Orders within one line
710tA                      when trnaline = %editc(compLne(sltcnt):'X')
                                  and trnawo#='ALL';
710tA                         // write records for Line Specific cost records
710tA                         cslwo = compWo(sltcnt);
710tA                         cslline = compLne(sltcnt);
710tA                         cslfgitm = compItm(sltcnt);
710tA                         cslfgqty = compQty(sltcnt);
710tA                         qtyele = %lookup(compLne(sltcnt):clneLne:1);
710tA                         if qtyele <> *zeros;
710tA                            qtyforlne = clneQty(qtyele);
710tA                         else;
710tA                            qtyforlne = *zeros;
710tA                            cslsecs    = *zeros;
710tA                         endif;
710tA                         cslwoqty = qtyforlne;
710tA                         if qtyforlne = *zeros;
710tA                            cslcstasgn = *zeros;
710tA                         else;
710tA                            cslcstasgn = ((s_lcsrte/60/60)*trnasecs) *
710tA                                 (compQty(sltcnt) / qtyforlne);
710tA                            cslsecs    = trnasecs *
710tA                                 (compQty(sltcnt) / qtyforlne);
710tA                         endif;
710tA                         write cslrec;
                           // When not All/All and not All WO within specific Line
                           // we write Cost as one line to specific Work Order
710tA                      other;
710tA                         // write records for Line Specific cost records
710tA                         cslwo = compWo(sltcnt);
710tA                         cslline = compLne(sltcnt);
710tA                         cslfgitm = compItm(sltcnt);
710tA                         cslfgqty = compQty(sltcnt);
710tA                         cslwoqty = compQty(sltcnt);
710tA                         cslcstasgn = ((s_lcsrte/60/60)*trnasecs);
710tA                         cslsecs    = trnasecs;
710tA                         write cslrec;
710tA                   endsl;
710tA                   sltcnt = sltcnt + 1;
710tA                enddo;
710tA         endif;
710tA
710tA /end-free
710tAc     skiprec       tag
710tA /free
710tA         exec sql Fetch next from TranActCs into :TranActRec;
710tA      enddo;
710tA      exec sql Close TranActCs;
710tA
710kA     // First delete any OH cost for passed day to close
          if $ppPrimary = 'ALL';
710kA        exec sql delete from pCostWoo where csowhse=:$ppwhse and
710kA                                            csoprddate=:$ppExpdt;
          else;
710kA        exec sql delete from pCostWoo where csowhse=:$ppwhse and
710kA                                            csoprddate=:$ppExpdt
710tA                                        and csoline=:$ppPrimary;
          endif;
710kA
710kA      // loop through Labor just generated and create Overhead records
710kA      // for each unique Warehouse/Prod Date/Mfg Line/Work Order/Seq#
710kA      SqlStmt='select cslwhse,cslprddate,cslline,csltask,cslwo,cslfgitm,' +
710kA              'cslseq,sum(cslcstasgn) ' +
710kA              'from pCostWol where ' + %char($ppWhse) +
710kA              '=cslwhse and cslprddate=' + %char($ppExpDt)  +
710kA              ' group by cslwhse,cslprddate,cslline,csltask,cslwo,' +
710kA              'cslfgitm,cslseq ' +
710kA              'order by cslwhse,cslprddate,cslline,csltask,cslwo,' +
710kA              'cslfgitm,cslseq ';
710kA
710kA      exec sql Prepare OhCp from :Sqlstmt;
710kA      exec sql Declare OhoCp scroll cursor for OhCp;
710kA      exec sql Open OhoCp;
710kA      exec sql Fetch first from OhoCp into :csowhse,:csoprddate,
710kA                                      :csoline, :csotask,:csowo,
710kA                                      :csofgitm,:csoseq, :csolabcst;
710kA      // loop through summarized labor recordset and generate overhead records
710kA      dow sqlstt = sqlSuccess;
710kA         csotype='O';
710tA         wkEmp = csoseq;
710kA         // get overhead rate and benefit rate from definition record
710kA         // first try unique wharehouse, line, employee and task
710kA         chain (csowhse:wkEmp:%editc(csoline:'X'):csotask) pLabCstLne;

710kA         // next try warehouse, line and employee
710kA         if not %found(pLabCstLne);
710kA            chain (csowhse:wkEmp:%editc(csoline:'X')) pLabCstLne;
710kA         endif;

710kA         // next try warehouse, All lines and employee
710kA         if not %found(pLabCstLne);
710kA            chain (csowhse:wkEmp:'*ALL') pLabCstLne;
710kA         endif;

710kA         if not %found(pLabCstLne);
710kA            csobenefit=*zeros;
710kA            csoovrpct=*zeros;
710kA         else;
710kA            csobenefit=lcbenrt;
710kA            csoovrpct=lcohpct;
710kA         endif;
710kA         csoovrcst = csolabcst * (csoovrpct/100);
710kA         csobfitcst = csolabcst * (csobenefit/100);
710kA         csocstasgn = csoovrcst + csobfitcst;
710kA         GetCurrStamp();
710kA         csolocts = CurrStampLoc;
710kA         csosysts = CurrStampSys;
710kA         csoucts  = CurrStampUC;
710kA         csojob = #job;
710kA         csouser = #user;
710kA         csojobnbr = #jobnbr;
710kA         write csorec;
710kA         exec sql Fetch next from OhoCp into :csowhse,:csoprddate,
710kA                                      :csoline, :csotask,:csowo,
710kA                                      :csofgitm,:csoseq, :csolabcst;
710kA      enddo;
710kA      exec sql Close OhoCp;
710kA
710kA      endsr;
710kA /end-free

710kA *----------------------------------------------------------------
710kA *  wrtRmCost - Build and Write Raw Material cost Data
710kA *----------------------------------------------------------------
710kA
710kA /free
710kA      begsr wrtRmCost;
710kA
710kA      clear csmrec;
710kA      // get proper Bill of Material values.  IF raw material was
710kA      // substituted or dynamic bill generated we need to locate
710kA      // and populate bom fields for this routine
710kA      chkForSub(matcsthld.mcwhse:matcsthld.mcwo#:matcsthld.mcrmi:
710kA                matcsthld.mcfgi:matcsthld.mcmfgno);
710kA
710kA      // Retrieve total usage for given raw material, production day
710kA      // manufacturing line
710kA      exec sql select sum(plqtyn*-1),
                           sum(plqty1*-1),
                           sum(plqty2*-1)
710kA               into :csmtusnq indicator :iusnq,
                         :csmtusb1 indicator :iusb1,
                         :csmtusb2 indicator :iusb2
710kA               from prodlog
710kA               where plwhse = :matcsthld.mcwhse  and
710kA                     plitem = :matcsthld.mcrmi   and
710kA                     plaction = 'PIU' and
710kA             //      plline = :matcsthld.mcmfgno and
710kA                     plprddte = :$ppExpDt;

           if iusnq <> 0;
              csmtusnq=*zeros;
           endif;

           if iusb1 <> 0;
              csmtusb1=*zeros;
           endif;

           if iusb2 <> 0;
              csmtusb2=*zeros;
           endif;
710kA
710kA      // Retrieve total waste for given raw material, production day
710kA      // manufacturing line
710kA      exec sql select sum(plqtyn*-1),
                           sum(plqty1*-1),
                           sum(plqty2*-1)
710kA               into :csmtwsnq indicator :iwsnq,
                         :csmtwsb1 indicator :iwsb1,
                         :csmtwsb2 indicator :iwsb2
710kA               from prodlog
710kA               where plwhse = :matcsthld.mcwhse  and
710kA                     plitem = :matcsthld.mcrmi   and
710kA                     plaction = 'PIW' and
710kA            //       plline = :matcsthld.mcmfgno and
710kA                     plprddte = :$ppExpDt;

           if iwsnq <> 0;
              csmtwsnq=*zeros;
           endif;

           if iwsb1 <> 0;
              csmtwsb1=*zeros;
           endif;

           if iwsb2 <> 0;
              csmtwsb2=*zeros;
           endif;
710kA
710kA      // set values for new Material Cost Sheet record
710kA      csmwhse   = matcsthld.mcwhse;
710kA      csmprddate = matcsthld.mcprddte;
710kA      csmline   = matcsthld.mcmfgno;
710kA      csmwo     = matcsthld.mcwo#;
710kA      csmfgitm  = matcsthld.mcfgi;
710kA      csmrmitm  = matcsthld.mcrmi;
710kA      csmfgqty  = tAct_FgQty;
710kA      csmprjnq  = tPrj_qtyn;
710kA      csmprjb1  = tPrj_qty1;
710kA      csmprjb2  = tPrj_qty2;
710kA      csmprjpq  = tPrj_prdq;
710kA      csmscrf   = bmscrf;
710kA      csmactnq  = tAct_qtyn;
710kA      csmactb1  = tAct_qty1;
710kA      csmactb2  = tAct_qty2;
710kA      csmactpq  = tAct_prdq;
710kA      csmscnwgt = tAct_Scnwg;
710kA      csmtare   = tAct_Tare;
710kA      csmbckf   = bmbckf;
710kA      csmpquf   = bmpquf;
710kA      csmusep   = bmusep;
710kA      csmfacused= 'A';         // change to pull from option when available
710kA      csmpocost = matcsthld.mcpocost;
710kA      csmavgcost= matcsthld.mcavgcost;
710kA      csmstdcost= matcsthld.mcstdcost;
710kA      csmjob = #job;
710kA      csmuser = #user;
710kA      csmjobnbr = #jobnbr;
710kA      GetCurrStamp();
710kA      csmlocts = CurrStampLoc;
710kA      csmsysts = CurrStampSys;
710kA      csmucts  = CurrStampUC;
710kA
710kA      chain (matcsthld.mcwhse:matcsthld.mcrmi) piritem;
710kA      chain (matcsthld.mcwhse:matcsthld.mcrmi) itemprd;
710kA      // Calculate percents used to determine Usage Assigned to each
710kA      // Work ORder for Usage and Waste for each Raw MAterial under each
710kA      // Work ORder
710kA
710kA      // if Production quantity exist for the Work Order then calculate
710kA      // percent using the Production Quantity breakdown, otherwise use
710kA      // normal Dakota inventory breakdowns
710kA      if tAct_prdq <> *zeros;
710kA         // Retrieve total Usage per the PRoduction UOM for this raw material
710kA         // per PWRKORDRU to determine percentage for this on work order
710kA         uractpq = *zeros;
710kA         exec sql select sum(uractpq)
710kA                  into :tsum_qty
710kA                  from pwrkordru
710kA                  where urwhse = :matcsthld.mcwhse and
710kA                        urrmi = :matcsthld.mcrmi   and
710kA                        urstat = 'C'               and
710kA                        urprddte = :$ppExpDt;
710kA         // convert normal inventories from Prodlog to equivalent
710kA         // Production Quantities since work order quantities are
710kA         // in Production UOM.
710kA         select;
710kA            when itumq2 <> 0 and itumq3<>0;
710kA               result = ipprdq / (itumq2*itumq3);
710qD         //    tSum_qty = tAct_prdq;
710kA               tu_type='UP';
710kA               tw_type='WP';
710kA               // first divide total actual production quantity
710kA               // for Work ORder by total recorded usage of Raw
710kA               // Material extended to breakdown level 2.
710kA               // Then multiple that by the factor above in result
710kA               // this should give us a percent of cost for this
710kA               // one work order
710kA               if csmtusnq=*zeros and csmtusb1=*zeros and csmtusb2=*zeros;
710kA                  // if no values been produced usage percent should be zero
710kA                  csmperuse = *zeros;
710kA               else;
710kA                  // else determine percent of produced for given work order
710kA                  // to total that was produced
710kA                  csmperuse = tAct_prdq / tsum_qty;
710kA               endif;
710kA            when itumq2 <> 0;
710kA               result = ipprdq / itumq2;
710qD        //     tSum_qty = tAct_prdq;
710kA               tu_type='UP';
710kA               tw_type='WP';
710kA               if csmtusnq=*zeros and csmtusb1=*zeros;
710kA               else;
710kA                  // refer to comments above. Only difference
710kA                  // here is only bd1
710kA                  csmperuse = tAct_prdq / tsum_qty;
710kA               endif;
710kA            other;
710kA               // only case quantity here.  Just divide
710kA               // Work Order Usage by total day usage
710kA               result = ipprdq;
710qD      //       tSum_qty = tAct_prdq;
710kA               tu_type='UP';
710kA               tw_type='WP';
710kA               if csmtusnq = *zeros;
710kA                  csmperuse = *zeros;
710kA               else;
710kA                  csmperuse = tAct_prdq / tsum_qty;
710kA               endif;
710kA         endsl;
710kA      else;
710kA         // following this else we will calculate cost using the
710kA         // normal Dakota Quantities versus the Production Breakdown
710kA         // convert normal inventories from Prodlog to equivalent
710kA         // Production Quantities since work order quantities are
710kA         // in Production UOM.
710kA         select;
710kA            when itumq2 <> 0 and itumq3<>0;
710kA               result = itumq2*itumq3;
710kA               tSum_qty = ((tAct_qtyn*itumq2*itumq3) +
710kA                           (tAct_qty1*itumq3) +
710kA                            tAct_qty2);
710kA               tu_type='UD';
710kA               tw_type='WD';
710kA               // result is the number of breakdowns in a case
710kA               if csmtusnq=*zeros and csmtusb1=*zeros and csmtusb2=*zeros;
710kA                  // if no values been produced usage percent should be zero
710kA                  csmperuse = *zeros;
710kA               else;
710kA                  // else determine percent of produced for given work order
710kA                  // to total that was produced
710kA                  csmperuse = ((tAct_qtyn*itumq2*itumq3) +
710kA                               (tAct_qty1*itumq3) +
710kA                               tAct_qty2) /
710kA                              ((csmTusNq*itumq2*itumq3) +
710kA                               (csmTusB1*itumq3) +
710kA                                csmTusB2);
710kA               endif;
710kA            when itumq2 <> 0;
710kA               result = itumq2;
710kA               tSum_qty = (tAct_qtyn*itumq2) +
710kA                          (tAct_qty1);
710kA               tu_type='UD';
710kA               tw_type='WD';
710kA               if csmtusnq=*zeros and csmtusb1=*zeros;
710kA                  csmperuse = *zeros;
710kA               else;
710kA                  csmperuse = ((tAct_qtyn * itumq2) + tAct_qty1) /
710kA                               ((csmTusnq * itumq2) + csmTusB1);
710kA               endif;
710kA            other;
710kA               // only case quantity here.  Just divide
710kA               // Work Order Usage by total day usage
710kA               result = 1;
710kA               tSum_qty = tACt_qtyn;
710kA               tu_type='UD';
710kA               tw_type='WD';
710kA               if csmtusnq = *zeros;
710kA                  csmperuse = *zeros;
710kA               else;
710kA                  csmperuse = tAct_qtyn / csmTusNq;
710kA               endif;
710kA         endsl;
710kA      endif;
710kA      // for the time we will force same percentage of usage on
710kA      // percentage of waste.
710kA      csmperwst = csmperuse;
710kA
710kA      // Calculate Cost
710kA      // Last PO Cost extended for Use and Waste
710kA      csmusecpo = calcCost($ppWhse:result:csmpocost:
710kA                           csmTusNq:csmTusB1:csmTusB2:
710kA                           tSum_Qty:csmperuse:tu_type);
710kA      csmwstcpo = calcCost($ppWhse:result:csmpocost:
710kA                           csmTwsNq:csmTwsB1:csmTwsB2:
710kA                           tSum_qty:csmperwst:tw_type);
710kA      // Avg Cost extended for Use and Waste
710kA      csmuseca = calcCost($ppWhse:result:csmavgcost:
710kA                           csmTusNq:csmTusB1:csmTusB2:
710kA                           tSum_Qty:csmperuse:tu_type);
710kA      csmwstca = calcCost($ppWhse:result:csmavgcost:
710kA                           csmTwsNq:csmTwsB1:csmTwsB2:
710kA                           tSum_Qty:csmperwst:tw_type);
710kA      // Std Cost extended for Use and Waste
710kA      csmusecs = calcCost($ppWhse:result:csmstdcost:
710kA                           csmTusNq:csmTusB1:csmTusB2:
710kA                           tSum_Qty:csmperuse:tu_type);
710kA      csmwstcs = calcCost($ppWhse:result:csmstdcost:
710kA                           csmTwsNq:csmTwsB1:csmTwsB2:
710kA                           tSum_Qty:csmperwst:tw_type);
710kA      // currently default Average Cost to Cost Assigned
710kA      // Reports will be written so you can select any cost value
710kA      // May need to add system option at some point and then
710kA      // change this to put that value in cost assigned
710kA      csmCstAsgn = csmuseca + csmwstca;
710kA      // write record
710kA      write csmrec;
710kA
710kA      tPrj_qtyn = *zeros;
710kA      tPrj_qty1 = *zeros;
710kA      tPrj_qty2 = *zeros;
710kA      tPrj_prdq = *zeros;
710kA      tAct_qtyn = *zeros;
710kA      tAct_qty1 = *zeros;
710kA      tAct_qty2 = *zeros;
710kA      tAct_prdq = *zeros;
710kA      tAct_FgQty= *zeros;
710kA      tAct_scnwg= *zeros;
710kA      tAct_Tare = *zeros;
710kA      matcsthld = matcst;
710kA
710kA      endsr;
710kA
710kA /end-free

710kA *----------------------------------------------------------
710kA *  zzNullChk  Check for Null values or No Cost for RM
710kA *----------------------------------------------------------
710kA
710kA /free
710kA     begsr zzNullChk;
710kA
710kA     // replace null values for any of the three cost values
710kA     // with *zeros.  This prevents failures of Null values
710kA     // in routine SPRDCOST when spreading cost for end of day
710kA
710kA        if Nullind(19) = NullValue;
710kA           Nullind(19) = 0;
710kA           matcst.mcpocost = *zeros;
710kA        endif;
710kA
710kA        if Nullind(20) = NullValue;
710kA           Nullind(20) = 0;
710kA           matcst.mcavgcost = *zeros;
710kA        endif;
710kA
710kA        if Nullind(21) = NullValue;
710kA           Nullind(21) = 0;
710kA           matcst.mcstdcost = *zeros;
710kA        endif;
710kA
710kA     endsr;
710kA
710kA /end-free
710kA
      *----------------------------------------------------------
      *  *INZSR   Initialization subroutine
      *----------------------------------------------------------

      /free
          begsr *INZSR;
             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

           endsr;

      /end-free

      *----------------------------------------------------------
      *  wrtDebugParms  Write out debug parm record
      *----------------------------------------------------------

      /free
       begsr wrtDebugParms;

         bdtype = 'PARMS';

         bdvalues = '&pruser = ' + $ppuser
                  + 'sqlStt =' + %trim(sqlstt)
                  + 'Line =' + %trimr(linenum);

         bdaddts = %timestamp();
         bdaddpgm = #pgm;
         bdaddcusr = #curruser;
         bdaddjusr = #user;
         bdaddjob = #job;
         bdaddnbr = #jobnbr;

         write(e) bdrec;

       endsr;
      /end-free
710 A *
710 A *  Procedure Split..............
710 A *
710 A *  Split Procedure that work like SPLIT in javascript.  It expects an input
710 A *  string up to 1000 characters long, a delimiter 3 character long, and passes
710 A *  back an array with 50 elements 50 character each.  The delmiter could
710 A *  be increased if need be and the code (%len) takes care of it.  You could
710 A *  also change the array size and element count.  If you do you should change
710 A *  split and returnarray here and you procedure definition in main program
710 A *  as well as the array defined in the main program that receives the return
710 A *  from this procedure.  When you return simply loop through array looking for
710 A *  non blanks and do what you need to given your data.
710 A *
710 AP split           b
710 AD split           pi            50    dim(50)
710 AD  data                       1000    const
710 AD  delimiter                     3    const
710 A
710 AD returnArray     s             50    dim(50)
710 A
710 AD startPos        s             10i 0
710 AD foundPos        s             10i 0
710 AD increment       s             10i 0
710 AD index           s              5i 0 inz(1)
710 A /free
710 A  if data <> *blanks;
710 A     increment = %len(%trim(delimiter));
710 A     startPos = 1;
710 A     dou foundPos = %len(data) + 1;
710 A        foundPos = %scan(%trim(delimiter):data:startPos);
710 A        if foundPos = 0;
710 A           foundPos = %len(data) + 1;
710 A        endif;
710 A        returnArray(index) = %subst(data:startPos:foundPos - startPos);
710 A        index += 1;
710 A        startPos = foundPos + increment;
710 A     enddo;
710 A  endif;
710 A
710 A  return returnArray;
710 A /end-free
710 AP split           e
710kA *
710kA *  Procedure calcCost.........
710kA *
710kA *  calcCost  Procedure will calculate portion of Daily Raw MAterial cost
710kA *  to specific Work Order.  The reason this is performed is due to the fact
710kA *  that Actual Usage (PIU) and Waste (PIW) are generated at a Raw MAterial
710kA *  level at End of Day.  Therefore it is determining percents at Work ORder
710kA *  level and applying to total use and cost factors to get assigned cost
710kA *
710kAP calcCost        b
710kAD calcCost        pi             9  4
710kAD  cstWhse                       3  0 value
710kAD  cstResult                     9  4 value
710kAD  cstCost                       9  4 value
     d  cstNq                         5  0 value
     d  cstB1                         5  0 value
     d  cstB2                         5  0 value
     d  cstPrdq                       9  4 value
710kAD  cstPercent                    6  2 value
710kAD  cstType                       2    const
710kA
     d  rtnCost        s              9  4
710kA
710kA /free
710kA
        select;
           when itumq2 <> 0 and itumq3 <> 0;
              // Extend Total used qty for this raw material to lowest
              // breakdown units and then extend by breakdown cost factor
              // *** Cost  ***
              // cstPrdq is Production UOM of quantity for this given Work ORder
              // Result is the factor between Production Case Quantity (IPPRDQ) to BD Qty
              // CstCost is which cost is being passed to this procedure (PO, Avg, STd)
              // ITUMQ2 and ITUMQ3 are Dakota Normal Inventory Breakdown Quantities
710qD   //   if cstType <> 'UP';
                if cstType <> 'WP';
                   result = 1;
                endif;
                // since we are using Production Usage values and waste is
                // only recorded at raw material level for a day and only
                // using normal Dakota breakdowns we must first convert the
                // waste for the day to the production quantity.  We will
                // also only apply the percent for this work order
                cstPrdq = ((cstNq * itumq2 * itumq3)
                          + (cstB1 * itumq3) + cstB2) * result * csmperwst;
710qD   //   endif;
              rtnCost =
              ((cstPrdq / Result) *
                 (cstCost / (itumq2*itumq3)));
          when itumq2 <> 0;
             // refer to comments above. Only difference
             // here is only bd1
             // *** Usage Cost  ***
710qD   //   if cstType <> 'UP';
                if cstType <> 'WP';
                   result = 1;
                endif;
                // since we are using Production Usage values and waste is
                // only recorded at raw material level for a day and only
                // using normal Dakota breakdowns we must first convert the
                // waste for the day to the production quantity.  We will
                // also only apply the percent for this work order
                cstPrdq = ((cstNq * itumq2) + cstB1) * result * csmperwst;
710qD   //   endif;
             rtnCost =
             ((cstPrdq / result) *
              (cstCost / itumq2));
          other;
             // only case quantity here.  Just divide
             // Work Order Usage by total day usage
             // *** Usage Cost  ***
710qD   //   if cstType <> 'UP';
                if cstType <> 'WP';
                   result = 1;
                endif;
                // since we are using Production Usage values and waste is
                // only recorded at raw material level for a day and only
                // using normal Dakota breakdowns we must first convert the
                // waste for the day to the production quantity.  We will
                // also only apply the percent for this work order
                cstPrdq = cstNq * csmperwst;
710qD   //   endif;
             rtnCost = ((cstPrdq/Result) * (cstCost));
       endsl;
       return rtnCost;
710kA /end-free
710kA
710kAP calcCost        e
710cA *
710cA *  Procedure chkForSub.........
710cA *
710cA *  chkForSub Procedure will used passed parms to determine if BOM line has been
710cA *  substituted.  If so it will locate the substitute and replace the pbom fields
710cA *  with values found in PBOMSUB
710cA *
710cAP chkForSub       b
710cAD chkForSub       pi             8
710cAD  chkWhse                       3  0 value
710cAD  chkwo#                       13    const
710cAD  chkRmi                       15    const
710cAD  chkFgi                       15    const
710cAD  chkLine                       3  0 value
710cA
710cA /free
740aA   sumQtyn=0;
740aA   sumQty1=0;
740aA   sumQty2=0;
740aA   sumPrdq=0;
740aA   bomLoc = 'PBOM';
710cA   // do not check bom file if primary since it reads it first before coming here
710jD   // if $pSubCmd <> '*CRTPRODWO';
710jA   if $pSubCmd <> '*CRTPRODWO' and $psubcmd<>'*AVGPRD'
730aA       and $psubcmd <> '*PRDQTY';
           if ($psubCmd='*UPDLOOP' and newWorkOrder);
              // set subUsed with BOM raw material when adding new work order
              // since it is already reading from pbom
              subUsed = bmrmi;
              return 'PBOM';
           else;
710cA         // first look to see if raw material from work order detail
710cA         // file exist in PBOM (Primary Bill of MAterial File
710oD         // setll (wrwhse:wrfgi) pbom;
710oD         // reade (wrwhse:wrfgi) pbom;
710oA         setll (chkwhse:chkfgi) pbom;
710oA         reade (chkwhse:chkfgi) pbom;
710cA         dow not %eof(pbom);
710cA            // if bom raw material equals raw material from work order
710cA            // return as PBOM
710oA            // if bmrmi = writem;
710oA            if bmrmi = chkrmi;
710cA               subUsed = bmrmi;
710cA               return 'PBOM';
710cA            endif;
710oD            // reade (wrwhse:wrfgi) pbom;
710oA            reade (chkwhse:chkfgi) pbom;
710cA         enddo;
710cA
710cA         // when it falls to here it means the work order raw material was not
710cA         // found in the active Bill of MAterial PBOM.  Look next in active
710cA         // substitution
710cA         // see if substitute item matches item from work order detail
710oD         // setll (wrwhse:wrfgi) pBomSub;
710oD         // reade (wrwhse:wrfgi) pBomSub;
710oA         setll (chkwhse:chkfgi) pBomSub;
710oA         reade (chkwhse:chkfgi) pBomSub;
710cA         dow not %eof(pBomSub);
710cA            // see if this alternate item matches raw material for this work order
710oD            // if sbami = writem;
710oA            if sbami = chkRmi;
710cA               bmwhse = sbwhse;
710cA               bmfgi = sbfgi;
710cA               bmqtyn = sbqtyn;
710cA               bmqty1 = sbqty1;
710cA               bmqty2 = sbqty2;
710cA               bmprdq = sbprdq;
710cA               bmscrf = sbscrf;
710cA               bmtype = sbtype;
710cA               bmbckf = sbbckf;
710cA               bmpquf = sbpquf;
710cA               bmeffd = sbeffd;
710cA               bmexpd = sbexpd;
710cA               bmrmi = sbami;
710cA               subUsed = sbami;
710cA               leave;
710cA            endif;
710oD            // reade (wrwhse:wrfgi) pBomSub;
710oA            reade (chkwhse:chkfgi) pBomSub;
710cA         enddo;
           endif;
        else;
           // set subUsed with BOM raw material
           subUsed = bmrmi;
           return 'PBOM';
710cA   endif;
710cA
710cA   // end of file when existing do loop indicates no sub was found to be active
710cA   // but the bom line was not active either
710cA   if not %eof(pBomSub);
           subUsed = sbami;
740aA      bomLoc = 'PBOMSUB';
710cA      return 'PBOMSUB';
710cA   else;
710cA      subUsed = *blanks;
710cA   endif;
710cA
710cA   // when it falls to here it means the work order raw material was not
710cA   // found in the active Bill of Mmterial PBOM, or the Substitute files.
710cA   // It must be a dynamic bill.
710oD   // subUsed = writem;
710oA   subUsed = chkrmi;
710cA   // see if substitute item matches item from work order detail
710oD   // setll (wrwhse:wrfgi) pBomVers;
710oD   // reade (wrwhse:wrfgi) pBomVers;
710oA   setll (chkwhse:chkfgi) pBomVers;
710oA   reade (chkwhse:chkfgi) pBomVers;
710cA   dow not %eof(pBomVers);
710cA      // see if this alternate item matches raw material for this work order
710oD      // if pxrmi = writem;
710oA      if pxrmi = chkrmi;
710cA         bmwhse = pxwhse;
710cA         bmfgi = pxfgi;
710cA         bmqtyn = pxqtyn;
710cA         bmqty1 = pxqty1;
710cA         bmqty2 = pxqty2;
710cA         bmprdq = pxprdq;
710cA         bmscrf = pxscrf;
710cA         bmtype = pxtype;
710cA         bmbckf = pxbckf;
710cA         bmpquf = pxpquf;
710cA         bmeffd = pxeffd;
710cA         bmexpd = pxexpd;
710cA         bmrmi = pxrmi;
710cA         subUsed = pxrmi;
710cA         leave;
710cA      endif;
710oD      // reade (wrwhse:wrfgi) pBomVers;
710oA      reade (chkwhse:chkfgi) pBomVers;
710cA   enddo;
710cA
710cA   // end of file when existing do loop indicates no sub was found to be active
710cA   // but the bom line was not active either
710cA   if not %eof(pBomVers);
           subUsed = pxrmi;
740aA      bomLoc = 'PBOMVERS';
710cA      return 'PBOMVERS';
710cA   else;
710cA      subUsed = *blanks;
710cA      return'NF';
710cA   endif;
710cA
710cA /end-free
710cA
710cAP chkForSub       e
710cA *
710cA *  Procedure calcUsageQty......
710cA *
710cA *  calcUsageQty will first if the Work ORder should use weight from a scanner or
710cA *  whether it should use quantities from the BOM.  This is decided by the number of
710cA *  raw materials identified as Production Specific (BMUSEP='Y').  Next, if scale weight
      *  is applied the system will determine which UOM is defined with pounds UOM (lb)
      *  and apply extended weight from scale to that uom, otherwise it will use code to
      *  extend the bom quantities.
      *
      *  ****  NOTE ****  When using scale weight it is only required that it determine the
      *  UOM with LB and extend the number of finished goods by scale weight unlike when it
      *  used BOM quantity path.  When using the BOM path you must multiply through the UOM
      *  tree to get quantities if the BOM is saying it uses "X" number of breakdown 2 quantities
      *  to get actual amount used or as if you are using scale quantity you know the exact
      *  used you simply have to locate the proper UOM to apply (prdq, qty1, or qty2)
710cA *
710cAP calcUsageQty    b
710cA
710cA /free
710cA   // earlier in routine VerifyQty a value was created for the Work Order which
710cA   // identifies how many raw materials on a Work ORder are Prd Specific (bmUsep='Y').
710cA   // if this value is one we use the weight from the scale/manual scale.  OTherwise
710cA   // we will use the bom quantities to record usage.  The reason is if multiple
710cA   // raw materials record waste we cannot determine how much of the scale weight
710cA   // to spread to multiple raw materials.
710cA   if bmUsep='Y';
           // go get factor to record material usage based
           // on scanned weight compared to weight of finished
           // good or component found one level up
           if result=0;    // no weight factor determined yet
              calcFactor(bmfgi);
           endif;
750aA   else;
750aA      // Use BOM when backflush and not production specific item
750aA      result = 1;
750aM   endif;  // numWastelines = 1

750aA   // Since this is recording usage it should be reverse of fg action
750aA   if $ppqty1 > 0;
750aA      result = -(%abs(result));
750aA   else;
750aA      result = %abs(result);
750aA   endif;

750aA   if bmUsep='Y' or bmBckF='Y';
710cA      // more than one waste line on Work ORder means we use BOM quantities for usage
           if bmprdq <> 0;
             urprjnq = 0;
             urprjb1 = 0;
             urprjb2 = 0;
             eval(h) urprjpq = $ppqty1 * bmprdq * result;
           else;
              urprjpq = 0;
              select;
                 when bmqty2 <> 0;
                    eval(h) urprjb2 = (($ppqty1 * bmqtyn * itumq2 * itumq3) +
                                       ($ppqty1 * bmqty1 * itumq3) +
                                       ($ppqty1 * bmqty2)*result);
                 when bmqty1 <> 0;
                    eval(h) urprjb1 = (($ppqty1 * bmqtyn * itumq2) +
                                       ($ppqty1 * bmqty1)*result);
                 other;
                    eval(h) urprjnq  = ($ppqty1 * bmqtyn);
              endsl;
          endif;  // bmprdq <> 0  - Production bom quantity
750aA   endif;  // Either Production Sepcific or Back Flush
710cA
710cA /end-free
710cA
710cAP calcUsageQty    e
730aA*----------------------------------------------------------------
730aA*  ¢alcFactor  Determine factor for for weight scanned compared
730aA*              to bill of material definition
730aA*----------------------------------------------------------------
730aA
730aAp calcFactor      b
730aAd calcFactor      pi
730aAD  iRmFGI                       15    value
730aA
     d rdPuom          s              2
     d rdUm1           s              2
     d rdUm2           s              2
     d rdUm3           s              2
740aAd fgprdq          s              7  4
740aAd fgbrkp          s              2
740aAd adddiv          s             12  4

730aA /free
           // first we need to ensure that the bill of material
           // associated with the scanned finished good has raw materials
           // assocaited with weight.  LB and OZ re pounds and ounces.
           // OP is a unit of measure used for pounds on either normal uom
           // or production uom when pounds needed for both.
           exec sql select ippuom,itum1,itum2,itum3
                     into :rdPuom,:rdUm1, :rdUm2, :rdUm3
                    from pbom, piritem,itemprd
                  where bmwhse=itwhse and bmrmi=ititem
                    and bmwhse=ipwhse and bmrmi=ipitem
                    and bmfgi=:iRmFgi and (ippuom in('LB','OZ','OP')
                     or itum1 in('LB','OZ','OP')
                     or itum2 in('LB', 'OZ', 'OP')
                     or itum3 in('LB', 'OZ', 'OP'))
                    fetch first row only;
           if sqlStt = '00000';
              // Assuming it is weight related definition we first
              // calculate the lowest level weight at either pounds
              // or ounces
740aA         if rdPuom='OZ' or rdUm1='OZ' or rdUm2='OZ' or rdUm3='OZ';
                result=($ppqty1*($ppwgt-$pptare)*16);
740aA         else;
                result=($ppqty1*($ppwgt-$pptare));
740aA         endif;
740aA         // Now we use bomloc to let us know whether the bill of
              // material is in live pbom, substitue file pbomsub, or
              // dynamic file pbomvers
740aA         select;
740aA           when bomloc='PBOM';
740aA             sqlstmt = 'select bmqtyn,bmqty1,bmqty2,bmprdq,' +
740aA                       'itumq2, itumq3 from pbom,piritem' +
740aA                       ' where bmwhse=' + %char(bmwhse) +
740aA                       ' and bmfgi=' + sq + %trim(bmfgi) + sq +
740aA                       ' and bmusep=' + sq + 'Y' + sq + ' and' +
740aA                       ' bmeffd<=' + %char(current_date) +
740aA                       ' and bmexpd>=' + %char(current_date) +
740aA                       ' and bmwhse=itwhse and bmrmi=ititem';
740aA           when bomloc='PBOMSUB';
740aA             sqlstmt = 'select sbqtyn,sbqty1,sbqty2,sbprdq,' +
740aA                       'itumq2, itumq3 from pbomsub,piritem' +
740aA                       ' where sbwhse=' + %char(bmwhse) +
740aA                       ' and sbfgi=' + sq + %trim(bmfgi) + sq +
740aA                       ' and sbwo#=' + sq + %trim(wrwo#) + sq +
740aA                       ' and sbusep=' + sq + 'Y' + sq + ' and ' +
740aA                       ' sbeffd<=' + %char(current_date) +
740aA                       ' and sbexpd>=' + %char(current_date) +
740aA                       ' sbwhse=itwhse and sbrmi=ititem';
740aA           other;
740aA             sqlstmt = 'select pxqtyn,pxqty1,pxqty2,pxprdq,' +
740aA                       'itumq2, itumq3 from pbomsub,piritem' +
740aA                       ' where pxwhse=' + %char(bmwhse)
740aA                       + ' and pxfgi=' + sq + %trim(bmfgi) + sq +
740aA                       ' and pxwo#=' + sq + %trim(wrwo#) + sq +
740aA                       ' and pxusep=' + sq + 'Y' + sq + ' and ' +
740aA                       ' pxeffd<=' + %char(current_date) +
740aA                       ' and pxexpd>=' + %char(current_date) +
740aA                       ' pxwhse=itwhse and pxrmi=ititem';
740aA         endsl;
              // loop and get total weight per fg bom to do factor
              // of weight scanned.  In order for this to happen
              // raw material has to be setup as used on finished good (xxusep)
              // of finished good, which is flag on bom.  Otherwise it
              // simply releave what is on bom.  Weight uom's like lb and oz
              // must also be present in uom structures
740aA         exec sql PREPARE tq FROM :SqlStmt;
740aA         exec sql DECLARE ttqty SCROLL CURSOR FOR tq;
740aA         exec sql OPEN ttqty;
740aA
740aA         adddiv = 0;
740aA         dow forever = forever;
740aA           exec sql fetch next from ttqty into :sumQtyn, :sumQty1,
740aA                                                :sumQty2, :sumPrdq,
740aA                                                :smumq2,  :smumq3;
740aA           if sqlstt<>'00000';
740aA             leave;
740aA           endif;
740aA
740aA           select;
                  when sumPrdq<>0;
                    adddiv = adddiv + sumPrdq;
740aA             when smumq3<>0;
740aA               adddiv = adddiv + (sumQtyn*smumq2*smumq3) +
740aA                        (sumQty1*smumq3) +
740aA                         sumQty2;
740aA             when smumq2<>0;
740aA               adddiv = adddiv + (sumQtyn*smumq2) +
740aA                         sumQty1;
740aA             other;
740aA               adddiv = adddiv + sumQtyn;
740aA           endsl;
740aA         enddo;
740aA         exec sql CLOSE ttqty;
740aA         if adddiv <> 0;
740aA           result = result / adddiv;
740aA         else;
740aA           result = 1;
740aA         endif;
           else;
              result=1;
           endif;
730aA /end-free
710cA
710cAP calcFactor      e
710kA*----------------------------------------------------------------
710kA*  GetCurrStamp  Get current timestamps
710kA*----------------------------------------------------------------
710kA
710kAp GetCurrStamp    b
710kAd GetCurrStamp    pi
710kA
710kA /free
710kA
710kA    getmicrotime(currstampuc:currstampsys);
710kA    ucOffset = %diff(currstampuc: currstampsys: *HOURS);
710kA    currstamploc = currstampsys + %hours(bfcoffset);
710kA
710kA /end-free
710kA
710kAp GetCurrStamp    e

     *----------------------------------------------------------------
     *  CreateTS   Create timestamp from Date/Time
     *----------------------------------------------------------------

     p CreateTS        b
     d CreateTS        pi              z
     d  date                          8p 0 const
     d  time                          6p 0 const

     *  Local Variables

     D stamp           s               z
     D temp26          s             26

     D                 ds
     D  yyyymmdd               1      8s 0
     D    yyyy                 1      4
     D    mm                   5      6
     D    dd                   7      8

     D                 ds
     D  hhmiss                 1      6s 0
     D    hh                   1      2
     D    mi                   3      4
     D    ss                   5      6


      /free

        clear stamp;

        if date = 0;
          return stamp;
        endif;

        yyyymmdd = date;
        hhmiss = time;
        temp26 = yyyy + '-' + mm + '-' + dd + '-'
               + hh + '.' + mi + '.' + ss + '.000000';

        monitor;
          stamp = %timestamp(temp26);
        on-error;
          clear stamp;
        endmon;

        return stamp;

      /end-free

     p CreateTS        e
730aA*----------------------------------------------------------------
730aA*  prcpBomLvl  Loop through Bill of Material for given FG or
730aA*              component being updated and return string with
730aA*              all items to update
730aA*----------------------------------------------------------------
730aA
730aAp prcpBomLvl      b
730aAfpbomlvlitmif   e           k disk    usropn
730aA
730aAd prcpBomLvl      pi          1000
730aAD  iWhse                         3  0 value
730aAD  iFgItm                       30    value
730aAD  iRmItm                       30    value
730aAd  iMakeQty                      4  0 value
730aAD  iMfgLine                      3  0 value
730aAD  ibomITems                  1000
730aA
730aAD bomData         DS                  LikeRec(BOMJOIN)
730aA
730aAD newMakeQty      s              4  0
730aAd blkRmItm        s             15
730aA
730aA /free
730aA
730aA       // loop through level one of pBomLvl recirsively
730aA       // to keep track of each quantity at different
730aA       // level to ensure proper production qty at each level
730aA       open pBomLvlItm;
730aA       setll (iWhse:iFgItm:iRmItm) pBomLvlItm;
730aA       read pBomLvlItm bomData;
730aA       bomItems = %trim(ibomItems);
730aA       dow not %eof(pBomLvlItm) and bomData.bmlfg=iFgItm;
              // skip if same as last entry.  This occurs when
              // multiple raw materials called from same level
              // from component
730eM         if %scan((bomData.bmlfg + bomData.bmllvl1 + '|'):
730eM                   %trim(bomItems))=0;
730aA            bomItems = %trim(bomItems) + bomData.bmlfg +
730aA                       bomData.bmllvl1 + '|';
730aA            // Call recursively to drill thru all components
730aA            // and get them all added or updated
730aA            prcpBomLvl (bomData.bmlwhs:bomData.bmllvl1:blkRmItm
730aA                        :iMakeQty:bomData.ipMfgNo:bomItems);
              endif;
730aA         read pBomLvlItm bomData;
730aA       enddo;
730aA       Close pBomLvlItm;
730aA       return bomItems;
730aA
730aA /end-free
730aA
730aAp prcpBomLvl      e

730aA*----------------------------------------------------------------
730aA*  reMainingQty  Determine remaining quantity between Work Order
730aA*                demand and User Override Demand
730aA*----------------------------------------------------------------
730aA *  This procedure will return total breakdown number for work order
730aA *  demand and user overrides
730aA *
730aAP reMainingQty    b
730aAD reMainingQty    pi            10  0
730aAD  icbd1                        10  0 value
730aAD  icbd2                        10  0 value
730aAD  iovrd                        10  0 value
730aA
730aAD returnQty       s             10  0
730aA
730aAD startPos        s             10i 0
730aA
730aA /free
730aA
730aA  select;
730aA    when itumq3>1;
730aA       // get total breakdown two quantity first
730aA       returnQty = (iovrd*itumq2*itumq3) + (icbd1*itumq3) + icbd2;
730aA    when itumq2>1;
730aA       // get total breakdown 1 quantity first
730aA       returnQty = (iovrd*itumq2) + icbd1;
730aA    other;
730aA       if iovrd > %abs(pMakeQty);
730aA          returnQty = %abs(pMakeQty);
730aA       else;
730aA          returnQty = iovrd;
730aA       endif;
730aA
730aA  endsl;
730aA
730aA  return returnQty;
730aA
730aA /end-free
730aAP reMainingQty    e
730aA
730aA*----------------------------------------------------------------
730aA*  adjustQtyprc  Return case equilalent for breakdowns and cases
730aA*----------------------------------------------------------------
730aA *  This procedure will return a number that represents full case counts
730aA *  of $ppcBd1, 2 and $ppovrd values which represent Work Order specific
730aA *  demand in $ppcbd1 and 2 and user entered demand without supporting
730aA *  Work Orders in $ppovrd
730aA *
730aAP adjustQtyprc    b
730aAD adjustQtyprc    pi            10  0
730aAD  iQty1                         5  0 value
730aAD  iQty2                         5  0 value
730aAD  iQty3                         5  0 value
730aA
730aAD returnQty       s             10  0
730aA
730aAD startPos        s             10i 0
730aA
730aA /free
730aA
730aA  select;
730aA    when itumq3>1;
730aA       // get total breakdown two quantity first
730aA       returnQty = (iqty1*itumq2*itumq3) + (iqty2*itumq3) + iqty3;
730aA    when itumq2>1;
730aA       // get total breakdown 1 quantity first
730aA       returnQty = (iqty1*itumq2) + iqty2;
730aA    other;
730aA       if iqty1 > %abs(pMakeQty);
730aA          returnQty = %abs(pMakeQty);
730aA       else;
730aA          returnQty = iqty1;
730aA       endif;
730aA
730aA  endsl;
730aA
730aA  return returnQty;
730aA
730aA /end-free
730aAP adjustQtyprc    e
730aA
730aA*----------------------------------------------------------------
730aA*  woOnlyDmd  This excludes the user entered demand that overrides WO
730aA*----------------------------------------------------------------
730aA *  This procedure will return a number that represents full case counts
730aA *  of $ppcBd1, 2 only
730aA *
730aAP woOnlyDmd       b
730aAD woOnlyDmd       pi            10  0
730aAD  iQty1                         5  0 value
730aAD  iQty2                         5  0 value
730aAD  iQty3                         5  0 value
730aA
730aAD returnQty       s             10  0
730aA
730aA /free
730aA
730aA  select;
730aA    when itumq3>1;
730aA       // get total breakdown two quantity first
730aA       returnQty = (iqty1*itumq2*itumq3) + (iqty2*itumq3) + iqty3;
730aA    when itumq2>1;
730aA       // get total breakdown 1 quantity first
730aA       returnQty = (iqty1*itumq2) + iqty2;
730aA    other;
730aA       if iqty1 > %abs(pMakeQty);
730aA          returnQty = %abs(pMakeQty);
730aA       else;
730aA          returnQty = iqty1;
730aA       endif;
730aA
730aA  endsl;
730aA
730aA  return returnQty;
730aA
730aA /end-free
730aAP woOnlyDmd       e
730aA
730aA*----------------------------------------------------------------
730aA*  getCorrectQty   Determine which quantity to adjust with for reductions
730aA*----------------------------------------------------------------
730aA *  If quantity being adjusted is greater than quantity allocated
730aA *  specifically for Work Orders then use the lesser quantity
730aA *
730aAP getCorrectQty   b
730aAD getCorrectQty   pi
730aA
730aAD alcQty          s             10  0
730aAD adjQty          s             10  0
730aA
730aA /free
730aA
730aA  select;
730aA    // Get usage and current requirements into lowest uom defined
730aA    when itumq3>0;
730aA       alcQty = ($ppcnrm*itumq2*itumq3) + ($ppcbd1*itumq3) + $ppcbd2;
730aA       adjQty = ($ppqty1*itumq2*itumq3) + ($ppQty2*itumq3) + $ppQty3;
730aA       newQtyn=0;
730aA       newQty1=0;
730aA       if alcQty > adjQty;
730aA          newQty2=adjQty;
730aA       else;
730aA          newQty2=alcQty;
730aA       endif;
730aA
730aA       // ensure new quantity has negative value if it should
730aA       if adjQty < 0;
730aA          newQty2 = -(%abs(newQty2));
730aA       endif;
730aA
730aA    when itumq2>0;
730aA       alcQty = ($ppcnrm*itumq2) + $ppcbd1;
730aA       adjQty = ($ppQty1*itumq2) + $ppQty2;
730aA       newQtyn=0;
730aA       newQty2=0;
730aA       if alcQty > %abs(adjQty);
730aA          newQty1=adjQty;
730aA       else;
730aA          newQty1=alcQty;
730aA       endif;
730aA
730aA       // ensure new quantity has negative value if it should
730aA       if adjQty < 0;
730aA          newQty1 = -(%abs(newQty1));
730aA       endif;
730aA
730aA    other;
730aA       alcQty=0;
730aA       adjQty=0;
730aA       newqtyn=0;
730aA       newqty1=0;
730aA       newqty2=0;
730aA  endsl;
730aA
730aA  // Rollup UOM tree
730aA  zzUpQty();
730aA
730aA
730dA  $ppQty1 = newQtyn;
730aA  $ppQty2 = newqty1;
730aA  $ppQty3 = newQty2;
730aA
730aA /end-free
730aAP getCorrectQty   e
730aA
730aA*----------------------------------------------------------------
730aA*  zzUpQty  Up Quantity through Unit of Measure structure
730aA*           Setup as subprocedure to call from either subroutine or procedure
730aA*----------------------------------------------------------------
730aAP zzupQty         b
730aAD zzupQty         pi
730aA
730aA /free
730aA       // check for negative quantities
700bA       *in49=*off;
700bA       if newqtyn<0;
700bA          *in49=*on;
700bA          newqtyn = %abs(newqtyn);
700bA       endif;
700bA       if newqty1<0;
700bA          *in49=*on;
730aA          newqty1 = %abs(newqty1);
730aA       endif;
730aA       if newqty2<0;
730aA          *in49=*on;
730aA          newqty2 = %abs(newqty2);
730aA       endif;
730aA
730aA       dow squmq3 > 0 and +
730aA           newqty2 >= squmq3;
730aA          newqty2 -= squmq3;
730aA          newqty1 += 1;
730aA       enddo;
730aA
730aA       dow squmq2 > 0 and +
730aA           newqty1 >= squmq2;
730aA          newqty1 -= squmq2;
730aA          newqtyn += 1;
730aA       enddo;
730aA
730aA       if *in49;
730aA          newqtyn = newqtyn * -1;
730aA          newqty1 = newqty1 * -1;
730aA          newqty2 = newqty2 * -1;
730aA       endif;
730aA /end-free
730aA
730aAP zzupQty         e

730aA*----------------------------------------------------------------
730aA*  splitQty  This procedure takes the alpha quantity represented
730aA*            as Normal.BD1.BD2 and returns lowest breakdown as
730aA*            number for compares
730aA*----------------------------------------------------------------
730aA *  This procedure will return a number that represents full case counts
730aA *  of $ppcBd1, 2 only
730aA *
730aAP splitQty        b
730aAD splitQty        pi            11  0
730aAD  iStrQty                      15    value
730aA
730aAD returnQty       s             11  0
730aA
730aA /free
730aA     // retrieve and send back updated requried quantities
730aA     clear bomQary;
          wrkQtyn=0;
          wrkQty1=0;
          wrkQty2=0;
730aA     // call procedure that splits normal qty text string into case and brkdwn qtys
730aA     bomQary = Split(iStrQty:'.');
730aA     lpos = 1;
730aA     dow lpos < 4;
730aA       if bomQary(lpos) <> *blanks;
730aA          select;
730aA           when lpos = 1;
730aA             wrkQtyn  = %Dec(%trim(bomQary(lpos)):5:0);
                  if $ppovrd>0 and ($ppdel='Y' or $ppdel='X' or wrkQtyn<0
                     or $ppovr1>0 or $ppovr2>0);
                     // if quantity overrides exist remove these from this
                     // calculation since these quantities should be manually
                     // removed as they were manually put in place
                     wrkQtyn = wrkQtyn - $ppovrd;
                     wrkQty1 = wrkQty1 - $ppovr1;
                     wrkQty2 = wrkQty2 - $ppovr2;
                  endif;
730aA           when lpos = 2;
730aA             wrkQty1  = %Dec(%trim(bomQary(lpos)):5:0);
730aA           when lpos = 3;
730aA             wrkQty2  = %Dec(%trim(bomQary(lpos)):5:0);
730aA          endsl;
730aA       endif;
730aA       lpos = lpos + 1;
730aA     enddo;

          // if string value started with '-' then force all three to negative
          if %scan('-':iStrQty) <>0;
             wrkQtyn = -(%abs(wrkQtyn));
             wrkQty1 = -(%abs(wrkQty1));
             wrkQty2 = -(%abs(wrkQty2));
          endif;

          squmq2=itumq2;
          squmq3=itumq3;
          if squmq2=0;
             squmq2=1;
          endif;
          if squmq3=0;
             squmq3=1;
          endif;
          returnQty = (wrkQtyn*squmq2*squmq3) + (wrkQty1*squmq3) + wrkQty2;
          return returnQty;

730aA /end-free

730aAP splitQty        e
730aA
730aA*----------------------------------------------------------------
730aA*  calcReq  Calculate the Required Quantities based on whether
730aA*           delete or adjustment
730aA*----------------------------------------------------------------
730aAP calcReq         b
730aAD calcReq         pi
730aA
730aA /free
                newQtyn=0;
                newQty1=0;
                newQty2=0;
730aA           // Always calculate Required inventory less current make quantity to return
                // valid reduction for deletions
                if $ppDel = 'Y';                  // Use Required when deleting
730aA              bomQary = Split(SMREQQ:'.');
730aA              lpos = 1;
730aA              dow lpos < 4;
730aA               if bomQary(lpos) <> *blanks;
730aA                 select;
730aA                     when lpos = 1;
                            monitor;
730aA                         newQtyn  = %Dec(%trim(bomQary(lpos)):5:0);
                            on-error;
730aA                         newQtyn  = 0;
                            endmon;
730aA                     when lpos = 2;
                            monitor;
730aA                         newQty1  = %Dec(%trim(bomQary(lpos)):5:0);
                            on-error;
730aA                         newQty1  = 0;
                            endmon;
730aA                     when lpos = 3;
                            monitor;
730aA                         newQty2  = %Dec(%trim(bomQary(lpos)):5:0);
                            on-error;
730aA                         newQty2  = 0;
                            endmon;
730aA                  endsl;
730aA               endif;
730aA               lpos = lpos + 1;
730aA              enddo;
                   if %scan('-':smreqq)=0;     // no minus sign means requirements exist
                      // subtract current make quantities to get reduction to meet
                      // what is being deleted
                      select;
                        when squmq3>1;
                          newQty2 = (((newQtyn+$ppovrd)*squmq2*squmq3) +
                                     ((newQty1+$ppovr1)*squmq3) +
                                      (newQty2+$ppovr2)) -
                                     (($ppmake*squmq2*squmq3)+($ppmake1*squmq3)
                                         + $ppmake2);
                          newQty1=0;
                          newQtyn=0;
                        when squmq2>1;
                          newQty1 = (((newQtyn+$ppovrd)*squmq2)+newQty1+$ppovr1)
                                    -(($ppmake*squmq2) + $ppmake1);
                          newQty2=0;
                          newQtyn=0;
                        other;
                          newQtyn=(newQtyn+$ppovrd)-$ppMake;
                          newQty1=0;
                          newQty2=0;
                      endsl;
                      zzUpQty();
                      reqQtyn=newQtyn;
                      reqQty1=newQty1;
                      reqQty2=newQty2;
                   endif;
                else;           // $ppDel <> 'Y'
730aA              bomQary = Split(SMRMDQ:'.');
730aA              lpos = 1;
730aA              dow lpos < 4;
730aA               if bomQary(lpos) <> *blanks;
730aA                  select;
730aA                     when lpos = 1;
                             monitor;
730aA                          newQtyn  = %Dec(%trim(bomQary(lpos)):5:0);
                             on-error;
730aA                          newQtyn  = 0;
                             endmon;
730aA                     when lpos = 2;
                             monitor;
730aA                          newQty1  = %Dec(%trim(bomQary(lpos)):5:0);
                             on-error;
730aA                          newQty1  = 0;
                             endmon;
730aA                     when lpos = 3;
                             monitor;
730aA                          newQty2  = %Dec(%trim(bomQary(lpos)):5:0);
                             on-error;
730aA                          newQty2  = 0;
                            endmon;
730aA                  endsl;
730aA               endif;
730aA               lpos = lpos + 1;
730aA              enddo;
                 // if any negative values then force all to negative
                 //if reqQtyn<0 or reqQty1<0 or reqQty2<0;
                 if %scan('-':smrmdq)<>0;
                    newQtyn = %abs(newQtyn);
                    newQty1 = %abs(newQty1);
                    newQty2 = %abs(newQty2);
                    // Return net amount for adjustment
                    select;
                      when squmq3>1;
                        newQty2 = (((newQtyn+$ppovrd)*squmq2*squmq3) +
                                   ((newQty1+$ppovr1)*squmq3) +
                                    (newQty2+$ppovr2)) -
                                    (($ppmake*squmq2*squmq3)+($ppmake1*squmq3)
                                       + $ppmake2);
                         newQty1=0;
                         newQtyn=0;
                      when squmq2>1;
                        newQty1 = (((newQtyn+$ppovrd)*squmq2)+newQty1+$ppovr1)
                                 - (($ppmake*squmq2) + $ppmake1);
                         newQty2=0;
                         newQtyn=0;
                      other;
                        newQtyn=(newQtyn+$ppovrd)-$ppMake;
                        newQty1=0;
                        newQty2=0;
                    endsl;
                    zzUpQty();
                    reqQtyn=newQtyn;
                    reqQty1=newQty1;
                    reqQty2=newQty2;
                 else;
                    reqQtyn=0;
                    reqQty1=0;
                    reqQty2=0;
                 endif;
                endif;
730aA /end-free

730aAP calcReq         e
730aA
730aA*----------------------------------------------------------------
730aA*  sumTwoGroups  This procedure either adds or subtracts the two
730aA*                sets of numbers sent in along with the + or -
730aA*----------------------------------------------------------------
730aAP sumTwoGroups    b
730aAD sumTwoGroups    pi
730aAD  iGrpTag                      15    const
730aAD  iAddSub                       1    const
730aAD  ileftCase                    10  0 value
730aAD  ileftBD1                     10  0 value
730aAD  ileftBD2                     10  0 value
730aAD  irightCase                   10  0 value
730aAD  irightBD1                    10  0 value
730aAD  irightBD2                    10  0 value
730aA
730aA /free
         // subtract current make quantities to get reduction to meet
         // what is being deleted
         if iAddSub = '-';        // subtract values
           select;
             when squmq3>1;
               newQty2 = ((ileftCase*squmq2*squmq3) +
                          (ileftBD1*squmq3) +
                           (ileftBD2)) -
                          ((irightCase*squmq2*squmq3)+(irightBD1*squmq3)
                          + irightBD2);
               newQty1=0;
               newQtyn=0;
             when squmq2>1;
               newQty1 = ((ileftCase*squmq2)+ileftBD1)
                         -((irightCase*squmq2) + irightBD1);
               newQty2=0;
               newQtyn=0;
            other;
               newQtyn=ileftCase-irightCase;
               newQty1=0;
               newQty2=0;
           endsl;
         else;   // Else add values together
           select;
             when squmq3>1;
               newQty2 = ((ileftCase*squmq2*squmq3) +
                          (ileftBD1*squmq3) +
                           (ileftBD2)) +
                          ((irightCase*squmq2*squmq3)+(irightBD1*squmq3)
                          + irightBD2);
               newQty1=0;
               newQtyn=0;
             when squmq2>1;
               newQty1 = ((ileftCase*squmq2)+ileftBD1)
                         +((irightCase*squmq2) + irightBD1);
               newQty2=0;
               newQtyn=0;
            other;
               newQtyn=ileftCase+irightCase;
               newQty1=0;
               newQty2=0;
           endsl;
         endif;

         zzUpQty();

         select;
           when iGrpTag = '$ppcnrm';
             $ppcnrm=newQtyn;
             $ppcbd1=newQty1;
             $ppcbd2=newQty2;
           when iGrpTag = 'pmake';
             pMake=newQtyn;
             pMake1=newQty1;
             pMake2=newQty2;
           when iGrpTag = '$ppovrd';
             $ppovrd=newQtyn;
             $ppovr1=newQty1;
             $ppovr2=newQty2;
           when iGrpTag = '$ppmake';
             $ppMake=newQtyn;
             $ppMake1=newQty1;
             $ppMake2=newQty2;
           when iGrpTag = '$ppqty1';
             $ppQty1=newQtyn;
             $ppQty2=newQty1;
             $ppQty3=newQty2;
           when iGrpTag = 'pmakeqty';
             pMakeQty=newQtyn;
             pMakeQty1=newQty1;
             pMAkeQty2=newQty2;
           when iGrpTag = 'netdifn';
             netDifn=newQtyn;
             netDif1=newQty1;
             netDif2=newQty2;
         endsl;

730aA /end-free

730aAP sumTwoGroups    e
