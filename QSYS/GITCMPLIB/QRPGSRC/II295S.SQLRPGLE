640aA /copy qcopysrc,hspecs
760 AH Dftactgrp(*No)
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  II295S    Staging Import - Items
     *  12 February 2011
     *  Dave Sommerville
     *
     *  This program was based on II295. All II295 revision comments
     *  were kept in this program. See 640 notes.
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
640aA*    01/25/11  DAS  6.40a
     *      - Revised to used staging file impsitmn in place of
     *        file impfitmn.
     *
640bA*    02/10/11  DAS  6.40b
     *      - Renamed IUVEN# to IUVEN
     *      - Renamed IUVIT# to IUVITM
640cA*    04/18/11  RH/MLB  6.40c
     *      - Fix: Revised program to update # of pick slots on update
640dA*    04/21/11  MLB  6.40d
     *     - Fix: Revised program when item cube is not updated from
     *        host and item dimensions are imported, to update item cube
     *        when the new computed cube is different from the cube on
     *        file.
640e *    10/18/12  LMC  6.40e
     *      ITEMFLD database change - requires recompile.
640f *    11/16/12  DAS  6.40f
     *      - Revised to remove CRLF characters from descriptions.
     *        Re: HM Wagner had these characters in their descriptions,
     *        which caused problems in rendering DragDrop screen.
640gA*    08/09/12  MLB  6.40g  (was 6.40e at HMW)
     *      - Fix: Revised program to cause pgm to compute item cube if
     *        opcube=Y and IUCUBE = 0.000. Pgm was not computing cube for
     *        item when dimensions sent, but zero cube imported.
640hA*    12/20/12  MLB  6.40h
     *     - Fix: Change to use logical so that base/parent items are
     *       created first.
640iA*     08/09/12  MLB  6.40i (missed in previous update)
     *       - Fix: Revised program to cause pgm to compute item cube
     *         opcube=Y and IUCUBE = 0.000. Pgm was not computing cubebe
     *         item when dimensions sent, but zero cube imported.
     *
650 A*    01/10/13  MLB  6.50
     *      - Fix: Revised to remove CRLF characters from item brand.
     *        Re: HM Wagner had these characters in their item brand,
     *        which caused problems in rendering DragDrop screen.
650 A*    01/22/13  MLB  6.50
     *      - Enh: Revised program to retrieve printer override for
     *        item import detail report, II265PR so that import reports
     *        can be directed where the user wants them to go.
650aA*    06/20/13  RTR  6.50a
     *      - Fix: Revised to convert any special character to a space
     *        for name/desc fields.
650b *    03/22/13  KDE  6.50b
     *      Changed to add blanks for DISP field in KITCOMP and chang
     *       to add KITITEM with default values for new Repack KIT
     *       format.  I am ONLY adding defaults to KITITEM until we
     *       add more fields to the incoming import
650cA*    07/17/13  MLB  6.50c
     *      - Fix: Revised program to set ITFLGD to N=No if OPFLGD = N.
     *      - Fix: Revised program to set IMMFLG to N=No if OPMFLG = N.
650dA*    07/17/13  MLB  6.50d
     *      - Enh: Revised pgm to add record to ITEMFLD file only when
     *        item doesn't exist. Initialize following new fields:
     *        IFUCICDE, IFRCVMTH, IFSLTMTH and IFBRDFLG.
650eA*    07/17/13  MLB  6.50e
     *      - Fix: Revised program to unlock record when chaining to
     *        DESIG, UNMESR, ACTIVITY and BLDCODE.
650fA*    08/18/13  MLB  6.50f
     *      - Fix: Change to 6.50a. Revised pgm to correct pointer error
     *        to prevent it from being incremented past 30.
650g *    08/28/13  KDE  6.50c
     *      Changed to allow for multiple records in Itemlnk for
     *       Repack Items to support Repack 6.50 changes
700a *    07/23/15  RTR  7.00a
     *      - Fix: Add mod 610 to brkdwn 1 & 2 also.
700bA*    06/11/16  DAS  7.00b
     *      - Enh - Revised to delete *EACH records from
     *        ITEMAVG, ITEMSLS.
700c *    06/11/16  DAS  7.00b
     *      - Reserved
700d *    06/11/16  DAS  7.00b
     *      - Reserved
700d *    06/11/16  DAS  7.00b
     *      - Reserved
700e *    08/14/15  RTR  7.00e
     *      - Fix: NECS Entree sending gross weight in IUBLNK, use
     *        when IUSWGT is zero. Added *HOST option checking to do
     *        for all NECS Entree clients.
700f *    03/02/16  RTR  7.00f
     *      - Enh: NECS Entree doesn't do PIR. If existing item is PIR,
     *        do not update section type for Entree clients.
700gA*    11/02/16  LMC  7.00g
     *      - Recompile only - UPC file changed.
     *
710a *    09/27/17  RTR  7.10a
     *      - Enh: for NECS Entree, put category in ITEMFLD/IFCAT also.
     *      - Enh: Always update ITEMEXT and ITEMFLD.
     *      - Enh: For NECS Entree, force IMPCAT to uppercase.
710b *    10/11/17  RTR  7.10b
     *      - Fix: Report date wasn't populated, fixed.
     *      - Enh: If IMPCAT not in ITEMCAT, add it.
     *
720a *    01/10/19  RTR  7.20a
     *      - Enh: for NECS Entree, do not update catchweight range.
730a *    01/21/19  RTR  7.30a
     *      - Enh: Uppercase item numbers.
     *      - Enh: Uppercase department.
730b *    03/08/19  RTR  7.30b
     *      - Fix: When ITEMMSC rec not found on chain, clear IMREC so
     *        existing values not used.
730c *    09/13/19  RTR  7.30c
     *      - Enh: Change to not print unless there is an error or
     *        items processed.
730d *    09/13/19  RTR  7.30d
     *      - Enh: For Aspen Canopy, if Date Sensitive = N clear other
     *        values.
730e *    09/20/19  RTR  7.30e
     *      - Enh: Added back update for IULTRK that had been commented
     *        out in mod 610 above.
730f *    11/18/19  RTR  7.30f
     *      - Hold for mod coming from A&D.
730g *    01/03/20  RTR  7.30g
     *      - Enh: Uppercase brand.
730h *    01/07/20  RTR  7.30h
     *      - Enh: Changed mod 710a to update ITEMFLD/IFCAT for all hosts.
740a *    02/11/20  RTR  7.40a
     *      - Fix: For NECS Entree, update cube/weight on type S/B items.
740b *    07/08/20  RTR  7.40b
     *      - Enh: Added uppercase for UOMs, Pack Desc.
740c *    09/02/20  RTR  7.40c
     *      - Enh: Reserved for mod coming from CPJ.
750a *    02/23/21  RTR  7.50a
     *      - Fix: Fix for 700e mod for NECS, which was missing.
750bA*    01/18/22  MLB  7.50b
     *      - Enh: for NECS Entree.
     *      - Revise program to call GETUSER to retrieve buyer number
     *        stored in the PIR User table as emp. nbr, first/last name.
     *        Import fields, IUBNBR, IUBNAM. Buyer ID is sent in IMPMS2
750c *    02/17/22  KDE  7.50c
     *      - Fix: Fix for mod 511a.  Do not create RPK for ondemand repacks
760  *    09/02/22  KDE  7.60
     *      - Enh:  Add call to interface error reporting in Report
     *        Scheduler when import has a failure or error
760a *    01/08/23  KDE  7.60a
     *      - Enh:  Change interface error report to R42600.  Also
     *        Add extended message for complete Stage Batch
     *
760bA*    09/09/22  TDC  7.60b
     *      - For FreshByte:
     *      - When updating an item, if WHDP is passed, use it.
     *      - When adding an item, if WHDP is blanks, Default 'UNK'.
     *      - These updates will execute if the system option for updating
     *        the department = 'Y'.
     *      - Change breakdown quantity 2 to be breakdown quantity
     *        2 divided by breakdown quantity 1.
     *
770 A*    02/21/23  MLB  7.70
     *      - Fix: Revised 7.60b mod to set IUWHDP = UNK when FRESHBYTE
     *        and IUWHDP = blanks.
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
HMW A*    04/27/12  MLB  HMW
     *      - Revise program to set IUWHDP to ZZ if blank.
HMWaA*    04/04/12  MLB  HMWa
     *      - Revised program to omit all slots that begin with 'S'
     *        which are showroom slots.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Hearn Kirkwood
     *
HKW A*    01/19/13  MLB  HKW
     *      - Revise program to not change item type when item is defined
     *        as ITTYPE = S=Same Slot Breakdown.
     *      - Revise program to not update brkdown 1 UoM, UomQ1 when
     *        parent item found in ITEMLNK13
     *      - Revise program to not update ITUM1, ITUM2, ITUMQ1 when
     *        ITTYPE = S.
HKWaA*    01/21/13  MLB  HKWa
     *      - Revise program to not change item type when item is defined
     *        as ITTYPE = B=Breakdown.
     *      - Revise program to not update brkdown 1 UoM, UomQ1 when
     *        parent item found in ITEMLNK13
     *      - Revise program to not update ITUM1, ITUM2, ITUMQ1 when
     *        ITTYPE = B.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
     *
ADFa *    12/16/16  RTR  ADFa
     *      - Force cube to 1.21 if not sent and existing is 0.
ADFb *    10/11/17  RTR  ADFb
     *      - Added A&D to mod CSPb
ADFcA*    01/30/20  MLB  ADFc
     *      - Removed ADFa mod. Per Michelle H email dated 01.29.20.
ADFdA*    02/16/21  MLB  ADFd
     *      - Revised pgm to only update ITSTYP on add. Section Type to
     *        be maintained on Dakota. Johnny Mullins setup PIR items.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Chef's Warehouse
     *
DRYaA*    03/25/14  RTR  DRYa
     *      - Revised override for error listing with email address from
     *        RPTEML file.
DRYbA*    06/08/15  MLB  DRYb
     *      - Revise program to update IMODAY to 720 days for items with
     *        ITWHDP = 'DRY'. All other items will default to 360.
     *      - Per Kelly R email dated 06/05/2015.
DRYcA*    09/16/15  MLB  DRYc
     *      - Revise program to update ITWHDP for new items only even
     *        though OPWHDP = N. Item will be defaulted to Host depart-
     *        ment when item is added. After that, individual warehouse
     *        locations will maintain the department. This mod is being
     *        done because not all of Dairyland's warehouses store an
     *        item in the same warehouse area. This mod will allow each
     *        warehouse to control where they store an item.
     *       -Copied mod from OI285, DRYa.
