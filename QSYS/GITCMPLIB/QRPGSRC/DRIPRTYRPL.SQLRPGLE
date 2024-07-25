      /COPY *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2002 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  DRIPRTYRPL  Dakota realtime interface - Priority replenishments
     *  20 October 2001
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
416  *    10/30/01  DAS  4.16
     *      - Created
     *
416a *    01/11/02  DAS  4.16a
     *      - Added subcommands *CRTRPLSEQ and *SEQPRTRPL.
     *      - Added SLOT2 file.
     *      - Replaced call to DRISLOT with subroutine drislotsr
     *        because it created a recursive call.
     *
416b *    02/22/02  DAS  4.16b
     *      - Revised chk4rpl routine to delete any 'D' records.
     *
416c *    02/25/02  DAS  4.16c
     *      - Revised createrpl to not check for existing repl.
     *      - Revised createrpl to delete all open priority replenishments
     *        for item first.
     *      - Added routine updprtyrpl.
     *
416d *    03/06/02  DAS  4.16d
     *      - Revised updprtyrpl to iter after deleting record.
     *      - Revised addprtyrpl to init prflag after getting seq#.
     *
416eA*    06/11/02  DAS  4.16e
     *      - Recompiled because of change to C#SLOT.
     *
417 A*    07/22/03  MLB  4.17
     *      - Enh: Revised program to update new fields added to
     *        PRPLFIL.
417aA*    09/09/03  MLB  4.17a
     *      - Enh: Revised program to set replenishment type flag.
      *
417bA*    12/30/03  DAS  4.17b
     *      - Enh: Added *CRTRPLSQ1 through *CRTRPLSQ9. See notes.
417cA*    01/05/04  RH   4.17c
     *      - Enh: Do not delete Just in time replenishments (priority <>0)
     *
417dA*    02/10/04  DAS  4.17d
     *      - Fix: Revised to save the original qtyneeded and write it
     *        to PRAQS.
     *
500 A*    10/14/04  DAS  5.00
     *      - Enh: Added "client" logic.
     *      - Enh: Added command *CRTRPLDKO.
     *      - Enh: Change 'Pushback' to 'FlowRack' replenishment,
     *        which is based on the pick slot's slot definition pallet
     *        code being '*FLOW'.
     *      - Enh: Change 'Eaches' to 'Breakdown' replenishment
     *        because it is for Breakdown (Type 'B') items.
     *      - Enh: Revised to work with *REPLEN options as in LT110A.
     *      - Enh: Revised to work with *REPLEN options as in LT110A.
     *
500aA*    10/14/04  DAS  5.00a
     *      - Originally from LT110A 10/09/03  MLB  4.17b
     *      - Enh: Revised program to set From/To slot position field.
     *        This is used to locate PushBack/Eaches Priority
     *        Replenishments.
     *
500bA*    10/15/04  DAS  5.00b
     *      - Revised QTYNOTSNT check to properly do check when slot
     *        is NOT sent.
     *
500cA*    10/18/04  DAS  5.00c
     *      - Added subcommands *ORDQTY, *AVGQTY, *RPLLVL, *AVGnnn.
     *
500dA*    10/30/04  DAS  5.00d
     *      - Revised getqtyneeded routine to round up the average if
     *        it has a decimal portion (i.e. 0.12 would become 1, while
     *        2.00 would stay at 2).
     *
500eA*    10/31/04  DAS  5.00e
     *      - Revised crtbrkfix and crtbrkovr to set pick qty to 1 if
     *        the slot to replenish did not have a ti/hi defined for it.
     *
500fA*    11/03/04  DAS  5.00f
     *      - Removed criteria that a PIR parent slot must be Reserved.
     *
500gA*    03/05/05  DAS  5.00g
     *      - Revised getslotpos to use DRILICHIST.
     *      - Revised to only get slot position for from pallet.
     *      - Revised to only get slot position for Flow & Brk repl.
     *
500hA*    03/24/05  MLB  5.00h
     *      - This is 3/24/05 500j in jordanos 5.10 version.
     *      - Enh: Create new command *CRTRPFSQ1 - 9 to force a priority
     *        replenishment to be created even if pick slot has available
     *        quantity that exceeds needed quantity. Setting priority
     *        will be the same as command *CRTRPLSQ1 - 9.
     *
500iA*    04/15/05  MLB  5.00i
     *      - Fix: Revised routine getqtyneeded to set iitqo, qtyneeded,
     *        savqtyneeded to zero when ITEMORD record not found.
     *
500kA*    03/25/05  DAS  5.00h
     *      - This is 3/24/05 500h in jordanos 5.10 version.
     *      - Revised addccqty routine to send warehouse as a packed field.
     *
510 A*    07/03/06  MLB  5.10
     *      - Fix: Revised program to add DRI sub-cmd *ORDQTY to test
     *        if replenishments up-to order qty should be created.
     *
510aA*    02/19/07  JCJ  5.10a
     *      - Enh: Added repack item processing.
     *      - Enh: Added *CRTRPLPH2. See notes.
     *
510bA*    07/20/07  JCJ  5.10b
     *      - Fix: For repack replenishments set savqtyneeded to
     *             original order quantity.
     *
520 A*    01/09/09  MLB  5.20
     *      - Fix: Revised routine UPDPRTYRPL to add SAVQTYNEEDED
     *             to PRAQS instead of replacing the existing value.
520aA*    04/07/09  MLB  5.20a
     *      - Fix: Change to 5.20 mod. Only add when $PSUBCMD not
     *        equal to *AVGQTY and *ORDQTY.
520bA*    04/28/09  MLB  5.20b
     *      - Fix: Two problems were fixed with this patch. One,
     *        JIT replenishments were being created when there was
     *        sufficient quantity in the pick slot. Two, when JIT
     *        replenishments were called for, the wrong quantity
     *        was used as the basis for the JIT replenishments.
     *        Routines affected: CREATERPL, RPLCRITERIA and GETQTYAVL.
     *
520cA*    06/18/09  MLB  5.20c
     *      - Fix: Added *ORDQTY, *AVGQTY to 5.20b mod. Determined
     *        that *AVGQTY, *ORDQTY replenishments are affected in the
     *        same way as JIT replenishments when routes are processed
     *        thru TruckBuilder before *AVGQTY, *ORDQTY replenishments
     *        are created. Having quantity in Allocated/Picked buckets
     *        causes Priority Replenishments to be created for items
     *        that do not need to be replenished.
530 A*    10/29/09  MLB  5.30
     *      - Fix: Revised routines ADDPRTYRPL, UPDPRTYRPL to check
     *        if topick > 999 then set PRQTY = 999 else use topick.
     *
530aA*    05/26/09  MLB  5.30a (was 5.20c at Springfield-GJA)
     *      - Enh: Revised program when processing *AVGQTY or *ORDQTY
     *        replenishments, that pick slots with zero stock qty1,
     *        stock qty2 and stock qty3 will be sequenced for replenish-
     *        ment before all other Priority Replenishments except
     *        JIT replenishments.
     *
600 A*    04/26/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - 500g/h/i/k added from Jordano's code.
     *
600aA*    04/26/08  DAS  6.00a
     *      - Revised getslotpos to use DRILICHIST in addprtyrplr.
     *
600bA*    03/07/09  DAS  6.00b
     *      - Removed DRILICHIST logic.
     *      - Hard code slot position to 1 until new license tracking
     *        starts tracking it.
     *
600cA*    03/07/09  DAS  6.00c
     *      - Revised to not look at RCV, STG, OSS and USR slots.
     *
600dA*    05/08/09  DAS  6.00d
     *      - Revised to used desig code BFC for specialty slots.
     *
610aA*    05/10/10  JCJ  6.10a
     *      - Fixed Repack replenishments when pick slot is short.
     *
610bA*    08/27/10  JCJ  6.10b
     *      - Enh: Added new subcommand *CRTRPLODR. Added new
     *        subroutines, addprtyrpld, crtodrfix.
     *
610cA*    09/21/10  JCJ  6.10c
     *      - Fix: Add code to populate the sequence number for on
     *        demand repack replenishments.
     *
640aA*    04/21/11  JCJ  6.40a
     *      - Fix: Add *CRTRPLODR to SR GETNXTSEQ.
640bA*    12/16/11  RH   6.40b
     *      - Renamed CVTNUM to CVTNUMB
640cA*    01/03/12  RH   6.40c
     *      - Enh: For JIT replenishment, delete 1st priority replen
     *        found for item, then create new JIT replenishment.
     *        Was updating existing priority replen and not creating
     *        new JIT replenishment.
     *
640dA*    01/11/12  DAS  6.40d
     *      - Fix: Revised CRTBRKFIX, CRTRPLFIX and CRTODRFIX to
     *        leave read loop on eof.
     *
640e *    02/28/12  GJA  6.40e
     *      - Fix: Not creating JIT replenishments for breakdown qty
     *
640f *    03/01/12  LMC  6.40f
     *      - Enh: Sort feature to use options field OPRSRT to process
     *        by PRPLFIL3 if OPRSRT is *TOSLOT, basically ignoring the
     *        value of the locator field
640gA*    10/19/12  RH/MLB  6.40g  Was 6.10b at Andrews.
     *      - Enh: Revised program to pass back priority repl seq #
     *
650aA*    03/20/13  KDE 6.50a
     *      - Enh: Revised priority replenishment routine for
     *        on-demand items to look for passed slot for the "to"
     *        slot when passed, otherwise it will continue old code
     *
650bA*    04/11/13  KDE 6.50b
     *      - Enh: Revised Work Order Repack routine to always use
     *        Pick slot if exist for replenishment of repack slot from
     *        parent pick slot.  If parent pick does not exist use the
     *        first available overflow.  ALWAYS create replenishment
     *        for the FULL quantity needed whether from slot has qty
     *        or not.  Client will be trained to do Specific Slot
     *        replenishment if pick slot is short of needed qty.
     *
650cA*    05/30/13  LMC 6.50C
     *      - Fix: GETNXTSEQ it a record exists in the PRPLFIL1 file
     *        with a seq# 99999, each replenshment created for that
     *        same whse/dept will be created with seq# = 1. Added an
     *        additional check to make sure the whse/dept/seq#
     *        combination does not already exist, when getting the
     *        next sequence number to assign to the replenishment.
     *
650dA*    06/04/13  MLB 6.50d
     *      - Fix: Correct looping condition in routine CRTRPKOVR
     *        from 6.50b mod.
     *
650eA*    04/24/13  KDE 6.50e
     *      - Enh: Revised Work Order Repack routine to allow parent
     *        item to be another repack item.
     *
650fA*    05/06/13  KDE 6.50f
     *      - Enh: Allow Ondemand items using Work Order Repack Screen
     *
650gA*    06/07/13  KDE 6.50g
     *      - Fix: Allow for different replenishments to PRPLFIL
     *        for On-Demand versus Work Order.
     *
650hA*    06/19/13  KDE 6.50h
     *      - Enh: Allow on-demand items to replenish like normal
     *             items if overflow slots exits
650iA*    06/10/14  KDE 6.50i
     *      - Enh: Added command CRTPRDRPL and supporting routines
     *             for Production replenishments
     *
650jA*    08/25/14  KDE 6.50j
     *      - Fix: Changed repack odr replenishment to be added with
     *             priority number to prevent rebuild from deleting
     *
650kA*    12/03/14  LMC 6.50k
     *      - Fix: GETNXTSEQ if a record exists in the PRPLFIL1 file
     *        with a neg seq# at the lowest number ex..7000-, 6000-
     *        we need to reset the nextseq# to minseq# ex...7999-,6999-
     *        Recheck to make sure the sequence we are going to use
     *        does not already exist in the file.
     *        This mod was put in to eliminate a problem with enormous
     *        amounts of BATCTL records being created by LT108 when
      *        multiple 7000- sequence numbers existed in PRPLFIL.
     *
650lA*    01/21/15  KDE 6.50l
    *      - Fix: Changed CRTRPKFIX condition to only be considered
    *             if on demand pick slot.  (rpkslot <> 'RPK')
    *             Also zero qtyneeded when less than zero before
    *             iter
    *
700 A*    04/20/15  KDE 7.00
    *      - Enh: Added replen option for Repacks.  If set to yes it
    *             will either create a Work Order or ODR replen based
    *             on type of repack item
    *
700aA*    01/09/16  KDE 7.00a
    *      - Enh: Added ability to replenishment stock from
    *             Production WIP location before going to the
    *             warehouse
    *
700bA*    03/28/16  DLS 7.00b
     *      - Fix: Mod 7.00a incomplete - commented out most of code.
     *      - Enh: Changed program to first check & generate replenishments
     *             from existing WIP inventory, then resume normal
     *             replenishments from warehouse as needed.
     *
700cA*    03/23/16  DLS 7.00c
     *      - Enh: Added Production replenishment from next available
     *             slot when item Pick slot is negative.
700dA*    05/31/16  DLS 7.00d
     *      - 700d mod marker held for *EACH slot enhancement
     *
700eA*    06/09/16  DLS 7.00e
     *      - Enh: Production replenishments for *EACH slot items.
     *      - Removed by DAS. Lines physically deleted for readability.
     *
700fA*    06/14/16  DAS  7.00f
     *      - Enh: Added *EACH logic (see notes below)
     *      - Removed 700d, 700e changes
700gA*    06/15/16  LMC  7.00g
     *      - Enh: Additions to 700f - these can be the same mod mark
     *        after testing is completed. Making this mod so I can
     *        identify the pieces I added/changed.
710 A*    02/09/17  KDE  7.10
     *      - Enh: Added new field to PLINED.  Recompiled only
710aA*    02/24/17  TAB  7.10a
     *      - Fix: Added file PIRRECID# to get next replinishment
     *             sequence number. When production module was added
     *             MRC fires jobs off rapidly when releasing work orders
     *             causing sequence number to be duplicated.
710bA*    02/28/17  MLB  7.10b
     *      - Enh: Added Production replenishment from next available
     *             slot when item Pick slot is negative.
710cA*    04/10/17  TAB  7.10c
     *      - Enh: Added check for sub command *CRTPRDRPL and *CRTPRDQTY
     *             to drop into logic that checks control record for next
     *             replenenishment sequence number
710dA*    08/28/17  KDE  7.10d
     *      - Enh: Default WO Repacks to NOT generate replenishment Orders
720 A*    02/26/18  KDE  7.20
     *      - Enh: Code changes for Marque's Priority Replenishment logic
     *        for company store
     *        - Call command STRZONE in DRIZONED to determin if in store zone.
     *          You pass store one in using $zdtstzone.  Can be portion or all
     *        - All $zd fields come from DRIZONED data structure.  These fields
     *          can be found under version 2 changes.
     *        - Field $zdStgFlg='Y' means found in Store Zone.  'N' means not in store
     *        - To fields in PRPLFIL are all written as blank except PRTAIL (Aisle)
     *          It is written as RPA and once replen is started LT108 will generate
     *          a RPADOCK-xx virtual that will be used in Specific Slot Replenishment
     *        - Calculated Replenishment quantity value is reduced by the quantity
     *          in the stores overflow slot(s)
     *        - Create Priority Replenishment for Store when pick slot for item
     *          exist in both Store and Warehouse.  In this case look to *REPLEN
     *          setting OPRZST which points to a Slot Def record defined for this
     *          scenario and will be associated with the item on tihi screen.  If
     *          found on item DRIPRTYRPL will use this TIHI instead of default for
     *          item when generating Replenishment for Store.  It will analyze when
     *          quantity is one or less
720aA*    05/14/18  KDE  7.20a
     *      - Fix: Force 'S' on PRFLAG when Store Replenishment (RPA to slot)
720bA*    08/15/18  KDE  7.20b
     *      - Enh: When Staging Replenishment slot, force Default Slot Defnition
     *          to TIHI array as 1 by 1 to always calc demand of 1 case if
     *          the slot definition does not exist in item def array.  Also
     *          accumulate total quantity needed for staging pick slots instead
     *          of always using last quantity calculated
     *      - Enh: Also change GETSTRZ to just check file SLOTSTR if $PRSLOT was
     *          sent in instead of calling DRIZONED to speed up Priorirty Replen
     *      - Enh: Add code to allow user to generate replenishment for
     *          item based on difference between replenishment level ($itrepl)
     *          and homeavlqty difference between homeavlqty and replenishment
     *          level ($itrepl).  This essentially gives the user the ability to trigger
     *          a case replen at level before half way point.  The example breakdown
     *          used had 12 breakdowns and the case at 2.  Marques wanted a replenishment
     *          generated when one case or two breakdowns are consumed.  This would
     *          mean Replenishment Level would have 10 put on it.  Once the available
     *          quantity falls below 10 a replenishment would be generated.
     *          This is only done for *RPLLVL replenishments
720cA*    09/19/18  KDE  7.20c
     *      - Fix: Change where normal Replenishments will not consider Aisle RPA
     *             which is Staging Replenishment Aisle, and change where Store
     *             replenishments consider any RPA aisles when calculating needed
     *             quantity
     *      - Fix: Look for Store Overflow quantities if DRIZONED not called.  This
     *             happens to speed up process when slot passed in.
720dA*    09/27/18  KDE  7.20d
     *      - Enh: Pass specific type to generate
720eA*    10/01/18  KDE  7.20e
     *      - Enh: Use Slot Type if passed for Store Replenishment.  This allows for
     *             different quantities for Display Slots
720fA*    10/03/18  KDE  7.20f
     *      - Fix: Repack replenishments handling negative availability incorrectly
     *
730 A*    03/06/19  RH/MLB  7.30
     *      - Enh: Revised routine RPLCRITERIA when processing JIT re-
     *        plenishments to compare qtyneeded <= homeavlqty, then get
     *        out, no replenishment needed.
730aA*    02/18/19  KDE  7.30a
     *      - Enh: Add ability where Production Module Components can request
     *        replenishments from PAR stock aisle
730bA*    08/26/19  KDE  7.30b
     *      - Enh: Change type for Production Replens to 'O'
     *      - Enh: Add command CRTDDRPL - Create Replen for DropPick items
     *        First intoduced at Chefs
740 A*    05/07/20  KDE  7.40
     *      - Enh: Change status to "DP" for Drop Pick slots
     *      - Enh: Change to use EXITEMORD to access/update ITEMORDEXA
     *      - Enh: Verify Overflow slot as configured for Drop Pick
740aA*    05/13/20  DAS  7.40a
     *      - Enh: Revised to ignore whse-to-whse transfer aisle/loc.
740bA*    06/22/20  DAS  7.40b
     *      - Enh: Added 740b change to some spots that were ignoring
     *        'BFC' slots.
740cA*    07/04/20  DAS  7.40c
     *      - Enh: Revised to reuse deleted JIT seq#'s. This allows
     *        an item's JIT to keep its place.
740dA*    08/10/20  KDE  7.40d
     *      - Enh: Revised CalcddReq which calculates replen
     *        requirements for Drop Picks from either Allocation
     *        Order Quantity Replenishment process
740eA*    08/20/20  KDE  7.40e
     *      - Enh: Revised to ensure proper quantities exist for
     *        Drop Pick replenishment when created
740fA*    09/08/20  KDE  7.40f
     *      - Fix: Fix divide by zero when repack has no breakdown
740gA*    09/10/20  RH/MLB   7.40g
     *      - Fix: Revised drislotsr to add alocated qty to $slavl1
     *        Was created JIT when not needed.
750 A*    02/02/21  KDE      7.50
     *      - Fix: where clause issue in sql statement
750aA*    02/25/21  KDE      7.50a
     *      - Fix: bad quantity being placed in Empty Quantity when
     *        *RPLLVL and Repack Work Order Creation flag set
     *      - Enh: Reduce Work Order Quantity by whats onhand
750bA*    04/08/21  KDE      7.50b
     *      - Fix: Ignore BF designated slots for Drop Pick Replen
750cA*    04/16/21  KDE      7.50c
     *      - Fix: Correct Drop Pick replenishment need in calcDDReq
750dA*    07/21/21  KDE      7.50d
     *      - Fix: Correct potential loop issue
750eA*    08/11/21  KDE      7.50e
     *      - Fix: Correction to mod 750c.  Should have been <>'A'
     *        instead of <>'S'
     *      - Enh: Also added parms to GETDDSLOT to make sure it
     *        directs to proper slot in correct order
     *      - Enh: Added code to only replenish Drop Pick slot to
     *        max cube as defined by slot type and item cube
     *      - Fix: Changes to calcuating need for Drop Pick replenishment
750fA*    09/22/21  KDE      7.50f
     *      - Fix: Few more changes how to handle status "A" in PRPLFIL
     *        with Drop Pick
750gA*    11/02/21  KDE      7.50g
     *      - Fix: Multiple Pick Slot replen process changes
     *        It was not working as intended
750hA*    11/29/21  KDE      7.50h
     *      - Fix: Change to prevent duplicate Drop Pick Replenishment
750iA*    02/11/22  KDE      7.50i
     *      - Fix: Correct issue with 750g to only do when multi pick slot
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Cheney Custom Mods
     *
     *   All Cheney custom mods should be conditioned with ...
     *      'if client = cheney'
     *   or 'client  cabne  cheney   skipcheney1'
     *   or 'select / when client = cheney / other / endsl'
     *
     *
CBIaA*    02/03/04  DAS  CBIa
     *      - Enh: Revised to added Container/Cruise pick/allocated qtys
     *        into the pick slot's available qty.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: BiRite
     *
BIRaA*    07/19/05  MLB  BIRa
     *      - Revised program to stop creating replenishments after
     *        available qty in pick slot + replenished qty exceeds
     *        quantity needed (IITQO).
BIRbA*    03/23/06  MLB  BIRb
     *      - Revised program to force program to use Sunday's
     *        averages when program is run on Fridays. No picking is
     *        done on Fridays, so no Priority Replen's get created.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Finkle Distributing
     *
FDI A*    06/25/08  MLB  FDI
     *      - Revised program to stop creating replenishments after
     *        available qty in pick slot + replenished qty exceeds
     *        quantity needed (IITQO).
     *      - Added Finkle to BIRa mod.
FDIaA*    06/25/08  MLB  FDIa
     *      - Revised program to use IITQO for qty pick slot will
     *        hold when item tie/high not on file.
     *      - Note: The FDIa change made in getqtyneeded was not
     *        needed because of the 500i change, which was missing
     *        from the PIRCUR/PIRENH520 copies.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: MJ Kellner
     *
MJK A*    09/02/08  MLB  MJK
     *      - Revised program to stop creating replenishments after
     *        available qty in pick slot + replenished qty exceeds
     *        quantity needed (IITQO).
     *      - Added MJK to BIRa mod.
MJKaA*    09/02/08  MLB  MJKa
     *      - Revised program to use IITQO for qty pick slot will
     *        hold when item tie/high not on file.
     *      - Added MJK to FDIa mod.
MJKbA*    12/06/17  MLB  MJKb
     *      - Revised program to force program to use Friday + Sunday
     *        averages when program is run on Fridays.
     *      - Added MJKb to ALN mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Jack Palmer
     *
JPF A*    09/25/17  KDE  JPF
     *      - Revised program to not round up case quantity for
     *        Breakdown Replenishments per customer request
JPFaA*    07/30/19  MLB  JPFa
     *      - Revised program to force program to use Friday + Sunday
     *        averages when program is run on Fridays.
     *      - Added JPFa to ALN mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: USF - Allen division
     *
ALN A*    10/06/06  MLB  ALN
     *      - Revised program to force program to use Friday + Sunday
     *        averages when program is run on Fridays.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Saval Foods
     *
SVL A*    09/11/09  MLB  SVL
     *      - Revised program to force program to use Sunday's
     *        averages when program is run on Fridays. No picking is
     *        done on Fridays, so no Priority Replen's get created.
SVLbA*    05/09/14  MLB/RH  SVLb
     *      - Add SVL mod to AVGnn command to use Sunday's
     *        averages when program is run on Fridays.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Capital City Produce
     *
CCP A*    05/12/10  JCJ  CCP
     *      - Changed program to not execute CRTWRKORD.
     * Client Custom Revisions: Capital City Produce
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Coastal Sunbelt Produce
     *
CSP A*    07/28/10  JCJ  CSP
     *      - Changed program to not execute CRTWRKORD.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Dairyland
     *
DRYaA*    02/15/11  RH   DRYa
     *      - Revised program to NOT select slots with aisle >'099'
     *        locations are off site at other location (240 whse)
DRYbA*    02/28/11  MLB  DRYb
     *      - Revised program to force program to use Sunday's
     *        averages when program is run on Saturdays.
DRYcA*    06/07/11  RH   DRYc
     *      - Reversed DRYa to process all slot locations and not
     *        exclude slots with aisle > '099' 240 whse locations
DRYdA*    06/15/11  RH   DRYd
     *      - Increase all AVGQTY replenishments by 20% to account
     *        for recent increased sales.
DRYfA*    06/16/14  MLB  DRYf
     *      - Changed program to set DSPQTY, DSTQTY to stock qty in
     *        overflow slot when no item tie/high is found. This is
     *        done to stop pgm from creating replenishment rcds for
     *        every overflow slot on file for item because tie/high
     *        gets set to 9999 when tie/high rcd is not found.
     *      - Added DRYe to KHL mod.
DRYgA*    07/16/15  MLB  DRYg
     *      - Change to DRYe mod. Revised pgm when processing *RPLLVL
     *        replenishments, to only create replen when slot qty < ITREPL
     *        instead of slot qty <= ITREPL.
     *      - Per Melissa email dated 07/16/2015.
DRYhA*    04/29/19  DAS  DRYh
     *      - Revised to exclude OSS aisles 030 - 050
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Inter County Bakers
ICBaA*    04/04/12  RH   ICBa
     *      - Revised to skip aisles in back OSS warehouse,
     *        exclude slots with aisle = G, H, I, N, P, R, T
     *
     *----------------------------------------------------------------
     * Client Custom Rivsions: TPC
     *
TPC A*    06/05/08  MLB  TPC
     *      - Revised program to skip replenishments that would use
     *        aisles 60-99 in dept DRY. These aisles are in the
     *        cone house.
TPCaA*    02/13/12  MLB  TPCa
     *      - Revised program to skip replenishments that would use
     *        aisles 60-69 or 77-99 in dept DRY. These aisles are in
     *        the cone house. Per Steve W. phone call.
     *      - Change to TPC mod.
TPCbA*    03/07/12  RBD  TPCb
     *      - Revised program to include replenishments in DRY
     *        aisles 95-96. Per Steve W. email.
TPCcA*    03/30/12  RBD  TPCc
     *      - Revised program to include replenishments in DRY
     *        aisles 77-80. Per Steve W. phone call.
TPCdA*    01/30/17  MLB  TPCd
     *      - Revised program to use slot stock quantity when processing
     *        *ORDQTY replenishments. Stanpack sends total on-order qty
     *        each time process is executed and not omitting routes that
     *        have been picked on Stanpack and sent to TruckBuilder(r).
TPCeA*    01/20/20  RH   TPCe
     *      - Revised program to include replenishments in DRY
     *        aisles 90. Per Steve W. phone call.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Get Fresh Produce
     *
GFS A*    03/06/13  RH   GFS
     *      - Changed program to not execute CRTWRKORD.
     *----------------------------------------------------------------
     * Client Custom Revisions: Greenleaf Produce
     *
GLP A*    08/25/13  RH   GLP
     *      - Changed program to not execute CRTWRKORD.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Kohl Wholesale
     *
KHL A*    08/14/14  MLB  KHL
     *      - Changed program to set DSPQTY, DSTQTY to stock qty in
     *        overflow slot when no item tie/high is found. This is
     *        done to stop pgm from creating replenishment rcds for
     *        every overflow slot on file for item because tie/high
     *        gets set to 9999 when tie/high rcd is not found.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Fischer Foods
     *
FFC A*    12/05/14  MLB  FFC
     *      - Revised program to force program to use Sunday's
     *        averages when program is run on Fridays. No picking is
     *        done on Fridays, so no Priority Replen's get created.
     *      - Added FFC to SVL mod.
FFCaA*    12/05/14  MLB  FFCa
     *      - Add FFC mod to AVGnn command to use Sunday's
     *        averages when program is run on Fridays.
     *      - Added FFCa to SVLb mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: FoodPro
     *
FPR A*    10/14/15  MLB  FPR
     *      - Revised program to force program to sort using *DEMAND
     *        even though Locator = Yes is true.
FPRaA*    01/20/20  MLB  FPRa
     *      - Revised program to force program to use Friday+Sunday
     *        averages when program is run on Friday.
     *      - Added FPRa to ALN mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Cash Wa Distributing
     *
CWD A*    07/26/18  MLB  CWD
     *      - Revised program to disable 7.10b mod in routine DRISLOTSR.
     *        Was causing JIT replenishments to not be created.
     *        *** Temporary Mod *** Only until solution for 7.10b chg is
     *        found.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Stern Produce
     *
     *----------------------------------------------------------------
MQS A* Client Custom Revisions: Marques
     *
MQS A*    06/29/18  RH   MQSa
     *      - Add to KHL mod to stop pgm from creating repl rcds for
     *        every overflow slot on file for item because tie/high
     *        gets set to 9999 when tie/high rcd is not found.
MQSbA*    08/17/18  KDE  MQSb
     *      - Perform new logic for Replenishment Level Replen
MQScA*    08/18/18  KDE  MQSc
     *      - Ignore aisle MTF
MQSdA*    09/21/18  KDE  MQSd
     *      - Revised to NOT round Breakdown Replenishments for
     *        Store
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: City Line Distributors
     *
CLD A*    10/15/19  MLB  CLD
     *      - Revised program to stop creating replenishments after
     *        available qty in pick slot + replenished qty exceeds
     *        quantity needed (IITQO).
     *      - Added CLD to BIR mod.
CLDaA*    10/15/19  MLB  CLDa
     *      - Revised program to use IITQO for qty pick slot will
     *        hold when item tie/high not on file.
     *      - Added CLDa to FDIa mod.
     *
     *----------------------------------------------------------------
     * Client Custom Revisions: Seashore Fruit & Produce
     *
SFP A*    02/27/23  MLB  SFP
     *      - Add to KHL mod to stop pgm from creating repl rcds for
     *        every overflow slot on file for item because tie/high
     *        gets set to 9999 when tie/high rcd is not found.
     *        Done for both *AVGQTY, *ORDQTY replenishments.
     *      - Added SFP to KHL mod.
     *
      *----------------------------------------------------------------
      *  Sub-Command Notes
      *
      *    Sub-Commands
      *
      *      *OPEN             Open program and return.
      *
      *      *CLOSE            Close program with *INLR = *ON
      *
500bA *      *AVGQTY           Create priority repl using Dakota avg sales.
500bA *                        Don't assign seq#. Assigned with *SEQPRTRPL.
500bA *                        Same as *CRTRPLDKA.
      *
650iA *      *AVGPRD           This ONLY calls GETQTYNEEDED to return  tion
650iA *                        the Average Sales Quantity to DRIPROD
650iA *                        routine CRTSUGG to generate a Production
650iA *                        suggestion if needed
      *
500bA *      *AVGnnn           Create priority repl using Dakota avg sales
500bA *                        plus nnn percent.
500bA *                        Don't assign seq#. Assigned with *SEQPRTRPL.
      *
730bA *      *CRTDDRPL         Create priority replenishment for Drop Picks
      *
      *      *CRTRPL           Create priority replenishment.
      *                        Don't assign seq#. Assigned with *SEQPRTRPL.
      *
650iA *      *CRTPRDRPL        Create priority replenishment for Production
650iA *                        requests. Determine qty based on current
650iA *                        available and item replen level
      *
650iA *      *CRTPRDQTY        Create priority replenishment for Production
650iA *                        requests. Assume quantity requested is needed
      *
      *      *CRTRPLDKA        Create priority repl using Dakota avg sales.
      *                        Don't assign seq#. Assigned with *SEQPRTRPL.
500bA *                        Same as *AVGQTY.
      *
500 A *      *CRTRPLDKO        Create priority repl using Dakota ordered qty
      *                        Don't assign seq#. Assigned with *SEQPRTRPL.
500bA *                        Same as *ORDQTY.
      *
510aA *      *CRTRPLPH2        Create priority replenishment Phase 2.
510aA *                        Replenish parent stock of repack items. RPL.
510aA *
      *
610bA *      *CRTRPLODR        Create priority replenishment for On
610bA *                        Demand Repack breaker slot.
610bA *
      *      *CRTRPLSEQ        Create priority replenishment.
      *                        Assign seq# immediately.
417bA *                        Set priority to 0.
      *
417bA *      *CRTRPLSQ1 - 9    Create priority replenishment.
417bA *                        Assign negative seq# immediately.
417bA *                        Set priority to last character (1-9).
      *
500hA *      *CRTRPFSQ1 - 9    Force create priority replenishment.
500hA *                        Create Priority Replenishment even if
500hA *                        avail. qty exceeds qty needed.
500hA *                        Set priority to last character (1-9).
      *
