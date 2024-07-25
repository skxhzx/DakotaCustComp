600aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RN250     Customer returns putaway - Virtual Slots
     *  September 23, 1999
     *  Roxanne Harrison
     *    Created using RN150
     *  Notes
     *    Program creates record in ORRTN, calls RN246 to create
     *    records in PIRTRAN and LABEL files.
     *    If item is type S, display Breakdown UOM.
     *
     *----------------------------------------------------------------
     *  Revisions
415aA*    01/03/01  RH   4.15a
     *      - Add $PLBL#.
     *      - If label# scanned, do not enter license plates,
     *        call RN246L to write label, transaction# and
     *        record in LABELNK label link file.
415bA*    02/07/01  RH   4.15b
     *      - Add Catch wt.
     *      - If called from quick returns, do not edit catch wt or
     *        reason code, edit if called from returns (RN120)
     *      - Pass *BLANKS in PO to RN246, PTRTPO should be blank for
     *        returns.
     *      - Add $PORD customer order.
415cA*    03/30/01  RH   4.15c
     *      - Fix F4 Reason Code look up.
     *
416 A*    10/16/01  MLB  4.16
    A*      - Field added to ORRTN. Re-compile only.
416bA*    11/09/01  RH   4.16b
     *      - Add disposition code to screen1.
     *      - Add Screen2,impact inventory, memo and correspond item.
     *      - If mispick, create label rec.for physical item W2CITM.
416cA *    11/13/01  RH   4.16c
     *      - Change to process for quick returns.  QUICK=*ON
416dA*    11/18/01  RH   4.16c
     *      - Pass Invoice # as parm $PINV#.
     *      - Create exception for mispick or RNINVF=Y notify inv ctl.
416eA*    11/29/01  RH   4.16e
     *      - Add option to Export quick returns, N=write upload
     *        date and tiem so quick returns are not exported.
416fA*    11/30/01  RH   4.16f
     *      - Fix - was not moving corresponding item into W2CITM.
416gA*    02/04/02  RH   4.16g
     *      - Add option to use label for putaway (OPRULB).
     *      - Change field name W1FLBL to W1ULBL.
416hA*    03/20/02  RH   4.16h
     *      - Add F9 to enable UOM for breakdown quantity.
416iA*    07/09/02  RH   4.16i
     *      - Write pick slot to ITMEXCP file.
416jA*    07/11/02  RH   4.16j
     *      - Mispick item cannot be ordered item.
416kA*    08/14/02  RH   4.16k
     *      - Create record in POMFR for expiration date.
     *      - Add Manufacture date to screen, calculate expir. date
416lA*    09/05/02  RH   4.16l
     *      - Move code for these changes instead of replacing.
     *      - Move manufacturer date to screen 2.
     *      - Move corresponding item to screen 1.
417bA*    04/03/03  RH   4.17b
     *      - Recompiled, ITEMMSC file changed.
417aA*    04/09/03  RH   4.17a
     *      - Enh: Allow multiple items for one UPC code.
417cA*    06/06/03  MLB  4.17c
     *      - Fix: Revise ZZUPD3 to run convert date every time
     *        record is added to returns file. Revised ZZEXCP with
     *        same change for field EXGDTE.
417dA*    10/14/03  RH   4.17d
     *      - Enh: Check mfg date is not already expired.
     *
500aA*    03/01/05  RH   5.00a
     *      - ENH:For mispick, create adjustments if both items have
     *        pick slots, otherwise create exception record.
     *      - ENH:Add ITEMADJ file.
500bA*    08/09/05  RH   5.00b
     *      - Fix: For mispick, call DRI interface to create adjustments
     *        and update slot and warehouse quantities. Adjustments were
     *        created but not updating quantities.
500cA*    09/23/05  MLB/RH  5.00c
     *      - Fix: Revised ZZUPD2 to call ZZUMFR on good return
     *        from RN246L when using label for putaway.
500dA *    10/11/05  RH   5.00d
      *      - ENH: Revised to chain to POMFR1 with label#, update
      *        existing record if found.  Problem POMFR records
      *        already existing when label# have cycled around again
      *        and having previous item's expiration date info.
500eA*    02/03/06  RH      5.00e
     *      - Fix: Revised to get base item before GETPSLT.   Was
     *        not finding pick slot for type 'S' item.
510 A*    09/11/06  JCJ     5.10
     *      - Enh: Revised program to add support for Client id
510aA*    09/07/06  JCJ     5.10a
     *      - Enh: Changed heading "Invoice number" to "Delivery number"
     *      - Enh: Added Billing Document number when client is Packers
510bA*    01/25/07  HNK     5.10b
     *      - Fix: Fix Reason code and Disp code lookup columns.