DRYdA*    11/07/16  MLB  DRYd
     *      - Revise program to update item c/wgt variance fields for new
     *        items and update if variances are zero and update has
     *        positive values.
     *       -Copied mod from OI285, DRYd.
DRYeA*    03/02/22  MLB  DRYe
     *      - Revise DRYd mod to correct update for c/wgt variance 2 field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marque's Foods
     *
MQSa *    01/18/18  RTR  MQSa
     *      - Force all type S items to type B, because all their
     *        breakdowns are in their store slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    09/05/18  RTR  EOPa
     *      - Force all items to department REF.
EOPb *    10/10/18  RTR  EOPb
     *      - Handle special breakdowns.
EOPc *    10/26/18  RTR  EOPc
     *      - For 2.5 dozen items, check for repack and create if not
     *        found.
EOPd *    11/26/18  RTR  EOPd
     *      - Adding half doz to items with only dozen UOM.
EOPe *    01/17/19  RTR  EOPe
     *      - Items F3659, F0575, O4161, remove HD UOM per Shane.
EOPf *    07/01/19  RTR  EOPf
     *      - Change to handle 'EA' only sample items.
EOPgA*    11/04/21  MLB  EOPg  ZD#5699
     *      - Enh: Revised pgm to only update item designation when code
     *        sent from host is NSTK*.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dependable Foods
     *
DFCa *    02/17/20  RTR  DFCa
     *      - Rename departments COOLE and FROZE.
DFCb *    03/02/20  RTR  DFCb
     *      - Clear sent cube if dimensions sent, divide weight by 10.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony Foods
     *
CFIa *    05/02/18  RTR  CFIa
     *      - Default Section Type to F.
CFIb *    05/19/18  RTR  CFIb
     *      - Temp mod to turn off date sensitive for DRY/FRZ.
CFIdA*    05/20/21  MLB  CFId
     *      - Disabled CBIb mod per Paul B response in zd# 4311. Date
     *        sensitive items will be managed from Aspen for DRY/FRZ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi Foods
     *
ACCa *    05/27/18  RTR  ACCa
     *      - Default Section Type to F.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Palmer Foodservice
     *
JPFa *    01/21/19  RTR  JPFa
     *      - If UOM is LB and catchweight, change UOM to CS.
JPFb *    08/07/19  RTR  JPFb
     *      - For type 'P' or 'B' items, change to blank and don't update
     *        breakdown UOMs. Also do not update repack fields for JPF.
JPFcA*    06/21/21  MLB  JPFc
     *      - As part of Accumatica upgrade, needed to add pgm logic to
     *        convert Accumatica codes to single BFC dept codes.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Tiffin Products
     *
TPCa *   07/15/19  RTR  TPCa
     *      - Convert entree depts to standard DRY/REF/FRZ.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Lieber's Kosher Foods
     *
LKFa *   09/18/19  RTR  LKFa
     *      - Default UOM to CS when blank.
LKFb *   11/06/19  RTR  LKFb
     *      - Set type=A for items that begin with '*' and master item
     *        to same without *.
LKFc *   11/06/19  RTR  LKFc
     *      - Load UPC from Misc 1 if not on file.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Caribbean Producers Jamaica
     *
CPJa *   02/12/20  RTR  CPJa
     *      - Default Normal UOM to CS when KG.
     *      - Default Breakdown 1 UOM to EA when KG.
CPJbA*   08/04/21  MLB  CPJb  ZD# 4991
     *      - Revised routine, ZZUPD1 to add code to add/update
     *        Item Category Code sent from Host.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
SFP A*   09/19/22  MLB  SFP
     *      - Revised pgm to not update category code while on Thyme ERP.
     *        Host interface does not support maintenance of this field.
     *   02/01/23  RH   Merged SFP mod into current version
SFPaA*   02/08/23  MLB  SFPa
     *      - Revised pgm to not update category code unless category
     *        code greater than blanks. SFP mod only addressed additions.
SFPbA*   02/20/23  MLB  SFPb
     *      - Revised pgm to not update category code if = WET.
     *        FreshByte does not have the WET Category code setup.
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
640hDF*impsitmn  uf   e           k disk
EOPcDF*impsitmn1 uf   e           k disk
EOPcMFimpsitmn1 uf a e           k disk
640aDF*mpfitm4  uf   e             disk
640aDF*mpfitmm  uf   e           k disk    usropn
     Fwarehs    if   e           k disk
     Freports   if   e           k disk
     Fpiritem   uf a e           k disk
     Fitemdsc   uf a e           k disk
     Fitemdef   uf a e           k disk
650dDF*itemfld   if   e           k disk    usropn
650dMFitemfld   Uf a e           k disk
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
650 AF                                     usropn
     Fwhdept    if   e           k disk
     Fdesig     uf a e           k disk
     Factivity  uf a e           k disk
     Funmesr    uf a e           k disk
     Fbldcode   uf a e           k disk
     Fslot3     uf   e           k disk
     Fupc1      uf   e           k disk
LKFcAFupc2      uf a e           k disk    rename(uprec:uprec2)
511aAFkitcomp   uf a e           k disk
650bAFkititem   uf a e           k disk
710bDF**itemcat   uf a e           k disk
710bAFitemcat   if a e           k disk
510bA*----------------------------------------------------------------
510bA*  Customer id
510bA*
PAK A /COPY QCOPYSRC,ID#packers
CCP A /COPY QCOPYSRC,ID#capitol
CSP A /COPY QCOPYSRC,ID#coastal
640aM /COPY QCOPYSRC,ID#cheney
AFS A /COPY QCOPYSRC,ID#andrews
CPC A /COPY QCOPYSRC,ID#cpc
HMW A /COPY QCOPYSRC,ID#hmwagne
DRYaA /copy qcopysrc,id#dairyla
HKW A /COPY QCOPYSRC,ID#hkw
ADFaA /COPY QCOPYSRC,ID#adf
MQSaA /copy qcopysrc,id#mqs
EOPaA /copy qcopysrc,id#eop
DFCaA /copy qcopysrc,id#dfc
CFIaA /COPY QCOPYSRC,ID#cfi
ACCaA /COPY QCOPYSRC,ID#acc
JPFaA /copy qcopysrc,id#palmer
TPCaA /copy qcopysrc,id#tpc
LKFaA /copy qcopysrc,id#lkf
CPJaA /copy qcopysrc,id#cpj
SFP A /copy qcopysrc,id#sfp
510bA*
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a30             s              1    dim(30)
     *                   DESC    1  44 30
510fDD*desc            s             30    dim(45) ctdata perrcd(1)
510fMD desc            s             30    dim(46) ctdata perrcd(1)
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

640fA*----------------------------------------------------------------
640fA*  Constants
640fA*----------------------------------------------------------------

640fAD spaces          c                   const('  ')
650aAD okchar          c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ+
650aAD                                      abcdefghijklmnopqrstuvwxyz+
650aAD                                      0123456789+
650aAD                                      .%/- ()*&$#!?='
710aAd lower           c                   'abcdefghijklmnopqrstuvwxyz'
710aAd UPPER           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

760 A /copy qcopysrc,c#stdvar
760 AD/copy qcopysrc,p.mrcrptsc
760 AD/copy qcopysrc,p.qcmdexc
760aAd/copy qcopysrc,p.wIntLog

510bA*----------------------------------------------------------------
510bA*  Working variables
510bA*
     D actcub          s                   like(itcube)
640aMD addflg          s               n
     D a2nflg          s              1
640aMD chgflg          s               n
650aAD chkpos          s              3  0
650aAD chkstr          s             30a
     D count           s              3  0
EOPcAd crtRepack       s               n
EOPcAd crtRpkPar       s             15a
700bAD dltItem         s                   like(ititem)
     D eofd            s              1
     D eofi            s              1
     D eofl            s              1
     D first           s              1
     D forevr          s              1
710aAD host            s             20a
     D grdord          s              5  0
HKW AD hkw_lnkrcd      s              4    inz('*NO ')
     D impdte          s              8  0
640aAD importError     s               n
     D imptim          s              6  0
     D itumq3          s              3  0
     D itum2           s              2
     D itum3           s              2
JPFbAd JpfParent       s               n   inz('0')
     D kysdef          s              2
     D kywhse          s              3  0
     D len             s              1  0
     D linppg          s              3  0
510cAD miscitmupd      s              4    inz('*NO ')
LKFcAd ntype           s              7a
510cAD opnimpitmm      s              1    inz('0')
     D opcode          s              8
     D pflag           s              1
     D pos             s              1  0
     D pxflg           s              1
640aAD stamp           s               z
640aAD stampUC         s               z
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
760 AD currReport      s             20
760 AD url             s           3000
760 AD schEmail        s           1000
760 AD orient          s              1
760 AD grDev           s             10
760 Ad sbmusr          s             10
760 Ad sbmjobd         s             10
760 Ad sbmlibl         s             10
760 AD cmd             s           3000    varying
760 AD opmusr          s             10
760 Ad opjobd          s             10

760 A*----------------------------------------------------------------
760 A*  Sub-procedure prototypes
760 A*----------------------------------------------------------------

760 Ad getSchTimeEml   pr

640aA
640aA*----------------------------------------------------------------
640aA*  Parameters
640aA*----------------------------------------------------------------
640aA
640aAD $pWhse          s              3p 0
640aAD $pWhse3A        s              3
640aAD $pBatId         s             11
640aAD $pReturn        s             10
640aAD $pMessage       s            200
640aA
     *----------------------------------------------------------------
     *  Program info data structure
     *
640aA /copy qcopysrc,c#pgminfds
640aDD*               sds
640aDD* #prog            *proc
640aDD* #job                 244    253
640aDD* #user                254    263
640aDD* #jobn                264    269
640aDD* #jobdt               276    281  0
640aDD* #jobtm               282    287  0

640aA*----------------------------------------------------------------
640aA*  Standard SQL variables and constants
640aA*----------------------------------------------------------------
640aA
640aA /copy qcopysrc,c#stdsql

640aA*----------------------------------------------------------------
640aA*  File data data structure
640aA*----------------------------------------------------------------
640aA
640aAD sbrec         E ds                  extname(stgbatch) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
640aA*      $pWhse  - Warehouse
640aA*      $pBatId - Batch id
     *
     *    Returned Parameters
640aA*      $pReturn  - Return code
640aA*      $pMessage - Return message
     *
     *----------------------------------------------------------------