500bA *      *ORDQTY           Create priority repl using Dakota ordered qty
500bA *                        Don't assign seq#. Assigned with *SEQPRTRPL.
500bA *                        Same as *CRTRPLDKO.
      *
      *      *REMOVE           Remove open priority replenishements
      *
500bA *      *RPLLVL           Create priority repl using item repl. level.
500bA *                        Don't assign seq#. Assigned with *SEQPRTRPL.
      *
416aA *      *SEQPRTRPL        Sequence priority replenishements
      *
      *----------------------------------------------------------------
700fA*----------------------------------------------------------------
700fA* *EACH Notes
     *
     *     The *EACH method was created to allow tht selling of Eaches
     *     using the Case item number, but from a different slot. The
     *     Pick slot for selling the Eaches must have a slot definition
     *     code that has a pallet type of *EACH. The quantities in this
     *     slot will have the same breakdown as the main slot (Cases, Eaches).
     *
     *     Instead of changing files ITEMAVG, ITEMORD and ITEMSLS to
     *     include breakdown qtys, it was decided to create an extra
     *     record where '*EACH' was appended to the item number, like
     *     '123456*EACH'.
     *
     *     No change is necessary in programs that send the slot
     *     number to DRIPRTYRPL. However, programs that only send the
     *     item number will need to be revised to call DRIPRTYRPL
     *     twice, once with the main item number, 123456, and again
     *     with the *EACH item number, 123456*EACH.
     *
     *     A *EACH PRPLFIL record will be created as a Breakdown
     *     replenishment (PRRPLT = 'B') using the Case item number.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fprplfil   uf a e           k disk
     F                                     infds(file1ds)
416bDF**plfil4  if   e           k disk
416bMFprplfil4  uf   e           k disk
     F                                     infds(file2ds)
     F                                     rename(prrec:prrec4)
416aAFprplfil1  if   e           k disk
416aAF                                     rename(prrec:p1rec)
416aAFprplfil2  uf   e           k disk
416aAF                                     rename(prrec:p2rec)
416aAFprplfil3  uf   e           k disk
416aAF                                     rename(prrec:p3rec)
     Fitemavg   if   e           k disk
500 AFitemord   if   e           k disk
     Fslotdef   if   e           k disk
     Fslot3     if   e           k disk
     F                                     infds(file3ds)
     Fslot2     if   e           k disk
416aAF                                     rename(slrec:s2rec)
730bAFslot4     if   e           k disk
730bAF                                     rename(slrec:slrec4)
     Foptions   if   e           k disk
500gDF*lotpos   if   e           k disk
510aAFkitordh3  if   e           k disk
650hAFkitordd   if   e           k disk
510aAFkitcomp   if   e           k disk
700 AFkititem   if   e           k disk
710aAFpirrecid# uf a e           k disk
720aAfslotstr   if   e           k disk
     Flogprtyrplo    e           k disk

     *----------------------------------------------------------------
     *  Client id's for custom mods.
     *----------------------------------------------------------------

417nA /copy qcopysrc,id#cheney
BIR A /copy qcopysrc,id#birite
FDI A /copy qcopysrc,id#finkle
MJK A /copy qcopysrc,id#mjkelln
ALN A /copy qcopysrc,id#allen
JPF A /COPY QCOPYSRC,ID#PALMER
SVL A /copy qcopysrc,id#saval
CCP A /copy qcopysrc,id#capitol
CSP A /copy qcopysrc,id#coastal
DRYaA /copy qcopysrc,id#dairyla
TPC A /copy qcopysrc,id#tpc
ICBaA /copy qcopysrc,id#icb
GFSaA /copy qcopysrc,id#gfs
GLPaA /copy qcopysrc,id#glp
KHL A /copy qcopysrc,id#khl
FFC A /copy qcopysrc,id#fischer
FPR A /copy qcopysrc,id#fpr
SPI A /copy qcopysrc,id#spi
CWD A /copy qcopysrc,id#cashwa
MQS A /copy qcopysrc,id#mqs
CLD A /copy qcopysrc,id#citylin
SFP A /copy qcopysrc,id#sfp
417nAD client          s             10

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

740 A /COPY *libl/qcopysrc,p.exitemor
740 A /COPY *libl/qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#PRTYRPL
      /COPY *libl/qcopysrc,C#SLOT
      /COPY *libl/qcopysrc,C#ITEM
720 A /COPY *libl/qcopysrc,C#ZONED
     D saveVer#        s                   like($prver#)
600bMD slotpos         s                   like(prfpos)
     D driitem         s               n
720 AD drizoned        s               n
     D drislot         s               n

     *----------------------------------------------------------------
     *  Computed slot quantities.
     *----------------------------------------------------------------

     D slphy1          s                   like(slstk1)
     D slphy2          s                   like(slstk2)
     D slphy3          s                   like(slstk3)
     D slavl1          s                   like(slstk1)
     D slavl2          s                   like(slstk2)
     D slavl3          s                   like(slstk3)
     D sladj1          s                   like(slstk1)
     D sladj2          s                   like(slstk2)
     D sladj3          s                   like(slstk3)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

     D $vcount         s              3p 0
     D $vcommand       s              8
     D $vdesc          s             30
     D $vmessage       s             60
     D $vmsgk          s              4
     D $vprg           s             10
     D $vreturn        s             10

     D $vitem          s                   like($slitem)
     D $vwhdp          s                   like($slwhdp)
     D $vwhse          s              3p 0

     D vfywhdp         s               n
     D vfywhse         s               n

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D addrplflag      s               n
650iAd $brkqty         s              5  0
500bAD avgpct          s              5  2
730bAd calcQtyn        s              7  0
730bAd calcQty1        s              7  0
730bAd dmdQtyn         s              7  0
730bAd dmdQty1         s              7  0
730bAd avlQtyn         s              7  0
730bAd avlQty1         s              7  0
730bAd cmpItem         s             15
     D check4err       s               n
     D curdate         s              8  0
     D curdef          s              3  0
     D curtime         s              6  0
     D duration        s              7  2
     D d               s              1  0
740cAD deletedJITSeq#  s                   like(prseq#)
     D dshigh          s              2  0
     D dspqty          s              5  0
     D dstie           s              4  0
     D dstqty          s              7  0
     D dummy           s                   like(slloc)
700fAD eachItem        s                   like(slitem)
700fAD eachPos         s              3  0
700fAD eachRPL         s               n
     D emptylayer      s              7  0
     D emptyq          s              7  0
740 DD*error           s               n
740 DD*forever         s               n   inz(*on)
740 DD*found           s               n
     D foundpslot      s               n
     D foundtihi       s               n
     D fromdate        s              8  0
     D fromtime        s              6  0
     D homeavlqty      s              7  0
     D homeemplayer    s              7  0
     D homeempqty      s              7  0
     D homehigh        s              2  0
     D homelayer       s              7  0
     D homepltqty      s              7  0
     D hometie         s              4  0
     D homettlqty      s              7  0
750eAd holdsdcode      s              2
750gAd lastPickSlot    s                   like(sldisp)
     D item#           s                   like(slitem)
720 Ad itmcube         s             11  4
     D kyaisl          s                   like(slaisl)
     D kycode          s                   like(opcode)
     D kyentd          s                   like(slentd)
     D kyexpd          s                   like(slexpd)
     D kyhand          s                   like(slhand)
     D kyitem          s                   like(slitem)
     D kyitem2         s                   like(slitem)
500aAD kyloc           s                   like(slloc)
     D kypick          s                   like(slpick)
     D kyprty          s                   like(slprty)
     D kypseq          s                   like(slpseq)
     D kyrlvl          s                   like(slrlvl)
     D kysdef          s                   like(slsdef)
     D kystat          s                   like(slstat)
     D kystyp          s                   like(slstyp)
     D kywhdp          s                   like(slwhdp)
     D lasttime        s              6  0 inz(999999)
     D lastwhse        s                   like(prwhse)
     D                                     inz(-1)
     D layer           s              5  0
     D locator         s               n