510cA*    09/25/07  RBD     5.10c
     *      - Fix: On older releases j$tst (ie Jordano's) would not
     *        truncate, causing mch1210 error, receiver or target
     *        value too small.  Added fld j$tsthld to hold result,
     *        then move decimal value to j$tst.
510dA*    10/29/07  RBD     5.10d
     *      - Fix: If error condition 'Product Expired' occurred, and
     *        then the user keys a valid mfg date, error PIR1009 would
     *        erroneously occur because w2expd had been populated in
     *        zzchk2 when calculating expiration date even though the
     *        user had not keyed w2expd.  Will now use work field instead
     *        of scrn field when calculating expiration date.
520aA*    02/13/08  RH      5.20a
     *      - Fix: Change error indicators to match RN250FM.
520bA*    02/26/08  RH      5.20b
     *      - Fix: Position cursor on reason code after F4 lookup
520cA*    08/26/08  RH      5.20c
     *      - Enh: Force reason code and return code to be entered.
     *
600aA*    05/17/09  DAS  6.00a
     *      - Enh: Added dates to RN246/RN246L parms
     *
600bA*    06/09/09  DAS  6.00b
     *      - Revised to not allow breakdown qty to be returned to
     *        stock if item brkdn qty is not greater than zero.
     *
610aA*    07/20/09  DAS  6.10a
     *      - Revised to use %ADJUSTRTN instead of $ADJUST. Re: This
     *        command will allow slot qty to go negative.
530aA*    01/29/10  RH      5.30a
     *      - Enh: Do not put product away for dept NOT-live
530bA*    02/17/10  RBD     5.30b
     *      - Enh: Added *TRKRTN command. Tracker pgm TR830 sends in
     *        cmd *RETURN, if return is completed, send *TRKRTN back
     *        to TR830.
530cA*    08/24/10  RH      5.30c
     *      - Enh: Add code to not check MFG date if date is not being
     *        entered because item not being put away.
530dA*    03/01/10  RH      5.30d
     *      - Enh: Force Put away='N' if dept not live for mispick
     *
610b *    04/27/10  GJA  6.10b     P#00243
     *      - Enh: change UCI to be option driven.  OPUCI
     *
610c *    05/11/10  GJA  6.10c     P#00243
     *      - Fix: change UCI option position.
640aA*    01/13/11  RH   6.40a
     *      - Enh: Add Whse to CHKLIVE parms
640bA*    01/13/11  RH   6.40b
     *      - Fix: Rename RN250FM to RN25001, had to fix Format member
640cA*    02/02/11  RBD  6.40c
     *      - Added incoming parms and logic for normal, generic,
     *        and breakdown qty's when called by Trax pgm TR830.
640dA*    02/02/11  RBD  6.40d
     *      - Fix: Clear woitem and the item fields which populate
     *        it if no hit to PIRITEM.
640eA*    03/15/11  RBD  6.40e
     *      - Do not force 'use label for putaway = Y' when called
     *        from TR830.
640fA*    09/29/11  RH   6.40f
     *      - Fix: Calculate expiration date for use by date item,
     *        just like receiving. Exp date-user days=expiration dt.
640gA*    03/02/12  LMC  6.40g
     *      - Enh: Add Edit to ensure quantity returned does not
     *        exceed quanity picked for order. If order/item link is
     *        not found, user can return whatever they want.
640hA*    07/11/12  RBD  6.40h
     *      - Fix: Changed rev 640g logic to add up the qty of all
     *        occurrences of an item on an order, not just the first
     *        occurrence, because the same item may exist multiple
     *        times on the same order.
     *      - Fix: See same changes to rev CSPc logic.
640iA*    08/31/12  RH   6.40i
     *      - ENH: Add Override for error return qty greater than
     *        order quantity.
     *      - Change to use RN25003.
640jA*    07/17/12  LMC  6.40j
     *      - Enh: Added logic to pass dates to RN246 for new LICINFO
     *        records *MFGDTE, *MFGEXP, *MFGDCOD
     *      - Enh: Added call to decipher code program
     *      - Enh: renamed display file rn25002
640kA*    11/09/12  LMC  6.40k - in process
640lA*    12/18/12  LMC  6.40l
     *      - Fix: Revised program to set W2EXpd, W2MFDT to zeros if
     *        return from MF200 returned with an error and the user
     *        had previously keyed an invalid date into the screen
     *        expiration or mfg date field.
650aA*    02/26/13  LMC  6.50a
     *      - Fix: Turn on indicator 94 for non display on w1qt02 if
     *        the w1um2 field is set to blanks on SSB item.
650bA*    05/22/13  LMC  6.50b
     *      - Enh: RCVRTN transaction for MRC reporting
650cA*    11/09/12  LMC  6.50c
     *      - Enh: Added logic for GS1/UCI scanning.
     *      - Fix: Rev 640H left the wkqor1,wkqor2, wkqor3 fields with
     *      values. Needs to init to zero.
650dA*    06/19/13  LMC  6.50d
     *      - Enh: Pass parm added to RN246 for GTIN. Used for
     *      calculating PTI for the LICINFO file.
     *      - Enh: Add call to CALCPTI
     *      NOTE: this enhancement needs to include Program CALCPTI
650eA*    10/31/13  LMC  6.50e
     *      - Enh: Added PTI code Entry field.
650fA*    12/11/13  LMC  6.50f
     *      - Enh: Increase size of work fields.
     *
650gA*    03/11/14  LMC  6.50g
     *      - Fix: Only check for item difference if gtinsent.
     *        Internal 99 labels - will not be able to identify
     *        an item to compare.
650hA*    05/30/14  LMC  6.50h
     *      - Fix: PTI edit should only occur if *in81 is off.
650iA*    06/02/14  RH   6.50i
     *      - Fix: Add edit to require quantity to be entered.
650jA*    06/13/14  LMC  6.50j
     *      - Fix: Pack date needs to work like Prod date from UCI.
650kA*    07/29/14  LMC  6.50k
     *      - Fix: Move the clear of the w1cwtr field to the end
     *        of the zzupd2 subroutine. Field was being cleared before
     *        writing the orrtn record.
650lA*    08/08/14  RH   6.50l
     *      - Fix: Remove clear of W1CWTR line missed in 650k mod
700 A*    11/07/16  JGD  7.00
     *      - Add logic to support new "Item Type" field (W1TYPE)
     *        This new field will be displayed if client is Cheney,
     *        otherwise displays original "Order #" field. This
     *        modification will identify "BANC and NORM" items
     *        type for Cheney.
700aA*    05/07/15  RH   7.00a
     *      - Display file changed to RN25007, protect normal qty fld
700bA*    08/10/15  RH   7.00b
     *      - Fix: Write exception for mispick pick/order items, was
     *        conditioned only if both items didn't have pick slots.
700cA*    01/06/16  LMC  7.00c
     *      - Enh: Need to call RN246 when Use Generic License is N in
     *        receiving options,  unless using label for putaway.
     *        This is added in order to print receiving labels for
     *        Clients who have Receiving options Use Generic License
     *        set to N, we now print a recieving label with a License
     *        Number(R+Trn#) that is applied to product, and used for
     *        putaway.
     *        Previously we only called RN246 when client was
     *        Using Generic License and not using label for putaway.
700dA*    02/23/16  RH   7.00d
     *      - Fix: woexdt was being set to the calculated expiration
     *        date and written to LICINFO as entered date.  Change to
     *        set woexdt to the keyed date in CMD format like womfdt
700eA*    03/29/16  LMC  7.00e
     *      - Enh: Adding logic for Metric.
700fA*    04/21/16  LMC  7.00f
     *      - Fix: Need to clear templcns field - was being retained
     *        and causing returns being putaway by label following
     *        a return of a uci item to not get a licinfo record.
     *        cleared $barcode & $barcode2.
700gA*    05/03/16  LMC  7.00g
     *      - Fix: 700f was causing data dec error.
     *        Need to clear the $barcode & $barcode2, not eval = ' '.
700hA*    05/05/16  LMC  7.00h
     *      - Fix: UCI scanning was only checking LICACTIVE for
     *        license edit, added additional edits against LICENSE and
     *        liclog, which are done in RN246. Which is too late.
700iA*    07/25/16  MR   7.00i - reserved
700jA*    08/02/16  LMC  7.00j - reserved
700kA*    08/22/16  LMC  7.00k
     *      - Fix: UCI scanning screen should only display for
     *        item that have uci receiving or selection turned on
700l *    01/11/17  RTR  7.00l
     *      - Fix: Add employee number to DRISLOT parms, was creating
     *        LICLOG entries that didn't have employee number.
700mA*    11/03/16  LMC  7.00m
     *      - Enh: UPC file has a database change. Recompile only.
710a *    01/18/17  LMC  7.10a
     *      - Fix: When a upc is scanned in the uci scanning field,
     *        need to clear the $barcode/$barcode2 fields, and do not
     *        overlay them with the data returned in zzconv, unless
     *        the $BCGTINSENT is on.
710b *    03/08/17  LMC  7.10b
     *      - Fix: 710a fixed when a upc was scanned, but does not
     *        handle uci selection/receiving items.
710cA*    09/07/17  MLB  7.10c
     *      - Display file changed to RN25009. Add new flds for SGC.
     *      - Reference SGCb mod.
710dA*    10/18/17  LMC  7.10d
     *      - If the date extracted from the barcode scan is not valid
     *        we will treat the date fields as tho they were not in
     *        the barcode, which will allow the user to enter the date
     *      - added check against LICINFO to make sure license does
     *        not already exist, this only applies to uci scanning.
710eA*    12/06/17  DAS  710e
     *      - Fix: Revised 700c change. Instead of working with field
     *        usegeneric, revised to always set lcnflg *on because we
     *        always want to go into RN246. Current logic will turn
     *        lcnflg *off if we don't need a license plate.
     *
720aA*    12/28/17  NLK  7.20a
     *      - Enh: w1cwtr; CW return, check Range, itemmsc
720bA*    05/21/18  MLB  7.20b (missed coming back from Chef's)
     *      - Enh: Revised 7.20a mod to add code to open ORDC3 for
     *        all users. Was user-controlled open for CSP mod.
720cA*    05/04/18  NLK  7.20c
     *      - FIX: ordcwtot moved out of getordc and before DoU
     *        Should only clear field once while it totals c.w.
720dA*    07/26/18  LMC  7.20d
     *      - ENH: Allow quantity to be entered for the mispick item.
720eA*    08/14/18  LMC  7.20e
     *      - ENH: We will check the uom to determine which fields to
     *        populate on the mispick.
720fA*    09/14/18  RH - LMC  720f
     *      - FIX: do NOT write rec to POMFR if item not date
     *        sensitive.  Was writing to POMFR when GS1 code scanned.
720gA*    09/17/18  RH - LMC  720g
     *      - FIX: Change error msg to be Expired when EXPD calculated
     *        expiration date is < today.
720hA*    09/19/18  LMC/RH    720h
     *      - FIX: Only allow multiple uom's to be returned at the
     *        same time if the number of pallets is 1.
     *        RN246 adds pallets if multiple UOM are returned.
     *        If the client has multiple physical pallets to return
     *        they will need to return the UOMs one at a time.
720iA*    08/02/16  LMC  7.20i  reserved
     *      - Enh: UCI Tracking.
730aA*    10/03/19  LMC  7.30a
     *      - Fix: On mispick returns that are being trashed, we were
     *        not loading an action.
     *
730bA*    10/04/19  LMC  7.30b
     *      - Fix: I had thougth this was only a problem if you didn't
     *        impact inventory. I was wrong. Take out that condition.
740aA*    06/18/20  LMC  7.40a
     *      - Added new incoming parm pckorg. Increased desc to 21.
     *      - loaded invoice# field text same as in scr01i.
740bA*    06/25/20  LMC  7.40b
     *      - Send vendor to cvtbar.
     *      - init cnvwgt on loading screen1
740cA*    08/03/20  LMC  7.40c
     *      - Mod 740b was wiping out w3lcns
740dA*    08/07/20  LMC  7.40d
     *      - CW variance should not occur for uci items if weight
     *        was extracted.
     *      - CW variance should not occur if w3lcns is populated.
     *        The Cw edit has already taken place one.
740eA*    08/12/20  LMC  7.40e
     *      - If a uci is sent in from RN120. Need to get the Item
     *        information before attempting to convert the barcode.
     *        The item number would also be sent in from RN120.
     *      - Only check CW over CW shipped if CW item.
740fA*    08/14/20  LMC  7.40f
     *      - For uci selction items, if we encounter a date error
     *        on screen 2, indicators *in25 or *in32 come on.
     *        if the user does override these errors, need to setof
     *        these two indicators for uci selection items. Otherwise
     *        when screen 4 displays for the next uci to be scanned
     *        the dates fields are displayed and highlighted.
     *      - Only check for missing weight on 99i if cw item
740gA*    08/14/20  LMC  7.40g
     *      - Add scan count to screen4
     *      - change display file to rn25011
740hA*    08/17/20  LMC  7.40h
     *      - on uci item with mispick, zzchk5 executes zzchk1
     *        it needs to edit the original item not the mispicked
     *        item to verify item is on order and not returning more
     *        than was picked.
740iA*    08/27/20  LMC  7.40i
     *      - Reset cwtck to '0' after each uci is added.
740jA*    12/18/20  RH   7.40j
     *      - Fix: Set qty in Mispick Normal Qty, RN246 will shift
     *        qty.  Was putting in breakdown3 causing error. Tkt# 2756
750aA*    04/03/20  RH   7.50a
     *      - Enh: For mispick if there is no slot for the mispick
     *        item. We will create a xdk slot.
750bA*    06/11/21  LMC  7.50b
     *      - Enh: Added new pltlcns/hldpicklbl parms to send to RN246
750cA*    07/19/21  LMC  7.50c
     *      - Enh: When being called from trax returns need to allow
     *        Pallet license to be scanned on screen1.
750dA*    07/29/21  LMC  7.50d
     *      - Enh: Added call to OR737s for exporting realtime returns
     *        as adjustments.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Bros.
     *
CBIaA*    09/23/02  RH   CBIa
     *      - Default PutAway W2IINV to Y.
CBIcA*    11/26/16  MLB  CBIc
     *      - Revised pgm to default Return Code = 99 and Disposition
     *        Code = 01.
CBIdA*    12/16/16  JCJ  CBId
     *      - Temporarily seton *in81 to not require PTI code.
     *      - Temporarily set $lnrcvqty to 1 when 0 to prvent
     *        devide by zero error.
     *
     *----------------------------------------------------------------
     *  Custom changes - Capitol City Produce
CCPaA*    04/27/10  RH      CCPa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away.
     *
     *----------------------------------------------------------------
     *  Custom changes - Dairyland
DRYaA*    01/31/11  RH      DRYa
     *      - Do not allow trans # to be changed.
DRYbA*    02/07/18  NLK     DRYb
     *      - DisAllow F20 to override
     *        DisAllow PutAway to be change for all Disp Codes
DRYcA*    07/29/19  NLK     DRYc
     *      - Allow FULL qty total come in and decide if
     *        Entered Qty is EQ or LT FULL qty
     *      - Remember FULL qty is Item on multi Orders + multi dates
     *      - TIMEOUT: notice the Parms in RN120 calling RN250 vs
     *        RN250's plist - what a mess!!  Scratch above thought
     *      - NEW plan: New array code in RN120 added in RN250 too
DRYdA*    08/10/20  LMC     DRYd
     *      - DisAllow F20 to override needs to be on screen1,3&5
DRYeA*    08/13/20  LMC  DRYe
     *      - Do not verify expiration date or MFG date as non-expired
     *        if will not be put back in inventory
     *      - Allow F20 override of expired product date if being
     *        put back in inventory.
DRYfA*    09/11/20  RH   DRYf
     *      - Display error if Corresponding item is used and
     *        disposition code will impact inventory and corresponding
     *        has no qty on hand.
     *      - Add call DRIITEMQTY
DRYgA*    10/15/20  RH   DRYg
     *      - Display error if Corresponding item is used and
     *        disposition code will impact inventory and return qty
     *        is > coresponding item qty on hand
DRYhA*    10/21/20  RH   DRYh
     *      - Change to display error if Corresponding item is used
     *        and disposition code will impact inventory and return
     *        qty is > coresponding item TOTAL qty on hand
DRYiA*    02/11/21  NLK  DRYi
     *      - FIX (DRYf) to only goto zzzdricop if error=0
     *        User was getting error message displayed on
     *        next screen instead of current screen (zzchk1)
     *
     *----------------------------------------------------------------
     *  Custom changes - EG Forrest
EGFaA*    01/27/10  RH      EGFa
     *      - Make invoice # required entry.
EGFbA*    01/28/10  RH      EGFb
     *      - Do not verify expiration date or MFG date as non-expired
EGFcA*    03/01/10  RH      EGFc
     *      - Force Impact inventory, RNINVF=Y, stock, N=No stock
     *        RNINVF set = field used on DataTech to impact inventory
EGFdA*    03/08/10  RH      EGFd
     *      - For No item return, NOITM dispositon, create adjustment
     *        and update ORRTN record.  No label, trans or license.
EGFeA*    03/12/10  RH      EGFe
     *      - For NOITM, do NOT check pick slot for NOTLIVE dept.
EGFgA*    08/20/10  RH      EGFg
     *      - For NOITM, do NOT require expiration or Mfg date.
     *
     *----------------------------------------------------------------
     *  Custom changes - Earls Organic Produce
EOPaA*    09/17/18  RH      EOPa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away. Add to HSYa
     *----------------------------------------------------------------
     *  Custom changes - FoodPro
FPRaA*    03/17/15  RH   FPRa
     *      -  Enh: Require invoice #, do not allow user to change
     *         put away Y/N.
FPRbA*    05/07/15  RH   FPRb
     *      - Enh: Protect normal uom qty when normal UOM = MP.
FPRcA*    10/13/15  RH   FPRc
     *      - Enh: Allow F20 override of expired product date.
FPRdA*    12/29/15  RH   FPRd
     *      - Fix: FPRc mod was not working for mfg date product.
     *        add code to condition error for override.
     *----------------------------------------------------------------
     *  Custom changes - Greenleaf Produce
GLPaA*    06/26/13  RH      GLPa
     *      - Make CW entry required for quick returns CW items.
GLPbA*    08/09/13  RH      GLPb
GLPb *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away. Add to HSYa
     *----------------------------------------------------------------
     *  Custom changes - Graves Menu Maker
GMMaA*    08/06/13  RH      GMMa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away.
     *----------------------------------------------------------------
     *  Custom changes - Halsey
HSYaA*    01/25/10  RH      HSYa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away.
     *
     *----------------------------------------------------------------
     *  Custom changes - Jordanos
JORaA*    04/20/05  RH   JORa
     *      - ENH:Default Disposition code to 'STOCK'
JORbA*    12/04/07  RH   JORb
     *      - ENH:Force entry of corresponding item if return code is 08
JORcA*    01/28/20  RH   JORc
     *      - Enh: Allow F20 override of expired product date.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packer's
PCK A*    09/07/06  JCJ  PCK
     *      - Enh: Changed heading "Invoice number" to "Delivery number"
PCKaA*    09/28/06  RAH  PCKa
     *      - Enh: Call CW133 instead of UI110 to enter UCI numbers.
PCKbA*    10/17/06  JCJ  PCKb
     *      - Enh: Added disposition code to CW133 parm list.
PCKcA*    12/25/07  JCJ  PCKc
     *      - Fix: Added code to remove blanks from delivery number
PCKdA*    02/09/07  JCJ  PCKd
     *      - Fix: Fix decimal data error with field w1cwtr.
PCKeA*    02/16/07  JCJ  PCKe
     *      Enh: Added file orrtnm processing.
     *
     *----------------------------------------------------------------
     *    Client Custom Revisions: Packers730
PCKfA*    06/18/20  LMC  PCKf
     *      - Enh: special return logic for packers
PCKgA*    08/17/20  LMC  PCKg
     *      - Enh: Do not issue multiple lot warning for vendor 203
     *        Still process and store as if they have taken the
     *        override on multiple lots.
     *      - Enh: For vendor 203 allow user to override lot stored in
     *        LICINFO on screen 9. This is typically protected if the
     *        lot was extracted from the gs1 barcode.
PCK*A*    10/19/20  LMC  PCK*
     *      - Enh: Packers now has RN250 in their custom library.
     *        No more packers mods are required to this program.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: YHata
YHAaA*    04/01/08  RH      YHAa
     *      - Make invoice # required entry.
     *      - Make CW entry required.
YHAbA*    10/24/16  RH   YHAb
     *      - Enh: Allow F20 override of expired product date.
     *      - Add to FPRc and FPRd mods.
     *
     *----------------------------------------------------------------
CLDaA*  Client Custom Revisions: City Line
CLDaA*    03/04/11  RBD     CLDa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt Produce
CSP A*    05/04/11  MLB  CSP  P#01041
     *      - Revised program to write out order detail line number
     *        into return memo field, ORRMEM.
     *      - Added files LABEL, ORDH, ORDH5, ORDC3, ORDD2, RTEHED to pgm.
CSPbA*    09/29/11  RTR  CSPb  P#01053
     *      - Enh: Set default disposition from return code.
     *      - Renamed DSPF to RN25002 from RN25001.
CSPcA*    03/19/12  LMC  CSPc
     *      - Enh: Check for linked items during edit. User will enter
     *      base item, but order will have ODR items. This addition in
     *      specifications to mod 640g came from Ginger after user
     *      testing.
     *      - Enh: Client does not want to allow return of an item if
     *      the item is not on the SO.
CSPdA*    07/11/12  RBD  CSPd
     *      - Fix: Changed rev 640g & CSPc logic to add up the qty of
     *        all occurrences of an item on an order, not just the
     *        first occurrence, because the same item may exist
     *        multiple times on the same order.
     *
     *----------------------------------------------------------------
     *  Custom changes - City Wholesale
CTWaA*    12/01/10  RH      CTWa
     *      - Default disposition code to '1'.
     *      - Default return reason code to 'AA.
     *----------------------------------------------------------------
     *  Custom changes - Springfield
SGCaA*    06/05/12  RBD     SGCa
     *      - Default Number of pallets to 1.
     *      - Default Use label for putaway to 'Y'.
SGCbA*    09/07/17  MLB  SGCb  P#01801
     *      - Revised SCREEN1 to add new fields.
     *      - Add new field to screen1; W1lookt - Lookup Type (O, I, C)
     *        Where O=Order# lookup, I=Invoice history lookup and
     *              C=Pick-up request.
SGCcA*    09/13/17  MLB  SGCc  P#01801
     *      - Revised ZCHK1 to force w1inv1 to be entered.
     *      - Added SGCc to EGFa mod.
     *
     *----------------------------------------------------------------
     *  Custom changes - West Side Foods
WSTaA*    06/24/03  MLB     WSTa
     *      - Revised ZZFIL1 to set W1CODE to 'WR'. W1DCDE to 'STOCK'
     *      - Revised ZZCHK1 to not flag error if catchwgt not entered
WSTb *   06/13/14  LMC  WSTb
     *     - Load the earliest prod/pack date from the UCI scan to
     *     wofifo date field
     *----------------------------------------------------------------
     *  Custom changes - Kohl Wholesale
KHLaA*    08/25/14  LMC     KHLa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Will Foods
WIL A*    09/30/14  MLB/RH  WIL
     *      - Make invoice # required entry.
     *      - Added WIL to YHAa mod.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
FGL A*    06/27/16  RH   FGLa
     *      - Make invoice # required entry.
     *      - Added FGL to YHAa mod.
     *----------------------------------------------------------------
     *  Custom changes - Panos
PANaA*    10/03/17  RH      PANa
     *      - Do not verify expiration date or MFG date as non-expired
     *        if Put away = 'N'. Will not be put away. add to HSYa mod
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Julius Silvert
JSLaA*    04/10/17  LMC  JSLa
     *      - For S type items do not require UCI scanning unless
     *      - the item is setup for UCI Selection.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
640bDF*n250fm   cf   e             workstn
CSPbDF*rn25001   cf   e             workstn
640iDF*n25002   cf   e             workstn
640jDF*rn25003   cf   e             workstn
650cDF*rn25004   cf   e             workstn
650eDF*rn25005   cf   e             workstn
700aDF*n25006   cf   e             workstn
700eDF*rn25007   cf   e             workstn
710cDF*rn25008   cf   e             workstn
720dDF*rn25009   cf   e             workstn
740gDF*rn25010   cf   e             workstn
750cDF*rn25011   cf   e             workstn
750cMFrn25012   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Funmesr    if   e           k disk
     Fpiritem   if   e           k disk
CSPcAFitemlnk1  if   e           k disk
640gDF*orrtn     o  a e           k disk
640gMForrtn     uf a e           k disk
     Foptions   if   e           k disk
CSP AFLabel     if   e           k disk    prefix(lb)
CSP AF                                     usropn
DRYcAFordd3     if   e           k disk    prefix(od3_)
DRYcAF                                     rename(odrec:o3rec)
415aAFLabel2    if   e           k disk
     F                                     rename(lbrec:record)
415aAFLabelnk   o  a e           k disk
416bAFupc       if   e           k disk
416bAFpiritem4  if   e           k disk
     F                                     rename(itrec:i4rec)
416kAFitemmsc   if   e           k disk
416bAFrdscode   if   e           k disk
416dAFrtncode   if   e           k disk
416bAFitmexcp   o    e           k disk
500dDF*omfr     o    e             disk
500dAFpomfr1    uf a e           k disk
500bDF*temadj   o  a e           k disk
CSP AFordc3     if   e           k disk
CSP AF                                     usropn
640gAFordd      if   e           k disk    prefix(od_)rename(odrec:od2)
CSP AFordd2     if   e           k disk
CSP AF                                     usropn
CSP AFordh      if   e           k disk    prefix(oh)
CSP AF                                     usropn
CSP AFordh5     if   e           k disk    prefix(oh5)
CSP AF                                     rename(ohrec:oh5rec)
CSP AF                                     usropn
CSP AFrtehed    if   e           k disk
CSP AF                                     usropn
510aAFordhm3    if   e           k disk
PCKeAForrtnm    o    e             disk
700hAFLicense   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
YHAaDD*desc            s             50    dim(9) ctdata perrcd(1)
640gDD*desc            s             50    dim(10) ctdata perrcd(1)
650cDD*desc            s             50    dim(11) ctdata perrcd(1)
650eDD*desc            s             50    dim(14) ctdata perrcd(1)
SGCbDD*desc            s             50    dim(15) ctdata perrcd(1)
720aDD*desc            s             50    dim(16) ctdata perrcd(1)
720dDD*desc            s             50    dim(17) ctdata perrcd(1)
720hDD*desc            s             50    dim(18) ctdata perrcd(1)
740aDD*desc            s             50    dim(19) ctdata perrcd(1)
DRYfDD*desc            s             50    dim(21) ctdata perrcd(1)
DRYfMD desc            s             50    dim(22) ctdata perrcd(1)
416bD*                   DESC    1   6 50
416cMD hed             s             50    dim(4) ctdata perrcd(1)
DRYbAD*cmdln           s             79    dim(6)ctdata perrcd(1)
DRYbAD cmdln           s             79    dim(9)ctdata perrcd(1)
DRYcAD ORDnum          s              7  0 dim(99)
DRYcAD ORDqt1          s              5  0 dim(99)
DRYcAD ORDqt2          s              5  0 dim(99)

700eA*----------------------------------------------------------------
700eA* Function prototypes.
700eA*----------------------------------------------------------------

700eA /copy qcopysrc,p.getimuom

500b *----------------------------------------------------------------
500b *  DRI parameters
500b *----------------------------------------------------------------

500b  /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
500b *  Data Formats
     *----------------------------------------------------------------

500b  /COPY *libl/qcopysrc,C#ITEM
DRYfA /COPY *libl/qcopysrc,C#ITEMQTY
500b  /COPY *libl/qcopysrc,C#SLOT
650cA /COPY *libl/qcopysrc,C#LICENSE
650cA /COPY *libl/qcopysrc,C#LICINFO
650cA /COPY *libl/qcopysrc,C#UCIINFO
720dAD rtn$Item        ds                  likeds($item)
720dAD rtn$item2       ds                  likeds($item2)

510 A*----------------------------------------------------------------
510 A*  Customer id
510 A*----------------------------------------------------------------

510 A /copy qcopysrc,id#packers
YHAaA /copy qcopysrc,id#yhata
CCPaA /copy qcopysrc,id#capitol
EGFaA /copy qcopysrc,id#egf
HSYaA /copy qcopysrc,id#halsey
JOR   /copy qcopysrc,id#jordano
DRYaA /copy qcopysrc,id#dairyla
CLDaA /copy qcopysrc,id#citylin
CSP A /copy qcopysrc,id#coastal
CTWaA /copy qcopysrc,id#citywho
SGCaA /copy qcopysrc,id#sgc
WSTaAD/copy qcopysrc,id#westsid
GLPaAD/copy qcopysrc,id#glp
GMMaAD/copy qcopysrc,id#gmm
KHLaAD/copy qcopysrc,id#khl
WIL AD/copy qcopysrc,id#wil
700 A /copy qcopysrc,id#cheney
FGLaAD/copy qcopysrc,id#fgl
FPR AD/copy qcopysrc,id#fpr
JSLaAD/copy qcopysrc,id#jsl
PAN AD/copy qcopysrc,id#pan
EOP AD/copy qcopysrc,id#eop

500b D savever#        s                   like($slver#)
500b D saveaisl        s                   like($slaisl)
500b D saveloc         s                   like($slloc)
500b D saverlvl        s                   like($slrlvl)
500b D savehand        s                   like($slhand)
500b D slotds        e ds                  extname(slot)

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Variables
     *
650cAD $emp#           s              5  0
650cAD $lexpdt6        s              6  0
650cAD $lmfgdt6        s              6  0
650cAD $unext          s             13  0
     D $lord           s              7  0
650dAD $lbcProdD       s              6  0
     D $msgf           s             10
650eAD $pw2pti         s              4  0
650bAD $rtnord         s              9
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
720iAD blank6          s              6
650cAD checklcns       s             15
650cAD chk4err         s               n
     D clear           s              5  0
     D cmdchk          s              8
     D cmdtkn          s              1
700eAD CnvWgt          s              9  2
     D comand          s              5  0
720aAD cwtck           s              1
640iAD dfchk           s              1
650cAD difflot         s               n
650cAD diffexpd        s               n
     D dtfrmt          s              1  0
     D e               s              2  0
     D enter           s              5  0
650cDD*error           s              1
650cMD error           s               n
720aAD exwgt           s              9  2
720aAD exwgt2          s              9  2
     D expd            s              8  0
650cAD expdwarn        s              1
650cAD expdovr         s              1
     D flbflg          s              1
     D forevr          s              1
     D g$date          s              6  0
     D g$dd            s              2  0
     D g$dw            s              1  0
     D g$jd            s              5  0
     D g$jyd           s              7  0
     D g$mm            s              2  0
     D g$mmwk          s              2  0
     D g$wk7           s              7  0
     D g$yy            s              2  0
     D g$yywk          s              3  0
     D g$yyyy          s              4  0
640gAD good1           s              1
     D gmwksv          s              2  0
     D help            s              5  0
720aAD hirng           s              9  2
720aAD hivar           s              9  2
720aAD hlddt           s              8  0
720aAD hvskp           s              1
720aAD ihrng           s              9  2
720aAD ihvar           s              9  2
720aAD ilrng           s              9  2
720aAD ilvar           s              9  2
     D j$date          s              6  0
     D j$dd            s              2  0
     D j$jd            s              5  0
     D j$md            s              3  0
     D j$mm            s              2  0
     D j$tst           s              9  9
510cAD j$tsthld        s             14  9
     D j$x             s              2  0
     D j$yd            s              7  0
     D j$yywk          s              3  0
     D j$yyyy          s              4  0
650dAd k               s                   like($lnrcvqty)
700eAD kgs2lbs         c                   2.20462262
700eAD KiloLbs         s              1
700eAD IMkilolbs       s              1
700eAD IMUom           s              3
     D kyitem          s                   like(ititem)
CSP AD kystat          s                   like(odstat)
CSP AD                                     inz('P')
     D kyupc           s                   like(upupc)
     D kyvmfg          s                   like(itvit#)
650cAD lastseq         s                   like($lnseq)
     D lcnflg          s              1
700eAD lcnswgt         s              9  2
CSPcAD linkitem        s             15
650cAD lcnsExists      s               n
650cAD licinfoupd      s               n
650cAD lotwarn         s              1
650cAD lotovr          s              1
720aAD lvskp           s              1
720aAD lwrng           s              9  2
720aAD lwvar           s              9  2
     D mfdtj           s              5  0
510dAD mfg_expd        s              6  0
     D mfgd            s              8  0
     D msgk            s              4  0
640jAD mexpd           s              8  0
640jAD mfgdte          s              8  0
650cAD moretoscan      s              1
700eAD needweight      s              1
     D nxtscr          s              3
720aAD OrdCWtot        s              9  2
640iaD ovrrid          s              1
     D ocode           s              8
     D oslot           s             12
     D picksl          s              1
650bAD poppcs          s                   like($lpcs)
650dAd pplot           s             20
650dAd pppti           s              4  0
720aAD prg1c           s              4  3
720aAD prg2c           s              4  3
     D pslot           s             12
650eAD ptiovr          s              1
650eAD ptichk          s              1
650eAd ptinodate       s              6  0
     D quick           s              1
650bAD rcvrtncomplete  s               n
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
     D rtntyp          s              1
WSTbAD savewstfifo     s              8  0
WSTbAD wstfifo         s              8  0
650cAD savew2mfdt      s                   like(w2mfdt)
650cAD savew2expd      s                   like(w2expd)
650cAD saveexpd        s                   like(expd)
650cAD savelotc        s                   like(w2lotc)
650cAD savewgt         s                   like(w1cwtr)
650cAD saveqty         s                   like($lnrcvqty)
     D sclear          s              1
     D stop            s              1
650eAD svpti           s              4  0
720aAD taddw           s              7  2
650cAD templcns        s             15
     D today           s              8  0
DRYcAD totqt1          s              5  0
DRYcAD totqt2          s              5  0
650cAD uciexists       s               n
650cAD unexta          s             13
     D upcctr          s              3  0
640fAD usdtj           s              5  0
640fAD usb_expd        s              6  0
710eDD*usegeneric      s              1
700eAD whse            s              3  0
     D warn            s              1
720aAD wkcwrtn         s              9  2
720aAD wkcwleft        s              9  2
640gAD wkoQty1         s              6  0 inz
640gAD wkoQty2         s              6  0 inz
640gAD wkoQty3         s              6  0 inz
640gAD wkQor1          s              5  0 inz
640gAD wkQor2          s              5  0 inz
640gAD wkQor3          s              5  0 inz
650fDD*wkretqty        s              5  0 inz
650fDD*wkpickqty       s              5  0 inz
650fDD*wkpretqty       s              5  0 inz
650fMD wkretqty        s              9  0 inz
650fMD wkpickqty       s              9  0 inz
650fMD wkpretqty       s              9  0 inz
     D wodev           s             10
     D woform          s             10
     D woinvf          s              1
     D wolbl#          s              7  0
640gAD WOORD           s              7  0
DRYcAD wiord           s              7  0
     D worexq          s              1
     D work2           s              2
     D work4           s              4
     D wotrn#          s              7  0
     D woulbl          s              1
     D wouser          s             10
600aAD woexdt          s              8  0
600aAD wofifo          s              8  0
600aAD woindt          s              8  0
600aAD womfdt          s              8  0
600aAD wodktexpd       s              8  0
     D wscitm          s             15
     D w1memo          s             30
720aAD w1qt01x         s              5  2
     D w1slot          s             12
DRYcAD x               s              2  0
650cAD ckupc           s             50
500b D AJCODE          s              2
500b D zmsflag         s               n
510 AD client          s             10
PCKcAD wkinv#          s              9
PCKcAD pos             s              1  0
650cAD zmflag          s               n
740aAD pak9            s              9  0
740aAD pak7            s              7  0
750aAd wkCrtXDKErr     s              8    inz

750bAD pltlcns         s             10
750bAD hldpicklbl      s             10

750dAD batId           s             11
750dAD rtnCodex        s             10
750dAD rtnMessage      s            200
750dAD haveBatId       s               n
750dAD $pWhse3A        s              3
750dAd ExportType      s            117a
650cA*----------------------------------------------------------------
650cA*  Prototypes
650cA*----------------------------------------------------------------
650cAD ucilic#         pr                  extpgm('UCILIC#')
650cA * Input
650cAD   unext                       13  0 const
650cAD   uwhse                        3  0 const
650dAD calcpti         pr                  extpgm('CALCPTI')
650dA * Input
650dAD   pGTIN                             like($bcgtin)
650dAD   pLOT                              like(pplot)
650dAD   pPackDate                         like($lbcProdD)
650dAD   pPTI                              like(pppti)
750dA /copy qcopysrc,p.getoptio
750dA /copy *libl/qcopysrc,p.getopint
650cA*----------------------------------------------------------------
650cA*  Convert Barcode Parms
650cA*----------------------------------------------------------------

650cA /COPY *libl/qcopysrc,C#CVTPARMS
650cA /COPY *libl/qcopysrc,C#BARCODE
750cA*----------------------------------------------------------------
750cA*  File field data structure.
750cA*----------------------------------------------------------------

750cAD rnlrec        e ds                  extname(PLTLCNS) inz(*EXTDFT)
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
     D  $pitem                22     36
     D  $puser                37     46
     D  $pdev                 47     56
     D  $pform                57     66

500eAD #slotitem       s                   like($ititem)
500eAD #slottype       s                   like($ittype)

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
     D  $litem                22     36
     *
417a D  $lupc                 22     41
417a D  $litm1                42     56
     *
     D  $lcode                19     20
     *
PCKaAD  $lwhseu               19     21  0
PCKaAD  $litemu               22     36
PCKaAD  $lcodeu               37     38
PCKaAD  $ltypeu               39     39
PCKaAD  w1qt01p               40     44  0
PCKaAD  w1qt02p               45     47  0
PCKaAD  w1qt03p               48     50  0
PCKdD***w1cwtr                51     59  2
PCKdMD  $pcwgt                51     59  2
PCKaAD  $ldate                60     64p 0
PCKaAD  $ltime                65     68p 0
416bA*
416bAD  $ldcde                19     23
     *
     D  $ltrn#                19     25  0
     *
     D  $luser                19     28
     *
     D  $lpo                  37     45
     D  $lrq1                 46     50  0
     D  $lrq2                 51     55  0
     D  $lrq3                 56     60  0
     D  $lrpal                61     63  0
     *
640jAD  $lmfr#                22     32  0
640jAD  $lmfritem             33     47
640jAD  $ldakitem             48     62
640jA*------------------------------------------------------------------
640jA* CLCDUR2 parameters
640jA*------------------------------------------------------------------

640jAD $cdcmd          s              8

640jAD $cddatein       s              8  0
640jAD $cdtimein       s              6  0

640jAD $cdyears        s              3  0
640jAD $cdmonths       s              3  0
640jAD $cddays         s              3  0
640jAD $cdhours        s              3  0
640jAD $cdminutes      s              3  0
640jAD $cdseconds      s              3  0

640jAD $cddateOut      s              8  0
640jAD $cdtimeOut      s              6  0

     *
     *----------------------------------------------------------------
     *  Called programs
     *
650bAD @crtrcv         c                   const('CRTRCVTRN')
     D @cvtdt          c                   const('CVTDTE')
PCKaAD @cwght          c                   const('CW133')
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
     *
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erulen                 1      3p 2
     D  eruwdt                 4      6p 2
     D  eruhgt                 7      9p 2
     D  ercalc                10     13p 3
     D  ercube                14     17p 3
     D  ercdiv                18     22p 2
     D  ercrng                23     24p 1
     D  ermax                 25     28p 4
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
720a *
720aAD  ertcwt                 1      5p 2
720aAD  erlrng                 6     10p 2
720aAD  erhrng                11     15p 2
720aAD  errg1c                16     17p 1
720aAD  errg2c                18     19p 1
720aAD  erexwt                20     24p 2
720aAD  erum                  25     26
720aAD  erilrng               27     31p 2
720aAD  erihrng               32     36p 2
     *
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
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     D  opupct                11     13  0
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
     D  oppasl                21     21  0
     D  oppfrc                22     22
     D  opplcn                23     23
     D  opcum                 24     43
     D  opcdiv                44     52  2
     D  opcaut                53     53
     D  opcwrn                54     54
     D  opcrng                55     57  1
     D  opwum                 58     72
     D  opxdsc                73     73
     D  optend               117    117
416eA*----------------------------------------------------------------
416eA*  *RETURNS -  Customer Returns options
416eA*----------------------------------------------------------------
416eA*
416eA* Fields
416eA*
416eA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
416eA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
416eA*    OPRFLB  -  Force return label entry. (Y/N)
416cA*    OPREXQ  -  Export Quick returns.(Y/N)
416dA*    OPRULB  -  Use label for putaway.(Y/N)
750cA*    OPPLTL  -  Allow Pallet License.(Y/N)
750dA*    OPREAD  -  Export as adjustments. (Y/N)
416eA*
416eA* Data structure
416eA*
416eAD oprdta          ds
416eAD  oprqch                 1      1
416eAD  oprqec                 2      2
416eAD  oprflb                 3      3
416eAD  oprexq                 4      4
416gAD  oprulb                 5      5
750dAD  opread                 6      6
750cAD  oppltl                 9      9
416eAD  oprend               117    117
610bA*----------------------------------------------------------------
610bA*  *SYSTEM  -  System options.
610bA*----------------------------------------------------------------
610bA*
610bA* Fields
610bA*
610bA*    OPUCI   -  Use UCI processing (Y,N)
610bA*
610bA* Data structure
610bA*
610bAD opdta2          ds
720aAD  oprg1c                 6      8  1
720aAD  oprg2c                 9     11  1
610cDD**opuci                 33     33
610cMD  opuci                 36     36
610bAD  optend2              117    117
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
PCKeA*
PCKeA*----------------------------------------------------------------
PCKeA*  SAP Returns Misc field File data structures
PCKeA*
PCKeA /copy qcopysrc,rmmsc1_pak
PCKeA /copy qcopysrc,rmmsc2_pak
PCKeA /copy qcopysrc,rmmsc3_pak
PCKeA /copy qcopysrc,rmmsc4_pak
PCKeA /copy qcopysrc,rmmsc5_pak
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *RETURN  - Customer return.
     *              *TFRRTN  - Transfer returns.
     *              *POSRTN  - POS returns.
     *
     *    Returned Parameters
530bA*              *TRKRTN  - Tracker return was completed.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
415aAC                   parm                    $plbl#            7 0
415bAC                   parm                    $pord             7 0
416bAC                   parm                    $ptrn#            7 0
416cAC                   parm                    $pqck             1
416dAC                   parm                    $pinv#            9
640cAC                   parm                    $ttqty            5 0
640cAC                   parm                    $ttrcod           2
640cAC                   parm                    $ttcwgt           9 2
640cAC                   parm                    $ttbflg           1
650bAC                   parm                    $lsavetrn         7 0
650cAC                   parm                    $w1uci          100
720aAC                   parm                    $lbord            7 0
740aAC                   parm                    pckorg            4 0
750bAC                   parm                    pltlcns
750bAC                   parm                    hldpicklbl
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
650bAc                   eval      rcvrtncomplete = *off
650cAc                   if        $w1uci <> ' '
740eAc                   exsr      getitem
650cAc                   eval      w1uci = $w1uci
650cAc                   exsr      zzconvertuci
650cAc                   endif
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
650cAC     nxtscr        caseq     '03 '         sc3
650cAC     nxtscr        caseq     '04 '         sc4
650cAC     nxtscr        caseq     '05 '         sc5
650cAC     nxtscr        caseq     'CNL'         sccnl
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
650bAC                   exsr      zzrcvrtnclose
     C                   return
750aA*----------------------------------------------------------------
750aA*
750aA*  ZZCrtXDK - Creat XDK slot for item.
750aA*
     C     zzcrtxdk      begsr
750aA*
750aA*  Use DRI interface to create XDK slot.
750aA
750aAC                   eval      savever# = $slver#
750aAC                   clear                   $slot
750aAc                   clear                   $slot2
750aAC                   eval      $slver# = savever#
750aA*
750aAC                   eval      $slwhseu = *on
750aAC                   eval      $slwhse  = $pwhse
750aA*
750aAC                   eval      $slwhdpu = *on
750aAC                   eval      $slwhdp  = $itwhdp
750aA*
750aAC                   eval      $slitemu = *on
750aAC                   eval      $slitem  = $ititem
750aA*
750aAC                   eval      $slaislu = *on
750aAC                   eval      $slaisl  = 'XDK'
750aA*
750aAC                   eval      $dricommand = '*SLOT'
750aAC                   eval      $drisubcmd = '%CRTXDOCK'
750aAC                   eval      $drisys2upd = 'D'
750aAc                   exsr      ZzzDriCop
750aAc                   if        $drireturn <> '*OK'
750aAC                   eval      wkCrtXDKErr = '*XDKCRTER'
750aAc                   else
750aAc                   eval      pslot = $sldisp
750aAC                   endif
750aA*
750aAc****               return    wkCrtXDKErr
750aA*
750aA*
     C                   endsr
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
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
650cAC                   if        nxtscr = '03 '
650cAC                   exfmt     screen3                              50
650cAC                   endif
     *
650cAC                   if        nxtscr = '04 '
650cAC                   exfmt     screen4                              50
650cAC                   endif
     *
650cAC                   if        nxtscr = '05 '
650cAC                   exfmt     screen5                              50
650cAC                   endif
650cA*
650cAC                   if        nxtscr = 'CNL'
650cAc                   exfmt     cnlwdw                               50
650cAC                   endif
     *
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
     C                   setoff                                       3031
740fAC                   setoff                                       32
     C                   setoff                                       333435
700 DC*                  setoff                                       363738
700 MC                   setoff                                       3637
     C                   setoff                                       3940
650cAC                   setoff                                       43
650eAC                   setoff                                       41
     C                   setoff                                       98
EGFcAC                   setoff                                       58
700eAC                   setoff                                       5565
720eAC                   setoff                                       444648
750cAC                   setoff                                       57
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
     C                   eval      nxtscr = '01 '
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
CSPbA *
CSPbAC                   if        client = CoastalSunbelt
CSPbAC                   eval      *in89 = *on
CSPbAC                   endif
CSPbA *
     C                   eval      refrsh = *off
DRYaA *
DRYaAC                   select
DRYaAC                   when      client = dairyland
DRYaAC                   eval      *in59 = *on
DRYaAC                   other
DRYaAC                   eval      *in59 = *off
DRYaAC                   endsl
510aA *
510aAC                   select
510aAC                   when      client = packers
510aAC                   eval      w1invh = 'Delivery number . . . . .'
510aAC                   eval      w1bilh = 'Billing Document number .'
510aAC                   eval      *in17 = *off
SGCbA*
SGCbAC                   when      client = sgc
SGCbAC                   eval      w1invh = 'Invoice number. . . . . .'
SGCbAC                   eval      w1bilh = *blanks
SGCbAC                   eval      *in17  = *on
SGCbAC                   eval      w1lktx = 'Lookup type'
SGCbAC                   eval      w1lktp = 'O'
SGCbAC                   eval      w1lkcd = 'O,I,C'
SGCbA*
510aAC                   other
510aAC                   eval      w1invh = 'Invoice number. . . . . .'
510aAC                   eval      w1bilh = *blanks
510aAC                   eval      *in17 = *on
510aAC                   endsl
640iAC                   eval      ovrrid = *off
510aA *
720dAc                   eval      *in45 = *on
720dAc                   eval      *in47 = *on
720dAc                   eval      *in49 = *on
     C     end01i        endsr
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     C                   eval      w2scrn = 'RN250.02'
     *R         REFRSH    IFEQ *ON
     C                   exsr      zzfil2
     *R                   ENDIF
     C                   eval      refrsh = *off
     C     end02i        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  Screen 03 initialization
650cA*
650cAC     scr03i        begsr
650cAC                   eval      nxtscr = '03 '
650cAC                   if        refrsh = *on
650cAC                   exsr      zzfil3
650cAC                   endif
650cAC                   eval      w3scrn = 'RN250.03'
650cAC                   eval      refrsh = *off
740aAC                   select
740aAC                   when      client = packers
740aAC                   eval      w1invh = 'Delivery number . . . . .'
740aAC                   eval      w1bilh = 'Billing Document number .'
740aAC                   eval      *in17 = *off
740aA*
740aAC                   when      client = sgc
740aAC                   eval      w1invh = 'Invoice number. . . . . .'
740aAC                   eval      w1bilh = *blanks
740aAC                   eval      *in17  = *on
740aAC                   eval      w1lktx = 'Lookup type'
740aAC                   eval      w1lktp = 'O'
740aAC                   eval      w1lkcd = 'O,I,C'
740aA*
740aAC                   other
740aAC                   eval      w1invh = 'Invoice number. . . . . .'
740aAC                   eval      w1bilh = *blanks
740aAC                   eval      *in17 = *on
740aAC                   endsl
650cAC     end03i        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  Screen 04 initialization
650cA*
650cAC     scr04i        begsr
650cAC                   move      '04 '         nxtscr
650cAC                   exsr      zzfil4
650cAC                   eval      w4scrn = 'RN250.04'
650cAC                   eval      refrsh = *off
650cAC     end04i        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  Screen 05 initialization
650cA*
650cAC     scr05i        begsr
650cAC                   move      '05 '         nxtscr
650cAC                   exsr      zzfil5
650cAC                   eval      refrsh = *off
650cAC                   eval      w5scrn = 'RN250.05'
740aAC                   select
740aAC                   when      client = packers
740aAC                   eval      w1invh = 'Delivery number . . . . .'
740aAC                   eval      w1bilh = 'Billing Document number .'
740aAC                   eval      *in17 = *off
740aA*
740aAC                   when      client = sgc
740aAC                   eval      w1invh = 'Invoice number. . . . . .'
740aAC                   eval      w1bilh = *blanks
740aAC                   eval      *in17  = *on
740aAC                   eval      w1lktx = 'Lookup type'
740aAC                   eval      w1lktp = 'O'
740aAC                   eval      w1lkcd = 'O,I,C'
740aA*
740aAC                   other
740aAC                   eval      w1invh = 'Invoice number. . . . . .'
740aAC                   eval      w1bilh = *blanks
740aAC                   eval      *in17 = *on
740aAC                   endsl
650cAC     end05i        endsr
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
650cAC                   if        moretoscan = *on
650cAc                   eval      nxtscr = 'CNL'
650cAC                   goto      endsc1
650cAc                   endif
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
411 D*R                   MOVE *OFF      *IN32
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      $prtn = '*CANCEL '
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
700eA*     Setup converted weight field.
700eAC                   exsr      zzcnvwgt
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Everything went fine so onto the next screen.
     *
416BAC                   eval      refrsh = *on
JSLaAc                   Select
JSLaAc                   when      client = jsilvert and $ittype = 'S'
JSLaAc                             and $ifsltmth <> '2'
JSLaAC                   exsr      scr02i
JSLaAc                   other
650cAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650cAc                   if        w1uci = ' '
650cAC                   exsr      scr04i
650cAc                   else
650cAC                   exsr      scr03i
650cAc                   endif
650cAc                   else
416b C                   exsr      scr02i
650cAc                   endif
JSLaAc                   endsl
412 D*R                   MOVE 'EOJ'     NXTSCR
     *
     C     endsc1        endsr
     *
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
416bMC                   eval      nxtscr = '02 '
416bM**                   MOVE 'EOJ'     NXTSCR
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
650cAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650cAc                   eval      nxtscr = '03 '
650cAc                   else
     C                   eval      nxtscr = '01 '
650cAc                   endif
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
JSLaAc                   Select
JSLaAc                   when      client = jsilvert and $ittype = 'S'
JSLaAc                             and $ifsltmth <> '2'
JSLaAC                   exsr      zzupd2
JSLaAc                   other
650cAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650cAc                   exsr      zzuci
650cAc                   else
     C                   exsr      zzupd2
650cAc                   endif
JSLaAc                   endsl
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *
     *----------------------------------------------------------------
650cA*
650cA*  SC3  -  Screen 3
650cA*
650cAC     sc3           begsr
650cA*
650cA*  Test for F3 - Exit
650cA*
650cAC                   if        *inkc
650cAC                   if        moretoscan = *on
650cAc                   eval      nxtscr = 'CNL'
650cAc                   else
650cAC                   move      'EOJ'         nxtscr
650cAc                   eval      w1uci = ' '
650cAC                   goto      endsc3
650cAc                   endif
650cAC                   endif
650cA*
650cA*  Test for F5 - Refresh
650cA*
650cAC                   if        *inke
650cAC                   eval      refrsh = *on
650cAC                   exsr      scr03i
650cAC                   goto      endsc3
650cAC                   endif
650cA*
650cA*  Test for F12 - Previous
650cA*
650cAC                   if        *inkl
650cAC                   if        moretoscan = *on
650cAc                   eval      nxtscr = 'CNL'
650cAc                   else
650cAC                   move      'EOJ'         nxtscr
650cAc                   eval      w1uci = ' '
650cAC                   goto      endsc3
650cAc                   endif
650cAC                   endif
650cA*
650cA*  Test for other command keys BEFORE verification and update.
650cA*
650cAC                   eval      cmdchk = '*BEFORE '
650cAC                   exsr      zzcmd3
650cAC     cmdtkn        cabeq     *on           endsc3
650cA*
650cA*  Some other key pressed.
650cA*
650cA*     Check input and write/update record.
650cA*
700eA*     Setup converted weight field.
700eAC                   exsr      zzcnvwgt
650cAC                   exsr      zzchk3
650cAC     error         cabeq     *on           endsc3
650cAC                   exsr      zzupd3
650cAC     error         cabeq     *on           endsc3
650cA*
650cA*  Test for other command keys AFTER verification and update.
650cA*
650cAC                   eval      cmdchk = '*AFTER  '
650cAC                   exsr      zzcmd3
650cAC     cmdtkn        cabeq     *on           endsc3
650cA*
650cA*  Everything went fine so onto the next screen.
650cA*
650cAC                   eval      refrsh = *on
650cAC                   exsr      scr02i
650cA*
650cAC     endsc3        endsr
     *
650cA*----------------------------------------------------------------
650cA*
650cA*  SC4  -  Screen 4
650cA*
650cAC     sc4           begsr
650cA*
650cA*  Test for F3 - Exit
650cA*
650cAC                   if        *inkc
650cAC                   if        moretoscan = *on
650cAc                   eval      nxtscr = 'CNL'
650cAC                   goto      endsc4
650cAc                   endif
650cAC     *loval        setll     record
650cAC                   eval      nxtscr = 'EOJ'
650cAc                   eval      w1uci = ' '
650cAC                   goto      endsc4
650cAC                   endif
650cA*
650cA*  Test for F5 - Refresh
650cA*
650cAC                   if        *inke
650cAC                   eval      refrsh = *on
650cAC                   exsr      scr04i
650cAC                   goto      endsc4
650cAC                   endif
650cA*
650cA*  Test for F12 - Previous
650cA*
650cAC                   if        *inkl
650cAC                   if        moretoscan = *on
650cAc                   eval      nxtscr = 'CNL'
650cAC                   goto      endsc4
650cAc                   endif
650cAC     *loval        setll     record
650cAC                   eval      nxtscr = 'EOJ'
650cAc                   eval      w1uci = ' '
740dAC                   eval      $prtn = '*CANCEL '
740dAC                   eval      nxtscr = 'EOJ'
650cAC                   goto      endsc4
650cA*
650cAC                   endif
650cA*
650cA*  Test for other command keys BEFORE verification and update.
650cA*
650cAC                   move      '*BEFORE '    cmdchk
650cAC                   exsr      zzcmd4
650cAC     cmdtkn        cabeq     *on           endsc4
650cA*
650cA*  Some other key pressed.
650cA*
650cA*     Check input and write/update record.
650cA*
650cAC                   exsr      zzchk4
650cAC     error         cabeq     *on           endsc4
650cAC     moretoscan    cabne     *on           endsc4
650cAC                   exsr      zzupd4
650cAC     error         cabeq     *on           endsc4
650cA*
650cA*  Test for other command keys AFTER verification and update.
650cA*
650cAC                   move      '*AFTER  '    cmdchk
650cAC                   exsr      zzcmd4
650cAC     cmdtkn        cabeq     *on           endsc4
650cA*
650cA*  Everything went fine get next uci.
650cA*
650cAC                   eval      refrsh = *on
650cA*
650cAC     endsc4        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  SC5  -  Screen 5
650cA*
650cAC     sc5           begsr
650cA*
650cA*  Test for F3 - Exit
650cA*
650cAC                   if        *inkc
650cAC                   move      '04 '         nxtscr
650cAC                   goto      endsc5
650cAC                   endif
650cA*
650cA*  Test for F5 - Refresh
650cA*
650cAC                   if        *inke
650cAC                   eval      refrsh = *on
650cAC                   exsr      scr05i
650cAC                   goto      endsc5
650cAC                   endif
650cA*
650cA*  Test for F12 - Previous
650cA*
650cAC                   if        *inkl
650cAC                   move      '04 '         nxtscr
650cAC                   goto      endsc5
650cAC                   endif
650cA*
650cA*  Test for other command keys BEFORE verification and update.
650cA*
650cAC                   move      '*BEFORE '    cmdchk
650cAC                   exsr      zzcmd5
650cAC     cmdtkn        cabeq     *on           endsc5
650cA*
650cA*  Some other key pressed.
650cA*
650cA*     Check input and write/update record.
650cA*
650cAC                   exsr      zzchk5
650cAC     error         cabeq     *on           endsc5
650cAC                   exsr      zzupd5
650cAC     error         cabeq     *on           endsc5
650cA*
650cA*  Test for other command keys AFTER verification and update.
650cA*
650cAC                   move      '*AFTER  '    cmdchk
650cAC                   exsr      zzcmd5
650cAC     cmdtkn        cabeq     *on           endsc5
650cA*
650cA*  Everything went fine so onto the next screen.
650cA*
650cAC                   eval      refrsh = *on
650cAc                   eval      nxtscr = 'EOJ'
650cAC*                  exsr      scr01i
WSTbAc                   eval      savewstfifo = 0
WSTbAc                   eval      wstfifo = 0
650cA*
650cAC     endsc5        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  SCCNL-  Cancel Warning Window
650cA*
650cAC     scCnl         begsr
650cA*
650cA*  Test for F12 - Previous
650cA*
650cA /free
650cA   if *inkl;
650cA     nxtscr = '04 ';
650cA     leavesr;
650cA   endif;
650cA
650cA /end-free
650cA*
650cA*  Test for other command keys
650cA*
650cAC                   exsr      zzcmdcnl
650cAC     cmdtkn        cabeq     *on           endsccnl
650cA*
650cA*  Some other key pressed.
650cA*
650cA*     Check input and write/update record.
650cA*
650cAC                   exsr      zzupdcnl
650cAc                   if        *inkj
650cAC                   eval      nxtscr = 'EOJ'
650cAc                   endif
650cAC     endsccnl      endsr
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
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
510 A*
510 A* Get client id.
510 A*
510 AC                   call      'GETCLIENT'
510 AC                   parm                    client
CSP A*
720bMC                   if        not %open(ordc3)
720bMC                   open      ordc3
720bMC                   endif
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP A*
CSP AC                   if        not %open(label)
CSP AC                   open      label
CSP AC                   endif
CSP A*
CSP AC                   if        not %open(ordd2)
CSP AC                   open      ordd2
CSP AC                   endif
CSP A*
CSP AC                   if        not %open(ordh)
CSP AC                   open      ordh
CSP AC                   endif
CSP A*
CSP AC                   if        not %open(ordh5)
CSP AC                   open      ordh5
CSP AC                   endif
CSP A*
CSP AC                   if        not %open(rtehed)
CSP AC                   open      rtehed
CSP AC                   endif
CSP A*
CSP AC                   endif
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
500eA*----------------------------------------------------------------
500eA*  clr$item  Clear $item data structure fields
500eA*----------------------------------------------------------------
500eA
500eAC     clr$item      begsr
500e C**                 eval      savever# = $itver#
500e C                   clear                   $item
500e C**                 eval      $itver# = savever#
500e C                   endsr
650cA*----------------------------------------------------------------
650cA*  GETITEM      Get item info from driitem
650cA*----------------------------------------------------------------
650cA /free
650cA   begsr getitem;
650cA     exsr clr$item;
650cA
650cA     $itWhse = $pwhse;
650cA     $ititem = $pitem;
650cA
650cA     $dricommand = '*ITEM';
650cA     $drisubcmd  = '%GETALL';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     zmflag  = *off;
650cA     exsr zzzdricop;
650cA     if error = *on;
650cA       *in75 = *on;
650cA     endif;
650cA   endsr;
650cA /end-free
720dA*----------------------------------------------------------------
720dA*  GETCITEM      Get Corresponding item info from driitem
720dA*----------------------------------------------------------------
720dA /free
720dA   begsr getcitem;
720dA     exsr clr$item;
720dA
720dA     $itWhse = $pwhse;
720dA     $ititem = w1citm;
720dA
720dA     $dricommand = '*ITEM';
720dA     $drisubcmd  = '%GETALL';
720dA     $drisys2upd = 'D';
720dA     chk4err = *on;
720dA     zmflag  = *off;
720dA     exsr zzzdricop;
720dA     if error = *on;
720dA       *in75 = *on;
720dA     endif;
720dA   endsr;
720dA /end-free
720aA*----------------------------------------------------------------
720aA*  GETORDC      Get CW total from Orig Order
720aA*----------------------------------------------------------------
720aA /free
720aA   begsr getordc;
720aA
720cD       // ordcwtot = 0;
720aA    setll ($pwhse: woord: od_oditem: od_odseq)
720aA           ordc3;
720aA
720aA    dow forevr = forevr;
720aA
720aA      reade ($pwhse: woord: od_oditem: od_odseq)
720aA             ordc3;
720aA
720aA      if %eof(ordc3);
720aA        leave;
720aA      endif;
720aA
720aA      ordcwtot += occwgt;
720aA
720aA    enddo;
720aA
720aA   endsr;
720aA /end-free
     *----------------------------------------------------------------
416k *
416kA*                                                                   DOC
416kAC     gtoj$         begsr
416kAC                   eval      g$date = g$date
416kA* SPLIT DATE INTO MONTH, DAY, YEAR FIELDS                           DOC
416kAC                   if        dtfrmt = 1
416kAC                   movel     g$date        g$yy
416kAC                   move      g$date        work4
416kAC                   movel     work4         g$mm
416kAC                   move      work4         g$dd
416kAC                   else
416kAC                   movel     g$date        g$mm
416kAC                   move      g$date        work4
416kAC                   movel     work4         g$dd
416kAC                   move      work4         g$yy
416kAC                   endif
416kA* CREATE 4 DIGIT YEAR                                               DOC
416kAC                   move      g$yy          g$yyyy
416kAC                   if        g$yy >= 60
416kAC                   movel     '19'          g$yyyy
416kAC                   else
416kAC                   movel     '20'          g$yyyy
416kAC                   endif
416kAC                   eval      g$jd = 0
416kAC                   eval      g$mmwk = g$mm - 3
416kAC                   eval      gmwksv = g$mmwk
416kAC                   if        g$mmwk < 0
416kAC                   add       12            g$mmwk
416kAC                   endif
416kAC                   if        gmwksv <> 0
416kAC                   eval(h)   g$jd = g$mmwk * 30.6
416kAC                   endif
416kAC                   add       g$dd          g$jd
416kAC     g$yyyy        sub       1900          g$yywk
416kAC                   if        g$yywk <> 0
416kAC                   if        gmwksv < 0
416kAC                   eval      g$yywk = g$yywk - 1
416kAC                   endif
416kAC                   endif
416kAC                   eval      g$jyd = g$yywk * 365.25
416kAC                   add       g$jyd         g$jd
416kAC     g$jd          div       7             g$wk7
416kAC                   mvr                     g$dw
416kAC                   endsr
     *----------------------------------------------------------------
416k *
416kA*                                                                   DOC
416kAC     jtog$         begsr
416kAC     j$jd          div       365.25        j$yywk
510cDC**   j$jd          div       365.25        j$tst
510cMC     j$jd          div       365.25        j$tsthld
510cAC                   move      j$tsthld      j$tst
416kAC                   if        j$tst = 0
416kAC                   eval      j$yywk = j$yywk - 1
416kAC                   endif
416kAC                   eval      j$yd = j$yywk * 365.25
416kAC                   eval      j$yd = j$jd - j$yd
416kAC                   if        j$yd > 306
416kAC                   add       1             j$yywk
416kAC                   endif
416kAC                   eval      j$x = 0
416kAC                   dou       j$yd <= j$md
416kAC                   add       1             j$x
416kAC     j$x           mult(h)   30.6          j$md
416kAC                   enddo
416kAC                   eval      j$x = j$x - 1
416kAC     j$x           mult(h)   30.6          j$md
416kAC     j$yd          sub       j$md          j$dd
416kAC     j$x           add       3             j$mm
416kAC                   if        j$mm > 12
416kAC                   eval      j$mm = j$mm - 12
416kAC                   endif
416kAC     j$yywk        add       1900          j$yyyy
416kAC                   if        dtfrmt = 1
416kAC                   move      j$yyyy        work2
416kAC                   movel     j$mm          work4
416kAC                   move      j$dd          work4
416kAC                   movel     work2         j$date
416kAC                   move      work4         j$date
416kAC                   else
416kAC                   move      j$yyyy        work2
416kAC                   movel     j$mm          work4
416kAC                   move      j$dd          work4
416kAC                   move      work2         j$date
416kAC                   movel     work4         j$date
416kAC                   endif
416kAC                   endsr
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
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
500bA *    DRI0001  Local system caused error
     *----------------------------------------------------------------

500bAC     zm0001        begsr
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
500bAC                   endsr


     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0109  Value can not be less than 0.
     *
     C     zm0109        begsr
     C                   eval      #msgid = 'PIR0109'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0110  Value must be > 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
650cA*----------------------------------------------------------------
650cA*   PIR0202  Code already exists.
650cA*
650cAC     zm02          begsr
650cAC                   eval      #msgid = 'PIR0202'
650cAC                   eval      #msgtp = '*DIAG  '
650cAC                   movea     errmsg        $md(1)
650cAC                   exsr      zmpmsg
650cAC                   endsr
720a *----------------------------------------------------------------
720a *   PT13021  Warning: Entered catch weight not within +/- range.
720a *
720aAC     zm13021       begsr
720aAC                   eval      #msgid = 'PT13021'
720aAC                   eval      #msgtp = '*DIAG  '
720aAC                   movea     errmsg        $md
720aAC                   exsr      zmpmsg
720aAC                   endsr
416b *----------------------------------------------------------------
416b *   PIR0204  Can only enter one value.
416b *
416b C     zm0204        begsr
416b C                   eval      #msgid = 'PIR0204'
416b C                   eval      #msgtp = '*DIAG  '
416b C                   movea     errmsg        $md
416b C                   exsr      zmpmsg
416b C                   endsr
416kA*----------------------------------------------------------------
416kA*    PIR1010  Date must be <OR= today's date.
416kA*
416kAC     zm1010        begsr
416kAC                   eval      #msgid = 'PIR1010'
416kAC                   eval      #msgtp = '*DIAG  '
416kAC                   movea     errmsg        $md
416kAC                   exsr      zmpmsg
416kAC                   endsr
640jA*----------------------------------------------------------------
640jA*    ZM13250  Item not date sensitive.
640jA*
640jAC     zm13250       begsr
640jAC                   eval      #msgid = 'PO13250'
640jAC                   eval      #msgtp = '*DIAG  '
640jAC                   movea     errmsg        $md
640jAC                   exsr      zmpmsg
640jAC                   endsr
417dA*----------------------------------------------------------------
417dA*    PIR4002  Product expired.
417dA*
417dAC     zm4002        begsr
417dAC                   eval      #msgid = 'PIR4002'
417dAC                   eval      #msgtp = '*DIAG  '
417dAC                   movea     errmsg        $md
417dAC                   exsr      zmpmsg
417dAC                   endsr
650eA*----------------------------------------------------------------
650eA*   PO23203  PTI doesn't match calculated PTI.
650eA*
650eAC     zm3203        begsr
650eAC                   eval      #msgid = 'PO23203'
650eAC                   eval      #msgtp = '*DIAG  '
650eAC                   movea     errmsg        $md(1)
650eAC                   exsr      zmpmsg
650eAC                   endsr
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
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1008  Date is required.
     *
     C     zm1008        begsr
     C                   eval      #msgid = 'PIR1008'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1009  Date must be > today's date.
     *
     C     zm1009        begsr
     C                   eval      #msgid = 'PIR1009'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
416j *    OR12202  Mispick item cannot be ordered item.
     *
416j C     zm1202        begsr
416j C                   eval      #msgid = 'OR12202'
416j C                   eval      #msgtp = '*DIAG  '
416j C                   movea     errmsg        $md
416j C                   exsr      zmpmsg
416j C                   endsr
JORb *----------------------------------------------------------------
JORb *    OR12203  Mispick item must be entered.
JORb *
JORb C     zm1203        begsr
JORb C                   eval      #msgid = 'OR12203'
JORb C                   eval      #msgtp = '*DIAG  '
JORb C                   movea     errmsg        $md
JORb C                   exsr      zmpmsg
JORb C                   endsr
510aA*----------------------------------------------------------------
510aA*    OR11202  Invalid value entered
510aA*
510aAC     zm11202       begsr
510aAC                   eval      #msgid = 'OR11202'
510aAC                   eval      #msgtp = '*DIAG  '
510aAC                   movea     errmsg        $md
510aAC                   exsr      zmpmsg
510aAC                   endsr
510aA*----------------------------------------------------------------
510aA*    PIR0203  Delivery number required
510aA*
510aAC     zm0203        begsr
510aAC                   eval      #msgid = 'PIR0203'
510aAC                   eval      #msgtp = '*DIAG  '
510aAC                   movea     errmsg        $md
510aAC                   exsr      zmpmsg
510aAC                   endsr
     *----------------------------------------------------------------
     *    PO15021  P.O. number must be entered.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PO15021'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
416bA*----------------------------------------------------------------
416bA*   PO20029  UPC not on file.
416bA*
416bAC     zm29          begsr
416bAC                   eval      #msgid = 'PO20029'
416bAC                   eval      #msgtp = '*DIAG  '
416bAC                   movea     errmsg        $md(1)
416bAC                   exsr      zmpmsg
416bAC                   endsr
650cA*----------------------------------------------------------------
650cA*   PO23701  Mixed Lots on License.
650cA*
650cAC     zm3701        begsr
650cAC                   eval      #msgid = 'PO23701'
650cAC                   eval      #msgtp = '*DIAG  '
650cAC                   movea     errmsg        $md(1)
650cAC                   exsr      zmpmsg
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*   PO23702  Mixed Expiration Dates on License
650cA*
650cAC     zm3702        begsr
650cAC                   eval      #msgid = 'PO23702'
650cAC                   eval      #msgtp = '*DIAG  '
650cAC                   movea     errmsg        $md(1)
650cAC                   exsr      zmpmsg
650cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
640i C*   DFCHK Flags are used to force F20 for each test
640i C*   Values: Flag = 0 Do check.
640i C*           Flag = 1 Check was done, ok.
640i C*           Flag = 2 Warning condition.
640i C*
     C                   eval      error = *off
650bAc                   exsr      zzrcvrtncheck
416lAC                   eval      wscitm = *blanks
650iA*
650iA*  Verify quantity is entered.
650iA*
650iAC                   if        w1qt01 = 0
650iAC                             and w1qt02 = 0
650iAC                             and w1qt03 = 0
650iAC                   eval      error = *on
650iAC                   eval      *in24 = *on
650iAC                   eval      errmsg = *blanks
650iAC                   eval      errmsg = desc(2)
650iAC                   exsr      zm0110
650iAC                   endif
     *
     *  Verify normal quantity.
     *
     C                   if        w1qt01 < 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
720dA*
720dA*  Verify normal quantity.
720dA*
720dAC                   if        w1qm01 < 0
720dAC                   eval      error = *on
720dAC                   eval      *in44 = *on
720dAC                   eval      errmsg = *blanks
720dAC                   movel     desc(1)       erfld
720dAC                   exsr      zm0109
720dAC                   endif
     *
     *  Verify breakdown 1 quantity.
     *
     C                   if        w1qt02 < 0
     C                   eval      error = *on
     C                   eval      *in31 = *on
     C                   eval      *in11 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
720dA*
720dA*  Verify breakdown 1 quantity.
720dA*
720dAC                   if        w1qm02 < 0
720dAC                   eval      error = *on
720dAC                   eval      *in46 = *on
720dAC                   eval      errmsg = *blanks
720dAC                   movel     desc(1)       erfld
720dAC                   exsr      zm0109
720dAC                   endif
     *
     *  Verify breakdown 2 quantity.
     *
     C                   if        w1qt03 < 0
     C                   eval      error = *on
     C                   eval      *in30 = *on
     C                   eval      *in10 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   exsr      zm0109
     C                   endif
720dA*
720dA*  Verify breakdown 2 quantity.
720dA*
720dAC                   if        w1qM03 < 0
720dAC                   eval      error = *on
720dAC                   eval      *in48 = *on
720dAC                   eval      errmsg = *blanks
720dAC                   movel     desc(1)       erfld
720dAC                   exsr      zm0109
720dAC                   endif
640gA*
640gA*  Verify return quantity does not exceed qty picked
640gA*
640gA*
640gA*   Need to get internal bfc order in order to check ordd file
720aA*     Chef's had multi CORD#s in ORDH, find newest ord
640gA*
640gAC                   if        not %open(ordh5)
640gAC                   open      ordh5
640gAC                   endif
720aM **   oh5key    **  chain     ordh5
640gAc                   eval      woord = 0
720aAc                   eval      hlddt = 0
720aAC     oh5key        setll     ordh5
DRYcAC                   eval      x = 0
DRYcAC                   eval      totqt1 = 0
DRYcAC                   eval      totqt2 = 0
DRYc  *    Clear ARRAY to load ALL CORD hits when returning by item
DRYcAC                   clear                   ORDnum
DRYcAC                   clear                   ORDqt1
DRYcAC                   clear                   ORDqt2
720aAC                   dow       forevr = forevr
720aAC     oh5key        reade     ordh5                                  74
720aAc                   if        not *in74
720aAc                   if        hlddt < oh5ohsdte
720aAc                   eval      hlddt = oh5ohsdte
640gAc                   eval      woord = oh5ohord
DRYcAc                   eval      wiord = oh5ohord
DRYcA*   Verify item is on order, yes then hold that ohord
DRYcA*   If not, look for next ohord with same cust#(cord)
DRYcA*     Will same item ever be on both orders returning full qty???
DRYcA*     keep looking at this IF
DRYcAC     orddkey1      setll     ordd3
DRYcAC     orddkey1      reade     ordd3                                  79
DRYcAC                   if        not *in79
     *            then build array; keep going to read ALL records
DRYcAC                   eval      x = x + 1
DRYcAC                   eval      totqt1 = od3_odqpk1
DRYcAC                   eval      totqt2 = od3_odqpk2
DRYcAC                   z-add     od3_odord     ORDnum(x)
DRYcAC                   z-add     od3_odqpk1    ORDqt1(x)
DRYcAC                   z-add     od3_odqpk2    ORDqt2(x)
DRYcAc                   endif

720aAc                   endif
640gAc                   else
720aAC                   leave
640gAc                   endif
720aAc                   enddo
640gA*
640gA*   Verify item is on order.
640gA*
DRYcAC                   eval      x = 1
DRYcAC                   eval      woord = ORDnum(x)
640gAC     orddkey       setll     ordd
640gAC                   move      *off          stop
640gAC                   move      *off          good1
650cAC                   eval      wkqor1 = *zeros
650cAC                   eval      wkqor2 = *zeros
650cAC                   eval      wkqor3 = *zeros
720c *
720c *   Moved out of getordc and before DoU before getordc
720c *                  zero out just once while calculating
720cMC                   eval      ordcwtot = 0

640gAC                   dou       stop = *on
640gAC     orddkey       reade     ordd                                   79
640gAC                   if        *in79
DRYcAC                   eval      x = x + 1
DRYcAC                   if        ORDnum(x) > 0
DRYcAC                   eval      woord = ORDnum(x)
DRYcAC                   eval      *in79 = '0'
DRYcAC     orddkey       setll     ordd
DRYcAC                   else
640gAC                   move      *on           stop
DRYcAC                   endif
640gAC                   else
640gAC                   if        kyitem = od_oditem
740hAc                             or $pitem <> kyitem and
740hAc                                $pitem = od_oditem
640gA*
640gA* Load Qty Shipped/Picked from original order for compare to Rtn
640gA*
640hDC**                 eval      wkQor1 = od_odQpk1
640hDC**                 eval      wkQor2 = od_odQpk2
640hDC**                 eval      wkQor3 = od_odQpk3
640hMC                   eval      wkQor1 = wkQor1 + od_odQpk1
640hMC                   eval      wkQor2 = wkQor2 + od_odQpk2
640hMC                   eval      wkQor3 = wkQor3 + od_odQpk3
720aA*
720aA* New, find Orig Order CW and don't exceed it on Returns
720aA*                                   OrdCWtot
720aAC                   exsr      getordc
720aA*
640gA*
640gA*
640gAC                   move      *on           good1
640hDC**                 leave
640gAC                   endif
640gAC                   endif
640gAC                   enddo
CSPcA*
CSPcA*   Need to check linked items if Item entered isn't on the order
CSPcA*
CSPcAC                   if        client = CoastalSunbelt
CSPcAc                             and good1 = *off
CSPcA * build an item from base and breakdown uom
CSPcAc                   if        itum2 <> ' '
CSPcAc                   eval      linkitem = ' '
CSPcAc                   eval      wkqor1 = 0
CSPcAc                   eval      wkqor2 = 0
CSPcAc                   eval      wkqor3 = 0
CSPcAc                   eval      linkitem = %trim(ititem) + %trim(itum2)
CSPcA * does this item exist in the link file
CSPcAc     linkkey       chain     itemlnk1
CSPcAc                   if        %found(itemlnk1)
CSPcA*
CSPcA*   Verify item is on order.
CSPcA*
CSPcAC     orddkey       setll     ordd
CSPcAC                   move      *off          stop
CSPcAC                   move      *off          good1
CSPcAC                   dou       stop = *on
CSPcAC     orddkey       reade     ordd                                   79
CSPcAC                   if        *in79
CSPcAC                   move      *on           stop
CSPcAC                   else
CSPcAC                   if        linkitem =  od_oditem
CSPcA*
CSPcA* Load Qty Shipped/Picked from original order for compare to Rtn
CSPcA*
CSPdDC**                 eval      wkQor2 = od_odQpk1
CSPdMC                   eval      wkQor2 = wkQor2 + od_odQpk1
CSPcA*
CSPcA*
CSPcAC                   move      *on           good1
CSPdDC**                 leave
CSPcAC                   endif
CSPcAC                   endif
CSPcAC                   enddo
CSPcAC                   endif
CSPcAC                   endif
CSPcAc                   if        itum3 <> ' '
CSPcAc                   eval      linkitem = ' '
CSPcAc                   eval      linkitem = %trim(ititem) + %trim(itum3)
CSPcA * does this item exist in the link file
CSPcAc     linkkey       chain     itemlnk1
CSPcAc                   if        %found(itemlnk1)
CSPcA*
CSPcA*   Verify item is on order.
CSPcA*
CSPcAC     orddkey       setll     ordd
CSPcAC                   move      *off          stop
CSPcAC*                  move      *off          good1
CSPcAC                   dou       stop = *on
CSPcAC     orddkey       reade     ordd                                   79
CSPcAC                   if        *in79
CSPcAC                   move      *on           stop
CSPcAC                   else
CSPcAC                   if        linkitem = od_oditem
CSPcA*
CSPcA* Load Qty Shipped/Picked from original order for compare to Rtn
CSPcA*
CSPdDC**                 eval      wkQor3 = od_odqpk1
CSPdMC                   eval      wkQor3 = wkQor3 + od_odqpk1
CSPcA*
CSPcA*
CSPcAC                   move      *on           good1
CSPdDC**                 leave
CSPcAC                   endif
CSPcAC                   endif
CSPcAC                   enddo
CSPcAC                   endif
CSPcAC                   endif
CSPcAC                   endif
640iA*  Set override to check quantity compare.
640i C                   if        dfchk  = '0' and
640i C                             ovrrid = *on
640i C                   eval      ovrrid = *off
640i C                   endif
640i C
640i C                   if        dfchk  = '2' and
640i C                             ovrrid = *on
640i C                   eval      dfchk  = '1'
640i C                   endif
640i C
640gA*  Continue to check only if item is found on order
640gac                   if        good1 = *on
CSPcAC                             or client = CoastalSunbelt
PCKfAc                             or client = Pack730
640gA*  Make sure if item already returned that quantities of
640gA*  current and previous returns is not > original Ord Picked
640gA*  Make sure item is not already returned.
640gA*
640gAC                   eval      wkoQty1 = *zeros
640gAC                   eval      wkoQty2 = *zeros
640gAC                   eval      wkoQty3 = *zeros
720aAC                   eval      wkcwrtn = *zeros
720aAC                   eval      wkcwleft = *zeros
640gAC     rnkeya        setll     orrtn
640gAC                   dou       %eof(orrtn)
640gAC     rnkeya        reade(n)  orrtn
640gAC                   if        not %eof(orrtn)
640gAC                   eval      wkoQty1 = wkoQty1 + orQty1
640gAC                   eval      wkoQty2 = wkoQty2 + orQty2
640gAC                   eval      wkoQty3 = wkoQty3 + orQty3
720aAC                   eval      wkcwrtn = wkcwrtn + orcwtr
640gAC                   endif
640gAC                   enddo
720aA*
720aA* calc ORDC CW - ORRTN CW for Remaining CW to Return
720aMC                   eval      wkcwleft = ordcwtot - wkcwrtn
640gA*
640gA* need to convert qty to the breakdown lowest uom being returned
640gAc                   eval      wkretqty = 0
640gAc                   eval      wkpretqty = 0
640gAc                   eval      wkpickqty = 0
640gAc                   select
640gA * breakdown2 qty - conversion
640gAc                   when      itumq3 > 0
640gA * all returns need to be at this uom in order to check qty's
640gAc                   if        w1qt01 > 0
640gAc                   eval      wkretqty = wkretqty +
640gAc                             ((w1qt01 * itumq2) * itumq3)
640gAc                   endif
640gAc                   if        w1qt02 > 0
640gAc                   eval      wkretqty = wkretqty +
640gAc                                        (w1qt02 * itumq3)
640gAc                   endif
640gAc                   eval      wkretqty = wkretqty + w1qt03
640gA * now convert previous returns
640gAc                   if        wkoqty1 > 0
640gAc                   eval      wkpretqty = wkpretqty +
640gAc                                         ((wkoqty1 * itumq2) * itumq3)
640gAc                   endif
640gAc                   if        wkoqty2 > 0
640gAc                   eval      wkpretqty = wkpretqty +
640gAc                                        (wkoqty2 * itumq3)
640gAc                   endif
640gAc                   eval      wkpretqty = wkpretqty + wkoqty3
640gA * now convert picked qty
640gAc                   if        wkqor1  > 0
640gAc                   eval      wkpickqty = wkpickqty +
640gAc                                         ((wkqor1 * itumq2) * itumq3)
640gAc                   endif
640gAc                   if        wkqor2  > 0
640gAc                   eval      wkpickqty = wkpickqty +
640gAc                                        (wkqor2 * itumq3)
640gAc                   endif
640gAc                   eval      wkpickqty = wkpickqty + wkqor3
640gA
640gA * breakdown1 qty conversion
640gAc                   when      itumq2 > 0
640gA * all returns need to be at this uom in order to check qty's
640gAc                   if        w1qt01 > 0
640gAc                   eval      wkretqty = wkretqty + (w1qt01 * itumq2)
640gAc                   endif
640gAc                   eval      wkretqty = wkretqty + w1qt02
640gA * now convert previous returns
640gAc                   if        wkoqty1 > 0
640gAc                   eval      wkpretqty = wkpretqty + (wkoqty1 * itumq2)
640gAc                   endif
640gAc                   eval      wkpretqty = wkpretqty + wkoqty2
640gA * now convert picked qty
640gAc                   if        wkqor1  > 0
640gAc                   eval      wkpickqty = wkpickqty + (wkqor1  * itumq2)
640gAc                   endif
640gAc                   eval      wkpickqty = wkpickqty + wkqor2
640gA * Normal uom   conversion
640gAc                   other
640gA * all returns need to be at this uom in order to check qty's
640gAc                   if        w1qt01 > 0
640gAc                   eval      wkretqty = w1qt01
640gAc                   endif
640gA * now convert previous returns
640gAc                   if        wkoqty1 > 0
640gAc                   eval      wkpretqty = wkoqty1
640gAc                   endif
640gA * now convert picked qty
640gAc                   if        wkqor1  > 0
640gAc                   eval      wkpickqty = wkqor1
640gAc                   endif
640gA
640gAc                   endsl
640gA
640iAC                   select
CSPbAC                   when      client = CoastalSunbelt
PCKfAc                             or client = PACK730
640gAC                   if        (wkretqty + wkpretqty) > wkpickqty
640gAC                   move      *on           error
640gAC                   endif
CSPbAC                   other
640iAC                   if        dfchk <> '1'
640iAC                   eval      dfchk = '1'
640iAC                   if        (wkretqty + wkpretqty) > wkpickqty
740eDC*                            or w1cwtr > wkcwleft
740eMC                             or w1cwtr > wkcwleft and $itcwgt='Y'
640iAC                   move      *on           error
640iAC                   eval      dfchk = '2'
640iAC                   eval      warn = *on
640iAC                   endif
640iAC                   endif
640iAC                   endsl
640gA*
640gAC                   if        error = *on
640gAC                   eval      errmsg = *blanks
720aAC                   if        (wkretqty + wkpretqty) > wkpickqty
640gAc                   if        w1qt01 > 0
640gAC                   eval      *in24 = *on
640gAC                   eval      *in04 = *on
640gAc                   endif
640gAc                   if        w1qt02 > 0
640gAC                   eval      *in31 = *on
640gAC                   eval      *in11 = *on
640gAc                   endif
640gAc                   if        w1qt03 > 0
640gAC                   eval      *in30 = *on
640gAC                   eval      *in10 = *on
640gAc                   endif
640gA*
640gAC                   eval      errmsg = desc(11)
720aAC                   else
720aA ** else means weight error
720aAC                   eval      errmsg = desc(17)
720aAC                   endif
640gA*
640gAC                   exsr      zm0105
640iAC                   goto      endck1
640gAC                   endif
640gAC                   endif
     *
     *  Verify # of Pallets.
     *
     C                   if        w1plts <= 0
     C                   eval      error = *on
     C                   eval      *in36 = *on
     C                   eval      *in16 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(6)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
415aA*
415aA*  # of Pallets must = 1 if Label was scanned.
415aA*
415aAC                   if        $plbl# > 0  and
415aAC                             w1plts <> 1
415aAC                   eval      error = *on
415aAC                   eval      *in36 = *on
415aAC                   eval      *in16 = *on
415aAC                   eval      errmsg = *blanks
415aAC                   movel     desc(6)       erfld
415aAC                   movel     '1'           erfrom
415aAC                   movel     '1'           erto
415aAC                   exsr      zm0112
415aAC                   endif
720hA*
720hA*  # of Pallets must = 1 if multiple UOM are being returned
720hA*
720hAC                   if        w1qt01 > 0  and
720hAc                             w1qt02 > 0  and
720hAC                             w1plts <> 1  or
720hAC                             w1qt01 > 0  and
720hAc                             w1qt03 > 0  and
720hAC                             w1plts <> 1  or
720hAC                             w1qt02 > 0  and
720hAc                             w1qt03 > 0  and
720hAC                             w1plts <> 1
720hAC                   eval      error = *on
720hAC                   eval      *in24 = *on
720hAC                   eval      *in31 = *on
720hAC                   eval      *in30 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   movel     desc(19)      errmsg
720hAC                   exsr      zm0105
720hAC                   endif
415b *
415b *   Verify catchweight.
415b *
415bAC                   if        not *in95  and
415bAC                             quick = *off  and
415bAC                             w1cwtr = 0
WSTaAC                             and client <> westside
415bAC                   eval      error = *on
415bAC                   eval      *in33 = *on
415bAC                   eval      errmsg = *blanks
415bAC                   eval      errmsg = desc(5)
415bAC                   exsr      zm0110
415bAC                   endif
YHAa *   Catchweight required for YHata
YHAaAC                   if        not *in95  and
YHAaAC                             client = yhata and
YHAaAC                             w1cwtr = 0
YHAaAC                   eval      error = *on
YHAaAC                   eval      *in33 = *on
YHAaAC                   eval      errmsg = *blanks
YHAaAC                   eval      errmsg = desc(5)
YHAaAC                   exsr      zm0110
YHAaAC                   endif
GLPa *   Catchweight required for Greenleaf Produce
GLPaAC                   if        not *in95  and
GLPaAC                             client = Greenleaf and
GLPaAC                             w1cwtr = 0
GLPaAC                   eval      error = *on
GLPaAC                   eval      *in33 = *on
GLPaAC                   eval      errmsg = *blanks
GLPaAC                   eval      errmsg = desc(5)
GLPaAC                   exsr      zm0110
GLPaAC                   endif
720a *
720a *   Verify catchweight RANGE (F20 - allow override)
720a *
720aAC                   if        not *in95  and
720aAC                             quick = *off and
720aAC                             *inku = *off and
740ddc                             $ifsltmth <> '2' and
720aAC                             w1cwtr > 0
740dAc                             or $ifsltmth = '2' and
740fAc                             *in95 = *off and
740dAc                             $bcai99sent = *on  and
740dAC                             cwtck <> '1'  and
740dAC                             *inku = *off
720a
720aAC                   eval      lwvar = 0
720aAC                   eval      hivar = 0
720aAC                   eval      lwrng = 0
720aAC                   eval      hirng = 0
720aAC                   eval      exwgt = 0
720aAC                   eval      ilvar = 0
720aAC                   eval      ihvar = 0
720aAC                   eval      ilrng = 0
720aAC                   eval      ihrng = 0
720aAC                   eval      prg1c = *zeros
720aAC                   eval      prg2c = *zeros
720aAC                   eval      imrg1c = 0
720aAC                   eval      imrg2c = 0
720aA**   Use itswgt instead of lbuwgt
720aAC     w1qt01        mult      itswgt        exwgt

720aA**   NEW-add to exwgt if w1qt02 (break qty exist)
720aAC                   if        w1qt02 > 0
720aAC     w1qt02        div       itumq2        w1qt01x
720aAC     w1qt01x       mult      itswgt        exwgt2
720aAC                   eval      exwgt = exwgt + exwgt2
720aAC                   endif
720a **   Iniz. flag used to skip variance check if = *ON.
720aAC                   eval      lvskp = *off
720aAC                   eval      hvskp = *off
720a **   Use item variance % if it exists
720aAC     imkey         chain     itemmsc                            79
720aAC                   if        not *in79
720a *
720aAC                   if        imrg1c <> 0
720aAC     imrg1c        div       100           prg1c
720aAC                   if        imrg1c = 99
720aAC                   eval      lvskp = *on
720aAC                   endif
720aAC                   endif
720a *
720aAC                   if        imrg2c <> 0
720aAC     imrg2c        div       100           prg2c
720aAC                   if        imrg2c = 99
720aAC                   eval      hvskp = *on
720aAC                   endif
720aAC                   endif
720aAC                   endif
720a *  NEW-skip if now range in PirItem
720aAC*                  if        imrg1c = 0
720aAC*                            or imrg2c = 0
720aAC*                  goto      skipcw
720aAC*                  endif
720a *
720aAC                   if        prg1c = 0
720aAC     oprg1c        div       100           prg1c
720aAC                   endif
720aAC                   if        prg2c = 0
720aAC     oprg2c        div       100           prg2c
720aAC                   endif
720a *
720aAC                   if        prg1c > 0
720aAC     exwgt         mult      prg1c         lwvar
720aAC                   eval      ilvar = itswgt * prg1c
720aAC                   endif
720aAC                   eval      lwrng = exwgt - lwvar
720aAC                   eval      ilrng = itswgt - ilvar
720aAC                   if        prg2c > 0
720aAC     exwgt         mult      prg2c         hivar
720aAC                   eval      ihvar = itswgt * prg2c
720aAC                   endif
720aAC     exwgt         add       hivar         hirng
720aAC     itswgt        add       ihvar         ihrng
720a
720aAC                   if        w1cwtr < lwrng
720aAC                             or w1cwtr > hirng
720aAC                   eval      error = *on
720aAC                   eval      warn = *on
720aAC                   eval      cwtck = '2'
740dAc                   if        $bcai99sent = '1'
740dAc                   eval      *in33 = *on
740dAc                   endif
720aAC                   eval      *in21 = *on
720aAC                   eval      *in01 = *on
720aAC                   eval      errmsg = *blanks
720aD **              ** eval      errmsg = desc(5)
720aD **              ** eval      ertcwt = taddw
720aMC                   eval      ertcwt = w1cwtr
720aAC                   eval      erlrng = lwrng
720aAC                   if        hvskp = *on
720aAC                   eval      erhrng = 0
720aAC                   else
720aAC                   eval      erhrng = hirng
720aAC                   endif
720aAC     prg1c         mult      100           errg1c
720aAC     prg2c         mult      100           errg2c
720aAC                   eval      erexwt = itswgt
720aAC                   exsr      zm13021
720aAC                   endif
720aAC                   endif
720aAC     skipcw        tag
520c *
520c *  Return code must be entered.
520cAC                   if        w1code = *blanks
520c C                   eval      error = *on
520c C                   eval      *in22 = *on
520c C                   eval      *in02 = *on
520c C                   eval      errmsg = *blanks
520cAC                   eval      errmsg = 'Return code     '
520c C                   exsr      zm0203
520cAC                   endif
520c *
     *
     *  Verify return code.
     *
416d C                   eval      woinvf = *blanks
415bAC                   if        quick = *off  or
415bMC                             w1code <> *blanks
415bD*R         W1CODE    IFNE *BLANKS
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
416l **                   MOVE *ON       *IN26
416l **                   MOVE *ON       *IN06
416lMC                   eval      *in22 = *on
416lMC                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
520aMC                   eval      *in22 = *on
520aMC                   eval      *in02 = *on
520aDC*                  eval      *in26 = *on
520aDC*                  eval      *in06 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
416d C                   else
416dAC     w1code        chain     rtncode                            79
416dAC                   if        not *in79
416dAC                   eval      woinvf = rninvf
CSPbA*
CSPbAC                   if        client = CoastalSunbelt
CSPbAC                             and %subst(rndesc:26:5) <> *blanks
CSPbAC                   eval      w1dcde = %subst(rndesc:26:5)
CSPbAC                   endif
CSPbA*
416d C                   endif
     C                   endif
     C                   endif
     C                   endif
     *
520c *
520c *  Disposition must be entered.
520cAC                   if        w1dcde = *blanks
520c C                   eval      error = *on
520c C                   eval      *in27 = *on
520c C                   eval      *in07 = *on
520c C                   eval      errmsg = *blanks
520cAC                   eval      errmsg = 'Disposition code'
520c C                   exsr      zm0203
520cAC                   endif
520c *
416b *
416b *  Verify disposition code.
416b *
416cAC                   if        quick = *off  or
416cMC                             w1dcde <> *blanks
416b C                   eval      $lcmd = '*VERIFY '
416b C                   eval      $ldcde = w1dcde
416b C                   call      'RD900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*ERROR  '
416b C                   eval      error = *on
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   movel     $lerm         errmsg
416b C                   exsr      zm0105
416b C                   else
416b C                   if        $lrtn = '*PGMQ   '
416b C                   eval      error = *on
416b C                   eval      *in27 = *on
416b C                   eval      *in07 = *on
416b C                   eval      #msgk = $lmsg
416b C                   exsr      zmqmsg
416b C                   endif
416b C                   endif
416c C                   endif
PCKfA*  For Packers (pckorg=2000) must enter reason code 99 if the
PCKfA*  disposition code is 3.
PCKfA*
PCKfA /free
PCKfA   if client = pack730;
PCKfA     select;
PCKfA       when pckorg =2000;
PCKfA         if w1dcde='3' and w1code<>'99';
PCKfA           error = *On;
PCKfA           *in22 = *on;
PCKfA           *in02 = *on;
PCKfA           errmsg = *blanks;
PCKfA           errmsg = desc(20);
PCKfA           exsr zm0105;
PCKfA         endif;
PCKfA         if w1dcde<>'3' and w1code='99';
PCKfA           error = *On;
PCKfA           *in22 = *on;
PCKfA           *in02 = *on;
PCKfA           errmsg = *blanks;
PCKfA           errmsg = desc(21);
PCKfA           exsr zm0105;
PCKfA         endif;
PCKfA     endsl;
PCKfA   endif;
PCKfA /end-free
     *
750ca*  Pallet license
     *
750cAC                   if        *in56 and PLTLCNS <> ' '
750cAc                   if        %subst(pltlcns:1:6) <> 'RTNPLT'
750cAC                   move      *on           error
750cAC                   eval      *in57 = *on
750cAC                   eval      errmsg = *blanks
750cAC                   eval      errmsg = 'Invalid Pallet License +
750cAc                                      must begin with RTNPLT'
750cAC                   exsr      zm0105
750cAC                   goto      endck1
750cAC                   endif
750cA /free
750cA   // has putaway of pallet license begun
750cA   exec sql select * into :rnlrec
750cA        from pltlcns
750cA        where rnlwhse = :w1whse
750cA          and rnlpltlcns = :pltlcns
750cA          and rnlput = 'Y'
750cA            fetch first 1 rows only;

750cA   If sqlstt = sqlSuccess;
750cA     error = *on;
750cA     *in57 = *on;
750cA     errmsg = *blanks;
750cA     errmsg = 'Pallet is already in put away process';
750cA     exsr zm0105;
750cA   endif;
750cA /end-free
750cAC                   endif
EGFdA
EGFdA*  Can NOT enter NOITM dispositon code for mispick
EGFdAC                   if        client = egf and
EGFdAC                             w1dcde = 'NOITM' and
EGFdAC                             w1citm <> *blanks
EGFdAC                   eval      error = *on
EGFdAC                   eval      *in27 = *on
EGFdAC                   eval      *in07 = *on
EGFdAC                   eval      errmsg = *blanks
EGFdAC                   eval      errmsg = 'NOITM invalid for mispick'
EFGdAC                   exsr      zm0105
EGFdAC                   goto      endck1
EGFdAC                   endif
600bA
600bA*  Breakdown qty can only be entered if umq > 0.
600bA
600bAC     w1dcde        chain     rdscode                            79
600bAC                   if        not *in79
600bAC                             and rdiinv = 'Y'
600bAC                   if        w1qt02 > 0
600bAC                             and itumq2 <= 0
600bAC                   eval      error = *on
600bAC                   eval      *in31 = *on
600bAC                   eval      *in11 = *on
600bAC                   eval      errmsg = 'Brkdn info must be defined '
600bAC                                    + 'to return to stock'
600bAC                   exsr      zm0105
600bAC                   endif
600bAC                   if        w1qt03 > 0
600bAC                             and itumq3 <= 0
600bAC                   eval      error = *on
600bAC                   eval      *in32 = *on
600bAC                   eval      *in12 = *on
600bAC                   eval      errmsg = 'Brkdn info must be defined '
600bAC                                    + 'to return to stock'
600bAC                   exsr      zm0105
600bAC                   endif
600bAC                   endif
     *
530a *    Check if dept is live
530aA
530aAC                   call      'CHKLIVE'
640aAC                   parm      $pwhse        $swhse
530aAC                   parm                    itwhdp
530aAC                   parm                    livestat          8
530aA
     *
EGFdA
EGFdA*  Verify item has pick slot for code NOITM
EGFdAC                   if        client = egf and
EGFdAC                             w1dcde = 'NOITM' and
EGFeAC                             livestat <> '*NOTLIVE'
EGFdA*  Use DRI interface to get Slot item for ordered item
EGFdA
EGFdAC                   eval      $itwhse  = $pwhse
EGFdAC                   eval      $ititem  = $pitem
EGFdAC                   exsr      zzsltitm
     *
EGFd C                   movel     '*FIRST'      $scmd
EGFd C                   call      'GETPSLT'
EGFd C                   parm                    $scmd
EFGd C                   parm      $pwhse        $swhse
EFGd C                   parm      $ititem       #sitem
EFGd C                   parm                    woslot
EGFd C                   parm                    $saisl
EGFd C                   parm                    $sloc
EGFd C                   parm                    $srlvl
EGFd C                   parm                    $shand
EFGd C                   parm                    $srtn
EFGd C                   if        $srtn = '*NONE   '
EGFdAC                   eval      exitem = $pitem
EGFdAC                   eval      error = *on
EGFdAC                   eval      *in27 = *on
EGFdAC                   eval      *in07 = *on
EGFdAC                   eval      errmsg = 'Item missing pick slot -add '
EGFdAC                                    + 'pick slot and retry'
EGFdAC                   exsr      zm0105
EGFdAC                   goto      endck1
EGFdAC                   else
EGFdAC                   eval      pslot = woslot
EGFdAC                   endif
EGFdAC                   endif
EGFdA
     *
416bA*  Verify Use label for putaway Y/N.
     *
416bAC                   if        w1ulbl <> 'Y'  and
416bAC                             w1ulbl <> 'N'
416bAC                   eval      error = *on
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(7)
416bAC                   exsr      zm1001
416bAC                   endif
     *
416cA*  Use label MUST=N if label was not entered.
     *
416cAC                   if        w1ulbl = 'Y'  and
416cAC                             $plbl# = 0
416cAC                   eval      error = *on
416cAC                   eval      *in28 = *on
416cAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(7)
416bAC                   exsr      zm1001
416bAC                   endif
YHAa *
YHAa *  Must enter invoice #
YHAa *
YHAaAC                   if        client = yhata or
EGFaAC                             client = egf
WIL AC                             or client = willfoods
FGL AC                             or client = foodsgalore
FPRaAC                             or client = FoodPro
SGCcAC                             or client = SGC
YHAaAC                   if        w1inv# = *blanks
YHAaAC                   eval      error = *on
YHAaAC                   eval      *in29 = *on
YHAaAC                   eval      errmsg = *blanks
YHAaAC                   eval      errmsg = desc(10)
YHAaAC                   exsr      zm0110
YHAaAC                   endif
YHAaAC                   endif
SGCbA*
SGCbA*  Lookup Type Code must be O, I or C.
SGCbA*
SGCbAC                   if        client = sgc
SGCbA*
SGCbAC                   if            w1lktp <> 'O'
SGCbAC                             and w1lktp <> 'I'
SGCbAC                             and w1lktp <> 'C'
SGCbAC                   eval      error = *on
SGCbAC                   eval      *in38 = *on
SGCbAC                   eval      errmsg = *blanks
SGCbAC                   eval      errmsg = desc(16)
SGCbAC                   exsr      zm1001
SGCbAC                   endif
SGCbA*
SGCbAC                   endif
     *
     *  Verify transaction number.
     *
     C                   if        w1trn# <> 0
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $ltrn# = w1trn#
     C                   call      'PT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in34 = *on
     C                   eval      *in14 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
     *
416b *  The code to verify item was moved to screen2.
     *  Verify item number.
     *
416bD**         W2CITM    IFNE *BLANKS
416bD**                   MOVE '*VERIFY '$LCMD
416bD**                   Z-ADD$PWHSE    $LWHSE
416bD**                   MOVE W2CITM    $LITEM
416bD**                   CALL 'IT900'
416bD*R                   PARM           $LPARM
416bD*R         $LRTN     IFEQ '*PGMQ   '
416bD*R                   MOVE *ON       ERROR
416bD*R                   MOVE *ON       *IN35
416bD*R                   MOVE *ON       *IN15
416bD*R                   MOVE $LMSG     #MSGK
416bD*R                   EXSR ZMQMSG
416bD*R                   ENDIF
416bD*R                   ENDIF
     *
     *
416lAC                   select
416l *  UPC entered
416lAC                   when      w1upc <> *blanks
416lAC                   if        w1citm = *blanks  and
416lAC                             w1vmfg = *blanks
416l *
416lAC                   eval      $cbcmd = '*UPC    '
416lAC                   movel     w1upc         $cbbar
416lAC                   call      'CVTBAR'
416lAC                   parm                    $cbcmd            8
416lAC                   parm                    $cbbar          100
416lAC                   parm                    $cbcod            3 0
416lAC                   parm                    $cbdec            1 0
416lAC                   parm                    $cbdsc           30
416lAC                   parm                    $cbpos            3 0
416lAC                   parm                    $cbtyp            1 0
416lAC                   parm                    $cbv1            11 3
416lAC                   parm                    $cbv2            50
416lAC                   parm                    $cbrtn            8
416lAC                   parm                    $cberm           60
740bAC                   parm      $itven#       $cbven           10 0
740bAC                   parm                    $cvtdata
740bAC                   parm                    $cvtdata2
740bAC                   parm      w1whse        $cbwhse           3 0
740bAC                   parm                    $cbsent           1
740bAC                   parm                    $cbitem          15
416l *
416lAC                   if        $cbrtn = '*OK'
416lAC                   eval      w1upc = $cbv2
416lAC                   endif
416l *
416l *   Right adjust UPC code for file.
416l *
416lAC                   eval      $cstr = *blanks
416lAC                   movel     w1upc         $cstr
416lAC                   call      'ADJUST'
416lAC                   parm      '*RIGHT  '    $ccmd             8
416lAC                   parm                    $cstr            30
416lAC                   move      $cstr         kyupc
417a *   Check if mulitple items exist for one UPC code.
417a *    UPCCTR = 0, error, upc code not found.
417a *    UPCCTR = 1, only one upc found, process for item.
417a *    UPCCTR > 1, multiple upc found, need to select item.
417a C                   eval      upcctr = 0
417a C     upckey        setll     upc
417a C                   dow       forevr = forevr
417a C     upckey        reade     upc                                    79
     *
417a C                   if        *in79
417a C                   leave
417a C                   else
417a C                   add       1             upcctr
417a C                   endif
     *
417a C                   enddo
     *
417aD**         UPCKEY    CHAINUPC                  79
417aD**         *IN79     IFEQ *ON
417a C                   if        upcctr = 0
416lAC                   eval      error = *on
416lAC                   eval      *in25 = *on
416lAC                   eval      *in05 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm29
416lAC                   goto      endck1
416lAC                   endif
     *
     *   Multiple items exist for UPC
417a C                   if        upcctr > 1
417a C                   eval      $lcmd = '*VERIFY '
417a C                   eval      $lwhse = $pwhse
417a C                   eval      $lupc = kyupc
417a C                   call      'UC920'
417a C                   parm                    $lparm
417a C                   if        $lrtn = '*ERROR  '
417a C                   eval      error = *on
520aMC                   eval      *in25 = *on
520aMC                   eval      *in05 = *on
520aDC*                  eval      *in24 = *on
520aDC*                  eval      *in04 = *on
417a C                   movel     $lerm         errmsg
417a C                   exsr      zm0105
417a C                   else
417a C                   if        $lrtn = '*PGMQ   '
417a C                   eval      error = *on
520aMC                   eval      *in25 = *on
520aMC                   eval      *in05 = *on
520aDC*                  eval      *in24 = *on
520aDC*                  eval      *in04 = *on
417a C                   eval      #msgk = $lmsg
417a C                   exsr      zmqmsg
417a C                   endif
417a C                   endif
417a C                   eval      upitem = $litm1
     *
417a C                   endif
416l *
416lAC                   eval      wscitm = upitem
416lAC                   else
416lA*  Error, more than one value entered.
416lAC                   eval      error = *on
416lAC                   eval      *in23 = *on
416lAC                   eval      *in25 = *on
416lAC                   eval      *in26 = *on
416lAC                   eval      *in05 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm0204
416lAC                   goto      endck1
416lAC                   endif
416l *
416lAC                   endsl
416l *
416l *  Verify Mfg code/vendor item.
416l *
416lAC                   if        w1vmfg <> *blanks
416lAC                   if        w1upc = *blanks  and
416lAC                             w1citm = *blanks
416lAC                   eval      kyvmfg = w1vmfg
416lAC     mfgkey        chain     piritem4                           79
416lAC                   if        *in79
416lAC                   eval      error = *on
520aMC                   eval      *in26 = *on
520aMC                   eval      *in06 = *on
520aDC*                  eval      *in25 = *on
520aDC*                  eval      *in05 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm29
416lAC                   goto      endck1
416lAC                   else
416lAC                   eval      wscitm = ititem
416lAC                   endif
416lAC                   else
416lA*  Error, more than one value entered.
416lAC                   eval      error = *on
416lAC                   eval      *in23 = *on
416lAC                   eval      *in25 = *on
416lAC                   eval      *in26 = *on
416lAC                   eval      *in05 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm0204
416lAC                   goto      endck1
416lAC                   endif
416lAC                   endif
     *
416lA*  Error, more than one value entered.
416lAC                   if        w1citm <> *blanks
416lAC                   if        w1upc <> *blanks  or
416lAC                             w1vmfg <> *blanks
416lAC                   eval      error = *on
416lAC                   eval      *in23 = *on
416lAC                   eval      *in25 = *on
416lAC                   eval      *in26 = *on
416lAC                   eval      *in03 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm0204
416lAC                   goto      endck1
416lAC                   endif
416lAC                   endif
     *
     *  Get item # from other field entered.
     *
416lAC                   if        w1citm = *blanks  and
416lAC                             wscitm <> *blanks
416lAC                   eval      w1citm = wscitm
416lAC                   endif
JORb *
JORb *  If mispick return code entered, must enter corresponding item
JORb *
JORb C                   if        client = jordanos
JORbAC                   if        w1code = '8 '     and
JORbAC                             w1citm = *blanks
JORbAC                   eval      error = *on
JORbAC                   eval      *in23 = *on
JORbAC                   eval      *in03 = *on
JORbAC                   eval      errmsg = *blanks
JORbAC                   eval      errmsg = desc(9)
JORbAC                   exsr      zm1203
JORbAC                   endif
JORbAC                   endif
     *
416lA*  Mispick item must be different than ordered item.
     *
416lAC                   if        w1citm = $pitem
416lAC                   eval      error = *on
416lAC                   eval      *in23 = *on
416lAC                   eval      *in03 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   eval      errmsg = desc(9)
416lAC                   exsr      zm1202
416lAC                   endif
     *
     *  Verify item number.
     *
416l C                   if        w1citm <> *blanks
416l C                   eval      $lcmd = '*VERIFY '
416l C                   eval      $lwhse = $pwhse
416l C                   eval      $litem = w1citm
416l C                   call      'IT900'
416l C                   parm                    $lparm
416l C                   if        $lrtn = '*PGMQ   '
416l C                   eval      error = *on
416l C                   eval      *in23 = *on
416l C                   eval      *in03 = *on
416l C                   eval      #msgk = $lmsg
416l C                   exsr      zmqmsg
416lAC                   goto      endck1
416l C                   endif
416lAC                   endif
DRYfA*  Get item qty
DRYfAC                   if        client = Dairyland
DRYiAC                             and error = '0'
DRYfAC                   eval      $dricommand = '*ITEMQTY'
DRYfAC                   eval      $drisubcmd  = '*GET'
DRYfAC                   eval      $iqwhse  = $pwhse
DRYfAC                   eval      $iqitem  = w1citm
DRYfAC                   eval      $drisys2upd = 'D'
DRYfAC                   exsr      zzzdricop
DRYfAC                   if        error = *on
DRYfAC                   eval      $iqavl1 = 0
DRYfAC                   eval      $iqavl2 = 0
DRYfAC                   eval      $iqavl3 = 0
DRYfAC                   eval      error = *off
DRYfAC                   endif
DRYfA
DRYfAC                   endif
DRYfA*
DRYfA*  Corresponging item cannot be entered if disposition code
DRYfA*  will impact inventory and 0 qty on hand
DRYhA*  OR return qty > qty on hand.
DRYfAC                   select
DRYfAC                   when      client = Dairyland
DRYfAC                   if        w1citm <> ' ' and rdiinv = 'Y'
DRYfAC                   if        ($iqavl1 <= 0 and
DRYfAC                             $iqavl2 <= 0 and
DRYfAC                             $iqavl3 <= 0) or
DRYgAC                             $iqavl1 < w1qt01 or
DRYgAC                             $iqavl2 < w1qt02 or
DRYgAC                             $iqavl3 < w1qt03
DRYfAC                   eval      error = *on
DRYfAC                   eval      *in23 = *on
DRYfAC                   eval      *in03 = *on
DRYfAC                   eval      errmsg = *blanks
DRYfAC                   eval      errmsg = desc(22)
DRYfAC                   exsr      zm0105
DRYfAC                   endif
DRYgAC                   endif
DRYfAC                   endsl
510aA*
510aA*  Verify delivery number
510aA*
510aAC                   if        client = packers and
510aAC                             w1inv# <> *blanks
PCK AC                   eval      wkinv# = w1inv#
PCKcAC                   dou       pos = *zeros
PCKcAC                   eval      pos = %scan(' ':wkinv#)
PCKcAC                   if        pos <> *zeros
PCKcAC                   eval      wkinv# = %replace('0':wkinv#:pos:1)
PCKcAC                   endif
PCKcAC                   enddo
510aAC     orhkey        chain     ordhm3
510aAC                   if        not %found(ordhm3)
510aAC                   eval      errmsg = *blanks
510aAC                   eval      error = *on
510aAC                   eval      *in29 = *on
510aAC                   eval      *in09 = *on
510aAC                   exsr      zm11202
510aAC                   endif
510aAC                   endif
510aA*
510aAC                   if        client = packers and
510aAC                             w1inv# = *blanks
510aAC                   eval      errmsg = 'Delivery Number '
510aAC                   eval      error = *on
510aAC                   eval      *in29 = *on
510aAC                   eval      *in09 = *on
510aAC                   exsr      zm0203
510aAC                   endif
416b *
EGFaAC     error         cabeq     *on           endck1
EGFaAC                   if        client = egf
EGFa C                   eval      $fwhse = $pwhse
EGFa C                   eval      $fcnum = $pord
EGFa C                   eval      $finv# = w1inv#
EGFa C                   eval      $fitem = $pitem
EGFa C                   eval      $fqt01 = w1qt01
EGFa C                   eval      $fqt02 = w1qt02
EGFa C                   eval      $fqt03 = w1qt03
700eDC*                  eval      $fcwtr = w1cwtr
700eMC                   eval      $fcwtr = cnvwgt
EGFa C                   eval      $frrtn = *blanks
EGFa C                   eval      $frdes = *blanks
EGFaXC***                goto      jumpit
EGFa C                   call      'DKVALIDATE'
EGFa C                   parm                    $fwhse            3 0
EGFa C                   parm                    $fcnum            7 0
EGFa C                   parm                    $finv#           12
EGFa C                   parm                    $fitem           15
EGFa C                   parm                    $fqt01            5 0
EGFa C                   parm                    $fqt02            5 0
EGFa C                   parm                    $fqt03            5 0
EGFa C                   parm                    $fcwtr            9 2
EGFa C                   parm                    $frrtn            8
EGFa C                   parm                    $frdes           50
EGFa *
EGFaXC     jumpit        tag
EGFa C                   if        $frrtn <> '*OK'
EGFa C                   movel     $frdes        errmsg
EGFa C                   eval      error = *on
EGFaAC                   eval      *in29 = *on
EGFa C                   exsr      zm0105
EGFaAC                   endif
EGFaAC                   endif
720dA*  need to get the mispick item info if it is entered
720dA /free
720dA   if w1citm <> *blanks;
720dA     rtn$item = $item;
720dA     rtn$item2 = $item2;
720dA     exsr getcitem;
720dA     //chain ($pwhse: w1citm) piritem;
720dA     *in45 = *off;
720dA     w1um1m = $itum1;
720eA     chain ($itum1) unmesr;
720eA     if %found(unmesr);
720eA       w1um1m = umshrt;
720eA     else;
720eA       w1um1m = *blanks;
720eA     endif;
720eA     if $itum2 <> ' ';
720eA       chain ($itum2) unmesr;
720eA       if %found(unmesr);
720eA         w1um2m = umshrt;
720eA       else;
720eA         w1um2m = *blanks;
720eA       endif;
720eA     endif;
720eA     if $itum3 <> ' ';
720eA       chain ($itum3) unmesr;
720eA       if %found(unmesr);
720eA         w1um3m = umshrt;
720eA       else;
720eA         w1um3m = *blanks;
720eA       endif;
720eA     endif;
720dA     // breadkown 1
720dA     if $ITFLG1 = 'Y';
720dA       *in47 = *off;
720dA       w1um2m = $itum2;
720dA     endif;
720dA     // breadkown 2
720dA     if $ITFLG2 = 'Y';
720dA       *in49 = *off;
720dA       w1um3m = $itum3;
720dA     endif;
720dA     // only load the defaults if all the w1qm fields are 0
720dA     if w1qm01 = 0 and
720dA        w1qm02 = 0 and
720dA        w1qm03 = 0;
720eA       // lets check the actual uom before deciding which mispick
720eA       // fields to load.
720eA       select;
720eA         when w1qt01 > 0;
720eA           select;
720eA             when rtn$item.$itum1 = $itum1;
720eA               w1qm01 = w1qt01;
740jA             when $ittype = 'S';
740jA               w1qm01 = w1qt01;
720eA             when rtn$item.$itum1 = $itum2;
720eA               w1qm02 = w1qt01;
720eA             when rtn$item.$itum1 = $itum3;
720eA               w1qm03 = w1qt01;
720eA           endsl;
720eA         when w1qt02 > 0;
720eA           select;
720eA             when rtn$item.$itum2 = $itum1;
720eA               w1qm01 = w1qt02;
720eA             when rtn$item.$itum2 = $itum2;
720eA               w1qm02 = w1qt02;
720eA             when rtn$item.$itum2 = $itum3;
720eA               w1qm03 = w1qt02;
720eA           endsl;
720eA         when w1qt03 > 0;
720eA           select;
720eA             when rtn$item.$itum3 = $itum1;
720eA               w1qm01 = w1qt03;
720eA             when rtn$item.$itum3 = $itum2;
720eA               w1qm02 = w1qt03;
720eA             when rtn$item.$itum3 = $itum3;
720eA               w1qm03 = w1qt03;
720eA           endsl;
720eA       endsl;
720eD       //w1qm01 = w1qt01;
720eD       //if $Itflg1 = 'Y';
720eD         //w1qm02 = w1qt02;
720eD       //endif;
720eD       //if $Itflg2 = 'Y';
720eD         //w1qm03 = w1qt03;
720eD       //endif;
720dA     endif;
720dA     // at least one field must have a qty
720dA     if w1qm01 = 0 and
720dA        w1qm02 = 0 and
720dA        w1qm03 = 0;
720dA       error = *on;
720dA       *in44 = *on;
720dA       if $itflg1 = 'Y';
720dA         *in46 = *on;
720dA       endif;
720dA       if $itflg2 = 'Y';
720dA         *in48 = *on;
720dA       endif;
720dA       errmsg = *blanks;
720dA       errmsg = desc(18);
720dA       exsr zm0110;
720dA     endif;
720dA     $item = rtn$item;
720dA     $item2 = rtn$item2;
720dA   endif;
720dA /end-free
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
650bAc                   exsr      zzrcvrtncheck
600aAC                   eval      woexdt = 0
600aAC                   eval      womfdt = 0
600aAC                   eval      wodktexpd = 0
WSTbAc                   if        client = westside and wofifo > 0
WSTbAc                   else
600aAC                   eval      wofifo = 0
WSTbAc                   endif
600aAC                   eval      woindt = 0
     *
416bA*  Verify Impact inventory Y/N.
     *
416bAC                   if        w2iinv <> 'Y'  and
416bAC                             w2iinv <> 'N'
416bAC                   eval      error = *on
416bAC                   eval      *in28 = *on
416bAC                   eval      *in08 = *on
416bAC                   eval      errmsg = *blanks
416bAC                   eval      errmsg = desc(8)
416bAC                   exsr      zm1001
416bAC                   endif
600bA
600bA*  Breakdown qty can only be entered if umq > 0.
600bA
600bAC                   if        w2iinv = 'Y'
720dDC*                  if        w1qt02 > 0
720dMC                   if        w1qm02 > 0
600bAC                             and itumq2 <= 0
600bAC                   eval      error = *on
600bAC                   eval      *in28 = *on
600bAC                   eval      *in08 = *on
600bAC                   eval      errmsg = 'Brkdn info must be defined '
600bAC                                    + 'to return to stock'
600bAC                   exsr      zm0105
600bAC                   endif
720dDC*                  if        w1qt03 > 0
720dMC                   if        w1qm03 > 0
600bAC                             and itumq3 <= 0
600bAC                   eval      error = *on
600bAC                   eval      *in28 = *on
600bAC                   eval      *in08 = *on
600bAC                   eval      errmsg = 'Brkdn info must be defined '
600bAC                                    + 'to return to stock'
600bAC                   exsr      zm0105
600bAC                   endif
600bAC                   endif
416l *
416l *     Verify expired date (optional)
416l *
416l C                   if        not *in96  and
416l C                             w2expd = 0
416l C                   eval      error = *on
416l C                   eval      *in25 = *on
416l C                   eval      *in05 = *on
416l C                   eval      errmsg = *blanks
416l C                   exsr      zm1008
416l C                   else
416l C                   if        w2expd <> 0
416l C                   eval      $cvcmd = '*MDYEDT '
416l C                   move      w2expd        $cvd6i
416l C                   call      @cvtdt
416l C                   parm                    $cvtdt
416l C                   if        $cvrtn = '*PGMQ   '
416l C                   eval      error = *on
416l C                   eval      *in25 = *on
416l C                   eval      *in05 = *on
416l C                   eval      #msgk = $cvmsg
416l C                   exsr      zmqmsg
416l C                   else
640fA*  Calculate Use by exp date.(Exp date-User days)
640fA*
640fAC                   select
640fAC                   when      immflg = 'N'
640fAC                             and imuday > 0
640fAC                   move      w2expd        g$date
640fAC                   eval      dtfrmt = 2
640fAC                   exsr      gtoj$
640fAC                   eval      usdtj = g$jd
640fA*
640fAC     usdtj         sub       imuday        j$jd
640fAC                   exsr      jtog$
640fAC                   move      j$date        $cvd6o
640fAC                   eval      usb_expd = $cvd6o
640f *
640fAC                   eval      $cvcmd = '*MDYCMD '
640fAC                   move      usb_expd      $cvd6i
640fAC                   call      @cvtdt
640fAC                   parm                    $cvtdt
640fAC                   move      $cvd8o        expd
700dDC*                  eval      woexdt = $cvd8o
640fAC                   eval      wodktexpd = $cvd8o
640fA*
700dAC                   eval      $cvcmd = '*MDYCMD '
700dAC                   move      w2expd        $cvd6i
700dAC                   call      @cvtdt
700dAC                   parm                    $cvtdt
700dAC                   eval      woexdt = $cvd8o
700dA*
640fAC                   other
640fA*
416l C                   eval      w2expd = $cvd6o
416l C                   eval      $cvcmd = '*MDYCMD '
416l C                   call      @cvtdt
416l C                   parm                    $cvtdt
416l C                   move      $cvd8o        expd
600aAC                   eval      woexdt = $cvd8o
600aAC                   eval      wodktexpd = $cvd8o
640fA*
640fAC                   endsl
640fA*
HSYaAC                   select
HSYaAC                   when      client = Halsey or
EGFbAC                             client = egf or
CCPaAC                             client = capitolcity or
EOPaAC                             client = earls or
GMMaAC                             client = menumaker or
KHLaAC                             client = kohl      or
GLPbAC                             client = Greenleaf or
DRYeAC                             client = Dairyland and w2iinv <> 'Y' or
PANbAC                             client = panos or
CLDaAC                             client = cityline
HSYaAC                   if        expd <= today and
HSYaAC                             w2iinv = 'Y'
HSYaAC                   eval      error = *on
HSYaAC                   eval      *in25 = *on
HSYaAC                   eval      *in05 = *on
HSYaAC                   eval      errmsg = *blanks
720gDC**                 exsr      zm1009
720gMC                   exsr      zm4002
HSYaAC                   endif
FPRcAC                   when      client = FoodPro or
JORcAC                             client = jordanos or
DRYeAC                             client = Dairyland or
YHAbAC                             client = Yhata
FPRcAC                   if        ovrrid = *off and
FPRcAC                             expd <= today
FPRcAC                   eval      error = *on
FPRcAC                   eval      *in25 = *on
FPRcAC                   eval      *in05 = *on
FPRcAC                   eval      errmsg = *blanks
720gDC**                 exsr      zm1009
720gMC                   exsr      zm4002
FPRcAC                   endif
HSYaAC                   other
416l C                   if        expd <= today
416l C                   eval      error = *on
416l C                   eval      *in25 = *on
416l C                   eval      *in05 = *on
416l C                   eval      errmsg = *blanks
720gDC**                 exsr      zm1009
720gMC                   exsr      zm4002
416l C                   endif
HSYaAC                   endsl
416l C                   endif
416l C                   endif
416l C                   endif
416lA*
416lA*  Verify manufacturing date.
416lA*
416lAC                   if        not *in87
416lAC                   if        immflg = 'Y'  and
416lAC                             w2mfdt = 0
416lAC                   eval      error = *on
416lAC                   eval      *in32 = *on
416lAC                   eval      *in12 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm1008
416lAC                   else
416lAC                   if        w2mfdt <> 0
416lAC                   eval      $cvcmd = '*MDYEDT '
416lAC                   move      w2mfdt        $cvd6i
416lAC                   call      @cvtdt
416lAC                   parm                    $cvtdt
416lAC                   if        $cvrtn = '*PGMQ   '
416lAC                   eval      error = *on
416lAC                   eval      *in32 = *on
416lAC                   eval      *in12 = *on
416lAC                   eval      #msgk = $cvmsg
416lA**                   EXSR ZMQMSG
416lA**                   GOTO ENDERR
416lAC                   else
416lAC                   eval      w2mfdt = $cvd6o
416lAC                   eval      $cvcmd = '*MDYCMD '
416lAC                   call      @cvtdt
416lAC                   parm                    $cvtdt
416lAC                   move      $cvd8o        mfgd
600aAC                   eval      womfdt = $cvd8o
416lAC                   if        mfgd > today
416lAC                   eval      error = *on
416lAC                   eval      *in32 = *on
416lAC                   eval      *in12 = *on
416lAC                   eval      errmsg = *blanks
416lAC                   exsr      zm1010
416lAC                   endif
416lAC                   endif
416lAC                   endif
416lAC                   endif
416lAC                   endif
 50eA * pti check
650eA /free
650eA       // calculate the PTI.
650hD       //if $bclot <> ' ' and $bcgtin <> ' ';
650hM       if $bclot <> ' ' and $bcgtin <> ' ' and *in81 = *off;
650eA         if w2pti = 0;
650eA           error = *on;
650eA           *in41 = *on;
650eA           errmsg = desc(15);
650eA           exsr zm0110;
650eA         endif;
650eA       endif;
650eA /end-free
416l *
416lAC     error         cabeq     *on           endck2
416lA*
650eA /free
650eA   // calculate the PTI.
650hD   //if $bclot <> ' ' and $bcgtin <> ' ';
650hM   if $bclot <> ' ' and $bcgtin <> ' ' and *in81 = *off;
650eA     pplot  = %subst($bclot: 1 : 20);
650eA     calcpti ($bcgtin: pplot: $lbcprodD: pppti);
650eA     if svpti <> w2pti;
650eA       ptichk = *off;
650ea     endif;
650ea     if ptichk = '2' and
650ea        ovrrid = *on;
650ea        ptiovr = *on;
650ea        ptichk = *on;
650ea     endif;
650ea     if ptichk <> '1';
650ea       ptichk = *on;
650eA       if w2pti <> pppti
650eA         and ptiovr <> '1';
650eA         // recalc pti without production date
650eA         calcpti ($bcgtin: pplot: ptinodate: pppti);
650eA         if w2pti <> pppti;
650eA           error = *on;
650eA           *in37 = *on;
650eA           *in17 = *on;
650ea           ptichk = '2';
650eA           warn = *on;
650eA           exsr zm3203;
650eA         endif;
650eA       endif;
650eA     endif;
650eA   endif;
650eA /end-free
650eAc     error         cabeq     *on           enderr
416lAC                   if        immflg = 'Y'
530cAC                             and not *in87
416lA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
416lA*
416lAC                   move      w2mfdt        g$date
416lAC                   eval      dtfrmt = 2
416lAC                   exsr      gtoj$
416lAC                   eval      mfdtj = g$jd
416lA*
416lAC     mfdtj         add       immday        j$jd
416lAC                   eval      j$jd = j$jd - imuday
416lAC                   exsr      jtog$
416lAC                   move      j$date        $cvd6o
510dD**                 eval      w2expd = $cvd6o
510dMC                   eval      mfg_expd = $cvd6o
416l *
416lAC                   eval      $cvcmd = '*MDYCMD '
510dD**                 move      w2expd        $cvd6i
510dMC                   move      mfg_expd      $cvd6i
416lAC                   call      @cvtdt
416lAC                   parm                    $cvtdt
416lAC                   move      $cvd8o        expd
600aAC                   eval      wodktexpd = $cvd8o
416lA*
416lA*  Verify Expiration date is not already expired.                 days)
HSYaAC                   select
HSYaAC                   when      client = Halsey or
CCPaAC                             client = capitolcity or
EOPaAC                             client = earls or
GMMaAC                             client = menumaker or
KHLaAC                             client = kohl      or
GLPbAC                             client = Greenleaf or
DRYeAC                             client = Dairyland and w2iinv <> 'Y' or
PANaAC                             client = panos or
CLDaAC                             client = cityline
HSYaAC                   if        expd <= today and
HSYaAC                             w2iinv = 'Y'
HSYaAC                   eval      expd = 0
HSYaAC                   eval      error = *on
HSYaAC                   eval      *in32 = *on
HSYaAC                   eval      *in12 = *on
HSYaAC                   eval      errmsg = *blanks
HSYaAC                   exsr      zm4002
HSYaAC                   endif
FPRdAC                   when      client = FoodPro or
JORcAC                             client = jordanos or
DRYeAC                             client = Dairyland or
YHAbAC                             client = Yhata
FPRdAC                   if        ovrrid = *off and
FPRdAC                             expd <= today
FPRdAC                   eval      expd = 0
FPRdAC                   eval      error = *on
FPRdAC                   eval      *in32 = *on
FPRdAC                   eval      *in12 = *on
FPRdAC                   eval      errmsg = *blanks
FPRdAC                   exsr      zm4002
FPRdAC                   endif
HSYaAC                   other
417d C                   if        expd <= today
417d C                   eval      expd = 0
417d C                   eval      error = *on
417d C                   eval      *in32 = *on
417d C                   eval      *in12 = *on
417d C                   eval      errmsg = *blanks
417d C                   exsr      zm4002
417d C                   endif
HSYaAC                   endsl
416lAC                   endif
650eAc     enderr        tag
650eAc                   eval      svpti = w2pti
     *
     C     endck2        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCHK3   Screen 1 error checking.
650cA*
650cAC     zzchk3        begsr
650cAc                   exsr      zzchk1
650cA /free
650cA    if error;
650cA      leavesr;
650cA    endif;
650cA    // if use label for putaway load up uci temporary license
650cA    select;
650cA      when w1ulbl = 'Y' and $plbl# >0;
650cA        eval w3lcns = 'Use Label';
650cA        eval templcns = 'UL' + #jobn;
650cA        eval *in80 = *on;
650cA      when rdiinv <>'Y' and $ifsltmth = '2'
650cA        or rdiinv <>'Y' and $ifrcvmth = '2';
650cA        eval w3lcns = '*NO Stock';
650cA        eval templcns = 'NS' + #jobn;
650cA        eval *in80 = *on;
650cA    other;
650cA      eval templcns = ' ';
650cA      eval *in80 = *off;
650cA    endsl;

650cA    if $ifrcvmth = '2' and rdiinv = 'Y' or
650cA       $ifsltmth = '2' and rdiinv = 'Y';
650cA      // license must be entered
650cA      if w3lcns = ' ' and w1ulbl <> 'Y' or
650cA         w3lcns = '*NO Stock';
650cA        *in43 = *on;
650cA        error = *on;
650cA        erfld = desc(12);
650cA        exsr zm0203;
650cA        if w3lcns = '*NO Stock';
650cA          eval w3lcns = ' ';
650cA        endif;
650cA        eval *in73 = *off;
650cA        leavesr;
650cA      endif;
650cA    endif;
650cA /end-free
650cA*
650cA*  Make sure license doesn't already exist if first scan
650cA*
650cAc                   if        *in80 = *off
650cAc                             and w3lcns <> ' '
650cAc                   exsr      zzchklcns
650cAc                   endif
650cAC     endck3        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCHK4   Screen 4 error checking.
650cA*
650cA /free
650cA   begsr zzchk4;
650cA   if w1uci <> *blanks;
650cA     // check to make sure UCI barcode does not already exist
650cA     exsr clr$uciinfo;

650cA     $uiWhse = $pwhse;
650cA     $uiuci  = w1uci;
650cA     $uiitem = $pitem;

650cA     $dricommand = '*UCIINFO';
650cA     $drisubcmd  = '%CHKACTV';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     zmflag  = *off;
650cA     exsr zzzdricop;
          // if return is *EXIST seton error
650cA     if $drireturn = '*EXIST';
650cA       error = *on;
700eA       exsr zzsetcmdln14;
650cA       errmsg = desc(13);
650cA       eval nxtscr = '04 ';
650cA       exsr zm02;
650cA       leavesr;
650cA     endif;
650cA     if w1uci = ' ' and $plbl# = 0;
650cA       error = *on;
700eA       exsr zzsetcmdln14;
650cA       errmsg = desc(13);
650cA       exsr zm0105;
650cA     endif;
650cA     exsr zzconvertuci;
700eA     exsr zzcnvwgt;
650cA     if not $bcgtinsent
650cA        and not $bcai99sent;
650cA       error = *on;
700eA       exsr zzsetcmdln14;
650cA       exsr zm11202;
650cA       leavesr;
650cA     endif;
650cA     exsr zzfil3;
650cA     exsr zzfil2;
650cA     exsr zzupcck;
650cA     // diff item error
650gD     //if $pitem <> upitem;
650gM     if $pitem <> upitem
650gA        and $bcgtinsent;
700eA       exsr zzsetcmdln14;
650cA       errmsg = desc(14);
650cA       exsr zm0105;
650cA       error = *on;
650cA       leavesr;
650cA     endif;
650cA     if moretoscan <> *on;
650cA       exsr scr03i;
650cA     endif;
700eA     exsr zzchk1;
700eA     needweight = ' ';
700eA     if error = *on;
700eA       needweight = 'Y';
700eA       exsr zzsetcmdln14;
700eA       leavesr;
700eA     endif;
650cA     exsr zzchk2;
700eA     if error = *on;
700eA       exsr zzsetcmdln14;
700eA       leavesr;
700eA     endif;
700eA     // if we have any errors will need to display new fields
700eA     // for entry - weights/dates
650cA     // diff exp date warning
650cA     if expd <> saveexpd and moretoscan = *on
650cA        and diffexpd = *off;
650cA       error = *on;
700eA       exsr zzsetcmdln14;
650cA       warn = *on;
650cA       expdwarn = *on;
650cA       exsr zm3702;
650cA     endif;
650cA     // Different Lot
PCKgA     Select;
PCKgA       when $itven# = 203 and $bclot <> savelotc
PCKgA            and $bcai99sent = *off and client=pack730;
PCKgA         Difflot = *on;
PCKgA         Lotovr = *on;
PCKgA       other;
650cA         if $bclot <> savelotc and moretoscan = *on
650cA            and difflot = *off and $bclotsent;
650cA           error = *on;
700eA           exsr zzsetcmdln14;
650cA           warn = *on;
650cA           lotwarn = *on;
650cA           exsr zm3701;
650cA         endif;
PCKaA     Endsl;
650cA   else;
650cA     eval error = *on;
650cA   endif;
650cA   if error;
650cA     leavesr;
650cA   endif;
650cA   endsr;
650cA /end-free
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCHK5   Screen 5 review screen error checking.
650cA*
650cAC     zzchk5        begsr
650cAC                   move      *off          error
740cAc                   exsr      zzchk1
650cA*
650cAC     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  dairyland disallows F20, if they attempt it
     *
DRYbAC                   select
DRYbAC                   when      client = dairyland
DRYbAC                   eval      dfchk = '0'
DRYbAC                   move      *off          *inku
DRYbAC                   endsl
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
     *
     *     Return code.
     *
415cD*R         ROW#      WHEQ 15
416aD*R         ROW#      WHEQ 17
510bDC*                  when      row# = 14
510b C                   when      row# = 12
520bMC                   eval      *in02 = *on
520bDC*                  eval      *in06 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lprg = #prog
     C                   eval      $lcode = w1code
     C                   call      'RN900'
     C                   parm                    $lparm
PCKdAC                   eval      $pcwgt = *zeros
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1code = $lcode
     C                   endif
     *
416b *     Disposition code.
416b *
510bDC**                 when      row# = 15
510b C                   when      row# = 13
416b C                   eval      *in07 = *on
416b C                   eval      $lcmd = '*LOOKUP '
416b C                   eval      $lprg = #prog
416b C                   eval      $ldcde = w1dcde
416b C                   call      'RD900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*SELECT '
416b C                   eval      w1dcde = $ldcde
416b C                   endif
     *
416b *     Lookup corresponding item moved to ZZCMD3
     *     Corresponding item number.
     *
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
700eA*
700eA*      F7 - kilograms/Pounds toggle
700eA*
700eAC                   if        *inkg
700eAC                   eval      cmdtkn = *on
700eAC                   if        KiloLbs = 'P'
700eAC                   eval      KiloLbs = 'K'
700eAC                   eval      W1KgLb  = 'Kgs'
700eAC                   else
700eAC                   eval      KiloLbs = 'P'
700eAC                   eval      W1KgLb  = 'Lbs'
700eAC                   endif
700eAc                   exsr      zzsetcmdln1
700eAC                   goto      endcm1
700eAC                   endif
     *
416hA*  Test for F9 - Enable UOM Breakdown fields.
416h *
416hAC                   if        *inki
416hAC                   eval      cmdtkn = *on
416hAC                   eval      *in93 = *off
416hAC                   eval      *in94 = *off
EGFdAC                   if        client = egf
FPRaAC                             or client = FoodPro
EGFdAC                   eval      *IN58 = *on
EGFdAC                   endif
416hAC                   endif
416h *
     C                   endif
640iA*
640iA*      F20 - Accept Warning.
640iA*
640iAC                   if        *inku
640iAC                   move      *on           ovrrid
640iAC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
     *
416b *
416b *     Corresponding item number.
416b *
416b C                   when      row# = 12
416b C                   eval      *in15 = *on
416b C                   eval      $lcmd = '*LOOKUP '
416b C                   eval      $lprg = #prog
416b C                   eval      $lwhse = $pwhse
416B ***                  MOVE W1CITM    $LITEM
416B C                   eval      $litem = w1citm
416b C                   call      'IT900'
416b C                   parm                    $lparm
416b C                   if        $lrtn = '*SELECT '
416b C                   eval      w1citm = $litem
416b C                   endif
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
640jA*
640jA*      F11 - Manufacturer code decipher
640jA*
640jAc                   if        *inkk
640jAC                   eval      $lexpdat = 0
640jAC                   eval      $lmfrdat = 0
640jAc                   eval      $lrtn = ' '
640jA * f11 is only valid on date sensitive items
640jAc                   If        itflgd = 'Y' or immflg = 'Y'
640jAC                   eval      $lwhse = $pwhse
640jAc                   eval      $lmfr#    = itven#
640jAc                   eval      $lmfritem = itvit#
640jAc                   eval      $ldakitem = ititem
640jAc                   eval      $lupc1    = kyupc
640jAc                   call      'MF200'                              66
640jAC                   parm                    $lparm
640jAC                   parm      0             $lexpdat          6 0
640jAC                   parm      0             $lmfrdat          6 0
640jAC                   parm                    $lupc1           20
640jAC                   parm      ' '           $ldecvalue       15
640lAc                   if        $lrtn <> *blanks and $lrtn <> 'OK'
640lAc                   eval      w2expd = 0
640lAc                   eval      w2mfdt = 0
640lAc                   endif
640jAc                   else
640jac                   exsr      zm13250
640jAc                   endif
640jAc                   exsr      zzmfrdates
640jAC                   eval      w2exPD = $lexpdat
640jAc                   if        immflg = 'Y'
640jAC                   eval      w2mfdt = $lmfrdat
640jAc                   endif
640jAc                   endif
     C                   endif
650eA*
650eA*      F20 - Accept Warning.
650eA*
650eAC                   if        *inku
650eAC                   eval      ovrrid = *on
650eAC                   else
650eAC                   eval      ovrrid = *off
650eAC                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCMD3   User defined command keys for screen 1.
650cA*
650cAC     zzcmd3        begsr
650cA*
650cA*  Command keys to check BEFORE verification and update.
650cA*
650cAC                   if        cmdchk = '*BEFORE '
DRYdAC                   select
DRYdAC                   when      client = dairyland
DRYdAC                   eval      dfchk = '0'
DRYdAC                   move      *off          *inku
DRYdAC                   endsl
650cA*
650cA*  Test for F4 - Lookup
650cA*
650cAC                   if        *inkd
650cAC                   eval      cmdtkn = *on
650cAC                   z-add     0             row#
650cAC                   eval      row = rowin
650cAC                   z-add     0             col#
650cAC                   eval      col = colin
650cAC                   select
650cA*
650cA*
650cA*     Return code.
650cA*
650cAC                   when      row# = 12
650cAC                   eval      *in02 = *on
650cAC                   eval      $lcmd = '*LOOKUP '
650cAC                   eval      $lprg = #prog
650cAC                   eval      $lcode = w1code
650cAC                   call      'RN900'
650cAC                   parm                    $lparm
650cAC                   eval      $pcwgt = *zeros
650cAC                   if        $lrtn = '*SELECT '
650cAC                   eval      w1code = $lcode
650cAC                   endif
650cA*
650cA*     Disposition code.
650cA*
650cAC                   when      row# = 13
650cAC                   eval      *in07 = *on
650cAC                   eval      $lcmd = '*LOOKUP '
650cAC                   eval      $lprg = #prog
650cAC                   eval      $ldcde = w1dcde
650cAC                   call      'RD900'
650cAC                   parm                    $lparm
650cAC                   if        $lrtn = '*SELECT '
650cAC                   eval      w1dcde = $ldcde
650cAC                   endif
650cA*
650cAC                   other
650cA*
650cA*     Cursor not on a valid lookup field.
650cA*
650cAC                   eval      error = *on
650cAC                   exsr      zm9905
650cAC                   endsl
650cAC                   goto      endcm3
650cAC                   endif
650cA*
650cA*  Test for F9 - Enable UOM Breakdown fields.
650cA*
650cAC                   if        *inki
650cAC                   eval      cmdtkn = *on
650cAC                   eval      *in93 = *off
650cAC                   eval      *in94 = *off
650cAC                   if        client = egf
FPRaAC                             or client = FoodPro
650cAC                   eval      *IN58 = *on
650cAC                   endif
650cAC                   endif
650cA*
650cAC                   endif
650cA*
650cA*      F20 - Accept Warning.
650cA*
650cAC                   if        *inku
650cAC                   move      *on           ovrrid
740dAc                   if        cwtck = '2'
740dAc                   eval      cwtck = '1'
740dAc                   endif
650cAC                   endif
650cA*
650cA*  Command keys to check AFTER verification and update.
650cA*
650cAC                   if        cmdchk = '*AFTER  '
650cAC                   endif
650cAC     endcm3        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCMD4   User defined command keys for screen 4.
650cA*
650cAC     zzcmd4        begsr
650cA*
650cA*  Command keys to check BEFORE verification and update.
650cA*
650cAC                   eval      cmdtkn = *off
700eA*
700eA*      F7 - kilograms/Pounds toggle
700eA*
700eAC                   if        *inkg
700eAC                   eval      cmdtkn = *on
700eAC                   if        needweight = 'Y'
700eAc                   eval      *in33 = *on
700eAc                   endif
700eAC                   if        KiloLbs = 'P'
700eAC                   eval      KiloLbs = 'K'
700eAC                   eval      W1KgLb  = 'Kgs'
700eAC                   else
700eAC                   eval      KiloLbs = 'P'
700eAC                   eval      W1KgLb  = 'Lbs'
700eAC                   endif
700eAc                   exsr      zzsetcmdln14
700eAC                   goto      endcm4
700eAC                   endif
650cA*
650cA*      F20 - Accept Warning.
650cA*
650cAC                   if        *inku
650cAC                             or *inkj
650cAc                   if        lotwarn = *on
650cAC                   eval      difflot = *on
650cAC                   eval      lotwarn = *off
650cAc                   endif
650cAc                   if        expdwarn = *on
650cAC                   eval      diffexpd = *on
650cAC                   eval      expdwarn = *off
650cAc                   endif
740dAc                   if        cwtck = '2'
740dAc                   eval      cwtck = '1'
740dAc                   endif
650cAC                   else
650cAC                   endif
650cA*
650cA*
650cA*      F22 - Complete License.
650cAC                   if        *inkw
650cAc                   if        saveqty > 0
650cAC                   eval      cmdtkn = *on
650cAc                   eval      nxtscr = '05 '
650cAc                   exsr      scr05i
650cAc                   endif
740dAc                   eval      cwtck  = '0'
740dAc                   eval      $bcai99sent = *off
650cAC                   endif
650cA *
650cAC     endcm4        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCMD5   User defined command keys for screen 5.
650cA*
650cAC     zzcmd5        begsr
650cA*
650cA*  Command keys to check BEFORE verification and update.
650cA*
650cAC                   if        cmdchk = '*BEFORE '
DRYdAC                   select
DRYdAC                   when      client = dairyland
DRYdAC                   eval      dfchk = '0'
DRYdAC                   move      *off          *inku
DRYdAC                   endsl
650cAC                   endif
650cA*
650cA*
650cA*  Command keys to check AFTER verification and update.
650cA*
650cAC                   if        cmdchk = '*AFTER  '
650cAC                   endif
650cAC     endcm5        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCMDCNL User defined command keys for cancel window warning
650cA*
650cAC     zzcmdCnl      begsr
650cAC     endcmCnl      endsr
700eA*----------------------------------------------------------------
700eA*
700eA*  ZZCNVWGT  Setup converted weight field.
700eA*
700eAC     zzcnvwgt      begsr
700eA*
700eA*
700eA* If item options is setup as kgs and user enters kgs no conversion
700eA* If item options is setup as kgs and user enters lbs need conversion
700eA* If item options is setup as lbs and user enters lbs no conversion
700eA* If item options is setup as lbs and user enters kgs need conversion
700eA /free
700eA   select;
700eA     when IMkilolbs = 'K';
700eA       if KiloLbs = 'K';
700eA         eval cnvwgt = w1cwtr;
700ea       else;
700eA         eval(h) cnvwgt = w1cwtr / kgs2lbs;
700eA       endif;
700eA     other;
700eA       if KiloLbs = 'K';
700eA         eval(h) cnvwgt = w1cwtr * kgs2lbs;
700eA       else;
700eA         eval cnvwgt = w1cwtr;
700eA       endif;
700eA   endsl;
700eA /end-free

700eAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCONVERTUCI Convert uci scanned
650cA*
650cAC     zzconvertuci  begsr
710aAc                   clear                   $barcode
710aAc                   clear                   $barcode2
650cAC                   eval      $cbcmd = '*ALL    '
650cAC                   movel     w1uci         $cbbar
650cAC                   call      'CVTBAR'
650cAC                   parm                    $cbcmd            8
650cAC                   parm                    $cbbar          100
650cAC                   parm                    $cbcod            3 0
650cAC                   parm                    $cbdec            1 0
650cAC                   parm                    $cbdsc           30
650cAC                   parm                    $cbpos            3 0
650cAC                   parm                    $cbtyp            1 0
650cAC                   parm                    $cbv1            11 3
650cAC                   parm                    $cbv2            50
650cAC                   parm                    $cbrtn            8
650cAC                   parm                    $cberm           60
740bDC*                  parm                    $cbven           10 0
740bMC                   parm      $itven#       $cbven           10 0
650cAC                   parm                    $cvtdata
650cAC                   parm                    $cvtdata2
700eAC                   parm      $pwhse        $cbwhse
650cA*
710bAc                   if        $cbrtn = '*NOMORE'
740bac                             or $cbrtn = '*OK'
710aA * this line was moved up and deleted below
710bA * Put this line back where it came from
710bDc*                  if        $bcGtinSent
650cAc                   eval      $barcode = $cvtdata
650cAc                   eval      $barcode2 = $cvtdata2
710bAc                   endif
650cA * Load UPC
710bMc                   if        $bcGtinSent
650cAc                   eval      *in92 = *on
650cAc                   else
650cAc                   endif
650cA * Load Expiration Date
650cAc                   select

650cAc                   when      $bcExpDSent
650cAc                   eval      $lexpdt6 = $bcExpD
700eA
700eAc                   when      $bcSlBydSent
700eAc                   eval      $lexpdt6 = $bcSlByd
650cA
650cAc                   when      not $bcExpDSent and moretoscan = *on
700eAc                             and not $bcSlBydSent
650cAC                   eval      $cvcmd = '*MDYYMD '
650cAC                   move      savew2expd    $cvd6i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
650cAC                   eval      $lexpdt6 = $cvd6o
650cA
650cAc                   endsl
650cA * Load Manufacturing Date
650cAc                   select
650cA
650cAc                   when      $bcProdDSent
650cAc                   eval      $lmfgdt6 = $bcProdD
650dAc                   eval      $lbcProdD = $bcProdD
650cA
650jAc                   when      $bcPackDSent
650jAc                   eval      $lmfgdt6 = $bcPackD
650jAc                   eval      $lbcProdD = $bcPackD

650cAc                   when      not $bcProdDSent and moretoscan = *on
650jAc                             and not $bcPackDSent
650cAC                   eval      $cvcmd = '*MDYYMD '
650cAC                   move      savew2mfdt    $cvd6i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
650cAC                   eval      $lmfgdt6 = $cvd6o
650cA
650cAc                   endsl
650cAc
650cA * Load Catch Weight
700eAc                   select
700eAC                   when      IMkilolbs = 'K'
700eAc                   if        $bcPNtkgSent
700eAc                   eval      w1cwtr  = $bcPNtkg
700eAc                   endif
700eAC                   other
650cAc                   if        $bcPNtLbSent
700eAc                   eval      w1cwtr = $bcPNtLb
650cAc                   endif
700eAc                   endsl
650cA * Load Lot
650cAc                   if        $bcLotSent
650cAc                   endif
650cAC                   endsr
500bA*----------------------------------------------------------------
500bA*  zzerrind    Set error indicators from DRI call.
500bA*----------------------------------------------------------------

500bAC     zzerrind      begsr

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

500bAC                   endsr

     *----------------------------------------------------------------
416b *
416b *  ZZEXCP Write item exception record to file.
416b *
416b C     zzexcp        begsr
416b *
416b *    Write an item exception record for item (mispick).
416b *
416bAC     itkey         chain     piritem                            79
416bAC                   if        not *in79
416bAC                   eval      exwhdp = itwhdp
416bAC                   eval      exstyp = itstyp
416bAC                   else
416bAC                   eval      exwhdp = *blanks
416bAC                   eval      exstyp = *blanks
416bAC                   endif
     *
500eA
500eA*  Use DRI interface to get Slot item for ordered item
500eA
500eAC                   eval      $itwhse  = $pwhse
500eAC                   eval      $ititem  = exitem
500eAC                   exsr      zzsltitm
     *
416iAC                   eval      $scmd = '*FIRST'
416iAC                   call      'GETPSLT'
416iAC                   parm                    $scmd             8
416iAC                   parm      $pwhse        $swhse            3 0
500eMC                   parm      $ititem       #sitem           15
500eDC*                  parm      exitem        #sitem           15
416iAC                   parm                    woslot           12
416iAC                   parm                    $saisl            3
416iAC                   parm                    $sloc             3 0
416iAC                   parm                    $srlvl            2 0
416iAC                   parm                    $shand            2
416iAC                   parm                    $srtn             8
416iAC                   if        $srtn <> '*NONE   '
416iAC                   eval      extdis = woslot
416iAC                   else
416iAC                   eval      extdis = *blanks
416iAC                   endif
416b C                   eval      exwhse = $pwhse
416b **                   MOVE $PITEM    EXITEM
416b **                   MOVE W2CITM    EXCITM
720dAc                   if        exitem = w1citm
720dAC                   z-add     w1qm01        exqty
720dAC                   eval      exqty2 = w1qm02
720dAC                   eval      exqty3 = w1qm03
720dAc                   else
416b C                   z-add     w1qt01        exqty
416b C                   eval      exqty2 = w1qt02
416b C                   eval      exqty3 = w1qt03
720dAc                   endif
500aD**                   MOVE *BLANKS   EXFDIS
416b C                   eval      extask = 'PUTRTN'
416b **                   MOVE 'MISPICK' EXERID
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
416cD*R                   Z-ADDTODAY     EXGDTE
417cMC                   eval      exgdte = $cvd8o
416b C                   time                    exgtim
416b C                   eval      exgby = #user
416b C                   eval      exesta = '1 '
416b C                   write     exrec
416b *
416b C     endexc        endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
740dDc*                  eval      cnvwgt = 0
740cDc*                  eval      w3lcns = ' '
FPRaAC                   select
EGFcAC                   when      client = egf
FPRaDC*                  if        client = egf
EGFcAC                   eval      *IN58 = *on
EGFcAC                   eval      w2iinv = rninvf
FPRaDC*                  endif

FPRaAC                   when      client = FoodPro
FPRaAC                   eval      *IN58 = *on

700 AC                   when      client = cheney
700 AC                   eval      *IN38 = *on
700 AC     itkey         chain     piritem                            79
700 AC                   if        *in79 = *off
700 AC                   if        itactv = '99'
700 AC                   movel     'BANC'        w1type
700 AC                   else
700 AC                   movel     'NORM'        w1type
700 AC                   endif
700 AC                   endif

700 AC                   other
700 AC                   eval      *IN38 = *off
FPRaAC                   endsl
     *
     *  Verify warehouse code to get description.
     *
650cA * this code was moved to zzinz2
650cDC*                  eval      $lcmd = '*VERIFY '
650cDC*                  eval      $lwhse = $pwhse
650cDC*                  call      'WH900'
650cDC*                  parm                    $lparm
650cDC*                  if        $lrtn = '*PGMQ   '
650cDC*                  eval      wowhse = *blanks
650cDC*                  movel     $pwhse        wowhse
650cDC*                  else
650cDC*                  eval      $fwhse = $pwhse
650cDC*                  movel     $lerm         $fdesc
650cDC*                  call      'FRMTWH'
650cDC*                  parm                    $fwhse            3 0
650cDC*                  parm                    $fdesc           30
650cDC*                  parm                    wowhse
650cDC*                  endif
650cDC*                  eval      wouser = $puser
650cDC*                  eval      woitem = *blanks
650cDC*                  move      $pitem        woitem
650cDC*                  eval      wodev = $pdev
650cDC*                  eval      woform = *blanks
650cDC*                  eval      woform = $pform
650cDC*                  move      $pord         w1ord
650cDC*                  eval      wotrn# = $ptrn#
     *
     *   Get Unit of measure fields
     C                   eval      w1um1 = *blanks
     C                   eval      w1um2 = *blanks
     C                   eval      w1um3 = *blanks
     C                   exsr      zzuom
     C*
FPRb  * protect normal qty if normal uom = 'MP'
FPRa  /free
FPRa    if client = foodpro;
FPRa      if itum1 = 'MP' and itum2 <> ' ';
FPRa        *in41 = *on;
FPRa      else;
FPRa        *in41 = *off;
FPRa      endif;
FPRa    endif;
FPRb  /end-free
     *
     *   Format item description
     *
     C                   call      'FRMTIT'
     C                   parm                    ititem
     C                   parm                    itdesc
     C                   parm                    itpdsc
     C                   parm                    $frtn            70
     C                   movel     $frtn         woitem
415aA*
415aA*  Get label number.
415aA*
415aAC                   eval      wolbl# = 0
416aD**                   Z-ADD0         WOTRN#  70
415aAC                   if        $plbl# <> 0
415aAC                   eval      wolbl# = $plbl#
415aA**         WOLBL#    CHAINLABEL                79
415aA**         *IN79     IFEQ *OFF
415aA**                   Z-ADDLBTRN#    WOTRN#
415aA**                   ENDIF
415aAC                   endif
416aAC                   eval      w1trn# = wotrn#
416d C                   eval      w1inv# = *blanks
416d C                   eval      w1inv# = $pinv#
     *
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
720dAC                   eval      w1qm01 = 0
720dAC                   eval      w1qm02 = 0
720dAC                   eval      w1qm03 = 0
SGCaAC                   select
SGCaAC                   when      client = sgc
SGCaAC                   eval      w1plts = 1
SGCaAC                   other
     C                   eval      w1plts = 0
SGCaAC                   endsl
     C                   eval      w2expd = 0
416kAC                   eval      w2mfdt = 0
415bAC                   eval      w1cwtr = 0
700eAc                   select
700eAC                   when      IMkilolbs = 'K'
700eAc                   if        $bcPNtkgSent
700eAc                   eval      w1cwtr  = $bcPNtkg
700eAC                   if        $ifrcvmth = '2' or $ifsltmth = '2'
700eAc                   eval      *in72 = *on
700eAc                   else
700eAc                   eval      *in72 = *off
700eAc                   endif
700eAc                   else
700eAc                   if        w4cwtr <> 0
700eAc                   eval      w1cwtr = w4cwtr
700eAc                   exsr      zzcnvwgt
700eAc                   endif
700eAc                   endif
700eAC                   other
700eAc                   if        $bcPNtLbSent
700eAc                   eval      w1cwtr = $bcPNtLb
700eAC                   if        $ifrcvmth = '2' or $ifsltmth = '2'
700eAc                   eval      *in72 = *on
700eAc                   else
700eAc                   eval      *in72 = *off
700eAc                   endif
700eAc                   else
700eAc                   if        w4cwtr <> 0
700eAc                   eval      w1cwtr = w4cwtr
700eAc                   exsr      zzcnvwgt
700eAc                   endif
700eAc                   endif
700eAc                   endsl
700eDc*                  if        $bcpntlb > 0
700eDc*                  eval      w1cwtr = $bcpntlb
700eDc*                  else
700eDc*                  endif
CTWaAC                   if        client = citywh
CTWaAC                   eval      w1code = 'AA'
CTWaAC                   else
650cAc                   if        moretoscan <> *on
     C                   eval      w1code = *blanks
650cAc                   endif
CTWaAC                   endif
     C                   eval      w1memo = *blanks
JORbMC                   select
JORbMC                   when      client = citywh
JORbDC*                  if        client = citywh
CTWaAC                   eval      w1dcde = '1'
JORb C                   when      client = jordanos
JORa C                   eval      w1dcde = 'STOCK'
CBIcAC                   when      client = Cheney
CBIcAC                   eval      w1code = '99'
CBIcAC                   eval      w1dcde = '01'
JORbMC                   other
JORbDC**                 else
650cAc                   if        moretoscan <> *on
416b C                   eval      w1dcde = *blanks
650cAc                   endif
JORbMC                   endsl
JORbDC**                 endif
SGCaAC                   select
SGCaAC                   when      client = sgc
SGCaAC                   eval      w1ulbl = 'Y'
700eAc                   when      moretoscan = '1'
700eAc* leave w1ulbl set as it was on the first uci return scan
SGCaAC                   other
416gMC                   eval      w1ulbl = oprulb
SGCaAC                   endsl
416lAC                   eval      w1upc = *blanks
416lAC                   eval      w1vmfg = *blanks
416l C                   eval      w1citm = *blanks
WSTa C                   if        client = westside
WSTaAC                   eval      w1code = 'WR'
WSTaAC                   eval      w1dcde = 'STOCK'
WSTa C                   endif
416gD**         WOLBL#    IFNE 0
416gD**                   MOVE 'Y'       W1ULBL
416gD**                   ENDIF
416 D**                   Z-ADD0         W1TRN#
     C                   eval      w1citm = *blanks
     C                   eval      w1slot = *blanks
     C                   if        itcwgt <> 'Y'
     C                   eval      *in95 = *on
     C                   else
     C                   eval      *in95 = *off
     C                   endif
     *
640cA*   If this pgm was called by TR830 it is a Trax return ...
640cA*   if so, populate the appropriate screen qty with the qty
640cA*   passed in based on the breakdown flag, position cursor on
640cA*   "Disposition code", default "Number of pallets" to 1,
640cA*   and populate reason code with the reason code passed in.
     *
640cAC                   if        $pprg = 'TR830'
640cAC                   eval      *in07 = *on
640cAC                   eval      w1plts = 1
640eDC**                 eval      w1ulbl = 'Y'
640cAC                   eval      w1code = $ttrcod
640cAC                   eval      w1cwtr = $ttcwgt
750cAc                   eval      pltlcns = ' '

640cAC                   select
640cAC                   when      $ttbflg = '0'
640cAC                   eval      w1qt01 = $ttqty
640cAC                   when      $ttbflg = '1'
640cAC                   eval      w1qt02 = $ttqty
640cAC                   when      $ttbflg = '2'
640cAC                   eval      w1qt03 = $ttqty
640cA*  Do not populate qty for Generic breakdowns ... force
640cA*  the user to enter the qty in whichever bucket they choose,
640cA*  be it normal, breakdown 1, or breakdown 2.
640cAC                   when      $ttbflg = 'G'
640cAC                   endsl

640cAC                   endif
     *
412 D*R         *IN32     IFEQ *OFF
412 D*R                   ENDIF
700eAc                   exsr      zzsetcmdln1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
416b C     w1dcde        chain     rdscode                            79
416b C                   if        not *in79
416b C                   eval      w2iinv = rdiinv
416b C                   else
CBIaA*
CBIaAC                   if        client = Cheney
CBIaAC                   eval      w2iinv = 'Y'
CBIaAC                   else
CBIaA*
416b C                   eval      w2iinv = 'N'
CBIaAC                   endif
CBIaA*
416b C                   endif
EGFc *
FPRaAC                   select
EGFcDC*                  if        client = egf
FPRaMC                   when      client = egf
EGFcAC                   eval      *IN58 = *on
EGFcAC                   eval      w2iinv = rninvf
FPRaDC*                  endif
FPRaAC                   when      client = FoodPro
DRYbAC                             or client = dairyland
FPRaAC                   eval      *IN58 = *on
FPRaAC                   endsl
     *
     C                   eval      w2memo = *blanks
     *
416l *  If mispick, get info for mispick item.
416l C                   if        w1citm <> *blanks
416l C                   eval      kyitem = w1citm
416l C                   endif
     *
416l C     itkey         chain     piritem                            75
416l C                   if        not *in75  and
416l C                             itflgd = 'Y'
416l C                   eval      *in96 = *off
416l C                   else
416l C                   eval      *in96 = *on
416l C                   endif
416L *    If mispick was entered, get item/description.
416l C                   if        w1citm <> *blanks
416l C                   eval      woitem = *blanks
416l C                   move      w1citm        woitem
     *   Format item description
416l C                   call      'FRMTIT'
416l C                   parm                    ititem
416l C                   parm                    itdesc
416l C                   parm                    itpdsc
416l C                   parm                    $frtn
416l C                   movel     $frtn         woitem
416l C                   endif
416lA*
416lA*   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
416lA*
416lAC     imkey         chain     itemmsc                            79
416lAC                   if        not *in79  and
416lAC                             immflg = 'Y'
416lAC                   eval      *in87 = *off
416lAC                   eval      *in96 = *on
416lAC                   else
416lAC                   eval      *in87 = *on
416lAC                   endif
416lAC                   if        *in79
416lAC                   eval      immflg = 'N'
416lAC                   endif
EGFgA*  If EGF, check for NOITM, force non-date sensitive.
EGFgAC                   if        client = egf and
EGFgAC                             w1dcde = 'NOITM'
EGFgAC                   eval      *in87 = *on
EGFgAC                   eval      *in96 = *on
EGFgAC                   endif
650cA * load up information from barcode scan
650cAc                   if        $bcproddsent
650cAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650cAc                   eval      *in84 = *on
WSTbAC                   if        client = westside
WSTbAc                   move      $bcProdD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650cAc                   else
650cAc                   eval      *in84 = *off
650cAc                   endif
650cAC                   eval      $cvcmd = '*YMDMDY '
650cAC                   move      $bcprodd      $cvd6i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
720fAc                   if        immflg = 'Y'
650cAC                   eval      w2mfdt = $cvd6o
720fAc                   endif
710dAc                   if        w2mfdt = 0
710dAc                   eval      *in84 = *off
710dAc                   endif
650cAc                   else
650cAc                   if        moretoscan = *on and savew2mfdt > 0
650cAC                   eval      w2mfdt = savew2mfdt
650cAc                   eval      *in84 = *on
650cAc                   else
650cAC                   eval      w2mfdt = 0
650cAc                   eval      *in84 = *off
650cAc                   endif
650cAc                   endif
650cA
650jAc                   if        $bcpackdsent
650jAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
650jAc                   eval      *in84 = *on
WSTbAC                   if        client = westside
WSTbAc                   move      $bcPackD      $cvd6i
WSTbAC                   eval      $cvcmd = '*YMDCMD '
WSTbAC                   call      @cvtdt
WSTbAC                   parm                    $cvtdt
WSTbAC                   move      $cvd8o        expd
WSTbAC                   move      $cvd8o        wstfifo
WSTbAc                   Select
WSTbAc                   when      savewstfifo = 0
WSTbAc                   eval      savewstfifo = wstfifo
WSTbac                   when      wstfifo < savewstfifo
WSTbAc                   eval      savewstfifo = wstfifo
WSTbAc                   other
WSTbAc                   endsl
WSTbAc                   endif
650jAc                   else
650jAc                   eval      *in84 = *off
650jAc                   endif
650jAC                   eval      $cvcmd = '*YMDMDY '
650jAC                   move      $bcpackd      $cvd6i
650jAC                   call      @cvtdt
650jAC                   parm                    $cvtdt
720fAc                   if        immflg = 'Y'
650jAC                   eval      w2mfdt = $cvd6o
720fAc                   endif
710dAc                   if        w2mfdt = 0
710dAc                   eval      *in84 = *off
710dAc                   endif
650jAc                   else
650jAc                   if        moretoscan = *on and savew2mfdt > 0
650jAC                   eval      w2mfdt = savew2mfdt
650jAc                   eval      *in84 = *on
650jAc                   else
710bAc                   if        not $bcproddsent
650jAC                   eval      w2mfdt = 0
650jAc                   eval      *in84 = *off
710bAc                   endif
650jAc                   endif
650jAc                   endif
650cA
700eAc                   Select
700eDc*                  if        $bcexpdsent
700eMc                   When      $bcexpdsent
650cAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
650cAC                   eval      *in83 = *on
650cAc                   else
650cAC                   eval      *in83 = *off
650cAc                   endif
650cAC                   eval      $cvcmd = '*YMDMDY '
650cAC                   move      $bcexpd       $cvd6i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
720fAc                   if        itflgd = 'Y'
650cAC                   eval      w2expd = $cvd6o
720fAc                   endif
710dAc                   if        w2expd = 0
710dAc                   eval      *in83 = *off
710dAc                   endif
700eAc                   When      $bcSlByDsent
700eAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
700eAC                   eval      *in83 = *on
700eAc                   else
700eAC                   eval      *in83 = *off
700eAc                   endif
700eAC                   eval      $cvcmd = '*YMDMDY '
700eAC                   move      $bcslbyd      $cvd6i
700eAC                   call      @cvtdt
700eAC                   parm                    $cvtdt
720fAc                   if        itflgd = 'Y'
700eAC                   eval      w2expd = $cvd6o
720fAc                   endif
710dAc                   if        w2expd = 0
710dAc                   eval      *in83 = *off
710dAc                   endif
700eAc                   When      W4expd <> 0
700eAC                   eval      w2expd = w4expd
700eDc*                  else
700eAc                   other
650cAC                   eval      w2expd = 0
650cAC                   eval      *in83 = *off
700eDc*                  endif
700eAc                   endsl
650cA
650cA * lot
650cAc                   if        $bclotsent
650cAc                   if        $ifrcvmth = '2'  or $ifsltmth = '2'
650cAc                   eval      *in85 = *on
650cAc                   else
650cAc                   eval      *in85 = *off
650cAc                   endif
650cAc                   eval      w2lotc = $bclot
650cAc                   else
650cAc                   eval      w2lotc = ' '
650cAc                   eval      *in85 = *off
650cAc                   endif
PCKgA /free
PCKgA   // Allow lot to be overriden for vendor 203
PCKgA   if client = Pack730 and $itven# = 203;
PCKgA     *in85 = *off;
PCKgA   endif;
PCKgA /end-free
650eA * pti
710dDc*                  if        $ifucicde <> '1'and $ifrcvmth <> '2'
710dMc                   if        $ifucicde <> '1'and $ifsltmth = '3'
650eAc                   eval      *in81 = *off
650eAc                   else
650eAc                   eval      *in81 = *on
650eAc                   endif
650eAc                   eval      w2pti = 0

WSTbAC                   if        client = westside
WSTbAc                   if        $itflgd <> 'Y'
WSTbAc                   eval      wofifo = savewstfifo
WSTbAC                   endif
WSTbAC                   endif
     *
     C                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZFIL3   Fill screen 3 fields with info from file.
650cA*
650cAC     zzfil3        begsr
650cA*
650cA * need license field everything else is the same as zzfil1
650cA /free
650cA   exsr zzfil1;
720iA   // need to get upc uom type
720iA   kyupc = blank6 + $bcgtin;
720iA   uputyp = 'N';
720iA   chain ($pwhse: kyupc) upc;
720iA   select;
720iA     when uputyp = 'N';
650cA       w1qt01 = 1;
720iA     when uputyp = '1';
720iA       w1qt02 = 1;
720iA     when uputyp = '2';
720iA       w1qt03 = 1;
720iA   endsl;
650cA   w1plts = 1;
650cA   if $ifrcvmth = '2'  or $ifsltmth = '2';
650cA     *in82 = *on;
650cA   else;
650cA     *in82 = *off;
650cA   endif;
650cA   if rninvf = 'Y';
650cA     *in73 = *off;
650cA   else;
650cA     *in73 = *on;
650cA   endif;
650cA /end-free
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZFIL4   Fill screen 8 fields with info from file.
650cA*
650cAC     zzfil4        begsr
650cA*
650cA*   Format item description
650cA*
650cAC                   call      'FRMTIT'
650cAC                   parm                    $ititem
650cAC                   parm                    $itdesc
650cAC                   parm                    $itpdsc
650cAC                   parm                    $frtn            70
650cAC                   movel     $frtn         woitem
700eAc                   eval      w4cwtr = 0
700eAc                   eval      w4expd = 0
700eAc                   eval      w4mfdt = 0
700eAc                   exsr      zzsetcmdln14
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZFIL5   Fill screen 5 fields with info from file.
650cA*
650cAC     zzfil5        begsr
650cA*
650cA*   Get Unit of measure fields
650cAC                   eval      w1um1 = *blanks
650cAC                   eval      w1um2 = *blanks
650cAC                   eval      w1um3 = *blanks
650cAC                   exsr      zzuom
650cA*
650cA*   Format item description
650cA*
650cAC                   call      'FRMTIT'
650cAC                   parm                    ititem
650cAC                   parm                    itdesc
650cAC                   parm                    itpdsc
650cAC                   parm                    $frtn            70
650cAC                   movel     $frtn         woitem
650cA*
650cA*   Initialize entry fields
650cA*
720iAc                   select
720iAc                   when      uputyp = 'N'
650cAC                   eval      w1qt01 = saveqty
650cAC                   eval      w1qt02 = 0
650cAC                   eval      w1qt03 = 0
720iAc                   when      uputyp = '1'
720iAC                   eval      w1qt01 = 0
720iAC                   eval      w1qt02 = saveqty
720iAC                   eval      w1qt03 = 0
720iAc                   when      uputyp = '2'
720iAC                   eval      w1qt01 = 0
720iAC                   eval      w1qt02 = 0
720iAC                   eval      w1qt03 = saveqty
720iAc                   other
650cAC                   eval      w1qt01 = saveqty
650cAC                   eval      w1qt02 = 0
650cAC                   eval      w1qt03 = 0
720iAc                   endsl
650cAC                   eval      w1cwtr = 0
650cAC                   move      w1inv#        w1inv#
650cAC*                  if        client = westside
650cAC*                  eval      w1code = 'WR'
650cAC*                  eval      w1dcde = 'STOCK'
650cAC*                  endif
650cAC                   if        itcwgt <> 'Y'
650cAC                   eval      *in95 = *on
650cAC                   else
650cAc                   eval      w1cwtr  = savewgt
650cAC                   eval      *in95 = *off
650cAC                   endif
650cAC                   if        itflgd <> 'Y'
650cAC                   eval      *in96 = *on
650cAC                   else
650cAC                   eval      *in96 = *off
650cAC                   endif
650cAC                   if        not *in32
650cAC                   endif
650cAC     w1dcde        chain     rdscode                            79
650cAC                   if        not *in79
650cAC                   eval      w2iinv = rdiinv
650cAC                   else
650cAC                   eval      w2iinv = 'N'
650cAC                   endif
650cA*
650cAc                   if        savew2mfdt > 0
650cAC                   eval      w2mfdt = savew2mfdt
650cAc                   else
650cAC                   eval      w2mfdt = 0
650cAc                   endif
650cA
650cAc                   if        savew2expd > 0
650cAC                   eval      w2expd = savew2expd
650cAc                   else
650cAC                   eval      w2expd = 0
650cAc                   endif
650cA
650cA * lot
650cAc                   if        savelotc <> ' '
650cAc                   eval      w2lotc = savelotc
650cAc                   else
650cAc                   eval      w2lotc = ' '
650cAc                   endif
650cA
650cA*
650cA*  If mispick, get info for mispick item.
650cAC                   if        w1citm <> *blanks
650cAC                   move      w1citm        kyitem
650cAC                   endif
650cA*
650cAC     itkey         chain     piritem                            75
650cAC                   if        not *in75  and
650cAC                             itflgd = 'Y'
650cAC                   eval      *in96 = *off
650cAC                   else
650cAC                   eval      *in96 = *on
650cAC                   endif
650cA*    If mispick was entered, get item/description.
650cAC                   if        w1citm <> *blanks
650cAC                   eval      woitem = *blanks
650cAC                   move      w1citm        woitem
650cA*   Format item description
650cAC                   call      'FRMTIT'
650cAC                   parm                    ititem
650cAC                   parm                    itdesc
650cAC                   parm                    itpdsc
650cAC                   parm                    $frtn
650cAC                   movel     $frtn         woitem
650cAC                   endif
650cA*
650cA*   Enable Mfg date and disable Exp date, if Mfg date flag = 'Y'
650cA*
650cAC     imkey         chain     itemmsc                            79
650cAC                   if        not *in79  and
650cAc                             immflg = 'Y'
650cAC                   eval      *in87 = *off
650cAC                   eval      *in96 = *on
650cAC                   else
650cAC                   eval      *in87 = *on
650cAC                   endif
650cAC                   if        *in79
650cAC                   eval      immflg = 'N'
650cAC                   endif
650cAc                   eval      expd   = saveexpd

WSTbAC                   if        client = westside
WSTbAc                   if        $itflgd <> 'Y'
WSTbAc                   eval      wofifo = savewstfifo
WSTbAC                   endif
WSTbAC                   endif
650cA*
650cAC                   endsr
CSP A
CSP A*----------------------------------------------------------------
CSP A*
CSP A*  ZZGETLNNBR    Get Ordered Item Line Number.
CSP A*
CSP AC     zzgetlnnbr    begsr
CSP A*
CSP A*      Pick label scanned by user.
CSP AC                   select
CSP AC                   when      $plbl# > 0
CSP A*
CSP AC     $plbl#        chain     label
CSP AC                   if        not %found(label)
CSP AC                   eval      lblbord = 0
CSP AC                   eval      lblbseq = 0
CSP AC                   endif
CSP A*
CSP AC     ohkey         chain     ordh
CSP AC                   if        not %found(ordh)
CSP AC                   eval      ohohord = 0
CSP AC                   eval      ohohcord = 0
CSP AC                   endif
CSP A*
CSP AC                   if        $pord = ohohcord
CSP AC                   eval      orrmem =
CSP AC                               %replace(%editc(lblbseq:'X'):orrmem:26:5)
CSP AC                   else
CSP AC                   eval      orrmem = %replace('00000':orrmem:26:5)
CSP AC                   endif
CSP A*
CSP A*      Customer Order Number entered, no label scanned.
CSP AC                   when      $pord > 0
CSP A*
CSP AC                   eval      lblbseq = 0
CSP A*
CSP AC     oh5key        setll     ordh5
CSP AC     oh5key        reade     ordh5
CSP AC                   if        %eof(ordh5)
CSP AC                   eval      oh5ohord = 0
CSP AC                   eval      oh5ohcord = 0
CSP AC                   endif
CSP A*
CSP AC                   if        itcwgt = 'Y'
CSP A*      Look for matching wgt since catchwgt items are ordered
CSP A*      one case per line.
CSP AC     ockey         setll     ordc3
CSP AC                   dow       forevr = forevr
CSP AC     ockey         reade     ordc3
CSP AC                   if        %eof(ordc3)
CSP AC                   leave
CSP AC                   endif
CSP A*
CSP A*      Matching catchwgt found, get out.
700eDC*                  if        occwgt = w1cwtr
700eMC                   if        occwgt = cnvwgt
CSP AC                   eval      lblbseq = ocseq#
CSP AC                   leave
CSP AC                   endif
CSP A*
CSP AC                   enddo
CSP A*
CSP AC                   endif
CSP A*
CSP AC                   if        lblbseq = 0
CSP A*      Matching wgt not found or non-catchwgt item.
CSP AC     odkey         setll     ordd2
CSP AC                   dow       forevr = forevr
CSP AC     odkey         reade     ordd2
CSP AC                   if        %eof(ordd2)
CSP AC                   leave
CSP AC                   endif
CSP A*
CSP A*      Matching item found, get out.
CSP AC                   eval      lblbseq = odseq
CSP AC                   leave
CSP AC                   enddo
CSP A*
CSP AC                   endif
CSP A*
CSP AC                   eval      orrmem =
CSP AC                               %replace(%editc(lblbseq:'X'):orrmem:26:5)
CSP A*
CSP AC                   other
CSP AC                   eval      orrmem = %replace('00000':orrmem:26:5)
CSP AC                   endsl
CSP A*
CSP AC                   endsr
CSP A*
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
412 D*R                   MOVE #PROG     $RPRG
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     *
     *  Define key for PIRITEM file.
     *
     C     itkey         klist
     C                   kfld                    $pwhse
416b C                   kfld                    kyitem
416bD**                   KFLD           $PITEM
CSPcA*  Define key for linkitm1 file.
CSPcA*
CSPcAC     linkkey       klist
CSPcAC                   kfld                    $pwhse
CSPcAC                   kfld                    kyitem
CSPcAC                   kfld                    linkitem
415aA*
415aAC     partk2        klist
415aAC                   kfld                    $lord
415aAC                   kfld                    $pwhse
CSP A*
CSP A*  Define key for ORDC3 file.
CSP A*
CSP AC     ockey         klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    oh5ohord
CSP AC                   kfld                    $pitem
CSP A*
CSP A*  Define key for ORDD2 file.
CSP A*
CSP AC     odkey         klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    oh5ohord
CSP AC                   kfld                    kystat
CSP AC                   kfld                    $pitem
CSP A*
CSP A*  Define key for ORDH file.
CSP A*
CSP AC     ohkey         klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    lblbord
CSP A*
CSP A*  Define key for ORDH5 file.
CSP A*
CSP AC     oh5key        klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    $pord
CSP A*
CSP A*  Define key for RTEHED file.
CSP A*
CSP AC     rhkey         klist
CSP AC                   kfld                    $pwhse
CSP AC                   kfld                    oh5ohrte
640gA*  Define key for ORRTN file.
640gA*
640gAC     rnkeya        klist
640gAC                   kfld                    $pwhse
640gAC                   kfld                    $pord
640gAC                   kfld                    kyitem
640gA*  Define key for ORdd  file.
640gA*
640gAC     orddkey       klist
640gAC                   kfld                    $pwhse
640gAC                   kfld                    woord
DRYcA*
DRYcAC     orddkey1      klist
DRYcAC                   kfld                    $pwhse
DRYcAC                   kfld                    wiord
DRYcAC                   kfld                    kyitem
     *
     *     OPTIONS
     *
     C     opkey         klist
     C                   kfld                    $pwhse
     C                   kfld                    ocode
     *
416bA*
416bA*  Define key for UPC file.
416bA*
416bAC     upckey        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    kyupc
416bA*  Define key for PIRITEM4 MFG code.
416bA*
416bAC     mfgkey        klist
416bAC                   kfld                    $pwhse
416bAC                   kfld                    kyvmfg
416k *
416k *  Define key for ITEMMSC file.
416k *
416kAC     imkey         klist
416kAC                   kfld                    itwhse
416kAC                   kfld                    ititem
510aA*
510aA*  Define key for ORDHM3 file.
510aA*
510aAC     orhkey        klist
510aAC                   kfld                    $pwhse
PCKcD ***                kfld                    w1inv#
PCKcMC                   kfld                    wkinv#
610bA*
610bAC                   eval      opcode = '*SYSTEM '
610bA*
610bAC                   eval      opwhse = *zeros
     *
610bAC     keyop         klist
610bAC                   kfld                    opwhse
610bAC                   kfld                    opcode
610bA*
610bAC     keyop         chain     options
610bAC                   if        not %found(options)
610bAC                   eval      opuci  = 'N'
610bAC                   else
610bAC                   movel     opdata        opdta2
610bAC                   endif
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
640jA * determine if mfr decipher is available to client
640jAc                   eval      $lcmd = '*OPEN'
640jAC                   eval      $lwhse = $pwhse
640jAc                   call      'MF200'                              66
640jAC                   parm                    $lparm
640jAC                   parm      0             $lexpdat          6 0
640jAC                   parm      0             $lmfrdat          6 0
640jAC                   parm                    $lupc            20
640jAC                   parm      ' '           $ldecvalue       15
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
740hAc                   eval      scan = 0
     *
700eA*
700eA*   Get Item Maintenance options.
700eA*
700eA /free
700eA    whse = $pwhse;
700eA    getimuom(whse: IMkilolbs: IMUom);
700eA    select;
700eA      when IMkilolbs = 'K';
700eA        KiloLbs = 'K';
700eA        W1KgLb  = IMUom;
700eA      other;
700eA        kiloLbs = 'P';
700eA        W1KgLb  = 'Lbs';
700eA    endsl;
700eA /end-free
640iAC                   move      '0'           dfchk
740cAc                   eval      w3lcns = ' '
740dAc                   eval      cnvwgt = 0
417a C                   eval      forevr = *off
416bAC                   eval      kyitem = $pitem
     *
412 D*R                   CALL 'GETWHSE'
    D*R                   PARM           #USER
    D*R         W1WHSE    PARM 0         #WHSE   30
416e *
416e *   Get Return Options.
416e *
416eAC                   eval      flbflg = *off
416eAC                   eval      worexq = *blanks
416eAC                   eval      ocode = '*RETURNS'
416e *
416eAC     opkey         chain     options                            79
416eAC                   if        not *in79
416eAC                   eval      oprdta = opdata
416eAC                   if        oprflb = 'Y'
416eAC                   eval      flbflg = *on
416eAC                   endif
416eAC                   eval      worexq = oprexq
416eAC                   endif
750cA /free
750cA   if oppltl = 'Y' and $pprg  = 'TR830';
750cA     *in56 = *on;
750cA   else;
750cA     *in56 = *off;
750cA   endif;
750cA /end-free
     *
415bA*   Set flag if called from Quick Return (RN150)
416cD****       $PPRG     IFEQ 'RN150'
416cMC                   if        $pqck = 'Y'
415bAC                   eval      quick = *on
415bAC                   else
415bAC                   eval      quick = *off
415bAC                   endif
     *
     *   Initialize headings and return type.
     *
     C                   select
     C                   when      $pcmd = '*RETURN '
416CD***                  MOVE ' '       RTNTYP  1
     C                   eval      w1scrn = 'RN250.01'
416cAC                   if        $pqck = 'N'
416CAC                   eval      rtntyp = ' '
     C                   move      hed(1)        wohead
416cAC                   else
416CAC                   eval      rtntyp = 'Q'
416cAC                   move      hed(4)        wohead
416cAC                   endif
     C                   when      $pcmd = '*TFRRTN '
     C                   eval      rtntyp = 'T'
     C                   eval      w1scrn = 'RN255.01'
     C                   move      hed(2)        wohead
     C                   when      $pcmd = '*POSRTN '
     C                   eval      rtntyp = 'P'
     C                   eval      w1scrn = 'RN257.01'
     C                   move      hed(3)        wohead
     C                   endsl
650cA*
650cA*  Verify warehouse code to get description.
650cA*
650cAC                   eval      $lcmd = '*VERIFY '
650cAC                   eval      $lwhse = $pwhse
650cAC                   call      'WH900'
650cAC                   parm                    $lparm
650cAC                   if        $lrtn = '*PGMQ   '
650cAC                   eval      wowhse = *blanks
650cAC                   movel     $pwhse        wowhse
650cAC                   else
650cAC                   eval      $fwhse = $pwhse
650cAC                   movel     $lerm         $fdesc
650cAC                   call      'FRMTWH'
650cAC                   parm                    $fwhse            3 0
650cAC                   parm                    $fdesc           30
650cAC                   parm                    wowhse
650cAC                   endif
650cAC                   eval      wouser = $puser
650cAC                   eval      woitem = *blanks
650cAC                   move      $pitem        woitem
650cAC                   eval      wodev = $pdev
650cAC                   eval      woform = *blanks
650cAC                   eval      woform = $pform
650cAC                   move      $pord         w1ord
650cAC                   eval      wotrn# = $ptrn#
     *
     *   Center screen heading.
     *
     C                   call      'CENTER'
     C                   parm                    wohead
     C                   parm      60            $clen             3 0
650cAc                   exsr      getitem
650cA*
650cA*    Get User's employee number to be written to PORCV file
650cA*    if any records are flagged as touched.
650cA*
650cAC                   call      'GETUSER'
650cAC                   parm      #user         $code            10
650cAC                   parm      0             $whse             3 0
650cAC                   parm      0             $emp#             5 0
650cAC                   parm      *blanks       $fnam            15
650cAC                   parm      *blanks       $init             1
650cAC                   parm      *blanks       $lnam            20
650cAC                   parm      *blanks       $whdp             5
650cAC                   parm      *blanks       $styp             1
650cAC                   parm      *blanks       $shft             6
650cAC                   parm      *blanks       $crew             6
650cAC                   parm      0             $nhrs             3 1
650cAC                   parm      *blanks       $rtn              8
     *
     *   Display first screen.
     *
     C                   eval      refrsh = *on
JSLaAc                   Select
JSLaAc                   when      client = jsilvert and $ittype = 'S'
JSLaAc                             and $ifsltmth <> '2'
JSLaAC                   exsr      scr01i
JSLaAc                   other
650cAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
700kDc*                            or $ifucicde = '3' and $ifsltmth <> '2'
700kMc                             or $ifucicde = '3' and $ifsltmth <> '1'
650cAc                   if        w1uci = ' '
650cAC                   exsr      scr04i
650cAc                   else
650cAC                   exsr      scr03i
650cAc                   endif
650cAc                   else
     C                   exsr      scr01i
650cAc                   endif
JSLaAc                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZLCNS   Get use generic license option
     *
     C     zzlcns        begsr
     *
     *   Get use generic license option.
     *
710eM*   Because we want to call RN246 regardless of the generic
     *   option, we can force lcnflg to *on and let the existing
     *   logic turn it off for things like don't impact inventory.
     *
710eDC**                 eval      lcnflg = *off
710eMC                   eval      lcnflg = *on
710eDC**                 eval      usegeneric = *off
     C                   eval      ocode = '*RCVLBL '
     *
     C     opkey         chain     options                            79
     C                   if        not *in79
     C                   if        opplcn = 'Y'
     C                   eval      lcnflg = *on
710eDC**                 eval      usegeneric = *on
     C                   endif
     C                   endif
     *
     C                   endsr
650cA*----------------------------------------------------------------
650cA*  ZZLICINFOCAN  User cancelled - licinfo needs to be deleted
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA   begsr zzlicinfocan;
650cA
650cA     exsr clr$licinfo;
650cA
650cA     $lnwhse  = $pwhse;
650cA     select;
650cA     when w1ulbl = 'Y';
650cA       $lnlcns  = templcns;
650cA     when w2iinv = 'N';
650cA       $lnlcns  = templcns;
650cA     other;
650cA       $lnlcns  = w3lcns;
650cA     endsl;
650cA
650cA     $dricommand = '*LICINFO';
650cA     $drisubcmd  = '%DELETEALL';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     exsr zzzdricop;
650cA     if error;
650cA     endif;
650cA
650cA   endsr;
650cA /end-free
650cA*----------------------------------------------------------------
650cA*  ZZLICINFOCHK  Check to see if licinfo exist for this lcnslot/exp
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA   begsr zzlicinfochk;
650cA
650cA     Lastseq  = 1;
650cA     dow forevr = forevr;
650cA
650cA     exsr clr$licinfo;
650cA
650cA     $lnwhse  = $pwhse;
650cA     select;
650cA     when w1ulbl = 'Y';
650cA       $lnlcns  = templcns;
650cA     when w2iinv = 'N';
650cA       $lnlcns  = templcns;
650cA     other;
650cA       $lnlcns  = w3lcns;
650cA     endsl;
650cA     $lnseq  = lastseq + 1;
650cA
650cA     $dricommand = '*LICINFO';
650cA     $drisubcmd  = '%GET';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     exsr zzzdricop;
650cA     if error;
650cA       leave;
650cA     else;
650cA       // compare lot and date fields
650cA       if $lnlot = w2lotc and
650cA          $lnexpdate = expd;
650cA         // add qty and weight, update licinfo
700eD         //$lnttllbs = $lnttllbs + w1cwtr;
700eM         $lnttllbs = $lnttllbs + cnvwgt;
650cA         //$lnrcvqty = $lnrcvqty + 1;
650cA         $lnseqqty = $lnseqqty + 1;
650cA         $dricommand = '*LICINFO';
650cA         $drisubcmd  = '%CHANGES';
650cA         $drisys2upd = 'D';
650cA         chk4err = *on;
650cA         exsr zzzdricop;
650cA         licinfoupd = *on;
650cA         leave;
650cA       endif;
650cA       eval lastseq = lastseq + 1;
650cA     endif;
650cA
650cA   enddo;
650cA   endsr;
650cA /end-free
650cA*----------------------------------------------------------------
650cA*  ZZLICINFOSEQ  Used to get the current lnseqqty for accumulator
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA   begsr zzlicinfoseq;
650cA
650cA     exsr clr$licinfo;
650cA
650cA     $lnwhse  = $pwhse;
650cA     select;
650cA     when w1ulbl = 'Y';
650cA       $lnlcns  = templcns;
650cA     when w2iinv = 'N';
650cA       $lnlcns  = templcns;
650cA     other;
650cA       $lnlcns  = w3lcns;
650cA     endsl;
650cA     $lnseq  = 1;
650cA
650cA     $dricommand = '*LICINFO';
650cA     $drisubcmd  = '%GET';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     exsr zzzdricop;
650cA     if error;
650cA     else;
650cA       // accumulate the lnseqqty field
650cA       $lnseqqty = $lnseqqty + 1;
650cA       $dricommand = '*LICINFO';
650cA       $drisubcmd  = '%CHANGES';
650cA       $drisys2upd = 'D';
650cA       chk4err = *on;
650cA       exsr zzzdricop;
650cA       licinfoupd = *on;
650cA     endif;
650cA
650cA   endsr;
650cA /end-free
650cA*----------------------------------------------------------------
650cA*  ZZLICINFONew Update New format of LICINFO
650cA*----------------------------------------------------------------
650cA
650cA /free
650cA   begsr zzlicinfonew;
650cA
650cA     // Write out standard license information
650cA     exsr clr$licinfo;
650cA
650cA     $lnwhse  = $pwhse;
650cA     select;
650cA       when w1ulbl = 'Y';
650cA         $lnlcns  = templcns;
650cA       when w2iinv = 'N';
650cA         $lnlcns  = templcns;
650cA     other;
650cA       $lnlcns  = w3lcns;
650cA     endsl;
650cA
650cA     if difflot or diffexpd;
650cA       $lnseq = lastseq + 1;
650cA       $lnseqqty = $lnseqqty + 1;
650cA       //$lnrcvqty = 1;
700eD       //$lnttllbs = w1cwtr;
700eM       $lnttllbs = cnvwgt;
650cA     else;
650cA       $lnseq = 1;
650cA       $lnseqqty = 1;
650cA     endif;
650cA     $lnpo = ' ';
650cA     $lnposeq = 0;
650cA     $lnitem = $pitem;
650cA     // LNRCVTYP notes
650cA     // 1 = Manual quantity (original method)
650cA     // 2 = Manual quantity with initial GS1 scan
650cA     // 3 = UCI using Mfg GS1 barcodes
650cA     // 4 = UCI using Internal GS1 barcodes (start with 99)
650cA     // 5 = ASN file
650cA
650cA     select;
650cA       when $ifucicde = ' ';
650cA         $lnrcvtyp = '1';
650cA       when $ifucicde = '1';
650cA         $lnrcvtyp = '1';
650cA       when $ifucicde = '2';
650cA         $lnrcvtyp = '3';
650cA       when $ifucicde = '3';
650cA         $lnrcvtyp = '4';
650cA       // don't know exactly what 2 will represent
650cA     endsl;
650cA     $lnrcvtrn# = 0;
650cA     $lnrcvlbl# = 0;
650cA
650cA     select;
650cA       when wofifo <> 0;
650cA         $lnentdate = wofifo;
650cA       when w2mfdt <> 0;
650cA         $lnentdate = womfdt;
650cA       other;
650cA         $lnentdate = woexdt;
650cA     endsl;
650cA
650cA     if wofifo > 0;
650cA       $lnenttype = '*FIFODT';
650cA     else;
650cA       if $itflgd = 'Y';
650cA         select;
650cA           when $imuday > 0 or
650cA                $imdday > 0;
650cA             if $immflg = 'Y';
650cA               $lnenttype = '*MFGDTE';
650cA             else;
650cA               $lnenttype = '*USEDTE';
650cA             endif;
650cA           other;
650cA             $lnenttype = '*EXPDTE';
650cA         endsl;
650cA       else;
650cA         $lnenttype = '*ENTDTE';
650cA       endif;
650cA
650cA       $lndateflag = $itflgd;
650cA       $lnmfgflag = $immflg;
650cA
650cA       $lnmfgdays = $immday;
650cA       $lnusrdays = $imuday;
650cA       $lndstdays = $imdday;
650cA     endif;
650cA
650cA     $lnmfgdate = womfdt;
650cA
650cA     if mexpd > 0;
650cA       $lnmfgexp = mexpd;
650cA     endif;
650cA
650cA     if wofifo > 0;
650cA       $lnfifodate = wofifo;
650cA     endif;
650cA
650cA     if expd > 0;
650cA       $lnexpdate = expd;
650cA     endif;
650cA
650cA     if $ldecvalue > ' ';
650cA       $lnmfgcode = $ldecvalue;
650cA     endif;
650cA
650cA     $lnavglbs = 0;
650cA
650cA     if W2lotc <> ' ';
650cA       $lnlot = w2lotc;
650cA     endif;
650cA
650cA     //if w1brand <> ' ';
650cA       //$lnbrand = w1brand;
650cA     //endif;
650cA
650dA       // calculate the PTI.
650dA       if $bclot <> ' ' and $bcgtin <> ' ';
650dA         pplot  = %subst($bclot: 1 : 20);
650dA         calcpti ($bcgtin: pplot: $lbcprodD: pppti);
650dA         if pppti > 0;
650dA           $lnlotPTI4 = %editc(pppti:'X');
650dA           $lnlotPTI2 = %Subst(%EditC(pppti:'X'):3:2);
650dA           // create detail pti records in UCIINFO for use at selection
650dA           // when item is not UCI receiving method
650dA           k = 0;
710dD           //if $ifrcvmth <> '2';
710DM           if $ifsltmth = '3';
650dA             dou k = $lnrcvqty;
650dA               k = k + 1;
650dA               exsr clr$uciinfo;
650dA               $uiWhse = $pwhse;
650dA               $uiItem = $pitem;
650dA               $uiuci = %trim(%editc(pppti:'X'));
650dA               ucilic#($unext: $pwhse);
650dA               unexta = %editc($unext:'X');
650dA               $uiuciLcns = 'P:' + unexta;
650dA               $uiLcns = $lnlcns;
650dA               $uiseq = 1;
650dA               $uiSerial = ' ';
650dA               // weight is calculated as average
700eD               //$uiwgtlbs = w1cwtr / $lnrcvqty;
700eM               $uiwgtlbs = CnvWgt / $lnrcvqty;
650dA               $uiSelTrn# = 0;
650dA               $uiSelLbl# = 0;
650dA               $uiSelOrd = 0;
650dA               $uiSelSeq = 0;
650dA               $uiSelCSeq = 0;
650dA               $uiSelTrax = ' ';
650dA               $uiCrtBy = '2';
720iA               $uiaUTyp = uputyp;
720iA               $uiaSlUTyp = uputyp;
720iA               if $bcgtin = *blanks;
720iA                  $uiaGtin = 0;
720iA               else;
720iA                  $uiaGtin  = %DEC($bcgtin:14:0);
720iA               endif;
720iA               $uiaLot   = $bclot;
720iA               if saveexpd = 0;
720iA                  $uiaExpD = expd;
720iA               else;
720iA                  $uiaExpD = saveexpd;
720iA               endif;
720iA               $uiaEntD  = today;

650dA               $dricommand = '*UCIINFO';
650dA               $drisubcmd  = '%ADD';
650dA               $drisys2upd = 'D';
650dA               chk4err = *on;
650dA               zmflag  = *off;
650dA               exsr zzzdricop;
650dA             enddo;
650dA           endif;
650dA         endif;
650dA       endif;

650cA     $dricommand = '*LICINFO';
650cA     $drisubcmd  = '%ADDS';
650cA     $drisys2upd = 'D';
650cA     chk4err = *on;
650cA     exsr zzzdricop;
650cA     if error;
650cA     endif;
650cA
650cA   endsr;
650cA /end-free
640jA*----------------------------------------------------------------
640jA*
640jA*  ZZmfrdates  Set manufactures dates
640jA*
640jAC     zzmfrdates    begsr
640jAc                   select
640jAc                   when      $lmfrdat > 0 and $ldecvalue > ' '
640jA*
640jA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640jA*

640jAC                   eval      $cvcmd = '*MDYCMD '
640jAC                   move      $lmfrdat      $cvd6i
640jAC                   call      @cvtdt
640jAC                   parm                    $cvtdt
640jAC                   move      $cvd8o        mfgdte

640jA*  Create mfg expiration date mfgdate + mfg shelf life days
640jA
640jAC                   call      'CLCDUR2'
640jAC                   parm      '*ADD'        $cdcmd
640jAC                   parm      mfgdte        $cddatein
640jAC                   parm      0             $cdtimein
640jAC                   parm      0             $cdyears
640jAC                   parm      0             $cdmonths
640jAC                   parm      immday        $cddays
640jAC                   parm      0             $cdhours
640jAC                   parm      0             $cdminutes
640jAC                   parm      0             $cdseconds
640jAC     mexpd         parm      0             $cddateout
640jAC                   parm      0             $cdtimeout


640jA*
640jA*  Calculate Mfg date if mfg exp date is entered
640jA*
640jAc                   when      $lexpdat > 0 and $ldecvalue > ' '

640jA*
640jA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640jA*

640jAC                   eval      $cvcmd = '*MDYCMD '
640jAC                   move      $lexpdat      $cvd6i
640jAC                   call      @cvtdt
640jAC                   parm                    $cvtdt
640jAC                   move      $cvd8o        mexpd

640jA*  Create mfg date - date mfg exp date - mfg shelf life days
640jA
640jAC                   call      'CLCDUR2'
640jAC                   parm      '*SUB'        $cdcmd
640jAC                   parm      mexpd         $cddatein
640jAC                   parm      0             $cdtimein
640jAC                   parm      0             $cdyears
640jAC                   parm      0             $cdmonths
640jAC                   parm      immday        $cddays
640jAC                   parm      0             $cdhours
640jAC                   parm      0             $cdminutes
640jAC                   parm      0             $cdseconds
640jAC     mfgdte        parm      0             $cddateout
640jAC                   parm      0             $cdtimeout
640jAc                   if        immday = 0
640jAc                   eval      mfgdte = 0
640jAc                   endif

640jAc                   when      w2mfdt > 0 and itflgd = 'Y'
640jA*
640jA*  Calculate Mfg Exp    date.(Mfg date + Mfg Shelf life days)
640jA*

640jAC                   eval      $cvcmd = '*MDYCMD '
640jAC                   move      w2mfdt        $cvd6i
640jAC                   call      @cvtdt
640jAC                   parm                    $cvtdt
640jAC                   move      $cvd8o        mfgdte

640jA*  Create mfg expiration date mfgdate + mfg shelf life days
640jA
640jAC                   call      'CLCDUR2'
640jAC                   parm      '*ADD'        $cdcmd
640jAC                   parm      mfgdte        $cddatein
640jAC                   parm      0             $cdtimein
640jAC                   parm      0             $cdyears
640jAC                   parm      0             $cdmonths
640jAC                   parm      immday        $cddays
640jAC                   parm      0             $cdhours
640jAC                   parm      0             $cdminutes
640jAC                   parm      0             $cdseconds
640jAC     mexpd         parm      0             $cddateout
640jAC                   parm      0             $cdtimeout

640jAc                   when      w2expd > 0

640jA*
640jA*  Calculate Mfg date.(Mfg exp date - Mfg Shelf life days)
640jA*

640jAC                   eval      $cvcmd = '*MDYCMD '
640jAC                   move      w2expd        $cvd6i
640jAC                   call      @cvtdt
640jAC                   parm                    $cvtdt
640jAC                   move      $cvd8o        mexpd

640jA*  Create mfg date - date mfg exp date - mfg shelf life days
640jA
640jAC                   call      'CLCDUR2'
640jAC                   parm      '*SUB'        $cdcmd
640jAC                   parm      mexpd         $cddatein
640jAC                   parm      0             $cdtimein
640jAC                   parm      0             $cdyears
640jAC                   parm      0             $cdmonths
640jAC                   parm      immday        $cddays
640jAC                   parm      0             $cdhours
640jAC                   parm      0             $cdminutes
640jAC                   parm      0             $cdseconds
640jAC     mfgdte        parm      0             $cddateout
640jAC                   parm      0             $cdtimeout

640jAc                   if        immday = 0
     c                   eval      mfgdte = 0
640jAc                   endif

640jAc                   endsl
640jAC                   endsr
     *
500aA*----------------------------------------------------------------
500aA*
500aA*  ZZPSLT   Get Put pick slot for mispick items
500aA*
500aAC     zzpslt        begsr
     *
500eA
500eA*  Use DRI interface to get Slot item for ordered item
500eA
500eAC                   eval      $itwhse  = $pwhse
500eAC                   eval      $ititem  = exitem
500eAC                   exsr      zzsltitm
     *
     C                   eval      picksl = *off
     C                   eval      oslot = *blanks
     C                   eval      pslot = *blanks
     C                   movel     '*FIRST'      $scmd
     C                   call      'GETPSLT'
     C                   parm                    $scmd
     C                   parm      $pwhse        $swhse
500eDC*                  parm      exitem        #sitem
500eMC                   parm      $ititem       #sitem
     C                   parm                    woslot
     C                   parm                    $saisl
     C                   parm                    $sloc
     C                   parm                    $srlvl
     C                   parm                    $shand
     C                   parm                    $srtn
     C                   if        $srtn <> '*NONE   '
     C                   eval      oslot = woslot
500eA
500eA*  Use DRI interface to get Slot item for picked item
500eA
500eAC                   eval      $itwhse  = $pwhse
500eAC                   eval      $ititem  = excitm
500eAC                   exsr      zzsltitm
     *
     *
     C                   movel     '*FIRST'      $scmd
     C                   call      'GETPSLT'
     C                   parm                    $scmd
     C                   parm      $pwhse        $swhse
500eMC                   parm      $ititem       #sitem
500eDC*                  parm      excitm        #sitem
     C                   parm                    woslot
     C                   parm                    $saisl
     C                   parm                    $sloc
     C                   parm                    $srlvl
     C                   parm                    $shand
     C                   parm                    $srtn
     C                   if        $srtn <> '*NONE   '
     C                   eval      pslot = woslot
     *
     C                   eval      picksl = *on
     C                   endif
     C                   endif
500aAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVRTNCHECK check for started RCVRTN Transaction
650bA*
650bAC     zzrcvrtncheck begsr
650bA*
650bA*  See if RCVRTN transaction is status 2 - start new if needed
650bA*
650bAc                   move      w1ord         $rtnord
650bAC                   call      @crtrcv
650bAC                   parm      '*RETURN'     $lcmdr           10
650bAC                   parm      '*CHECK '     $lsubcmd         10
650bAC                   parm      itwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $ppo              9
650bAC                   parm      itstyp        $litstyp          1
650bAC                   parm      itwhdp        $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZRCVRTNCLOSE  Close RCVRTN transaction.
650bA*
650bAC     zzrcvrtnclose begsr
650bAc                   if        rcvrtncomplete

650bAc                   select
650bAc                   when      $lrq1 > 0
650bAc                   eval      poppcs = $lrq1
650bAc                   when      $lrq2 > 0
650bAc                   eval      poppcs = $lrq2
650bAc                   when      $lrq3 > 0
650bAc                   eval      poppcs = $lrq3
650bAc                   endsl
650bAC                   call      @crtrcv
650bAC                   parm      '*RETURN'     $lcmdr           10
650bAC                   parm      '*COMPLETE'   $lsubcmd         10
650bAC                   parm      itwhse        @lwhse            3 0
650bAC                   parm      poppcs        $lpcs             5 0
650bAC                   parm      $lrpal        $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $rtnord           9
650bAC                   parm      itstyp        $litstyp          1
650bAC                   parm      itwhdp        $litwhdp          5
650bAC                   parm                    $lrtnr           10
650bA
650bAc                   else
650bA
650bAC                   call      @crtrcv
650bAC                   parm      '*RETURN'     $lcmdr           10
650bAC                   parm      '*CLOSE'      $lsubcmd         10
650bAC                   parm      itwhse        @lwhse            3 0
650bAC                   parm      0             $lpcs             5 0
650bAC                   parm      0             $lpallets         5 0
650bAC                   parm                    $lsavetrn         7 0
650bAC                   parm                    $rtnord           9
650bAC                   parm      itstyp        $litstyp          1
650bAC                   parm      itwhdp        $litwhdp          5
650bAC                   parm                    $lrtnr           10

650bAc                   endif

650bAC                   endsr
     *
700eA*----------------------------------------------------------------
700eA*
700eA*  ZZSETCMDLN1  Setup the command keys
700ea*
700eaC     zzsetcmdln1   begsr
700eA /free
700eA   Select;
700eA     when itcwgt <> 'Y';
DRYbA       if client = dairyland;
DRYbA         cmdln1 = cmdln(9);
DRYbA       else;
700eA         cmdln1 = cmdln(3);
DRYbA       endif;
700eA     when kilolbs  = 'K';
DRYbA       if client = dairyland;
DRYbA         cmdln1 = cmdln(8);
DRYbA       else;
700eA         cmdln1 = cmdln(2);
DRYbA       endif;
700eA     when kilolbs  = 'P';
DRYbA       if client = dairyland;
DRYbA         cmdln1 = cmdln(7);
DRYbA       else;
700eA         cmdln1 = cmdln(1);
DRYbA       endif;
700eA   endsl;
700eA /end-free
700eaC                   endsr
700eA*----------------------------------------------------------------
700eA*
700eA*  ZZSETCMDLN14 Setup the command keys for screen 4
700eA*
700eAC     zzsetcmdln14  begsr
700eA /free
700eA   Select;
700eA     when *in33 = *off;
700eA         cmdln1 = cmdln(6);
700eA     when kilolbs  = 'K';
700eA         cmdln1 = cmdln(5);
700eA     when kilolbs  = 'P';
700eA         cmdln1 = cmdln(4);
700eA   endsl;
700eA /end-free
700eaC                   endsr
500eA*----------------------------------------------------------------
500eA*  zzsltitm    Get slot item (base item)
500eA*----------------------------------------------------------------

500eAC     zzsltitm      begsr

500eA
500eA*  Use DRI interface to get Slot item.
500eA
500eAC                   eval      $dricommand = '*ITEM'
500eAC                   eval      $drisubcmd  = '%GETSLOT'
500eAC                   eval      $drisys2upd = 'D'
500eAC***                eval      ck4err = *on
500eAC                   exsr      zzzdricop
500eAC                   if        error  = *on
500eAC                   clear                   #slotitem
500eAC                   clear                   #slottype
500eAC                   endif
500eA
500eAC                   eval      #slotitem = $ititem
500eAC                   eval      #slottype = $ittype
     *
     C     enditm        endsr
     *
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZUPDCnl Delete scanned records
650cA*
650cA*----------------------------------------------------------------
650cAC     zzupdCnl      begsr
650cAC                   eval      error = *off
650cA*   Remove any LICUCI records
650cA /free
650cA   if moretoscan = *on;
650cA     if *inkj;
650cA       // Delete LICINFO Records
650cA       exsr zzlicinfocan;
650cA
650cA       exsr clr$uciinfo;
650cA
650cA       // warehouse
650cA       $uiWhse = $pwhse;
650cA
650cA       // License
650cA       select;
650cA       when w1ulbl = 'Y';
650cA         $uiLcns = templcns;
650cA       when w2iinv = 'N';
650cA         $uiLcns = templcns;
650cA       other;
650cA         $uiLcns = w3lcns;
650cA       endsl;
650cA
650cA       $dricommand = '*UCIINFO';
650cA       $drisubcmd  = '%CANCEL';
650cA       $drisys2upd = 'D';
650cA       chk4err = *on;
650cA       zmflag  = *off;
650cA       exsr zzzdricop;
650cA       if error;
650cA       endif;
650cA       moretoscan = *off;
650cA       //$puci = ' ';
650cA       w1uci = ' ';
650cA       w3lcns = ' ';
650cA       templcns = ' ';
650cA       //ovrrid = *off;
650cA       //$pexpdt = 0;
650cA       //$pwgt = 0;
650cA       //$pmfgdt = 0;
650cA       //$plot = ' ';
650cA     endif;
650cA   endif;
650cA
650cA   savew2mfdt = 0;
650cA   savew2expd = 0;
650cA   saveexpd = 0;
650cA   savelotc = ' ';
650cA   savewgt = 0;
650cA   saveqty = 0;
650cA /end-free
650cAC     endupCnl      endsr
     *----------------------------------------------------------------
416aA*
416aA*  ZZULNK   Update for LABELNK FILE
416aA*
416aAC     zzulnk        begsr
416aA*
416aA*
416aA*      Write to label link file if Label # was entered.          .
416aA*
     *  $LORD in PARTK2 has batch number for new label.
416aAC                   if        wolbl# <> 0
416aAC     partk2        setll     label2
416aAC                   eval      stop = *off
416aAC                   dou       stop = *on
416aAC     partk2        reade     label2                                 79
416aAC                   if        *in79
416aAC                   eval      stop = *on
416aAC                   else
416aAC                   eval      lllblo = wolbl#
416aAC                   eval      lllbl# = lblbl#
416aAC                   eval      lltrn# = lbtrn#
416aAC                   eval      llqpck = lbqpck
416aAC                   eval      llucod = lbucod
416aAC                   write     llrec
416aAC                   endif
416aAC                   enddo
416aAC                   endif
416aAC     endlnk        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZCHKLCNS  Check for active license
650cA*
650cAC     zzchklcns     begsr
650cAC                   eval      lcnsExists = *off
650cA
650cA*  See if license exists in licactive file.
650cA
650cAC                   exsr      clr$license
650cAC                   eval      $liToLcnsU = *on
650cAc                   select
650cAc                   when      w1ulbl = 'Y'
650cAC                   eval      $liToLcns = templcns
700hDc*                  when      w2iinv = 'N'
700hMc                   when      rdiinv = 'N'
650cAC                   eval      $liToLcns = templcns
650cAc                   other
650cAC                   eval      $liToLcns = w3lcns
650cAc                   endsl
650cAC                   eval      $dricommand = '*LICENSE'
650cAC                   eval      $drisubcmd  = '%GETLCNS'
650cAC                   eval      $drisys2upd = 'D'
650cAC                   eval      chk4err = *off
650cAC                   eval      zmflag  = *off
650cAC                   exsr      zzzdricop
650cAC                   if        error
700hA * if error means license is not in licactive.
700hA * still need to check license file
700hA /free
700hA   chain ($pwhse: $liToLcns) license;
700hA   if %found(license);
700hA     lcnsExists = *on;
700hA     error = *on;
700hA     *in43 = *on;
700hA     errmsg= desc(12);
700hA     exsr zm02;
700hA     leavesr;
700hA   endif;
700hA /end-free
700hA * still need to check liclog file
700hA*
700hA*  Check LICLOG before accepting this license
700hA*
700hAC                   eval      $liToLcnsU = *on
700hAC                   eval      $liToLcns = $liToLcns
700hAC                   eval      $liOLcnsU = *on
700hAC                   eval      $liOLcns = $liToLcns
700hAC                   eval      $dricommand = '*LICENSE'
700hAC                   eval      $drisubcmd  = '%GETINFO'
700hAC                   eval      $drisys2upd = 'D'
700hAC                   eval      chk4err = *off
700hAC                   exsr      zzzdricop
700hAc* if we get an ok on the return this means it exist - don't use
700hAC                   if        $drireturn = '*OK'
700hAC                   eval      error = *on
700hAC                   eval      *in43 = *on
700hAc                   eval      lcnsExists = *on
700hAC                   eval      errmsg= desc(12)
700hAC                   exsr      zm02
700hAc                   leavesr
700hAc                   endif
710dA*
710dA*  Check LICINFO before accepting this license
710dA*
710dAc                   if        error = *off
710dAC                   exsr      clr$licinfo
710dAC                   eval      $lnwhse  = $pwhse
710dAC                   eval      $lnlcns = $LITOLCNS
710dAC                   eval      $dricommand = '*LICINFO'
710dAC                   eval      $drisubcmd  = '%GET'
710dAC                   eval      $drisys2upd = 'D'
710dAC                   exsr      zzzdricop
710dAc* if it exist don't allow to use
710dAC                   if        $drireturn = '*OK'
710dAC                   eval      error = *on
710dAC                   eval      *in43 = *on
710dAc                   eval      lcnsExists = *on
710dAC                   eval      errmsg= desc(12)
710dAC                   exsr      zm02
710dAc                   leavesr
710dAC                   endif
710dAC                   endif

650cAC                   eval      lcnsExists = *off
650cAC                   eval      error = *off
650cAC                   leavesr
650cAC                   else
650cAC                   eval      lcnsExists = *on
650cAC                   eval      error = *on
650cAC                   eval      *in43 = *on
650cAc                   eval      errmsg= desc(12)
650cAc                   exsr      zm02
650cAC                   endif
650cA
650cA
650cAC                   endsr
650cA*
650cA*  ZZUCI    Write UCI data
650cA*
650cAC     zzuci         begsr
650cAc                   if        $ldecvalue = ' '
650cAc                   exsr      zzmfrdates
650cAc                   endif
650cAC                   if        $immflg = 'Y'
650cA*
650cA*  Calculate Expiration date.(Mfg date + Mfg Shelf life days-User days)
650cA*
650cA
650cAC                   eval      $cvcmd = '*MDYCMD '
650cAC                   move      w2mfdt        $cvd6i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
650cAC                   move      $cvd8o        expd
650cAC                   move      $cvd8o        womfdt
650cA
650cAC*                  if        client = Glazier
650cAC*                  eval      $imuday = *zeros
650cAC*                  endif
650cA
650cAC                   call      'CLCDUR2'
650cAC                   parm      '*ADD'        $cdcmd
650cAC                   parm      expd          $cddatein
650cAC                   parm      0             $cdtimein
650cAC                   parm      0             $cdyears
650cAC                   parm      0             $cdmonths
650cAC                   parm      $immday       $cddays
650cAC                   parm      0             $cdhours
650cAC                   parm      0             $cdminutes
650cAC                   parm      0             $cdseconds
650cAC                   parm      0             $cddateout
650cAC                   parm      0             $cdtimeout
650cA
650cAC                   call      'CLCDUR2'
650cAC                   parm      '*SUB'        $cdcmd
650cAC                   parm      $cddateout    $cddatein
650cAC                   parm      0             $cdtimein
650cAC                   parm      0             $cdyears
650cAC                   parm      0             $cdmonths
650cAC                   parm      $imuday       $cddays
650cAC                   parm      0             $cdhours
650cAC                   parm      0             $cdminutes
650cAC                   parm      0             $cdseconds
650cAC     expd          parm      0             $cddateout
650cAC                   parm      0             $cdtimeout
650cA
650cAC                   eval      $cvcmd = '*CMDMDY '
650cAC                   move      expd          $cvd8i
650cAC                   call      @cvtdt
650cAC                   parm                    $cvtdt
650cAC                   move      $cvd6o        w2expd
650cA
650cA*
650cAC                   endif
650cA* add records to uci file
650cA*
650cA /free
650cA   // need to determine if the licinfo record already exist for
650cA   // this lcns/lot/exp date - keep checking until we find a match
650cA   // or no more licinfo records exist - if no match and no licinfo
650cA   // exist need to write the next available seq# to licinfo.
650cA   // if licinfo record exist - just update the qty and the weight
650cA   select;
650cA     when moretoscan = *on and difflot = *on  or
650cA          moretoscan = *on and diffexpd = *on;
650cA       exsr zzlicinfochk;
650cA     when moretoscan = *on and difflot <> *on and diffexpd <> *on;
650cA       exsr zzlicinfoseq;
650cA   endsl;
650cA
650cA   if licinfoupd <> *on and difflot = *on or
650cA      licinfoupd <> *on and diffexpd = *on or
650cA      moretoscan <> *on;
          // do not write a licinfo record if the templcns is NS+job#
650cA     eval checklcns = 'NS' + #jobn;
650ca     //if templcns <> checklcns;
650cA       exsr zzlicinfonew;
650ca     //endif;
650cA   endif;
650cA
650cA   exsr clr$uciinfo;
650cA   $uiWhse = $pwhse;
650cA   $uiItem = $pitem;
650cA   $uiuci = w1uci;
650cA   ucilic#($unext: $pwhse);
650cA   unexta = %editc($unext:'X');
650cA   $uiuciLcns = 'U:' + unexta;
650cA   select;
650cA   when w1ulbl = 'Y';
650cA     $uiLcns = templcns;
650cA   when w2iinv = 'N';
650cA     $uiLcns = templcns;
650cA   other;
650cA     $uiLcns = w3lcns;
650cA   endsl;
650cA   if difflot = *on or
650cA     diffexpd = *on;
650cA     $uiseq = $lnseq;
650cA   else;
650cA     $uiseq = 1;
650cA   endif;
650cA   $uiSerial = $bcSer#;
650cA   // if user entered weight use that/ if uci had weight use that
650cA   select;
700eD     //when w1cwtr > 0;
700eM     when w1cwtr > 0 and kilolbs = 'P';
700eD       //$uiwgtlbs = w1cwtr;
700eM       $uiwgtlbs = cnvwgt;
650cA     when $bcPNtLbSent = *on;
650cA       $uiwgtlbs = $bcPNtLb;
650cA     other;
650cA       $uiwgtlbs = 0;
650cA   endsl;
650cA   // Weight KG  - only if uci barcode contained KG
700eA   // 700e metric changes - if item options weight uom = kgs
700eM   select;
700eA     when IMkilolbs = 'K';
700eA       select;
700eA         when w1cwtr > 0 and kilolbs = 'K';
700eA           $uiwgtkgs = cnvwgt;
700eA         when w1cwtr > 0 and kilolbs = 'P';
700eA           $uiwgtkgs = cnvwgt;
700eA         when $bcPNtkgSent = *on;
700eA           $uiwgtkgs = $bcPNtkg;
700eA         other;
700eA           $uiwgtkgs = 0;
700eA       endsl;
700eA     other;
650cA       if $bcPNtKgSent = *on;
650cA         $uiWgtKgs = $bcPntKg;
650cA       else;
650cA         $uiWgtKgs = 0;
650cA       endif;
700eA   endsl;
650cA   $uiSelTrn# = 0;
650cA   $uiSelLbl# = 0;
650cA   $uiSelOrd = 0;
650cA   $uiSelSeq = 0;
650cA   $uiSelCSeq = 0;
650cA   $uiSelTrax = ' ';
650cA   $uiCrtBy = '2';
720iA   $uiaUTyp = uputyp;
720iA   $uiaSlUTyp = uputyp;
720iA   if $bcGTin = *blanks;
720iA      $uiaGtin = 0;
720iA   else;
720iA      $uiaGtin  = %DEC($bcGTin:14:0);
720iA   endif;
720iA   $uiaLot   = $bclot;
720iA   if saveexpd = 0;
720iA      $uiaExpD = expd;
720iA   else;
720iA      $uiaExpD = saveexpd;
720iA   endif;
720iA   $uiaExpD  = expd;
720iA   $uiaEntD  = today;
720iA   // Lets add some more stuff for tracking
720iA   if rdiinv = 'Y';
720iA     $uiaction = 'RTN';
720iA   else;
720iA     $uiaction = 'RTNNOSTK';
720iA   endif;
720iA   $uiaolcns = $uilcns;
720iA   $uialcns = $uilcns;
720iA   $uiaoseq = $uiseq;
720iA   $uiscan = 'Y';
650cA
650cA   $dricommand = '*UCIINFO';
650cA   $drisubcmd  = '%ADD';
650cA   $drisys2upd = 'D';
650cA   chk4err = *on;
650cA   zmflag  = *off;
650cA   exsr zzzdricop;
650cA   if error;
650cA     uciExists = *on;
650cA     error = *on;
650cA     errmsg= desc(13);
650cA     exsr zm02;
650cA     leavesr;
650cA   else;
650cA     UciExists = *off;
650cA     error = *off;
740hA     scan = scan + 1;
650cA   endif;
650cA
650cA   // save the values from the first scan to be used for the license
650cA   if moretoscan <> *on;
650cA     if $immflg = 'Y';
650cA       savew2mfdt = w2mfdt;
650cA     endif;
650cA     if $itflgd = 'Y';
650cA       savew2expd = w2expd;
650cA     endif;
650cA     saveexpd = expd;
650cA     savelotc = w2lotc;
650cA   endif;
700eD   //savewgt  = savewgt + w1cwtr;
700eM   savewgt  = savewgt + cnvwgt;
650cA   saveqty  = saveqty + 1;
650cA   // scan some more uci barcodes
650cA   // save first scanned lot and dates
650cA   moretoscan = *on;
740iA   cwtck = '0';
650cA   exsr scr04i;
650cA   //$puci = ' ';
650cA   w1uci = ' ';
650cA   //ovrrid = *off;
650cA   difflot = *off;
650cA   diffexpd = *off;
650cA   lotwarn = *off;
650cA   expdwarn = *off;
650cA   lotovr  = *off;
650cA   expdovr  = *off;
650cA   licinfoupd = *off;
650cA
650cA /end-free
650cAc
650cAC     enduci        endsr
     *----------------------------------------------------------------
416kA*
416kA*  ZZUMFR   Update for POMFR FILE
416kA*
416kAC     zzumfr        begsr
416kA*
416kAC                   if        w2mfdt <> 0  or
416kAC                             w2expd <> 0
416kA**         W1EXPD    IFNE 0
416kAC     partk2        setll     label2
416kAC                   eval      stop = *off
416kAC                   dou       stop = *on
416kAC     partk2        reade     label2                                 79
416kA**         LBKEY     READELABEL2                   79
416kAC                   if        *in79
416kAC                   eval      stop = *on
416kAC                   else
500dAC     lblbl#        chain     pomfr1                             78
416kAC                   eval      pmwhse = $pwhse
416kAC                   eval      pmpo = *blanks
416kAC                   eval      pmseq = 0
416lD**                   MOVE $PITEM    PMITEM
416lMC                   if        w1citm <> *blanks
416lMC                   eval      pmitem = w1citm
416lMC                   else
416lMC                   eval      pmitem = $pitem
416lMC                   endif
416kAC                   eval      pmexpd = expd
416kA**                   Z-ADD$REXPD    PMEXPD
416kAC                   if        w2mfdt <> 0
416kAC                   move      w2mfdt        $cvd6i
416kAC                   eval      $cvcmd = '*MDYCMD '
416kAC                   call      @cvtdt
416kAC                   parm                    $cvtdt
416kAC                   eval      pmmfgd = $cvd8o
416kAC                   else
416kAC                   eval      pmmfgd = 0
416kAC                   endif
416kAC                   eval      pmtrn# = lbtrn#
416kAC                   eval      pmlbl# = lblbl#
500dAC                   if        *in78  = *off
500dAC                   update    pmrec
500dAC                   else
416kAC                   write     pmrec
500dAC                   endif
416 A*
416kAC                   endif
416kAC                   enddo
416kAC                   endif
416kA*
416kAC                   endsr
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
     *
     C                   eval      *in94 = *off
     C                   eval      *in93 = *off
     C     itkey         chain     piritem                            75
     C                   if        *in75
     C                   eval      *in94 = *on
     C                   eval      *in93 = *on
600bAC                   eval      itum2 = ' '
600bAC                   eval      itumq2 = 0
600bAC                   eval      itum3 = ' '
600bAC                   eval      itumq3 = 0
640dAC                   eval      ititem = *blanks
640dAC                   eval      itdesc = *blanks
640dAC                   eval      itpdsc = *blanks
     C                   goto      enduom
     C                   else
     C                   if        itflg1 = 'N'
     C                   eval      *in94 = *on
     C                   endif
     C                   if        itflg2 = 'N'
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
     C     itum1         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
600bDC**                 if        not *in94
     C     itum2         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
600bDC**                 endif
     *
600bDC**                 if        not *in93
     C     itum3         chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
600bDC**                 endif
412 A*
412 AC                   if        ittype = 'S'
412 AC                   eval      itum1 = itum2
412 AC                   eval      itum2 = itum3
412 AC                   eval      itum3 = *blanks
412 AC     itum1         chain     unmesr                             75
412 AC                   if        not *in75
412 AC                   eval      w1um1 = umshrt
412 AC                   else
412 AC                   eval      w1um1 = *blanks
412 AC                   endif
     *
412 AC     itum2         chain     unmesr                             75
412 AC                   if        not *in75
412 AC                   eval      w1um2 = umshrt
412 AC                   else
412 AC                   eval      w1um2 = *blanks
650aAc                   eval      *in94 = *on
412 AC                   endif
     *
412 AC                   endif
     *
     C     enduom        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZUPCCK  Update for screen 1.
650cA*
650cAC     zzupcck       begsr
650cAC                   select
650cA*  UPC entered
650cAC                   when      w1uci <> ' '
650cAc                             and not $bcai99sent
650cA*
650cAC                   eval      $cbcmd = '*UPC    '
650cAC                   movel     w1uci         $cbbar
650cAC                   call      'CVTBAR'
650cAC                   parm                    $cbcmd            8
650cAC                   parm                    $cbbar          100
650cAC                   parm                    $cbcod            3 0
650cAC                   parm                    $cbdec            1 0
650cAC                   parm                    $cbdsc           30
650cAC                   parm                    $cbpos            3 0
650cAC                   parm                    $cbtyp            1 0
650cAC                   parm                    $cbv1            11 3
650cAC                   parm                    $cbv2            50
650cAC                   parm                    $cbrtn            8
650cAC                   parm                    $cberm           60
740bAC                   parm      $itven#       $cbven           10 0
740bAC                   parm                    $cvtdata
740bAC                   parm                    $cvtdata2
740bAC                   parm      w1whse        $cbwhse           3 0
740bAC                   parm                    $cbsent           1
740bAC                   parm                    $cbitem          15
650cAC                   if        $cbrtn = '*OK'
650cAC                   eval      ckupc = $cbv2
650cAC                   endif
650cA*
650cA*
650cA*   Right adjust UPC code for file.
650cA*
650cAC                   eval      $cstr = *blanks
650cAC                   movel     ckupc         $cstr
650cAC                   call      'ADJUST'
650cAC                   parm      '*RIGHT  '    $ccmd             8
650cAC                   parm                    $cstr            30
650cAC                   move      $cstr         kyupc
650cA*   Check if mulitple items exist for one UPC code.
650cA*    UPCCTR = 0, error, upc code not found.
650cA*    UPCCTR = 1, only one upc found, process for item.
650cA*    UPCCTR > 1, multiple upc found, need to select item.
650cAC                   eval      upcctr = 0
650cAC     upckey        setll     upc
650cAC                   dow       forevr = forevr
650cAC     upckey        reade     upc                                    79
650cA*
650cAC                   if        *in79
650cAC                   leave
650cAC                   else
650cAC                   add       1             upcctr
700eA
700eA /free
700eA   // during uci scanning, if we find upitem = $pitem
700eA   // set upcctr = 1 and get out.
700eA   // don't want to display the uc920 list after the first time
700eA   if moretoscan = *on;
700eA     if upitem = $pitem;
700eA       upcctr = 1;
700eA       leavesr;
700eA     endif;
700eA   endif;
700eA /end-free
650cAC                   endif
650cA*
650cAC                   enddo
650cA*
650cAC                   if        upcctr = 0
650cAC                   eval      error = *on
650cAC                   eval      *in25 = *on
650cAC                   eval      *in05 = *on
650cAC                   eval      errmsg = *blanks
650cAC                   exsr      zm29
650cAC                   goto      endupcck
650cAC                   endif
650cA*
650cA*   Multiple items exist for UPC
650cAC                   if        upcctr > 1
650cAC                   eval      $lcmd = '*VERIFY '
650cAC                   eval      $lwhse = $pwhse
650cAC                   eval      $lupc = kyupc
650cAC                   call      'UC920'
650cAC                   parm                    $lparm
650cAC                   if        $lrtn = '*ERROR  '
650cAC                   eval      error = *on
650cAC                   eval      *in25 = *on
650cAC                   eval      *in05 = *on
650cAC                   movel     $lerm         errmsg
650cAC                   exsr      zm0105
650cAC                   else
650cAC                   if        $lrtn = '*PGMQ   '
650cAC                   eval      error = *on
650cAC                   eval      *in25 = *on
650cAC                   eval      *in05 = *on
650cAC                   eval      #msgk = $lmsg
650cAC                   exsr      zmqmsg
650cAC                   endif
650cAC                   endif
650cAC                   eval      upitem = $litm1
650cA*
650cAC                   endif
650cA*
650cAC                   endsl
650cAc     endupcck      endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
416g C                   eval      woulbl = w1ulbl
     *
416b *    Code to enter license and putaway was moved to ZZUPD2
     *
     *
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
640jAc                   if        $ldecvalue = ' '
640jAc                   exsr      zzmfrdates
640jAc                   endif
600aA* Move mfg or expire or fifo date to keyed in date field
600aA* to send to PO236
600aAC                   eval      woindt = 0
600aAC                   select
600aAC                   when      wofifo <> 0
600aAC                   eval      woindt = wofifo
600aAC                   when      womfdt <> 0
600aAC                   eval      woindt = womfdt
600aAC                   other
600aAC                   eval      woindt = woexdt
600aAC                   endsl
417hA*
416b *    Code to enter license and putaway moved from ZZUPD1
     *
416b *    Get license options.
     C                   exsr      zzlcns
     *
530a *    Check if Dept is live.
530a *    Moved check to ZZCHK1.
530a C*                  call      'CHKLIVE'
530aAC*                  parm                    itwhdp
530aAC*                  parm                    livestat          8
     *
416b C                   eval      $lpo = *blanks
416bDC*                  if        w2iinv = 'N'
530aMC                   if        w2iinv = 'N' or
530aAC                             livestat = '*NOTLIVE'
416b C                   movel     '*NOSTOCK'    $lpo
750aAC                   eval      pltlcns = ' '
416b C                   eval      lcnflg = *off
416gMC                   eval      woulbl = 'N'
416b C                   endif
EGFdA*  If EGF, check for NOITM, create adjustment.
EGFdAC                   if        client = egf and
EGFdAC                             w1dcde = 'NOITM' and
EGFeAC                             livestat <> '*NOTLIVE'
EGFdAC                   eval      lcnflg = *off
EGFdAC                   eval      woulbl = 'N'
500a *       Write adjustment for ordered item.
EGFdAC                   eval      ajcode = 'NI'
EGFdAC                   eval      kyitem = $pitem
EGFdAC                   exsr      fill$adj
EGFdAC                   eval      $dricommand = '*SLOT'
EGFdAC                   eval      $drisubcmd  = '%ADJUSTRTN'
EGFdAC                   eval      $drisys2upd = 'D'
EGFdAC                   exsr      zzzdricop
EGFdAC                   goto      EGF1
EGFdAC                   endif
     *
416b *  If mispick, create put away for corresponding (physical) item,
416b *  If mispick will impact inventory, force license entry.
416b C                   if        w1citm <> *blanks
416b C                   eval      $litem = w1citm
416b C                   if        w2iinv = 'Y'
530d C                             and livestat <> '*NOTLIVE'
416b C                   eval      lcnflg = *on
416g C                   eval      woulbl = 'N'
416b C                   endif
416b C                   else
416b C                   eval      $litem = $pitem
416b C                   endif
     *
     *
416b *      Enter license if LCNFLG is on.                            .
416b *
416b C                   if        lcnflg = *on  and
416gMC                             woulbl = 'N'
710eDc**                           or usegeneric = *off and
710eDC**                           woulbl = 'N'
416bD*R         WOLBL#    ANDEQ0
416b C                   eval      $lcmd = '*CHANGE '
416b C                   eval      $lwhse = $pwhse
416BD***                  MOVE *BLANKS   $LPO
416bD***                  MOVE $PITEM    $LITEM
720dAc                   if        w1citm <> ' '
720dAC                   eval      $lrq1 = w1qm01
720dAC                   eval      $lrq2 = w1qm02
720dAc                   eval      $lrq3 = w1qm03
720dAc                   else
416b C                   eval      $lrq1 = w1qt01
416b C                   eval      $lrq2 = w1qt02
416b C                   eval      $lrq3 = w1qt03
720dAc                   endif
416b C                   z-add     w1plts        $lrpal
415bMC                   eval      $lord = $pord
415bD*R                   Z-ADD0         $LORD   70
700eA /free
700eA   if $ifrcvmth = '2' or $ifsltmth = '2';
700eA     lcnswgt = w1cwtr;
700eA   else;
700eA     lcnswgt = cnvwgt;
700eA   endif;
700eA /end-free
416b C                   call      'RN246'
416b C                   parm                    $lparm
416b C                   parm                    $lord
600aAC                   parm                    wolbl#
700eDC*                  parm                    w1cwtr
700eMC                   parm                    lcnswgt
600aAC                   parm                    wodktexpd
600aAC                   parm                    woindt
600aAC                   parm                    wofifo
640jAc                   parm                    $ldecvalue
640jAC                   parm      mexpd         $lmfgex           8 0
640jAC                   parm      mfgdte        $lmfgdt           8 0
650bAC                   parm                    $lsavetrn
650cAC                   parm                    w3lcns
650cAC                   parm                    w2lotc
650dAC                   parm                    $bcGtin
650dAC                   parm                    $lbcProdD
650dAC                   parm                    $bclot
650eAc                   parm      w2pti         $pw2pti
750bAc                   parm                    pltlcns
750bAc                   parm                    hldpicklbl
416b C                   if        $lrtn = '*CANCEL '
416b C                   eval      nxtscr = '02 '
416b C                   eval      refrsh = *on
416b C                   exsr      scr02i
416b C                   goto      endup2
416k C                   else
650bAc                   eval      rcvrtncomplete = *on
416k C                   exsr      zzumfr
650cAc                   eval      savelotc = ' '
650cAc                   eval      savew2expd = 0
650cAc                   eval      savew2mfdt = 0
650cAc                   eval      saveexpd = 0
650cAc                   eval      savewgt  = 0
650cAc                   eval      saveqty  = 0
650cAc                   eval      moretoscan = *off
650cAc                   eval      w3lcns = ' '
700fAc                   eval      templcns = ' '
700gDc*                  eval      $barcode = ' '
700gDc*                  eval      $barcode2 = ' '
650kDc*                  eval      w1cwtr = 0
650dAc                   eval      w2expd = 0
650dAc                   eval      w2mfdt = 0
650dAc                   eval      w2lotc = ' '
650dAc                   eval      w1uci  = ' '
650dAc                   clear                   $barcode
650dAc                   clear                   $barcode2
416b C                   endif
416aA*
415aAC                   else
415aA*
415aAC                   eval      $lcmd = '*CHANGE '
415aAC                   eval      $lwhse = $pwhse
416BD***                  MOVE *BLANKS   $LPO
416BA***                  MOVE $PITEM    $LITEM
720dAc                   if        w1citm <> ' '
720dAC                   eval      $lrq1 = w1qm01
720dAC                   eval      $lrq2 = w1qm02
720dAc                   eval      $lrq3 = w1qm03
720dAc                   else
415aAC                   eval      $lrq1 = w1qt01
415aAC                   eval      $lrq2 = w1qt02
415aAC                   eval      $lrq3 = w1qt03
720dAc                   endif
415aAC                   z-add     w1plts        $lrpal
415bAC                   eval      $lord = $pord
650cAc                   eval      w3lcns = templcns
415bD*R                   Z-ADD0         $LORD   70
700eA /free
700eA   if $ifrcvmth = '2' or $ifsltmth = '2';
700eA     lcnswgt = w1cwtr;
700eA   else;
700eA     lcnswgt = cnvwgt;
700eA   endif;
700eA /end-free
415aAC                   call      'RN246L'
415aAC                   parm                    $lparm
415aA*R                   PARM           $LUM1
415aA*R                   PARM           $LUM2
415aA*R                   PARM           $LUM3
415aAC                   parm                    $lord
600aAC                   parm                    wolbl#
700eDC*                  parm                    w1cwtr
700eMC                   parm                    lcnswgt
600aAC                   parm                    wodktexpd
600aAC                   parm                    woindt
600aAC                   parm                    wofifo
640jAc                   parm                    $ldecvalue
640jAC                   parm      mexpd         $lmfgex           8 0
640jAC                   parm      mfgdte        $lmfgdt           8 0
650bAC                   parm                    $lsavetrn
650cAC                   parm                    w3lcns
650cAC                   parm                    w2lotc
650dAC                   parm                    $bcGtin
650dAC                   parm                    $lbcProdD
650dAC                   parm                    $bclot
650eAc                   parm      w2pti         $pw2pti
750bAc                   parm                    pltlcns
750bAc                   parm                    hldpicklbl
415aAC                   if        $lrtn = '*CANCEL '
415aAC                   eval      nxtscr = '02 '
415aAC                   eval      refrsh = *on
415aAC                   exsr      scr02i
415aAC                   goto      endup2
500cAC                   else
500cAC                   exsr      zzumfr
650bAc                   eval      rcvrtncomplete = *on
650cAc                   eval      savelotc = ' '
650cAc                   eval      savew2expd = 0
650cAc                   eval      savew2mfdt = 0
650cAc                   eval      saveexpd = 0
650cAc                   eval      savewgt  = 0
650cAc                   eval      saveqty  = 0
650cAc                   eval      moretoscan = *off
650cAc                   eval      w3lcns = ' '
700fAc                   eval      templcns = ' '
700gDc*                  eval      $barcode = ' '
700gDc*                  eval      $barcode2 = ' '
700gAc                   clear                   $barcode
700gAc                   clear                   $barcode2
650lDc**                 eval      w1cwtr = 0
650dAc                   eval      w2expd = 0
650dAc                   eval      w2mfdt = 0
650dAc                   eval      w2lotc = ' '
415aAC                   endif
416aAC                   endif
416aA*
416aA*      Write to label link file if Label # was entered.          .
416aA*        Moved code to ZZULNK subroutine.                        .
416aA*
416aAC                   if        wolbl# <> 0
416aAC                   exsr      zzulnk
416aAC                   endif
416bA*      If mispick, create exceptions for item and corresponding  .
416bA*      item.
416bA*      if both items don't have pick slots.
500a C                   eval      exfdis = *blanks
416bAC                   if        w1citm <> *blanks
416d C                   eval      exitem = $pitem
416d C                   eval      excitm = w1citm
416d C                   eval      exerid = 'MISPICK'
500aAC                   exsr      zzpslt
750aAc                   if        pslot = ' '
750aAC                   exsr      zzCRTXDK
750aAc                   endif
700bDC**                 if        picksl = *off
500a C                   movel     '*ORDER'      exfdis
416dAC                   exsr      zzexcp
416dAC                   eval      kyitem = w1citm
416d C                   eval      exitem = w1citm
416d C                   eval      excitm = $pitem
416d C                   eval      exerid = 'MISPICK'
500a C                   movel     '*PUT  '      exfdis
416dAC                   exsr      zzexcp
700bDC**                 else
500a *       Write adjustment for ordered item.
500bAC                   eval      ajcode = 'MO'
500bAC                   eval      kyitem = $pitem
500bAC                   exsr      fill$adj
500bAC                   eval      $dricommand = '*SLOT'
610aDC**                 eval      $drisubcmd  = '%ADJUST'
610aMC                   eval      $drisubcmd  = '%ADJUSTRTN'
500bAC                   eval      $drisys2upd = 'D'
500bAC                   exsr      zzzdricop
500bDC*                  eval      kyitem = $pitem
500bDC*    itkey         chain     piritem                            79
500bDC*                  if        not *in79
500bDC*                  eval      iawhdp = itwhdp
500bDC*                  else
500aDC*                  eval      iawhdp = *blanks
500bDC*                  endif
500bDC*                  eval      iawhse = $pwhse
500bDC*                  eval      iaitem = $pitem
500bDC*                  eval      iadate = today
500bDC*                  time                    iatime
500bDC*                  movel     'RTN'         iaby
500bDC*                  eval      iadisp = oslot
500bDC*                  eval      iacwta = 0
500aA*          W1QT01    MULT -1        IAQTY1
500bDC*                  eval      iaqty1 = w1qt01
500bDC*                  eval      iaqty2 = w1qt02
500bDC*                  eval      iaqty3 = w1qt03
500bDC*                  eval      iacode = 'MO'
500bDC*                  write     iarec
500a *       Write adjustment for physical item.
500a C                   eval      kyitem = w1citm
500bAC                   eval      ajcode = 'MP'
500bAC                   exsr      fill$adj
500bAC                   eval      $dricommand = '*SLOT'
610aDC**                 eval      $drisubcmd  = '%ADJUST'
610aMC                   eval      $drisubcmd  = '%ADJUSTRTN'
500bAC                   eval      $drisys2upd = 'D'
500bAC                   exsr      zzzdricop
500bDC*    itkey         chain     piritem                            79
500bDC*                  if        not *in79
500bDC*                  eval      iawhdp = itwhdp
500bDC*                  else
500bDC*                  eval      iawhdp = *blanks
500bDC*                  endif
500bDC*                  eval      iawhse = $pwhse
500bDC*                  eval      iaitem = w1citm
500bDC*                  eval      iadate = today
500bDC*                  time                    iatime
500bDC*                  movel     'RTN'         iaby
500bDC*                  eval      iadisp = pslot
500bDC*                  eval      iacwta = 0
500aA*          W1QT01    MULT -1        IAQTY1
500bDC*                  eval      iaqty1 = w1qt01 * -1
500bDC*                  eval      iaqty2 = w1qt02 * -1
500bDC*                  eval      iaqty3 = w1qt03 * -1
500bDC*                  eval      iacode = 'MP'
500bDC*                  write     iarec
700bDC**                 endif
416 A*
416dAC                   else
416dAC                   if        woinvf = 'Y'
EGFdAC                             and client <> egf
500a C                   eval      exfdis = *blanks
416d C                   eval      kyitem = $pitem
416d C                   eval      exitem = $pitem
416d C                   eval      excitm = *blanks
416d C                   eval      exerid = 'INVCTRL'
416dAC                   exsr      zzexcp
416dAC                   endif
416dAC                   endif
416b *
EGFd C     EGF1          tag
416b *      Product put away. Write history record and display message.
416b C                   clear                   orrec
416b C                   eval      orwhse = $pwhse
416bAC                   eval      ortrn# = $ptrn#
415bMC                   eval      orord = $pord
415bD*R                   Z-ADD0         ORORD
416b C                   eval      oritem = $pitem
416b C                   eval      orqty1 = w1qt01
416b C                   eval      orqty2 = w1qt02
416b C                   eval      orqty3 = w1qt03
415bD*R                   Z-ADD0         ORCWTR
700eAc                   if        $ifrcvmth = '2' or $ifsltmth = '2'
415bMC                   eval      orcwtr = w1cwtr
700eAC                   else
740bAc                   if        $itcwgt = 'Y'
700eMC                   eval      orcwtr = cnvwgt
740bAc                   else
700eMC                   eval      orcwtr = 0
740bAc                   endif
700eAC                   endif
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cD*R                   Z-ADDTODAY     ORRDTE
417cMC                   eval      orrdte = $cvd8o
416b C                   time                    orrtim
416c C                   if        quick = *on  and
416eAC                             worexq <> 'Y'
417cA*    Retrieve current date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cD*R                   Z-ADDTODAY     ORUDTE
417cMC                   eval      orudte = $cvd8o
416c C                   time                    orutim
416c C                   endif
416b C                   eval      orrusr = wouser
416b C                   eval      ortype = rtntyp
416b C                   eval      ortrn# = w1trn#
416 AC                   eval      orpbat = $lord
416b C                   eval      orcitm = w1citm
416b C                   eval      orrcod = w1code
416b C                   eval      ordcod = w1dcde
416b C                   eval      oriinv = w2iinv
416b C                   eval      orolb# = wolbl#
416b C                   move      w1inv#        orinv#
SGCbA*
SGCbAC                   if        client = sgc
SGCbAC                   eval      orinv# = %replace(w1lktp:orinv#:1:1)
SGCbAC                   endif
CSP A*
CSP AC                   if        client = CoastalSunbelt
CSP A*
CSP AC                   eval      orrmem = w2memo
CSP AC                   exsr      zzgetlnnbr
CSP A*
CSP A*      All other clients.
CSP AC                   else
CSP A*
416b C                   eval      orrmem = w2memo
CSP AC                   endif
CSP A*
416b C                   eval      orslot = *blanks
720aAC                   eval      oroord = woord
PCKfA /free
PCKfA   if client = pack730;
PCKfA     if w2iinv = 'N';
PCKfA       oroord = 0;
PCKfA     endif;
PCKfA   endif;
PCKfA /end-free
416b C                   write     orrec
750dA /free
750dA      GetOptions(%editc(0:'X'):
750dA                 '*FTP': '001': '001': ExportType);
750dA /end-free
750dAC                   if        opread = 'Y' and ExportType = 'R'
750dAc                   eval      $pWhse3A  = %editc($pwhse:'X')
750dAC                   call      'OR737S'
750dAC                   parm                    $pWhse3a
750dAC                   parm                    BatId
750dAC                   parm                    rtnCodex
750dAC                   parm                    rtnMessage
750dAC                   if        BatId <> *blank
750dAC                   eval      haveBatId = *on
750dAC                   endif
750dAC                   endif
     *
530bA*  If return pgm was called by Tracker, TR830, send back cmd *TRKRTN
530bA*  to let TR830 know the return was completed.
640cA*  Also, send back the qty processed for return.
     *
530bAC                   if        $pprg = 'TR830'
530bAC                   eval      $pcmd = '*TRKRTN '
640cAC                   select
640cAC                   when      w1qt01 > 0
640cAC                   eval      $ttqty = w1qt01
640cAC                   when      w1qt02 > 0
640cAC                   eval      $ttqty = w1qt02
640cAC                   when      w1qt03 > 0
640cAC                   eval      $ttqty = w1qt03
640cAC                   endsl
530bAC                   endif
416b *
412bAC                   eval      nxtscr = 'EOJ'
     *
PCK AC*****              if        client = packers
740aDC*                  if        opuci  = 'Y'

740aDC*                  if        itcwgt = 'Y'
740aDc*                  eval      w1qt01p = w1qt01
740aDc*                  eval      w1qt02p = w1qt02
740aDc*                  eval      w1qt03p = w1qt03
740aDc*                  eval      $pcwgt = *zeros
740aDc*                  select
740aDC*                  when      w1qt01 > *zeros
740aDC*                  eval      $lcmd   = '*ADDADJ '
740aDC*                  when      w1qt01 < *zeros
740aDc*                  eval      $lcmd   = '*DLTADJ '
740aDc*                  endsl
740aDC*                  eval      $lwhseu = $pwhse
740aDC*                  eval      $litemu = $pitem
740aDC*                  eval      $lcodeu = w1code
740aDC*                  eval      $ltypeu = 'R'
740aDc*                  eval      $ldate = orrdte
740aDc*                  eval      $ltime = orrtim
740aDC*                  call      @cwght
740aDC*                  parm                    $lparm
740aDC*                  parm                    orpbat
740aDC*                  parm                    w1inv#
740aDC*                  parm                    w1bil#
740aDC*                  parm                    w1dcde
740aDc*                  eval      w1cwtr = $pcwgt
740aDC*                  endif

PCKeA *  Write orrtnm, record.

PCKfA /free
PCKfA   if client = pack730;
PCKfA /end-free
PCKeAc                   eval      rmwhse = $pwhse
PCKeAc                   eval      rmord  = $pord
PCKeAc                   eval      rmitem = $pitem
PCKfDc*                  eval      rmrdte = $ldate
PCKfDc*                  eval      rmrtim = $ltime
PCKfMc                   eval      rmrdte = orrdte
PCKfMc                   eval      rmrtim = orrtim
PCKeAc                   eval      rmpbat = orpbat
PCKeAc                   eval      rmtrn# = $ptrn#
PCKfDc*                  eval      rmrcod = $lcodeu
PCKfMc                   eval      rmrcod = w1code
PCKeAc                   eval      rmdcod = w1dcde
PCKeAc                   eval      rmudte = *zeros
PCKeAc                   eval      rmutim = *zeros
PCKfDc*                  eval      pakrm1_delv = w1inv#
PCKfAc                   eval      pak9 = $pord
PCKfMc                   eval      pakrm1_delv = %editc(pak9:'X')
PCKfAc                   eval      pak7 = woord
PCKfAc                   eval      pakrm1_ordid = %editc(pak7:'X')
PCKeAc***PCKfD           eval      pakrm1_bdoc = w1bil#
PCKfA /free
PCKfA     select;
PCKfA       when %subst(OH5ohmisc:17:4) = '0002';
PCKfA         pakrm1_vkorg = '2100';
PCKfA       other;
PCKfA         pakrm1_vkorg = %char(pckorg);
PCKfA     endsl;
PCKfA   endif;
PCKfA /end-free
PCKeAc                   eval      rmmsc1 = pakrm1_base
PCKeAc                   eval      rmmsc2 = *blanks
PCKeAc                   eval      rmmsc3 = *blanks
PCKeAc                   eval      rmmsc4 = *blanks
PCKeAc                   eval      rmmsc5 = *blanks

PCKeAc                   write     rmrec
740aDC*                  endif
     *
650kAc                   eval      w1cwtr = 0
740dAc                   eval      $perm = 'Return completed'
740dAc                   eval      $prtn = '*OK'
     C     endup2        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZUPD3   Update for screen 3.
650cA*
650cAC     zzupd3        begsr
650cAC                   eval      error = *off
650cAC                   eval      woulbl = w1ulbl
650cA*
650cA*    Code to enter license and putaway was moved to ZZUPD2
650cA*
650cA*
650cA*
650cAC     endup3        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZUPD4   Update for screen 4.
650cA*
650cAC     zzupd4        begsr
650cAC                   eval      error = *off
650cAc                   exsr      zzuci
650cA*
650cAC     endup4        endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZUPD5   Update for screen 5.
650cA*
650cAC     zzupd5        begsr
650cA*
650cAc                   exsr      zzupd2
650cA*
650cAC     endup5        endsr
650cA*----------------------------------------------------------------
650cA*  clr$license  Clear $license data structure fields
650cA*----------------------------------------------------------------
650cA
650cAC     clr$license   begsr
650cAC                   eval      savever# = $liver#
650cAC                   clear                   $license
650cAC                   eval      $liver# = savever#
650cAC                   eval      $liemp# = $emp#
650cAC                   eval      $liuser = #user
650cAC                   eval      $lipgm  = #prog
650cAC                   eval      $lijob  = #job
650cAC                   eval      $lijobn = #jobn
650cAC                   eval      $liTowhse = $pwhse
650cAC                   eval      $liTowhseu = *on
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*  clr$licinfo  Clear $licinfo data structure fields
650cA*----------------------------------------------------------------
650cA
650cAC     clr$licinfo   begsr
650cAC                   eval      savever# = $lnver#
650cAC                   clear                   $licinfo
650cAC                   clear                   $licinfo2
650cAC                   eval      $lnver# = savever#
650cA
650cAC                   eval      $lnuser = #user
650cAC                   eval      $lnemp# = $emp#
650cAC                   eval      $lnpgm  = #prog
650cAC                   eval      $lnjob  = #job
650cAC                   eval      $lnjobnbr = #jobn
650cA
650cAC                   endsr
650cA*----------------------------------------------------------------
650cA*  clr$uciinfo  Clear $uciinfo data structure fields
650cA*----------------------------------------------------------------
650cA
650cAC     clr$uciinfo   begsr
650cAC                   eval      savever# = $uiver#
650cAC                   clear                   $uciinfo
720iAC                   clear                   $uciinfo2
650cAC                   eval      $uiver# = savever#
650cAC                   eval      $uiaddemp = $emp#
650cAC                   eval      $uiaddusr = #user
650cAC                   eval      $uiaddpgm  = #prog
650cAC                   eval      $uiaddjob  = #job
650cAC                   eval      $uiaddnbr = #jobn
650cAC                   endsr
     *----------------------------------------------------------------
500b *  zzzdricop  Call DRICOP
     *----------------------------------------------------------------

500b C     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
730aAC                   eval      $dridata2= $slot2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416cAC                   eval      $dridata2 = $item2
DRYfAC                   when      $dricommand = '*ITEMQTY'
DRYfAC                   eval      $dridata = $itemqty
650cAC                   when      $dricommand = '*LICENSE'
650cAC                   eval      $dridata = $license
650cAC                   eval      $dridata2 = $license2
650cAC                   when      $dricommand = '*LICINFO'
650cAC                   eval      $dridata = $licinfo
650cAC                   eval      $dridata2 = $licinfo2
650cAC                   when      $dricommand = '*UCIINFO'
650cAC                   eval      $dridata = $uciinfo
720iAC                   eval      $dridata2 = $uciinfo2
     C                   endsl

416cAC                   select

416cAC                   when      $dricommand = '*ITEM'
650cAC                             or $dricommand = '*LICENSE'
650cAC                             or $dricommand = '*LICINFO'
720iAC                             or $dricommand = '*UCIINFO'
730aAC                             or $dricommand = '*SLOT'
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

650cDC*                  when      %error
650cMC                   when      chk4err and %error
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
500b C*                  if        zmsflag
500b C*                  exsr      zm0105s
500b C*                  else
     C                   exsr      zm0105
500b C*                  endif

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C*                  if        zmsflag
     C*                  exsr      zm0001s
     C*                  else
650cAc                   if        zmflag
     C                   exsr      zm0001
     C                   exsr      zzerrind
650cAc                   endif
     C*                  endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
730aAC                   eval      $slot2= $dridata2
DRYfAC                   when      $dricommand = '*ITEMQTY'
DRYfAC                   eval      $itemqty = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416cAC                   eval      $item2 = $dridata2
650cAC                   when      $dricommand = '*LICENSE'
650cAC                   eval      $license = $dridata
650cAC                   eval      $license2 = $dridata2
650cAC                   when      $dricommand = '*LICINFO'
650cAC                   eval      $licinfo = $dridata
650cAC                   eval      $licinfo2 = $dridata2
650cAC                   when      $dricommand = '*UCIINFO'
650cAC                   eval      $uciinfo = $dridata
720iAC                   eval      $uciinfo2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C     enddricop     endsr

500b *----------------------------------------------------------------
500b *  fill$adj   Fill $slot data structure fields for adjustment.
500b *----------------------------------------------------------------
500b
500b C     fill$adj      begsr
500b
500b *  Initialize data structure
500b
500b C                   eval      savever# = $slver#
500b C                   clear                   $slot
730aAC                   clear                   $slot2
500b C                   eval      $slver# = savever#
500b
500b *  Move fields from record to data structure.
500b
500b C                   eval      $slwhseu = *on
500b C                   eval      $slwhse  = $pwhse
500b
500b C                   eval      $slwhdpu = *on
500bAC     itkey         chain     piritem                            79
500bAC                   if        not *in79
500bAC                   eval      $slwhdp = itwhdp
500bAC                   else
500bAC                   eval      $slwhdp = *blanks
500bAC                   endif
500b C**                 eval      $slwhdp  = $pwhdp
500b
500b C                   eval      $sldispu = *on
500bAC                   if        ajcode = 'MO'
500b C                   eval      $sldisp  = oslot
500bAC                   else
500b C                   eval      $sldisp  = pslot
500bAC                   endif
500b
500b C                   eval      $saitemu = *on
500b C                   eval      $saitem  = kyitem
500b
500b C                   eval      $saqtyu  = *on
500bAC                   if        ajcode = 'MO' or
EGFdAC                             client = egf and
EGFdAC                             ajcode = 'NI'
500b C                   eval      $saqty1  = w1qt01
500b C                   eval      $saqty2  = w1qt02
500b C                   eval      $saqty3  = w1qt03
500bAC                   else
720dAc                   if        ajcode = 'MP'
720dAC                   eval      $saqty1  = w1qm01 * -1
720dAC                   eval      $saqty2  = w1qm02 * -1
720dAC                   eval      $saqty3  = w1qm03 * -1
720dAc                   else
500bDC                   eval      $saqty1  = w1qt01 * -1
500bDC                   eval      $saqty2  = w1qt02 * -1
500bDC                   eval      $saqty3  = w1qt03 * -1
720dAc                   endif
500bAC                   endif
500b
500b C                   eval      $sacwtau = *on
500b C                   eval      $sacwta  = 0
500b
500b C                   eval      $sacodeu = *on
500b C                   eval      $sacode  = ajcode
500b
500b C                   eval      $samemou = *on
500b C                   eval      $samemo  = ' '
500b
500b C                   eval      $sabyu   = *on
500b C                   eval      $saby    = 'RTN'
700lAC                   eval      $saemp#U = *on
700lAC                   eval      $saemp#  = $emp#
500b
730bDc*                  if        w2iinv = 'N'
730aAC                   eval      $saactionu = *on
730aAC                   eval      $saaction  = 'RTN'
730bDc*                  endif
500b C                   endsr
500b
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Order Number
Quantity Returned
Printer Device
Printer Form
Catch weight
Number of pallets
Use label for putaway
Impact inventory
Coresponding item
Invoice #
Qty Returned must be less or equal to Qty Shipped
License
UCI Barcode
Different Item on UCI
PTI Code
Lookup Type Code
Weight Returning exceeds total weight on Order
Coresponding item Quantity Returned
Return multiple Unit of Measures Separately
Reason code must be 99
Reason code cannot be 99
Corsp item would impact inventory, see supervisor
**  HED
Customer Returns
Transfer Returns
POS Returns
Quick Returns Putaway
**  CMDLN - Command display line 700e
F3=Exit  F4=Prompt  F5=Refresh  F7=Kilogram  F9=UOM  F12=Cancel  F20=Accept Wrn
F3=Exit  F4=Prompt  F5=Refresh  F7=Pounds    F9=UOM  F12=Cancel  F20=Accept Wrn
F3=Exit  F4=Prompt  F5=Refresh  F9=UOM  F12=Cancel  F20=Accept Warn
F3=Exit  F7=Kilogram  F12=Cancel  F20=Ovdrride  F22=Complete License
F3=Exit  F7=Pounds  F12=Cancel  F20=Ovdrride  F22=Complete License
F3=Exit  F12=Cancel  F20=Ovdrride  F22=Complete License
F3=Exit  F4=Prompt  F5=Refresh  F7=Kilogram  F9=UOM  F12=Cancel
F3=Exit  F4=Prompt  F5=Refresh  F7=Pounds    F9=UOM  F12=Cancel
F3=Exit  F4=Prompt  F5=Refresh  F9=UOM  F12=Cancel