640aAc     *entry        plist
640aAc                   parm                    $pWhse3A
640aAc                   parm                    $pBatId
640aAc                   parm                    $pReturn
640aAc                   parm                    $pMessage
640aA
640aAc                   eval      $pWhse = %dec($pWhse3A: 3: 0)
640aAc                   eval      $pReturn = '*OK'
640aAc                   eval      $pMessage = ' '
640aAC                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *
640aA* Update stgbatch record to start process
640aA*
640aAC                   exsr      zzzStart
640aAC                   if        $pReturn <> '*OK'
640aAC                   return
640aAC                   endif
     *
     * Whip through all the download Update Item records
     *
     C                   eval      first = *on
     C                   eval      pflag = *on
     C                   eval      eofi = *off
     C                   eval      linppg = 55
     C                   eval      count = 0

640hDC*    keyiu         setll     impsitmn
640hMC     keyiu         setll     impsitmn1
     C                   dou       eofi = *on
     *
640aDC**                 read      impfitm4                               79
640hDC*    keyiu         reade     impsitmn                               79
640hMC     keyiu         reade     impsitmn1                              79
     C                   eval      error = *off
     C                   if        *in79
     C                   eval      eofi = *on
640aDC**                 goto      enddiu
640aAC                   leave
     C                   endif
PAK A*
730aA* Make sure item and master item are uppercase.
730aAc                   eval      iuitem = %xlate(lower:UPPER:iuitem)
730aAc                   eval      iumitm = %xlate(lower:UPPER:iumitm)
730aA* Make sure department is uppercase.
730aAc                   eval      iuwhdp = %xlate(lower:UPPER:iuwhdp)
730aA
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
650dDC*    ifkey         chain     itemfld
650dMC*    ifkey         chain(n)  itemfld
CSPdAC                   if        not %found(itemfld)
CSPdAC                   clear                   ifcat
CSPdAC                   endif
HMW A*
HMW AC                   when      client = HMWagner
HMW A*
HMW AC                   select
HMWaAC                   when      %subst(iuwhdp:1:2) = 'SH'
HMWaA*      Skip showroom slots.
HMWaAC                   iter
HMWaA*
HMW A*      For items missing dept code, set to ZZ=Not Slotted dept.
HMW AC                   when      iuwhdp = '     '
HMW AC                   eval      iuwhdp = 'ZZ   '
HMW AC                   endsl
CSPdA*
MQSaAC                   when      client = Marques
MQSaAC                   exsr      PreProcMQS
MQSaA*
EOPaA /free
EOPaA    when client = Earls;
EOPaA      exsr PreProcEOP;
EOPaA /end-free
JPFaAC                   when      client = Palmer
JPFaAC                   exsr      PreProcPAL
JPFaA*
DFCaAC                   when      client = Dependable
DFCaAC                   exsr      PreProcDFC
DFCaA*
TPCaAc                   when      client = TPC
TPCaAc                   exsr      PreProcTPC
TPCaA
LKFaAc                   when      client = Liebers
LKFaAc                   exsr      PreProcLKF
LKFaA
CPJaAc                   when      client = CPJ
CPJaAc                   exsr      PreProcCPJ
CPJaA
PAK AC                   endsl
PAK A*
510cA*
640aD ** Retrieve Import Item Update Misc. file.
640aDC**                 if        miscitmupd = '*YES'
640aDC**   itkey         chain     impfitmm
640aDC**                 if        not %found(impfitmm)
640aDC**                 clear                   impgrp
640aDC**                 clear                   imppnt
640aDC**                 clear                   impvar
640aDC**                 clear                   impcat
640aDC**                 clear                   impms1
640aDC**                 clear                   impms2
640aDC**                 clear                   impms3
640aDC**                 clear                   impms4
640aDC**                 clear                   impms5
640aDC**                 endif
640aDC**                 endif
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
710bAC                   eval      rdate = %dec(%char(%date():*mdy0):6:0)
     C                   eval      count = 0
     C                   write     head1
     C                   add       3             count
     C                   eval      pflag = *off
     C                   endif
640aA*
640aA*  Skip processed records.
640aA*
640aAC                   if        iustatus <> 'R'
640aAC                   iter
640aAC                   endif
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
640aA*       Staging file records do not get deleted when processed.
     *
640aDC**                 delete    iurec
640aD **
640aD **     Import Item Updates Misc file record imported.
640aDC**                 if        miscitmupd = '*YES'
640aDC**                           and %found(impfitmm)
640aDC**                 delete    imprec
640aDC**                 endif
     *
     C     enddiu        tag

640aAC                   if        error
640aAC                   eval      importError = *on
640aAC                   eval      iustatus = 'E'
640aAC                   eval      iutext   = detmsg
640aAC                   else
640aAC                   eval      iustatus = 'S'
640aAC                   if        addflg or chgflg
640aAC                   eval      iutext = detmsg
640aAC                   else
640aAC                   eval      iutext = ' '
640aAC                   endif
640aAC                   endif
640aAC                   exsr      zzzGetStamps
640aAC                   eval      iuststs = stamp
640aAC                   eval      iustsuc = stampuc
640aAC                   update    iurec
EOPcA
EOPcA /free
EOPcA   // Create repack item if needed
EOPcA   if client = EarlsOrganic
EOPcA    and crtRepack = *on;
EOPcA     exsr zzCrtRepack;
EOPcA   endif;
EOPcA /end-free
EOPcA
LKFcA /free
LKFcA    if client = Liebers
LKFcA     and impms1 <> *blanks;
LKFcA      exsr zzckup;
LKFcA      exsr zzupdu;
LKFcA    endif;
LKFcA /end-free

     C                   enddo
     *
     *
     *  Print order grand totals
     *
     C                   if        pflag = *on
730cAC                             and first = *off
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
640aAC                   exsr      zzzEnd
640aDC**                 eval      *inlr = *on
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
640aD **
640aD **
640aD **Open IMPFORDHM file.
640aDC**                 if        opnimpitmm <> *on
640aDC**                 open      impfitmm                             67
640aDC**                 if        *in67 = *off
640aDC**                 eval      opnimpitmm = *on
640aDC**                 eval      miscitmupd = '*YES'
640aDC**                 else
640aDC**                 eval      miscitmupd = '*NO '
640aDC**                 endif
640aDC**                 endif
510cA*
650dA* Open ITEMFLD file.
650dAC                   if        client = coastalsunbelt
650dA*
650dAC                   if        not %open(itemfld)
650dAC                   open      itemfld
650dAC                   endif
650dA*
650dAC                   endif
650dA*
     * Key definitions
640aA*
640aA*  Define key for impsitmn file.
640aA*
640aAC     keyiu         klist
640aAC                   kfld                    $pWhse
640aAC                   kfld                    $pBatId
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    iuwhse
     C                   kfld                    iuitem