720 Ad loccube         s             11  4
740 DD*lock            s               n
700 Ad lt110cl         s               n
     D lstseq          s                   like(prseq#)
417bAD maxseq#         s                   like(prseq#)
417bAD minseq#         s                   like(prseq#)
750gAd multPick        s               n
     D n               s                   like(prseq#)
730bAd newQtyn         s              7  0
730bAd newQty1         s              7  0
750eAd curRpln         s              7  0
750eAd curRpl1         s              7  0
     D nextseq#        s                   like(prseq#)
BIRa d nwhomeavlqty    s              7  0
730aAd opCmpRepln      s              1
     D ovravlqty       s              7  0
510aAD ovravlqtyr      s              7  0
720 Ad ovrCasesAvl     s              4  0
720cAd ovrCasesAvl1    s              4  0
720 AD ovrfCnt         s              2  0
510aAD parentqty1      s              7  0
510aAD parentqty2      s              7  0
     D pallet          s              7  0
417aAD picksdef        s                   like(slsdef)
720 Ad projQty         s              3  0
720dAd $prtype         s              1
     D pssrflag        s               n
     D qtyneeded       s              7  0
417dAD savqtyneeded    s              7  0
750gAd replencnt       s              3  0
417aAD rpltype         s              1
     D saveavail       s                   like($slavl1)
     D savepick        s                   like(sldisp)
     d first_overflow  s                   like(sldisp)
     d frst_ovrflow_f  s                   like(sldisp)
700bAD sav$prqtyn      s                   like($prqtyn)
700bAD sav$prqtyw      s                   like($prqtyw)
     D savewhdp        s                   like(slwhdp)
     D svavl1          s                   like($slavl1)
     D startover       s               n
417bAD temp1n          s              1s 0
     D todate          s              8  0
     D totime          s              6  0
     D today           s              8  0
     D topick          s              7  0
700bADttlQtyNeeded     s             10s 0 inz(0)
700bADttlWipStock      s             10s 0 inz(0)
     D updflag         s               n
720 Ad useOvrf         s             12
     D warningtype     s                   like($psubcmd)
700bAD wipsldisp       s                   like(sldisp)
700bDd* wipstk1         s                   like(slstk1)
700bDd* wipstk2         s                   like(slstk2)
700bDd* wipstk3         s                   like(slstk3)
700bDd* wipumq2         s              5  0
700bDd* wipumq3         s              5  0
710aAd pFileNm         s             10    inz('PRPLFIL')
710aAD pMaxSq          s                   like(prseq#)

     D $kaqs           s                   like(praqs)
     D $kfail          s                   like(prfail)
417bAD $kseq#          s                   like(prseq#)
     D $ktail          s                   like(prtail)
     D $ktdis          s                   like(prtdis)
     D $kwhdp          s                   like(prwhdp)
     D $kwhse          s                   like(prwhse)
     D $prplb          s              8

     D $pcmd           s             10
     D $pwhse          s              3  0
     D $pitem          s             15
     D $pqty           s              5  0
     D $pby            s              1
     D $pref           s             15
     D $prtn           s             10
     D $pmsg           s             60
510aAD wohqty          s              5  0
510aAD pqty            s              5  0
510aAD prem            s              3  0
510aAD hqty            s              5  0
510aAD sqty            s              5  0
510aAD $pord           s              7  0
510aAD $pndtc          s              8  0
510aAD rpkslot         s             12
510aAD rpkpslot        s             12
510aAD rpkwhdp         s              5
530aAD zeropickslot    s               n
610aAD rpkpail         s                   like(slaisl)
610aAD rpkploc         s                   like(slloc)
610aAD rpkplvl         s                   like(slrlvl)
610aAD rpkphnd         s                   like(slhand)
650iAD prdtslot        s             12
650iAD prdtail         s                   like(slaisl)
650iAD prdtloc         s                   like(slloc)
650iAD prdtlvl         s                   like(slrlvl)
650iAD prdthnd         s                   like(slhand)
650iAd wkButch         s            500    varying
650iAd wkpack          s            500    varying
650iAd wkship          s            500    varying
740aAD wwrtn           s             10
740aAD wwmsg           s             99    varying
     *----------------------------------------------------------------
     *  Field/array overlay
     *----------------------------------------------------------------

     D aqsds           ds
     D  igaqs1                 1      7  2
     D  igaqs2                 8     14  2
     D  igaqs3                15     21  2
     D  igaqs4                22     28  2
     D  igaqs5                29     35  2
     D  igaqs6                36     42  2
     D  igaqs7                43     49  2
     D  igaqsw                50     56  2
     D  aqs                    1     56  2
     D                                     DIM(8)

700bAD dsSlot        e ds                  extname('SLOT')

     *----------------------------------------------------------------
     *  *FEATURE  -  PIR Feature options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFEAT  -  PIR Installed feature.
     *
     * Data structure
     *
     D opdata          ds
     D  opfeat                 1      1
     D  optend               117    117
500 A
500 A*----------------------------------------------------------------
500 A*  *REPLEN  -  Replenishment options.
500 A*----------------------------------------------------------------
500 A*
500 A* Fields
500 A*
500 A*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
500 A*    OPOQRP  -  Order qty replenishment (Y/N).
500 A*
500 A* Data structure
500 A*
500 AD opdat2          ds
500 AD  oprplb                 1      8
500 AD  opoqrp                 9      9
640fAD  oprsrt                15     24
720 AD  opsslcn               29     29
720 AD  oprzst                30     31
500 AD  opten2               117    117
700 A
700 A*----------------------------------------------------------------
700 A*  *REPACK  -  Repack Options
700 A*----------------------------------------------------------------
700 A*
700 A* Fields
700 A*
700 A*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
700 A*    OPOQRP  -  Order qty replenishment (Y/N).
700 A*
700 A* Data structure
700 A*
700 AD opdat3          ds
700 AD  oppadj                 1      2
700 AD  opwadj                 3      4
700 AD  opradj                 5      6
700 AD  oprasl                 7      9
700 AD  oparpl                10     10
700 AD  opten3               117    117

     *----------------------------------------------------------------
     *  Called programs
     *----------------------------------------------------------------

     D @cvtdt          c                   const('CVTDTE')

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
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
500gAD  #pgm             *proc
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
500gAD  #jobnbr              264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql

730bA*----------------------------------------------------------
730bA*  SQL record layouts referenced
730bA*----------------------------------------------------------

730bAD slrec2        E Ds                  Extname(Slot) prefix(s_)

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

     D File2DS         ds
     D  f2filename             1      8
     D  f2openind              9      9
     D  f2endoffile           10     10
     D  f2status              11     15  0
     D  f2opercode            16     21
     D  f2routine             22     29
     D  f2stmtnbr             30     37
     D  f2recordcd            38     45
     D  f2messageid           46     52
     D  f2sourceid            53     54

     D File3DS         ds
     D  f3filename             1      8
     D  f3openind              9      9
     D  f3endoffile           10     10
     D  f3status              11     15  0
     D  f3opercode            16     21
     D  f3routine             22     29
     D  f3stmtnbr             30     37
     D  f3recordcd            38     45
     D  f3messageid           46     52
     D  f3sourceid            53     54

740aA*----------------------------------------------------------------
740aA* Called program prototypes
740aA*----------------------------------------------------------------
740aA
740aA /copy qcopysrc,p.wwtfr

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $psubcmd   Sub-command
      *      $pprogram  Calling program (the one that called interface)
      *      $pdata     Data needed by command
      *
      *    Returned Parameters
      *      $preturn   Return code
      *      $pmessage  Return code
      *      $pdata     Data returned by command
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

     C                   eval      $prtyrpl = $pdata
     C                   eval      $preturn = '*OK'
     C                   eval      $pmessage = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $psubcmd = '*OPEN'
     C                   goto      bottom

     C                   when      $psubcmd = '*CLOSE'
     C                   exsr      zzzclose
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Otherwise, do some initialization and move on.

     C                   exsr      aaainit
     C                   eval      error = *off

     *  Do what user has requested.

     C                   select

650iAc                   when      $psubcmd = '*AVGPRD'
650iAc                   exsr      getqtyneeded
650iAc                   eval      $prqtyn = qtyneeded
650iA
     C                   when      $psubcmd = '*CRTRPL'    or
     C                             $psubcmd = '*CRTRPLDKA' or
500 AC                             $psubcmd = '*CRTRPLDKO' or
417bMC                             $psubcmd = '*CRTRPLSEQ' or
417bAC                             $psubcmd = '*CRTRPLSQ1' or
417bAC                             $psubcmd = '*CRTRPLSQ2' or
417bAC                             $psubcmd = '*CRTRPLSQ3' or
417bAC                             $psubcmd = '*CRTRPLSQ4' or
417bAC                             $psubcmd = '*CRTRPLSQ5' or
417bAC                             $psubcmd = '*CRTRPLSQ6' or
417bAC                             $psubcmd = '*CRTRPLSQ7' or
417bAC                             $psubcmd = '*CRTRPLSQ8' or
500bMC                             $psubcmd = '*CRTRPLSQ9' or
500hAC                             $psubcmd = '*CRTRPFSQ1' or
500hAC                             $psubcmd = '*CRTRPFSQ2' or
500hAC                             $psubcmd = '*CRTRPFSQ3' or
500hAC                             $psubcmd = '*CRTRPFSQ4' or
500hAC                             $psubcmd = '*CRTRPFSQ5' or
500hAC                             $psubcmd = '*CRTRPFSQ6' or
500hAC                             $psubcmd = '*CRTRPFSQ7' or
500hAC                             $psubcmd = '*CRTRPFSQ8' or
500hAC                             $psubcmd = '*CRTRPFSQ9' or
500bAC                             %subst($psubcmd:1:4) = '*AVG' or
500bAC                             $psubcmd = '*ORDQTY'    or
500bAC                             $psubcmd = '*RPLLVL'
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifycrt
     C                   endif
720 Ac                   if        not error
720 Ac                   exsr      getStrZ
720 AC                   endif
     C                   if        not error
     C                   exsr      createrpl
720 aC                   endif
750gA
750gAC                   when      %subst($psubcmd:1:4) = 'M*AVG' or
750gAC                             $psubcmd = 'M*ORDQTY' or
750gAC                             $psubcmd = 'M*RPLLVL'
750gAc                   eval      multPick = *on
750gAc                   eval      $psubcmd = %subst($psubcmd:2:7)
750gAC                   exsr      verifygen
750gA
750gAC                   if        not error
750gAC                   exsr      multPSlt
750gAC                   endif

     C                   when      $psubcmd = '*REMOVE'
     C                   exsr      verifygen
     C                   if        not error
     C                   exsr      verifyrmv
     C                   endif
     C                   if        not error
     C                   exsr      remove
     C                   endif

416aAC                   when      $psubcmd = '*SEQPRTRPL'
416aAC                   exsr      verifygen
416aAC                   if        not error
416aAC                   exsr      seqprtyrpl
416aAC                   endif
650iA * Production
650iAC                   When      $psubcmd = '*CRTPRDRPL'
650iAC                              or $psubcmd = '*CRTPRDQTY'

700bA * Saving original normal & breakdown quantities for WIP consideration
700bAC                   eval      sav$prqtyn = $prqtyn
700bAC                   eval      sav$prqtyw = $prqtyw

650iAc                   if        $prqtyw <> 0
650iAc                   eval      $brkQty = $prqtyw
650iAc                   eval      $prqtyw = 0
650iAc                   eval      $prqtywu = *off
650iAc                   else
650iAc                   eval      $brkQty = 0
650iAc                   endif
650iAC                   exsr      verifygen
650iAC                   if        not error
650iAC                   exsr      verifyprd
650iAC                   endif
650iAC                   if        not error
650iAC                   exsr      crtprdfix
650iAC                   endif
730bA * Drop Pick
730bAC                   When      $psubcmd = '*CRTDDRPL'

730bAC                   exsr      verifygen
730bAC                   if        not error
730bAC                   exsr      verifydd
730bAC                   endif
730bAC                   if        not error
730bAc                   exsr      calcDDReq
730bAC                   endif
      * phase 2
510aAC                   When      $psubcmd = '*CRTRPLPH2'
700 AC                             or $psubcmd = '*CRTRPLPH3'
700 Ac                   eval      LT110CL = *off
700 Ac                   if        $psubcmd = '*CRTRPLPH3'
700 Ac                   eval      $psubcmd = '*CRTRPLPH2'
700 Ac                   eval      LT110CL = *on
700 Ac                   endif
510aAC                   exsr      verifygen
510aAC                   if        not error
510aAC                   exsr      verifyph2
510aAC                   endif
510aAC                   if        not error
510aAC                   exsr      crtrpkfix
510aAC                   endif
      * on demand repack
650hdC*                  When      $psubcmd = '*CRTRPLODR' or
650hAC                   When      $psubcmd = '*CRTRPLODR' or
650hAC                             $psubcmd = '*CRTRPLODN'
610bAC                   exsr      verifygen
610bAC                   if        not error
610bAC                   exsr      verifyph2
610bAC                   endif
610bAC                   if        not error
650hAc                   if        $psubcmd = '*CRTRPLODR'
610bAC                   exsr      crtodrfix
650hAc                   else
650hAC                   exsr      verifycrt
650hAC                   exsr      createrpl
650hAc                   endif
610bAC                   endif

     C                   other
     C                   eval      error = *on
     C                   eval      $preturn = 'INVLDSBCMD'
     C                   exsr      getmsg

     C                   endsl

     C     bottom        tag

     *  We are finished so get out

     C                   eval      $pdata = $prtyrpl
     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

500 A* Get client id

500 AC                   call      'GETCLIENT'
500 AC                   parm                    client

     * Key definitions

     *  Define partial keys for PRPLFIL.

     C     keyprw        klist
     C                   kfld                    $prwhse

     C     keyprd        klist
     C                   kfld                    $prwhse
     C                   kfld                    $prwhdp
417bA
417bA*  Define key for PRPLFIL1
417bA
417bAC     keypr1        klist
417bAC                   kfld                    $prwhse
417bAC                   kfld                    $prwhdp
417bAC                   kfld                    $kseq#

     *  Define key for PRPLFIL4

     C     keypr4        klist
     C                   kfld                    $prwhse
     C                   kfld                    $pritem

     *  Define key for PRPLFIL4 - Parent

     C     keypr4p       klist
     C                   kfld                    $prwhse
     C                   kfld                    #bitem

     *  Define key for ITEMAVG

     C     keyig         klist
     C                   kfld                    $prwhse
     C                   kfld                    $pritem

700fAC     keyigEA       klist
700fAC                   kfld                    $prwhse
700fAC                   kfld                    eachItem

     *  Define key for SLOT2 file.

     C     keysl2        klist
     C                   kfld                    $slwhse
     C                   kfld                    $slwhdp
     C                   kfld                    $sldisp

     *  Define key for SLOT2 during priority replenishment

     C     kysl2p        klist
650aAC                   kfld                    $prwhse
650aAC                   kfld                    $prwhdp
650aAC                   kfld                    $prslot

     *  Define partial key for SLOT3 file.

     C     keys3         klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     *
     *  Define partial key for SLOT3 file including dates.
     *
     C     keys3b        klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     *
     *  Define full key for SLOT3 file.
     *
     C     keys3c        klist
     C                   kfld                    $prwhse
     C                   kfld                    kyitem
     C                   kfld                    kystat
     C                   kfld                    kypick
     C                   kfld                    kyprty
     C                   kfld                    kyexpd
     C                   kfld                    kyentd
     C                   kfld                    kywhdp
     C                   kfld                    kystyp
     C                   kfld                    kyaisl
     C                   kfld                    kypseq
     C                   kfld                    kyrlvl
     C                   kfld                    kyhand

     *  Define key for SLOTDEF file.

     C     keysd         klist
     C                   kfld                    $prwhse
     C                   kfld                    kysdef

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $prwhse
     C                   kfld                    kycode

     *  Define key for PRPLFIL2 file.

     C     keypr2        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    $kaqs
     C                   kfld                    $kfail
     C                   kfld                    $ktail

     *    Define key for PRPLFIL3 file.

     C     keypr3        klist
     C                   kfld                    $kwhse
     C                   kfld                    $kwhdp
     C                   kfld                    $ktail
     C                   kfld                    $ktdis
500aA*
500aA*  Define full key for SLOTPOS file.
500aA*
500gDC**   keysp         klist
500gDC**                 kfld                    prwhse
500gDC**                 kfld                    prwhdp
500gDC**                 kfld                    kyaisl
500gDC**                 kfld                    kyloc
500gDC**                 kfld                    kyrlvl
500gDC**                 kfld                    kyhand

     C                   endsr

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

     *  Send message back to calling program.

     C                   eval      $preturn = 'U:' + #status
     C                   eval      $pmessage = 'U:'
     C                                       + %trim(#prog)
     C                                       + '('
     C                                       + %trim(%editc(#stmt:'Z'))
     C                                       + ')-'
     C                                       + #pgmmsg
     C                   eval      *inlr = *on
 1E  C                   return

     C                   endsr

     *----------------------------------------------------------------
     *  aaainit   Pre-subcommand initialization.
     *----------------------------------------------------------------

     C     aaainit       begsr
700fA
700fA*  Clear Each replenishment fields
700fA
700fAC                   eval      eachRPL = *off
700fAC                   eval      eachItem = ''
750gAc                   eval      multPick = *off

     *  Initialize log fields

     C                   clear                   lgprrec

     *  Convert today's date into century format.

     C                   exsr      getdatetime
     C                   eval      today = curdate

     *  Convert today's date into day number.

     C                   eval      $cvcmd = '*CMDNBR '
     C                   move      today         $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      d = $cvd6o

     C                   if        $prwhse <> lastwhse
     C                   eval      lastwhse = $prwhse
730aA
730aA*    Retrieve Production Module settings as needed
730aA
730aA /free
730aA          chain ($prwhse:'*PROD') options;
730aA          if not %found;
730aA             opCmpRepln = 'N';
730aA          endif;
730aA /end-free

     *    Retrieve FS-WMS installed feature code.

     C                   eval      kycode = '*FEATURE'
     C     keyop         chain     options
 1B  C                   if        not %found or opfeat = '2'
     C                   eval      locator = *off
 1E  C                   else
     C                   eval      locator = *on
 1E  C                   endif
500 A*
500 A*    Retrieve FS-WMS replenishment options.
500 A*
500 AC                   eval      kycode = '*REPLEN '
500 AC     keyop         chain     options                            79
500 AC                   select
500 AC                   when      *in79
500 AC                   eval      opoqrp = 'N'
500 AC                   when      not *in79
500 AC                   eval      opdat2 = opdata
500 AC                   endsl
500 A*
700 A*
700 A*    Retrieve FS-WMS replenishment Repack options
700 A*
700 AC                   eval      kycode = '*REPACK '
700 AC     keyop         chain     options                            79
700 AC                   select
700 AC                   when      *in79
700 AC                   eval      oparpl = 'N'
700 AC                   when      not *in79
700 AC                   eval      opdat3 = opdata
710dAc                   if        oparpl = *blanks
710dAC                   eval      oparpl = 'N'
710dAc                   endif
700 AC                   endsl
700 A*
 1E  C                   endif
720 Ac*  Set Staging indicator to No for any call in case it does
720 Ac*  not pass through routine GetStrZ.
720 Ac                   eval      $zdstgflg='N'

     C                   endsr

CBIaA*----------------------------------------------------------------
CBIaA*  addccqty    Add container/cruise qtys to avail qtys.
CBIaA*----------------------------------------------------------------
CBIaA
CBIaAC     addccqty      begsr

     *  Get picked/allocated qtys associated with container/cruise ord

     C                   call      'CCQTY'
500kDC**                 parm                    $slwhse
500kMC                   parm      $slwhse       $ccwhse           3 0
     C                   parm                    $slitem
     C                   parm                    $slstyp
     C                   parm                    $slwhdp
     C                   parm                    $slaisl
500kDC**                 parm                    $slpseq
500kMC                   parm      $slpseq       $ccpseq           5 0
500kDC**                 parm                    $slrlvl
500kMC                   parm      $slrlvl       $ccrlvl           2 0
     C                   parm                    $slhand
     C                   parm                    $ccpck1           5 0
     C                   parm                    $ccpck2           3 0
     C                   parm                    $ccpck3           3 0
     C                   parm                    $ccalc1           5 0
     C                   parm                    $ccalc2           3 0
     C                   parm                    $ccalc3           3 0

     *  Add CC qtys to slot available qtys.

     C                   eval      $slavl1 = $slavl1+$ccpck1+$ccalc1
     C                   eval      $slavl2 = $slavl2+$ccpck2+$ccalc2
     C                   eval      $slavl3 = $slavl3+$ccpck3+$ccalc3

     C                   endsr

     *----------------------------------------------------------------
     *  addprtyrpl  Add priority replenishment record
     *----------------------------------------------------------------

     C     addprtyrpl    begsr

     *  Initialize flag and sequence number.

     C                   if        $psubcmd = '*CRTRPLSEQ'
417bAC                             or $psubcmd = '*CRTRPLSQ1'
417bAC                             or $psubcmd = '*CRTRPLSQ2'
417bAC                             or $psubcmd = '*CRTRPLSQ3'
417bAC                             or $psubcmd = '*CRTRPLSQ4'
417bAC                             or $psubcmd = '*CRTRPLSQ5'
417bAC                             or $psubcmd = '*CRTRPLSQ6'
417bAC                             or $psubcmd = '*CRTRPLSQ7'
417bAC                             or $psubcmd = '*CRTRPLSQ8'
417bAC                             or $psubcmd = '*CRTRPLSQ9'
500hAC                             or $psubcmd = '*CRTRPFSQ1'
500hAC                             or $psubcmd = '*CRTRPFSQ2'
500hAC                             or $psubcmd = '*CRTRPFSQ3'
500hAC                             or $psubcmd = '*CRTRPFSQ4'
500hAC                             or $psubcmd = '*CRTRPFSQ5'
500hAC                             or $psubcmd = '*CRTRPFSQ6'
500hAC                             or $psubcmd = '*CRTRPFSQ7'
500hAC                             or $psubcmd = '*CRTRPFSQ8'
500hAC                             or $psubcmd = '*CRTRPFSQ9'
650hAC                             or $psubcmd = '*CRTRPLODN'
720aAc                             or $zdstgFlg = 'Y'
416dDC**                 eval      prflag = 'S'
740cA
740cA*     See if we can reuse a deleted JIT seq#
740cA
740cAC                   if        $psubcmd = '*CRTRPLSQ7'
740cAC                             and deletedJITSeq# < 0
740cAC                   eval      prseq# = deletedJITSeq#
740cAC                   else
     C                   exsr      getnxtseq
     C                   eval      prseq# = nextseq#
740cAC                   endif
416dAC                   eval      prflag = 'S'
     C                   else
     C                   eval      prflag = ' '
     C                   eval      prseq# = 0
     C                   endif

     *  Check to see if replenishment will free up a slot?

 1B  C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
 1X  C                   else
     C                   eval      prfree = 'Y'
 1E  C                   endif

     *  Add records to work file.

     C                   eval      prwhse = $slwhse
     C                   eval      prwhdp = $slwhdp
     C                   eval      prfail = slaisl
417 AC                   eval      prfloc = slloc
417 AC                   eval      prflvl = slrlvl
417 AC                   eval      prfhnd = slhand
     C                   eval      prfdis = sldisp
     C                   eval      pritem = $slitem
720 Ac                   if        $zdStgFlg = 'Y'
720 Ac                   eval      prtail = 'RPA'
720 AC                   eval      prtloc = *zeros
720 AC                   eval      prtlvl = *zeros
720 AC                   eval      prthnd = *blanks
720 AC                   eval      prtdis = *blanks
720 Ac                   else
     C                   eval      prtail = $slaisl
417 AC                   eval      prtloc = $slloc
417 AC                   eval      prtlvl = $slrlvl
417 AC                   eval      prthnd = $slhand
     C                   eval      prtdis = $sldisp
720 Ac                   endif
530 AC                   if        topick > 999
530 AC                   eval      prqty = 999
530 AC                   else
     C                   eval      prqty  = topick
530 AC                   endif
     C                   eval      prsdef = slsdef
     C                   eval      prstat = $slstat
417bAC                   if         $psubcmd = '*CRTRPLSQ1'
417bAC                             or $psubcmd = '*CRTRPLSQ2'
417bAC                             or $psubcmd = '*CRTRPLSQ3'
417bAC                             or $psubcmd = '*CRTRPLSQ4'
417bAC                             or $psubcmd = '*CRTRPLSQ5'
417bAC                             or $psubcmd = '*CRTRPLSQ6'
417bAC                             or $psubcmd = '*CRTRPLSQ7'
417bAC                             or $psubcmd = '*CRTRPLSQ8'
417bAC                             or $psubcmd = '*CRTRPLSQ9'
500hAC                             or $psubcmd = '*CRTRPFSQ1'
500hAC                             or $psubcmd = '*CRTRPFSQ2'
500hAC                             or $psubcmd = '*CRTRPFSQ3'
500hAC                             or $psubcmd = '*CRTRPFSQ4'
500hAC                             or $psubcmd = '*CRTRPFSQ5'
500hAC                             or $psubcmd = '*CRTRPFSQ6'
500hAC                             or $psubcmd = '*CRTRPFSQ7'
500hAC                             or $psubcmd = '*CRTRPFSQ8'
500hAC                             or $psubcmd = '*CRTRPFSQ9'
417bAC                   move      $psubcmd      prprty
417bAC                   else
     C                   eval      prprty = 0
417bAC                   endif
     C                   eval      prtype = $ittype
720 Ac                   if        $zdstgflg = 'Y'
720 Ac                   eval      prrplt = 'S'
720 Ac                   if        prtype='B'
720 Ac*  for staging type replenishments we move by case quantity and the
720 Ac*  Breakdown Replen already has case quantity so need to just blank
720 Ac*  type and force case item on replen
720 AC                   eval      prtype = ' '
720 Ac                   eval      pritem = $itmitem
720 Ac                   endif
720 Ac                   else
417aAC                   eval      prrplt = rpltype
720 Ac                   endif
     C                   exsr      getdatetime
     C                   eval      pradte = curdate
     C                   eval      pratim = curtime
417dDC**                 eval      praqs  = qtyneeded
417dMC                   eval      praqs  = savqtyneeded
500aA*
500aA*  Get From/To slot positions
500aA*
500gDC**                 eval      kyaisl = prfail
500gDC**                 eval      kyloc  = prfloc
500gDC**                 eval      kyrlvl = prflvl
500gDC**                 eval      kyhand = prfhnd
500aAC                   exsr      getslotpos
500gDC**                 eval      prfpos = sppos
500aA*
500gDC**                 eval      kyaisl = prtail
500gDC**                 eval      kyloc  = prtloc
500gDC**                 eval      kyrlvl = prtlvl
500gDC**                 eval      kyhand = prthnd
500gDC**                 exsr      getslotpos
500gDC**                 eval      prtpos = sppos

     C                   write(e)  prrec
     C                   if        %error
     C                   endif

     *  write record to log file.

     C                   eval      lgprcrt  = 'Y'
     C                   eval      lgprowhd = slwhdp
     C                   eval      lgproslt = sldisp
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

     C     endadd        endsr

610aA*----------------------------------------------------------------
610aA*  addprtyrpl2 Add priority replenishment record
610aA*----------------------------------------------------------------

610aAC     addprtyrpl2   begsr

     *  Initialize flag and sequence number.

     C                   eval      prflag = ' '
     C                   eval      prseq# = 0
     C                   exsr      getnxtseq
     C                   eval      prseq# = nextseq#
     C                   eval      prflag = 'S'

     *  Check to see if replenishment will free up a slot?

 1B  C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
 1X  C                   else
     C                   eval      prfree = 'Y'
 1E  C                   endif

     *  Add records to work file.

     C                   eval      prwhse = $slwhse
     C                   eval      prwhdp = $slwhdp
     C                   eval      prfail = slaisl
     C                   eval      prfloc = slloc
     C                   eval      prflvl = slrlvl
     C                   eval      prfhnd = slhand
     C                   eval      prtail = rpkpail
     C                   eval      prtloc = rpkploc
     C                   eval      prtlvl = rpkplvl
     C                   eval      prthnd = rpkphnd
     C                   eval      prfdis = sldisp
     C                   eval      prtdis = rpkpslot
     C                   eval      pritem = $slitem
     C                   if        topick > 999
     C                   eval      prqty = 999
     C                   else
     C                   eval      prqty  = topick
     C                   endif
     C                   eval      prsdef = slsdef
     C                   eval      prstat = $slstat
     C                   eval      prprty = 7
     C                   eval      prtype = $ittype
650iAC                   if        $psubcmd = '*CRTPRDRPL'
650iAC                              or $psubcmd = '*CRTPRDQTY'
730bDc*                  eval      prrplt = 'D'
730bMc                   eval      prrplt = 'O'
650iAC                   eval      prwhse = slwhse
650iAC                   eval      prwhdp = slwhdp
650iAC                   eval      pritem = slitem
650iAC                   eval      prstat = slstat
650iAc                   else
     C                   eval      prrplt = rpltype
650iAc                   endif
     C                   exsr      getdatetime
     C                   eval      pradte = curdate
     C                   eval      pratim = curtime
     C                   eval      praqs  = savqtyneeded
     *
     *  Get From/To slot positions
     *
     C                   exsr      getslotpos
     C                   write(e)  prrec
     C                   if        %error
     C                   endif

     *  write record to log file.

     C                   eval      lgprcrt  = 'Y'
     C                   eval      lgprowhd = slwhdp
     C                   eval      lgproslt = sldisp
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

610aAC     endadd2       endsr

650iA*----------------------------------------------------------------
650iA*  addprtyrplp Add priority replenishment record for Production
650iA*----------------------------------------------------------------
650iA
650iAC     addprtyrplp   begsr
650iA
650iA*  Initialize flag and sequence number.
650iA
650iAC                   eval      prflag = ' '
650iAC                   eval      prseq# = 0
650iAC                   exsr      getnxtseq
650iAC                   eval      prseq# = nextseq#
650iAC                   eval      prflag = 'S'
650iA
650iA*  Check to see if replenishment will free up a slot?
650iA
650iAC                   if        topick <> slavl1
650iAC                   eval      prfree = 'N'
650iAC                   else
650iAC                   eval      prfree = 'Y'
650iAC                   endif
650iA
650iA*  Add records to work file.
650iA
650iAC                   eval      prwhse = $slwhse
650iAC                   eval      prwhdp = $slwhdp
650iAC                   eval      prfail = slaisl
650iAC                   eval      prfloc = slloc
650iAC                   eval      prflvl = slrlvl
650iAC                   eval      prfhnd = slhand
650iAC                   eval      prtail = prdTail
650iAC                   eval      prtloc = prdTloc
650iAC                   eval      prtlvl = prdTlvl
650iAC                   eval      prthnd = prdThnd
650iAC                   eval      prfdis = sldisp
650iAC                   eval      prtdis = prdTslot
650iAC                   eval      pritem = $slitem
650iAC                   if        topick > 999
650iAC                   eval      prqty = 999
650iAC                   else
650iAC                   eval      prqty  = topick
650iAC                   endif
650iAC                   eval      prsdef = slsdef
650iAC                   eval      prstat = $slstat
650iAC                   eval      prprty = 0
650iAc                   if        $brkqty <> 0
650iAc                   eval      prtype = 'E'
650iAc                   else
650iAC                   eval      prtype = $ittype
650iAc                   endif
730bAc                   select
730bMC                   when      $psubcmd = '*CRTPRDRPL'
650iAC                              or $psubcmd = '*CRTPRDQTY'
730bAc                   eval      prrplt = 'O'
650iAC                   eval      prwhse = slwhse
650iAC                   eval      prwhdp = slwhdp
650iAC                   eval      pritem = slitem
650iAC                   eval      prstat = slstat
730bMC                   when      $psubcmd = '*CRTDDRPL'
730bAc                   eval      prrplt = 'D'
730bAC                   eval      prwhse = $prwhse
730bAC                   eval      prwhdp = $prwhdp
730bAC                   eval      pritem = $pritem
740 DC*                  eval      prstat = 'A '
740 MC                   eval      prstat = 'DP'
730bMc                   other
650iAC                   eval      prrplt = rpltype
730bMc                   endsl
650iAC                   exsr      getdatetime
650iAC                   eval      pradte = curdate
650iAC                   eval      pratim = curtime
650iA*
650iA*  Get From/To slot positions
650iA*
650iAC                   exsr      getslotpos
650iAC                   write(e)  prrec
650iAC                   if        %error
650iAC                   endif
650iA
650iA*  write record to log file.
650iA
650iAC                   eval      lgprcrt  = 'Y'
650iAC                   eval      lgprowhd = slwhdp
650iAC                   eval      lgproslt = sldisp
650iAC                   eval      lgproavl = slavl1
650iAC                   exsr      writelog
650iA
650iAC                   endsr
650iA

510aA*----------------------------------------------------------------
510aA*  addprtyrplr  Add priority replenishment record for repack item
510aA*----------------------------------------------------------------

510aAC     addprtyrplr   begsr

510aA*  Initialize flag and sequence number.

510aAC                   eval      prflag = ' '
510aAC                   eval      prseq# = 0

510aA*  Check to see if replenishment will free up a slot?

510aAC                   if        topick <> slavl1
510aAC                   eval      prfree = 'N'
510aAC                   else
510aAC                   eval      prfree = 'Y'
510aAC                   endif

510aA*  Add records to work file.

510aAC                   eval      prwhse = $slwhse
510aAC                   eval      prwhdp = $slwhdp
510aAC                   eval      pritem = #bitem
530 AC                   if        topick > 999
530 AC                   eval      prqty = 999
530 AC                   else
510aAC                   eval      prqty  = topick
530 AC                   endif
510aAC                   eval      prsdef = slsdef
510aAC                   eval      prstat = $slstat
510aA * From data
510aAC                   eval      prfail = slaisl
510aAC                   eval      prfloc = slloc
510aAC                   eval      prflvl = slrlvl
510aAC                   eval      prfhnd = slhand
510aAC                   eval      prfdis = sldisp
510aA * To data
650fAc                   if        $prslot <> ' '
650fAc                   eval      $sldisp = $prslot
650fAc                   exsr      drislotsr
650fAc                   else
510aAC                   exsr      getslot
650fAc                   endif
510aAC                   eval      prtail = $slaisl
510aAC                   eval      prtloc = $slloc
510aAC                   eval      prtlvl = $slrlvl
510aAC                   eval      prthnd = $slhand
510aAC                   eval      prtdis = $sldisp

610bMC*                  eval      prprty = 0
700 Ac                   if        not lt110cl
650jAC                   eval      prprty = 5
700 Ac                   else
700 AC                   eval      prprty = 0
700 Ac                   endif

510aAC                   eval      prtype = #bityp
510aAC                   eval      prrplt = 'R'
510aAC                   exsr      getdatetime
510aAC                   eval      pradte = curdate
510aAC                   eval      pratim = curtime
510aAC                   eval      praqs  = savqtyneeded
510aA*
510aA*  Get From/To slot positions
510aA*
600aDC**                 eval      kyaisl = prfail
600aDC**                 eval      kyloc  = prfloc
600aDC**                 eval      kyrlvl = prflvl
600aDC**                 eval      kyhand = prfhnd
510aAC                   exsr      getslotpos
600aDC**                 eval      prfpos = sppos
510aA*
600aDC**                 eval      kyaisl = prtail
600aDC**                 eval      kyloc  = prtloc
600aDC**                 eval      kyrlvl = prtlvl
600aDC**                 eval      kyhand = prthnd
510aAC                   exsr      getslotpos
600aDC**                 eval      prtpos = sppos

510aAC                   write(e)  prrec
510aAC                   if        %error
510aAC                   endif

510aA*  write record to log file.

510aAC                   eval      lgprcrt  = 'Y'
510aAC                   eval      lgprowhd = slwhdp
510aAC                   eval      lgproslt = sldisp
510aAC                   eval      lgproavl = slavl1
510aAC                   exsr      writelog

510aAC     endaddr       endsr

610bA*----------------------------------------------------------------
610bA*  addprtyrpld  Add priority replenishment record for odr item
610bA*----------------------------------------------------------------

610bAC     addprtyrpld   begsr

610bA*  Initialize flag and sequence number.

610bAC                   eval      prseq# = 0
610cAC                   exsr      getnxtseq
610cAC                   eval      prseq# = nextseq#
610bAC                   eval      prflag = 'S'

610bA*  Check to see if replenishment will free up a slot?

610bAC                   if        topick <> slavl1
610bAC                   eval      prfree = 'N'
610bAC                   else
610bAC                   eval      prfree = 'Y'
610bAC                   endif

610bA*  Add records to work file.

610bAC                   eval      prwhse = $slwhse
610bAC                   eval      prwhdp = $slwhdp
610bAC                   eval      pritem = #bitem
610bAC                   if        topick > 999
610bAC                   eval      prqty = 999
610bAC                   else
610bAC                   eval      prqty  = topick
610bAC                   endif
610bAC                   eval      prsdef = slsdef
610bAC                   eval      prstat = $slstat
610bA * From data
610bAC                   eval      prfail = slaisl
610bAC                   eval      prfloc = slloc
610bAC                   eval      prflvl = slrlvl
610bAC                   eval      prfhnd = slhand
610bAC                   eval      prfdis = sldisp
610bA * To data
650fAc                   if        $prslot <> ' '
650fAc                   eval      $sldisp = $prslot
650fAc                   exsr      drislotsr
650fAc                   else
610bAC                   eval      kyitem = $pritem
610bAC                   eval      kystat = 'RP'
610bAC                   eval      kypick = 'Y'

610bAC     keys3         setll     slot3

610bAC                   dow       forever = forever
610bAC     keys3         reade     slot3

610bAC                   if        %eof
610bAC                             or slitem = kyitem
610bAC                   leave
610bAC                   endif
610bAC                   enddo
650fAc                   endif

610bAC                   eval      prtail = slaisl
610bAC                   eval      prtloc = slloc
610bAC                   eval      prtlvl = slrlvl
610bAC                   eval      prthnd = slhand
610bAC                   eval      prtdis = sldisp

610bAC                   eval      prprty = 0

610bAC                   eval      prtype = #bityp
610bAC                   eval      prrplt = 'R'
610bAC                   exsr      getdatetime
610bAC                   eval      pradte = curdate
610bAC                   eval      pratim = curtime
610bAC                   eval      praqs  = savqtyneeded
610bA*
610bA*  Get From/To slot positions
610bA*
610bAC                   exsr      getslotpos
610bA*
610bAC                   exsr      getslotpos

610bAC                   write(e)  prrec
610bAC                   if        %error
610bAC                   endif

610bA*  write record to log file.

610bAC                   eval      lgprcrt  = 'Y'
610bAC                   eval      lgprowhd = slwhdp
610bAC                   eval      lgproslt = sldisp
610bAC                   eval      lgproavl = slavl1
610bAC                   exsr      writelog

610bAC     endaddrd      endsr

     *----------------------------------------------------------------
     *  calcovrflw    Calculate overflow available quantity
     *----------------------------------------------------------------

     C     calcovrflw    begsr

     C                   eval      ovravlqty = 0

     *  Whip through all active overflow slots for item.

     C                   eval      kyitem = $pritem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3

     C                   dow       forever = forever

     C     keys3         reade     slot3

     C                   if        %eof
     C                   leave
     C                   endif

     *    Calculate available slot qty.

     C                   exsr      calcqtys
     C                   eval      ovravlqty = ovravlqty + slavl1

     C                   enddo

     C                   endsr

510aA*----------------------------------------------------------------
750aA*  calcovrflwr   Calculate available quantity/all slots
510aA*----------------------------------------------------------------

510aAC     calcovrflwr   begsr

510aAC                   eval      ovravlqtyr = *zeros

750mA*  Whip through all slots for item. Used to determine onhand
750aA*  quantity for Repack items before adding Work Order

750aDC*                  eval      kystat = 'RP'
750aDC*                  eval      kypick = 'N'
750dAC*    keys3         setll     slot3
750aA /free
750aA                    setll ($prwhse:$pritem) slot3;
750aA /end-free

510aAC                   dow       forever = forever

750aDC*    keys3         reade     slot3
750aA /free
750aA                    reade ($prwhse:$pritem) slot3;
750aA /end-free

510aAC                   if        %eof
510aAC                   leave
510aAC                   endif

750aAc                   if        slstat<>'A ' and slstat<>'RP'
750aAc                   iter
750aAc                   endif

750aAC                   if        $itflgd = 'Y'  and
750aAC                             slexpd <> *zeros  and
750aAC                             slexpd < today
750aAC                   iter
750aAC                   endif

510aA*    Calculate available slot qty.

510aAC                   exsr      calcqtys
510aAC                   eval      ovravlqtyr = ovravlqtyr + slavl1

510aAC                   enddo

510aAC                   endsr

510aA*----------------------------------------------------------------
510aA*  calcovrflw2   Calculate overflow available quantity for parent
510aA*                item of a repack item.
510aA*----------------------------------------------------------------

510aAC     calcovrflw2   begsr

510aAC                   eval      parentqty1 = *zeros
510aAC                   eval      parentqty2 = *zeros
510aAC                   eval      rpkslot = *blanks

510aAC                   eval      $drisubcmd = '*GETMAIN'
510aAC                   eval      item# = $pritem
510aAC                   exsr      getitem

510aA*  Whip through all active overflow slots for item.

510aAC                   eval      kyitem = $pritem
510aAC                   eval      kystat = 'RP'
510aAC                   eval      kypick = 'N'
650aAc                   select
650aAc                   when      $prslot <> ' '
650aAC     kysl2p        setll     slot2
650aAc                   other
650aAC     keys3         setll     slot3
650aAc                   endsl

650aAC                   dow       forever = forever
650aAc                   select
650aAc                   when      $prslot <> ' '
650aAC     kysl2p        reade     slot2
650aAc                   other
510bAC     keys3         reade     slot3
650aAc                   endsl

510aAC                   if        %eof
510aAC                   leave
510aAC                   endif

510aA*    Calculate available slot qty.

510aAC                   exsr      calcqtys
510aAC                   eval      parentqty1 = parentqty1 + slavl1
510aAC                   eval      parentqty2 = parentqty2 + slavl2

510aAC                   enddo

650eA *  If the parent is another repack then use the quantity 1 field
650eAc                   select
740fDc*                  when      $ittype <> 'R'
740fMc                   when      $ittype <> 'R' and $itumq2 <> 0
510aAC                   eval      parentqty2 = parentqty2 / $itumq2
510aAC                   eval      rpkslot = sldisp
650eAC                   other
650eAc                   eval      rpkslot = sldisp
650eAc                   endsl

510aAC                   endsr

     *----------------------------------------------------------------
     *  calcqtys  Calculate slot quantities.
     *
     *     *** This routine should be identical to the one ***
     *     *** in program DRISLOT.                         ***
     *
     *----------------------------------------------------------------

     C     calcqtys      begsr

     *  Calculate physical quantity in slot.

     *    Note: The quantities that are used to calculate the physical
     *          slot quantity are part of processes which should be
     *          completed soon. We can not wait until the processes
     *          are closed to say the stock is or isn't there.

     *          For example: A replenishment request can not be refused
     *          because the picks that depleted the slot have not been
     *          closed yet. Timing is everything.

     C                   eval      slphy1 = (slstk1+slrcv1)-(sltfr1+slpck1)
     C                   eval      slphy2 = (slstk2+slrcv2)-(sltfr2+slpck2)
     C                   eval      slphy3 = (slstk3+slrcv3)-(sltfr3+slpck3)

     *  Calculate available quantity in slot.

     C                   eval      slavl1 = slphy1 - slalc1
     C                   eval      slavl2 = slphy2 - slalc2
     C                   eval      slavl3 = slphy3 - slalc3

     *  Calculate adjustable quantity in slot.

     C                   eval      sladj1 = slavl1 - slrcv1
     C                   eval      sladj2 = slavl2 - slrcv2
     C                   eval      sladj3 = slavl3 - slrcv3

     C                   endsr

     *----------------------------------------------------------------
     *  clearerrflags  Clear error flag fields.
     *----------------------------------------------------------------

     C     clearerrflags begsr

     C                   if        $prwhsee = '1'
     C                   eval      $prwhsee = '0'
     C                   endif

     C                   if        $priteme = '1'
     C                   eval      $priteme = '0'
     C                   endif

     C                   if        $prwhdpe = '1'
     C                   eval      $prwhdpe = '0'
     C                   endif

     C                   if        $prslote = '1'
     C                   eval      $prslote = '0'
     C                   endif

     C                   if        $prqtyne = '1'
     C                   eval      $prqtyne = '0'
     C                   endif

     C                   if        $prqtywe = '1'
     C                   eval      $prqtywe = '0'
     C                   endif

     C                   if        $prfille = '1'
     C                   eval      $prfille = '0'
     C                   endif

640gAC                   if        $prseq#e = '1'
640gAC                   eval      $prseq#e = '0'
640gAC                   endif

     C                   endsr

     *----------------------------------------------------------------
     *  chk4rpl    Check if replenishment already exists
     *----------------------------------------------------------------

     C     chk4rpl       begsr

     *  See if replenishment already exists.

     C     keypr4        setll     prplfil4

     C                   dow       forever = forever

     C     keypr4        reade     prplfil4

     C                   if        %eof
     C                   leave
     C                   endif

416bAC                   if        prflag = 'D'
416bAC                   delete(e) prrec4
416bAC                   if        %error
416bAC                   endif
416bAC                   iter
416bAC                   endif

     C                   if        $prslotu and prtdis <> $prslot
     C                   iter
     C                   endif

416bAC                   unlock    prplfil4
     C                   eval      error = *on
     C                   eval      $preturn  = 'REPLEXIST'
     C                   exsr      getmsg
     C                   if        $psubcmd = '*CRTSLTRPL'
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   endif
     C                   exsr      writelog
     C                   leave

     C                   enddo

     C     endchk4rpl    endsr

750gA*----------------------------------------------------------------
750gA*  multPSlt  -  Determine proper quantities to be replenished
750gA*               for multiple pick slot items
750gA*----------------------------------------------------------------

750gAC     multPSlt      begsr
750gAc                   exsr      getQtyNeeded
750gAC                   if        error
750gAC                   goto      endMultPck
750gAC                   endif
750gA *
750gA *   Now we will loop until we either have fulfilled all need for
750gA *   item by either placing required quantities in repsective Pick
750gA *   pick slots or by running out of pick slots to fill
750gA *
750gA /free
750cA     // Create looping SQL for all pick slot for this item
750gA       sqlstmt = 'select slwhse,slitem,sldisp' +
750gA                 '       from slot3' +
750gA                 ' where slwhse=' + %char($prwhse) + ' and' +
750gA                 ' slitem=' + sq + %trim($pritem) + sq +
750gA                 ' and slstat=' + sq + 'A' + sq +
750gA                 ' and slpick=' + sq + 'Y' + sq;
750gA       exec sql PREPARE mp FROM :SqlStmt;
750gA       exec sql DECLARE multp SCROLL CURSOR FOR mp;
750gA       exec sql OPEN multp;
750gA
750gA       dow qtyNeeded > 0;
750gA
750gA       // get last slot display before looping so I know my last pick slot
750gA       exec sql fetch last from multp into :$prwhse,:$pritem,:$prslot;
750gA       if sqlstt = sqlSuccess;
750gA         lastPickSlot = $prslot;
750gA         exec sql fetch first from multp into :$prwhse,:$pritem,:$prslot;
750gA       else;
750gA         lastPickSlot = *blanks;
750gA         leavesr;
750gA       endif;
750gA
750gA       dow forever = forever;
750gA          if sqlstt <> sqlSuccess;
750gA             qtyNeeded = 0;
750gA             leave;
750gA          endif;
750gA          exsr verifycrt;
750gA          if not error;
750gA            exsr createrpl;
750gA          endif;
750gA          exec sql fetch next from multp into :$prwhse,:$pritem,:$prslot;
750gA       enddo;
750gA
750gA       enddo;
750gA
750gA       exec sql close multp;
750gA /end-free
750gAc     endMultPck    endsr

     *----------------------------------------------------------------
     *  createrpl  Create replenishment
     *----------------------------------------------------------------

     C     createrpl     begsr

720dA*  Grab Specific Replen Type if sent
720dA
720dAC                   if        $pprogram = 'LT110A'
720dAc                   if        $prfill = *blanks or
720dAc                             ($prfill<>'N' and $prfill<>'F' and
720dAc                              $prfill<>'B' and $prfill<>'R' and
720dAc                              $prfill<>'A' and $prfill<>'S')
720dAc                   eval      $prtype='A'
720dAc                   endif
720dAC                   eval      $prtype = $prfill
720dAC                   eval      $prfill = *blanks
720dAc                   if        $prtype = 'N'
720dAc                   eval      $prtype=' '
720dAc                   endif
720dAc                   else
720dAc                   eval      $prtype='A'
720dAc                   endif

     *  See if replenishment already exists.

416cDC**                 exsr      chk4rpl
416cDC**                 if        error
416cDC**                 goto      endcreaterpl
416cDC**                 endif

     *  Get quantity needed.

750gA *  When Multiple Pick Slot item qtyneeded is called in MULTPICK
750gAc                   if        not multPick
 1B  C                   exsr      getqtyneeded
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif
750gAc                   endif

     *  Get slot to fill.

510aAC                   if        $ittype = 'R'and not $prslotu
510aAC                   eval      homeavlqty = *zeros
510aAC                   eval      error = *off
510aAC                   else
 1B  C                   exsr      getslt2fil
510aAC                   endif
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif

     *  At this point ...

     *    - We have the pick slot we are going to replenish.
     *    - We have already calculated the total qty the slot can hold.
     *    - We have already determined the qty of a single layer.
     *    - We have already calculated the empty qty of the slot.
     *    - We have already calculated the quantity needed.

     *  Now, see if replenishment needs to be done.

 1B  C                   exsr      rplcriteria
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif

     *  We passed the tests.
417aA*
417aA*  Set the replenishment type flag.
417aA*
520bAC                   if        $psubcmd >= '*CRTRPLSQ1'
520bAC                             and $psubcmd <= '*CRTRPLSQ9'
520bAC                             and homeavlqty< 0
520cAC                             or ($psubcmd = '*AVGQTY'
520cAC                              or $psubcmd = '*ORDQTY')
520cAC                             and homeavlqty < 0
520cA*
520bA*  Replace Qty Needed with actual slot quantity needed.
520bAC                   eval      qtyneeded  = homeavlqty * -1
520bAC                   eval      homeavlqty = 0
520bAC                   endif
520bA*
417aAC                   Exsr      setrpltype
720dA
720dA*  If replen type is not match to requested type skip
720dA
720dAC                   if        $prtype <> 'A'
720dAc                             and rplType <> $prtype
720dAc                   if        $prtype='S' and $zdstgflg='Y'
720dAc                   else
720dAC                   goto      endcreaterpl
720dAc                   endif
720dAc                   endif

     *  If item is a broken case item, then get base item information.

 3B  C                   if        $ittype = 'B'
700gAc                             or eachItem <> ' '
     C                   exsr      getbase
 1B  C                   if        error
     C                   goto      endcreaterpl
     C                   endif
 3E  C                   endif

510aA*  If item is a repack item, then get base item information-itemlnk

650hAC                   if        $ittype = 'R'
650hAc                             and (($psubcmd <>'*CRTRPLODN'
CCP AC                             and client <> capitolcity
CSP AC                             and client <> coastl
GFS AC                             and client <> getfresh)
700 DC*                            and client <> greenleaf
700 Ac*  as the new option below OPARPL is rolled to the above
700 Ac*  customers you can set as "N" No and remove the not
700 Ac*  equal condition above.
710dDC*                            or  oparpl = 'Y')
710dAC                             and  oparpl = 'Y')
700 Ac*  get repack type (1=Work Order, 2=On Demand)
700 A /free
700 A                    chain ($itwhse:$ititem) kititem;
700 A /end-free
510aAC                   exsr      getbase
700 Ac                   if        %found(kititem)
700 Ac                   if        kirptp = '1'
700 Ac*  only Work Order Repacks are performed here.  The
700 Ac*  qty logic for On Demand is in LT110F and it then
700 Ac*  calls command CRTRPLODR in DRIPRTYRPL if needed
650gMC                   exsr      createwo
700 Ac                   endif
700 Ac                   endif
510aAC                   goto      endcreaterpl
510aAC                   endif

720bA*  Reduce homeavlqty by Replenishment Level quantity on item master
720bA*  This will allow replenishment to be trigger once below Replenishment
720bA*  Level.  Essentially forces replen at certain number of consumed cases.
720bA*  Example:  Breakdown/Normal Replishment Level = 10
720bA*            Breakdown/Normal Available is 10
720bA*            Several statements below if qtyneeded is less than available
720bA*            Quantity no replen is generated.  Now if *RPLLVL system will
720bA*            reduce available quantitry by Replen Level on item master and
720bA*            and drive a repenishment.
720bA
MQSbAC                   if        client = marques
720bAc                   if        $psubCmd = '*RPLLVL'
720bAc                   eval      homeavlqty = homeavlqty - $itrepl
720bAc                   if        homeavlqty < *zeros
720bAc                   eval      homeavlqty=*zeros
720bAc                   endif
720bAc                   endif
MQSbAc                   endif

     *  Reduce quantity needed by home slot available quantity.

 1B  C                   eval      qtyneeded = qtyneeded - homeavlqty

     *  Create replenishment.

 1B  C                   select

700gAC* resequence the when statements for the *each project
700gAc* a *each replenishment will have rpltype = 'B', but will
700gAc* also have $ittype = ' ', so code will never hit the rpgtype=B
700gAC* when statement for *each
700gAC* move the when $ittype = ' ' to the last when statement
MQSbA *
MQSbA *   If Marques Store Slot force case replenishments through Breakdown
MQSbA *   logic since cases are moved and not pallets.  We also want both
MQScA *   Breakdown repln quantities and case quantities to be pulled from
MQSbA *   pick slot when possible
MQSbA *
MQSbAc                   when      client=Marques and $ittype=' '
MQSbAc                             and $zdstgFlg='Y'
MQSbAc                   eval      #bitem = $pritem
MQSbAc                   eval      #bumq2 = 1
MQSbAc                   eval      #bstyp = $itstyp
MQSbAC                   exsr      crtbrkfix
700gDC**                 when      $ittype = 'B' and #bstyp = 'F'
700fMC                   when      rpltype = 'B' and #bstyp = 'F'
     C                   exsr      crtbrkfix

700fDC**                 when      $ittype = 'B' and #bstyp = 'P'
700fMC                   when      rpltype = 'B' and #bstyp = 'P'
     C                   exsr      crtbrkpir

650hdC*                  when      $ittype = ' '
650hMC                   when      $ittype = ' ' or $psubcmd = '*CRTRPLODN'
     C                   exsr      crtnorm
 1E  C                   endsl
640gAC                   eval      $prseq# = prseq#

     C     endcreaterpl  endsr

510aA*----------------------------------------------------------------
510aA*  createwo   Create repack work orders
510aA*----------------------------------------------------------------

510aAC     createwo      begsr

510aAC                   eval      ovravlqty = *zeros
510aAC                   eval      ovravlqtyr = *zeros
750aDC*                  if        homeavlqty <> *zeros
750aDc*                  exsr      calcovrflw
510aAC                   exsr      calcovrflwr
750aDC*                  endif

510aA*  Reduce quantity needed by home slot available quantity.

510aAC                   eval      qtyneeded = qtyneeded - homeavlqty
510aAC                                                   - ovravlqty
510aAC                                                   - ovravlqtyr

750aAc                   if        qtyneeded < 0
750aAc                   eval      qtyneeded=0
750aAc                   endif

510aAC                   z-add     qtyneeded     $pqty

510aAC                   if        $pqty <> *zeros

510aAC                   call      'CRTWRKORD'
700 DC*                  parm      '*CRTWRKODR'  $pcmd
700 AC                   parm      '*CRTWRKORD'  $pcmd
510aAC                   parm      $prwhse       $pwhse
510aAC                   parm      $pritem       $pitem
510aAC                   parm                    $pqty
510aAC                   parm      'D'           $pby
510aAC                   parm                    $pref
510aAC                   parm                    $prtn
510aAC                   parm                    $pmsg
510bAC                   parm                    $pord
510bAC                   parm      today         $pndtc

510aAC                   endif

510aAC                   endsr

     *----------------------------------------------------------------
     *  crtbrkfix  Create replenishment for brokencase item
     *              where base item is in Fixed section.
     *----------------------------------------------------------------

     C     crtbrkfix     begsr
     C                   eval      addrplflag = *off
     C                   eval      foundpslot = *off

720 A*     If this is a Store Staging Replen and Overflow at the store covers the
720 A*     pick slot need then leave without doing anything
720 A
720 Ac                   if        $zdStgFlg = 'Y'
720 AC                   if        qtyneeded <= (ovrCasesAvl*#bumq2)
500bAC                   eval      error = *on
500bAC                   eval      $preturn  = 'LVLOK'
500bAC                   exsr      getmsg
500bAC                   exsr      writelog
720 AC                   leavesr
720 Ac                   else
720 Ac*     when store overflow is less than needed simply reduce the replenishment
720 Ac*     by what is in overflow and then zero in case it loops around because one
720 Ac*     slot cannot replen remaining need
720 Ac                   eval      qtyneeded = qtyneeded -
720 Ac                                          (ovrCasesAvl*#bumq2)
720 Ac                   eval      homeempqty = homeempqty -
720 Ac                                          (ovrCasesAvl*#bumq2)
720 Ac                   eval      foundpSlot = *off
720 Ac                   eval      ovrCasesAvl = *zeros
720 AC                   endif
720 Ac                   endif

     *   Loop through picking slot for breakdown item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879

     *     Item does not have a pick slot, replenish from overflow slots.

640dDC**                 if        *in79 and not foundpslot
640dMC                   if        *in79
640dAC                   if        not foundpslot
     C                   exsr      crtbrkovr
640dAC                   endif
 1L  C                   leave
 2E  C                   endif
720 A
720 A*     If pick slot is in Store do not use for Replenishment Staging
720 A
720 AC                   if        sldisp=$zdstrbpck or sldisp=$zdstrcpck
720 AC                   iter
720 AC                   endif
720 A
720 A*     If Staging Replenishment then verify no other Store Slot
720 A
720 A /free
720 A                    if opsslcn='Y';
720 A                      chain (slwhse:slwhdp:sldisp) slotstr;
720 A                      if %found(slotStr);
720 A                        iter;
720 A                      endif;
720 A                    endif;
720 A /end-free

     *     If record is locked, try to get next one.

 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

700fA*     If Each replenishment, ignore *EACH slots.

700fA /free
700fA       if eachRPL;
700fA         chain (slwhse: slsdef) slotdef;
700fA         // 700gD if not %found(slotdef) or sdpal <> '*EACH';
700GA         if not %found(slotdef) or sdpal = '*EACH';
700fA           iter;
700fA         endif;
700fA       endif;
700fA /end-free

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
     C                   iter
 2E  C                   endif

     *     Ignore slot if nothing available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
     C                   iter
 2E  C                   endif

     *     Found a usable pick slot.

     C                   eval      foundpslot = *on

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
MQSdAc                              and Client<>marques and $zdStgFlg <> 'Y'
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
JPF Ac                              and Client<>'PALMER'
MQSdAc                              and Client<>marques and $zdStgFlg <> 'Y'
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     If total to pick is zero then leave.  This could happen if not rounded

720eAC                   if        topick = *zeros
720eAC                   leave
720eAC                   endif

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
500eA
500eA*     If ti/hi wasn't found for pick slot, set pick quantity to 1.
500eA
500eAC                   if        not foundtihi
500eAC                   eval      topick = 1
500eAC                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

     *     Otherwise, we loop around and try for another replenishment.

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOFULLCASE'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     pickfe        endsr

     *----------------------------------------------------------------
     *  crtbrkovr  Create replenishment for brokencase item
     *              where base item does not have a pick slot.
     *----------------------------------------------------------------

     C     crtbrkovr     begsr

     *   Loop through replenishment slots for item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879
 2B
 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif
 2B
 2B  C                   if        *in78
TPC A*
TPC A*     Skip slots for TPC that are in "cone house".
TPC AC                             or client = TPC
TPC AC                             and slwhdp = 'DRY'
TPCaMC                             and (slaisl >= ' 60'
TPCaAC                             and  slaisl <= ' 69'
TPCcDC**                           or   slaisl >= ' 77'
TPCcMC                             or   slaisl >= ' 81'
TPCeAC                             and  slaisl <= ' 89'
TPCeAC                             or   slaisl >= ' 91'
TPCbAC                             and  slaisl <= ' 94'
TPCbAC                             or   slaisl >= ' 97'
TPCaMC                             and  slaisl <= ' 99')
TPC A*
 1L  C                   iter
 2E  C                   endif
720 A
720 A*     Do not allow ANY replenishment to use overflow slots defined
720 A*     in Store locations
720 A
720 AC                   if        sldisp = $zdstrovf1
720 AC                               or sldisp = $zdstrovf2
720 AC                               or sldisp = $zdstrovf3
720 AC                   iter
720 AC                   endif
720 Ac
720 A
720 A*     Do not use any outstanding RPA DOCK slots
720 A
720 AC                   if        slaisl = 'RPA'
MQScAC                              or (client = marques
MQScAc                                  and slaisl='MTF')
720 AC                   iter
720 AC                   endif
720 Ac
600cA*     Ignore some special license tracking slots.
600cA
600dAC                   if        sldesg = 'BFC'
600cAC                   iter
600cAC                   endif
720 A
720 A*     Do not use any outstanding RPA DOCK slots
720 A
720 AC                   if        slsdef = 'BF'
720 AC                   iter
720 AC                   endif
740bA
740bA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740bA
740bA /free
740bA    monitor;
740bA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740bA      if wwrtn = '*YES';
740bA        iter;
740bA      endif;
740bA    on-error;
740bA    endmon;
740bA /end-free
740bA
720 A
720 A*     If Staging Replenishment then verify no other Store Slot
720 A
720 A /free
720 A                    if opsslcn='Y';
720 A                      chain (slwhse:slwhdp:sldisp) slotstr;
720 A                      if %found(slotStr);
720 A                        iter;
720 A                      endif;
720 A                    endif;
720 A /end-free
DRYaA*     Ignore slots in other facility (slaisl > '099')
DRYcMC*                  if        client = dairyland and
DRYcMC*                            slwhse = 001 and
DRYcMC*                            slaisl > '099'
DRYcMC*                  iter
DRYcMC*                  endif
DRYhA*     Ignore slots in Chefs OSS aisles
DRYhAC                   if        client = dairyland
DRYhAC                   if        slwhse = 55
DRYhAC                             and (slaisl >= '030' and slaisl <= '050')
DRYhAC                   iter
DRYhAC                   endif
DRYhAC                   endif
ICBaA*     Ignore slots in other facility (slaisl > '099')
ICBaMC                   select
ICBaMC                   when      client = icb
ICBaMC                   if        slaisl = '  G'
ICBaMC                             or slaisl = '  H'
ICBaMC                             or slaisl = '  I'
ICBaMC                             or slaisl = '  N'
ICBaMC                             or slaisl = '  P'
ICBaMC                             or slaisl = '  R'
ICBaMC                             or slaisl = '  T'
ICBaMC                   iter
ICBaMC                   endif
ICBaMC                   endsl
740aA
740aA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740aA
740aA /free
740aA    monitor;
740aA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740aA      if wwrtn = '*YES';
740aA        iter;
740aA      endif;
740aA    on-error;
740aA    endmon;
740aA /end-free
740aA

     *     Ignore slot if no normal stock or past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Save slot information and available quantities.

     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.

 2B  C                   dou       forever <> forever
     C     keys3b        reade     slot3                                  76
 3B  C                   if        *in76
 2L  C                   leave
 3E  C                   endif

     *        Ignore slot if past expiration date.

 3B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 2I  C                   iter
 3E  C                   endif

     *        Calculate quantity available in slot.

     C                   exsr      calcqtys

 3B  C                   if        slavl1 <= 0
 2I  C                   iter
 3E  C                   endif
720 A
720 A*     Do not allow ANY replenishment to use overflow slots defined
720 A*     in Store locations
720 A
720 AC                   if        sldisp = $zdstrovf1
720 AC                               or sldisp = $zdstrovf2
720 AC                               or sldisp = $zdstrovf3
720 AC                   iter
720 AC                   endif
720 Ac
720 Ac
600cA*     Ignore some special license tracking slots.
600cA
600dAC                   if        sldesg = 'BFC'
600cAC                   iter
600cAC                   endif
720 A
720 A*     Do not use any outstanding RPA DOCK slots
720 A
720 AC                   if        slsdef = 'BF'
720 AC                   iter
720 AC                   endif
720 A
720 A*     If Staging Replenishment then verify no other Store Slot
720 A
720 A /free
720 A                    if opsslcn='Y';
720 A                      chain (slwhse:slwhdp:sldisp) slotstr;
720 A                      if %found(slotStr);
720 A                        iter;
720 A                      endif;
720 A                    endif;
720 A /end-free

     *        If this slot has the least qty available then
     *        save slot information and available quantities.

 3B  C                   if        slavl1 <= svavl1

     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

 3E  C                   endif

 2E  C                   enddo

     *     Get the selected slot.

     C     keys3c        chain     slot3                              76
 2B  C                   if        *in76
 1I  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
MQSdAc                              and Client<>marques and $zdStgFlg <> 'Y'
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
MQSdAc                              and Client<>marques and $zdStgFlg <> 'Y'
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
500eA
500eA*     If ti/hi wasn't found for pick slot, set pick quantity to 1.
500eA
500eAC                   if        not foundtihi
500eAC                   eval      topick = 1
500eAC                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

 1E  C                   enddo

     C                   endsr


700aA*----------------------------------------------------------------
700aA*  crtprdwip  Create replenishment from WIP if stock exists
700aA*----------------------------------------------------------------
700aA
700aAC     crtprdwip     begsr
700bDc*  This routine will determine what if any WIP quantity exist
700bDc*  for passed in item.  If wip quantity exist it will then
700bDc*  decide if all will be used or partial.
      /free
700bD  //       wipstk1=0;
700bD  //       wipstk2=0;
700bD  //       wipstk3=0;

700bD  //       exec sql
700bD  //            select sldisp,sum(slstk1),sum(slstk2),sum(slstk3)
700bD  //              into wipstk1,wipstk2,wipstk3
700bD  //              from slot where slitem = :$pritem
700bD  //              group by sldisp
700bD  //              fetch first row only;

700bD  //       if sqlStt <> '00000' or
700bD  //          (wipstk1=0 and wipstk2=0 and wipstk3=0);
700bD  //          leavesr;
700bD  //       endif;

700bD  //At this point we know we have a WIP location for this item
700bD  //so we need to see if WIP location has enough stock for the
700bD  //request or if we need to generate replenishment for what is
700bD  //in WIP and then return and get remaining stock from the
700bD  //Warehouse

700bD  // always replenish the full value from WIP to LINE slot
700bD  // and then determine if that leaves remaining need to
700bD  // come from the warehouse
700bD  //exec sql delete from slot where xxx=yyy;
700bD  //if (qtyneeded * wipumq2 * wipumq3) <
700bD  //   ((wipstk1 * wipumq2 * wipumq3) +
700bD  //    (wipstk2 * wipumq3) + wipstk3);



700bA  // Leave subroutine when quantity needed is zero.
700bA  if qtyneeded <= 0;
700bA    leavesr;
700bA  endif;

700bA  // Close Cursor
700bA  exec sql
700bA   close csrWipStock;

700bA  // Retrieve existing Production WIP inventory for the item passed in.
700bA  // SLOT & PLINED files are joined because the customers can rename their
700bA  // WIP aisles (not recommended).
700bA  // * Note: slrlvl(rack level) ~ inlneno(mfg line#).

700bA  // Declare Cursor
700bA  exec sql
700bA    declare csrWipStock cursor for
700bA    select a.*
700bA      from SLOT a inner join PLINED
700bA        on slwhse = inwhse
700bA       and slrlvl = inlneno
700bA       and slaisl = inwipaisl
700bA       and slstat = 'PR'
700bA       and instat = 'A'
700bA     where slwhdp = :$prwhdp
700bA       and slitem = :$pritem
700bA       and slrlvl = :prdTlvl;

700bA  // Open Cursor
700bA  exec sql
700bA   open csrWipStock;

700bA  // Process Result Set
700bA  dow forever = forever;
700bA    clear dsSlot;
700bA    exec sql
700bA      fetch next from csrWipStock into :dsSlot;

700bA    if sqlStt <> '00000';
700bA      leave;
700bA    endif;

700bA    // Ignore slot if past expiration date.
700bA    if $itflgd = 'Y' AND (slexpd <> *zeros and slexpd < today);
700bA      iter;
700bA    endif;

700bA    // Ignore slot if nothing available in slot.
700bA    exsr calcqtys;
700bA    if slavl1 <= *zeros and slavl2 <= *zeros;
700bA      iter;
700bA    endif;

700bA    // Get item information.  Breakdown unit of measure & quantity needed.
700bA    eval item# = $pritem;
700bA    $drisubcmd = '*GETMAIN';
700bA    exsr getitem;

700bA    // Convert total quantity needed to the lowest unit of measure.
700bA    select;
700bA      when sav$prqtyw <> 0 and $itum2 <> *blanks;
700bA        ttlQtyNeeded = (sav$prqtyn * $itumq2) + sav$prqtyw;
700bA      other;
700bA        ttlQtyNeeded = sav$prqtyn;
700bA    endsl;

700bA    // Convert total quantity in WIP slot to the lowest unit of measure.
700bA    select;
700bA      when $itum3 <> *blanks and $itumq3 <> 0;
700bA        ttlWipStock = ((slavl1 * $itumq2 * $itumq3))
700bA                    +  (slavl2 * $itumq3)
700bA                    +   slavl3;
700bA      when $itum2 <> *blanks and $itumq2 <> 0;
700bA        ttlWipStock = (slavl1 * $itumq2)
700bA                    +  slavl2;
700bA      other;
700bA        ttlWipStock = slavl1;
700bA    endsl;

700bA    // Calculate replenishment quantity to pick.
700bA    //  If breakdown replenishments are needed, LT110G will pass both case
700bA    //  and breakdown replenishments needed on 1st call and case only on
700bA    //  on 2nd call.  Otherwise, only 1 call from LT110G for case
700bA    //  replenishment.

700bA    // Breakdown replenishment
700bA    if $brkqty <> 0;
700bA      select;
700bA        // No WIP stock available
700bA        when ttlWipStock <= 0;
700bA          iter;

700bA        // Use ALL available breakdown from WIP slot
700bA        when qtyneeded = slavl2;
700bA          topick = qtyneeded;

700bA        // When available WIP breakdown exceeds replenishment breakdown &
700bA        // total WIP available exceeds total replenishment, then pull
700bA        // qtyneeded from WIP breakdown.
700bA        when qtyneeded < slavl2 and ttlQtyNeeded <= ttlWipStock;
700bA          topick = qtyneeded;

700bA        // When available WIP breakdown exceeds replenishment breakdown &
700bA        // total replenishment exceeds total WIP available, then go ahead
700bA        // and pull ALL available WIP breakdown.
700bA        when qtyneeded < slavl2 and ttlQtyNeeded > ttlWipStock;
700bA          topick = slavl2;

700bA        // Breakdown needed exceeds breakdown quantity in WIP slot, but
700bA        // enough overall WIP quantity to fill this breakdown replenishment
700bA        when qtyneeded > slavl2 and ttlQtyNeeded <= ttlWipStock;
700bA          topick = qtyneeded;

700bA        // Breakdown needed exceeds overall WIP quantity so use remaining
700bA        // WIP quantity.  The remainder of this breakdown replenishment
700bA        // will be pulled from the warehouse.
700bA        when qtyneeded > slavl2 and ttlQtyNeeded > ttlWipStock;
700bA          if slavl2 > 0;
700bA            // Not enough in WIP to fill entire replenishment so use
700bA            // remaining quantity from WIP.
700bA            topick = slavl2;
700bA          else;
700bA            // Nothing left in WIP breakdown slot to replenishment with.
700bA            iter;
700bA          endif;
700bA      endsl;
700bA    endif;


700bA    // Case replenishment
700bA    if $brkqty = 0;
700bA      select;
700bA        // No WIP cases available
700bA        when slavl1 <= 0;
700bA          // Pull any remaining breakdown WIP stock
700bA          if ttlWipStock > 0;
700bA            // temporarily make $brkqty & topick equal to remaining
700bA            //  WIP breakdown
700bA            $brkqty = ttlWipStock;
700bA            topick  = ttlWipStock;

700bA            // See if existing replenishment record can be updated.
700bA            updflag = *off;
700bA            addrplflag = *off;
700bA            #bitem = $pritem;
700bA            exsr updprtyrplp;
700bA            if updflag = *on;
700bA              addrplflag = *on;
700bA            endif;

700bA            // Create priority replenishment.
700bA            if updflag = *off;
700bA              $slwhse = slwhse;
700bA              $slwhdp = slwhdp;
700bA              exsr addprtyrplp;
700bA              addrplflag = *on;
700bA            endif;

700bA            // restore $brkqty back to zero
700bA            $brkqty = 0;
700bA          endif;

700bA          iter;

700bA        // WIP cases available
700bA        when slavl1 > 0;
700bA          if qtyneeded < slavl1;
700bA            topick = qtyneeded;
700bA          else;
700bA            // Pull available WIP then remainder will be pulled from warehouse
700bA            topick = slavl1;
700bA          endif;
700bA      endsl;
700bA    endif;

700bA    // See if existing replenishment record can be updated.
700bA    updflag = *off;
700bA    addrplflag = *off;
700bA    #bitem = $pritem;
700bA    exsr updprtyrplp;
700bA    if updflag = *on;
700bA      addrplflag = *on;
700bA    endif;

700bA    // Create priority replenishment.
700bA    if updflag = *off;
700bA      $slwhse = slwhse;
700bA      $slwhdp = slwhdp;
700bA      exsr addprtyrplp;
700bA      addrplflag = *on;
700bA    endif;

700bA    // Reduce empty and needed quantities.
700bA    homeempqty = homeempqty - topick;
700bA    qtyneeded  = qtyneeded  - topick;

700bA    // If we got what we needed, get out.
700bA    if qtyneeded <= 0 or $preturn = 'NOOVERFLOW';
700bA      leave;
700bA    endif;

700bA    // If we are not trying to fill need and slot is full, get out.
700bA    if not $prfillu or $prfill <> 'Y';
700bA      if homeempqty <= 0;
700bA        leave;
700bA      endif;
700bA    endif;

700bA  enddo;
      /end-free
700aAC                   endsr

650iA*----------------------------------------------------------------
650iA*  crtprdfix  Create replenishment for Production Item
650iA*----------------------------------------------------------------
650iA
650iAC     crtprdfix     begsr
650iAC                   eval      addrplflag = *off
650iAC                   eval      foundpslot = *off
650iAc*  You can only send breakdown or case quantity to generate
650iAc*  replenishment.  If both are required they must be sent
650iAc*  as separate calls.  Therefore is break quantity is sent
650iAc*  force on replenishment quantity and set item type to "E"
650iAc*  for Each (breakdown 1).  Do not confuse this with a actual
650iAc*  "B" type breakdown item.  This "E" is where a case item
650iAc*  has a breakdown 1 and we are allowing someone to generate
650iAc*  and actually deliver the breakdown item as a replenishment
650iAc                   if        $brkqty <> 0
650iAc                   eval      $prqtyn = $brkqty
650iAc                   endif
650iAC                   eval      homeempqty  = $prqtyn
650iAC                   eval      qtyneeded   = $prqtyn
650iAC                   eval      savqtyneeded  = $prqtyn
650iA
650iA*   Get To Production Slot that was passed in
650iA
      /free
                         chain ($prwhse:$prwhdp:$prslot) slot2;
                         if %found(slot2);
                    // setup to production slot
650iA                    prdTslot = sldisp;
650iA                    rpkwhdp  = slwhdp;
650iA                    prdTail  = slaisl;
650iA                    prdTlvl  = slrlvl;
650iA                    prdThnd  = slhand;
650iA                    prdTloc  = slloc;
650iA                    else;
650iA /end-free
650iAc                   goto      endcrtprd
650iAc                   endif

700bA*   Check Production WIP slots for requested item
700bAc                   exsr      crtprdwip

650iA*   Loop through picking slot for requested item being pulled
650iA
650iAC                   eval      kyitem = $pritem
650iAC                   eval      #bitem = $pritem
650iAC                   eval      kystat = 'A '
650iAC                   eval      kypick = 'Y'
650iAC     keys3         setll     slot3
650iAC                   dow       forever = forever
650iAC     keys3         reade     slot3                                7879
650iA
650iA*  Item does not have a pick slot, replenish from overflow slots.
650iA
650iAC                   if        *in79
650iA*  only allow full case replenishments from overflow,
650iA*  otherwise return error
650iAC                   if        not foundpslot and $brkqty = 0
650iDC*                  if        not foundpslot
650iAC*                  exsr      calcovrflw
650iAC                   exsr      crtprdovr
650iAC                   endif
650iAC                   leave
650iAC                   endif
650iA
650iA*     If record is locked, try to get next one.
650iA
650iAC                   if        *in78
650iAC                   iter
650iAC                   endif
650iA

700fA*     Ignore *EACH slots
700fA
700fA /free
700fA       chain (slwhse: slsdef) slotdef;
700fA       if %found(slotdef) and sdpal = '*EACH';
700fA         iter;
700fA       endif;
700fA /end-free

650iA*     Ignore slot if past expiration date.
650iA*     No longer exclude pick slot because zero quantity
650iA
650iAC*                  if        slstk1 <= *zeros or
650iAC*                            $itflgd = 'Y'     and
650iAC                   if        $itflgd = 'Y'  and
650iAC                             slexpd <> *zeros  and
650iAC                             slexpd < today
650iAC                   iter
650iAC                   endif
650iA
650iA*     Ignore slot if nothing available in slot.
650iA*     No longer exclude because of zero available
650iA
650iAC                   exsr      calcqtys
650iAC                   if        slavl1 <= *zeros
650iAC                   iter
650iAC                   endif
650iA
650iA*  remove from replen calc since it is already available and the
650iAc                   if        qtyneeded <= 0
650iAc                   leave
650iAc                   endif
650iA
650iA*     Found a usable pick slot.
650iA
650iAC                   eval      foundpslot = *on
650iA
650iA*     Calculate quantity to pick.
650iA
650iAC                   eval      topick = qtyneeded
650iA
650iA*     Make sure pick quantity isn't greater than available quantity.
650iA*     remove this check to allow for larger replenishment
650iA*     to allow user to do Specific slot replenishment or repack
650iA*     Work Orders where pick slot has too little stock
650iA
650iAC*                  if        topick > slavl1
650iAC*                  eval      topick = slavl1
650iAC*                  endif
650iA
650iA*     See if existing replenishment record can be updated.
650iA
650iAC                   exsr      updprtyrplp
650iAC                   if        updflag = *on
650iAC                   eval      addrplflag = *on
650iAC                   endif
650iA
650iA*     Create priority replenishment.
650iA
650iAC                   if        updflag = *off
650iAC                   eval      $slwhse = slwhse
650iAC                   eval      $slwhdp = slwhdp
650iAC                   exsr      addprtyrplp
650iAC                   eval      addrplflag = *on
650iAC                   endif
650iA
650iA*     Reduce empty and needed quantities.
650iA
650iAC                   eval      homeempqty = homeempqty - topick
650iAC                   eval      qtyneeded  = qtyneeded - topick
650iA
650iA*     If we got what we needed, get out.
650iA
650iAC                   if        qtyneeded <= 0
650iAC                             or $preturn = 'NOOVERFLOW'
650iAC                   leave
650iAC                   endif
650iA
650iA*     If we are not trying to fill need and slot is full, get out.
650iA
650iAC                   if        not $prfillu or $prfill <> 'Y'
650iAC                   if        homeempqty <= 0
650iAC                   leave
650iAC                   endif
650iAC                   endif
650iA
650iA*     Otherwise, we loop around and try for another replenishment.
650iA
650iAC                   enddo
650iA
650iA*  Throw error if a replenishment was not created.
650iA
650iAC                   if        not addrplflag
650iAC                   eval      error = *on
650IAC                   IF        $brkqty <> 0
650iAC                   eval      $preturn  = 'NOPICKFBRK'
650iAc                   else
650iAC                   eval      $preturn  = 'NOFULLCASE'
650iAc                   endif
650iAC                   exsr      getmsg
650iAC                   exsr      writelog
650iAC                   endif
650iA
650iAC     endcrtprd     endsr

730bA*----------------------------------------------------------------
730bA*  caclDdReq  Determine proper quantity require for Drop Pick
730bA*             Total quantity for case/breakdown 1 is calculated
730bA*             and compared to allocated and quantities already
730bA*             replenished to get the proper value needed in addition
730bA*             to what is already in place
730bA*----------------------------------------------------------------
730bA
730bAC     calcDdReq     begsr
     c                   eval      cmpItem=$pritem
730bAc*  get item information
730bAC                   eval      $drisubcmd = '*GETMAIN'
730bAC                   eval      item# = $pritem
730bAC                   exsr      getitem
     c*
     c*     If Contract, Alias or SSB item
     c*     Then get Base Slot item.
     c*
     c                   if        $ittype = 'A'  or
     c                             $ittype = 'C'  or
     c                             $ittype = 'S'
     c                   call      'GETSLOTITM'
     c                   parm                    $prwhse
     c                   parm                    $pritem
     c                   parm      ' '           #sitem           15
     c                   parm                    #sityp            1
     c                   parm                    #sdesc           30
     c                   parm                    #spdsc           15
     c                   parm                    #srtn            10
     c                   parm                    #smsg            60
     c
     c*    use base item if found
     c                   if        #srtn='*OK'
     c                   eval      $pritem = #sitem
     c                   eval      cmpItem=#sitem
     c                   endif
     c                   endif
730bAc
730bAc*  get item information
730bAC                   eval      $drisubcmd = '*GETMAIN'
730bAC                   eval      item# = $pritem
730bAC                   exsr      getitem
730bA /free
730bA    // get demand from itemord and itemordexa if not or610
730bA         newQtyn=0;
730bA         newQty1=0;
740dD         if $pprogram<>'OR610';
730bA           chain ($prwhse:$pritem) itemord;
730bA           if %found(itemord);
730bA             newQtyn=iitqo;
730bA           endif;
740 A           exWhse = $prWhse;
740 A           ioeitm = $pritem;
740 A           exitemord ('*GET': exRtnCode: exRtnMsg: exWhse: ioeitm:
740 A                        ioebd1);
740 A           if exRtnCode = '*ERROR';
740 A             ioebd1=*zeros;
740 A           endif;
740 A           newQty1=ioebd1;
740dD         else;
                // setup allocation quantity from or610
                newQty1 = $prQtyw;
                newQtyn = $prQtyn;
740dD         endif;

730bA         // roll quantities to lowest level for calculations later
730bA         if $itumq2 <> 0;
730bA           dmdQty1 = (newQtyn*$itumq2) + newQty1;
730bA           dmdQtyn = 0;
730bA         else;
730bA           dmdQty1=0;
730bA           dmdQtyn = newQtyn;
730bA         endif;

740dA         // consider replenishments being processed currently
730bA         newQtyn=0;
730bA         newqty1=0;
730bA         setll ($prwhse:$pritem) prplfil4;
730bA         dow forever = forever;
730bA           reade ($prwhse:$pritem) prplfil4;
730bA           if not %equal(prplfil4) or %eof(prplfil4);
730bA             leave;
730bA           else;
750cA             // only consider non deleted and ones NOT being processed
750cD             //if prflag<>'D';
750eD             //if prflag<>'D' and prflag<>'S';
750dD             //if prflag<>'D' and prflag<>'A';
750fA             // we should consider the quantity on a Status "A".  It has
750fA             // a chance of being doubled in small window after update to
750fA             // to slot but before status is updated to "D"
750fM             if prflag<>'D';
730bA               if prtype='E';
730bA                 newQty1 = newQty1 + prqty;
730bA               else;
730bA                 newQtyn = newQtyn + prqty;
730bA               endif;
750eA               monitor;
750fA                 if prflag<>'A';
750fA                   // do not delete PRPLFIL when Actively being replenished
750eA                   delete prrec4;
750fA                 endif;
750eA               on-error;
750eA               endmon;
730bA             endif;
730bA           endif;
730bA         enddo;
730bA         // roll quantities to lowest level for calculations later
730bA         if $itumq2 <> 0;
730bA           curRpl1 = (newQtyn*$itumq2) + newQty1;
730bA           curRpln = 0;
730bA         else;
730bA           curRpl1=0;
730bA           curRpln = newQtyn;
730bA         endif;

730bA         // get quantity already in allocated and picked
730bA         newQtyn=0;
730bA         newqty1=0;
750eA         avlQtyn=0;
750eA         avlqty1=0;
730bA         setll ($prwhse:$itwhdp:$pritem) slot4;
730bA         dow forever = forever;
730bA           reade ($prwhse:$itwhdp:$pritem) slot4;
730bA           if not %equal(slot4) or %eof(slot4);
730bA             leave;
730bA           else;
730bA             if slstat<>'Z' and sldesg='*DROP';
                    // add stock to available and allocation/pick to demand
750eA               if slstk2>0;
730bA                 avlQty1 = avlQty1 + slstk2;
750eA               endif;
750eA               if slstk1>0;
730bA                 avlQtyn = avlQtyn + slstk1;
750eA               endif;
740dA               newQty1 = newQty1 + slalc2 + slpck2;
740dA               newQtyn = newQtyn + slalc1 + slpck1;
730bA             endif;
730bA           endif;
730bA         enddo;

740dA         // If quantity allocated exceeds quantity from Itemord process
740dA         // we should use that number, otherwise use Itemord number
740dD         if $pprogram<>'OR610';
740dA           if $itumq2 <> 0;
740dA             if ((newQtyn*$itumq2) + newQty1) >
740dA                ((dmdQtyn*$itumq2) + dmdQty1);
740dA               dmdQty1 = newQty1;
740dA               dmdQtyn = newQtyn;
740dA             endif;
740dA           else;
740dA             if newQtyn > dmdQtyn;
740dA               dmdQtyn = newQtyn;
740dA             endif;
740dA           endif;
              else;
                // when called from single order allocation process
                // we add this orders allocation to the total allocation
                // and pick qty for total demand.  That will be compared
                // to existing onhand plus any outstanding prplfil
                // quantity to understand if additional quantity is required.
                dmdQty1 = dmdQty1 + newQty1;
                dmdQtyn = dmdQtyn + newQtyn;
740dA         endif;

730bA         // get net value needed
              if $itumq2 <> 0;
                calcQty1 = ((avlQtyn*$itumq2) + avlQty1) -
                           ((dmdQtyn*$itumq2) + dmdQty1);
                calcQtyn = 0;
              else;
                calcQtyn = avlQtyn - dmdQtyn;
                calcQty1=0;
              endif;

730bA         // rollup calculated quantity if necessary
730bA         if calcQty1 < 0;
730bA           newQtyn=%abs(calcQtyn);
730bA           newQty1=%abs(calcQty1);
730bA           exsr zzupQty;
                calcQtyn = newQtyn;
                calcQty1 = newQty1;
              else;
                calcQty1 = 0;
                if calcQtyn < 0;
                  calcQtyn=%abs(calcQtyn);
                  calcQty1=0;
                else;
                  calcQtyn=0;
                  calcQty1=0;
                endif;
730bA         endif;

750eA         // When coming from OR610 it will use the greater of the current replen
750eA         // quantity in prplfil or the allocation qty from or610.  The reason for
750eA         // this is when order qty replen procedure generates replenishment for
750eA         // 2 cases and OR610 comes through with 1 each we keep the 2 cases.
750eA         if $pprogram='OR610';
750eA           if $itumq2 <> 0;
750eA             if ((curRpln*$itumq2) + curRpl1) >
750eA                ((calcQtyn*$itumq2) + calcQty1) and
750hA                 ((curRpln*$itumq2) + curRpl1) >
750hA                 ((dmdQtyn*$itumq2) + dmdQty1);
750eA               calcQty1 = ((curRpln*$itumq2) + curRpl1);
750eA               calcQtyn = 0;
750eA             endif;
750eA           else;
750hd             //if curRpln > calcQtyn;
750ha             if curRpln > calcQtyn and curRpln > dmdQtyn;
750eA               calcQtyn = curRpln;
750eA               calcQty1 = 0;
750eA             endif;
750eA           endif;
750eA           // rollup current replenishment quantities
750eA           newQtyn=calcQtyn;
750eA           newQty1=calcQty1;
750eA           exsr zzupQty;
750eA           calcQtyn = newQtyn;
750eA           calcQty1 = newQty1;
750eA         endif;

730bA         // if either case or breakdown quantity is negative
730bA         // call CRTDDFIX with absolute value to generate
730bA         // or update replenishment
730bA         if calcQty1 > 0;
750eA           // make sure to mark as breakdown
750eA           prtype='E';
730bA           newQty1 = %abs(calcQty1);
730bA           $prqtyn = newQty1;
730bA           homeempqty = newQty1;
730bA           qtyneeded = newQty1;
730bA           savqtyneeded = newQty1;
730bA           $brkqty = newQty1;
730bA           exsr crtddfix;
730bA         endif;
730bA         if calcQtyn > 0;
750eA           // if quantities rolled to a case(s) then blank each type.  May
750eA           // have come into DRIPRTYRPL as number of eaches and was rolled up
750eA           prtype=' ';
730bA           newQtyn = %abs(calcQtyn);
730bA           $prqtyn = newQtyn;
730bA           homeempqty = newQtyn;
730bA           qtyneeded = newQtyn;
730bA           savqtyneeded = newQtyn;
730bA           $brkQty = 0;
730bA           exsr crtddfix;
730bA         endif;
730bA
730bA /end-free
730bAC                   endsr
730bAc
730bA*----------------------------------------------------------------
730bA*  crtddfix  Create replenishment for Drop Picks
730bA*----------------------------------------------------------------
730bA
730bAC     crtddfix      begsr
730bAC                   eval      addrplflag = *off
730bAC                   eval      foundpslot = *off
730bA
730bA /free
730bA     // locate and establish *DROP slot if one already assigned
730bA     exec sql select * into :slrec2
730bA              from slot
730bA            where slwhse=:$prwhse and slwhdp=:$prwhdp
730bA              and slitem=:$pritem and sldesg='*DROP'
740 M              and slstat='DP'
730bA            fetch first row only;
730bA     if sqlstt = sqlSuccess;
730bA        prdTslot = s_sldisp;
730bA        rpkwhdp  = $prwhdp;
730bA        prdTail  = s_slaisl;
730bA        prdTlvl  = s_slrlvl;
730bA        prdThnd  = s_slhand;
730bA        prdTloc  = s_slloc;
730bA     else;
730bA        prdTslot = '*DDSLOT';
730bA        rpkwhdp  = $prwhdp;
730bA        prdTail  = *blanks;
730bA        prdTlvl  = *zeros;
730bA        prdThnd  = *blanks;
730bA        prdTloc  = *zeros;
730bA     endif;
730bA /end-free
730bA
730bA*   Loop through overflow slots for requested item being pulled
730bA
730bAC                   eval      kyitem = $pritem
730bAC                   eval      #bitem = $pritem
730bAC                   eval      kystat = 'A '
730bAC                   eval      kypick = 'N'
730bAC     keys3         setll     slot3
730bAC                   dow       forever = forever
730bAC     keys3         reade     slot3                                7879
730bA
730bA*  Item does not have a pick slot, replenish from overflow slots.
730bA
730bAC                   if        *in79
730bA*  if no stock then return such message
730bAC                   if        not foundpslot
730bAC                   eval      error = *on
730bAC                   eval      $preturn  = 'NOFULLCASE'
730bAC                   exsr      getmsg
730bAC                   exsr      writelog
750dDC*                  leave
730bAC                   endif
750dAC                   leave
730bAC                   endif
730bA
730bA*     If record is locked, try to get next one.
730bA
730bAC                   if        *in78
730bAC                   iter
730bAC                   endif
740 A
740 A*     Confirm this overflow is valid for Drop Pick Config
750eA*     Send blank tp ptrntype because this is not LT107 and
750eA*     this sends one item at time.  LT107 can get in loop
750eA*     picking up items and needs to consider all for specific
750eA*     slot display to suggest correct one next
740 A
740 Ac                   eval      ddwhse=slwhse
740 Ac                   eval      ddloc=slloc
740 Ac                   call      'GETDDSLOT'
740 Ac                   parm                    ddwhse            3 0
740 Ac                   parm                    $prwhdp
740 Ac                   parm                    $pritem
740 Ac                   parm                    sldisp
740 Ac                   parm                    slaisl
740 Ac                   parm                    ddloc             3 0
740 Ac                   parm      *blanks       s_sldisp         12
740 Ac                   parm      *blanks       s_slaisl          3
740 Ac                   parm      *zeros        s_slloc           3 0
740 Ac                   parm      *zeros        s_slrlvl          2 0
740 Ac                   parm      *blanks       s_slhand          2
750eAc                   parm      qtyneeded     pddqty1           3 0
750eAc                   parm      ' '           pddtype           1
750eAc                   parm      '   '         ptrntype          3
740 Ac                   parm      *blanks       pReturn          10
740 Ac                   if        pReturn <> '*OK'
740 Ac                   iter
740 Ac                   endif
730bA
730bA
730bA*     Ignore *EACH slots
730bA
730bA /free
730bA       chain (slwhse: slsdef) slotdef;
730bA       if %found(slotdef) and sdpal = '*EACH';
730bA         iter;
730bA       endif;
730bA /end-free
730bA
730bA*     Ignore slot if past expiration date.
730bA*     No longer exclude pick slot because zero quantity
730bA
730bAC                   if        $itflgd = 'Y'  and
730bAC                             slexpd <> *zeros  and
730bAC                             slexpd < today
730bAC                   iter
730bAC                   endif
730bA
730bA*  remove from replen calc since it is already available and the
730bAc                   if        qtyneeded <= 0
730bAc                   leave
730bAc                   endif
650bA
750bA*  do not use BF designation special slots to replenish from
750bAc                   if        sldesg = 'BFC'
750bAc                   iter
750bAc                   endif
730bA
730bA*     Calculate quantity to pick.
730bA
730bAC                   eval      topick = qtyneeded
740eA /free
740eA                    exsr calcqtys;
740eA       // Make sure replenishment generated for no more
740eA       // than available
740eA                    if $brkQty <> 0;
740eA                       // dealing with breakdown replenishment
740eA                       if topick > ((slavl1*$itumq2) + slavl2);
740eA                         topick =  ((slavl1*$itumq2) + slavl2);
740eA                       endif;
740eA                    else;
740eA                       // dealing with cases quantity
740eA                       if topick > slavl1;
740eA                         topick = slavl1;
740eA                       endif;
740eA                    endif;
740eA
740eA          // if nothing available then skip
740eA                    if topick <= *zeros;
740eA                      iter;
740eA                    endif;
740eA /end-free
730bA
730bA*     Found a usable pick slot.
730bA
730bAC                   eval      foundpslot = *on
750eAc                   exsr      calcMaxCube
730bA
730bA*     See if existing replenishment record can be updated.
730bA
730bAC                   exsr      updprtyrplp
730bAC                   if        updflag = *on
730bAC                   eval      addrplflag = *on
730bAC                   endif
730bA
730bA*     Create priority replenishment.
730bA
730bAC                   if        updflag = *off
730bAC                   eval      $slwhse = slwhse
730bAC                   eval      $slwhdp = slwhdp
730bAC                   exsr      addprtyrplp
730bAC                   eval      addrplflag = *on
730bAC                   endif
730bA
730bA*     Reduce empty and needed quantities.
730bA
730bAC                   eval      homeempqty = homeempqty - topick
730bAC                   eval      qtyneeded  = qtyneeded - topick
730bA
730bA*     If we got what we needed, get out.
730bA
730bAC                   if        qtyneeded <= 0
730bAC                             or $preturn = 'NOOVERFLOW'
730bAC                   leave
730bAC                   endif
730bA
730bA*     If we are not trying to fill need and slot is full, get out.
730bA
730bAC                   if        not $prfillu or $prfill <> 'Y'
730bAC                   if        homeempqty <= 0
730bAC                   leave
730bAC                   endif
730bAC                   endif
730bA
730bA*     Otherwise, we loop around and try for another replenishment.
730bA
730bAC                   enddo
730bA
730bA*  Throw error if a replenishment was not created.
730bA
730bAC                   if        not addrplflag
730bAC                   eval      error = *on
730bAC                   IF        $brkqty <> 0
730bAC                   eval      $preturn  = 'NOPICKFBRK'
730bAc                   else
730bAC                   eval      $preturn  = 'NOFULLCASE'
730bAc                   endif
730bAC                   exsr      getmsg
730bAC                   exsr      writelog
730bAC                   endif
730bA
730bAC     endcreatedd   endsr
510aA*----------------------------------------------------------------
510aA*  crtrpkfix  Create replenishment for repack item where base
510aA*             item is in Fixed section.
510aA*----------------------------------------------------------------

510aAC     crtrpkfix     begsr
510aAC                   eval      addrplflag = *off
510aAC                   eval      foundpslot = *off
510aAC                   eval      homeempqty  = $prqtyn
510aAC                   eval      qtyneeded   = $prqtyn
510bAC                   eval      savqtyneeded  = $prqtyn

510aAC                   exsr      calcovrflw2
510aAC                   select
650gMC*                  when      parentqty1 >= $prqtyn
650gMC                   when      (parentqty1-slavl1) >= $prqtyn
510aAC                   goto      pickfer
650gAC*                  when      parentqty2 >= $prqtyn
650gAC                   when      $itumq2<>0 and parentqty2<>0
650gAC                   if        (parentqty2/$itumq2) >= $prqtyn
510aAC                   goto      pickfer
510aAC                   endif
510aAC                   endsl
720fAc                   if        slavl1 > 0
650gAc                   eval      qtyneeded -= slavl1
720fAc                   endif

510aA*   Loop through parent picking slot.

510aAC                   eval      kyitem = $pritem
510aAC                   eval      #bitem = $pritem
510aAC                   eval      rpkpslot = *blanks
510aAC                   eval      rpkwhdp = *blanks
510aAC                   eval      kystat = 'A '
510aAC                   eval      kypick = 'Y'
510aAC     keys3         setll     slot3
510aAC                   dow       forever = forever
510aAC     keys3         reade     slot3                                7879

510aA*  Item does not have a pick slot, replenish from overflow slots.

640dDC**                 if        *in79 and not foundpslot
640dMC                   if        *in79
640dAC                   if        not foundpslot
650bDC*                  exsr      calcovrflw
650bAC                   exsr      crtrpkovr
640dAC                   endif
510aAC                   leave
510aAC                   endif

510aA*     If record is locked, try to get next one.

510aAC                   if        *in78
510aAC                   iter
510aAC                   endif

     *     Ignore slot if past expiration date.
     *     No longer exclude pick slot because zero quantity

650bDC*                  if        slstk1 <= *zeros or
650bDC*                            $itflgd = 'Y'     and
650bMC                   if        $itflgd = 'Y'  and
510aAC                             slexpd <> *zeros  and
510aAC                             slexpd < today
510aAC                   iter
510aAC                   endif

510aA*     Ignore slot if nothing available in slot.
650bA*     No longer exclude because of zero available

510aAC                   exsr      calcqtys
650bDC*                  if        slavl1 <= *zeros
650bDC*                  iter
650bDC*                  endif

650lDC*                  if        slrsrv = 'V'
650lAC                   if        slrsrv = 'V'
650laC                              AND %subst(rpkslot:1:3) <> 'RPK'
650gA *  remove from replen calc since it is already available and the
650gA *  replenishment request is for the full need quantity
650lA *  For Work Order replenishments this code should be skipped.
650lA *  The check for rpkslot <> RPK will catch these.  For ODR
650lA *  items it will reduce the qtyneeded by available since
650lA *  those goods can go against the need.
650gAc                   eval      qtyneeded = qtyneeded - slavl1
650lAc                   if        qtyneeded < 0
650lAc                   eval      qtyneeded = 0
650gAc                   endif
650gAC                   iter
650gAC                   endif

650gA*  remove from replen calc since it is already available and the
650gAc                   if        qtyneeded <= 0
650gAc                   leave
650gAc                   endif

510aA*     Found a usable pick slot.

510aAC                   eval      foundpslot = *on
510aAC                   eval      rpkpslot = sldisp
510aAC                   eval      rpkwhdp  = slwhdp
610aAC                   eval      rpkpail  = slaisl
610aAC                   eval      rpkplvl  = slrlvl
610aAC                   eval      rpkphnd  = slhand
610aAC                   eval      rpkploc  = slloc

510aA*     Calculate quantity to pick.

510aAC                   eval      topick = qtyneeded

510aA*     Make sure pick quantity isn't greater than available quantity.
650bA*     remove this check to allow for larger replenishment
650bA*     to allow user to do Specific slot replenishment or repack
650bA*     Work Orders where pick slot has too little stock

650bDC*                  if        topick > slavl1
650bDC*                  eval      topick = slavl1
650bDC*                  endif

510aA*     See if existing replenishment record can be updated.

510aAC                   exsr      updprtyrplr
510aAC                   if        updflag = *on
510aAC                   eval      addrplflag = *on
510aAC                   endif

510aA*     Create priority replenishment.

510aAC                   if        updflag = *off
510aAC                   eval      $slwhse = slwhse
510aAC                   eval      $slwhdp = slwhdp
510aAC                   exsr      addprtyrplr
510aAC                   eval      addrplflag = *on
510aAC                   endif

510aA*     Reduce empty and needed quantities.

510aAC                   eval      homeempqty = homeempqty - topick
510aAC                   eval      qtyneeded  = qtyneeded - topick

610aAC                   if        qtyneeded > 0
610aAC                   exsr      crtnorm2
610aAC                   endif

510aA*     If we got what we needed, get out.

510aAC                   if        qtyneeded <= 0
510aAC                             or $preturn = 'NOOVERFLOW'
510aAC                   leave
510aAC                   endif

510aA*     If we are not trying to fill need and slot is full, get out.

510aAC                   if        not $prfillu or $prfill <> 'Y'
510aAC                   if        homeempqty <= 0
510aAC                   leave
510aAC                   endif
510aAC                   endif

510aA*     Otherwise, we loop around and try for another replenishment.

510aAC                   enddo

510aA*  Throw error if a replenishment was not created.

510aAC                   if        not addrplflag
510aAC                   eval      error = *on
510aAC                   eval      $preturn  = 'NOFULLCASE'
510aAC                   exsr      getmsg
510aAC                   exsr      writelog
510aAC                   endif

510aAC     pickfer       endsr

650bA*----------------------------------------------------------------
650bA*  crtrpkovr  Create replenishment for repack item from overflow
650bA*             slot for work order calls
510aA*----------------------------------------------------------------
650bA
650bAC     crtrpkovr     begsr
650bA
650bA*   Loop through parent overflow slots
650bA
650bAc                   eval      first_overflow = ' '
650bAc                   eval      frst_ovrflow_f = ' '
650bAC                   eval      kyitem = $pritem
650bAC                   eval      #bitem = $pritem
650bAC                   eval      rpkpslot = *blanks
650bAC                   eval      rpkwhdp = *blanks
650bAC                   eval      kystat = 'A '
650bAC                   eval      kypick = 'N'
650bAC     keys3         setll     slot3
650bAC                   dow       forever = forever
650bAC     keys3         reade     slot3                                7879
650bAC                   if        *in79 = '1'
650bAc                   leave
650bAc                   endif
650bA
650bA*     overflow slot was found and not locked
650bA
650cAC                   if        not *in79
650cAc                              and not *in78
650bA
650bA*     Ignore slot if past expiration date.
650bA*     No longer exclude pick slot because zero quantity
650bA
650bMC                   if        $itflgd = 'Y'  and
650bAC                             slexpd <> *zeros  and
650bAC                             slexpd < today
650bAC                   iter
650bAC                   endif
650bA
650gAc                   if        sldesg = 'BFC'
650gAc                   iter
650gAc                   endif
740bA
740bA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740bA
740bA /free
740bA    monitor;
740bA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740bA      if wwrtn = '*YES';
740bA        iter;
740bA      endif;
740bA    on-error;
740bA    endmon;
740bA /end-free
740bA
650gA
510aAC                   exsr      calcqtys
650bA
650bA*     overflow slot was found and not locked
650bA
650gAC                   if        slavl1 <= 0
650gAc                   iter
650gAc                   endif
650bA
650bA*     save first overflow slot with any quantity
650bA
650bAc                   if        first_overflow = ' '
650bAc                   eval      first_overflow = sldisp
650bAC                   eval      rpkpslot = sldisp
650bAC                   eval      rpkwhdp  = slwhdp
650bAC                   eval      rpkpail  = slaisl
650bAC                   eval      rpkplvl  = slrlvl
650bAC                   eval      rpkphnd  = slhand
650bAC                   eval      rpkploc  = slloc
650bAc                   eval      topick = qtyneeded
650bAc                   endif
650bA
650bA*     save first overflow slot with enough qty to fulfill work order
650bA
650bAc                   if        frst_ovrflow_f = ' '
650bAc                              and slavl1 >= qtyneeded
650bAc                   eval      frst_ovrflow_f = sldisp
650bAC                   eval      rpkpslot = sldisp
650bAC                   eval      rpkwhdp  = slwhdp
650bAc                   eval      rpkpail  = slaisl
650bAC                   eval      rpkplvl  = slrlvl
650bAC                   eval      rpkphnd  = slhand
650bAC                   eval      rpkploc  = slloc
650bAc                   eval      topick = qtyneeded
650bAc                   leave
650bAc                   endif
650bA
650bA*     get next overflow slot to review
650bA
650bAc                   endif
650bAC                   enddo
650bA
650bA*     If a slot was found with quantity continue
650bA
650gAc                   if        first_overflow<>' '
650gAc                              or frst_ovrflow_f<>' '

650bA*     See if existing replenishment record can be updated.
650bA
650bAC                   exsr      updprtyrplr
650bAC                   if        updflag = *on
650bAC                   eval      addrplflag = *on
650bAC                   endif
650bA
650bA*     Create priority replenishment.
650bA
650bAC                   if        updflag = *off
650bAC                   eval      $slwhse = slwhse
650bAC                   eval      $slwhdp = slwhdp
650hAc                   if        $psubcmd = '*CRTRPLODR'
650bAC                   exsr      addprtyrpld
650hAc                   else
650bAC                   exsr      addprtyrplr
650hAc                   endif
650bAC                   eval      addrplflag = *on
650bAC                   endif

650gAc                   endif
650bA
650bA*  Throw error if a replenishment was not created.
650bA
650bAC                   if        not addrplflag
650bAC                   eval      error = *on
650bAC                   eval      $preturn  = 'NOFULLCASE'
650bAC                   exsr      getmsg
650bAC                   exsr      writelog
650bAC                   endif
650bA
650bAC                   endsr

610bA*----------------------------------------------------------------
610bA*  crtodrfix  Create replenishment for odr item where base
610bA*             item is in Fixed section.
610bA*----------------------------------------------------------------

610bAC     crtodrfix     begsr
610bAC                   eval      addrplflag = *off
610bAC                   eval      foundpslot = *off
610bAC                   eval      homeempqty  = $prqtyn
610bAC                   eval      qtyneeded   = $prqtyn
610bAC                   eval      savqtyneeded  = $prqtyn

610bA*   Loop through parent picking slot.

610bAC                   eval      kyitem = $pritem
610bAC                   eval      #bitem = $pritem
610bAC                   eval      rpkpslot = *blanks
610bAC                   eval      rpkwhdp = *blanks
610bAC                   eval      kystat = 'A '
610bAC                   eval      kypick = 'Y'
610bAC     keys3         setll     slot3
610bAC                   dow       forever = forever
610bAC     keys3         reade     slot3                                7879

610bA*  Item does not have a pick slot, replenish from overflow slots.

640dDC**                 if        *in79 and not foundpslot
640dMC                   if        *in79
640dAC                   if        not foundpslot
650gMC*                  exsr      calcovrflw
650gAC                   exsr      crtrpkovr
640dAC                   endif
610bAC                   leave
610bAC                   endif

610bA*     If record is locked, try to get next one.

610bAC                   if        *in78
610bAC                   iter
610bAC                   endif

     *     Ignore slot if past expiration date.

610bAC                   if        slstk1 <= *zeros  or
610bAC                             $itflgd = 'Y'     and
610bAC                             slexpd <> *zeros  and
610bAC                             slexpd < today
610bAC                   iter
610bAC                   endif

610bA*     Ignore slot if nothing available in slot.

610bAC                   exsr      calcqtys
610bAC*                  if        slavl1 <= *zeros
650hAC                   if        slavl1 <= qtyneeded
610bAC                   iter
610bAC                   endif

610bA*     Found a usable pick slot.

610bAC                   eval      foundpslot = *on
610bAC                   eval      rpkpslot = sldisp
610bAC                   eval      rpkwhdp  = slwhdp
610bAC                   eval      rpkpail  = slaisl
610bAC                   eval      rpkplvl  = slrlvl
610bAC                   eval      rpkphnd  = slhand
610bAC                   eval      rpkploc  = slloc

610bA*     Calculate quantity to pick.

610bAC                   eval      topick = qtyneeded

610bA*     Make sure pick quantity isn't greater than available quantity.

610bAC                   if        topick > slavl1
610bAC                   eval      topick = slavl1
610bAC                   endif

610bA*     See if existing replenishment record can be updated.

610bAC                   exsr      updprtyrplr
610bAC                   if        updflag = *on
610bAC                   eval      addrplflag = *on
610bAC                   endif

610bA*     Create priority replenishment.

610bAC                   if        updflag = *off
610bAC                   eval      $slwhse = slwhse
610bAC                   eval      $slwhdp = slwhdp
610bAC                   exsr      addprtyrpld
610bAC                   eval      addrplflag = *on
610bAC                   endif

610bA*     Reduce empty and needed quantities.

610bAC                   eval      homeempqty = homeempqty - topick
610bAC                   eval      qtyneeded  = qtyneeded - topick

610bAC                   if        qtyneeded > 0
610bAC                   exsr      crtnorm2
610bAC                   endif

610bA*     If we got what we needed, get out.

610bAC                   if        qtyneeded <= 0
610bAC                             or $preturn = 'NOOVERFLOW'
610bAC                   leave
610bAC                   endif

610bA*     If we are not trying to fill need and slot is full, get out.

610bAC                   if        not $prfillu or $prfill <> 'Y'
610bAC                   if        homeempqty <= 0
610bAC                   leave
610bAC                   endif
610bAC                   endif

610bA*     Otherwise, we loop around and try for another replenishment.

510aAC                   enddo

510aA*  Throw error if a replenishment was not created.

510aAC                   if        not addrplflag
510aAC                   eval      error = *on
510aAC                   eval      $preturn  = 'NOFULLCASE'
510aAC                   exsr      getmsg
510aAC                   exsr      writelog
510aAC                   endif

510aAC                   endsr

     *----------------------------------------------------------------
     *  crtbrkpir  Create replenishment for brokencase item
     *              where base item is in PIR section.
     *----------------------------------------------------------------

     C     crtbrkpir     begsr
     C                   eval      addrplflag = *off

720 A*     If this is a Store Staging Replen and Overflow at the store covers the
720 A*     pick slot need then leave without doing anything
720 A
720 Ac                   if        $zdStgFlg = 'Y'
720 AC                   if        qtyneeded < (ovrCasesAvl*#bumq2)
720 AC                   leavesr
720 Ac                   else
720 Ac*     when store overflow is less than needed simply reduce the replenishment
720 Ac*     by what is in overflow and then zero in case it loops around because one
720 Ac*     slot cannot replen remaining need
720 Ac                   eval      qtyneeded = qtyneeded -
720 Ac                                          (ovrCasesAvl*#bumq2)
720 Ac                   eval      homeempqty = homeempqty -
720 Ac                                          (ovrCasesAvl*#bumq2)
720 Ac                   eval      ovrCasesAvl = *zeros
720 AC                   endif
720 Ac                   endif

     *   Loop through picking slots for item.

     C                   eval      kyitem = #bitem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879
 2B
 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif
 2B
 2B  C                   if        *in78
TPC A*
TPC A*     Skip slots for TPC that are in "cone house".
TPC AC                             or client = TPC
TPC AC                             and slwhdp = 'DRY'
TPCaMC                             and (slaisl >= ' 60'
TPCaAC                             and  slaisl <= ' 69'
TPCcDC**                           or   slaisl >= ' 77'
TPCcMC                             or   slaisl >= ' 81'
TPCeAC                             and  slaisl <= ' 89'
TPCeAC                             or   slaisl >= ' 91'
TPCbAC                             and  slaisl <= ' 94'
TPCbAC                             or   slaisl >= ' 97'
TPCaMC                             and  slaisl <= ' 99')
TPC A*
 1L  C                   iter
 2E  C                   endif
600cA
600cA*     Ignore some special license tracking slots.
600cA
600dAC                   if        sldesg = 'BFC'
600cAC                   iter
600cAC                   endif
DRYcA*     Ignore slots in other facility (slaisl > '099')
DRYcMC*                  if        client = dairyland and
DRYcMC*                            slwhse = 001 and
DRYcMC*                            slaisl > '099'
DRYcMC*                  iter
DRYcMC*                  endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Save slot information and available quantities.

     C                   eval      kyprty = slprty
     C                   eval      kyexpd = slexpd
     C                   eval      kyentd = slentd
     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

     *     Loop through slots with same priority and dates.
     *     We want the slot with the least quantity available.

 2B  C                   dou       forever <> forever
     C     keys3b        reade     slot3                                  76
 3B  C                   if        *in76
 2L  C                   leave
 3E  C                   endif

     *        Ignore slot if past expiration date.

 3B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 2I  C                   iter
 3E  C                   endif

     *        Calculate quantity available in slot.

     C                   exsr      calcqtys
 3B  C                   if        slavl1 <= 0
 2I  C                   iter
 3E  C                   endif

     *        If this slot has the least qty available then
     *        save slot information and available quantities.

 3B  C                   if        slavl1 <= svavl1

     C                   eval      kywhdp = slwhdp
     C                   eval      kystyp = slstyp
     C                   eval      kyaisl = slaisl
     C                   eval      kypseq = slpseq
     C                   eval      kyrlvl = slrlvl
     C                   eval      kyhand = slhand

     C                   eval      svavl1 = slavl1

 3E  C                   endif

 2E  C                   enddo

     *     Get the selected slot.

     C     keys3c        chain     slot3                              76
 2B  C                   if        *in76
 1I  C                   iter
 2E  C                   endif

     *     Ignore slot if past expiration date.

 2B  C                   if        slstk1 <= 0  or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0  and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity available in slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Calculate quantity to pick.

 2B  C                   select

     *       When filling to needed qty and that qty is > home empty qty
     *         Then calculate qty to pick based on needed qty.

 2B  C                   when      $prfillu and $prfill = 'Y' and
 2B  C                             qtyneeded > homeempqty
     C                   eval      topick = (qtyneeded / #bumq2)
     C                   if        topick * #bumq2 < qtyneeded
     C                   eval      topick = topick + 1
     C                   endif

     *       Otherwise, calculate qty to pick based on home empty qty.

 2B  C                   other
     C                   eval      topick = (homeempqty / #bumq2)
     C                   if        topick * #bumq2 < homeempqty
     C                   eval      topick = topick + 1
     C                   endif

     C                   endsl

     *     Make sure pick quantity isn't greater than available quantity.

     C                   if        topick > slavl1
     C                   eval      topick = slavl1
     C                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - (topick*#bumq2)
     C                   eval      qtyneeded  = qtyneeded - (topick*#bumq2)

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOFULLCASE'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     pickpe        endsr

     *----------------------------------------------------------------
     *  crtnorm  Create replenishment for Normal item.
     *----------------------------------------------------------------

     C     crtnorm       begsr
     C                   eval      addrplflag = *off

     *  Loop through replenishment slots for item.

     C                   eval      kyitem = $ititem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879

 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif

 2B  C                   if        *in78
TPC A*
TPC A*     Skip slots for TPC that are in "cone house".
TPC AC                             or client = TPC
TPC AC                             and slwhdp = 'DRY'
TPCaMC                             and (slaisl >= ' 60'
TPCaAC                             and  slaisl <= ' 69'
TPCcDC**                           or   slaisl >= ' 77'
TPCcMC                             or   slaisl >= ' 81'
TPCeAC                             and  slaisl <= ' 89'
TPCeAC                             or   slaisl >= ' 91'
TPCbAC                             and  slaisl <= ' 94'
TPCbAC                             or   slaisl >= ' 97'
TPCaMC                             and  slaisl <= ' 99')
TPC A*
 1L  C                   iter
 2E  C                   endif
720 A
720 A*     Do not allow ANY replenishment to use overflow slots defined
720 A*     in Store locations
720 A
720 AC                   if        sldisp = $zdstrovf1
720 AC                               or sldisp = $zdstrovf2
720 AC                               or sldisp = $zdstrovf3
720 AC                   iter
720 AC                   endif
720 A
720 AC                   if        sldisp=$zdstrbpck or sldisp=$zdstrcpck
720 AC                   iter
720 AC                   endif
720 A
720 A*     If Staging Replenishment then verify no other Store Slot
720 A
720 A /free
720 A                    if opsslcn='Y';
720 A                      chain (slwhse:slwhdp:sldisp) slotstr;
720 A                      if %found(slotStr);
720 A                        iter;
720 A                      endif;
720 A                    endif;
720 A /end-free
600cA
600cA*     Ignore some special license tracking slots.
600cA
600dAC                   if        sldesg = 'BFC'
720cAc                              or slaisl='RPA'
600cAC                   iter
600cAC                   endif
MQScA
MQScA *     Ignore MTF slots at Marques
MQScA
MQScAC                   if        client = marques and slaisl='MTF'
MQScAC                   iter
MQScAC                   endif
MQScA
DRYaA*     Ignore slots in other facility (slloc< 99).
DRYcMC*                  if        client = dairyland and
DRYcMC*                            slwhse = 001 and
DRYcMC*                            slaisl > '099'
DRYcMC*                  iter
DRYcMC*                  endif
DRYhA*     Ignore slots in Chefs OSS aisles
DRYhAC                   if        client = dairyland
DRYhAC                   if        slwhse = 55
DRYhAC                             and (slaisl >= '030' and slaisl <= '050')
DRYhAC                   iter
DRYhAC                   endif
DRYhAC                   endif
ICBaA*
ICBaA*     Ignore slots in other facility (slaisl > '099')
ICBaMC                   select
ICBaMC                   when      client = icb
ICBaMC                   if        slaisl = '  G'
ICBaMC                             or slaisl = '  H'
ICBaMC                             or slaisl = '  I'
ICBaMC                             or slaisl = '  N'
ICBaMC                             or slaisl = '  P'
ICBaMC                             or slaisl = '  R'
ICBaMC                             or slaisl = '  T'
ICBaMC                   iter
ICBaMC                   endif
ICBaMC                   endsl
740aA
740aA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740aA
740aA /free
740aA    monitor;
740aA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740aA      if wwrtn = '*YES';
740aA        iter;
740aA      endif;
740aA    on-error;
740aA    endmon;
740aA /end-free
740aA

     *     Ignore slot if no normal stock or past expiration date.

 2B  C                   if        slstk1 <= 0   or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0   and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     If nothing available then go to next slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

750gA *     if this overflow is already represented in the file
750gA *     and it would clear the slot then skip this overflow
750gA /free
750iA       if multpick;
750gA       replencnt=0;
750gA       exec sql select count(*) into :replencnt
750gA                  from prplfil11
750gA             where prwhse=:slwhse and prwhdp=:slwhdp and
750gA                   prfdis=:sldisp and prfree='Y';
750gA       if sqlstt='00000' and replencnt>0;
750gA         iter;
750gA       endif;
750iA       endif;
750gA /end-free

     *     Get tie/high info

     C                   eval      kysdef = slsdef
     C                   exsr      gettihi
     C                   eval      pallet = dspqty

     *     Grab one pallet or less.

MQSbAC                   if        client = Marques and $zdstgFlg='Y'
MQSbAc                             and qtyneeded<>*zeros
MQSbAc                   eval      topick=qtyneeded
MQSbA *     preserve topick quantity for Store Replen when Marques.  Logic was ran
MQSbA *     earlier in process to select case quantity vs. full pallet
MQSbAc                   else
 2B  C                   if        pallet > 0 and pallet <= slavl1
     C                   eval      topick = pallet
 2X  C                   else
     C                   eval      topick = slavl1
 2E  C                   endif
MQSbAC                   endif

     *     If we are not filling to needed quantity,
     *       Then make sure quantity will fit in slot.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
KHL A*
KHL MC                   if           (client = Kohlwholesale
MQSaAC                              or client = marques
SFP AC                              or client = Seashore
DRYfAC                              or client = Dairyland)
KHL AC                             and $psubcmd = '*RPLLVL'
KHL A*      Leave topick at available qty in from slot.
KHL AC                   else
KHL A*
 2B  C                   if        topick > homeempqty
     C                   eval      topick = homeempqty
 2E  C                   endif
KHL A*
KHL AC                   endif
KHL A*
 2E  C                   endif

720 A*     If this is a Store Staging Replen and Overflow at the store covers the
720 A*     pick slot need then leave without doing anything
720 A
720 Ac                   if        $zdStgFlg = 'Y'
720 AC                   if        qtyneeded < ovrCasesAvl
720 AC                   leave
720 Ac                   else
720 Ac*     when store overflow is less than needed simply reduce the replenishment
720 Ac*     by what is in overflow and then zero in case it loops around because one
720 Ac*     slot cannot replen remaining need
720 Ac                   eval      qtyneeded = qtyneeded - ovrCasesAvl
720 Ac                   eval      ovrCasesAvl = *zeros
720 AC                   endif
720 Ac                   endif
416cA
416cA*     See if existing replenishment record can be updated.
416cA
416cAC                   exsr      updprtyrpl
416cAC                   if        updflag = *on
416cAC                   eval      addrplflag = *on
416cAC                   endif

     *     Create priority replenishment.

416cAC                   if        updflag = *off
     C                   exsr      addprtyrpl
     C                   eval      addrplflag = *on
416cAC                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - topick
     C                   eval      qtyneeded  = qtyneeded - topick

BIRaAC                   if        client = birite
FDI AC                             or client = Finkle
MJK AC                             or client = MJKellner
CLD AC                             or client = CityLine
BIRa *     Available qty meets or exceeds qty needed
BIRa *     Get out of replenishment loop.
BIRa C                   eval      nwhomeavlqty = nwhomeavlqty + topick
BIRaAC                   if        nwhomeavlqty >= savqtyneeded
BIRa C                   eval      qtyneeded = 0
BIRaAC                   endif
BIRa *
BIRaAC                   endif
750gA *     If Multi Pick Slot item we should return to pick slot loop
750gA *     and determine if next pick slot should get a replenishment
750gAc                   if        multpick
750gAc                             and $prslot <> lastPickSlot
750gAc                   leave
750gAc                   endif
     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
500hAC                             and ($psubcmd <> '*CRTRPFSQ1' and
500hAC                                  $psubcmd <> '*CRTRPFSQ2' and
500hAC                                  $psubcmd <> '*CRTRPFSQ3' and
500hAC                                  $psubcmd <> '*CRTRPFSQ4' and
500hAC                                  $psubcmd <> '*CRTRPFSQ5' and
500hAC                                  $psubcmd <> '*CRTRPFSQ6' and
500hAC                                  $psubcmd <> '*CRTRPFSQ7' and
500hAC                                  $psubcmd <> '*CRTRPFSQ8' and
500hAC                                  $psubcmd <> '*CRTRPFSQ9')
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

     *     Otherwise, we loop around and try for another replenishment.

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 2B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOOVERFLOW'
     C                   exsr      getmsg
     C                   exsr      writelog
 2E  C                   endif

     C     endfix        endsr

610aA*----------------------------------------------------------------
610aA*  crtnorm2 Create replenishment for Normal item.
610aA*----------------------------------------------------------------

610aAC     crtnorm2      begsr
     C                   eval      addrplflag = *off

     *  Loop through replenishment slots for item.

     C                   eval      kyitem = $ititem
     C                   eval      kystat = 'A '
     C                   eval      kypick = 'N'
     C     keys3         setll     slot3
 1B  C                   dow       forever = forever
     C     keys3         reade     slot3                                7879

 2B  C                   if        *in79
 1L  C                   leave
 2E  C                   endif

 2B  C                   if        *in78
 1L  C                   iter
 2E  C                   endif

     *     Ignore some special license tracking slots.

 2B  C                   if        sldesg = 'BFC'
720cAc                              or slaisl='RPA'
 1L  C                   iter
 2E  C                   endif
740bA
740bA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740bA
740bA /free
740bA    monitor;
740bA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740bA      if wwrtn = '*YES';
740bA        iter;
740bA      endif;
740bA    on-error;
740bA    endmon;
740bA /end-free
740bA

     *     Ignore slot if no normal stock or past expiration date.

 2B  C                   if        slstk1 <= 0   or
     C                             $itflgd = 'Y' and
     C                             slexpd <> 0   and
     C                             slexpd < today
 1I  C                   iter
 2E  C                   endif

     *     If nothing available then go to next slot.

     C                   exsr      calcqtys
 2B  C                   if        slavl1 <= 0
 1I  C                   iter
 2E  C                   endif

     *     Get tie/high info

     C                   eval      kysdef = slsdef
     C                   exsr      gettihi
     C                   eval      pallet = dspqty

     *     Grab one pallet or less.

 2B  C                   if        pallet > 0 and pallet <= slavl1
     C                   eval      topick = pallet
 2X  C                   else
     C                   eval      topick = slavl1
 2E  C                   endif

     *     If we are not filling to needed quantity,
     *       Then make sure quantity will fit in slot.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        topick > homeempqty
     C                   eval      topick = homeempqty
 2E  C                   endif
 2E  C                   endif

     *     See if existing replenishment record can be updated.

     C                   exsr      updprtyrpl2
     C                   if        updflag = *on
     C                   eval      addrplflag = *on
     C                   endif

     *     Create priority replenishment.

     C                   if        updflag = *off
     C                   exsr      addprtyrpl2
     C                   eval      addrplflag = *on
     C                   endif

     *     Reduce empty and needed quantities.

     C                   eval      homeempqty = homeempqty - topick
     C                   eval      qtyneeded  = qtyneeded - topick

     *     If we got what we needed, get out.

 2B  C                   if        qtyneeded <= 0
 2B  C                   leave
 2B  C                   endif

     *     If we are not trying to fill need and slot is full, get out.

 2B  C                   if        not $prfillu or $prfill <> 'Y'
 2B  C                   if        homeempqty <= 0
 2B  C                   leave
 2B  C                   endif
 2B  C                   endif

     *     Otherwise, we loop around and try for another replenishment.

 1E  C                   enddo

     *  Throw error if a replenishment was not created.

 1B  C                   if        not addrplflag
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOOVERFLOW'
     C                   exsr      getmsg
     C                   exsr      writelog
 1E  C                   endif

     C     endfix2       endsr


650iA*----------------------------------------------------------------
650iA*  crtprdovr  Create replenishment for Production item from
650iA*             overflow slot
650iA*----------------------------------------------------------------
650iA
650iAC     crtprdovr     begsr
650iA
650iA*   Loop through parent overflow slots
650iA
650iAc                   eval      first_overflow = ' '
650iAc                   eval      frst_ovrflow_f = ' '
650iAC                   eval      kyitem = $pritem
650iAC                   eval      #bitem = $pritem
650iAC                   eval      rpkpslot = *blanks
650iAC                   eval      rpkwhdp = *blanks
730aDC*                  eval      kystat = 'A '
730aDC*                  eval      kypick = 'N'

730aA  //  Change to use SQL so we can look for both "A" status overflow slots
730aA  //  as well as PR status PAR slots when a component item
730aA  // Close Cursor
      /free
730aA  exec sql
730aA   close csrOvrStock;

730aA  // Retrieve existing normal overflow slots and PAR Production slots
730aA  // for given item

730aA  // Declare Cursor
730aA  exec sql
730aA    declare csrOvrStock cursor for
730aA    select a.*
730aA      from SLOT3 a inner join ITEMPRD
730aA        on slwhse = ipwhse
730aA       and slitem = ipitem
750 D     //where (slstat='A ' or slstat='PR')
750 D     //  and slpick='N' and ipPrdFlg='C'
750 M     where ((slstat='A ' or slpick='N') or
750 M           (ipPrdFlg='C' and slstat='PR'))
750 A           and slwhse=:$prwhse and slitem=:$pritem
730aA      order by slwhse,slitem,slstat;

730aA  // Open Cursor
730aA  exec sql
730aA   open csrOvrStock;

730aA  // Process Result Set
730aA  dow forever = forever;
730aA    clear dsSlot;
730aA    exec sql
730aA      fetch next from csrOvrStock into :dsSlot;

730aA    if sqlStt <> '00000';
730aA      leave;
730aA    endif;

      /end-free
730aDC*    keys3         setll     slot3
730aDC*                  dow       forever = forever
730aDC*    keys3         reade     slot3                                7879
730aDC*                  if        *in79 = '1'
730aDc*                  leave
730aDc*                  endif
650iA
650iA*     overflow slot was found and not locked
650iA
730aDC*                  if        not *in79
730aDc*                             and not *in78
650iA
650iA*     Ignore slot if past expiration date.
650iA*     No longer exclude pick slot because zero quantity
650iA
650iMC                   if        $itflgd = 'Y'  and
650iAC                             slexpd <> *zeros  and
650iAC                             slexpd < today
650iAC                   iter
650iAC                   endif
730aA
730aA      // If Production Module slot (status PR) ignore if either
730aA      // Component Production setting is off or it is not a PAR slot
730aA      // This process allows the customer to have system generate
730aA      // replenishments from PAR slot in say a component line to
730aA      // another Mfg Line LIN slot for some type assembly (FG or CMP)
730aA /free
730aA                    if (slstat='PR' and slaisl<>'PAR') or
730aA                       (slstat='PR' and opCmpRepln='N');
730aA                       iter;
730aA                    endif;
730aA /end-free
650iA
650iAc                   if        sldesg = 'BFC'
650iAc                   iter
650iAc                   endif
740bA
740bA*    Ignore warehouse-to-warehouse (GLOWWTFR) aisle/locations
740bA
740bA /free
740bA    monitor;
740bA      WWTFR('*CHKTFR': slaisl: slloc: slwhse: #user: wwrtn: wwmsg);
740bA      if wwrtn = '*YES';
740bA        iter;
740bA      endif;
740bA    on-error;
740bA    endmon;
740bA /end-free
740bA
650iA
650iAC                   exsr      calcqtys
650iA
650iA*     overflow slot was found and not locked
650iA
650iAC                   if        slavl1 <= 0
650iAc                   iter
650iAc                   endif
650iA
650iA*     save first overflow slot with any quantity
650iA
650iAc                   if        first_overflow = ' '
650iAc                   eval      first_overflow = sldisp
650iAC                   eval      rpkpslot = sldisp
650iAC                   eval      rpkwhdp  = slwhdp
650iAC                   eval      rpkpail  = slaisl
650iAC                   eval      rpkplvl  = slrlvl
650iAC                   eval      rpkphnd  = slhand
650iAC                   eval      rpkploc  = slloc
650iAc                   eval      topick = qtyneeded
650iAc                   endif
650iA
650iA*     save first overflow slot with enough qty to fulfill work order
650iA
650iAc                   if        frst_ovrflow_f = ' '
650iAc                              and slavl1 >= qtyneeded
650iAc                   eval      frst_ovrflow_f = sldisp
650iAC                   eval      rpkpslot = sldisp
650iAC                   eval      rpkwhdp  = slwhdp
650iAc                   eval      rpkpail  = slaisl
650iAC                   eval      rpkplvl  = slrlvl
650iAC                   eval      rpkphnd  = slhand
650iAC                   eval      rpkploc  = slloc
650iAc                   eval      topick = qtyneeded
650iAc                   leave
650iAc                   endif
650iA
650iA*     get next overflow slot to review
650iA
730aDc*                  endif
650iAC                   enddo

      /free
730aA  // Open Cursor
730aA  exec sql
730aA   open csrOvrStock;
      /end-free
650iA
650iA*     If a slot was found with quantity continue
650iA
650iAc                   if        first_overflow<>' '
650iAc                              or frst_ovrflow_f<>' '
650i
650iA*     See if existing replenishment record can be updated.
650iA
650iAC                   exsr      updprtyrplr
650iAC                   if        updflag = *on
650iAC                   eval      addrplflag = *on
650iAC                   endif
650iA
650iA*     Create priority replenishment.
650iA
650iAC                   if        updflag = *off
650iAC                   eval      $slwhse = slwhse
650iAC                   eval      $slwhdp = slwhdp
650iAC                   exsr      addprtyrplp
650iAC                   eval      addrplflag = *on
650iAC                   endif
650i
650iAc                   endif
650iA
650iA*  Throw error if a replenishment was not created.
650iA
650iAC                   if        not addrplflag
650iAC                   eval      error = *on
650iAC                   eval      $preturn  = 'NOFULLCASE'
650iAC                   exsr      getmsg
650iAC                   exsr      writelog
650iAC                   endif
650iA
650iAC                   endsr
     *----------------------------------------------------------------
     *  drislotsr   Fake call to DRISLOT.
     *----------------------------------------------------------------

     C     drislotsr     begsr
     C                   eval      $drireturn = '*OK'

     C* Get slot2 record

     C     keysl2        chain     slot2

     C                   if        not %found
     C                   eval      error = *on
     C                   eval      $drireturn = 'INVLDSLOT'
     C                   eval      $drimessage = 'Invalid slot '
     C                                         + '('
     C                                         + %Trim(%editc($slwhse:'Z'))
     C                                         + '/'
     C                                         + %trim($slwhdp)
     C                                         + '/'
     C                                         + %trim($sldisp)
     C                                         + ')'
     C                   goto      enddrislot
     C                   endif

     C                   exsr      calcqtys

     C* Move information to data structure.

     C                   eval      $slwhse = slwhse
     C                   eval      $slwhdp = slwhdp
     C                   eval      $sldisp = sldisp
     C                   eval      $slaisl = slaisl
     C                   eval      $slloc  = slloc
     C                   eval      $slrlvl = slrlvl
     C                   eval      $slhand = slhand
     C                   eval      $slside = slside
     C                   eval      $slstyp = slstyp
     C                   eval      $slstat = slstat
     C                   eval      $slsdte = slsdte
     C                   eval      $slstim = slstim
     C                   eval      $slsdef = slsdef
     C                   eval      $sldesg = sldesg
     C                   eval      $slactv = slactv
     C                   eval      $slbld  = slbld
     C                   eval      $slpick = slpick
     C                   eval      $slpseq = slpseq
     C                   eval      $slprty = slprty
     C                   eval      $slentd = slentd
     C                   eval      $slexpd = slexpd
     C                   eval      $slslfd = slslfd
     C                   eval      $slrsrv = slrsrv
     C                   eval      $slitem = slitem
     C                   eval      $slstk1 = slstk1
     C                   eval      $slstk2 = slstk2
     C                   eval      $slstk3 = slstk3
     C                   eval      $slalc1 = slalc1
     C                   eval      $slalc2 = slalc2
     C                   eval      $slalc3 = slalc3
     C                   eval      $sltfr1 = sltfr1
     C                   eval      $sltfr2 = sltfr2
     C                   eval      $sltfr3 = sltfr3
     C                   eval      $slpck1 = slpck1
     C                   eval      $slpck2 = slpck2
     C                   eval      $slpck3 = slpck3
     C                   eval      $slrcv1 = slrcv1
     C                   eval      $slrcv2 = slrcv2
     C                   eval      $slrcv3 = slrcv3
     C                   eval      $slphy1 = slphy1
     C                   eval      $slphy2 = slphy2
     C                   eval      $slphy3 = slphy3
     C                   eval      $slavl1 = slavl1
     C                   eval      $slavl2 = slavl2
     C                   eval      $slavl3 = slavl3
     C                   eval      $sladj1 = sladj1
     C                   eval      $sladj2 = sladj2
     C                   eval      $sladj3 = sladj3
710bA*
710bAC                   if            %subst($psubcmd:1:9) = '*CRTRPLSQ'
710bAC                             and %subst($psubcmd:10:1) >= '1'
710bAC                             and %subst($psubcmd:10:1) <= '9'
CWD AC                             and client <> CashWa
710bA*       When processing JIT replenishments, either at Pick/Print or
710bA*       Transaction check-out, the qty needed is already in the pick
710bA*       buckets, so it needs to be added back in to the physical qty
710bA*       and avail qty and adj qty, so it doesn't unnecessarily
710bA*       create replenishments when they aren't needed.
710bAC                   eval      $slphy1 = $slphy1 + $prqtyn
710bAC                   eval      $slavl1 = $slavl1 + $prqtyn
740gAC                   eval      $slavl1 = $slavl1 + slalc1
710bAC                   eval      $sladj1 = $sladj1 + $prqtyn
740gAC                   eval      $sladj1 = $sladj1 + slalc1
710bAC                   endif

     C     enddrislot    endsr

     *----------------------------------------------------------------
     *  getbase  Get base item information
     *----------------------------------------------------------------

     C     getbase       begsr

     *  Get base item information.

700fAC                   if        eachRpl
700fA
700fAC                   eval      #bitem = $ititem
700fAC                   eval      #bityp = $ittype
700fAC                   eval      #bdesc = $itdesc
700fAC                   eval      #bpdsc = $itpdsc
700fAC                   eval      #bwhdp = $itwhdp
700fAC                   eval      #bstyp = $itstyp
700fAC                   eval      #bum   = $itum1
700fAC                   eval      #bum2  = $itum2
700fAC                   eval      #bumq2 = $itumq2
700fAC                   eval      #bum3  = $itum3
700fAC                   eval      #bumq3 = $itumq3
700fAC                   eval      #bcitm = ''
700fAC                   eval      #bctyp = ''
700fAC                   eval      #bcdsc = ''
700fAC                   eval      #bcpds = ''
700fAC                   eval      #bcwdp = ''
700fAC                   eval      #bcstp = ''
700fAC                   eval      #bcum  = ''
700fAC                   eval      #bcum2 = ''
700fAC                   eval      #bcuq2 = 0
700fAC                   eval      #bcum3 = ''
700fAC                   eval      #bcuq3 = 0
700fAC                   eval      #brtn  = ''
700fA
700fAC                   else

     C                   call      'GETBASE'
     C                   parm      $itwhse       $gwhse            3 0
     C                   parm      $ititem       $gitem           15
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

700fAC                   endif

     *  See if base item was found.

     C                   if        #brtn = '*ERROR'
     C                   eval      error = *on
     C                   eval      $preturn  = 'BASENOTFND'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetbase
     C                   endif

     *  Make sure base item has a brokencase uom.

     C                   if        #bumq2 <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'UM2NOTDEF'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetbase
     C                   endif

     C     endgetbase    endsr

     *----------------------------------------------------------------
     *  getdatetime  Get current date & time
     *----------------------------------------------------------------

     C     getdatetime   begsr

     C                   time                    curtime

     C                   if        curtime < lasttime
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      curdate = $cvd8o
     C                   endif

     C                   eval      lasttime = curtime

     C                   endsr

     *----------------------------------------------------------------
     *  getitem  Get item info.
     *----------------------------------------------------------------

     C     getitem       begsr

     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   eval      $itver# = savever#

     C                   eval      $itwhse = $prwhse
     C                   eval      $ititem = item#

     C                   eval      driitem = *on
     C                   call(e)   'DRIITEM'
     C                   parm                    $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C     $item         parm      $item         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRIITEM'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   when      $drireturn <> '*OK' and
     C                             check4err = *on
     C                   eval      error = *on
     C                   eval      $priteme = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   goto      endgetitem
     C                   endsl

     C     endgetitem    endsr

720 A*----------------------------------------------------------------
720 A*  getStrZ  Get Store/Remote location such as Company Store
720 A*----------------------------------------------------------------
720 A
720 AC     getStrZ       begsr
720 Ac
720 AC                   eval      savever# = $zdver#
720 AC                   clear                   $zoned
720 AC                   eval      $zdver# = savever#
720 Ac
720 Ac                   eval      $zdStgFlg = 'N'
720 Ac                   if        opsslcn <> 'Y'
720 Ac                   goto      endstrz
720 Ac                   endif
720 A
720 Ac*  zdtsttruk can be complete name of specific Truck in Zoned or just a portion
720 Ac*  I am sending only ! which is first character since we do not have way to pass
720 Ac*  desired zones currently.  This will read in any definitions beginning with !
720 AC                   eval      $zdtsttruku = *on
720 AC                   eval      $zdtsttruk = '!'
720 AC                   eval      $zdwhseu = *on
720 AC                   eval      $zdwhse = $prwhse

720 Ac                   if        $prwhdp <> *blanks
720 Ac                   eval      $zdwhdpu = *on
720 Ac                   eval      $zdwhdp = $prwhdp
720 Ac                   else
720 Ac                   eval      $zdwhdpu = *on
720 Ac                   eval      $zdwhdp = $itwhdp
720 Ac                   endif
720 Ac
720 Ac*  By sending in either Case ITem , Breakdown Item or Case Pick Slot, Breakdown
720 Ac*  pick slot command STRZONE in DRIZONED returns both pick slots along with
720 Ac*  any overflow slots found in Store Zone and flag zdstgflg as "Y" for yes.  If not
720 Ac*  found in Store zone passed it returns all blanks with flag zdstgflg='N'
720 Ac                   select
720 Ac                   when      $prslot <> *blanks
720 Ac                   if        $ittype='B' or $ittype='S'
720 Ac                   eval      $zdstrbpcku = *on
720 Ac                   eval      $zdstrbpck = $prslot
720 Ac                   else
720 Ac                   eval      $zdstrcpcku = *on
720 Ac                   eval      $zdstrcpck = $prslot
720 Ac                   endif
720bAc**
720bAc**   If slot passed in then simply check SLOTSTR to see if Staging Replenishment
720bAC**   slot.  Otherwise call routine in DRIZONED to search Zone definition
720bAc                   if        $prslot <> *blanks
720bA /free
720bA              chain ($prwhse:$zdwhdp:$prslot) slotstr;
720bA /end-free
720bAc                   if        %found(slotstr)
720bAc                   eval      $zdStgFlg = 'Y'
720bAc                   goto      arndDriZ
720bAc                   endif
720bAc                   endif
720bAc*
720 Ac                   when      $pritem <> *blanks
720 Ac                   if        $ittype='B' or $ittype='S'
720 Ac                   eval      $zdstrcpcku = *off
720 Ac                   eval      $zdstrcpck = ' '
720 Ac                   eval      $zdstrbpcku = *on
720 Ac                   eval      $zdstrbpck = $prslot
720 Ac                   eval      $zdstrbitmu = *on
720 Ac                   eval      $zdstrbitm = $pritem
720 Ac                   eval      $zdstrcitmu = *off
720 Ac                   eval      $zdstrcitm = *blanks
720 Ac                   else
720 Ac                   eval      $zdstrcpcku = *on
720 Ac                   eval      $zdstrcpck = $prslot
720 Ac                   eval      $zdstrcitmu = *on
720 Ac                   eval      $zdstrcitm = $pritem
720 Ac                   eval      $zdstrbitmu = *off
720 Ac                   eval      $zdstrbitm = *blanks
720 Ac                   endif
720 Ac                   endsl
720 A
720 AC                   eval      drizoned = *on
720 Ac                   eval      $drisubcmd = '%STRZONE'
720 Ac
720 AC                   call(e)   'DRIZONED'
720 AC                   parm                    $drisubcmd
720 AC                   parm      $pprogram     $driprogram
720 AC                   parm      ' '           $drireturn
720 AC                   parm      ' '           $drimessage
720 AC     $zoned        parm      $zoned        $dridata
720 A
720 AC                   select
720 AC                   when      %error
720 AC                   eval      error = *on
720 AC                   eval      $preturn  = 'CALLERROR'
720 AC                   eval      $pmessage = 'Error occured on call to '
720 AC                                       + 'DRIZONED'
720 AC                                       + '/' + %trim($drisubcmd)
720 AC                                       + ' from ' + #prog
720 AC                   when      $drireturn <> '*OK' and
720 AC                             check4err = *on
720 AC                   eval      error = *on
720 AC                   eval      $preturn  = $drireturn
720 AC                   eval      $pmessage = $drimessage
720 AC                   goto      endstrz
720 AC                   endsl
720 Ac
720bAc     arndDriZ      tag
720 A*    Change to replenishment level for Store Replen
720 Ac                   if        $zdStgFlg = 'Y'
720 Ac                   eval      $pSubCmd = '*RPLLVL'
720 Ac                   endif
720 A
720 AC     endstrz       endsr

510aA*----------------------------------------------------------------
510aA*  getkitqty  Get kitord wo quantity
510aA*----------------------------------------------------------------

510aAC     getkitqty     begsr

510aA * get kitordh quantity

510aAC                   eval      hqty = *zeros
510aAC                   eval      pqty = *zeros
510aAC     keypr4        setll     kitordh3
510aAC                   dou       %eof(kitordh3)
510aAC     keypr4        reade     kitordh3
510aAC                   if        not %eof(kitordh3)
650hAC                   if        kohsta <> '4'
650hA /free
650hA          hqty = hqty + kohqty;
650hA          setll (kohwhs:kohord:kohitm) kitordd;
650hA          reade (kohwhs:kohord:kohitm) kitordd;
650hA          dow not %eof and %found;
510aA             hqty = hqty - kodqty;
650hA             reade (kohwhs:kohord:kohitm) kitordd;
650hA          enddo;
650ha          if hqty <= 0;
650ha             hqty = 0;
650ha          endif;
650hA /end-free
650hAC                   endif
510aAC                   endif
510aAC                   enddo

510aAC                   eval      pqty = hqty

510aAC                   endsr

     *----------------------------------------------------------------
     *  getmsg   Get message for error code.
     *----------------------------------------------------------------

     C     getmsg        begsr

     C                   select

     C                   when      $preturn = 'BASENOTFND'
     C                   eval      $pmessage = 'Parent item not found'

     C                   when      $preturn = 'FLDNOTSNT'
     C                   eval      $pmessage = 'Department and slot fields '
     C                                       + 'must be sent as a pair'

     C                   when      $preturn = 'FULLSLOT'
     C                   eval      $pmessage = 'Slot is full'

500bAC                   when      $preturn = 'LVLOK'
500bAC                   eval      $pmessage = 'Slot qty exceeds '
500bAC                                       + 'replenishment level'

500bAC                   when      $preturn = 'INVLDPCT'
500bAC                   eval      $pmessage = 'Invalid Avt pct '
500bAC                                       + '(' + %trim($cvstr) + ') '
500bAC                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'INVLDSBCMD'
     C                   eval      $pmessage = 'Invalid subcommand '
     C                                       + '(' + %trim($psubcmd) + ') '
     C                                       + 'sent to ' + %trim(#prog)

     C                   when      $preturn = 'ITMNOTSNT'
     C                   eval      $pmessage = 'Item must be sent'

     C                   when      $preturn = 'NEGATIVQTN'
     C                   eval      $pmessage = 'Quantity needed must be '
     C                                       + 'positive'

     C                   when      $preturn = 'NEGATIVQTW'
     C                   eval      $pmessage = 'Warehouse quantity must be '
     C                                       + 'positive'

     C                   when      $preturn = 'NOFULLCASE'
     C                   eval      $pmessage = 'No full cases available'

     C                   when      $preturn = 'NOLAYER'
     C                   eval      $pmessage = 'Empty space in slot is '
     C                                       + 'less than a single layer'
650iA
650iAC                   when      $preturn = 'QTYREQ '
650iAC                   eval      $pmessage = 'Replenishment requires '
650iAC                                       + 'either case or brkdwn qty'

     C                   when      $preturn = 'NOOVERFLOW'
     C                   eval      $pmessage = 'No overflow available'

     C                   when      $preturn = 'NOPICKSLOT'
     C                   eval      $pmessage = 'No pick slot with defined '
     C                                       + 'tie/high found for item '
     C                                       + %trim($pritem)
650iA
650iAC                   when      $preturn = 'NOPICKFBRK'
650iAC                   eval      $pmessage = 'Pick slot must exist for '
650iAC                                       + 'breakdown replenishment. '
650iAc                                       + %trim($pritem)

     C                   when      $preturn = 'NOTIEHIGH'
     C                   eval      $pmessage = 'Slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' does not have defined'
     C                                       + ' tie/high'

     C                   when      $preturn = 'NOTPICKSLT'
     C                   eval      $pmessage = 'Slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' not a pick slot'

     C                   when      $preturn = 'PIRNOTRSRV'
     C                   eval      $pmessage = 'PIR slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)
     C                                       + ' not reserved'

     C                   when      $preturn = 'QTYEXISTS'
     C                   eval      $pmessage = 'Qty needed ('
     C                                       + %Trim(%editc(qtyneeded:'J'))
     C                                       + ') is less than or equal to '
     C                                       + 'available ('
     C                                       + %Trim(%editc(homeavlqty:'J'))
     C                                       + ')'

     C                   when      $preturn = 'QTYNOTSNT'
     C                   eval      $pmessage = 'Quantity needed must be '
     C                                       + 'sent when slot is not sent'

     C                   when      $preturn = 'QTYNSENT'
     C                   eval      $pmessage = 'Quantity needed cannot be '
     C                                       + 'sent for *CRTRPLDKA'

500 AC                   when      $preturn = 'QTYNSENTO'
500 AC                   eval      $pmessage = 'Quantity needed cannot be '
500 AC                                       + 'sent for *CRTRPLDKO'

     C                   when      $preturn = 'QTYZERO'
     C                   eval      $pmessage = 'Qty needed is zero'

     C                   when      $preturn = 'REPLEXIST'
     C                   eval      $pmessage = 'Replenishment already '
     C                                       + 'exists for item '
     C                                       + %trim($pritem)

     C                   when      $preturn = 'UM2NOTDEF'
     C                   eval      $pmessage = 'Base item does not have '
     C                                       + 'breakdown 1 qty defined'

     C                   when      $preturn = 'WHSNOTSNT'
     C                   eval      $pmessage = 'Warehouse must be sent'

     C                   when      $preturn = 'WRONGITEM'
     C                   eval      $pmessage = 'Item ' + %trim($pritem)
     C                                       + ' not in slot '
     C                                       + %Trim(%editc($prwhse:'Z'))
     C                                       + '/'
     C                                       + %trim($prwhdp)
     C                                       + '/'
     C                                       + %trim($prslot)

     C                   when      $preturn = 'WRONGITYP'
     C                   eval      $pmessage = 'Item is not '
     C                                       + 'Fix Norm/Bkdn '
     C                                       + 'or PIR Bkdn '
     C                                       + '('
     C                                       + %trim($pritem)
     C                                       + '/' + $itstyp + '/' + $ittype
     C                                       + ')'

     C                   other
     C                   eval      $pmessage = %trim($preturn)
     C                                       + ': Unknown return code'

     C                   endsl

     C                   endsr

416aA*----------------------------------------------------------------
416aA*  getnxtseq   Get next sequence number.
416aA*
416aA*
416aA*
416aA*----------------------------------------------------------------
416aA
416aAC     getnxtseq     begsr

710aA /free
710aA     Chain(n) ($prwhse: pFileNm) pirrecid#;
710aA       If Not %Found(pirrecid#);
710aA         exec sql select max(prseq#) into :pMaxSq from prplfil;
710aA           If sqlstt <> sqlSuccess;
710aA             Eval pMaxSq = 0;
710aA           EndIf;
710aA          Eval NRIWHSE  = $prwhse;
710aA          Eval NRIFILE  = pFileNm;
710aA          Eval NRIRECID = pMaxSq;
710aA          Write NRIREC;
710aA       EndIf;
710aA /end-free

417bAC                   select

417bA*  When creating a positive sequence number.

417bAC                   when      $psubcmd = '*CRTRPLSEQ'
640aAC                             or $psubcmd = '*CRTRPLODR'
710cAC                             or $psubcmd = '*CRTPRDRPL'
710cAC                             or $psubcmd = '*CRTPRDQTY'

710aA /free

710aA     Chain ($prwhse: pFileNm) pirrecid#;
710aA       If %found(pirrecid#);
710aA         Eval pMaxSq = NRIRECID;
710aA         DoU not %Equal(prplfil1);
710aA           SetLL ($prwhse: $prwhdp: pMaxSq) prplfil1;
710aA             If %Equal;
710aA               pMaxSq = pMaxSq+ 1;
710aA             Else;
710aA               Leave;
710aA             EndIf;
710aA         EndDo;

710aA         If pMaxSq > 99998;
710aA            Eval pMaxSq = 1;
710aA         EndIf;
710aA            Eval nextseq# = pMaxSq;
710aA            Eval NRIRECID = nextseq# +1;
710aA            Update NRIREC;
710aA       EndIf;
710aA /end-free

710aDC*    keyprd        setgt     prplfil1
710aDC*    keyprd        readpe    prplfil1
710aDC*                  if        %eof           or
710aDC*                            prseq# < 0     or
710aDC*                            prseq# = 99999
710aDC*                  eval      nextseq# = 1

650cAc*710aD/  /free
650cAc*710aD/    dou not %equal(prplfil1);
650cAc*710aD/      setll ($prwhse: $prwhdp: nextseq#) prplfil1;
650cAc*710aD/      if %equal;
650cAc*710aD/        nextseq# = nextseq#  + 1;
650cAc*710aD/      else;
650cAc*710aD/        leave;
650cAc*710aD/      endif;
650cAc*710aD/    enddo;
650cAc*710aD/  /end-free
710aDC*                  else
710aDC*                  eval      nextseq# = prseq# + 1
710aDC*                  endif

417bA*  When creating a negative sequence number.
417bA
417bAC                   other
417bAC                   move      $psubcmd      temp1n
417bAC                   eval      maxseq# = -(temp1n * 1000)
417bAC                   eval      minseq# = maxseq# - 999
417bAC                   eval      $kseq# = maxseq#
417bAC     keypr1        setll     prplfil1
650KAC                   if        %equal
650kAC                   eval      nextseq# = minseq#
650kA /free
650kA   dou not %equal(prplfil1);
650kA     setll ($prwhse: $prwhdp: nextseq#) prplfil1;
650kA     if %equal;
650kA       nextseq# = nextseq#  + 1;
650kA     else;
650kA       leave;
650kA     endif;
650kA   enddo;
650kA /end-free
650kAC                   else
417bAC     keyprd        readpe    prplfil1
417bAC                   if        %eof           or
417bAC                             prseq# < minseq#
417bAC                   eval      nextseq# = minseq#
417bAC                   else
417bAC                   eval      nextseq# = prseq# + 1
417bAC                   endif
650kAC                   endif
417bA
417bAC                   endsl

     C     endnxtseq     endsr

     *----------------------------------------------------------------
     *  getqtyavl    Get home slot quantity available
     *----------------------------------------------------------------

     C     getqtyavl     begsr

     C                   eval      homeavlqty = 0

 1B  C                   select

     *  When warehouse qty is not sent, use slot's actual available qty.

 1B  C                   when      not $prqtywu
CBIaAC                   if        client = cheney
CBIaAC                   exsr      addccqty
CBIaAC                   endif
     C                   if        $slavl1 > 0
520bA*
520bA*  When doing JIT replenishments, send back actual available qty.
520bAC                             or  $psubcmd >= '*CRTRPLSQ1'
520bAC                             and $psubcmd <= '*CRTRPLSQ9'
520bA*
520cA*  When doing priority replenishments, send back actual available qty.
520cAC                             or  $psubcmd = '*AVGQTY'
520cAC                             or  $psubcmd = '*ORDQTY'
     C                   eval      homeavlqty = $slavl1
     C                   endif

     *  Otherwise, calculate available qty.

 1B  C                   other

     C                   exsr      calcovrflw
 2B  C                   eval      homeavlqty = $prqtyw - ovravlqty

     C                   eval      lgprqtyw = $prqtyw
     C                   eval      lgproavl = ovravlqty

     C                   endsl

     C                   eval      lgprhavl = homeavlqty

     C     endgetavl     endsr

     *----------------------------------------------------------------
     *  getqtyneeded   Get quantity needed
     *----------------------------------------------------------------

     C     getqtyneeded  begsr

     C                   eval      qtyneeded = 0
417dAC                   eval      savqtyneeded = qtyneeded
720 A
720 A*  get Overflow Quantity Available for Store location items
720 Ac                   if        $zdStgFlg = 'Y'
720 Ac                   exsr      getStrOvr
720 Ac                   endif

 1B  C                   select

500bA*  When *RPLLVL is sent,
500bA*    set qty needed to 1, actual qty needed to be determined later.
500bA
500bAC                   when      $psubcmd = '*RPLLVL'
500bAC                   eval      qtyneeded = 1
500bAC                   eval      savqtyneeded = qtyneeded

500bM*  When *CRTRPLDKA or *AVGQTY is sent,
     *    the qty needed is the Dakota avg sales for today.

 1B  C                   when      $psubcmd = '*CRTRPLDKA'
500bAC                             or $psubcmd = '*AVGQTY'
700fAC                   if        eachRPL
700fAC     keyigEA       chain     itemavg
700fAC                   else
     C     keyig         chain     itemavg
700fAC                   endif
750aAc                   if        not %found(itemavg)
750aA /free
750aA                    clear aqs;
750aA /end-free
750aAc                   endif
ALN AC                   select
BIRbAC                   when      client = BiRite
SVL AC                             or client = SavalFoods
FFC AC                             or client = Fischerfoods
BIRbA*    When day is Friday, use Sunday to retrieve Averages.
BIRbAC                   if        d = 6
BIRbAC                   eval      d = 1
BIRbAC                   endif
ALN A*
ALN AC                   when      client = Allen
MJKbAC                             or client = MJKellner
JPFaAC                             or client = Palmer
FPRaAC                             or client = Foodpro
ALN A*    When day is Friday, combine Friday+Sunday averages.
ALN AC                   if        d = 6
ALN AC                   eval      aqs(6) = aqs(6) + aqs(1)
ALN AC                   endif
ALN A*
DRYbAC                   when      client = Dairyland
DRYbA*    When day is Saturday, use Sunday to retrieve Averages.
DRYbAC                   if        d = 7
DRYbAC                   eval      d = 1
DRYbAC                   endif
DRYbA*
BIRbAC                   endsl
 2B  C                   if        %found and aqs(d) > 0
500dAC                   eval      aqs(d) = %inth(aqs(d)+0.49)
     C                   eval      qtyneeded = aqs(d)
DRYdAC                   if        client = Dairyland
DRYdAC                   eval      qtyneeded = aqs(d)+(aqs(d)*0.20)
DRYdAC                   endif
417dAC                   eval      savqtyneeded = qtyneeded
     C                   endif
500bA
500bA*  When *AVGnnn is sent,
500bA*    the qty needed is the Dakota avg sales for today
500bA*    plus nnn percent.
500bA
500bAC                   when      %subst($psubcmd:1:4) = '*AVG'
700fAC                   if        eachRPL
700fAC     keyigEA       chain     itemavg
700fAC                   else
500bAC     keyig         chain     itemavg
700fAC                   endif
SVLbAC                   select
SVLbAC                   when      client = SavalFoods
FFCaAC                             or client = Fischerfoods
SVLbAC*    When day is Friday, use Sunday to retrieve Averages.
SVLbAC                   if        d = 6
SVLbAC                   eval      d = 1
SVLbAC                   endif
SVLbAC                   endsl
SVLbAC*
500bAC                   if        %found and aqs(d) > 0
500dAC                   eval      aqs(d) = %inth(aqs(d)+0.49)
500bAC                   eval(h)   qtyneeded = aqs(d) + (aqs(d) * avgpct)
500bAC                   eval      savqtyneeded = qtyneeded
500bAC                   endif
730bA
730bA*    When Breakdown Quantity is sent for Drop Pick Items
730bA
730bAC                   when      ($psubcmd = '*CRTDDRPL'
500bAC                             or $psubcmd = '*ORDQTY')
730bAc                             and $brkqty <> 0
740 A /free
740 A           exWhse=$prwhse;
740 A           ioeitm = $pritem;
740 A           exitemord ('*GET': exRtnCode: exRtnMsg: exWhse: ioeitm:
740 A                        ioebd1);
740 A           if exRtnCode = '*ERROR';
740 A             ioebd1=*zeros;
740 A             $prqtyw=0;
740 A             $brkqty=0;
740 A             qtyneeded=0;
740 A           else;
740 A             $prqtyw=ioebd1;
740 A             $brkqty=ioebd1;
740 A             qtyneeded=ioebd1;
740 A           endif;
740 A /end-free

500bM*  When *CRTRPLDKO or *ORDQTY is sent,
500 A*    the qty needed is the Dakota ordered quantity.
500 A
500 AC                   when      ($psubcmd = '*CRTRPLDKO'
730bAC                             or $psubcmd = '*CRTDDRPL'
500bAC                             or $psubcmd = '*ORDQTY')
730bAc                             and $brkqty = 0
700fAC                   if        eachRPL
700fAC*    keyigEA       chain     itemavg
700fAC     keyigEA       chain     itemord
700fAC                   else
500 AC     keyig         chain     itemord
700fAC                   endif
500iAC                   select
730bDc*                  when      not %found
730bAC                   when      not %found(itemord)
500iAC                   eval      iitqo        = 0
500iAC                   eval      qtyneeded    = 0
500iAC                   eval      savqtyneeded = 0
500iAC*
500iDC*                  if        %found and iitqo > 0
730bDC*                  when      %found and iitqo > 0
730bAC                   when      %found(itemord) and iitqo > 0
500 AC                   eval      qtyneeded = iitqo
500 AC                   eval      savqtyneeded = qtyneeded
500iAC*
730bDC*                  when      %found and iitqo <= 0
730bAC                   when      %found(itemord) and iitqo <= 0
500iAC                   eval      iitqo        = 0
500iAC                   eval      qtyneeded    = 0
500iAC                   eval      savqtyneeded = qtyneeded
500iDC**                 endif
500iMC                   endsl

     *  When quantity needed is sent, use it.

 1B  C                   when      $prqtynu
     C                   eval      qtyneeded = $prqtyn
417dAC                   eval      savqtyneeded = qtyneeded

     *  When quantity needed is not sent and the slot is sent,
     *    the qty needed is the qty that would bring the available slot
     *    qty to zero. If available is already positive, then nothing
     *    is needed.

 1B  C                   when      not $prqtynu and $prslotu
 2B  C                   if        $slavl1 < 0
     C                   eval      qtyneeded = %abs($slavl1)
417dAC                   eval      savqtyneeded = qtyneeded
     C                   endif

     C                   endsl

     C                   eval      lgprqtyn = qtyneeded

510aAC                   if        $ittype = 'R'
510aAC                   exsr      getkitqty
510aAC                   eval      qtyneeded = qtyneeded - pqty
510aAC                   endif

     *  If quantity needed is zero, there is nothing to do.

730bDC*                  if        qtyneeded <= 0
730bMC                   if        qtyneeded <= 0 and $prqtyw <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'QTYZERO'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endgetqty
     C                   endif

     C     endgetqty     endsr

500aA*----------------------------------------------------------------
500aA*  getslotpos  Get Slot Position field.
500aA*----------------------------------------------------------------
500aA
500aAC     getslotpos    begsr
500aA
500aA*  Get FROM slot position.
500gA
500aA*    If repl type not Flowrack or Breaker,
500aA*      Then just set position to 1.
500aA*      Otherwise, get position associated with license.
500gA
500gAC                   if        rpltype <> 'F' and rpltype <> 'B'
500gAC                   eval      prfpos = 1
500gAC                   else
500aAC                   eval      kyaisl = prfail
500aAC                   eval      kyloc  = prfloc
500aAC                   eval      kyrlvl = prflvl
500aAC                   eval      kyhand = prfhnd
500aAC                   exsr      getslotpos2
500gAC                   eval      prfpos = slotpos
500gAC                   endif
500aA
500aA*  Get TO slot position.
500gA
500aA*    Don't care about position in TO slot so set it to 1.
500gA
500gAC                   eval      prtpos = 1
500gA
500gDC**   keysp         setll     slotpos
500gDC**   keysp         reade     slotpos                                74
500gDC**                 if        *in74
500gDC**                 eval      sppos = 1
500gDC**                 endif
500aA
500aAC                   endsr

500gA*----------------------------------------------------------------
500gA*  getslotpos2   Get Slot Position.
500gA*----------------------------------------------------------------
500gA
500gAC     getslotpos2   begsr

     C                   eval      slotpos = 1

     C                   endsr

     *----------------------------------------------------------------
     *  getslt2fil   Get slot to fill
     *----------------------------------------------------------------

     C     getslt2fil    begsr

650iAC                   eval      found = *off
     C                   eval      error = *off
530aAC                   eval      zeropickslot = *off

     *  If slot was sent in, then just get tie/high info.

     C                   if        $prslotu
     C                   goto      skipsearch
720 AC                   else
720 Ac                   if        $zdstgflg='Y'
720 Ac                   select
720 Ac                   when      $ittype = 'B'
720 Ac                   eval      $prslotu = *on
720 Ac                   eval      $prslot  = $zdstrbpck
720 AC                   goto      skipsearch
720 Ac                   when      $ittype = ' '
720 Ac                   eval      $prslotu = *on
720 Ac                   eval      $prslot  = $zdstrcpck
720 AC                   goto      skipsearch
720 Ac                   endsl
720 Ac                   endif
     C                   endif

     *  Otherwise, whip through all active pick slots for item.

     C                   eval      $slavl1 = 0

     C                   eval      savepick  = ' '
     C                   eval      saveavail = 0

     C                   eval      kyitem = $pritem
     C                   eval      kystat = 'A'
     C                   eval      kypick = 'Y'
     C     keys3         setll     slot3

     C                   dow       forever = forever

     C     keys3         reade     slot3

     C                   if        %eof
     C                   leave
     C                   endif


700fA*    If Each replenishment, slot must be *EACH.
700fA
700fA /free
700fA      if eachRPL;
700fA        chain (slwhse: slsdef) slotdef;
700fA        if not %found(slotdef) or sdpal <> '*EACH';
700fA          iter;
700fA        endif;
700fA      endif;
700fA /end-free

     *    If slot is in PIR section, it must be a reserved slot.
500fD*      (Criteria Removed as of 4.17f)

500fDC**                 if        slstyp = 'P' and slrsrv <> 'Y'
500fDC**                 iter
500fDC**                 endif

     *    Calculate available slot qty.

     C                   exsr      calcqtys
     C                   eval      $slavl1  = $slavl1 + slavl1
TPCdA*
TPCdAC                   if        client = TPC
TPCdA*
TPCdAC                   if        $psubcmd = '*ORDQTY'
TPCdA*      Ignore qty's in allocated/picked buckets.
TPCdAC                   eval      $slavl1 = slstk1
TPCdAC                   eval      $slavl2 = slstk2
TPCdAC                   eval      $slavl3 = slstk3
TPCdAC                   endif
TPCdA*
TPCdAC                   endif
TPCdA*
     C                   eval      lgprhcnt = lgprhcnt + 1
530aA
530aA*    Flag pick slot as empty so that it will be filled first.
530aAC                   if            slstk1 = 0
530aAC                             and slstk2 = 0
530aAC                             and slstk3 = 0
530aAC                   eval      zeropickslot = '1'
530aAC                   endif

     *    Save last pick slot (this will be the last one in FIFO order).

     C                   eval      found = *on
     C                   eval      savewhdp = slwhdp
     C                   eval      savepick = sldisp
     C                   eval      saveavail = slavl1

     C                   enddo

     *  If slot not found, send back error.

     C                   if        not found
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOPICKSLOT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endslt2fil
     C                   endif

     *  Otherwise, get pick slot record that was found.

     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $prwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = savewhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = savepick

     C                   eval      drislot = *on
     C                   exsr      drislotsr
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*GET'        $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*    $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRISLOT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endslt2fil

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   exsr      writelog
     C                   goto      endslt2fil

     C                   endsl

     *  Get available qty to use and tie/high information.

     C     skipsearch    tag

     *    Save slot information for log file.

     C                   eval      lgprhwhd = $slwhdp
     C                   eval      lgprhslt = $sldisp

     *    Get available qty for selected slot.
TPCdA*
TPCdAC                   if        client = TPC
TPCdA*
TPCdAC                   if        $psubcmd = '*ORDQTY'
TPCdA*      Ignore qty's in allocated/picked buckets.
TPCdAC                   eval      $slavl1 = slstk1
TPCdAC                   eval      $slavl2 = slstk2
TPCdAC                   eval      $slavl3 = slstk3
TPCdAC                   endif
TPCdA*
TPCdAC                   endif

     C                   exsr      getqtyavl

     *    Get tie/high info for selected slot.

     C                   eval      kysdef = $slsdef
417aAC                   eval      picksdef = $slsdef
 1B  C                   exsr      gettihi
     C                   eval      homepltqty   = dspqty
     C                   eval      homelayer    = layer
     C                   eval      homettlqty   = dstqty
     C                   eval      hometie      = dstie
     C                   eval      homehigh     = dshigh

     *    Calculate empty quantity in slot.

     C                   select
     C                   when      not foundtihi
     C                   eval      homeempqty   = homettlqty
     C                   eval      homeemplayer = homelayer

     C                   when      homeavlqty >= homettlqty
500hAC                             and $psubcmd <> '*CRTRPFSQ1'
500hAC                             and $psubcmd <> '*CRTRPFSQ2'
500hAC                             and $psubcmd <> '*CRTRPFSQ3'
500hAC                             and $psubcmd <> '*CRTRPFSQ4'
500hAC                             and $psubcmd <> '*CRTRPFSQ5'
500hAC                             and $psubcmd <> '*CRTRPFSQ6'
500hAC                             and $psubcmd <> '*CRTRPFSQ7'
500hAC                             and $psubcmd <> '*CRTRPFSQ8'
500hAC                             and $psubcmd <> '*CRTRPFSQ9'
     C
     C                   eval      homeempqty   = 0
     C                   eval      homeemplayer = 0

     C                   other
     C                   eval      homeempqty   = homettlqty - homeavlqty
500hA*
500hA*    To slot empty qty must be positive when forcing Priority
500hA*    Replenishment to be created.
500hAC                   if        $psubcmd >= '*CRTRPFSQ1'
500hAC                             and $psubcmd <= '*CRTRPFSQ9'
500hAC                             and homeempqty < 0
500hAC                   eval      homeempqty = homeempqty * -1
500hA*
500hA*    When forcing priority replen to be created, the maximum
500hA*    qty we want is one pallet.
500hAC                   if        homeempqty > homepltqty
500hAC                   eval      homeempqty = homepltqty
500hAC                   endif
500hAC                   endif
     C
 1B  C                   if        homelayer > 0
 1B  C                   eval      homeemplayer = homeempqty / homelayer
500hA*
500hA*    To slot empty layer must be positive when forcing Priority
500hA*    Replenishment to be created.
500hAC                   if        $psubcmd >= '*CRTRPFSQ1'
500hAC                             and $psubcmd <= '*CRTRPFSQ9'
500hAC                             and homeemplayer < 0
500hAC                   eval      homeemplayer = homeemplayer * -1
500hAC                   endif
     C
     C                   else
 1B  C                   eval      homeemplayer = 0
     C                   endif

     C                   endsl

500 A*  When creating replenishments based on ordered quantity, see
500 A*  if user wants to create replenishments to fill entire ordered
500 A*  quantity. If so, make sure the empty quantity is greater than
500 A*  or equal to ordered quantity.

500 AC                   if        $psubcmd = '*CRTRPLDKO' and opoqrp = 'Y'
510 AC                             or $psubcmd = '*ORDQTY' and opoqrp = 'Y'
500 AC                   if        homeempqty < iitqo
500 AC                   eval      homeempqty = iitqo
500 AC                   if        homelayer > 0
500 AC                   eval      homeemplayer = homeempqty / homelayer
500 AC                   else
500 AC                   eval      homeemplayer = 1
500 AC                   endif
500 AC                   endif
500 AC                   endif

     C     endslt2fil    endsr

720 A*-------------------------------------------------------------------
720 A*  getStrOvr   Get quantity from Store Overflow slots
720 A*-------------------------------------------------------------------
720 A
720 AC     getStrOvr     begsr
720 A
720 AC                   eval      found = *off
720 AC                   eval      error = *off
720 Ac                   eval      ovrcasesavl = *zeros
720cA
720cA         //  Add any RPA (Staging slot quantity) to case quantity availalb as well
720cA         //  First we will get item from either the passed Case Pick or Breakdown slot
      /free
720cA                    exec sql select slitem into :$slitem
720cA                              from slot
720cA                            where sldisp=:$zdstrcpck and slstat='A ';
720cA                    if sqlstt <> '00000';
720cA                       exec sql select ilitm2 into :$slitem
720cA                                from slot,itemlnk
720cA                             where slwhse=ilwhse and sldisp=:$zdstrbpck
720cA                               and slstat='A ' and slitem=ilitem
720cA                                fetch first row only;
720cA                    endif;
720cA
720cA                    if sqlStt = '00000';
720cA                      // If item found for Case then force total RPA Aisle
720cA                      // quantity to ovrcaseabl so it will be considered
720cA                      exec sql select sum(slstk1) into :ovrcasesavl
720cA                                from slot
720cA                              where slaisl='RPA' and slstat='A '
720cA                                and slitem=:$slitem;
720cA                    endif;
720cA
720cA                    ovrcasesavl1 = *zeros;
720cA             // if no overflow returned from DRIZONED do simple query
720cA             // to ensure no overflow slots exist with quantity to consider
720cA                    exec sql select sum(slstk1) into :ovrcasesavl1
720cA                              from slot,slotstr
720cA                           where slwhse=stwhse and slwhdp=stwhdp and
720cA                           sldisp=stdisp and
720cA                           slitem=:$slitem and slpick='N';
720cA                    ovrcasesavl = ovrcasesavl + ovrcasesavl1;
      /end-free
720cA
720 A
720 A*  loop though returned overflow slots for Store Location
720 A /free
720 A                    ovrfCnt = 1;
720 A                    dow ovrfCnt < 4;
720 A                       select;
720 A                          when ovrfCnt = 1;
720 A                             useovrf = $zdstrovf1;
720 A                          when ovrfCnt = 2;
720 A                             useovrf = $zdstrovf2;
720 A                          when ovrfCnt = 3;
720 A                             useovrf = $zdstrovf3;
720 A                       endsl;
720 A
720 A          // *  Get slot information
720 A
                        if useovrf <> *blanks;
720 A                       $slwhseu  = *on;
720 A                       $slwhse   = $zdwhse;
720 A                       $slwhdpu  = *on;
720 A                       $slwhdp   = $zdwhdp;
720 A                       $sldispu  = *on;
720 A                       $sldisp   = useovrf;
720 A
720 A                       drislot = *on;
720 A                       exsr drislotsr;
720 A
720 A          //  Get/Verify Slot item.
720 A
720 A                       check4err = *on;
720 A                       $drisubcmd = '*GETALL';
720 A                       item# = $slitem;
720 A                       exsr getitem;
720 A
720 A          //  accumulate overflow found in store location to be
720 A          //  used when determining whether replenishment should occur
720 A                       ovrcasesavl = ovrcasesavl + $slavl1;
                         endif;
720 A
720 A                       ovrfCnt = ovrfCnt + 1;
720 A                       enddo;
                            exsr verifycrt;
720 A /end-free
720 AC     endgetstrovr  endsr

     *----------------------------------------------------------------
     *  gettihi      Get item tie/high for slot
     *----------------------------------------------------------------

     C     gettihi       begsr

     *  Initialize the following quantities that are needed.

     *    - Single pallet quantity for slot (dspqty).
     *    - Single layer quantity for pallet (layer).
     *    - Total quantity that can fit into slot (dstqty).

     C                   eval      dspqty = 0
     C                   eval      dstqty = 0
     C                   eval      layer  = 0
417aAC                   eval      sdpos  = 0

     C                   eval      foundtihi = *off
720 A
720 A*  If Replen Staging required and slot in questions resides
720 A*  in the store and no matching tihi was found and a Store
720 A*  slot def was defined force to that slot def.
720 A
720 Ac                   if        $zdStgFlg='Y'
720eDc*                  if        oprzst <> *blanks
720eMc                   if        oprzst <> *blanks and kysdef = *blanks
720 Ac                   eval      kysdef = oprzst
720bA /free
720bA                    if %lookup(%trim(oprzst):$idsdef) = *zeros;
720bA                       // since this is a Staging Replenishment by way of $zdStgFlg="Y"
720bA                       // we will force default staging slot type which is defined in
720bA                       // Replenishment Options. By placing this in the slot def array
720bA                       // with TIHI of 1 by 1 we guarantee at least a 1 case replenishment
720bA                       // if stock is not there to cover the 1 case
720bA                       curdef = %lookup(*blanks:$idsdef);
720bA                       if curdef <> *zeros;
720bA                          $idsdef(curdef) = %trim(oprzst);
720bA                          $idtie(curdef) = 1;
720bA                          $idhigh(curdef) = 1;
720bA                       endif;
720bA                    endif;
720bA /end-free
720 Ac                   endif
720 Ac                   endif

     *  Loop through item's definitions looking for a match.

     C                   eval      curdef = 0
     C                   dou       curdef = %elem($idsdef)
     C                   eval      curdef = curdef + 1

     C                   if        $idsdef(curdef) = kysdef
720 Ac                   if        $idsdef(curdef) = oprzst
720 Ac                             and $zdStgFlg <>'Y'
720 A*      Do not turn on foundTiHi if this is a Store
720 A*      defined TIHI definition but slot being
720 A*      replenished is not in the store
720 Ac                   else
     C                   eval      foundtihi = *on
     C                   leave
720 AC                   endif
     C                   endif

     C                   enddo

     *  If match is not found then all qtys end up being avail qty.

720 Ac     force_no_tihi tag
 1B  C                   if        not foundtihi
FDIaA*
FDIaA*      Force item tie/high to be order qty when not found.
KHL AC                   select
KHL DC*                  if        client = Finkle
KHL MC                   when      client = Finkle
FDIaAC                             and $psubcmd = '*ORDQTY'
MJKaAC                             or client = MJKellner
MJKaAC                             and $psubcmd = '*ORDQTY'
CLDaAC                             or client = CityLine
CLDaAC                             and $psubcmd = '*ORDQTY'
SFPxAC***                          or client = Seashore
SFPxAC***                          and ($psubcmd = '*AVGQTY'
SFPxAC***                           or  $psubcmd = '*ORDQTY')
FDIaAC                   eval      dspqty = iitqo
FDIaAC                   eval      dstqty = iitqo
FDIaAC                   eval      emptyq = iitqo
FDIaAC                   eval      emptylayer = 1
FDIaAC                   eval      layer  = iitqo
FDIaA*
KHL A*      Force item tie/high to be slot avail qty when ti/hi missing.
KHL MC                   when      (client = Kohlwholesale
MQSaAC                              or client = marques
DRYfAC                             or client = Dairyland)
KHL AC                             and $psubcmd = '*RPLLVL'
KHL AC                             and slpick = 'N'
KHL AC                   eval      dspqty     = slavl1
KHL AC                   eval      dstqty     = slavl1
KHL AC                   eval      emptyq     = slavl1
KHL AC                   eval      emptylayer = 1
KHL AC                   eval      layer      = slavl1
KHL A*
KHL DC*                  else
KHL MC                   other
     C                   eval      dspqty = 9999
     C                   eval      dstqty = 9999
     C                   eval      emptyq = 9999
     C                   eval      emptylayer = 1
     C                   eval      layer  = 9999
KHL DC*                  endif
KHL MC                   endsl
FDIaA*
     C                   endif

     *  If match is found then calculate the needed quantities.

 1B  C                   if        foundtihi

 1B  C                   select

 1X  C                   when      $idtie(curdef) = 0
     C                   eval      dspqty = $idhigh(curdef)
     C                   eval      layer  = $idhigh(curdef)

 1X  C                   when      $idhigh(curdef) = 0
     C                   eval      dspqty = $idtie(curdef)
     C                   eval      layer  = $idtie(curdef)

 1X  C                   other
     C                   eval      dspqty = $idtie(curdef) * $idhigh(curdef)
     C                   eval      layer  = $idtie(curdef)

 1E  C                   endsl

     C     keysd         chain     slotdef
     C                   if        not %found or sdpos <= 0
     C                   eval      dstqty = dspqty
     C                   else
     C                   eval      dstqty = dspqty * sdpos
     C                   endif

     C                   endif

     C     endgettihi    endsr

510aA*----------------------------------------------------------------
510aA*  getslot  Get slot info.
510aA*----------------------------------------------------------------

510aAC     getslot       begsr

     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#

     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $prwhse

     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $prwhdp

     C                   eval      $slitemu = *on
     C                   eval      $slitem  = $pritem

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = *blanks

510aAC                   eval      drislot = *on
510aAC                   call(e)   'DRISLOT'
510aAC                   parm      '*GETREPACK'  $drisubcmd
510aAC                   parm      $pprogram     $driprogram
510aAC                   parm      ' '           $drireturn
510aAC                   parm      ' '           $drimessage
510aAC     $slot         parm      $slot         $dridata

510aAC     endgetslot    endsr

     *----------------------------------------------------------------
     *  remove     Remove priority replenishments
     *----------------------------------------------------------------

     C     remove        begsr
     C                   move      *off          error

 1B  C                   if        not $prwhdpu or
 1B  C                             $prwhdp = ' ' or $prwhdp = '*ALL'
     C     keyprw        setll     prplfil
     C                   else
     C     keyprd        setll     prplfil
     C                   endif

     C                   dow       forever = forever

 1B  C                   if        not $prwhdpu or
 1B  C                             $prwhdp = ' ' or $prwhdp = '*ALL'
     C     keyprw        reade     prplfil                              78
     C                   else
     C     keyprd        reade     prplfil                              78
     C                   endif

     C                   if        %eof
     C                   leave
     C                   endif

417c C                   if        prprty <> 0
417c C                   iter
417c C                   endif

     C                   if        *in78
     C                   iter
     C                   endif

     C                   delete(e) prrec
     C                   if        %error
     C                   endif

     C                   enddo

     C     endremove     endsr

     *----------------------------------------------------------------
     *  rplcriteria  See if replenishment should be done
     *----------------------------------------------------------------

     C     rplcriteria   begsr

500bA*  For *REPLVL,
500bA*    Replenishment not needed if avail qty is > item repl level.
500bA*    Otherwise, set needed qty to slot empty quantity.
500bA
500bAC                   if        $psubcmd = '*RPLLVL'
500bAC                   if        homeavlqty > $itrepl
DRYgAC                             and client <> Dairyland
DRYgA*
DRYgAC                             or homeavlqty >= $itrepl
DRYgAC                             and client = Dairyland
700gAc                             and not eachRPL
700gAc
700gAc                             or eachRPL
700gAC                             and homeavlqty > 0
700gAC                             and client = Dairyland
DRYgA*
500bAC                   eval      error = *on
500bAC                   eval      $preturn  = 'LVLOK'
500bAC                   exsr      getmsg
500bAC                   exsr      writelog
500bAC                   goto      endcriteria
500bAC                   endif
KHL A*
KHL AC                   if        client = Kohlwholesale
MQSaAC                             or client = marques
DRYfAC                             or client = Dairyland
SFP AC                             or client = Seashore
750aAc                             or (oparpl='Y' and $psubcmd = '*RPLLVL'
750aAc                                            and $ittype='R')
KHL A*      No ti/hi defined. Default to Replenishment level.
KHL AC                   if        homeempqty = 9999
700fAC                   if        eachRpl
700fAC                   eval      homeempqty = 1
700fAC                   else
KHL AC                   eval      homeempqty = $itrepl
700fAC                   endif
KHL AC                   endif
KHL AC                   endif
KHL A*
500bAC                   eval      qtyneeded = homeempqty
500bAC                   eval      savqtyneeded = qtyneeded
500bAC                   goto      endcriteria
500bAC                   endif

     *  If that met the need, get out.

 2B  C                   if        qtyneeded <= homeavlqty
500hAC                             and $psubcmd <> '*CRTRPFSQ1'
500hAC                             and $psubcmd <> '*CRTRPFSQ2'
500hAC                             and $psubcmd <> '*CRTRPFSQ3'
500hAC                             and $psubcmd <> '*CRTRPFSQ4'
500hAC                             and $psubcmd <> '*CRTRPFSQ5'
500hAC                             and $psubcmd <> '*CRTRPFSQ6'
500hAC                             and $psubcmd <> '*CRTRPFSQ7'
500hAC                             and $psubcmd <> '*CRTRPFSQ8'
500hAC                             and $psubcmd <> '*CRTRPFSQ9'
650hAC                             and $psubcmd <> '*CRTRPLODN'
520bA*
520bA*  Pick slot has positive qty, no replenishment needed.
640eDC*****                        or homeavlqty >= 0
730 DC*                            or homeavlqty > 0
730 MC                             or qtyneeded <= homeavlqty
520bAC                             and $psubcmd >= '*CRTRPLSQ1'
520bAC                             and $psubcmd <= '*CRTRPLSQ9'
520cA*
520cA*  Pick slot has positive qty, no replenishment needed.
520cDC*                            or homeavlqty >= 0
520cDC*                            and ($psubcmd = '*AVGQTY'
520cDC*                             or $psubcmd = '*ORDQTY')
     C
     C                   eval      error = *on
     C                   eval      $preturn  = 'QTYEXISTS'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif

     *  If we are filling to needed qty, there is nothing else to check.

 1X  C                   if        $prfillu and $prfill = 'Y'
     C                   goto      endcriteria
 2E  C                   endif

     *  Otherwise ...

     *    See if slot has any more room.

 1X  C                   if        homeempqty <= 0
     C                   eval      error = *on
     C                   eval      $preturn  = 'FULLSLOT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif
 2E
     *    See if slot has at least one empty layer
     *      (Only do check if high value is greater than 1)

 1X  C                   if        homehigh > 1 and homeemplayer < 1
     C                   eval      error = *on
     C                   eval      $preturn  = 'NOLAYER'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endcriteria
 2E  C                   endif

     C     endcriteria   endsr

416aA*----------------------------------------------------------------
416aA*  seqprtyrpl  Sequence priority replenishments                  ent
416aA*----------------------------------------------------------------
416aA
416aAC     seqprtyrpl    begsr
     C                   eval      lstseq = 0

     *    Find highest sequence number in file. Then add 1 more.

710aA /free
710aA     Chain(n) ($prwhse: pFileNm) pirrecid#;
710aA       If Not %Found(pirrecid#);
710aA         exec sql select max(prseq#) into :pMaxSq from prplfil;
710aA           If sqlstt <> sqlSuccess;
710aA             Eval pMaxSq = 0;
710aA           EndIf;
710aA          Eval NRIWHSE  = $prwhse;
710aA          Eval NRIFILE  = pFileNm;
710aA          Eval NRIRECID = pMaxSq;
710aA          Write NRIREC;
710aA       EndIf;
710aA /end-free

710aDC*    keyprw        setll     prplfil1
710aDC*                  dow       forever = forever
710aDC*    keyprw        reade     prplfil1

710aDC*                  select

710aDC*                  when      %eof
710aDC*                  add       1             lstseq
710aDC*                  leave

710aDC*                  when      prseq# > lstseq
710aDC*                  eval      lstseq = prseq#
710aDC*                  endsl

710aDC*                  enddo

     C                   eval      $kwhse = $prwhse
     C                   eval      $kwhdp = *blanks
     C                   eval      $ktdis = *blanks
     C                   move      *hival        $kaqs
     C                   eval      $kfail = *blanks
     C                   eval      $ktail = *blanks
640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C     keypr3        setll     prplfil3
 1X  C                   else
     C     keypr2        setll     prplfil2
 1E  C                   endif
     C                   eval      startover = *off

     *    Initialize starting sequence number.

710aDC*                  eval      n = lstseq

     C     start         tag

 1B  C                   dou       forever <> forever
 2B  C                   if        startover
640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C     keypr3        setll     prplfil3
 3X  C                   else
     C     keypr2        setll     prplfil2
 3E  C                   endif
     C                   eval      startover = *off
 2E  C                   endif
     C     again         tag
640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C     keyprw        reade     prplfil3
 2X  C                   else
     C     keyprw        reade     prplfil2
 2E  C                   endif
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
     C     prflag        cabne     ' '           again
710aDC*                  add       1             n
710aD /free
710aD   // lets make sure a record doesn't already exist for this seq#
710aD   // this problem comes up when the lstseq = 99999
710aD   // dou not %equal(prplfil1);
710aD   //  setll (prwhse: prwhdp: n) prplfil1;
710aD   //  if %equal;
710aD   //    n = n + 1;
710aD   //  else;
710aD   //    leave;
710aD   //  endif;
710aD   // enddo;
710aD /end-free
710aA /free
710aA     Chain (prwhse: pFileNm) pirrecid#;
710aA       If %found(pirrecid#);
710aA         Eval pMaxSq = NRIRECID;
710aA         DoU not %Equal(prplfil1);
710aA           SetLL (prwhse: prwhdp: pMaxSq) prplfil1;
710aA             If %Equal;
710aA               pMaxSq = pMaxSq+ 1;
710aA             Else;
710aA               Leave;
710aA             EndIf;
710aA         EndDo;

710aA         If pMaxSq > 99998;
710aA            Eval pMaxSq = 1;
710aA         EndIf;
710aA            Eval nextseq# = pMaxSq;
710aA            Eval NRIRECID = nextseq# + 1;
710aA            Update NRIREC;
710aA       EndIf;
710aA       Eval lstseq = nextseq#;
710aA /end-free

710aDC*                  eval      prseq# = n
710aAC                   eval      prseq# = nextseq#
     C                   eval      prflag = 'S'
640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C                   update    p3rec
 2X  C                   else
     C                   update    p2rec
 2E  C                   endif
     C                   eval      $kwhse = prwhse
     C                   eval      $kwhdp = prwhdp
     C                   eval      $kaqs = praqs
     C                   eval      $kfail = prfail
     C                   eval      $ktail = prtail
     C                   eval      $ktdis = prtdis
     C     prtail        cabeq     prfail        again
     C                   eval      $kfail = prtail
     C                   eval      $ktail = *blanks
     C                   eval      $ktdis = *blanks
     C                   eval      startover = *on
 1I  C                   iter
 1E  C                   enddo

     * Make sure that all aisles are done.

640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C     keyprw        setll     prplfil3
 1X  C                   else
     C     keyprw        setll     prplfil2
 1E  C                   endif
 1B  C                   dou       forever <> forever
640fDC*                  if        locator
FPR DC*                  if        locator  or oprsrt = '*TOSLOT'
FPR MC                   if        locator
FPR AC                             and (client <> FoodPro)
FPR AC                             or oprsrt = '*TOSLOT'
     C     keyprw        reade     prplfil3
 2X  C                   else
     C     keyprw        reade     prplfil2
 2E  C                   endif
 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif
 2B  C                   if        prflag > ' '
 1I  C                   iter
 2E  C                   endif
     C                   eval      startover = *on
 1L  C                   leave
 1E  C                   enddo

     * Start again, if any aisles are not done.

 1B  C                   if        startover
     C                   eval      $ktdis = *blanks
     C                   eval      $kwhdp = *blanks
     C                   move      *hival        $kaqs
     C                   eval      $kfail = *blanks
     C                   eval      $ktail = *blanks
goto Csr                 goto      start
 1E  C                   endif

     C     endseq        endsr
417aA
417aA*----------------------------------------------------------------
417aA*  setrpltype  Set replenishment type
417aA*----------------------------------------------------------------
417aA
417aAC     setrpltype    begsr
500 A
500 A* Get slot definition for "To" slot.
417aA
417aAC                   eval      kysdef = picksdef
417aAC     keysd         chain     slotdef
417aAC                   if        not %found
500 AC                   eval      sdpal = '*NONE'
417aAC                   endif
500 A
500 A* Determine type Priority replenishment type ...
417aA
417aAC                   select
417aA
500 M*   ... FlowRack replenishment?
417aA
500 MC                   when      sdpal = '*FLOW'
500 MC                   eval      rpltype = 'F'
417aA
500 M*   ... Breakdown replenishment?
417aA
417aAC                   when      $ittype = 'B'
700fAC                             or sdpal = '*EACH'
500 MC                   eval      rpltype = 'B'
510 A*
510 A*   ... Repack replenishment?
510 A*
510 AC                   when      $ittype = 'R'
510 AC                   eval      rpltype = 'R'
417aA
417aA*    Otherwise, treat as Normal replenishment.
417aA
417aAC                   other
417aAC                   eval      rpltype = ' '
417aAC*
417aAC                   endsl
417aA
417aAC                   endsr

416cA*----------------------------------------------------------------
416cA*  updprtyrpl   Update existing priority replenishment
416cA*----------------------------------------------------------------
416cA
416cAC     updprtyrpl    begsr

740cAC                   eval      deletedJITSeq# = 0
     C                   eval      updflag = *off
     C                   exsr      getdatetime
720 Ac
720 Ac                   if        $zdstgflg = 'Y'
720 Ac                   if        $ittype='B'
720 Ac*  for staging type replenishments we move by case quantity and the
720 Ac*  Breakdown Replen already has case quantity so need to just blank
720 Ac*  type and force case item on replen
720 Ac                   eval      $pritem = $itmitem
720 Ac                   endif
720 Ac                   endif

     *  Loop through existing priority replenishments for item.

     C     keypr4        setll     prplfil4

     C                   dow       forever = forever

     C     keypr4        reade(e)  prplfil4

     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        %error
     C                   iter
     C                   endif

     *    Remove deleted records to keep file clean.

     C                   if        prflag = 'D'
     C                   delete(e) prrec4
     C                   if        %error
416dDC**                 iter
     C                   endif
416dAC                   iter
     C                   endif
700fA
700fA*    For Each replenishment, replenishment type must be 'B'
700fA
700fAC                   if        eachRPL and prrplt <> 'B'
700fAC                   iter
700fAC                   endif

     *    Remove active records older than 1 day.
417c *    and not just-in-time replenishments.

417cDC**                 if        prflag = 'A'
417cMC                   if        prflag = 'A' and
417cMC                             prprty =  0
     C                   Call      'CALCTIME'
     C                   Parm      '*DAYS'       calccmd           8
     C                   Parm      pradte        fromdate
     C                   Parm      pratim        fromtime
     C                   Parm      curdate       todate
     C                   Parm      curtime       totime
     C                   Parm      0             duration
     C                   if        duration > 1
     C                   delete(e) prrec4
     C                   if        %error
     C                   iter
     C                   endif
     C                   endif
     C                   endif

     *    If slot information doesn't match, then get next record.

     C                   if        prwhdp <> $slwhdp or
     C                             prfdis <> sldisp  or
720 DC*                            prtdis <> $sldisp
720 AC                             (prtdis <> $sldisp and $zdStgFlg='N') or
720 AC                             (prtdis <> *blanks and $zdStgFlg='Y')
     C                   iter
     C                   endif

640cA*    If JIT replenisment is needed, delete 1st priority replen.
640cA
640cAC                   if        $psubcmd = '*CRTRPLSQ7'
740cAC                   if        prseq# < 0
740cAC                   eval      deletedJITSeq# = prseq#
740cAC                   else
740cAC                   eval      deletedJITSeq# = 0
740cAC                   endif
640cAC                   delete(e) prrec4
640cAC                   leave
640cAC                   endif
640cAC

     *    Otherwise, update existing priority replenishment record.

 1B  C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
 1X  C                   else
     C                   eval      prfree = 'Y'
 1E  C                   endif

530 AC                   if        topick > 999
530 AC                   eval      prqty = 999
530 AC                   else
720bDc*                  eval      prqty  = topick
530 AC                   endif
     C                   eval      prstat = $slstat
417dAC**                 eval      praqs  = qtyneeded
520aAC*
520aAC                   if        %subst($psubcmd:1:4) <> '*AVG'
520aAC                             and $psubcmd <> '*ORDQTY'
520 DC*                  eval      praqs  = savqtyneeded
520 MC                   eval      praqs  = praqs + savqtyneeded
720bAC                   eval      prqty  = prqty + topick
520aAC                   else
720bAC                   eval      prqty  = topick
520aAC                   eval      praqs = qtyneeded
520aAC                   endif
500gA
500gAC                   exsr      getslotpos

     C                   update(e) prrec4
     C                   if        %error
     C                   endif

     C                   eval      lgprcrt  = 'U'
     C                   eval      lgprowhd = prwhdp
     C                   eval      lgproslt = prfdis
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

     C                   eval      updflag = *on
     C                   leave

     C                   enddo

     C                   endsr

610aA*----------------------------------------------------------------
610aA*  updprtyrpl2  Update existing priority replenishment
610aA*----------------------------------------------------------------
610aA
610aAC     updprtyrpl2   begsr

     C                   eval      updflag = *off
     C                   exsr      getdatetime

     *  Loop through existing priority replenishments for item.

     C     keypr4        setll     prplfil4

     C                   dow       forever = forever

     C     keypr4        reade(e)  prplfil4

     C                   if        %eof
     C                   leave
     C                   endif

     C                   if        %error
     C                   iter
     C                   endif

     *    Remove deleted records to keep file clean.

     C                   if        prflag = 'D'
     C                   delete(e) prrec4
     C                   if        %error
     C                   endif
     C                   iter
     C                   endif

     *    Remove active records older than 1 day.
     *    and not just-in-time replenishments.

     C                   if        prflag = 'A' and
     C                             prprty =  0
     C                   Call      'CALCTIME'
     C                   Parm      '*DAYS'       calccmd           8
     C                   Parm      pradte        fromdate
     C                   Parm      pratim        fromtime
     C                   Parm      curdate       todate
     C                   Parm      curtime       totime
     C                   Parm      0             duration
     C                   if        duration > 1
     C                   delete(e) prrec4
     C                   if        %error
     C                   iter
     C                   endif
     C                   endif
     C                   endif

     *    If slot information doesn't match, then get next record.

     C                   if        prwhdp <> $slwhdp or
     C                             prfdis <> sldisp  or
     C                             prtdis <> rpkpslot
     C                   iter
     C                   endif

     *    Otherwise, update existing priority replenishment record.

     C                   if        topick <> slavl1
     C                   eval      prfree = 'N'
     C                   else
     C                   eval      prfree = 'Y'
     C                   endif

     C                   if        topick > 999
     C                   eval      prqty = 999
     C                   else
     C                   eval      prqty  = topick
     C                   endif
     C                   eval      prstat = $slstat
     C                   if        %subst($psubcmd:1:4) <> '*AVG'
     C                             and $psubcmd <> '*ORDQTY'
     C                   eval      praqs  = praqs + savqtyneeded
     C                   else
     C                   eval      praqs = qtyneeded
     C                   endif

     C                   exsr      getslotpos

     C                   update(e) prrec4
     C                   if        %error
     C                   endif

     C                   eval      lgprcrt  = 'U'
     C                   eval      lgprowhd = prwhdp
     C                   eval      lgproslt = prfdis
     C                   eval      lgproavl = slavl1
     C                   exsr      writelog

     C                   eval      updflag = *on
     C                   leave

     C                   enddo

610aAC                   endsr

510aA*----------------------------------------------------------------
510aA*  updprtyrplr  Update existing priority replenishment
510aA*----------------------------------------------------------------

510aAC     updprtyrplr   begsr

510aAC                   eval      updflag = *off
510aAC                   exsr      getdatetime

510aA*  Loop through existing priority replenishments for item.

510aAC     keypr4p       setll     prplfil4

510aAC                   dow       forever = forever

510aAC     keypr4p       reade(e)  prplfil4

510aAC                   if        %eof
510aAC                   leave
510aAC                   endif

510aAC                   if        %error
510aAC                   iter
510aAC                   endif

510aA*    Remove deleted records to keep file clean.

510aAC                   if        prflag = 'D'
510aAC                   delete(e) prrec4
510aAC                   if        %error
510aAC                   endif
510aAC                   iter
510aAC                   endif

510aA*    Remove active records older than 1 day.
510aA*    and not just-in-time replenishments.
650jA*    Also change to delete on-demand replenishments
650jA*    if not executed within a day since we now
650jA*    place a priority on these to prevent rebuild
650jA*    from deleting

650jMC*                  if        prflag = 'A' and
650jMC*                            prprty =  0
650jMC                   if        (prflag = 'A' and
650jMC                              prprty =  0)
650jAC                             or (prflag = 'A' and
650jAC                               prrplt = 'R' and
650jAC                               prprty <> 0)
510aAC                   Call      'CALCTIME'
510aAC                   Parm      '*DAYS'       calccmd           8
510aAC                   Parm      pradte        fromdate
510aAC                   Parm      pratim        fromtime
510aAC                   Parm      curdate       todate
510aAC                   Parm      curtime       totime
510aAC                   Parm      0             duration
510aAC                   if        duration > 1
510aAC                   delete(e) prrec4
510aAC                   if        %error
510aAC                   iter
510aAC                   endif
510aAC                   endif
510aAC                   endif

510aA*    If slot information doesn't match, then get next record.

650gA /free
510aA                    if        prwhdp <> rpkwhdp
510aA                              or prfdis <> rpkpslot
510aA  //                          or prtdis <> rpkslot
650gA                      or (%subst(prtdis:1:3)='RPK' and
650gA                         %subst(rpkslot:1:3)<>'RPK')
650gA                      or (%subst(prtdis:1:3)<>'RPK' and
650gA                         %subst(rpkslot:1:3)='RPK');
650gA /end-free
650gAc
510aAC                   iter
510aAC                   endif

700cA /free
700cA  // Verify current PRPLFIL record for Production replenishments
700cA  if ($psubcmd = '*CRTPRDRPL' or $psubcmd = '*CRTPRDQTY')
730bD     //AND prrplt <> 'D';
730bD     AND prrplt <> 'O';
700cA    iter;
700cA  endif;
700cA /end-free

510aA*    Otherwise, update existing priority replenishment record.

510aAC                   if        topick <> slavl1
510aAC                   eval      prfree = 'N'
510aAC                   else
510aAC                   eval      prfree = 'Y'
510aAC                   endif

530 AC                   if        topick > 999
530 AC                   eval      prqty = 999
530 AC                   else
510aAC                   eval      prqty  = topick
530 AC                   endif
510aAC                   eval      prstat = $slstat
510aAC                   eval      praqs  = savqtyneeded

510aAC                   update(e) prrec4
510aAC                   if        %error
510aAC                   endif

510aAC                   eval      lgprcrt  = 'U'
510aAC                   eval      lgprowhd = prwhdp
510aAC                   eval      lgproslt = prfdis
510aAC                   eval      lgproavl = slavl1
510aAC                   exsr      writelog

510aAC                   eval      updflag = *on
510aAC                   leave

510aAC                   enddo

510aAC                   endsr


650iA*----------------------------------------------------------------
650iA*  updprtyrplp  Update existing priority replenishment
650iA*----------------------------------------------------------------
650iA
650iAC     updprtyrplp   begsr
650iA
650iAC                   eval      updflag = *off
650iAC                   exsr      getdatetime
650iA
650iA*  Loop through existing priority replenishments for item.
650iA
650iAC     keypr4p       setll     prplfil4
650iA
650iAC                   dow       forever = forever
650iA
650iAC     keypr4p       reade(e)  prplfil4
650iA
650iAC                   if        %eof
650iAC                   leave
650iAC                   endif
650iA
650iAC                   if        %error
650iAC                   iter
650iAC                   endif
650iA
650iA*    Remove deleted records to keep file clean.
650iA
650iAC                   if        prflag = 'D'
650iAC                   delete(e) prrec4
650iAC                   if        %error
650iAC                   endif
650iAC                   iter
650iAC                   endif
650iA
650iA*    Remove active records older than 1 day.
650iA*    and not just-in-time replenishments.
650iA
650iMC                   if        (prflag = 'A' and
650iMC                              prprty =  0)
650iAC                   Call      'CALCTIME'
650iAC                   Parm      '*DAYS'       calccmd           8
650iAC                   Parm      pradte        fromdate
650iAC                   Parm      pratim        fromtime
650iAC                   Parm      curdate       todate
650iAC                   Parm      curtime       totime
650iAC                   Parm      0             duration
650iAC                   if        duration > 1
650iAC                   delete(e) prrec4
650iAC                   if        %error
650iAC                   iter
650iAC                   endif
650iAC                   endif
650iAC                   endif
650iA
650iA*    If breakdown replenishment request and record read is not
650iA*    for breakdown then skip
650iA
650iAc                   if        $brkqty <> 0 and prtype <> 'E'
     c                             or (prtype ='E' and $brkqty=0)
650iAc                   iter
650iAc                   endif
650iA
650iA*    If slot information doesn't match, then get next record.
650iA
650iA /free
650iA                    if        prwhdp <> rpkwhdp
650iA                              or prfdis <> sldisp
650iA                              or prtdis <> prdTslot;
650iA /end-free
650iAc
650iAC                   iter
650iAC                   endif
650iA
650iA*    Otherwise, update existing priority replenishment record.
650iA
650iAC                   if        topick <> slavl1
650iAC                   eval      prfree = 'N'
650iAC                   else
650iAC                   eval      prfree = 'Y'
650iAC                   endif
650iA
650iAC                   if        topick > 999
650iAC                   eval      prqty = 999
650iAC                   else
650iAc* kde 082914       select
650iAc* kde 082914       when      $psubCmd = '*CRTPRDQTY'
650iAC* kde 082914       eval      prqty  = prqty + topick
650iAc* kde 082914       other
650iAC                   eval      prqty  = topick
650iAc* kde 082914       endsl
650iAC                   endif
650iAC                   eval      prstat = $slstat
650iA
650iAC                   update(e) prrec4
650iAC                   if        %error
650iAC                   endif
650iA
650iAC                   eval      lgprcrt  = 'U'
650iAC                   eval      lgprowhd = prwhdp
650iAC                   eval      lgproslt = prfdis
650iAC                   eval      lgproavl = slavl1
650iAC                   exsr      writelog
650iA
650iAC                   eval      updflag = *on
650iAC                   leave
650iA
650iAC                   enddo
650iAC     *loval        setll     prplfil4
650iA
650iAC                   endsr
     *----------------------------------------------------------------
     *  verifycrt  Verify information when trying to create replenishment
     *----------------------------------------------------------------

     C     verifycrt     begsr
500bA
500bA*  If *AVGnnn sent, verify that nnn is numeric.
500bA
500bAC                   if        %subst($psubcmd:1:4) = '*AVG'
500bAC                             and $psubcmd <> '*AVGQTY'
500bA
500bAC                   eval      $cvstr =  %subst($psubcmd:5:3)
640bDC*                  call      'CVTNUM'
640bMC                   call      'CVTNUMB'
500bAC                   parm      '*STR2NUM'    $cvcmd            8
500bAC                   parm                    $cvstr           30
500bAC                   parm      0             $cvnum           15 5
500bAC                   parm      0             $cvdec            1 0
500bAC                   parm                    $cvrtn            8
500bA
500bAC                   if        $cvrtn = '*ERROR'
500bAC                   eval      error = *on
500bAC                   eval      $preturn = 'INVLDPCT'
500bAC                   exsr      getmsg
500bAC                   exsr      writelog
500bAC                   goto      endvfycrt
500bAC                   endif
500bA
500bAC                   if        $cvnum > 0
500bAC                   eval      avgpct = $cvnum / 100
500bAC                   else
500bAC                   eval      avgpct = 0
500bAC                   endif
500bA
500bAC                   endif

     *  Item must be sent.

     C                   if        not $pritemu
     C                   eval      error = *on
     C                   eval      $priteme = '1'
     C                   eval      $preturn = 'ITMNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
700fA
700fA*  Check if *EACH item number sent
700fA
700fAC                   eval      eachPos = %scan($pritem: '*E')
700fAC                   if        eachPos > 0
700fAC                   eval      eachRPL = *on
700fAC                   eval      eachItem = $pritem
700fAC                   eval      $pritem = %subst($pritem: 1: eachPos-1)
700fAC                   endif

     *  Get/Verify item.

     C                   eval      check4err = *on
     C                   eval      $drisubcmd = '*GETALL'
     C                   eval      item# = $pritem
     C                   exsr      getitem
     C                   if        error
     C                   eval      $priteme = '1'
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Only create replenishments for following item types ...

     *    - Fixed Normal, Fixed Breakdown or PIR Breakdown.

510 D ***                if        $itstyp = 'F'  and
510 D ***                          $ittype <> ' ' and $ittype <> 'B'  or
510 D ***                          $itstyp = 'P' and $ittype <> 'B'
510 D ***                eval      error = *on
510 D ***                eval      $preturn  = 'WRONGITYP'
510 D ***                exsr      getmsg
510 D ***                exsr      writelog
510 D ***                goto      endvfycrt
510 D ***                endif

510 MC                   if        $itstyp = 'F'  and
510 MC                             $ittype <> ' ' and
510 MC                             $ittype <> 'B' and
510 MC                             $ittype <> 'R' or
510 MC                             $itstyp = 'P'  and
510 MC                             $ittype <>'B'  and
510 MC                             $ittype <>'R'
510 MC                   eval      error = *on
510 MC                   eval      $preturn  = 'WRONGITYP'
510 MC                   exsr      getmsg
510 MC                   exsr      writelog
510 MC                   goto      endvfycrt
510 MC                   endif

     *  Quantity needed can't be sent for *CRTRPLDKA.

500bDC**                 if        $prqtynu and $psubcmd = '*CRTRPLDKA'
500bMC                   if        $prqtynu and
500bMC                             ($psubcmd = '*CRTRPLDKA' or
500bAC                              %subst($psubcmd:1:4) = '*AVG')
700 Ac                              and $driprogram <> 'LT110F'
     C                   eval      error = *on
     C                   eval      $prqtyne = '1'
     C                   eval      $preturn = 'QTYNSENT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
500 A
500 A*  Quantity needed can't be sent for *CRTRPLDKO.
500 A
510aAC                   if        $ittype <> 'R'
500 AC                   if        $prqtynu and
500bAC                             ($psubcmd = '*CRTRPLDKO' or
500bAC                              $psubcmd = '*ORDQTY')
500 AC                   eval      error = *on
500 AC                   eval      $prqtyne = '1'
500 AC                   eval      $preturn = 'QTYNSENTO'
500 AC                   exsr      getmsg
500 AC                   exsr      writelog
500 AC                   goto      endvfycrt
500 AC                   endif
510aAC                   endif

     *  Quantity needed must be sent if slot is not sent.

500bDC**                 if        $prslotu and not $prqtynu
500bMC                   if        not $prslotu and not $prqtynu
     C                   eval      error = *on
     C                   eval      $prqtywe = '1'
     C                   eval      $preturn = 'QTYNOTSNT'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  Quantity needed can't be negative.

     C                   if        $prqtynu and $prqtyn < 0
     C                   eval      error = *on
     C                   eval      $prqtyne = '1'
     C                   eval      $preturn = 'NEGATIVQTN'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  Warehouse quantity can't be negative.

     C                   if        $prqtywu and $prqtyw < 0
     C                   eval      error = *on
     C                   eval      $prqtywe = '1'
     C                   eval      $preturn = 'NEGATIVQTW'
     C                   exsr      getmsg
     C                   goto      endvfycrt
     C                   endif

     *  If department and slot not sent, nothing else to verify.

     C                   if        not $prwhdpu and not $prslotu
     C                   goto      endvfycrt
     C                   endif

     *  Department and slot must be sent together.

510aAC                   if        $ittype <> 'R'
     C                   if        $prwhdpu or $prslotu
     C                   if        not $prwhdpu or
     C                             not $prslotu
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'FLDNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
     C                   endif
510aAC                   endif

     *  Verify department that was sent.

     C                   eval      vfywhdp = *on
     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHDP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   endsl

510aAC                   if        $ittype = 'R'and not $prslotu
510bAC                   goto      endvfycrt
510aAC                   endif

     *  Get slot information

     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $prwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = $prwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = $prslot

     C                   eval      drislot = *on
     C                   exsr      drislotsr
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*GET'        $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*    $slot         parm      $slot         $dridata

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'DRISLOT'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   when      $drireturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = $drireturn
     C                   eval      $pmessage = $drimessage
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt

     C                   endsl

     *  Slot doesn't contain item.

     C                   if        $slitem <> $pritem
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'WRONGITEM'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Slot not a pick slot.

     C                   if        $slpick <> 'Y'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'NOTPICKSLT'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif

     *  Slot is PIR but not reserved.

     C                   if        $slstyp = 'P' and $slrsrv <> 'Y'
     C                   eval      error = *on
     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'PIRNOTRSRV'
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog
     C                   goto      endvfycrt
     C                   endif
700fA*  See if slot is an *EACH slot.

700fA /free
700fA    chain ($slwhse: $slsdef) slotdef;
700fA    if %found(slotdef) and sdpal = '*EACH';
700fA      eachRPL = *on;
700gD      //eachItem = %trim($slitem) + '*EACH';
700gA      eachItem = %trim($slitem) + '*E';
700fA    endif;
700fA /end-free

     C     endvfycrt     endsr

     *----------------------------------------------------------------
     *  verifygen   General verification.
     *----------------------------------------------------------------

     C     verifygen     begsr

     *  Clear log fields

     C                   clear                   lgprrec

     *  Clear error flags.

     C                   exsr      clearerrflags

     *  Warehouse must be sent.

     C                   if        not $prwhseu
     C                   eval      error = *on
     C                   eval      $prwhsee = '1'
     C                   eval      $preturn = 'WHSNOTSNT'
     C                   exsr      getmsg
     C                   exsr      writelog
     C                   goto      endvfygen
     C                   endif

     *  Verify warehouse.

     C                   eval      vfywhse = *on
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHSE'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endvfygen

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $slwhsee = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   exsr      writelog
     C                   goto      endvfygen

     C                   endsl

     C     endvfygen     endsr

510aA*----------------------------------------------------------------
510aA*  verifyph2   General verification for phase 2. (parent repack)
510aA*----------------------------------------------------------------

510aAC     verifyph2     begsr

510aA*  Demand quantity required.

     C                   if        $prqtyn <= *zeros

     C                   eval      $prslote = '1'
     C                   eval      $preturn  = 'QTYREQ   '
     C                   exsr      getmsg
     C                   eval      lgprhwhd = $prwhdp
     C                   eval      lgprhslt = $prslot
     C                   exsr      writelog

     C                   endif

     C     endvfyph2     endsr


650iA*----------------------------------------------------------------
650iA*  verifyprd   General verification for Production
650iA*----------------------------------------------------------------
650i
650iAC     verifyprd     begsr
650i
650iA*  Demand quantity required.
650i
650i C                   if        $prqtyn <= *zeros
650i C                              and $brkqty <= *zeros
650i
650i C                   eval      $prslote = '1'
650i C                   eval      $preturn  = 'QTYREQ   '
650i C                   exsr      getmsg
650i C                   eval      lgprhwhd = $prwhdp
650i C                   eval      lgprhslt = $prslot
650i C                   exsr      writelog
650i
650i C                   endif
650i
650i C     endvfyprd     endsr

730bA*----------------------------------------------------------------
730bA*  verifydd  Verify Drop Pick values for Replenishment
730bA*----------------------------------------------------------------
730bA
730bAc     verifydd      begsr
730bAC     endvfydd      endsr

     *----------------------------------------------------------------
     *  verifyrmv   Verify information when removing replenishments.
     *----------------------------------------------------------------

     C     verifyrmv     begsr

     *  Department can be blank or *ALL.

     C                   if        not $prwhdpu or
     C                             $prwhdp = ' ' or
     C                             $prwhdp = '*ALL'
     C                   goto      endvfyrmv
     C                   endif

     *  Verify department that was sent.

     C                   eval      vfywhdp = *on
     C                   call(e)   'VFYWHDP'
     C                   parm      '*VERIFY'     $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk

     C                   select
     C                   when      %error
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn  = 'CALLERROR'
     C                   eval      $pmessage = 'Error occured on call to '
     C                                       + 'VFYWHDP'
     C                                       + '/' + %trim($vcommand)
     C                                       + ' from ' + #prog
     C                   exsr      writelog
     C                   goto      endvfyrmv

     C                   when      $vreturn <> '*OK'
     C                   eval      error = *on
     C                   eval      $prwhdpe = '1'
     C                   eval      $preturn = $vreturn
     C                   eval      $pmessage = $vmessage
     C                   eval      lgprhwhd = $prwhdp
     C                   exsr      writelog
     C                   goto      endvfyrmv

     C                   endsl

     C     endvfyrmv     endsr

     *----------------------------------------------------------------
     *  writelog    Write record to priority replenishment log file
     *----------------------------------------------------------------

     C     writelog      begsr

     C                   exsr      getdatetime

     C                   eval      lgprwhse = $prwhse
700gAc                   if        eachRpl
700bAC                   eval      lgpritem = eachItem
700gAc                   else
     C                   eval      lgpritem = $pritem
700gAc                   endif
     C                   eval      lgprdate = curdate
     C                   eval      lgprtime = curtime
     C                   eval      lgprscmd = $psubcmd
     C                   eval      lgprpgm  = $pprogram
     C                   eval      lgprfill = $prfill

     C                   eval      lgprrtn  = $preturn
     C                   eval      lgprmsg  = $pmessage
     C                   eval      lgprdata = $prtyrpl

     C                   write(e)  lgprrec
     C                   if        %error
     C                   endif

     C                   endsr

500gA*----------------------------------------------------------------
500gA*----------------------------------------------------------------
500gA*                     DRI SUBROUTINES
500gA*----------------------------------------------------------------
500gA*----------------------------------------------------------------

     *----------------------------------------------------------------
     *  zzzclose  Close open programs
     *----------------------------------------------------------------

     C     zzzclose      begsr

     C                   if        drislot
     C*                  call(e)   'DRISLOT'
     C*                  parm      '*CLOSE'      $drisubcmd
     C*                  parm      $pprogram     $driprogram
     C*                  parm      ' '           $drireturn
     C*                  parm      ' '           $drimessage
     C*                  parm      ' '           $dridata
     C                   endif

     C                   if        driitem
     C                   call(e)   'DRIITEM'
     C                   parm      '*CLOSE'      $drisubcmd
     C                   parm      $pprogram     $driprogram
     C                   parm      ' '           $drireturn
     C                   parm      ' '           $drimessage
     C                   parm      ' '           $dridata
     C                   endif

     C                   if        vfywhdp
     C                   call(e)   'VFYWHDP'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      $prwhdp       $vwhdp
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   endif

     C                   if        vfywhse
     C                   call(e)   'VFYWHSE'
     C                   parm      '*CLOSE'      $vcommand
     C                   parm      '*NONE'       $vprg
     C                   parm      $prwhse       $vwhse
     C                   parm      ' '           $vdesc
     C                   parm      ' '           $vreturn
     C                   parm      ' '           $vmessage
     C                   parm      ' '           $vmsgk
     C                   endif

     C                   endsr
730bA
730bA*----------------------------------------------------------------
730bA*  zzUpQty  Up Quantity from breakdown 1 if it exists
730aA*----------------------------------------------------------------
     C     zzupQty       begsr
730bA
730bA /free
730bA       // check for negative quantities
730bA       *in49=*off;
730bA       if newqtyn<0;
700bA          *in49=*on;
730bA          newqtyn = %abs(newqtyn);
730bA       endif;
730bA       if newqty1<0;
730bA          *in49=*on;
730bA          newqty1 = %abs(newqty1);
730bA       endif;
730bA
730bA       dow $itumq2 > 0 and +
730bA           newqty1 >= $itumq2;
730bA          newqty1 -= $itumq2;
730bA          newqtyn += 1;
730bA       enddo;
730bA
730bA       if *in49;
730bA          newqtyn = newqtyn * -1;
730bA          newqty1 = newqty1 * -1;
730bA       endif;
730bA /end-free
730bA
     C                   endsr
750eA
750eA*----------------------------------------------------------------
750eA*  calcMAxCube  - Calc Max cube that will fit in Drop Pick slot
750eA*                 If max is exceeded return Max Cube Quantity.
750eA*                 Order Allocation will send indiividual order as
750eA*                 Bulk Pick if it's entire quantity cannot fit
750eA*----------------------------------------------------------------
750eAC     calcMaxCube   begsr
750eA
750eA /free
750eA    monitor;
750eA     // get slot type for passed in Drop Pick sLot
750eA     exec sql select slsdef into :s_slsdef
750eA             from slot2
750eA       where slwhse=:slwhse and slwhdp=:$prwhdp and sldisp=:s_sldisp
750eA         and slstat='DP' fetch first row only;
750eA     // calc max cube per slot type
750eA     holdsdcode = sdcode;
750eA     chain (slwhse:s_slsdef) slotdef;
750eA     if not %found(slotdef);
750eA       // keep calculated value since slot def not defined
750eA       chain (slwhse:holdsdcode) slotdef;
750eA       leavesr;
750eA     else;
750eA       // if slot dimensions are zero return same quantity
750eA       if (sdlen*sdwdth*sdhgt)=0;
750eA         chain (slwhse:holdsdcode) slotdef;
750eA         leavesr;
750eA       endif;
750eA       // now determine Max Quantity slot will hold per the
750eA       // item defined Cube
750eA       if $itcube <> 0;
750eA         if topick > (sdlen*sdwdth*sdhgt)/1728/$itcube;
750eA           topick = ((sdlen*sdwdth*sdhgt)/1728/$itcube-1);
750eA         endif;
750eA       endif;
750eA       chain (slwhse:holdsdcode) slotdef;
750eA     endif;
750eA   on-error;
750eA     // if any errors occur in this routine it will essentially return
750eA     // the same topick that came into the routine and create replenishment
750eA     // for original quantity.
750eA   endmon;
750eA /end-free
750eA
750eAC                   endsr
