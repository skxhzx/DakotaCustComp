500dA /Copy qcopysrc,hspecs
     H dftactgrp(*NO)
     H actgrp(*CALLER)
750fAH bnddir('QC2LE':'QUSAPIBD':'BFCBND': 'YAJL')
      *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   (BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  OR400     RF Order Selection
     *  17 January, 2006
     *  Roxanne Harrison
     *
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *       Created using RC300.
     *       Uses PIRVOICE QCOPYSRC.
     *
     *  Revisions
     *
500 A*    01/17/06  RH   5.00
     *      - Created
500bA*    05/16/06  RH   5.00b
     *      - Fix: Set W4UPCD UPC value to send to VOSELECT
     *
500cA*    05/18/06  DAS  5.00c
     *      - Fix: In routine ZZCHK7, removed check to see if the
     *        "Individual catch weight entry" option (OPICW) is "Y".
     *        Since catchweights are entered one at a time, we want
     *        the program to assume this option is 'Y'.
     *
500dA*    05/19/06  DAS  5.00d
     *      - Fix: Moved get user logic from ZZINZ to ZZINZ2.
     *      - Revised SCREEN6 to use nxtscr '06A' instead of '10 '.
     *      - Added SCREEN10.
     *      - Revised to display SCREEN10 for invalid user.
     *      - Added logic to write records to bfcsktlog file.
     *      - Revised to set on LR before leaving.
500eA*    05/19/06  RH   5.00e
     *      - Fix: Verify transaction if open in ZZCHK1.
500fA*    05/23/06  RH   5.00f
     *      - Fix: Check for started transactions each time.
500gA*    05/23/06  RH   5.00g
     *      - Fix: Correct ZZUPD5 to display SC6 after license entered
500hA*    05/25/06  RH   5.00h
     *      - Fix: Correct ZZUPD7 to send the individual CW range to
     *        VOSELECT to create the CW exception.
510aA*    10/09/06  RH   5.10a
     *      - Enh: Display SC6B to verify pick with UPC if UPC entered
     *        on Screen4.
510bA*    10/09/06  RH   5.10b
     *      - Fix: Verify SC6B UPC is for label item.  The slot may have
     *        multiple UPC codes for the same item in the same slot.
520aA*    04/17/09  GJA  5.20a
     *      - Enh: Add RF verify slot option  OPRFSL
520bA*    04/17/09  DAS  5.20b
     *      - Enh: Initialized $slceiseq#
     *      - Enh: Revised to display 'Error occurred in VOSELECT'
     *        in some cases.
     *      - Enh: Added F10=Short to cwgt entry screen7.
520cA*    06/17/09  RH   5.20c
     *      - Fix: Correct position of OPRFSL, should be 17.
     *      - Enh: Add error for item/dept not allowed to scan.
520dA*    06/25/09  GJA  5.20d
     *      - Fix: If F10 on screen 7, need to reduce qty by 1 because
     *        the quantity is not picked
530aA*    10/04/10  RH   5.30a
     *      - Enh: Change to use GETITEMFLD to get info from ITEMFLD
     *        in place of chaining so program can use 5.20 or 6.10
     *        version of ITEMFLD file.
640aA*    11/07/11  RH   6.40a
     *      - Fix: Change catch weight OPWRNC to use updated options
640b *    03/19/12  GJA  6.40b
     *      - Enh: Increase label entry to 10 positions for Trax.
650aA*    11/11/13  LMC  6.50a
     *      - Enh: Added change slot ability to screen3.
     *        Rename display file from OR40002 to OR40003.
     *        Added suspend function.
     *        ****** NOTE *******
     *        The suspend function requires the
     *          Tote/Box/Drop Functionality be turned on in OP510.
650bA*    11/26/13  LMC  6.50b
     *      - Enh: Added UCI Selection - Screen6D.
     *        Rename display file from OR40003 to OR40004.
     *        F11 - change slot is now conditioned on gen pick option
     *        F12 - added to Screen4,Screen5 and all Screen6 versions.
     *        On screen6 versions once scanning or qty has started F12
     *        is no longer allowed to be used.
650cA*    12/17/13  LMC  6.50c
     *      - Enh: Added INDTASK.
     *        Rename display file from OR40004 to OR40005.
     *        ****** NOTE *******
     *        The INDTASK functions requires the
     *          Tote/Box/Drop Functionality be turned on in OP510.
650dA*    02/12/14  MLB  6.50d
     *      - Fix: Revised routine ZZCHK7 to add test for error code on
     *        return from VOSELECT <> 002 for valid wgt. Error code 002
     *        means that a non-GS1 value was scanned.
650eA*    02/17/14  LMC  6.50e
     *      - Fix: Clear $newsl if return from OR401 with cancel.
700aA*    08/11/15  RH   7.00a
     *      - Enh: Allow selected slot to have less stock than qty on
     *        order.  Must press F10 to short balance, runner can get.
     *        rename format to OR40007, enable F8 on Screen 3.
     *        Force user to scan new selected slot on Screen 3.
700b *    02/23/16  NK/GJA 7.00b
     *      - Enh: Call to VOSELECT SCANCWT did not populate the label
700c *    03/30/16  RH/LMC 7.00c
     *      - FIx: Initialize $slvsoloqavl = 0, blank was causing
     *        decimal data error if f11 not used.
     *        Only do edit for overflow slot pick not greater than
     *        available.
700d *    03/31/16  MR     7.00d
     *      - Enh: Rename OR40007 to OR40008
     *      - Enh: Add Pounds/Kilograms functionality
700e *    05/19/16  LMC    7.00e
     *      - FIx: When license is skipped display qty entry screen
     *        if RF Pick Allow Qty Entry is Y.
700f *    09/13/16  MR      700f
     *      - Enh: Rename display OR40008 to OR40009.
     *      - Enh: Add Functionality for Pick process to
     *             direct selection like VOSELECT does.
700g *    10/05/16  GJA     700g
     *      - Enh: Rename display OR40009 to OR40010.
700h *    10/12/16  GJA     700f
     *      - Enh: Rename display OR40010 to OR40011.
     *             Add F10=Short function to screen12
700i *    10/27/16  MR      700i
     *      - Remove VOSELECT and loop through label
     *        records looking for picked label.
700j *    11/09/16  MR      700j
     *      - Add @apics call to zzchk12 routine.
700k *    11/10/16  LMC     700k
     *      - Fix: ZZCHK6 was going thru the driuciinfo check from mod
     *        700f even if the client is set to RF Pick Method=Manual
     *        The w6uci field is only populated when RF Pick Method=
     *        Directed. So the edit was failing with UCI cannot be
     *        blank. Conditioned the uci edit to only take place in
     *        zzchk6 when the client is using Directed RF Pick Method.
700l *    12/01/16  MR      700l
     *      - Fix: Process using wrong error check variable from
     *             VOSELECT when returning from TK901 causing data
     *             decimal error.
700m *    12/22/16  GJA     700m
     *      - Enh: Rename display OR40011 to OR40012.
710a *    01/18/17  LMC     710a
     *      - Fix: changed the oprfqto field to be numeric.
     *      - Fix: Manual RF Pick method was not using the oprfqto
     *        field to determine if the user could enter a qty instead
     *        of scanning each piece.
710b *    02/15/17  MR      710b
     *      - Fix: Allow program to fall through edits on SCREEN12
     *             when formated slot is blank.
710c *    02/20/17  LMC     710c
     *      - Note: This change requires the updated UPC file.        ing
     *        Do not install this change unless you have the new UPC
     *        file and all programs that go with this Database Change
     *      - Enh:  New copy specs RISLVFYUPU & ROSLVFYUPU.
     *              voselect will now be expecting vfyupcuom
710d *    02/21/17  GJA     710d
     *      - Fix:  change status to "1" from "4" so exception will being
     *              processed.                                        ing
     *      - Fix:  change label pick to UCI picked.  Rename OR40013  ing
710e *    06/07/17  TAB     710e
     *      - Enh:  Added check in screen 6D for correct UOM UPC when
     *              picking
710f *    06/27/17  LMC     710f
     *      - Fix:  zzchk6d - should not be doing any 99trax process
     *              removed that code.
710g *    06/30/17  MR      710g
     *      - Fix:  zzchk6/zzchk6a - should not be doing any 99trax
     *              process unless uci is a 99trax label.
710h *    07/20/17  MR      710h
     *      - Fix:  zzchk6 - was not checking if label had already
     *              been selected.
710i *    07/19/17  LMC     710i
     *      - Fix:  Need to pass scanned or entered field w7cwgt
     *              to voselect so the cwlog file is loaded with the
     *              correct scanned value.
710j *    12/14/17  JCJ     710j
     *      - Enh:  Changed to only display the UPC code screen if a
     *              UPC code exits in the UPC file for the item.
720a *    03/05/18  GJA/LMC 720a
     *      - Fix:  Chain was only getting first label to compare
     *              for directed and quantity
720b *    03/20/18  NLK 720b
     *      - Fix:  zzchk12 sslot <> lbdisp giving Wrong slot error
     *              due to virtual slot compared to base slot.
     *              Call drislot to grab Base Slot before this check.
720c *    05/23/18  LMC 720c
     *      - Enh:  Allow for upc scanning logic to be based on global
     *              setting in general picking options or at the item
     *              level by using seletion method 4 or 5.
     *      - Enh:  Use 99TRAXM for merge selection
     *      - Enh:  Added Zone Pickup
     *      - Enh:  Added call to Equipment checkout for belt printer
     *      - Fix:  Override on screen 12 is not allowed.
     *      - Enh:  Base screen15 which allows multiple trans on voice
     *              options.
720d *    07/23/18  LMC 720d
     *      - Enh:  Added the ability to show slot display on screen12
     *      - Enh:  Added the ability to check out pallet jack.
     *      - Enh:  Send indirect flag to tk901.
     *      - Enh:  When scanning a combo we need a different process
     *      - Client wants to direct the user to check their pallet
     *        jack back in. This will be based on a new RF option
     *        in the future. For now we will turn the opeqpj field
     *        on for KOHL, which will in turn seton indicator 61, so
     *        the display file on screen 1 will display an additional
     *        field asking user if they are ending their day.
     *        We will then take the user to EQ410 to check their
     *        equipment back in if they are ending their day.
     *      - Fix:  to eliminate the confusion we are correcting the
     *        command pickrf to picksrf, it is doing the picks logic
     *        in voselect on this command, not the pick logic.
     *      - Fix:  when returning from voselect on the picksrf
     *        command move the return fields into the $slpicksout
     *        not the $slassignout fields.
     *      - Enh: Added short confirmation screen16.
720e *    08/08/18  LMC 720e
     *      - Fix:  Use the w2lbl field for counting unfinished
     *        transaction uci scans.
720f *    08/15/18  LMC 720f
     *      - Enh:  Populate the $slasiunfi field to '1' if the we
     *        have an unfinished transaction.
720g *    09/21/18  LMC 720g
     *      - Enh:  Combo logic didn't exist.
     *        Non Catch weight items will require a qty be entered.
     *        Catch weight items will just scan/enter weights.
720h *    09/20/18  LMC 720h
     *      - Enh:  Added Weigh Later feature.
720I *    09/27/18  LMC 720i
     *      - Fix:  Weight later weight variance logic is not using
     *        the correct fields.
720j *    10/03/18  LMC 720j
     *      - Fix:  Remove the suspend call to voselect when user
     *        chooses to do an indirect task.
     *      - Fix:  If weight later is needed from complete2 voselect
     *        process, we need to use the $slc fields not the $slg
     *        fields in the weight variance.
     *        The $slg fields will be used when the user request the
     *        option to weigh now using f6, where they enter the label
     *        they are going to be procesing for weight entry.
720k *    10/10/18  LMC 720k
     *      - Fix:  This could be temporary until a decision is made
     *        if or400 should handle bulk picks
720l *    11/02/18  LMC 720l
     *      - Enh:  Add ability to create exception for bad upc or no
     *        upc. New screen 20
720m *    12/17/18  LMC 720m
     *      - Enh:  UCI Tracking
720n *    12/21/18  LMC 720n
     *      - Enh:  Add command key to do next slot. Skip current slot
     *      - Enh:  condition f6 on screen7 for done. No more Weights.
     *      - Enh:  Added call to or680 for bulk. Also added new file
     *        BULKWRK to hold bulk transaction number to be used by
     *        OR680 rf bulk pick.
730a *    01/18/19  LMC 730a
     *      - Fix:  fix logic on unfinished transaction
730c *    03/25/19  LMC 730c
     *      - Enh:  When scanning individual upcs, we will still
     *        allow the allow qty over logic to take place.
     *        So if user is selecting from a combo label, we will not
     *        require scanning of each piece, just because indidual
     *        upc verification is turned on.
730d *    03/25/19  GJA 730d
     *      - Enh:  Allow selector to scan a barcode instead
     *              having to press ENTER.  They can still use ENTER
     *              Rename display file OR40019 to OR40020
730e *    04/15/19  GJA 730e
     *      - Enh:  Get stop from RTESTP
     *              Rename display file OR40020 to OR40021
730f *    04/16/19  GJA 730f
     *      - Enh:  Don't ask for UPC if it doesn't exist, if you
     *              have global UPC verification
730g *    04/17/19  GJA 730g
     *      - Enh:  Add UOM on screen 6
     *              Rename display file OR40021 to OR40022
730h *    04/26/19  LMC 730h
     *      - Fix:  mod 730c caused an issue where it never leaves the
     *              slot verification screen if scan individual is on
     *              but we don't allow a qty override.
     *      - Fix:  When bad or no upc - need to still get weights
     *      - Fix:  remove 730f mod from zzupd3, the code was already
     *              there as mod 710j
730i *    04/29/19  LMC 730i
     *      - Fix:  When returning from indirect task, return to the
     *              screen it came from. Should not need to replace
     *              the nxtscr field.
730j *    04/30/19  LMC 730j
     *      - Fix:  Non catch weight items got stuck on bad/no upc
     *              screen. user would have to f12 to get back to
     *              upc screen entry.
730k *    05/02/19  GJA 730k
     *      - Enh:  Allow for the question "Are you ending your day"
     *              to be default so selector can do it instead of
     *              having to use F7=Task
730l *    05/23/19  LMC 730l
     *      - Enh:  Change to the way we handle an unfinished
     *              transaction. The user will be required to start
     *              the selection of the label over, even if they have
     *              already picked some. We will clear the uciinfo file
     *              and the CW if a CW item.
730m *    05/22/19  KDE 730m
     *      - Enh:  Change to use LABEL32D when customer using
     *        softcoded DFPICK (DFPICKDTL)
730n *    06/11/19  LMC 730n
     *      - Fix:  zzupd12 needs to base the next screen on upcyes
730o *    07/05/19  LMC 730o
     *      - Fix:  use w6lbl instead of lblbl# in chk4skipcw
730p *    08/09/19  LMC 730p
     *      - Enh:  Change uom desscription on screen6* to be the
     *        Unit of Measure short description.
730q *    08/09/19  LMC 730q
     *      - Enh:  Added Pick to Weight - SCREEN6E
     *      - Enh:  Added Pick to Weight Delete - SCREEN6F
     *      - Fix:  Slot verification set to N.
730r *    09/19/19  LMC 730r
     *      - Fix:  When using end of day flag first time in a decimal
     *        data error occurred in zzupd1.
730s *    10/03/19  LMC 730s
     *      - Fix:  The wrong klist was being used on the chain to
     *        label90 for the upc verification check.
730t *    10/09/19  LMC 730t
     *      - Fix:  setoff combo flag at vrylabel, otherwise if can
     *        cause a problem with the CW screen7, and get the pick
     *        qty inflated greater than the allocated qty.
730u *    10/10/19  DAS  7.30u
     *      - Added phrase logging.
730v *    10/14/19  LMC  7.30v
     *      - Added pick-to-light.
730w *    10/16/19  LMC  7.30w
     *      - OR400 will now handle bulk picks, no more calling OR680
     *        For now this will be controlled by AllowBulk = on.
     *        We will seton AllowBulk for the clients we wish to use
     *        or400 for bulk, others will still use or680
     *      - Include pristine license logic
     *        Added the auto loading of CW records for UCI/GS1
     *        This process will only execute if the UCI receiving
     *        method on the item is set to UCI Receiving.
     *      - Fix: zzcmd12 - if return from change slot is cancelled
     *        don't move the $slv* fields that were never loaded
740a *    01/22/20  LMC  7.40a
     *      - Enh: Adding logic to handle new selection method 6
     *        UPC Verification Normal UOM only.
     *      - Fix: Make sure selection method 4 & 5 goto the correct
     *        screen6 in zzupd12 if qty entry is turned on.
740b *    02/03/20  LMC  7.40b
     *      - Fix: All chains to label90 in zzupd12 need to use keyl90
     *        klist instead of l90ky.
740c *    03/09/20  LMC  7.40c
     *      - Fix: Weight later catch weight variances were using the
     *        wrong fields. As stated in 720j should be using $SLC
     *        fields.
740d *    03/18/20  LMC  7.40d
     *      - Enh: RF Verify Individual UPC  = Y and
     *             Auto Load weight from UPC  = Y
     *        Need to load up weight for screen7, and only exfmt the
     *        screen if there is an error, or no weight in what was
     *        scanned during vfyupcuom.
     *      - Enh: Issue confirmation screen if user has a suspended
     *        transaction that does not have an exception create.
     *      - Enh: Change pirtran files to use the pirtranw version.
     *        Per email from Dave on 12/9/19.
740e *    03/26/20  LMC  7.40e
     *      - Enh: Added RF Location Verification priority
     *      - Enh: Clear the upc field if verification is skipped
     *        on indivial upc verification screen.
     *      - Removed some code that was not needed.
     *      - Enh: Add all parms to CVTBAR calls.
     *      - Enh: F12 from screen12 will no longer execute zzchk11
     *        This was causing a problem with the slot verification.
740f *    05/12/20  LMC  7.40f
     *      - Enh: When executing command PICKCHG this should only
     *        occur if the oprfcs flag is on. There is an Isupply
     *        mod that uses the same field positions in $prtky
     *        so the $newsl had a value and caused the pckchg to occur
740g *    05/30/20  DAS  7.40g
     *      - Enh: Added zone override for RF Zone Pickup
740h *    09/22/20  DAS  7.40h
     *      - Fix: Revised autoloadcw to not set ERROR when calling
     *        zzzdricop for *LICINFO.
740i *    09/24/20  LCM  7.40i
     *      - Fix: If slot verify if E, should work same as N.
740j *    10/07/20  LCM  7.40j
     *      - Fix: End indirect task if it is started.
740k *    10/14/20  LCM  7.40k
     *      - Fix: do not allow negative pick qty to be entered
740l *    08/27/20  LMC  7.40l
     *      - Enh: Zone pickup process added for clients who have
     *        zone pickup turned off. We will ask them to comfirm
     *        the zone pickup is completed.
740mA*    11/10/20  MLB  7.40m  ZD# 2924
     *     - Enh:  Recompiled pgm for changes in /copy book,
     *       ROSLVFYLBL. Ref 7.40 mod. Correct MCH1210-Rcver value too
     *       small to hold result error. Found at Big Apple.
     *     - Recompile pgms: VOSELECT, OR402 with this update.
     *
750aA*    02/10/21  LMC  7.50a
     *     - Enh: Change screen format to or40028. The display file
     *       mod 700e was removed. To eliminate screen confusion.
750bA*    02/10/21  LMC  7.50b
     *     - Enh: If all labels for the transaction have been flagged
     *       prior to the start of the transaction, the transaction
     *       was not completing properly.
750cA*    02/11/21  LMC  7.50c
     *     - Enh:  In zzchk12v do not clear the $slvsoloqavl field
     *       if the change slot function was used.
750dA*    03/02/21  LMC  7.50d
     *     - Enh:  In zzcmd12v if only one location verification is
     *       set, you need to move on after a skip.
750eA*    03/04/21  LMC  7.50e
     *     - Enh:  Bulk pick - one weight only loaded, unless uci
     *       selection. bulk pick cw variance added.
     *     - Enh: Set allowbulk on - so it is our default. All clients
     *       who use or400 will now use it for bulk picking It will no
     *       longer call or680.
     *     - NOTE: if you install modification 750e, you must also
     *       install VOSELECT modification 750c for VFYLABELB.
750fA*    04/09/21  DAS  7.50f
     *     - Enh:  Revised to work with SelectPrime (WT6000)
     *     - Added optional pJsonStr parameter
     *     - Changed screen format to be usropn
     *     - Changed GetCurrStamp into a subprocedure
     *     - Added the following screens for SelectPrime. They are
     *       dummy screens used to reserver the nxtscr values.
     *           81 - Belt printer verification screen
     *           82 - Pallet summary
     *           83 - Stop summary
     *           84 - Pick list
     *           91 - TK901 Task list
     *           92 - OR401 Chg slot list
750gA*    04/08/21  LMC  7.50g
     *     - Enh:  Show slot display on screen 12/12v when client
     *       is set to display loc/level. We still display loc/levl
     *       but we add a display of the slot.
     *       Clients who don't use screen11 to display aisle already
     *       have the full slot display on the screen.
     *     - Enh:  Display pallet# and zone on screen6's
     *     - Enh:  Add UOM description to screen12v. So user knows
     *       which upc to scan for location verification.
     *     - Fix:  Set save62 when initially setting *in62 for weigh
     *       later function.
     *     - Fix:  The key fields on ordskipcw are not correct. W6lbl
     *       can only be used if scannig the pick label on screen6
     *
750hA*    04/21/21  LMC  7.50h
     *     - Enh:  Per hemant, we removed the condition where
     *       $slvlopickqty > 1 for allowing the user to enter a count
     *       Previously we didn't ask them to enter a count, even if
     *       that option was set unless the pick qty was > 1
750iA*    04/23/21  LMC  7.50i
     *     - Enh:  Per hemant, on count entry screen, once the user
     *       has entered a count, don't default to the original qty
     *       to pick, send blank instead.
750jA*    04/26/21  LMC  7.50j
     *     - Enh:  copied code for sceen6E, to also work for screen6EN
     *       for pick to weight screen.
     *     - Enh:  Added GetSpoken.
750kA*    05/04/21  LMC  7.50k
     *     - Enh: We allow the qty to be entered if option
     *       oprfqtcw = 'Y' is turned on.
750lA*    04/29/21  LMC  7.50l
     *     - Enh:  Added pallet summary
     *     - Enh:  Added stop summary
     *     - Enh:  Added pick list
750mA*    05/11/21  LMC  7.50m
     *     - Enh: changes to spoken words.
750nA*    05/11/21  DAS  7.50n
     *      - Revised how unexpected errors are sent back.
750oA*    05/13/21  LMC  7.50o
     *     - Enh: Adding the ability to skip location verification
     *       if the slot is the same as the previous label.
750pA*    05/11/21  DAS  7.50p
     *      - Increased JSON parameter size
     *      - Added file LABELOUT
750qA*    05/18/21  DAS  7.50q
     *      - Converted to SQLRPGLE
     *      - Added SelectPrime reprinting
     *      - Added file bfcsktjsn to record entire 64512 JSON fields
     *        in CLOB fields.
750rA*    05/20/21  LMC  7.50r
     *     - Enh: Sending des01 field with stop, qty, pallet & zone
     *       removed code for des02/des03 for readability
750sA*    05/20/21  LMC  7.50s
     *     - Enh: For clients using virtual picks the pickuci and
     *       pick commands sent to voice were failing. Created new
     *       variable virtualpick to condition the proper slot value
     *       to send on these commands.
750tA*    06/08/21  LMC  7.50t
     *     - Enh: UPC verification overrides count entry, for belt
     *       printer users, if NO upc we send them to sc6c to enter
     *       a qty. Non belt print users will be send to sc6 to scan
     *       pick labels.
     *     - Enh: Scanning individual upc, these are stored in uciinfo
     *       had to adjust the check to see if weight is in the scan.
     *       We were finding the upc in uciinfo, and sending back 0
     *       weight if the scan didn't include a weight. so if the
     *       weight returned is 0, we don't load up the weight field
     *       for screen7, because it was just loading a upc with no
     *       weight, and issuing weight variance error.
750uA*    06/16/21  LMC  7.50u
     *     - Enh: When a label is selected from the pick list that
     *       has already been picked, we need to reset the data back
     *       to the label they were picking before requesting the pick
     *       list on screen84.
750uA*    06/17/21  DAS  7.50u
     *     - Added new *GENPICK option OPSPPBA for controlling printing
     *       of labels before or after the pick, with 'pick' being
     *       defined as entering a qty or scanning a UCI.
     *     - Revised to print labels for a catchweight item before
     *       weights are entered instead of 1 at a time after a
     *       weight is entered.
750vA*    06/21/21  DAS  7.50v
     *     - Added belt printer peel-off.
750wA*    06/22/21  LMC  7.50w
     *     - Prime and Assume short from qty entry. Will now bypass
     *       displaying of screen16 to confirm the short. we will
     *       assume that if the user took the time to change the qty
     *       being picked and presses next or double clicks. They are
     *       making a decision to short the pick.
     *     - Stop Summary screen was not loading large stop number.
     *       Found this once I had a printer and compared the labels
     *       to screen83.
750xA*    06/23/21  LMC  7.50x
     *     - clear save slot fields used for skipping location
     *       verification on same slot in zzfil1. If you finish a
     *       transaction and start a new one. Those values need reset.
     *       ZZFIL2 also needs to clear the save fields.
750yA*    06/24/21  LMC  7.50y
     *     - When requesting to enter label, and you scan anything
     *       invalid, and then cancel. We reset everything back to
     *       the label you were processing before requesting the
     *       lable screen. Subr ZZRESETL
     *       Changed zzchk84 to use the new routine also to eliminate
     *       redundant code if error occurs on label selected from
     *       the pick list.
750zA*    06/25/21  LMC  7.50z
     *     - Add spoken words to 6c for stop,pallet and zone,
     *       based on voice options.
     *     - Send pick method to voselect. Mod 750g in voselect also
     *       this allows us to identify in labeldo file what picking
     *       method was used.
     *     - Treat double click with no value scanned on screen12v
     *       like the say again voice command.
     *       This will allow for the location and what is expected
     *       to be scanned to repeat.
751aA*    07/01/21  LMC  7.51a
     *     - Setoff zonepickup once a transaction is completed.
     *       this was causing the next transaction to loop because
     *       zonepickup was left on, and logic was doing vrylabelm
     *        for an o type label.
751bA*    08/10/21  LMC  7.51b
     *     - Load Merge labels to the pick list. Put the zone in the
     *       slot field on the pick list. lbwhdp/lbstyp.
     *     - if user selets a merge label from the pick list and is
     *       not currently in zonepickup process, voselect will send
     *       back error message, saying it failed the vfylabel check
     *       at this point we will just use that message.
     *     - Screen12V we are going to set des01 to just be the slot
     *       display. This will not effect what is spoken. Only change
     *       what is displayed.
     *     - Screen12V Added woitem2 to hold second line description.
751cA*    08/11/21  DAS  7.51c
     *     - When SelectPrime and belt printer option is 'Y', get
     *       printer id. If id is 11's then go into test print mode
     *       as type 'P', otherwise as type 'B'.
751dA*    08/12/21  LMC  7.51d
     *     - Somewhere in the process with belt printing, it broke
     *       the requirement of scanning original pick label for zone
     *       pickup, and was allowing for a qty entry, which then sent
     *       things down the wrong path.
751eA*    08/13/21  LMC  7.51e
     *     - Correct pallet# - pspal# is already available for us
     *       from label32/sktlbl32 so we can just use it.
751fA*    08/16/21  LMC  7.51f
     *     - Remove word ZONE from screen6's to allow for larger font.
     *     - correct qty picking on screen6a.
     *     - Screen6's Added woitem2 to hold second line description.
751gA*    08/16/21  DAS  7.51g
     *     - Revised merge pickup screen 6A to print label
751hA*    08/18/21  LMC  7.51h
     *     - Increased occurance for Palsum - SBI NC has exceeded the
     *       occur of 9. So will be creasing to 99.
751iA*    08/20/21  LMC  7.51i
     *     - Adding a method to cleanup previously loaded ordc records
     *       in case the apk crashes while entering weights. When the
     *       user starts over the will begin processing the label they
     *       errored on, and any previously loaded weights need to be
     *       removed, and the user starts this label from scratch.
     *       We do a similar process with uci scanning.
751jA*    08/31/21  LMC  7.51j
     *     - Reset pckcnt and clear pcklst. When checking out multiple
     *       transactions the data was being duplicated.
     *       At one client it was filing up pcklst, and erroring out.
751kA*    09/02/21  LMC  7.51k
     *     - Enhanced some error messages in zzchk6c to provide better
     *       tracking information.
751lA*    09/03/21  DAS  7.51l
     *     - Added colors
     *     - Added field w2trn to contain trn# for w2lbl, then
     *       put it into return SelectPrime string.
751mA*    09/07/21  LMC  7.51m
     *     - remove the default setting of opsppba = 'A' that was
     *       based on the user being a belt printer user. We will
     *       let the option control when labels print.
751nA*    09/09/21  DAS  7.51n
     *      - Revised zzinz2 to set opeqpj = 'N' and $slsriopeqpj = '0'
     *        for SelectPrime in order to prevent doing check in/out.
751oA*    09/10/21  DAS  7.51o
     *      - Added transaction auto assign logic.
751pA*    09/15/21  LMC  7.51p
     *      - Merge labels were not updating pick list correctly
     *      - clear w6uci in zzupd6a turn off zonepickup when coming
     *        from the pick list SC84.
     *      - allow pick label for zone pickup to be scanned/entered
     *        if traxid is not available. We will not store in the
     *        UCIINFO file in this case, because this would not be a
     *        unique value. We were storing this for our internal
     *        purpose only not for client use.
751qA*    09/29/21  DAS  7.51q
     *      - Added head1, head2, head3 fields
     *      - Revised $SetNxtSrc, screen 8, to send list of trans
751rA*    10/11/21  LMC  7.51r
     *      - Added pallet id (which pallet)
751sA*    10/08/21  DAS  7.51s
     *      - Cleaned up Prime code.
     *      - Moved standard routines into a section at the end
     *        of the program, including a special section heading.
     *      - Moved Prime initialization code from beginning of
     *        program into routine PrimeInit.
     *      - Moved button logic out of $SetNxtScr into $SetButtons.
     *      - Set spBtnFlags 6 to Lbs and 7 to Kgs. Revised
     *        $InzFuncKeys routine accordingly.
751tA*    10/22/21  LMC  7.51t
     *      - When using auto assign, and user choose to finish
     *        suspended transaction (sc22), need to send *undo back
     *        thru auto assignment program to release the transaction
     *        from this employee..
     *      - Moved the auto assign up in the zzchk1 logic, so it
     *        happens before we do the check for suspended. This
     *        allows us to undo the on demand transactions retrieved
     *        if the selector chooses to finish his suspended
     *        transaction.
751uA*    10/25/21  DAS  7.51u
     *      - Changed screen to OR40030.
     *      - Added screen 85 for Big Pallet Label
     *      - Added logic for Big Pallet Label
751vA*    10/27/21  LMC  7.51v
     *      - When user enters quantity of 0 on screen6c, we will turn
     *        on the *inkj command key so it does the short process.
     *        user was being asked to enter weights on CW items..
751wA*    11/02/21  DAS  7.51w
     *      - Revised ZZCHK1 to undo auto assign if error returned
     *        from VOSELECT.
751xA*    11/03/21  DAS  7.51x
     *      - 751t added Auto Assign *UNDO to routine ZZRESET. Turns
     *        out this routine gets called in places that only want
     *        to reset some fields, not do the *UNDO, such as in
     *        ZZUPD8.
     *      - Created routine ZZUNDOAUTO and added it after ZZRESET
     *        call in some places, including in ZZUPD22, the suspend
     *        screen.
751yA*    11/17/21  DAS  7.51y
     *     - Added logic for overflow print buffer.
751zA*    11/17/21  DAS  7.51z
     *      - Added logic to capture catchweights for gen 1 'M' recs
     *        instead of gen 2 'O' recs. Created variable GetMrgWgt to
     *        control this.
752aA*    11/17/21  DAS  7.52a
     *      - Fixed setting some buttons
     *      - Revised to uppercase screen 12V entered value. This was
     *        done to enhance manual entry.
752bA*    11/18/21  LMC  7.52b
     *        Remove this portion of 751p. This was originally put
     *        in for Cheney PICKC labels, where they didn't want to
     *        to put the 10 digit unique piece number on the pir pick
     *        they have since decied to put the 10 digit unique piece
     *        on the label with a QR(2D) barcode so the drivers will
     *        know to only scan the linear barcodes.
     *        This code below will be removed and the normal edits
     *        will occur.
     *      - allow pick label for zone pickup to be scanned/entered
     *        if traxid is not available. We will not store in the
     *        UCIINFO file in this case, because this would not be a
     *        unique value. We were storing this for our internal
     *        purpose only not for client use.
752cA*    11/22/21  LMC  7.52c
     *        Increase the stop summavy array to max 999.
752dA*    11/22/21  LMC  7.52d
     *        Setoff FIRSTZONEPICK at the end of ZZUPD14.
     *        If the transaction had only M labels, scr14 displayed
     *        more than once.
752eA*    11/24/21  LMC  7.52e
     *        Changing how we set the flag for the change slot button
     *        We will no longer use indicator 49, instead we will base
     *        it off the oprfcs option field.
752gA*    12/08/21  LMC  7.52g
     *        Fix the Weigh Later process.
     *      - Revised $SetButtons to use KiloLbs field instead of *in31
     *        Fix code where the lbs/kgs were not set correct
752hA*    12/09/21  LMC  7.52h
     *        Fix issue where the label and transaction numbers were
     *         not getting reset correctly after user had entered
     *         zero label on screen2, and they are using the old sc12
     *         not the new location verification logic for sc12v.
     *         Client was recently upgraded, but no one had them use
     *         the new logic. I believe with the 12v logic all the
     *         code was correct.
752iA*    12/03/21  LMC  7.52i
     *        Increase trnlst to 30. CBI checks out more than 20
     *        transactions.
752jA*    12/22/21  LMC  7.52j
     *        Add stop number and slot to screen6a.
     *        Add stop,pieces and pallet info to screen12v.
752kA*    12/22/21  DAS  7.52k
     *      - Temporary change adding rte/stp/plt to description line
     *        of list display.
     *      - Created $GetPlidSec subprocedure from getplidsec
     *        subroutine. This was to call it from $GetPckLst.
     *      - Revised getplidsec to call $GetPlidSec.
752lA*    01/11/22  LMC  7.52l
     *      - some of 751u needs to be changed. Label32d was not being
     *        opened.
     *      - additional code for getting pallet jack single/double/
     *        triple.
752mA*    02/18/22  LMC  7.52m
     *      - When introducing the pick list, broke some of bulk pick.
     *      - change to call or401 instead or or681.
752nA*    02/22/22  LMC  7.52n
     *      - Load up individual fields for the second line of the
     *        pick list. Route, Stop and Pallet.
752oA*    12/22/21  DAS  7.52o
     *      - Revised to not look for SETHED, SETSUM and PALLET
     *        labels for a Bulk Pick.
     *      - Revised ZZUPD1 to handle Bulk pick within pick list.
752pA*    02/10/22  DAS  7.52p
     *      - Remove 752k description changes.
     *      - Put Rte/Stp/Plt into new cells/fields that were created
     *        on Screen 84.
     *      - Put hyphen between pal# and section
752qA*    02/22/22  DAS  7.52q
     *      - Added some colors to copy source C#COLORS
     *      - Added alternating color to label list display
     *      - In label list, changed slot bkgrd color for merge
     *      - In label list, changed qty bkgrd color for brkdn1/2
752rA*    02/23/22  DAS  7.52r
     *      - Revised zzchk87 to just throw error when equip not found
752sA*    02/24/22  LMC  7.52s
     *      - If picking Merge during normal picking the logic in
     *        zzfil6a was not loading the corect slot.
     *      - Remove the pltsum4 logic put in $getpcklst logic in
     *        mod 752k. That corrupted the pallet value. We already
     *        have the correct value from the lable32/sktlbl32 files.
     *      - Fix which label displays after zone pickup from pick
     *        list in the middle of selection, not at the end.
     *      - Client reported issue No Print Rec error. Found that if
     *        they go from screen82, to screen84 the w2rtid field was
     *        still populated with the route id from the previous
     *        transaction. Added code into zzchk2 to populate the
     *        w2rtid with the route id from the return value of
     *        $slvfylblout/$slvlorouteid.
     *      - Fix when user cancels from big pallet label print screen
     *        just move on to screen8. The program was looping.
752tA*    03/03/22  LMC  7.52t
     *      - If suspending with multiple transactions scr13 loops
     *        because we don't setof the spnd field when there is an
     *        error.
     *      - Provide same slot more qty notifiation based on genpick
     *        option.
     *      - Remove items from pick list, when picked - based on
     *        genpick option.
752uA*    03/15/22  LMC  7.52u
     *      - Added logging for auto assign information.
     *      - Do not do endday processing from screen1 if the user
     *        has started seletion transactions.
752vA*    03/15/22  DAS  7.52v
     *      - Added screen 88 (merge entry) and 89 (merge list)
760aA*    04/22/22  LMC  7.60a
     *      - When using auto assignment, and you cancel out *undo,
     *        currently we only send the undo for the last transaction
     *        the user checked out, need to send undo for all
     *        transactions checked out by user, in case of multiples
     *      - Added additional logic for handling the pallet jacks
     *        Single, Double , Triple.
     *
     *----------------------------------------------------------------
     *  Andrews custom mods
     *
ADWbA*    05/23/06  RH   ADWb
     *      - Enh: Set item 27801 CW to 5.10, skip screen entry.
     *
     *----------------------------------------------------------------
     *  Client custom revisions: Cheney Brothers
     *
CBIaA*    11/17/21  DAS  CBIa
     *      - Revised to turn on getMrgWgt flag to get weights for
     *        gen 1 'M' recs instead of gen 2 'O' recs.
CBIbA*    01/14/22  LMC  CBIb
     *      - Adding colors for background on 12v based on even/odd
     *        slots. Even = Green, Odd = Blue
     *
     *----------------------------------------------------------------
     *  Custom Client Revisions:  iSupply
     *
ISPaA*    12/20/12  GJA/RR  ISPa
     *      - Enh: Force close & export of willcall transactions
     *
ISPbA*    04/10/12  RTR     ISPb
     *      - Fix: Change to allow F3 on screen 9A without exporting
ISPcA*    02/27/15  MLB     ISPc
     *      - Enh: Revised pgm to pass warehouse number to OR400CLISP.
     *        Needed to support new Kalamazoo whse.
ISPd *    01/18/16  GJA     ISPd
     *      - Enh: Revised pgm to only force close and export on
     *        WillCall orders.
ISPe *    02/15/16  GJA     ISPe
     *      - Enh: Force UPC, License and slot verification to
     *        always be off when WillCall orders.
     *
     *----------------------------------------------------------------
     *  Saval
     *
SVLaA*    04/17/09  GJA  SVLa
     *      - Enh: Use label UPC in weight to verify item and enter weight
     *
SVLbA*    04/17/09  DAS  SVLb
     *      - Enh: Revised zzupd7 to check UPC.
     *
SVLcA*    04/23/09  DAS  SVLc
     *      - Enh: Revised to bypass screen 6 and 6A.
SVLdA*    06/18/09  RH   SVLd
     *      - Enh: Revised to only execute SVLb & SVLc for steak
     *      - Enh: Revised to scan UPC and enter wt for Seafood.
     *      - Enh: Add type field STK=steak, SEA=seafood.
SVLeA*    07/30/09  RH   SVLe
     *      - Enh: Add ITEMFLD file for category code.
     *      - Enh: Revised to use category and vendor # to set
     *        type for steak(STK) or seafood(SEA)
SVLfA*    08/25/09  RH   SVLf
     *      - Enh: Set type for STK or SEA using category & vend
     *        OR location.
SVLgA*    01/14/13  RTR  SVLg
     *      - Enh: Set type for CHK using category & vend
     *        OR location.
SVLhA*    02/06/13  RTR  SVLh
     *      - Enh: Set type KSI for Kitchen Small Items to check item
     *        using barcode.
SVLiA*    12/04/13  RTR  SVLi
     *      - Enh: Change for 128 char barcode on chicken items because
     *        of vendor label change.
SVLjA*    01/23/14  RH   SVLj
     *      - Enh: change to use OR40006, SVLG, H & I changes merged  e
SVLkA*    02/04/14  RH   SVLk
     *      - Fix: Do not verify slot in ZZCHK3, slot is not scanned. e
SVLlA*    09/27/16  RTR  SVLl
     *      - Enh: Change to use 128 barcode on all chicken.
SVLmA*    11/01/16  MLB  SVLm
     *      - Revised SLVd mod to add dept 3 items to be picked by pgm.
     *        Per Gary P phone call 11.01.16.
SVLnA*    08/17/17  LMC  SVLn
     *      - Enh: Seafood vendor 5932 with category code 25. Will be e
     *        sent to the uci scanning screen, and we will treat like e
     *        UCI selection, so we can validate the item and extract  e
     *        the weight from the GS1 barcode.                        e
SVLoA*    09/08/17  MLB  SVLo
     *      - Revised program to look for category code 48 for produce
     *        items. The email indicated Cat Code 24, but the
     *        pgm was looking for Cat Code 74. Per email from Gary P
     *        dated 09.08.17.
SVLpA*    06/10/19  LMC  SVLp
     *      - Revised program to use vendor 8502 or 8503 for produce e
SVLqA*    08/29/20  MLB  SVLq
     *      - Revised SVLn mod to use vendor 3697 instead of 5932. Per
     *        email from Gary P dated 08.21.2020.
SVLr *    02/03/22  GJA  SVLr
     *      - Revised program to use vendor 4663 for steak per email
     *        from Gary
SVLs *    02/11/22  DAs  SVLs
     *      - Revised SVLr change. Using vendor 2545, category 08.
     *      - Barcode is different from other STK item. It is 10 char,
     *        formatted iiiiiccccc, where i is Saval Item Number and
     *        c is Saval Customer Number.
     *      - Currently, only item is 11000.
     *      - Created new type B10 for this.
     *      - **** 'RF Verify Individual UPC' must be set to 'Y' ****
     *----------------------------------------------------------------
     *  Client Custom Revisions: A and D Foods
     *
ADF A*    10/26/16  MLB  ADF  P#
     *      - Revised pgm to use LABEL32D for pick sequenc processing to
     *        match PFMT and VOSELECT.
     *      - Added ADF to 700f.
ADFbA*    04/01/20  LMC  ADFb
     *      - Do not allow the user to skip the slot verification.    to
     *        F9 is not allowed screen12.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Accardi
     *
ACCa *    04/15/19  GJA  ACCa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
ACCb *    04/16/19  GJA  ACCb
     *      - Ehn: Changed to use LABEL32S for department REF and FRZ
     *        Could not do zones REFF & FRZBIN.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Vitco
     *
VFIa *    01/28/20  GJA  VFIa
     *      - Skip screen11 - new device enter key on aisle change    to
     *        requires user to remove gloves.                         to
     *      - display slot display on screen12.                       to
VFIb *    02/03/20  LMC  VFIb
     *      - Revised pgm to seton AllowBulk.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
     *
SOFa *    07/21/20  GJA  SOFa
     *      - Skip screen11 - new device enter key on aisle change    to
     *        requires user to remove gloves.                         to
     *      - display slot display on screen12.                       to
     *----------------------------------------------------------------
     *  Client Custom Revisions: FreshSense
     *
FSFa *    03/18/18  GJA  FSFa
     *      - Was not allowing them to pick from overflow slot        to
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kellys
     *
KFSa *    04/08/19  LMC  KFSa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *  Client Custom Revisions: Big Apple Deli
     *
BADa *    10/01/19  GJA  BADa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
BADb *    10/03/19  GJA  BADb
     *      - Enh: Don't allow F6=Done on screen7
BADc *    10/16/19  LMC  BADc
     *      - Revised pgm to seton AllowBulk.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kohl Wholesale
     *
KHLa *    07/23/18  LMC  KHLa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
KHLb *    07/24/18  LMC  KHLb
     *      - Client wants to scan the combo label multiple times
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cotati Foods
     *
COT A*    09/25/18  MLB  COT  P#
     *      - Revised pgm to use LABEL32D for pick sequenc processing to
     *        match PFMT and VOSELECT.
     *      - Added COT to 700f.
     *
COTaA*    09/25/18  LMC  COTa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Greco
     *
GRCa *    09/28/18  LMC  GRCa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Colony
     *
CFIa *    09/28/18  LMC  CFIa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
CFIb *    10/02/18  GJA  CFIb
     *      - Revised pgm to use LABEL32X for aisle seq processing to
     *        match PFMT and VOSELECT.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Panos
     *
PANa *    09/28/18  LMC  PANa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
PANb *    12/06/18  LMC  PANb
     *      - SSB items will automatically default to weight later.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
     *
EOPa *    03/11/19  GJA  EOPa
     *      - display slot display on screen12.
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit
     *
MRTa *    11/06/18  LMC  MRTa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
     *
MRTb *    11/12/18  MLB  MRTb  P#
     *      - Revised pgm to use LABEL32D for pick sequenc processing
     *        match PFMT and VOSELECT.
     *      - Added MRT to 700f.
MRTc *    10/16/19  LMC  MRTc
     *      - Revised pgm to seton AllowBulk.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Marques Foods
     *
MQSaA*    02/16/19  LMC  MQSa
     *      - Selection scanning would be changed to show the Go To
     *        Aisle for the first "M" aisle label and then bypass the
     *        slot verification for each "M" aisle label within that
     *        transaction. Per Ginger
     *----------------------------------------------------------------
     *
SFPa *    08/12/19  GJA  SFPa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
     *
SWT  *    03/08/19  MLB  SWT  P#
     *      - Revised pgm to use LABEL32D for pick sequenc processing
     *        match PFMT and VOSELECT.
     *      - Added SWT to 700f.
     *
SWTa *    03/20/19  GJA  SWTa
     *      - Skip screen11 - new device enter key on aisle change
     *        requires user to remove gloves.
     *      - display slot display on screen12.
     *
SWTb *    03/29/19  GJA  SWTb
     *      - Enh:  Added the ability to check out pallet jack.
     *              Add "ending your day?"
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    04/20/21  LMC  PFCa
     *      - Do not allow skip slot verification.
     *      - Removing the call to apicvtslt because the periodmethod
     *        will not be used in SelectPrime.
     *      - We will treat CW items as combo for selection, which
     *        will require them to scan one pick label, then we will
     *        loop screen7 for the weights.
     *      - We allow the qty to be entered if future option
     *        oprfqtcw = 'Y' is turned on. We will default this option
     *        on for Presto at this time.
PFCb *    05/13/21  LMC  PFCb
     *      - Should be using sktlbl32d/label32d
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sunrise
     *
SUNaA*    04/18/22  LMC  SUNa
     *      - Do not allow the user to skip the slot verification.
     *        F9 is not allowed screen12 or screen12v
     *
     *
     *----------------------------------------------------------------
750fA*  SelectPrime Notes
     *
     *    The ZPL code for the label(s) to be printed is returned in
     *    JSON variable "print". Since the overall length of the JSON
     *    string is 64510, and the average number of ZPL characters of
     *    a label is 1400, approxamately 45 labels can be returned,
     *    which also gives room for the Std and Output sections.
     *
     *    Although anything close to this number of pieces would
     *    normally be a combo label or bulk pick, we have added a
     *    second 64512 parameter to be returned to the front end
     *    that could contain field "print2", which would give us
     *    approxamately 46 more labels, for a total of 91.
     *    Therefore, we are assuming we will not exceed 91 labels for
     *    a single label.
     *
     *    In the GetLabelZPL routine, we will make up to 2 passes to
     *    to get the ZPL for the requested label(s). In the first
     *    pass, we tell GetZPL to limit the number of characters it
     *    will send back in order to leave room for the Std and
     *    Output sections in the JSON string. it is only a guess, as
     *    we do not know the size taken up by those sections when
     *    we get the ZPL for the labels. For the second pass, we
     *    allow a larger size because less space is needed for the
     *    "print2" JSON string.
     *
     *    Also note, GetZPL will only return complete labels, it will
     *    not chop the ZPL code for a label and return the remainder
     *    in the second call.
     *
     *    Because there is a data queue size limit of 64512, we will
     *    take the second print value and write it to file PRINTOVRF,
     *    which will be retrieved in OR400COP.
     *
     *    The 64510 is not a typo above. Although the parameter we
     *    are sending back to the front end is 64512 and the size of
     *    the data queue value can be 64512, because we are using a
     *    variable length field, 2 characters needs to be added to the
     *    length for the variable size. Thus, if we return 64511 or
     *    64512 characters the data queue will throw an error because
     *    the length would exceed 64512.
     *
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

500dA*----------------------------------------------------------------
500dA*  Binding Directories
500dA*----------------------------------------------------------------
500dA
750fDH*bnddir('QC2LE':'QUSAPIBD':'BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
ISPaDF**or400fm   cf   e             workstn
ISPaAF***or40001   cf   e             workstn
650aDF*or40002   cf   e             workstn
650bDF*or40003   cf   e             workstn
650cDF*or40004   cf   e             workstn
650cDF*or40005   cf   e             workstn
700aDF*or40006   cf   e             workstn
700dDF*or40007   cf   e             workstn
700fDF*or40008   cf   e             workstn
700eDF*or40009   cf   e             workstn
700hDF*or40010   cf   e             workstn
700mDF*or40011   cf   e             workstn
700mMF*or40012   cf   e             workstn
720cDF*or40013   cf   e             workstn
720dDF*or40014   cf   e             workstn
720dDF*or40015   cf   e             workstn
720hDF*or40016   cf   e             workstn
720lDF*or40017   cf   e             workstn
720nDF*or40018   cf   e             workstn
720nDF*or40019  cf   e             workstn
730dMF*or40020   cf   e             workstn
730eDF*or40021   cf   e             workstn
730pDF*or40022   cf   e             workstn
730wDF*or40023   cf   e             workstn
740dDF*or40024   cf   e             workstn
740eDF*or40025   cf   e             workstn
740lDF*or40026   cf   e             workstn
750aDF*or40027   cf   e             workstn
750gDF*or40028   cf   e             workstn
752gDF*or40029   cf   e             workstn
752gMFor40030   cf   e             workstn
750fAF                                     usropn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
750fAF*****
750fAF***** If format name changes, change it in *INZSR ***
750fAF*****
     FLicense   if   e           k disk
     Foptions   if   e           k disk
     F*iruser   if   e           k disk
     Fpiritem   if   e           k disk
     Fitemmsc   if   e           k disk
740dDF*pirtran   if   e           k disk
740dMFpirtranw  if   e           k disk
530aDF*temfld   if   e           k disk
ISPaAFrtehed    uf   e           k disk
752vDF*LABEL32   IF   E           K Disk
752vMFLABEL32   IF   E           K Disk    rename(ljrec32:ZP) prefix(zp_)
700fAFLABEL32C  IF   E           K Disk
700fAFLABEL32D  IF   E           K Disk
700fAF                                     usropn
700fAFLABEL32g  IF   E           K Disk
700fAF                                     usropn
700fAFLABEL32h  IF   E           K Disk
700fAF                                     usropn
700fAFLABEL32X  IF   E           K Disk
700fAF                                     usropn
700fAFLABEL32I  IF   E           K Disk
700fAF                                     usropn
ACCbAFLABEL32S  IF   E           K Disk
ACCbAF                                     usropn
700fAFLABEL32Z  IF   E           K Disk
700fAF                                     usropn
700fAFLABEL32W  IF   E           K Disk
700fAF                                     usropn
700fAF*label90   uf   e           k disk
700fAFlabel90   if   e           k disk
700fAFSKTLBL    UF A E           K DISK
700fAF                                     usropn
752vDF*SKTLBL32  IF   E           K DISK
752vMFSKTLBL32  IF   E           K DISK    rename(SLWREC32:slzp) prefix(zp_)
752vDF*                                    usropn
700fAFSKTLBL32C IF   E           K DISK
700fAF                                     usropn
700fAFSKTLBL32D IF   E           K DISK
700fAF                                     usropn
700fAFSKTLBL32G IF   E           K DISK
700fAF                                     usropn
700fAFSKTLBL32H IF   E           K DISK
700fAF                                     usropn
700fAFSKTLBL32S IF   E           K DISK
700fAF                                     usropn
700fAFSKTLBL32X IF   E           K DISK
700fAF                                     usropn
700fAFsktlbl32z if   e           k disk
700fAF                                     usropn
700fAFSKTLBL32W IF   E           K DISK
700fAF                                     usropn
PFCbDF*SKTLBL32j IF   E           K DISK
PFCbDF*                                    usropn
700fAFSLOTCW    if   e           k disk
700fAFVSLOT1    if   e           k disk
700fAFmultran   if   e           k disk    rename(murec:murecx)
ISPaAFmultran1  if   e           k disk
ISPaAFpirtran4  if   e           k disk    rename(ptrec:record)
     Fvoexcp    uf a e           k disk
700fAFordh      if   e           k disk    rename(ohrec:orec)
ISPaAFordh3     if   e           k disk
500dAFbfcsktlog o    e           k disk
710jAFupc5      if   e           k disk
720dAFordp      if   e           k disk
752vAFordp5     if   e           k disk    rename(orprec:ordpp) prefix(zpu_)
720hAfordskipcw1if   e           k disk    prefix(sk_)
720nAfbulkwrk   uf a e           k disk
730pAfunmesr    if   e           k disk
730vAfpltsum4   if   e           k disk
730wAFliclog1   if   e           k disk    usropn
730wAFordc      uf a e           k disk    usropn
740dAFpirtran1w if   e           k disk    rename(ptrec:pt1)
750fAFslot3     if   e           k disk    rename(slrec:slrec3)
750fAFlicense1  if   e           k disk    rename(lirec:lirec1)
750lAFpltstp1   if   e           k disk
750lAFLabel31   if   e           k disk
750lAFitemfld   if   e           k disk
750lAFitemlnk   if   e           k disk
750lAFoptionz   if   e           k disk
750lAFLabel33   if   e           k disk
751uAFdevgrph   if   e           k disk
752lAFequip     if   e           k disk
752vAFspmrgsum  uf a e           k disk

750qA*----------------------------------------------------------------
750qA*  File data data structure
750qA*----------------------------------------------------------------
750qA
750qAD sjrec         E ds                  extname(bfcsktjsn) inz(*EXTDFT)
750pAD lorec         E ds                  extname(labelout) inz(*EXTDFT)
752vAD correc        E ds                  extname(label) inz(*EXTDFT)prefix(z_)
752vAD mrgrec        E ds                  extname(SPmrgwrk) inz(*EXTDFT)
752vAD msurecdl      E ds                  extname(SPmrgsum) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

700fA /copy qcopysrc,id#birite
700fA /copy qcopysrc,id#cdi
700fA /copy qcopysrc,id#cashwa
700fA /copy qcopysrc,id#cheney
700fA /copy qcopysrc,id#cheneyo
700fA /copy qcopysrc,id#cheneyr
700fA /copy qcopysrc,id#citylin
700fA /copy qcopysrc,id#dairyla
700fA /copy qcopysrc,id#westsid
700fA /copy qcopysrc,id#glp
700fA /copy qcopysrc,id#gsc
700fA /copy qcopysrc,id#ei
700fA /copy qcopysrc,id#harbor
417nA /copy qcopysrc,id#andrews
SVLaA /copy qcopysrc,id#saval
ISPaA /copy qcopysrc,id#isupply
700fA /copy qcopysrc,id#packers
700fA /copy qcopysrc,id#vip
700fA /copy qcopysrc,id#sgc
700fA /copy qcopysrc,id#ellenbe
700fA /copy qcopysrc,id#royal
700fA /copy qcopysrc,id#tpc
700fA /copy qcopysrc,id#citywho
700fA /copy qcopysrc,id#yhata
700fA /copy qcopysrc,id#ifd
700fA /copy qcopysrc,id#mjkelln
700fA /copy qcopysrc,id#renzi
700fA /copy qcopysrc,id#finkle
700fA /copy qcopysrc,id#palmer
700fA /copy qcopysrc,id#sofo
700fA /copy qcopysrc,id#frf
700fA /copy qcopysrc,id#capitol
700fA /copy qcopysrc,id#coastal
700fA /copy qcopysrc,id#jtd
700fA /copy qcopysrc,id#dierks
700fA /copy qcopysrc,id#silberm
700fA /copy qcopysrc,id#cpc
700fA /copy qcopysrc,id#avalon
700fA /copy qcopysrc,id#gmm
700fA /copy qcopysrc,id#hmwagne
700fA /copy qcopysrc,id#gfs
700fA /copy qcopysrc,id#pfc
700fA /copy qcopysrc,id#fpr
700fA /copy qcopysrc,id#wil
700fA /copy qcopysrc,id#pan
700fA /copy qcopysrc,id#jordano
ADF A /copy qcopysrc,id#adf
KHLaA /copy qcopysrc,id#khl
COT A /copy qcopysrc,id#cot
CFIaA /copy qcopysrc,id#cfi
GRC A /copy qcopysrc,id#grc
ACCaA /copy qcopysrc,id#acc
MRTaA /copy qcopysrc,id#mrt
MQSaA /copy qcopysrc,id#mqs
EOPaA /copy qcopysrc,id#eop
SWT A /copy qcopysrc,id#swt
SFPaA /copy qcopysrc,id#sfp
KFSaA /copy qcopysrc,id#kfs
BADaA /copy qcopysrc,id#bad
VFIaA /copy qcopysrc,id#vfi
DFFaA /copy qcopysrc,id#dff
SUNaA /copy qcopysrc,id#sun
417nAD client          s             10

     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a2n             s              1    dim(2)
     D a10             s              1    dim(10)
720kMD desc            s             50    dim(15) ctdata perrcd(1)
720kDD*desc            s             50    dim(14) ctdata perrcd(1)
710hDD*desc            s             50    dim(12) ctdata perrcd(1)
710bDD*desc            s             50    dim(11) ctdata perrcd(1)
700fDD*desc            s             50    dim(10) ctdata perrcd(1)
650aDD*desc            s             50    dim(8) ctdata perrcd(1)
520cDD*desc            s             50    dim(7) ctdata perrcd(1)
510aDD*desc            s             50    dim(6) ctdata perrcd(1)
500eDD*desc            s             50    dim(5) ctdata perrcd(1)
ISPaAD em              s             50    dim(2) ctdata perrcd(1)

500cA*----------------------------------------------------------------
500cA* Function prototypes.
500cA*----------------------------------------------------------------
500cA
500cA /copy qcopysrc,p.bfcdteti
730eA /copy qcopysrc,p.getstop
730qA /copy qcopysrc,p.umlabel
730vA /copy qcopysrc,p.p2plight
730wA /copy qcopysrc,p.cw800
740dA /copy qcopysrc,p.cvtbar
740gA /copy qcopysrc,p.getzpcku

750fA*----------------------------------------------------------------
750fA*  YAJL Header
750fA*----------------------------------------------------------------
750fA
750fA /copy qcopysrc,yajl_h
750fAd yajlerr         s            500    varying
750fAd docNode         s                   like(yajl_val)
750fAd node            s                   like(yajl_val)

750fAd stdNode         s                   like(yajl_val)
750fAd stdPointer      s               *   inz(%addr(stdBuffer))
750fAd stdBuffer       s           2048
750fAd stdLen          s             10i 0

750fAd inputNode       s                   like(yajl_val)
750fAd inputPointer    s               *   inz(%addr(inputBuffer))
750fAd inputBuffer     s           1024
750fAd inputLen        s             10i 0

650bA*----------------------------------------------------------------
650bA*  DRI parameters
650bA*----------------------------------------------------------------
650bA /COPY *libl/qcopysrc,C#DRIPARMS
650bA
650bA*----------------------------------------------------------------
650bA*  Data Formats
650bA*----------------------------------------------------------------
650bA /COPY *libl/qcopysrc,C#ITEM
650bA /COPY *libl/qcopysrc,C#SLOT
710eA /COPY *libl/qcopysrc,C#BARCODE
720dA /COPY *libl/qcopysrc,C#UCIINFO
730wA /COPY *libl/qcopysrc,C#LICINFO
730wA /COPY *libl/qcopysrc,C#CWLOG
700dA /Copy qcopysrc,p.getimuom
650bAD savever#        s                   like($itver#)
740dA /COPY *libl/qcopysrc,C#CVTPARMS
752vAd mrglst        e ds                  extname(spmrgwrk) prefix(w89_)
     *----------------------------------------------------------------
     *  Talkman record formats
     *----------------------------------------------------------------

      /Copy qcopysrc,r#header
500 A /Copy qcopysrc,rislassign
650cA /Copy qcopysrc,rislbeday
501lA /Copy qcopysrc,rislbox
500 A /Copy qcopysrc,rislchk4lb
500 A /Copy qcopysrc,rislchk4uf
500 A /Copy qcopysrc,rislclose
500 A /Copy qcopysrc,rislcomplt
720hA /Copy qcopysrc,rislcompl2
501lA /Copy qcopysrc,rislexpdte
501lA /Copy qcopysrc,rislgetcw
650cA /Copy qcopysrc,rislindtsk
501lA /Copy qcopysrc,rislnomcw
650bA /Copy qcopysrc,rislpckuci
500 A /Copy qcopysrc,rislpick
650aA /Copy qcopysrc,rislpickch
500 A /Copy qcopysrc,rislpicks
500 A /Copy qcopysrc,rislprtlbl
500 A /Copy qcopysrc,rislresett
730lA /Copy qcopysrc,rislresetu
500 A /Copy qcopysrc,rislresetw
500 A /Copy qcopysrc,rislscancw
500 A /Copy qcopysrc,rislsignof
500 A /Copy qcopysrc,rislsignon
501jA /Copy qcopysrc,rislsignrf
501lA /Copy qcopysrc,rislskipcw
500 A /Copy qcopysrc,rislsurvey
500 A /Copy qcopysrc,rislsuspnd
500 A /Copy qcopysrc,risltestcw
501jA /Copy qcopysrc,rislvfylbl
501jA /Copy qcopysrc,rislvfylic
500 A /Copy qcopysrc,rislvfyprt
650aA /Copy qcopysrc,rislvfyslt
501jA /Copy qcopysrc,rislvfyupc
710cA /Copy qcopysrc,rislvfyupu
500 A /Copy qcopysrc,rislweight
740eA /Copy qcopysrc,rislvfyckd
751iA /Copy qcopysrc,rislresetw

500 A /Copy qcopysrc,roslassign
650cA /Copy qcopysrc,roslbeday
501lA /Copy qcopysrc,roslbox
500 A /Copy qcopysrc,roslchk4lb
500 A /Copy qcopysrc,roslchk4uf
500 A /Copy qcopysrc,roslclose
500 A /Copy qcopysrc,roslcomplt
720hA /Copy qcopysrc,roslcompl2
501lA /Copy qcopysrc,roslexpdte
501lA /Copy qcopysrc,roslgetcw
501lA /Copy qcopysrc,roslnomcw
500 A /Copy qcopysrc,roslpick
650cA /Copy qcopysrc,roslindtsk
650aA /Copy qcopysrc,roslpickch
500 A /Copy qcopysrc,roslpicks
650bA /Copy qcopysrc,roslpckuci
500 A /Copy qcopysrc,roslprtlbl
500 A /Copy qcopysrc,roslresett
730lA /Copy qcopysrc,roslresetu
500 A /Copy qcopysrc,roslresetw
500 A /Copy qcopysrc,roslscancw
500 A /Copy qcopysrc,roslsignof
500 A /Copy qcopysrc,roslsignon
501jA /Copy qcopysrc,roslsignrf
501lA /Copy qcopysrc,roslskipcw
500 A /Copy qcopysrc,roslsurvey
500 A /Copy qcopysrc,roslsuspnd
500 A /Copy qcopysrc,rosltestcw
501jA /Copy qcopysrc,roslvfylbl
501jA /Copy qcopysrc,roslvfylic
500 A /Copy qcopysrc,roslvfyprt
650aA /Copy qcopysrc,roslvfyslt
501jA /Copy qcopysrc,roslvfyupc
710cA /Copy qcopysrc,roslvfyupu
500 A /Copy qcopysrc,roslweight
740eA /Copy qcopysrc,roslvfyckd
751iA /Copy qcopysrc,roslresetw

500dA*----------------------------------------------------------------
500dA*  Time variables
500dA*----------------------------------------------------------------
500dA
500dAD CurrStamploc    s               z
500dAD CurrStampsys    s               z
500dAD CurrStampuc     s               z
500dAD FromStamp       s               z
500dAD ToStamp         s               z
500dAD oldeststamp     s               z
500dAD ts              s               z
500dA
500dAD Duration        s              7  2
500dAD TtlMin          s              5  0
500dAD TtlMinSec       s              9  0
500dAD TtlSec          s              9  0
500dAD RemSec          s              3  0
500dA
500dAD bfcoffset       s              3  0 inz(0)
750fAD ucOffset        s              3  0

730uA*----------------------------------------------------------------
730uA*  Phrase Variables
730uA*----------------------------------------------------------------
730uA
730uA /COPY *libl/qcopysrc,c#phrasvar
730uAD  currFile       s             10
730uAD  currRoutine    s             20
730uAD  lastnxtscr     s              3
730u D  stackCount     s              3  0
730u D  aRoutine       s             20    dim(30)
730uA
730uA*----------------------------------------------------------------
730uA*  Phrases
730uA*----------------------------------------------------------------
730uA
730uA /COPY *libl/qcopysrc,c#phrases

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
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
     D  optend               117    117
     *
700fAD wkrtpo          ds
700fAD  wkrtid                 1      5
700fAD  wkppo                  6      9
     *
     *----------------------------------------------------------------
     *  TE130 Key Data Structure
     *----------------------------------------------------------------

     D $te130          ds
     D  $tlen                  1     50
     D  $temp#                 1      5  0
     D  $tstat                 6      6

     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjt2          c                   const('ADJTRAN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @addtr          c                   const('ADDSTDTRN')
520aAD @cvtbar         c                   const('CVTBAR')
640bAD @cvtbarsel      c                   const('CVTBARSEL')
530aAD @itmfl          c                   const('GETITEMFLD')
ISPaAD @pckrt          c                   const('CALPCKRTE')
750lAd/copy qcopysrc,p.gettbtyp
     *----------------------------------------------------------------
     *  Called program parameters
     *
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
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
     D  $ltrn1                19     25  0
     *
650cAD  $lcat                 19     24
720aMD  $ltktype              25     25
720amD  $lcode                26     31
720aDD* $lsub                 25     30
720aDD* $lcode                31     36
720aDD* $ltktype              37     37
     *
ISPaA *
ISPaAD $prtky          ds
650aDD* $len50                 1     50
650aMD  $len50                 1    100
ISPaAD  $kwhse                 1      3  0
ISPaAD  $krte                  4      8
ISPaAD  $krtid                 9     13
ISPaAD  $ktruk                14     23
ISPaAD  $kstat                24     24
ISPaAD  $ktype                25     25
ISPaA *
650aAD  $whdp                  4      8
650aAD  $pitem                 9     23
650aAD  $newsl                24     35
650aAD  $disp                 36     47
650aAD  $lbl#                 48     51p 0
650aAD  $trn#                 52     55p 0
650aAD  $bat#                 56     59p 0
650aAD  $blkq                 60     62p 0
650aAD  $oblkq                63     65p 0
650aAD  $task                 66     71
650aAD  $prg                  72     81
650aAD  $ActualSlot           82     82
    A *
ISPaAD $parms          ds
ISPaAD  $pcmd                  1      8
ISPaAD  $pprg                  9     18
ISPaAD  $puky                 19     68
ISPaAD  $prtn                 69     76
ISPaAD  $perm                 77    136
ISPaAD  $pmsg                 77     80
ISPaAD  $ptype                81     88
ISPaAD  $pmput                89     89
ISPaA *
ISPaA *   Redefine key
ISPaA *
ISPaAD  $pwhse                19     21  0
ISPaAD  $prte                 22     26
ISPaAD  $ppo                  27     35
ISPaAD  $ptrn#                36     42  0
ISPaAD  $puow#                60     68
     *
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
     D currstamp       s               z
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     *                                   P   1   20ERWHSE
     *
     D  erfld                  1     30
     *
     D  ertrn#                 1      4p 0
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  ertcw#                 1      3p 0
     D  erqpck                 4      6p 0
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgfc          c                   const('QCPFMSG   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
750lA*----------------------------------------------------------------
750lA*  Pallet summary data structure for a transaction
750lA*
751hDD*palsum          ds                  occurs(9)
751hMD palsum          ds                  occurs(99)
750lAD  dsppal                 1      7  0
750lAD  dspstp                 8      9  0
750lAD  stp                   26     43  0
750lAD                                     DIM(9)
750lAD  dsppli                44     50  0 inz
750lAD  dsprti                51     55
750lAD  dsstp1                56     57  0
750lAD  dsstp2                58     59  0
750lAD  dspcub                65     71  3
750lAD  dsppcs                72     76  0
750lAD  dspgtm                77     83  3
750lAD  dspwgt                84     92  2
750lAD  dsptrn                93     99  0
750lA*----------------------------------------------------------------
750lA*  Stop summary data structure for one set of labels.
750lA*  Maximum of 9 stops on one pallet, for fixed section items.
750lA*  Maximum of 99 stops on one pallet, for PIR section items.
750lA*
752cDD*stpsum          ds                  occurs(99)
752cMD stpsum          ds                  occurs(999)
750lAD  dssstp                 1      5  0 inz(0)
750lAD  dsscub                 6     12  3 inz(0)
75lAMD  dsspcs                17     21  0 inz(0)
750lAD  dsscnm                22     61
750lAD  dspal#                62     68  0 inz(0)
750lAD  dssord                69     75  0 inz(0)
750lAD  dsswgt                76     84  2 inz(0)
750lAD  dsscno                85     90
750lAD  dsstrn                91     97  0 inz(0)
750lA*
750lAD pcklst          ds                  qualified dim(999)
750lAD  pcktrn                 1      7  0 inz(0)
750lAD  pcklbl                 8     14  0 inz(0)
750lAD  pckitem               15     29
75lAMD  pckdesc               30     59
750lAD  pckdisp               60     71
750lAD  pckqty                72     76  0 inz(0)
750lAD  pckcub                77     85  3 inz(0)
750lAD  pckwgt                86     94  2 inz(0)
750lAD  pckdone               95     95    inz(' ')
752kAD  pckdesc2              96    125    inz(' ')
752nAD  pckrte               126    130    inz(' ')
752nAD  pckstp               131    135  0 inz(0)
752nAD  pckplt               136    142    inz(' ')
752pAD  pckpal               143    149  0 inz(0)
752pAD  pcksec               150    151    inz(' ')
752qAD  pcktype              152    152    inz(' ')
752qAD  pckuom               153    154    inz(' ')
752qAD  pckutyp              155    155    inz(' ')
750qA*
752iDD*trnlst          ds                  qualified dim(20)
752iMD trnlst          ds                  qualified dim(30)
750qAD  trn                           7  0 inz(0)
750qAD  rtid                          5    inz('')
752oAD  bulkFlag                       n   inz(*off)
750vA*
750vAD setlst          ds                  qualified dim(20)
750vAD  set                                like(loset) inz('')
650aA*----------------------------------------------------------------
650aA*  API programs
650aA*
650aAD @apics          c                   const('APICVTSLT ')
650aA*
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
ISPaAD editw11         c                   '0           '
750mAD comma           c                   ','
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #job#           s              6  0
     D #msgid          s              7
     D #msgtp          s              7
750fAD #msgtext        s            100
     D #pgmq           s             10
     D first2          s              1
     D first6          s              1
     D first6a         s              1
752vAD first88         s               n
720h D first18         s              1
720h D first19         s              1
     D morelb          s              1
752vAD morepickup      s               n
752vAD newqpck         s                   like(lbqpck)
752vAD mergelabel      s                   like(mglbl#)
752vAD mergetran#      s                   like(mgtrn#)
650bAD chk4err         s               n
     D clear           s              5  0
ISPaAD close           s              1
720gAD combo           s               n
     D cmdchk          s              8
     D cmdtkn          s              1
     D comand          s              5  0
500 AD curtime         s               z
     D cwgt            s              7  2
720nAD DonewithWgt     s               n
     D e               s              2  0
730qDD*enter           s              5  0
730qDD*error           s              1
     D exwgt           s              9  2
750lAD fabitems        s               n
     D first           s              1
     D forevr          s              1
730qDD*found           s              1
720hAD foundWL         s              1
720hAD foundWLabel     s              1
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
730eAD hostStop        s              5  0
     D hvskp           s              1
     D ihvar           s              9  2
     D ilvar           s              9  2
     D ihrng           s              9  2
     D ilrng           s              9  2
     D itmdsc          s             70
ISPaAD kygrp2          s                   like(ptgrp2)
ISPaAD kyrtpo          s                   like(ptrtpo)
     D kylcns          s                   like(lilcns)
750lAD kyltyp          s                   like(lbtype)
     D kywhse          s                   like(liwhse)
     D lflag           s              1
     D lstlic          s                   like(lilcns)
750lAD lststp          s                   like(lbstop)
     D lvskp           s              1
     D lwrng           s              9  2
     D lwvar           s              9  2
     D msgk            s              4  0
     D nxtscr          s              3
740lAD olabel          s               n
     D ocode           s              8
     D otaisl          s              5  0
     D otcube          s              9  3
     D otgrp1          s              1
     D otgrp2          s              1
     D otpcs           s              5  0
     D otpo            s              9
     D otqty1          s              5  0
     D otqty2          s              5  0
     D otqty3          s              5  0
     D otstyp          s              1
     D otswgt          s              9  2
     D otwhdp          s              5
     D ovrrid          s              1
750lAD palcnt          s              2  0
750lAD pckcnt          s              3  0
750qAD trncnt          s              3  0
750lAD pcksum          s              7  0
751rAD pltsec          s              2
760aAD p               s              3  0
760aAD undotran        s                   like(w1trn#)
760aAD PIRsoask        s               n
760aAD autoassigndone  s               n
760aAD autoassignpdon  s               n
760aAD autoassignmore  s               n
752lAD pos             s              3  0
752lAD pjpLength       S              5P 0
752lAD pjtype          s              1
760aAD pjtype#         s              1  0
752lAD pjtypepos       S              5P 0
     D prg1c           s              4  3
     D prg2c           s              4  3
750lAD ptrtid          s              5
     D putflg          s              1
650aAD redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
750oAd saveaisle       s                   like(lbaisl)
750oAd saveloc         s                   like(lbloc)
750oAd savelvl         s                   like(lbrlvl)
750oAd savehand        s                   like(lbhand)
510a D savupc          s                   like(w4upcd)
     D sclear          s              1
750lAD ssdcnt          s              2  0
752tAD ssmoreqty       s               n
750lAD stpcnt          s              3  0
750lAD stpcnm          s                   like(ohcnam)
750lAD stpstp          s                   like(wkstop)
750lAD stptrn          s                   like(lbtrn#)
     D stpflg          s              1
750lAD stpcub          s              8  3
750lAD stppcs          s              7  0
750lAD stpwgt          s              9  2
750lAD sstcub          s              8  3
750lAD sstpcs          s              7  0
750lAD sstwgt          s              9  2
650aAD svdisp          s                   like(lbdisp)
650aAD svqpck          s                   like(lbqpck)
740dAD suspendFound    s               n
740dAD suspendStat     s              1    inz('8')
     D t#task          s              6
750LAd tbEnhanced      s               n
750lAd tbPalletType    s              1
750lAd tbType          s              1
SVLbAD temp5           s              5
     D today           s              8  0
710hAD traxYN          s              1
     D trndte          s              8  0
     D trntim          s              6  0
     D ttlcub          s                   like($slasocube)
     D ttllic          s              3  0
     D ttlpcs          s                   like($slasopieces)
     D ttlwgt          s                   like($slasoweight)
520cAD type            s              3
     D ufinfl          s              1
     D usestr          s              4
730qDD*warn            s              1
     D wdpflg          s              1
     D wkcode          s              8
     D wkwhse          s                   like(liwhse)
700fAD Wktype          s              1    inz('O')
752vAD wrkrte          s              5
752vAD wrkunq          s              5
     D wtchk           s              1
     D*w1crew          s                   like(uscrew)
     D*w1emp#          s                   like(usemp#)
     D*w1shft          s                   like(usshft)
     D*w1styp          s                   like(usstyp)
     D*w1whdp          s                   like(uswhdp)
     D zdesc           s             30
     D $pdqlib         s             10
     D $pdqnameout     s             10
     D $pdqkey         s             36
     D $pcominfo       s             25
     D $pheader        s            512
     D $pfields        s           2048
501jAD $prtnfields     s           2048
640bAD w2lbl           s              7  0
750uAD w2rtid          s              5
640bAD w6lbl           s              7  0
640bAD w6albl          s              7  0
700aAD w6aval          s              7  0
720hAD w18lbl          s              7  0
720hAD w19lbl          s              7  0
650bAD zmflag          s               n
650bAD zmsflag         s               n
700dAD KiloLbs         s              1
700dAD BegKiloLbs      s              1
700dAD kgs2lbs         c                   2.20462262
700dAD CnvWgt          s              9  2
700dAD IMUOM           s              3
700dAD wwgt            s             11  3
700dAD wgt             s             11  3
720dDD*whereFrom       s              2
720dMD whereFrom       s              3
700fAD reccycle        s              2  0
700fAD multitran       s               n
700fAD kystat          s              1
720hAD kyent           s              1
700fAD count           s              5  0
700fAD wklabel         s             10
710jAD upcyes          s               n
720cAD zonepickup      s               n
720cAD firstzonepick   s               n
720dA ** temporary until added to genpick
720dAD opeqpj          s              1
720dAD opeqpt          s              6
720hAD w17trn#         s              7  0
720hAD w17lbl#         s              7  0
720hAD w17stop         s                   like($slvlostop)
720hAD w17item         s             15
720jAD WLUserChoice    s               n
MQSaAD FirstMslot      s               n
730qAD W6WGT1          S              6  2
730qAD W6WGT2          S              6  2
730qAD Pick2lbs        s              6  2
730vAD UsingP2P        s               n
730wAD AllowBulk       s               n
730wAD Save49          s               n
730wAD Save62          s               n
730wAD #scwgt          s                   like(itcwgt)
730wAD  CWcmd          s             10
730wAD  CWpgm          s             10
730wAD  CWrtn          s             10
730wAD  CWmsg          s             60
730wAD  CWdata         s            512
730wAD Newseq          s              3  0
730wAD  processstatus  s             10
730wAD #sitem          s                   like(ititem)
730wAD #frombasesldsp  s                   like($sldisp)
750fAD pCmd            s             10
750fAD usingScreen     s               n
750fAD displayScreen   s               n
750fAD prime           s               n
750fAD exfmtScreen     s               n
750fAD chgSlotInit     s               n
750fAD getTaskInit     s               n
750fAD jType           s              1
750fAD savedNxtScr     s                   like(nxtscr)
750fAD getout          s               n
750fAD bulkLabel       s               n
750fAD comboLabel      s               n

750fAd  spApp          s             20
750fAd  spUser         s             10
750fAd  spWhereFrom    s             20
750fAd  spUid          s             32
750fAd  spWhouse       s              3
750fAd  spF1F24Flags   s             24
750fAd  spBtnFlags     s             10
750fAD  spBtnClick     s             10
750fAd  errmsg500      s            500    varying
750pDd* pJsonStr       s           4096    varying
750pMd  pJsonStr       s          64512    varying
750pMd  printOutput    s          64512    varying
750pMd  printOutput2   s          64512    varying
750vAd  printInit      s          64512    varying
750pMd  lastPrintOut   s          64512    varying
750pMd  lastPrintOut2  s          64512    varying
750pAd  currPrintStr   s              2  0
750pAd  usingBeltPrt   s               n
750vAd  usingPeelOff   s               n
751cAd  printTest      s               n
750pAd  equipMsg       s             60
750pAd  deviceType     s             10
750pAd  deviceId       s             20
750pAd  printerId      s             20
750pAd  btnReprint     s               n
750pAd  btnPltSum      s               n
750pAd  btnStpSum      s               n
750pAd  btnPckList     s               n
752vAd  btnMrgList     s               n
750pAd  lastCmd        s             10
750pAd  lastRte        s                   like(lbrte)
750qAd  lastLbl        s                   like(lblbl#)
750pAd  lastTrn        s                   like(lbtrn#)
750qAd  lastFromSeq    s              5  0
750qAd  lastToSeq      s              5  0
750qAd  lastFmt        s              8
750qAd  lastPrintCnt   s              5  0
750qAd  $prtidl        s                   like(lbrte)
750qAd  skipDSPSCR     s               n
750qAd  displayBtnScr  s               n
750qAd  reprintSeq     s              5  0
750qAd  reprintSeqChr  s             10
750qAd  reprintType    s              1
750qAD  reprintScr     s                   like(nxtscr)
750qAD  returnToScr    s                   like(nxtscr)
752VaD  pickupnum      s              3  0
752VaD  pickupnum1     s              1  0
752VaD  pickupnum2     s              1  0
752VaD  pickupnum3     s              1  0
750qAD  printedLabel   s               n
750qAD  printedSETHED  s               n
750qAD  printedSETSUM  s               n
750qAD  printedPALLET  s               n
750qAD  lastLABEL      s               n
750qAD  lastSETHED     s               n
750qAD  lastSETSUM     s               n
750qAD  lastPALLET     s               n
750qAd  inzsrFlag      s               n
750fAd  zplString      s          64512    varying
750fAd  zplRtnCode     s             10
750fAd  zplRtnMsg      s             99    varying
750qAd  w84lb#         s              7  0
750qAd  w84lb#Char     s              7
750vAD  setCnt         s              3  0
750vAD  setLookup      s              3  0
750vAD  usingSavedFmt  s               n
7501AD  w2trn          s              7  0
752VaD  w88lbl         s             10
752VaD  w88rpcs        s              5  0
752VaD  w89id          s              3
752VaD  w89zone        s              6
752VaD  w89slot        s             12
752VaD  w89desc        s             30
752VaD  w89trx         s             10
752VaD  mrgcount       s              5  0
751oADusingAutoAssign  s               n
751oAD  dmdCode        s             10
751oAD  dmdMsg         s             50
760aAD  dmdrte         s              5
760aAD  dmdzone        s              6
751lAD  testColorSet   s              1  0
751uAD  usingBigPal    s               n
751uAd  bigPalDev      s             10
751uAd  pltjack        s              8
751uAd  getJackCode    s               n   inz(*off)
751uAd  maxPallets     s              1  0
751zAD  getMrgWgt      s               n
751zAD  getWgtFlag     s               n

730wAD #fromithead     s             70
730wAD #fromslwhdp     s                   like($slwhdp)
730wAD #fromslstyp     s                   like($slstyp)
730wAD #fromsldisp     s                   like($sldisp)
730wAD #fromslaisl     s                   like($slaisl)
730wAD #fromslloc      s                   like($slloc)
730wAD #fromslpseq     s                   like($slpseq)
730wAD #fromslrlvl     s                   like($slrlvl)
730wAD #fromslhand     s                   like($slhand)
730wAD #fromslrsrv     s                   like($slrsrv)
730wAD #fromslentd     s                   like($slentd)
730wAD #fromslexpd     s                   like($slexpd)
730wAD #fromslslfd     s                   like($slslfd)
730wAD #fromslactv     s                   like($slactv)
730wAD #fromslbld      s                   like($slbld)
730wAD #fromslpick     s                   like($slpick)
730wAD #fromslitem     s                   like($slitem)
730wAD #fromslsdef     s                   like($slsdef)
730wAD #fromslpos      s              3S 1
730wAD #fromslvirt     s                   like($sfvirt)
730wAD #fromslstk1     s                   like($slstk1)
730wAD #fromslstk2     s                   like($slstk2)
730wAD #fromslstk3     s                   like($slstk2)
730wAD #fromslalc1     s                   like($slalc1)
730wAD #fromslalc2     s                   like($slalc2)
730wAD #fromslalc3     s                   like($slalc3)
730wAD #fromsltfr1     s                   like($sltfr1)
730wAD #fromsltfr2     s                   like($sltfr2)
730wAD #fromsltfr3     s                   like($sltfr3)
730wAD #fromslpck1     s                   like($slpck1)
730wAD #fromslpck2     s                   like($slpck2)
730wAD #fromslpck3     s                   like($slpck3)
730wAD #fromslrcv1     s                   like($slrcv1)
730wAD #fromslrcv2     s                   like($slrcv2)
730wAD #fromslrcv3     s                   like($slrcv3)
730wAD #fromslphy1     s                   like($slphy1)
730wAD #fromslphy2     s                   like($slphy2)
730wAD #fromslphy3     s                   like($slphy3)
730wAD #fromslavl1     s                   like($slavl1)
730wAD #fromslavl2     s                   like($slavl2)
730wAD #fromslavl3     s                   like($slavl3)
730wAD #fromToLcns     s                   like($saToLcns)
730wAD #fromToPos      s                   like($saToPos)
730wAD #fromOLcns      s                   like($saOLcns)
730wAD pristineloaded  s               n
740gAD ozrfzp          s              1
750lAd showaisle       s                   like(lbaisl)
750lAd labeldone       s              3S 0
750lAd trncheck        s              2S 0
750sAd virtualpick     s                   like(slrsrv)
750uAd savew2lbl#b     s                   like(w2lbl#b)
750uAd savex           s                   like(x)
750wAd wkstop          s                   like(x)

     *----------------------------------------------------------------
     *  Standard variables
     *----------------------------------------------------------------
730qA /copy qcopysrc,c#stdvar

750qA*----------------------------------------------------------------
750qA*  Standard SQL variables and constants
750qA*----------------------------------------------------------------
750qA
750qA /copy qcopysrc,c#stdsql

751lA*----------------------------------------------------------------
751lA*  Standard colors
751lA*----------------------------------------------------------------
751lA /copy qcopysrc,c#colors

     *----------------------------------------------------------------
     *  *GENPICK -  General picking options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPERPT  -  Print exception (short) error report (Y,N).
     *    OPELBL  -  Print exception (short) labels (Y,N)
     *    OPRFWC  -  Using RF will call (Y,N)
     *    OPNRSC  -  Number of pallet sections (1-9)
     *    OPHPWC  -  Host pick Will Call  (Y,N).
     *    OPMRGA  -  Merge Add-on order(s) with Open Routes.
     *    OPPLSQ  -  Pallet number sequence. 1=Unload, 2=Load.
     *    OPEADJ  -  Close short labels without adjustment (Y,N)
     *    OPNOPK  -  Pick items without pick slots as bulk picks? (Y,N)
      *    OPGPK1  -  <Not Used / Available>
      *    OPGPK2  -  <Not Used / Available>
      *               task has been assigned. (Y/N)
      *    OPJITR  -  Create JIT Letdown or JIT Replenishment
      *                 0=None. No replenishments are created.
      *                 1=Letdowns are created during Truck Builder
      *                   Pick/Print processing.
      *                 2=Priority Replenishments are created during
      *                   Truck Builder Pick/Print processing.
      *                 3=JIT Letdowns created when transaction is
      *                   checked out.
      *                 4=JIT Priority Replenishments created when
      *                   transaction is checked out.
      *    OPPSET  -  Print separate set summary label for each pallet.
      *    OPRFUC  -  RF Pick Verify item with UPC.
      *    OPRFLC  -  RF Pick Verify item with license.
510hAI*    OPUSF1  -  USF Option: Allow merge items for stop to be split.
510hAI*               across truck pallets.
520aA*    OPRFSL  -  RF Pick Verify slot (Y,N)
700fA*               Y=Yes
700fA*               N=No
700fA*               C=Scan Check Digit
700fA*               E=Enter to Continue
650aA*    OPRFQT  -  RF Pick Allow Qty Entry (Y,N)
700fA*    OPRFQTO -     With Quantity Over (if RF Pick Allow Qty Entry = Y)
650bA*    OPRFCS  -  RF Pick Allow Change Slot (Y,N)
700fA*    OPRFPM  -  RF Pick Method
700fA*               1=Manual
700fA*               2=Directed
751uA*    OPRPLT  -  Print Pallet Label
751uA*               1=Normal
751uA*               2=Big
751uA*               3=Both
751uA*               4=No
720cA*    OPRFUI  -  Scan individual UPC for each unit.
720cA*    OPRFZP  -  Zone Pickup
720cA*    OPRFUW  -  Auto load weight from individual UPC
740eA*    OPRVUP  -  RF Location verification UPC
740eA*    OPRVSL  -  RF Location verification Slot
740eA*    OPRVCD  -  RF Location verification Check Digit
750kA*    OPRFQTCW-  RF allow Qty entry on cw items.
750lA*    OPRFQTAS-  SelectPrime - assume short from qty entry.
750lA*    OPRFSSSV-  SelectPrime - Same Slot skip Loc verification
750lA*    OPSPPS  -  SelectPrime only-auto display the pallet summary
750lA*    OPSPATRN-  SelectPrime - Auto assign transactions
750lA*    OPSPPLBL-  SelectPrime - Print pallet label on Belt Printer
750lA*    OPSPBTXT-  SelectPrime - Next Item breakdown warning text
750lA*    OPSPPSH -  SelectPrime - Print SetHed Label
750lA*    OPSPPSS -  SelectPrime - Print SetSum Label
750lA*               N=No
750lA*               B=with the Sethed
750lA*               E=with the pallet
750cA*    OPAUTS  -  Allow auto substitutions (Y/N)
750uA*    OPSPPBA -  SelectPrime - Print Before/After pick (B/A)
750uA*               (entering qty, scanning uci)
752lA*    OPSPJP  -  SelectPrime - Pallet jack prefix
752tA*      - OPSPSSN-  SelectPrime - Same Slot/More Qty visual Notif ication
752tA*      - OPSPPLDL-  SelectPrime - remove items from pick list as
752tA*                   they are picked.
     *
     * Data structure
     *
     D opdat2          ds
     D  operpt                 1      1
     D  opelbl                 2      2
     D  oprfwc                 3      3
     D  opnrsc                 4      4
     D  ophpwc                 5      5
     D  opmrga                 6      6
     D  opplsq                 7      7
     D  opeadj                 8      8
     D  opnopk                 9      9
     D* opgpk1                10     10
     D* opgpk2                11     11
     D  opjitr                12     12
     D  oppset                13     13
     D  oprfuc                14     14
     D  oprflc                15     15
     D  opusf1                16     16
520cDD* oprfsl                16     16
520cMD  oprfsl                17     17
650aAD  oprfqt                21     21
650bAD  oprfcs                22     22
700fAD  oprUSF                23     26
710aDD* oprfqto               27     29
710aMD  oprfqto               27     29  0
751uAD  oprplt                31     31
700fAD  oprfpm                30     30
720cAD  oprfui                32     32
720cAD  oprfzp                33     33
720cAD  oprfuw                34     34
740eAD  oprvup                36     36  0
740eAD  oprvsl                37     37  0
740eAD  oprvcd                38     38  0
750lMD  oprfqtcw              64     64
750lMD  oprfqtas              65     65
750lMD  oprfsssv              66     66
750lMD  opspps                67     67
750lMD  opspatrn              68     68
750lMD  opspplbl              69     69
750lMD  opspbtxt              70     99
750lMD  opsppsh              100    100
750lMD  opsppss              101    101
750cAD  opauts               102    102
750uAD  opsppba              103    103
752lAD  opspjp               104    108
752tAD  opspssn              109    109
752tAD  opsppldl             110    110
     D  opten2               117    117
     *----------------------------------------------------------------
520iA*  *PICKLBB -  Label printing options for the pick list and
520iA*               ASN labels and pick list report.
     *
520iA*     08/12/09  RBD  5.20  P#00219
520iA*       - Added record type *PICKLBB which holds printing info
520iA*         for the pick list and ASN labels and pick list report.
     *
     *----------------------------------------------------------------
     * Fields
     *
     *    OPLB4   -  Print pick list label Y/N.       - Pick list label
     *    OPCU4   -  Use cutter option Y/N.           - Pick list label
     *    OPLP4   -  Label printing program.          - Pick list label
     *    OPDV4   -  Printer device.                  - Pick list label
     *    OPFM4   -  Form.                            - Pick list label
     *
     *    OPLB5   -  Print ASN label Y/N.             - ASN label
     *    OPCU5   -  Use cutter option Y/N.           - ASN label
     *    OPLP5   -  Label printing program.          - ASN label
     *    OPDV5   -  Printer device.                  - ASN label
     *    OPFM5   -  Form.                            - ASN label
     *
     *    OPLB6   -  Print pick list report Y/N.      - Pick list report
     *    OPCU6   -  Use cutter option Y/N.           - Pick list report
     *    OPLP6   -  Label printing program.          - Pick list report
     *    OPDV6   -  Printer device.                  - Pick list report
     *    OPFM6   -  Form.                            - Pick list report
     *
530 A*    OPLB7   -  Print PICK labels for ZONPKUP 1/2- Pick labels
     *
     * Data structure
     *
     D opdta4          ds
     D  oplb4                  1      1
     D  opcu4                  2      2
     D  oplp4                  3     12
     D  opdv4                 13     22
     D  opfm4                 23     32
     D  oplb5                 33     33
     D  opcu5                 34     34
     D  oplp5                 35     44
     D  opdv5                 45     54
     D  opfm5                 55     64
     D  oplb6                 65     65
     D  opcu6                 66     66
     D  oplp6                 67     76
     D  opdv6                 77     86
     D  opfm6                 87     96
530 AD  oplb7                 97     97
     D  opend4               117    117
     *----------------------------------------------------------------
     I*  *SYSTEM  -  System options.
     I*
     I* Fields
     I*
     I*    OPEPM   -  Using EPM module (Y,N).
     I*    OPRF    -  Using RF module (Y,N).
     I*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     I*    OPLETD  -  Print letdown labels (Y,N).
     I*    OPWRNC  -  Perform catch weight variance check (Y,N).
     I*    OPRG1C  -  Catch weight low variance percentage.
     I*    OPRG2C  -  Catch weight high variance percentage.
     I*    OPIMPI  -  Import item fields from host.(Y,N).
     I*    OPICW   -  Individual catch weight entry (Y,N).
750fA*    OPTRNA  -  Assign Selection Transactions On-Demand
750fA*    OPSRTA  -  Assign Selection Transactions On-Demand Sort Order
     *
     * Data structure
     *
     D opdat3          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  opimpi                12     12
     D  opicw                 13     13
750fAD  optrna                47     47
750fAD  opsrta                48     48
     D  opten3               117    117
720cA*----------------------------------------------------------------
720cA*  *VOICE  -  PIR Voice options.
720cA*----------------------------------------------------------------
720cA*
720cA* Fields
720cA*
720cA*    OPINCP  -  Include pack description (Y/N)
720cA*    OPCRTR  -  Create RUNNER entries for shorts/outs (Y/N)
720cA*    OPUPLV  -  Update Label with quantity picked during Voice
720cA*               selection (Y/N)
720cA*               NOTE: Any change to this field will cause OPUPLR
720cA*                     in the *RUNNER options record to be updated.
720cA*    OPVMRG  -  Create Runner entries for Merge records? (Y/N)
720cA*    OPFOUT  -  Create Runner entry after slot marked out. (Y/N)
720cA*    OPFRPL  -  Replenish flagged items before print report? (Y/N)
720cA*               & create Priority Replenishment if necessary.
720cA*    OPVMLT  -  Allow multiple transaction (Y/N)
720cA*    OPVSPN  -  Speak pallet number (Y/N)
720cA*    OPVSPZ  -  Speak pallet zone (Y/N)
720cA*    OPVSLW  -  Speak large quantity warning (Y/N)
720cA*    OPVCEP  -  Speak unit of measure change warning (Y/N)
720cA*    OPVSSN  -  Speak stop number (Y/N)
720cA*    OPVCPZ  -  Confirm pallet zone (Y/N)
720cA*    OPESTP  -  Extended stop number length (2-5)
720cA*
720cA* Data structure
720cA*
720cA*----------------------------------------------------------------
720cA
720cAD opvdta          ds
720cAD  opincp                 1      1
720cAD  opcrtr                 2      2
720cAD  opuplv                 3      3
720cAD  opvmrg                 4      4
720cAD  opoutf                 5      5
720cAD  opfrpl                 6      6
720cAD  opvmlt                 7      7
720cAD  opvspn                 8      8
720cAD  opvspz                 9      9
720cAD  opvslw                10     10
720cAD  opvcep                11     11
720cAD  opvssn                12     12
720cAD  opvcpz                13     13
720cAD  opestp                14     14
720cAD  opvend               117    117

730wA*----------------------------------------------------------------
730wA*  LT210 parameters
730wA*----------------------------------------------------------------

730wAD  $tcmd          s              8
730wAD  $tprogram      s             10
730wAD  $ttype         s              3
730wAD  $thead         s             20
730wAD  $twhse         s              3  0
730wAD  $titem         s             15
730wAD  $titemdsc      s             65
730wAD  $twhdp         s              5
730wAD  $tslot         s             12
730wAD  $tslotpos      s              3  0
730wAD  $templ#        s              5  0
730wAD  $ttran#        s              7  0
730wAD  $tlic#         s             15
730wAD  $tnewlic#      s             15
730wAD  $tqty1         s              5  0
730wAD  $tqty2         s              3  0
730wAD  $tqty3         s              3  0
730wAD  $tnorm1        s              5  0
730wAD  $tnorm2        s              3  0
730wAD  $tnorm3        s              3  0
730wAD  $tpartial      s               n
730wAD  $tpulled       s              3  0
730wAD  $tinslot       s              1
730wAD  $tsamepos      s              1
730wAD  $tdiffpos      s              1
730wAD  $tpsplit       s              1
730wAD  $tinlic#       s             15
730wAD  $toutlic#      s             15
730wAD  $tnexttask     s             10
730wAD  $treturn       s              8
730wAD  $terrmsg       s             60
730wAD  $tmsgid        s              4

     *----------------------------------------------------------------
     *  Program info data structure
     *
730uA /Copy qcopysrc,c#pgminfds
730uDD**              sds
730uDD**#prog            *proc
730uDD**#job                 244    253
730uDD**#user                254    263
730uDD**#jobn                264    269
730uDD**#jobdt               276    281  0
730uDD**#jobtm               282    287  0
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

750fA*----------------------------------------------------------------
750fA*  Sub-procedure prototypes
750fA*----------------------------------------------------------------

750lAd $GetPckLst      pr

750lAd $GetPltSum      pr

750kAd $GetPlidSec     pr

750lAd $GetStpSum      pr

750fAd WriteIncoming   pr

750fAd WriteOutgoing   pr

750fAd WriteVoiceLog   pr
750fAd  type                               const like(slgtyp)
750fAd  buffer                             const like(slgbuf)

750qAd WriteCLOB       pr
750qAd  jsonStr                   64512    varying options(*varsize) const
750qAd  printStr1                 64512    varying options(*varsize) const
750qAd  printStr2                 64512    varying options(*varsize) const

750pAd GetLabelZPL     pr
750pAd  pCmd                         10    const
750pAd  pRte                          5    const
750pAd  pTrn                          7  0 const
750pAd  pLbl                          7  0 const
750pAd  pFromSeq                      3  0 const
750pAd  pToSeq                        3  0 const
750pAd  pFmt                          8    const

751sA*----------------------------------------------------------------
751sA*  Prime Standard Sub-procedure prototypes
751sA*----------------------------------------------------------------

750fAd GetCurrStamp    pr

750fAd CreateRtnError  pr

751sAd $PrimeInit      pr

750fAd $InzFuncKeys    pr

750fAd $InzPgmVar      pr

750fAd $SetNxtScr      pr

751sAd $SetButtons     pr

750jAd GetSpoken       pr           200    varying

750fAd UpperToLower    pr         65535A   varying
750fAd  value                     65535A   varying const

750fAd SetPgmField     pr
750fAd  key                          50A   varying const
750fAd  value                              like(yajl_val) const

750fAd LoadJson        pr

750fA*----------------------------------------------------------------
750fA*  Called program prototypes
750fA*----------------------------------------------------------------
750fA
750pA /copy qcopysrc,p.getequip
750pA /copy qcopysrc,p.setequip
751oA /copy qcopysrc,p.getdmdse
750pA
750fAD GetJType        pr                  extpgm('GETJTYPE')
750fAD   jobType                      1
750fA
750pAD GetZPL          pr                  extpgm('GETZPL')
     d  pCmd                         10    const
     d  pWhse                         3  0 const
     d  pRtid                         5    const
     d  pTrn                          7  0 const
     d  pLbl                          7  0 const
     d  pFmt                          8    const
     d  pFromSeq                      3  0
     d  pToSeq                        3  0
     d  pMaxRtnLen                    5  0
     d  pRtnCode                     10
     d  pRtnMsg                      99    varying options(*varsize)
     d  pZPLString                64512    varying options(*varsize)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
750fA*      iCmd       *PRIME  (optional)
750fA*      xpParms    SelectPrime data structure  (optional)
     *
     *    Returned Parameters
     *      None
750fA*----------------------------------------------------------------
750fA*  Let the show begin .....
750fA*
750fAC     *entry        plist
750fAC                   parm                    pJsonStr
     *----------------------------------------------------------------
     *  Main line
     *

750fA /free
750fA   if prime;
751sA     $PrimeInit();
751sA     if error;
751sA       return;
751sA     endif;
750fA   endif;
750fA /end-free

730aAC                   eval      stackCount = 0
730aAC                   eval      currRoutine = 'main'
730aAC                   exsr      phpgmV1V2V3s

     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
750qDC**                 if        not prime
750qDC**                           or spWhereFrom = 'LOGIN'
750qDC**                           or spWhereFrom = 'OR400.01'
750qAC                   if        inzsrFlag = *on
750qAC                   eval      inzsrFlag = *off
750vAC                   eval      usingSavedFmt = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
750fAC                   endif
750fA
750fA /free
750fA
750fA   // For Prime, initialize inputs.
750fA   // We need to do this after zzinz2 because coming in with
750fA   // OR400.01 will clear the w1trn# field that we are sending in.
750fA
750fA   if prime;
750fA     $InzPgmVar();
750fA     if error;
750fA       return;
750fA     endif;
750fA   endif;
750fA
750fA   // Set flag for dspscr
750fA
750fA   if not prime;
750fA     displayScreen = *on;
750fA   else;
750fA     if spWhereFrom = 'LOGIN' or displayBtnScr;
750fA       displayScreen = *on;
750fA     else;
750fA       displayScreen = *off;
750fA     endif;
750fA   endif;
750fA   exfmtScreen = *off;
750fA
750fA /end-free
     *
     C                   dow       nxtscr <> 'EOJ'
750qAC                             and not skipDSPSCR
750fA
750fAC                   if        displayScreen
     C                   exsr      dspscr
750fAC                   endif
750fA
750fAC                   eval      displayScreen = *on
750fA
750fAC*    For Prime, we want to get out if a screen was displayed.
750fA
750fAC                   if        prime and exfmtScreen
750fAC                   leave
750fAC                   endif

     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
500dAC     nxtscr        caseq     '06A'         sc6a
510aAC     nxtscr        caseq     '06B'         sc6b
650aAC     nxtscr        caseq     '06C'         sc6c
650bAC     nxtscr        caseq     '06D'         sc6d
730QAC     nxtscr        caseq     '06E'         sc6e
730QAC     nxtscr        caseq     '06F'         sc6f
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
     C     nxtscr        caseq     '09 '         sc9
ISPaAC     nxtscr        caseq     '09A'         sc9a
500dDC**   nxtscr        caseq     '10 '         sc6a
500dAC     nxtscr        caseq     '10 '         sc10
700fAC     nxtscr        caseq     '11 '         sc11
700fAC     nxtscr        caseq     '12 '         sc12
740eAC     nxtscr        caseq     '12V'         sc12V
700fAC     nxtscr        caseq     '13 '         sc13
720cAC     nxtscr        caseq     '14 '         sc14
720cAC     nxtscr        caseq     '15 '         sc15
720dAC     nxtscr        caseq     '16 '         sc16
720hAC     nxtscr        caseq     '17 '         sc17
720hAC     nxtscr        caseq     '18 '         sc18
720hAC     nxtscr        caseq     '19 '         sc19
720lAC     nxtscr        caseq     '20 '         sc20
730qAC     nxtscr        caseq     '21 '         sc21
740dAC     nxtscr        caseq     '22 '         sc22
740lAC     nxtscr        caseq     '23 '         sc23
750fAC     nxtscr        caseq     '81 '         sc81
750lAC     nxtscr        caseq     '82 '         sc82
750qAC     nxtscr        caseq     '83 '         sc83
750qAC     nxtscr        caseq     '84 '         sc84
750qAC     nxtscr        caseq     '85 '         sc85
751uAC     nxtscr        caseq     '86 '         sc86
751uAC     nxtscr        caseq     '87 '         sc87
752vAC     nxtscr        caseq     '88 '         sc88
752vAC     nxtscr        caseq     '89 '         sc89
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
750fA*   For Prime, we want to have the program remain open.
     *
     C                   exsr      zsclr
730uAC                   exsr      phpgmV1V2V3e

750fA /free
750fA      select;
750fA        when prime;
750fA          $SetNxtScr();
750fA          if nxtscr = 'EOJ';
750pA            GetLabelZPL('*SHUTDOWN': '': 0 : 0 :0 :0:'');
750fA            *inlr = *on;
750fA          endif;
750fA        other;
750pA          GetLabelZPL('*SHUTDOWN': '': 0 : 0 :0 :0:'');
500dA          *inlr = *on;
750fA      endsl;
750fA
750fA     if prime;
750fA       slgbuf = '<End> '
750fA              + '*INLR=' + *inlr + ' '
750fA              + 'error=' + error + ' '
750fA              + 'nxtscr=' + %trimr(nxtscr) + ' '
750fA              + pjsonstr;
750fA       WriteVoiceLog ('End': slgbuf);
750fA       WriteClob(pjsonstr: lastPrintOut: lastPrintOut2);
750fA     endif;
750fA
750fA /end-free

     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
750fAC                   eval      exfmtScreen = *off
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
730uA*
730uA*   Write tracking phrase of which screen is being displayed.
730uA*
730uAC                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
750fAC                   if        nxtscr = '81 '
750fAC                   eval      exfmtScreen = *on
750fAC                   endif
750fAC                   if        nxtscr = '91 '
750fAC                   eval      exfmtScreen = *on
750fAC                   endif
750fAC                   if        nxtscr = '92 '
750fAC                   eval      exfmtScreen = *on
750fAC                   endif
750lAC                   if        nxtscr = '82 '
750lAC                   eval      exfmtScreen = *on
750lAC                   endif
750lAC                   if        nxtscr = '83 '
750lAC                   eval      exfmtScreen = *on
750lAC                   endif
750lAC                   if        nxtscr = '84 '
750lAC                   eval      exfmtScreen = *on
750lAC                   endif
750qAC                   if        nxtscr = '85 '
750qAC                   eval      exfmtScreen = *on
750qAC                   endif
751uAC                   if        nxtscr = '86 '
751uAC                   eval      exfmtScreen = *on
751uAC                   endif
751uAC                   if        nxtscr = '87 '
751uAC                   eval      exfmtScreen = *on
751uAC                   endif
752vAC                   if        nxtscr = '88 '
752vAC                   eval      exfmtScreen = *on
752vAC                   endif
752vAC                   if        nxtscr = '89 '
752vAC                   eval      exfmtScreen = *on
752vAC                   endif
     C                   if        nxtscr = '01 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen1                              50
750fAC                   endif
     C                   endif
     C                   if        nxtscr = '02 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen2                              50
750fAC                   endif
     C                   endif
     C                   if        nxtscr = '03 '
520aAC                   if        oprfsl = 'Y'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen3                              50
750fAC                   endif
520aAC                   else
520aAC                   eval      w3scan=w3disp
520aAC                   endif
     C                   endif
     C                   if        nxtscr = '04 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen4                              50
750fAC                   endif
     C                   endif
     C                   if        nxtscr = '05 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen5                              50
750fAC                   endif
     C                   endif
     C                   if        nxtscr = '06 '
SVLcAC                   if        client = saval
SVLdAC                             and type = 'STK'
SVLgAC                             or client = saval
SVLgAC                             and type = 'CHK'
SVLhAC                             or client = saval
SVLhAC                             and type = 'SKI'
SVLmAC                             or client = saval
SVLmAC                             and type = 'PRO'
SVLdAC***                          or client <> saval
SVLcAC                   eval      w6lbl = $slvlolbl#
640bAC                   movel     $slvlolbl#    w6lbl#b
SVLcAC                   else
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen6                              50
750fAC                   endif
SVLcAC                   endif
     C                   endif
     C                   if        nxtscr = '07 '
     C*
SVLgAC                   select
SVLgAC                   when      client = saval
SVLgAC                             and type = 'CHK'
SVLgAC                   eval      w7blbl = *blanks
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
SVLgAC                   exfmt     screen7b                             50
750fAC                   endif
SVLgAC                   eval      w7cwgt = w7blbl
     C*
SVLhAC                   when      client = saval
SVLhAC                             and type = 'SKI'
SVLhAC                   eval      w7ilbl = *blanks
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
SVLhAC                   exfmt     screen7c                             50
750fAC                   endif
SVLhAC                   eval      w7cwgt = w7ilbl
     C*
PANbAC                   when      client = panos
PANbAC                             and $ittype = 'S'
PANbAc                   eval      *inki = *on
740dAc                   When      oprfui = 'Y' and oprfuw = 'Y'
740dAc                             and w7cwgt <> ' ' and error = *off
740eAc                             and ($ifsltmth >='4' and $ifsltmth <='6')
SVLgAC                   other
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen7                              50
750fAC                   endif
SVLgAC                   endsl
     C                   endif
     C                   if        nxtscr = '08 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen8                              50
750fAC                   endif
     C                   endif
     C                   if        nxtscr = '09 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen9                              50
750fAC                   endif
     C                   endif
ISPaAC                   if        nxtscr = '09A'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
ISPaAC                   exfmt     screen9a                             50
750fAC                   endif
ISPaAC                   endif
500dDC**                 if        nxtscr = '10 '
500dMC                   if        nxtscr = '06A'
SVLcAC                   if        client = saval
SVLdAC                             and type='STK'
SVLgAC                             or client = saval
SVLgAC                             and type = 'CHK'
SVLhAC                             or client = saval
SVLhAC                             and type = 'SKI'
SVLcAC                   eval      w6albl = w2lbl
640bAC                   eval      w6albl#b = w2lbl#b
SVLcAC                   else
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
     C                   exfmt     screen6a                             50
750fAC                   endif
SVLcAC                   endif
     C                   endif
510aAC                   if        nxtscr = '06B'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
510a C                   exfmt     screen6b                             50
750fAC                   endif
510a C                   endif
650aAC                   if        nxtscr = '06C'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
650aAC                   exfmt     screen6c                             50
750fAC                   endif
650aAC                   endif
650bAC                   if        nxtscr = '06D'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
650bAC                   exfmt     screen6d                             50
750fAC                   endif
650bAC                   endif
730qAC                   if        nxtscr = '06E'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
730qAC                   exfmt     screen6e                             50
750fAC                   endif
730qAC                   endif
730qAC                   if        nxtscr = '06F'
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
730qAC                   exfmt     screen6f                             50
750fAC                   endif
730qAC                   endif
500dAC                   if        nxtscr = '10 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
500dAC                   exfmt     screen10                             50
750fAC                   endif
500dAC                   endif
700fAC                   if        nxtscr = '11 '
KHLaAc                   if        client = kohl
COTaAc                             or client = Cotati
GRCaAc                             or client = greco
CFIaAc                             or client = colony
PANaAc                             or client = panos
ACCaAc                             or client = accardi
MRTaAc                             or client = merit
EOPaAc                             or client = EarlsOrganic
SWTaAC                             or client = SWT
SFPaAC                             or client = SFP
KFSaAC                             or client = Kellys
BADaAc                             or client = BigApple
VFIaAc                             or client = Vitco
SOFaAc                             or client = SofoFoods
740eAc                   exsr      zzzsetof
KHLaAc                   else
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
700fAC                   exfmt     screen11                             50
750fAC                   endif
KHLaAc                   endif
700fAC                   endif
700fAC                   if        nxtscr = '12 '
MQSaAc                   if        client = marques and
MQSaAc                             FirstMSlot = *off
740eAc                   exsr      zzzsetof
MQSaAc                   else
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
700fAC                   exfmt     screen12                             50
750fAC                   endif
MQSaAc                   endif
700fAC                   endif
740eAC                   if        nxtscr = '12V'
740eAc                   if        client = marques and
740eAc                             FirstMSlot = *off
740eAc                   exsr      zzzsetof
740eAc                   else
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
740eAC                   exfmt     screen12V                            50
750fAC                   endif
740eAc                   endif
740eAC                   endif
700fAC                   if        nxtscr = '13 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
700fAC                   exfmt     screen13                             50
750fAC                   endif
700fAC                   endif
720cAC                   if        nxtscr = '14 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720cAC                   exfmt     screen14                             50
750fAC                   endif
720cAC                   endif
720cAC                   if        nxtscr = '15 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720cAC                   exfmt     screen15                             50
750fAC                   endif
720cAC                   endif
720dAC                   if        nxtscr = '16 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720dAC                   exfmt     screen16                             50
750fAC                   endif
720dAC                   endif
720hAC                   if        nxtscr = '17 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720hAC                   exfmt     screen17                             50
750fAC                   endif
720hAC                   endif
720hAC                   if        nxtscr = '18 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720hAC                   exfmt     screen18                             50
750fAC                   endif
720hAC                   endif
720hAC                   if        nxtscr = '19 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720hAC                   exfmt     screen19                             50
750fAC                   endif
720hAC                   endif
720lAC                   if        nxtscr = '20 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
720lAC                   exfmt     screen20                             50
750fAC                   endif
720lAC                   endif
730qAC                   if        nxtscr = '21 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
730qAC                   exfmt     screen21                             50
750fAC                   endif
730qAC                   endif
740dAC                   if        nxtscr = '22 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
740dAC                   exfmt     screen22                             50
750fAC                   endif
740dAC                   endif
740lAC                   if        nxtscr = '23 '
750fAC                   eval      exfmtScreen = *on
750fAC                   if        usingScreen
740lAC                   exfmt     screen23                             50
750fAC                   endif
740lAC                   endif
730uA*
730uA*   Write tracking phrase of what was pressed.
730uA*
730uAC                   exsr      phV2onV1
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
     C                   setoff                                       3334
     C                   setoff                                       363738
     C                   setoff                                       3940
     *
     C                   setoff                                       9298
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
650aAC                   eval      redspl = *off
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
     C                   eval      first2 = *off
720cAc                   eval      wktype = 'O'
700fAC                   setoff                                       454647
700fAC                   setoff                                       48
700fAc                   exsr      openfile
     C                   exsr      zzfil1
     C     end01i        endsr
     *---------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
740eAc                   eval      x = 0
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   eval      nxtscr = '03 '
     C                   exsr      zzget3
     C                   exsr      zzfil3
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   eval      nxtscr = '04 '
     C                   exsr      zzfil4
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   eval      nxtscr = '05 '
     C                   exsr      zzfil5
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   eval      nxtscr = '06 '
     C                   exsr      zzfil6
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06a initialization
     *
     C     scr06ai       begsr
500dDC**                 eval      nxtscr = '10 '
500dMC                   eval      nxtscr = '06A'
     C                   exsr      zzfil6a
     C     end06ai       endsr
510a *----------------------------------------------------------------
510a *
510a *  Screen 06b initialization
510a *
510a C     scr06bi       begsr
510a C                   eval      nxtscr = '06B'
510a C                   exsr      zzfil6b
510a C     end06bi       endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  Screen 06c initialization
650aA*
650aAC     scr06ci       begsr
650aAC                   eval      nxtscr = '06C'
650aAC                   exsr      zzfil6c
650aAC     end06ci       endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  Screen 06d initialization
650bA*
650bAC     scr06di       begsr
650bAC                   eval      nxtscr = '06D'
650bAC                   exsr      zzfil6d
650bAC     end06di       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  Screen 06e initialization
730qA*
730qAC     scr06ei       begsr
730qAC                   eval      nxtscr = '06E'
730qAC                   exsr      zzfil6e
730qAC     end06ei       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  Screen 06f initialization
730qA*
730qAC     scr06fi       begsr
730qAC                   eval      nxtscr = '06F'
730qAC                   exsr      zzfil6f
730qAC     end06fi       endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   eval      nxtscr = '07 '
     C                   eval      wtchk = '0'
     *  Get catch wt options.
     C                   exsr      zzfil7
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   eval      nxtscr = '08 '
     C                   exsr      zzfil8
     C     end08i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   eval      nxtscr = '09 '
     C                   exsr      zzfil9
     C     end09i        endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  Screen 09A initialization
ISPaA*
ISPaAC     scr09ai       begsr
ISPaAC                   eval      nxtscr = '09A'
ISPaAC                   exsr      zzfil9a
ISPaAC     end09ai       endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  Screen 10 initialization
500dA*
500dAC     scr10i        begsr
     C                   eval      nxtscr = '10 '
     C                   exsr      zzfil10
     C     end10i        endsr
     *----------------------------------------------------------------
700fA*
700fA*  Screen 11 initialization
700fA*
700fAC     scr11i        begsr
700fAC                   eval      reccycle =0
740eAc                   eval      x = 0
700fAc     begread       tag
700fAc                   exsr      getrecord
700fAc                   if        %eof
700fAc                   eval      reccycle += 1
700fAc                   if        reccycle >=2
740lAc*** check for zone pickup
740lAc                   if        wktype = 'O'
740lAc                   eval      firstzonepick = '1'
740lAc                   exsr      zznxt
740lDc*                  exsr      scr14i
740lAc                   goto      end11i
740lAc                   else
700fAc                   goto      end11i
740lAc                   endif
700fAc                   endif
700fAc                   exsr      getlowlimit
700fAC                   eval      aisle = *blanks
750lAC                   eval      showaisle = *blanks
700fAc                   goto      begread
700fAc                   else
700fA* If aisle is the same as tie last aisle the go to location
700fA* screen else go to aisle screen.
740lAc                   if        wktype = 'O'
740lAc                   eval      olabel = *on
740lAc                   endif

700fAc                   if        multitran
700fAc                   if        slwstyp = 'M'
700fAc                   goto      begread
700fAc                   endif
700fAc                   else
700fAc                   if        lbtype = 'M'
700fAc                   goto      begread
700fAc                   endif
700fAc                   end
700fAc                   exsr      zzchk11a
700fAc                   if        error = *on
700fAc                   goto      begread
700fAc                   endif
700fAc
750qA /free
750qA    // When using belt printer get combo info
750qA
750qA    bulkLabel = *off;
750qA    comboLabel = *off;
750qA
750qA    if usingBeltPrt;
750qA
750qA      exec sql
750qA        select lolbltype, lolblcombo into :lolbltype, :lolblcombo
750qA          from labelout
750qA         where lowhse = :lbwhse and lortid = :w2rtid
750qA           and lolbl = :w2lbl and lolblcnt = 1;
750qA
750qA      if sqlstt <> sqlSuccess;
750qA        lolbltype = '';
750qA        lolblcombo = '0';
750qA      endif;
750qA
750qA      if lolbltype = 'B';
750qA        bulkLabel = *on;
750qA      endif;
750qA      if lolblcombo = '1';
750qA        comboLabel = *on;
750qA      endif;
750qA
750qA    endif;
750qA /end-free
700fAc                   if        multitran
750lDC*                  if        aisle = slwaisl
750lMC                   if        showaisle = slwaisl
MQSaAC                             or client = Marques
MQSaAc                             and FirstMslot = *off
700fAc                   exsr      zzupd11
700fAc                   else
700fAC                   eval      nxtscr = '11 '
700fAc                   endif
700fAc                   else
750lDC*                  if        aisle = lbaisl
750lMC                   if        showaisle = lbaisl
MQSaAC                             or client = Marques
MQSaAc                             and FirstMslot = *off
700fAc                   exsr      zzupd11
700fAc                   else
700fAC                   eval      nxtscr = '11 '
700fAc                   endif
700fAc                   endif
700fAc                   exsr      zzfil11
MQSaAc                   if        client = Marques
MQSaAc                             and %subst(aisle:1:1) = 'M'
MQSaAc                   eval      FirstMSlot = *off
MQSaAc                   endif
700fAc                   endif
700fAC     end11i        endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  Screen 12V initialization
740eA*
740eAC     scr12Vi       begsr
740eAC                   eval      nxtscr = '12V'
740eAC                   exsr      zzfil12V
740eAC     end12vi       endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  Screen 14  initialization
720cA*
720cAC     scr14i        begsr
720cAC                   eval      nxtscr = '14 '
752vA /free
752vA   exsr clrSPmrgfiles;
752vA /end-free
720cAc*                  exsr      zzchk11a
720cAC                   exsr      zzfil14
720cAC     end14i        endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  Screen 15  initialization
720cA*
720cAC     scr15i        begsr
720cAC                   eval      nxtscr = '15 '
720cAC                   exsr      zzfil15
720cAC     end15i        endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  Screen 16  initialization
720dA*
720dAC     scr16i        begsr
720dAC                   eval      nxtscr = '16 '
720dAC                   exsr      zzfil16
720dAC     end16i        endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  Screen 17 initialization
720hA*
720hAC     scr17i        begsr
720hAC                   eval      nxtscr = '17 '
720hAC                   exsr      zzfil17
720hAC     end17i        endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  Screen 18 initialization
720hA*
720hAC     scr18i        begsr
720hAC                   eval      nxtscr = '18 '
720hAC                   exsr      zzfil18
720hAC     end18i        endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  Screen 19 initialization
720hA*
720hAC     scr19i        begsr
720hAC                   eval      nxtscr = '19 '
720hAC                   exsr      zzfil19
720hAC     end19i        endsr
720lA*----------------------------------------------------------------
720lA*
720lA*  Screen 20  initialization
720lA*
720lAC     scr20i        begsr
720lAC                   eval      nxtscr = '20 '
720lAC                   exsr      zzfil20
720lAC     end20i        endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  Screen 21  initialization
730qA*
730qAC     scr21i        begsr
730qAC                   eval      nxtscr = '21 '
730qAC                   exsr      zzfil21
730qAC     end21i        endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  Screen 22  initialization
740dA*
740dAC     scr22i        begsr
740dAC                   eval      nxtscr = '22 '
740dAC                   exsr      zzfil22
740dAC     end22i        endsr
740lA*----------------------------------------------------------------
740lA*
740lA*  Screen 23  initialization
740lA*
740lAC     scr23i        begsr
740lAC                   eval      nxtscr = '23 '
740lAC                   exsr      zzfil23
740lAC     end23i        endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  Screen 81  initialization
750pA*
750pAC     scr81i        begsr
      /free
        nxtscr = '81';
        exsr zzfil81;
      /end-free
     C                   endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  Screen 82  initialization
750pA*
750pAC     scr82i        begsr
      /free
        nxtscr = '82';
        exsr zzfil82;
      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  Screen 86  initialization
751uA*
751uAC     scr86i        begsr
      /free
        nxtscr = '86';
      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  Screen 88  initialization
752vA*
752vAC     scr88i        begsr
      /free
        nxtscr = '88';
        exsr zzfil88;
      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  Screen 89  initialization
752vA*
752vAC     scr89i        begsr
752vA /free
752vD   //nxtscr = '89';
752vA   exsr zzfil89;
752vA /end-free
752vAC                   endsr
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
751wAC                             or *inkl
751wAC                   if        trncnt > 0
751wAC                   exsr      zzrset
751wAC                   endif
720dAc                   if        w1eod  = 'Y'
730kAc                   if        opeqpj = 'Y'
720cAc                   CALL      'EQ410CL'
730kAc                   endif
     *
730kAC                   exsr      zzcktn
     *
730kAC                   if        ufinfl = *on
730kAC                   eval      error = *on
730kAC                   eval      *in22 = *on
730kAC                   eval      *in02 = *on
730kAC                   eval      errmsg = *blanks
730kAC                   eval      errmsg = $slcuoerrtext
730kAC                   exsr      zm0105
730kAC                   eval      w1eod = 'N'
730kAC                   eval      ufinfl = *off
730kAC                   eval      *inkc = *off
730kAC                   goto      endsc1
730kAC                   else
730k *
730kAC                   eval      $hdrcommand = 'endday'
730kAC                   time                    curtime
730kAC                   eval      $hdrtimestamp = %char(curtime)
730kAC                   eval      $slbeitman# = #job
730kAc                   eval      $slbeiemp# = $emp#
730kAc                   eval      $pheader = $header
730kAc                   eval      $pfields = $slbedayin
730kAc                   exsr      writelog
730kAc                   call      'VOSELECT'
730kAC                   parm      '*none'       $pdqlib
730kAC                   parm      '*none'       $pdqnameout
730kAC                   parm      '*none'       $pdqkey
730kAC                   parm                    $pheader
730kAC                   parm                    $pfields
730kAC                   parm                    $prtnfields
730kAC                   eval      $slbedayout = $prtnfields
730kAC                   eval      nxtscr = 'EOJ'
730kAC                   eval      w1eod = 'N'
730kAC                   eval      *inkc = *off
730kAC                   goto      endsc1
730kAc                   endif
730kAc                   else
730kAC                   eval      nxtscr = 'EOJ'
730kAC                   goto      endsc1
730kAc                   endif
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
650cA*
650cA*  Test for F7 - Task change
650cA*
650cAC                   if        *inkg
650cAC                   exsr      indtask
650cAC                   goto      endsc1
650cAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
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
740jAc                   if        $slititask <> ' '
740jAc                   exsr      endindtask
740jAc                   endif
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
700fAc     endsc1        tag
700fAc                   exsr      zsclr
700fMC                   endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
650cA*
650cA*  Test for F7 - Task change
650cA*
650cAC                   if        *inkg
650cAC                   exsr      indtask
650cAC                   goto      endsc2
650cAC                   endif
     *
     *  Test for F12 - Previous
     *   Only allowed if nothing has been selected
     *
     C                   if        *inkl
     C                   if        first2 = *off
     *   Reset started transaction.
700fAc                   if        oprfpm = '1'
     C                   exsr      zzrset
700fAc                   else
700fAC                   eval      $slrtoerrnum = 0
700fAc                   endif
501jAC                   if        $slrtoerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C*                  eval      errmsg = $slrtoerrtext
     C*                  exsr      zm9898
     C                   eval      ertrn# = $slrtotrn#
     C                   exsr      zm2002
     C                   goto      endsc2
     C                   else
700fAc                   if        oprfpm = '2'
740lAc                   if        whereFrom = '14 '
740lAc                   eval      nxtscr = '14 '
740lAC                   goto      endsc2
740lAc                   endif
700fAc                   if        whereFrom = '11'
700fAc                   eval      nxtscr = '11 '
700fAc                   else
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
750yAc                   exsr      zzresetl
750yAc                   exsr      scr12Vi
750yDc****               eval      nxtscr = '12V'
740eAc                   else
752hAc                   exsr      zzresetl
700fAc                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700fAc                   endif
700fAc                   else
750lAc                   exsr      zzreset
     C                   exsr      scr01i
700fAc                   endif
     C                   goto      endsc2
     C                   endif
     C                   else
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm9898
     C                   goto      endsc2
     C                   endif
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
740jAc                   if        $slititask <> ' '
740jAc                   exsr      endindtask
740jAc                   endif
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *  SC3  -  Screen 3
     *
     C     sc3           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc  and
     C                             not *in92
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr03i
     C                   goto      endsc3
     C                   endif
650cA*  Test for F7 - Task change
650cA*
650cAC                   if        *inkg
650cAC                   exsr      indtask
650cAC                   goto      endsc3
650cAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   if        first2 = *off
     C                   exsr      scr02i
     C                   goto      endsc3
     C                   else
     C                   eval      error = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(1)
     C                   exsr      zm9898
     C                   goto      endsc3
     C                   endif
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
740jAc                   if        $slititask <> ' '
740jAc                   exsr      endindtask
740jAc                   endif
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
650aAC     redspl        cabeq     *on           endsc3
     C                   exsr      zzupd3
     C     error         cabeq     *on           endsc3
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd3
     C     cmdtkn        cabeq     *on           endsc3
     *
     C     endsc3        endsr
     *----------------------------------------------------------------
     *
     *  SC4  -  Screen 4
     *
     C     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C**                 exsr      zzabt3
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
650bDC*                  if        *inkl
650bDC*                  exsr      scr03i
650bDC*                  goto      endsc4
650bDC*                  endif

650bMC                   if        *inkl
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAC                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAc                   endif
650bAC                   goto      endsc4
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc4
650bAC                   endif
650bAC                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk4
     C     error         cabeq     *on           endsc4
     C                   exsr      zzupd4
     C     error         cabeq     *on           endsc4
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
     *----------------------------------------------------------------
     *
     *  SC5  -  Screen 5
     *
     C     sc5           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C**                 exsr      zzabt3
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr05i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C**                 exsr      zzabt3
750lAc                   exsr      zzreset
     C                   exsr      scr01i
     C                   goto      endsc5
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     C     endsc5        endsr
     *----------------------------------------------------------------
     *
     *  SC6  -  Screen 6
     *
     C     sc6           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr06i
     C                   goto      endsc6
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
740eDc*                            and ufinfl = *off
650bDC*                  exsr      scr01i
650bDC*                  goto      endsc6
650bAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6
740lAc                   endif
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAC                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAC                   endif
650bAC                   goto      endsc6
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAc                   exsr      zm9898
650bAC                   goto      endsc6
650bAC                   endif
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc6
650aAC                   endif
     C                   endif
720cAC                   if        *inkl
720cAc                             and ufinfl = *on
720cAc                   eval      errmsg = 'F12 not allowed on unfinished tran+
720cAc                                      saction'
720cAC                   exsr      zm9898
720cAC                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
     C                   exsr      zzupd6
     C     error         cabeq     *on           endsc6
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd6
     C     cmdtkn        cabeq     *on           endsc6
     *
     C     endsc6        endsr
     *----------------------------------------------------------------
     *
     *  SC6a -  Screen 6a
     *
     C     sc6a          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc6a
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr06ai
     C                   goto      endsc6a
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
650bDC*                  exsr      scr01i
650bDC*                  goto      endsc6a
650bAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6a
740lAc                   endif
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAc                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAc                   endif
650bAC                   goto      endsc6a
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAc                   exsr      zm9898
650bAC                   goto      endsc6a
650bAC                   endif
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc6a
650aAC                   endif
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6a
     C     cmdtkn        cabeq     *on           endsc6a
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk6a
     C     error         cabeq     *on           endsc6a
     C                   exsr      zzupd6a
     C     error         cabeq     *on           endsc6a
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd6a
     C     cmdtkn        cabeq     *on           endsc6a
     *
     C     endsc6a       endsr
510a *----------------------------------------------------------------
510a *
510a *  SC6B -  Screen 6B
510a *
510a C     sc6b          begsr
510a *
510a *  Test for F3 - Exit
510a *
510a C                   if        *inkc
510a C                   eval      nxtscr = 'EOJ'
510a C                   goto      endsc6b
510a C                   endif
510a *
510a *  Test for F5 - Refresh
510a *
510a C                   if        *inke
510a C                   exsr      scr06bi
510a C                   goto      endsc6b
510a C                   endif
510a *
510a *  Test for F12 - Previous
510a *
510a C                   if        *inkl
650bDC*                  exsr      scr01i
650bDC*                  goto      endsc6b
650bAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6b
740lAc                   endif
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAc                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAc                   endif
650bAC                   goto      endsc6b
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAc                   exsr      zm9898
650bAC                   goto      endsc6b
650bAC                   endif
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc6b
650aAC                   endif
510a C                   endif
510a *
510a *  Test for other command keys BEFORE verification and update.
510a *
510a C                   eval      cmdchk = '*BEFORE '
510a C                   exsr      zzcmd6b
510a C     cmdtkn        cabeq     *on           endsc6b
510a *
510a *  Some other key pressed.
510a *
510a *     Check input and write/update record.
510a *
510a C                   exsr      zzchk6b
510a C     error         cabeq     *on           endsc6b
510a C                   exsr      zzupd6b
510a C     error         cabeq     *on           endsc6b
510a *
510a *  Test for other command keys AFTER verification and update.
510a *
510a C                   eval      cmdchk = '*AFTER  '
510a C                   exsr      zzcmd6b
510a C     cmdtkn        cabeq     *on           endsc6b
510a *
510a C     endsc6b       endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  SC6c -  Screen 6c
650aA*
650aAC     sc6c          begsr
650aA*
650aA*  Test for F3 - Exit
650aA*
650aAC                   if        *inkc
650aAC                   eval      nxtscr = 'EOJ'
650aAC                   goto      endsc6c
650aAC                   endif
650aA*
650aA*  Test for F5 - Refresh
650aA*
650aAC                   if        *inke
650aAC                   exsr      scr06ci
650aAC                   goto      endsc6c
650aAC                   endif
650aA*
650aA*  Test for F12 - Previous
650aA*
650aAC                   if        *inkl
750oA /free
750oA   clear saveaisle;
750oA   clear saveloc;
750oA   clear savelvl;
750oA   clear savehand;
750oA /end-free
650bAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6c
740lAc                   endif
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAc                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAc                   endif
650bAC                   goto      endsc6c
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAc                   exsr      zm9898
650bAC                   goto      endsc6c
650bAC                   endif
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc6c
650bDC*                  exsr      scr01i
650aAC*                  goto      endsc6c
650aAC                   endif
650aAC                   endif
650aA*
650aA*  Test for other command keys BEFORE verification and update.
650aA*
650aAC                   eval      cmdchk = '*BEFORE '
650aAC                   exsr      zzcmd6c
650aAC     cmdtkn        cabeq     *on           endsc6c
650aA*
650aA*  Some other key pressed.
650aA*
650aA*     Check input and write/update record.
650aA*
650aAC                   exsr      zzchk6c
650aAC     error         cabeq     *on           endsc6c
650aAC                   exsr      zzupd6c
650aAC     error         cabeq     *on           endsc6c
650aA*
650aA*  Test for other command keys AFTER verification and update.
650aA*
650aAC                   eval      cmdchk = '*AFTER  '
650aAC                   exsr      zzcmd6c
650aAC     cmdtkn        cabeq     *on           endsc6c
650aA*
650aAC     endsc6c       endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  SC6d -  Screen 6d
650bA*
650bAC     sc6d          begsr
650bA*
650bA*  Test for F3 - Exit
650bA*
650bAC                   if        *inkc
650bAC                   eval      nxtscr = 'EOJ'
650bAC                   goto      endsc6d
650bAC                   endif
650bA*
650bA*  Test for F5 - Refresh
650bA*
650bAC                   if        *inke
650bAC                   exsr      scr06di
650bAC                   goto      endsc6d
650bAC                   endif
650bA*
650bA*  Test for F12 - Previous
650bA*
650bAC                   if        *inkl
650bDC*                  exsr      scr01i
650aAC*                  goto      endsc6c
650bAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6d
740lAc                   endif
650bAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
700fAc                   if        oprfpm = '2'
700fAc                   exsr      zzupd11
700fAc                   else
650bAC                   exsr      scr03i
700fAc                   endif
650bAC                   goto      endsc6d
650bAC                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAc                   exsr      zm9898
650bAC                   goto      endsc6d
650bAC                   endif
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = desc(1)
650bAC                   exsr      zm9898
650bAC                   goto      endsc6d
650aAC                   endif
650bAC                   endif
650bA*
650bA*  Test for other command keys BEFORE verification and update.
650bA*
650bAC                   eval      cmdchk = '*BEFORE '
650bAC                   exsr      zzcmd6d
650bAC     cmdtkn        cabeq     *on           endsc6d
650bA*
650bA*  Some other key pressed.
650bA*
650bA*     Check input and write/update record.
650bA*
650bAC                   exsr      zzchk6d
650bAC     error         cabeq     *on           endsc6d
650bAC                   exsr      zzupd6d
650bAC     error         cabeq     *on           endsc6d
650bA*
650bA*  Test for other command keys AFTER verification and update.
650bA*
650bAC                   eval      cmdchk = '*AFTER  '
650bAC                   exsr      zzcmd6d
650bAC     cmdtkn        cabeq     *on           endsc6d
650bA*
650bAC     endsc6d       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  SC6e -  Screen 6e
730qA*
730qAC     sc6e          begsr
730qA*
730qA*  Test for F3 - Exit
730qA*
730qAC                   if        *inkc
730qAC                   eval      nxtscr = 'EOJ'
730qAC                   goto      endsc6e
730qAC                   endif
730qA*
730qA*  Test for F5 - Refresh
730qA*
730qAC                   if        *inke
730qAC                   exsr      scr06ei
730qAC                   goto      endsc6e
730qAC                   endif
730qA*
730qA*  Test for F12 - Previous
730qA*
730qAC                   if        *inkl
730qAC                   if        first6a = *off and first6 = *off
740lAC                   if        wktype = 'M'
740lAc                   eval      nxtscr = wherefrom
740lAc                   goto      endsc6e
740lAc                   endif
730qAc                   if        oprfsl = 'Y'
740eAc                             or oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
730qAc                   if        oprfpm = '2'
730qAc                   exsr      zzupd11
730qAc                   else
730qAC                   exsr      scr03i
730qAc                   endif
730qAC                   goto      endsc6e
730qAC                   else
730qAC                   eval      error = *on
730qAC                   eval      errmsg = *blanks
730qAC                   eval      errmsg = desc(1)
730qAc                   exsr      zm9898
730qAC                   goto      endsc6e
730qAC                   endif
730qAc                   else
730qAC                   eval      error = *on
730qAC                   eval      errmsg = *blanks
730qAC                   eval      errmsg = desc(1)
730qAC                   exsr      zm9898
730qAC                   goto      endsc6e
730qAC                   endif
730qAC                   endif
730qA*
730qA*  Test for other command keys BEFORE verification and update.
730qA*
730qAC                   eval      cmdchk = '*BEFORE '
730qAC                   exsr      zzcmd6e
730qAC     cmdtkn        cabeq     *on           endsc6e
730qA*
730qA*  Some other key pressed.
730qA*
730qA*     Check input and write/update record.
730qA*
730qAC                   exsr      zzchk6e
730qAC     error         cabeq     *on           endsc6e
730qAC                   exsr      zzupd6e
730qAC     error         cabeq     *on           endsc6e
730qA*
730qA*  Test for other command keys AFTER verification and update.
730qA*
730qAC                   eval      cmdchk = '*AFTER  '
730qAC                   exsr      zzcmd6e
730qAC     cmdtkn        cabeq     *on           endsc6e
730qA*
730qAC     endsc6e       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  SC6f -  Screen 6f
730qA*
730qAC     sc6f          begsr
730qA*
730qA*  Test for F3 - Exit
730qA*
730qAC*                  if        *inkc
730qAC*                  eval      nxtscr = 'EOJ'
730qAC*                  goto      endsc6f
730qAC*                  endif
730qA*
730qA*  Test for F5 - Refresh
730qA*
730qAC*                  if        *inke
730qAC*                  exsr      scr06fi
730qAC*                  goto      endsc6f
730qAC*                  endif
730qA*
730qA*  Test for F12 - Previous
730qA*
730qAC                   if        *inkl
730qAc                   eval      w6uci = ' '
730qAc                   eval      nxtscr = '06E'
730qAC                   goto      endsc6f
730qAC                   endif
730qA*
730qA*  Test for other command keys BEFORE verification and update.
730qA*
730qAC                   eval      cmdchk = '*BEFORE '
730qAC                   exsr      zzcmd6f
730qAC     cmdtkn        cabeq     *on           endsc6f
730qA*
730qA*  Some other key pressed.
730qA*
730qA*     Check input and write/update record.
730qA*
730qAC                   exsr      zzchk6f
730qAC     error         cabeq     *on           endsc6f
730qAC                   exsr      zzupd6f
730qAC     error         cabeq     *on           endsc6f
730qA*
730qA*  Test for other command keys AFTER verification and update.
730qA*
730qAC                   eval      cmdchk = '*AFTER  '
730qAC                   exsr      zzcmd6f
730qAC     cmdtkn        cabeq     *on           endsc6f
730qA*
730qAC     endsc6f       endsr
     *----------------------------------------------------------------
     *
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr07i
     C                   goto      endsc7
     C                   endif
720nA*
720nA*      F6 - Done with weights
720nA*
720nAC                   if        *inkf
BADbAC                   if        client <> BigApple
720nAc                   eval      donewithwgt = *on
BADbAc                   endif
720nAc                   endif
700dA*
700dA*      F7 - kilograms/Pounds Toggle
700dA*
700dAC                   if        *inkg
700dAC                   eval      cmdtkn = *on

750fA /free
750fA  //select;
750fA  //  when prime and spBtnClick = 'S18';
750fA  //    KiloLbs = 'P';
750fA  //    W7um1   = 'Lbs';
750fA  //    *in31 = *on;
750fA  //  when prime and spBtnClick = 'S19';
750fA  //    KiloLbs = 'K';
750fA  //    w7um1   = 'Kgs';
750fA  //    *in31 = *off;
750fA  //  other;
750fA /end-free

700dAC                   if        KiloLbs = 'P'
700dAC                   eval      KiloLbs = 'K'
700dAC                   eval      w7um1   = 'Kgs'
700dAC                   Eval      *in31 = *off
700dAC                   else
700dAC                   eval      KiloLbs = 'P'
700dAC                   eval      W7um1   = 'Lbs'
700dAC                   Eval      *in31 = *on
700dAC                   endif

750fA /free
750fA  //endsl;
750fA /end-free

700dAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl

750fA /free
750fA    if prime;
750fA      error = *on;
750fA      errmsg = 'Cancel Not Allowed';
750fA    else;
750fA /end-free

750lAc                   exsr      zzreset
     C                   exsr      scr01i

750fA /free
750fA    endif;
750fA /end-free

     C                   goto      endsc7
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd7
     C     cmdtkn        cabeq     *on           endsc7
     *
     C     endsc7        endsr
     *----------------------------------------------------------------
     *
     *  SC8  -  Screen 8
     *
     C     sc8           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr08i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr07i
     C                   goto      endsc8
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     C     endsc8        endsr
     *----------------------------------------------------------------
     *
     *  SC9  -  Screen 9
     *
     C     sc9           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr09i
     C                   goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc9
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     C     endsc9        endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  SC9a  -  Screen 9a
ISPaA*
ISPaAC     sc9a          begsr
ISPbA*
ISPbA*  Test for F3 - Exit
ISPbA*
ISPbAC                   if        *inkc
ISPbAC                   eval      nxtscr = 'EOJ'
ISPbAC                   goto      endsc9a
ISPbAC                   endif
ISPbA*
ISPbA*  Test for F12 - Previous
ISPbA*
ISPbAC                   if        *inkl
ISPbAC                   eval      nxtscr = 'EOJ'
ISPbAC                   goto      endsc9a
ISPbAC                   endif
ISPaA*
ISPaA*     Check input and write/update record.
ISPaA*
ISPaAC                   if        client = isupply
ISPaAC                   exsr      zzchk9a
ISPaAC     error         cabeq     *on           endsc9a
ISPaAC                   exsr      zzupd9a
ISPaAC     error         cabeq     *on           endsc9a
ISPaAC                   endif
ISPaA*
ISPaA*  Test for other command keys AFTER verification and update.
ISPaA*
     C                   eval      nxtscr = 'EOJ'
ISPaAC                   eval      cmdchk = '*AFTER  '
ISPaAC                   exsr      zzcmd9a
ISPaAC     cmdtkn        cabeq     *on           endsc9a
ISPaA*
ISPaAC     endsc9a       endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  SC10 -  Screen 10
500dA*
500dAC     sc10          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc10
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr10i
     C                   goto      endsc10
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc10
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk10
     C     error         cabeq     *on           endsc10
     C                   exsr      zzupd10
     C     error         cabeq     *on           endsc10
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   eval      cmdchk = '*AFTER  '
     C                   exsr      zzcmd10
     C     cmdtkn        cabeq     *on           endsc10
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc10       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  SC11 -  Screen 11
700fA*
700fAC     sc11          begsr
700fA*
700fA*  Test for F3 - Exit
700fA*
700fAC                   if        *inkc
700fAC                   eval      nxtscr = 'EOJ'
700fAC                   goto      endsc11
700fAC                   endif
700fA*
700fA*  Test for F5 - Refresh
700fA*
700fAC                   if        *inke
700fAC                   exsr      scr11i
700fAC                   goto      endsc11
700fAC                   endif
700fA*
700fA*  Test for F8 - Go to Label Screen
700fA*
700fAC                   if        *inkh
700fAc                   eval      whereFrom = '11'
700fAc                   eval      first2 = *off
700fAc                   exsr      scr02i
700fAC                   goto      endsc11
700fAC                   endif
700fA*
700fA*  Test for F12 - Previous
700fA*
700fAC                   if        *inkl
700fA*  Check For Picked Status
700fAc                   exsr      zzchk11
700iDC*                  if        $slvloerrnum = 031
700iAC                   if        error = *on
700fAC                   eval      nxtscr = '13 '
700fAC                   eval      whereFrom = '11'
700fAC                   goto      endsc11
700fAc                   else
700fA*  Reset Transaction
700fAC                   exsr      zzrset
750lAc                   exsr      zzreset
700fAc                   exsr      scr01i
700fAc                   goto      endsc11
700fAc                   endif
700fAC                   endif
700fA*
700fAc                   exsr      zzupd11
700fA*
700fAc     endsc11       tag
700fAc                   exsr      zsclr
700fAC                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  SC12 -  Screen 12
700fA*
700fAC     sc12          begsr
720nA*
720nA*  Test for F1 - Next Slot
720nA*
720nAC                   if        *inka
720nAc                   eval      whereFrom = '12'
720nAc                   eval      first2 = *off
720nAc                   exsr      zzmore
720nAc                   if        morelb = 'Y'
720nAC                   exsr      scr11i
720nAC                   goto      endsc12
720nAC                   endif
720nAC                   endif
720hA*
720hA*  Test for F6 - Enter Weigh later weights
720hA*
720hAC                   if        *inkf
720hAc                   eval      whereFrom = '12'
720hAC                   exsr      scr19i
720hAC                   goto      endsc12
720hAC                   endif
700fA*
700fA*  Test for F7 - Task change
700fA*
700fAC                   if        *inkg
700fAc                   eval      whereFrom = '12'
700fAC                   exsr      indtask
700fAC                   goto      endsc12
700fAC                   endif
700fA*
700fA*  Test for F8 - Go to Label Screen
700fA*
700fAC                   if        *inkh
700fAc                   eval      whereFrom = '12'
700fAc                   eval      first2 = *off
700fAC                   exsr      scr02i
700fAC                   goto      endsc12
700fAC                   endif
700fA*
700fA*  Test for F12 - Previous
700fA*
700fAC                   if        *inkl
720cAc                             and ufinfl = *off
740eDc*****              exsr      zzchk11
700iDC*                  if        $slvloerrnum = 031
740eDC*****              if        error = *on
740eDC*****              eval      nxtscr = '13 '
740eDC*****              eval      whereFrom = '12'
740eDC*****              goto      endsc12
740eDc*****              else
700fAC                   exsr      zzrset
750lAc                   exsr      zzreset
700fAc                   exsr      scr01i
700fAc                   goto      endsc12
700fAc                   endif
740eDC*****              endif
720cAC                   if        *inkl
720cAc                             and ufinfl = *on
740eAC                   eval      nxtscr = '13 '
740eAC                   eval      whereFrom = '12'
740eAC                   goto      endsc12
740eDc*****              eval      errmsg = 'F12 not allowed on unfinished tran+
740eDc*****                                 saction'
740eDC*****              exsr      zm9898
720cAC                   endif
700fA
700fA*  Test for other command keys BEFORE verification and update.
700fA*
700fAC                   eval      cmdchk = '*BEFORE '
700fAC                   exsr      zzcmd12
700fAC     cmdtkn        cabeq     *on           endsc12
740jAc                   if        $slititask <> ' '
740jAc                   exsr      endindtask
740jAc                   endif
700fAC                   exsr      zzchk12
700fAC     error         cabeq     *on           endsc12
720cAC     redspl        cabeq     *on           endsc12
700fA*
700fAC                   exsr      zzupd12
700fAC     endsc12       tag
700fAc                   exsr      zsclr
700fAC                   endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  SC12V-  Screen 12V
740eA*
740eAC     sc12v         begsr
740eA*
740eA*  Test for F1 - Next Slot
740eA*
740eAC                   if        *inka
740eAc                   eval      whereFrom = '12V'
740eAc                   eval      first2 = *off
740eAc                   exsr      zzmore
740eAc                   if        morelb = 'Y'
740eAC                   exsr      scr11i
740eAC                   goto      endsc12v
740eAC                   endif
740eAC                   endif
740eA*
740eA*  Test for F6 - Enter Weigh later weights
740eA*
740eAC                   if        *inkf
740eAc                   eval      whereFrom = '12V'
740eAC                   exsr      scr19i
740eAC                   goto      endsc12v
740eAC                   endif
740eA*
740eA*  Test for F7 - Task change
740eA*
740eAC                   if        *inkg
740eAc                   eval      whereFrom = '12V'
740eAC                   exsr      indtask
740eAC                   goto      endsc12v
740eAC                   endif
740eA*
740eA*  Test for F8 - Go to Label Screen
740eA*
740eAC                   if        *inkh
740eAc                   eval      whereFrom = '12V'
740eAc                   eval      first2 = *off
740eAC                   exsr      scr02i
740eAC                   goto      endsc12V
740eAC                   endif
740eA*
740eA*  Test for F12 - Previous
740eA*
740eAC                   if        *inkl
740eAc                             and ufinfl = *off
740eAC                   exsr      zzrset
750lAc                   exsr      zzreset
740eAc                   exsr      scr01i
740eAc                   goto      endsc12V
740eAc                   endif
740eAC                   if        *inkl
740eAc                             and ufinfl = *on
740eAC                   eval      nxtscr = '13 '
740eAC                   eval      whereFrom = '12V'
740eAC                   goto      endsc12v
740eAC                   endif
740eA
740eA*  Test for other command keys BEFORE verification and update.
740eA*
740eAC                   eval      cmdchk = '*BEFORE '
740eAC                   exsr      zzcmd12V
740eAC     cmdtkn        cabeq     *on           endsc12V
740jAc                   if        $slititask <> ' '
740jAc                   exsr      endindtask
740jAc                   endif
740eAC                   exsr      zzchk12V
740eAC     error         cabeq     *on           endsc12V
740eAC     redspl        cabeq     *on           endsc12V
740eA*
740eAC                   exsr      zzupd12V
740eAC     endsc12V      tag
740eAc                   exsr      zsclr
740eAC                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  SC13 -  Screen 13
700fA*
700fAC     sc13          begsr
700fA*
700fA*  Test for other command keys BEFORE verification and update.
700fA*
700fAC                   eval      cmdchk = '*BEFORE '
740eAC                   exsr      zzchk13
740eAC     error         cabeq     *on           endsc13
700fAc                   exsr      zzupd13
700fA*
700fAc                   if        spnd = 'Y'
750lAc                   exsr      zzreset
700fAC                   exsr      scr01i
700fAc                   else
740eAc                   eval      nxtscr = wherefrom
740eDc****               if        whereFrom = '11'
740eDc****               eval      nxtscr = '11 '
740eDc****               else
740eDc****               eval      nxtscr = '12 '
740eDc****               endif
700fAc                   endif
700fAC     endsc13       endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  SC14 -  Screen 14
720cA*
720cAC     sc14          begsr
720cA*
752vA*
752vA*  Test for F12 - Previous
752vA*
752vAC                   if        *inkl
752vAC                   goto      endsc14
752vAC                   endif

740lAC                   eval      whereFrom = '14 '
720cAc                   exsr      zzupd14
720cA*
720cAc     endsc14       tag
720cAc                   exsr      zsclr
720cAC                   endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  SC15 -  Screen 15
720cA*
720cAC     sc15          begsr
720cA *
720cA*  Test for F3 - Exit
720cA*
720cAC                   if        *inkc
720cAC                   eval      nxtscr = 'EOJ'
720cAC                   goto      endsc15
720cAC                   endif
720cA*
720cA*  Test for F5 - Refresh
720cA*
720cAC                   if        *inke
720cAC                   exsr      scr15i
720cAC                   goto      endsc15
720cAC                   endif
720cA*
720cA*  Test for F12 - Previous
720cA*
720cAC                   if        *inkl
720cAC                   eval      nxtscr = 'EOJ'
751wAC                   exsr      zzrset
751wAc                   exsr      zzreset
720cAC                   goto      endsc15
720cAC                   endif
720cA*
720cA*  Test for other command keys BEFORE verification and update.
720cA*
720cAC                   eval      cmdchk = '*BEFORE '
720cAC                   exsr      zzcmd15
720cAC     cmdtkn        cabeq     *on           endsc15
720cA*
720cA*  Some other key pressed.
720cA*
720cA*     Check input and write/update record.
720cA*
720cAC                   exsr      zzchk15
720cAC     error         cabeq     *on           endsc15
720cAC                   exsr      zzupd15
720cAC     error         cabeq     *on           endsc15
720cA*
720cA*  Test for other command keys AFTER verification and update.
720cA*
720cAC                   eval      cmdchk = '*AFTER  '
720cAC                   exsr      zzcmd15
720cAC     cmdtkn        cabeq     *on           endsc15
720cA*
720cAc     endsc15       tag
720cAc                   exsr      zsclr
720cAC                   endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  SC16 -  Screen 16
720dA*
720dAC     sc16          begsr
720dA*
720dA*     Check input and write/update record.
720dA*
720dAC                   exsr      zzchk16
720dAC     error         cabeq     *on           endsc16
720dAC                   exsr      zzupd16
720dAC     error         cabeq     *on           endsc16
720dA*
720dAc     endsc16       tag
720dAc                   exsr      zsclr
720dAC                   endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  SC17 -  Screen 17
720hA*
720hAC     sc17          begsr
752gA*      F6 - Done with weights
752gA*
752gAC                   if        *inkf
752gAC                   if        client <> BigApple
752gAc                   eval      donewithwgt = *on
752gAc                   endif
752gAc                   endif
720hA*
720hA*      F7 - kilograms/Pounds Toggle
720hA*
720hAC                   if        *inkg
720hAC                   eval      cmdtkn = *on
720hAC                   if        KiloLbs = 'P'
720hAC                   eval      KiloLbs = 'K'
720hAC                   eval      w7um1   = 'Kgs'
720hAC                   Eval      *in31 = *off
720hAC                   else
720hAC                   eval      KiloLbs = 'P'
720hAC                   eval      W7um1   = 'Lbs'
720hAC                   Eval      *in31 = *on
720hAC                   endif
720hAC                   endif
720hA*
720hA*  Test for F12 - Previous
720hA*
720hAC                   if        *inkl
720hAC                   exsr      scr18i
720hAC                   goto      endsc17
720hAC                   endif
720hA*
720hA*  Test for other command keys BEFORE verification and update.
720hA*
720hAC                   eval      cmdchk = '*BEFORE '
720hAC                   exsr      zzcmd17
720hAC     cmdtkn        cabeq     *on           endsc17
720hA*
720hA*  Some other key pressed.
720hA*
720hA*     Check input and write/update record.
720hA*
720hAC                   exsr      zzchk17
720hAC     error         cabeq     *on           endsc17
720hAC                   exsr      zzupd17
720hAC     error         cabeq     *on           endsc17
720hA*
720hA*  Test for other command keys AFTER verification and update.
720hA*
720hAC                   eval      cmdchk = '*AFTER  '
720hAC                   exsr      zzcmd17
720hAC     cmdtkn        cabeq     *on           endsc17
720hA*
720hAC     endsc17       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  SC18 -  Screen 18
720hA*
720hAC     sc18          begsr
720hA*
720hA*  Test for F12 - Previous
720hA*
720hAC                   if        *inkl
720hAc*                  exsr      zznxt
720hAC                   endif
720hA*
720hA*  Test for other command keys BEFORE verification and update.
720hA*
720hAC                   eval      cmdchk = '*BEFORE '
720hAC                   exsr      zzcmd18
720hAC     cmdtkn        cabeq     *on           endsc18
720hA*
720hA*  Some other key pressed.
720hA*
720hA*     Check input and write/update record.
720hA*
720hAC                   exsr      zzchk18
720hAC     error         cabeq     *on           endsc18
720hAC                   exsr      zzupd18
720hAC     error         cabeq     *on           endsc18
720hA*
720hA*  Test for other command keys AFTER verification and update.
720hA*
720hAC                   eval      cmdchk = '*AFTER  '
720hAC                   exsr      zzcmd18
720hAC     cmdtkn        cabeq     *on           endsc18
720hA*
720hAC     endsc18       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  SC19 -  Screen 19
720hA*
720hAC     sc19          begsr
720hA*
720hA*  Test for F12 - Previous
720hA*
720hAC                   if        *inkl
720iAc                   select
720iAc                   when      wherefrom = '11'
720hAc                   eval      nxtscr = '11 '
720iAc                   when      wherefrom = '18'
720iAc                   eval      nxtscr = '18 '
720iaC                   other
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
752gAc                   exsr      zzresetl
752gAc                   exsr      scr12Vi
752gDc*                  eval      nxtscr = '12V'
740eAc                   else
752hAc                   exsr      zzresetl
720hAc                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
720iDc*                  if        whereFrom = '11'
720iDc*                  else
720iDc*                  endif
720iAc                   endsl
720hAC                   goto      endsc19
720hAC                   endif
720hA*
720hA*  Test for other command keys BEFORE verification and update.
720hA*
720hAC                   eval      cmdchk = '*BEFORE '
720hAC                   exsr      zzcmd19
720hAC     cmdtkn        cabeq     *on           endsc19
720hA*
720hA*  Some other key pressed.
720hA*
720hA*     Check input and see if we have weights to enter
720hA*
720hAC                   exsr      zzchk19
720hAC     error         cabeq     *on           endsc19
720hAC                   exsr      zzupd19
720hAC     error         cabeq     *on           endsc19
720hA*
720hA*  Test for other command keys AFTER verification and update.
720hA*
720hAC                   eval      cmdchk = '*AFTER  '
720hAC                   exsr      zzcmd19
720hAC     cmdtkn        cabeq     *on           endsc19
720hA*
720hAC     endsc19       endsr
720lA*----------------------------------------------------------------
720lA*
720lA*  SC20 -  Screen 20
720lA*
720lAC     sc20          begsr
720lA*  Test for F12 - Previous
720lA*
720lAC                   if        *inkl
720lAC                   eval      nxtscr = wherefrom
720lAC                   goto      endsc20
720lAC                   endif
720lA*
720lA*     Check input and write/update record.
720lA*
720lAC                   exsr      zzchk20
720lAC     error         cabeq     *on           endsc20
720lAC                   exsr      zzupd20
720lAC     error         cabeq     *on           endsc20
720lA*
720lAc     endsc20       tag
720lAc                   exsr      zsclr
720lAC                   endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  SC21 -  Screen 21
730qA*
730qAC     sc21          begsr
730qA*
730qA*     Check input and write/update record.
730qA*
730qAC                   exsr      zzchk21
730qAC     error         cabeq     *on           endsc21
730qAC                   exsr      zzupd21
730qAC     error         cabeq     *on           endsc21
730qA*
730qAc     endsc21       tag
730qAc                   exsr      zsclr
730qAC                   endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  SC22 -  Screen 22
740dA*
740dAC     sc22          begsr
740dA*
740dA*     Check input and write/update record.
740dA*
740dAC                   exsr      zzchk22
740dAC     error         cabeq     *on           endsc22
740dAC                   exsr      zzupd22
740dAC     error         cabeq     *on           endsc22
740dA*
740dAc     endsc22       tag
740dAc                   exsr      zsclr
740dAC                   endsr
740lA*----------------------------------------------------------------
740lA*
740lA*  SC23 -  Screen 23
740lA*
740lAC     sc23          begsr
740lA*
740lA*  Test for other command keys BEFORE verification and update.
740lA*
740lAC                   eval      cmdchk = '*BEFORE '
740lAC                   exsr      zzchk23
740lAC     error         cabeq     *on           endsc23
740lAc                   exsr      zzupd23
740lA*
740lAC     endsc23       endsr
750fA*----------------------------------------------------------------
750pA*
750pA*  SC81 -  Screen 81 - Printer verification
750pA*
750pAC     sc81          begsr
750pA /free
750pA    exsr zzchk81;
750pA    if error;
750pA      leavesr;
750pA    endif;
750pA    exsr zzupd81;
751uD    //nxtscr = '01';
750pA /end-free
750pAC                   endsr
750lA*----------------------------------------------------------------
750lA*
750lA*  SC82 -  Screen 82 - Pallet summary
750lA*
750lAC     sc82          begsr
750lA*
750lA*  Test for F3 - Exit
750lA*
750lAC                   if        *inkc
750lAC                   eval      nxtscr = 'EOJ'
750lAC                   goto      endsc82
750lAc                   endif
750lA*
750lA*  Test for F12 - Previous
750lA*
750lAC                   if        *inkl
750lAC                   eval      nxtscr = '01 '
751wAC                   exsr      zzrset
750lAc                   exsr      zzreset
750lAC                   goto      endsc82
750lAC                   endif
750lA*
750lA*  Test for other command keys BEFORE verification and update.
750lA*
750lAC                   eval      cmdchk = '*BEFORE '
750lAC                   exsr      zzcmd82
750lAC     cmdtkn        cabeq     *on           endsc82
750lA*
750lA*  Some other key pressed.
750lA*
750lAC                   exsr      zzchk82
750lAC     error         cabeq     *on           endsc82
750lAc                   exsr      zzupd82
750lA*
750lA*  Test for other command keys AFTER verification and update.
750lA*
750lAC                   eval      cmdchk = '*AFTER  '
750lAC                   exsr      zzcmd82
750lAC     cmdtkn        cabeq     *on           endsc82
750lA*
750lAC     endsc82       endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  SC83 -  Screen 83 - Stop Summary
750qA*
750qAC     sc83          begsr
750qA /free
750qA    nxtscr = returnToScr;
750qA /end-free
750qAC                   endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  SC84 -  Screen 84 - Pick List
750qA*
750qAC     sc84          begsr
750qA /free

         // Test for F3 - Exit or F12 - Cancel

         if *inkc or *inkl or w84lb# = 0;
           nxtscr = returnToScr;
           leavesr;
         endif;

         // Some other key pressed

751pA    zonepickup = *off;
         exsr zzchk84;
         if error;
           leavesr;
         endif;

         exsr zzupd84;
      /end-free
     C                   endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  SC85 -  Screen 85 - Reprint
750qA*
750qAC     sc85          begsr
750qA /free
750qA
750qA    // Test for F3 - Exit or F12 - Cancel
750qA
750qA    if *inkc or *inkl;
750qA      nxtscr = returnToScr;
750qA      leavesr;
750qA    endif;
750qA
750qA    exsr zzchk85;
750qA    if error;
750qA      leavesr;
750qA    endif;
750qA    exsr zzupd85;
750qA    nxtscr = returnToScr;
750qA /end-free
750qAC                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  SC86 -  Screen 86 - Get Big Pallet printer id
751uA*
751uAC     sc86          begsr
      /free

         // Test for F3 - Exit or F12 - Cancel

         if *inkc or *inkl;
752sD      //nxtscr = returnToScr;
752sA      // Display End of Tran screen

752sA      exsr scr08i;
           leavesr;
         endif;

         exsr zzchk86;
         if error;
           leavesr;
         endif;
         exsr zzupd86;
      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  SC87 -  Screen 87 - Get pallet jack code
751uA*
751uAC     sc87          begsr
      /free
         // Test for F3 - Exit or F12 - Exit

         if *inkc or *inkl;
           nxtscr = 'EOJ';
           leavesr;
         endif;

         exsr zzchk87;
         if error;
           leavesr;
         endif;
         exsr zzupd87;
      /end-free
    AC                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  SC88 -  Screen 88 - Merge entry
752vA*
752vAC     sc88          begsr
      /free
         // Test for F3 - Exit or F12

         // if F3 - just redisplay  - should never happen
         if *inkc;
           leavesr;
         endif;

         // F12 can go back to previous screen if this is the first
         // time on Screen88, it will go back to screen14, which tells
         // them to goto zone pickup.
         if *inkl;
           if first88 = *off;
             if wherefrom = '14 ';
               exsr scr14i;
             else;
               nxtscr = wherefrom;
             endif;
             leavesr;
           else;
             errmsg = 'Cannot Cancel';
             leavesr;
           endif;
         endif;

         // done button
         if *inkf;
           morepickup = *off;
           exec sql update SPmrgwrk set
                       mgscan = 'D'
                   where mgjob = :#job
                     and mgtrn# = :mgtrn#
                     and mgscan = ' ';
           if multitran;
           else;
             wktype = 'O';
           endif;
           exsr zznxt;
           leavesr;
         endif;
         exsr zzchk88;
         if error;
           leavesr;
         endif;
         exsr zzupd88;
      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  SC89 -  Screen 89 - Merge list
752vA*
752vAC     sc89          begsr
      /free
           nxtscr = returnToScr;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
750fA /free
750qA
750qA   inzsrFlag = *on;
750fA
750fA   // Open screen if running interactively
750fA
750fA   GetJType (usingScreen);
750fA   if usingScreen;
752gD     //open or40029;
752gM     open or40030;
750fA   endif;
750fA
750fA   // See if called with SelectPrime
750fA
750fA   if not usingScreen and %parms >= 1;
750fA     prime = *on;
750fA     slgbuf = '<*inzsr>' + pjsonstr;
750fA     WriteVoiceLog('Inf': slgbuf);
750fA   else;
750fA     prime = *off;
750fA   endif;
750fA
750fA /end-free

500gA* Get client id

500gAC                   call      'GETCLIENT'
500gAC                   parm                    client
730wAc                   eval      AllowBulk = *off
750eAc                   eval      AllowBulk = *on
750eDc*                  if        client = merit
750eDc*                  eval      AllowBulk = *on
750eDc*                  endif
750eDc*                  if        client = BigApple
750eDc*                  eval      AllowBulk = *on
750eDc*                  endif
750eDc*                  if        client = Vitco
750eDc*                  eval      AllowBulk = *on
750eDc*                  endif
     *
     *  Initialize special keys
     *
730qDC*                  eval      enter = 0
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

     *----------------------------------------------------------------
     *  *PSSR  Unexpected error handler
     *----------------------------------------------------------------

     C     XpssrX        begsr
      /free

         *inlr = *on;

         //  Make sure we don't get caught in an infinite loop

         if pssrflag;
           return;
         endif;

         pssrflag = *on;

         //  Send message back to calling program.

         slgbuf = '<Err> '
                 + 'Error PSSR: ' + %trim(#prog)
                 + '('  + %trim(%editc(#stmt:'Z'))  + ')-'
                 + %trimr(#pgmmsg)
                 + ' - status ' + #status;
         WriteVoiceLog ('Err': slgbuf);
         return;

      /end-free
     C                   endsr
750gA*----------------------------------------------------------------
750gA*
750gA*  fillpallet-load pallet/zone
750gA*
750gAC     fillpallet    begsr
750gA /free
750gA   w6pal# = 0;
750gA   w6zone = ' ';
751eD   //w6pal# = $slvlopal#;
751eM   w6pal# = pspal#;
750gA   w6zone = $slvlohand2;
750gA /end-free
750gAC                   endsr
CBIbA*----------------------------------------------------------------
CBIbA*
CBIbA*  getevenodd for slot - slside
CBIbA*
CBIbA*    Get side flag for determining background color.
CBIbAC     getevenodd    begsr
CBIbAc                   exsr      clr$slot
CBIbAC                   eval      $dricommand = '*SLOT'
CBIbAC                   eval      $drisubcmd  = '%GET'
CBIbAC                   eval      $drisys2upd = 'D'
CBIbAC                   eval      $slwhseu = *on
CBIbAC                   eval      $slwhse = ptwhse
CBIbAC                   eval      $slwhdpu = *on
CBIbAC                   eval      $slwhdp = itwhdp
CBIbAC                   eval      $sldispu = *on
CBIbAC                   eval      $sldisp = lbdisp
CBIbAC                   exsr      zzzdricop
CBIbAC                   endsr
730pA*----------------------------------------------------------------
730pA*
730pA*  getuomdesc get uom description
730pA*
730pAC     getuomdesc    begsr
730pA /free
730pA   w6uom = ' ';
730pA   chain (lbucod) unmesr;
730pA   if %found(unmesr);
730pA     w6uom = umshrt;
730pA   endif;
730pA /end-free
730pAC                   endsr
751rA*----------------------------------------------------------------
751rA*
751rA*  getplidsec get the pallet id and section  - code from PFMT
751rA*
751rAC     getplidsec    begsr
752kA /free
752kA    $GetPlidSec();
752kA /end-free
751rAC                   endsr
650cA*----------------------------------------------------------------
650cA*
650cA*  INDTASK Indirect task requested
650cA*
650cAC     indtask       begsr
650cA* Call task selection
650cA
650cA*   SELECT TASK
650cA*
650cAC                   eval      $lcmd = '*LOOKUP '

750fA     // For Prime we would first call TK901 to create list,
750fA     // which gets sent back to fronend.
750fA     // Then, since no extra checks are done on the selection,
750fA     // we skip calling TK901 and process what was selected.

750fA /free
750fA     if not prime
750fA       or prime and spWhereFrom <> 'TK901.01';
750fA         if prime;
750fA           $lcmd = '*SPLIST';
750fA         endif;
750fA /end-free

650cAC                   eval      $lCAT  = 'MISC'
720dAC                   eval      $ltktype = 'I'
650cAC                   call      'TK901'
650cAC                   parm                    $lparm
750fAC                   parm                    pJsonStr

750fA /free
750fA     endif;
750fA /end-free

750fA /free
750fA     // We're done if only getting list for Prime
750fA     if $lcmd = '*SPLIST';
750fA       nxtscr = '91';
750fA       leavesr;
750fA     endif;
750fA     // For Prime, see if user is canceling Task selection
750fA     // $lcode is set in SetPgmField
750fA     // $lktype is remembered from doing *SPLIST
750fA     if prime;
750fA       if  %subst(spF1F24Flags: 12: 1) = '1';
750fA         $lrtn = '*CANCEL';
750fA       else;
750fA         $lrtn = '';
750fA       endif;
750fA     endif;
750fA /end-free

650cAC                   select
650cAC                   when      $lrtn = '*ERROR  '
650cAC                   when      $lrtn = '*CANCEL '
650cAC                   when      $lcode   = 'IDLE  '
650cAC                   when      $ltktype = 'I'
650cAc                   if        nxtscr > '01 '
650cA * suspend
720jDC*****              eval      $hdrcommand = 'suspend'
720jDC*****              time                    curtime
720jDC*****              eval      $hdrtimestamp = %char(curtime)
720jDC*****              eval      $slssitman#  = #job
720jDC*****              eval      $slssitrn#  = w1trn#
720jDC*****              eval      $pheader = $header
720jDC*****              eval      $pfields = $slsuspndin
720jDC*****              exsr      writelog
720jDC*****              call      'VOSELECT'
720jDC*****              parm      '*none'       $pdqlib
720jDC*****              parm      '*none'       $pdqnameout
720jDC*****              parm      '*none'       $pdqkey
720jDC*****              parm                    $pheader
720jDC*****              parm                    $pfields
720jDC*****              parm                    $prtnfields
720jDC*****              eval      $slsuspndout = $prtnfields
650cAc                   endif
650cA*   Indirect transaction.
650cAC                   eval      $hdrcommand = 'indtask'
650cAC                   time                    curtime
650cAC                   eval      $hdrtimestamp = %char(curtime)
650cAC                   eval      $slititman# = #job
650cAC                   eval      $slitiemp# = $emp#
650cAC                   eval      $slitiflag = '1'
650cAC                   eval      $slititask = $lcode
650cAC                   eval      $pheader = $header
650cAC                   eval      $pfields = $slindtskin
650cAC                   exsr      writelog
650cAC                   call      'VOSELECT'
650cAC                   parm      '*none'       $pdqlib
650cAC                   parm      '*none'       $pdqnameout
650cAC                   parm      '*none'       $pdqkey
650cAC                   parm                    $pheader
650cAC                   parm                    $pfields
650cAC                   parm                    $prtnfields
650cAC                   eval      $slindtskout = $prtnfields
650cA*
700lDC*                  if        $slasoerrnum <> 0
700lAC                   if        $slitoerrnum <> 0
650cAC                   eval      error = *on
650cAC                   eval      *in22 = *on
650cAC                   eval      *in02 = *on
650cAC                   eval      errmsg = *blanks
700lDC*                  eval      ertrn# = $slasotrn#
700lAC                   eval      ertrn# = $slitoerrnum
650cAC                   exsr      zm2002
650cAC                   else
650cAC                   endif
730iA *** don't alter nxtscr
700fAC*730iD             if        whereFrom = '12'
700fAc*730iD             eval      nxtscr = '12 '
700fAC*730iD             else
650cAC*730iD             exsr      scr01i
700fAc*730iD             end
650cAC                   when      $ltktype = 'D'
650cAc                   if        nxtscr > '01 '
650cA * suspend
720jDC*****              eval      $hdrcommand = 'suspend'
720jDC*****              time                    curtime
720jDC*****              eval      $hdrtimestamp = %char(curtime)
720jDC*****              eval      $slssitman#  = #job
720jDC*****              eval      $slssitrn#  = w1trn#
720jDC*****              eval      $pheader = $header
720jDC*****              eval      $pfields = $slsuspndin
720jDC*****              exsr      writelog
720jDC*****              call      'VOSELECT'
720jDC*****              parm      '*none'       $pdqlib
720jDC*****              parm      '*none'       $pdqnameout
720jDC*****              parm      '*none'       $pdqkey
720jDC*****              parm                    $pheader
720jDC*****              parm                    $pfields
720jDC*****              parm                    $prtnfields
720jDC*****              eval      $slsuspndout = $prtnfields
650cAc                   endif
650cA*   begday/endday transaction
650cAC                   if        $lcode = 'BEGDAY'
650cAC                   eval      $hdrcommand = 'begday'
650cAC                   endif
650cAC                   if        $lcode = 'ENDDAY'
650cAC                   eval      $hdrcommand = 'endday'
650cAC                   endif
650cAC                   time                    curtime
650cAC                   eval      $hdrtimestamp = %char(curtime)
650cAC                   eval      $slbeitman# = #job
650cAC                   eval      $slbeiemp# = $emp#
650cAC                   eval      $pheader = $header
650cAC                   eval      $pfields = $slbedayin
650cAC                   exsr      writelog
650cAC                   call      'VOSELECT'
650cAC                   parm      '*none'       $pdqlib
650cAC                   parm      '*none'       $pdqnameout
650cAC                   parm      '*none'       $pdqkey
650cAC                   parm                    $pheader
650cAC                   parm                    $pfields
650cAC                   parm                    $prtnfields
650cAC                   eval      $slbedayout = $prtnfields
730iD * Don't alter nxtscr
700fAC*730iD             if        whereFrom = '12'
700fAc*730iD             eval      nxtscr = '12 '
700fAc*730iD             else
650cAC*730iD             exsr      scr01i
700fAC*730iD             endif
650cA*
650cAc                   endsl
650cAC                   endsr
740jA*----------------------------------------------------------------
740jA*
740jA*  EndINDTASK Indirect task end
740jA*
740jAC     Endindtask    begsr
740jA*   Indirect transaction.
740jAC                   eval      $hdrcommand = 'indtask'
740jAC                   time                    curtime
740jAC                   eval      $hdrtimestamp = %char(curtime)
740jAC                   eval      $slititman# = #job
740jAC                   eval      $slitiemp# = $emp#
740jAC                   eval      $slitiflag = '2'
740jAC                   eval      $slititask = $lcode
740jAC                   eval      $pheader = $header
740jAC                   eval      $pfields = $slindtskin
740jAC                   exsr      writelog
740jAC                   call      'VOSELECT'
740jAC                   parm      '*none'       $pdqlib
740jAC                   parm      '*none'       $pdqnameout
740jAC                   parm      '*none'       $pdqkey
740jAC                   parm                    $pheader
740jAC                   parm                    $pfields
740jAC                   parm                    $prtnfields
740jAC                   eval      $slindtskout = $prtnfields
740jA*
740jAC                   if        $slitoerrnum <> 0
740jAC                   eval      error = *on
740jAC                   eval      *in22 = *on
740jAC                   eval      *in02 = *on
740jAC                   eval      errmsg = *blanks
740jAC                   eval      ertrn# = $slitoerrnum
740jAC                   exsr      zm2002
740jAC                   endif
740jAC                   endsr
720hA*----------------------------------------------------------------*********
720hA*
720hA*  WEIGHLATER  Weight Later for screen 7.
720hA*
720hAC     weighlater    begsr
720hAC                   eval      error  = *off
720hA
720hA*  Record weigh later
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'skipcw'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slswitman# = #job
720hAC                   eval      $slswitrn# = $slvlotrn#
720hAC                   eval      $slswilbl# = $slvlolbl#
720hAC                   eval      $slswitype = 'LATER'
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slskipcwin
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slskipcwout = $prtnfields
720hA*
720hAC                   if        $slswoerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in21 = *on
720hAC                   eval      *in01 = *on
720hAC                   eval      errmsg = 'Error occurred in VOSELECT'
720hAC                   exsr      zm9898
720hAC                   eval      error = *on
720hAC                   goto      endwl
720hAC                   else
720hA*  Determine what screen to display and/or update pick qty.
752gAc                   if        oprfqtcw = 'Y'
752gAc                   eval      w6cnt1 = w6cnt1e
752gAc                   endif
720hAC                   exsr      zznxt
720hAC                   endif
720hA*
720hA*
720hAC     endWL         endsr
730wA*---------------------------------------------------------------
730wA*
730wA*    AUTOLOADCW auto load catch weight from UCI info File
730wA*
730wA*---------------------------------------------------------------
730wA /free
730wA   begsr autoloadcw;
730wA     // now check to see if catch weights can be auto loaded
730wA     if #scwgt <> 'Y';
730wA       leavesr;
730wA     endif;
740aA     // Don't need to get item again, previously loaded.
740aA     // This was changing the value of $ifsltmth, which was
740aA     // set to 1 if the picker said the item had NOPUPC
730wA     // get data from itemfld
740aD     //exsr clr$item;

740aD     //$itWhse = lbwhse;
740aD     //$ititem = lbitem;

740aD     //$dricommand = '*ITEM';
740aD     //$drisubcmd  = '%GETALL';
740aD     //$drisys2upd = 'D';
740aD     //chk4err = *on;
740aD     //exsr zzzdricop;
740aD     //if error = *on;
740aD       //$ifrcvmth = ' ';
740aD     //endif;
740aD     //if $ifrcvmth <> '2';
740aD       //leavesr;
740ad     //endif;

730wA     // if multiple license in overflow slot we can not auto load.
730wA     // so get out of here.
730wA     if $toutlic# = '*MULTIPLE';
730wA       leavesr;
730wA     endif;

730wA     exsr clr$licinfo;

730wA     $lnwhse  = lbwhse;
730wA     $lnlcns  = $toutlic#;
730wA     $lnseq = 1;

730wA     $dricommand = '*LICINFO';
730wA     $drisubcmd  = '%GET';
730wA     $drisys2upd = 'D';
730wA     chk4err = *on;
730wA     exsr zzzdricop;

730wA     if error = *on;
740hA       error = *off;
730wA       leavesr;
730wA     endif;

730wA     // first lets check the qty being pulled against the rcv qty
730wA     // on the license - if they are different we can't continue
730wA     if $lnrcvqty <> w6cnt2;
730wA       leavesr;
730wA     endif;

730wA     // continue by checking to make sure license has had NO
730wA     // adjustments or selections.
730wA     if not %open(liclog1);
730wA       open liclog1;
730wA     endif;
730wA     setll (lbwhse: $toutlic#) liclog1;
730wA     dow not %eof(liclog1);
730wA       reade (lbwhse: $toutlic#) liclog1;
730wA       if %eof(liclog1);
730wA         leave;
730wA       else;
730wA         // is log for action ADJ or SEL
730wA         if llaction = 'ADJ';
730wA           close liclog1;
730wA           leavesr;
730wA         endif;
730wA         if llaction = 'SEL';
730wA           close liclog1;
730wA           leavesr;
730wA         endif;
730wA       endif;
730wA     enddo;

730wA     // if we get here then no adj or selection log records for license
730wA     // finally now go see if we have uci records for this license
730wA     // Check to make sure we have the same qty of UCI records
730wA     exsr clr$uciinfo;

730wA     $uiWhse = lbwhse;
730wA     $uilcns = $toutlic#;

730wA     $dricommand = '*UCIINFO';
730wA     $drisubcmd  = '%CNT4BLK';
730wA     $drisys2upd = 'D';
730wA     exsr zzzdricop;

730wA     // if return is *BULKQTY1 - NO UCI Were Found - so get out
730wA     if $drireturn   = '*BULKQTY1';
730wA       leavesr;
730wA     endif;

730wA     // if return is *BULKCNT  - pmessage holds the uci count
730wA     if $drireturn   = '*BULKCNT';
730wA       // count must be same as qty being pulled
730wA       if w6cnt2   <> %dec($drimessage:5:0);
730wA         leavesr;
730wA       endif;
730wA     endif;
730wA     // we have UCI's with catch weights that can be auto loaded to
730wA     // ORDC and UCIINFO file can be updated with the selection
730wA     // order/tran/label. CWLOG file is also loaded.

730wA     if not %open(ordc);
730wA       open ordc;
730wA     endif;
730wA     dou $drireturn = '*DONE';
730wA       exsr clr$uciinfo;

730wA       $uiWhse = lbwhse;
730wA       $uilcns = $toutlic#;

730wA       $dricommand = '*UCIINFO';
730wA       $drisubcmd  = '%GET4BLK';
730wA       $drisys2upd = 'D';
730wA       chk4err = *on;
730wA       exsr zzzdricop;
730wA       if $drireturn <> '*DONE';
730wA         exsr douciwgt;
730wA         // now post seq number and selection data into UCIINFO file
730wA         $uiseltrn# = lbtrn#;
730wA         $uisellbl# = lblbl#;
730wA         $uiselord  = lbord;
730wA         $uiselseq  = lbseq;
730wA         $uiselcseq = ocseq;

730wA         // Lets add some more stuff for tracking
730wA         $uiaction = 'SELBULK';
730wA         $uiaolcns = $uiaOlcns;
730wA         $uiaoseq = $uiaOseq;
730wA         $uiscan = ' ';
730wA         $uitran# = lbtrn#;
730wA         $uilbl# = lblbl#;

730wA         $dricommand = '*UCIINFO';
730wA         $drisubcmd  = '%SEL4BLK';
730wA         $drisys2upd = 'D';
730wA         chk4err = *on;
730wA         exsr zzzdricop;
730wA       endif;
730wA     enddo;
730wA     if %open(ordc);
730wA       close ordc;
730wA       pristineloaded = *on;
750pA /free
750pA    if comboLabel or bulkLabel;
750uA      GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1:'');
750pA    else;
750uA      GetLabelZPL('*GETLABEL': w2rtid: 0:w2lbl: w6cnt1+1: w6cnt2:'');
750pA    endif;
750pA /end-free
730wA       w6cnt1 = w6cnt2;
730wA     endif;
730wA   endsr;
730wA /end-free
730wA*----------------------------------------------------------------
730wA*
730wA*  DoUCIwgt      Create catchweight record in ORDC.
730wA*
730wAC     DoUCIwgt      begsr
730wAC
730wAC     Ockey         SetGt     Ordc
730wAC     Ockey         ReadPe(n) Ordc

730wAC                   If        %eof(ordc)
730wAC                   Eval      Ocseq = 0
730wAC                   Endif
730wAC                   Eval      NewSeq = OcSeq + 1

730wAC                   Clear                   OcRec
730wAC     OcNkey        Chain     Ordc
730wAC                   If        not %found(ordc)
730wAC                   Eval      OcWhse = LbWhse
730wAC                   Eval      OcOrd  = LbOrd
730wAC                   Eval      OcSeq# = LbSeq
730wAC                   Eval      OcItem = LbItem
730wAC                   Eval      OcSeq  = NewSeq
730wAC                   Eval      Occwgt = $uiwgtlbs
730wAC                   Eval      OcTran = LbTrn#
730wAC                   Eval      OcLbl# = LbLbl#
730wAC                   Write     OcRec
730wAc                   eval      processstatus = '*ADD'
730wAc                   exsr      processcwlog
730wAC                   Else
730wAC                   Eval      OcTran = LbTrn#
730wAC                   Eval      Occwgt = $uiwgtlbs
730wAC                   Update    OcRec
730wAc                   eval      processstatus = '*UPDATE'
730wAc                   exsr      processcwlog
730wAC                   Endif
730wAC
730wAC                   Endsr

730wA*----------------------------------------------------------------
730wA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
730wA*----------------------------------------------------------------

730wA /free
730wA   begsr processCWlog;
730wA     exsr clrCWLog;
730wA     $cwwhse = ocwhse;
730wA     $cwitem = ocitem;
730wA     $cwseltrn# = octran;
730wA     $cwsellbl# = oclbl#;
730wA     $cwselord  = ocord;
730wA     $cwselseq  = ocseq#;
730wA     $cwselcseq = ocseq;
730wA     $cwscan = ' ';
730wA     $cwwgtlbs = occwgt;
730wA     $cwentflg = 4;

730wA     cwdata = $cwlog;
730wA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

730wA     $cwlog = cwdata;

730wA     select;
730wA       when %error;
730wA         error = *on;
730wA       when cwrtn <> '*OK';
730wA         error = *on;
730wA     endsl;
730wA   endsr;
730wA /end-free
730wA*----------------------------------------------------------------
730wA*  clrCWLog     Clear $cwlog   data structure fields
730wA*----------------------------------------------------------------

730wA /free
730wA   begsr ClrCWLog;

730wA     savever# = $cwver#;
730wA     clear $cwlog;
730wA     $cwver# = savever#;
730wA     $cwaddemp = $emp#;
730wA     $cwaddusr = #user;
730wA     $cwaddpgm  = #pgm;
730wA     $cwaddjob  = #job;
730wA     $cwaddnbr = #jobnbr;
730wA
730wA   endsr;
730wA /end-free

730wA*----------------------------------------------------------------
730wA*  clr$licinfo  Clear $licinfo data structure fields
730wA*----------------------------------------------------------------

730wAC     clr$licinfo   begsr
730wAC                   eval      savever# = $lnver#
730wAC                   clear                   $licinfo
730wAC                   clear                   $licinfo2
730wAC                   eval      $lnver# = savever#

730wAC                   eval      $lnuser = #curruser
730wAC                   eval      $lnemp# = $emp#
730wAC                   eval      $lnpgm  = #pgm
730wAC                   eval      $lnjob  = #job
730wAC                   eval      $lnjobnbr = #jobnbr

730wAC                   endsr

     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
750fAC                   if        usingScreen
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
750fAC                   endif
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
750fAC                   if        usingScreen
     C                   write     msgctl
750fAC                   endif
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
750fAC                   select
750fAC                   when      usingScreen
     C                   write     msgrec
750fAC                   other
750fAC                   call      'GETMSG2'
750fAC                   parm                    #msgk
750fAC                   parm                    #pgmq
750fAC                   parm                    #msgtext
750fAC                   eval      errmsg = #msgtext
750fAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZMPCPF  Add CPF message record to subfile
     *
     C     zmpcpf        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgfc
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
750fAC                   select
750fAC                   when      usingScreen
     C                   write     msgrec
750fAC                   other
750fAC                   call      'GETMSG2'
750fAC                   parm                    #msgk
750fAC                   parm                    #pgmq
750fAC                   parm                    #msgtext
750fAC                   eval      errmsg = #msgtext
750fAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
750fAC                   if        usingScreen
     C                   write     clrscr
750fAC                   endif
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
750fAC                   if        usingScreen
     C                   write     msgrec
750fAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
ISPaA*      6401  Multi trans, end using task entry.
ISPaA*
     C     zm6401        begsr
     C                   eval      #msgid = 'PT64001'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*      6403  Flags exists, can not close this transaction.
ISPaA*
     C     zm6403        begsr
     C                   eval      #msgid = 'PT64003'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
ISPaA*----------------------------------------------------------------
     *   CPF9898  Generic error message
     *
     C     zm9898        begsr
     C                   eval      #msgid = 'CPF9898'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpcpf
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   eval      #msgid = 'PIR7979'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   LP11022  Invalid license number.
     *
     C     zm1022        begsr
     C                   eval      #msgid = 'LP11022'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20001  Invalid slot entered.(TO)
     *
     C     zm2001        begsr
     C                   eval      #msgid = 'RC20001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20002 Transaction is closed.
     *
     C     zm2002        begsr
     C                   eval      #msgid = 'RC20002'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20003 Quantity must be > 0.
     *
     C     zm2003        begsr
     C                   eval      #msgid = 'RC20003'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20004 Quantity can't be > quantity to put away.
     *
     C     zm2004        begsr
     C                   eval      #msgid = 'RC20004'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
640bA*----------------------------------------------------------------
640bA*      0110  Number must be > 0
640bA*
640bAC     zm0110        begsr
640bAC                   move      'PIR0110'     #msgid
640bAC                   move      '*DIAG  '     #msgtp
640bAC                   movea     errmsg        $md(1)
640bAC                   exsr      zmpmsg
640bAC                   endsr
     *----------------------------------------------------------------
     *   PIR0204  Enter only one value.
     *
     C     zm0204        begsr
     C                   eval      #msgid = 'PIR0204'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0205  Must enter one value.
     *
     C     zm0205        begsr
     C                   eval      #msgid = 'PIR0205'
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
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   eval      #msgid = 'PIR1005'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   eval      #msgid = 'IT15204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PT13021  Warning: Entered catch wt not within +/- range.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'PT13021'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     Smaller message for new rf selection device
     *
720iAC     zm21Small     begsr
720iAc** per Hemant we need shorter messages
720iAc                   eval      errmsg = 'Warning: ' +
720iAc                                       %char(ertcwt) +
720iAc                                       ' is not within ' +
720iAc                                       %char(erlrng) + ' / ' +
720iaC                                       %char(erhrng)
720iAC                   exsr      zm9898
720iAC                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*   PIR9908  &1 currently inuse. &2 in progress.
ISPaA*
ISPaAC     zm9908        begsr
ISPaAC                   eval      #msgid = 'PIR9908'
ISPaAC                   eval      #msgtp = '*DIAG  '
ISPaAC                   eval      $md(1) = errmsg
ISPaAC                   exsr      zmpmsg
ISPaAC                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*      0105  ZZZZZZ
ISPaA*
     C     zms105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   eval      $rtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *
     *   Check for end of day
730kAC                   if        w1eod  = 'Y'
752uA /free
752uA   // do not do endday if user has started selection transactions
752uA   setll (w1whse:$emp#:'2') pirtran1w;
752uA   dow forever = forever;
752uA     reade (w1whse:$emp#:'2') pirtran1w;
752ua     if %eof(pirtran1w);
752ua       leave;
752ua     endif;
752ua     if ptcat <> 'SELECT';
752uA       iter;
752uA     endif;
752uA     leavesr;
752uA   enddo;
752uA /end-free
730kAC                   eval      $hdrcommand = 'endday'
730kAC                   time                    curtime
730kAC                   eval      $hdrtimestamp = %char(curtime)
730kAC                   eval      $slbeitman# = #job
730kAc                   eval      $slbeiemp# = $emp#
730kAc                   eval      $pheader = $header
730kAc                   eval      $pfields = $slbedayin
730kAc                   exsr      writelog
730kAc                   call      'VOSELECT'
730kAC                   parm      '*none'       $pdqlib
730kAC                   parm      '*none'       $pdqnameout
730kAC                   parm      '*none'       $pdqkey
730kAC                   parm                    $pheader
730kAC                   parm                    $pfields
730kAC                   parm                    $prtnfields
730kAC                   eval      $slbedayout = $prtnfields
730rDC*                  eval      w1eod = 'N'
730kAC                   goto      endck1
730kAC                   endif
     *
751oA   // See if we should get auto assigned transaction
751oA
751oA   if w1trn# = 0;
751oA     if usingAutoAssign;
751oA       if prime and usingBeltPrt;
760aA         PIRsoask  = '0';
760aA         autoassigndone = '0';
760aA         autoassignpdon = '0';
760aA         autoassignmore = '0';
752uA         slgbuf = '<DMDSelBefore> '
752uA              + 'cmd=*GET' + ' '
752uA              + 'whs=' + %char(w1whse)  + ' '
752uA              + 'user=' + %trimr(#curruser)  + ' '
760aA              + 'pjtype=' + %char(pjtype#)  + ' '
760aA              + 'dmdrte=' + dmdrte  + ' '
760aA              + 'dmdzone=' + dmdzone  + ' '
752uA              + 'trn=' + %char(w1trn#);
752uA         WriteVoiceLog ('Beg': slgbuf);
751oA         monitor;
751oA           GetDMDSel('*GET': w1whse: #curruser: w1trn#:
760aD   //                 dmdCode: dmdMsg);
760aM                      pjtype#: dmdrte: dmdzone: dmdCode: dmdMsg);
752uA           slgbuf = '<DMDSelAfter> '
752uA                + 'cmd=*GET' + ' '
752uA                + 'whs=' + %char(w1whse)  + ' '
752uA                + 'user=' + %trimr(#curruser)  + ' '
752uA                + 'trn=' + %char(w1trn#)  + ' '
760aA                + 'pjtype=' + %char(pjtype#)  + ' '
760aA                + 'dmdrte=' + dmdrte  + ' '
760aA                + 'dmdzone=' + dmdzone  + ' '
752uA                + 'dmdcode=' + dmdCode  + ' '
752uA                + 'dmdmsg=' + dmdMsg;
752uA           WriteVoiceLog ('End': slgbuf);
760aA           Select;
760aA             // return is ok, pallet count > 0 and route is blank-pir
760aA             // pick we won't assume they want more, will send to
760aA             // scrn 15 to ask if they want more.
760aA             when dmdcode = '*OK' and pjtype# >0 and dmdrte = ' ';
760aA               PIRsoask  = '1';
760aA             when dmdcode = '*OK' and pjtype# =0 and dmdrte <>' ';
760aA               autoassigndone= '1';
760aA             when dmdcode = '*OK' and pjtype# >0 and dmdrte <>' ';
760aA               autoassignmore= '1';
760aA             when dmdcode = '*PRVASSN' and w1trn# = 0;
760aA               autoassignpdon= '1';
760aA               errmsg  = 'No more transactions found';
760aA               leavesr;
760aA             other;
760aA               error = *on;
760aA               *in22 = *on;
760aA               *in02 = *on;
760aA               errmsg = dmdMsg;
760aA               exsr zm9898;
760aA               leavesr;
760aA           endsl;
760aD   //      if dmdCode <> '*OK';
760aD   //        error = *on;
760aD   //        *in22 = *on;
760aD   //        *in02 = *on;
760aD   //        errmsg = dmdMsg;
760aD   //        exsr zm9898;
760aD   //        leavesr;
760aD   //      endif;
751oA         on-error;
751oA         endmon;
751oA       endif;
751oA     endif;
751oA   endif;
740dA*
740dA*   Make sure user does not have another transaction in suspended
740dA*   status, if so issue warning another transaction in suspended
740dA /free
740dA   setll (w1whse:$emp#:suspendstat) pirtran1w;
740dA   dow forever = forever;
740dA     reade (w1whse:$emp#:suspendstat) pirtran1w;
740dA     if %eof(pirtran1w);
740dA       leave;
740dA     endif;
740dA     if w1trn# = pttrn#;
740dA       iter;
740dA     endif;
740dA     // have we already logged an exception for suspend
740dA     suspendFound = *off;
740dA     setll (w1whse:pttrn#) voexcp;
740dA     dow forever = forever;
750fD       //reade (w1whse:pttrn#) voexcp;
740fM       reade(n) (w1whse:pttrn#) voexcp;
740dA       if %eof(voexcp);
740dA         leave;
740dA       endif;
740dA       if sxerid <> 'SUSPEND';
740dA         iter;
740dA       endif;
740dA       suspendFound = *on;
740dA       leave;
740dA     enddo;
740dA     if suspendFound = *off;
740dA       exsr scr22i;
740dA       error = *on;
740dA       leavesr;
740dA     endif;
740dA   enddo;


740dA /end-free
     *
     *   Make sure that the transaction is open.
740dDC*    w1trn#        chain     pirtran                            79
740dA /free
740dM   chain (w1whse: w1trn#) pirtranw;
740dA   if not %found(pirtranw);
740dA     *in79 = *On;
740eA   else;
740eA     *in79 = *off;
740dA   endif;
740dA /end-free
500e C                   if        *in79 = *on
500e C                   eval      error = *on
500e C                   eval      *in22 = *on
500e C                   eval      *in02 = *on
500e C                   eval      errmsg = *blanks
500e C                   eval      errmsg = desc(4)
500e C                   exsr      zm9898
500e C                   goto      endck1
500e C                   else
650aDC*                  if        ptstat <> '1'
650aMC                   if        ptstat <> '1' and ptstat <> '8'
720dAc                             and ptstat <> '2'
500e C                   eval      error = *on
500e C                   eval      *in22 = *on
500e C                   eval      *in02 = *on
500e C                   eval      errmsg = *blanks
500e C                   eval      errmsg = desc(6)
500e C                   exsr      zm9898
500e C                   goto      endck1
500e C                   endif

750qA /free
750qA   // If using a printer, check if labels exist for transaction
750qA   // If not found, try to create them
750qA
750qA   if usingBeltPrt;
750qA     GetLabelZPL('*CHKTRAN': ptrtpo: w1trn#: 0: 0: 0:'');
750qA     if zplRtnCode = '*NORECS';
750qA       errmsg = '';
750qA       GetLabelZPL('*CRTTRAN': ptrtpo: w1trn#: 0: 0: 0:'');
750qA     endif;
750qA     if zplRtnCode <> '*OK';
750qA       error = *on;
750qA       leavesr;
750qA     endif;
750qA   endif;
750qA /end-free

720kAC                   if        ptsub = 'BULK'
730wAc                             and AllowBulk = *off
720nA /free
720nA   // write transaction to bulkwrk file
720nA   blkemp = $emp#;
720nA   chain (blkemp) bulkwrk;
720nA   if not %found(bulkwrk);
720nA     blktrn = w1trn#;
720nA     write blkrec;
720nA   else;
720nA     blktrn = w1trn#;
720nA     update blkrec;
720nA   endif;
720nA /end-free
720nAc                   call      'OR680'
720nDC*                  eval      error = *on
720nDC*                  eval      *in22 = *on
720nDC*                  eval      *in02 = *on
720nDC*                  eval      errmsg = *blanks
720nDC*                  eval      errmsg = desc(15)
720nDC*                  exsr      zm9898
720nA /free
720nA   chain (blkemp) bulkwrk;
720nA   if %found(bulkwrk);
720nA     delete blkrec;
720nA   endif;
720nA /end-free
720kAC                   goto      endck1
720kAC                   endif
500e C                   endif
500e *   Assign transaction.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'assign'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slasitman# = #job
     C                   eval      $slasitrn# = w1trn#
     C                   eval      $slasitype = ' '
720fAc                   if        ufinfl = *on
720fAc                   eval      $slasiunfi = '1'
720fAc                   else
720fAc                   eval      $slasiunfi = '0'
720fAc                   endif
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slassignin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slassignout = $prtnfields
     *
     C                   if        $slasoerrnum <> 0
751wA /free
751wA   // See if we need to undo auto assigned transaction
751wA   if usingAutoAssign;
751wA     if prime and usingBeltPrt;
752uA       slgbuf = '<DMDSelBefore> '
752uA            + 'cmd=*UNDO' + ' '
752uA            + 'whs=' + %char(w1whse)  + ' '
752uA            + 'user=' + %trimr(#curruser)  + ' '
760aA            + 'pjtype=' + %char(pjtype#)  + ' '
760aA            + 'dmdrte=' + dmdrte  + ' '
760aA            + 'dmdzone=' + dmdzone  + ' '
752uA            + 'trn=' + %char(w1trn#);
752uA       WriteVoiceLog ('Beg': slgbuf);
751wA       monitor;
751wA         GetDMDSel('*UNDO': w1whse: #curruser: w1trn#:
760aD      //            dmdCode: dmdMsg);
760aM                    pjtype#: dmdrte: dmdzone: dmdCode: dmdMsg);
751wA         if dmdCode <> '*OK';
751wA         endif;
752uA         slgbuf = '<DMDSelAfter> '
752uA                + 'cmd=*UNDO' + ' '
752uA                + 'whs=' + %char(w1whse)  + ' '
752uA                + 'user=' + %trimr(#curruser)  + ' '
752uA                + 'trn=' + %char(w1trn#)  + ' '
760aA                + 'pjtype=' + %char(pjtype#)  + ' '
760aA                + 'dmdrte=' + dmdrte  + ' '
760aA                + 'dmdzone=' + dmdzone  + ' '
752uA                + 'dmdcode=' + dmdCode  + ' '
752uA                + 'dmdmsg=' + dmdMsg;
752uA         WriteVoiceLog ('End': slgbuf);
751wA       on-error;
751wA       endmon;
751wA     endif;
751wA   endif;
751wA /end-free
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C*                  eval      errmsg = $slasoerrtext
     C*                  exsr      zm9898
720dAC                   eval      errmsg = $slasoerrtext
720dAC                   exsr      zm0105
720dAC                   goto      endck1
720dDC**                 eval      ertrn# = $slasotrn#
720dDC**                 exsr      zm2002
     C                   else
     C                   endif
ISPeA*
ISPeAC                   if        client = ISupply
ISPeAC                   eval      $kwhse = ptwhse
ISPeAC                   eval      $krtid = ptrtpo
ISPeAC     keyoh         chain     ohrec                              79
ISPeAC                   if        *in79 = *off
ISPeAC                             and ohtype = 'W'
ISPeAC                   eval      oprfuc = 'N'
ISPeAC                   eval      oprflc = 'N'
ISPeAC                   eval      oprfsl = 'Y'
ISPeAC                   endif
ISPeAC                   endif
700fA* Move Record to SKTLBL32
700fAC                   if        oprfpm = '2'
720dDC*                  eval      $hdrcommand = 'pickrf'
700dMC                   eval      $hdrcommand = 'picksrf'
700fAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
700fAC                   eval      $slpsitman# = #job
700fAC                   eval      $slpsitrn# = w1trn#
700fAC                   eval      $slasitype = ' '
700fAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slpicksin
700fAC                   exsr      writelog
700fAC                   call      'VOSELECT'
700fAC                   parm      '*none'       $pdqlib
700fAC                   parm      '*none'       $pdqnameout
700fAC                   parm      '*none'       $pdqkey
700fAC                   parm                    $pheader
700fAC                   parm                    $pfields
700fAC                   parm                    $prtnfields
720dDC*                  eval      $slassignout = $prtnfields
720dMC                   eval      $slpicksout  = $prtnfields
700fA*
700fAC                   if        $slpsoerrnum <> 0
751wA /free
751wA   // See if we need to undo auto assigned transaction
751wA   if usingAutoAssign;
751wA     if prime and usingBeltPrt;
752uA       slgbuf = '<DMDSelBefore> '
752uA            + 'cmd=*UNDO' + ' '
752uA            + 'whs=' + %char(w1whse)  + ' '
752uA            + 'user=' + %trimr(#curruser)  + ' '
760aA            + 'pjtype=' + %char(pjtype#)  + ' '
760aA            + 'dmdrte=' + dmdrte  + ' '
760aA            + 'dmdzone=' + dmdzone  + ' '
752uA            + 'trn=' + %char(w1trn#);
752uA       WriteVoiceLog ('Beg': slgbuf);
751wA       monitor;
751wA         GetDMDSel('*UNDO': w1whse: #curruser: w1trn#:
760aD    //                dmdCode: dmdMsg);
760aM                    pjtype#: dmdrte: dmdzone: dmdCode: dmdMsg);
751wA         if dmdCode <> '*OK';
751wA         endif;
752uA         slgbuf = '<DMDSelAfter> '
752uA                + 'cmd=*UNDO' + ' '
752uA                + 'whs=' + %char(w1whse)  + ' '
752uA                + 'user=' + %trimr(#curruser)  + ' '
752uA                + 'trn=' + %char(w1trn#)  + ' '
760aA                + 'pjtype=' + %char(pjtype#)  + ' '
760aA                + 'dmdrte=' + dmdrte  + ' '
760aA                + 'dmdzone=' + dmdzone  + ' '
752uA                + 'dmdcode=' + dmdCode  + ' '
752uA                + 'dmdmsg=' + dmdMsg;
752uA         WriteVoiceLog ('End': slgbuf);
751wA       on-error;
751wA       endmon;
751wA     endif;
751wA   endif;
751wA /end-free
700fAC                   eval      error = *on
700fAC                   eval      *in22 = *on
700fAC                   eval      *in02 = *on
720dAC                   eval      errmsg = $slpsoerrtext
720dAC                   exsr      zm0105
720dAC                   goto      endck1
720dDC*                  eval      errmsg = *blanks
720dDC*                  eval      ertrn# = $slasotrn#
720dDC*                  exsr      zm2002
700fAC                   else
700fAC                   endif
700fAC                   endif
     *  If not found
     C*                  if        *in79 = *on
     C*                  eval      error = *on
     C*                  eval      *in22 = *on
     C*                  eval      *in02 = *on
     C*                  eval      errmsg = *blanks
     C*                  eval      errmsg = desc(4)
     C*                  exsr      zm9898
     C*                  goto      endck1
     C*                  endif
     *
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     *
     *  Verify label is for entered transaction and still open.
     *
     * Fill r#header ds
720cAc                   if        zonepickup
720cAC                   eval      $hdrcommand = 'vfylabelM'
720cAc                   else
730wAc                   if        ptsub = 'BULK' and AllowBulk = *on
730wAC                   eval      $hdrcommand = 'vfylabelB'
730wAc                   else
     C                   eval      $hdrcommand = 'vfylabel'
730wAc                   endif
720cAc                   endif
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvlitman# = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w2lbl#b
640bAC                   move      $plbl#        w2lbl#b
640bAC                   z-add     $plbl#        w2lbl
     C                   eval      $slvlilbl# = w2lbl
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfylblin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slvfylblout = $prtnfields
     *
501jAC                   if        $slvloerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = $slvloerrtext
     C*                  eval      errmsg = desc(2)
     C                   exsr      zm9898
720cMC                   eval      w2lbl#b = $pbarcode
     C                   goto      endck2
     C                   else
730vA /free
752sA   w2rtid = $slvlorouteid;
751lA   w2trn = $slvlotrn#;
730vA   if usingp2p = *on;
730vA     setll ($slvlotrn#) pltsum4;
730vA     dow forevr = forevr;
730vA       reade ($slvlotrn#) pltsum4;
730vA       if %eof(pltsum4);
730vA         leave;
730vA       endif;
730vA       if $slvlopal# > pspal#;
730vA         p2plights ('*SET':$slsropjack:'B':'B':'1');
730vA       else;
730vA         p2plights ('*SET':$slsropjack:'A':'B':'1');
730vA       endif;
730vA     enddo;
730vA   endif;
730vA /end-free
730qA /free
730qA
730qA  monitor;
730qA    umWhse = lbwhse;
730qA    umlabel('*GET': umRtnCode: umRtnMsg:
730qA            umWhse: lblbl#:
730qA            umFlexPickFlag:
730qA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730qA  on-error;
730qA    umRtnCode = '*ERROR';
730qA  endmon;
730qA
730qA  if umRtnCode = '*OK';
730qA    select;
730qA      when umFlexPickFlag = 'P2W';
730qA        pick2lbs = lbswgt;
730qA      when umFlexPickFlag = 'PAQ';
730qA    endsl;
730qA  endif;
730qA
730qA /end-free
     C                   endif

     *
720cA /free
720cA   if $slvloaisle = 'zon';
720cA     eval zonepickup = *on;
720cA   endif;
720cA   if zonepickup;
752vA            if prime;
752vA              // load merge work file
752vA              wktype = 'M';
752vA              exsr buildSPmrgwrk;
752vA              exsr scr88i;
752vA              leavesr;
752vA            endif;
752sA     select;
752sA       when client = cityline
752sA            or client = harbor
752sA            or client = greenleaf
752sA            or client = Colony;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA       when client = cheney
752sA            or client = ellenbee
752sA            or client = royal
752sA            or client = tpc
752sA            or client = saval
752sA            or client = palmer
752sA            or client = frf
752sA            or client = Getfresh
752sA            or client = FoodPro
752sA            or client = EI
752sA            or client = WillFoods
752sA            or client = Panos
752sA            or client = Renzi
752sA            or client = AandDFoods
752sA            or client = Cotati
752sA            or client = Merit
752sA            or client = SWT
752sA            or client = prestofoods
752sA            or usrDFPICK='Y';
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA       when client = ISupply;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA       when client = Coastl
752sA            and psszon = 'REFB';
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA       when client = Accardi
752sA            and (ptwhdp = 'REF  '
752sA            or   ptwhdp = 'FRZ  ');
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA       when client = SGC;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA       when client = Westside;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA       when client = avalon;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA       other;
752sA         setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA     endsl;
752sD     //setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
720cA     dow forevr = forevr;
752sA       select;
752sA         when client = cityline
752sA              or client = harbor
752sA              or client = greenleaf
752sA              or client = Colony;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA           if %eof(label32x);
752sA             leave;
752sA           endif;
752sA         when client = cheney
752sA              or client = ellenbee
752sA              or client = royal
752sA              or client = tpc
752sA              or client = saval
752sA              or client = palmer
752sA              or client = frf
752sA              or client = Getfresh
752sA              or client = FoodPro
752sA              or client = EI
752sA              or client = WillFoods
752sA              or client = Panos
752sA              or client = Renzi
752sA              or client = AandDFoods
752sA              or client = Cotati
752sA              or client = Merit
752sA              or client = SWT
752sA              or client = prestofoods
752sA              or usrDFPICK='Y';
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA           if %eof(label32d);
752sA             leave;
752sA           endif;
752sA         when client = ISupply;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA           if %eof(label32i);
752sA             leave;
752sA           endif;
752sA         when client = Coastl
752sA              and psszon = 'REFB';
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA           if %eof(label32i);
752sA             leave;
752sA           endif;
752sA         when client = Accardi
752sA              and (ptwhdp = 'REF  '
752sA              or   ptwhdp = 'FRZ  ');
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA           if %eof(label32s);
752sA             leave;
752sA           endif;
752sA         when client = SGC;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA           if %eof(label32g);
752sA             leave;
752sA           endif;
752sA         when client = Westside;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA           if %eof(label32w);
752sA             leave;
752sA           endif;
752sA         when client = avalon;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA           if %eof(label32h);
752sA             leave;
752sA           endif;
752sA         other;
752sA           reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA           if %eof(label32c);
752sA             leave;
752sA           endif;
752sA       endsl;
752sD       //reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sD       //if %eof(label32c);
752sD         //leave;
752sD       //endif;
720cA       if lblbl# = $slvlolbl#;
720cA         leave;
720cA       endif;
720cA     enddo;
720cA   endif;
720cA /end-free
520c C                   eval      type = *blanks
SVLd * For Saval, JIT steak or seafood, set option to NOT scan slot.
SVLdAC                   if        client = saval
SVLe C     keyit         chain     piritem                            79
SVLe C                   if        *in79 = *off
530aDC*    imkey         chain     itemfld                            79
530aDC*                  if        *in79 = *off
530aMC                   call      @itmfl
530aAC                   parm      w1whse        $gWhse            3 0
530aAC                   parm      $slvloitem    $gItem           15
530aAC                   parm      ' '           $gCat            10
530aAC                   parm      ' '           $gCaseOvf         1
SVLeAC                   select
SVLsAC                   when      $gcat = '08' and
SVLsMC                             itven# = 2545
SVLsMC                   eval      type = 'B10'
SVLrAC                   eval      oprfsl = 'N'
SVLrAC                   eval      savupc = *blanks
SVLrAC*
530aDC*                  when      ifcat = '31' and
530aMC                   when      $gcat = '31' and
SVLeAC                             itven# = 7101
SVLeAC                   eval      type = 'STK'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLeAC                   eval      savupc = *blanks
SVLeAC*
530aDC*                  when      ifcat = '37' and
530aMC                   when      $gcat = '37' and
SVLeAC                             itven# = 7101
SVLeAC                   eval      type = 'STK'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLeAC                   eval      savupc = *blanks
SVLeAC*
530aDC*                  when      ifcat = '56' and
530aMC                   when      $gcat = '56' and
SVLeAC                             itven# = 3887
SVLeAC                   eval      type = 'SEA'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLeAC*
530aDC*                  when      ifcat = '57' and
530aMC                   when      $gcat = '57' and
SVLeAC                             itven# = 3887
SVLeAC                   eval      type = 'SEA'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLnA *
SVLnAC                   when      $gcat = '25' and
SVLqDC*                            itven# = 5932
SVLqMC                             itven# = 3697
SVLnAC                   eval      type = 'SEG'
SVLnAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLeAC*
SVLoDC*                  when      $gcat = '74' and
SVLoMC                   when      $gcat = '48' and
SVLpDC*                            itven# = 8502
SVLpMC                             (itven# = 8502 or itven# = 8503)
SVLmAC                   eval      type = 'PRO'
SVLmAC                   eval      oprfsl = 'N'
SVLeAC                   when      $slvlodisp = 'S'
SVLeAC                   eval      type = 'STK'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLeAC                   eval      savupc = *blanks
SVLeAC*
SVLeAC                   when      $slvlodisp = 'SF'
SVLeAC                   eval      type = 'SEA'
SVLeAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLgAC*
SVLgA* For Saval, if Chicken item set to scan weight barcode label
SVLgAC                   when      %subst($slvlodisp:1:4) = 'SCHX'
SVLgAC                             and itven# = 3880
SVLgAC                   eval      type = 'CHK'
SVLgAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLgAC                   eval      savupc = *blanks
SVLhAC*
SVLh * For Saval, if Small Kitchen Item set to scan item # label
SVLhAC                   when      %subst($slvlodisp:1:2) = 'SE'
SVLhAC                             and $gcat = '85        '
SVLhAC                   eval      type = 'SKI'
SVLhAC                   eval      oprfsl = 'N'
740eAc                   eval      oprvsl = 0
740eAc                   eval      oprvcd = 0
740eAc                   eval      oprvup = 0
SVLhAC                   eval      savupc = *blanks
SVLgAC*
SVLeAC                   endsl
SVLeAC*
SVLdAC*                  select
SVLdAC*                  when      $slvlodisp = 'S'
SVLdAC*                  eval      type = 'STK'
SVLdAC*                  eval      oprfsl = 'N'
SVLdAC*                  eval      savupc = *blanks
SVLdAC*                  when      $slvlodisp = 'SF'
SVLdAC*                  eval      type = 'SEA'
SVLdAC*                  eval      oprfsl = 'N'
SVLdAC*                  endsl
530aDC**                 endif
SVLeAC                   endif
SVLdAC                   exsr      zzgeti
SVLdAC                   if        itwhdp <> '9'
SVLmAC                             and itwhdp <> '3'
SVLdAC                   eval      error = *on
SVLdAC                   eval      errmsg = *blanks
SVLdAC                   eval      errmsg = desc(8)
SVLdAC                   exsr      zm9898
SVLdAC                   goto      endck2
SVLdAC                   endif
SVLdAC                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   eval      error = *off
     *  New slot selected.
700aAc                   if        $newsl <> ' '
700aAc                   eval      w3disp = $newsl
700aAc                   endif
     *
     *  Verify slot scanned matches slot displayed
     *
700aDc*                  if        $newsl = ' '
SVLkAC                   if        client = saval
SVLkAC                             and w3scan = ' '
700aMc                             and $newsl = ' '
SVLkA*      Allow user to bypass OUT label with no slot.
SVLkAC                   goto      endck3
SVLkAC                   endif
650aDC*                  if        w3scan <> w3disp
650aMC                   if        w3scan = ' '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(3)
     C                   exsr      zm9898
     C                   goto      endck3
     C                   endif
SVLkAC                   if        client = saval
SVLkAC                   goto      endck3
SVLkAC                   endif
650aA*
650aA*  Call API for slot.
650aA*
PFCaAc                   select
PFCaAc                   when      client = prestofoods
PFCaAc                   other
650aAC                   call      @apics
650aAC                   parm                    w3scan
650aAC                   parm      5             worow
650aAC                   parm      7             wocol
650aAC                   parm                    @artn             8
650aAC                   if        @artn = '*REDSPLY'
650aAC                   move      *on           redspl
650aAC                   goto      endck3
650aAC                   endif
PFCaAc                   endsl
650aA*
650aA*  Verify slot scanned matches slot displayed
650aA*
650aAC                   exsr      clr$slot
650aAC                   eval      $dricommand = '*SLOT'
650aAC                   eval      $drisubcmd  = '%GET'
650aAC                   eval      $drisys2upd = 'D'
650aA
650aAC                   eval      $slwhseu = *on
650aAC                   eval      $slwhse = ptwhse
650aAC                   eval      $slwhdpu = *on
700aDC*                  eval      $slwhdp = ptwhdp
700aMC                   eval      $slwhdp = itwhdp
650aAC                   eval      $sldispu = *on
650aAC                   eval      $sldisp = w3disp
650aAC                   exsr      zzzdricop
650aA * drislot returns $SACDSP with base slot
650aAC                   if        w3scan <> $SACDSP
700eAc                             and OPRFSL = 'Y'
650aAC                   eval      error = *on
650aAC                   eval      *in21 = *on
650aAC                   eval      *in01 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      errmsg = desc(3)
650aAC                   exsr      zm9898
650aAC                   goto      endck3
650aAC                   endif
700aDC**                 endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   eval      error = *off
     *
     *  Verify UPC is for label item.
     * Fill r#header ds
710cDC*                  eval      $hdrcommand = 'vfyupc'
710cMC                   eval      $hdrcommand = 'vfyupcuom'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
710cDC*                  eval      $slvuitman# = #job
710cMC                   eval      $slvuuitman#  = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w2lbl#b
640bAC                   move      $plbl#        w2lbl#b
640bAC                   z-add     $plbl#        w2lbl
710cDC*                  eval      $slvuilbl# = w2lbl
710cMC                   eval      $slvuuilbl# = w2lbl
710cDC*                  eval      $slvuivalue = w4upcd
710cMC                   eval      $slvuuivalue   = w4upcd
     C                   eval      $pheader = $header
710cDC*                  eval      $pfields = $slvfyupcin
710cMC                   eval      $pfields = $slvfyupuin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
710cDC*                  eval      $slvfyupcout = $prtnfields
710cMC                   eval      $slvfyupuout = $prtnfields
     *
710cDC*                  if        $slvuoerrnum <> 0
710cMC                   if        $slvuuoerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in24 = *on
     C                   eval      *in04 = *on
     C                   eval      errmsg = *blanks
710cDC*                  eval      errmsg = $slvuoerrtext
710cMC                   eval      errmsg = $slvuuoerrtxt
     C*                  eval      errmsg = desc(2)
     C                   exsr      zm9898
     C                   goto      endck4
     C                   else
     C                   endif
     *
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   eval      error = *off
     *
     *  Verify License is for label item.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'vfylicense'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvlpitman# = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w2lbl#b
640bAC                   move      $plbl#        w2lbl#b
640bAC                   z-add     $plbl#        w2lbl
     C                   eval      $slvlpilbl# = w2lbl
     C                   eval      $slvlpilic = w5lcns
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfylicin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slvfylicout = $prtnfields
     *
501jAC                   if        $slvlpoerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = $slvlpoerrtxt
     C*                  eval      errmsg = desc(2)
     C                   exsr      zm9898
     C                   goto      endck5
     C                   else
     C                   endif
     *
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 6 error checking.
     *
     C     zzchk6        begsr
     C                   eval      error = *off
     *
     *  Verify label is for trans (scanned on SC2)
710hAc                   eval      traxYN = 'N'
710gDc*                  if        oprfpm = '2'
710gDC*                  eval      w6uci = '99TRAX'+w6lbl#b
710gDc*                  endif
710hAc                   if        %len(%trim(w6lbl#b)) = 10
720cAc*****              if        $slvloaisle = 'zon'
720cAc                   if        zonepickup
720cAC                   eval      w6uci = '99TRAXM'+w6lbl#b
720cAc                   else
710hAC                   eval      w6uci = '99TRAX'+w6lbl#b
720cAc                   endif
710hAC                   eval      traxYN = 'Y'
710hAc                   endif
     *
720cDC*                  movel     w6lbl#b       $pbarcode
720cMC                   eval      $pbarcode =  w6lbl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w6lbl#b
640bAC                   move      $plbl#        w6lbl#b
640bAC                   z-add     $plbl#        w6lbl
640bDC***                if        w6lbl <> $slvlolbl#
     C                   if        w6lbl <> w2lbl
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm9898
     C                   goto      endck6
     C                   endif
710gDc*                  if        oprfpm = '2'
710hDc*                  if        %len(%trim(w6lbl#b)) = 10
710hDC*                  eval      w6uci = '99TRAX'+w6lbl#b
710hAc                   if        traxYN = 'Y'
     * Check if already scanned
700fAC                   eval      $hdrcommand = 'pickuci'
700fAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
700fAC                   eval      $slpuitman# = #job
700fAC                   eval      $slpuitrn# = $slvlotrn#
700fAC                   eval      $slpuilbl# = $slvlolbl#
700fAC                   eval      $slpuistop = $slvlostop
700fAC                   eval      $slpuiitem = $slvloitem
750sAc                   if        virtualpick = 'V'
750sAC                   eval      $slpuislot = lbdisp
750sAc                   else
700fAC                   eval      $slpuislot = $slvlodisp
750sAc                   endif
700fAC                   eval      $slpuiuci = w6uci
700fAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slpickuciin
700fAC                   exsr      writelog
700fAC                   call      'VOSELECT'
700fAC                   parm      '*none'       $pdqlib
700fAC                   parm      '*none'       $pdqnameout
700fAC                   parm      '*none'       $pdqkey
700fAC                   parm                    $pheader
700fAC                   parm                    $pfields
700fAC                   parm                    $prtnfields
700fAC                   eval      $slpckuciout   = $prtnfields
700fA* Error Number 99 for 99TRAX
700fAC                   if        $slpuoerrnum <> 0
KHLbAc                   if        client = kohl
720dAc                   if        w6cnt1 > 0
720dAc** is this a combo label
720dAc
720dAc                   movel     $pbarcode     combochk         10
720dAc                   movel     combochk      comborte          5
720dAc                   move      combochk      combounq          5 0
720dAc
720aA /free
720aA   chain (w1whse: comborte: combounq) ordp;
720aA   if %found(ordp) and orpscn > 1;
720aA     leavesr;
720aA   endif;
PFCaA   // for presto CW item we want to treat like combo
PFCaA   if client = prestofoods  and $itcwgt = 'Y';
PFCaA     leavesr;
PFCaA   endif;
720aA   endif;
KHLbA   endif;
720aA /end-free
730aA /free
730aA   if w6cnt2 = 1 and ufinfl = *on;
730aA     if w6cnt1 = 1;
730aA       w6cnt1 = w6cnt1 - 1;
730aA     endif;
730aA     leavesr;
730aA   endif;
730aA /end-free
700fAC                   movel     $pbarcode     w6lbl#b
700fAC                   eval      error = *on
700fAC                   eval      *in23 = *on
700fAC                   eval      *in03 = *on
700fAC                   eval      errmsg = $slpuoerrtext
700fAC                   exsr      zm9898
700fAC                   goto      endck6
700fAC                   endif
710hAc                   endif
     *
     C     endck6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6a  Screen 6a error checking.
     *
     C     zzchk6a       begsr
     C                   eval      error = *off
     *
     *  Verify label is for label (scanned on SC2)
700fAc*                  if        oprfpm = '2'
     * 99trax
710gAc                   if        %len(%trim(w6albl#b)) = 10
720cAc******             if        $slvloaisle = 'zon'
720cAc                   if        zonepickup
720cAC                   eval      w6uci = '99TRAXM'+w6albl#b
720cAc                   else
710gAC                   eval      w6uci = '99TRAX'+w6albl#b
720cAc                   endif
710gAc                   endif
720cDC*                  movel     w6albl#b      $pbarcode
720cMC                   eval      $pbarcode = w6albl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w6albl#b
640bAC                   move      $plbl#        w6albl#b
640bAC                   z-add     $plbl#        w6albl
720cAc                   select
720cAc********           when      $slvloaisle = 'zon'
720cAc                   when      zonepickup
720cAc                   if        w6albl <> lbctr#
720cAC                   eval      error = *on
720cAC                   eval      *in23 = *on
720cAC                   eval      *in03 = *on
720cAC                   eval      errmsg = *blanks
720cAC                   eval      errmsg = desc(2)
720cAC                   exsr      zm9898
720cAC                   goto      endck6a
720cAC                   endif
720cAc                   other
     C                   if        w6albl <> w2lbl
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = desc(2)
     C                   exsr      zm9898
     C                   goto      endck6a
     C                   endif
720cAc                   endsl
     *
     * Check if already scanned
752bDc***                if        %len(%trim(w6albl#b)) = 10
700fAC                   eval      $hdrcommand = 'pickuci'
700fAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
700fAC                   eval      $slpuitman# = #job
700fAC                   eval      $slpuitrn# = $slvlotrn#
700fAC                   eval      $slpuilbl# = $slvlolbl#
700fAC                   eval      $slpuistop = $slvlostop
700fAC                   eval      $slpuiitem = $slvloitem
750sAc                   if        virtualpick = 'V'
750sAC                   eval      $slpuislot = lbdisp
750sAc                   else
700fAC                   eval      $slpuislot = $slvlodisp
750sAc                   endif
700fAC                   eval      $slpuiuci = w6uci
700fAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slpickuciin
700fAC                   exsr      writelog
700fAC                   call      'VOSELECT'
700fAC                   parm      '*none'       $pdqlib
700fAC                   parm      '*none'       $pdqnameout
700fAC                   parm      '*none'       $pdqkey
700fAC                   parm                    $pheader
700fAC                   parm                    $pfields
700fAC                   parm                    $prtnfields
700fAC                   eval      $slpckuciout   = $prtnfields
700fA* Error Number 99 for 99TRAX
700fAC                   if        $slpuoerrnum <> 0
730aA /free
730aA   if w6cnt2 = 1 and ufinfl = *on;
730aA     if w6cnt1 = 1;
730aA       w6cnt1 = w6cnt1 - 1;
730aA     endif;
730aA     leavesr;
730aA   endif;
730aA /end-free
700fAC                   movel     $pbarcode     w6albl#b
700fAC                   eval      error = *on
700fAC                   eval      *in23 = *on
700fAC                   eval      *in03 = *on
700fAC                   eval      errmsg = $slpuoerrtext
700fAC                   exsr      zm9898
700fAC                   goto      endck6a
700fAC                   endif
752bDC***                endif
     *
     C     endck6a       endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZCHK6b  Screen 6b error checking.
510a *
510a C     zzchk6b       begsr
510a C                   eval      error = *off
SVLsA /free
SVLsA   // Saval Ven# 2545  Cat 08
SVLsA
SVLsA   if client = saval and type = 'B10';
SVLsM
SVLsA     // Value must be 10 digits
SVLsA
SVLsA     if %len(%trimr(w6upcd)) <> 10;
SVLsA       Error = *on;
SVLsA       errmsg = 'Invalid barcode - not 10 characters';
SVLsA       exsr zm9898;
SVLsA       leavesr;
SVLsA     endif;
SVLsA
SVLsA     // Must match item number
SVLsA
SVLsA     exsr zzgeti;
SVLsA
SVLsA     if %subst(w6upcd:1:5) <> ititem;
SVLsA       Error = *on;
SVLsA       errmsg = 'Wrong item - ' + %subst(w6upcd:1:5);
SVLsA       exsr zm9898;
SVLsA       leavesr;
SVLsA     endif;
SVLsA
SVLsA     // Must match customer number
SVLsA
SVLsA     chain (w1whse: lbord) ordh;
SVLsA     if not %found(ordh);
SVLsA       Error = *on;
SVLsA       errmsg = 'Order not found - ' + %char(lbord);
SVLsA       exsr zm9898;
SVLsA       leavesr;
SVLsA     endif;
SVLsA
SVLsA     monitor;
SVLsA       if %dec(%subst(w6upcd:6:5):5:0) <> ohcust;
SVLsA         Error = *on;
SVLsA         errmsg = 'Wrong cust# - ' + %subst(w6upcd:6:5);
SVLsA         exsr zm9898;
SVLsA         leavesr;
SVLsA       endif;
SVLsA     on-error;
SVLsA       Error = *on;
SVLsA       errmsg = 'Wrong cust# - ' + %subst(w6upcd:6:5);
SVLsA       exsr zm9898;
SVLsA       leavesr;
SVLsA     endmon;
SVLsA
SVLsA     // It's a match, get out
SVLsA
SVLsA     leavesr;
SVLsA
SVLsA   endif;
SLVsA /end-free
510a *
510a *  Verify UPC is same as UPC scanned on SC4
510b *  Verify UPC is for label item instead of saved UPC from SC4
510b * Fill r#header ds
710cDC*                  eval      $hdrcommand = 'vfyupc'
710cMC                   eval      $hdrcommand = 'vfyupcuom'
510b C                   time                    curtime
510b C                   eval      $hdrtimestamp = %char(curtime)
710cDC*                  eval      $slvuitman# = #job
710cMC                   eval      $slvuuitman#  = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
640bAC                   exsr      zztraxlbl
640bAC                   move      *blanks       w2lbl#b
640bAC                   move      $plbl#        w2lbl#b
640bAC                   z-add     $plbl#        w2lbl
710cDC*                  eval      $slvuilbl# = w2lbl
710cDC*                  eval      $slvuivalue = w6upcd
710cMC                   eval      $slvuuilbl#  = w2lbl
710cMC                   eval      $slvuuivalue = w6upcd
510b C                   eval      $pheader = $header
710cDC*                  eval      $pfields = $slvfyupcin
710cMC                   eval      $pfields = $slvfyupuin
510bAC                   exsr      writelog
510b C                   call      'VOSELECT'
510b C                   parm      '*none'       $pdqlib
510b C                   parm      '*none'       $pdqnameout
510b C                   parm      '*none'       $pdqkey
510b C                   parm                    $pheader
510b C                   parm                    $pfields
510bAC                   parm                    $prtnfields
710cDC*                  eval      $slvfyupcout = $prtnfields
710cMC                   eval      $slvfyupuout = $prtnfields
510b *
510bDC*                  if        w6upcd <> savupc
710cDC*                  if        $slvuoerrnum <> 0
710cMC                   if        $slvuuoerrnum   <> 0
510a C                   eval      error = *on
510a C                   eval      *in26 = *on
510a C                   eval      *in06 = *on
510a C                   eval      errmsg = *blanks
720cDC*                  eval      errmsg = desc(7)
720cAC                   eval      errmsg = $slvuuoerrtxt
510a C                   exsr      zm9898
510a C                   goto      endck6b
510a C                   endif
510a *
510a *
510a C     endck6b       endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZCHK6c  Screen 6c error checking.
650aA*
650aAC     zzchk6c       begsr
650aAC                   eval      error = *off
700aAc                   if        w6aval < w6cnt1E + w6cnt1
700aCC                             and $slpick = 'N'
730wAc                             and $newsl <> ' '
FSFaCC                             and client <> FreshSense
700aAC                   eval      error = *on
700aAC                   eval      errmsg = *blanks
700aAC                   eval      errmsg = desc(9)
700aAC                   exsr      zm9898
700aAC                   goto      endck6c
700aAc                   endif
650aA*
650aAc                   if        w6cnt2 < w6cnt1e
650aAC                   eval      error = *on
650aAC                   eval      errmsg = *blanks
751kDC**                 eval      errmsg = desc(9)
751kA /free
751kA   errmsg = 'Quantity entered ' +
751kA            %char(w6cnt1e)   +
751kA            ' greater than ' +
751kA            %char(w6cnt2);
751kA /end-free
650aAC                   exsr      zm9898
650aAC                   goto      endck6c
650aAc                   endif
     *
650aAc                   if        w6cnt2 < w6cnt1E + w6cnt1
650aAC                   eval      error = *on
650aAC                   eval      errmsg = *blanks
751kDC***                eval      errmsg = desc(10)
751kA /free
751kA   errmsg = 'Total picked quantity ' +
751kA            %char(w6cnt1e + w6cnt1)   +
751kA            ' greater than ' +
751kA            %char(w6cnt2);
751kA /end-free
650aAC                   exsr      zm9898
650aAC                   goto      endck6c
650aAc                   endif
740kAc                   if        w6cnt1E < 0
740kAC                   eval      error = *on
740kAC                   eval      errmsg = *blanks
751kDC***                eval      errmsg = desc(10)
751kA /free
751kA   errmsg = 'Entered quantity less than zero';
751kA /end-free
740kAC                   exsr      zm9898
740kAC                   goto      endck6c
740kAc                   endif
650aAC     endck6c       endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCHK6d  Screen 6d error checking.
650bA*
650bAC     zzchk6d       begsr
650bAC                   eval      error = *off

710eA*    Check for I99 uci
710eA
710eAC                   call      'CVTBAR'
710eAC                   parm      '*ALL'        $cbcmd            8
710eAC                   parm      w6uci         $cbbar          100
710eAC                   parm                    $cbcod            3 0
710eAC                   parm                    $cbdec            1 0
710eAC                   parm                    $cbdsc           30
710eAC                   parm                    $cbpos            3 0
710eAC                   parm                    $cbtyp            1 0
710eAC                   parm                    $cbv1            11 3
710eAC                   parm                    $cbv2            50
710eAC                   parm                    $cbrtn            8
710eAC                   parm                    $cberm           60
710eAC                   parm                    $cbven           10 0
710eAC                   parm                    $cvtdata
710eAC                   parm                    $cvtdata2
740eAC                   parm      w1whse        $cbwhse           3 0
740eAC                   parm                    $cbsent           1
740eAC                   parm      lbitem        $cbitem          15

710eAc                   eval      $barcode = $cvtdata
710eAc                   eval      $barcode2 = $cvtdata2

710eA*  Verify UPC UOM is the correct UOM being picked.
710eA* Fill r#header ds
710eAc                   if        not $bcai99sent
710eAC                   eval      $hdrcommand = 'vfyupcuom'
710eAC                   time                    curtime
710eAC                   eval      $hdrtimestamp = %char(curtime)
710eAC                   eval      $slvuuitman#  = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
710eAC                   exsr      zztraxlbl
710eAC                   move      *blanks       w2lbl#b
710eAC                   move      $plbl#        w2lbl#b
710eAC                   z-add     $plbl#        w2lbl
710eAC                   eval      $slvuuilbl#  = w2lbl
710eAC                   eval      $slvuuivalue = w6uci
710eAC                   eval      $pheader = $header
710eAC                   eval      $pfields = $slvfyupuin
710eAC                   exsr      writelog
710eAC                   call      'VOSELECT'
710eAC                   parm      '*none'       $pdqlib
710eAC                   parm      '*none'       $pdqnameout
710eAC                   parm      '*none'       $pdqkey
710eAC                   parm                    $pheader
710eAC                   parm                    $pfields
710eAC                   parm                    $prtnfields
710cMC                   eval      $slvfyupuout = $prtnfields
710eA*
710eAC                   if        $slvuuoerrnum   <> 0
710eAC                   eval      error = *on
710eAC                   eval      *in23 = *on
710eAC                   eval      *in03 = *on
710eAC                   eval      errmsg = $slvuuoerrtxt
710eAC                   exsr      zm9898
710eAC                   goto      endck6d
710eAC                   endif
710eAC                   endif
650bA*
650bA*
650bA*  Verify UCI is for item scanned on label from SCreen2
650bA* Fill r#header ds
650bAC                   eval      $hdrcommand = 'pickuci'
650bAC                   time                    curtime
650bAC                   eval      $hdrtimestamp = %char(curtime)
650bAC                   eval      $slpuitman# = #job
650bAC                   eval      $slpuitrn# = $slvlotrn#
650bAC                   eval      $slpuilbl# = $slvlolbl#
650bAC                   eval      $slpuistop = $slvlostop
650bAC                   eval      $slpuiitem = $slvloitem
750sAc                   if        virtualpick = 'V'
750sAC                   eval      $slpuislot = lbdisp
750sAc                   else
650bAC                   eval      $slpuislot = $slvlodisp
750sAc                   endif
650bAC                   eval      $slpuiuci = w6uci
650bAC                   eval      $pheader = $header
650bAC                   eval      $pfields = $slpickuciin
650bAC                   exsr      writelog
650bAC                   call      'VOSELECT'
650bAC                   parm      '*none'       $pdqlib
650bAC                   parm      '*none'       $pdqnameout
650bAC                   parm      '*none'       $pdqkey
650bAC                   parm                    $pheader
650bAC                   parm                    $pfields
650bAC                   parm                    $prtnfields
650bAC                   eval      $slpckuciout   = $prtnfields
     *
650bAC                   if        $slpuoerrnum > 0
730aA /free
730aA   if w6cnt2 = 1 and ufinfl = *on;
730aA     if w6cnt1 = 1;
730aA       w6cnt1 = w6cnt1 - 1;
730aA     endif;
730aA     leavesr;
730aA   endif;
730aA /end-free
650bAC                   eval      error = *on
650bAC                   eval      *in23 = *on
650bAC                   eval      *in03 = *on
650bAC                   eval      errmsg = $slpuoerrtext
650bAC                   exsr      zm9898
650bAC                   goto      endck6d
650bAC                   endif
     * Check if already scanned
710fDc*                  if        oprfpm = '2'
710fDC*                  eval      w6uci = '99TRAX'+w6uci
710fDc*                  endif
710fDc*                  move      w6uci         $pbarcode
710fDC*                  eval      $hdrcommand = 'pickuci'
710fDC*                  time                    curtime
710fDC*                  eval      $hdrtimestamp = %char(curtime)
710fDC*                  eval      $slpuitman# = #job
710fDC*                  eval      $slpuitrn# = $slvlotrn#
710fDC*                  eval      $slpuilbl# = $slvlolbl#
710fDC*                  eval      $slpuistop = $slvlostop
710fDC*                  eval      $slpuiitem = $slvloitem
710fDC*                  eval      $slpuislot = $slvlodisp
710fDC*                  eval      $slpuiuci = w6uci
710fDC*                  eval      $pheader = $header
710fDC*                  eval      $pfields = $slpickuciin
710fDC*                  exsr      writelog
710fDC*                  call      'VOSELECT'
710fDC*                  parm      '*none'       $pdqlib
710fDC*                  parm      '*none'       $pdqnameout
710fDC*                  parm      '*none'       $pdqkey
710fDC*                  parm                    $pheader
710fDC*                  parm                    $pfields
710fDC*                  parm                    $prtnfields
710fDC*                  eval      $slpckuciout   = $prtnfields
710fD* Error Number 99 for 99TRAX
710fDC*                  if        $slpuoerrnum <> 0
710fDC*                  movel     $pbarcode     w6uci
710fDC*                  eval      error = *on
710fDC*                  eval      *in23 = *on
710fDC*                  eval      *in03 = *on
710fDC*                  eval      errmsg = $slpuoerrtext
710fDC*                  exsr      zm9898
710fDC*                  goto      endck6d
710fDC*                  endif

650bAC     endck6d       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZCHK6e  Screen 6e error checking.
730qA*
730qAC     zzchk6e       begsr
730qAC                   eval      error = *off

730qA*    Check for I99 uci
730qA
730qAC                   call      'CVTBAR'
730qAC                   parm      '*ALL'        $cbcmd            8
730qAC                   parm      w6uci         $cbbar          100
730qAC                   parm                    $cbcod            3 0
730qAC                   parm                    $cbdec            1 0
730qAC                   parm                    $cbdsc           30
730qAC                   parm                    $cbpos            3 0
730qAC                   parm                    $cbtyp            1 0
730qAC                   parm                    $cbv1            11 3
730qAC                   parm                    $cbv2            50
730qAC                   parm                    $cbrtn            8
730qAC                   parm                    $cberm           60
730qAC                   parm                    $cbven           10 0
730qAC                   parm                    $cvtdata
730qAC                   parm                    $cvtdata2
740eAC                   parm      w1whse        $cbwhse           3 0
740eAC                   parm                    $cbsent           1
740eAC                   parm      lbitem        $cbitem          15

730qAc                   eval      $barcode = $cvtdata
730qAc                   eval      $barcode2 = $cvtdata2

730qA*  Verify UPC UOM is the correct UOM being picked.
730qA* Fill r#header ds
730qAc                   if        not $bcai99sent
730qAC                   eval      $hdrcommand = 'vfyupcuom'
730qAC                   time                    curtime
730qAC                   eval      $hdrtimestamp = %char(curtime)
730qAC                   eval      $slvuuitman#  = #job
730qAC                   eval      $pbarcode = w2lbl#b
730qAC                   exsr      zztraxlbl
730qAC                   move      *blanks       w2lbl#b
730qAC                   move      $plbl#        w2lbl#b
730qAC                   z-add     $plbl#        w2lbl
730qAC                   eval      $slvuuilbl#  = w2lbl
730qAC                   eval      $slvuuivalue = w6uci
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slvfyupuin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slvfyupuout = $prtnfields
730qA*
730qAC                   if        $slvuuoerrnum   <> 0
730qAC                   eval      error = *on
730qAC                   eval      *in23 = *on
730qAC                   eval      *in03 = *on
730qAC                   eval      errmsg = $slvuuoerrtxt
730qAC                   exsr      zm9898
730qAC                   goto      endck6e
730qAC                   endif
730qAC                   endif
730qA*
730qA*
730qA*  Verify UCI is for item scanned on label from SCreen2
730qA* Fill r#header ds
730qAC                   eval      $hdrcommand = 'pickuci'
730qAC                   time                    curtime
730qAC                   eval      $hdrtimestamp = %char(curtime)
730qAC                   eval      $slpuitman# = #job
730qAC                   eval      $slpuitrn# = $slvlotrn#
730qAC                   eval      $slpuilbl# = $slvlolbl#
730qAC                   eval      $slpuistop = $slvlostop
730qAC                   eval      $slpuiitem = $slvloitem
750sAc                   if        virtualpick = 'V'
750sAC                   eval      $slpuislot = lbdisp
750sAc                   else
730qAC                   eval      $slpuislot = $slvlodisp
750sAc                   endif
730qAC                   eval      $slpuiuci = w6uci
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slpickuciin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slpckuciout   = $prtnfields
     *
730qAC                   if        $slpuoerrnum > 0
730qA /free
730qA   if w6cnt2 = 1 and ufinfl = *on;
730qA     if w6cnt1 = 1;
730qA       w6cnt1 = w6cnt1 - 1;
730qA     endif;
730qA     leavesr;
730qA   endif;
730qA /end-free
730qAC                   eval      error = *on
730qAC                   eval      *in23 = *on
730qAC                   eval      *in03 = *on
730qAC                   eval      errmsg = $slpuoerrtext
650bAC                   exsr      zm9898
730qAC                   goto      endck6e
730qAC                   endif

730qAC     endck6e       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZCHK6f  Screen 6f error checking.
730qA*
730qAC     zzchk6f       begsr
730qAC                   eval      error = *off

730qA*    Check for I99 uci
730qA
730qAC                   call      'CVTBAR'
730qAC                   parm      '*ALL'        $cbcmd            8
730qAC                   parm      w6uci         $cbbar          100
730qAC                   parm                    $cbcod            3 0
730qAC                   parm                    $cbdec            1 0
730qAC                   parm                    $cbdsc           30
730qAC                   parm                    $cbpos            3 0
730qAC                   parm                    $cbtyp            1 0
730qAC                   parm                    $cbv1            11 3
730qAC                   parm                    $cbv2            50
730qAC                   parm                    $cbrtn            8
730qAC                   parm                    $cberm           60
730qAC                   parm                    $cbven           10 0
730qAC                   parm                    $cvtdata
730qAC                   parm                    $cvtdata2
740eAC                   parm      w1whse        $cbwhse           3 0
740eAC                   parm                    $cbsent           1
740eAC                   parm      lbitem        $cbitem          15

730qAc                   eval      $barcode = $cvtdata
730qAc                   eval      $barcode2 = $cvtdata2

730qA*  Verify UPC UOM is the correct UOM being picked.
730qA* Fill r#header ds
730qAc                   if        not $bcai99sent
730qAC                   eval      $hdrcommand = 'vfyupcuom'
730qAC                   time                    curtime
730qAC                   eval      $hdrtimestamp = %char(curtime)
730qAC                   eval      $slvuuitman#  = #job
730qAC                   eval      $pbarcode = w2lbl#b
730qAC                   exsr      zztraxlbl
730qAC                   move      *blanks       w2lbl#b
730qAC                   move      $plbl#        w2lbl#b
730qAC                   z-add     $plbl#        w2lbl
730qAC                   eval      $slvuuilbl#  = w2lbl
730qAC                   eval      $slvuuivalue = w6uci
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slvfyupuin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slvfyupuout = $prtnfields
730qA*
730qAC                   if        $slvuuoerrnum   <> 0
730qAC                   eval      error = *on
730qAC                   eval      *in23 = *on
730qAC                   eval      *in03 = *on
730qAC                   eval      errmsg = $slvuuoerrtxt
730qAC                   exsr      zm9898
730qAC                   goto      endck6f
730qAC                   endif
730qAC                   endif
730qA*
730qA*
730qA*  Verify UCI is for item scanned on label from SCreen2
730qA* Fill r#header ds
730qAC                   eval      $hdrcommand = 'unpickuci'
730qAC                   time                    curtime
730qAC                   eval      $hdrtimestamp = %char(curtime)
730qAC                   eval      $slpuitman# = #job
730qAC                   eval      $slpuitrn# = $slvlotrn#
730qAC                   eval      $slpuilbl# = $slvlolbl#
730qAC                   eval      $slpuistop = $slvlostop
730qAC                   eval      $slpuiitem = $slvloitem
730qAC                   eval      $slpuislot = $slvlodisp
730qAC                   eval      $slpuiuci = w6uci
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slpickuciin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slpckuciout   = $prtnfields
     *
730qAC                   if        $slpuoerrnum > 0
730qA /free
730qA   if w6cnt2 = 1 and ufinfl = *on;
730qA     if w6cnt1 = 1;
730qA       w6cnt1 = w6cnt1 - 1;
730qA     endif;
730qA     leavesr;
730qA   endif;
730qA /end-free
730qAC                   eval      error = *on
730qAC                   eval      *in23 = *on
730qAC                   eval      *in03 = *on
730qAC                   eval      errmsg = $slpuoerrtext
650bAC                   exsr      zm9898
730qAC                   goto      endck6f
730qAC                   endif

730qAC     endck6f       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 7 error checking.
     *
     C     zzchk7        begsr

720nAc                   if        DonewithWgt = *off
SVLbA
SVLbA*  For Saval ...
SVLbA
SVLhA*    Saval Small Kitchen Items
SVLhAC                   if        client = saval
SVLmMC                             and (type = 'SKI'
SVLmAC                              or  type = 'PRO')
SVLhA
SVLhA*    Verify item number is correct.
SVLhAC                   exsr      zzgeti
SVLhAC                   if        w7cwgt <> ititem
SVLhAC                   eval      Error = *On
SVLhAC                   eval      errmsg = 'Wrong Item#'
SVLhAC                   exsr      zm9898
SVLhAC                   endif
SVLhAC                   goto      endck7
SVLhAC                   endif
SVLgA
SVLgA*    Saval Chicken Items
SVLgAC                   if        client = saval
SVLgAC                             and type = 'CHK'
SVLiA
SVLiA*    Get Vendor Item Number
SVLiA
SVLiAC                   exsr      zzgeti
SVLiA
SVLiA*    For NON-Catchweight, just test item number and skip
SVLiA
SVLlDC**                 if        itcwgt = 'N'
SVLlDC**                 eval      temp5 = %subst(w7cwgt:2:5)
SVLlDC**                 if        temp5 <> %subst(itvit#:1:5)
SVLlDC**                 eval      Error = *On
SVLlDC**                 eval      errmsg = 'Wrong Ven Item#'
SVLlDC**                 exsr      zm9898
SVLlDC**                 endif
SVLlDC**                 goto      endck7
SVLlDC**                 endif
SVLiA
SVLiA*    Extract UPC from scanned value.
SVLiA
SVLiAC                   call      'CVTBAR'
SVLiAC                   parm      '*UPC'        $cbcmd            8
SVLiAC                   parm      w7cwgt        $cbbar          100
SVLiAC                   parm                    $cbcod            3 0
SVLiAC                   parm                    $cbdec            1 0
SVLiAC                   parm                    $cbdsc           30
SVLiAC                   parm                    $cbpos            3 0
SVLiAC                   parm                    $cbtyp            1 0
SVLiAC                   parm                    $cbv1            11 3
SVLiAC                   parm                    $cbv2            50
SVLiAC                   parm                    $cbrtn            8
SVLiAC                   parm                    $cberm           60
740eAC                   parm                    $cbven           10 0
740eAC                   parm                    $cvtdata
740eAC                   parm                    $cvtdata2
740eAC                   parm      w1whse        $cbwhse           3 0
740eAC                   parm                    $cbsent           1
740eAC                   parm      lbitem        $cbitem          15
SVLiA
SVLiA*    Error if value not extracted.
SVLiA
SVLiAC                   if        $cbrtn <> '*OK'
SVLiAC                   eval      Error = *On
SVLiAC                   eval      errmsg = 'Invalid UPC code'
SVLiAC                   exsr      zm9898
SVLiAC                   goto      endck7
SVLiAC                   endif
SVLiA
SVLiA* check vendor item number against what was ordered.
SVLiA
SVLiAC                   eval      temp5 = %subst($cbv2:9:5)
SVLiAC                   if        temp5 <> %subst(itvit#:1:5)
SVLiAC                   eval      Error = *On
SVLiAC                   eval      errmsg = 'Wrong Ven Item#'
SVLiAC                   exsr      zm9898
SVLiAC                   goto      endck7
SVLiAC                   endif
SVLlA
SVLlAC                   if        client = Saval
SVLlAC                   if        itcwgt = 'N'
SVLlAC                   goto      endck7
SVLlAC                   endif
SVLlAC                   endif
SVLgA
SVLiA*    Extract catchweight from scanned value.
SVLiA
SVLiAC                   call      'CVTBAR'
SVLiAC                   parm      '*CWGTLBS'    $cbcmd            8
SVLiAC                   parm      w7cwgt        $cbbar          100
SVLiAC                   parm                    $cbcod            3 0
SVLiAC                   parm                    $cbdec            1 0
SVLiAC                   parm                    $cbdsc           30
SVLiAC                   parm                    $cbpos            3 0
SVLiAC                   parm                    $cbtyp            1 0
SVLiAC                   parm                    $cbv1            11 3
SVLiAC                   parm                    $cbv2            50
SVLiAC                   parm                    $cbrtn            8
SVLiAC                   parm                    $cberm           60
700dAC                   parm      0             $cbven           10 0
700dAC                   parm                    $cvtdata        256
700dAC                   parm                    $cvtdata2       256
700dAC                   parm      w1whse        $cbwhse           3 0
700dAC                   parm      kilolbs       $cbsent           1
740eAC                   parm      lbitem        $cbitem          15
SVLiA
SVLiA*    Error if value not extracted.
SVLiA
SVLiAC                   if        $cbrtn <> '*OK'
SVLiAC                   eval      Error = *On
SVLiAC                   eval      errmsg = 'Invalid catchweight'
SVLiAC                   exsr      zm9898
SVLiAC                   goto      endck7
SVLiAC                   endif
SVLiA
SVLiA*    Verify catchweight is correct.
SVLiA
SVLiAC                   eval      cwgt = $cbv1
SVLiAC                   eval      $slscoweight = cwgt
SVLgAC                   goto      chkwgt
SVLgAC                   endif
SVLgA
SVLbAC                   if        client = saval
SVLdAC                             and type = 'STK'
SVLbA
SVLbA*    Extract UPC from scanned value.
SVLbA
SVLbAC                   call      'CVTBAR'
SVLbAC                   parm      '*UPC'        $cbcmd            8
SVLbAC                   parm      w7cwgt        $cbbar          100
SVLbAC                   parm                    $cbcod            3 0
SVLbAC                   parm                    $cbdec            1 0
SVLbAC                   parm                    $cbdsc           30
SVLbAC                   parm                    $cbpos            3 0
SVLbAC                   parm                    $cbtyp            1 0
SVLbAC                   parm                    $cbv1            11 3
SVLbAC                   parm                    $cbv2            50
SVLbAC                   parm                    $cbrtn            8
SVLbAC                   parm                    $cberm           60
700dAC                   parm      0             $cbven           10 0
700dAC                   parm                    $cvtdata        256
700dAC                   parm                    $cvtdata2       256
700dAC                   parm      w1whse        $cbwhse           3 0
700dAC                   parm      kilolbs       $cbsent           1
740eAC                   parm      lbitem        $cbitem          15
SVLbA
SVLbA*    Error if value not extracted.
SVLbA
SVLbAC                   if        $cbrtn <> '*OK'
SVLbAC                   eval      Error = *On
SVLbAC                   eval      errmsg = 'Invalid UPC code'
SVLbAC                   exsr      zm9898
SVLbAC                   goto      endck7
SVLbAC                   endif
SVLbA
SVLbA*    Verify vendor item number is correct.
SVLbA
SVLbAC                   exsr      zzgeti
SVLbAC                   eval      temp5 = %subst($cbv2:9:5)
SVLbAC                   if        temp5 <> itvit#
SVLbAC                   eval      Error = *On
SVLbAC                   eval      errmsg = 'Wrong Ven Item#'
SVLbAC                   exsr      zm9898
SVLbAC                   goto      endck7
SVLbAC                   endif
SVLbA
SVLbAC                   endif
     *
     * Extract weight from scan
     * Fill r#header ds
     C                   eval      $hdrcommand = 'scancwt'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slscitman# = #job
     C                   eval      $slscivalue = w7cwgt
700bAC                   eval      $slscilabel# = w6lbl
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slscancwin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slscancwout = $prtnfields
     *
501jAC                   if        $slscoerrnum <> 0
650dA*      001 means GS1 value scanned.
650aAC                              and $slscoerrnum <> 001
650dA*      002 means non-GS1 value scanned.
650dAC                              and $slscoerrnum <> 002
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = $slscoerrtext
700fAC                   exsr      zm9898
     C                   goto      endck7
     C                   else
     *  Use extracted catch weight.
     C                   eval      cwgt = $slscoweight
700dAC                   if        $slscoerrnum = 002
700dAc                   eval      wgt = cwgt
700dAc                   Exsr      zzcnvwgt
700dAC                   eval      cwgt = wwgt
700dAc                   endif
700dAC                   eval      $slscoweight = cwgt
     C                   endif
     *
SVLgAC     chkwgt        tag
     *   Calculate catch weight values for check.
     C                   exsr      zzcwgt
     *
     *   WTCHK, Flags are used to force F8 for each test
     *   Values: Flag = 0 Do check.
     *           Flag = 1 Check was done, ok.
     *           Flag = 2 Warning condition.
     *
     C                   eval      error = *off
     * Set flag
     C                   if        wtchk = '2' and
     C                             ovrrid = *on
     C                   eval      wtchk = '1'
     C                   endif
     *  Verify catch weight.
     C                   if        wtchk <> '1'
     C                   eval      wtchk = '1'
     *
     C*     Check individual CW if variance check = Y.
700fDC*                  if        opwrnc = 'M' or
700fDC*                            opwrnc = 'B'
640aDC*                  if        opwrnc = 'Y'
500cDC**                           opicw  = 'Y'
     C*                  movel     w7cwgt        cwgt              7 0
     C*    cwgt          div       100           taddw             7 2
     C                   z-add     0             taddw             7 2
     C                   eval      taddw = cwgt
750eAc                   if        ptsub = 'BULK' and allowbulk
750eAc                             and combo
750eAc                   eval      ilrng = lwrng
750eAc                   eval      ihrng = hirng
750eAc                   endif
     C                   if        lvskp = *off and
     C                             taddw < ilrng
     C                   eval      error = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   z-add     ilrng         erlrng
     *
     C                   if        hvskp  = *on
     C                   z-add     0             erhrng
     C                   else
     C                   z-add     ihrng         erhrng
     C                   endif
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     $slvlouwgt    erexwt
     C*                  z-add     lbuwgt        erexwt
720iDC*                  exsr      zm21
720iMC                   exsr      zm21small
     C                   endif
     *
     C                   if        hvskp  = *off and
     C                             taddw  > ihrng
     C                   eval      error = *on
     C                   eval      warn  = *on
     C                   eval      wtchk = '2'
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   z-add     taddw         ertcwt
     C                   if        lvskp = *on
     C                   z-add     0             erlrng
     C                   else
     C                   z-add     ilrng         erlrng
     C                   endif
     C                   z-add     ihrng         erhrng
     C     prg1c         mult      100           errg1c
     C     prg2c         mult      100           errg2c
     C                   z-add     $slvlouwgt    erexwt
720iDC*                  exsr      zm21
720iMC                   exsr      zm21small
     C                   endif
     *
700fDC*                  endif
     C                   endif
720nAc                   endif
     *
     *
     C     endck7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8   Screen 8 error checking.
     *
     C     zzchk8        begsr
     C                   eval      error = *off
     *
     *  Display Trans complete message.
     *
     C     endck8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK9   Screen 9 error checking.
     *
     C     zzchk9        begsr
     C                   eval      error = *off
     *
     *  Close open selection Trans message.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'close'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slclitman# = #job
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slclosein
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slcloseout = $prtnfields
     *
501jAC                   if        $slcloerrnum <> 0
     C                   eval      error = *on
     C                   eval      errmsg = $slcloerrtext
     C*                  eval      #msgk = $slcloerrtext
     C                   exsr      zm9898
     C                   else
     C                   eval      ufinfl= *off
     C                   endif
     *
     C     endck9        endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZCHK9a  Screen 9a error checking.
ISPaA*
ISPaAC     zzchk9a       begsr
     C                   eval      error = *off
     *
     *  Close open selection Trans message.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'close'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slclitman# = #job
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slclosein
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slcloseout = $prtnfields
     *
501jAC                   if        $slcloerrnum <> 0
     C                   eval      error = *on
     C                   eval      errmsg = $slcloerrtext
     C*                  eval      #msgk = $slcloerrtext
     C                   exsr      zm9898
     C                   else
     C                   eval      ufinfl= *off
     C                   endif
     *
ISPaAC     endck9a       endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  ZZCHK10  Screen 10 error checking.
500dA*
500dAC     zzchk10       begsr
     C                   eval      error = *off
     C     endck10       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZCHK11  Screen 11 error checking.
700fA*
700fAC     zzchk11       begsr
700fAC                   eval      error = *off
700fA* Check if label has been picked before giving suspend confirmation.
700iDC*                  eval      $hdrcommand = 'vfylabel'
700iDC*                  time                    curtime
700iDC*                  eval      $hdrtimestamp = %char(curtime)
700iDC*                  eval      $slvlitman# = #job
700iDC*                  move      *blanks       w2lbl#b
700iDc*                  if        multitran
700iDc*                  movel     slwlbl#       w2lbl#b
700iDc*                  z-add     slwlbl#       w2lbl
700iDc*                  else
700iDc*                  movel     lblbl#        w2lbl#b
700iDc*                  z-add     lblbl#        w2lbl
700iDc*                  endif
700iDC*                  movel     w2lbl#b       $pbarcode
700iDC*                  eval      $slvlilbl# = w2lbl
700iDC*                  eval      $pheader = $header
700iDC*                  eval      $pfields = $slvfylblin
700iDC*                  exsr      writelog
700iDC*                  call      'VOSELECT'
700iDC*                  parm      '*none'       $pdqlib
700iDC*                  parm      '*none'       $pdqnameout
700iDC*                  parm      '*none'       $pdqkey
700iDC*                  parm                    $pheader
700iDC*                  parm                    $pfields
700iDC*                  parm                    $prtnfields
700iDC*                  eval      $slvfylblout = $prtnfields
700iAc                   eval      kywhse = w1whse
700iAC     l90key        Setll     Label90
700iAC                   DoW       Forevr = Forevr
700iAC     l90key        ReadE     Label90
700iAC                   if        %eof
700iAC                   Leave
700iAC                   endif
700iAC                   If        Lbstat = 'C' Or Lbvrfy = 'T'
700iAC                             Or Lbvrfy = 'F'
700iAC                             Or Lbvrfy = 'I'
700iAc                   eval      error = *on
700iAC                   endif
700iAC                   Enddo
700fA*
700fAC     endck11       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZCHK11a  Screen 11 error checking.
700fA*
700fAC     zzchk11a      begsr
700fAC                   eval      error = *off
     *
700fAC                   eval      $slvsoloqavl = 0
700fAC                   clear                   w2lbl#b
700fAC                   clear                   $pbarcode
700fAc                   if        lblbl# <> 0
700fAc                   movel     lblbl#        w2lbl#b
700fAc                   else
700fAc                   movel     slwlbl#       w2lbl#b
700fAc                   end
700fAc                   eval      w3scan = sslot
700fAc                   eval      w3disp = sslot
700fA*
700fA*  Verify label is for entered transaction and still open.
700fA*
700fA* Fill r#header ds
720cAc                   if        zonepickup
720cAC                   eval      $hdrcommand = 'vfylabelM'
720cAc                   else
730wAc                   if        ptsub = 'BULK' and AllowBulk = *on
730wAC                   eval      $hdrcommand = 'vfylabelB'
730wAc                   else
700fAC                   eval      $hdrcommand = 'vfylabel'
730wAc                   endif
720cAc                   endif
700fAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
700fAC                   eval      $slvlitman# = #job
720cDC*                  movel     w2lbl#b       $pbarcode
720cMC                   eval      $pbarcode = w2lbl#b
700fAC                   exsr      zztraxlbl
700fAC                   move      *blanks       w2lbl#b
700fAC                   move      $plbl#        w2lbl#b
700fAC                   z-add     $plbl#        w2lbl
700fAC                   eval      $slvlilbl# = w2lbl
700fAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slvfylblin
700fAC                   exsr      writelog
700fAC                   call      'VOSELECT'
700fAC                   parm      '*none'       $pdqlib
700fAC                   parm      '*none'       $pdqnameout
700fAC                   parm      '*none'       $pdqkey
700fAC                   parm                    $pheader
700fAC                   parm                    $pfields
700fAC                   parm                    $prtnfields
700fAC                   eval      $slvfylblout = $prtnfields
700fA*
700fAC                   if        $slvloerrnum <> 0
700fAC                   eval      error = *on
700fAC                   endif
730vA /free
730vA   if usingp2p = *on;
730vA     setll ($slvlotrn#) pltsum4;
730vA     dow forevr = forevr;
730vA       reade ($slvlotrn#) pltsum4;
730vA       if %eof(pltsum4);
730vA         leave;
730vA       endif;
730vA       if $slvlopal# > pspal#;
730vA         p2plights ('*SET':$slsropjack:'B':'B':'1');
730vA       else;
730vA         p2plights ('*SET':$slsropjack:'A':'B':'1');
730vA       endif;
730vA     enddo;
730vA   endif;
730vA /end-free
730qA /free
730qA
730qA  monitor;
730qA    umWhse = lbwhse;
730qA    umlabel('*GET': umRtnCode: umRtnMsg:
730qA            umWhse: lblbl#:
730qA            umFlexPickFlag:
730qA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730qA  on-error;
730qA    umRtnCode = '*ERROR';
730qA  endmon;
730qA
730qA  if umRtnCode = '*OK';
730qA    select;
730qA      when umFlexPickFlag = 'P2W';
730qA        pick2lbs = lbswgt;
730qA      when umFlexPickFlag = 'PAQ';
730qA    endsl;
730qA  endif;
730qA
750uA  if multitran;
750uA    w2rtid = slwrte;
750uA  else;
750uA    w2rtid = lbrte;
750uA  endif;
730qA /end-free
700fAC     endck11a      endsr
700fA*
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZCHK12  Screen 12 error checking.
700fA*
700fAC     zzchk12       begsr
700fAC                   eval      error = *off
700fA*
710bA*   Reassign transaction when transaction has been suspended.
740dDC*    w1trn#        chain     pirtran                            79
740dA /free
740eD   //chain (w1whse:w1trn#) pirtranw;
740eM   chain (w1whse: $SLVLOTRN#) pirtranw;
740dA   if not %found(pirtranw);
740dA     *in79 = *on;
740dA   endif;
740dA /end-free
710bAC                   if        ptstat = '8'
710bA* Fill r#header ds
710bAC                   eval      $hdrcommand = 'assign'
710bAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
710bAC                   eval      $slasitman# = #job
740eDC*                  eval      $slasitrn# = w1trn#
740eMC                   eval      $slasitrn# = $SLVLOTRN#
710bAC                   eval      $slasitype = ' '
710bAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slassignin
710bAC                   exsr      writelog
700fAC                   call      'VOSELECT'
710bAC                   parm      '*none'       $pdqlib
710bAC                   parm      '*none'       $pdqnameout
710bAC                   parm      '*none'       $pdqkey
710bAC                   parm                    $pheader
710bAC                   parm                    $pfields
710bAC                   parm                    $prtnfields
710bAC                   endif
710bA*
730qAC                   if        oprfsl = 'N'
740iAC                             or oprfsl = 'E'
730qAC                   goto      endck12
730qAc                   endif
700fAc                   if        oprfsl = 'Y'
700jA*  Call API for slot.
700jA*
PFCaAc                   select
PFCaAc                   when      client = prestofoods
PFCaAc                   other
700jAC                   call      @apics
700jAC                   parm                    SSLOT
700jAC                   parm      5             worow
700jAC                   parm      7             wocol
700jAC                   parm                    @artn             8
700jAC                   if        @artn = '*REDSPLY'
710bAC                             and sslot <> *blanks
700jAC                   move      *on           redspl
700jAC                   goto      endck12
700jAC                   endif
PFCaAc                   endsl
700jA*
740eA*
740eA*  Removed the following code, the edit happens at the end
740eA*  This was just duplicated code.
740eA*
740eDc*                  if        multitran
720bA*
720bA*  Verify slot scanned matches slot displayed
720bA*
740eDc*                  exsr      clr$slot
740eDc*                  eval      $dricommand = '*SLOT'
740eDc*                  eval      $drisubcmd  = '%GET'
740eDc*                  eval      $drisys2upd = 'D'
740eDc*
740eDc*                  eval      $slwhseu = *on
740eDc*                  eval      $slwhse = ptwhse
740eDc*                  eval      $slwhdpu = *on
740eDc*                  eval      $slwhdp = itwhdp
740eDc*                  eval      $sldispu = *on
740eDc*                  eval      $sldisp = slwdisp
740eDc*                  exsr      zzzdricop

740eDc*                  if        sslot <> $sacdsp
720bD **                 if  **    sslot <> slwdisp
720cDC*                            and *inku = *off
740eDc*                  eval      error = *on
740eDc*                  eval      errmsg = *blanks
740eDc*                  if        sslot = *blanks
740eDc*                  eval      errmsg = desc(12)
740eDc*                  else
740eDc*                  eval      errmsg = desc(3)
740eDc*                  endif
740eDc*                  exsr      zm9898
740eDc*                  goto      endck12
740eDc*                  endif
740eDc*                  else
720bA*
720bA*  Verify slot scanned matches slot displayed
720bA*
740eDc*                  exsr      clr$slot
740eDc*                  eval      $dricommand = '*SLOT'
740eDc*                  eval      $drisubcmd  = '%GET'
740eDc*                  eval      $drisys2upd = 'D'
740eDc*
740eDc*                  eval      $slwhseu = *on
740eDc*                  eval      $slwhse = ptwhse
740eDc*                  eval      $slwhdpu = *on
740eDc*                  eval      $slwhdp = itwhdp
740eDc*                  eval      $sldispu = *on
740eDc*                  eval      $sldisp = lbdisp
740eDc*                  exsr      zzzdricop

740eDc*                  if        sslot <> $sacdsp
720bD **                 if   **   sslot <> lbdisp
720cDC*                            and *inku = *off
740eDc*                  eval      error = *on
740eDc*                  eval      errmsg = *blanks
740eDc*                  if        sslot = *blanks
740eDc*                  eval      errmsg = desc(12)
740eDc*                  else
740eDc*                  eval      errmsg = desc(3)
740eDc*                  endif
740eDc*                  exsr      zm9898
740eDc*                  goto      endck12
740eDc*                  endif
740eDc*                  endif
700fAc                   endif
700fAc                   if        oprfsl = 'C'
720cDc*                            and *inku = *off
740eAC                   eval      $hdrcommand = 'vfyckd'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAc
740eAC                   eval      $slvcditman# = #job
740eAC                   eval      $slvcdilbl# = lblbl#
740eAC                   eval      $slvcdichkd = cdgt
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slvfyckdin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAc                   eval      $slvfyckdout = $prtnfields
740eAC                   if        $slvcoerrnum <> 0
740eAC                   eval      error = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slvcoerrtext
740eAC                   exsr      zm9898
740eAC                   goto      endck12
740eAc                   endif

740eDc*                  if        multitran
740eDc*                  call      'GETCHKDGT'
740eDc*                  parm      ' '           $dCmd             8
740eDc*                  parm      slwwhse       $dWhse            3 0
740eDc*                  parm      slwwhdp       $dWhdp            5
740eDc*                  parm      slwdisp       $dSlot           12
740eDc*                  parm                    $dCodes           1 0
740eDc*                  parm                    $dDigits          1 0
740eDc*                  parm                    $dOrderType       1
740eDc*                  parm                    $dOrder1          6
740eDc*                  parm                    $dOrder2          6
740eDc*                  parm                    $dOrder3          6
740eDc*                  parm                    $dCodeType        1
740eDc*                  parm                    $dCode            6
740eDc*                  parm                    $dChkDigit        3 0
740eDc*                  parm                    $dReturn         10
740eDc*                  else
740eDc*                  call      'GETCHKDGT'
740eDc*                  parm      ' '           $dCmd             8
740eDc*                  parm      lbwhse        $dWhse            3 0
740eDc*                  parm      lbwhdp        $dWhdp            5
740eDc*                  parm      lbdisp        $dSlot           12
740eDc*                  parm                    $dCodes           1 0
740eDc*                  parm                    $dDigits          1 0
740eDc*                  parm                    $dOrderType       1
740eDc*                  parm                    $dOrder1          6
740eDc*                  parm                    $dOrder2          6
740eDc*                  parm                    $dOrder3          6
740eDc*                  parm                    $dCodeType        1
740eDc*                  parm                    $dCode            6
740eDc*                  parm                    $dChkDigit        3 0
740eDc*                  parm                    $dReturn         10
740eDc*                  endif
740eDc*                  if        cdgt <> $dChkDigit
740eDc*                  eval      error = *on
740eDc*                  eval      errmsg = *blanks
740eDc*                  eval      errmsg = desc(11)
740eDc*                  exsr      zm9898
740eDc*                  goto      endck12
740eDc*                  endif
700fAc                   endif
     *
700fAC                   if        not *inkh
     c                             and not *inkk
700fAC                   eval      $slvsoloqavl = 0
700fAC                   clear                   w2lbl#b
700fAC                   clear                   $pbarcode
700fAc                   if        multitran
700fAc                   movel     slwlbl#       w2lbl#b
700fAc                   else
700fAc                   movel     lblbl#        w2lbl#b
700fac                   endif
700fAc                   eval      w3scan = sslot
700fAc                   eval      w3disp = sslot
700fA*
700fA*  Verify label is for entered transaction and still open.
700fA*
700fA* Fill r#header ds
700fAC*                  eval      $hdrcommand = 'vfylabel'
700fAC*                  time                    curtime
700fAC*                  eval      $hdrtimestamp = %char(curtime)
700fAC*                  eval      $slvlitman# = #job
700fAC*                  movel     w2lbl#b       $pbarcode
700fAC*                  exsr      zztraxlbl
700fAC*                  move      *blanks       w2lbl#b
700fAC*                  move      $plbl#        w2lbl#b
700fAC*                  z-add     $plbl#        w2lbl
700fAC*                  eval      $slvlilbl# = w2lbl
700fAC*                  eval      $pheader = $header
700fAC*                  eval      $pfields = $slvfylblin
700fAC*                  exsr      writelog
700fAC*                  call      'VOSELECT'
700fAC*                  parm      '*none'       $pdqlib
700fAC*                  parm      '*none'       $pdqnameout
700fAC*                  parm      '*none'       $pdqkey
700fAC*                  parm                    $pheader
700fAC*                  parm                    $pfields
700fAC*                  parm                    $prtnfields
700fAC*                  eval      $slvfylblout = $prtnfields
700fA*
700fAC*                  if        $slvloerrnum <> 0
700fAC*                  eval      error = *on
700fAC*                  eval      *in23 = *on
700fAC*                  eval      *in03 = *on
700fAC*                  eval      errmsg = *blanks
700fAC*                  eval      errmsg = $slvloerrtext
700fAC*                  exsr      zm9898
700fAC*                  goto      endck12
700fAC*                  else
700fAC*                  endif
700fA*
700fA*  Call API for slot.
700fA*
PFCaAc                   select
PFCaAc                   when      client = prestofoods
PFCaAc                   other
700fAC                   call      @apics
700fAC                   parm                    w3scan
700fAC                   parm      5             worow
700fAC                   parm      7             wocol
700fAC                   parm                    @artn             8
700fAC                   if        @artn = '*REDSPLY'
700fAC                   move      *on           redspl
700fAC                   goto      endck12
700fAC                   endif
PFCaAc                   endsl
700fA*
700fA*  Verify slot scanned matches slot displayed
700fA*
700fAC                   exsr      clr$slot
700fAC                   eval      $dricommand = '*SLOT'
700fAC                   eval      $drisubcmd  = '%GET'
700fAC                   eval      $drisys2upd = 'D'
700fA
700fAC                   eval      $slwhseu = *on
700fAC                   eval      $slwhse = ptwhse
700fAC                   eval      $slwhdpu = *on
700fAC                   eval      $slwhdp = itwhdp
700fAC                   eval      $sldispu = *on
740eDC*                  eval      $sldisp = w3disp
740eMC                   eval      $sldisp = lbdisp
700fAC                   exsr      zzzdricop
700fA * drislot returns $SACDSP with base slot
750sAc                   eval      virtualpick = $slrsrv
700fAC                   if        w3scan <> $SACDSP
700fAc                             and OPRFSL = 'Y'
700fAC                   eval      error = *on
700fAC                   eval      *in21 = *on
700fAC                   eval      *in01 = *on
700fAC                   eval      errmsg = *blanks
700fAC                   eval      errmsg = desc(3)
700fAC                   exsr      zm9898
700fAC                   goto      endck12
700fAC                   endif
700fAC                   endif
700fA*
700fAC     endck12       endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  ZZCHK12v Screen 12v error checking.
740eA*
740eAC     zzchk12v      begsr
740eAC                   eval      error = *off
740eA*
740eA*   Reassign transaction when transaction has been suspended.
740eA /free
740eA   chain (w1whse: $SLVLOTRN#) pirtranw;
740eA   if not %found(pirtranw);
740eA     *in79 = *on;
740eA   endif;
740eA /end-free
740eAC                   if        ptstat = '8'
740eA* Fill r#header ds
740eAC                   eval      $hdrcommand = 'assign'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAC                   eval      $slasitman# = #job
740eAC                   eval      $slasitrn# = $SLVLOTRN#
740eAC                   eval      $slasitype = ' '
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slassignin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAC                   endif
750zA /free
750zA   // adding the ability to double click and try like say again
750zA   if (oprvsl > 0 or oprvcd > 0 or oprvup > 0) and slvfyval = ' '
           and *inki = '0';
750zA     // treat as double click for say again
750zA     // turn error on so it will redisplay the screen to voice
750zA     // instructions again.
750zA     error = *on;
750zA     leavesr;
750zA   endif;
750zA /end-free
740eA*
740eA*  verify slot
740eAc                   if        x = oprvsl and oprvsl <> 0
740eAc                   eval      SLVFYVAL = %triml(SLVFYVAL)
740eAc                   eval      sslot = %subst(SLVFYVAL:1:12)
740eA*  Call API for slot.
740eA*
PFCaAc                   select
PFCaAc                   when      client = prestofoods
PFCaAc                   other
740eAC                   call      @apics
740eAC                   parm                    SSLOT
740eAC                   parm      5             worow
740eAC                   parm      7             wocol
740eAC                   parm                    @artn             8
740eAC                   if        @artn = '*REDSPLY'
740eAC                             and sslot <> *blanks
740eAC                   move      *on           redspl
740eAC                   goto      endck12v
740eAC                   endif
PFCaAc                   endsl
740eA*
740eAc                   endif
740eA*  verify check digit
740eAc                   if        x = oprvcd and oprvcd <> 0
740eAc                   eval      SLVFYVAL = %triml(SLVFYVAL)
740eAc                   if        slvfyval <> ' '
740eAc                   eval      cdgt  = %dec(slvfyval:3:0)
740eAc                   endif
740eAC                   eval      $hdrcommand = 'vfyckd'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAc
740eAC                   eval      $slvcditman# = #job
740eAC                   eval      $slvcdilbl# = lblbl#
740eAC                   eval      $slvcdichkd = cdgt
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slvfyckdin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAc                   eval      $slvfyckdout = $prtnfields
740eAC                   if        $slvcoerrnum <> 0
740eAC                   eval      error = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slvcoerrtext
740eAC                   exsr      zm9898
740eAC                   goto      endck12v
740eAc                   endif
740eAc                   endif
740eA*
740eA*  verify upc
740eAc                   if        x = oprvup and oprvup <> 0
740eA* Fill r#header ds
740eAC                   eval      $hdrcommand = 'vfyupcuoml'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAC                   eval      $slvuuitman#  = #job
740eAC                   eval      $pbarcode = w2lbl#b
740eAC                   exsr      zztraxlbl
740eAC                   move      *blanks       w2lbl#b
740eAC                   move      $plbl#        w2lbl#b
740eAC                   z-add     $plbl#        w2lbl
740eAC                   eval      $slvuuilbl# = w2lbl
740eAc                   eval      SLVFYVAL = %triml(SLVFYVAL)
740eAC                   eval      $slvuuivalue   = slvfyval
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slvfyupuin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAC                   eval      $slvfyupuout = $prtnfields
740eA*
740eAC                   if        $slvuuoerrnum <> 0
740eAC                   eval      error = *on
740eAC                   eval      *in24 = *on
740eAC                   eval      *in04 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slvuuoerrtxt
740eAC                   exsr      zm9898
740eAC                   goto      endck12v
740eAC                   else
740eAc                   eval      sslot = sdisp
740eAC                   endif
740eAc                   endif
740eA*
740eAC                   if        not *inkh
740eAc                             and not *inkk
740eAc                             and oprvsl = x and oprvsl <> 0
750cAc                   if        $newsl = ' '
740eAC                   eval      $slvsoloqavl = 0
750cAc                   endif
740eAC                   clear                   w2lbl#b
740eAC                   clear                   $pbarcode
740eAc                   if        multitran
740eAc                   movel     slwlbl#       w2lbl#b
740eAc                   else
740eAc                   movel     lblbl#        w2lbl#b
740eAc                   endif
740eAc                   eval      w3scan = sslot
740eAc                   eval      w3disp = sslot
740eA*
740eA*  Verify label is for entered transaction and still open.
740eA*
740eA* Fill r#header ds
740eA*
740eA*
740eA*  Call API for slot.
740eA*
PFCaAc                   select
PFCaAc                   when      client = prestofoods
PFCaAc                   other
740eAC                   call      @apics
740eAC                   parm                    w3scan
740eAC                   parm      5             worow
740eAC                   parm      7             wocol
740eAC                   parm                    @artn             8
740eAC                   if        @artn = '*REDSPLY'
740eAC                   move      *on           redspl
740eAC                   goto      endck12v
740eAC                   endif
PFCaAc                   endsl
740eA*
740eA*  Verify slot scanned matches slot displayed
740eA*
740eAC                   exsr      clr$slot
740eAC                   eval      $dricommand = '*SLOT'
740eAC                   eval      $drisubcmd  = '%GET'
740eAC                   eval      $drisys2upd = 'D'
740eA
740eAC                   eval      $slwhseu = *on
740eAC                   eval      $slwhse = ptwhse
740eAC                   eval      $slwhdpu = *on
740eAC                   eval      $slwhdp = itwhdp
740eAC                   eval      $sldispu = *on
740eAC                   eval      $sldisp = lbdisp
740eAC                   exsr      zzzdricop
740eA * drislot returns $SACDSP with base slot
750sAc                   eval      virtualpick = $slrsrv
740eAC                   if        w3scan <> $SACDSP
740eAC                   eval      error = *on
740eAC                   eval      *in21 = *on
740eAC                   eval      *in01 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = desc(3)
740eAC                   exsr      zm9898
740eAC                   goto      endck12v
740eAC                   endif
740eAC                   endif
740eA*
740eAC     endck12v      endsr
740eA*
740eA*  ZZCHK13  Screen 113error checking.
740eA*
740eAC     zzchk13       begsr
740eAC                   eval      error = *off
740eA*
740eA*
740eA*   Make sure that the answer is Y/N.
740eAC                   if        spnd <> 'Y' and spnd <> 'N'
740eAC                   eval      error = *on
740eAC                   eval      errmsg = *blanks
740eAC                   exsr      zm1005
740eAC                   goto      endck13
740eAC                   endif
740eAc                   if        spnd = 'Y'
740eA * suspend
740eAC                   eval      $hdrcommand = 'suspend'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAC                   eval      $slssitman#  = #job
740eAC                   eval      $slssitrn#  = $SLVLOTRN#
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slsuspndin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAC                   eval      $slsuspndout = $prtnfields
740eA
740eAC                   if        $slssoerrnum <> 0
752tAc                   eval      spnd = 'N'
740eAc                   eval      error = *on
740eAC                   eval      *in22 = *on
740eAC                   eval      *in02 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slssoerrtext
740eAC                   exsr      zm9898
740eaC                   goto      endck13
740eAc                   endif
740eAc                   endif
740eAC*
740eAC     endck13       endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZCHK15  Screen 15 error checking.
720cA*
720cAC     zzchk15       begsr
720cAC                   eval      error = *off
720cA*
720cA*
720cA*   Make sure that the answer is Y/N.
720cAC                   if        mtrn <> 'Y' and Mtrn <> 'N'
720cAC                   eval      error = *on
720cAC                   eval      *in41 = *on
720cAC                   eval      errmsg = *blanks
720cAC*                  eval      errmsg = desc(4)
720cAC                   exsr      zm1005
720cAC                   goto      endck15
720cAC                   endif
720cAC*
720cAC     endck15       endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  ZZCHK16  Screen 16 error checking.
720dA*
720dAC     zzchk16       begsr
720dAC                   eval      error = *off
720dA*
720dA*
720dA*   Make sure that the answer is Y/N.
720dAC                   if        cshrt<> 'Y' and cshrt<> 'N'
720dAC                   eval      error = *on
720dAC                   eval      errmsg = *blanks
720dAC                   exsr      zm1005
720dAC                   goto      endck16
720dAC                   endif
720dAC*
720dAC     endck16       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCHK17  Screen 17 error checking.
720hA*
720hAC     zzchk17       begsr
752gAc                   if        DonewithWgt = *off
720hA*
720hA* Extract weight from scan
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'scancwt'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slscitman# = #job
720hAC                   eval      $slscivalue = w7cwgt
720hAC                   eval      $slscilabel# = w18lbl
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slscancwin
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slscancwout = $prtnfields
720hA*
720hAC                   if        $slscoerrnum <> 0
720hA*      001 means GS1 value scanned.
720hAC                              and $slscoerrnum <> 001
720hA*      002 means non-GS1 value scanned.
720hAC                              and $slscoerrnum <> 002
720hAC                   eval      error = *on
720hAC                   eval      *in21 = *on
720hAC                   eval      *in01 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   eval      errmsg = $slscoerrtext
720hAC                   exsr      zm9898
720hAC                   goto      endck17
720hAC                   else
720hA*  Use extracted catch weight.
720hAC                   eval      cwgt = $slscoweight
720hAC                   if        $slscoerrnum = 002
720hAc                   eval      wgt = cwgt
720hAc                   Exsr      zzcnvwgt
720hAC                   eval      cwgt = wwgt
720hAc                   endif
720hAC                   eval      $slscoweight = cwgt
720hAC                   endif
720hA*
720hAC     chkwgt17      tag
720hA*   Calculate catch weight values for check.
720hAC                   exsr      zzcwgt
720hA*
720hA*   WTCHK, Flags are used to force F8 for each test
720hA*   Values: Flag = 0 Do check.
720hA*           Flag = 1 Check was done, ok.
720hA*           Flag = 2 Warning condition.
720hA*
720hAC                   eval      error = *off
720hA* Set flag
720hAC                   if        wtchk = '2' and
720hAC                             ovrrid = *on
720hAC                   eval      wtchk = '1'
720hAC                   endif
720hA*  Verify catch weight.
720hAC                   if        wtchk <> '1'
720hAC                   eval      wtchk = '1'
720hA*
720hAC*     Check individual CW if variance check = Y.
720hAC                   z-add     0             taddw             7 2
720hAC                   eval      taddw = cwgt
720hAC                   if        lvskp = *off and
720hAC                             taddw < ilrng
720hAC                   eval      error = *on
720hAC                   eval      wtchk = '2'
720hAC                   eval      *in21 = *on
720hAC                   eval      *in01 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   z-add     taddw         ertcwt
720hAC                   z-add     ilrng         erlrng
720hA*
720hAC                   if        hvskp  = *on
720hAC                   z-add     0             erhrng
720hAC                   else
720hAC                   z-add     ihrng         erhrng
720hAC                   endif
720hAC     prg1c         mult      100           errg1c
720hAC     prg2c         mult      100           errg2c
720hAC                   z-add     $slvlouwgt    erexwt
720iDC*                  exsr      zm21
720iMC                   exsr      zm21small
720hAC                   endif
720hA*
720hAC                   if        hvskp  = *off and
720hAC                             taddw  > ihrng
720hAC                   eval      error = *on
720hAC                   eval      warn  = *on
720hAC                   eval      wtchk = '2'
720hAC                   eval      *in21 = *on
720hAC                   eval      *in01 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   z-add     taddw         ertcwt
720hAC                   if        lvskp = *on
720hAC                   z-add     0             erlrng
720hAC                   else
720hAC                   z-add     ilrng         erlrng
720hAC                   endif
720hAC                   z-add     ihrng         erhrng
720hAC     prg1c         mult      100           errg1c
720hAC     prg2c         mult      100           errg2c
720hAC                   z-add     $slvlouwgt    erexwt
720iDC*                  exsr      zm21
720iMC                   exsr      zm21small
720hAC                   endif
720hA*
720hAC                   endif
720hA*
720hA*
752gAc                   endif
720hAC     endck17       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCHK18  Screen 18 error checking.
720hA*
720hAC     zzchk18       begsr
720hAC                   eval      error = *off
720hA*
720hA*  Verify label is for trans
720hAc                   eval      traxYN = 'N'
720hAc                   if        %len(%trim(w18lbl#b)) = 10
720hAC                   eval      traxYN = 'Y'
720hAc                   endif
720hA*
720hA*  Verify label is the label we retrieved from voselect
720hA*
720hAC                   eval      $pbarcode =  w18lbl#b
720hAC                   exsr      zztraxlbl
720hAC                   move      *blanks       w18lbl#b
720hAC                   move      $plbl#        w18lbl#b
720hAC                   move      $plbl#        w18lbl
720hAc                   if        W18LBL#H <> $PLBL#
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   eval      errmsg = desc(14)
720hAC                   exsr      zm9898
720hAC                   goto      endck18
720hAC                   endif
720hA*  Verify label is the label we retrieved from voselect
720hA*
720hac                   exsr      Vfy4Skipcw
720hAc                   if        FoundWLabel = *off
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   eval      errmsg = desc(1)
720hAC                   exsr      zm9898
720hAC                   goto      endck18
720hAC                   endif
720hA*
720hAC     endck18       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCHK19  Screen 19 error checking.
720hA*
720hAC     zzchk19       begsr
720hAC                   eval      error = *off
720hA*
720hA*  Verify label is for a weigh later label
720hAC                   eval      $pbarcode = W19LBL#B
720hAC                   exsr      zztraxlbl
720hAC                   move      *blanks       W19LBL#B
720hAC                   move      $plbl#        W19LBL#B
720hAC                   z-add     $plbl#        w19lbl
720hAC                   time                    curtime
720hAc                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $hdrcommand = 'getcw'
720hAC                   move      $plbl#        $slgwilbl#4
720hAC                   eval      $slgwitman# = #job
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slgetcwin
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slgetcwout  = $prtnfields
720hA*
720hAC                   if        $slgwoerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720hAC                   eval      errmsg = *blanks
720hAC                   eval      errmsg = $slgwoerrtext
720hAC                   exsr      zm9898
720hAC                   eval      w19lbl#b = $pbarcode
720hAC                   goto      endck19
720hAC                   else
                         eval      $slc2otrn# = $slgwotrn#;
                         eval      w18lbl#h = $slgwolbl#;

720hAC                   endif
720hA
720hA*
720hA*
720hAC     endck19       endsr
720lA*----------------------------------------------------------------
720lA*
720lA*  ZZCHK20  Screen 20 error checking.
720lA*
720lAC     zzchk20       begsr
720lAC                   eval      error = *off
720lA*
720lA*
720lA*   Make sure that the answer is 1/2.
720lAC                   if        eupc <> '1' and eupc <> '2'
720lAC                   eval      error = *on
720lAC                   eval      errmsg = *blanks
720lAC                   exsr      zm1005
720lAC                   goto      endck20
720lAC                   endif
720lAC*
720lAC     endck20       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZCHK21  Screen 21 error checking.
730qA*
730qAC     zzchk21       begsr
730qAC                   eval      error = *off
730qA*
730qA*
730qA*   Make sure that the answer is Y/N.
730qAC                   if        cdone<> 'Y' and cdone<> 'N'
730qAC                   eval      error = *on
730qAC                   eval      errmsg = *blanks
730qAC                   exsr      zm1005
730qAC                   goto      endck21
730qAC                   endif
730qAC*
730qAC     endck21       endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  ZZCHK22  Screen 22 error checking.
740dA*
740dAC     zzchk22       begsr
740dAC                   eval      error = *off
740dA*
740dA*
740dA*   Make sure that the answer is Y/N.
740dAC                   if        leavesus<> 'Y' and leavesus <> 'N'
740dAC                   eval      error = *on
740dAC                   eval      errmsg = *blanks
740dAC                   exsr      zm1005
740dAC                   goto      endck22
740dAC                   endif
740dAC*
740dAC     endck22       endsr
740lA*----------------------------------------------------------------
740lA*
740lA*  ZZCHK23  Screen 23 error checking.
740lA*
740lAC     zzchk23       begsr
740lAC                   eval      error = *off
740lA*
740lA*
740lA*   Make sure that the answer is Y/N.
740lAC                   if        zcmpl<> 'Y' and zcmpl<> 'N'
740lAC                   eval      error = *on
740lAC                   eval      errmsg = *blanks
740lAC                   exsr      zm1005
740lAC                   goto      endck23
740lAC                   endif
740lA
740lAC     endck23       endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  ZZCHK81  Screen 81 error checking.
750pA*
750pAC     zzchk81       begsr
      /free
        error = *off;
      /end-free
740pAC                   endsr
750lA*----------------------------------------------------------------
750lA*
750lA*  ZZCHK82  Screen 82 error checking.
750lA*
750lAC     zzchk82       begsr
750lAC                   eval      error = *off
750lA
750lAC     endck82       endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  ZZCHK84  Screen 84 error checking.
750qA*
750qAC     zzchk84       begsr
      /free
        error = *off;
        showaisle = ' ';
750uA   savex = x;
        x = 0;
        $slvsoloqavl = 0;
750uA   savew2lbl#b = w2lbl#b;
        w2lbl#b = w84lb#Char;
        exsr zzchk2;
        if error;
750yA     exsr zzresetl;
          leavesr;
        endif;
        exsr zzupd2;
      /end-free
     C                   endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  ZZCHK85  Screen 85 error checking.
750qA*
750qAC     zzchk85       begsr
      /free
        error = *off;
      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  ZZCHK86  Screen 86 error checking.
751uA*
751uAC     zzchk86       begsr
      /free
        error = *off;

        // Verify device code

        chain (w1whse: bigPalDev) devgrph;
        if not %found(devgrph);
          error = *on;
          errmsg = 'Device ' + %trimr(bigPalDev) + ' not found';
          leavesr;
        endif;

      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  ZZCHK87  Screen 86 error checking.
751uA*
751uAC     zzchk87       begsr
      /free
        error = *off;
752lA   // edit what they scanned.
752lA   // if it's a valid id, and it is a pallet jack type get the
752lA   // single, double triple info from the equipment type

752lA   // if it is a valid equipment code but not a pallet jack type
752lA   // we will assume single, since they could be doing a bulk pick
752lA   // with a forklift

752lA   // if they scan something that is not in the equip table, I will
752lA   // check to see if they scan something with the prefix they have
752lA   // setup in genpick options. if not I will send error

752rA   // Code cannot be blank
752rA
752rA   if pltjack = '';
752rA     error = *on;
752rA     errmsg = 'Code must be entered';
752rA     leavesr;
752rA   endif;

752rA   // Get length of prefix
752rA
752rA   pjpLength = %len(%trim(opspjp));

752rA   // See if code starts with pallet jack prefix
752rA
752rA   if pjpLength > 0
752rA      and %subst(pltjack:1:pjpLength) = %trim(opspjp);
752rA
752rA      // If code doesn't include # of pallets, default to 1
752rA
752rA      if %len(%trimr(pltjack)) = pjpLength;
752rA        pjtype = '1';
752rA        leavesr;
752rA      endif;
752rA
752rA      // Extract last character to get number of pallets.
752rA
752rA      pjtype = %subst(pltjack:pjplength+1:1);
752rA
752rA      // If not 1, 2 or 3, default to 1
752rA
752rA      if pjtype < '1' or pjtype > '3';
752rA        pjtype = '1';
752rA      endif;
752rA
752rA      leavesr;
752rA   endif;

752rA   // Code does not start with pallet jack prefix

752rA   // Error if equipment code doesn't exist

752lA   chain (w1whse: pltjack) equip;
752lA   if not %found(equip);
752lA     error = *on;
752lA     errmsg = %trimr(pltjack) + ' not valid';
752lA     leavesr;
752lA   endif;

752rA   // Code is not a pallet jack, but is in equipment file,
752rA   // Therefore, assume forklift and default to 1
752rA
752rA   pjtype = '1';

      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZCHK88  Screen 88 error checking.
752vA*
752vAC     zzchk88       begsr
      /free
        error = *off;
      /end-free
     *  Verify label is for label (scanned on SC2)
     * 99trax
     c                   if        %len(%trim(w88lbl)) = 10
     c                   if        zonepickup
     C                   eval      w6uci = '99TRAXM'+ w88lbl
     c                   endif
     c                   endif
     C                   eval      $pbarcode = w88lbl
     C                   exsr      zztraxlbl
     C                   move      *blanks       w6albl
     C                   move      $plbl#        w6albl
     C*                  z-add     $plbl#        w88lbl
      /free
          exec sql select * into :mrgrec
               from SPmrgwrk
               where mgwhse = :lbwhse
                 and mgjob  = :#job
                 and mgtrn# = :mgtrn#
                 and mgclb# = :w6albl
                 fetch first 1 rows only;
          If sqlstt <> sqlSuccess;
            error = *on;
            errmsg = *blanks;
            errmsg = desc(2);
            exsr zm9898;
            leavesr;
          endif;
      /end-free
     *
     * Check if already scanned
     C                   eval      $hdrcommand = 'pickuci'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpuitman# = #job
     C                   eval      $slpuitrn# = $slvlotrn#
     C                   eval      $slpuilbl# = $slvlolbl#
     C                   eval      $slpuistop = $slvlostop
     C                   eval      $slpuiitem = $slvloitem
     c                   if        virtualpick = 'V'
     C                   eval      $slpuislot = lbdisp
     c                   else
     C                   eval      $slpuislot = $slvlodisp
     c                   endif
     C                   eval      $slpuiuci = w6uci
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickuciin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpckuciout   = $prtnfields
     * Error Number 99 for 99TRAX
     C                   if        $slpuoerrnum <> 0
      /free
        if w6cnt2 = 1 and ufinfl = *on;
          if w6cnt1 = 1;
            w6cnt1 = w6cnt1 - 1;
          endif;
          leavesr;
        endif;
      /end-free
     C                   movel     $pbarcode     w88lbl
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C                   eval      errmsg = $slpuoerrtext
     C                   exsr      zm9898
     C                   goto      endck88
     C                   endif
     *
     C     endck88       endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZCHK89  Screen 89 error checking.
752vA*
752vAC     zzchk89       begsr
      /free
        error = *off;
      /end-free
     C                   endsr
500fA*----------------------------------------------------------------
500fA*
500fA*  ZZCKTN   Check for unfinished transactions.
500fA*
500fAC     zzcktn        begsr
500f C                   eval      error = *off
500fA
500fAC                   eval      $hdrcommand = 'chk4unfin'
500fAC                   time                    curtime
500fAC                   eval      $hdrtimestamp = %char(curtime)
500fAC                   eval      $slcuitman# = #job
500fAC                   eval      $pheader = $header
500fAC                   eval      $pfields = $slchk4ufin
500fAC                   exsr      writelog
500fAC                   call      'VOSELECT'
500fAC                   parm      '*none'       $pdqlib
500fAC                   parm      '*none'       $pdqnameout
500fAC                   parm      '*none'       $pdqkey
500fAC                   parm                    $pheader
500fAC                   parm                    $pfields
500fAC                   parm                    $prtnfields
500fAC                   eval      $slchk4ufout = $prtnfields
500fA*
500fAC                   if        $slcuoerrnum <> 0
500fAC                   eval      ufinfl = *on
500fAC                   else
500fAC                   eval      ufinfl = *off
500fAC                   endif
500fA
500f C     endcktn       endsr
ISPaA*
     *----------------------------------------------------------------
     *
     *  ZZCLOSE  Close Transaction
     *
ISPaAC     zzclose       begsr
ISPaAC                   eval      error = *off
ISPaA *
ISPaA *  Call close program
ISPaA *
ISPaAC                   clear                   $parms
ISPaAC                   eval      $pprg = #prog
ISPaAC                   eval      $ptype = '*BATCH  '
ISPaAC                   eval      $pcmd = '*CLOSE  '
ISPaAC                   eval      $prte = ptrtpo
ISPaAC                   eval      $ptrn# = pttrn#
ISPaAC                   eval      $pwhse = ptwhse
ISPaAC                   call      'PT132'
ISPaAC                   parm                    $parms
ISPaA *
ISPaA *     Error occured - Error message sent back
ISPaA *
ISPaAC                   if        $prtn = '*ERROR  '
ISPaAC                   eval      error = *on
ISPaAC                   movel     $perm         errmsg
ISPaAC                   exsr      zm0105
ISPaAC                   else
ISPaA *
ISPaA *     Error occured - Error message sent to program msgq
ISPaA *
ISPaAC                   if        $prtn = '*PGMQ   '
ISPaAC                   eval      error = *on
ISPaAC                   eval      #msgk = $pmsg
ISPaAC                   exsr      zmqmsg
ISPaAC                   endif
ISPaA *
ISPaAC                   endif
ISPaA *
ISPaA *  Close open selection Trans message.
ISPaA *
ISPaAC                   eval      $hdrcommand = 'close'
ISPaAC                   time                    curtime
ISPaAC                   eval      $hdrtimestamp = %char(curtime)
ISPaAC                   eval      $slclitman# = #job
ISPaAC                   eval      $pheader = $header
ISPaAC                   eval      $pfields = $slclosein
ISPaAC                   exsr      writelog
ISPaAC                   call      'VOSELECT'
ISPaAC                   parm      '*none'       $pdqlib
ISPaAC                   parm      '*none'       $pdqnameout
ISPaAC                   parm      '*none'       $pdqkey
ISPaAC                   parm                    $pheader
ISPaAC                   parm                    $pfields
ISPaAC                   parm                    $prtnfields
ISPaAC                   eval      $slcloseout = $prtnfields
ISPaA *
ISPaAC                   if        $slcloerrnum <> 0
ISPaAC                   eval      error = *on
ISPaAC                   eval      errmsg = $slcloerrtext
ISPaAC                   exsr      zm9898
ISPaAC                   else
ISPaAC                   eval      ufinfl= *off
ISPaAC                   endif
ISPaA *
ISPaA *  Check to see if all trans for route are done, if so export
ISPaA *
ISPbAC                   exsr      zzstat
ISPbA*
ISPbA*  Show export screen
ISPbDC***                eval      nxtscr = '09A'
ISPaA *
ISPaAC     endclose      endsr
ISPaA *
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
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
650aA*  Test for F9 - Suspend.
     *
650aAC                   if        *inki
650aAC                   eval      cmdtkn = *on
650aA * suspend
650aAC                   eval      $hdrcommand = 'suspend'
650aAC                   time                    curtime
650aAC                   eval      $hdrtimestamp = %char(curtime)
650aAC                   eval      $slssitman#  = #job
650aAC                   eval      $slssitrn#  = w1trn#
650aAC                   eval      $pheader = $header
650aAC                   eval      $pfields = $slsuspndin
650aAC                   exsr      writelog
650aAC                   call      'VOSELECT'
650aAC                   parm      '*none'       $pdqlib
650aAC                   parm      '*none'       $pdqnameout
650aAC                   parm      '*none'       $pdqkey
650aAC                   parm                    $pheader
650aAC                   parm                    $pfields
650aAC                   parm                    $prtnfields
650aAC                   eval      $slsuspndout = $prtnfields

650aAC                   if        $slssoerrnum <> 0
650aAC                   eval      error = *on
650aAC                   eval      *in22 = *on
650aAC                   eval      *in02 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      errmsg = $slssoerrtext
650aAC                   exsr      zm9898
650aAc                   else
750lAc                   exsr      zzreset
650aAC                   exsr      scr01i
650aAC                   endif
650aAC                   goto      endcm2
650aAC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
700aA*
700aA*  F8 - Override slot qty error, accept warning
700aA*
700aAC                   if        *inkh
700aAC                   move      *on           ovrrid
700aAC                   else
700aAC                   move      *off          ovrrid
700aAC                   endif
     *
     *  Test for F10 - Short
     *    Zero w6cnt1, 0 picked.
     *
     C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
     C                   eval      cmdtkn = *on
     C                   goto      endcm3
720dAc***  moved to zzupd16
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  eval      w6cnt1 = *zero
720dDC*                  exsr      zznxt
720dDc*                  eval      $newsl = ' '
     C                   endif
650aA*
650aA*  Test for F11 - Change Slot
650aA*   Override not taken
650aAC                   if        *inkk
700aAC                             and ovrrid = *off
650bAC                   if        oprfcs = 'Y'
650aAc                   eval      $slvsoerrnum = 0
650aAc                   dow       forevr = forevr
650aAC                   eval      cmdtkn = *on
650aA*    Display list of slots item occupies.
650aAc                   eval      $lcmd = '*CHGSLOT'
650aAC                   eval      $kwhse= w1whse
700fAc                   if        multitran
700fAc                   eval      $whdp = slwwhdp
700fAc                   else
650aAC                   eval      $whdp = lbwhdp
700fAc                   endif
650aAC                   eval      $pitem = $slvloitem
650aAc                   if        $slvsoerrnum = 47
650aAc                   else
650aAC                   eval      $newsl = *blanks
650aAc                   endif
650aAC                   eval      $lbl# = $slvlilbl#
740eDC*                  eval      $trn# = w1trn#
740eMC                   eval      $trn# = $SLVLOTRN#
650aAC                   eval      $bat# = 0
650aAC                   eval      $disp = w3disp
650aAC                   eval      $blkq = $slvlopickqty
650aAC                   eval      $oblkq = svqpck
650aAC                   eval      $task = pttask
650aAC                   eval      $prg = #prog
730wDC*                  call      'OR401'
740eAc                   if        lbtype = 'B'
752mDC**                 call      'OR681'
752mMC                   call      'OR401'
740eAC                   parm                    $lcmd
740eAC                   parm                    $prtky
740eAC                   parm      *blanks       $lrtn
740eAc                   else
740eAC                   call      'OR401'
650aAC                   parm                    $lcmd
650aAC                   parm                    $prtky
650aAC                   parm      *blanks       $lrtn
740eAc                   endif
650eAc                   if        $lrtn = '*CANCEL '
650eAc                   eval      $newsl = ' '
650eAc                   endif
650aAc                   if        $lrtn = '*OK'
650aA*    Get slot record.
650aA*
650aA*
650aAC                   eval      $hdrcommand = 'vfyslot'
650aAC                   time                    curtime
650aAC                   eval      $hdrtimestamp = %char(curtime)
650aAC                   eval      $slvslitman# = #job
650aAC                   eval      $slvslilbl# = $lbl#
650aAC                   eval      $slvslislot = $newsl
650aAc                   eval      $slvslitype = $actualslot
650aAC                   eval      $pheader = $header
650aAC                   eval      $pfields = $slvfysltin
650aAC                   exsr      writelog
650aAC                   call      'VOSELECT'
650aAC                   parm      '*none'       $pdqlib
650aAC                   parm      '*none'       $pdqnameout
650aAC                   parm      '*none'       $pdqkey
650aAC                   parm                    $pheader
650aAC                   parm                    $pfields
650aAC                   parm                    $prtnfields
650aAC                   eval      $slvfysltout = $prtnfields

700aAC                   select
700aDC*                  if        $slvsoerrnum = 47
700aMC                   when      $slvsoerrnum = 47
650aAc                   iter
700aDC*                  endif

700aAC                   when      $slvsoerrnum = 46
700aAC                   eval      warn = *on
700aAC                   eval      error = *on
700aAC                   eval      *in22 = *on
700aAC                   eval      *in02 = *on
700aAC                   eval      errmsg = *blanks
700aAC                   eval      errmsg = $slvsoerrtext
700aAC                   exsr      zm9898
700aAc*
700aDC*                  if        $slvsoerrnum <> 0
700aMC                   when      $slvsoerrnum <> 0
650aAC                   eval      error = *on
650aAC                   eval      *in22 = *on
650aAC                   eval      *in02 = *on
650aAC                   eval      errmsg = *blanks
650aAC                   eval      errmsg = $slvsoerrtext
650aAC                   exsr      zm9898
650aAc                   eval      $newsl = ' '
700aDC*                  else
700aMC                   other
650aAC                   eval      cmdtkn = *off
700aDC*                  endif
700aMC                   endsl

650aAc                   endif
650aAC                   goto      endcm3
650aAc                   enddo
650bAc                   else
650bAC                   eval      error = *on
650bAC                   eval      *in22 = *on
650bAC                   eval      *in02 = *on
650bAC                   eval      errmsg = *blanks
650bAC                   eval      errmsg = 'Function disabled'
650bAC                   exsr      zm9898
650bAc                   eval      $newsl = ' '
650bAC                   endif
650aAC                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD4   User defined command keys for screen 4.
     *
     C     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F9 - SKIP
     *
     C                   if        *inki
     C                   move      *on           cmdtkn
     C                   move      'SKPUPC '     sxerid
     C                   exsr      zzexcp
     C                   select
     *  If license options
     C                   when      oprflc = 'Y'
     C                   exsr      scr05i
650aAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
710aAc                             and $slvlopickqty > oprfqto
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
650aAC                   exsr      scr06ci
     *  Scan to pallet
     C                   other
     C                   exsr      scr06i
     C                   endsl
     C                   goto      endcm4
     C                   endif
     *
     *  Test for F10 - Short
     *    Zero w6cnt1, 0 picked
     *
     C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
     C                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  eval      w6cnt1 = *zero
720dDC*                  exsr      zznxt
     C                   goto      endcm4
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD5   User defined command keys for screen 5.
     *
     C     zzcmd5        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F9 - SKIP
     *
     C                   if        *inki
     C                   move      *on           cmdtkn
     C                   move      'SKPLCN '     sxerid
     C                   exsr      zzexcp
     *  Scan to pallet
700eAC                   Select
700eAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
710aAc                             and $slvlopickqty > oprfqto
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y      '
750kAc                   eval      combo = *on
750kAc                   endif
700eAC                   exsr      scr06ci
700eAC                   other
700eAC                   exsr      scr06i
700eAC                   endsl
     C                   goto      endcm5
     C                   endif
     *
     *  Test for F10 - Short
     *    Zero w6cnt1, 0 picked
     *
     C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
     C                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  eval      w6cnt1 = *zero
720dDC*                  exsr      zznxt
     C                   goto      endcm5
     C                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 6.
     *
     C     zzcmd6        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - Short
     *
     C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
     C                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
     C                   goto      endcm6
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6a  User defined command keys for screen 6a
     *
     C     zzcmd6a       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  Test for F10 - Short
     *
     C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
     C                   eval      cmdtkn = *on
720dDC*                  move      'SHORTM '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
     C                   goto      endcm6a
     C                   endif
     C                   endif
     *
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6a       endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZCMD6b  User defined command keys for screen 6b.
510a *
510a C     zzcmd6b       begsr
510a *
510a *  Command keys to check BEFORE verification and update.
510a *
510a C                   if        cmdchk = '*BEFORE '
720lA*
720lA*  Test for F2 - Bad/No Upc
720lA*
720lAC                   if        *inkb
720lAc                   eval      wherefrom = nxtscr
740eAc                   eval      w6upcd = ' '
720lAC                   exsr      scr20i
720lAC                   eval      cmdtkn = *on
720lAC                   goto      endcm6b
720lAC                   endif
510a *
510a *  Test for F10 - Short
510a *
510a C                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
510a C                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
510a C                   goto      endcm6b
510a C                   endif
510a C                   endif
510a *
510a *
510a *  Command keys to check AFTER verification and update.
510a *
510a C                   if        cmdchk = '*AFTER  '
510a C                   endif
510a C     endcm6b       endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZCMD6c  User defined command keys for screen 6c.
650aA*
650aAC     zzcmd6c       begsr
650aA*
650aA*  Command keys to check BEFORE verification and update.
650aA*
650aAC                   if        cmdchk = '*BEFORE '
650aA*
650aA*  Test for F10 - Short
650aA*
650aAC                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
650aAC                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
650aAC                   goto      endcm6c
650aAC                   endif
650aAC                   endif
650aA*
650aA*
650aA*  Command keys to check AFTER verification and update.
650aA*
650aAC                   if        cmdchk = '*AFTER  '
750kA*
750kA*  AUTOMATIC SHORTING
750kA*
750kAC                   if        *inkj
750kAc                   eval      wherefrom = nxtscr
750wA ** bypass auto short screen if oprfqtas and prime
750wAc                   if        oprfqtas = 'Y' and prime
750wAc                   eval      cshrt= 'Y'
750wAc                   eval      nxtscr = '16 '
750wAc                   exsr      zzupd16
750wAc                   else
750kAC                   exsr      scr16i
750wAc                   endif
750kAC                   eval      cmdtkn = *on
750kAC                   goto      endcm6c
750kAC                   endif
650aAC                   endif
650aAC     endcm6c       endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZCMD6d  User defined command keys for screen 6d.
650bA*
650bAC     zzcmd6d       begsr
650bA*
650bA*  Command keys to check BEFORE verification and update.
650bA*
650bAC                   if        cmdchk = '*BEFORE '
650bA*
650bA*  Test for F10 - Short
650bA*
650bAC                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
650bAC                   eval      cmdtkn = *on
720dDc*                  move      'SHORTS '     sxerid
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
650bAC                   goto      endcm6d
650bAC                   endif
650bAC                   endif
650bA*
650bA*
650bA*  Command keys to check AFTER verification and update.
650bA*
650bAC                   if        cmdchk = '*AFTER  '
650bAC                   endif
650bAC     endcm6d       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZCMD6e  User defined command keys for screen 6e.
730qA*
730qAC     zzcmd6e       begsr
730qA*
730qA*  Command keys to check BEFORE verification and update.
730qA*
730qAC                   if        cmdchk = '*BEFORE '
730qA*
730qA*  Test for F4  - Delete
730qA*
730qAC                   if        *inkd
730qAc                   eval      wherefrom = nxtscr
730qAC                   exsr      scr06fi
730qAC                   eval      cmdtkn = *on
730qAC                   goto      endcm6e
730qAC                   endif
730qA*
730qA*  Test for F6  - Done
730qA*
730qAC                   if        *inkf
730qAc                   eval      wherefrom = nxtscr
730qAC                   exsr      scr21i
730qAC                   eval      cmdtkn = *on
730qAC                   goto      endcm6e
730qAC                   endif
730qA*
730qA*  Test for F10 - Short
730qA*
730qAC                   if        *inkj
730qAc                   eval      wherefrom = nxtscr
730qAC                   exsr      scr16i
730qAC                   eval      cmdtkn = *on
730qAC                   goto      endcm6e
730qAC                   endif
730qAC                   endif
730qA*
730qA*
730qA*  Command keys to check AFTER verification and update.
730qA*
730qAC                   if        cmdchk = '*AFTER  '
730qAC                   endif
730qAC     endcm6e       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZCMD6f  User defined command keys for screen 6f.
730qA*
730qAC     zzcmd6f       begsr
730qA*
730qA*  Command keys to check BEFORE verification and update.
730qA*
730qAC                   if        cmdchk = '*BEFORE '
730qA*
730qA*  Test for F6  - Done
730qA*
730qAC                   if        *inkf
730qAc                   eval      wherefrom = nxtscr
730qAC                   exsr      scr21i
730qAC                   eval      cmdtkn = *on
730qAC                   goto      endcm6f
730qAC                   endif
730qA*
730qA*  Test for F10 - Short
730qA*
730qAC                   if        *inkj
730qAc                   eval      wherefrom = nxtscr
730qAC                   exsr      scr16i
730qAC                   eval      cmdtkn = *on
730qAC                   goto      endcm6f
730qAC                   endif
730qAC                   endif
730qA*
730qA*
730qA*  Command keys to check AFTER verification and update.
730qA*
730qAC                   if        cmdchk = '*AFTER  '
730qAC                   endif
730qAC     endcm6f       endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD7   User defined command keys for screen 7.
     *
     C     zzcmd7        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *  F8 - Override CW error, accept warning
     *
     C                   if        *inkh
     C                   move      *on           ovrrid
     C                   else
     C                   move      *off          ovrrid
     C                   endif
720hA*
720hA*  Test for F9  - Weigh Later
720hA*
720hAC                   if        *inki
720hAc                   eval      wherefrom = nxtscr
720hAC                   exsr      WeighLater
750pA /free
750pA    // If weighing later, then get ZPL for label
750pA    if nxtscr <> wherefrom;
750pA      if comboLabel or bulkLabel;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1:'');
750pA      else;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0:w2lbl: w6cnt1+1: w6cnt2:'');
750pA      endif;
750pA    endif;
750pA /end-free
720hAC                   eval      cmdtkn = *on
720hAC                   goto      endcm7
720hAC                   endif
520bA*
520bA*  Test for F10 - Short
520bA*
520bAC                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
520bAC                   eval      cmdtkn = *on
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  eval      w6cnt1 = w6cnt1-1
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
520bAC                   goto      endcm7
520bAC                   endif
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
750kA*
750kA*  AUTOMATIC SHORTING
750kA*
750kAC                   if        *inkj
750kAc                   eval      wherefrom = nxtscr
750wA ** bypass auto short screen if oprfqtas and prime
750wAc                   if        oprfqtas = 'Y' and prime
750wAc                   eval      cshrt= 'Y'
750wAc                   eval      nxtscr = '16 '
750wAc                   exsr      zzupd16
750wAc                   else
750kAC                   exsr      scr16i
750wAc                   endif
750kAC                   eval      cmdtkn = *on
750kAC                   goto      endcm7
750kAC                   endif
     C                   endif
     C     endcm7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD8   User defined command keys for screen 8.
     *
     C     zzcmd8        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD9   User defined command keys for screen 9.
     *
     C     zzcmd9        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm9        endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZCMD9a  User defined command keys for screen 9a.
ISPaA*
ISPaAC     zzcmd9a       begsr
ISPaA*
ISPaA*  Command keys to check BEFORE verification and update.
ISPaA*
ISPaAC                   if        cmdchk = '*BEFORE '
ISPaAC                   endif
ISPaA*
ISPaA*  Command keys to check AFTER verification and update.
ISPaA*
ISPaAC                   if        cmdchk = '*AFTER  '
ISPaAC                   endif
ISPaAC     endcm9a       endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  ZZCMD10  User defined command keys for screen 10.
500dA*
500dAC     zzcmd10       begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm10       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZCMD12  User defined command keys for screen 12.
700fA*
700fAC     zzcmd12       begsr
700fA*
700fA*  Command keys to check BEFORE verification and update.
700fA*
700fAC                   if        cmdchk = '*BEFORE '
720cA*
720cA*  Test for F9 - SKIP
720cA*
ADFbAc                   Select
ADFbAc                   when      client = AandDFoods
SUNaAc                   when      client = sunrise
PFCaAc***                when      client = prestofoods
ADFbAc                   other
720cAC                   if        *inki
720cAc                             and sslot = ' '
720cAC                   move      *on           cmdtkn
720cAC                   move      'SKPSLT '     sxerid
720cAC                   exsr      zzexcp
700fMC                   exsr      zzupd12
720cAc                   endif
ADFbAc                   Endsl
700fA*
700fA*  F20 - Override slot error, accept warning
700fA*
700fAC                   if        *inku
720cDC*                  eval      cmdtkn = *on
700fAC                   else
700fAC                   move      *off          ovrrid
700fAC                   endif
700fA*
700fA*  Test for F11 - Change Slot
700fA*   Override not taken
700fAC                   if        *inkk
700fAC                             and ovrrid = *off
700fAC                   eval      cmdtkn = *on
700fAC                   if        oprfcs = 'Y'
730wAc                             or AllowBulk = '1' and *in49 = *off
700fAc                   eval      $slvsoerrnum = 0
700fAc                   dow       forevr = forevr
700fA*    Display list of slots item occupies.
700fAc                   eval      $lcmd = '*CHGSLOT'
700fAC                   eval      $kwhse= w1whse
700fAC                   eval      $pitem = $slvloitem
700fAc                   if        $slvsoerrnum = 47
700fAc                   else
750fAc                   if        prime and spWhereFrom = 'OR401.01'
750fAc                   else
700fAC                   eval      $newsl = *blanks
750fAc                   endif
700fAc                   endif
700fAC                   eval      $lbl# = $slvlilbl#
740eDC*                  eval      $trn# = w1trn#
740eMC                   eval      $trn# = $SLVLOTRN#
700fAC                   eval      $bat# = 0
700fAc                   if        multitran
700fAC                   eval      $whdp = slwwhdp
700fAc                   eval      $disp = slwdisp
700fAc                   else
700fAC                   eval      $whdp = lbwhdp
700fAc                   eval      $disp = lbdisp
700fAc                   endif
700fAC                   eval      $blkq = $slvlopickqty
700fAC                   eval      $oblkq = svqpck
700fAC                   eval      $task = pttask
700fAC                   eval      $prg = #prog

750fA     // For Prime we would first call OR401 to create list,
750fA     // which gets sent back to fronend.
750fA     // Then, we go back to OR401 to process selected slot.

750fA /free
750fA     if prime;
750fA       if spWhereFrom <> 'OR401.01';
750fA         $lcmd = '*SPLIST';
750fA       else;
750fA         $lcmd = '*SPENTRY';
750fA       endif;
750fA     endif;
750fA /end-free

730wDC*                  call      'OR401'
740eAc                   if        lbtype = 'B'
752mDC**                 call      'OR681'
752mMC                   call      'OR401'
740eAC                   parm                    $lcmd
740eAC                   parm                    $prtky
740eAC                   parm      *blanks       $lrtn
750fAC                   parm                    pJsonStr
740eAc                   else
740eMC                   call      'OR401'
700fAC                   parm                    $lcmd
700fAC                   parm                    $prtky
700fAC                   parm      *blanks       $lrtn
750fAC                   parm                    pJsonStr
740eAc                   endif

750fA /free
750fA     // We're done if only getting list for Prime
750fA     if $lcmd = '*SPLIST';
750fA       nxtscr = '92 ';
750fA       leavesr;
750fA     endif;
750fA     // For Prime, see if user is canceling Task selection
750fA     // When not canceling, for $actualslot to 'Y'
750fA     // VOSELECT will always return an error when 'N'
750fA     // Normal OR401 also chokes when slot is manually entered.
750fA     if prime;
750fA       if  %subst(spF1F24Flags: 12: 1) = '1';
750fA         $lrtn = '*CANCEL';
750fA       else;
750fA         $actualslot = 'Y';
750fA         $lrtn = '*OK';
750fA       endif;
750fA     endif;
750fA /end-free

700fAc                   if        $lrtn = '*CANCEL '
700fAc                   eval      $newsl = ' '
700fAc                   endif

700fAc                   if        $lrtn = '*OK'
700fA*    Get slot record.
700fA*
700fA*
700fAC                   eval      $hdrcommand = 'vfyslot'
700fAC                   time                    curtime
700fAC                   eval      $hdrtimestamp = %char(curtime)
700fAC                   eval      $slvslitman# = #job
700fAC                   eval      $slvslilbl# = $lbl#
700fAC                   eval      $slvslislot = $newsl
700fAc                   eval      $slvslitype = $actualslot
700fAC                   eval      $pheader = $header
700fAC                   eval      $pfields = $slvfysltin
700fAC                   exsr      writelog
700fAC                   call      'VOSELECT'
700fAC                   parm      '*none'       $pdqlib
700fAC                   parm      '*none'       $pdqnameout
700fAC                   parm      '*none'       $pdqkey
700fAC                   parm                    $pheader
700fAC                   parm                    $pfields
700fAC                   parm                    $prtnfields
700fAC                   eval      $slvfysltout = $prtnfields
700fA
700fAC                   select
700fAC                   when      $slvsoerrnum = 47
700fAc                   iter
700fA
700fAC                   when      $slvsoerrnum = 46
700fAC                   eval      warn = *on
700fAC                   eval      error = *on
700fAC                   eval      *in22 = *on
700fAC                   eval      *in02 = *on
700fAC                   eval      errmsg = *blanks
700fAC                   eval      errmsg = $slvsoerrtext
700fAC                   exsr      zm9898
700fA
700aMC                   when      $slvsoerrnum <> 0
700fAC                   eval      error = *on
700fAC                   eval      *in22 = *on
700fAC                   eval      *in02 = *on
700fAC                   eval      errmsg = *blanks
700fAC                   eval      errmsg = $slvsoerrtext
700fAC                   exsr      zm9898
700fAc                   eval      $newsl = ' '
700fAC                   other
700fAC                   endsl
700fA
730wA * move up with in the $lrtn = '*OK'
730wAc                   eval      sldisp = $slvsoslt
730wAc                   eval      slwdisp= $slvsoslt
730wAc                   eval      lbdisp= $slvsoslt
730wAc                   eval      vsdisp= $slvsoslt
700fAc                   endif
730wDc*                  eval      sldisp = $slvsoslt
730wAc*                  eval      slwdisp= $slvsoslt
730wAc*                  eval      lbdisp= $slvsoslt
730wAc*                  eval      vsdisp= $slvsoslt
700fAc     slotky        chain     slotcw
700fAc                   if        %found
730wAc                   eval      sdisp = sldisp
750gAc                   eval      showdisp = sldisp
700fAc                   eval      aisle = slaisl
700fAc                   eval      loctn = slloc
700fAc                   eval      slevel = %char(slrlvl)
700fAc                   if        slhand <> *blanks
700fAc                   eval      slevel = %char(slrlvl)
700fAc                             +%trim(slhand)
700fAc                   endif
700fAc                   if        slrsrv = 'V'
700fAc     vslotky       chain     vslot1
700fAc                   if        %found
700fAc                   eval      sldisp = vspdis
700fAc                   eval      slwdisp= vspdis
700fAc                   eval      lbdisp=  vspdis
700fAc                   endif
700fAc                   endif
700fAc                   endif
730wAc                   exsr      zzgets
700fAC                   goto      endcm12
700fAc                   enddo
700fAc                   else
700fAC                   eval      error = *on
700fAC                   eval      *in22 = *on
700fAC                   eval      *in02 = *on
700fAC                   eval      errmsg = *blanks
700fAC                   eval      errmsg = 'Function disabled'
700fAC                   exsr      zm9898
700fAc                   eval      $newsl = ' '
700fAC                   endif
700fAC                   endif
700fAC                   endif
700hA*
700hA*  Test for F10 - Short
700hA*
700hAC                   if        *inkj
720dAc                   eval      wherefrom = nxtscr
720dAC                   exsr      scr16i
700hAC                   eval      cmdtkn = *on
700hAC                   goto      endcm12
720dA **** code moved to zzupd16
720dDC*                  move      'SHORTS '     sxerid
720dDC*                  eval      w6cnt1 = 0
720dDC*                  exsr      zzexcp
720dDC*                  exsr      zznxt
700hAC                   endif
700fA*
700fA*  Command keys to check AFTER verification and update.
700fA*
700fAC                   if        cmdchk = '*AFTER  '
700fAC                   endif
700fAC     endcm12       endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  ZZCMD12v User defined command keys for screen 12v
740eA*
740eAC     zzcmd12v      begsr
740eA*
740eA*  Command keys to check BEFORE verification and update.
740eA*
740eAC                   if        cmdchk = '*BEFORE '
740eA*
740eA*  Test for F9 - SKIP
740eA*
740eAC                   if        *inki
740eA /free
740eA   select;
740eA     when oprvsl = x;
740eA       sxerid = 'SKPSLT ';
740eA       if client = AandDFoods;
740eA         leavesr;
740eA       endif;
SUNaA       if client = sunrise;
SUNaA         leavesr;
SUNaA       endif;
PFCaA       //if client = prestofoods;
PFCaA         //leavesr;
PFCaA       //endif;
740eA     when oprvup = x;
740eA       sxerid = 'SKPLUPC';
740eA     when oprvcd = x;
740eA       sxerid = 'SKPCKDG';
740eA   endsl;
740eA   exsr zzexcp;
740eA   Select;
740eA     when oprvup = x and oprvup > oprvsl and oprvup > oprvcd;
740eA       cmdtkn = *off;
740eA       x = 4;
750dA     when oprvsl = x and oprvsl > oprvup and oprvsl > oprvcd;
750dA       cmdtkn = *off;
750dA       x = 4;
750dA     when oprvcd = x and oprvcd > oprvup and oprvcd > oprvsl;
750dA       cmdtkn = *off;
750dA       x = 4;
740eA     when x < 3;
740eA       cmdtkn = *on;
740eA       exsr scr12vi;
740eA     when i = 3;
740eA       cmdtkn = *off;
740eA       x = 4;
740eA   endsl;
740eA /end-free
740eAc                   endif
740eA*
740eA*  F20 - Override slot error, accept warning
740eA*
740eAC                   if        *inku
740eAC                   else
740eAC                   move      *off          ovrrid
740eAC                   endif
740eA*
740eA*  Test for F11 - Change Slot
740eA*   Override not taken
740eAC                   if        *inkk
740eAC                             and ovrrid = *off
740eAC                   eval      cmdtkn = *on
740eAC                   if        oprfcs = 'Y'
740eAc                             or AllowBulk = '1' and *in49 = *off
740eAc                   eval      $slvsoerrnum = 0
740eAc                   dow       forevr = forevr
740eA*    Display list of slots item occupies.
740eAc                   eval      $lcmd = '*CHGSLOT'
740eAC                   eval      $kwhse= w1whse
740eAC                   eval      $pitem = $slvloitem
740eAc                   if        $slvsoerrnum = 47
740eAc                   else
750fAc                   if        prime and spWhereFrom = 'OR401.01'
750fAc                   else
740eAC                   eval      $newsl = *blanks
750fAc                   endif
740eAc                   endif
740eAC                   eval      $lbl# = $slvlilbl#
740eAC                   eval      $trn# = $SLVLOTRN#
740eAC                   eval      $bat# = 0
740eAc                   if        multitran
740eAC                   eval      $whdp = slwwhdp
740eAc                   eval      $disp = slwdisp
740eAc                   else
740eAC                   eval      $whdp = lbwhdp
740eAc                   eval      $disp = lbdisp
740eAc                   endif
740eAC                   eval      $blkq = $slvlopickqty
740eAC                   eval      $oblkq = svqpck
740eAC                   eval      $task = pttask
740eAC                   eval      $prg = #prog

750fA     // For Prime we would first call OR401 to create list,
750fA     // which gets sent back to fronend.
750fA     // Then, we go back to OR401 to process selected slot.

750fA /free
750fA     if prime;
750fA       if spWhereFrom <> 'OR401.01';
750fA         $lcmd = '*SPLIST';
750fA       else;
750fA         $lcmd = '*SPENTRY';
750fA       endif;
750fA     endif;
750fA /end-free

740eAc                   if        lbtype = 'B'
752mDC**                 call      'OR681'
752mMC                   call      'OR401'
740eAC                   parm                    $lcmd
740eAC                   parm                    $prtky
740eAC                   parm      *blanks       $lrtn
750fAC                   parm                    pJsonStr
740eAc                   else
740eAC                   call      'OR401'
740eAC                   parm                    $lcmd
740eAC                   parm                    $prtky
740eAC                   parm      *blanks       $lrtn
750fAC                   parm                    pJsonStr
740eAc                   endif

750fA /free
750fA     // We're done if only getting list for Prime
750fA     if $lcmd = '*SPLIST';
750fA       nxtscr = '92 ';
750fA       leavesr;
750fA     endif;
750fA     // For Prime, see if user is canceling Task selection
750fA     // When not canceling, for $actualslot to 'Y'
750fA     // VOSELECT will always return an error when 'N'
750fA     // Normal OR401 also chokes when slot is manually entered.
750fA     if prime;
750fA       if  %subst(spF1F24Flags: 12: 1) = '1';
750fA         $lrtn = '*CANCEL';
750fA       else;
750fA         $actualslot = 'Y';
750fA         $lrtn = '*OK';
750fA       endif;
750fA     endif;
750fA /end-free

740eAc                   if        $lrtn = '*CANCEL '
740eAc                   eval      $newsl = ' '
740eAc                   endif

740eAc                   if        $lrtn = '*OK'
740eA*    Get slot record.
740eA*
740eA*
740eAC                   eval      $hdrcommand = 'vfyslot'
740eAC                   time                    curtime
740eAC                   eval      $hdrtimestamp = %char(curtime)
740eAC                   eval      $slvslitman# = #job
740eAC                   eval      $slvslilbl# = $lbl#
740eAC                   eval      $slvslislot = $newsl
740eAc                   eval      $slvslitype = $actualslot
740eAC                   eval      $pheader = $header
740eAC                   eval      $pfields = $slvfysltin
740eAC                   exsr      writelog
740eAC                   call      'VOSELECT'
740eAC                   parm      '*none'       $pdqlib
740eAC                   parm      '*none'       $pdqnameout
740eAC                   parm      '*none'       $pdqkey
740eAC                   parm                    $pheader
740eAC                   parm                    $pfields
740eAC                   parm                    $prtnfields
740eAC                   eval      $slvfysltout = $prtnfields
740eA
740eAC                   select
740eAC                   when      $slvsoerrnum = 47
740eAc                   iter
740eA
740eAC                   when      $slvsoerrnum = 46
740eAC                   eval      warn = *on
740eAC                   eval      error = *on
740eAC                   eval      *in22 = *on
740eAC                   eval      *in02 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slvsoerrtext
740eAC                   exsr      zm9898
740eA
740eAC                   when      $slvsoerrnum <> 0
740eAC                   eval      error = *on
740eAC                   eval      *in22 = *on
740eAC                   eval      *in02 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = $slvsoerrtext
740eAC                   exsr      zm9898
740eAc                   eval      $newsl = ' '
740eAC                   other
740eAC                   endsl
740eA
740eA * move up with in the $lrtn = '*OK'
740eAc                   eval      sldisp = $slvsoslt
740eAc                   eval      slwdisp= $slvsoslt
740eAc                   eval      lbdisp= $slvsoslt
740eAc                   eval      vsdisp= $slvsoslt
740eAc                   endif
740eAc     slotky        chain     slotcw
740eAc                   if        %found
740eAc                   eval      sdisp = sldisp
750gAc                   eval      showdisp = sldisp
740eAc                   eval      aisle = slaisl
740eAc                   eval      loctn = slloc
740eAc                   eval      slevel = %char(slrlvl)
740eAc                   if        slhand <> *blanks
740eAc                   eval      slevel = %char(slrlvl)
740eAc                             +%trim(slhand)
740eAc                   endif
740eAc                   if        slrsrv = 'V'
740eAc     vslotky       chain     vslot1
740eAc                   if        %found
740eAc                   eval      sldisp = vspdis
740eAc                   eval      slwdisp= vspdis
740eAc                   eval      lbdisp=  vspdis
740eAc                   endif
740eAc                   endif
740eAc                   endif
740eAc                   exsr      zzgets
740eAC                   goto      endcm12v
740eAc                   enddo
740eAc                   else
740eAC                   eval      error = *on
740eAC                   eval      *in22 = *on
740eAC                   eval      *in02 = *on
740eAC                   eval      errmsg = *blanks
740eAC                   eval      errmsg = 'Function disabled'
740eAC                   exsr      zm9898
740eAc                   eval      $newsl = ' '
740eAC                   endif
740eAC                   endif
740eA*
740eA*  Test for F10 - Short
740eA*
740eAC                   if        *inkj
740eAc                   eval      wherefrom = nxtscr
740eAC                   exsr      scr16i
740eAC                   eval      cmdtkn = *on
740eAC                   goto      endcm12v
740eAC                   endif
740eAC                   endif
740eA*
740eA*  Command keys to check AFTER verification and update.
740eA*
740eAC                   if        cmdchk = '*AFTER  '
740eAC                   endif
740eAC     endcm12v      endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZCMD15  User defined command keys for screen 15
720cA*
720cAC     zzcmd15       begsr
720cA*
720cA*  Command keys to check BEFORE verification and update.
720cA*
720cAC                   if        cmdchk = '*BEFORE '
720cAC                   endif
720cA*
720cA*  Command keys to check AFTER verification and update.
720cA*
720cAC                   if        cmdchk = '*AFTER  '
720cAC                   endif
720cAC     endcm15       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCMD17  User defined command keys for screen 17.
720hA*
720hAC     zzcmd17       begsr
720hA*
720hA*  Command keys to check BEFORE verification and update.
720hA*
720hAC                   if        cmdchk = '*BEFORE '
720hA*
720hA*  F8 - Override CW error, accept warning
720hA*
720hAC                   if        *inkh
720hAC                   move      *on           ovrrid
720hAC                   else
720hAC                   move      *off          ovrrid
720hAC                   endif
720hA*
720hA*  Test for F6  - done
720hA*
752gDC*                  if        *inkf
752gDc*                  eval      wherefrom = nxtscr
752gDC*                  eval      cmdtkn = *on
752gDC*                  goto      endcm17
752gDC*                  endif
720hA*
720hAC                   endif
720hA*
720hA*  Command keys to check AFTER verification and update.
720hA*
720hAC                   if        cmdchk = '*AFTER  '
720hAC                   endif
720hAC     endcm17       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCMD18  User defined command keys for screen 18.
720hA*
720hAC     zzcmd18       begsr
720hA*
720hA*  Command keys to check BEFORE verification and update.
720hA*
720hAC                   if        cmdchk = '*BEFORE '
720hA*
720hA*  Test for F8  - change label
720hA*
720hAC                   if        *inkh
720hAc                   eval      wherefrom = nxtscr
720hAC                   exsr      scr19i
720hAC                   eval      cmdtkn = *on
720hAC                   goto      endcm18
720hAC                   endif
720hAC                   endif
720hA*
720hA*
720hA*  Command keys to check AFTER verification and update.
720hA*
720hAC                   if        cmdchk = '*AFTER  '
720hAC                   endif
720hAC     endcm18       endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZCMD19  User defined command keys for screen 19.
720hA*
720hAC     zzcmd19       begsr
720hA*
720hA*  Command keys to check BEFORE verification and update.
720hA*
720hAC                   if        cmdchk = '*BEFORE '
720hAC                   endif
720hA*
720hA*
720hA*  Command keys to check AFTER verification and update.
720hA*
720hAC                   if        cmdchk = '*AFTER  '
720hAC                   endif
720hAC     endcm19       endsr
750lA*----------------------------------------------------------------
750lA*
750lA*  ZZCMD82  User defined command keys for screen 82
750lA*
750lAC     zzcmd82       begsr
750lA*
750la*  Command keys to check BEFORE verification and update.
750lA*
750lAC                   if        cmdchk = '*BEFORE '
750lAC                   endif
750lA*
750lA*  Command keys to check AFTER verification and update.
750lA*
750lAC                   if        cmdchk = '*AFTER  '
750lAC                   endif
750lAC     endcm82       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZUPD13  Update for screen 13.
700fA*
700fAC     zzupd13       begsr
700fA*
700fA*  If suspend = 'N' then return to previous screen else
700fA*  suspend transaction.
700fA*
740eDc*****              if        spnd = 'Y'
700fA * suspend
740eDC****               eval      $hdrcommand = 'suspend'
740eDC****               time                    curtime
740eDC****               eval      $hdrtimestamp = %char(curtime)
740eDC****               eval      $slssitman#  = #job
740eDC****               eval      $slssitrn#  = w1trn#
740eDC****               eval      $pheader = $header
740eDC****               eval      $pfields = $slsuspndin
740eDC****               exsr      writelog
740eDC****               call      'VOSELECT'
740eDC****               parm      '*none'       $pdqlib
740eDC****               parm      '*none'       $pdqnameout
740eDC****               parm      '*none'       $pdqkey
740eDC****               parm                    $pheader
740eDC****               parm                    $pfields
740eDC*****              parm                    $prtnfields
740eDC*****              eval      $slsuspndout = $prtnfields
700fA
740eDC*****              if        $slssoerrnum <> 0
740eDC*****              eval      error = *on
740eDC*****              eval      *in22 = *on
740eDC*****              eval      *in02 = *on
740eDC*****              eval      errmsg = *blanks
740eDC*****              eval      errmsg = $slssoerrtext
740eDC*****              exsr      zm9898
740eDc*****              else
740eDC*****              exsr      scr01i
740eDC*****              endif
740eDC*****              goto      endcm13
740eDC*****              endif
     *
700fAC     endcm13       endsr
     *----------------------------------------------------------------
     *
     *  ZZEXCP   Write exception record
     *
     C     zzexcp        begsr
     *
500bAC***                eval      sxesta = '4'
710dMC                   eval      sxesta = '1'
500bAC                   eval      sxwhse = w1whse
500bAC                   eval      sxtrn# = $slvlotrn#
500bAC                   eval      sxlbl# = $slvlolbl#
500bAC                   eval      sxitem = $slvloitem
500bAC                   time                    currstamp
500bAC                   eval      sxgdts = currstamp
500bAC                   eval      sxgemp = $emp#
500bAC                   eval      sxgby  = #user
500bAC                   eval      sxcusr = *blanks
500bAC                   eval      sxcdts = *loval
     *
500bAC                   write     sxrec
     C                   endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  ZZEXCPSUS   Write exception record leaving a suspended transaction
740dA*
740dAC     zzexcpsus     begsr
740dA*
740dAC                   eval      sxesta = '1'
740dAC                   eval      sxwhse = w1whse
740dAC                   eval      sxtrn# = pttrn#
740dAC                   eval      sxlbl# = 0
740dAC                   eval      sxitem = ' '
740dAC                   time                    currstamp
740dAC                   eval      sxgdts = currstamp
740dAC                   eval      sxgemp = $emp#
740dAC                   eval      sxgby  = #user
740dAC                   eval      sxcusr = *blanks
740dAC                   eval      sxcdts = *loval
740dAc                   eval      sxerid = 'SUSPEND'
740dA*
740dAC                   write     sxrec
740dAC                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZEXPORT   Export transactions
ISPaA*
ISPaAC     zzexport      begsr
ISPaA
ISPaA*    Set Inuse flag for pick/print processing.
ISPaA
ISPaAC                   eval      $ICMD = '*INUSE3 '
ISPaAC                   exsr      zziuse
ISPaAC                   if        stserr = *on
ISPaAC                   goto      endexport
ISPaAC                   endif
ISPaA
ISPaAC                   call      'PT645'
ISPaAC                   parm                    $PPRG
ISPaAC                   parm      $prtky        $PUKY
ISPaAC                   parm                    $PRTN
ISPaAC                   parm                    $PMSG
ISPaA
ISPaA*    Reset Inuse flag.
ISPaA
ISPaAC                   eval      $ICMD = '*CLEAR  '
ISPaAC                   exsr      zziuse
ISPaAC                   eval      nxtscr = 'EOJ'
ISPaA
ISPaAC     endexport     endsr
ISPaA
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
751lAC                   eval      w2trn = 0
750fAC                   eval      w2lbl = 0
     C                   eval      w1trn# = *zero
740lAc                   eval      olabel = *off
740eAc                   eval      x = 0
700fAC                   eval      aisle = *blanks
750lAC                   eval      showaisle = *blanks
700fAC                   eval      sslot = *blanks
700fAC                   eval      cdgt  = 0
700fAc                   eval      loctn = 0
720dAc                   eval      w1eod = 'N'
720dAc*** In61 control whether the field is displayed
720dAc***gja             if        opeqpj = 'Y'
720dAc                   eval      *in61 = *on
720dAc***gja             else
720dAc***gja             eval      *in61 = *off
720dAc***gja             endif
730vA /free
730vA   if usingp2p = *on;
730vA     p2plights ('*SET':$slsropjack:'Z':'':'0');
730vA   endif;
750xA   clear saveaisle;
750xA   clear saveloc;
750xA   clear savelvl;
750xA   clear savehand;
730vA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
750yA /free
750yA   savex = x;
750yA   savew2lbl#b = w2lbl#b;
750yA /end-free
     C                   z-add     0             w2lbl
640bAC                   eval      w2lbl#b = *blanks
750xA /free
750xA   clear saveaisle;
750xA   clear saveloc;
750xA   clear savelvl;
750xA   clear savehand;
750xA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
     *
     *  Initialize screen variables
     *
     C                   eval      w3disp = $slvlodisp
     C                   eval      w3scan = *blanks
700cAC                   eval      $slvsoloqavl = 0
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
     C                   eval      w4upcd = *blanks
510b C                   eval      savupc = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     C                   eval      w5lcns = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *
     C     zzfil6        begsr
     C                   if        first6 = *off
720dAc                   if        ufinfl = *on
720dA /free
720dA    exsr clr$uciinfo;
720eD    //$uiwhse = lbwhse;
720eD    //$uiitem = lbItem;
720eD    //$uisellbl# = lblbl#;
720dM    $uiwhse = w1whse;
720dM    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
720dA    $uirtntrn# = 0;
720dA
720dA    $dricommand = '*UCIINFO';
720dA    $drisubcmd  = '*CNT4UNF';
720dA    $drisys2upd = 'D';
720dA    exsr zzzdricop;
720dA    // message will have the count
720dA    w6cnt1 = %dec($drimessage:5:0);
730lA    if w6cnt1 > 0;
730lA /end-free
730lAc*  resetuci
730lAc                   eval      $hdrcommand = 'resetuci'
730lAc                   time                    curtime
730lAc                   eval      $hdrtimestamp = %char(curtime)
730lAc                   eval      $slruitman# = #job
730lAc                   eval      $slruitrn# = $slvlotrn#
730lAc                   eval      $slruilbl# = $slvlolbl#
730lAC                   eval      $slruiitem = $slvloitem
730lAC                   eval      $pheader = $header
730lAC                   eval      $pfields = $slresetuin
730lAC                   exsr      writelog
730lAC                   call      'VOSELECT'
730lAC                   parm      '*none'       $pdqlib
730lAC                   parm      '*none'       $pdqnameout
730lAC                   parm      '*none'       $pdqkey
730lAC                   parm                    $pheader
730lAC                   parm                    $pfields
730lAC                   parm                    $prtnfields
730lAC                   eval      $slresetuout   = $prtnfields
730lA* Error Number 99 for 99TRAX
730lAC                   if        $slruoerrnum =  0
730lAc                   eval      w6cnt1 = 0
730lAc                   endif
730lA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730lA    endif;
720dA /end-free
720dAc                   else
     C                   eval      w6cnt1 = *zero
720dAc                   endif
     C                   eval      w6cnt2 = $slvlopickqty
     C                   endif
     C                   eval      w6lbl  = *zero
640bAC                   eval      w6lbl#b  = *blanks
730pAc                   exsr      getuomdesc
730pDC*                  eval      w6uom    = $slvlouomdsc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6a  Fill screen 6a fields with info from file.
     *
     C     zzfil6a       begsr
740lA /free
740lA    if wktype = 'M'
752sA       or zonepickup;
752jM      sdisp = lbdisp;
752jM      showdisp = lbdisp;
752jD      //sdisp = ' ';
752jD      //showdisp = ' ';
740lA      w6stop = 0;
752jA  // Get Host Stop number
752jA
752jA  GetStop('*PLTSTP': lbwhse: lbrte: 0: lbstop: hostStop);
752jA  if hostStop <= 0;
752jA    w6stop = slwstop;
752jA  else;
752jA    w6Stop = hostStop;
752jA  endif;
740lA    endif;
740lA /end-free
     C                   if        first6a = *off
720dAc                   if        ufinfl = *on
720dA /free
720dA    exsr clr$uciinfo;
720eD    //$uiwhse = lbwhse;
720eD    //$uiitem = lbItem;
720eD    //$uisellbl# = lblbl#;
720dM    $uiwhse = w1whse;
720dM    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
720dA    $uirtntrn# = 0;
720dA
720dA    $dricommand = '*UCIINFO';
720dA    $drisubcmd  = '*CNT4UNF';
720dA    $drisys2upd = 'D';
720dA    exsr zzzdricop;
720dA    // message will have the count
720dA    w6acnt1 = %dec($drimessage:5:0);
730lA    if w6acnt1 > 0;
730lA /end-free
730lAc*  resetuci
730lAc                   eval      $hdrcommand = 'resetuci'
730lAc                   time                    curtime
730lAc                   eval      $hdrtimestamp = %char(curtime)
730lAc                   eval      $slruitman# = #job
730lAc                   eval      $slruitrn# = $slvlotrn#
730lAc                   eval      $slruilbl# = $slvlolbl#
730lAC                   eval      $slruiitem = $slvloitem
730lAC                   eval      $pheader = $header
730lAC                   eval      $pfields = $slresetuin
730lAC                   exsr      writelog
730lAC                   call      'VOSELECT'
730lAC                   parm      '*none'       $pdqlib
730lAC                   parm      '*none'       $pdqnameout
730lAC                   parm      '*none'       $pdqkey
730lAC                   parm                    $pheader
730lAC                   parm                    $pfields
730lAC                   parm                    $prtnfields
730lAC                   eval      $slresetuout   = $prtnfields
730lA* Error Number 99 for 99TRAX
730lAC                   if        $slruoerrnum =  0
730lAc                   eval      w6acnt1 = 0
730lAc                   endif
730lA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730lA    endif;
720dA /end-free
720dAc                   else
     C                   eval      w6acnt1 = *zero
720dAc                   endif
     C                   eval      w6acnt2 = $slvlopickqty
     C                   endif
     C                   eval      w6albl  = *zero
640bAC                   eval      w6albl#B  = *blanks
730pAc                   exsr      getuomdesc
730pDC*                  eval      w6uom    = $slvlouomdsc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
     C                   endsr
510a *----------------------------------------------------------------
510a *
510a *  ZZFIL6b  Fill screen 6b fields with info from file.
510a *
510a C     zzfil6b       begsr
510a C                   if        first6 = *off
720dAc                   if        ufinfl = *on
720dA /free
720dA    exsr clr$uciinfo;
720eD    //$uiwhse = lbwhse;
720eD    //$uiitem = lbItem;
720eD    //$uisellbl# = lblbl#;
720dM    $uiwhse = w1whse;
720dM    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740dM    $uiseltrn# = $SLVLOTRN#;
720dA    $uirtntrn# = 0;
720dA
720dA    $dricommand = '*UCIINFO';
720dA    $drisubcmd  = '*CNT4UNF';
720dA    $drisys2upd = 'D';
720dA    exsr zzzdricop;
720dA    // message will have the count
720dA    w6cnt1 = %dec($drimessage:5:0);
730lA    if w6cnt1 > 0;
730lA /end-free
730lAc*  resetuci
730lAc                   eval      $hdrcommand = 'resetuci'
730lAc                   time                    curtime
730lAc                   eval      $hdrtimestamp = %char(curtime)
730lAc                   eval      $slruitman# = #job
730lAc                   eval      $slruitrn# = $slvlotrn#
730lAc                   eval      $slruilbl# = $slvlolbl#
730lAC                   eval      $slruiitem = $slvloitem
730lAC                   eval      $pheader = $header
730lAC                   eval      $pfields = $slresetuin
730lAC                   exsr      writelog
730lAC                   call      'VOSELECT'
730lAC                   parm      '*none'       $pdqlib
730lAC                   parm      '*none'       $pdqnameout
730lAC                   parm      '*none'       $pdqkey
730lAC                   parm                    $pheader
730lAC                   parm                    $pfields
730lAC                   parm                    $prtnfields
730lAC                   eval      $slresetuout   = $prtnfields
730lA* Error Number 99 for 99TRAX
730lAC                   if        $slruoerrnum =  0
730lAc                   eval      w6cnt1 = 0
730lAc                   endif
730lA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730lA    endif;
720dA /end-free
720dAc                   else
     C                   eval      w6cnt1 = *zero
720dAc                   endif
510a C                   eval      w6cnt2 = $slvlopickqty
510a C                   endif
510a C                   eval      w6upcd = *blanks
730pAc                   exsr      getuomdesc
730pDC*                  eval      w6uom    = $slvlouomdsc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
     C                   endsr
650aA*----------------------------------------------------------------
650aA*
650aA*  ZZFIL6c  Fill screen 6c fields with info from file.
650aA*
650aAC     zzfil6c       begsr
650aAC                   if        first6 = *off
700aAC                   eval      w6aval = $slvsoloqavl
720dAc                   if        ufinfl = *on
720dA /free
720dA    exsr clr$uciinfo;
720eD    //$uiwhse = lbwhse;
720eD    //$uiitem = lbItem;
720eD    //$uisellbl# = lblbl#;
720dM    $uiwhse = w1whse;
720dM    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
720dA    $uirtntrn# = 0;
720dA
720dA    $dricommand = '*UCIINFO';
720dA    $drisubcmd  = '*CNT4UNF';
720dA    $drisys2upd = 'D';
720dA    exsr zzzdricop;
720dA    // message will have the count
720dA    w6cnt1 = %dec($drimessage:5:0);
730lA    if w6cnt1 > 0;
730lA /end-free
730lAc*  resetuci
730lAc                   eval      $hdrcommand = 'resetuci'
730lAc                   time                    curtime
730lAc                   eval      $hdrtimestamp = %char(curtime)
730lAc                   eval      $slruitman# = #job
730lAc                   eval      $slruitrn# = $slvlotrn#
730lAc                   eval      $slruilbl# = $slvlolbl#
730lAC                   eval      $slruiitem = $slvloitem
730lAC                   eval      $pheader = $header
730lAC                   eval      $pfields = $slresetuin
730lAC                   exsr      writelog
730lAC                   call      'VOSELECT'
730lAC                   parm      '*none'       $pdqlib
730lAC                   parm      '*none'       $pdqnameout
730lAC                   parm      '*none'       $pdqkey
730lAC                   parm                    $pheader
730lAC                   parm                    $pfields
730lAC                   parm                    $prtnfields
730lAC                   eval      $slresetuout   = $prtnfields
730lA* Error Number 99 for 99TRAX
730lAC                   if        $slruoerrnum =  0
730lAc                   eval      w6cnt1 = 0
730lAc                   endif
730lA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730lA    endif;
720dA /end-free
720dAc                   else
     C                   eval      w6cnt1 = *zero
720dAc                   endif
650aAC                   eval      w6cnt2 = $slvlopickqty
650aAC                   endif
650aAC                   eval      w6cnt1E = *zero
730pAc                   exsr      getuomdesc
730pDC*                  eval      w6uom    = $slvlouomdsc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
650aAC                   endsr
650bA*----------------------------------------------------------------
650bA*
650bA*  ZZFIL6d  Fill screen 6d fields with info from file.
650bA*
650bAC     zzfil6d       begsr
650bAC                   if        first6 = *off
720dAc                   if        ufinfl = *on
720dA /free
720dA    exsr clr$uciinfo;
720eD    //$uiwhse = lbwhse;
720eD    //$uiitem = lbItem;
720eD    //$uisellbl# = lblbl#;
720dM    $uiwhse = w1whse;
720dM    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
720dA    $uirtntrn# = 0;
720dA
720dA    $dricommand = '*UCIINFO';
720dA    $drisubcmd  = '*CNT4UNF';
720dA    $drisys2upd = 'D';
720dA    exsr zzzdricop;
720dA    // message will have the count
720dA    w6cnt1 = %dec($drimessage:5:0);
730lA    if w6cnt1 > 0;
730lA /end-free
730lAc*  resetuci
730lAc                   eval      $hdrcommand = 'resetuci'
730lAc                   time                    curtime
730lAc                   eval      $hdrtimestamp = %char(curtime)
730lAc                   eval      $slruitman# = #job
730lAc                   eval      $slruitrn# = $slvlotrn#
730lAc                   eval      $slruilbl# = $slvlolbl#
730lAC                   eval      $slruiitem = $slvloitem
730lAC                   eval      $pheader = $header
730lAC                   eval      $pfields = $slresetuin
730lAC                   exsr      writelog
730lAC                   call      'VOSELECT'
730lAC                   parm      '*none'       $pdqlib
730lAC                   parm      '*none'       $pdqnameout
730lAC                   parm      '*none'       $pdqkey
730lAC                   parm                    $pheader
730lAC                   parm                    $pfields
730lAC                   parm                    $prtnfields
730lAC                   eval      $slresetuout   = $prtnfields
730lA* Error Number 99 for 99TRAX
730lAC                   if        $slruoerrnum =  0
730lAc                   eval      w6cnt1 = 0
730lAc                   endif
730lA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730lA    endif;
720dA /end-free
720dAc                   else
     C                   eval      w6cnt1 = *zero
720dAc                   endif
650bAC                   eval      w6cnt2 = $slvlopickqty
650bAC                   endif
650bAC                   eval      w6uci   = ' '
730pAc                   exsr      getuomdesc
730pDC*                  eval      w6uom    = $slvlouomdsc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
650bAC                   endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZFIL6e  Fill screen 6e fields with info from file.
730qA*
730qAC     zzfil6e       begsr
730qAC                   if        first6 = *off
730qAc                   if        ufinfl = *on
730qA /free
730qA    exsr clr$uciinfo;
730qA    $uiwhse = w1whse;
730qA    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
730qA    $uirtntrn# = 0;
730qA
730qA    $dricommand = '*UCIINFO';
730qA    $drisubcmd  = '*CNT4UNF';
730qA    $drisys2upd = 'D';
730qA    exsr zzzdricop;
730qA    // message will have the count
730qA    w6cnt1 = %dec($drimessage:5:0);
730qA    if w6cnt1 > 0;
730qA /end-free
730qAc*  resetuci
730qAc                   eval      $hdrcommand = 'resetuci'
730qAc                   time                    curtime
730qAc                   eval      $hdrtimestamp = %char(curtime)
730qAc                   eval      $slruitman# = #job
730qAc                   eval      $slruitrn# = $slvlotrn#
730qAc                   eval      $slruilbl# = $slvlolbl#
730qAC                   eval      $slruiitem = $slvloitem
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slresetuin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slresetuout   = $prtnfields
730qA* Error Number 99 for 99TRAX
730qAC                   if        $slruoerrnum =  0
730qAc                   eval      w6cnt1 = 0
730qAc                   endif
730qA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730qA    endif;
730qA /end-free
730qAc                   else
730qAC                   eval      w6cnt1 = *zero
730qAC                   eval      w6wgt1 = *zero
730qAc                   endif
730qAC                   eval      w6cnt2 = 99999
730qAc*** temp hard code until I know where I will get weight
730qAC                   eval      w6wgt2 = Pick2lbs
730qAC                   endif
730qAC                   eval      w6uci   = ' '
730qAc                   exsr      getuomdesc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
730qAC                   endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZFIL6f  Fill screen 6f fields with info from file.
730qA*
730qAC     zzfil6f       begsr
730qAC                   if        first6 = *off
730qAc                   if        ufinfl = *on
730qA /free
730qA    exsr clr$uciinfo;
730qA    $uiwhse = w1whse;
730qA    $uisellbl# = w2lbl;
740eD    //$uiseltrn# = w1trn#;
740eM    $uiseltrn# = $SLVLOTRN#;
730qA    $uirtntrn# = 0;
730qA
730qA    $dricommand = '*UCIINFO';
730qA    $drisubcmd  = '*CNT4UNF';
730qA    $drisys2upd = 'D';
730qA    exsr zzzdricop;
730qA    // message will have the count
730qA    w6cnt1 = %dec($drimessage:5:0);
730qA    if w6cnt1 > 0;
730qA /end-free
730qAc*  resetuci
730qAc                   eval      $hdrcommand = 'resetuci'
730qAc                   time                    curtime
730qAc                   eval      $hdrtimestamp = %char(curtime)
730qAc                   eval      $slruitman# = #job
730qAc                   eval      $slruitrn# = $slvlotrn#
730qAc                   eval      $slruilbl# = $slvlolbl#
730qAC                   eval      $slruiitem = $slvloitem
730qAC                   eval      $pheader = $header
730qAC                   eval      $pfields = $slresetuin
730qAC                   exsr      writelog
730qAC                   call      'VOSELECT'
730qAC                   parm      '*none'       $pdqlib
730qAC                   parm      '*none'       $pdqnameout
730qAC                   parm      '*none'       $pdqkey
730qAC                   parm                    $pheader
730qAC                   parm                    $pfields
730qAC                   parm                    $prtnfields
730qAC                   eval      $slresetuout   = $prtnfields
730qA* Error Number 99 for 99TRAX
730qAC                   if        $slruoerrnum =  0
730qAc                   eval      w6cnt1 = 0
730qAc                   endif
730qA /free
751iA    else;
751iA      // resetcw if cw item
751iA      exsr zzresetcw;
730qA    endif;
730qA /end-free
730qAc                   else
730qAC                   eval      w6cnt1 = *zero
730qAC                   eval      w6wgt1 = *zero
730qAc                   endif
730qAC                   eval      w6cnt2 = 99999
730qAc*** temp hard code until I know where I will get weight
730qAC                   eval      w6wgt2 = Pick2lbs
730qAC                   endif
730qAC                   eval      w6uci   = ' '
730qAc                   exsr      getuomdesc
750gA /free
750gA   exsr fillpallet;
751rA   exsr getplidsec;
752tA   if Prime and opspssn = 'Y';
752tA     exsr getrecordSS;
752tA   endif;
750gA /end-free
730qAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *
     C     zzfil7        begsr
     C                   eval      w7cwgt = *blanks
     *
700dA /free
700dA    getimuom(w1whse: BegKilolbs: IMUom);
700dA    select;
700dA      when Begkilolbs = 'K';
700dA        KiloLbs = 'K';
700dA        eval *In31 = *off;
700dA        W7UM1  = IMUom;
700dA      other;
700dA        kiloLbs = 'P';
700dA        eval *In31 = *on;
700dA        W7UM1  = 'Lbs';
700dA    endsl;
730wD    //if w6cnt1 > 1;
752vM    if w6cnt1 > 1 and not combo
752vA                  and not zonepickup;
720nA      *in64 = '1';
720nA    else;
720nA      *in64 = '0';
720nA    endif;
700dA /end-free
740dA /free
740dA   if oprfui = 'Y' and oprfuw = 'Y'
740eA      and ($ifsltmth >='4' and $ifsltmth <='6');
740dA     cvtbar('*ALL': w6upcd:
740dA            $cbcod: $cbdec: $cbdsc: $cbpos: $cbtyp: $cbv1: $cbv2:
740eM            $cbrtn: $cberm: $cbven: $cvtdata: $cvtdata2: lbwhse:
740eA            kilolbs: lbitem);
740dA     $barcode = $cvtdata;
740dA     $barcode2 = $cvtdata2;
750tD     //if $bcPNtLbSent or $bcPNtKgSent;
750tM     if $bcPNtLbSent and $bcPntLb > 0
750tA        or $bcPNtKgSent and $bcPntkg > 0;
740dA         w7cwgt = w6upcd;
740dA     endif;
740dA   endif;
740dA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *
     C     zzfil8        begsr
740eDC*                  eval      w8trn# = w1trn#
740lAc                   if        olabel = *on
740lAc                   if        $slvlotrn# <> 0
740eMC                   eval      w8trn# = $SLVLOTRN#
740lAc                   else
740lAc                   eval      w8trn# = w1trn#
740lAc                   endif
740lAc                   else
740lAc                   eval      w8trn# = w1trn#
740lAc                   endif
700fAc     orkey         chain     ordh
700fAc                   if        not %found
700fAc                   eval      ohtype = ''
700fAc                   endif
ISPaAC                   if        client = isupply
700fAC                             and ohtype = 'W'
ISPbDC***                exsr      zzclose
ISPbAC                   eval      nxtscr = '09A'
ISPaAC                   endif
      /free
        if usingBeltPrt;
          for i = 1 to trncnt;

            // Get ZPL for SETSUM for transaction
752oD       //if OPSPPSS = 'E';
752oM       if OPSPPSS = 'E' and not trnlst(i).bulkFlag;
              GetLabelZPL('*GETFMT': trnlst(i).rtid: trnlst(i).trn: 0: 0: 0:
                          'SETSUM');
              if error;
                error = *off;
              endif;
            endif;
            // Get ZPL for pallet(s) for transaction
752oD       //if OPSPPLBL = 'Y';
752oM       if OPSPPLBL = 'Y' and not trnlst(i).bulkFlag;
              GetLabelZPL('*GETFMT': trnlst(i).rtid: trnlst(i).trn: 0: 0: 0:
                          'PALLET');
              if zplRtnCode <> '*OK';
                error = *off;
                errmsg = '';
              endif;
            endif;

          endfor;
        endif;
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL9   Fill screen 9 fields with info from file.
     *
     C     zzfil9        begsr
     C                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZFIL9a   Fill screen 9a fields with info from file.
ISPaA*
ISPaAC     zzfil9a       begsr
ISPaAC                   endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  ZZFIL10  Fill screen 10 fields with info from file.
500dA*
500dAC     zzfil10       begsr
     C                   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZFIL11  Fill screen 11 and 12 fields with info from file.
700fA*
700fAC     zzfil11       begsr
700fA
700fAc                   eval      sslot = *blanks
700fAc                   if        multitran
700fAc                   eval      aisle = slwaisl
700fAc                   eval      loctn = slwloc
700fAc**730e             eval      w6stop = slwstop
      /free
730eA  // Get Host Stop number
730eA
730eA  GetStop('*PLTSTP': slwwhse: slwrte: 0: slwstop: hostStop);
730eA  if hostStop <= 0;
730eA    w6stop = slwstop;
730eA  else;
730eA    w6Stop = hostStop;
730eA  endif;
      /end-free
700fAc                   eval      slevel = *blanks
700fAc                   if        slwhand <> *blanks
700fAc                   eval      slevel = %char(slwrlvl) +
700fAc                             %trim(slwhand)
700fAc                   else
700fAc                   EVAL      slevel = %char(slwrlvl)
700fAc                   end
740eDc*                  eval      sdisp = slwdisp
740eMc                   eval      sdisp = lbdisp
750gMc                   eval      showdisp = lbdisp
700iAc                   eval      $slvloitem = slwitem
700fAc                   else
700fAc                   eval      aisle = lbaisl
700fAc                   eval      loctn = lbloc
700fAc**730e             eval      w6stop = lbstop
      /free
730eA  // Get Host Stop number
730eA
730eA  GetStop('*ORDSTP': lbwhse: lbrte: lbord: lbstop: hostStop);
730eA  if hostStop <= 0;
730eA    w6stop = lbstop;
730eA  else;
730eA    w6Stop = hostStop;
730eA  endif;
      /end-free
700fAc                   eval      slevel = *blanks
700fAc                   if        lbhand <> *blanks
700fAc                   eval      slevel = %char(lbrlvl) +
700fAc                             %trim(lbhand)
700fAc                   else
700fAc                   EVAL      slevel = %char(lbrlvl)
700fAc                   end
720dAc                   eval      sdisp = lbdisp
750gAc                   eval      showdisp = lbdisp
700iAc                   eval      $slvloitem = lbitem
700fAc                   endif
700fAc
700fAc                   eval      *in45 = *on
700fAc                   exsr      zzgeti
730wAc                   if        ptsub = 'BULK'
730wAc                   eval      *in51 = *on
730wAc                   exsr      zzgets
730wAc                   else
730wAc                   eval      *in51 = *off
730wAc                   endif
700fAC                   endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  ZZFIL12v Fill screen 12v fields with info from file.
740eA*
740eAC     zzfil12v      begsr
740eA /free
752gA   DonewithWgt = *off;
740eA   slvfyval = ' ';
740eA   if x >= 3;
740eA     x = 0;
740eA   endif;
740eA   // What priority we are using for location verification
740eA   if x > 0;
740eA     i = x + 1;
740eA   else;
740eA     i = 1;
740eA   endif;
740eA   for  i TO 3;
740eA     select;
740eA       when oprvup = i;
740eA       // Don't check for upc existence if UPC is the last
740eA       // possible verification. We need to still display this screen
740eA       // 12v because it tells them the slot they
740eA       // should be picking from. They will need to log an
740eA       // exception, so we know they didn't verify they were at
740eA       // the correct slot.
740eA         upcyes = *off;
740eA         if oprvup > oprvsl and oprvup > oprvcd;
740eA           upcyes = *on;
740eA         else;
740eA           chain(n) (w1whse: $slvlotrn#: $slvlilbl#) label90;
740eA           if %found(label90);
740eA             chain (w1whse: $slvloitem: lbutyp: lbucod) upc5;
740eA             if %found(upc5);
740eA               upcyes = *on;
740eA             endif;
740eA           endif;
740eA         endif;
740eA         if upcyes = '0';
740eA           iter;
740eA         else;
740eA           slvfy = 'Scan UPC';
740eA           x = i;
740eA           leave;
740eA         endif;
740eA       when oprvsl = i;
740eA         slvfy = 'Scan Slot';
740eA         x = i;
740eA         leave;
740eA       when oprvcd = i;
740eA         slvfy = 'Scan Check Digit';
740eA         x = i;
740eA        leave;
740eA     endsl;
740eA   endfor;
750gA   exsr getuomdesc;
752jA   exsr fillpallet;
752jA   exsr getplidsec;
752gA   exsr Chk4weighbtn;
CBIbA   if client = Cheney;
CBIbA     exsr GetEvenOdd;
CBIbA   endif;
740eA
740eA /end-free
740eAC                   endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZFIL14  Fill screen 14 fields with info from file.
720cA*
720cAC     zzfil14       begsr
720cAC                   endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZFIL15  Fill screen 15 fields with info from file.
720cA*
720cAC     zzfil15       begsr
720cAc                   eval      mtrn = 'N'
720cAC                   endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  ZZFIL16  Fill screen 16 fields with info from file.
720dA*
720dAC     zzfil16       begsr
720dAc                   eval      cshrt= 'N'
720dAC                   endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZFIL17  Fill screen 17 fields with info from voselect return
720hA*
720hAC     zzfil17       begsr
720hAC                   eval      w7cwgt = *blanks
720hA*
720hA /free
720hA    getimuom(w1whse: BegKilolbs: IMUom);
720hA    select;
720hA      when Begkilolbs = 'K';
720hA        KiloLbs = 'K';
720hA        eval *In31 = *off;
720hA        W7UM1  = IMUom;
720hA      other;
720hA        kiloLbs = 'P';
720hA        eval *In31 = *on;
720hA        W7UM1  = 'Lbs';
720hA    endsl;
720hA    w17cnt1 = w18cnt1;
720hA    w17cnt2 = w18cnt2;
752gA    if w17cnt1 > 0 and not combo;
752gA      *in64 = '1';
752gA    else;
752gA      *in64 = '0';
752gA    endif;
720hA /end-free
720hAC                   endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZFIL18  Fill screen 18 fields with info from voselect return
720hA*
720hAC     zzfil18       begsr
720hAC                   if        first18 = *off
720hAC                   eval      w18cnt1 = *zero
720hAC                   eval      w18cnt2 = $slc2oqty
720hAC                   endif
720hAc                   eval      first18 = *on
720hAC                   eval      W18LBL#H = $slc2olbl#
720hAC                   eval      w18lbl#b  = *blanks
720hAc                   eval      w18oitem = %trim($slc2oitem) + ' ' +
720hAc                             %trim($slc2oitemdsc)
752gAc                   eval      w18stop = $SLC2STOP
720hAC                   endsr
720hA*----------------------------------------------------------------
720hA*
720hA*  ZZFIL19  Fill screen 19 fields with info from voselect return
720hA*
720hAC     zzfil19       begsr
720hAc                   eval      W19LBL#B = ' '
752gA /free
752gA   savex = 0;
752gA   savew2lbl#b = w2lbl#b;
752gA   clear saveaisle;
752gA   clear saveloc;
752gA   clear savelvl;
752gA   clear savehand;
752gA /end-free
720hAC                   endsr
720lA*----------------------------------------------------------------
720lA*
720lA*  ZZFIL20  Fill screen 20 fields with info from file.
720lA*
720lAC     zzfil20       begsr
720lAc                   eval      eupc = ' '
720lAC                   endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZFIL21  Fill screen 21 fields with info from file.
730qA*
730qAC     zzfil21       begsr
730qAc                   eval      cdone= 'N'
730qAC                   endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  ZZFIL22  Fill screen 22 fields with info from file.
740dA*
740dAC     zzfil22       begsr
740dAc                   eval      leavesus = 'N'
740dAc                   eval      w22trn = pttrn#
740dAC                   endsr
740lA*----------------------------------------------------------------
740lA*
740lA*  ZZFIL23  Fill screen 23 fields with info from file.
740lA*
740lAC     zzfil23       begsr
740lAc                   eval      zcmpl= 'N'
740lAC                   endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  ZZFIL81  Fill screen 81 fields with info from file.
750pA*
750pAC     zzfil81       begsr
      /free
        // Get last printer MAC address used by user

        deviceType = 'BLUPRT';
        GetEquipId(w1whse: #user: deviceType: printerId: equipMsg);
        if equipMsg <> '*OK' or printerId = 'NONE';
          printerId = '';
        endif;

        // Get Test label ZPL

        GetLabelZPL('*GETBLTTST': '': 0: 0: 0: 0: '');

      /end-free
     C                   endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  ZZFIL82  Fill screen 82 fields with info from file.
750pA*
750pAC     zzfil82       begsr
      /free
      /end-free
752vAC                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZFIL88  Fill screen 88 fields with info from file.
752vA*
752vAC     zzfil88       begsr
      /free
        exec sql select * into :mrgrec
             from SPmrgwrk
             where mgwhse = :lbwhse
               and mgjob  = :#job
               and mgscan = ' '
               fetch first 1 rows only;
        If sqlstt = sqlSuccess;
          // Pickup id is last 3 digits of Tran#
          pickupnum = %dec(%subst(%editc(mgtrn#:'X'):5:3):3:0);
          pickupnum1= %dec(%subst(%editc(mgtrn#:'X'):5:1):1:0);
          pickupnum2= %dec(%subst(%editc(mgtrn#:'X'):6:1):1:0);
          pickupnum3= %dec(%subst(%editc(mgtrn#:'X'):7:1):1:0);
          exec sql select count(*)
                 into :count
                 from spmrgwrk
                 where mgjob = :mgjob
                  and  mgtrn# = :mgtrn#
                  and  mgscan = ' ';
          if sqlstt = sqlSuccess;
            w88rpcs = count;
          else;
            w88rpcs = 0;
          endif;
        else;
          pickupnum = 000;
          pickupnum1= 0;
          pickupnum2= 0;
          pickupnum3= 0;
          w88rpcs = 0;
        endif;
        w88lbl = ' ';
      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZFIL89  Fill screen 89 fields with info from file.
752vA*
752vAC     zzfil89       begsr
      /free
      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET3   Get screen 3 info.
     *
     C     zzget3        begsr
     *
     C                   exsr      zzgeti
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCWGT   Calculate catch weight variance values.
     *
     C     zzcwgt        begsr
     *
     *  If verify catch weight = yes
     *   Calculate total expected catch weight,
     *   Calculate low/high ranges.
640aMC                   if        opwrnc = 'M' or
640aMC                             opwrnc = 'B'
640aDC*                  if        opwrnc = 'Y'
     C                   z-add     0             lwvar
     C                   z-add     0             hivar
     C                   z-add     0             lwrng
     C                   z-add     0             hirng
     C                   z-add     0             exwgt
     C                   z-add     0             ilvar
     C                   z-add     0             ihvar
     C                   z-add     0             ilrng
     C                   z-add     0             ihrng
     C*    lbqpck        mult      lbuwgt        exwgt
740cAc                   Select
740cDc*                  if        nxtscr = '17'
740cMc                   When      nxtscr = '17'
720jac                             and WLUserChoice = *on
720iAC     $slgwoqty     mult      $slgwouwgt    exwgt
740cAc                   When      nxtscr = '17'
740cAc                             and WLUserChoice = *off
740cAC     $slc2oqty     mult      $slc2ouwgt    exwgt
740cMc                   other
740cDc*                  else
     C     $slvlopickqty mult      $slvlouwgt    exwgt
740cMc                   endsl
740cDc*                  endif
     *   Iniz flag used to skip variance check if = *ON.
     C                   eval      lvskp = *off
     C                   eval      hvskp = *off
     *   Use item variance % if it exists.
     C     imkey         chain     itemmsc                            79
     C                   if        *in79 = *off
     C                   if        imrg1c <> 0
     C     imrg1c        div       100           prg1c
     C                   if        imrg1c = 99
     C                   eval      lvskp = *on
     C                   endif
     C                   endif
     *
     C                   if        imrg2c <> 0
     C     imrg2c        div       100           prg2c
     C                   if        imrg2c = 99
     C                   eval      hvskp = *on
     C                   endif
     C                   endif
     *
     C                   endif
     *
     C                   if        prg1c = 0
     C     oprg1c        div       100           prg1c
     C                   endif
     C                   if        prg2c = 0
     C     oprg2c        div       100           prg2c
     C                   endif
     *
     C                   if        prg1c > 0
     C     exwgt         mult      prg1c         lwvar
740cAc                   Select
740cDc*                  if        nxtscr = '17'
740cMc                   When      nxtscr = '17'
720jac                             and WLUserChoice = *on
720iAC     $slgwouwgt    mult      prg1c         ilvar
740cAc                   When      nxtscr = '17'
740cAc                             and WLUserChoice = *off
740cAC     $slc2ouwgt    mult      prg1c         ilvar
740cDc*                  else
740cMc                   other
     C     $slvlouwgt    mult      prg1c         ilvar
740cMc                   endsl
740cDc*                  endif
     C*    lbuwgt        mult      prg1c         ilvar
     C                   endif
     C     exwgt         sub       lwvar         lwrng
740cAc                   Select
740cDc*                  if        nxtscr = '17'
740cMc                   When      nxtscr = '17'
720jac                             and WLUserChoice = *on
720iAC     $slgwouwgt    sub       ilvar         ilrng
740cAc                   When      nxtscr = '17'
740cAc                             and WLUserChoice = *off
740cAC     $slc2ouwgt    sub       ilvar         ilrng
740cDc*                  else
740cMc                   other
     C     $slvlouwgt    sub       ilvar         ilrng
740cMc                   endsl
740cDc*                  endif
     C                   if        prg2c > 0
     C     exwgt         mult      prg2c         hivar
740cAc                   Select
740cDc*                  if        nxtscr = '17'
740cMc                   when      nxtscr = '17'
720jac                             and WLUserChoice = *on
720iAC     $slgwouwgt    mult      prg2c         ihvar
740cAc                   when      nxtscr = '17'
740cAc                             and WLUserChoice = *off
740cAC     $slc2ouwgt    mult      prg2c         ihvar
740cDc*                  else
740cMc                   other
     C     $slvlouwgt    mult      prg2c         ihvar
740cMc                   endsl
740cDc*                  endif
     C*    lbuwgt        mult      prg2c         ihvar
     C                   endif
     C     exwgt         add       hivar         hirng
740cAc                   Select
740cDc*                  if        nxtscr = '17'
740cMc                   when      nxtscr = '17'
720jac                             and WLUserChoice = *on
     C     $slgwouwgt    add       ihvar         ihrng
740cAc                   when      nxtscr = '17'
740cAc                             and WLUserChoice = *off
740cAC     $slc2ouwgt    add       ihvar         ihrng
740cDc*                  else
740cMc                   other
     C     $slvlouwgt    add       ihvar         ihrng
740cMc                   endsl
740cDc*                  endif
     *
700fDC*                  eval      wgt = ilrng
700fDc*                  exsr      zzcnvwgt
700fDc*                  eval      ilrng = wwgt
700fDC*                  eval      wgt = ihrng
700fDc*                  exsr      zzcnvwgt
700fDc*                  eval      ihrng = wwgt
700fAC                   if        KiloLbs = 'P'
700fAC                   Eval      *in31 = *on
700fAC                   else
700fAC                   Eval      *in31 = *off
700fAC                   endif
     *
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
     *
650bA * add dri to get data from itemfld
650bA /free
650bA   exsr clr$item;

650bA   $itWhse = w1whse;
650bA   $ititem = $slvloitem;

650bA   $dricommand = '*ITEM';
650bA   $drisubcmd  = '%GETALL';
650bA   $drisys2upd = 'D';
650bA   chk4err = *on;
650bA   zmflag  = *off;
650bA   exsr zzzdricop;
650bA   if error = *on;
650bA     $ifucicde = ' ';
650bA     $ifrcvmth = ' ';
650bA     $ifsltmth = ' ';
650bA   endif;

SVLsA   // If Saval Ven# 2545  Cat 08, force to UPC Pick
SVLsA
SVLsA   if client = saval and type = 'B10';
SVLsA     $ifsltmth = '4';
SVLsA   endif;

650bA /end-free
     C     keyit         chain     piritem                            79
     C                   if        *in79
     C                   eval      ittype = *blanks
     C                   eval      itdesc = *blanks
     C                   eval      itpdsc = *blanks
     C                   endif
     *
     C                   eval      itmdsc = *blanks
     C                   eval      $iitem = ititem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
730wAC                   eval      #scwgt = itcwgt
     C                   call      @fmtit
     C                   parm                    $iitem           15
     C                   parm                    $idesc           30
     C                   parm                    $ipdsc           15
     C                   parm                    $istr            70
     C                   eval      itmdsc = $istr
     C                   eval      woitem = itmdsc
     *
     *
     *
     C                   endsr
     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define flags
     *
     C                   eval      forevr = *off
     C                   eval      found = *off
     C                   eval      first = *off
     C                   eval      first2 = *off
     C                   eval      first6 = *off
     C                   eval      first6a = *off
720hAC                   eval      first18 = *off
720hAC                   eval      first19 = *off
720jAC                   eval      WLUserChoice = *off
     *
     *
     *  Define misc variables
     *
     C                   eval      ttllic = 0
710hAC                   eval      traxYN = 'N'
     *
     *  Define keys
     *
     *
     *     ITEMMSC file -
     *
     C     imkey         klist
     C                   kfld                    w1whse
     C                   kfld                    $slvloitem
     *     LICENSE file - Partial
     *
     C     likey         klist
     C                   kfld                    kywhse
     C                   kfld                    kylcns
     *
     *     LABEL7 file - Partial
     *
740eDC*    lbkey7        klist
740eDC*                  kfld                    w1trn#
700fA*
700fA*     LABEL32 file - Partial
700fA*
700fAC     lbkey32       klist
700fAC                   kfld                    slwemp#
700fA
700fA*  Define partial key for LABEL32 file.
700fA
700fAC     Keyl32        KList
700fAC                   Kfld                    w1whse
700fAC                   Kfld                    Wkrtid
700fAC                   kfld                    Wktype
700fAC                   Kfld                    w1trn#
700fA
700fA*  Define partial key for SKTLBL32 file.
700fA
700fAC     Keyl32w       KList
700fAC                   Kfld                    $Emp#
720cAC                   kfld                    Wktype
700fA*  Define partial key for MULTRAN file.
700fA
700fAC
700fAC     keymu         KLIST
700fAC                   KFLD                    $Emp#
700fAC                   KFLD                    kystat

     *
     *     PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    w1whse
     C                   kfld                    $slvloitem
700fA*
700fA*     ORDERH  file
700fA*
700fAC     orkey         klist
700fAC                   kfld                    w1whse
700fAC                   kfld                    lbord
     *
     *     OPTIONS file
     *
     C     opkey         klist
     C                   kfld                    w1whse
     C                   kfld                    ocode
     *
     C     opkeys        klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
     *  Define partial key for RTEHED file.
     *
ISPaAC     keyrh         klist
ISPaAC                   kfld                    kywhse
ISPaAC                   kfld                    $krtid
     *
     *  Define key for ORDH file.
     *
ISPaAC     keyoh         klist
ISPaAC                   kfld                    $kwhse
ISPaAC                   kfld                    $krtid
     *
     *  Define key for LABEL90
     *
710jAC     keyl90        klist
710jAC                   kfld                    w1whse
740eDC*                  kfld                    w1trn#
740eMC                   kfld                    $SLVLOTRN#
730sDC*                  kfld                    $slvloitem
730sAC                   kfld                    $slvlilbl#
     *
     *  Define partial key for LABEL90
     *
ISPaAC     l90key        klist
ISPaAC                   kfld                    kywhse
740eDC*                  kfld                    w1trn#
740eMC                   kfld                    $SLVLOTRN#
750lA* for getpltsum from pfmt
750lAC     lb90key       klist
750lAC                   kfld                    pswhse
750lAC                   kfld                    pstrn#
750lA* Item Link & Item Fields
750lAC     ilkey         klist
750lAC                   kfld                    lbwhse
750lAC                   kfld                    lbitem
750lA* Item Link-base item
750lAC     ilkey2        klist
750lAC                   kfld                    ilwhse
750lAC                   kfld                    ilitm2
750lA*  Define partial key for LABEL31 file.
750lA*
750lAC     keyl31        klist
750lAC                   kfld                    pswhse
750lAC                   kfld                    psrtid
750lAC                   kfld                    kyltyp
750lAC                   kfld                    psplid
750lA*  Define partial key for LABEL33 file.
750lA*
750lAC     keyl33        klist
750lAC                   kfld                    w1whse
750lAC                   kfld                    ptrtid
750lAC                   kfld                    w1trn#
     *
     *  Define partial key for main file (if needed).
     *
ISPaAC     partky        klist
ISPaAC                   kfld                    $kwhse
ISPaAC                   kfld                    $ktype
     C                   kfld                    kyrtpo
     *
     *  Define partial key for SLOTCW file (if needed).
     *
700fAC     slotky        klist
700fAC                   kfld                    sldisp
     *
     *  Define partial key for VSLOT1 file (if needed).
     *
700fAC     vslotky       klist
700fAC                   kfld                    w1whse
700fAC                   kfld                    $whdp
700fAC                   kfld                    vsdisp
     *
710jA*  Define key for UPC5 file.
     *
710jAC     upcky         klist
710jAC                   kfld                    w1whse
710jAC                   kfld                    $slvloitem
710jAC                   kfld                    lbutyp
710jAC                   kfld                    lbucod
     *
730wA*
730wA*  Define key for ORDC file.
730wA*

730wAC     Ockey         KList
730wAC                   Kfld                    Lbwhse
730wAC                   Kfld                    Lbord
730wAC                   Kfld                    Lbseq
730wAC                   Kfld                    Lbitem
730wAC                   Kfld                    Lblbl#

730wAC     OcNkey        Klist
730wAC                   Kfld                    Lbwhse
730wAC                   Kfld                    Lbord
730wAC                   Kfld                    Lbseq
730wAC                   Kfld                    Lbitem
730wAC                   Kfld                    Lblbl#
730wAC                   Kfld                    NewSeq
750lA*  Define partial key for PLTSTP1 file.
750lA*
750lAC     keyss1        klist
750lAC                   kfld                    pswhse
750lAC                   kfld                    psrtid
750lAC                   kfld                    psplid
750lAC                   kfld                    psrow
750lAC                   kfld                    pscol

     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
500dD**
500dD**Get User information.
500dD **
500dDC**                 call      'GETUSER'
500dDC**                 parm      #user         $code            10
500dDC**                 parm      0             $whse             3 0
500dDC**                 parm      0             $emp#             5 0
500dDC**                 parm      *blanks       $fnam            15
500dDC**                 parm      *blanks       $init             1
500dDC**                 parm      *blanks       $lnam            20
500dDC**                 parm      *blanks       $whdp             5
500dDC**                 parm      *blanks       $styp             1
500dDC**                 parm      *blanks       $shft             6
500dDC**                 parm      *blanks       $crew             6
500dDC**                 parm      0             $nhrs             3 1
500dDC**                 parm      *blanks       $rtn              8
500dD
500dDC**                 eval      w1whse = $whse
     C*                  eval      w1emp# = $emp#
     C*                  eval      w1whdp = $whdp
     C*                  eval      w1styp = $styp
     C*                  eval      w1shft = $shft
     C*                  eval      w1crew = $crew
500dD**
500dD**Fill r#header ds
500dDC**                 eval      $hdrcommand = 'signonrf'
500dDC**                 eval      $hdrfuncid  = 6
500dDC**                 move      #jobn         #job#
500dDC**                 eval      $hdrserial# = #job#
500dDC**                 eval      $hdrempl#   = $emp#
     C**                 time                    $hdrtimestamp
500dDC**                 time                    curtime
500dDC**                 eval      $hdrtimestamp = %char(curtime)
500dDC**                 eval      $glofuncpgm = 'VOSELECT'
500dDC**                 eval      $glousercode = #user
500dDC**                 eval      $glowhse = $whse
500dDC**                 eval      $glodept = *blanks
500dDC**                 eval      $hdripaddr = #job
500dDC**                 eval      $hdrportl = 0
500dDC**                 eval      $hdrportc = 0
500dDC**                 eval      $hdrjobname = #job
500dDC**                 move      #jobn         $hdrjobnumber
     C*                  eval      $hdrjobnumber = #jobn
500dDC**                 eval      $hdrjobuser = #user
500dDC**                 eval      $slsritman# = #job
500dDC**                 eval      $slsriuser = #user
500dDC**                 eval      $pheader = $header
500dDC**                 eval      $pfields = $slsignrfin
500dDC**                 call      'VOSELECT'
500dDC**                 parm      '*none'       $pdqlib
500dDC**                 parm      '*none'       $pdqnameout
500dDC**                 parm      '*none'       $pdqkey
500dDC**                 parm                    $pheader
500dDC**                 parm                    $pfields
500dDC**                 parm                    $prtnfields
500dDC**                 eval      $slsignrfout = $prtnfields
500dDC**                 if        $slsroerrnum <> 0
500dDC**                 eval      error = *on
500dDC**                 eval      nxtscr = 'EOJ'
500dDC**                 else
500dD**Check for unfinished selection trans for user.
500dD**Fill r#header ds
500dDC**                 eval      $hdrcommand = 'chk4unfin'
500dDC**                 time                    curtime
500dDC**                 eval      $hdrtimestamp = %char(curtime)
500dDC**                 eval      $slcuitman# = #job
500dDC**                 eval      $pheader = $header
500dDC**                 eval      $pfields = $slchk4ufin
500dDC**                 call      'VOSELECT'
500dDC**                 parm      '*none'       $pdqlib
500dDC**                 parm      '*none'       $pdqnameout
500dDC**                 parm      '*none'       $pdqkey
500dDC**                 parm                    $pheader
500dDC**                 parm                    $pfields
500dDC**                 parm                    $prtnfields
500dDC**                 eval      $slchk4ufout = $prtnfields
500dD**
500dDC**                 if        $slcuoerrnum <> 0
500dDC**                 eval      ufinfl = *on
500dDC**                 else
500dDC**                 eval      ufinfl = *off
500dDC**                 endif
500dDC**                 endif

     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
730uAC                   eval      currRoutine = 'zzinz2'
730uAC                   exsr      phpgmV1V2V3s
500dA
500dA* Get User information.
500dA
500dAC                   call      'GETUSER'
500dAC                   parm      #user         $code            10
500dAC                   parm      0             $whse             3 0
500dAC                   parm      0             $emp#             5 0
500dAC                   parm      *blanks       $fnam            15
500dAC                   parm      *blanks       $init             1
500dAC                   parm      *blanks       $lnam            20
500dAC                   parm      *blanks       $whdp             5
500dAC                   parm      *blanks       $styp             1
500dAC                   parm      *blanks       $shft             6
500dAC                   parm      *blanks       $crew             6
500dAC                   parm      0             $nhrs             3 1
500dAC                   parm      *blanks       $rtn              8
750pAC                   parm      *blanks       $bpu              1
500dA
500dAC                   if        $rtn = '*ERROR'
500dAC                   exsr      scr10i
500dAC                   goto      endinz2
500dAC                   endif
500dA
500dAC                   eval      w1whse = $whse
750pA /free
751cA   // See if we are testing printing with a printer
751cA   printTest = *off;
751cA   if ($bpu = 'Y') and prime;
751cA     printTest = *on;
751cA     deviceType = 'BLUPRT';
751cA     GetEquipId(w1whse: #user: deviceType: printerId: equipMsg);
751cA     if equipMsg <> '*OK' or printerId = 'NONE';
751cA       printerId = '';
751cA     endif;
751cA     if printerId = '11:11:11:11:11:11';
751cA       $bpu = 'P';
751cA     else;
751cA       $bpu = 'B';
751cA     endif;
751cA   endif;
751cA   // See if we are using a belt printer
750vA   if ($bpu = 'B' or $bpu = 'P') and prime;
750pA     usingBeltPrt = *on;
750vA     if $bpu = 'P';
750vA       usingPeelOff = *on;
750vA     else;
750vA       usingPeelOff = *off;
750vA     endif;
750pA     GetLabelZPL('*OPEN': '': 0: 0 :0 :0: '');
750pA   else;
750pA     usingBeltPrt = *off;
750pA   endif;
750pA /end-free
730mA**
730mA**  Get Slot Sequence with new Option and possible soft coding
730mA**
730mAc                   eval      gpscmd = '*ISSOFT'
     c                   monitor
730mAc                   call      'GETPSEQO'
730mAc                   parm                    gpscmd            8
730mAc                   parm                    $pwhse
730mAc                   parm      ' '           gpswhdp           5
730mAc                   parm      ' '           gpsdisp          12
730mAc                   parm      ' '           gpsSeqcd          1
730mAc                   parm      0             gpsSeq            5 0
730mAc                   parm      ' '           usrDFPICK         1
     c                   on-error
     c                   eval      usrDFPICK = 'N'
     c                   endmon
500dA
500dA* Fill r#header ds
500dA
720CAC     onagain       tag
500dAC                   eval      $hdrcommand = 'signonrf'
500dAC                   eval      $hdrfuncid  = 6
500dAC                   move      #jobn         #job#
500dAC                   eval      $hdrserial# = #job#
500dAC                   eval      $hdrempl#   = $emp#
500dAC**                 time                    $hdrtimestamp
500dAC                   time                    curtime
500dAC                   eval      $hdrtimestamp = %char(curtime)
500dAC                   eval      $glofuncpgm = 'VOSELECT'
500dAC                   eval      $glousercode = #user
500dAC                   eval      $glowhse = $whse
500dAC                   eval      $glodept = *blanks
500dAC                   eval      $hdripaddr = #job
500dAC                   eval      $hdrportl = 0
500dAC                   eval      $hdrportc = 0
500dAC                   eval      $hdrjobname = #job
500dAC                   move      #jobn         $hdrjobnumber
500dAC*                  eval      $hdrjobnumber = #jobn
500dAC                   eval      $hdrjobuser = #user
500dAC                   eval      $slsritman# = #job
500dAC                   eval      $slsriuser = #user
720dAc                   if        client = kohl
SWTbAc                             or client = swt
720dAc                   eval      opeqpj = 'Y'
720dAc                   eval      opeqpt = 'PJACK '
720dAc                   endif
720dAc                   if        opeqpj = 'Y'
720dAc                   eval      $slsriopeqpj = '1'
720dAc                   eval      $slsriopeqpt = opeqpt
720dAc                   endif
751nAc*   This prime code is to prevent calling EQ410 Check In/Out
751nAc                   if        prime
751nAc                   eval      opeqpj = 'N'
751nAc                   eval      $slsriopeqpj = '0'
751nAc                   endif
500dAC                   eval      $pheader = $header
500dAC                   eval      $pfields = $slsignrfin
500dAC                   exsr      writelog
500dAC                   call      'VOSELECT'
500dAC                   parm      '*none'       $pdqlib
500dAC                   parm      '*none'       $pdqnameout
500dAC                   parm      '*none'       $pdqkey
500dAC                   parm                    $pheader
500dAC                   parm                    $pfields
500dAC                   parm                    $prtnfields
500dAC                   eval      $slsignrfout = $prtnfields
730vA /free
730vA   if $slsropckmode = 'P2P';
730vA     usingP2P = *on;
730vA     p2plights ('*TEST':$slsropjack:'':'':'');
730vA   else;
730vA     usingP2P = *off;
730vA   endif;
730vA /end-free
720cAc                   if        $slsroerrnum = 17
720dAc                             or $slsroerrnum = 54
720cAc                   CALL      'EQ410CL'
720cAC                   goto      onagain
720cAc                   endif
500dAC                   if        $slsroerrnum <> 0
500dAC                   exsr      scr10i
500dAC                   goto      endinz2
 00dAC                   endif

     C                   eval      trndte = *zeros
     C                   eval      trntim = *zeros
     C                   eval      usestr = '*NO '
     C                   exsr      zzoptn

500f *  If unfinished selection trans for user, display sc9 with msg.
750lAc                   if        spWhereFrom <> 'OR400.01'
500f C                   exsr      zzcktn
xxxx c                   endif
500f *  Moved code to zzcktn to be executed each time before sc1.
     *  If unfinished selection trans for user, display sc9 with msg.
500dA
500dAC*                  eval      $hdrcommand = 'chk4unfin'
500dAC*                  time                    curtime
500dAC*                  eval      $hdrtimestamp = %char(curtime)
500dAC*                  eval      $slcuitman# = #job
500dAC*                  eval      $pheader = $header
500dAC*                  eval      $pfields = $slchk4ufin
500dAC*                  exsr      writelog
500dAC*                  call      'VOSELECT'
500dAC*                  parm      '*none'       $pdqlib
500dAC*                  parm      '*none'       $pdqnameout
500dAC*                  parm      '*none'       $pdqkey
500dAC*                  parm                    $pheader
500dAC*                  parm                    $pfields
 00dAC*                  parm                    $prtnfields
500dAC*                  eval      $slchk4ufout = $prtnfields
500dA*
500dAC*                  if        $slcuoerrnum <> 0
500dAC*                  eval      ufinfl = *on
500dAC*                  else
500dAC*                  eval      ufinfl = *off
500dAC*                  endif
500dA
720dDC*                  if        ufinfl = *on
720dDC*                  exsr      scr09i
720dDC*                  else
751uDc**                 exsr      zzreset
751uDC**                 exsr      scr01i
751uDC**                 if        usingBeltPrt
751uDC**                           and not printTest
751uDC**                 exsr      scr81i
751yDC**                 endif
750l  /free
750l    exsr zzreset;
751uA
751uA   select;
751uA     when usingBeltPrt and not printTest;
751uA       exsr scr81i;
752vA     when getJackCode and prime;
752vD     //when getJackCode;
751uA       nxtscr = '87';
751uA     other;
751uA       exsr scr01i;
751uA
751uA   endsl;
750l  /end-free
720dDC*                  endif
500dA
500dMC     endinz2       endsr
     *
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZIUSE   Set Inuse flag for route before proceeding.
ISPaA*
ISPaAC     zziuse        begsr
ISPaAC                   MOVE      *OFF          STSERR            1
ISPaA
ISPaAC                   CALL      'CHKIUSE'
ISPaAC                   PARM                    $ICMD             8
ISPaAC                   PARM      RHWHSE        $IWHSE            3 0
ISPaAC                   PARM      RHRTID        $IRTID            5
ISPaAC                   PARM      *BLANKS       $IRTN             8
ISPaA
ISPaAC                   select
ISPaAC                   when      $irtn = '*ERROR  '
ISPaAC                   eval      error = *on
ISPaAC                   exsr      ZM9908
ISPaAC                   endsl
ISPaA
ISPaAC                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZMORE   Check for more labels for transaction
     *
     C     zzmore        begsr
     C                   eval      morelb = 'N'
730tAc                   eval      combo = *off
730wAc                   eval      *in49 = save49
730wAc                   eval      *in62 = save62
730vA /free
730vA   if usingp2p = *on;
730vA     p2plights ('*SET':$slsropjack:'Z':'':'0');
730vA   endif;
730vA /end-free
     * Fill r#header ds
     C                   eval      $hdrcommand = 'chk4lbl'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slclbitman# = #job
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slchk4lbin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slchk4lbout = $prtnfields
     *
501jAC                   if        $slclboerrnum = 0
501jAC                   if        $slclbocount = 0
     C                   eval      morelb = 'N'
     C                   else
     C                   eval      morelb = 'Y'
     C                   endif
     C                   else
     C                   eval      error = *on
     C*                  eval      *in23 = *on
     C*                  eval      *in03 = *on
     C                   eval      errmsg = *blanks
     C                   eval      errmsg = $slclboerrtxt
     C                   exsr      zm9898
     C**                 goto      endck2
     C                   endif

     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZNXT    Update and get next screen
     *
     C     zznxt         begsr
     C**                 eval      morelb = 'N'
     *
     *  CODE TO DO UPDATE AND DETERMINE WHAT SCREEN TO DISPLAY.
     *  WILL BE CALLED FROM ZZUPD6, ZZUPD6B AND ZZUPD7 (CATCH WT).
     C                   select
752vAC*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
752vA*  Prime and Zonepickup done.
752vA*  Need to process all Merge labels with the pick command
752vAC*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
752vAc                   when       prime and zonepickup and
752vAc                              morepickup = *off
752vAc                   exsr      getspmrgsum
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720gA*  When weigh later is being processed.
720gA*  Need to get all weights.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720gAc                   when       w17cnt2 > w17cnt1
720gAc                             and nxtscr = '17 '
720gAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720hA*  When weigh later is being processed.
720hA*  all weights entered.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720hAc                   when       w17cnt2 = w17cnt1
720hAc                             and nxtscr = '17 '
720hAc                             and first19 = *on
720hAc                             and first18 = *off
720jAc                   eval      WLUserChoice = *off
720hAc                   eval      first19 = *off
720hAC                   exsr      zzmore
720hA*  If more labels exist for transaction #
720hAC                   if        morelb = 'Y'
720hAC                   if        oprfpm = '2'
752gAc                   if        savew2lbl#b <> ' '
752gAc                   if        oprvsl > 0
752gAc                             or oprvcd > 0
752gAc                             or oprvup > 0
752gAc                   exsr      zzresetl
752gAc                   exsr      scr12Vi
752gAc                   else
752gAc                   exsr      zzresetl
720hAc                   exsr      scr11i
752gAc                   endif
752gAc                   endif
720hAc                   else
720hAC                   exsr      scr02i
720hAc                   endif
720hAc                   endif
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720hA*  When weigh later is being processed.
720hA*  all weights entered.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720hAc                   when       w17cnt2 = w17cnt1
720hAc                             and nxtscr = '17 '
720hAc                             and first18 = *on
720hAc                   eval      first18 = *off
720hA*   Do we have weights that need to be entered.
720hA*   End transaction and start idle if all weights entered.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'complete2'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slc2itman# = #job
750bAc                   if        $slvlotrn# <> 0
720hAC                   eval      $slc2itrn# = $slvlotrn#
750bAc                   else
720hAC                   eval      $slc2itrn# = w1trn#
750bAc                   endif
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slcompl2in
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slcompl2out = $prtnfields
720hA*
720hAC                   if        $slc2oerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720iDC*                  eval      errmsg = $slc2oerrtext
720iMc                   eval      errmsg = 'Label ' +
720iAc                             %char($slc2olbl#) +
720iAc                             ' needs weights'
720hAC                   exsr      zm9898
720hAc                   exsr      scr18i
720hAC                   goto      endnxt
720hAC                   else
720hA
720hA*   Display SC8 transaction complete message.
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
720hAC                   exsr      scr08i
751uAC                   endif

720hAc                   endif
720hAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kA*  When combo and catch weight & oprfqtcw = 'Y' loop weights
750kA*  number of weights entered equal the qty they entered as pick
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kAc                   when      combo and w6cnt1e > w6cnt1
750kAc                             and oprfqtcw = 'Y'
750kAc                             and itcwgt = 'Y'
750kAc                             and nxtscr = '07 '
750kAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kA*  When combo and catch weight Presto qty entry weigts entered
750kA*  equal qty entry - we will force into shorting if qty entered
750kA*  is less than the pick qty.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kAc                   when      combo and w6cnt1e = w6cnt1
750kAc                             and w6cnt1e < w6cnt2
750kAc                             and oprfqtcw = 'Y'
750kAc                             and itcwgt = 'Y'
750kAc                             and nxtscr = '07 '
752gAc                             and *inki = *off
750kAc                   eval      *inkj = *on
750kAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720gA*  When combo and catch weight need to loop weight screen until
720gA*  number of weights entered equal the qty picked.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
720gAc                   when      combo and w6cnt2 > w6cnt1
720gAc                             and nxtscr = '07 '
752gAc                             and *inki = *off
720gAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kA*  When quantity entered, and oprfqtas (auto short when qty <
750kA*  qty to pick) coming from 06c, cause short
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
750kAc                   when      w6cnt2 > w6cnt1 and
750kAc                             oprfqtas = 'Y' and nxtscr = '06C'
750kAc                             and itcwgt <> 'Y'
750kAc                   eval      *inkj = *on
750kAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
751zA*  When quantity entered, and oprfqtas (auto short when qty <
751zA*  qty to pick) coming from 06c, cause short if getWgtFlag = off
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
751zAc                   when      w6cnt2 > w6cnt1 and
751zAc                             oprfqtas = 'Y' and nxtscr = '06C'
751zAc                             and itcwgt ='Y'
751zAc                             and getWgtFlag = *off
751zAc                   eval      *inkj = *on
751zAc                   leavesr
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
650aA*  if $newsl - then change slot processing = pickchg.
650aA*  All labels were scanned to pallet or F10 short
650aA*  w6cnt1 = picked,  w6cnt2 = ordered.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
650aAC                   when      w6cnt1 = w6cnt2 and $newsl <> ' '
740fAc                                             and oprfcs = 'Y'
650aAC                             or *inkj and $newsl <> ' '
740fAc                                      and oprfcs = 'Y'
650aAC                   eval      error = *off
650aA*  Record qty picked for item.
650aA* Fill r#header ds
650aAC                   eval      $hdrcommand = 'pickchg'
650aAC                   time                    curtime
650aAC                   eval      $hdrtimestamp = %char(curtime)
650aAC                   eval      $slpcitman# = #job
650aAC                   eval      $slpcitrn# = $slvlotrn#
650aAC                   eval      $slpcilbl# = $slvlolbl#
650aAC                   eval      $slpcistop = $slvlostop
650aAC                   eval      $slpciitem = $slvloitem
650aAC                   eval      $slpcislot = $slvlodisp
650aAC                   eval      $slpciqty = w6cnt1
650aAC                   eval      $slpcislotNew = $newsl
650aAC                   eval      $pheader = $header
650aAC                   eval      $pfields = $slpickchin
650aAC                   exsr      writelog
650aAC                   call      'VOSELECT'
650aAC                   parm      '*none'       $pdqlib
650aAC                   parm      '*none'       $pdqnameout
650aAC                   parm      '*none'       $pdqkey
650aAC                   parm                    $pheader
650aAC                   parm                    $pfields
650aAC                   parm                    $prtnfields
650aAC                   eval      $slpickchout = $prtnfields
     *
650aAC                   if        $slpcoflag <> '1'
650aAC                   eval      error = *on
650aAC                   eval      *in23 = *on
650aAC                   eval      *in03 = *on
650aAC                   eval      errmsg = 'Error occurred in VOSELECT'
650aAC                   exsr      zm9898
650aAC                   goto      endnxt
650aAC                   endif
650aAc                   eval      $newsl = ' '
     *
650aAC                   exsr      zzmore
650aA*  If more labels exist for transaction #
650aA*   Display SC2 to scan next label.
650aAC                   if        morelb = 'Y'
700fAC                   if        oprfpm = '2'
700fAc                   exsr      scr11i
700fAc                   else
650aAC                   exsr      scr02i
700fAc                   endif
650aAC                   else
720caC*  do we have any Zone Pickup
720cA /free
720cA   if OPRFZP  = 'Y' or
740lA      oprfzp = 'N' or
720cA      OPRFZP  = 'M';
720cA     zonepickup = *off;
720cA     slwemp# = $emp#;
720cA     wktype = 'M';
720cA     exsr chkmultitran;
720cA     select;
720cA       when multitran;
720cA         setll ($Emp#: 'M') sktlbl32c;
720ca       other;
740lA         if reccycle >= 2;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32x;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32d;
752sA             when client = ISupply;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32s;
752sA             when client = SGC;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32g;
752sA             when client = Westside;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32w;
752sA             when client = avalon;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32h;
752sA             other;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           endsl;
752sD           //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
740lA         else;
740eD         //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA             when client = ISupply;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA             when client = SGC;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA             when client = Westside;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA             when client = avalon;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA             other;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA           endsl;
752sD           //setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
740lA         endif;
720cA     endsl;
720cA     dow forevr = forevr;
720cA       select;
720cA         when multitran;
720cA           reade ($Emp#: 'M') sktlbl32c;
720cA           if %eof(sktlbl32c);
720cA             leave;
720cA           endif;
720ca         other;
740lA         if reccycle >= 2;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32x;
752sA               if %eof(label32x);
752sA                 leave;
752sA               endif;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32d;
752sA               if %eof(label32d);
752sA                 leave;
752sA               endif;
752sA             when client = ISupply;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32s;
752sA               if %eof(label32s);
752sA                 leave;
752sA               endif;
752sA             when client = SGC;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32g;
752sA               if %eof(label32g);
752sA                 leave;
752sA               endif;
752sA             when client = Westside;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32w;
752sA               if %eof(label32w);
752sA                 leave;
752sA               endif;
752sA             when client = avalon;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32h;
752sA               if %eof(label32h);
752sA                 leave;
752sA               endif;
752sA             other;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA               if %eof(label32c);
752sA                 leave;
752sA               endif;
752sA           endsl;
752sD           //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
740lA         else;
740eD           //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA               if %eof(label32x);
752sA                 leave;
752sA               endif;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA               if %eof(label32d);
752sA                 leave;
752sA               endif;
752sA             when client = ISupply;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA               if %eof(label32s);
752sA                 leave;
752sA               endif;
752sA             when client = SGC;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA               if %eof(label32g);
752sA                 leave;
752sA               endif;
752sA             when client = Westside;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA               if %eof(label32w);
752sA                 leave;
752sA               endif;
752sA             when client = avalon;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA               if %eof(label32h);
752sA                 leave;
752sA               endif;
752sA             other;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA               if %eof(label32c);
752sA                 leave;
752sA               endif;
752sA           endsl;
752sD           //reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
740lA         endif;
752sD           //if %eof(label32c);
752sD             //leave;
752sD           //endif;
720cA       endsl;
720cA       if lbvrfy <> ' ';
720cA         iter;
720cA       endif;
740gA
740ga       // Check RF Zone Pickup flag for label
740gA
740gA       monitor;
740gA         getzpckup (lbwhse: lbctr#: ozrfzp);
740gA         if ozrfzp = 'N';
740gA           iter;
740gA         endif;
740gA       on-error;
740gA       endmon;
740gA
720cA       zonepickup = *on;
720cA       first6a = *off;
720cA       first6 = *off;
720cA       leave;
720cA     enddo;
720cA     if zonepickup;
720cA      // slwemp# = $emp#;
720cA      // wktype = 'M';
720cA       exsr getlowlimit;
720cA /end-free
720cA*
720cA*  Verify label is for entered transaction and still open.
720cA*
720cA* Fill r#header ds
720cAc                   if        zonepickup
720cAC                   eval      $hdrcommand = 'vfylabelM'
720cAc                   else
730wAc                   if        ptsub = 'BULK' and AllowBulk = *on
730wAC                   eval      $hdrcommand = 'vfylabelB'
730wAc                   else
720cAC                   eval      $hdrcommand = 'vfylabel'
730wAc                   endif
720cAc                   endif
720cAC                   time                    curtime
720cAC                   eval      $hdrtimestamp = %char(curtime)
720cAC                   eval      $slvlitman# = #job
720cDC*                  movel     lblbl#        $pbarcode
720cMC                   eval      $pbarcode = %char(lblbl#)
720cAC                   exsr      zztraxlbl
720cAC                   move      *blanks       w2lbl#b
720cAC                   move      $plbl#        w2lbl#b
720cAC                   z-add     $plbl#        w2lbl
720cAC                   eval      $slvlilbl# = w2lbl
720cAC                   eval      $pheader = $header
720cAC                   eval      $pfields = $slvfylblin
720cAC                   exsr      writelog
720cAC                   call      'VOSELECT'
720cAC                   parm      '*none'       $pdqlib
720cAC                   parm      '*none'       $pdqnameout
720cAC                   parm      '*none'       $pdqkey
720cAC                   parm                    $pheader
720cAC                   parm                    $pfields
720cAC                   parm                    $prtnfields
720cAC                   eval      $slvfylblout = $prtnfields
     *
720cAC                   if        $slvloerrnum <> 0
720cAC                   eval      error = *on
720cAC                   else
730vA /free
730vA   if usingp2p = *on;
730vA     setll ($slvlotrn#) pltsum4;
730vA     dow forevr = forevr;
730vA       reade ($slvlotrn#) pltsum4;
730vA       if %eof(pltsum4);
730vA         leave;
730vA       endif;
730vA       if $slvlopal# > pspal#;
730vA         p2plights ('*SET':$slsropjack:'B':'B':'1');
730vA       else;
730vA         p2plights ('*SET':$slsropjack:'A':'B':'1');
730vA       endif;
730vA     enddo;
730vA   endif;
730vA /end-free
730qA /free
730qA
730qA  monitor;
730qA    umWhse = lbwhse;
730qA    umlabel('*GET': umRtnCode: umRtnMsg:
730qA            umWhse: lblbl#:
730qA            umFlexPickFlag:
730qA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730qA  on-error;
730qA    umRtnCode = '*ERROR';
730qA  endmon;
730qA
730qA  if umRtnCode = '*OK';
730qA    select;
730qA      when umFlexPickFlag = 'P2W';
730qA        pick2lbs = lbswgt;
730qA      when umFlexPickFlag = 'PAQ';
730qA    endsl;
730qA  endif;
730qA
730qA /end-free
720cAC                   endif
720cA /free
720cA       exsr zzgeti;
720cA       if firstzonepick = *on;
720cA         exsr scr14i;
720cA         firstzonepick = *off;
720cA       else;
720cA         if oprfzp = 'M';
720cA           exsr scr02i;
720c          else;
720cA           if oprfqt = 'Y' and itcwgt <> 'Y'
751dA              and not zonepickup
710aA              and $slvlopickqty > oprfqto;
650aA             exsr scr06ci;
720cA           else;
752vA             if prime;
752vA               exsr scr88i;
752vA             else;
720cA               exsr scr06ai;
752vA             endif;
720cA           endif;
720c          endif;
720cA       endif;
720cA     else;
720cA /end-free
720hA*   Do we have weights that need to be entered.
720hA*   End transaction and start idle if all weights entered.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'complete2'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slc2itman# = #job
750bAc                   if        $slvlotrn# <> 0
720hAC                   eval      $slc2itrn# = $slvlotrn#
750bAc                   else
720hAC                   eval      $slc2itrn# = w1trn#
750bAc                   endif
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slcompl2in
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slcompl2out = $prtnfields
720hA*
720hAC                   if        $slc2oerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720iDC*                  eval      errmsg = $slc2oerrtext
720iMc                   eval      errmsg = 'Label ' +
720iAc                             %char($slc2olbl#) +
720iAc                             ' needs weights'
720hAC                   exsr      zm9898
720hAc                   exsr      scr18i
720hAC                   goto      endnxt
720hAC                   endif
720hA
650aA*   Display SC8 transaction complete message.
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
650aAC                   exsr      scr08i
751uAC                   endif

720cAc                   endif
720cAc                   else
720hA*   Do we have weights that need to be entered.
720hA*   End transaction and start idle if all weights entered.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'complete2'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slc2itman# = #job
750bAc                   if        $slvlotrn# <> 0
720hAC                   eval      $slc2itrn# = $slvlotrn#
750bAc                   else
720hAC                   eval      $slc2itrn# = w1trn#
750bAc                   endif
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slcompl2in
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slcompl2out = $prtnfields
720hA*
720hAC                   if        $slc2oerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720iDC*                  eval      errmsg = $slc2oerrtext
720iMc                   eval      errmsg = 'Label ' +
720iAc                             %char($slc2olbl#) +
720iAc                             ' needs weights'
720hAC                   exsr      zm9898
720hAc                   exsr      scr18i
720hAC                   goto      endnxt
720hAC                   endif
720hA
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
720cAC                   exsr      scr08i
751uAC                   endif

720cAc                   endif
650aAC                   endif
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
650aA*   Not all labels scanned to pallet.
     *  All labels were scanned to pallet or F10 short
     *  w6cnt1 = picked,  w6cnt2 = ordered.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
     C                   when      w6cnt1 = w6cnt2  or
     C                             *inkj
730qAc                             or *inkf and umFlexPickFlag = 'P2W'
752gAc                             or *inki and w6cnt1 < w6cnt2
     C                   eval      error = *off
     *  Record qty picked for item.
     * Fill r#header ds
740lAc                   if        reccycle <> 2
     C                   eval      $hdrcommand = 'pick'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpkitman# = #job
     C                   eval      $slpkitrn# = $slvlotrn#
     C                   eval      $slpkilbl# = $slvlolbl#
     C**                 eval      $slpkilbl# = w2lbl
     C                   eval      $slpkistop = $slvlostop
     C                   eval      $slpkiitem = $slvloitem
     C                   eval      $slpkislot = $slvlodisp
     C                   eval      $slpkiqty = w6cnt1
750zA /free
750zA   Select;
750zA     when Prime;
750zA       $slpkmeth = 'SP';
750zA     other;
750zA       $slpkmeth = 'RF';
750zA   endsl;
750za /end-free
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slpickout = $prtnfields
     *
501jAC                   if        $slpkoflag <> '1'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
520bDC**                 eval      errmsg = *blanks
520bMC                   eval      errmsg = 'Error occurred in VOSELECT'
520bAC                   exsr      zm9898
     C                   goto      endnxt
     C                   endif
750lA /free
751pA   if zonepickup;
751pA     labeldone = %lookup(w2lbl : pcklst(*).pcklbl : 1);
751pA   else;
750lA     labeldone = %lookup($slvlolbl# : pcklst(*).pcklbl : 1);
751pA   endif;
750lA   if labeldone <> 0;
750lA     pcklst(labeldone).pckdone = 'Y';
750lA   endif;
750lA /end-free
740lAc                   endif
     *
     C                   exsr      zzmore
     *  If more labels exist for transaction #
     *   Display SC2 to scan next label.
     C                   if        morelb = 'Y'
700fAC                   if        oprfpm = '2'
700fAc                   exsr      scr11i
700fAc                   else
650aAC                   exsr      scr02i
700fAc                   endif
     C                   else
     *   Display SC8 transaction complete message.
720caC*  do we have any Zone Pickup
720cA /free
720cA   if OPRFZP  = 'Y' or
740lA      OPRFZP  = 'N' or
720cA      OPRFZP  = 'M';
720cA     zonepickup = *off;
720cA     slwemp# = $emp#;
720cA     wktype = 'M';
720cA     exsr chkmultitran;
720cA     select;
720cA       when multitran;
720cA         setll ($Emp#: 'M') sktlbl32c;
720ca       other;
740lA         if reccycle >= 2;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32x;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32d;
752sA             when client = ISupply;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32s;
752sA             when client = SGC;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32g;
752sA             when client = Westside;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32w;
752sA             when client = avalon;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32h;
752sA             other;
752sA               setll (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           endsl;
752sD           //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
740lA         else;
740eD         //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA             when client = ISupply;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA             when client = SGC;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA             when client = Westside;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA             when client = avalon;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA             other;
752sA               setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA           endsl;
752sD           //setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
740lA         endif;
720cA     endsl;
720cA     dow forevr = forevr;
720cA       select;
720cA         when multitran;
720cA           reade ($Emp#: 'M') sktlbl32c;
720cA           if %eof(sktlbl32c);
720cA             leave;
720cA           endif;
720ca         other;
740lA         if reccycle >= 2;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32x;
752sA               if %eof(label32x);
752sA                 leave;
752sA               endif;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32d;
752sA               if %eof(label32d);
752sA                 leave;
752sA               endif;
752sA             when client = ISupply;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32s;
752sA               if %eof(label32s);
752sA                 leave;
752sA               endif;
752sA             when client = SGC;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32g;
752sA               if %eof(label32g);
752sA                 leave;
752sA               endif;
752sA             when client = Westside;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32w;
752sA               if %eof(label32w);
752sA                 leave;
752sA               endif;
752sA             when client = avalon;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32h;
752sA               if %eof(label32h);
752sA                 leave;
752sA               endif;
752sA             other;
752sA               reade (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA               if %eof(label32c);
752sA                 leave;
752sA               endif;
752sA           endsl;
752sD           //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
740lA         else;
740eD           //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
752sA           select;
752sA             when client = cityline
752sA                  or client = harbor
752sA                  or client = greenleaf
752sA                  or client = Colony;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
752sA               if %eof(label32x);
752sA                 leave;
752sA               endif;
752sA             when client = cheney
752sA                  or client = ellenbee
752sA                  or client = royal
752sA                  or client = tpc
752sA                  or client = saval
752sA                  or client = palmer
752sA                  or client = frf
752sA                  or client = Getfresh
752sA                  or client = FoodPro
752sA                  or client = EI
752sA                  or client = WillFoods
752sA                  or client = Panos
752sA                  or client = Renzi
752sA                  or client = AandDFoods
752sA                  or client = Cotati
752sA                  or client = Merit
752sA                  or client = SWT
752sA                  or client = prestofoods
752sA                  or usrDFPICK='Y';
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
752sA               if %eof(label32d);
752sA                 leave;
752sA               endif;
752sA             when client = ISupply;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Coastl
752sA                  and psszon = 'REFB';
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
752sA               if %eof(label32i);
752sA                 leave;
752sA               endif;
752sA             when client = Accardi
752sA                  and (ptwhdp = 'REF  '
752sA                  or   ptwhdp = 'FRZ  ');
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
752sA               if %eof(label32s);
752sA                 leave;
752sA               endif;
752sA             when client = SGC;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
752sA               if %eof(label32g);
752sA                 leave;
752sA               endif;
752sA             when client = Westside;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
752sA               if %eof(label32w);
752sA                 leave;
752sA               endif;
752sA             when client = avalon;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
752sA               if %eof(label32h);
752sA                 leave;
752sA               endif;
752sA             other;
752sA               reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
752sA               if %eof(label32c);
752sA                 leave;
752sA               endif;
752sA           endsl;
752sD           //reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
740lA         endif;
752sD           //if %eof(label32c);
752sD             //leave;
752sD           //endif;
720cA       endsl;
720cA       if lbvrfy <> ' ';
720cA         iter;
720cA       endif;
740gA
740ga       // Check RF Zone Pickup flag for label
740gA
740gA       monitor;
740gA         getzpckup (lbwhse: lbctr#: ozrfzp);
740gA         if ozrfzp = 'N';
740gA           iter;
740gA         endif;
740gA       on-error;
740gA       endmon;
740gA
720cA       zonepickup = *on;
720cA       first6a = *off;
720cA       first6  = *off;
720cA       leave;
720cA     enddo;
720cA     if zonepickup;
720cA       slwemp# = $emp#;
720cA       wktype = 'M';
720cA       exsr getlowlimit;
720cA /end-free
720cA*
720cA*  Verify label is for entered transaction and still open.
720cA*
720cA* Fill r#header ds
720cAc                   if        zonepickup
720cAC                   eval      $hdrcommand = 'vfylabelM'
720cAc                   else
730wAc                   if        ptsub = 'BULK' and AllowBulk = *on
730waC                   eval      $hdrcommand = 'vfylabelB'
730wAc                   else
720cAC                   eval      $hdrcommand = 'vfylabel'
730wAc                   endif
720cAc                   endif
720cAC                   time                    curtime
720cAC                   eval      $hdrtimestamp = %char(curtime)
720cAC                   eval      $slvlitman# = #job
720cDC*                  movel     lblbl#        $pbarcode
720cMC                   eval      $pbarcode = %char(lblbl#)
720cAC                   exsr      zztraxlbl
720cAC                   move      *blanks       w2lbl#b
720cAC                   move      $plbl#        w2lbl#b
720cAC                   z-add     $plbl#        w2lbl
720cAC                   eval      $slvlilbl# = w2lbl
720cAC                   eval      $pheader = $header
720cAC                   eval      $pfields = $slvfylblin
720cAC                   exsr      writelog
720cAC                   call      'VOSELECT'
720cAC                   parm      '*none'       $pdqlib
720cAC                   parm      '*none'       $pdqnameout
720cAC                   parm      '*none'       $pdqkey
720cAC                   parm                    $pheader
720cAC                   parm                    $pfields
720cAC                   parm                    $prtnfields
720cAC                   eval      $slvfylblout = $prtnfields
720cA*
720cAC                   if        $slvloerrnum <> 0
720cAC                   eval      error = *on
720cAC                   else
730vA /free
730vA   if usingp2p = *on;
730vA     setll ($slvlotrn#) pltsum4;
730vA     dow forevr = forevr;
730vA       reade ($slvlotrn#) pltsum4;
730vA       if %eof(pltsum4);
730vA         leave;
730vA       endif;
730vA       if $slvlopal# > pspal#;
730vA         p2plights ('*SET':$slsropjack:'B':'B':'1');
730vA       else;
730vA         p2plights ('*SET':$slsropjack:'A':'B':'1');
730vA       endif;
730vA     enddo;
730vA   endif;
730vA /end-free
730qA /free
730qA
730qA  monitor;
730qA    umWhse = lbwhse;
730qA    umlabel('*GET': umRtnCode: umRtnMsg:
730qA            umWhse: lblbl#:
730qA            umFlexPickFlag:
730qA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730qA  on-error;
730qA    umRtnCode = '*ERROR';
730qA  endmon;
730qA
730qA  if umRtnCode = '*OK';
730qA    select;
730qA      when umFlexPickFlag = 'P2W';
730qA        pick2lbs = lbswgt;
730qA      when umFlexPickFlag = 'PAQ';
730qA    endsl;
730qA  endif;
730qA
730qA /end-free
720cAC                   endif
720cA /free
720cA       exsr zzgeti;
720cA       if firstzonepick = *on;
720cA         exsr scr14i;
720cA         firstzonepick = *off;
720cA       else;
720cA         if oprfzp = 'M';
720cA           exsr scr02i;
720c          else;
720cA           if oprfqt = 'Y' and itcwgt <> 'Y'
751dA              and not zonepickup
710aA              and $slvlopickqty > oprfqto;
650aA             exsr scr06ci;
720cA           else;
752vA             if prime;
752vA               exsr scr88i;
752vA             else;
720cA               exsr scr06ai;
752vA             endif;
720cA           endif;
720c          endif;
720cA       endif;
720cA     else;
720cA /end-free
720hac* do we need to get weigh later weights
720hA*   Do we have weights that need to be entered.
720hA*   End transaction and start idle if all weights entered.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'complete2'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slc2itman# = #job
750bAc                   if        $slvlotrn# <> 0
720hAC                   eval      $slc2itrn# = $slvlotrn#
750bAc                   else
720hAC                   eval      $slc2itrn# = w1trn#
750bAc                   endif
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slcompl2in
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slcompl2out = $prtnfields
720hA*
720hAC                   if        $slc2oerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720iDC*                  eval      errmsg = $slc2oerrtext
720iMc                   eval      errmsg = 'Label ' +
720iAc                             %char($slc2olbl#) +
720iAc                             ' needs weights'
720hAC                   exsr      zm9898
720hAc                   exsr      scr18i
720hAC                   goto      endnxt
720hAC                   endif
720hA
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
     C                   exsr      scr08i
751uAC                   endif

720cAC                   endif
720cAc                   else
720hac* do we need to get weigh later weights
720hA*   Do we have weights that need to be entered.
720hA*   End transaction and start idle if all weights entered.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'complete2'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slc2itman# = #job
750bAc                   if        $slvlotrn# <> 0
720hAC                   eval      $slc2itrn# = $slvlotrn#
750bAc                   else
720hAC                   eval      $slc2itrn# = w1trn#
750bAc                   endif
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slcompl2in
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slcompl2out = $prtnfields
720hA*
720hAC                   if        $slc2oerrnum <> 0
720hAC                   eval      error = *on
720hAC                   eval      *in23 = *on
720hAC                   eval      *in03 = *on
720iDC*                  eval      errmsg = $slc2oerrtext
720iMc                   eval      errmsg = 'Label ' +
720iAc                             %char($slc2olbl#) +
720iAc                             ' needs weights'
720hAC                   exsr      zm9898
720hAc                   exsr      scr18i
720hAC                   goto      endnxt
720hAC                   endif
720hA
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
720cAC                   exsr      scr08i
751uAC                   endif

720cAC                   endif
     C                   endif
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
     *   Not all labels scanned to pallet.
     C*  <<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>
     C                   other
     *   Display SC6 to scan next label.
500dDC**                 if        nxtscr = '10 '
650aDC*                  if        nxtscr = '06A'
650aAc                   select
650aMc                   when      nxtscr = '06A'
752vAc                   if        prime
752vAC                   exsr      scr88i
752vAc                   else
     C                   exsr      scr06ai
752vAc                   endif
650aAC                   when      nxtscr = '06C'
650aAC                   exsr      scr06ci
650bAC                   when      nxtscr = '06D'
650bAC                   exsr      scr06di
730qAC                   when      nxtscr = '06E'
730qAC                   exsr      scr06ei
730qAC                   when      nxtscr = '06F'
730qAC                   exsr      scr06fi
650aDC*                  else
510a C*                  if        nxtscr = '06B'
650aDC*                  if        savupc <> *blanks
650aMC*720c              when      savupc <> *blanks
700fAC*720c              if        oprfpm = '2'
700faC*720c              exsr      scr06i
700fAC*720c              else
510a C*720c              exsr      scr06bi
700fAc*720c              endif
720cAc** if we scan indivdual upc for order qty is now based on new
720cAc** field in genpick options
720cAC                   when      oprfui = 'Y' and oprfuc = 'Y'
740eAc                             and eupc <> '2' and w6cnt1 <> 0
740eAc                             and upcyes = *on
740eAc                             and ($ifsltmth >='4'and $ifsltmth <='6')
720cAC                   exsr      scr06bi
650aDC*                  else
750tAc                   when      oprfui = 'Y' and eupc = '2'
750tAc                             and usingBeltPrt
750tAc                   eval      eupc = ' '
750tAC                   exsr      scr06ci
720cAc                   when      $ifsltmth = '4'
720cAc                             and oprfui = 'Y'
720cAc                             or $ifsltmth = '5' and lbutyp <> 'N'
720cAc                             and oprfui = 'Y'
740aAc                             or $ifsltmth = '6' and lbutyp =  'N'
740aAc                             and oprfui = 'Y'
720cAC                   exsr      scr06bi
720hAc                   when      nxtscr = '17'
720hac                   exsr      scr18i
650aAc                   other
650aAC                   exsr      scr06i
650aDC*                  endif
650aMC                   endsl
650aDC*                  endif
     C                   endsl
     *
     *
     C     endnxt        endsr
     *----------------------------------------------------------------
     *
     *  ZZOPTN   Get options
     *
     C     zzoptn        begsr
720cA*
720cA*  GetVoiceOpt  Get voice options.
720cA*
720cAC                   Eval      ocode  = '*VOICE'
720cAC     OpKey         Chain     Options
720cAC                   if        %found
720cAC                   eval      opvdta = opdata
720cAC                   else
720cAC                   eval      opincp = 'Y'
720cAC                   eval      opcrtr = 'N'
720cAC                   eval      opuplv = 'N'
720cAC                   eval      opvmrg = 'N'
720cAC                   eval      opoutf = 'N'
720cAC                   eval      opfrpl = 'N'
720cAC                   eval      opvmlt = 'N'
720cAC                   eval      opvspn = 'N'
720cAC                   eval      opvspz = 'N'
720cAC                   eval      opvslw = 'N'
720cAC                   eval      opvcep = 'N'
720cAC                   eval      opvssn = 'N'
720cAC                   eval      opvcpz = 'N'
720cAC                   eval      opestp = 'N'
720cAC                   endif
     *
     *   Get General Picking options
     C                   eval      ocode = '*GENPICK'
     *
     C     opkey         chain     options                            79
     C                   if        *in79
     C                   eval      oprfuc = 'N'
     C                   eval      oprflc = 'N'
520c C                   eval      oprfsl = 'Y'
740eAc                   eval      oprvsl = 1
751uAc                   eval      oprplt = '4'
     C                   else
     C                   eval      opdat2 = opdata
     C                   endif
      /free
        if usingBeltPrt;
          oprfqtcw = 'Y';
          oprfqt = 'Y';
          oprfqto= 0;
751mD     //opsppba = 'A';
        endif;

751zA   getMrgWgt = *off;
CBIaA   if client = Cheney;
CBIaA     getMrgWgt = *on;
CBIaA   endif;
xxxxx   if #user = 'LYNNM';
xxxxx     getMrgWgt = *on;
xxxxx   endif;
751uA   usingBigPal = *off;
751uA   if prime and usingBeltPrt;
751uA     if oprplt = '2' or oprplt = '3';
751uA       usingBigPal = *on;
751uA     endif;
751uA   endif;
      /end-free

      *  *** Temporarily force screen 82 to display ***
750lAc***                eval      opSPps   = 'Y'

PFCaAc***                if        client  = prestofoods
PFCaAc***                eval      oprfqtcw = 'Y'
PFCaAc***                eval      oprfqtas = 'Y'
750oAc***                eval      oprfsssv = 'Y'
PFCaAc***                endif
750lAc***                if        client  = cheney
CBIxAc***                eval      oprfqtcw = 'Y'
CBIxAc***                eval      oprfqtas = 'Y'
750lAc***                endif
720dAC                   if        oprfcs = 'Y'
720dAc                   eval      *in49 = *off
720daC                   else
720dAc                   eval      *in49 = *on
720dAc                   endif
720hAC                   if        oprfpm = '2'
720hAc                   eval      *in62 = *on
750gAc                   eval      save62 = *on
720haC                   else
720hAc                   eval      *in62 = *off
720hAc                   endif
     *
     *
     *   Get catch wt options.
     C                   eval      wkcode = '*SYSTEM '
     C                   eval      wkwhse = 0
     *
     C     opkeys        chain     options                            79
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   eval      opicw  = 'N'
751oAC                   eval      optrna = 'N'
     C                   else
     C                   eval      opdat3 = opdata
     C                   endif
751oAC                   if        optrna = 'Y'
751oAC                   eval      usingAutoAssign = *on
752lAC                   eval      getJackCode = *on
751oAC                   else
751oAC                   eval      usingAutoAssign = *off
752lAC                   eval      getJackCode = *off
751oAC                   endif
     C*
     C                   endsr
750lA*----------------------------------------------------------------
750lA*
750lA*  ZZRESET  Reset pallet summary, stop summary, pick list
750lA*
750lAC     zzreset       begsr
750lA /free
750lA   palcnt = 0;
750lA   stpcnt = 0;
750lA   pckcnt = 0;
750qA   trncnt = 0;
750la   clear pcklst;
750la   clear palsum;
750la   clear stpsum;
750qa   clear trnlst;
751xD   // See if we need to undo auto assigned transaction
751xD
751xD   //if usingAutoAssign;
751xD   //  if prime and usingBeltPrt;
751xD   //    monitor;
751xD   //      GetDMDSel('*UNDO': w1whse: #curruser: w1trn#:
751xD   //                 dmdCode: dmdMsg);
751xD   //      if dmdCode <> '*OK';
751xD   //      endif;
751xD   //    on-error;
751xD   //    endmon;
751xD   //  endif;
751xD   //endif;
750lA /end-free
750lAC                   endsr
760aA*----------------------------------------------------------------
760aA*
760aA*  ZZRESETAUTO   Reset auto assignment fields for GETDMDSEL
760aA*
760aAC     zzresetauto   begsr
760aA /free

760aA   if pjtype >= '1' and pjtype <= '3';
760aA     pjtype# = %dec(%subst(pjtype:1:1):1:0);
760aA   endif;
760AA   dmdrte = ' ';
760aA   dmdzone = ' ';

760aA /end-free
760aAC                   endsr
751iA*----------------------------------------------------------------
751iA*
751iA*  ZZRESETCW Reset Catch weights
751iA*
751iAC     zzresetcw     begsr
751iAc                   if        itcwgt = 'Y'
751iAc                   eval      $hdrcommand = 'resetcw'
751iAc                   time                    curtime
751iAc                   eval      $hdrtimestamp = %char(curtime)
751iAc                   eval      $slrwitman# = #job
751iAc                   eval      $slrwitrn# = $slvlotrn#
751iAc                   eval      $slrwilbl# = $slvlolbl#
751iAC                   eval      $slrwiitem = $slvloitem
751iAC                   eval      $pheader = $header
751iAC                   eval      $pfields = $slresetwin
751iAC                   exsr      writelog
751iAC                   call      'VOSELECT'
751iAC                   parm      '*none'       $pdqlib
751iAC                   parm      '*none'       $pdqnameout
751iAC                   parm      '*none'       $pdqkey
751iAC                   parm                    $pheader
751iAC                   parm                    $pfields
751iAC                   parm                    $prtnfields
751iAC                   eval      $slresetwout   = $prtnfields
751iAC                   if        $slrwoerrnum =  0
751iAc                   eval      w6cnt1 = 0
751iAc                   endif
751iAc                   endif
751iAC                   endsr
750yA*----------------------------------------------------------------
750yA*
750yA*  ZZRESETL Reset label back to the label we were working on
750yA*
750yAC     zzresetl      begsr
750yA /free
750yA     // reset back to the original label we were picking
750yA     // when selecting a label already picked, all the values from
750yA     // vfylabel - need to be reset to the correct label
750yA     w2lbl#b = savew2lbl#b;
750yA     x = savex;
750yA     // reset vfylabel
750yA /end-free
750yAc                   if        zonepickup
750yAC                   eval      $hdrcommand = 'vfylabelM'
750yAc                   else
750yAc                   if        ptsub = 'BULK' and AllowBulk = *on
750yAC                   eval      $hdrcommand = 'vfylabelB'
750yAc                   else
750yAC                   eval      $hdrcommand = 'vfylabel'
750yAc                   endif
750yAc                   endif
750yAC                   time                    curtime
750yAC                   eval      $hdrtimestamp = %char(curtime)
750yAC                   eval      $slvlitman# = #job
750yAC                   eval      $pbarcode = w2lbl#b
750yAC                   exsr      zztraxlbl
750yAC                   move      *blanks       w2lbl#b
750yAC                   move      $plbl#        w2lbl#b
750yAC                   z-add     $plbl#        w2lbl
750yAC                   eval      $slvlilbl# = w2lbl
750yAC                   eval      $pheader = $header
750yAC                   eval      $pfields = $slvfylblin
750yAC                   exsr      writelog
750yAC                   call      'VOSELECT'
750yAC                   parm      '*none'       $pdqlib
750yAC                   parm      '*none'       $pdqnameout
750yAC                   parm      '*none'       $pdqkey
750yAC                   parm                    $pheader
750yAC                   parm                    $pfields
750yAC                   parm                    $prtnfields
750yAC                   eval      $slvfylblout = $prtnfields
750yA /end-free
750yAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRSET   Reset Trans to Open
     *
     C     zzrset        begsr
760aA *
760aA  /free
760aA    // when we introduced sending the type of pallet jack to
760aA    // getdmdsel, and nothing is returned in w1trn# after a
760aA    // previous transaction was assigned on a previous call we
760aA    // end up with a zero w1trn#, but we have already started
760aA    // the previous transaction, so we need to get them reset.
760aA    // will you trnlst to get a transactionn to pass
760aA    if w1trn# = 0;
760aA      for p = 1 to trncnt;
760aA        if trnlst(p).trn = 0;
760aA          iter;
760aA        else;
760aA          w1trn# = trnlst(p).trn;
760aA          leave;
760aA        endif;
760aA      endfor;
760aA    endif;
760aA  /end-free
760aA *
     *
     *   Reset started trans to open
     * Fill r#header ds
     C                   eval      $hdrcommand = 'resettrn'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slrtitman# = #job
     C                   eval      $slrtitrn# = w1trn#
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slresettin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slresettout = $prtnfields
     *
751oA /free
751xA   exsr zzundoauto;
751oA
751xD   // See if we need to undo auto assigned transaction
751xD
751xD   //if usingAutoAssign;
751xD   //  if prime and usingBeltPrt;
751xD   //    monitor;
751xD   //      GetDMDSel('*UNDO': w1whse: #curruser: w1trn#:
751xD   //                 dmdCode: dmdMsg);
751xD   //      if dmdCode <> '*OK';
751xD   //      endif;
751xD   //    on-error;
751xD   //    endmon;
751xD   //  endif;
751xD   //endif;
751oA
751oA /end-free
     C*
     C                   endsr
751xA*----------------------------------------------------------------
751xA*
751xA*  ZZUNDOAUTO   Undo Auto Assigment
751xA*
751xAC     zzundoauto    begsr
      /free

        if usingAutoAssign;
          if prime and usingBeltPrt;
760aA      for p = 1 to trncnt;
760aA        if trnlst(p).trn = 0;
760aA          iter;
760aA        endif;
752uA       slgbuf = '<DMDSelBefore> '
752uA            + 'cmd=*UNDO' + ' '
752uA            + 'whs=' + %char(w1whse)  + ' '
752uA            + 'user=' + %trimr(#curruser)  + ' '
760aA            + 'pjtype=' + %char(pjtype#)  + ' '
760aA            + 'dmdrte=' + dmdrte  + ' '
760aA            + 'dmdzone=' + dmdzone  + ' '
760aD      //    + 'trn=' + %char(w1trn#);
760aM            + 'trn=' + %char(trnlst(p).trn);
752uA       WriteVoiceLog ('Beg': slgbuf);
760aA       undotran = trnlst(p).trn;
            monitor;
760aD   //    GetDMDSel('*UNDO': w1whse: #curruser: w1trn#:
760aM         GetDMDSel('*UNDO': w1whse: #curruser: undotran:
760aD    //              dmdCode: dmdMsg);
760aM                    pjtype#: dmdrte: dmdzone: dmdCode: dmdMsg);
              if dmdCode <> '*OK';
              endif;
752uA         slgbuf = '<DMDSelAfter> '
752uA                + 'cmd=*UNDO' + ' '
752uA                + 'whs=' + %char(w1whse)  + ' '
752uA                + 'user=' + %trimr(#curruser)  + ' '
760aD   //           + 'trn=' + %char(w1trn#)  + ' '
760aM                + 'trn=' + %char(trnlst(p).trn)  + ' '
760aA                + 'pjtype=' + %char(pjtype#)  + ' '
760aA                + 'dmdrte=' + dmdrte  + ' '
760aA                + 'dmdzone=' + dmdzone  + ' '
752uA                + 'dmdcode=' + dmdCode  + ' '
752uA                + 'dmdmsg=' + dmdMsg;
752uA         WriteVoiceLog ('End': slgbuf);
            on-error;
            endmon;
760aA      endfor;
760aA      exsr zzresetauto;
          endif;
        endif;

      /end-free
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
720hAC                   eval      foundWL = *off
720hAC                   eval      *in63 = *off
730rAc                   if        w1eod = 'Y'
730rAc                   eval      nxtscr = 'EOJ'
730rAc                   goto      endup1
730rAc                   endif
760aA /free
760aA   if autoassignpdon;
750lA     exsr scr82i;
750fA     leavesr;
760aA   endif;
760aA /end-free
730oA /free
730oA   kyent = 'N';
730oM   setll (w1whse: kyent: w1trn#) ordskipcw1;
730oM   reade (w1whse: kyent: w1trn#) ordskipcw1;
730oA   If not %eof(ordskipcw1);
730oA      *in63 = *on;
730oA   Endif;
730oA /end-free
720nAc                   if        ptsub = 'BULK'
730wAc                   if        AllowBulk = *off
730wAc                   eval      wktype = 'O'
720nAc                   eval      w1trn# = 0
720nAc                   goto      endup1
730wAc                   else
730wAc                   eval      wktype = 'B'
730wAc                   eval      save49 = *in49
730wAc                   eval      *in49 = *off
730wAc                   eval      save62 = *in62
730wAc                   eval      *in62 = *off
730wAc                   endif
720nAc                   endif
      /free

750lA   trncheck  = %lookup(w1trn# : trnlst(*).trn : 1);
        trncnt += 1;
        trnlst(trncnt).trn = w1trn#;
        trnlst(trncnt).rtid = ptrtpo;
752oA   if ptsub = 'BULK';
752oA     trnlst(trncnt).bulkFlag = *on;
752oA   else;
752oA     trnlst(trncnt).bulkFlag = *off;
752oA   endif;

        if usingBeltPrt;
          // Initialize print variables
          GetLabelZPL('*INIT': '': 0: 0: 0: 0: '');
750vA     // Get ZPL init and stored formats if they exist
750vA     exec sql
750vA       select loset into :loset
750vA         from labelout
750vA        where lowhse = :ptwhse and lortid = :ptrtpo
750va        fetch first 1 rows only;
750vA     if sqlstt = sqlSuccess;
750vA       setLookup  = %lookup(loset : setlst(*).set : 1);
750vA       if setLookup = 0;
750vA         setcnt += 1;
750vA         setlst(setcnt).set = loset;
750vA         GetLabelZPL('*GETINIT': '': 0: 0: 0: 0: loset);
750vA         if %len(printOutput) > 0;
750vA           usingSavedFmt = *on;
750vA         endif;
750vA       endif;
750vA     endif;
          // Get ZPL for SETHED for transaction
752oD     //if OPSPPSH = 'Y';
752oM     if OPSPPSH = 'Y' and ptsub <> 'BULK';
            GetLabelZPL('*GETFMT': ptrtpo: w1trn#: 0: 0: 0: 'SETHED');
            if error;
              error = *off;
              errmsg = '';
            endif;
          endif;
          // Get ZPL for SETSUM for transaction
752oD     //if OPSPPSS = 'B';
752oM     if OPSPPSS = 'B' and ptsub <> 'BULK';
            GetLabelZPL('*GETFMT': ptrtpo: w1trn#: 0: 0: 0: 'SETSUM');
            if error;
              error = *off;
              errmsg = '';
            endif;
          endif;
        endif;
      /end-free
     *
     *   End current task for user.
     *
750lA*
750lA*   get palllet summary
750lA  /free
750lA    if prime;
750lA      if trncheck  <> 0;
750lA      else;
750lA        $GetStpSum();          // get stop summary
750lA      endif;
750lA      // get pick list
750lA      wkrtid = ptrtpo;
750lA      exsr getlowlimit;
751jA      pckcnt = 0;
751jA      clear pcklst;
750lA      dow forever = forever;
750lA        exsr getrecord;
750lA        if %eof;
752oA          if wktype = 'B';
752oA            leave;
752oA          endif;
751bA          if wktype = 'M';
752mA            if ptsub = 'BULK';
752mA              wktype = 'B';
752mA            else;
751bA              wktype = 'O';
752mA            endif;
750lA            leave;
751bA          else;
751bA            wktype = 'M';
751bA            exsr getlowlimit;
750bA            iter;
751bA          endif;
750lA        endif;
750lA        if trncheck  <> 0;
750lA        else;
750lA          $GetPckLst();          // get pick list
750lA        endif;
750lA      enddo;
750lA    endif;
750lA    if prime and opSPps = 'Y';
750lA      if trncheck  <> 0;
750lA      else;
750lA        $GetPltSum();          // get pallet summary
750lA      endif;
760aD      //if OPVMLT = 'N';
760aM      if OPVMLT = 'N' or
760aA         autoassigndone;
750lA        exsr scr82i;
750fA        leavesr;
750lA      endif;
750lA    endif;
750lA  /end-free
     *
     *   Start scanned transaction
     *
     *
     *   Initialize totals
     *
760aDc**                 if        OPVMLT  = 'Y'
760aDc**                 else
760aDC**                 eval      ttllic = 1
760aDC**                 eval      ttlpcs = $slasopieces
760aDC**                 eval      ttlcub = $slasocube
760aDC**                 eval      ttlwgt = $slasoweight
760aDc**                 eval      wkrtpo = ptrtpo
760aDc**                 endif
760aA /free
760aA  select;
760aA    when PIRsoask;
760aA    when autoassignmore;
760aA    when opvmlt = 'Y';
760aA    other;
760aA      ttllic = 1;
760aA      ttlpcs = $slasopieces;
760aA      ttlcub = $slasocube;
760aA      ttlwgt = $slasoweight;
760aA      wkrtpo = ptrtpo;
760aA  endsl;
760aA /end-free
     c
     *
     *   Display screen to scan label.
     *
760aA /free
760aA  select;
760aA    when PIRsoask;
760aA      exsr scr15i;
760aA    when autoassignmore;
760aA      w1trn# = 0;
760aA      displayScreen = '0';
760aA      leavesr;
760aA    when opvmlt = 'Y';
760aA      exsr scr15i;
760aA    other;
760aA /end-free
760aDc**                 if        OPVMLT = 'Y'
760aDC**                 exsr      scr15i
760aDc**                 else
700fAC                   if        oprfpm = '2'
700fAc                   eval      slwemp# = $emp#
700fAC                   exsr      getlowlimit
MQSaAc                   eval      FirstMslot = *on
700fAc                   exsr      scr11i
700fAC                   else
700fAC                   exsr      scr02i
700fAC                   endif
720cAC                   eval      firstzonepick = *on
760aAC                   endsl
760aDc**                 endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
750qA /free
750qA    // When using belt printer get combo info
750qA
750qA    bulkLabel = *off;
750qA    comboLabel = *off;
750qA
750qA    exec sql
750qA      select lolbltype, lolblcombo into :lolbltype, :lolblcombo
750qA        from labelout
750qA       where lowhse = :lbwhse and lortid = :lbrte
750qA         and lolbl = :lblbl# and lolblcnt = 1;
750qA
750qA    if sqlstt <> sqlSuccess;
750qA      lolbltype = '';
750qA      lolblcombo = '0';
750qA    endif;
750qA
750qA    if lolbltype = 'B';
750qA      bulkLabel = *on;
750qA    endif;
750qA    if lolblcombo = '1';
750qA      comboLabel = *on;
750qA    endif;
750qA /end-free
720cA*  manual zone pickup
720cAc*****              if        $slvloaisle = 'zon'
720cAc                   if        zonepickup
720cAc                   else
520c *  Advance read to current label value.
700fAC                   if        oprfpm = '2'
700fAC                   dow       forevr=forevr
700fAc                   exsr      getrecord
700fAC                   if        %eof
700fAc                   exsr      getlowlimit
700fAc                   iter
700fAc                   endif
700fAc                   if        multitran
700fAc                   move      slwlbl#       wklabel
700iDc*                  eval      aisle = slwaisl
700fAc                   else
700fAc                   move      lblbl#        wklabel
700iDc*                  eval      aisle = lbaisl
700fAc                   endif
700fAc                   if        wklabel = w2lbl#b
700iAc                   if        multitran
750lDc*                  if        aisle = slwaisl
750lAc                   if        showaisle = slwaisl
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAc                   eval      nxtscr = '12V'
740eAc                   else
700iAc                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700iAc                   else
700iAC                   eval      nxtscr = '11 '
700iAc                   endif
700iAc                   else
750lDc*                  if        aisle = lbaisl
750lMc                   if        showaisle = lbaisl
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAc                   eval      nxtscr = '12V'
740eAc                   else
700iAc                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700iAc                   else
700iAC                   eval      nxtscr = '11 '
700iAc                   endif
700iAc                   endif
700iAc                   exsr      zzfil11
700fAc                   leave
700fAc                   endif
700fAc                   enddo
700fAc                   endif
720cAc                   endif
520c *  Get item and then get category.
520c C                   exsr      zzgeti
520cA*
520cAC*                  call      'GETITEMFLD'
520cAC*                  parm      w1whse        $gWhse            3 0
520cAC*                  parm      ititem        $gItem           15
520cAC*                  parm      ' '           $gCat            10
520cAC*                  parm      ' '           $gCaseOvf         1
     *
     *  Do Scr06ai for merge label.
     C                   if        $slvlolbl# <> w2lbl
     C                   eval      first6a = *off
720cAC                   eval      first6 = *off
650aA*  If User can enter quantity
650aAC                   if        oprfqt = 'Y' and itcwgt <> 'Y'
710aDc*                            and $slvlopickqty > 1
710aAc                             and $slvlopickqty > oprfqto
751dAc                             and not zonepickup
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                             and lbtype <> 'M'
751dAc                             and not zonepickup
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
650aAC                   exsr      scr06ci
     c                   else
752vAc                   if        prime
752vAC                   exsr      scr88i
752vAc                   else
     C                   exsr      scr06ai
752vAc                   endif
650aAc                   endif
     C                   else
700fAc                   if        oprfpm = '2'
700fAc                   if        whereFrom = '11'
700fAc                             or whereFrom = '12'
740eAc                             or whereFrom = '12V'
750lAc                             or SPWHEREFROM = 'OR400.84'
700fAc                   exsr      zzfil11
750lAc                   if        showaisle = lbaisl
700fAc                   exsr      zzupd11
750lAc                   else
750lAc                   goto      endup2
750lAc                   endif
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAc                   eval      nxtscr = '12V'
740eAc                   else
700fAc                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700fAc                   else
700fAC                   if        oprfqt = 'Y' and itcwgt <> 'Y'
710aDc*                            and $slvlopickqty > 1
710aAc                             and $slvlopickqty > oprfqto
751dAc                             and not zonepickup
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
751dAc                             and not zonepickup
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
700fAC                   exsr      scr06ci
700fAc                   else
752vAc                   if        prime
752vAC                   exsr      scr88i
752vAc                   else
700fAC                   exsr      scr06ai
752vAc                   endif
700fAc                   endif
700fAc                   endif
700fAC                   else
     C                   exsr      scr03i
700fAC                   endif
700fAC                   endif
     *
     C     endup2        endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   eval      error = *off
     C                   eval      first6 = *off
     C                   eval      first6a = *off
     *
     *  Scanned pick location.
     C                   eval      first2 = *on
730fA*
730fA*  Check to see if UPC exist
730hDc*                  eval      kywhse = w1whse
730hDC*                  eval      upcyes = *off
730hDC*    l90key        chain     label90
730hDC*                  if        %found(label90)
730hDC*    upcky         chain     upc5
730hdC*                  if        %found(upc5)
730hDC*                  eval      upcyes = *on
730hDC*                  else
730hDC*                  eval      savupc = *blanks
730hDC*                  endif
730hDC*                  endif

     *  Check options to determine next screen

710jAc                   eval      kywhse = w1whse
710jAC                   eval      upcyes = *off
730sDC*    l90key        chain     label90
730sMC     keyl90        chain     label90
710jAC                   if        %found(label90)
710jAC     upcky         chain     upc5
710jAC                   if        %found(upc5)
710jAC                   eval      upcyes = *on
710jAC                   else
710jAC                   eval      savupc = *blanks
710jAC                   endif
710jAC                   endif

     C                   select
SVLb *  If Saval, Seafood
SVLbAC                   when      client = Saval
SVLbAC                             and type = 'SEA'
     C                   exsr      scr06bi
SVLnA*  If Saval, Seafood new vendor
SVLnAC                   when      client = Saval
SVLnAC                             and type = 'SEG'
SVLnAC                   exsr      scr06di
730qA*  Pick to Weight
730qAC                   when      $ifsltmth = '2' and umFlexPickFlag = 'P2W'
730qAc                             or $ifsltmth = '3' and umFlexPickFlag = 'P2W'
730qAC                   exsr      scr06ei
650bA*  uci selection
650bAC                   when      $ifsltmth = '2' or $ifsltmth = '3'
650bAC                   exsr      scr06di
720cA*  If UPC options, upc verify - individual is off, scan one time
     C                   when      oprfuc = 'Y'
710jAC                             and upcyes
720cAc                             and oprfui <>'Y'
     C                   exsr      scr04i
720cA*  If UPC selection turned on at global and individual scan is on
720cA*  Scan each unit selected
720cAC                   when      oprfuc = 'Y'
720cAC                             and upcyes
720cAc                             and oprfui = 'Y'
740eAc                             and ($ifsltmth <'4' or $ifsltmth >'6')
720cAC                   exsr      scr06i
720cA*  If UPC selection turned on at the item
720cAC                   when      $ifsltmth = '4'
720cAc                             and oprfui = 'Y'
720cAC                   exsr      scr06bi
720cA*  If UPC selection turned on at the item
720cAC                   when      $ifsltmth = '4'
720cAc                             and oprfui <>'Y'
720cAC                   exsr      scr04i
720cAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
720cAc                             and oprfui = 'Y'
720cAC                   exsr      scr06bi
720cAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
720cAc                             and oprfui <>'Y'
720cAC                   exsr      scr04i
740aAC                   when      $ifsltmth = '6' and lbutyp =  'N'
740aAc                             and oprfui = 'Y'
740aAC                   exsr      scr06bi
740aAC                   when      $ifsltmth = '6' and lbutyp  = 'N'
740aAc                             and oprfui <>'Y'
740aAC                   exsr      scr04i
     *  If license options
     C                   when      oprflc = 'Y'
     C                   exsr      scr05i
650aA*  If User can enter quantity
650aAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
710aDc*                            and $slvlopickqty > 1
710aAc                             and $slvlopickqty > oprfqto
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
650aAC                   exsr      scr06ci
     *  Scan to pallet
     C                   other
     C                   exsr      scr06i
     C                   endsl
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   eval      error = *off
510b C                   eval      savupc = w4upcd
     *  Check options to determine next screen
     C*                  select
510b C                   select
     *  If license options
     C*                  when      oprflc = 'Y'
     C*                  exsr      scr05i

650aAC                   when      w4upcd <> *blanks
650aAC                             and oprfqt = 'Y' and itcwgt <> 'Y'
710aDc*                            and $slvlopickqty > 1
710aAc                             and $slvlopickqty > oprfqto
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
650aAC                   exsr      scr06ci
     *  Scan to pallet
     C*                  other
510b C                   when      w4upcd <> *blanks
700fAC                   if        oprfpm = '2'
700fAC                   exsr      scr06i
700fAC                   else
510b C                   exsr      scr06bi
700fAC                   end
510b C                   other
510b C                   exsr      scr06i
510b C                   endsl
     *
     C     endup4        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     C                   eval      error = *off
     *  Check options to determine next screen
500gDC*                  select
     *  If catch weight item
     C***                when      itcwgt = 'Y'
500gDC*                  when      $slvlocwtflag = *on
500gDC*                  exsr      scr07i
     *  Scan to pallet
500gDC*                  other
710aA*  If User can enter quantity
710aAc                   select
710aAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
710aAc                             and $slvlopickqty > oprfqto
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
710aAC                   exsr      scr06ci
710aAc                   other
710aAC                   exsr      scr06i
710aAc                   endsl
500gDC*                  endsl
     *
     C     endup5        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD6   Update for screen 6.
     *
     C     zzupd6        begsr
     C                   eval      error = *off
     C                   eval      first6 = *on
     *  Scan to pallet
     C                   add       1             w6cnt1
720gAc** is this a combo label
720gAc
720gAc                   movel     $pbarcode     combochk         10
720gAc                   movel     combochk      comborte          5
720gAc                   move      combochk      combounq          5 0
720gAc
720gA /free
720gA   combo = *off;
720gA   chain (w1whse: comborte: combounq) ordp;
750kD   //if %found(ordp) and orpscn > 1;
750kM   if %found(ordp) and orpscn > 1;
750tD      //or oprfqtcw = 'Y' and $itcwgt = 'Y';
720gA     combo = *on;
720gA     w6cnt1 = w6cnt1 - 1;
720gA   endif;
720gA /end-free
     *  Catch weight item
     C                   if        itcwgt = 'Y'
ADWb C                   if        ititem = '27801' and
ADWb C                             client = andrews
ADWb C                   eval      $slscoweight = 5.10
ADWb C                   eval      lwrng = 0
ADWb C                   eval      hirng = 0
ADWb C                   eval      cwgt = 5.10
ADWb C                   exsr      zzupd7
ADWb C                   else
720hA /free
720hA   // has user already indicated weigh later for this label
720hA   exsr Chk4Skipcw;
720hA /end-free
720hAc                   if        foundWL = *off
720nAc                             and DonewithWgt = *off
730wAc                   eval      pristineloaded = *off
730wAc                   exsr      autoloadcw
730wAc                   if        pristineloaded
730wAc                   exsr      zznxt
730wAc                   else
750eAc                   select
750eAc                   when      $ifsltmth = '2'
750eAc                   exsr      scr06di
750eAc                   other
     C                   exsr      scr07i
750eAc                   endsl
730wAc                   endif
720hAc                   else
720hAc                   exsr      zznxt
720hAc                   endif
ADWb C                   endif
     C                   goto      endup6
     C                   else

SVLgAC                   if        client = saval
SVLgAC                             and type = 'CHK'
SVLhAC                             or client = saval
SVLmMC                             and (type = 'SKI'
SVLmAC                               or type = 'PRO')
SVLgAC                   exsr      scr07i
SVLgAC                   goto      endup6
SVLgAC                   endif

720gAc                   if        combo = *on
720gAc                   exsr      scr06ci
720gAc                   else
     C                   exsr      zznxt
720gAc                   endif
     C                   endif
     C*
     *
     *
     C     endup6        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD6a  Update for screen 6a.
     *
     C     zzupd6a       begsr
     C                   eval      error = *off
     C                   eval      first6a = *on
751gA /free
751gA    // Print labels if 'After Pick' option taken
751gA    if opsppba = 'A';
751gA      if comboLabel or bulkLabel;
751pA        if zonepickup;
751pA          GetLabelZPL('*GETLABEL': w2rtid: 0: $SLVLOLBL#:
751pA                       1: 1: '');
751pA        else;
751gA          GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1: '');
751pA        endif;
751gA      else;
751pA        if zonepickup;
751pA          GetLabelZPL('*GETLABEL': w2rtid: 0:
751pA                       $SLVLOLBL#: w6acnt1+1: W6acnt1+1: '');
751pA        else;
751gA          GetLabelZPL('*GETLABEL': w2rtid: 0:
751gA                       w2lbl: w6acnt1+1: W6acnt1+1: '');
751pA        endif;
751gA      endif;
751gA    endif;
751gA    // Assume error means Merge label not printed
751gA    if zplRtnCode <> '*OK';
751gA      errmsg = '';
751gA    endif;
751gA /end-free
     *  Scan to pallet
     C                   add       1             w6acnt1
     C                   z-add     w6acnt1       w6cnt1
     C                   z-add     w6acnt2       w6cnt2
751zDC**                 exsr      zznxt

751zA /free
751zA    if zonepickup and getMrgWgt and itcwgt = 'Y';
751zA      exsr scr07i;
751zA    else;
751zA      exsr zznxt;
751zA    endif;
751zA /end-free

751pAC                   eval      w6uci = ' '
     C*
     *
     *
     C     endup6a       endsr
510a *----------------------------------------------------------------*********
510a *
510a *  ZZUPD6b  Update for screen 6b.
510a *
510a C     zzupd6b       begsr
510a C                   eval      error = *off
510a C                   eval      first6 = *on
510a *  Scan to pallet
510a C                   add       1             w6cnt1
      /free
750uA   // Print label if 'After Pick' option taken
750uA   if opsppba = 'A';
750uA     GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: w6cnt1: w6cnt1: '');
750uA   endif;
      /end-free
510a *  Catch weight item
510a C                   if        itcwgt = 'Y'
ADWb C                   if        ititem = '27801' and
ADWb C                             client = andrews
ADWb C                   eval      $slscoweight = 5.10
ADWb C                   eval      lwrng = 0
ADWb C                   eval      hirng = 0
ADWb C                   eval      cwgt = 5.10
ADWb C                   exsr      zzupd7
ADWb C                   else
720hA /free
720hA   // has user already indicated weigh later for this label
720hA   exsr Chk4Skipcw;
720hA /end-free
720hAc                   if        foundWL = *off
720nAc                             and DonewithWgt = *off
510a C                   exsr      scr07i
720hAc                   else
720hAc                   exsr      zznxt
720hAc                   endif
ADWb C                   endif
510a C                   goto      endup6b
510a C                   else

SVLgAC                   if        client = saval
SVLgAC                             and type = 'CHK'
SVLhAC                             or client = saval
SVLhAC                             and type = 'SKI'
SVLgAC                   exsr      scr07i
SVLgAC                   goto      endup6b
SVLgAC                   endif

510a C                   exsr      zznxt
510a C                   endif
510a C*
510a *
510a *
510a C     endup6b       endsr
650aA*----------------------------------------------------------------*********
650aA*
650aA*  ZZUPD6c  Update for screen 6c.
650aA*
650aAC     zzupd6c       begsr
650aAC                   eval      error = *off
650aAC                   eval      first6 = *on
750uA /free
750uA    // Print labels if 'After Pick' option taken
750uA    if opsppba = 'A';
750uA      if comboLabel or bulkLabel;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1: '');
750uA      else;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0:
750uA                     w2lbl: w6cnt1+1: W6cnt1+w6cnt1e: '');
750uA      endif;
750uA    endif;

751zA    if (itcwgt = 'Y' and lbpal# < 20000)
751zA       or (itcwgt = 'Y' and not getMrgWgt);
751zA      getWgtFlag = *on;
751zA    else;
751zA      getWgtFlag = *off;
751zA    endif;

750uA /end-free

750kAc                   if        oprfqtcw = 'Y' and
750zMc                             getWgtFlag and combo = *on
750zDc**                           itcwgt = 'Y' and combo = *on
750kAc                   eval      w6cnt1 = 0
750kAc                   else
750uD /free
750uD    //if comboLabel or bulkLabel;
750uD    //  GetLabelZPL('*GETLABEL': $prtidl: 0: w2lbl: 1: 1: '');
750uD    //else;
750uD    //  GetLabelZPL('*GETLABEL':$prtidl:0:w2lbl:w6cnt1+1:W6cnt1+w6cnt1e: '');
750uD    //endif;
750uD /end-free
650aAC                   eval      w6cnt1 = w6cnt1 + w6cnt1e
750kAc                   endif
751vAc/free
751vA  if w6cnt1e = 0;
751vA    eval *inkj = *on;
751vA    leavesr;
751vA  endif;
751vAc/end-free
650aA*  Catch weight item
751zDC**                 if        itcwgt = 'Y'
751zMC                   if        getWgtFlag
650aAC                   if        ititem = '27801' and
650aAC                             client = andrews
650aAC                   eval      $slscoweight = 5.10
650aAC                   eval      lwrng = 0
650aAC                   eval      hirng = 0
650aAC                   eval      cwgt = 5.10
650aAC                   exsr      zzupd7
650aAC                   else
720hA /free
720hA   // has user already indicated weigh later for this label
720hA   exsr Chk4Skipcw;
720hA /end-free
720hAc                   if        foundWL = *off
720nAc                             and DonewithWgt = *off
730wAc                   eval      pristineloaded = *off
730wAc                   exsr      autoloadcw
730wAc                   if        pristineloaded
730wAc                   exsr      zznxt
730wAc                   else
650aAC                   exsr      scr07i
730wAc                   endif
720hAc                   else
720hAc                   exsr      zznxt
720hAc                   endif
650aAC                   endif
650aAC                   goto      endup6c
650aAC                   else
650aAC                   exsr      zznxt
650aAC                   endif
650aA*
650aAC     endup6c       endsr
650bA*----------------------------------------------------------------*********
650bA*
650bA*  ZZUPD6d  Update for screen 6d.
650bA*
650bAC     zzupd6d       begsr
650bAC                   eval      error = *off
650bAC                   eval      first6 = *on
650bA*  Scan to pallet
650bAC                   add       1             w6cnt1
      /free
750uA   // Print label if 'After Pick' option taken
750uA   if opsppba = 'A';
750uA     GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: w6cnt1: w6cnt1: '');
750uA   endif;
      /end-free
650bA*  Catch weight item
650bAC*                  if        itcwgt = 'Y'
650bAC*                  if        ititem = '27801' and
650bAC*                            client = andrews
650bAC*                  eval      $slscoweight = 5.10
650bAC*                  eval      lwrng = 0
650bAC*                  eval      hirng = 0
650bAC*                  eval      cwgt = 5.10
650bAC*                  exsr      zzupd7
650bAC*                  else
650bAC*                  exsr      scr07i
650bAC*                  endif
650bAC*                  goto      endup6
650bAC*                  else
650bAC                   exsr      zznxt
650bAC*                  endif
650bAC*
650bA*
650bA*
650bAC     endup6d       endsr
730qA*----------------------------------------------------------------*********
730qA*
730qA*  ZZUPD6e  Update for screen 6e.
730qA*
730qAC     zzupd6e       begsr
730qAC                   eval      error = *off
730qAC                   eval      first6 = *on
730qA*  Scan to pallet
730qAC                   add       1             w6cnt1
730qAC                   add       $BCPNTLB      w6wgt1
730qAC                   exsr      zznxt
730qA*
730qAC     endup6e       endsr
730qA*----------------------------------------------------------------*********
730qA*
730qA*  ZZUPD6f  Update for screen 6f.
730qA*
730qAC     zzupd6f       begsr
730qAC                   eval      error = *off
730qAC                   eval      first6 = *on
730qA*  Scan to pallet
730qAC                   sub       1             w6cnt1
730qAC                   sub       $BCPNTLB      w6wgt1
730qAC                   exsr      zznxt
730qA*
730qAC     endup6f       endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD7   Update for screen 7.
     *
     C     zzupd7        begsr
     C                   eval      error  = *off

750pA /free
750tA   // this was added because we already print the labels from
750tA   // screen6b/zzupd20 for upc selection(4,5,6)
750tA   // screen6d for uci selection(2)
750tA   if $ifsltmth = '2' or $ifsltmth = '4' and oprfui = 'Y'
750tA     or $ifsltmth = '5' or $ifsltmth = '6';
750tA   else;
750uD     //if comboLabel or bulkLabel;
750uD     //  GetLabelZPL('*GETLABEL': $prtidl: 0: w2lbl: 1: 1: '');
750uD     //else;
750uD     //  GetLabelZPL('*GETLABEL': $prtidl: 0:w2lbl: w6cnt1+1: w6cnt1+1:'');
750uD     //endif;
750tA   endif;
750pA /end-free

SVLhAC                   if        client = saval
SVLmMC                             and (type = 'SKI'
SVLmAC                               or type = 'PRO')
SVLhAC                   exsr      zznxt
SVLhAC                   goto      endup7
SVLhAC                   endif

SVLgAC                   if        client = saval
SVLgAC                             and type = 'CHK'
SVLgAC                             and itcwgt = 'N'
SVLgAC                   exsr      zznxt
SVLgAC                   goto      endup7
SVLgAC                   endif

720nAc                   if        DonewithWgt = *off
     *  Record weight.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'weight'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slcwitman# = #job
752vAc                   if        zonepickup and getMrgWgt and prime
752vAC                   eval      $slcwitrn# = mstrn#
752vAC                   eval      $slcwilbl# = mslbl#
752vAC                   eval      $slcwistop = msstop
752vAC                   eval      $slcwiitem = msitem
752vAc                   else
     C                   eval      $slcwitrn# = $slvlotrn#
     C                   eval      $slcwilbl# = $slvlolbl#
     C                   eval      $slcwistop = $slvlostop
     C                   eval      $slcwiitem = $slvloitem
752vAc                   endif
     C                   eval      $slcwiweight = $slscoweight
710iAc                   eval      $slcwivalue =  w7cwgt
     C                   if        *inkh
     C                   eval      $slcwiexcep = 'Y'
     C                   else
     C                   eval      $slcwiexcep = 'N'
     C                   endif
500hDC*                  eval      $slcwirnglow = lwrng
500hDC*                  eval      $slcwirnghigh = hirng
500hMC                   eval      $slcwirnglow = ilrng
500hMC                   eval      $slcwirnghigh = ihrng
520bAC                   eval      $slcwiseq# = 0
     C                   eval      $slcwientwgt = cwgt
     C                   eval      $slcwienttype = 'Pounds'
700dAc                   if        BegKiloLbs = 'K'
700dAC                   eval      $slcwienttype = 'Kilograms'
700dAc                   endif
     C                   eval      $slcwilater = 'N'
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slweightin
500dAC                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
501jAC                   parm                    $prtnfields
     C                   eval      $slweightout = $prtnfields
     *
720nAc                   endif
501jAC                   if        $slcwoflag <> '1'
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
520bDC**                 eval      errmsg = *blanks
520bMC                   eval      errmsg = 'Error occurred in VOSELECT'
520bAC                   exsr      zm9898
     C                   eval      error = *on
     C                   goto      endup7
     C                   else
     *  Determine what screen to display and/or update pick qty.
720gA /free
750eA   Select;
750eA     when ptsub = 'BULK' and allowbulk and combo
750eA          and $ifsltmth <> '2';
750eA       w6cnt1 = w6cnt2;
750eA     other;
720gA       if combo;
720gA         w6cnt1 = w6cnt1 + 1;
720gA         wtchk = '0';
720gA         w7cwgt = ' ';
720gA         ovrrid = '0';
720gA       endif;
750eA   endsl;
720gA /end-free
751zDC**                 exsr      zznxt

751zA /free
752vA    // do we have more to pickup for zonepickup
752vA   morepickup = *off;
752vA   if prime and zonepickup;
752vA
752vA     exec sql select * into :mrgrec
752vA          from SPmrgwrk
752vA          where mgwhse = :lbwhse
752vA            and mgjob  = :#job
752vA            and mgscan = ' '
752vA            fetch first 1 rows only;
752vA     If sqlstt = sqlSuccess;
752vA       morepickup = *on;
752vA     else;
752vA       morepickup = *off;
752vA     endif;
752vA   endif;
751vA    if zonepickup
751vA       and w6cnt1 < w6cnt2
752vA       or morepickup = *on;
752vA      if prime;
752vA        exsr scr88i;
752vA      else;
751zA        exsr scr06ai;
752vA      endif;
751zA    else;
751zA      exsr zznxt;
751zA    endif;
751zA /end-free

     C                   endif
     *
     *
     C     endup7        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD8   Update for screen 8.
     *
     C     zzupd8        begsr
     C                   eval      error  = *off
     *  End transaction and start idle.
     * Fill r#header ds
720hDC***                eval      $hdrcommand = 'complete'
720hDC***                time                    curtime
720hDC***                eval      $hdrtimestamp = %char(curtime)
720hDC***                eval      $slcmitman# = #job
720hDC***                eval      $slcmitrn# = $slvlotrn#
720hDC***                eval      $pheader = $header
720hDC***                eval      $pfields = $slcompltin
720hDC***                exsr      writelog
720hDC***                call      'VOSELECT'
720hDC***                parm      '*none'       $pdqlib
720hDC***                parm      '*none'       $pdqnameout
720hDC***                parm      '*none'       $pdqkey
720hDC***                parm                    $pheader
720hDC***                parm                    $pfields
720hDC***                parm                    $prtnfields
720hDC***                eval      $slcompltout = $prtnfields
     *
720hDC***                if        $slcmoflag <> '1'
720hDC***                eval      error = *on
720hDC***                eval      *in23 = *on
720hDC***                eval      *in03 = *on
720hDC***                eval      errmsg = *blanks
720hDC***                eval      errmsg = 'Error occurred in VOSELECT'
720hDC***                exsr      zm9898
720hDC***                goto      endup8
720hDC***                endif
     *
500fA
500f *  If unfinished selection trans for user, display sc9 with msg.
500f C                   exsr      zzcktn
720dDC*                  if        ufinfl = *on
720dDC*                  exsr      scr09i
720dDC*                  else
     *  Display screen 1 for next transaction
750lAc                   exsr      zzreset
760aAc                   exsr      zzresetauto
751aAc                   eval      zonepickup = *off
752vAc                   exsr      clrSPmrgfiles
     C                   exsr      scr01i
720dDC*                  endif
     *
     C     endup8        endsr
     *----------------------------------------------------------------*********
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
     C                   eval      error  = *off
     *
     *  Display screen 1 for next transaction
750lAc                   exsr      zzreset
     C                   exsr      scr01i
     *
     C     endup9        endsr
ISPaA*----------------------------------------------------------------*********
ISPaA*
ISPaA*  ZZUPD9a  Update for screen 9a.
ISPaA*
ISPaAC     zzupd9a       begsr
ISPaAC                   eval      error  = *off
ISPbAC                   if        client = isupply
ISPbAC***                exsr      zzstat
ISPbAC                   exsr      zzclose
ISPbAC                   endif
ISPaAC
ISPaA*  Display screen 1 for next transaction
750lAc                   exsr      zzreset
ISPaAC                   exsr      scr01i
ISPaA*
ISPaAC     endup9a       endsr
500dA*----------------------------------------------------------------*********
500dA*
500dA*  ZZUPD10  Update for screen 10
500dA*
500dAC     zzupd10       begsr
     C                   eval      error  = *off
     c     endup10       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZUPD11 -  Screen 11
700fA*
700fAC     zzupd11       begsr
700fA*
750lAc                   eval      showaisle = aisle
720nAc                   eval      DonewithWgt = *off
700fAc                   clear                   sslot
KHLaAc                   if        client = kohl
COTaAc                             or client = Cotati
GRCaAc                             or client = greco
CFIaAc                             or client = colony
PANaAc                             or client = panos
ACCaAc                             or client = accardi
MRTaAc                             or client = merit
EOPaAc                             or client = EarlsOrganic
BADaAc                             or client = BigApple
SWTaAC                             or client = SWT
SFPaAC                             or client = SFP
KFSaAC                             or client = Kellys
BADaAc                             or client = BigApple
VFIaAc                             or client = Vitco
SOFaAc                             or client = SofoFoods
KHLaAc                   eval      *in60 = *on
KHLaAc                   else
KHLaAc                   eval      *in60 = *off
KHLaAc                   endif
MQSaAc                   if        client = marques and
MQSaAc                             FirstMSlot = *on
MQSaAc                             or client <> marques
750oAc                   if        oprfsssv = 'Y'
750oAc                             and saveaisle = lbaisl
750oAc                             and saveloc = lbloc
750oAc                             and savelvl = lbrlvl
750oAc                             and savehand = lbhand
750oac                   exsr      zzupd12v
750oAc                   goto      endup11
750oAc                   endif
740eAc                   if        oprvsl <> 0  or
740eAc                             oprvup <> 0  or
740eAc                             oprvcd <> 0
740eAC                   exsr      scr12vi
740eAc                   goto      endup11
740eAc                   endif
700fAc                   if        oprfsl = 'Y'
700fAc                   seton                                        46
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAC                   eval      nxtscr = '12V'
740eAc                   else
700fAC                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700fAc                   goto      endup11
700fAc                   endif
700fAc                   if        oprfsl = 'C'
700fAc                   seton                                        47
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAC                   eval      nxtscr = '12V'
740eAc                   else
700fAC                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700fAc                   goto      endup11
700fAc                   endif
700fAc                   if        oprfsl = 'E'
700fAc                             or oprfsl = 'N'
700fAc                   seton                                        48
740eAc                   if        oprvsl > 0
740eAc                             or oprvcd > 0
740eAc                             or oprvup > 0
740eAC                   eval      nxtscr = '12V'
740eAc                   else
700fAC                   eval      nxtscr = '12 '
752gAc                   exsr      Chk4weighbtn
740eAc                   endif
700fAc                   goto      endup11
700fAc                   endif
700fA*
700fDc*                  exsr      scr02i
700fAc                   exsr      zzupd12
MQSaAc                   else
MQSaAc                   exsr      zzupd12
MQSaAc                   endif
700fA*
700fAC     endup11       endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  ZZUPD12  Update for screen 12.
700fA*
700fAC     zzupd12       begsr
700fA*
700fA*
700fAC                   eval      error = *off
700fAC                   eval      first6 = *off
700fAC                   eval      first6a = *off
730wAc                   if        *in51
730wAc                   exsr      zzgets
730wAC                   if        error = *on
730wAC                   goto      endup12
730wAC                   endif
730wA
730wA*    Call program that will (if necessary) ...
730wA*      - Prompt user to pull pallet.
730wA*      - Have user verify license being pulled.
730wA*      - Update license information.
730wA
730wAC                   exsr      zzzclr$lt210
730wAC                   eval      $tcmd  = '*PULDROP'
730wAC                   eval      $twhse = w1whse
730wAC                   eval      $twhdp = #fromslwhdp
730wAC                   eval      $tslot = #fromsldisp
730wAC                   eval      $titem = #fromslitem
730wAC                   eval      $titemdsc = #fromithead
730wAC                   eval      $tlic# = #fromToLcns
730wAC                   exsr      zzzcall$lt210
730wA
730wA
730wAC                   if        $treturn = '*CANCEL'
730wAC                   goto      endup12
730wAC                   endif
730wA
730wAC                   if        $treturn = '*NOTFND'
730wA
730wAC                   exsr      zzzclr$lt210
730wAC                   eval      $tcmd   = '*PULRTN'
730wAC                   eval      $twhse  = $pwhse
730wAC                   eval      $twhdp  = lbwhdp
730wAC                   eval      $tslot  = lbdisp
730wAC                   eval      $titem  = lbitem
730wAC                   eval      $titemdsc = itdesc
730wAC                   eval      $tlic# = #fromToLcns
730wAC                   exsr      zzzcall$lt210
730wA
730wAC                   eval      nxtscr = '01'
730wAC                   goto      endup12
730wAC                   endif
730wAc                   endif
700fA*
700fA*  Scanned pick location.
700fAC                   eval      first2 = *on
730fA*
730fA*  Check to see if UPC exist
730fAc                   eval      kywhse = w1whse
730fAC                   eval      upcyes = *off
730sDC*    l90key        chain     label90
730sMC     keyl90        chain     label90
730fAC                   if        %found(label90)
730fAC     upcky         chain     upc5
730fAC                   if        %found(upc5)
730fAC                   eval      upcyes = *on
730fAC                   else
730fAC                   eval      savupc = *blanks
730fAC                   endif
730fAC                   endif

700fA*  Check options to determine next screen
700fAC                   select
700fA*  If Saval, Seafood
700fAC                   when      client = Saval
700fAC                             and type = 'SEA'
700fAC                   exsr      scr06bi
730qA*  pick to weight
730qAC                   when      $ifsltmth = '2' and umFlexPickFlag = 'P2W'
730qAC                             or $ifsltmth = '3' and umFlexPickFlag = 'P2W'
730qAC                   exsr      scr06ei
700fA*  uci selection
730wDC*                  when      $ifsltmth = '2' or $ifsltmth = '3'
730wAC                   when      $ifsltmth = '2' and ptsub <>'BULK'or
730wAC                             $ifsltmth = '3' and ptsub <>'BULK'
700fAC                   exsr      scr06di
700fA*  If UPC options,
700fAC                   when      oprfuc = 'Y'
730nAC                             and upcyes
720cAc                             and oprfui <> 'Y'
700fAC                   exsr      scr04i
740eAC                   when      oprfuc = 'Y'
740eAC                             and upcyes
740eAc                             and oprfui = 'Y'
740eAc                             and ($ifsltmth <'4' or $ifsltmth > '6')
740eAC                   exsr      scr04i
720cAC                   when      oprfuc = 'Y'
730nAC                             and upcyes
720cAc                             and oprfui = 'Y'
740eAc                             and ($ifsltmth >='4' and $ifsltmth <='6')
720cAC                   exsr      scr06bi
720cA*  If UPC selection turned on at the item
720cAC                   when      $ifsltmth = '4'
720cAc                             and oprfui = 'Y'
730cA*  Do we allow user to enter a qty
730cAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
730cAc                             and $slvlopickqty > 1
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
730cAc                   eval      kywhse = w1whse
740bDC*    l90key        chain     label90
740bMC     keyl90        chain     label90
730cAC                   if        %found
730cAc                   if        $slvlopickqty <= oprfqto
720cAC                   exsr      scr06bi
730cAc                   else
730cAC                   exsr      scr06ci
730cAC                   endif
730cAC                   endif
730hAc                   else
730bAc                   exsr      scr06bi
730cAC                   endif
720cAC                   when      $ifsltmth = '4'
720cAc                             and oprfui <>'Y'
720cAC                   exsr      scr04i
720cAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
720cAc                             and oprfui = 'Y'
730cA*  Do we allow user to enter a qty
730cAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
730cAc                             and $slvlopickqty > 1
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
730cAc                   eval      kywhse = w1whse
740bDC*    l90key        chain     label90
740bMC     keyl90        chain     label90
730cAC                   if        %found
730cAc                   if        $slvlopickqty <= oprfqto
720cAC                   exsr      scr06bi
730cAc                   else
730cAC                   exsr      scr06ci
730cAC                   endif
730cAC                   endif
740aAc                   else
740aAc                   exsr      scr06bi
730cAC                   endif
720cAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
720cAc                             and oprfui <>'Y'
720cAC                   exsr      scr04i
740aAC                   when      $ifsltmth = '6' and lbutyp =  'N'
740aAc                             and oprfui = 'Y'
740aA*  Do we allow user to enter a qty
740aAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
740aAc                             and $slvlopickqty > 1
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
740aAc                   eval      kywhse = w1whse
740bDC*    l90key        chain     label90
740bMC     keyl90        chain     label90
740aAC                   if        %found
740aAc                   if        $slvlopickqty <= oprfqto
740aAC                   exsr      scr06bi
740aAc                   else
740aAC                   exsr      scr06ci
740aAC                   endif
740aAC                   endif
730hAc                   else
730bAc                   exsr      scr06bi
740aAC                   endif
740aAC                   when      $ifsltmth = '6' and lbutyp =  'N'
740aAc                             and oprfui <>'Y'
740aAC                   exsr      scr04i
700fA*  If license options
700fAC                   when      oprflc = 'Y'
700fAC                   exsr      scr05i
700fA*  If User can enter quantity
700fAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
700fAc                             and $slvlopickqty > 1
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
700fA*  If RF Pick Allow Qty Entry = 'Y' and
700fA*  label qty < When Quantity over value
700fA*  then go to label screen.
700fAC                   if        oprfpm = '2'
700fAC                             and oprfqt = 'Y'
700fAc                   eval      kywhse = w1whse
740bDC*    l90key        chain     label90
740bMC     keyl90        chain     label90
700fAC                   if        %found
710aDc*                  if        lbqpck <  %DEC(oprfqto:3:0)
720aDc**                 if        lbqpck <=  oprfqto
720aMc                   if        $slvlopickqty <= oprfqto
700fAC                   exsr      scr06i
700fAc                   else
700fAC                   exsr      scr06ci
700fAC                   endif
700fAC                   endif
700fAc                   else
700fAC                   exsr      scr06ci
700fAC                   endif
700fA*  Scan to pallet
700fAC                   other
700fAC                   exsr      scr06i
700fAC                   endsl
740eAc                   eval      ufinfl = *on
700fA*
700fAC     endup12       endsr
740eA*----------------------------------------------------------------
740eA*
740eA*  ZZUPD12v Update for screen 12v.
740eA*
740eAC     zzupd12v      begsr
740eA*
740eA*
740eAC                   eval      error = *off
740eAC                   eval      first6 = *off
740eAC                   eval      first6a = *off
740eAc                   if        *in51
740eAc                   exsr      zzgets
740eAC                   if        error = *on
740eAC                   goto      endup12v
740eAC                   endif
740eA
xxxx c                   if        not prime
740eA*    Call program that will (if necessary) ...
740eA*      - Prompt user to pull pallet.
740eA*      - Have user verify license being pulled.
740eA*      - Update license information.
740eA
740eAC                   exsr      zzzclr$lt210
740eAC                   eval      $tcmd  = '*PULDROP'
740eAC                   eval      $twhse = w1whse
740eAC                   eval      $twhdp = #fromslwhdp
740eAC                   eval      $tslot = #fromsldisp
740eAC                   eval      $titem = #fromslitem
740eAC                   eval      $titemdsc = #fromithead
740eAC                   eval      $tlic# = #fromToLcns
740eAC                   exsr      zzzcall$lt210
740eA
740eA
740eAC                   if        $treturn = '*CANCEL'
740eAC                   goto      endup12v
740eAC                   endif
740eA
740eAC                   if        $treturn = '*NOTFND'
740eA
740eAC                   exsr      zzzclr$lt210
740eAC                   eval      $tcmd   = '*PULRTN'
740eAC                   eval      $twhse  = $pwhse
740eAC                   eval      $twhdp  = lbwhdp
740eAC                   eval      $tslot  = lbdisp
740eAC                   eval      $titem  = lbitem
740eAC                   eval      $titemdsc = itdesc
740eAC                   eval      $tlic# = #fromToLcns
740eAC                   exsr      zzzcall$lt210
740eA
740eAC                   eval      nxtscr = '01'
740eAC                   goto      endup12v
740eAC                   endif
xxxx c                   endif
740eAc                   endif
740eA*
740eA*  Scanned pick location.
740eAC                   eval      first2 = *on
740eA*
740eA*  Check to see if UPC exist
740eAc                   eval      kywhse = w1whse
740eAC                   eval      upcyes = *off
740eAC     keyl90        chain     label90
740eAC                   if        %found(label90)
740eAC     upcky         chain     upc5
740eAC                   if        %found(upc5)
740eAC                   eval      upcyes = *on
740eAC                   else
740eAC                   eval      savupc = *blanks
740eAC                   endif
740eAC                   endif

740eA*  Check options to determine next screen
740eAC                   select
740eA*  If Saval, Seafood
740eAC                   when      client = Saval
740eAC                             and type = 'SEA'
740eAC                   exsr      scr06bi
740eA*  pick to weight
740eAC                   when      $ifsltmth = '2' and umFlexPickFlag = 'P2W'
740eAC                             or $ifsltmth = '3' and umFlexPickFlag = 'P2W'
740eAC                   exsr      scr06ei
740eA*  uci selection
740eAC                   when      $ifsltmth = '2' and ptsub <>'BULK'or
740eAC                             $ifsltmth = '3' and ptsub <>'BULK'
740eAC                   exsr      scr06di
740eA*  If UPC options,
740eAC                   when      oprfuc = 'Y'
740eAC                             and upcyes
740eAc                             and oprfui <> 'Y'
740eAC                   exsr      scr04i
740eAC                   when      oprfuc = 'Y'
740eAC                             and upcyes
740eAc                             and oprfui = 'Y'
740eAc                             and ($ifsltmth >='4' and $ifsltmth <='6')
740eAC                   exsr      scr06bi
740eAC                   when      oprfuc = 'Y'
740eAC                             and upcyes
740eAc                             and oprfui = 'Y'
740eAc                             and ($ifsltmth <'4' or $ifsltmth > '6')
740eAC                   exsr      scr04i
740eA*  If UPC selection turned on at the item
740eAC                   when      $ifsltmth = '4'
740eAc                             and oprfui = 'Y'
740eA*  Do we allow user to enter a qty
740eAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
750tAc                             and oprfqto > 0
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750tDc*                  eval      combo = *on
750kAc                   endif
750hDc*****                        and $slvlopickqty > 1
740eAc                   eval      kywhse = w1whse
740eAC     keyl90        chain     label90
740eAC                   if        %found
740eAc                   if        $slvlopickqty <= oprfqto
740eAC                   exsr      scr06bi
740eAc                   else
750tAc                   eval      combo = *on
740eAC                   exsr      scr06ci
740eAC                   endif
740eAC                   endif
740eAc                   else
740eAc                   exsr      scr06bi
740eAC                   endif
740eAC                   when      $ifsltmth = '4'
740eAc                             and oprfui <>'Y'
740eAC                   exsr      scr04i
740eAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
740eAc                             and oprfui = 'Y'
740eA*  Do we allow user to enter a qty
740eAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
750tAc                             and oprfqto > 0
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750tDc*                  eval      combo = *on
750kAc                   endif
750hDc****                         and $slvlopickqty > 1
740eAc                   eval      kywhse = w1whse
740eAC     keyl90        chain     label90
740eAC                   if        %found
740eAc                   if        $slvlopickqty <= oprfqto
740eAC                   exsr      scr06bi
740eAc                   else
740eAC                   exsr      scr06ci
740eAC                   endif
740eAC                   endif
740eAc                   else
740eAc                   exsr      scr06bi
740eAC                   endif
740eAC                   when      $ifsltmth = '5' and lbutyp <> 'N'
740eAc                             and oprfui <>'Y'
740eAC                   exsr      scr04i
740eAC                   when      $ifsltmth = '6' and lbutyp =  'N'
740eAc                             and oprfui = 'Y'
740eA*  Do we allow user to enter a qty
740eAc                   if        oprfqt =  'Y' and itcwgt <> 'Y'
750tAc                             and oprfqto > 0
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750tAc                             and oprfqto > 0
750tDc*                  eval      combo = *on
750kAc                   endif
750hDc****                         and $slvlopickqty > 1
740eAc                   eval      kywhse = w1whse
740eAC     keyl90        chain     label90
740eAC                   if        %found
740eAc                   if        $slvlopickqty <= oprfqto
740eAC                   exsr      scr06bi
740eAc                   else
740eAC                   exsr      scr06ci
740eAC                   endif
740eAC                   endif
740eAc                   else
740eAc                   exsr      scr06bi
740eAC                   endif
740eAC                   when      $ifsltmth = '6' and lbutyp =  'N'
740eAc                             and oprfui <>'Y'
740eAC                   exsr      scr04i
740eA*  If license options
740eAC                   when      oprflc = 'Y'
740eAC                   exsr      scr05i
740eA*  If User can enter quantity
740eAC                   when      oprfqt = 'Y' and itcwgt <> 'Y'
750kAc                             or oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   if        oprfqtcw = 'Y' and itcwgt = 'Y'
750kAc                   eval      combo = *on
750kAc                   endif
740eA*  If RF Pick Allow Qty Entry = 'Y' and
740eA*  label qty < When Quantity over value
740eA*  then go to label screen.
740eAC                   if        oprfpm = '2'
740eAC                             and oprfqt = 'Y'
740eAc                   eval      kywhse = w1whse
740eAC     keyl90        chain     label90
740eAC                   if        %found
740eAc                   if        $slvlopickqty <= oprfqto
740eAC                   exsr      scr06i
740eAc                   else
740eAC                   exsr      scr06ci
740eAC                   endif
740eAC                   endif
740eAc                   else
740eAC                   exsr      scr06ci
740eAC                   endif
740eA*  Scan to pallet
740eAC                   other
740eAC                   exsr      scr06i
740eAC                   endsl
740eAc                   eval      x = x-1
740eAc                   eval      ufinfl = *on
750oAc                   eval      saveaisle = lbaisl
750oAc                   eval      saveloc = lbloc
750oAc                   eval      savelvl = lbrlvl
750oAc                   eval      savehand = lbhand
740eA*
750uA /free
750uA    // Print labels if 'Before Pick' option taken, which is the default
750uA    if opsppba <> 'A';
750uA      if comboLabel or bulkLabel;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1: '');
750uA      else;
750uA        GetLabelZPL('*GETLABEL': w2rtid: 0:
750uA                     w2lbl: 1: lbqpck: '');
750uA      endif;
750uA    endif;
750uA /end-free
740eAC     endup12v      endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZUPD14 -  Screen 14
720cA*
720cAC     zzupd14       begsr
720cA*
740lDc*                  if        oprfzp = 'M'
740lDC*                  exsr      scr02i
740lDc*                  else
720cA /free
740lA    reccycle = 0;
740lA    select;
740lA      when oprfzp = 'N';
740lA        exsr scr23i;
740lA      other;
740lM        if oprfzp = 'M';
740lM          exsr scr02i;
740lM        else;
720cA          if oprfqt = 'Y' and itcwgt <> 'Y'
751dA             and not zonepickup
720cA             and $slvlopickqty > oprfqto;
720cA            exsr scr06ci;
720cA          else;
752vA            if prime;
752vA              // load merge work file
752vA              exsr buildSPmrgwrk;
752vA              exsr scr88i;
752vA            else;
720cA              exsr scr06ai;
752vA            endif;
720cA          endif;
740lM        endif;
740lA    endsl;
752dA    firstzonepick = *off;
720cA /end-free
740lDc*                  endif
720cA*
720cAC     endup14       endsr
720cA*----------------------------------------------------------------
720cA*
720cA*  ZZUPD15  Update for screen 15.
720cA*
720cAC     zzupd15       begsr
720cAC                   eval      error = *off
720cA*
720cA*   Start scanned transaction
720cA*
720cA*
720cA*   Initialize totals
720cA*
720cAC                   eval      $slvsoloqavl = 0
720cAC                   eval      ttllic = 1
720cAC                   eval      ttlpcs = $slasopieces
720cAC                   eval      ttlcub = $slasocube
720cAC                   eval      ttlwgt = $slasoweight
720cAc                   eval      wkrtpo = ptrtpo
720cAc
750lA /free
750lA    // display the pallet summary screen
750lA    if prime and opSPps = 'Y';
750lA      if MTRN = 'N';
750lA        nxtscr = '82';
750lA        exsr scr82i;
750lA        leavesr;
750lA      endif;
750lA    endif;
750lA /end-free
720cA*
720cA*   Display screen to scan label.
720cA*
720cAc                   if        mtrn = 'Y'
720cAC                   exsr      scr01i
720cAc                   else
720cAC                   if        oprfpm = '2'
720cAc                   eval      slwemp# = $emp#
720cAC                   exsr      getlowlimit
720cAc                   exsr      scr11i
720cAC                   else
720cAC                   exsr      scr02i
720cAC                   endif
720cAC                   eval      firstzonepick = *on
720cAc                   endif
720cA*
720cAC     endup15       endsr
720dA*----------------------------------------------------------------
720dA*
720dA*  ZZUPD16  Update for screen 16.
720dA*
720dAC     zzupd16       begsr
720dAC                   eval      error = *off
720dAc
720dA*
720dA*   Display screen to scan label.
720dA*
720dA /free
720dA   select;
720dA     when cshrt = 'Y';
720dA       select;
740eM         when wherefrom = '12 ' or
740eA              wherefrom = '12V';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid = 'SHORTS ';
720dA           w6cnt1 = 0;
720dA           exsr zzexcp;
720dA           exsr zznxt;
720dA         when wherefrom = '03 ';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid = 'SHORTS ';
720dA           exsr zzexcp;
720dA           w6cnt1 = *zero;
720dA           exsr zznxt;
720dA           $newsl = ' ';
720dA         when wherefrom = '04 ';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid = 'SHORTS ';
720dA           exsr zzexcp;
720dA           w6cnt1 = *zero;
720dA           exsr zznxt;
720dA         when wherefrom = '05 ';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid =  'SHORTS ';
720dA           exsr zzexcp;
720dA           w6cnt1 = *zero;
72ccA           exsr zznxt;
720dA         when wherefrom = '06 '
720dA           or wherefrom = '06A'
720dA           or wherefrom = '06B'
720dA           or wherefrom = '06C'
730qM           or wherefrom = '06D'
730qA           or wherefrom = '06E'
730qA           or wherefrom = '06F';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid =  'SHORTS ';
720dA           exsr zzexcp;
72ccA           exsr zznxt;
720dA         when wherefrom = '07 ';
720dA           *inkj = *on;
720dA           cmdtkn = *on;
720dA           sxerid = 'SHORTS ';
720gA           if combo;
720gA           else;
720dA           w6cnt1 = w6cnt1-1;
720gA           endif;
720dA           exsr zzexcp;
720dA           exsr zznxt;
720dA       endsl;
720dA     other;
720dA       nxtscr = wherefrom;
720dA   endsl;
720dA /end-free
720dA*
720dAC     endup16       endsr
720hA*----------------------------------------------------------------*********
720hA*
720hA*  ZZUPD17  Update for screen 17.
720hA*
720hAC     zzupd17       begsr
720hAC                   eval      error  = *off
720hA
752gAc                   if        DonewithWgt = *off
720hA*  Record weight.
720hA* Fill r#header ds
720hAC                   eval      $hdrcommand = 'weight'
720hAC                   time                    curtime
720hAC                   eval      $hdrtimestamp = %char(curtime)
720hAC                   eval      $slcwitman# = #job
720hAC                   eval      $slcwitrn# = w17trn#
720hAC                   eval      $slcwilbl# = w17lbl#
720hAC                   eval      $slcwistop = w17stop
720hAC                   eval      $slcwiitem = w17item
720hAC                   eval      $slcwiweight = $slscoweight
720hAc                   eval      $slcwivalue =  w7cwgt
720hAC                   if        *inkh
720hAC                   eval      $slcwiexcep = 'Y'
720hAC                   else
720hAC                   eval      $slcwiexcep = 'N'
720hAC                   endif
720hAC*                  eval      $slcwirnglow = lwrng
720hAC*                  eval      $slcwirnghigh = hirng
720hAC                   eval      $slcwirnglow = ilrng
720hAC                   eval      $slcwirnghigh = ihrng
720hAC                   eval      $slcwiseq# = 0
720hAC                   eval      $slcwientwgt = cwgt
720hAC                   eval      $slcwienttype = 'Pounds'
720hAc                   if        BegKiloLbs = 'K'
720hAC                   eval      $slcwienttype = 'Kilograms'
720hAc                   endif
720hAC                   eval      $slcwilater = 'N'
720hAC                   eval      $pheader = $header
720hAC                   eval      $pfields = $slweightin
720hAC                   exsr      writelog
720hAC                   call      'VOSELECT'
720hAC                   parm      '*none'       $pdqlib
720hAC                   parm      '*none'       $pdqnameout
720hAC                   parm      '*none'       $pdqkey
720hAC                   parm                    $pheader
720hAC                   parm                    $pfields
720hAC                   parm                    $prtnfields
720hAC                   eval      $slweightout = $prtnfields
720hA*
752gAc                   endif
720hAC                   if        $slcwoflag <> '1'
720hAC                   eval      error = *on
720hAC                   eval      *in21 = *on
720hAC                   eval      *in01 = *on
720hAC**                 eval      errmsg = *blanks
720hAC                   eval      errmsg = 'Error occurred in VOSELECT'
720hAC                   exsr      zm9898
720hAC                   eval      error = *on
720hAC                   goto      endup17
720hAC                   else
720hA*  Determine what screen to display and/or update pick qty.
720hA /free
720hA     w17cnt1 = w17cnt1 + 1;
752gA     if *inkf = *on;
752gA       w17cnt1 = w18cnt2;
752gA     endif;
720hA     wtchk = '0';
720hA     w7cwgt = ' ';
720hA     ovrrid = '0';
752gA     if w17cnt1 > 0 and not combo;
752gA       *in64 = '1';
752gA     else;
752gA       *in64 = '0';
752gA     endif;
720hA /end-free
720hAC                   exsr      zznxt
720hAC                   endif
720hA*
720hA*
720hAc     endup17       endsr
720hA*----------------------------------------------------------------*********
720hA*
720hA*  ZZUPD18  Update for screen 18.
720hA*
720hAC     zzupd18       begsr
720hAC                   eval      error = *off
720hAC                   eval      first18 = *on

720hAc                   if        foundWLabel = *on
720hAc                   eval      w17trn# = $slc2otrn#
720hAc                   eval      w17lbl# = $slc2olbl#
720hAc                   eval      w17stop = 0
720hAc                   eval      w17item = $slc2oitem
720hAC                   exsr      scr17i
720hAC                   goto      endup18
720hAC                   endif

720hAC     endup18       endsr
720hA*----------------------------------------------------------------*********
720hA*
720hA*  ZZUPD19  Update for screen 19.
720hA*
720hAC     zzupd19       begsr
720hAC                   eval      error = *off
720hAC                   if        first19 = *off
720hAC                   eval      w18cnt1 = *zero
720hAC                   eval      w18cnt2 = $slgwoqty
720hAC                   endif
720hAc                   eval      w18oitem = %trim($slgwoitem) + ' ' +
720hAc                             %trim($slgwoitemdsc)

720hAC                   eval      first19 = *on
720hAc                   eval      w17trn# = $slgwotrn#
720hAc                   eval      w17lbl# = $slgwolbl#
720hAc                   eval      w17stop = 0
720hAc                   eval      w17item = $slgwoitem
720jAC                   eval      WLUserChoice = *on
720hAC                   exsr      scr17i
720hAC                   goto      endup19

720hAC     endup19       endsr
720lA*----------------------------------------------------------------
720lA*
720lA*  ZZUPD20  Update for screen 20.
720lA*
720lAC     zzupd20       begsr
720lAC                   eval      error = *off
720lAc
720lA*
720lA /free
720lA   select;
720lA     when eupc  = '1';
720lA       cmdtkn = *on;
720lA       sxerid = 'BADUPC ';
720lA       w6cnt1 = w6cnt1 + 1;
      /free
750uA   // Print labels if 'After Pick' option taken
750uA   if opsppba = 'A';
750uA     GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: w6cnt1: w6cnt1: '  ');
750uA   endif;
      /end-free
730hA       first6 = *on;
730hD         //nxtscr = wherefrom;
720lA       exsr zzexcp;
730hD       //if w6cnt1 = w6cnt2;
730hD         //exsr zznxt;
730hD       //endif;
720lA     when eupc  = '2';
720lA       cmdtkn = *on;
720lA       sxerid = 'NOUPC  ';
720lA       // if no upc have been scanned we will have user enter a
720lA       // quantity since the product has no upc's
720lA       if w6cnt1 = 0;
730hD         //exsr scr06i;
740eA         // if no upc have been scanned user will be required to
740eA         // scan the pick label instead.
750tA         // belt printer users will goto screen 06c instead
750tA         if usingBeltPrt;
750tA           combo = *on;
750tA         else;
720lA           $ifsltmth = '1';
750tA         endif;
730hA         exsr zznxt;
      /free
750uA   // Print labels if 'After Pick' option taken
750uA   if opsppba = 'A';
          // Get ZPL for all labels
750uA     GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: w6cnt2: '');
750uA   endif;
      /end-free
730hA         leavesr;
720lA       else;
720lA        w6cnt1 = w6cnt1 + 1;
      /free
750uA   // Print labels if 'After Pick' option taken
750uA   if opsppba = 'A';
          // Get ZPL for label
750uA     GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: w6cnt1: w6cnt1: '  ');
750uA   endif;
      /end-free
730hA        first6 = *on;
730hD          //nxtscr = wherefrom;
720lA       endif;
720lA       exsr zzexcp;
720lA   endsl;
730hA   // catch weight item
730hA   if itcwgt = 'Y';
ADWbA     if ititem = '27801' and
ADWbA        client = andrews;
ADWbA       $slscoweight = 5.10;
ADWbA       lwrng = 0;
ADWbA       hirng = 0;
ADWbA       cwgt = 5.10;
ADWbA       exsr zzupd7;
ADWbA     else;
730hA       // has user already indicated weigh later for label
730hA       exsr Chk4Skipcw;
730hA       if foundWL = *off
730hA          and DonewithWgt = *off;
730hA         exsr scr07i;
730hA       else;
730hA         exsr zznxt;
730hA       endif;
ADWbA     endif;
730hA     leavesr;
730hA   else;

SVLgA     if client = saval
SVLgA        and type = 'CHK'
SVLhA        or client = saval
SVLhA        and type = 'SKI';
SVLgA       exsr scr07i;
SVLgA       leavesr;
SVLgA     endif;

730hA   endif;

730hD       //exsr zznxt;
720lA   if w6cnt1 = w6cnt2;
720lA     exsr zznxt;
730jA     leavesr;
720lA   endif;
730jA   nxtscr = wherefrom;
720lA /end-free
720lA*
720lAC     endup20       endsr
730qA*----------------------------------------------------------------
730qA*
730qA*  ZZUPD21  Update for screen 21.
730qA*
730qAC     zzupd21       begsr
730qAC                   eval      error = *off
730qAc
730qA*
730qA*   Display screen to scan label.
730qA*
730qA /free
730qA   select;
730qA     when cdone = 'Y';
730qA       select;
730qA         when wherefrom = '06 '
730qA           or wherefrom = '06A'
730qA           or wherefrom = '06B'
730qA           or wherefrom = '06C'
730qA           or wherefrom = '06D'
730qA           or wherefrom = '06E'
730qA           or wherefrom = '06F';
730qA           *inkf = *on;
730qA           cmdtkn = *on;
730qA           exsr zznxt;
730qA       endsl;
730qA     other;
730qA       nxtscr = wherefrom;
730qA   endsl;
730qA /end-free
730qA*
730qAC     endup21       endsr
740dA*----------------------------------------------------------------
740dA*
740dA*  ZZUPD22  Update for screen 22.
740dA*
740dAC     zzupd22       begsr
740dAC                   eval      error = *off
740dAc
740dA*
740dA*   Display screen to scan label.
740dA*
740dA /free
740dA   select;
740dA     when leavesus = 'Y';
740dA       // write and exception
740dA       exsr zzexcpsus;
740dA       // need to get back to sc1
740dA       nxtscr = '01 ';
740dA       exsr sc1;
740dA     other;
750lA       exsr zzreset;
750xA       exsr zzundoauto;
740dA       exsr scr01i;
740dA       eval w1trn# = pttrn#;
740dA       leavesr;
740dA   endsl;
740dA /end-free
740dA*
740dAC     endup22       endsr
740lA*----------------------------------------------------------------
740lA*
740lA*  ZZUPD23  Update for screen 23.
740lA*
740lAC     zzupd23       begsr
740lA*
740lA*  If zone pickup completed. Send complete to voselect
740lA*
740lAc                   if        zcmpl= 'Y'
740lA * complete
740lAC                   eval      $hdrcommand = 'complete2'
740lAC                   time                    curtime
740lAC                   eval      $hdrtimestamp = %char(curtime)
740lAC                   eval      $slc2itman# = #job
740lAC                   eval      $slc2itrn# = w1trn#
740lAC                   eval      $pheader = $header
740lAC                   eval      $pfields = $slcompl2in
740lAC                   exsr      writelog
740lAC                   call      'VOSELECT'
740lAC                   parm      '*none'       $pdqlib
740lAC                   parm      '*none'       $pdqnameout
740lAC                   parm      '*none'       $pdqkey
740lAC                   parm                    $pheader
740lAC                   parm                    $pfields
740lAC                   parm                    $prtnfields
740lAC                   eval      $slcompl2out = $prtnfields
740lA*
740lAC                   if        $slc2oerrnum <> 0
740lAC                   eval      error = *on
740lAC                   eval      *in23 = *on
740lAC                   eval      *in03 = *on
740lAc                   eval      errmsg = 'Label ' +
740lAc                             %char($slc2olbl#) +
740lAc                             ' needs weights'
740lAC                   exsr      zm9898
740lAc                   exsr      scr18i
740lAC                   goto      endup23
740lAC                   else
740lA
740lA*   Display SC8 transaction complete message.
751uAC                   if        usingBigPal
751uAC                   exsr      scr86i
751uAC                   else
740lAC                   exsr      scr08i
751uAC                   endif

740lAc                   endif
740lA
740lAC                   endif
740lA*
740lAC     endup23       endsr
750pA*----------------------------------------------------------------
750pA*
750pA*  ZZUPD81  Update for screen 81.
750pA*
750pAC     zzupd81       begsr
      /free
        // Record printer that is being used

        deviceType = 'BLUPRT';
        SetEquipId(w1whse: #user: deviceType: printerId: #pgm: equipMsg);
        if printerId = 'NONE';
          usingBeltPrt = *off;
        endif;

        // Record device that is being used

        deviceType = 'ANDHND';
        SetEquipId(w1whse: #user: deviceType: printerId: #pgm: equipMsg);
751uA   // Determine next screen
751uA
751uA   if getJackCode;
751uA     nxtscr = '87';
751uA   else;
752lD     //nxtscr = '01';
752lM     exsr scr01i;
751uA   endif;

      /end-free
     C                   endsr
750lA*----------------------------------------------------------------
750lA*
750lA*  ZZUPD82  Update for screen 82
750lA*
750lAC     zzupd82       begsr
750lAC                   eval      error = *off
750lA*
750lA*   Start scanned transaction
750lA*
750lA*
750lA*   Initialize totals
750lA*
750lAc                   if        OPVMLT  = 'Y'
750lAc                   else
750lAC                   eval      ttllic = 1
750lAC                   eval      ttlpcs = $slasopieces
750lAC                   eval      ttlcub = $slasocube
750lAC                   eval      ttlwgt = $slasoweight
750lAc                   eval      wkrtpo = ptrtpo
750lAc                   endif
750lAc
750lA*
750lA*   Display screen to scan label.
750lA*
750lAC                   if        oprfpm = '2'
750lAc                   eval      slwemp# = $emp#
750lAC                   exsr      getlowlimit
750lAc                   eval      FirstMslot = *on
750lAc                   exsr      scr11i
750lAC                   else
750lAC                   exsr      scr02i
750lAC                   endif
750lAC                   eval      firstzonepick = *on
750lA*
750lAC     endup82       endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  ZZUPD84  Update for screen 84
750qA*
750qAC     zzupd84       begsr
      /free

        // Jump to selected label


      /end-free
     C                   endsr
750qA*----------------------------------------------------------------
750qA*
750qA*  ZZUPD85  Update for screen 85
750qA*
750qAC     zzupd85       begsr
      /free

        // Get label(s) ZPL

        select;

          when reprintSeqChr = 'SETHED';
            for i = 1 to trncnt;
              GetLabelZPL('*GETFMTR': trnlst(i).rtid: trnlst(i).trn: 0:0:0:
                          'SETHED');
              if error;
                error = *off;
                errmsg = '';
              endif;
            endfor;

          when reprintSeqChr = 'SETSUM';
            for i = 1 to trncnt;
              GetLabelZPL('*GETFMTR': trnlst(i).rtid: trnlst(i).trn: 0:0:0:
                          'SETSUM');
              if error;
                error = *off;
                errmsg = '';
              endif;
            endfor;

          when reprintSeqChr = 'PALLET';
            for i = 1 to trncnt;
              GetLabelZPL('*GETFMTR': trnlst(i).rtid: trnlst(i).trn: 0:0:0:
                          'PALLET');
              if error;
                error = *off;
                errmsg = '';
              endif;
            endfor;

          other;
            if reprintType = '2';
              GetLabelZPL('*GETLABELR': lastRte: 0: lastLbl:
                          reprintSeq: lastToSeq: '');
            else;
              GetLabelZPL('*GETLABELR': lastRte: 0: lastLbl:
                          reprintSeq: reprintSeq: '');
            endif;

        endsl;

      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  ZZUPD86  Update for screen 86
751uA*
751uAC     zzupd86       begsr
      /free

        // Print BIGPAL label using PFMT *REPRINT

        for i = 1 to trncnt;

          jWhse = %editc(w1whse: 'X');
          jRtid = trnlst(i).rtid;
          jValue = %editc(trnlst(i).trn: 'X');

      /end-free

     C                   call      'OR640J'
     C                   parm      '*REPRINT'    jCmd              8
     C                   parm                    jWhse             3
     C                   parm                    jRtid             5
     C                   parm      ' '           jRte              5
     C                   parm      bigPalDev     jTruk            10
     C                   parm                    jValue            7
     C                   parm      'S'           jType             1

      /free

        endfor;

        // Display End of Tran screen

        exsr scr08i;

      /end-free
     C                   endsr
751uA*----------------------------------------------------------------
751uA*
751uA*  ZZUPD87  Update for screen 87
751uA*
751uAC     zzupd87       begsr
      /free

760aA   exsr zzresetauto;
760aA   if pjtype >= '1' and pjtype <= '3';
760aA     pjtype# = %dec(%subst(pjtype:1:1):1:0);
760aA   endif;
760AA   dmdrte = ' ';
760aA   dmdzone = ' ';
752lD   //nxtscr = '01';
752lM   exsr scr01i;

      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZUPD88  Update for screen 88
752vA*
752vAC     zzupd88       begsr
      /free

        error = *off;
        first88 = *on;

        wrkrte  = %subst(w88lbl:1:5);
        wrkunq  = %subst(w88lbl:6:5);
        mergelabel = 0;
        mergetran# = 0;
        exec sql select * into :mrgrec
             from SPmrgwrk
             where mgjob = :#job
               and mgwhse = :lbwhse
               and mgprid = :wrkrte
               and mgpup# = :wrkunq;
        if sqlstt = sqlSuccess;
          mergelabel = mglbl#;
          mergetran# = mgtrn#;
        endif;

         // this was copied from zzupd6a
         // Print labels if 'After Pick' option taken
         if opsppba = 'A';
           if comboLabel or bulkLabel;
             if zonepickup;
               GetLabelZPL('*GETLABEL': w2rtid: 0: mergelabel:
                            1: 1: '');
             //else;
               //GetLabelZPL('*GETLABEL': w2rtid: 0: w2lbl: 1: 1: '');
             endif;
           else;
             if zonepickup;
               GetLabelZPL('*GETLABEL': w2rtid: 0:
                            mergelabel: w6acnt1+1: W6acnt1+1: '');
             //else;
               //GetLabelZPL('*GETLABEL': w2rtid: 0:
               //             w2lbl: w6acnt1+1: W6acnt1+1: '');
             endif;
           endif;
         endif;
         // Assume error means Merge label not printed
         if zplRtnCode <> '*OK';
           errmsg = '';
         endif;
      /end-free
     *  Scan to pallet
     C                   add       1             w6acnt1
     C                   z-add     w6acnt1       w6cnt1
     C                   z-add     w6acnt2       w6cnt2
      /free
        // need to mark the SPmrgwrk record as scanned.
        // if they scan something that is valid but not in our file
        // we will just mark another record for that label.

        // if they scan something that is valid and in our file as
        // aleady scanned, we will mark another record for that label.
        // if it truely was scanned, it would fail the edit in pickuci

          // this is by trax# scan = ' '
            //wrkrte  = %subst(w88lbl:1:5);
            //wrkunq  = %subst(w88lbl:6:5);
          exec sql update SPmrgwrk set
                       mgscan = 'Y'
                   where mgjob = :#job
                     and mgwhse = :lbwhse
                     and mgprid = :wrkrte
                     and mgpup# = :wrkunq
                     and mgscan = ' ';

          if sqlstt = sqlSuccess;
            // reduce the remaining pcs
            w88rpcs = w88rpcs - 1;
            // update the summary file with the qty picked
            chain (#job: lbwhse: mergetran#: mergelabel) spmrgsum;
            if %found(spmrgsum);
              if mspick = ' ';
                msqpck = msqpck + 1;
                update msurec;
              endif;
            else;
            endif;
          endif;

          if sqlstt <> sqlSuccess;
            // this is by trax# scan = 'S' if success will need to mark
            // another record as S to replace this short.
            wrkrte  = %subst(w88lbl:1:5);
            wrkunq  = %subst(w88lbl:6:5);
            exec sql update SPmrgwrk set
                         mgscan = 'Y'
                     where mgjob = :#job
                       and mgwhse = :lbwhse
                       and mgprid = :wrkrte
                       and mgpup# = :wrkunq
                       and mgscan = 'S';

            if sqlstt = sqlSuccess;
              // update the summary file with the qty picked
              chain (#job: lbwhse: mergetran#: mergelabel) spmrgsum;
              if %found(spmrgsum);
                if mspick = ' ';
                  msqpck = msqpck + 1;
                  update msurec;
                endif;
              else;
              endif;
              // now go update the first available record for this label
              // to replace the one that we assumed short but they scanned
              exec sql update SPmrgwrk set
                           mgscan = 'S'
                       where mgjob = :#job
                         and mgwhse = :mgwhse
                         and mgtrn# = :mgtrn#
                         and mglbl# = :mglbl#
                         and mgclb# = :mgclb#
                         and mgscan = ' '
                         fetch first 1 rows only;
              if sqlstt = sqlSuccess;
                // reduce the remaining pcs
                w88rpcs = w88rpcs - 1;
                // update the summary file with the qty picked
               //chain (#job: lbwhse: mergetran#: mergelabel) spmrgsum;
                //if %found(spmrgsum);
                  //if mspick = ' ';
                    //msqpck = msqpck + 1;
                    //update msurec;
                  //endif;
                //else;
                //endif;
              endif;
            endif;
          endif;
      /end-free

      /free
         if zonepickup and getMrgWgt and itcwgt = 'Y';
           exsr scr07i;
         else;
           // do we have more to pickup for zonepickup
           morepickup = *off;
           if prime and zonepickup;

             exec sql select * into :mrgrec
                  from SPmrgwrk
                  where mgwhse = :lbwhse
                    and mgjob  = :#job
                    and mgscan = ' '
                    fetch first 1 rows only;
             If sqlstt = sqlSuccess;
               morepickup = *on;
             else;
               morepickup = *off;
             endif;
           endif;
           exsr zznxt;
         endif;
      /end-free

     C                   eval      w6uci = ' '

      /end-free
     C                   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  ZZUPD89  Update for screen 89
752vA*
752vAC     zzupd89       begsr
      /free


      /end-free
     C                   endsr
500dA*----------------------------------------------------------------
500dA*
500dA*  WriteLog    Write log record
500dA*
500dAC     writelog      begsr

750fDC**                 exsr      getcurrstamp
750fA /free
750fA    GetCurrStamp();
750fA /end-free

     C                   eval      SlgTyp = 'Rcv'
     C                   eval      SlgBuf = %trim($hdrcommand) + '/'
     C                                    + $pfields

     C                   eval      slgts     = currstamploc
     C                   eval      slgucs    = currstampuc
     C                   eval      slguser   = #user
     C                   eval      slgjob    = #job
     C                   eval      slgjobnbr = #jobn

     C                   eval      slgsk2 = 0
750fDC**                 eval      SlgIP  = #job
750fMC                   eval      SlgIP  = #pgm
     C                   eval      SlgPortL = 0
     C                   eval      SlgPortC = 0
     C                   select
     C                   when      slgtyp = 'Sel'
     C                             or slgtyp = 'Opn'
     C                             or slgtyp = 'Rcv'
     C                   eval      slgid  = ' '
750fAC                   if        prime
750fAC                   eval      slgid = spUid
750fAC                   endif
     C                   other
     C******             eval      slgid  = tmansnum
     C                   endsl
     C                   write     slgrec
     C
     C                   endsr

752vA*----------------------------------------------------------------
752vA*
752vA*  buildSPmrgwrk Build the merge work file
752vA*
752vAC     buildSPmrgwrk begsr
752vA /free
        w88rpcs = 0;
        if multitran;
          setll ($Emp#:Wktype) sktlbl32;
          dow forever=forever;
            reade ($Emp#:Wktype) sktlbl32;
            if %eof(sktlbl32);
              leave;
            endif;
            exsr writeSPmrgwrk;
          enddo;
        else;
          setll (lbwhse:lbrte:wktype:w1trn#) label32;
          dow forever=forever;
            reade (lbwhse:lbrte:wktype:w1trn#) label32;
            if %eof(label32);
              leave;
            endif;
            exsr writeSPmrgwrk;

          enddo;
        endif;
752vA /end-free
752vAC                   endsr

752vA*----------------------------------------------------------------
752vA*
752vA*  writeSPmrgwrk Write the merge work file
752vA*
752vAC     writeSPmrgwrk begsr
752vA /free
        // need to get the qty picked from the pir label so I only
        // load enough ordp data here
        exec sql select * into :correc
             from label
             where lbwhse = :zp_lbwhse
               and lblbl# = :zp_lbctr#;
        if sqlstt <> sqlSuccess;
        endif;

        // need to get the ordp data for the lbctr# label
        setll (z_lbrte: z_lblbl#) ordp5;
        //for i = 1 to z_lbqpck;
        mrgcount = 0;
        // write out summary record used for send Pick Record
          mswhse = zp_lbwhse;
          mstrn# = zp_lbtrn#;
          mslbl# = zp_lblbl#;
          msstop = zp_lbstop;
          msitem = zp_lbitem;
          msdisp = zp_lbdisp;
          msclb# = zp_lbctr#;
          msqpck = 0;
          mspick = ' ';
          msjob  = #job;
          //exec sql insert into SPmrgsum values(:msurec);
          write msurec;
        dow forever = forever;
          reade (z_lbrte: z_lblbl#) ordp5;
          if %eof(ordp5);
            leave;
          endif;
          mrgcount = mrgcount + 1;
          mgprid = zpu_orprid;
          mgpup# = zpu_orpup#;

          mgwhse = zp_lbwhse;
          mgtrn# = zp_lbtrn#;
          mglbl# = zp_lblbl#;
          mgclb# = zp_lbctr#;
          mgqpck = 1;
          mgzone = zp_lbwhdp + zp_lbstyp;
          mgdisp = zp_lbdisp;
          mgdesc = zp_itdesc;
          if mrgcount <= z_lbqpck;
            mgscan = ' ';
            w88rpcs = w88rpcs + 1;
          else;
            mgscan = 'S';
          endif;
          mgjob  = #job;
          exec sql insert into SPmrgwrk values(:mrgrec);
        //endfor;
        enddo;
752vA /end-free
752vAC                   endsr

752vA*----------------------------------------------------------------
752vA*
752vA*  clrSPmrgfiles Clear the mrg files for this job#
752vA*
752vAC     clrspmrgfiles begsr
752vA /free
        // clear SPmrgwrk for Job#
        exec sql delete from SPmrgwrk
         where mgwhse  = :ptwhse
           and mgjob   = :#job;
        if sqlstt <> sqlSuccess;
        endif;
        // clear SPmrgsum for Job#
        exec sql delete from SPmrgsum
         where mswhse  = :ptwhse
           and msjob   = :#job;
        if sqlstt <> sqlSuccess;
        endif;
752vA /end-free
752vAC     endmrgfiles   endsr
752vA*----------------------------------------------------------------
752vA*
752vA*  getspmrgsum   Read summary records fo sending the pick to voselect
752vA*
752vAC     getspmrgsum   begsr
752vA /free
        // process summary file for sending the pick
        if multitran;
          setll (#job: lbwhse: mgtrn#) spmrgsum;
        else;
          setll (#job: lbwhse) spmrgsum;
        endif;
        dow forever = forever;
          if multitran;
            reade (#job: lbwhse: mgtrn#) spmrgsum;
          else;
            reade (#job: lbwhse) spmrgsum;
          endif;
          if %eof(spmrgsum);
            if multitran;
              // do we have more transactions to pickup
              exec sql select * into :msurecdl
              from spmrgsum
              where mswhse  = :ptwhse
                and msjob   = :#job
                and mspick  = ' '
                 fetch first 1 rows only;
              if sqlstt = sqlSuccess;
                exsr scr88i;
                leavesr;
              endif;
            else;
              wktype = 'O';
              zonepickup = '0';
            endif;
            leave;
          endif;
          if mspick = 'Y';
            iter;
          endif;
          // send pick
      /end-free
     C                   eval      $hdrcommand = 'pick'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slpkitman# = #job
     C                   eval      $slpkitrn# = mstrn#
     C                   eval      $slpkilbl# = mslbl#
     C                   eval      $slpkistop = msstop
     C                   eval      $slpkiitem = msitem
     C                   eval      $slpkislot = msdisp
     C                   eval      $slpkiqty = msqpck
      /free
        Select;
          when Prime;
            $slpkmeth = 'SP';
          other;
            $slpkmeth = 'RF';
        endsl;
      /end-free
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slpickin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slpickout = $prtnfields
     *
     C                   if        $slpkoflag <> '1'
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C**                 eval      errmsg = *blanks
     C                   eval      errmsg = 'Error occurred in VOSELECT'
     C                   exsr      zm9898
     C                   goto      endmrgsum
     C                   endif
      /free
          mspick = 'Y';
          update msurec;

          if zonepickup;
            labeldone = %lookup(msclb# : pcklst(*).pcklbl : 1);
          else;
            labeldone = %lookup($slvlolbl# : pcklst(*).pcklbl : 1);
          endif;
          if labeldone <> 0;
            pcklst(labeldone).pckdone = 'Y';
          endif;
        enddo;
      /end-free
     C                   exsr      zzmore
     *  If more labels exist for transaction #
     *   Display SC2 to scan next label.
     C                   if        morelb = 'Y'
     C                   if        oprfpm = '2'
     c                   exsr      scr11i
     c                   else
     C                   exsr      scr02i
     c                   endif
     C                   else
     *   Display SC8 transaction complete message.
     C*  do we have any Zone Pickup
      /free
        if OPRFZP  = 'Y' or
           OPRFZP  = 'N' or
           OPRFZP  = 'M';
          zonepickup = *off;
          slwemp# = $emp#;
          wktype = 'M';
          exsr chkmultitran;
          select;
            when multitran;
              setll ($Emp#: 'M') sktlbl32c;
            other;
              if reccycle >= 2;
                select;
                  when client = cityline
                       or client = harbor
                       or client = greenleaf
                       or client = Colony;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32x;
                  when client = cheney
                       or client = ellenbee
                       or client = royal
                       or client = tpc
                       or client = saval
                       or client = palmer
                       or client = frf
                       or client = Getfresh
                       or client = FoodPro
                       or client = EI
                       or client = WillFoods
                       or client = Panos
                       or client = Renzi
                       or client = AandDFoods
                       or client = Cotati
                       or client = Merit
                       or client = SWT
                       or client = prestofoods
                       or usrDFPICK='Y';
                    setll (w1whse: wkrtid: 'M': w1trn#) label32d;
                  when client = ISupply;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32i;
                  when client = Coastl
                       and psszon = 'REFB';
                    setll (w1whse: wkrtid: 'M': w1trn#) label32i;
                  when client = Accardi
                       and (ptwhdp = 'REF  '
                       or   ptwhdp = 'FRZ  ');
                    setll (w1whse: wkrtid: 'M': w1trn#) label32s;
                  when client = SGC;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32g;
                  when client = Westside;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32w;
                  when client = avalon;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32h;
                  other;
                    setll (w1whse: wkrtid: 'M': w1trn#) label32c;
                endsl;
                //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
              else;
              //setll (w1whse: wkrtid: 'M': w1trn#) label32c;
                select;
                  when client = cityline
                       or client = harbor
                       or client = greenleaf
                       or client = Colony;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
                  when client = cheney
                       or client = ellenbee
                       or client = royal
                       or client = tpc
                       or client = saval
                       or client = palmer
                       or client = frf
                       or client = Getfresh
                       or client = FoodPro
                       or client = EI
                       or client = WillFoods
                       or client = Panos
                       or client = Renzi
                       or client = AandDFoods
                       or client = Cotati
                       or client = Merit
                       or client = SWT
                       or client = prestofoods
                       or usrDFPICK='Y';
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
                  when client = ISupply;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
                  when client = Coastl
                       and psszon = 'REFB';
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
                  when client = Accardi
                       and (ptwhdp = 'REF  '
                       or   ptwhdp = 'FRZ  ');
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
                  when client = SGC;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
                  when client = Westside;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
                  when client = avalon;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
                  other;
                    setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
                endsl;
                //setll (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
              endif;
          endsl;
          dow forevr = forevr;
            select;
              when multitran;
                reade ($Emp#: 'M') sktlbl32c;
                if %eof(sktlbl32c);
                  leave;
                endif;
              other;
              if reccycle >= 2;
                select;
                  when client = cityline
                       or client = harbor
                       or client = greenleaf
                       or client = Colony;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32x;
                    if %eof(label32x);
                      leave;
                    endif;
                  when client = cheney
                       or client = ellenbee
                       or client = royal
                       or client = tpc
                       or client = saval
                       or client = palmer
                       or client = frf
                       or client = Getfresh
                       or client = FoodPro
                       or client = EI
                       or client = WillFoods
                       or client = Panos
                       or client = Renzi
                       or client = AandDFoods
                       or client = Cotati
                       or client = Merit
                       or client = SWT
                       or client = prestofoods
                       or usrDFPICK='Y';
                    reade (w1whse: wkrtid: 'M': w1trn#) label32d;
                    if %eof(label32d);
                      leave;
                    endif;
                  when client = ISupply;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32i;
                    if %eof(label32i);
                      leave;
                    endif;
                  when client = Coastl
                       and psszon = 'REFB';
                    reade (w1whse: wkrtid: 'M': w1trn#) label32i;
                    if %eof(label32i);
                      leave;
                    endif;
                  when client = Accardi
                       and (ptwhdp = 'REF  '
                       or   ptwhdp = 'FRZ  ');
                    reade (w1whse: wkrtid: 'M': w1trn#) label32s;
                    if %eof(label32s);
                      leave;
                    endif;
                  when client = SGC;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32g;
                    if %eof(label32g);
                      leave;
                    endif;
                  when client = Westside;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32w;
                    if %eof(label32w);
                      leave;
                    endif;
                  when client = avalon;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32h;
                    if %eof(label32h);
                      leave;
                    endif;
                  other;
                    reade (w1whse: wkrtid: 'M': w1trn#) label32c;
                    if %eof(label32c);
                      leave;
                    endif;
                endsl;
                //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
              else;
                //reade (w1whse: wkrtid: 'M': w1trn#) label32c;
                select;
                  when client = cityline
                       or client = harbor
                       or client = greenleaf
                       or client = Colony;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32x;
                    if %eof(label32x);
                      leave;
                    endif;
                  when client = cheney
                       or client = ellenbee
                       or client = royal
                       or client = tpc
                       or client = saval
                       or client = palmer
                       or client = frf
                       or client = Getfresh
                       or client = FoodPro
                       or client = EI
                       or client = WillFoods
                       or client = Panos
                       or client = Renzi
                       or client = AandDFoods
                       or client = Cotati
                       or client = Merit
                       or client = SWT
                       or client = prestofoods
                       or usrDFPICK='Y';
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32d;
                    if %eof(label32d);
                      leave;
                    endif;
                  when client = ISupply;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
                    if %eof(label32i);
                      leave;
                    endif;
                  when client = Coastl
                       and psszon = 'REFB';
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32i;
                    if %eof(label32i);
                      leave;
                    endif;
                  when client = Accardi
                       and (ptwhdp = 'REF  '
                       or   ptwhdp = 'FRZ  ');
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32s;
                    if %eof(label32s);
                      leave;
                    endif;
                  when client = SGC;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32g;
                    if %eof(label32g);
                      leave;
                    endif;
                  when client = Westside;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32w;
                    if %eof(label32w);
                      leave;
                    endif;
                  when client = avalon;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32h;
                    if %eof(label32h);
                      leave;
                    endif;
                  other;
                    reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
                    if %eof(label32c);
                      leave;
                    endif;
                endsl;
                //reade (w1whse: wkrtid: 'M': $SLVLOTRN#) label32c;
              endif;
                //if %eof(label32c);
                  //leave;
                //endif;
            endsl;
            if lbvrfy <> ' ';
              iter;
            endif;

            // Check RF Zone Pickup flag for label

            monitor;
              getzpckup (lbwhse: lbctr#: ozrfzp);
              if ozrfzp = 'N';
                iter;
              endif;
            on-error;
            endmon;

            zonepickup = *on;
            first6a = *off;
            first6  = *off;
            leave;
          enddo;
          if zonepickup;
            slwemp# = $emp#;
            wktype = 'M';
            exsr getlowlimit;
      /end-free
     *
     *  Verify label is for entered transaction and still open.
     *
     * Fill r#header ds
     c                   if        zonepickup
     C                   eval      $hdrcommand = 'vfylabelM'
     c                   else
     c                   if        ptsub = 'BULK' and AllowBulk = *on
     C                   eval      $hdrcommand = 'vfylabelB'
     c                   else
     C                   eval      $hdrcommand = 'vfylabel'
     c                   endif
     c                   endif
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slvlitman# = #job
     C*                  movel     lblbl#        $pbarcode
     C                   eval      $pbarcode = %char(lblbl#)
     C                   exsr      zztraxlbl
     C                   move      *blanks       w2lbl#b
     C                   move      $plbl#        w2lbl#b
     C                   z-add     $plbl#        w2lbl
     C                   eval      $slvlilbl# = w2lbl
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slvfylblin
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slvfylblout = $prtnfields
     *
     C                   if        $slvloerrnum <> 0
     C                   eval      error = *on
     C                   else
      /free
        if usingp2p = *on;
          setll ($slvlotrn#) pltsum4;
          dow forevr = forevr;
            reade ($slvlotrn#) pltsum4;
            if %eof(pltsum4);
              leave;
            endif;
            if $slvlopal# > pspal#;
              p2plights ('*SET':$slsropjack:'B':'B':'1');
            else;
              p2plights ('*SET':$slsropjack:'A':'B':'1');
            endif;
          enddo;
        endif;
      /end-free
      /free

       monitor;
         umWhse = lbwhse;
         umlabel('*GET': umRtnCode: umRtnMsg:
                 umWhse: lblbl#:
                 umFlexPickFlag:
                 lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
       on-error;
         umRtnCode = '*ERROR';
       endmon;

       if umRtnCode = '*OK';
         select;
           when umFlexPickFlag = 'P2W';
             pick2lbs = lbswgt;
           when umFlexPickFlag = 'PAQ';
         endsl;
       endif;

      /end-free
     C                   endif
      /free
            exsr zzgeti;
            if firstzonepick = *on;
              exsr scr14i;
              firstzonepick = *off;
            else;
              if oprfzp = 'M';
                exsr scr02i;
              else;
                if oprfqt = 'Y' and itcwgt <> 'Y'
                   and not zonepickup
                   and $slvlopickqty > oprfqto;
                  exsr scr06ci;
                else;
                  if prime;
                    exsr scr88i;
                  else;
                    exsr scr06ai;
                  endif;
                endif;
              endif;
            endif;
          else;
      /end-free
     c* do we need to get weigh later weights
     *   Do we have weights that need to be entered.
     *   End transaction and start idle if all weights entered.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'complete2'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slc2itman# = #job
     c                   if        $slvlotrn# <> 0
     C                   eval      $slc2itrn# = $slvlotrn#
     c                   else
     C                   eval      $slc2itrn# = w1trn#
     c                   endif
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slcompl2in
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slcompl2out = $prtnfields
     *
     C                   if        $slc2oerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C*                  eval      errmsg = $slc2oerrtext
     c                   eval      errmsg = 'Label ' +
     c                             %char($slc2olbl#) +
     c                             ' needs weights'
     C                   exsr      zm9898
     c                   exsr      scr18i
     C                   goto      endmrgsum
     C                   endif

     C                   if        usingBigPal
     C                   exsr      scr86i
     C                   else
     C                   exsr      scr08i
     C                   endif

     C                   endif
     c                   else
     c* do we need to get weigh later weights
     *   Do we have weights that need to be entered.
     *   End transaction and start idle if all weights entered.
     * Fill r#header ds
     C                   eval      $hdrcommand = 'complete2'
     C                   time                    curtime
     C                   eval      $hdrtimestamp = %char(curtime)
     C                   eval      $slc2itman# = #job
     c                   if        $slvlotrn# <> 0
     C                   eval      $slc2itrn# = $slvlotrn#
     c                   else
     C                   eval      $slc2itrn# = w1trn#
     c                   endif
     C                   eval      $pheader = $header
     C                   eval      $pfields = $slcompl2in
     C                   exsr      writelog
     C                   call      'VOSELECT'
     C                   parm      '*none'       $pdqlib
     C                   parm      '*none'       $pdqnameout
     C                   parm      '*none'       $pdqkey
     C                   parm                    $pheader
     C                   parm                    $pfields
     C                   parm                    $prtnfields
     C                   eval      $slcompl2out = $prtnfields
     *
     C                   if        $slc2oerrnum <> 0
     C                   eval      error = *on
     C                   eval      *in23 = *on
     C                   eval      *in03 = *on
     C*                  eval      errmsg = $slc2oerrtext
     c                   eval      errmsg = 'Label ' +
     c                             %char($slc2olbl#) +
     c                             ' needs weights'
     C                   exsr      zm9898
     c                   exsr      scr18i
     C                   goto      endmrgsum
     C                   endif

     C                   if        usingBigPal
     C                   exsr      scr86i
     C                   else
     C                   exsr      scr08i
     C                   endif

     C                   endif
     C                   endif
752vAC     endmrgsum     endsr

750fD **---------------------------------------------------------------
750fD ** getcurrstamp  Get current timestamps
750fD **---------------------------------------------------------------
750fD **
750fDC**   getcurrstamp  begsr
750fD **
750fDC**                 callp     getmicrotime(currstampuc:currstampsys)
750fDC**   currstampsys  adddur    bfcoffset:*H  currstamploc
750fD **
750fDC**                 endsr
ISPaA*----------------------------------------------------------------
ISPaA*  ISupply processing to close and export will call
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZFLAG   Check if there are open flags (shorts) for this
ISPaA*           transaction.
ISPaA*
     C     zzflag        begsr
     C     l90key        setll     label90
     C                   dow       forevr = forevr
     C     l90key        reade     label90                                79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        not *in79  and
     C                             lbvrfy = 'F'  or
     C                             not *in79  and
     C                             lbvrfy = 'I'
     C                   exsr      zm6401
     C                   leave
     C                   endif
     C                   enddo
     C                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZMULT   Check if transaction is a multiple scan transaction.
ISPaA*            Note: IF multiple, must end using TE130 task entry.
     *
     C     zzmult        begsr
     C     pttrn#        chain     multran1                           75
     C                   if        not *in75  and
     C                             mustat = '1'
     C                   eval      error = *on
     C                   exsr      zm6401
     C                   endif
     C                   endsr
ISPaA*----------------------------------------------------------------
ISPaA*
ISPaA*  ZZSTAT   Status check.
ISPaA*           When all transactions have been closed export route
ISPaA*           and changed RTEHED status to '6'.
     *
     C     zzstat        begsr
     *
     *  Exit routine if route no longer at 4=Printed status.
     C     keyrh         chain(n)  rtehed                             79
     C                   if        not *in79  and
     C                             rhstat <> '4'
     C                   eval      error = *on
     C                   eval      errmsg = em(2)
     C                   exsr      zm0105
     C                   goto      endstat
     C                   endif
     *
     *  Loop through all the transactions for route.
     *
     C                   eval      close = *on
     C                   eval      $kwhse = ptwhse
     C                   eval      $ktype = ptgrp2
     C                   eval      $krtid = ptrtpo
     C                   eval      kyrtpo = ptrtpo
     C     partky        setll     pirtran4
     C                   dow       forevr = forevr
     C     partky        reade     record                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     If not a selection or letdown record then loop.
     *
     C                   if        ptgrp1 <> 'S'  and
     C                             ptgrp1 <> 'L'
     C                   iter
     C                   endif
     *
     *     If transaction is not closed, we're done.
     *
     C                   if        ptstat < '4'  or
     C                             ptstat > '4'
     C                   eval      close = *off
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *  If all transaction were closed, export and update status.
     *
     C                   if        close = *on
     *
     *    Update unique piece number recs' scan qty, file ORDP.
     *
     *
     C                   call      'OR633'
     C                   parm      $kwhse        w1whse
     C                   parm                    ptrtpo
     *
     *  4.11 Notes
     *
     *    The call to RH151 has been left alone, except to include
     *    it in the new select statement. Notice, that RH151 will
     *    never display an error because it does not use $PRTN.
     *
     C                   call      'RH251'
     C                   parm      $kwhse        rhwhse
     C                   parm      $krtid        rhrtid
     C                   parm      $krte         rhrte
     C                   parm      ' '           $rtn
ISPaA*
ISPaA*  Custom call for ISupply - get Ord# & Cust# then call
ISPaA*
ISPaAC                   if        Client = isupply
ISPaAC     keyoh         chain     ohrec                              79
ISPaA*
ISPdAC                   if        *in79 = *off
ISPdAC                             and ohtype = 'W'
ISPaAC                   move      ohcord        ispord
ISPaAC                   eval      ispcust = %subst(%editw(ohcust:editw11):8:5)
ISPaA*
ISPcAC                   eval      iswhse = %editc($kwhse : 'X')
ISPaAC                   call      'OR400CLISP'
ISPaAC                   parm                    ispord            7
ISPaAC                   parm                    ispcust          11
ISPcAC                   parm                    iswhse            3
ISPdAC                   endif
ISPaAC                   endif
ISPaA*
     C     keyrh         chain     rtehed                             79
     C                   if        not *in79
     C                   eval      rhstat = '6'
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      rhstsd = $cvd8o
     C                   time                    rhstst
     C                   update    rhrec
     *  Update picked qty, wt, and cube.
     C                   call      @pckrt
     C                   parm                    rhwhse
     C                   parm                    rhrtid
     C                   endif
     *
     *  Make sure Multran is closed.
     C                   if        client = isupply
     C     pttrn#        chain     multran1                           75
     C                   if        not *in75  and
     C                             mustat <> '4'
     C                   eval      $temp# = $emp#
     C                   eval      $tstat = '*'
     C                   call      'TE130'
     C                   parm                    $te130
     C                   parm                    $trtn             8
     C                   endif
     C                   endif
     *
     *  Show export screen
ISPbDC***                eval      nxtscr = '09A'
     *
     C                   endif
     *
     C     endstat       tag
     C                   endsr
640bA*----------------------------------------------------------------
640bA*
640bA*  ZZTRAXLBL  Convert TRAX label
640bAC     zztraxlbl     begsr
     C                   move      w1whse        $pwhseb
     C                   call      @cvtbarsel
     C                   parm                    $pwhseb           3
     C                   parm                    $pbarcode        15
     C                   parm                    $plbl#            7 0
     C                   parm                    $prtid            5
     C                   parm                    $punq#            5
     C                   parm                    $preturn          8
     C                   parm                    $perrmsg         60
     C                   if        $preturn = '*OK'
     C                   else
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   movel     desc(2)       errmsg
     C                   exsr      zm0110
     C                   endif
     C                   endsr
650bA*----------------------------------------------------------------
650bA*  clr$item  Clear $item data structure fields
650bA*----------------------------------------------------------------

650bAC     clr$item      begsr
650bAC                   eval      savever# = $itver#
650bAC                   clear                   $item
650bAC                   clear                   $item2
650bAC                   eval      $itver# = savever#
650bAC                   endsr

650aA*----------------------------------------------------------------
650aA*  clr$slot  Clear $slot data structure fields
650aA*----------------------------------------------------------------
650aA
650aAC     clr$slot      begsr
650aAC                   eval      savever# = $slver#
650aAC                   clear                   $slot
650aAC                   clear                   $slot2
650aAC                   eval      $slver# = savever#
650aAC                   eval      $saemp#U = *on
650aAC                   eval      $saemp# = $emp#
650aAC                   endsr
650aA
720dA*----------------------------------------------------------------
720dA*  clr$uciinfo  Clear $uciinfo data structure fields
720dA*----------------------------------------------------------------
720dA
720dAC     clr$uciinfo   begsr
720dAC                   eval      savever# = $uiver#
720dAC                   clear                   $uciinfo
720dAC                   eval      $uiver# = savever#
720dAC                   eval      $uiaddemp = $emp#
720dAC                   eval      $uiaddusr = #user
720dAC                   eval      $uiaddpgm  = #prog
720dAC                   eval      $uiaddjob  = #jobn
720dAC                   eval      $uichgemp = $emp#
720dAC                   eval      $uichgusr = #user
720dAC                   eval      $uichgpgm  = #prog
720dAC                   eval      $uichgjob  = #job
720dAC                   eval      $uichgnbr = #jobn
720dAC                   endsr

650bA*----------------------------------------------------------------
650bA*  zzzdricop  Call DRICOP
650bA*----------------------------------------------------------------

650bAC     zzzdricop     begsr
650bAC                   eval      error = *off

650bAC                   select
650bAC                   when      $dricommand = '*ITEM'
650bAC                   eval      $dridata = $item
650bAC                   eval      $dridata2 = $item2
650bAC                   when      $dricommand = '*SLOT'
650bAC                   eval      $dridata = $slot
650bAC                   eval      $dridata2 = $slot2
730wAC                   when      $dricommand = '*LICINFO'
730wAC                   eval      $dridata = $licinfo
730wAC                   eval      $dridata2 = $licinfo2
720dAC                   when      $dricommand = '*UCIINFO'
720dAC                   eval      $dridata = $uciinfo
720mAC                   eval      $dridata2 = $uciinfo2
650bAC                   endsl

650bAC                   if        $dricommand = '*ITEM'
650bAC                             or $dricommand = '*SLOT'
730wAC                             or $dricommand = '*LICINFO'
720mAC                             or $dricommand = '*UCIINFO'
650bAC                   call(e)   'DRICOP'
650bAC                   parm                    $dricommand
650bAC                   parm                    $drisubcmd
650bAC                   parm                    $drisys2upd
650bAC                   parm      #prog         $driprogram
650bAC                   parm      ' '           $drireturn
650bAC                   parm      ' '           $drimessage
650bAC                   parm                    $dridata
650bAC                   parm                    $dridata2
650bAC                   else
650bAC                   call(e)   'DRICOP'
650bAC                   parm                    $dricommand
650bAC                   parm                    $drisubcmd
650bAC                   parm                    $drisys2upd
650bAC                   parm      #prog         $driprogram
650bAC                   parm      ' '           $drireturn
650bAC                   parm      ' '           $drimessage
650bAC                   parm                    $dridata
650bAC                   endif

650bAC                   select

650bAC                   when      chk4err and %error
650bAC                   eval      error = *on

650bAC                   when      chk4err and $drireturn <> '*OK'
650bAC                   eval      error = *on

650bAC                   endsl

650bAC                   select
650bAC                   when      $dricommand = '*ITEM'
650bAC                   eval      $item = $dridata
650bAC                   eval      $item2 = $dridata2
650bAC                   when      $dricommand = '*SLOT'
650bAC                   eval      $slot = $dridata
650bAC                   eval      $slot2 = $dridata2
730wAC                   when      $dricommand = '*LICINFO'
730wAC                   eval      $licinfo = $dridata
730wAC                   eval      $licinfo2 = $dridata2
720dAC                   when      $dricommand = '*UCIINFO'
720dAC                   eval      $uciinfo = $dridata
720mAC                   eval      $uciinfo2 = $dridata2
650bAC                   endsl

650bAC                   eval      zmflag = *off
650bAC                   eval      zmsflag = *off
650bAC                   eval      chk4err = *off
650bAC     enddricop     endsr
700dA*----------------------------------------------------------------
700dA*
700dA*  ZZCNVWGT  Setup converted weight field.
700dA*
700dAC     zzcnvwgt      begsr
700dA*
700dA*
700dA* If item options is setup as kgs and user enters kgs no conversion
700dA* If item options is setup as kgs and user enters lbs need conversion
700dA* If item options is setup as lbs and user enters lbs no conversion
700dA* If item options is setup as lbs and user enters kgs need conversion
700dA /free
700dA   select;
700dA     when Begkilolbs = 'K';
700dA       if KiloLbs = 'K';
700dA         eval wwgt = wgt;
700dA       else;
700dA         eval(h) wwgt = wgt / kgs2lbs;
700dA       endif;
700dA     other;
700dA       if KiloLbs = 'K';
700dA         eval(h) wwgt = wgt * kgs2lbs;
700dA       else;
700dA         eval wwgt = wgt;
700dA       endif;
700dA   endsl;
700dA /end-free

700dAC                   endsr
720hA*----------------------------------------------------------------
720hA*  Chk4Skipcw  Check for unentered skipped weights
720hA*----------------------------------------------------------------
720hA
720hAC     Chk4Skipcw    begsr
720hA /free
720hA   Error = *Off;
720hA   FoundWL = *off;
720hA   *in60 = *off;
720hA   // loop through multran recs for employee.

720hA   kystat = '1';
720hA   setll ($emp#: kystat) multran;
720hA   dow forevr = forevr;
720hA     reade ($emp#: kystat) multran;
720hA     if %eof(multran);
720hA       leave;
720hA     endif;

720hA     // check for unentered skipped weights.

720hA     kyent = 'N';
730oD     //setll (muwhse: kyent: mutrn#: lblbl#) ordskipcw1;
730oD     //reade (muwhse: kyent: mutrn#: lblbl#) ordskipcw1;
750gA     if w6lbl <> 0;
730oM     setll (muwhse: kyent: mutrn#: w6lbl) ordskipcw1;
730oM     reade (muwhse: kyent: mutrn#: w6lbl) ordskipcw1;
750gA     else;
750gM       setll (muwhse: kyent: mutrn#: lblbl#) ordskipcw1;
750gM       reade (muwhse: kyent: mutrn#: lblbl#) ordskipcw1;
750gA     endif;
720hA     If not %eof(ordskipcw1);
720hA       FoundWL = *on;
720hA       *in63 = *on;
720hA       leave;
720hA     Endif;

720hA   EndDo;

720hA /end-free
720hAC                   endsr

752gA*----------------------------------------------------------------
752gA*  Chk4weighbtn   check for displaying weigh button
752gA*----------------------------------------------------------------
752gA
752gAC     Chk4weighbtn  begsr
752gA /free
752gA   kyent = 'N';
752gA   setll (w1whse: kyent: lbtrn#) ordskipcw1;
752gA   reade (w1whse: kyent: lbtrn#) ordskipcw1;
752gA   If not %eof(ordskipcw1);
752gA      *in63 = *on;
        else;
           *in63 = *off;
752gA   Endif;

752gA /end-free
752gAC                   endsr
720hA*----------------------------------------------------------------
720hA*  Vfy4Skipcw  Verify for unentered skipped weights
720hA*----------------------------------------------------------------
720hA
720hAC     Vfy4Skipcw    begsr
720hA /free
720hA   FoundWLabel = *off;
720hA   // loop through multran recs for employee.

720hA   kystat = '1';
720hA   setll ($emp#: kystat) multran;
720hA   dow forevr = forevr;
720hA     reade ($emp#: kystat) multran;
720hA     if %eof(multran);
720hA       leave;
720hA     endif;

720hA     // check for unentered skipped weights for label scanned.

720hA     kyent = 'N';
720hA     setll (muwhse: kyent: mutrn#: $plbl#) ordskipcw1;
720hA     reade (muwhse: kyent: mutrn#: $plbl#) ordskipcw1;
720hA     If not %eof(ordskipcw1);
720hA       FoundWLabel = *on;
720hA       leave;
720hA     Endif;

720hA   EndDo;

720hA /end-free
720hAC                   endsr

700fA*----------------------------------------------------------------
700fA*
700fA*  OPENFILE - Open file by client
700fA*
700fAC     openfile      begsr
700fAC                   if        client = cheney
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = cityline
700fAC                   if        not %open(label32x)
700fAC                   open      label32x
700fAC                   endif
700fAC                   endif
700fA
CFIbAC                   if        client = Colony
CFIbAC                   if        not %open(label32x)
CFIbAC                   open      label32x
CFIbAC                   endif
CFIbAC                   if        not %open(sktlbl32x)
CFIbAC                   open      sktlbl32x
CFIbAC                   endif
CFIbAC                   endif
CFIbA
700fAC                   if        client = greenleaf
700fAC                   if        not %open(label32x)
700fAC                   open      label32x
700fAC                   endif
700fAC                   if        not %open(sktlbl32x)
700fAC                   open      sktlbl32x
700fAC                   endif
700fAC                   endif
700fA
700fA
700fAC                   if        client = Westside
700fAC                   if        not %open(label32w)
700fAC                   open      label32w
700fAC                   endif
700fAC                   if        not %open(sktlbl32w)
700fAC                   open      sktlbl32w
700fAC                   endif
700fAC                   endif
700fA
700fA
700fAC                   if        client = ISupply
700fAC                             or client = Coastl
700fAC                   if        not %open(label32i)
700fAC                   open      label32i
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = SGC
700fAC                   if        not %open(label32g)
700fAC                   open      label32g
700fAC                   endif
700fAC                   if        not %open(sktlbl32g)
700fAC                   open      sktlbl32g
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = mjkellner
700fAC                   if        not %open(sktlbl32s)
700fAC                   open      sktlbl32s
700fAC                   endif
700fAC                   endif
ACCbA
ACCbAC                   if        client = accardi
ACCbAC                   if        not %open(sktlbl32s)
ACCbAC                   open      sktlbl32s
ACCbAC                   endif
ACCbAC                   if        not %open(label32s)
ACCbAC                   open      label32s
ACCbAC                   endif
ACCbAC                   endif
700fA
700fAC                   if        client = prestofoods
PFCbDC*                  if        not %open(sktlbl32j)
PFCbDC*                  open      sktlbl32j
PFCbMC                   if        not %open(sktlbl32d)
PFCbMC                   open      sktlbl32d
700fAC                   endif
PFCbAC                   if        not %open(label32d)
PFCbAC                   open      label32d
PFCbAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = harbor
700fAC                   if        not %open(label32x)
700fAC                   open      label32x
700fAC                   endif
700fAC                   if        not %open(sktlbl32x)
700fAC                   open      sktlbl32x
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = ellenbee
700fAC                             or client = dierks
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(label32z)
700fAC                   open      label32z
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32z)
700fAC                   open      sktlbl32z
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = royal
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = tpc
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = saval
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = dierks
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = palmer
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = frf
700fAC                             or client = FoodPro
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = Getfresh
700fAC                             or client = EI
700fAC                             or client = WillFoods
700fAC                             or client = Panos
700fAC                             or client = Renzi
ADF AC                             or client = AandDFoods
COT AC                             or client = Cotati
MRTbAC                             or client = Merit
SWT AC                             or client = SWT
730mAc                             or usrDFPICK='Y'
700fAC                   if        not %open(label32d)
700fAC                   open      label32d
700fAC                   endif
700fAC                   if        not %open(sktlbl32d)
700fAC                   open      sktlbl32d
700fAC                   endif
700fAC                   endif
700fA
700fAC                   if        client = avalon
700fAC                   if        not %open(label32h)
700fAC                   open      label32h
700fAC                   endif
700fAC                   if        not %open(sktlbl32h)
700fAC                   open      sktlbl32h
700fAC                   endif
700fAc                   endif
700fAc
700fAC                   if        not %open(sktlbl)
700fAC                   open      sktlbl
700fAC                   endif
700fA
752vDC***                if        not %open(sktlbl32)
752vDC***                open      sktlbl32
752vDC***                endif
700fA
700fAC                   if        not %open(sktlbl32c)
700fAC                   open      sktlbl32c
700fAC                   endif
700fA*
700fAC     endopnfile    endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  GETLOWLIMIT - Set lower limits on label file by client
700fA*
700fAC     getlowlimit   begsr
700fA*
700fAc                   exsr      chkmultitran
700fA*
700fAc                   if        multitran
700fAC                   select
700fAC                   when      client = cheney
700fAC                             or client = ellenbee
700fAC                             or client = royal
700fAC                             or client = tpc
700fAC                             or client = saval
700fAC                             or client = palmer
700fAC                             or client = frf
700fAC                             or client = Getfresh
700fAC                             or client = FoodPro
700fAC                             or client = EI
700fAC                             or client = WillFoods
700fAC                             or client = Panos
700fAC                             or client = Renzi
ADF AC                             or client = AandDFoods
COT AC                             or client = Cotati
MRTbAC                             or client = Merit
SWT AC                             or client = SWT
PFCbAC                             or client = prestofoods
730mAc                             or usrDFPICK='Y'
700fAC     Keyl32w       SetLL     sktlbl32d
700fAC                   when      client = SGC
700fAC     Keyl32w       SetLL     sktlbl32g
700fAC                   when      client = Westside
700fAC     Keyl32w       SetLL     sktlbl32w
700fAC                   when      client = avalon
700fAC     Keyl32w       SetLL     sktlbl32h
700fAC                   when      client = mjkellner
700fAC     Keyl32w       SetLL     sktlbl32s
ACCbAC                   when      client = accardi
ACCbAC                             and (ptwhdp = 'REF  '
ACCbAC                             or   ptwhdp = 'FRZ  ')
ACCbAC     Keyl32w       SetLL     sktlbl32s
PFCbDC*                  when      client = prestofoods
PFCbDC*    Keyl32w       SetLL     sktlbl32j
700fAC                   when      client = harbor
700fAC
700fAC                   when      client = greenleaf
700fAC     Keyl32w       SetLL     sktlbl32x
700fAC
700fAC                   other
700fAC     Keyl32w       SetLL     sktlbl32c
700fAC                   endsl
700fA
700fAC                   else

700fAC                   select
700fAC                   when      client = cityline
700fAC                             or client = harbor
700fAC                             or client = greenleaf
CFIbAC                             or client = Colony
700fAC     Keyl32        SetLL     Label32X
700fAC                   when      client = cheney
700fAC                             or client = ellenbee
700fAC                             or client = royal
700fAC                             or client = tpc
700fAC                             or client = saval
700fAC                             or client = palmer
700fAC                             or client = frf
700fAC                             or client = Getfresh
700fAC                             or client = FoodPro
700fAC                             or client = EI
700fAC                             or client = WillFoods
700fAC                             or client = Panos
700fAC                             or client = Renzi
ADF AC                             or client = AandDFoods
COT AC                             or client = Cotati
MRTbAC                             or client = Merit
SWT AC                             or client = SWT
PFCbAC                             or client = prestofoods
730mAc                             or usrDFPICK='Y'
700fAC     Keyl32        SetLL     Label32D
700fAC                   when      client = ISupply
700fAC     Keyl32        SetLL     Label32I
700fAC                   when      client = Coastl
700fAC                             and psszon = 'REFB'
700fAC     Keyl32        SetLL     Label32I
ACCbAC                   when      client = Accardi
ACCbAC                             and (ptwhdp = 'REF  '
ACCbAC                             or   ptwhdp = 'FRZ  ')
ACCbAC     Keyl32        SetLL     Label32s
700fAC                   when      client = SGC
700fAC     Keyl32        SetLL     Label32G
700fAC                   when      client = Westside
700fAC     Keyl32        SetLL     Label32w
700fAC                   when      client = avalon
700fAC     Keyl32        SetLL     label32h
700fAC                   other
700fAC     Keyl32        SetLL     Label32C
700fAC                   endsl
700fAc                   endif
700fA*
700fAC     endlowlimit   endsr
700fA*----------------------------------------------------------------
700fA*
700fA*  GETRECORD   - Read files by client
700fA*
700fAC     getRecord     begsr
700fAC                   if        multitran
700fA
700fAC                   select
700fAC                   when      client = cheney
700fAC                             or client = ellenbee
700fAC                             or client = royal
700fAC                             or client = tpc
700fAC                             or client = saval
700fAC                             or client = palmer
700fAC                             or client = frf
700fAC                             or client = Getfresh
700fAC                             or client = FoodPro
700fAC                             or client = EI
700fAC                             or client = WillFoods
700fAC                             or client = Panos
700fAC                             or client = Renzi
ADF AC                             or client = AandDFoods
COT AC                             or client = Cotati
MRTbAC                             or client = Merit
SWT AC                             or client = SWT
PFCbAC                             or client = prestofoods
730mAc                             or usrDFPICK='Y'
700fAC     Keyl32w       Reade     sktlbl32d                              20
700fAC                   when      client = SGC
700fAC     Keyl32w       Reade     sktlbl32g                              20
700fAC                   when      client = Westside
700fAC     Keyl32w       Reade     sktlbl32w                              20
700fAC                   when      client = avalon
700fAC     Keyl32w       Reade     sktlbl32h                              20
700fAC                   when      client = mjkellner
700fAC     Keyl32w       Reade     sktlbl32s                              20
ACCbAC                   when      client = accardi
ACCbAC                             and (ptwhdp = 'REF  '
ACCbAC                             or   ptwhdp = 'FRZ  ')
ACCbAC     Keyl32w       Reade     sktlbl32s                              20
PFCbDC*                  when      client = prestofoods
PFCbDC*    Keyl32w       Reade     sktlbl32j                              20
700fAC                   when      client = harbor
700fAC                             or client = greenleaf
700fAC     Keyl32w       Reade     sktlbl32x                              20
720cAc                   other
700fAC     Keyl32w       Reade     sktlbl32c                              20
700fAC                   endsl
700fA
700fAC                   else
700fA
700fAC                   select
700fAC                   when      client = cityline
700fAC                             or client = harbor
700fAC                             or client = greenleaf
CFIbAC                             or client = Colony
700fAC     Keyl32        Reade     Label32X                               20
700fAC                   when      client = cheney
700fAC                             or client = ellenbee
700fAC                             or client = royal
700fAC                             or client = tpc
700fAC                             or client = saval
700fAC                             or client = palmer
700fAC                             or client = frf
700fAC                             or client = Getfresh
700fAC                             or client = FoodPro
700fAC                             or client = EI
700fAC                             or client = WillFoods
700fAC                             or client = Panos
700fAC                             or client = Renzi
ADF AC                             or client = AandDFoods
COT AC                             or client = Cotati
MRTbAC                             or client = Merit
SWT AC                             or client = SWT
PFCbAC                             or client = prestofoods
730mAc                             or usrDFPICK='Y'
700fAC     Keyl32        Reade     Label32D                               20
700fAC                   when      client = ISupply
700fAC     Keyl32        Reade     Label32I                               20
700fAC                   when      client = Coastl
700fAC                             and psszon = 'REFB'
700fAC     Keyl32        Reade     Label32I                               20
700fAC                   when      client = SGC
700fAC     Keyl32        Reade     Label32G                               20
700fAC                   when      client = Westside
700fAC     Keyl32        Reade     Label32w                               20
700fAC                   when      client = avalon
700fAC     Keyl32        Reade     label32h                               20
ACCbAC                   when      client = accardi
ACCbAC                             and (ptwhdp = 'REF  '
ACCbAC                             or   ptwhdp = 'FRZ  ')
ACCbAC     Keyl32        Reade     label32s                               20
700fAC                   other
700fAC     Keyl32        Reade     Label32C                               20
700fAC                   endsl
700fAC                   endif
700fAC     endGetRecord  endsr
752tA*----------------------------------------------------------------
752tA*
752tA*  GETRECORDss - Read files by client to check for same slot
752tA*
752tAC     getRecordss   begsr
752tAc                   eval      ssmoreqty = *off
752tAC                   if        multitran
752tA
752tAC                   select
752tAC                   when      client = cheney
752tAC                             or client = ellenbee
752tAC                             or client = royal
752tAC                             or client = tpc
752tAC                             or client = saval
752tAC                             or client = palmer
752tAC                             or client = frf
752tAC                             or client = Getfresh
752tAC                             or client = FoodPro
752tAC                             or client = EI
752tAC                             or client = WillFoods
752tAC                             or client = Panos
752tAC                             or client = Renzi
752tAC                             or client = AandDFoods
752tAC                             or client = Cotati
752tAC                             or client = Merit
752tAC                             or client = SWT
752tAC                             or client = prestofoods
752tAc                             or usrDFPICK='Y'
752tAC     Keyl32w       Reade     sktlbl32d                              20
752tAC                   when      client = SGC
752tAC     Keyl32w       Reade     sktlbl32g                              20
752tAC                   when      client = Westside
752tAC     Keyl32w       Reade     sktlbl32w                              20
752tAC                   when      client = avalon
752tAC     Keyl32w       Reade     sktlbl32h                              20
752tAC                   when      client = mjkellner
752tAC     Keyl32w       Reade     sktlbl32s                              20
752tAC                   when      client = accardi
752tAC                             and (ptwhdp = 'REF  '
752tAC                             or   ptwhdp = 'FRZ  ')
752tAC     Keyl32w       Reade     sktlbl32s                              20
752tAC                   when      client = harbor
752tAC                             or client = greenleaf
752tAC     Keyl32w       Reade     sktlbl32x                              20
752tAc                   other
752tAC     Keyl32w       Reade     sktlbl32c                              20
752tAC                   endsl
752tA /free
752tA   if not %eof(sktlbl32c)
752tA      and not %eof(sktlbl32x)
752tA      and not %eof(sktlbl32s)
752tA      and not %eof(sktlbl32d)
752tA      and not %eof(sktlbl32g)
752tA      and not %eof(sktlbl32w)
752tA      and not %eof(sktlbl32h);
752tA     if lbaisl  = slwaisl and
752tA        lbloc = slwloc and
752tA        lbrlvl = slwrlvl and
752tA        lbhand = slwhand;
752tA       if opspssn = 'Y';
752tA         ssmoreqty = *on;
752tA       endif;
752tA     endif;
752tA   endif;
752tA /end-free
752tA
752tAC                   else
752tA
752tAC                   select
752tAC                   when      client = cityline
752tAC                             or client = harbor
752tAC                             or client = greenleaf
752tAC                             or client = Colony
752tAC     Keyl32        Reade     Label32X                               20
752tAC                   when      client = cheney
752tAC                             or client = ellenbee
752tAC                             or client = royal
752tAC                             or client = tpc
752tAC                             or client = saval
752tAC                             or client = palmer
752tAC                             or client = frf
752tAC                             or client = Getfresh
752tAC                             or client = FoodPro
752tAC                             or client = EI
752tAC                             or client = WillFoods
752tAC                             or client = Panos
752tAC                             or client = Renzi
752tAC                             or client = AandDFoods
752tAC                             or client = Cotati
752tAC                             or client = Merit
752tAC                             or client = SWT
752tAC                             or client = prestofoods
752tAc                             or usrDFPICK='Y'
752tAC     Keyl32        Reade     Label32D                               20
752tAC                   when      client = ISupply
752tAC     Keyl32        Reade     Label32I                               20
752tAC                   when      client = Coastl
752tAC                             and psszon = 'REFB'
752tAC     Keyl32        Reade     Label32I                               20
752tAC                   when      client = SGC
752tAC     Keyl32        Reade     Label32G                               20
752tAC                   when      client = Westside
752tAC     Keyl32        Reade     Label32w                               20
752tAC                   when      client = avalon
752tAC     Keyl32        Reade     label32h                               20
752tAC                   when      client = accardi
752tAC                             and (ptwhdp = 'REF  '
752tAC                             or   ptwhdp = 'FRZ  ')
752tAC     Keyl32        Reade     label32s                               20
752tAC                   other
752tAC     Keyl32        Reade     Label32C                               20
752tAC                   endsl
752tAC                   endif
752tAc                   exsr      getPreSS
752tAC     endGetRecss   endsr
752tA*----------------------------------------------------------------
752tA*
752tA*  GETPRESS    - ReadP files by client to check for same slot ck
752tA*
752tAC     getPreSS      begsr
752tAC                   if        multitran
752tA
752tAC                   select
752tAC                   when      client = cheney
752tAC                             or client = ellenbee
752tAC                             or client = royal
752tAC                             or client = tpc
752tAC                             or client = saval
752tAC                             or client = palmer
752tAC                             or client = frf
752tAC                             or client = Getfresh
752tAC                             or client = FoodPro
752tAC                             or client = EI
752tAC                             or client = WillFoods
752tAC                             or client = Panos
752tAC                             or client = Renzi
752tAC                             or client = AandDFoods
752tAC                             or client = Cotati
752tAC                             or client = Merit
752tAC                             or client = SWT
752tAC                             or client = prestofoods
752tAc                             or usrDFPICK='Y'
752tAC     Keyl32w       Readpe    sktlbl32d                              20
752tAC                   when      client = SGC
752tAC     Keyl32w       Readpe    sktlbl32g                              20
752tAC                   when      client = Westside
752tAC     Keyl32w       Readpe    sktlbl32w                              20
752tAC                   when      client = avalon
752tAC     Keyl32w       Readpe    sktlbl32h                              20
752tAC                   when      client = mjkellner
752tAC     Keyl32w       Readpe    sktlbl32s                              20
752tAC                   when      client = accardi
752tAC                             and (ptwhdp = 'REF  '
752tAC                             or   ptwhdp = 'FRZ  ')
752tAC     Keyl32w       Readpe    sktlbl32s                              20
752tAC                   when      client = harbor
752tAC                             or client = greenleaf
752tAC     Keyl32w       Readpe    sktlbl32x                              20
752tAc                   other
752tAC     Keyl32w       Readpe    sktlbl32c                              20
752tAC                   endsl
752tA
752tAC                   else
752tA
752tAC                   select
752tAC                   when      client = cityline
752tAC                             or client = harbor
752tAC                             or client = greenleaf
752tAC                             or client = Colony
752tAC     Keyl32        Readpe    Label32X                               20
752tAC                   when      client = cheney
752tAC                             or client = ellenbee
752tAC                             or client = royal
752tAC                             or client = tpc
752tAC                             or client = saval
752tAC                             or client = palmer
752tAC                             or client = frf
752tAC                             or client = Getfresh
752tAC                             or client = FoodPro
752tAC                             or client = EI
752tAC                             or client = WillFoods
752tAC                             or client = Panos
752tAC                             or client = Renzi
752tAC                             or client = AandDFoods
752tAC                             or client = Cotati
752tAC                             or client = Merit
752tAC                             or client = SWT
752tAC                             or client = prestofoods
752tAc                             or usrDFPICK='Y'
752tAC     Keyl32        Readpe    Label32D                               20
752tAC                   when      client = ISupply
752tAC     Keyl32        Readpe    Label32I                               20
752tAC                   when      client = Coastl
752tAC                             and psszon = 'REFB'
752tAC     Keyl32        Readpe    Label32I                               20
752tAC                   when      client = SGC
752tAC     Keyl32        Readpe    Label32G                               20
752tAC                   when      client = Westside
752tAC     Keyl32        Readpe    Label32w                               20
752tAC                   when      client = avalon
752tAC     Keyl32        Readpe    label32h                               20
752tAC                   when      client = accardi
752tAC                             and (ptwhdp = 'REF  '
752tAC                             or   ptwhdp = 'FRZ  ')
752tAC     Keyl32        Readpe    label32s                               20
752tAC                   other
752tAC     Keyl32        Readpe    Label32C                               20
752tAC                   endsl
752tAC                   endif
752tAC     endPreRecss   endsr
700fA*---------------------------------------------------------------
700fA*  ChkMulitran  Check for multiple transactions.
700fA*---------------------------------------------------------------
700fAC     ChkMultitran  BegSr
700fA
700fAC                   eval      multitran = *off
700fA
700fAC                   eval      kystat = '1'
700fAC     keymu         setll     multran
700fA
700fAC                   eval      count = 0
700fAC                   dow       forevr = forevr
700fAC     keymu         reade     multran
700fAC                   if        %eof
700fAC                   leave
700fAC                   endif
700fAC                   eval      count = count + 1
700fAC                   enddo
700fA
700fAC                   if        count > 1
700fAC                   eval      multitran = *on
700fAC                   else
700fAC                   eval      multitran = *off
700fAC                   endif
700fA
700fAC     endchkmult    Endsr
700fA*

730wA*----------------------------------------------------------------
730wA*
730wA*  ZZGETS   Get slot information.
730wA*
730wAC     zzgets        begsr
730wAC                   eval      error = *off
730wAc                   eval      slcns = ' '
730wA*  Use DRI interface to get slot information.
730wA
730wAC                   exsr      clr$slot
730wA /free
730wA   $slwhseu = *on;
730wA   $slwhdpu = *on;
730wA   $sldispu = *on;
730wA   $sldisp  = sdisp;
730wA   select;
730wA     when multitran;
730wA       $slwhse  = slwwhse;
730wA       $slwhdp  = slwwhdp;
730wA     when not multitran;
730wA       $slwhse  = lbwhse;
730wA       $slwhdp  = lbwhdp;
730wA   endsl;
730wA /end-free
730wA
730wAC                   eval      $dricommand = '*SLOT'
730wAC                   eval      $drisubcmd  = '%GETCHKVX'
730wAC                   eval      $drisys2upd = 'D'
730wAC                   eval      chk4err = *on
730wAC                   eval      zmsflag = *on
730wAC                   exsr      zzzdricop
730wAC                   if        error = *on
730wAC                   eval      $prtn = '*PGMQ   '
730wAC                   goto      endgts
730wAC                   endif
730wA
730wAC                   eval      #fromslwhdp = $slwhdp
730wAC                   eval      #fromslstyp = $slstyp
730wAC                   eval      #fromsldisp = $sldisp
730wAC                   eval      #fromslaisl = $slaisl
730wAC                   eval      #fromslloc  = $slloc
730wAC                   eval      #fromslpseq = $slpseq
730wAC                   eval      #fromslrlvl = $slrlvl
730wAC                   eval      #fromslhand = $slhand
730wAC                   eval      #fromslrsrv = $slrsrv
730wAC                   eval      #fromslentd = $slentd
730wAC                   eval      #fromslexpd = $slexpd
730wAC                   eval      #fromslslfd = $slslfd
730wAC                   eval      #fromslactv = $slactv
730wAC                   eval      #fromslbld  = $slbld
730wAC                   eval      #fromslpick = $slpick
730wAC                   eval      #fromslitem = $slitem
730wAC                   eval      #fromslsdef = $slsdef
730wAC                   eval      #fromslvirt = $sfvirt
730wAC                   eval      #fromslstk1 = $slstk1
730wAC                   eval      #fromslstk2 = $slstk2
730wAC                   eval      #fromslstk3 = $slstk3
730wAC                   eval      #fromslalc1 = $slalc1
730wAC                   eval      #fromslalc2 = $slalc2
730wAC                   eval      #fromslalc3 = $slalc3
730wAC                   eval      #fromsltfr1 = $sltfr1
730wAC                   eval      #fromsltfr2 = $sltfr2
730wAC                   eval      #fromsltfr3 = $sltfr3
730wAC                   eval      #fromslpck1 = $slpck1
730wAC                   eval      #fromslpck2 = $slpck2
730wAC                   eval      #fromslpck3 = $slpck3
730wAC                   eval      #fromslrcv1 = $slrcv1
730wAC                   eval      #fromslrcv2 = $slrcv2
730wAC                   eval      #fromslrcv3 = $slrcv3
730wAC                   eval      #fromslphy1 = $slphy1
730wAC                   eval      #fromslphy2 = $slphy2
730wAC                   eval      #fromslphy3 = $slphy3
730wAC                   eval      #fromslavl1 = $slavl1
730wAC                   eval      #fromslavl2 = $slavl2
730wAC                   eval      #fromslavl3 = $slavl3
730wAC                   eval      #fromToLcns = $saToLcns
730wAC                   eval      #fromToPos  = $saToPos
730wAC                   eval      #fromOLcns = $saOLcns
730wA
730wAC                   eval      #frombasesldsp = $sacdsp
730wA
730wAC                   eval      slcns   = #fromToLcns
730wA*
730wAC     endgts        endsr

730wA*----------------------------------------------------------------
730wA*  ZZZCALL$LT210  -  Call LT210 program.
730wA*----------------------------------------------------------------
730wA
730wAC     ZZZCALL$LT210 begsr
730wA
730wAC                   call      'LT210'
730wAC                   parm                    $tcmd
730wAC                   parm      #prog         $tprogram
730wAC                   parm      'TFR'         $ttype
730wAC                   parm      'Transfer'    $thead
730wAC                   parm                    $twhse
730wAC                   parm                    $titem
730wAC                   parm                    $titemdsc
730wAC                   parm                    $twhdp
730wAC                   parm                    $tslot
730wAC                   parm                    $tslotpos
730wAC                   parm      $emp#         $templ#
730wAC                   parm                    $ttran#
730wAC                   parm                    $tlic#
730wAC                   parm                    $tnewlic#
730wAC                   parm                    $tqty1
730wAC                   parm                    $tqty2
730wAC                   parm                    $tqty3
730wAC                   parm                    $tnorm1
730wAC                   parm                    $tnorm2
730wAC                   parm                    $tnorm3
730wAC                   parm                    $tpartial
730wAC                   parm                    $tpulled
730wAC                   parm                    $tinslot
730wAC                   parm                    $tsamepos
730wAC                   parm                    $tdiffpos
730wAC                   parm                    $tpsplit
730wAC                   parm                    $tinlic#
730wAC                   parm                    $toutlic#
730wAC                   parm                    $tnexttask
730wAC                   parm                    $treturn
730wAC                   parm                    $terrmsg
730wAC                   parm                    $tmsgid
730wA
730wAC                   endsr
730wA
730wA*----------------------------------------------------------------
730wA*  ZZZCLR$LT210  -  Clear LT210 parameters.
730wA*----------------------------------------------------------------
730wA
730wAC     ZZZCLR$LT210  begsr
730wA
730wAC                   clear                   $tcmd
730wAC                   clear                   $tprogram
730wAC                   clear                   $ttype
730wAC                   clear                   $thead
730wAC                   clear                   $twhse
730wAC                   clear                   $titem
730wAC                   clear                   $titemdsc
730wAC                   clear                   $twhdp
730wAC                   clear                   $tslot
730wAC                   clear                   $tslotpos
730wAC                   clear                   $templ#
730wAC                   clear                   $ttran#
730wAC                   clear                   $tlic#
730wAC                   clear                   $tnewlic#
730wAC                   clear                   $tqty1
730wAC                   clear                   $tqty2
730wAC                   clear                   $tqty3
730wAC                   clear                   $tnorm1
730wAC                   clear                   $tnorm2
730wAC                   clear                   $tnorm3
730wAC                   clear                   $tpartial
730wAC                   clear                   $tpulled
730wAC                   clear                   $tinslot
730wAC                   clear                   $tsamepos
730wAC                   clear                   $tdiffpos
730wAC                   clear                   $tpsplit
730wAC                   clear                   $tinlic#
730wAC                   clear                   $toutlic#
730wAC                   clear                   $tnexttask
730wAC                   clear                   $treturn
730wAC                   clear                   $terrmsg
730wAC                   clear                   $tmsgid
730wA
730wAC                   endsr
730wA
740eA*----------------------------------------------------------------
740eA*  ZZZSETOF      -  setoff command key indicators
740eA*----------------------------------------------------------------
740eA /free
740eA  begsr zzzsetof;
740eA   *inka = *off;
740eA   *inkb = *off;
740eA   *inkc = *off;
740eA   *inkd = *off;
740eA   *inke = *off;
740eA   *inkf = *off;
740eA   *inkg = *off;
740eA   *inkh = *off;
740eA   *inki = *off;
740eA   *inkj = *off;
740eA   *inkk = *off;
740eA   *inkl = *off;
740eA   *inkm = *off;
740eA   *inkn = *off;
740eA   *inkp = *off;
740eA   *inkq = *off;
740eA   *inkr = *off;
740eA   *inks = *off;
740eA   *inkt = *off;
740eA   *inku = *off;
740eA   *inkv = *off;
740eA   *inkw = *off;
740eA   *inkx = *off;
740eA   *inky = *off;
740eA  endsr;
740eA /end-free
740eA
730uA*----------------------------------------------------------------
730uA*----------------------------------------------------------------
730uA*  Phrase Routines
730uA*----------------------------------------------------------------
730uA*----------------------------------------------------------------

730uA*----------------------------------------------------------------
730uA*  pushRoutine  -  Add routine to stack
730uA*----------------------------------------------------------------
730uA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

730uA*----------------------------------------------------------------
730uA*  popRoutine  -  Remove routine from stack
730uA*----------------------------------------------------------------
730uA
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

730uA*----------------------------------------------------------------
730uA*  phClearVars  - Clear phrase variables
730uA*----------------------------------------------------------------
730uA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


730uA*----------------------------------------------------------------
730uA*  zzWrtPhrase  - Write logging phrase
730uA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

xxxxx    if prime;
xxxxx      leavesr;
xxxxx    endif;

         pWhse = 0;
         pEmp# = $emp#;
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

730uA*----------------------------------------------------------------
730uA*  phV2onV1
730uA*----------------------------------------------------------------
730uA
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

730uA*----------------------------------------------------------------
730uA*  phScrV1pgmV2
730uA*----------------------------------------------------------------
730uA
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
           when warn = *on;
             v2 = 'redisplayed with warning';
           other;
             v2 = 'redisplayed';
         endsl;
         lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

730uA*----------------------------------------------------------------
730uA*  phPgmV1V2V3e
730uA*----------------------------------------------------------------
730uA
730uA /free
730uA  begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

730uA*----------------------------------------------------------------
730uA*  phPgmV1V2V3s
730uA*----------------------------------------------------------------
730uA
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

750fA*----------------------------------------------------------------
750fA*  WriteVoiceLog    Write record to voice log BFCSKTLOG
750fA*----------------------------------------------------------------
750fA
750fAp WriteVoiceLog   b
     d WriteVoiceLog   pi
     d  type                               const like(slgtyp)
     d  buffer                             const like(slgbuf)

      /free

       GetCurrStamp();

       slgTyp = type;

       //slgbuf = spWhereFrom
       //       + '      '
       //       + '- ' + #pgm + %trim(buffer);
       slgbuf = %trim(buffer);

       slgts     = currstamploc;
       slgucs    = currstampuc;
       slguser   = #user;
       slgjob    = #job;
       slgjobnbr = #jobn;

       slgsk2 = 0;
       SlgIP  = #pgm;
       SlgPortL = 0;
       SlgPortC = 0;
       slgid  = spUid;
       write slgrec;

      /end-free

     p                 e

750qA*----------------------------------------------------------------
750qA*  WriteCLOB        Write record to BFCSKTJSON with CLOB fields
750qA*----------------------------------------------------------------
750qA
750qAp WriteCLOB       b
     d WriteCLOB       pi
     d  jsonStr                   64512    varying options(*varsize) const
     d  printStr1                 64512    varying options(*varsize) const
     d  printStr2                 64512    varying options(*varsize) const

     d* This definitions will create corresponding fields _data, _len
     d*    http://itpscan.ca/blog/iSeries/clobs.php

     d wkJsonClob      s                   sqltype(CLOB:64512)
     d wkPrint1Clob    s                   sqltype(CLOB:64512)
     d wkPrint2Clob    s                   sqltype(CLOB:64512)

      /free

       wkJsonClob_data = jsonStr;
       wkJsonClob_len = %len(jsonStr);

       wkPrint1Clob_data = printStr1;
       wkPrint1Clob_len = %len(printStr1);

       wkPrint2Clob_data = printStr2;
       wkPrint2Clob_len = %len(printStr2);

       Exec SQL
          INSERT INTO BFCSKTJSN (sjts, sjjob, sjjobu, sjjobn,
                                 sjjson, sjprint1, sjprint2)
          VALUES (:slgts, :slgjobnbr, :slguser, :slgjob,
                  :wkJsonClob, :wkPrint1Clob, :wkPrint2Clob);

       If sqlstt <> sqlSuccess;
         sqlerm = sqlerm;
       endif;

       // Write print overflow

       if wkPrint2Clob_len > 0;
         Exec SQL
           INSERT INTO PRINTOVRF (povuid, povprt2)
           VALUES (:spUid, :wkPrint2Clob);
         If sqlstt <> sqlSuccess;
         endif;
       endif;

      /end-free

     p                 e

750lA*****************************************************************
750lA* Get Pallet Summary
750lA*****************************************************************
750lAp $GetPltSum      b
     d $GetPltSum      pi

      /free
        // this routine will be called each time screen1 is entered
        // I will load up the ds for all transactions.
        // it will be a summary screen for all transaction combined
        setll (w1trn#) pltsum4;
        dow forever = forever;
          reade (w1trn#) pltsum4;
          if %eof(pltsum4);
            leave;
          endif;
        // reset the palcnt to 0 when filling screen8

        //  Add pallet info to pallet summary data structure.
      /END-FREE

     C                   add       1             palcnt
     C     palcnt        occur     palsum
     c                   eval      dsptrn = pstrn#
     C                   eval      dsppal = pspal#
     C                   eval      dspcub = pscube
     C                   z-add     psswgt        dspwgt
CLDqAC                   if        client = cityln
     C                   z-add     0             pcksum
     C                   eval      fabitems = *off
     C     lb90key       setll     label90
     C                   DoW       Forevr = Forevr
     C                   read      label90
     C                   If        lbtrn# <> pstrn# or %EOF(label90)
     C                   Leave
     C                   endif
     C                   If        psplid = lbpal#
     C     ilkey         chain     itemlnk
     C                   if        %found(itemlnk)
     C     ilkey2        chain     itemfld
     C                   if        %found(itemfld) and
     C                             ifcat='FAB       '
     C                   eval      fabitems = *on
     C     ilkey2        chain(n)  piritem
     C                   if        %found(piritem)
     C                   if        lbqpck <= itumQ2 and itumq2 >0
     C                   add       1             pcksum
     C                   else
     C                   if        lbqpck > itumQ2 and itumq2 >0
     C                   eval      pcksum = (lbqpck/itumq2) + pcksum
     C                   endif
     C                   endif
     C                   endif
     C                   else
     C                   eval      pcksum = lbqpck + pcksum
     C                   endif
     C                   else
     C                   eval      pcksum = lbqpck + pcksum
     C                   endif
     C                   endif
     C                   enddo
CLDqAC                   if        fabitems = *on
CLDqAC                   z-add     pcksum        dsppcs
CLDqAC                   else
CLDqAC                   z-add     pspcs         dsppcs
CLDqAC                   endif
CLDqAC                   else
     C                   eval      dsppcs = pspcs
CLDqAC                   endif
     C                   eval      dspstp = 0
     C                   eval      lststp = -(1)
     C                   eval      dsppli = psplid
     C                   eval      dsprti = psrtid
     C                   eval      dsstp1 = psstp1
     C                   eval      dsstp2 = psstp2
     C     keyss1        setll     pltstp1
     C                   dow       forevr = forevr
     C     keyss1        reade     pltstp1                                78
     C                   if        *in78
     C                   leave
     C                   endif
     C                   if        pssstp <> lststp
     C                   add       1             dspstp
     C                   eval      lststp = pssstp
     C                   endif

750lA *    marking this code out until i find out if it is needed
     *    For a loader merge pallet, where everything on the
     *    pallet goes onto a single truck pallet,
     *    get the corresponding truck pallet for the pallet summary.

     C*****              if        psgen > 1
     C*****                        and opspal = 'Y'
     C*****              eval      truckPallet = 0

     C*****              eval      kyltyp = 'O'
     C*****keyl31        setll     label31

     C*****              dou       forevr <> forevr

     C*****keyl31        reade     label31
     C*****              if        %eof(label31)
     C*****              leave
     C*****              endif

     C*****              if        lbqpck = 0
     C*****              iter
     C*****              endif

     C*****              call      'GETTPL2'
     C*****              parm      '*FIRST'      $gcmd             8
     C*****              parm      lblbl#        $glbl#            7 0
     C*****              parm                    $gtplt            7 0
     C*****              parm                    $gmlbl            7 0
     C*****              parm                    $gmpid            7 0
     C*****              parm                    $gsplt            1
     C*****              parm                    $glow             1
     C*****              parm                    $ghnd2            2
     C*****              parm                    $gqypk            5 0
     C*****              parm                    $gqypl            5 0
     C*****              parm                    $grtn             8

     C*****              if        $grtn = '*OK'
     C*****              eval      truckPallet = $gtplt
     C*****              endif

     C*****              leave
     C*****              enddo
     C*****              if        truckPallet <> 0
     C*****              eval      dsppal = truckPallet
     C*****              endif
     C*****              endif

     C                   enddo
     *
     C                   enddo

      /END-FREE
     p                 e

752kA*****************************************************************
752kA* Get the pallet id and section  - code from PFMT
752kA*****************************************************************
752kAp $GetPlidSec     b
     d $GetPlidSec     pi

751rA*    Item split between multiple sections on pallet.
751rA*    Retrieve pallet section for current case number.
751rAC                   if        lbhnd2 = '*P'
751rAC                   call      'GETSCID'
751rAC                   parm      *blanks       $scmd             8
751rAC                   parm      lbwhse        $swhse            3 0
751rAC                   parm      lblbl#        $slbl#            7 0
751rAC                   parm      lbqpck        $scas#            5 0
751rAC                   parm      *blanks       $sscid            2
751rAC                   parm      *blanks       $srtn             8
751rA /free
751rA     if $srtn = '*OK';
751rA       pltsec = $sscid;
751rA     else;
751rA       pltsec = *blanks;
751rA     endif;
751rA
751rA   // Item assigned to single pallet section.
751rA   else;
751rA     pltsec = lbhnd2;
751rA   endif;
751rA /end-free

752kAp                 e

750lA*****************************************************************
750lA* Get Pick List
750lA*****************************************************************
750lAp $GetPckLst      b
     d $GetPckLst      pi

      /free

     C                   add       1             pckcnt
     C*    pckcnt        occur     pcklst
      /free
        pcklst(pckcnt).pcktrn = lbtrn#;
751bA   if wktype = 'M';
751bA     pcklst(pckcnt).pcklbl = LBCTR#;
751bA   else;
          pcklst(pckcnt).pcklbl = lblbl#;
751bA   endif;
        pcklst(pckcnt).pckitem = lbitem;
        pcklst(pckcnt).pckdesc = itdesc;
751bA   if wktype = 'M';
752kD     //pcklst(pckcnt).pckdisp = %trim(lbwhdp) + %trim(lbstyp);
752kM     pcklst(pckcnt).pckdisp = %trimr(lbdisp) + ' '
752kM                            + %trim(lbwhdp) + %trim(lbstyp);
751bA   else;
          pcklst(pckcnt).pckdisp = lbdisp;
751bA   endif;
        pcklst(pckcnt).pckqty = lbqpck;
        pcklst(pckcnt).pckcub = lbcube;
        pcklst(pckcnt).pckwgt = lbswgt;
        if lbvrfy = ' ';
          pcklst(pckcnt).pckdone = ' ';
        else;
          pcklst(pckcnt).pckdone = 'Y';
        endif;

752kA   chain(n) (lbwhse: lbrte) rtehed;
752kA   if not %found(rtehed);
752kA     rhrte = '';
752kA   endif;

752kA  GetStop('*ORDSTP': lbwhse: lbrte: lbord: lbstop: hostStop);
752kA  if hostStop <= 0;
752kA    w6stop = lbstop;
752kA  else;
752kA    w6Stop = hostStop;
752kA  endif;

752sD   //setll (lbtrn#) pltsum4;
752sD   //dow forever = forever;
752sD     //reade (lbtrn#) pltsum4;
752sD     //if %eof(pltsum4);
752sD       //leave;
752sD     //endif;
752sD   //enddo;

752kA   $GetPlidSec();

752nD   //pcklst(pckcnt).pckdesc2 = 'Rte: ' + %trimr(rhrte) + ' '
        //                        + 'Stp: ' + %char(w6stop) + ' '
        //                      + 'Pal: ' + %Char(pspal#) + %trim(pltsec);
752nM   pcklst(pckcnt).pckdesc2 = ' ';
752nA   pcklst(pckcnt).pckrte = %trimr(rhrte);
752nA   pcklst(pckcnt).pckstp = w6stop;
752pD   //pcklst(pckcnt).pckplt = %Char(pspal#) + %trim(pltsec);
752pM   pcklst(pckcnt).pckplt = %Char(pspal#) + '-' + %trim(pltsec);
750nA   pcklst(pckcnt).pckpal = pspal#;
750nA   pcklst(pckcnt).pcksec = pltsec;
752qA   pcklst(pckcnt).pcktype = lbtype;
752qA   pcklst(pckcnt).pckutyp = lbutyp;
752qA   pcklst(pckcnt).pckuom = lbucod;

      /END-FREE
     p                 e

750pA*----------------------------------------------------------------
750pA* GetLabelZPL    Get Label ZPL code
750pA*----------------------------------------------------------------
750pAp GetLabelZPL     b
     d GetLabelZPL     pi
     d  pCmd                         10    const
     d  pRte                          5    const
     d  pTrn                          7  0 const
     d  pLbl                          7  0 const
     d  pFromSeq                      3  0 const
     d  pToSeq                        3  0 const
     d  pFmt                          8    const

     d  i              s              3  0
     d  fromSeq        s              3  0
     d  toSeq          s              3  0
     d  maxRtnLen      s              5  0
     d  charLeft       s              5  0
     d  pos            s              5  0
     d  insertBefore   s              3
     d  tmpStr         s             50    varying

     d  zCmd           s                   like(pCmd)
     d  zRte           s                   like(pRte)
     d  zTrn           s                   like(pTrn)
     d  zLbl           s                   like(pLbl)
     d  zFromSeq       s                   like(pFromSeq)
     d  zToSeq         s                   like(pToSeq)
     d  zFmt           s                   like(pFmt)

      /free

        if not usingBeltPrt;
          return;
        endif;

        zCmd = pCmd;
        zRte = pRte;
        zTrn = pTrn;
        zLbl = pLbl;
        zFromSeq = pFromSeq;
        zToSeq = pToSeq;
        zFmt = pFmt;

        // The printOutput field is initialized outside of
        // this routine because this routine could be called
        // more than once before displaying a screen. For
        // example, it may be called for printing the last
        // label picked of a transaction, followed by the
        // printing of the pallet label.

        //printOutput = '';

        // currPrintStr is also initialized outside of this routine.
        // See notes at beginning of program about print strings
        // Max length is set lower than actual zplStr size in order to
        // leave room for other JSON stuff, like the Std section and
        // Output section. For string 2 we don't need to leave as much
        // room.

        select;
          when currPrintStr = 1;
            maxRtnlen = 63500;
            //maxRtnlen = 2000;
            charLeft = maxRtnlen - %len(printOutput);
          when currPrintStr = 2;
            maxRtnLen = 64450;
            charLeft = maxRtnlen - %len(printOutput2);
          other;
           return;
        endsl;

        // Initialize some printing variables
        // We assume *GETLABEL will only be sent once for a screen.

        select;

          when pCmd = '*INIT';
            printOutput = '';
            printOutput2 = '';
750vA       printInit = '';
750qA       printedLabel = *off;
750qA       printedSETHED = *off;
750qA       printedSETSUM = *off;
750qA       printedPALLET = *off;
750qA       lastCmd = '';
750qA       lastLbl = 0;
750qA       lastRte = '';
750qA       lastFromSeq = 0;
750qA       lastToSeq = 0;
750qA       lastPrintCnt = 0;
750qA       lastLABEL = *off;
750qA       lastSETHED = *off;
750qA       lastSETSUM = *off;
750qA       lastPALLET = *off;
            return;

          when pCmd = '*GETLABEL';
750qA       printedLabel = *on;
750qA       lastCmd = pCmd;
750qA       lastRte = pRte;
750qA       lastTrn = pTrn;
750qA       lastLbl = pLbl;
750qA       lastFromSeq = pFromSeq;
750qA       lastToSeq = pToSeq;
750qA       lastFmt = pFmt;
750qA       lastPrintCnt = lastToSeq - lastFromSeq + 1;
750qA       lastSETHED = *off;
750qA       lastSETSUM = *off;
750qA       lastPALLET = *off;
750vA       if usingSavedFmt;
750vA         zFmt = 'DATA';
750vA       else;
750vA        zFmt = 'FULL';
750vA       endif;

          when pCmd = '*GETFMT';
            select;
              when pFmt = 'SETHED';
750qA           printedSETHED = *on;
              when pFmt = 'SETSUM';
750qA           printedSETSUM = *on;
              when pFmt = 'PALLET';
750qA           printedPALLET = *on;
            endsl;
750qA       lastCmd = pCmd;
750qA       lastRte = pRte;
750qA       lastTrn = pTrn;
750qA       lastLbl = pLbl;
750qA       //lastFromSeq = pFromSeq;
750qA       //lastToSeq = pToSeq;
750qA       lastFmt = pFmt;
750qA       lastPrintCnt += 1;

          when pCmd = '*GETLAST';
            zCmd = %trim(lastCmd) + 'R';
            zRte = lastRte;
            zTrn = lastTrn;
            zLbl = lastLbl;
            zFromSeq = lastFromSeq;
            zToSeq = lastToSeq;
            zFmt = lastFmt;

        endsl;

        // Call GetZPL to get the ZPL for the requested label(s).
        // Loop until GetZPL says there is no more.

        dow forever = forever;

xxxxA     if prime;
xxxxA       slgbuf = '<GetZPL> '
xxxxA              + 'cmd=' + zcmd  + ' '
xxxxA              + 'whs=' + %char(w1whse)  + ' '
xxxxA              + 'rte=' + zrte  + ' '
xxxxA              + 'lbl=' + %char(zlbl)  + ' '
xxxxA              + 'froms=' + %char(zfromseq) + ' '
xxxxA              + 'tos=' + %char(ztoseq);
xxxxA       WriteVoiceLog ('Inf': slgbuf);
xxxxA     endif;
          GetZPL(zCmd: w1whse: zRte: zTrn: zLbl: zFmt: zFromSeq: zToSeq:
                 charleft: zplRtnCode: zplRtnMsg: zplString);

          if pCmd = '*OPEN' or pCmd = '*SIGNOFF';
            leave;
          endif;

          if zplRtnCode <> '*OK';
            errmsg = zplRtnMsg;
            leave;
          endif;

          select;

            when currPrintStr = 1;
750vA         if pCmd = '*GETBLTTST';
750vA           if usingPeelOff;
750vA             printOutput += '^XA^MMP,N^XZ';
750vA           else;
750vA             printOutput += '^XA^MMR,N^XZ';
750vA           endif;
750vA         endif;
750vA         if pCmd = '*GETINIT';
750vA           printInit += zplString;
750vA           if usingPeelOff;
750vA             printInit += '^XA^MMP,N^XZ';
750vA           else;
750vA             printInit += '^XA^MMR,N^XZ';
750vA           endif;
750vA         else;
                printOutput += zplString;
750vA         endif;

            when currPrintStr = 2;
              printOutput2 += zplString;

            other;

          endsl;
          zplString = '';

          // See if we should go back for more

          if zplRtnMsg = '*MORE' and currPrintStr = 1;
            currPrintStr = 2;
            maxRtnLen = 64450;
            charLeft = maxRtnlen;
            iter;
          endif;

          // Otherwise, we're done

          leave;

        enddo;

      /end-free

     p                 e

750lA*****************************************************************
750lA* Get Stop Summary
750lA*****************************************************************
750lAp $GetStpSum      b
     d $GetStpSum      pi

      /free
        ptrtid = ptrtpo;
750lAc*
750lAc*   Determine if using TruckBUilder Enhanced
750lAc*
750lA      GetTBType(w1Whse: ptrtid: tbType);
750lA      if tbType = 'E';
750lA        tbEnhanced = *on;
750lA        tbPalletType = 'P';
750lA      else;
750lA        tbEnhanced = *off;
750lA        tbPalletType = 'O';
750lA      endif;
     *
     *     Loop through all labels for transaction.
     *
     C     keyl33        setll     label33
     *
     C                   dou       forevr <> forevr
     C     keyl33        reade     label33                                78
     C                   if        *in78
     C                   leave
     C                   endif
     *
     C                   if        PSTYPE <> tbPalletType
     C                   iter
     C                   endif
     *
750wA /free
750wA  // Get Host Stop number
750wA
750wA  hostStop = 0;
750wA  GetStop('*PLTSTP': lbwhse: lbrte: 0: lbstop: hostStop);
750wA  if hostStop <= 0;
750wA    wkstop = lbstop;
750wA  else;
750wA    wkStop = hostStop;
750wA  endif;
      /end-free
     c                   if        wkstop <> stpstp
     c                             and stpstp <> 0
     c** print stop totals
     C                   add       1             stpcnt
     C     stpcnt        occur     stpsum
     C                   eval      dssstp = stpstp
     c                   eval      dsscub = stpcub
     c                   eval      dsspcs = stppcs
     c                   eval      dsswgt = stpwgt
     C                   eval      dsscnm = stpcnm
     C                   eval      dsstrn = stptrn
     C                   eval      stpcub = 0
     C                   eval      stpwgt = 0
     C                   eval      stppcs = 0
     C                   eval      stpcnm = ' '
     C                   eval      stptrn = 0
     c                   endif
     C                   eval      stpstp = wkstop
     c                   eval      stpcub = stpcub + lbcube
     c                   eval      stppcs = stppcs + lbqpck
     c                   eval      stpwgt = stpwgt + lbswgt
     C                   eval      stpcnm = ohcnam
     C                   eval      stptrn = lbtrn#
     c                   eval      sstcub = sstcub + lbcube
     c                   eval      sstpcs = sstpcs + lbqpck
     c                   eval      sstwgt = sstwgt + lbswgt
     *
     C                   enddo
     *
     *     Print final stop and totals
     *
     c** print last stop
     C                   add       1             stpcnt
     C     stpcnt        occur     stpsum
     C                   eval      dssstp = stpstp
     c                   eval      dsscub = stpcub
     c                   eval      dsspcs = stppcs
     c                   eval      dsswgt = stpwgt
     C                   eval      dsscnm = stpcnm
     C                   eval      dsstrn = stptrn
     C                   eval      stpcub = 0
     C                   eval      stpwgt = 0
     C                   eval      stppcs = 0
     C                   eval      stpcnm = ' '
     C                   eval      stpcnm = ' '

     c** print total
     C                   add       1             stpcnt
     C     stpcnt        occur     stpsum
     C                   eval      dsscub = sstcub
     C                   eval      dsswgt = sstwgt
     C                   eval      dsspcs = sstpcs
     C                   eval      dsscnm = 'TOTAL'
     C                   eval      dsstrn = stptrn
     c                   eval      stpcub = 0
     c                   eval      stppcs = 0
     c                   eval      stpwgt = 0
     c                   eval      stpcnm = ' '
     c                   eval      stptrn = 0
     c                   eval      sstcub = 0
     c                   eval      sstpcs = 0
     c                   eval      sstwgt = 0


      /END-FREE
     p                 e

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *     Standard Android Subprocedures
     *----------------------------------------------------------------
     *----------------------------------------------------------------

750fA*----------------------------------------------------------------
750fA*  GetCurrStamp  Get current timestamps
750fA*----------------------------------------------------------------
750fA
750fAp GetCurrStamp    b
     d GetCurrStamp    pi

      /free

         getmicrotime(currstampuc:currstampsys);
         ucOffset = %diff(currstampuc: currstampsys: *HOURS);
         currstamploc = currstampsys + %hours(bfcoffset);

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  CreateRtnError    Create return JSON error string
     *----------------------------------------------------------------

     p CreateRtnError  b
     d CreateRtnError  pi

      /free

         yajl_genOpen(*Off);

           yajl_beginObj();

             // Grab Std section that was sent in and added it

             yajl_addPreformattedPtr('Std': stdPointer: stdLen);

             // Add Output section

             yajl_beginObj('Output');
               yajl_addchar('errmsg': errmsg500);
               yajl_addchar('spoken': errmsg500);
             yajl_endObj();

         yajl_endObj();

           pJsonStr = YAJL_copyBufStr();

         yajl_genClose();

DAM      slgbuf = '<Error> ' + pjsonstr;
DAM      WriteVoiceLog('Err': slgbuf);

      /end-free

     p                 e

751sA*----------------------------------------------------------------
751sA*  $PrimeInit     Prime initialization
751sA*----------------------------------------------------------------
751sA
751sAp $PrimeInit      b
     d $PrimeInit      pi

      /free
750fA
750nA     error = *off;
750fA     errmsg = '';
750qA     skipDSPSCR = *off;
750qA     displayBtnScr = *off;
750fA     spF1F24Flags = '';
750fA     spBtnFlags = '';
750qA     printOutput = '';
750qA     printOutput2 = '';
750vA     printInit = '';
750qA     currPrintStr = 1;
750fA     slgbuf = '<Begin> ' + pjsonstr;
750fA     WriteVoiceLog('Beg': slgbuf);
750qA     WriteClob(pjsonstr: '': '');
750fA
750fA     // See if we should shut down
750fA     // pCmd is initialized in *INZSR
750fA
750fA     if pJsonStr = '*SHUTDOWN';
750pA       GetLabelZPL('*SHUTDOWN': '': 0 : 0 :0 :0:'');
750qA       slgbuf = '<SHUTDOWN> ' + pjsonstr;
750qA       WriteVoiceLog('End': slgbuf);
750fA       *inlr = *on;
750rA       error = *on;
750fA       return;
750fA     endif;
750fA
750fA     // Load JSON string and get pointers to sections
750fA
750fA     LoadJson();
750fA     if error;
750nA       if nxtscr <> '';
750nA         errmsg = errmsg500;
750nA         $SetNxtScr();
750nA       else;
750nA        CreateRtnError();
750nA       endif;
750nA       slgbuf = '<End> '
750nA              + '*INLR=' + *inlr + ' '
750nA              + 'error=' + error + ' '
750nA              + 'nxtscr=' + %trimr(nxtscr) + ' '
750nA              + pjsonstr;
750nA       WriteVoiceLog ('End': slgbuf);
750qA       WriteClob(pjsonstr: '': '');
750fA       return;
750fA     endif;
750fA
750fA     // Get Std field
750fA
750fA     jsonGetFields(stdNode);
750nA     if error;
750nA       if nxtscr <> '';
750nA         $SetNxtScr();
750nA       else;
750nA        errmsg500 = errmsg;
750nA        CreateRtnError();
750nA       endif;
750nA       slgbuf = '<End> '
750nA              + '*INLR=' + *inlr + ' '
750nA              + 'error=' + error + ' '
750nA              + 'nxtscr=' + %trimr(nxtscr) + ' '
750nA              + pjsonstr;
750nA       WriteVoiceLog ('End': slgbuf);
750qA       WriteClob(pjsonstr: '': '');
750nA       return;
750nA     endif;
750fA
      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzFuncKeys   Initialize function keys for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzFuncKeys    b
     d $InzFuncKeys    pi

      /free

         *inka = *off;
         *inkb = *off;
         *inkc = *off;
         *inkd = *off;
         *inke = *off;
         *inkf = *off;
         *inkg = *off;
         *inkh = *off;
         *inki = *off;
         *inkj = *off;
         *inkk = *off;
         *inkl = *off;
         *inkm = *off;
         *inkn = *off;
         *inkp = *off;
         *inkq = *off;
         *inkr = *off;
         *inks = *off;
         *inkt = *off;
         *inku = *off;
         *inkv = *off;
         *inkw = *off;
         *inkx = *off;
         *inky = *off;
         btnReprint = *off;
         btnPltSum = *off;
         btnStpSum = *off;
         btnPckList = *off;
752vA    btnMrgList = *off;

         // When passing through to another program,
         //   Do not set function keys based on Flags field
         //   because those are meant for the other program.
         //   But, manually set fuction key that will allow
         //   this program to call other program.

         select;
           when spWhereFrom = 'TK901.01';
             *inkg = *on;
             return;
           when spWhereFrom = 'OR401.01';
             *inkk = *on;
             return;
         endsl;

         // Set fuction keys for OR400

         select;

           when %subst(spF1F24Flags: 1: 1) = '1';
               *inka = *on;

           when %subst(spF1F24Flags: 2: 1) = '1';
               *inkb = *on;

           when %subst(spF1F24Flags: 3: 1) = '1';
               *inkc = *on;

           when %subst(spF1F24Flags: 4: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.12'
                   or spWhereFrom  = 'OR400.12V';
                   *inki = *on;
                 other;
                   *inkd = *on;
               endsl;

           when %subst(spF1F24Flags: 5: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.18';
                   *inkh = *on;
                 other;
                   *inke = *on;
               endsl;

           when %subst(spF1F24Flags: 6: 1) = '1';
               *inkf = *on;

           when %subst(spF1F24Flags: 7: 1) = '1';
               *inkg = *on;

           when %subst(spF1F24Flags: 8: 1) = '1';
               *inkh = *on;

           when %subst(spF1F24Flags: 9: 1) = '1';
               *inki = *on;

           when %subst(spF1F24Flags: 10: 1) = '1';
               *inkj = *on;

           when %subst(spF1F24Flags: 11: 1) = '1';
               *inkk = *on;

           when %subst(spF1F24Flags: 12: 1) = '1';
               *inkl = *on;

           when %subst(spF1F24Flags: 13: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.03'
                   or spWhereFrom  = 'OR400.03V';
                     *inkh = *on;
                 other;
                   *inkm = *on;
               endsl;

           when %subst(spF1F24Flags: 14: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.07'
                   or spWhereFrom  = 'OR400.17';
                   *inkh = *on;
                 other;
                   *inkn = *on;
               endsl;

           when %subst(spF1F24Flags: 15: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.07';
                   *inki = *on;
                 other;
                   *inkp = *on;
               endsl;

           when %subst(spF1F24Flags: 16: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.04'
                   or spWhereFrom  = 'OR400.05';
                     *inki = *on;
                 other;
                   *inkq = *on;
               endsl;

           when %subst(spF1F24Flags: 17: 1) = '1';
               *inkr = *on;

           when %subst(spF1F24Flags: 18: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.07'
                   or spWhereFrom  = 'OR400.17';
                   *inkg = *on;
                 other;
                   *inks = *on;
               endsl;

           when %subst(spF1F24Flags: 19: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.07';
                   *inkg = *on;
                 other;
                   *inkt = *on;
               endsl;

           when %subst(spF1F24Flags: 20: 1) = '1';
               *inku = *on;

           when %subst(spF1F24Flags: 21: 1) = '1';
               *inkv = *on;

           when %subst(spF1F24Flags: 22: 1) = '1';
               *inkw = *on;

           when %subst(spF1F24Flags: 23: 1) = '1';
               select;
                 when spWhereFrom  = 'OR400.06E';
                   *inkd = *on;
                 other;
                   *inkx = *on;
               endsl;

           when %subst(spF1F24Flags: 24: 1) = '1';
               *inky = *on;

750qA      when %subst(spBtnFlags: 2: 1) = '1';
750qA        btnPltSum = *on;

750qA      when %subst(spBtnFlags: 3: 1) = '1';
750qA        btnStpSum = *on;

750qA      when %subst(spBtnFlags: 4: 1) = '1';
750qA        btnPckList = *on;

750qA      when %subst(spBtnFlags: 5: 1) = '1';
750qA        btnReprint = *on;

           // Going from Lbs to Kgs
           // Setting KiloLbs to K is to ensure button and field
           // are in sync, which they should be.
           // SC7 will switch KiloLbs to P

751sA      when %subst(spBtnFlags: 6: 1) = '1';       // Lbs button clicked
751sA          *inkg = *on;
751sA          KiloLbs = 'K';

           // Going from Kgs to Lbs
           // Setting KiloLbs to P is to ensure button and field
           // are in sync, which they should be.
           // SC7 will switch KiloLbs to K

751sA      when %subst(spBtnFlags: 7: 1) = '1';       // Kgs button clicked
751sA          *inkg = *on;
751sA          KiloLbs = 'P';

752vA      when %subst(spBtnFlags: 8: 1) = '1';
752vA        btnMrgList = *on;

         endsl;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA*  $InzPgmVar     Initialize program variables for SelectPrime
750fA*----------------------------------------------------------------
750fA
750fAp $InzPgmVar      b
     d $InzPgmVar      pi

750qAd  pos            s              5  0

      /free

         getout = *on;
         errmsg500 = '';

         // Extract Input fields

         jsonGetFields(inputNode);

         // Set function keys

         $InzFuncKeys();

750qA    // Special processing when reprinting single label
750qA
750qA    if btnReprint;
750qA      select;
750qA        when lastPrintCnt = 0;
750qA          errmsg = 'There is nothing to reprint';
750qA          skipDSPSCR = *on;
750qA          return;
750qA        when lastPrintCnt = 1;
750qA          GetLabelZPL('*GETLAST': '': 0: 0: 0: 0: '');
750qA          skipDSPSCR = *on;
750qA          return;
750qA      endsl;
750qA    endif;

750qA    // Extract screen to process (nxtscr) from spWhereFrom

750qA    pos = %scan('.': spWhereFrom);
750qA    if pos > 0;
750qA      nxtscr = %subst(spWhereFrom: pos+1);
750qA    endif;

         // Override nxtscr - Check for buttons first

         select;

750qA      //when btnPltSum;
750aA        //returnToScr = nxtscr;
750qA        //nxtscr = '82';
750qA        //displayBtnScr = *on;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750qA      when btnStpSum;
750aA        returnToScr = nxtscr;
750qA        nxtscr = '83';
750qA        displayBtnScr = *on;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750qA      when btnPckList;
750aA        returnToScr = nxtscr;
750qA        nxtscr = '84';
750qA        displayBtnScr = *on;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750qA      when btnReprint;
750aA        returnToScr = nxtscr;
750qA        nxtscr = '85';
750qA        displayBtnScr = *on;

752vA      //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
752vA      when btnMrgList;
752vA        returnToScr = nxtscr;
752vA        nxtscr = '89';
752vA        displayBtnScr = *on;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'LOGIN';
             // Record device that is being used
             deviceType = 'ANDHND';
             SetEquipId(w1whse: #user: deviceType: deviceId: #pgm: equipMsg);

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'OR400.07B';
             nxtscr = '07 ';

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'OR400.07C';
             nxtscr = '07 ';

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'OR400.12A';
  		     nxtscr = '12 ';

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'OR400.12B';
             nxtscr = '12 ';

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750vA      when spWhereFrom  = 'OR400.12V';
750vA        // When '@@rrrrrlllllll' is sent print label for
750vA        // route rrrrr and label number lllllll.
750vA        if %len(%trim(slvfyval)) = 14 and %subst(slvfyval: 1: 2) = '@@';
750vA          monitor;
750vA            GetLabelZPL('*GETLABEL': %subst(slvfyval: 3: 5): 0:
750vA                        %dec(%subst(slvfyval: 8: 7): 7: 0):
750vA                        1: 99:'');
750vA            errmsg = 'Test print of ' + slvfyval;
750vA            skipDSPSCR = *on;
750vA            on-error;
750vA          endmon;
750vA        endif;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'OR401.01';
             // This will take us back to screen that called OR401
             nxtscr = savedNxtScr;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when spWhereFrom  = 'TK901.01';
             // This will take us back to screen that called TK901
             nxtscr = savedNxtScr;

           //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
           when nxtscr =  '';
             error = *on;
             errmsg = 'Error: Where From Screen not found '
                    + '(' + %trimr(spWhereFrom) + ') ';

         endsl;

         savedNxtScr = nxtscr;

750fA    if error;
750nA      $SetNxtScr();
750nA      slgbuf = '<End> '
750nA             + '*INLR=' + *inlr + ' '
750nA             + 'error=' + error + ' '
750nA             + 'nxtscr=' + %trimr(nxtscr) + ' '
750nA             + pjsonstr;
750nA      WriteVoiceLog ('End': slgbuf);
750qA      WriteClob(pjsonstr: '': '');
750fA    endif;

      /end-free

     p                 e

750fA*----------------------------------------------------------------
750fA* Set output for next screen
750fA*----------------------------------------------------------------
750fAp $SetNxtScr      b
     d $SetNxtScr      pi

     d  temp100        s            100    varying

752qAd s84Colors       ds
752qAd  pcktrn_bc                     7    inz('')
752qAd  pcktrn_fc                     7    inz('')
752qAd  pcklbl_bc                     7    inz('')
752qAd  pcklbl_fc                     7    inz('')
752qAd  pckitem_bc                    7    inz('')
752qAd  pckitem_fc                    7    inz('')
752qAd  pckdisp_bc                    7    inz('')
752qAd  pckdesc_fc                    7    inz('')
752qAd  pckdesc_bc                    7    inz('')
752qAd  pckdisp_fc                    7    inz('')
752qAd  pckqty_bc                     7    inz('')
752qAd  pckqty_fc                     7    inz('')
752qAd  pckcub_bc                     7    inz('')
752qAd  pckcub_fc                     7    inz('')
752qAd  pckwgt_bc                     7    inz('')
752qAd  pckwgt_fc                     7    inz('')
752qAd  pckrte_bc                     7    inz('')
752qAd  pckrte_fc                     7    inz('')
752qAd  pckstp_bc                     7    inz('')
752qAd  pckstp_fc                     7    inz('')
752qAd  pckplt_bc                     7    inz('')
752qAd  pckplt_fc                     7    inz('')

752vAd  w89id_bc                      7    inz('')
752vAd  w89id_fc                      7    inz('')
752vAd  w89zone_bc                    7    inz('')
752vAd  w89zone_fc                    7    inz('')
752vAd  w89slot_bc                    7    inz('')
752vAd  w89slot_fc                    7    inz('')
752vAd  w89trx_bc                     7    inz('')
752vAd  w89trx_fc                     7    inz('')
752vAd  w89desc_bc                    7    inz('')
752vAd  w89desc_fc                    7    inz('')
      /free

       // For list displays, just pass the returned JSON string through

       Select;
       When nxtscr = '91 ';
         return;
       When nxtscr = '92 ';
         return;
       Endsl;

       // Initialize JSON buffer

       yajl_genOpen(*Off);

       // Begin main JSON object

       yajl_beginObj();         // Begin JSON string

       // Grab Std section that was sent in and added it

       yajl_addPreformattedPtr('Std': stdPointer: stdLen);

       // Begin Ouput section

       yajl_beginObj('Output');

       // Put error message at beginning

       yajl_addchar('errmsg': %trim(errmsg));
751lA  if errmsg <> '';
751lA    yajl_addchar('screen_bc': cYellow);
751lA    yajl_addchar('errmsg_bc': cFireEngineRed);
751lA    yajl_addchar('errmsg_fc': cWhite);
751lA  endif;

       // Now add screen output

       Select;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = 'EOJ';
         yajl_addchar('nxtscr': 'LOGOUT');

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '01 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w1whse': %Char(W1WHSE));
         yajl_addchar('w1trn': %Char(W1TRN#));
         yajl_addchar('w1eod': w1eod);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '02 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w2lblb': %trim(w2lbl#b));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '03 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('woitem': %trim(woitem));
         yajl_addchar('w3disp': %trim(w3disp));
         yajl_addchar('w3scan': %trim(w3scan));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '04 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('woitem': %trim(woitem));
         yajl_addchar('w4upcd': %trim(w4upcd));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '05 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('woitem': %trim(woitem));
         yajl_addchar('w5lcns': %trim(w5lcns));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;
         yajl_addchar('woitem': %trim(woitem));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(sdisp));
         yajl_addchar('w6uom': %trim(w6uom));
         yajl_addchar('w6lblb': %trim(w6lbl#b));

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);
750rA    if lbtype = 'M';
750rA      yajl_addchar('des01': '(' +
750rA       %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' ' + w6uom + ')' +
751eD      //' Pal#: ' + %Char($slvlopal#) +
751eM      ' Pal#: ' + %Char(pspal#) +
751fD      //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));
750rA    else;
750rA      yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
750rA      '(' + %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' ' + w6uom +')' +
751eD      //' Pal#: ' + %Char($slvlopal#) +
751eM      ' Pal#: ' + %Char(pspal#) +
751fD      //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));
750rA    endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06A';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(woitem));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(sdisp));
         yajl_addchar('w6uom': %trim(w6uom));
lmcxA    if lbtype = 'M';
752jD      //yajl_addchar('des01':  '(' +
752jM      yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
751fD    //%Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' ' + w6uom + ')' +
752jA      '(' +
751fM    %Char(W6aCNT1)+ ' of ' + %Char(W6aCNT2)+ ' ' + w6uom + ')' +
751eD      //' Pal#: ' + %Char($slvlopal#) +
751eM      ' Pal#: ' + %Char(pspal#) +
751fD      //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));
lmcxA    else;
lmcxM      yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
lmcxA      '(' + %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' '+ w6uom + ')' +
751eD      //' Pal#: ' + %Char($slvlopal#) +
751eM      ' Pal#: ' + %Char(pspal#) +
751fD      //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));
lmcxA    endif;
         yajl_addchar('w6alblb': %trim(w6albl#b));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06B';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(woitem));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(sdisp));
         yajl_addchar('w6uom': %trim(w6uom));
         yajl_addchar('w6upcd': %trim(W6UPCD));
750rA    yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
750rA    '(' + %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' ' + w6uom + ')' +
751eD    //' Pal#: ' + %Char($slvlopal#) +
751eM    ' Pal#: ' + %Char(pspal#) +
751fD    //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06C';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(WOITEM));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(SDISP));
         yajl_addchar('w6uom': %trim(W6UOM));
750iA    if w6cnt1 = 0;
750iA      yajl_addchar('w6cnt1e': %Char(w6cnt2));
750iA    else;
           yajl_addchar('w6cnt1e': '');
750iA    endif;
750rA    yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
750rA    '(' + %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' '+ w6uom + ')' +
751eD    //' Pal#: ' + %Char($slvlopal#) +
751eM    ' Pal#: ' + %Char(pspal#) +
751fD    //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06D';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(WOITEM));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(SDISP));
         yajl_addchar('w6uom': %trim(W6UOM));
lmcxM    yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
lmcxA    '(' + %Char(W6CNT1) + ' of ' + %Char(W6CNT2) + ' ' + w6uom + ')' +
751eD    //' Pal#: ' + %Char($slvlopal#) +
751eM    ' Pal#: ' + %Char(pspal#) +
751fD    //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06E';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(WOITEM));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(SDISP));
         yajl_addchar('w6uci': %trim(W6UCI));
lmcxM    yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
lmcxA    '(' + %Char(W6WGT1) + ' of ' + %Char(W6WGT2) + ')'+ 'Lbs' +
751eD    //' Pal#: ' + %Char($slvlopal#) +
751eM    ' Pal#: ' + %Char(pspal#) +
751fD    //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06F';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
752tA    if ssmoreqty;
752tA      yajl_addchar('screen_bc': cLightPurple);
752tA    endif;
         yajl_addchar('woitem': %trim(WOITEM));
751fA    yajl_addchar('woitem2': %trim($IXDSC2));
         yajl_addchar('sdisp': %trim(SDISP));
         yajl_addchar('w6uci': %trim(W6UCI));

751qA    temp100 = 'Slot ' + %char(sdisp);
751qA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);
lmcxM    yajl_addchar('des01': 'Stop: ' + %char(w6stop) + ' ' +
lmcxA    '(' + %Char(W6WGT1) + ' of ' + %Char(W6WGT2) + ')'+ 'Lbs' +
751eD    //' Pal#: ' + %Char($slvlopal#) +
751eM    ' Pal#: ' + %Char(pspal#) +
751fD    //' Zone: ' + %Char($slvlohand2));
751rD      //' ' + %Char($slvlohand2));
751rM    ' ' + %Char(pltsec));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ' and client = saval and type = 'CHK';
751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);
         yajl_addchar('nxtscr': 'OR400.07B');
         If W6CNT2 > 0;
           yajl_addchar('des01': %Char(W6CNT1) + ' entered of '
               + %Char(W6CNT2));
         Endif;
         yajl_addchar('w7um1': %trim(W7UM1));
         //If *In31 = *On;
           //yajl_addchar('OParm4': 'S19-S14-S10');
         //Else;
           //yajl_addchar('OParm4': 'S18-S14-S10');
         //Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ' and client = saval and type = 'SKI';
         yajl_addchar('nxtscr': 'OR400.07C');
751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);
         If W6CNT2 > 0;
           yajl_addchar('des01': %Char(W6CNT1) + ' entered of '
               + %Char(W6CNT2));
         Endif;
         yajl_addchar('w7um1': %trim(W7UM1));
         //If *In31 = *On;
           //yajl_addchar('des02': 'S21-S10');
         //Else;
           //yajl_addchar('des02': 'S20-S10');
         //Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

752vA    if zonepickup and prime;
752vA      temp100 = 'Transaction ' + %char(mgtrn#);
752vA    else;
751qA      temp100 = 'Transaction ' + %char($slvlotrn#);
752vA    endif;
751qA    yajl_addchar('head2': temp100);

752vA    if zonepickup and prime;
752vA      temp100 = 'Lbl ' + %char(mglbl#);
752vA    else;
751qA      temp100 = 'Lbl ' + %char(w2lbl);
752vA    endif;
751qA    yajl_addchar('head3': temp100);

         If W6CNT2 > 0;
751zA      Select;
751zA        when zonepickup;
751zA          yajl_addchar('des01': 'entering ' + %Char(W6CNT1) + ' of '
751zA              + %Char(W6CNT2));
751zD        //if oprfqtcw = 'Y';
751ZM        when oprfqtcw = 'Y';
               yajl_addchar('des01': %Char(W6CNT1) + ' entered of '
                   + %Char(W6CNT1e));
751zD      //else;
751zM        other;
               yajl_addchar('des01': %Char(W6CNT1) + ' entered of '
                 + %Char(W6CNT2));
751zD      //endif;
751zM      endsl;
         Endif;
         yajl_addchar('w7um1': %trim(W7UM1));
         yajl_addchar('w7cwgt': %trim(W7CWGT));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '08 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
751qD    //yajl_addchar('w8trn': %Char(W8TRN#));
751qA    temp100 = '';
751qA    for i = 1 to trncnt;
751qA      if i > 1;
751qA        temp100 += ' ';
751qA      endif;
751qA      temp100 += %char(trnlst(i).trn);
751qA    endfor;
751qA    yajl_addchar('w8trn': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09A';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '10 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         //yajl_addchar('OParm1': %trim(#USER));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '11 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('aisle': %trim(AISLE));

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl );
751qA    yajl_addchar('head3': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12 ';
         Select;
           When *In46 = *On;
             yajl_addchar('nxtscr': 'OR400.12');
             yajl_addchar('sslot': 'Scan Slot: ' + %trim(SSLOT));
           When *In47 = *On;
             yajl_addchar('nxtscr': 'OR400.12A');
             yajl_addchar('cdgt': 'Scan Check Digit: '+ %Char(CDGT));
           When *In48 = *On;
             yajl_addchar('nxtscr': 'OR400.12B');
           Endsl;

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(WOITEM));

         If *In60 = *On;
           yajl_addchar('des01': 'Slot ' + %trim(SDISP));

         Else;
DAM        yajl_addchar('des01': 'Location: ' + %Char(LOCTN)
DAM                            + ' Level: ' + %trim(SLEVEL)
DAM                            + ' Slot: ' + %trim(SHOWDISP));
         Endif;

         If *In51 = *On;
           yajl_addchar('slcns': 'Lic:' + %trim(SLCNS));
         Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12V ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

         yajl_addchar('slvfyval': '');

752jA    temp100 = ('Stop: ' + %char(w6stop) + ' ' +
752jA    '(' + %Char($slvlopickqty)                   + ' '+ w6uom + ')' +
752jA    ' Pal#: ' + %Char(pspal#) +
752jA    ' ' + %Char(pltsec));
752jA    yajl_addchar('head1': temp100);

751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl  );
751qA    yajl_addchar('head3': temp100);

         yajl_addchar('woitem': %trim(WOITEM));

751bA    yajl_addchar('woitem2': %trim($IXDSC2));
750bA
751bD    //If *In60 = *On;
751bD      //yajl_addchar('des01': 'Slot ' + %trim(SDISP));
751bD    //Else;
751bD      //yajl_addchar('des01': 'Location: ' + %Char(LOCTN)
751bD      //                    + ' Level: ' + %trim(SLEVEL)
751bD      //                    + ' Slot: ' + %trim(SHOWDISP));
751bD      //yajl_addchar('w6uom': %trim(w6uom));
751bD    //Endif;
751qD    //yajl_addchar('des01': %trim(SDISP));
751qA    yajl_addchar('des01': %trim(SDISP) +'   Picking ' + %trim(lbucod));
751bA    yajl_addchar('w6uom': %trim(w6uom));

         If *In51 = *On;
           yajl_addchar('slcns': 'Lic:' + %trim(SLCNS));
         Endif;

         yajl_addchar('slvfy': SLVFY + %trim(SLVFYVAL));

CBIbA    if errmsg = '';
CBIbA      if client = Cheney;
CBIbA        if $slside = 1;
CBibA          yajl_addchar('screen_bc': cLightSkyBlue);
CBIbA        else;
CBibA          yajl_addchar('screen_bc': cGreen);
CBIbA        endif;
CBIbA      endif;
CBIbA    endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '13 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('spnd': SPND);
751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '14 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '15 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('mtrn': MTRN);
751qA    temp100 = 'Transaction ' + %char(w1trn#);
751qA    yajl_addchar('head2': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '16 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('cshrt': CSHRT);
751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '17 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w18oitem': %trim(W18OITEM));
         If W17CNT2 > 0;
           yajl_addchar('des01': %Char(W17CNT1) + ' of '
               + %Char(W17CNT2));
         Endif;

752gA    temp100 = 'Transaction ' + %char($slc2otrn#);
752gA    yajl_addchar('head2': temp100);

752gA    temp100 = 'Lbl ' + %char(W18LBL#h);
752gA    yajl_addchar('head3': temp100);

         yajl_addchar('w7um1': %trim(W7UM1));
         yajl_addchar('w7cwgt': %trim(W7CWGT));

         //If *In31 = *On;
           //yajl_addchar('des02': 'S06-S19');
         //Else;
           //yajl_addchar('des02': 'S06-S18');
         //Endif;
         //yajl_addchar('des03': 'S14');

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '18 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w18oitem': %trim(W18OITEM));
         //yajl_addchar('OParm2': %trim(spParm10)); ?????????????????????????
         //spParm10 = '';                           ?????????????????????????

752gA    temp100 = 'Transaction ' + %char($slc2otrn#);
752gA    yajl_addchar('head2': temp100);

752gA    temp100 = 'Lbl ' + %char(W18LBL#h);
752gA    yajl_addchar('head3': temp100);

         If W18STOP   > 0;
           yajl_addchar('des01': 'Stop: '
               + %Char(W18STOP));
         Endif;

         If W18CNT2 > 0;
           yajl_addchar('des02': %Char(W18CNT1) + ' of '
               + %Char(W18CNT2));
         Endif;
         yajl_addchar('w18lblb': %trim(W18LBL#B));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '19 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w19lblb': %trim(W19LBL#B));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '20 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('eupc': EUPC);
751qA    temp100 = 'Transaction ' + %char($slvlotrn#);
751qA    yajl_addchar('head2': temp100);

751qA    temp100 = 'Lbl ' + %char(w2lbl);
751qA    yajl_addchar('head3': temp100);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '21 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('cdone': CDONE);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '22 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('w22trn': %Char(W22TRN));
         yajl_addchar('leavesus': LEAVESUS);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '23 ';
         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
         yajl_addchar('cmpl': zcmpl);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '81 ';

         yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750lA  When nxtscr = '82 ';
750lA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
750lA    yajl_beginArray('listary');
750lA      for i = 1 to palcnt;
750lA        %occur(palsum) = i;
750lA        if dsptrn = 0;
750lA          iter;
750lA        endif;
750lA        yajl_beginObj();
750lA          yajl_addChar('pstrn': %trim(%char(dsptrn)));
750lA          yajl_addChar('pspal': %trim(%char(dsppal)));
750lA          yajl_addChar('psstops': %trim(%char(dspstp)));
750lA          yajl_addChar('pspcs': %trim(%char(dsppcs)));
750lA          yajl_addChar('pscube': %trim(%char(dspcub)));
750lA          yajl_addChar('pswgt': %trim(%char(dspwgt)));
750lA        yajl_endObj();
750lA      endfor;
750lA    yajl_endArray();

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750lA  When nxtscr = '83 ';
750lA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
750lA    yajl_beginArray('listary');
750lA      for i = 1 to stpcnt;
750lA        %occur(stpsum) = i;
750lA        if dsstrn = 0;
750lA          iter;
750lA        endif;
750lA        yajl_beginObj();
750lA          yajl_addChar('stptrn': %trim(%char(dsstrn)));
750lA          yajl_addChar('stpstp': %trim(%char(%editc(dssstp:'Z'))));
750lA          yajl_addChar('stppcs': %trim(%char(dsspcs)));
750lA          yajl_addChar('stpcube': %trim(%char(dsscub)));
750lA          yajl_addChar('stpwgt': %trim(%char(dsswgt)));
750lA          yajl_addChar('stpcnm': %trim(dsscnm));
750lA        yajl_endObj();
750lA      endfor;
750lA    yajl_endArray();

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750lA  When nxtscr = '84 ';
750lA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
750lA    yajl_beginArray('listary');
750lA      for i = 1 to pckcnt;
750lA        //%occur(pcklst) = i;
750lA        if pcklst(i).pcktrn = 0;
750lA          iter;
750lA        endif;
752tA        if opsppldl = 'Y';
752tA          if pcklst(i).pckdone = 'Y';
752tA            iter;
752tA          endif;
752tA        endif;
750lA        yajl_beginObj();
750lA          yajl_addChar('pcktrn': %trim(%char(pcklst(i).pcktrn)));
750lA          yajl_addChar('pcklbl': %trim(%char(pcklst(i).pcklbl)));
750lA          yajl_addChar('pckitem': %trim(pcklst(i).pckitem));
752kD          //yajl_addChar('pckdesc': %trim(pcklst(i).pckdesc));
752kM          yajl_addChar('pckdesc':
752kM              %trim(pcklst(i).pckdesc2) + ' ' + %trim(pcklst(i).pckdesc));
750lA          yajl_addChar('pckdisp': %trim(pcklst(i).pckdisp));
750lA          yajl_addChar('pckqty': %trim(%char(pcklst(i).pckqty)));
750lA          yajl_addChar('pckcub': %trim(%char(pcklst(i).pckcub)));
750lA          yajl_addChar('pckwgt': %trim(%char(pcklst(i).pckwgt)));
750lA          yajl_addChar('pckdone': %trim(pcklst(i).pckdone));
752nA          yajl_addChar('pckrte': %trim(pcklst(i).pckrte));
752nA          yajl_addChar('pckstp': %trim(%char(pcklst(i).pckstp)));
752nA          yajl_addChar('pckplt': %trim(%char(pcklst(i).pckplt)));

752qA    // Set every other row color
752qA
752qA          if %rem(i:2) = 0;
752qA            clear s84Colors;
752qA          else;
752qA            pcktrn_bc = cGainsboro;
752qA            pcktrn_fc = cBlack;
752qA            pcklbl_bc = cGainsboro;
752qA            pcklbl_fc = cBlack;
752qA            pckitem_bc = cGainsboro;
752qA            pckitem_fc = cBlack;
752qA            pckdesc_fc = cBlack;
752qA            pckdesc_bc = cGainsboro;
752qA            pckdisp_fc = cBlack;
752qA            pckdisp_bc = cGainsboro;
752qA            pckqty_bc = cGainsboro;
752qA            pckqty_fc = cBlack;
752qA            pckcub_bc = cGainsboro;
752qA            pckcub_fc = cBlack;
752qA            pckwgt_bc = cGainsboro;
752qA            pckwgt_fc = cBlack;
752qA            pckrte_bc = cGainsboro;
752qA            pckrte_fc = cBlack;
752qA            pckstp_bc = cGainsboro;
752qA            pckstp_fc = cBlack;
752qA            pckplt_bc = cGainsboro;
752qA            pckplt_fc = cBlack;
752qA          endif;
752qA
752qA    // Change slot background of Merge records
752qA
752qA          if pcklst(i).pcktype = 'M';
752qA            pckdisp_bc = cOrange;
752qA          endif;
752qA
752qA    // Change qty background of brkdn records
752qA
752qA          if pcklst(i).pckutyp <> 'N';
752qA            pckqty_bc = cGold;
752qA          endif;
752qA
752qA    // Add colors to JSON string
752qA
752qA          if pcktrn_bc <> '';
752qA            yajl_addchar('pcktrn_bc': pcktrn_bc);
752qA          endif;
752qA          if pcktrn_fc <> '';
752qA            yajl_addchar('pcktrn_fc': pcktrn_fc);
752qA          endif;
752qA          if pcklbl_bc <> '';
752qA            yajl_addchar('pcklbl_bc': pcklbl_bc);
752qA          endif;
752qA          if pcklbl_fc <> '';
752qA            yajl_addchar('pcklbl_fc': pcklbl_fc);
752qA          endif;
752qA          if pckitem_bc <> '';
752qA            yajl_addchar('pckitem_bc': pckitem_bc);
752qA          endif;
752qA          if pckitem_fc <> '';
752qA            yajl_addchar('pckitem_fc': pckitem_fc);
752qA          endif;
752qA          if pckdesc_fc <> '';
752qA            yajl_addchar('pckdesc_fc': pckdesc_fc);
752qA          endif;
752qA          if pckdesc_bc <> '';
752qA            yajl_addchar('pckdesc_bc': pckdesc_bc);
752qA          endif;
752qA          if pckdisp_bc <> '';
752qA            yajl_addchar('pckdisp_bc': pckdisp_bc);
752qA          endif;
752qA          if pckdisp_fc <> '';
752qA            yajl_addchar('pckdisp_fc': pckdisp_fc);
752qA          endif;
752qA          if pckqty_bc <> '';
752qA            yajl_addchar('pckqty_bc': pckqty_bc);
752qA          endif;
752qA          if pckqty_fc <> '';
752qA            yajl_addchar('pckqty_fc': pckqty_fc);
752qA          endif;
752qA          if pckcub_bc <> '';
752qA            yajl_addchar('pckcub_bc': pckcub_bc);
752qA          endif;
752qA          if pckcub_fc <> '';
752qA            yajl_addchar('pckcub_fc': pckcub_fc);
752qA          endif;
752qA          if pckwgt_bc <> '';
752qA            yajl_addchar('pckwgt_bc': pckwgt_bc);
752qA          endif;
752qA          if pckwgt_fc <> '';
752qA            yajl_addchar('pckwgt_fc': pckwgt_fc);
752qA          endif;
752qA          if pckrte_bc <> '';
752qA            yajl_addchar('pckrte_bc': pckrte_bc);
752qA          endif;
752qA          if pckrte_fc <> '';
752qA            yajl_addchar('pckrte_fc': pckrte_fc);
752qA          endif;
752qA          if pckstp_bc <> '';
752qA            yajl_addchar('pckstp_bc': pckstp_bc);
752qA          endif;
752qA          if pckstp_fc <> '';
752qA            yajl_addchar('pckstp_fc': pckstp_fc);
752qA          endif;
752qA          if pckplt_bc <> '';
752qA            yajl_addchar('pckplt_bc': pckplt_bc);
752qA          endif;
752qA          if pckplt_fc <> '';
752qA            yajl_addchar('pckplt_fc': pckplt_fc);
752qA          endif;


750lA        yajl_endObj();
750lA      endfor;
750lA    yajl_endArray();

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
750lA  When nxtscr = '85 ';
750lA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
750lA    yajl_beginArray('listary');
           if lastSETHED;
750lA        yajl_beginObj();
750lA          yajl_addChar('desc': 'SETHED');
750lA          yajl_addChar('rtnval': 'SETHED');
750lA        yajl_endObj();
           endif;
           if lastSETSUM;
750lA        yajl_beginObj();
750lA          yajl_addChar('desc': 'SETSUM');
750lA          yajl_addChar('rtnval': 'SETSUM');
750lA        yajl_endObj();
           endif;
           if lastPALLET;
750lA        yajl_beginObj();
750lA          yajl_addChar('desc': 'PALLET');
750lA          yajl_addChar('rtnval': 'PALLET');
750lA        yajl_endObj();
           endif;
           if lastLabel;
750lA        for i = lastFromSeq to lastToSeq;
750lA          yajl_beginObj();
750lA            temp100 = %char(i) + ' of ' + %char(lastToSeq);
750lA            yajl_addChar('desc': temp100);
750lA            yajl_addChar('rtnval': %char(i));
750lA          yajl_endObj();
             endfor;
750lA      endif;
750lA    yajl_endArray();

751uA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
751uA  When nxtscr = '86 ';
751uA
751uA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));
751uA    temp100 = 'Transaction ';
751uA    for i = 1 to trncnt;
751uA      if i > 1;
751uA        temp100 += ' ';
751uA      endif;
751uA      temp100 += %char(trnlst(i).trn);
751uA    endfor;
751uA    yajl_addchar('head2': temp100);

751uA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
751uA  When nxtscr = '87 ';
751uA
751uA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
752vA  When nxtscr = '88 ';
752vA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

752vA    temp100 = 'Transaction ' + %char(mgtrn#);
752vA    yajl_addchar('head2': temp100);

752vA    yajl_addchar('pickupnum': %char(pickupnum));
752vA    yajl_addchar('w88lbl': %trim(w88lbl));
752vA    yajl_addchar('w88rpcs': %char(w88rpcs));

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
752vA  When nxtscr = '89 ';
752vA    yajl_addchar('nxtscr': 'OR400.' + %trim(nxtscr));

752vA    temp100 = 'Transaction ' + %char(mgtrn#);
752vA    yajl_addchar('head2': temp100);
752vA    yajl_beginArray('listary');

752vA     i = 0;
752vA     exec sql declare mrgcsr cursor for
752vA       select * from spmrgwrk
752vA        where mgjob = :#job
752vA          and mgtrn#= :mgtrn#
752vA          and mgscan = ' ';

752vA     exec sql open mrgcsr;
752vA     if sqlstt <> sqlSuccess;
752vA     endif;

752vA     dow forever = forever;
752vA       exec sql fetch next from mrgcsr into :mrglst;
752vA       if sqlstt <> sqlSuccess;
752vA         leave;
752vA       endif;
752vA       i = i+1;
752vA   yajl_beginObj();

752vA       yajl_addChar('w89id': %char(pickupnum));
752vA       yajl_addchar('w89zone':w89_mgzone);
752vA       yajl_addchar('w89slot':w89_mgdisp);
752vA       yajl_addchar('w89desc':w89_mgdesc);
752vA       yajl_addchar('w89trx': %char(w89_mgpup#));

752vA    // Set every other row color
752vA
752vA          if %rem(i:2) = 0;
752vA            clear s84Colors;
752vA          else;
752vA            w89id_bc = cGainsboro;
752vA            w89id_fc = cBlack;
752vA            w89zone_bc = cGainsboro;
752vA            w89zone_fc = cBlack;
752vA            w89slot_bc = cGainsboro;
752vA            w89slot_fc = cBlack;
752vA            w89desc_fc = cBlack;
752vA            w89desc_bc = cGainsboro;
752vA            w89trx_fc = cBlack;
752vA            w89trx_bc = cGainsboro;
752vA          endif;
752vA
752vA
752vA    // Add colors to JSON string
752vA
752vA          if w89id_bc <> '';
752vA            yajl_addchar('w89id_bc': w89id_bc);
752vA          endif;
752vA          if w89id_fc <> '';
752vA            yajl_addchar('w89id_fc': w89id_fc);
752vA          endif;
752vA          if w89zone_bc <> '';
752vA            yajl_addchar('w89zone_bc': w89zone_bc);
752vA          endif;
752vA          if w89zone_fc <> '';
752vA            yajl_addchar('w89zone_fc': w89zone_fc);
752vA          endif;
752vA          if w89slot_bc <> '';
752vA            yajl_addchar('w89slot_bc': w89slot_bc);
752vA          endif;
752vA          if w89slot_fc <> '';
752vA            yajl_addchar('w89slot_fc': w89slot_fc);
752vA          endif;
752vA          if w89desc_fc <> '';
752vA            yajl_addchar('w89desc_fc': w89desc_fc);
752vA          endif;
752vA          if w89desc_bc <> '';
752vA            yajl_addchar('w89desc_bc': w89desc_bc);
752vA          endif;
752vA          if w89trx_bc <> '';
752vA            yajl_addchar('w89trx_bc': w89trx_bc);
752vA          endif;
752vA          if w89trx_fc <> '';
752vA            yajl_addchar('w89trx_fc': w89trx_fc);
752vA          endif;

752vA        yajl_endObj();

752vA   enddo;
752vA    yajl_endArray();
752vA     exec sql close mrgcsr;


       Endsl;

751sA  // Get button flags
751sA
751sA  $SetButtons();

751lA  // Add default colors (bc=Background Color, fc=Font Color)
751lA
751lA  if spWhereFrom  = 'LOGIN';
751lA    yajl_addchar('screen_bc': dftSP_BC);
751lA    yajl_addchar('errmsg_bc': dftSP_BC);
751lA    yajl_addchar('errmsg_fc': dftSPErr_FC);
751lA  endif;

751lA  // For Testing Only, alternate colors
751lA
751lA  //if spWhereFrom  <> 'LOGIN' and errmsg = '';
       //  testColorSet += 1;
       //  select;
       //    when testColorSet = 1;
751lA  //      yajl_addchar('screen_bc': cLightSkyBlue);
751lA  //      yajl_addchar('errmsg_bc': cOrange);
751lA  //      yajl_addchar('errmsg_fc': cWhite);
       //    when testColorSet = 2;
751lA  //      yajl_addchar('screen_bc': cMintGreen);
751lA  //      yajl_addchar('errmsg_bc': cYellow);
751lA  //      yajl_addchar('errmsg_fc': cBlack);
       //    other;
       //      testColorSet = 0;
       //  endsl;
751lA  //endif;

751lM  // Add tran and label number for reference

751lA  yajl_addchar('w2trn': %char(w2trn));
751lM  yajl_addchar('w2lbl': %char(w2lbl));

751sD  // Add function key display
751sD
751sD  //yajl_addchar('f1f24flags': spf1f24flags);
751sD  //yajl_addchar('btnflags': spBtnFlags);

       // Add what to speak

       yajl_addchar('spoken': GetSpoken());

       // Add what to print

       if %len(printOutput) > 0;
         yajl_addchar('printerId': %trim(printerId));
751cD    //if printerId = '00:00:00:00:00:00';
751cM    if printTest;
           yajl_addchar('printtest': printOutput);
         else;
           yajl_addchar('print': printOutput);
         endif;
         lastPrintOut = printOutput;
751yA    lastPrintOut2 = printOutput2;
         printOutput = '';
751yA    printOutput2 = '';
         if printedLabel;
           lastLABEL = printedLabel;
           printedLabel = *off;
         endif;
         if printedSETHED;
           lastSETHED = printedSETHED;
           printedSETHED = *off;
         endif;
         if printedSETSUM;
           lastSETSUM = printedSETSUM;
           printedSETSUM = *off;
         endif;
         if printedPALLET;
           lastPALLET = printedPALLET;
           printedPALLET = *off;
         endif;
       endif;
       //if printedLabel or printedPallet;
       //  reprintScr = nxtscr;
       //endif;

750vA  if %len(printInit) > 0;
750va    yajl_addchar('printinit': printInit);
750vA    printInit = '';
750vA  endif;

       yajl_endObj();                 // End Output section
       yajl_endObj();                 // End entire JSON string
       pJsonStr = YAJL_copyBufStr();  // Copy JSON string into parameter
       yajl_genClose();               // Close and cleanup JSON processing

      /END-FREE
     p                 e

751sA*----------------------------------------------------------------
751sA* Set button output for next screen
751sA*----------------------------------------------------------------
751sAp $SetButtons     b
     d $SetButtons     pi

      /free
       spF1F24Flags = '000000000000000000000000';
       spbtnFlags = '0000000000';

752aA  %subst(spBtnFlags: 5: 1) = '1';            // Reprint
752aA  %subst(spF1F24Flags: 12: 1) = '1';         // Cancel

       Select;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '01 ';
         %subst(spF1F24Flags: 3: 1) = '1';
         %subst(spF1F24Flags: 7: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '02 ';
         %subst(spF1F24Flags: 7: 1) = '1';
         %subst(spF1F24Flags: 9: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '03 ';
         %subst(spF1F24Flags: 7: 1) = '1';
         %subst(spF1F24Flags: 8: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:11: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '04 ';
         %subst(spF1F24Flags: 9: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '05 ';
         %subst(spF1F24Flags: 9: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06 ';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06A';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06B';
         %subst(spF1F24Flags: 2: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06C';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06D';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06E';
         %subst(spF1F24Flags: 4: 1) = '1';
         %subst(spF1F24Flags: 6: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06F';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ' and client = saval and type = 'CHK';
         %subst(spF1F24Flags: 7: 1) = '1';
         %subst(spF1F24Flags: 8: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ' and client = saval and type = 'SKI';
         %subst(spF1F24Flags: 7: 1) = '1';
         %subst(spF1F24Flags:10: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ';
751sA    %subst(spF1F24Flags: 8: 1) = '1';            // Accept wgt
751sA    %subst(spF1F24Flags: 10: 1) = '1';           // Short
752gD    //if *In31 = *On;
752gA    if kilolbs = 'P';
751sA      %subst(spBtnFlags: 7: 1) = '1';            // Kgs
751sA    else;
751sA      %subst(spBtnFlags: 6: 1) = '1';            // Lbs
751sA    endif;
751sA    if *In62 = *On;
751sA      %subst(spF1F24Flags: 9: 1) = '1';          // Weigh Later
751sA    endif;
751sA    if *In64 = *On;
751sA      %subst(spF1F24Flags: 6: 1) = '1';          // Done
751sA    endif;

751sD    //Select;
751sD    //  When *In31 = *Off And *In64 = *On;
751sD    //    %subst(spF1F24Flags: 6: 1) = '1';         // Done
751sD    //    %subst(spF1F24Flags: 7: 1) = '1';         // Lbs/Kgs
751sD    //    %subst(spF1F24Flags: 8: 1) = '1';         // Accept wgt
751sD    //  When *In31 = *Off And *In64 = *Off;
751sD    //    %subst(spF1F24Flags: 7: 1) = '1';         // Lbs/Kgs
751sD    //    %subst(spF1F24Flags: 8: 1) = '1';         // Accept wgt
751sD    //  When *In31 = *On  And *In64 = *On;
751sD    //    %subst(spF1F24Flags: 6: 1) = '1';         // Done
751sD    //    %subst(spF1F24Flags: 7: 1) = '1';         // Lbs/Kgs
751sD    //    %subst(spF1F24Flags: 8: 1) = '1';         // Accept wgt
751sD    //  When *In31 = *On  And *In64 = *Off;
751sD    //    %subst(spF1F24Flags: 7: 1) = '1';         // Lbs/Kgs
751sD    //    %subst(spF1F24Flags: 8: 1) = '1';         // Accept wgt
751sD    //EndSl;

751sD    //If *In62 = *On;
751sD    //  %subst(spF1F24Flags: 9: 1) = '1';           // Later
751sD    //  %subst(spF1F24Flags:10: 1) = '1';           // Short
751sD    //Else;
751sD    //  %subst(spF1F24Flags:10: 1) = '1';
751sD    //Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09 ';
         %subst(spF1F24Flags: 3: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09A';
         %subst(spF1F24Flags: 3: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '10 ';
         %subst(spF1F24Flags: 3: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '11 ';
752aA    %subst(spF1F24Flags: 7: 1) = '1';            // Task
         %subst(spF1F24Flags: 8: 1) = '1';            // Label
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12 ';
751sA    %subst(spF1F24Flags: 1: 1) = '1';            // Next Slot
751sA    %subst(spF1F24Flags: 7: 1) = '1';            // Task
751sA    %subst(spF1F24Flags: 8: 1) = '1';            // Label
751sA    %subst(spF1F24Flags: 9: 1) = '1';            // Skip Verify
751sA    %subst(spF1F24Flags: 10: 1) = '1';           // Short
751sA    If *In63 = *On;
751sA      %subst(spF1F24Flags: 6: 1) = '1';          // Weigh
751sA    Endif;
752eD    //If *In49 = *Off;
752eM    If oprfcs = 'Y';
751sA      %subst(spF1F24Flags: 11: 1) = '1';         // Change Slot
751sA    Endif;

751sD    //If *In63 = *On;
751sD    //  %subst(spF1F24Flags: 1: 1) = '1';
751sD    //  %subst(spF1F24Flags: 6: 1) = '1';
751sD    //  %subst(spF1F24Flags: 7: 1) = '1';
751sD    //  %subst(spF1F24Flags: 8: 1) = '1';
751sD    //Else;
751sD    //  %subst(spF1F24Flags: 1: 1) = '1';
751sD    //  %subst(spF1F24Flags: 7: 1) = '1';
751sD    //  %subst(spF1F24Flags: 8: 1) = '1';
751sD    //Endif;
751sD
751sD    //If *In49 = *On;
751sD    //  %subst(spF1F24Flags: 9: 1) = '1';
751sD    //  %subst(spF1F24Flags:10: 1) = '1';
751sD    //  %subst(spF1F24Flags:12: 1) = '1';
751sD    //Else;
751sD    //  %subst(spF1F24Flags: 9: 1) = '1';
751sD    //  %subst(spF1F24Flags:10: 1) = '1';
751sD    //  %subst(spF1F24Flags:11: 1) = '1';
751sD    //  %subst(spF1F24Flags:12: 1) = '1';
751sD    //Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12V ';
751sA    %subst(spF1F24Flags: 1: 1) = '1';            // Next Slot
751sA    %subst(spF1F24Flags: 7: 1) = '1';            // Task
751sA    %subst(spF1F24Flags: 8: 1) = '1';            // Label
751sA    %subst(spF1F24Flags: 9: 1) = '1';            // Skip Verify
751sA    %subst(spF1F24Flags: 10: 1) = '1';           // Short
751sA    If *In63 = *On;
751sA      %subst(spF1F24Flags: 6: 1) = '1';          // Weigh
751sA    Endif;
752eD    //If *In49 = *Off;
752eM    If oprfcs = 'Y';
751sA      %subst(spF1F24Flags: 11: 1) = '1';         // Change Slot
751sA    Endif;

751sD    //If *In63 = *On;
751sD    //  %subst(spF1F24Flags: 1: 1) = '1';
751sD    //  %subst(spF1F24Flags: 6: 1) = '1';
751sD    //  %subst(spF1F24Flags: 7: 1) = '1';
751sD    //  %subst(spF1F24Flags: 8: 1) = '1';
751sD    //Else;
751sD    //  %subst(spF1F24Flags: 1: 1) = '1';
751sD    //  %subst(spF1F24Flags: 7: 1) = '1';
751sD    //  %subst(spF1F24Flags: 8: 1) = '1';
751sD    //Endif;
751sD
751sD    //If *In49 = *On;
751sD    //  %subst(spF1F24Flags: 9: 1) = '1';
751sD    //  %subst(spF1F24Flags:10: 1) = '1';
751sD    //  %subst(spF1F24Flags:12: 1) = '1';
751sD    //Else;
751sD    //  %subst(spF1F24Flags: 9: 1) = '1';
751sD    //  %subst(spF1F24Flags:10: 1) = '1';
751sD    //  %subst(spF1F24Flags:11: 1) = '1';
751sD    //  %subst(spF1F24Flags:12: 1) = '1';
751sD    //Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '17 ';
752gA    if not *in31 and *in64;
           %subst(spF1F24Flags: 6: 1) = '1';
752gA    endif;
752gA    if kilolbs = 'P';
751sA      %subst(spBtnFlags: 7: 1) = '1';            // Kgs
751sA    else;
751sA      %subst(spBtnFlags: 6: 1) = '1';            // Lbs
751sA    endif;
         %subst(spF1F24Flags: 7: 1) = '1';
         %subst(spF1F24Flags: 8: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '18 ';
         %subst(spF1F24Flags: 8: 1) = '1';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '19 ';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '20 ';
         %subst(spF1F24Flags:12: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '81 ';
         %subst(spF1F24Flags: 3: 1) = '1';
         %subst(spBtnFlags: 1: 1) = '1';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '87 ';
         %subst(spF1F24Flags:12: 1) = '1';

752vA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
752vA  When nxtscr = '88 ';
752vA    %subst(spF1F24Flags: 6: 1) = '1';
752vA    %subst(spBtnFlags: 8: 1) = '1';

       Endsl;

       // Add function key display

       yajl_addchar('f1f24flags': spf1f24flags);
       yajl_addchar('btnflags': spBtnFlags);

      /END-FREE
     p                 e

750jA*----------------------------------------------------------------
750jA* Get Spoken words for screen
750jA*----------------------------------------------------------------
750jAp GetSpoken       b
     d GetSpoken       pi           200    varying

     d  spSpoken       s            200    varying

      /free

       spSpoken = '';

       Select;

       When errmsg <> '';
         spSpoken   = %trim(errmsg);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = 'EOJ';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '01 ';
751tA    if w1trn# = 0;
           spSpoken   = 'scan transaction number';
751tA    endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '02 ';
         spSpoken   = 'scan pick label';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '03 ';
         spSpoken   = 'go to aisle ' + $slvloaisle + ' ' +
                      'location ' + %Char($slvloloc) +
                      ' level ' +  %Char($slvlolevel);

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '04 ';
         spSpoken   = 'scan u p c for verification';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '05 ';
         spSpoken   = 'scan the license';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06 ';
         spSpoken   = 'picking' + %trim($slvlouomdsc);
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
750zA      spSpoken   = %trimr(spSpoken) +
                       'scan the pick label';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06A';
         spSpoken   = 'picking' + %trim($slvlouomdsc);
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
750zA      spSpoken   = %trimr(spSpoken) +
                       'scan the pick label';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06B';
         //spSpoken   = 'scan the u p c';
750mA    spSpoken   = 'picking' + %trim($slvlouomdsc);
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
750zA      spSpoken   = %trimr(spSpoken) +
                       'scan the u p c';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06C';
         if w6cnt1 = 0;
           spSpoken   = 'pick ' + %char(W6CNT2) +
                        //W6uom;
                        %trim($slvlouomdsc);
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
         else;
           spSpoken   = 'enter quantity picked';
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
         endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06D';
         spSpoken   = 'picking' + %trim($slvlouomdsc);
750zA      if opvssn = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'for stop ' +
750zA                   %char(w6stop) + ',';
750zA      endif;
750zA      if opvspn <> '0' and opvspn <> 'N';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'pallet ' +
751eD                   //%char($slvlopal#);
751eM                   %char(pspal#);
750zA      endif;
750zA      if opvspz = 'Y';
750zA      spSpoken   = %trimr(spSpoken) + ' ' + 'zone ' +
751rD                   //%char($slvlohand2);
751rM                   %char(pltsec);
750zA      endif;
750zA      spSpoken   = %trimr(spSpoken) +
                       'scan u c i g s 1 barcode';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06E';
         spSpoken   = 'scan or enter the weight';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '06F';
         spSpoken   = 'scan or enter the weight';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '07 ';

         Select;
           When client = saval
               and type = 'CHK';
             spSpoken   = 'scan or enter the weight';

           When client = saval
               and type = 'SKI';
             spSpoken   = 'scan or enter the item';

           Other;

             spSpoken   = 'scan or enter the weight';

         EndSl;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '08 ';
         spSpoken   = 'all labels are done for transaction';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09 ';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '09A';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '10 ';
         spSpoken   = 'user ' + #user +
                     ' does not exist in dakota, press cancel to exit';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '11 ';
         spSpoken   = 'go to aisle ' + aisle +
                     ' press next when ready';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12 ';

         If *In60 = *On;
           spSpoken   = 'go to aisle ' + lbaisl + ' ' +
                        'location ' + %Char(lbloc) +
                        ' level ' +  %Char(lbrlvl) + lbhand ;
         Else;
           spSpoken   = 'location ' + %Char(loctn) +
                        ' level ' + %Char(slevel) ;
         Endif;

         If *In46 = *On;
           spSpoken   = %trimr(spSpoken) + ' ' +
                     ' scan slot';
         Endif;

         If *In47 = *On;
           spSpoken   = %trimr(spSpoken) + ' ' +
                     ' scan check digit';
         Endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '12V ';

         // large quantity warning
         if opvslw = 'Y' and $slvlobulk = '1';
           spSpoken   = %trimr(spSpoken) + ' ' +
                        'large quantity next'+ comma;
         endif;

         // picking breakdown
         if $SLVLOCTYPE = '1';
           spSpoken   = %trimr(spSpoken) + ' ' +
                        %trim(opspbtxt)+ comma;
                        //'Next item is break down'+ comma;
         endif;

         If *In60 = *On;
           spSpoken   = %trimr(spSpoken) + ' ' +
                        'go to aisle ' + lbaisl + ' ' +
                        'location ' + %Char(lbloc) +
                        ' level ' +  %Char(lbrlvl) + lbhand ;
         Else;
           spSpoken   = %trimr(spSpoken) + ' ' +
                        'location ' + %Char(loctn) +
                        ' level ' + %Char(slevel) ;
         Endif;

xxx      spSpoken   = %trimr(spSpoken) + ' ' + 'picking' + ' ' +
xxx                   %trim($slvlouomdsc);
         spSpoken   = %trimr(spSpoken) + ' ' + slvfy;


       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '13 ';
         spSpoken   = 'are you sure you want to ' +
                      'suspend the transaction';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '14 ';
         spSpoken   = 'go to zone pickup press next';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '15 ';
         spSpoken   = 'do you have anymore transactions to start';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '16 ';
         spSpoken   = 'are you sure you want to short the label';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '17 ';
         spSpoken   = 'scan or enter the weight';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '18 ';
         spSpoken   = %trimr(errmsg) + ' ' + 'scan the pick label';
         // need to clear out the errmsg, so it doesn't speak it twice
         errmsg = ' ';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '19 ';
         spSpoken   = 'scan the pick label you would like' +
                      ' to enter weights for';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '20 ';
         spSpoken   = 'what is wrong with the u p c';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '21 ';
         spSpoken   = 'are you sure you want to ' +
                      'suspend the transaction';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '22 ';
         spSpoken   = 'are you sure you want to ' +
                        'leave transaction ' + %Char(w22trn) +
                        ' suspended';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '23 ';
         spSpoken   = 'is zone pickup completed';

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '81 ';
         if printerId = '';
           spSpoken   = 'scan printer mac i d';
         else;
           spSpoken   = 'check printer is working';
         endif;

       //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
       When nxtscr = '82 ';
         spSpoken   = 'pallet summary';

751uA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
751uA  When nxtscr = '86 ';
751uA    spSpoken   = 'scan desk top printer';

751uA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
751uA  When nxtscr = '87 ';
752lA    //spSpoken   = 'enter maximum pallets';
752lM    spSpoken   = 'Scan Pallet Jack I D';

752vA  //<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
752vA  When nxtscr = '88 ';
752vA    spSpoken   = 'Find Number ' + %Char(pickupnum1) + ' ' +
752vA                 %Char(pickupnum2) + ' ' +
752vA                 %Char(pickupnum3) + ' ' +
752vA                 'Scan Label';

       Endsl;

       return spSpoken;

      /END-FREE
     p                 e

752aA*----------------------------------------------------------------
752aA* LowerToUpper   Convert lowercase to uppercase
752aA*----------------------------------------------------------------
752aA
752aAp LowerToUpper    b
     d LowerToUpper    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(lowercase: uppercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * UpperToLower   Convert uppercase to lowercase
     *----------------------------------------------------------------

     p UpperToLower    b
     d UpperToLower    pi         65535A   varying
     d  value                     65535A   varying const

     * Local Variables

     d strOut          s          65535A   varying
     d lowercase       c                   'abcdefghijklmnopqrstuvwxyz'
     d uppercase       c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

      /free

        strOut = %xlate(uppercase: lowercase: value);

        return strOut;

      /end-free
     p                 e

     *----------------------------------------------------------------
     * SetPgmField      Set program field
     *----------------------------------------------------------------

     p SetPgmField     b
     d SetPgmField     pi
     d  key                          50A   varying const
     d  val                                like(yajl_val) const

     d  value          s            100    varying
     d lowkey          s             50A   varying

      /free

        // Force keys to lowercase to eliminate case errors

        lowkey = UpperToLower(key);

         // Move value into screen field

         monitor;

           select;

             // Standard Fields

             when lowkey = 'app';
               spApp = yajl_get_string(val);

             when lowkey = 'user';
               spUser = yajl_get_string(val);

             when lowkey = 'uid';
               spUid = yajl_get_string(val);

             when lowkey = 'wherefrom';
               spWhereFrom = yajl_get_string(val);

             when lowkey = 'whouse';
               spWhouse = yajl_get_string(val);

             // Input screen fields

             when lowkey = 'f1f24flags' or key = 'flags';
               spF1F24Flags = yajl_get_string(val);

             when lowkey = 'btnflags';
               spBtnFlags = yajl_get_string(val);

             when lowkey = 'w1eod';
               w1eod = yajl_get_string(val);

             when lowkey = 'w1trn';
               value = yajl_get_string(val);
               if value = '';
                 value = '0';
               endif;
               w1trn# = %dec(value: 7: 0);

             when lowkey = 'w2lblb';
               w2lbl#b = yajl_get_string(val);

             when lowkey = 'woitem';
               woitem = yajl_get_string(val);


             when lowkey = 'w3disp';
               w3disp = yajl_get_string(val);

             when lowkey = 'w3scan';
               w3scan = yajl_get_string(val);

             when lowkey = 'slvfyval';
               slvfyval = yajl_get_string(val);
752aA          slvfyval = LowerToUpper(slvfyval);

             when lowkey = 'w4upcd';
               w4upcd = yajl_get_string(val);

             when lowkey = 'w5lcns';
               w5lcns = yajl_get_string(val);

             when lowkey = 'w6lblb';
               w6lbl#b = yajl_get_string(val);

             when lowkey = 'w6alblb';
               w6albl#b = yajl_get_string(val);

             when lowkey = 'w6upcd';
               w6upcd = yajl_get_string(val);

             when lowkey = 'w6cnt1e';
               value = yajl_get_string(val);
               if value = '';
                 value = '0';
               endif;
               w6cnt1e = %dec(value: 5: 0);

             when lowkey = 'w6uci';
               w6uci = yajl_get_string(val);

             when lowkey = 'w7cwgt';
               w7cwgt = yajl_get_string(val);

             when lowkey = 'sslot';
               sslot = yajl_get_string(val);

             when lowkey = 'cdgt';
               value = yajl_get_string(val);
               if value = '';
                 value = '0';
               endif;
               cdgt = %dec(value: 3: 0);

             when lowkey = 'spnd';
               spnd = yajl_get_string(val);

             when lowkey = 'mtrn';
               mtrn = yajl_get_string(val);

             when lowkey = 'cshrt';
               cshrt = yajl_get_string(val);

             when lowkey = 'w18lblb';
               w18lbl#b = yajl_get_string(val);

             when lowkey = 'w19lblb';
               w19lbl#b = yajl_get_string(val);

             when lowkey = 'eupc';
               eupc = yajl_get_string(val);

             when lowkey = 'cdone';
               cdone = yajl_get_string(val);

             when lowkey = 'leavesus';
               leavesus = yajl_get_string(val);

             when lowkey = 'cmpl';
               zcmpl = yajl_get_string(val);

             when lowkey = 'tkcode';
               $lcode = yajl_get_string(val);

             when lowkey = 'slotdisp';
               $newsl = yajl_get_string(val);

             when lowkey = 'w1disp';
               $newsl = yajl_get_string(val);

             when lowkey = 'pcklbl';
               value = yajl_get_string(val);
               if value = '';
                 value = '0';
               endif;
               w84lb# = %dec(value: 7: 0);
               w84lb#Char = value;

             when lowkey = 'deviceid';
               deviceId = yajl_get_string(val);

             when lowkey = 'printerid';
               printerId = yajl_get_string(val);

             when lowkey = 'reprintseq';
               value = yajl_get_string(val);
               if value = '';
                 value = '0';
               endif;
               reprintSeqChr = value;
               if reprintSeqChr <> 'SETHED'
                and reprintSeqChr <> 'SETSUM'
                and reprintSeqchr <> 'PALLET'
751uA           and reprintSeqchr <> 'BIGPAL';
                  reprintSeq = %dec(value: 5: 0);
               else;
                  reprintSeq = 0;
               endif;

             when lowkey = 'reprinttype';
               reprintType = yajl_get_string(val);

751uA        when lowkey = 'bigpaldev';
751uA          bigPalDev = yajl_get_string(val);
751uA          bigPalDev = LowerToUpper(bigPalDev);

751uA        when lowkey = 'paljckdev';
751uA          pltjack = yajl_get_string(val);
751uA          pltjack = LowerToUpper(pltjack);

752vA        when lowkey = 'w88lbl';
752vA          w88lbl = yajl_get_string(val);
           endsl;

         on-error;

           error = *on;
           errmsg = 'Error extracting field ' + %trim(key);
           return;

         endmon;

      /end-free
     p                 e

750fA*----------------------------------------------------------------
750fA*  LoadJson   Load JSON into memory
750fA*----------------------------------------------------------------
750fA
750fAp LoadJson        b
     d LoadJson        pi

      /free

        // Load JSON string into memory and get pointer to root node/object

        docNode = yajl_string_load_tree( pJsonStr : yajlerr );
        if yajlerr <> '';
          error = *on;
          errmsg500 = 'Error loading JSON string - ' + yajlerr;
750nD     //CreateRtnError();
          return;
        endif;

        // Get pointer to Std section

        stdNode = yajl_object_find(docNode: 'Std');
        if stdNode = *null;
          error = *on;
          errmsg500 = 'Error loading Std section';
750nD     //CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;


        stdLen = YAJL_stringify(stdNode: stdPointer: %len(stdBuffer));

        // Get pointer to Input section

        inputNode = yajl_object_find(docNode: 'Input');
        if inputNode = *null;
          error = *on;
          errmsg500 = 'Error loading Input section';
750nD     //CreateRtnError();
          yajl_tree_free( docNode );
          return;
        endif;

        inputLen = YAJL_stringify(inputNode: inputPointer: %len(inputBuffer));

      /end-free

     p                 e

     *----------------------------------------------------------------
     *  JSON Subprocedures
     *----------------------------------------------------------------

      /copy qcopysrc,$jsonstr


     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
Trans started, can not cancel
Label rec not for transaction
Wrong slot scanned
Trans not found
No zone found
Trans not open
Wrong upc scanned
item dept not allowed
Not enough avail Inv.
Invalid qty
Invalid Check Digit
Slot can not be empty
Weights already entered.
Wrong Label.
Bulk not allowed.
**  EM - Error message
Not allowed Export at this time.
Route already exported to Host.