700bAC     keyitdel      klist
700bAC                   kfld                    iuwhse
700bAC                   kfld                    dltItem
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
650gAC                   kfld                    iumitm
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
ACCaA*----------------------------------------------------------------
ACCaA*
ACCaA*  PreProcACC   Pre-Process Accardi Foods Items.
ACCaA*
ACCaA /free
ACCaA   begsr PreProcACC;
ACCaA
ACCaA     if iustyp = ' ';
ACCaA       iustyp = 'F';
ACCaA     endif;
ACCaA     select;
ACCaA       when iuwhdp = 'Dry';
ACCaA         iuwhdp = 'DRY';
ACCaA       when iuwhdp = 'Refri';
ACCaA         iuwhdp = 'REF';
ACCaA       when iuwhdp = 'Froze';
ACCaA         iuwhdp = 'FRZ';
ACCaA       when iuwhdp = 'Candy';
ACCaA         iuwhdp = 'TEMPC';
ACCaA       when iuwhdp = 'Liquo';
ACCaA         iuwhdp = 'LIQ';
ACCaA       when iuwhdp = 'Espre';
ACCaA         iuwhdp = 'EPLUS';
ACCaA     endsl;
ACCaA
ACCaA   endsr; // PreProcACC
ACCaA /end-free
CFIaA*----------------------------------------------------------------
CFIaA*
CFIaA*  PreProcCFI   Pre-Process Colony Foods Items.
CFIaA*
CFIaA /free
CFIaA   begsr PreProcCFI;
CFIaA
CFIaA     if iustyp = ' ';
CFIaA       iustyp = 'F';
CFIaA     endif;
CFIaA     if iumflg = 'Y';
CFIaA       iuflgd = 'Y';
CFIaA     endif;
CFIdD     //if iuwhdp = 'DRY'
CFIdD     //  or iuwhdp = 'FRZ';
CFIdD     //    iuflgd = 'N';
CFIdD     //    iumflg = 'N';
CFIdD     //endif;
CFIaA
CFIaA   endsr; // PreProcCFI
CFIaA /end-free
EOPaA*----------------------------------------------------------------
EOPaA*
EOPaA*  PreProcEOP   Pre-Process Earl's Organic Items.
EOPaA*
EOPaA /free
EOPaA   begsr PreProcEOP;
EOPaA
EOPaA     // Skip Repack items, already handled.
EOPaA     if iutype = 'R';
EOPaA       leavesr;
EOPaA     endif;
EOPaA
EOPaA     // For Earl's, all items are REF items.
EOPaA     iuwhdp = 'REF';
EOPaA
EOPaA     // Convert UOMs - first pass.
EOPaA     iuum1 = 'CS';
EOPaA     if iuumq2 <= 1;
EOPaA       iuum2 = *blank;
EOPaA       iuumq2 = 0;
EOPaA       iuflg1 = 'N';
EOPaA     else;
EOPaA       iuflg1 = 'Y';
EOPaA       select;
EOPaA         when impms2 = 'CS'
EOPaA          or impms2 = 'EA'
EOPaA          or impms2 = 'PCS';
EOPaA           iuum2 = %subst(impms2:1:2);
EOPaA         when impms2 = 'BAG'
EOPaA          or impms2 = '4/5# BAG'
EOPaA          or impms2 = '10X1# BAGS'
EOPaA          or impms2 = '5 #BAG'
EOPaA          or impms2 = '5# BAG'
EOPaA          or impms2 = 'BAG3#'
EOPaA          or impms2 = '1# BAG';
EOPaA           iuum2 = 'BG';
EOPaA         when %subst(impms2:1:2) = 'LB';
EOPaA           iuum2 = 'LB';
EOPaA         when %subst(impms2:1:2) = 'DZ'
EOPaA          or impms2 = '1DZ';
EOPaA           iuum2 = 'DZ';
EOPaA         when impms2 = 'ROLL';
EOPaA           iuum2 = 'RL';
EOPaA         when impms2 = '5# JAR';
EOPaA           iuum2 = 'JR';
EOPaA         when impms2 = '10 / 1#';
EOPaA           iuum2 = 'LB';
EOPaA         when impms2 = '1/2DZ';
EOPaA           iuum2 = 'HD';
EOPaA         when impms2 = '2DZ';
EOPaA           iuum2 = '2D';
EOPaA         when impms2 = '4X2.5#'
EOPaA          or impms2 = '2.5DZ'
EOPaA          or impms2 = '5#';
EOPaA           iuum2 = 'EA';
EOPaA         when impms2 = '3 OZ'
EOPaA          or impms2 = '4 OZ'
EOPaA          or impms2 = '5OZ'
EOPaA          or impms2 = '4X40OZ'
EOPaA          or impms2 = '40OZ';
EOPaA           iuum2 = 'OZ';
EOPaA         other;
EOPaA           iuum2 = 'EA';
EOPaA           iutext = 'Unknown UOM ' + impms2;
EOPaA       endsl;
EOPaA     endif;
EOPaA
EOPfA     if iuum2 = 'EA' and iuum1 = *blank;
EOPfA       iuum1 = 'EA';
EOPfA       iuum2 = *blanks;
EOPfA     endif;
EOPfA
EOPcA     crtRepack = *off;
EOPbA     // Convert UOMs - second pass.
EOPbA     // handle 2.5 dozen items.
EOPbA     if impms3 = '2.5000';
EOPbA       iuum1 = 'D2';
EOPbA       iuum2 = 'HD';
EOPbA       iuumq2 = 5;
EOPcA       crtRepack = *on;
EOPbA     endif;
EOPbA     // handle 1 breakdown dozen items.
EOPbA     if iuum2 = 'DZ';
EOPbA       iuum3 = 'HD';
EOPbA       iuumq3 = 2;
EOPbA       iuflg2 = 'Y';
EOPbA     endif;
EOPdA     // handle 1 dozen items.
EOPdA     if impms1 = 'DZ'
EOPdA      and impms2 = 'DZ';
EOPdA       iuum1 = 'DZ';
EOPdA       iuum2 = 'HD';
EOPdA       iuumq2 = 2;
EOPdA       iuflg1 = 'Y';
EOPdA     endif;
EOPaA
EOPeA     select;
EOPeA       when iuitem = 'F3659'
EOPeA         or iuitem = 'F0575';
EOPeA         iuum2 = '  ';
EOPeA         iuumq2 = 0;
EOPeA         iuflg1 = 'N';
EOPeA       when iuitem = 'O4161';
EOPeA         iuum3 = '  ';
EOPeA         iuumq3 = 0;
EOPeA         iuflg2 = 'N';
EOPeA     endsl;
EOPeA
EOPaA   endsr; // PreProcEOP
EOPaA /end-free
MQSaA*----------------------------------------------------------------
MQSaA*
MQSaA*  PreProcMQS   Pre-Process Marques Foods Items.
MQSaA*
MQSaA /free
MQSaA   begsr PreProcMQS;
MQSaA
MQSaA     // For Marques, all breakdowns will be type B for store.
MQSaA     if iutype = 'S';
MQSaA       iutype = 'B';
MQSaA     endif;
MQSaA
MQSaA   endsr; // PreProcMQS
MQSaA /end-free
JPFaA*----------------------------------------------------------------
JPFaA*
JPFaA*  PreProcPAL   Pre-Process Palmer Foodservice Items.
JPFaA*
JPFaA /free
JPFaA   begsr PreProcPAL;
JPFaA
JPFbA     // If Parent type, set flag for UOM changes
JPFbA     select;
JPFbA       when iutype = 'P';
JPFbA          JpfParent = *on;
JPFbA          iutype = ' ';
JPFbA       when iutype = 'B';
JPFbA          JpfParent = *on;
JPFbA       other;
JPFbA          JpfParent = *off;
JPFbA     endsl;
JPFcA
JPJcA     select;
JPJcA       when iuwhdp = 'Dry'
JPJcA         or iuwhdp = 'DRY';
JPJcA         iuwhdp = 'D';
JPJcA       when iuwhdp = 'Refri'
JPJcA         or iuwhdp = 'REFRI';
JPJcA         iuwhdp = 'R';
JPJcA       when iuwhdp = 'Froze'
JPJcA         or iuwhdp = 'FROZE';
JPJcA         iuwhdp = 'F';
JPJcA       when iuwhdp = 'Candy'
JPJcA         or iuwhdp = 'CANDY';
JPJcA         iuwhdp = 'R';
JPJcA       when iuwhdp = 'Liquo'
JPJcA         or iuwhdp = 'LIQUO';
JPJcA         iuwhdp = 'D';
JPJcA       when iuwhdp = 'Espre'
JPJcA         or iuwhdp = 'ESPRE';
JPJcA         iuwhdp = 'D';
JPJcA     endsl;
JPFaA
JPFaA     // For Palmer, change all LB catchweight items to CS UOM.
JPFaA     if iuum1 = 'LB' and iucwgt = 'Y';
JPFaA       iuum1 = 'CS';
JPFaA     endif;
JPFaA
JPFaA     // Handle broken case items.
JPFaA     if iuum2 = 'BC';
JPFaA       iuumq2 = %dech(impms1: 5: 0);
JPFaA       iuflg1 = 'Y';
JPFaA     endif;
JPFaA
JPFaA     // Set Lot code = 'N' if blank.
JPFaA     if iulot = ' ';
JPFaA       iulot = 'N';
JPFaA     endif;
JPFaA
JPFaA   endsr; // PreProcMQS
JPFaA /end-free
DFCaA*----------------------------------------------------------------
DFCaA*
DFCaA*  PreProcDFC   Pre-Process Dependable Food Items.
DFCaA*
DFCaA /free
DFCaA   begsr PreProcDFC;
DFCaA
DFCaA     // For Dependable, fix departments.
DFCaA     select;
DFCaA       when iuwhdp = 'COOLE';
DFCaA         iuwhdp = 'REF';
DFCaA       when iuwhdp = 'FROZE';
DFCaA         iuwhdp = 'FRZ';
DFCaA     endsl;
DFCaA
DFCbA     select;
DFCbA       when iuum1 = *blanks;
DFCbA         iuum1 = 'CS';
DFCbA     endsl;
DFCbA
DFCbA     if iuulen > 0
DFCbA      and iuuwdt > 0
DFCbA      and iuuhgt > 0;
DFCbA       iucube = 0;
DFCbA     endif;
DFCbA
DFCbA     iuswgt = iuswgt / 10;
DFCaA
DFCaA   endsr; // PreProcDFC
DFCaA /end-free
TPCaA*----------------------------------------------------------------
TPCaA*
TPCaA*  PreProcTPC   Pre-Process TPC Items.
TPCaA*
TPCaA /free
TPCaA   begsr PreProcTPC;
TPCaA
TPCaA     select;
TPCaA       when iuwhdp = 'D';
TPCaA         iuwhdp = 'DRY';
TPCaA       when iuwhdp = 'R';
TPCaA         iuwhdp = 'REF';
TPCaA       when iuwhdp = 'F';
TPCaA         iuwhdp = 'FRZ';
TPCaA     endsl;
TPCaA
TPCaA   endsr;  // PreProcTPC
TPCaA /end-free
LKFaA*----------------------------------------------------------------
LKFaA*
LKFaA*  PreProcLKF   Pre-Process Liebers Items.
LKFaA*
LKFaA /free
LKFaA   begsr PreProcLKF;
LKFaA
LKFaA     select;
LKFaA       when iuum1 = *blanks;
LKFaA         iuum1 = 'CS';
LKFaA     endsl;
LKFaA
LKFbA     if %subst(iuitem:1:1) = '*';
LKFbA       iutype = 'A';
LKFbA       iumitm = %subst(iuitem:2:14);
LKFbA     endif;
LKFbA
LKFaA   endsr;  // PreProcLKF
LKFaA /end-free
CPJaA*----------------------------------------------------------------
CPJaA*
CPJaA*  PreProcCPJ   Pre-Process Caribbean Producers Jamaica
CPJaA*
CPJaA /free
CPJaA   begsr PreProcCPJ;
CPJaA
CPJaA     select;
CPJaA       when iuum1 = 'KG';
CPJaA         iuum1 = 'CS';
CPJaA     endsl;
CPJaA
CPJaA     select;
CPJaA       when iuum2 = 'KG';
CPJaA         iuum2 = 'EA';
CPJaA     endsl;
CPJaA
CPJaA   //select;
CPJaA   //  when iuum1 = iuum2;
CPJaA   //    iuum2 = '  ';
CPJaA   //    iuumq2 = 0;
CPJaA   //    iuflg1 = 'N';
CPJaA   //endsl;
CPJaA
CPJaA   endsr;  // PreProcCPJ
CPJaA /end-free
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

CFIaA /free
CFIaA   //  Client changes before edits.
CFIaA   select;
CFIaA
CFIaA     when client = Colony;
CFIaA       exsr PreProcCFI;
CFIaA
ACCaA     when client = Accardi;
ACCaA       exsr PreProcACC;
CFIaA
ACCaA   endsl;
CFIaA /end-free
710aAC                   if        host = 'NECS-ENTREE'
710aAC                             and iumitm = iuitem
710aAC                   eval      iumitm = *blanks
710aAC                   eval      iutype = *blanks
710aAC                   endif
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
770 A*
760bAC*  Do not edit for a blank department from FreshByte
760bAC                   if        host = 'FRESHBYTE' and
760bAC                             iuwhdp = ' '
770 A*    Bypass edit since FreshByte doesn't sent department.
760bAC                   else
770 A*
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
760bAC                   endif
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
650eAC                   else
650eAC                   unlock    desig
     C                   endif
     C                   endif
     *
     *  Verify activity zone (optional).
     *
     C                   if        opactv = 'Y'  and
     C                             iuactv <> *blanks
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
640bMC                   if        iuven < 0  or
640bMC                             iuven > 9999999999
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
ADFbAC                             or client = AandDFoods
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
HKW A*
HKW A*  Force item to stay as type S=Same Slot Breakdown item.
HKWaA*  Host can't send item configured as SSB or Breakdown item.
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW A*
HKW AC                   if            ittype = 'S'
HKW AC                             and iutype = ' '
HKWaAC                             or  ittype = 'B'
HKWaAC                             and iutype = ' '
HKW A*
HKW A*      Force item type back to Same Slot Breakdown.
HKWaMC                   eval      iutype = ittype
HKW A*      Load Parent item for Same Slot Breakdown.
HKW AC     itkey         chain (n) itemlnk
HKW AC                   if        %found(itemlnk)
HKW AC                   eval      iumitm = ilitm2
HKW AC                   goto      endckt
HKW AC                   endif
HKW A*
HKW AC                   endif
HKW A*
HKW AC                   endsl
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

EOPcA*----------------------------------------------------------------
EOPcA*
EOPcA*  ZZCRTREPACK  Create extra repack item
EOPcA*
EOPcA /free
EOPcA   begsr zzCrtRepack;
EOPcA     select;
EOPcA       when client = EarlsOrganic;
EOPcA         crtRpkPar = iuitem;
EOPcA         iuitem = %trim(iuitem) + '-DZ';
EOPcA         exec sql select count(*) into :count from piritem
EOPcA                   where ititem = :iuitem and ittype = 'R';
EOPcA         if sqlstt <> sqlsuccess
EOPcA          or count <= 0;
EOPcA           iustatus = 'R';
EOPcA           iutext = *blanks;
EOPcA           iutype = 'R';
EOPcA           iupdsc = 'Doz';
EOPcA           iuum1 = 'DZ';
EOPcA           iuum2 = *blanks;
EOPcA           iuum3 = *blanks;
EOPcA           iuumq2 = 0;
EOPcA           iuflg1 = 'N';
EOPcA           iuumq3 = 0;
EOPcA           iuflg2 = 'N';
EOPbA           iumitm = crtRpkPar;
EOPbA           iupqn2 = 2;
EOPbA           impms1 = 'DZ';
EOPbA           impms2 = *blanks;
EOPbA           impms3 = *blanks;
EOPcA           write iurec;
EOPcA         endif;
EOPcA
EOPcA     endsl;
EOPcA     crtRepack = *off;
EOPcA
EOPcA   endsr; // zzCrtRepack
EOPcA /end-free

LKFcA*----------------------------------------------------------------
LKFcA*
LKFcA*  ZZCKUP   Validate UPC code.
LKFcA*
LKFcAC     zzckup        begsr
LKFcA*
LKFcAc                   eval      $cbcmd = '*UPC    '
LKFcAc                   eval      impms1 = %subst(impms1:1:1)
LKFcAc                                    + %subst(impms1:3:5)
LKFcAc                                    + %subst(impms1:9:5)
LKFcAc                                    + %subst(impms1:15:1)
LKFcAc                   eval      $cbbar = impms1
LKFcA*
LKFcAc                   call      'CVTBAR'
LKFcAc                   parm                    $cbcmd            8
LKFcAc                   parm                    $cbbar          100
LKFcAc                   parm                    $cbcod            3 0
LKFcAc                   parm                    $cbdec            1 0
LKFcAc                   parm                    $cbdsc           30
LKFcAc                   parm                    $cbpos            3 0
LKFcAc                   parm                    $cbtyp            1 0
LKFcAc                   parm                    $cbv1            11 3
LKFcAc                   parm                    $cbv2            50
LKFcAc                   parm                    $cbrtn            8
LKFcAc                   parm                    $cberm           60
LKFcA*
LKFcAc                   evalr     upupc = %trimr(impms1)
LKFcA*
LKFcAc                   endsr
LKFcA*
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
650gDC*    ilkey         setll     itemlnk1                           79
650gMC     il1key        setll     itemlnk1                           79
     C                   if        not *in79
650gDC*    ilkey         reade     itemlnk1                               79
650gMC     il1key        reade     itemlnk1                               79
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
700bA
700bAC                   for       i = 1 to 2
700bA
700bAC                   if        i = 1
700bAC                   eval      dltItem = iuitem
700bAC                   else
700bAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700bAC                   endif
510dA
700bDC**   itkey         setll     itemsls
700bMC     keyitdel      setll     itemsls
510dA
510dAC                   dow       forevr = forevr
700bDC**   itkey         reade (e) itemsls
700bMC     keyitdel      reade (e) itemsls
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
700bA
700bAC                   endfor
510dA
510dA*  Delete ITEMAVG record
510dA*
510dAC                   if        not %open(itemavg)
510dAC                   open      itemavg
510dAC                   endif
700bA
700bAC                   for       i = 1 to 2
700bA
700bAC                   if        i = 1
700bAC                   eval      dltItem = iuitem
700bAC                   else
700bAC                   eval      dltItem = %trim(iuitem) + '*EACH'
700bAC                   endif
510dA
700bDC**   itkey         chain (e) itemavg
700bMC     keyitdel      chain (e) itemavg
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
700bA
700bAC                   endfor
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
770 D* If FreshByte, set the department and qty 3
770 D*
770 DC*                  if        opwhdp = 'Y' and
770 DC*                            host   = 'FRESHBYTE'
770 DC*                  if        iuwhdp <> ' '
770 DC*                  eval      itwhdp = iuwhdp
770 DC*                  endif
770 DC*                  if        iuumq3 > 0 and
770 DC*                            iuumq2 > 0
770 DC*                  eval      itumq3  = iuumq3 / iuumq2
770 DC*                  endif
770 DC*                  endif
770 DC*                  else
770 DC*
     C                   if        opwhdp = 'Y'  and
     C                             iuwhdp <> itwhdp
     C                   eval      detmsg = desc(29)
     C                   eval      chgflg = *on
     C                   endif
770 DC*                  endif
770 DC*
     C                   if        opstyp = 'Y'  and
     C                             iustyp <> itstyp
     C                   eval      detmsg = desc(30)
     C                   eval      chgflg = *on
     C                   endif
     C                   if        opdesg = 'Y'  and
     C                             iudesg <> itdesg
EOPgAC                             and client <> Earls
EOPgA*
EOPgAC                             or  opdesg = 'Y'
EOPgAC                             and iudesg <> itdesg
EOPgAC                             and iudesg = 'NSTK*'
EOPgAC                             and client = Earls
EOPgA*
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
640fA /free
640fA      // Remove CRLF characters
650aD    //  itdesc = %xlate(crlf: spaces: itdesc);
640fA /end-free
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = itdesc
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      itdesc = chkstr
     C                   endif
     C                   if        opstyp = 'Y'
ADFdAC                   if        client = AandDFoods
ADFdAC                   if        itstyp = ' '
ADFdAC                   eval      itstyp = iustyp
ADFdAC                   endif
ADFdAC                   else
ADFdA*
     C                   eval      itstyp = iustyp
ADFdAC                   endif
     C                   endif
     C                   if        opwhdp = 'Y'
DRYaA*
DRYaA*      Update department for Dairyland on new items only.
DRYaAC                             or  client = Dairyland
DRYaAC                             and opwhdp = 'N'
DRYaAC                             and *in79 = '1'
770 A*
770 AC                   if        Host = 'FRESHBYTE'
770 A*
770 AC                   if           *in79 = '0'
770 AC                             and itwhdp = ' '
770 A*      Default item dept = UNK for new items.
770 AC                             or *in79 = '1'
770 AC                   eval      iuwhdp = 'UNK'
770 AC                   else
770 AC                   eval      iuwhdp = itwhdp
770 AC                   endif
770 A*
770 AC                   endif
770 A*
     C                   eval      itwhdp = iuwhdp
     C                   endif
770 D*
770 D* Set the department for FreshByte
770 D*
770 DC*                  if        host <> 'FRESHBYTE'
770 DC*                  eval      itwhdp = iuwhdp
770 DC*                  endif
     C                   if        opdesg = 'Y'
EOPgAC                             and client <> Earls
EOPgA*
EOPgAC                             or  opdesg = 'Y'
EOPgAC                             and iudesg = 'NSTK*'
EOPgAC                             and client = Earls
EOPgA*
     C                   eval      itdesg = iudesg
     C                   endif
     C                   if        opactv = 'Y'
     C                   eval      itactv = iuactv
     C                   endif
     C                   if        opflgd = 'Y'
     C                   eval      itflgd = iuflgd
650cAC                   else
650cAC                   if        itflgd = ' '
650cAC                   eval      itflgd = 'N'
650cAC                   endif
     C                   endif
     C                   if        opflgb = 'Y'
     C                   eval      itflgb = iuflgb
     C                   endif
     C                   eval      itupc = *blanks
     C                   if        opven# = 'Y'
640bMC                   eval      itven# = iuven
     C                   endif
     C                   if        opvit# = 'Y'
640bMC                   eval      itvit# = iuvitm
     C                   endif
     C                   if        oprepl = 'Y'
     C                   eval      itrepl = iurepl
     C                   endif
     C                   if        oppdsc = 'Y'
     C                   eval      itpdsc = iupdsc
640fA /free
640fA      // Remove CRLF characters
650aD      // itpdsc = %xlate(crlf: spaces: itpdsc);
640fA /end-free
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = itpdsc
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      itpdsc = chkstr
     C                   endif
     C                   if        opum1 = 'Y'
HKW AC                   if           client = Hearnkirkwood
HKWaMC                             and (iutype = 'S'
HKWaAC                               or iutype = 'B')
HKW A*      Skip update of Normal UoM for Same Slot Breakdown item.
HKW AC                   else
HKW A*
     C                   eval      itum1 = iuum1
HKW AC                   endif
HKW A*
     C                   endif

511aAC*     Clear UM2/3 fields for Repack items because they are not used.
511aA
511cDC**                 if        iutype <> 'R'
511cMC                   if        iutype = 'R'
JPFbAC                             and client <> Palmer
511aAC                   eval      iuum2  = ' '
511aAC                   eval      iuumq2 = 0
511aAC                   eval      iuum3  = ' '
511aAC                   eval      iuumq3 = 0
511aAC                   endif
HKW A*
HKW AC                   select
HKW AC                   when      client = Hearnkirkwood
HKW A*      Check if item linked to SSB item.
HKW AC     itkey         setll     itemlnk1
HKW AC                   If        %equal(itemlnk1)
HKW AC                   eval      hkw_lnkrcd = '*YES'
HKW AC                   else
HKW AC                   eval      hkw_lnkrcd = '*NO '
HKW AC                   endif
HKW AC                   endsl
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
HKW A*
HKW AC                             or client = Hearnkirkwood
HKW AC                             and (hkw_lnkrcd = '*YES'
HKWaMC                               or iutype = 'S'
HKWaAC                               or iutype = 'B')
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
HKW A*      or Item is Parent item to SSB item. Skip update.
CSPdAC                   else
CSPdA*
     C                   eval      itum2 = iuum2
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   if        opumq2 = 'Y'
CPC A*
CPC AC                             or client = CPC
CPC AC                             and opumq2 = 'N'
CPC AC                             and iuflg1 = 'Y'
CPC A*
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
HKW A*
HKW AC                             or client = Hearnkirkwood
HKW AC                             and (hkw_lnkrcd = '*YES'
HKWaMC                               or iutype = 'S'
HKWaAC                               or iutype = 'B')
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
HKW A*      or Item is Parent item to SSB item. Skip update.
CSPdAC                   else
CSPdA*
     C                   eval      itumq2 = iuumq2
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
HKW A*
HKW AC                             or client = Hearnkirkwood
HKW AC                             and (hkw_lnkrcd = '*YES'
HKWaMC                               or iutype = 'S'
HKWaAC                               or iutype = 'B')
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
HKW A*      or Item is Parent item to SSB item. Skip update.
CSPdAC                   else
CSPdA*
     C                   eval      itflg1 = iuflg1
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   endif
     C                   if        opum3 = 'Y'
CSPdA*
CSPdAC                   if        client = Coastalsunbelt
CSPdAC                             and ifcat = 'ODR'
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
CSPdAC                   else
CSPdA*
     C                   eval      itum3 = iuum3
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
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
CSPdAC                   else
CSPdA*
770 DC*                  if        host <> 'FRESHBYTE'
770 MC                   if        host = 'FRESHBYTE'
770 AC                   if            iuumq2 > 0
770 AC                             and iuumq3 > 0
770 AC                   eval      iuumq3  = iuumq3 / iuumq2
770 AC                   endif
770 AC                   endif
     C                   eval      itumq3 = iuumq3
770 DC*                  endif
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
JPFbA
JPFbAc                             or JpfParent
CSPdA*      Skip update.
CSPdAC                   else
CSPdA*
     C                   eval      itflg2 = iuflg2
CSPdAC                   endif
CSPdA*
     C                   endif
     C                   endif
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
     C                   if        opcube = 'Y'
640iAC                             and iucube <> 0
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
640dA*      or Cube not imported from host and computed cube chg'd.
     *
     C                   if        opcaut = 'Y'  and
640dDC*                            itcube = 0
640dMC                             (itcube = 0
640dAC                             or itcube <> actcub)
     C                   eval      itcube = actcub
     C                   endif
     C                   endif
     C                   endif
ADFaA*
ADFaA*      Force default cube so that an item always has cube.
ADFaAC                   if        client = AandDFoods
ADFaAC                             and itcube = 0
ADFcDC*                  eval      itcube = 1.21
ADFaAC                   endif
     *
     C                   if        opswgt = 'Y'
     C                   eval      itswgt = iuswgt
     C                   endif
     C                   if        opcwgt = 'Y'
     C                   eval      itcwgt = iucwgt
     C                   endif
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
740aAc                   if        host = 'NECS-ENTREE'
740aAc                   eval      itcube = iucube
740aAc                   eval      itswgt = iuswgt
740aAc                   else
     C                   eval      itcube = svcube
     C                   eval      itswgt = svswgt
740aAc                   endif
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
640fA /free
640fA      // Remove CRLF characters
650aD     //  itdesc = %xlate(crlf: spaces: itdesc);
640fA /end-free
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = itdesc
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      itdesc = chkstr
     C                   eval      itpdsc = iupdsc
640fA /free
640fA      // Remove CRLF characters
650aD      // itpdsc = %xlate(crlf: spaces: itpdsc);
640fA /end-free
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = itpdsc
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      itpdsc = chkstr
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
650 A*
650 A* Process report override and open printer file.
650 A*
650 AC                   exsr      opnprt
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
700eA*   Get import item fields options.
700eA*
700eAC                   eval      kywhse = $pWhse
700eAC                   eval      opcode = '*HOST   '
700eAC     optnky        chain     options
700eAC                   if        %found(options)
700eAC                   eval      host = opdata
700eAC                   else
700eAC                   eval      host = *blanks
700eAC                   endif
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
770 D*     Do not update the quantity for FreshByte
770 D*
770 DC*                  if        opwhdp = 'Y' and
770 DC*                            host   = 'FRESHBYTE'
770 DC*                  else
770 DC*
     C                   eval      itum2 = iuum1
     C                   eval      itum3 = iuum2
     C                   eval      itumq3 = iuumq2
770 DC*                  endif
770 D*
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
     C                   eval      svwrnc = *zeros
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
650 A /free
650 A      // Remove CRLF characters
650aD   // imbrnd = %xlate(crlf: spaces: imbrnd);
650 A /end-free
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = imbrnd
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      imbrnd = chkstr
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
640aDC**                 if        miscitmupd = '*YES'

640aAC                   if        impgrp <> ' '
640aAC                             or imppnt <> ' '
640aAC                             or impvar  <> 0
640aAC                             or impcat  <> ' '
640aAC                             or impms1 <> ' '
640aAC                             or impms2 <> ' '
640aAC                             or impms3 <> ' '
640aAC                             or impms4 <> ' '
640aAC                             or impms5 <> ' '

510cAC     itkey         chain     itemext1
510cAC                   eval      ikgrp = impgrp
510eAC                   eval      ikplnt= imppnt
510cAC                   eval      ikvar = impvar
710aAC                   if        host = 'NECS-ENTREE'
510cAC                   eval      ikcat = %xlate(lower:UPPER:impcat)
710aAC                   else
510cAC                   eval      ikcat = impcat
710aAC                   endif
510cAC                   eval      ikmsc1= impms1
510cAC                   eval      ikmsc2= impms2
510cAC                   eval      ikmsc3= impms3
510cAC                   eval      ikmsc4= impms4
510cAC                   eval      ikmsc5= impms5
510cA*
510cAC                   if        not %found(itemext1)
640aDC**                 eval      ikwhse= impwhs
640aDC**                 eval      ikitem= impitm
640aMC                   eval      ikwhse= iuwhse
640aMC                   eval      ikitem= iuitem
510cAC                   write     ikrec
510cAC                   else
510cAC                   update    ikrec
510cAC                   endif
710bA*
710bA /free
710bA    // Add Category to ITEMCAT if not found
710bA    if ikcat <> *blanks;
710bA      chain (ikcat) icrec;
710bA      if not %found(itemcat);
710bA        iccode = ikcat;
710bA        icdesc = 'Created by Item Import';
710bA        ichhdr = '1';
710bA        ichdtl = '1';
710bA        ichcat = '1';
710bA        write icrec;
710bA      endif;
710bA    endif;
710bA /end-free
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
760bA*     For FreshByte, default UNK to the department on add
760bA*     if it's blank.
760bA*
770 DC*                  if        opwhdp = 'Y' and
770 DC*                            host   = 'FRESHBYTE'
770 A*
770 MC                   if        host   = 'FRESHBYTE'
770 A*
770 AC                   if        opwhdp = 'Y'
760bAC                   if        iuwhdp = ' '
760bAC                   eval      itwhdp = 'UNK'
760bAC                   endif
770 AC                   endif
770 A*
770 AC                   if            opumq2 = 'Y'
770 AC                             and opumq3 = 'Y'
770 A*
760bAC                   if        iuumq3 > 0 and
760bAC                             iuumq2 > 0
760bAC                   eval      itumq3  = iuumq3 / iuumq2
760bAC                   endif
770 A*
760bAC                   endif
770 A*
760bAC                   endif
760bAC
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
730bAc                   if        *in79
730bAc                   clear                   imrec
730bAc                   endif
     C                   if        optie = 'Y'
     C                   eval      imtie = iutie
     C                   endif
     C                   if        ophigh = 'Y'
     C                   eval      imhigh = iuhigh
     C                   endif
     C                   if        opmflg = 'Y'
     C                   eval      immflg = iumflg
650cAC                   else
650cAC                   if        immflg = ' '
650cAC                   eval      immflg = 'N'
650cAC                   endif
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
     C                   if        opnslt = 'Y'
     C                   eval      imnslt = iunslt
     C                   endif
     C                   if        opxdck = 'Y'
     C                   eval      imxdck = iuxdck
     C                   endif
750bA*
750bAC                   if        host = 'NECS-ENTREE'
750bA*      Retrieve buyer number from PIR User table.
750bAC                   eval      #buyerid = %subst(impms2:1:10)
750bAC                   call      'GETUSER'
750bAC                   parm                    #buyerid         10
750bAC                   parm      0             #whse             3 0
750bAC                   parm      0             #emp#             5 0
750bAC                   parm                    #fnam            15
750bAC                   parm                    #init             1
750bAC                   parm                    #lnam            20
750bAC                   parm                    #whdp             5
750bAC                   parm                    #styp             1
750bAC                   parm                    #shft             6
750bAC                   parm                    #crew             6
750bAC                   parm      0             #nhrs             3 1
750bAC                   parm                    #rtn              8
750bA*      Update buyer number/name for item.
750bAC                   if        #rtn = '*OK'
750bAC                   eval      iubnbr = #emp#
750bAC                   eval      iubnam = %trim(#fnam)
750bAC                                       + ' '
750bAC                                       + %trim(#lnam)
750bAC                   else
750bAC                   eval      iubnbr = 0
750bAC                   eval      iubnam = ' '
750bAC                   endif
750bA*
750bAC                   endif
750bA*
     C                   if        opbnbr = 'Y'
     C                   eval      imbnbr = iubnbr
     C                   endif
     C                   if        opbnam = 'Y'
     C                   eval      imbnam = iubnam
     C                   endif
     C                   if        opvnam = 'Y'
     C                   eval      imvnam = iuvnam
     C                   endif
650 A /free
650 A      // Remove CRLF characters
650 A      iubrnd = %xlate(crlf: spaces: iubrnd);
650 A /end-free
     C                   if        opbrnd = 'Y'
650aAC                   eval      chkstr = *blanks
650aAC                   eval      chkstr = iubrnd
650aAC                   exsr      zzzspcl2spc
650aAC                   eval      iubrnd = chkstr
     C                   eval      imbrnd = iubrnd
730gA /free
730gA      // Uppercase Brand
730gA      imbrnd = %xlate(lower:UPPER:imbrnd);
730gA /end-free
     C                   endif
     C                   if        oplot = 'Y'
     C                   eval      imlot = iulot
     C                   endif
640cA*
640cAC                   select
640cAC                   when      iustyp = 'P'
640cAC                   eval      imnrpk = *zeros
640cA*
640cAC                   when      iustyp = 'F' and
640cAC                             imnrpk = 0
640cAC                   eval      imnrpk = 1
640cAC                   endsl
640cA*
600aDC**                 if        opltrk = 'Y'
600aDC**                 eval      imltrk = iultrk
600aDC**                 endif
730eMC                   if        opltrk = 'Y'
730eMC                   eval      imltrk = iultrk
730eMC                   endif
730eA
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
DRYbAC                   select
DRYbMC                   when      client = capitolcity
CSP AC                             or client = CoastalSunBelt
CCP AC                   eval      imoday = 30
DRYbA*
DRYbAC                   when      client = Dairyland
DRYbA*    Dry items have longer shelf life so default to 2 yrs.
DRYbAC                   if        itwhdp = 'DRY'
DRYbAC                   eval      imoday = 720
DRYbAC                   else
DRYbAC                   eval      imoday = 360
DRYbAC                   endif
DRYbA*
DRYbMC                   other
530aAC                   eval      imoday = 360
DRYbMC                   endsl
CCP A*
530aAC                   endsl
530aAC*
     **                   MOVE 'Y'       IMWRNC
720aAC                   select
720aAC                   when      host = 'NECS-ENTREE'
720aAC****                ** do nothing
720aAC                   other
DRYdA
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
DRYdA*
720aAC                   endsl
     **                   MOVE 'N'       IMAPCK
     **                   Z-ADD0         IMNRPK
01   C                   if        not *in79
     C                   update    imrec
     C                   else
     C                   eval      imwrnc = 'Y'
720aAC                   select
720aAC                   when      host = 'NECS-ENTREE'
720aAC****                ** do nothing
720aAC                   other
DRYdA
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
DRYdA*
720aAC                   endsl
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
650dA*
650dA*
650dA*   Add record to ITEMFLD file.
650dAC     ifkey         chain     itemfld
650dAC                   if        not %found(itemfld)
650dAC                   eval      ifwhse    = iuwhse
650dAC                   eval      ifitem    = iuitem
710aAC                   if        host = 'NECS-ENTREE'
CPJbAC                             or client = CPJ
SFP AC                             or (client = Seashore
SFP AC                                and impcat > ' ')
710aAC                   eval      ifcat     = %xlate(lower:UPPER:impcat)
710aAC                   else
650dAC                   eval      ifcat     = ' '
710aAC                   endif
650dAC                   eval      ifcaseovf = 'N'
650dAC                   eval      ifodrslot = ' '
650dAC                   eval      ifucicde  = '1'
650dAC                   eval      ifrcvmth  = '1'
650dAC                   eval      ifsltmth  = '1'
650dAC                   eval      ifbrdflg  = 'N'
650dAC                   write     ifrec
650dA*
650dAC                   else
650dA*
730hDC***                if        host = 'NECS-ENTREE'
SFPaA*
SFPaAC                   if        client = Seashore
SFPaAC                   if        impcat > ' '
SFPbAC                             and ifcat <> 'WET'
SFPaAC                   eval      ifcat = %xlate(lower:UPPER:impcat)
SFPaAC                   endif
SFPaA*
SFPaAC                   else
SFPaA*
710aAC                   eval      ifcat = %xlate(lower:UPPER:impcat)
SFPaAC                   endif
SFPaA*
710aAC                   update    ifrec
730hDC***                endif
650dAC                   unlock    itemfld
650dAC                   endif
     *
     *
     *   Add record to ITEMLNK file.
     *     for Brokencase item.
511aA*         and Repack item.
     *
     C                   select
     C                   when      iutype = 'B'
650gMC                             or iutype = 'R'
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
JPFbAC                             or client = Palmer
CCPaA*      Only update Parent Repack Qty on Add.
CCPaAC                   if        *in79 = '1'
650bAc                   eval      kcdisp = ' '
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
650bAc                   eval      kcdisp = ' '
511aAC                   write     kcrec
511aAC                   else
511aAC                   update    kcrec
511aAC                   endif
650bA
650bAc*   add code to maintain KITITEM file with Repack item master
650bAc*    only adds KITITEM thru this interface for the time, no upds
650bAC     itkey         chain     kititem                            79
650bA*
650bAC                   if        client = CapitolCity
650bAC                             or client = CoastalSunBelt
JPFbAC                             or client = Palmer
650bA*      Only update Parent Repack Qty on Add.
650bAC                   if        *in79 = '1'
650bAc                   eval      kidisp = ' '
650bAc                   eval      kirptp = '1'
650bAC                   eval      kiqty1 = 1
650bAC                   eval      kiqty2 = 0
650bAC                   eval      kiqty3 = 0
650bAC                   endif
650bAC                   else
650bA*
650bAC                   if        *in79 = '1'
650bAc                   eval      kirptp = '1'
650bAC                   eval      kiqty1 = 1
650bAC                   eval      kiqty2 = 0
650bAC                   eval      kiqty3 = 0
650bAC                   endif
650bAC                   endif
650bA*
650bAC                   if        *in79
650bAC                   eval      kiwhse = iuwhse
650bAC                   eval      kiitem = iuitem
650bAc                   eval      kidisp = ' '
650bAC                   write     kirec
650bAC                   else
650bDC                   unlock    kititem
650bAC                   endif
511aAC                   endif
511aA*
511aA*   Create Repack slot for Repack item.
511aA*
511aAC                   if        iutype = 'R'
750cAc                             and kirptp='1'
JPFbAC                             and client <> Palmer
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
650gDC*    ilkey         setll     itemlnk1
650gMC     il1key        setll     itemlnk1
     C                   dou       eofl = *on
     *
650gDC*    ilkey         reade     itemlnk1                               75
650gMC     il1key        reade     itemlnk1                               75
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
760bA*     For FreshByte, update the department if the import
760bA*     warehouse department is not blank. Check the import
760bA*     options for updating the department.
760bA*
770 DC*                  if        opwhdp = 'Y' and
770 DC*                            host   = 'FRESHBYTE'
770 A*
770 MC                   if        host   = 'FRESHBYTE'
770 A*
770 AC                   if        opwhdp = 'Y'
760bAC                   if        iuwhdp <> ' '
760bAC                   eval      itwhdp = iuwhdp
760bAC                   endif
770 AC                   endif
770 A*
770 AC                   if            opumq2 = 'Y'
770 AC                             and opumq3 = 'Y'
760bAC                   if        iuumq3 > 0 and
760bAC                             iuumq2 > 0
760bAC                   eval      itumq3  = iuumq3 / iuumq2
760bAC                   endif
770 AC                   endif
770 A*
760bAC                   endif
760bAC
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
760bA*     For FreshByte, default UNK to the department on add.
760bA*     Calculte the quantity.
760bA*
760bAC                   if        opwhdp = 'Y' and
760bAC                             host   = 'FRESHBYTE'
760bAC                   if        iuwhdp = ' '
760bAC                   eval      itwhdp = 'UNK'
760bAC                   endif
760bAC                   if        iuumq3 > 0 and
760bAC                             iuumq2 > 0
760bAC                   eval      itumq3  = iuumq3 / iuumq2
760bAC                   endif
760bAC                   endif
760bAC
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
760bAC
760bA*     For FreshByte, update the department if the import
760bA*     warehouse department is not blank.
760bA*     Calculate the quantity.
760bA*
760bAC                   if        opwhdp = 'Y' and
760bAC                             host   = 'FRESHBYTE'
760bAC                   if        iuwhdp <> ' '
760bAC                   eval      itwhdp = iuwhdp
760bAC                   endif
760bAC                   if        iuumq3 > 0 and
760bAC                             iuumq2 > 0
760bAC                   eval      itumq3  = iuumq3 / iuumq2
760bAC                   endif
760bAC                   endif
760bAC
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
710aA*
710aA*   Add record to ITEMFLD file.
710aAC     ifkey         chain     itemfld
710aAC                   if        not %found(itemfld)
710aAC                   eval      ifwhse    = iuwhse
710aAC                   eval      ifitem    = iuitem
710aAC                   if        host = 'NECS-ENTREE'
CPJbAC                             or client = CPJ
SFP AC                             or (client = Seashore
SFP AC                                and impcat > ' ')
710aAC                   eval      ifcat     = impcat
710aAC                   else
710aAC                   eval      ifcat     = ' '
710aAC                   endif
710aAC                   eval      ifcaseovf = 'N'
710aAC                   eval      ifodrslot = ' '
710aAC                   eval      ifucicde  = '1'
710aAC                   eval      ifrcvmth  = '1'
710aAC                   eval      ifsltmth  = '1'
710aAC                   eval      ifbrdflg  = 'N'
710aAC                   write     ifrec
710aA*
710aAC                   else
710aA*
CPJbAC                   if        client = CPJ
CPJbAC                   eval      ifcat = %xlate(lower:UPPER:impcat)
CPJbAC                   update    ifrec
CPJbAC                   endif
CPJbA*
710aAC                   unlock    itemfld
710aAC                   endif
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
LKFcA*----------------------------------------------------------------
LKFcA*
LKFcA*  ZZUPDU   Update UPC file.
LKFcA*
LKFcA /free
LKFcA   begsr zzupdu;
LKFcA
LKFcA
LKFcA   chain (itwhse:ititem:upupc) uprec2;
LKFcA
LKFcA   if not %found(upc2)
LKFcA    and ititem <> *blanks
LKFcA    and $cbrtn = '*OK    ';
LKFcA     upwhse = itwhse;
LKFcA     upitem = ititem;
LKFcA   //upupc = %trimr(impms1);
LKFcA     uputyp = 'N';
LKFcA     upuom  = itum1;
LKFcA     ntype = %trimr($cbdsc);
LKFcA     select;
LKFcA       when ntype = 'UPC-12';
LKFcA         upctyp = '1';
LKFcA       when ntype = 'EAN-13';
LKFcA         upctyp = '2';
LKFcA       when ntype = 'GTIN';
LKFcA         upctyp = '3';
LKFcA       when ntype = 'SCC-14';
LKFcA         upctyp = '4';
LKFcA       when ntype = 'SSCC-18';
LKFcA         upctyp = '5';
LKFcA       other;
LKFcA         upctyp = '6';
LKFcA     endsl;
LKFcA
LKFcA     upitem = ititem;
LKFcA     upven = itven#;
LKFcA     upvnam = iuvnam;
LKFcA     upvitm = itvit#;
LKFcA     write(e) uprec2;
LKFcA   endif;
LKFcA
LKFcA   endsr; // zzupdu
LKFcA
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
650 A*
650 A*----------------------------------------------------------------
650 A*
650 A*  OPNPRT  Open printer file.
650 A*
650 AC     opnprt        begsr
650 A*
650 A*   Get device and form type for report.
650 A*
650 AC                   call      'GETRPT'
650 AC                   parm      '*DEVFORM'    $cmd              8
650 AC                   parm      'II265PR'     $lrpt            10
650 AC                   parm      iuwhse        $whse             3 0
650 AC                   parm      ' '           $styp             1
650 AC                   parm      ' '           $whdp             5
650 AC                   parm                    $desc            50
650 AC                   parm                    $dev             10
650 AC                   parm                    $form            10
650 A
650 AC                   if        $dev = ' '
650 AC                   eval      $dev = '*JOB'
650 AC                   endif
650 A
650 AC                   if        $form = ' '
650 AC                   eval      $form = '*STD'
650 AC                   endif
650 A*
650 A*      If printer already open then close it.
650 A*
650 AC                   if        %open(ii265pr)
650 AC                   close     II265pr
650 AC                   endif
650 A*
650 A*      Override printer file.
650 A*
650 A*          OVRPRTF FILE(II265PR) OUTQ($DEV) FORMTYPE($form)
650 A*
650 AC                   eval      qcmd = 'OVRPRTF '
650 AC                                  + 'FILE(II265PR) '
650 AC                                  + 'OUTQ(' + %trim($dev) + ') '
650 AC                                  + 'FORMTYPE(' + %trim($form) + ') '
DRYaA*
DRYaAC                   eval      qlen = 80
DRYaAC                   if        client = dairyland
DRYaAC                   call      'GETEML'
DRYaAC                   parm      'II265PR '    pqrptid          10
DRYaAC                   parm      1             pqseq             3 0
DRYaAC                   parm                    pqemail         100
DRYaA*
DRYaAC                   if        pqemail <> *blanks
DRYaAC                   eval      qcmd = %trim(qcmd) + ' USRDFNDTA('' '
DRYaAC                             + %trim(pqemail) + ''')'
DRYaAC                   eval      qlen = %len(%trim(qcmd))
DRYaAC                   endif
DRYaAC                   endif
DRYaA*
650 AC                   call      'QCMDEXC'
DRYaDC*                  parm                    qcmd             80
DRYaDC*                  parm      80            qlen             15 5
DRYaMC                   parm                    qcmd            200
DRYaMC                   parm                    qlen             15 5
650 A*
650 A*      Open printer file.
650 A*
650 AC                   open      ii265pr
650 A*
650 AC                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzEnd     End processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzEnd        begsr
      /free

        if importError;
          sbstatus = 'E';
          sbtext   = 'Import completed with error(s). See impsitmn file.';
          $pReturn = '*ERROR';
          $pMessage = sbtext;
        else;
          sbstatus = 'S';
          sbtext   = 'Import completed successfully';
        endif;

        exec sql
          update stgbatch
          set sbstatus = :sbstatus,
              sbtext   = :sbtext,
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbendts  = current_timestamp,
              sbenduc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = %trimr(sbtext) + ' - '
                    + 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzend';
          leavesr;
        endif;

760 A   if importError;
760 A     // if Staging Interface error report is scheduled then submit
760 A     // Use a timestamp as a session id.  MRCRPTSCH will call the
760 A     // update program to update the correct work file to report
760 A     exsr zzErrRpt;
760 A   endif;

      /end-free
     c                   endsr

760 A*----------------------------------------------------------------
760 A*  zzErrRpt   Send Error report for Staging File if scheduled
760 A*----------------------------------------------------------------
760 A
760 Ac     zzErrRpt      begsr
760 A /free
760 A
760 A *   Determine if scheduled, and if so what email to use based
760 A *   on current time compared to scheduled time(s).
760 A *   Loops thru BFCMRCRPRM looking for scheduled events and
760 A *   determining which one is closest to current time, but not
760 A *   after current time.
760aD     //currReport = 'BFCREPORTS.R40700';
760aM     currReport = 'BFCREPORTS.R42600';
760 A     // get the closest scheduled email address to current time.
760 A     // if email is return empty we assume not schedule and
760 A     // nothing is sent
760 A     schEmail=*blanks;
760 A     getSchTimeEml();

          // if email is returned then send out requested error report
          if schEmail <> *blanks;
            orient = 'P';
            grDev=*blanks;
            // Format URL
            // Note: pdf fields are genreated by MRCRPTSCH program
            url = '&OUTFMT=11'
                + '&D_DETAIL=1'
760aD           //+ '&CALCULA001=' + %char(%timestamp())
760aD           //+ '&CALCULA002=' + %char($pWhse)
760aD           //+ '&CALCULA003=' + $pBatid;
760aM           + '&R001=' + %char($pWhse)
760aM           + '&R002=' + $pBatid;

760aA       // Call program to populate Subject and Email Body to
760aA       // file intlog.  These are printed on Email error Report
760aA       // R42600 called below
760aA       wintlog ($pWhse:$pBatid);

            // Call program to print report

            monitor;

760 A         // get iSeries user and jobd from Report Scheduling
760 A         exec sql select opmusr,opjobd into :opmusr,:opjobd
760 A                   from opsmrcrpt
760 A                where opwhse=:$pwhse
760 A               fetch first row only;
760 A         if sqlstt = '00000';
760 A            sbmusr = opmusr;
760 A            sbmjobd = opjobd;
760 A            sbmlibl = '*JOBD';
760 A         else;
760 A            sbmusr = '*CURRENT';
760 A            sbmjobd = '*USRPRF';
760 A            sbmlibl = '*CURRENT';
760 A         endif;
760 A
760 A         cmd = 'sbmjob '
760 A               +   'cmd('
760 A               +      'MRCRPTSCH ' +
760 A                    'WHSE(' + %char($pwhse) + ') '  +
760 A                    'RPTNAM(''' + %trim(currReport) + ''') ' +
760 A                    'URL(''' + %trim(url) + ''') ' +
760 A                    'EMAIL(' + sq + %trim(schEmail) + sq + ') ' +
760 A                    'PRINTER(' + sq + %trim(grdev) + sq + ') ' +
760 A                    'ORIENT(' + sq + %trim(orient) + sq + ')) ' +
760 A               'inllibl(' + %trim(sbmlibl) + ') ' +
760 A               'jobd(' + %trim(sbmjobd) + ') ' +
760 A               'user(' + %trim(sbmusr) + ') ' +
760 A               'jobq(QSYSNOMAX) ' +
760 A               'job(OI285SRSCH)';
760 A         qcmdexc(cmd: %len(cmd));

            on-error;
            endmon;
          endif;
760 A
760 A /end-free
760 Ac                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzGetStamps   Get timestamps
640aA*----------------------------------------------------------------
640aA
640aAc     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

640aA*----------------------------------------------------------------
640aA*  zzzStart   Start processing
640aA*----------------------------------------------------------------
640aA
640aAc     zzzStart      begsr
      /free

        exec sql
          update stgbatch
          set sbstatus = 'P',
              sbtext   = 'Import started',
              sbststs  = current_timestamp,
              sbstsuc  = current_timestamp - current_timezone,
              sbstrts  = current_timestamp,
              sbstruc  = current_timestamp - current_timezone
          where sbwhse = :$pWhse
            and sbbatid = :$pBatId;

        if sqlstt <> sqlSuccess;
          $pReturn = '*SIUPDERR';
          $pMessage = 'Error updating STGBATCH file for '
                    + 'batch id ' + %trim($pBatId) + ' '
                    + '- SQLSTT ' + sqlstt + ' '
                    + '- ii265s/zzzstart';
          leavesr;
        endif;

        importError = *off;

      /end-free
     c                   endsr
650aA*----------------------------------------------------------------
650aA*  zzzspcl2spc  Remove unallowed characters.
650aA*----------------------------------------------------------------
650aA
650aAC     zzzspcl2spc   begsr
650aA
650aAC                   eval      chkpos = 0
650aA
650fDC*                  dou       chkpos = 0
650fMC                   dou       chkpos = 0 or chkpos + 1 > 30
650aAC                   eval      chkpos = %check(okchar:chkstr:chkpos+1)
650aAC                   if        chkpos > 0
650aAC                   eval      %subst(chkstr:chkpos:1) = ' '
650aAC                   endif
650aAC                   enddo
650aA
650aAC                   endsr

760 A *----------------------------------------------------------------
760 A *  getSchTimeEml - Get Email address for specific error  report
760 A *----------------------------------------------------------------

760 Ap getSchTimeEml   b
760 Ad getSchTimeEml   pi

      *  Local Variables

     D weekday         s              3
     D currTime        s              5

            // Set 3 character value for day
            select;
              when DayofWeek(%date()) = 0;
                weekday = 'SUN';
              when DayofWeek(%date()) = 1;
                weekday = 'MON';
              when DayofWeek(%date()) = 2;
                weekday = 'TUE';
              when DayofWeek(%date()) = 3;
                weekday = 'WED';
              when DayofWeek(%date()) = 4;
                weekday = 'THU';
              when DayofWeek(%date()) = 5;
                weekday = 'FRI';
              when DayofWeek(%date()) = 6;
                weekday = 'SAT';
            endsl;

            // get current time (hh:mm)
            currTime = %subst(%char(%time():*ISO):1:5);

            // now query scheduled entries for closest
            // time to current system time that is active
            // for the current Report being processed
            exec sql select bsvalue into :schEmail
                from bfcmrcrprm as a where a.bswhse=:$pWhse and
              a.bsrptpgm=:currReport and a.bsmrctbl='E' and
              a.bsmrcprm='EMAIL' and
               (select b.bsvalue from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='D'
                 and b.bsmrcprm=:weekday)='Y' and
               (select min(b.bsvalue) from bfcmrcrprm as b where
                 b.bswhse=a.bswhse and b.bsrptpgm=a.bsrptpgm and
                 b.bsschseq=a.bsschseq and b.bsmrctbl='X'
                 and b.bsmrcprm='SCHTIME')<:currTime;

760 Ap getSchTimeEml   e
760 A*----------------------------------------------------------------*
760 A* Procedure:  DayOfWeek
760 A* Purpose:  Determine the day of week for a particular date
760 A* Parameters:
760 A*    I: dt   -- date
760 A* Returns:
760 A*    0..6    -- 0=Sunday, 1=Monday, 2=Tuesday, etc.
760 A* Notes:
760 A*    January 5, 1800 is a Sunday.  This procedure only works for
760 A*    dates later than 1800-01-05.
760 A*----------------------------------------------------------------*

760 AP DayOfWeek       b
760 AD DayOfWeek       pi            10i 0
760 AD   dt                            d   value datfmt(*iso)
      /free
        return %rem (%diff (dt: d'1800-01-05': *days): 7);
      /end-free
760 AP DayOfWeek       e


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
**
*Auto created by item update*
