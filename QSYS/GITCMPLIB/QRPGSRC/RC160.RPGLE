730bD */COPY *libl/qcopysrc,hspecs
730bM /COPY *libl/qcopysrc,hspecstrnc
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  RC160     Receiving/Returns automatic put-away.
     *  07 November 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    11/11/94  DAS
     *      - Added logic to make sure breakdown qty's are not greater
     *        than unit of measure quantity.
     *      - Sending picking slot to label program.
     *
     *    11/18/94  DAS
     *      - Added PUTPR routine for PIR picks.
     *      - Changed PUTPCK routine to try and put as many full
     *        pallets as it could into the picking slot.
     *
     *    12/05/94  DAS
     *      - Post routine was using counter X for two differeent
     *        loops. Changed the first loop to use Y.
     *      - Changed TRYFIX and TRYPIR routines to leave after one
     *        slot is used instead of trying to fill up more slots of
     *        the same type. Reason: The quantity to be put in the
     *        slot (DSSQTY) was not be recalculated correctly.
     *      - Within POST routine moved the PO and order file update
     *        to the end of the routine. Moved the retreiving of the
     *        next PO detail seq# to the beginning of the routine.
     *      - Added the 'N' option to the chain and read statements
     *        for POH and POD so the records would not be locked.
     *      - Added line to PUTABV routine to ignore pick slots.
     *
     *    12/19/94  DAS
     *      - Revised PUTPR routine to put away as much as it can
     *        into reserved slot instead of full pallets.
     *
     *    12/21/94  DAS
     *      - Revised AWYFIX and AWYPIR to always call PUTPCK.
     *      - Revised how EMPTYQ was being calculated in PUTPCK
     *        and PUTPR.
     *      - Revised PUTPCK to contain conditions on when a pick
     *        slot can be used for put-away.
     *
     *     1/15/95  DAS
     *      - Revised PUTPCK and PUTPR to initialize SLENTD if it
     *        is zero.
     *
     *    02/21/95  DAS
     *      - Revised AWYPIR to call PUTPCK only for *RETURN.
     *      - Revised POST routine to assign a batch number to a
     *        set of labels.
     *      - Revised main line to return the batch number in the
     *        order number parameter.
     *      - Revised INIT routine to default the highest rack
     *        level to 10 and move call to RECALC to end of routine.
     *      - Revised PUTPR routine to quit if EMPTYQ <= 0.
     *
     *    03/06/95  DAS  2.10
     *      - Added empty percentage to SVGRP data structure.
     *      - Increased OCR array to a length of 9.
     *      - Revised RECALC to calculate and save the empty
     *        percentage of a slot tie/high definition so they
     *        can be sorted correctly.
     *
     *    03/09/95  DAS  2.10
     *      - Added flag field to SVGRP data structure.
     *      - Increased OCR array to a length of 10.
     *      - Revised RECALC to move a '1' to the flag field if
     *        only 1 pallet is needed but it doesn't meet the usage
     *        percentage wanted by user.
     *
     *    06/21/95  DAS  2.10
     *      - Added designation check to PUTABV routine.
     *
     *    08/21/95  DAS  2.10
     *      - Revised routine PUTACT to check quantities instead
     *        of entered date.
     *
     *    01/12/96  DAS  2.10
     *      - Revised to call ADDSTDTRN to add a record to PIRTRAN.
     *
212 A*    04/26/96  DAS  2.12
212 A*      - Revised label program parameter list.
     *
213 A*    05/21/96  RH   2.13
     *      - Added parameter $PSLOT.
     *      - Initialized new label fields LBGRP1, LBGRP2, LBRDTE
     *        and LBQAVL.
     *      - Added new transaction fields to parms (@PGRP1, @PGRP2)
     *      - Added new $PCMD codes.
     *      - Made sure all records were unlocked before leaving.
     *      - Revised PUTPR routine to set PRFLAG if a PIR reserved      GFG
     *        slot exists.                                               GFG
     *      - Revised TRYPIR routine to set SLPRTY to 9- if PRFLAG is    GFG
     *        on.                                                        GFG
     *      - Revised AWYFIX to utilize new field SLSIDE.
     *      - Removed ORRTN logic and moved it into RN120.
     *
217 A*    11/06/96  RH   2.17
     *      - Added PRFIND flag (item exists in PIR)
     *      - Revised to only use asile options if PRFIND is on.
     *      - When force same aisle, if item exists, must put in same
     *        aisle.  If no item exists, put in available slot and
     *        additional quantities of item must go in same aisle.
     *
217 A*    01/08/97  DAS  2.17
     *      - Added SLT array index check to PUTPIR and PUTUPR.
     *
218 A*    01/13/97  RH   2.18
     *      - Change to POHDR & PODTL files from POH & POD files.
     *      - Added $PSEQ parameter.
     *      - Added $PRPCK parameter.
     *      - Added $PPLBL parameter.
     *      - Revised POST to update PODTL if record exists.
     *      - Processes both manual and PO receiving.
     *
218 A*    01/24/97 HNK
     *      - Added parameter @PCMD with '*CREATE' to call ADDSTDTRN
     *        program.
     *
219 A*    03/11/97  RH   2.19
     *      - Added $PDWGT parameter.
     *
402 A*    07/15/97  HNK  4.02
     *      - Item with 0 tie/high value ignored for putaway.
     *
TMP A*    07/22/97  DAS  TMP
     *      - Temporary fix for AFI.
     *      - Created routine PUTSLT to putaway quantity sent into
     *        the slot number the user sent.
     *      - This assumes that the user is only sending the quantity
     *        that will fit into the slot.  Tie/Highs are not checked
     *        or printed.
     *
404 A*    09/04/97  HNK  4.04
     *      - Revised to work with cross dock line item.  Cross dock
     *        items have a record in the Crossdk file.
     *
405 A*    09/16/97  DAS  4.05
     *      - Revised to automatically close cross dock transactions.
     *
406 A*    09/29/97  RH   4.06
     *      - Change z-add to add weight to accumulate for PODTL update.
     *
407 A*    11/14/97  DAS  4.07
     *      - Revised PUTACT routine to ignore slot usage percentage as
     *        a criteria for using an active reserved slot.
409 A*    02/12/98  RH   4.09
     *      - Add CHKVSL routine to check if slot has virtual's for item
     *      - If virtual slot exists, by pass slot for put away.
     *      - Correct error, clear PO Detail rec before writing.
410 A*    09/22/98  RH/DAS
     *      - Revised logic for finding highest level in INIT routine.
     *        It now assumes that a rack code ending with an '*' is
     *        defining levels 11-20 for the corresponding rack code
     *        without the '*'.
     *
411 A*    05/26/99  DAS  4.11
     *      - Revised to deal with new item types.
     *      - All ITUMQ2 and ITUMQ3 fields have be changed to
     *        #BUMQ2 and #BUMQ3, respectively.
     *      - Created new routine to check for multiple slots
     *        for an item (CHKMLT)
     *      - Revised PUTPCK to call above routine instead of
     *        trying to determine if an item has multiple slots
     *        using the available quantities (That method does
     *        not work with Contract items).
     *
412 A*    08/17/99  MLB  4.12
     *      - Revised to assign fixed items to pick slots if
     *        item doesn't already have one.
     *      - Revised to allow put away to multiple pick slots.
412AA*    08/24/99  MLB  4.12A
     *      - Created two new routines: PUTLST put in last active
     *        pick slot. PUTAPK put in available empty active
     *        pick slots.
     *      - Revised AWYFIX to call PUTLST and PUTAPK for *RECEIVE
     *        option only.
     *
412bA*    08/26/99  DAS  4.12b
     *      - Revised AWYPIR to use PUTLST and PUTAPK routines instead
     *        of PUTPR which only put product into a single active
     *        slot for the item.
     *      - Revised expiration date check in PUTLST to check the
     *        item's expiration date flag.
     *      - Revised PUTLST routine to allow product to be put into
     *        slots with same expire for date sensitive items. For
     *        non-date sensitive items wor
     *
412cA*    - Unconditionally put returns into pick slot.
412dA*    09/07/99  MLB  4.12d
     *      - Created new routine PUTAOF to allow product with same
     *        entered date/expiration date to be received into a
     *        active overflow slot.
412eA*    09/15/99  MLB  4.12e
     *      - Revised to assign fixed items to pick slots if
     *        item doesn't already have one (ASNSLT).
     *      - Revised to allow put away to multiple pick slots.
412fA*    09/29/99  DAS  4.12f
     *      - Revised PUTPCK routine to only update Entered date
     *        when it is zero.
     *
413aA*    09/17/99  MLB  4.13a
     *      - Revised to add file PIRTRCK1 to pgm to track receiving
     *        processing.
413bA*    10/01/99  MLB  4.13b
     *      - Revised to add file DESIG to pgm to allow items with soft
     *        designation codes to be put into slots without a
     *        designation code.
413cA*    12/01/99  MLB  4.13c
     *      - Revised routine INIT to allow pick slots to be assigned
     *        when $PCMD = *RETURN.
413dA*    01/20/99  DAS  4.13d
     *      - Revised sizes of TRSQ variables to 5.0 from 3.0.
413eA*    01/24/00  DAS  4.13d
     *      - Revised routine TRYFIX to use BFRLOC and AFTLOC when
     *        determining if a slot was found. BFRDIF and AFTDIF did
     *        not work correctly if the slot found was the same
     *        location as the pick slot but a different handstack.
     *        In that case, the difference would be zero.
     *
415 A*    06/30/01  DAS  4.15
     *      - Revised routine AWYPUT to call PUTLST when MLTFLG=*ON.
     *
     *
416 A*    12/12/01  DAS  4.16
     *      - Added *RCVLBL option OPIPCK.
     *      - Used new option to skip executing PUTLST routine so
     *        product will not be putaway into and existing pick slot
     *        for an item. Originally created for Strano Sysco.
     *
416aA*    11/01/01  RH   4.16a
     *      - If $PPO is *NOSTOCK for returns, no putaway is done,
     *        Label allocated = returned qty, label pick = 0 put away.
     *      - ORRTN file changed.                                     e
     *
416bA*    01/24/02  DAS  4.16
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZS2D, ZZZCOP
     *
416cA*    02/08/02  DAS  4.16c
     *      - Added xdock DRI interface.
     *
416dA*    02/25/02  DAS  4.16d
     *      - Revised an IF statement within PUTXDR.
     *      - Added call to RECALC within PUTXDR.
     *      - Revised PUTXDR to call *XDOCK with *RECEIVE.
     *      - Revised UNDO to call *XDOCK with *RECEIVE.
     *
416eA*    02/25/02  MLB  4.16e
     *      - Revised routines ZZZCOP, ZZZFS1, ZZZS2D, ZZZX2D to
     *        add tracking support.
     *
416fA*    03/01/02  DAS  4.16f
     *      - Added *FEATURE option.
     *      - Replaced routine PUTXDR with routines PUTXFL and PUTXLC.
     *      - Revised to put crossdock quantity into pick slot when
     *        working with a Locator system and quantity was retrieved
     *        from host.
     *
416gA*    06/11/02  DAS  4.16g
     *      - Changed A$LIC# from 7.0 to 15.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
     *
417bA*    01/21/04  DAS  4.17b
     *      - Added command *MOVEINP.
     *      - Added command *MOVEINO.
417cA*    02/25/04  RH   4.17c
     *      - Added parm $PFIFO for MOVEIN FIFO entered date
417dA*    08/12/04  RH   4.17d
     *      - Fix: Revised to call GETBASE for type A alias items.
     *             Changed the parms used for GETSLOTITM to #S, GETBASE
     *             will use #B parms.                                 E
     *             Move qty to corresponding base breakdown qty for   E
     *             Alias items tied to a type 'S' same slot breakdown E
500aA*    12/27/04  RH   5.00a
     *      - ENH:Added command *SPRECV .
500bA*    12/29/04  RH   5.00b
     *      - ENH:Return error if no pick slots for *SPRECV.
     *      - ENH:Allow no tie/high for *SPRECV.
     *
610aA*    08/26/09  DAS  6.10a  P#00045
     *      - Converted to ILE
     *      - Old commented code removed for clarity.
     *      - See 610 notes below.
     *
610bA*    10/20/09  DAS  6.10b
     *      - Added logic to check slot usage by calling CHKUSAGE,
     *        which will any item in the physical slot, associated
     *        virtual slots, and associate RCV slots.
     *
610cA*    10/21/09  DAS  6.10c
     *      - Revised logic to take into account that even when using
     *        Directed putaway, we can end up with Virtual slots.
     *
610dA*    10/21/09  DAS  6.10d
     *      - Revised Recalc to always set dssqty to 1 pallet's qty.
     *
610fA*    10/21/09  DAS  6.10f
     *      - Revised to use dsposf instead of dspos to calculate dstqty.
     *
640aA*    09/28/12  DAS  6.40a
     *      - Revised chkusage routine to take savslt array into account.
     *        CHKUSAGE looks for RCV slots, but they must be associated
     *        with a label record. But, we don't create label records
     *        until the end.
     *
640bA*    09/28/12  DAS  6.40b
     *      - Revised to reinstate date checks so it will be consistent.
     *        with original version.
     *
640cA*    09/28/12  DAS  6.40c
     *      - Revised putabv to check for diff item and dates. it didn't
     *        have to do this before because it used to read unoccupied
     *        slots. Now it will grab a pushback slot that has an empty
     *        pallet position.
     *      - Writing out tracking record when slot skipped because
     *        it has a different item in it.
     *
640dA*    10/02/12  DAS  6.40d
     *      - Revised some qwyfix to loop and reset pointer after
     *        putting a pallet away.
     *      - Revised tryfix to ignore slots like putabv does.
     *
640eA*    10/02/12  DAS  6.40e
     *      - Extra change to complete 610d change.
     *
640fA*    10/06/12  DAS  6.40f
     *      - Revised CHKMLT to ignore special BFC slots.
     *
640gA*    10/07/12  DAS  6.40g
     *      - Revised parameters to chkusage.
     *      - Added chkusage logic to trypir.
     *
640hA*    10/09/12  DAS  6.40h
     *      - Revised awypir to try to put item into first pick slot
     *        for *SPRECV, which is what awyfix does.
     *
640iA*    10/09/12  DAS  6.40i
     *      - Added cmd *RECEIV1 for receiving a single pallet without
     *        splitting qty. This was created for UCI Receiving where
     *        we receive a single pallet at a time.
     *
640jA*    10/11/12  DAS  6.40j
     *      - Revised to put item (not qty) into slot and take actual
     *        slot and put it into label record. This is done during
     *        posting. This will allow selection to pick from the slot
     *        before pallet is put away.
     *
640kA*    11/16/12  LMC  6.40k
     *      - Revised so *RECEIV1 sets the pttask correctly
     *      - Added *RETURN1
650aA*    06/05/13  LMC  6.50a
     *      - NOTE: This program is no longer used if the return being
     *      processed is NOT GOING TO IMPACT INVENTORY. We will use
     *      RN246L to do the processing of the license/label/pirtran
     *      for these type of returns.
650bA*    07/24/13  LMC  6.50b
     *      - Fix: *RECEIV1 was not updating the po files.
650cA*    09/20/13  LMC  6.50c
     *      - Fix: Program was blowing up with duplicate key in label.
650dA*    03/09/14  LMC  6.50d
     *      - Fix: UCI receiving *RECEIV1 needs to also look for
     *      active overflow slots, for double pallet slot.
650e *    03/11/14  GJA  6.50e
     *      - Fix: PIR items were not getting in the proper slots
     *      when receiving individual pallets.
650f *    03/31/14  LMC  6.50f
     *      - Fix: Added *RECEIV1 to some logic that was only
     *      executing on *RECEIVE command.
650g *    04/25/14  GJA  6.50g
     *      - Enh: Changed SLOT3 to SLOT13 so it would sort in
     *      expired date descending and entered date descending.
650h *    05/09/14  LMC  6.50h
     *      - Fix: Field LBASL2 was being wiped out by blank SAVAS2
     *      field. Conditioned the moving of SAVAS2 into the LBASL2
     *      field if the SAVAS2 field is not blank.
650i *    06/17/14  LMC  6.50i
     *      - Fix: For High tracking item we need to use the base slot
     *      for determining usage, and storing the putawy location
     *      in the label record. We were having problems when the
     *      virtual slot was put into the label record on directed.
650j *    11/21/14  LMC  6.50j
     *      - Fix: Need to write batctl records when we return from
     *      the call to PIRBAT# retrieving the next batch# to be used.
650kA*    01/09/15  MLB  6.50k  Missed in 6.50 update.
     *      - Enh: Added client custom code support to program.
     *      - Note: Removed getclient call from mainline and added
     *        to *INZSR routine. Was part of WST mod.
700aA*    12/29/15  LMC  7.00a
     *      - Enh: Additional logic when Receiving label print program
     *        begins with RFMT.(OPLPGM)
     *
700bA*    01/07/16  LMC  7.00b
     *      - Fix: While working on returns, we found that the
     *        receiving labels were being generated if the client was
     *        using directed putaway, when they are not needed if the
     *        Receiving option Use Generic License is 'Y'.
     *        This fix will no longer produce useless spool files.
700cA*    02/16/16  MLB/RH  7.00C
     *      - Fix: Change POST s/r to not create slot if current
     *        slot status is 'Z' for *SPRECV only. PUTPCK was updating
     *        slot and quantity correctly but if slot was zero, POST
     *        was creating new virutal slot.
700eA*    05/27/16  LMC  7.00e
     *      - Enh: Additional logic for Branded Items.
     *        From Receiving we will send in the branded Item.
     *        Need to identify if item sent in is a branded Item.
     *        We use GetBranded to identify the parent Item.
     *        If branded Item - we need to update/add a PODTL record
     *        for both the parent and branded Items.
700fA*    06/27/16  LMC  7.00f
     *      - Reserved - UCI Tracking
700gA*    10/26/16  JCJ  7.00g
     *      - Enh: added brand to RFMT
720aA*    06/27/16  LMC  7.20a   Reserved
     *      - UCI Tracking - New Item tracking level 'U'
     *
730aA*    11/01/19  LMC  7.30a
     *      - Add incoming user parm. This will allow us to use the
     *        actual user from gui instead of the #curruser of the job
730bA*    11/02/19  MLB  7.30b
     *      - Fix: Revised pgm to use /copy spec, hspectrnc instead of
     *        hspecs. Pgm was failing at stmt# 7411.00 z-add slots into
     *        dsupct. Found at SWT.
740aA*    06/29/20  LMC  7.40a
     *      - Enh: Clients using item license plates, and pick slot
     *        receiving, should not get an item license generated.
     *      - Add incoming pick slot receiving parm.
     *
411 A*----------------------------------------------------------------
     *----------------------------------------------------------------
     * Westside Custom Mods
WSTa *   04/01/14  LMC  WSTa
     *     - Ignore different entered date returned from chkusage
     *     - set field to N for this client.
     *     - they now want to mix dates in multiple pallet slots.
     *     - pass date from uci to drislot on DPPUT.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: HM Wagner
     *
HMW A*    01/09/15  MLB  HMW
     *      - Enh: Revised pgm to create special order pick slot or
     *        JIT pick slot for items with one of the following Desig-
     *        nation codes assigned: JITC, JITM, JITP, SPECC, SPECD or
     *        SPECF. If item already has pick slot assigned, then
     *        nothing further is done.
     *      - Added file: SLOT5.
     *      - Per Roxanne H. conference call on 01/08/2015.
     *
     *----------------------------------------------------------------
     *  Quantity Types Notes
     *
411 A*   Contract
     *     - Quantity received is added to the warehouse stock
     *       quantity of the Contract item.
     *     - Quantity received is added to the warehouse stock
     *       and allocated quantities of the Base item.
     *     - Slot record will contain Base item number.
     *     - Quantity recieved is added to the slot's stock
     *       quantity.
     *     - Label record will contain Contract item number.
     *     - Label record type will correspond to quantity type being
     *       received (Normal, Brk1, Brk2).
     *
     *   Same Slot Breakdown (SSB) Item
     *     - Quantity is received into Base item warehouse/slot
     *       breakdown quantities (ie. a normal qty being recieved will
     *       go into the warehouse/slot breakdown 1 quantity).
     *     - Slot record will contain Base item number.
     *     - Label record will contain SSB item number.
     *     - Label record type will correspond to warehouse/slot
     *       quantity being used internally (ie. a normal qty being
     *       received will be put into the warehouse/slot breakdown 1
     *       quantity and would therefore have a label type of '2'.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FoodPro
     *
FPR A*    04/28/15  MLB  FPR
     *      - Enh: Revised pgm to create special order pick slot when
     *        $PCMD = *SPRECV. Slot will be based on department of item:
     *        CLR=C SO, DRY=D SO and FRZ=F SO. If item has pick slot
     *        assigned, then nothing further is done.
     *      - Per Roxanne H. email 04/24/2015.
FPRaA*    07/26/16  MLB  FPRa
     *      - Enh: Revised FPR mod. Change program to check for XDK slot.
     *        If XDK slot found, use it for *SPRECV otherwise create SO
     *        slot as described in mod FPR. Chg was needed because rcv
     *        process would create SO slot and order process was creating
     *        XDK process. At end of night, XDK slot would be negative
     *        and SO slot would be positive,requiring a manual transfer
     *        to negate the stranded slots.
     *
     *----------------------------------------------------------------
     *  Misc Notes
     *
411 A*    - Each item defined in the PIRITEM file, no matter the type,
     *      must contain its own detail information (ie. Description,
     *      Dimensions, Weight, Tie/Highs, Etc . . .).  This program
     *      will always deal with the Item information for the item
     *      that was sent into the program (the item being received).
     *      In the case of Alias, Contract and Same Slot Breakdown
     *      items the information should be identical to its
     *      corresponding Base item.
     *
417bA*    - *MOVEINP is used with the special "MOVE IN PICK" PO.
     *      This command will try to put the sent quantity into a
     *      pick slot, regardless if there is already existing
     *      overflow for the item. It does this by forcing the
     *      MLTFLG to *OFF in the AWYFIX routine.
     *
417bA*    - *MOVEINO is used with the special "MOVE IN OVERFLOW" PO.
     *      This command will only put the sent quantity into
     *      overflow slots.
     *
610aA*    - SLRCV buckets no longer used. Instead, license tracking
     *      RCV slots will be created.
     *
610aA*    - For *SPRECV, the qty will end up in the pick slot
     *      instead of a RCV slot.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
416cMFslot1     uf a e           k disk
     F                                     rename(slrec:s1rec)
610aDF*lot2     uf   e           k disk
610aMFslot2     if   e           k disk
     F                                     rename(slrec:s2rec)
HMW AFslot3     if   e           k disk    usropn
HMW AF                                     rename(slrec:slrec3)
610aDF*lot3     uf   e           k disk
650gDF*slot3     if   e           k disk
650gMFslot13    if   e           k disk
     F                                     rename(slrec:s3rec)
HMW AFslot5     if   e           k disk    usropn
HMW AF                                     rename(slrec:slrec5)
     Fslot6     uf   e           k disk
     F                                     rename(slrec:s6rec)
610aDF*lot7     uf   e           k disk
610aMFslot7     if   e           k disk
     F                                     rename(slrec:s7rec)
218 MFpohdr     uf a e           k disk
218 MFpodtl     uf a e           k disk
700eAFpodtl1    uf   e           k disk    prefix(BR_) rename(pdrec:pdrec1)
     FLabel     o  a e           k disk
610aDF*iritem   if   e           k disk
     Fitemdef1  if   e           k disk
     Fbldcode1  if   e           k disk
     Factivity  if   e           k disk
413bAFdesig     if   e           k disk
     Foptions   if   e           k disk
     Fracks     if   e           k disk
404 AFcrossdk2  if   e           k disk
409 AFvslot2    if   e           k disk
650iAFvslot1    if   e           k disk    rename(vsrec:vrec) prefix(v_)
610aDF*temmsc   if   e           k disk
610aAFlicense   uf a e           k disk
413aAFpirtrck1  o    e             disk
650jAFbatctl    o    e           k disk
     *----------------------------------------------------------------
     * Function prototypes.
     *----------------------------------------------------------------

700eA /copy qcopysrc,p.GETBRAND
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a40             s              1    dim(40)
410 AD a5              s              1    dim(5)
     D act             s              2    dim(50)
     D bld             s              2    dim(50)
210 MD ocr             s             10    dim(9)
412eAD ocr2            s              8    dim(9) descend
610aDD*slt             s             41    dim(50)
610aMD slt             s             98    dim(50)
650kA*----------------------------------------------------------------
650kA*  Customer id
650kA*----------------------------------------------------------------

WSTaA /copy qcopysrc,id#westsid
HMW A /copy qcopysrc,id#hmwagne
FPR A /copy qcopysrc,id#fpr
416bA*----------------------------------------------------------------
416bA*  External data structure for Dakota Realtime Interface.
416bA*
610aDD*$slot         e ds                  extname(c#slotdds)
610aDD*$xdock        e ds                  extname(c#xdockdds)

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------
      /COPY *libl/qcopysrc,C#DRIPARMS

610aA*----------------------------------------------------------------
610aA*  Data Formats
610aA*----------------------------------------------------------------
610aA /COPY *libl/qcopysrc,C#SLOT
610aA /COPY *libl/qcopysrc,C#XDOCK
610aA /COPY *libl/qcopysrc,C#LICINFO
610aA /COPY *libl/qcopysrc,C#LICENSE
610aA /COPY *libl/qcopysrc,C#ITEM
610aAD savever#        s                   like($lnver#)

405 A*----------------------------------------------------------------
405 A*  Called program parameters
405 A*
405 A*
405 AD $lparm          ds
405 AD  $lcmd                  1      8
405 AD  $lprg                  9     18
405 AD  $luky                 19     68
405 AD  $lrtn                 69     76
405 AD  $lerm                 77    136
405 AD  $lmsg                 77     80
405 AD  $ltype                81     88
405 A*
405 A*   Redefine key
405 A*
405 AD  $lwhse                19     21  0
405 AD  $lrte                 22     26
405 AD  $lpo                  27     35
405 AD  $ltrn#                36     42  0
     *
     *----------------------------------------------------------------
     *  Misc. data structures
     *
     D rklevl          ds
     D  rkl                    1     20
     D                                     DIM(10)
     D  rkl01                  1      2
     D  rkl02                  3      4
     D  rkl03                  5      6
     D  rkl04                  7      8
     D  rkl05                  9     10
     D  rkl06                 11     12
     D  rkl07                 13     14
     D  rkl08                 15     16
     D  rkl09                 17     18
     D  rkl10                 19     20
     *----------------------------------------------------------------
     *  *RCVLBL  -  Receiving options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLPGM  -  Receiving label program.
     *    OPUPCT  -  Ideal slot usage percentage.
     *    OPPDEF  -  PIR minimum number of slots priority.
     *    OPPBLD  -  PIR same build code priority.
     *    OPPACT  -  PIR same activity zone priority.
217 A*    OPPASL  -  PIR same aisle priority.
217 A*    OPPFRC  -  Forced PIR same aisle priority.
     *    OPFDEF  -  Fixed minimum number or slots priority.
     *    OPFASL  -  Fixed same aisle priority.
     *    OPFSID  -  Fixed same side priority.
     *    OPFLVL  -  Fixed highest level priority.
217 A*    OPPASL  -  PIR same aisle priority.
217 A*    OPPFRC  -  Force PIR same aisle priority.
221 A*    OPPLCN  -  Use generic license plates.
409 A*    OPPCHM  -  Check chimney (Y,N)
409 A*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
412eA*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
414 A*    OPFRCM  -  Force marking of all P.O. detail lines (Y,N)
416 A*    OPEXCK  -  Expiration date check (1,2,3)
416 A*                What to do when exp date being rcvd comes
416 A*                earlier than existing overflow exp date ...
416 A*                  1 = Don't allow it.
416 A*                  2 = Warn user & log when overriden
416 A*                  3 = Let it go through.
416 A*    OPCWEN  -  Allow catch weight entry (1,2,3)
416 A*                  1 = Every receipt
416 A*                  2 = First receipt only
416 A*                  3 = Never
416 A*    OPCWTP  -  Catch weight value entered (1,2,3)
416 A*                  1 = User choice
416 A*                  2 = Average
416 A*                  3 = Total
416 A*    OPCWFR  -  Force catch weight entry (Y,N)
416bA*    OPIPCK  -  Ignore existing pick slots (Y,N)
     *
     * Data structure
     *
     D opdata          ds
     D  oplpgm                 1     10
     *
     *  OPUPCT was changed to have 2 decimal positions.
     *
     D  opupct                11     13  2
     D  oppdef                14     14  0
     D  oppbld                15     15  0
     D  oppact                16     16  0
     D  opfdef                17     17  0
     D  opfasl                18     18  0
     D  opfsid                19     19  0
     D  opflvl                20     20  0
217 AD  oppasl                21     21  0
217 AD  oppfrc                22     22
221 AD  opplcn                23     23
409 AD  oppchm                24     24
409 AD  oppmix                25     25
412eAD  opapck                26     26
414 AD  opfrcm                27     27
416 AD  opexck                28     28
416 AD  opcwen                29     29
416 AD  opcwtp                30     30
416 AD  opcwfr                31     31
416bAD  opipck                32     32
     D  optend               117    117
412eA*----------------------------------------------------------------
412eA*  *SYSTEM  -  System options.
412eA*----------------------------------------------------------------
412eA*
412eA* Fields
412eA*
412eA*    OPEPM   -  Using EPM module (Y,N).
412eA*    OPRF    -  Using RF module (Y,N).
412eA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
412eA*    OPLETD  -  Print letdown labels (Y,N).
412eA*    OPWRNC  -  Perform catch weight variance check (Y,N).
412eA*    OPRG1C  -  Catch weight low variance percentage.
412eA*    OPRG2C  -  Catch weight high variance percentage.
412eA*    OPIMPI  -  Import item fields from host.(Y,N).
412eA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
412eA*
412eA* Data structure
412eA*
412eAD opdat2          ds
412eAD  opepm                  1      1
412eAD  oprf                   2      2
412eAD  opcapc                 3      3
412eAD  opletd                 4      4
412eAD  opwrnc                 5      5
412eAD  oprg1c                 6      8  1
412eAD  oprg2c                 9     11  1
412eAD  opimpi                12     12
412eAD  opmpck                14     14
412eAD  opten2               117    117
416fA*----------------------------------------------------------------
416fA*  *FEATURE  -  PIR Feature options.
416fA*----------------------------------------------------------------
416fA*
416fA* Fields
416fA*
416fA*    OPFEAT  -  PIR Installed feature.
416fA*                 1=Locator system installed.
416fA*                 2=Full system installed.
416fA*
416fA* Data structure
416fA*
416fAD opdat3          ds
416fAD  opfeat                 1      1
416fAD  op3end               117    117
     *----------------------------------------------------------------
     *  Tie/High definitions data structure.
     *
     *   DSSDEF - Slot definition.
     *   DSTIE  - Tie value.
     *   DSHIGH - High value.
     *   DSPQTY - Quantity on one pallet (Tie * High).
     *   DSPOS  - Number of pallet positions in slot.
     *   DSPOSF - Number of full pallet positions in slot.
     *   DSPLTS - Total number of pallets needed.
     *   DSSLTS - Total number of slots needed.
     *   DSSQTY - Quantity to fill one slot.
     *   DSUPCT - Percent of slot used.
     *   DSTQTY - Total quantity that can fit in slot (DSPQTY * DSPOS)
     *
     D defs            ds                  occurs(9)
     D  dssdef                 1      2
     D  dstie                  3      6  0
     D  dshigh                 7      8  0
     D  dspqty                 9     13  0
     D  dspos                 14     16  1
     D  dsposf                17     18  0
     D  dsplts                19     21  0
     D  dsslts                22     24  0
     D  dssqty                25     29  0
    MD  dsupct                30     34  5
    MD  dstqty                35     41  0
     D                 ds
210 MD  svgrp                  1     10
210 AD  svflag                 1      1
210 MD  svslts                 2      4  0
210 AD  svupct                 5      9  5
210 MD  svocur                10     10  0
412eAD ocr2ds          ds
412eAD  svlgpk                 1      7  0
412eAD  svocr2                 8      8  0
412eAD  svgrp2                 1      8
     D                 ds                  inz
610aMD  savslt                 1     98
     D  savdsp                 1     12
     D  savq1                 13     17s 0
     D  savq2                 18     22s 0
     D  savq3                 23     27s 0
     D  savtie                28     31s 0
     D  savhgh                32     33s 0
     D  savsta                34     35
     D  savlbl                36     38s 0
416fAD  savas2                39     41
610aAD  savtr#                42     48s 0
610aAD  savlb#                49     55s 0
610aAD  savaisl               56     58
610aAD  savloc                59     61s 0
610aAD  savlvl                62     63s 0
610aAD  savhand               64     65
610aAD  savstyp               66     66
610aAD  savrcvdsp             67     78
610aAD  savrcvaisl            79     81
610aAD  savrcvloc             82     84s 0
610aAD  savrcvlvl             85     86s 0
610aAD  savrcvhand            87     88
610aAD  savrcvpseq            89     93s 0
610aAD  savwhdp               94     98
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
413aA*----------------------------------------------------------------
413aA*
413aA* The following data structures are for capturing receiving
413aA* tracking info.
413aA*
413aA*  *RCV001   -  Received Item Header info
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRRCQ1  -  Qty received 1
413aA*    TRUOM1  -  Unit of measure 1
413aA*    TRRCQ2  -  Qty received 2
413aA*    TRUOM2  -  Unit of measure 2
413aA*    TRRCQ3  -  Qty received 3
413aA*    TRUOM3  -  Unit of measure 3
413aA*    TREXPD  -  Expiration date for item
413aA*    TRSTYP  -  Section type
413aA*    TRWHDP  -  Warehouse department
413aA*    TRDESG  -  Item designation
413aA*    TRTYPE  -  Item type
413aA*    TRBLD   -  Item build code
413aA*    TRACTV  -  Item activity zone
413aA*    TRPCMD  -  Program processing option
413aA*    TRPPRG  -  Calling program
413aA*    TRVEN#  -  Vendor number
413aA*    TRSEQ#  -  P/O sequence number (line nbr)
413aA*    TRRCST  -  Receiving status
413aA*    TRLBEG  -  Highest rack level
413aA*    TRIFLG  -  Invalid item flag
413aA*    TRBITM  -  Base item number
413aA*
413aA* Data structure
413aA*
413aAD tr01ds          ds
413aAD  trrcq1                 1      5  0
413aAD  truom1                 6      7
413aAD  trrcq2                 8     12  0
413aAD  truom2                13     14
413aAD  trrcq3                15     19  0
413aAD  truom3                20     21
413aAD  trexpd                22     29  0
413aAD  trstyp                30     30
413aAD  trwhdp                31     35
413aAD  trdesg                36     40
413aAD  trtype                41     41
413aAD  trbld                 42     43
413aAD  tractv                44     45
413aAD  trnrpk                46     48  0
413aAD  trpcmd                49     56
413aAD  trpprg                57     66
413aAD  trven#                67     77  0
413aAD  trseq                 78     84  0
413bAD  trdstp                85     85
413aAD  trrcst                86    105
413aAD  trlbeg               106    107  0
413aAD  triflg               108    108
413aAD  trbitm               109    123
413aAD  trdt01                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV002  -  System options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    Note: See system options definitions.
413aA*
413aA* Data structure
413aA*
413aAD tr02ds          ds
413aAD  trdt02                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV003  -  Receiving options
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    Note: See receiving options definitions.
413aA*
413aA* Data structure
413aA*
413aAD tr03ds          ds
413aAD  trdt03                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV010  -  Item definitions
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRDT10  -  See defintions from item tie/high DS.
413aA*
413aA* Data structure
413aA*
413aAD tr10ds          ds
413aAD  trdt10                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV011  -  Item occurances array
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TROCR   -  See array OCR.
413aA*    TRLDEF  -  Number of occurances in array OCR.
413aA*
413aA* Data structure
413aA*
413aAD tr11ds          ds
413aAD  trocr                  1     90
413aAD  trldef               149    150  0
413aAD  trdt11                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV020  -  Activity zones
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRAZxx  -  Activity zone 01 - 50
413aA*
413aA* Data structure
413aA*
413aAD tr20ds          ds
413aAD  trdt20                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV030  -  Build codes
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRBCxx  -  Build code 01 - 50
413aA*
413aA* Data structure
413aA*
413aAD tr30ds          ds
413aAD  trdt30                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV040  -  Subroutines entered
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRSUBR  -  Subroutines entered.
413aA*
413aA* Data structure
413aA*
413aAD tr40ds          ds
413aAD  trr                    1    150
     D                                     DIM(25)                              Tracking subr
413aAD  trrfld                 1    150
413aA*----------------------------------------------------------------
413aA*  *RCV050  -  Tracking message(s)
413aA*----------------------------------------------------------------
413aA*
413aA* Fields
413aA*
413aA*    TRSR50  -  Subroutine sending message
413aA*    TRDT50  -  Tracking message(s)
413aA*
413aA* Data structure
413aA*
413aAD tr50ds          ds
413aAD  trsr50                 1     10
413aAD  trdt50                11    150
413aA*----------------------------------------------------------------
413aA*  Tracking messages
413aA*----------------------------------------------------------------
     D tr01            c                   const('No verified pick slo-
     D                                     t found with build c-
     D                                     ode:')
     D tr02            c                   const('Next pass look for s-
     D                                     lots not using build-
     D                                      code.')
     D tr03            c                   const('Product putaway in l-
     D                                     ast pick slot:')
     D tr04            c                   const('Product putaway in a-
     D                                     ctive pick slot:')
     D tr05            c                   const('Product putaway in a-
     D                                     ctive overflow slot:')
     D tr06            c                   const('Product putaway in s-
     D                                     lot above pick slot:')
     D tr07            c                   const('Product putaway in u-
     D                                     pper level slot.')
     D tr08            c                   const('Return putaway in 1s-
     D                                     t pick slot:')
     D tr09            c                   const('Product putaway in r-
     D                                     eserved PIR slot:')
     D tr10            c                   const('Looking for slots in-
     D                                      activity zone:')
     D tr11            c                   const('Looking for slots in-
     D                                      fixed aisle:')
     D tr12            c                   const('Looking for slots wi-
     D                                     th build code:')
     D tr13            c                   const('Looking for slots wi-
     D                                     th slot type:')
     D tr14            c                   const('Looking for slots at-
     D                                      level:')
     D tr15            c                   const('Looking for slots in-
     D                                      PIR aisle:')
     D tr16            c                   const('Looking for slots,si-
     D                                     de aisle:')
     D tr17            c                   const('Slot bypassed: Wrong-
     D                                      status,inuse or not-
     D                                      a overflow slot:')
     D tr18            c                   const('No tie/high defined -
     D                                     for:')
     D tr19            c                   const('Item put into slot:')
     D tr20            c                   const('Qty:')
     D tr21            c                   const('Slot bypassed: Virtu-
     D                                     al slot:')
     D tr22            c                   const('Looking for slots wi-
     D                                     th following values:')
     D tr23            c                   const('Slot bypassed: Slot -
     D                                     occupied:')
     D tr24            c                   const('Looking for active e-
     D                                     mpty overflow slot.')
     D tr25            c                   const('Looking for empty pi-
     D                                     ck slot.')
     D tr26            c                   const('Slot bypassed: No sp-
     D                                     ace available:')
     D tr27            c                   const('Pick slot bypassed -
     D                                     Product in overflow -
     D                                     slots:')
     D tr28            c                   const('Slot bypassed: slot -
     D                                     will not accept qty:')
     D tr29            c                   const('Empty pick slot byp-
     D                                     assed - Looking for -
     D                                     last occupied slot:')
     D tr30            c                   const('Slot bypassed: Exp d-
     D                                     ate or entered dates-
     D                                      don''t match:')
     D tr31            c                   const('User assigned slot i-
     D                                     nuse or missing:')
     D tr32            c                   const('Slot bypassed: Cross-
     D                                     -dock slot missing:')
     D tr33            c                   const('Cross-dock item bypa-
     D                                     ssed - No product ne-
     D                                     eded:')
     D tr34            c                   const('Cross-dock item rece-
     D                                     ived: slot:')
     D tr35            c                   const('Exit loop - No slots-
     D                                      in aisle:')
     D tr36            c                   const('Exit loop - Past pic-
     D                                     k slot:')
     D tr37            c                   const('Slot bypassed: Need -
     D                                     a reserved slot:')
     D tr38            c                   const('See passed in values-
     D                                     (P/O, Seq) for key.')
     D tr39            c                   const('No verified slots.')
     D tr40            c                   const('Slot bypassed: Not s-
     D                                     ame side as pick slo-
     D                                     t.')
     D tr41            c                   const('Key:')
     D tr42            c                   const('Putaway canceled -')
     D tr43            c                   const('No tie/high''s defin-
     D                                     ed.')
     D tr44            c                   const('Receiving options re-
     D                                     cord missing.')
     D tr45            c                   const('No slots available.')
     D tr46            c                   const('Not enough slots ava-
     D                                     iable.')
     D tr47            c                   const('Item not found in FS-
     D                                     -WMS system.')
     D tr48            c                   const('Putaway completed su-
     D                                     ccessfully.')
     D tr49            c                   const('Looking for empty ov-
     D                                     erflow slots above p-
     D                                     ick slot.')
     D tr50            c                   const('Looking for last pic-
     D                                     k slot with product -
     D                                     in slot with space a-
     D                                     vailable.')
     D tr51            c                   const('Looking for next pic-
     D                                     k slot with space av-
     D                                     ailable for product -
     D                                     return.')
     D tr52            c                   const('Looking for PIR slot-
     D                                     s by priority.')
     D tr53            c                   const('Looking for reserved-
     D                                      PIR slots with spa -
     D                                     ce available.')
     D tr54            c                   const('Looking for specific-
     D                                      slot.')
     D tr55            c                   const('Looking for empty up-
     D                                     per level overflow s-
     D                                     lots.')
     D tr56            c                   const('Looking for empty cr-
     D                                     oss-dock slots.')
     D tr57            c                   const('Looking for active o-
     D                                     verflow slots with s-
     D                                     pace available.')
     D tr58            c                   const('Empty overflow slot-
     D                                      bypass - Looking fo-
     D                                     r slot with space av-
     D                                     ailable.')
     D tr59            c                   const('Item has soft desig-
     D                                     nation. Looking for -
     D                                     slots with no design-
     D                                     ation.')
     D tr60            c                   const('Slot bypassed: Need-
     D                                      active empty overfl-
     D                                     ow slot:')
     D tr61            c                   const('Computing put-away -
     D                                     variables.')
     D tr62            c                   const('Looking for verifie-
     D                                     d pick slots to ass-
     D                                     ign item to.')
     D tr63            c                   const('Looking for verifie-
     D                                     d pick slots withou-
     D                                     t build code.')
     D tr64            c                   const('Item assigned to pi-
     D                                     ck slot:')
     D tr71            c                   const('Product in overflow-
     D                                      slots, pick slots -
     D                                     bypassed.')
     D tr72            c                   const('Attempting to assig-
     D                                     n item to pick slot-
     D                                     s, item is short sl-
     D                                     ots.')
     D tr73            c                   const('XDock quantity rece-
     D                                     ived from host.')
     D tr74            c                   const('XDock slot exists.')
     D tr75            c                   const('XDock slot created.')
     D tr76            c                   const('No pick slot found f-
     D                                     or crossdock')
640cAD tr77            c                   const('Slot bypassed: Diffe-
640cAD                                     rent item in slot:')
413aA*  Receiving status messages.
     D tr65            c                   const('Received        ')
     D tr66            c                   const('No tie/hi define')
     D tr67            c                   const('No slots avail. ')
     D tr68            c                   const('Not enough slots')
     D tr69            c                   const('Invalid item    ')
     D tr70            c                   const('Rcv opt rcd miss')
     D trerr           c                   const('*NOTFOUND')
     *----------------------------------------------------------------
     *  Called programs
     *
     D @addtr          c                   const('ADDSTDTRN')
     D @cvtdt          c                   const('CVTDTE')
     D @getsi          c                   const('GETSLOTITM')
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
     D  erqty                  1     10
     D  erpal                 11     12p 0
     D  eritem                13     27
412eAD  ersl01                 1      3p 0
412eAD  ersl02                 4      6p 0
412eAD  eritm                  7     21
640iAD  erqty24                1      5p 0
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
610aA /COPY *libl/qcopysrc,C#PGMINFDS
610aDD*               sds
610aDD* #prog            *proc
610aDD* #job                 244    253
610aDD* #user                254    263
610aDD* #jobn                264    269
610aDD* #jobdt               276    281  0
610aDD* #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Variables
     *
     D $apslt          s             12
     D $msgf           s             10
     D #bitem          s                   like($ititem)
     D #bqty1          s                   like($pqty1)
     D #bqty2          s                   like($pqty2)
     D #bqty3          s                   like($pqty3)
     D #odesc          s                   like($itdesc)
     D #oitem          s                   like($ititem)
     D #opdsc          s                   like($itpdsc)
     D #otype          s              1
     D #sitem          s                   like($ititem)
     D actbeg          s              2  0
     D actcmd          s              8
     D actcnt          s              1  0
     D actpos          s              2  0
     D aftasl          s              3
     D aftdif          s              3  0
     D aftloc          s              3  0
     D aftrtn          s              8
     D aslcmd          s              8
     D asn2            s              4
     D bfrasl          s              3
     D bfrdif          s              3  0
     D bfrloc          s              3  0
     D bfrrtn          s              8
     D bldbeg          s              2  0
     D bldcmd          s              8
     D bldpos          s              2  0
     D ck4err          s              1
     D curdef          s              2  0
     D cursid          s              8
     D cvt2a           s              2
     D cvt3a           s              3
     D cvt5a           s              5
     D defbeg          s              2  0
     D defcmd          s              8
     D defpos          s              2  0
     D dummy           s              3  0
     D emptyq          s              7  0
     D error           s               n
     D extra           s              5  0
     D first           s              1
     D flgitm          s              1
     D flgrcv          s              1
     D flgsys          s              1
610aAD forceOnePallet  s               n
640aAD forever         s               n
     D forevr          s               n
     D found           s               n
610aAD i               s              5  0
     D kydesg          s                   like($itdesg)
     D kyitem          s                   like($ititem)
     D kywhse          s                   like($pwhse)
     D k1aisl          s                   like(slaisl)
     D k1loc           s                   like(slloc)
     D k1rlvl          s                   like(slrlvl)
     D k2disp          s                   like(sldisp)
     D k3pick          s                   like(slpick)
     D k3stat          s                   like(slstat)
     D k6actv          s                   like(slactv)
     D k6aisl          s                   like(slaisl)
     D k6bld           s                   like(slbld)
     D k6sdef          s                   like(slsdef)
     D k7aisl          s                   like(slaisl)
     D k7loc           s                   like(slloc)
     D k7rlvl          s                   like(slrlvl)
700aAD lblpgm          s                   like(oplpgm)
     D lblqty          s              5  0
     D locatr          s              1
     D lstact          s              2  0
     D lstbld          s              2  0
     D lstdef          s              2  0
     D lstlbl          s              2  0
     D lvlbeg          s              2  0
     D lvlcmd          s              8
     D mltflg          s              1
     D nbrpck          s              5  0
     D need1           s              5  0
     D need2           s              5  0
     D need3           s              5  0
FPRaAD newlbl#         s                   like(lblbl#)
     D nrasgn          s              3  0
     D nrshrt          s              5  0
     D orgcmd          s              8
     D palets          s              7  5
     D palqty          s              5  0
     D pckasl          s                   like(slaisl)
     D pckdsp          s                   like(sldisp)
     D pckhnd          s                   like(slhand)
     D pckloc          s                   like(slloc)
     D pcklvl          s                   like(slrlvl)
     D pcksid          s              8
     D pckslt          s              4
     D prfind          s              1
     D prflag          s              1                                                        GFG
     D prirty          s              1  0
610aAD pttrn#          s                   like(lbtrn#)
     D putpal          s              3  0
     D putqty          s              5  0
     D q1lft           s              5  0
     D q2lft           s              5  0
     D q3lft           s              5  0
640dAD q1sav           s              5  0
640dAD q2sav           s              5  0
640dAD q3sav           s              5  0
     D r               s              3  0
610aAD rcvInArea       s                   like($saToArea)
610aAD rcvInLbl#       s                   like(lblbl#)
610aAD rcvInTrn#       s                   like(lbtrn#)
610aAD rcvInQty1       s                   like($pqty1)
610aAD rcvInQty2       s                   like($pqty2)
610aAD rcvInQty3       s                   like($pqty3)
     D savcmd          s              8
     D sidcmd          s              8
     D slots           s              7  5
     D sltasn          s              4
HMW AD sverror         s               n   inz('0')
     D sventd          s                   like(slentd)
     D svpasl          s                   like(oppasl)
     D svrtn           s                   like($prtn)
     D svseq           s              5  0
     D temp1n          s              1  0
     D temp3n          s              3  0
     D tmpemp          s              5  0
     D tmpflg          s              1
     D tmplft          s              5  0
     D tmploc          s              3  0
     D tmprtn          s              8
     D today           s              8  0
     D today6          s              6  0
     D trkey           s             10
     D trnbr           s              4
     D trsq10          s              5  0
     D trsq11          s              5  0
     D trsq40          s              5  0
     D trsq50          s              5  0
     D trsubr          s              6
     D uprflg          s              1
     D vsfind          s              1
     D wodesg          s              1
     D x               s              2  0
     D xdkupd          s              1
     D y               s              2  0
640aAD z               s              2  0
610aAD zmflag          s               n
610aAD zmsflag         s               n

610aAD #rcvarea        s              6
610aAD #rcvdisp        s             12
610aAD #rcvlcns        s             15
610aAD #rcvQty1        s                   like($pqty1)
610aAD #rcvQty2        s                   like($pqty2)
610aAD #rcvQty3        s                   like($pqty3)
610aAD #usrdisp        s             12

610bAD $uDiffItem      s              1
610bAD $uCube          s              9  3
610bAD $uDisp          s             12
610bAD $uItem          s             15
610bAD $uPieces        s              5  0
610bAD $uRecs          s              3  0
640gAD $uRsrv          s              1
610bAD $uWhdp          s              5
610bAD $uWhse          s              3  0
640bAD $uEntDte        s              8  0
640bAD $uExpDte        s              8  0
640bAD $uDiffEntd      s              1
640bAD $uDiffExpd      s              1

700eAD bCmd            s             10
700eAD bBrand          s             10
700eAD bParentitm      s             15
700eAD bBranditm       s             15
700eAD bBrandFlg       s              1
700eAD NewSeq#         s                   like(pdseq)
730aAD jobuser         s                   like(#curruser)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *OPEN    - Open program and return.
     *              *RECEIVE - Receiving.
640iA*              *RECEIV1 - Receiving single pallet, not allowed to split.
213 A*              *TFRRCV  - Transfer receiving.
     *              *RETURN  - Customer returns.
213 A*              *TFRRTN  - Transfer returns.
213 A*              *POSRTN  - POS returns.
417bA*              *MOVEINP - Move In Pick slots.
417bA*              *MOVEINO - Move In Overflow slots.
500aA*              *SPRECV  - Special receiving, put in pick slot
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER    - Interactive, use program msg queue.
     *              *BATCH    - Batch, send error code.
     *      $PWHSE  Warehouse.
     *      $PITEM  Item to put away.
     *      $PQTY1  Normal returned quantity to put-away.
     *      $PQTY2  Breakdown 1 returned quantity to put-away.
     *      $PQTY3  Breakdown 2 returned quantity to put-away.
     *      $PPO    P.O. number for *RECEIVE.
     *      $PVEN   Vendor number for *RECEIVE.
     *      $PVNAM  Vendor name for *RECEIVE.
     *      $PVITM  Vendor item number for *RECEIVE.
     *      $PORD   Order number for *RETURN.
     *      $PRCOD  Return code.
     *      $PRMEM  Return memo.
     *      $PEXPD  Expiration date.
417c *      $PFIFO  MOVEIN FIFO entered date.
     *      $PDEV   Printer device to use or *DEFAULT.
     *      $PFORM  Printer form to use or *DEFAULT.
213 A*      $PSLOT  Manual override of slot to use for putaway.
218 A*      $PSEQ   Seq# for P.O. receiving.  0 = Manual receiving.
218 A*      $PRPCK  Allow returns into Pick Slot (Y,N).
218 A*      $PPLBL  Print putaway labels (Y,N).
219 A*      $PDWGT  Catch weight
     *
     *    Returned Parameters
    A*      $PORD   Batch number assigned to labels.
     *      $PRQ1   for *OK      - Normal qty put away.
     *              for *NOTENGH - Qty that could have been put away.
     *      $PRQ2   for *OK      - Brk1 qty put away.
     *              for *NOTENGH - Qty that could have been put away.
     *      $PRQ3   for *OK      - Brk2 qty put away.
     *              for *NOTENGH - Qty that could have been put away.
     *      $PRPAL  for *OK      - Pallets used for put away.
     *              for *NOTENGH - Pallets that were built.
     *      $PRTN   *OK      - No problem encountered.
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *                         (for use with $PTYPE = *INTER).
     *              *INVALID - Invalid item number.
     *              *NOOPT   - No receiving options defined.
     *              *NODEF   - No Tie/High defs defined for item.
640iA*              *NODEF2  - No Tie/High defs large enought for qty.
     *              *NOSLOT  - No slots available for item.
     *              *NOTENGH - Not enough slots available for item.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pprg            10
     C                   parm                    $ptype            8
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pqty1            5 0
     C                   parm                    $pqty2            5 0
     C                   parm                    $pqty3            5 0
     C                   parm                    $ppo              9
     C                   parm                    $pven            11 0
     C                   parm                    $pvnam           40
     C                   parm                    $pvitm           15
     C                   parm                    $pord             7 0
     C                   parm                    $prcod            2
     C                   parm                    $prmem           30
     C                   parm                    $pexpd            8 0
417c C                   parm                    $pfifo            8 0
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
213 AC                   parm                    $pslot           12
218 AC                   parm                    $pseq             5 0
218 AC                   parm                    $prpck            1
218 AC                   parm                    $pplbl            1
219 AC                   parm                    $pdwgt            9 2
     C                   parm                    $prq1             5 0
     C                   parm                    $prq2             5 0
     C                   parm                    $prq3             5 0
     C                   parm                    $prpal            3 0
     C                   parm                    $prtn             8
     C                   parm                    $pmsg             4
730aAc                   parm                    $puser           10
740aAc                   parm                    $ppsr             1
     *----------------------------------------------------------------
     *  Main line
     *
     C     $pcmd         cabeq     '*OPEN   '    bottom
213 A*
213 A* Convert command into generic form and initialize transaction parms
213 A*
213 AC                   eval      savcmd = $pcmd
417bAC                   eval      orgcmd = $pcmd
213 AC                   select
213 AC                   when      $pcmd = '*RECEIVE'
640kAc                             or $pcmd = '*RECEIV1'
213 AC                   eval      @ptask = 'PUTEMP'
213 AC                   eval      @pgrp1 = 'P'
213 AC                   eval      @pgrp2 = ' '
213 A*
213 AC                   when      $pcmd = '*TFRRCV '
213 AC                   eval      $pcmd = '*RECEIVE'
213 AC                   eval      @ptask = 'PUTEMP'
213 AC                   eval      @pgrp1 = 'P'
213 AC                   eval      @pgrp2 = 'T'
213 A*
213 AC                   when      $pcmd = '*RETURN '
640kAc                             or $pcmd = '*RETURN1'
213 AC                   eval      @ptask = 'PUTRTN'
213 AC                   eval      @pgrp1 = 'R'
213 AC                   eval      @pgrp2 = ' '
213 A*
213 AC                   when      $pcmd = '*TFRRTN '
213 AC                   eval      $pcmd = '*RETURN '
213 AC                   eval      @ptask = 'PUTRTN'
213 AC                   eval      @pgrp1 = 'R'
213 AC                   eval      @pgrp2 = 'T'
213 A*
213 AC                   when      $pcmd = '*POSRTN '
213 AC                   eval      $pcmd = '*RETURN '
213 AC                   eval      @ptask = 'PUTRTN'
213 AC                   eval      @pgrp1 = 'R'
213 AC                   eval      @pgrp2 = 'P'
417bA*
417bAC                   when      $pcmd = '*MOVEINP'  or
417bAC                             $pcmd = '*MOVEINO'
417bAC                   eval      $pcmd = '*RECEIVE'
417bAC                   eval      @ptask = 'PUTEMP'
417bAC                   eval      @pgrp1 = 'P'
417bAC                   eval      @pgrp2 = ' '
500 A*
500 AC                   when      $pcmd = '*SPRECV '
500 AC                   eval      @ptask = 'PUTEMP'
500 AC                   eval      @pgrp1 = 'P'
500 AC                   eval      @pgrp2 = ' '
213 A*
213 AC                   endsl
     *
     C                   eval      $prq1 = 0
     C                   eval      $prq2 = 0
     C                   eval      $prq3 = 0
     C                   eval      $prpal = 0
     C                   eval      $prtn = *blanks
     *
     * Perform initialization for item to be put away.
     *
     C                   exsr      init
     C     error         cabeq     *on           bottom
404 A*
404 A* Fill cross dock orders first.
404 A*
404 AC                   exsr      putxdk
416fAC     error         cabeq     *on           bottom
416aA*
416aA* Return with no putaway.
416aA*
416aAC                   if        $pcmd = '*RETURN'  and
416aAC                             $ppo = '*NOSTOCK'
416aAC                   eval      q1lft = 0
416aAC                   eval      q2lft = 0
416aAC                   eval      q3lft = 0
416aAC                   endif
     *
     * Execute put-away routine that coressponds to the items section.
     *
404 AC                   if        q1lft > 0  or
404 AC                             q2lft > 0  or
404 AC                             q3lft > 0
TMP AC     $pslot        casne     *blanks       putslt
610aMC     $itstyp       caseq     'P'           awypir
610aMC     $itstyp       casne     'P'           awyfix
     C                   endcs
404 AC                   endif
     *
     *  If everything was put away then do file post.
    A*    Pass back batch number for labels using $PORD.
     *
     C                   select
     C                   when      q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
     C                   exsr      post
     C                   eval      $prtn = '*OK     '
    AC                   eval      $pord = $pbat                                               GFG
     *
     *  Otherwise, reverse what has been done and send back error msg.
     *
     C                   other
411 MC                   if        q1lft = #bqty1  and
411 MC                             q2lft = #bqty2  and
411 MC                             q3lft = #bqty3
500bAC                   if        $prtn <> '*NOPICKS'
     C                   eval      $prtn = '*NOSLOT '
500bAC                   endif
     C                   else
     C                   exsr      undo
     C                   eval      $prtn = '*NOTENGH'
     C                   endif
     C                   endsl
     *
     C     bottom        tag
     *
413aAC                   eval      svrtn = $prtn
     *
     C                   if        $ptype = '*INTER  '
     *
     C                   select
     C                   when      $prtn = '*OK     '
     C                   exsr      zm20
413aAC                   eval      trnbr = 'TR48'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
     C                   when      $prtn = '*INVALID'
     C                   exsr      zm21
     C                   eval      $prtn = '*PGMQ   '
413aAC                   eval      trnbr = 'TR47'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
     C                   when      $prtn = '*NODEF  '
     C                   exsr      zm22
     C                   eval      $prtn = '*PGMQ   '
413aAC                   eval      trnbr = 'TR43'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
640iAC                   when      $prtn = '*NODEF2 '
640iAC                   exsr      zm24
640iAC                   eval      $prtn = '*PGMQ   '
640iAC                   eval      trnbr = 'TR43'
640iAC                   eval      trcode = '*RCV050 '
640iAC                   movel     'MAINLN'      trsr50
640iAC                   exsr      zztrck
     *
     C                   when      $prtn = '*NOOPT  '
     C                   exsr      zm23
     C                   eval      $prtn = '*PGMQ   '
413aAC                   eval      trnbr = 'TR44'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
     C                   when      $prtn = '*NOSLOT '
217 AC                   if        oppfrc = 'Y'
217 AC                   exsr      zm26
217 AC                   eval      $prtn = '*PGMQ   '
217 AC                   else
     C                   exsr      zm24
     C                   eval      $prtn = '*PGMQ   '
217 AC                   endif
413aAC                   eval      trnbr = 'TR45'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
     C                   when      $prtn = '*NOTENGH'
217 AC                   if        oppfrc = 'Y'
217 AC                   exsr      zm27
217 AC                   eval      $prtn = '*PGMQ   '
217 AC                   else
     C                   exsr      zm25
     C                   eval      $prtn = '*PGMQ   '
217 AC                   endif
413aAC                   eval      trnbr = 'TR46'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'MAINLN'      trsr50
413aAC                   exsr      zztrck
     *
416fAC                   when      $prtn = '*NOPICK'
416fAC                   exsr      zm22a
416fAC                   eval      $prtn = '*PGMQ   '
416fAC                   eval      trnbr = 'TR76'
416fAC                   eval      trcode = '*RCV050 '
416fAC                   movel     'MAINLN'      trsr50
416fAC                   exsr      zztrck
     *
500bAC                   when      $prtn = '*NOPICKS'
500bAC                   exsr      zm23a
500bAC                   eval      $prtn = '*PGMQ   '
500bAC                   eval      trnbr = 'TR76'
500bAC                   eval      trcode = '*RCV050 '
500bAC                   movel     'MAINLN'      trsr50
500bAC                   exsr      zztrck
     *
     C                   endsl
     C                   endif
213 A*
213 A* Make sure we haven't left any records locked.
213 A*
213 AC                   unlock    slot1
610aDC**                 unlock    slot2
610aDC**                 unlock    slot3
213 AC                   unlock    slot6
610aDC**                 unlock    slot7
218 MC                   unlock    pohdr
218 MC                   unlock    podtl
700eAC                   unlock    podtl1
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   if        $pcmd <> '*OPEN   '
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'EXIT    '    trsubr
413aAC                   eval      r = 32
413aAC                   exsr      zztrck
213 A*
213 A* Restore original command.
213 A*
213 AC                   eval      $pcmd = savcmd
     *
413aA*    Write out tracking record *RCV001.
413aA*
413aAC                   eval      trcode = '*RCV001 '                          Item info
413aAC                   exsr      zztrck
413aAC                   endif
     C                   return
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
650kA*
650kA* Get client id.
650kA*
650kAC                   call      'GETCLIENT'
650kAC                   parm                    client           10
650kAC                   parm                    clientloc        10
650kA*
HMW AC                   select
HMW AC                   when      client = HMWagner
FPR AC                             or client = FoodPro
HMW AC                   if        not %open(slot3)
HMW AC                   open      slot3
HMW AC                   endif
HMW AC                   if        not %open(slot5)
HMW AC                   open      slot5
HMW AC                   endif
HMW AC                   endsl
HMW A*
     C                   eval      first = *on
412eAC                   eval      pckslt = *blanks
412eAC                   eval      sltasn = *blanks
412eAC                   eval      asn2 = *blanks
412eAC                   eval      nbrpck = *zeros
412eAC                   eval      nrshrt = *zeros
412eAC                   eval      nrasgn = *zeros
411 A*
411 A*  Define save fields for different item types.
411 A*
411 AC                   eval      #otype = *blanks
412bA*
412bA*  Define work variables & constants
412bA*
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
411 MC                   kfld                    kyitem
     *
     *  Define partial key for ITEMDEF1 file.
     *
     C     keyid1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     C                   kfld                    idum
     C                   eval      idum = 'N'
     *
     *  Define partial keys for SLOT1 file.
     *
     C     keys1a        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
     *
     C     keys1b        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
     C                   kfld                    k1aisl
     *
     C     keys1c        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
     C                   kfld                    k1aisl
     C                   kfld                    k1loc
     *
     C     keys1d        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
     C                   kfld                    k1aisl
     C                   kfld                    k1loc
     C                   kfld                    k1rlvl
     *
     *  Define key for SLOT2 file.
     *
     C     keys2         klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
     C                   kfld                    k2disp
     *
     *  Define partial key for SLOT3 file.
     *
     C     keys3         klist
     C                   kfld                    $pwhse
417dMC                   kfld                    #sitem
     C                   kfld                    k3stat
     C                   kfld                    k3pick
     *
     C     keys3b        klist
     C                   kfld                    $pwhse
417dMC                   kfld                    #sitem
     C                   kfld                    k3stat
     *
411 AC     keys3c        klist
411 AC                   kfld                    $pwhse
417cMC                   kfld                    #sitem
HMW A*
HMW A* Define partial key for SLOT5 file.
HMW AC     keysl5        klist
HMW AC                   kfld                    $pwhse
HMW AC                   kfld                    $itwhdp
HMW AC                   kfld                    $itdesg
     *
     *  Define partial key for SLOT6 file.
     *
     C     keys6         klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
413bAC                   kfld                    kydesg
     C                   kfld                    k6sdef
     C                   kfld                    k6bld
     C                   kfld                    k6actv
     *
217 AC     keys6a        klist
217 AC                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
413bAC                   kfld                    kydesg
217 AC                   kfld                    k6sdef
217 AC                   kfld                    k6bld
217 AC                   kfld                    k6actv
217 AC                   kfld                    k6aisl
     *
412eA*    Note: We use this partial key to find available pick
412eA*          slots for non-slotted fixed items including
412eA*          build code.
412eA*
412eAC     keys6b        klist
412eAC                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
610aMC                   kfld                    $itdesg
412eAC                   kfld                    k6sdef
412eAC                   kfld                    k6bld
412eA*
412eA*    Note: We use this partial key to find available pick
412eA*          slots for non-slotted fixed items without the
412eA*          build code.
412eA*
412eAC     keys6c        klist
412eAC                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
610aMC                   kfld                    $itdesg
412eAC                   kfld                    k6sdef
     *
     *  Define partial keys for SLOT7 file.
     *
     *    Note: We use K6SDEF because the same GETDEF routine is
     *          used for finding PIR and fixed slots.
     *
     *
     C     keys7a        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
413bAC                   kfld                    kydesg
     C                   kfld                    k7aisl
     C                   kfld                    k7rlvl
     C                   kfld                    k6sdef
     *
     C     keys7b        klist
     C                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
610aMC                   kfld                    $itstyp
413bAC                   kfld                    kydesg
     C                   kfld                    k7aisl
     C                   kfld                    k7rlvl
     C                   kfld                    k6sdef
     C                   kfld                    k7loc
409 A*
409 A*  Define key for VSLOT2 file.
409 A*
409 AC     keyv2         klist
409 AC                   kfld                    $pwhse
610aMC                   kfld                    $itwhdp
409 AC                   kfld                    sldisp
     *
     *  Define key for RACKS file.
     *
     C     keyrk         klist
     C                   kfld                    $pwhse
     *
     *  Define key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *
218 M*  Define key for POHDR file.
218 D*  Define key for POH file.
     *
     C     keyph         klist
     C                   kfld                    $pwhse
     C                   kfld                    $ppo
     *
218 A*  Define key for PODTL file.
218 A*
218 AC     keypd         klist
218 AC                   kfld                    $pwhse
218 AC                   kfld                    $ppo
218 AC                   kfld                    svseq
218 AC                   kfld                    $pitem
404 A*
404 A*  Define key for CrossDk2 file.
404 A*
404 AC     keycd2        klist
404 AC                   kfld                    $pwhse
404 AC                   kfld                    $ppo
404 AC                   kfld                    $pseq
404 A*
404 A*  Define key for SLOT2 file for cross dock.
404 A*
404 AC     keys2x        klist
404 AC                   kfld                    cdwhse
404 AC                   kfld                    cdwhdp
404 AC                   kfld                    cdslot
     *
412eA*  Define key for options file, System values.
412eA*
412eAC     optsky        klist
412eAC                   kfld                    kywhse
412eAC                   kfld                    opcode
610aA
610aA*  Define key for LICENSE file.
610aA*
610aAC     keyLI         klist
610aAC                   kfld                    $pwhse
610aAC                   kfld                    $saToLcns
412eA*
     *  Variables and constants.
     *
217 AC                   eval      prfind = *off
217 AC                   eval      pckasl = *blanks
     C                   eval      forevr = *off
409 AC                   eval      vsfind = *off
     *
     *  Build array of build codes. A blank code is inserted at the
     *  end and will be the last code used.
     *
     C                   eval      x = 0
     C                   dou       forevr <> forevr
     C                   read      bcrec                                  79
     C                   if        *in79  or
     C                             x = 50
     C                   leave
     C                   endif
     C                   add       1             x
     C                   eval      bld(x) = bccode
     C                   enddo
     C                   add       1             x
     C                   eval      bld(x) = *blanks
     C                   eval      lstbld = x
     *
     *   Build array of activity zones. A blank code is inserted at
     *   the end. It will be used before higher priority codes.
     *
     C                   eval      x = 0
     C                   dou       forevr <> forevr
     C                   read      acrec                                  79
     C                   if        *in79  or
     C                             x = 50
     C                   leave
     C                   endif
     C                   add       1             x
     C                   eval      act(x) = accode
     C                   enddo
     C                   add       1             x
     C                   eval      act(x) = *blanks
     C                   eval      lstact = x
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
     *  Convert today's date into MMDDYY format.
     *
     C                   eval      $cvcmd = '*CURMDY '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today6 = $cvd6o
     *
405 AC                   eval      $lprg = #prog
     *
     C                   endsr
412eA*----------------------------------------------------------------
412eA*
412eA*  ASNSLT  Assign pick slot for non-slotted fixed item.
412eA*
412eAC     asnslt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'ASNSLT  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR62'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'ASNSLT'      trsr50
413aAC                   exsr      zztrck
412eA*
412eA*  Loop through slot types to build arrary to allow
412eA*  slot types to be sorted in descending sequence by
412eA*  the total qty the slot type will hold.
412eA*
412eAC                   move      *loval        ocr2
412eA*
412eAC     1             do        lstdef        x
412eAC     x             occur     defs
412eAC                   eval      svlgpk = dstqty
412eAC                   z-add     x             svocr2
412eAC                   eval      ocr2(x) = svgrp2
412eAC                   enddo
412eA*
412eAC                   sorta     ocr2
412eA*
412eAC                   eval      sltasn = '*NO '
412eAC                   eval      asn2 = '*NO '
412eAC                   eval      nrasgn = *zeros
610aMC                   eval      k6bld = $itbld
610aMC                   eval      k6actv = $itactv
412eA*
412eA*  Process slot types for item looking for largest slot
412eA*  available to hold item.
412eA*
412eAC     #asn01        tag
412eAC     1             do        lstdef        x
412eAC                   eval      svgrp2 = ocr2(x)
412eAC     svocr2        occur     defs
412eAC                   eval      k6sdef = dssdef
412eA*
412eAC                   if        asn2 = '*NO '                                Inc. build code
412eAC     keys6b        setll     slot6
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS6B'
413aAC                   eval      trsr50 = 'ASNSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412eAC                   else
412eAC     keys6c        setll     slot6                                        W/o build code
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS6C'
413aAC                   eval      trsr50 = 'ASNSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412eAC                   endif
412eA*
412eAC                   dou       forevr <> forevr
412eAC                   if        asn2 = '*NO '
412eAC     keys6b        reade     slot6                                7879     W/ build code
412eAC                   else
412eAC     keys6c        reade     slot6                                7879     W/o build code
412eAC                   endif
412eA*
412eAC                   select
412eAC                   when      *in79
412eAC                   leave
412eA*
412eAC                   when      *in78                                        Rcd in use
412eAC                   iter
412eA*
412eAC                   when      slpick = 'Y'  and
412eAC                             slrsrv = 'N'
412eA*
412eA*  Available pick slot was found.
412eA*
610aMC                   eval      slitem = $ititem
412eAC                   eval      slstat = 'A '
417cAC                   if        $pfifo = 0
412eAC                   eval      slentd = today
417cAC                   else
417cAC                   eval      slentd = $pfifo
417cAC                   endif
412eAC                   time                    slstim
412eAC                   eval      slsdte = today
412eAC                   update    s6rec
416bA*
412eAC                   eval      nrshrt = nrshrt - 1
412eAC                   add       1             nrasgn
413aAC                   eval      trnbr = 'TR64'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'ASNSLT'      trsr50
413aAC                   exsr      zztrck
412aAC                   endsl
412eA*
412eAC                   if        nrshrt <= *zeros
412eAC                   eval      sltasn = '*YES'
412eAC                   leave
412eAC                   endif
412eAC                   enddo
412eA*
412eA*  If a pick slot was assigned to this item - exit loop and
412eA*  continue with receiving, else try next slot type.
412eA*
412eAC                   select
412eAC                   when      sltasn = '*YES'
412eAC                   leave                                                  Exit loop
412eAC                   endsl
412eA*
412eAC                   enddo
412eA*
412eA*  If a pick slot was not assigned to this item - Go to
412eA*  the top and try again, this time without build code.
412eA*
412eAC                   select
412eAC                   when      sltasn = '*NO '  and
412eAC                             asn2 = '*NO '
412eAC                   eval      asn2 = '*YES'
413aAC                   eval      trnbr = 'TR63'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   movel     'ASNSLT'      trsr50
413aAC                   exsr      zztrck
412eAC                   goto      #asn01                                       Goto top
412eAC                   endsl
412eA*
412eAC                   exsr      zm20a
412eA*
412eAC                   unlock    slot6
412eAC                   endsr
     *----------------------------------------------------------------
     *
     *  AWYFIX  Put away fixed item.
     *
     C     awyfix        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'AWYFIX  '    trsubr
413aAC                   exsr      zztrck
     C                   eval      error = *off
640dA
640dA*  With the 610d change of setting dssqty to 1 pallet, we are
640dA*  putting 1 pallet away at a time. Therefore, as a pallet is
640dA*  put away, we want to loop and start from the beginning.
640dA
640dA
640dAC                   dow       forever = forever
640dA
640dAC                   eval      q1sav = q1lft
640dAC                   eval      q2sav = q2lft
640dAC                   eval      q3sav = q3lft
411 A*
411 A*  Check for multiple slots for item.
411 A*
411 AC                   exsr      chkmlt
     *
     *  Get picking slot for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
650gDC***  keys3         setll     slot3
650gDC***  keys3         reade(n)  slot3                                  79
650gMC     keys3         setll     slot13
650gMC     keys3         reade(n)  slot13                                 79
     *
     *  Save picking slot for use elsewhere.
     *
     C                   if        *in79
     C                   eval      pckasl = *blanks
     C                   eval      pckloc = 0
     C                   eval      pcklvl = 0
     C                   eval      pckhnd = *blanks
     C                   eval      pckdsp = *blanks
     C                   eval      pcksid = '*EVEN   '
     C                   else
     C                   eval      pckasl = slaisl
     C                   eval      pckloc = slloc
     C                   eval      pcklvl = slrlvl
     C                   eval      pckhnd = slhand
     C                   eval      pckdsp = sldisp
213 DC                   if        slside = 0
     C                   eval      pcksid = '*EVEN   '
     C                   else
     C                   eval      pcksid = '*ODD    '
     C                   endif
     C                   endif
     *
413aAC                   if        $pcmd = '*RECEIVE'  and
413aAC                             mltflg = *on
650fAC                             or $pcmd = '*RECEIV1' and
650fAC                             mltflg = *on
413aAC                   eval      trnbr = 'TR71'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     *  Try to put qty away in first picking slot.
     *
412AAC                   if        $pcmd = '*RETURN '
     C                   exsr      putpck
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR08'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
     C                   goto      endaf
     C                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
     C                   endif
500aA*
500aA*  Try to put qty away in first picking slot.
500aA*
500aAC                   if        $pcmd = '*SPRECV '
500aAC                   exsr      putpck
HMW A*
HMW AC                   select
HMW AC                   when      client = HMWagner
HMW A*
HMW A*      Pick slot not on file. Attempt to create if
HMW AC                   if        error = '1'
HMW A*
HMW AC                   if           $itdesg = 'JITC '
HMW AC                             or $itdesg = 'JITM '
HMW AC                             or $itdesg = 'JITP '
HMW AC                             or $itdesg = 'SPECC'
HMW AC                             or $itdesg = 'SPECD'
HMW AC                             or $itdesg = 'SPECF'
HMW A*      Check if JIT or Special Order Pick slot needs to be created.
HMW AC                   exsr      zzspclpck
HMW A*      Create pick slot was successful. Attempt to complete putaway.
HMW AC                   if        error = '0'
HMW AC                   exsr      putpck
HMW AC                   endif
HMW AC                   endif
HMW A*
HMW AC                   endif
FPR A*
FPR AC                   when      client = FoodPro
FPR A*
FPR A*      Pick slot not on file. Attempt to create if
FPR AC                   if        error = '1'
FPRaA*
FPRaAC                   eval      $drireturn = ' '
FPRaA*      Check if XDK slot already on file. If found, use it.
FPRaAC                   exsr      putxfl_fpr
FPR A*
FPR A*      Check if Special Order Pick slot needs to be created.
FPRaAC                   if        $drireturn <> '*OK'
FPRaA*      No XDK slot on file, so continue with special pick slot process.
FPR AC                   exsr      zzspclpck_fpr
FPR A*      Create pick slot was successful. Attempt to complete putaway.
FPR AC                   if        error = '0'
FPR AC                   exsr      putpck
FPR AC                   endif
FPRaA*
FPRaAC                   endif
FPR A*
FPR AC                   endif
FPR A*
HMW AC                   endsl
HMW A*
500bAC     error         cabeq     *on           endaf
500aAC                   if        q1lft = 0  and
500aAC                             q2lft = 0  and
500aAC                             q3lft = 0
500aAC                   eval      trnbr = 'TR08'
500aAC                   movel     '*RCV050'     trcode
500aAC                   eval      trsr50 = 'AWYFIX'
500aAC                   exsr      zztrck
500aAC                   goto      endaf
500aAC                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
500aAC                   endif
     *
610aA*  Try to put qty away in last picking slot.
610aA*
412AAC                   if        $pcmd = '*RECEIVE'  and
412AAC                             mltflg = *off  and
416 AC                             opipck <> 'Y'  and
417bAC                             orgcmd <> '*MOVEINO'
650fAC                             or $pcmd = '*RECEIV1'  and
650fAC                             mltflg = *off  and
650fAC                             opipck <> 'Y'  and
650fAC                             orgcmd <> '*MOVEINO'
412AAC                   exsr      putlst
412AAC                   if        q1lft = 0  and
412AAC                             q2lft = 0  and
412AAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR03'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
412AAC                   goto      endaf
412AAC                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
412AA*
412AA*  Otherwise, we try to put it in an empty active
412AA*  pick slot(s) if no qty in overflow.
412AA*
412AAC                   exsr      putapk
412AAC                   if        q1lft = 0  and
412AAC                             q2lft = 0  and
412AAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR04'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
412AAC                   goto      endaf
412AAC                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
412AAC                   endif
412dA*
412dA*  Otherwise, we try to put it in an active overflow slot.
412dA*
610aA* ????????????????????????????????????????????????????????
412dAC                   if        $pcmd = '*RECEIVE'  and
610aMC                             $itstyp = 'F'
650dAC                              or $pcmd = '*RECEIV1'  and
650dAC                             $itstyp = 'F'
412dAC                   exsr      putaof
412dAC                   if        q1lft = 0  and
412dAC                             q2lft = 0  and
412dAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR05'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
412dAC                   goto      endaf
412dAC                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
412dAC                   endif
     *
     *  Otherwise, we try to put it in an empty active slot.
     *
     C                   exsr      putact
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR05'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
     C                   goto      endaf
     C                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
     *
     *  Then we try the slots directly above the picking slot.
     *
413bAC     #awfx1        tag
413bA*
     C                   if        pckasl <> *blanks
     C                   exsr      putabv
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR06'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
     C                   goto      endaf
     C                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
     C                   endif
     *
     *  Then we try the upper levels around the picking slot.
     *
     C                   exsr      putupr
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR07'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYFIX'
413aAC                   exsr      zztrck
     C                   goto      endaf
     C                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
413bA*
413bA*   Item has a soft designation - not all product putaway so
413bA*   try again. This time look for slots with no designation.
413bA*
413bAC                   if        dstype = 'S'  and
413bAC                             wodesg = *off
413bAC                   if        q1lft > 0  or
413bAC                             q2lft > 0  or
413bAC                             q3lft > 0
413bAC                   eval      kydesg = *blanks
413bAC                   eval      wodesg = *on
413bAC                   eval      trnbr = 'TR59'
413bAC                   movel     '*RCV050'     trcode
413bAC                   eval      trsr50 = 'AWYFIX'
413bAC                   exsr      zztrck
413bAC                   goto      #awfx1
413bAC                   endif
640dA*      Loop if something put away.
640dAC                   if        q1lft <> q1sav or
640dAC                             q2lft <> q2sav or
640dAC                             q3lft <> q3sav
640dAC                   iter
640dAC                   endif
413bAC                   endif
     *
640dA*    If we make it here, nothing was put away, so get out.
640dA*
640dAC                   leave
640dAC                   enddo
640dA
     C     endaf         endsr
     *----------------------------------------------------------------
     *
     *  AWYPIR  Put away PIR item.
     *
     C     awypir        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'AWYPIR  '    trsubr
413aAC                   exsr      zztrck
     C                   eval      error = *off
411 A*
411 A*  Check for multiple slots for item.
411 A*
411 AC                   exsr      chkmlt
     *
     *  Try to put qty away in first picking slot.
     *
     C                   if        $pcmd = '*RETURN '
640hAC                             or $pcmd = '*SPRECV '
     C                   exsr      putpck
640hAC     error         cabeq     *on           endap
413aAC                   if        q1lft = 0  and
413aAC                             q2lft = 0  and
413aAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR08'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYPIR'
413aAC                   exsr      zztrck
413aAC                   goto      endap
413aAC                   endif
412bAC                   else
415 D**         MLTFLG    IFEQ *OFF
415 MC                   if        mltflg = *on  and
416 AC                             opipck <> 'Y'
412bAC                   exsr      putlst
412bAC                   endif
412bAC                   endif
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR03'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYPIR'
413aAC                   exsr      zztrck
     C                   goto      endap
     C                   endif
412bA*
412bA*  Otherwise, we try to put it in an empty active
412bA*  pick slot(s).
412bA*
412bAC                   exsr      putapk
412bD*
412bD*  Then try to put it in an existing reserved slot.
412bD*
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
413aAC                   eval      trnbr = 'TR04'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'AWYPIR'
413aAC                   exsr      zztrck
     C                   goto      endap
     C                   endif
     *
     *  For everything else we try to find a verified slot.
     *
413bAC     #awpr1        tag
413bA*
     C                   exsr      putpir
413bA*
413bA*   Item has a soft designation - not all product putaway so
413bA*   try again. This time look for slots with no designation.
413bA*
413bAC                   if        dstype = 'S'  and
413bAC                             wodesg = *off
413bAC                   if        q1lft > 0  or
413bAC                             q2lft > 0  or
413bAC                             q3lft > 0
413bAC                   eval      kydesg = *blanks
413bAC                   eval      wodesg = *on
413bAC                   eval      trnbr = 'TR59'
413bAC                   movel     '*RCV050'     trcode
413bAC                   eval      trsr50 = 'AWYPIR'
413bAC                   exsr      zztrck
413bAC                   goto      #awpr1
413bAC                   endif
413bAC                   endif
     *
     C     endap         endsr
     *----------------------------------------------------------------
     *
411 A*  CHKMLT  Check for multiple slots for an item.
     *
     C     chkmlt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'CHKMLT  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      actcnt = 0
     C                   eval      mltflg = *off
417bA*
417bA*  Don't do check for *MOVEINP.
417bA*
417bAC     orgcmd        cabeq     '*MOVEINP'    endmlt
     *
650gDC***  keys3c        setll     slot3
650gMC     keys3c        setll     slot13
     C                   dow       forevr = forevr
650gDC***  keys3c        reade(n)  slot3                                7879
650gMC     keys3c        reade(n)  slot13                               7879
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        slstat = 'Z'
     C                             or slstat = 'V'
640fAC                             or slsdef = 'BF'
412eAC                             or slpick = 'Y'
412eAC                                and slstyp = 'F'
412eAC                                and opmpck = 'Y'
TMPDSC                             or slpick = 'Y'
TMPDSC                                and slrsrv = 'Y'
TMPDSC                                and slstyp = 'P'
     C                   iter
     C                   endif
     C                   add       1             actcnt
TMPDSC                   if        actcnt >= 1
TMPMBC                                and slstyp = 'P'
412eA*
412eAC                             or actcnt >= 2
412eAC                                and opmpck = 'N'
412eA*
412eAC                             or actcnt >= 1
412eAC                                and slstyp = 'F'
412eAC                                and opmpck = 'Y'
     C                   eval      mltflg = *on
     C                   leave
     C                   endif
     C                   enddo
     *
417bMC     endmlt        endsr
     *----------------------------------------------------------------
409 A*
409 A*  CHKVSL  Check if virtual slots exist for normal slot.
409 A*
409 A*
409 AC     chkvsl        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'CHKVSL  '    trsubr
413aAC                   exsr      zztrck
409 AC     keyv2         setll     vslot2
409 AC     keyv2         reade     vslot2                                 75
409 AC                   if        not *in75
409 AC                   eval      vsfind = *on
413aAC                   eval      trnbr = 'TR21'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'CHKVSL'
413aAC                   exsr      zztrck
409 AC                   else
409 AC                   eval      vsfind = *off
409 AC                   endif
409 AC     endvsl        endsr
     *----------------------------------------------------------------
     *
     *  GETACT  Get next activity zone for slot search.
     *
     *    This routine will get lower priority codes before it will
     *    look at higher priority codes.
     *
     *    Activity zone code priorities are alphabetic by code, where
     *    'A' is the highest priority.
     *
     C     getact        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETACT  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      tmprtn = '*OK     '
     C                   select
     *
     *   Set pointer to first code to look for or ...
     *
     C                   when      actcmd = '*RESET  '
     C                   eval      actpos = actbeg
     *
     *   Get next code to look for on a priority basis.
     *
     C                   other
     C                   select
     *
     *      Working with lower priority codes.
     *        - If there are no more lower codes then try to get
     *          higher priority codes. If there are no higher codes
     *          then return *NOMORE.
     *
     C                   when      actpos >= actbeg
     C                   add       1             actpos
     C                   if        actpos > lstact
     C                   if        actbeg = 1
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      actpos = actbeg
     C                   else
     C                   eval      actpos = actbeg - 1
     C                   endif
     C                   endif
     *
     *      Working with higer priority codes.
     *        - If there are no higher codes then return *NOMORE.
     *
     C                   other
     C                   if        actpos = 1
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      actpos = actbeg
     C                   else
     C                   eval      actpos = actpos - 1
     C                   endif
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   if        tmprtn = '*NOMORE '
     C                   eval      actcmd = '*RESET  '
     C                   else
     C                   eval      actcmd = '*NEXT   '
     C                   endif
     *
     C                   eval      k6actv = act(actpos)
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR10'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETACT'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETASL  Get next aisle for slot search.
     *
     *    This routine will bounce back and forth between aisles
     *    before and after the aisle of the picking slot.
     *
     C     getasl        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETASL  '    trsubr
413aAC                   exsr      zztrck
     *
     C     tryagn        tag
     *
     C                   select
     *
     *   Do one of the following...
     *
     *      Reset values to picking aisle.
     *
     C                   when      aslcmd = '*RESET  '
     C                   eval      k7aisl = pckasl
     C                   eval      bfrrtn = '*OK     '
     C                   eval      bfrasl = pckasl
     C                   eval      aftrtn = '*OK     '
     C                   eval      aftasl = pckasl
     *
     *      Get an aisle that is before the picking slot aisle.
     *
     C                   when      aslcmd = '*BEFORE '
     C                   eval      k1aisl = bfrasl
     C     keys1b        setll     slot1
     C     keys1a        readpe(n) slot1                                  79
     C                   if        not *in79
     C                   eval      k7aisl = slaisl
     C                   eval      bfrasl = slaisl
     C                   else
     C                   eval      bfrrtn = '*NOMORE '
     C                   if        aftrtn <> '*NOMORE '
     C                   eval      aslcmd = '*AFTER  '
     C                   goto      tryagn
     C                   endif
     C                   endif
     *
     *      Get an aisle that is after the picking slot aisle.
     *
     C                   when      aslcmd = '*AFTER  '
     C                   eval      k1aisl = aftasl
     C     keys1b        setgt     slot1
     C     keys1a        reade(n)  slot1                                  79
     C                   if        not *in79
     C                   eval      k7aisl = slaisl
     C                   eval      aftasl = slaisl
     C                   else
     C                   eval      aftrtn = '*NOMORE '
     C                   if        bfrrtn <> '*NOMORE '
     C                   eval      aslcmd = '*BEFORE '
     C                   goto      tryagn
     C                   endif
     C                   endif
     *
     C                   endsl
     *
     *   Prepare for next time around.
     *
     C                   select
     C                   when      bfrrtn = '*NOMORE '  and
     C                             aftrtn = '*NOMORE '
     C                   eval      aslcmd = '*RESET  '
     C                   eval      tmprtn = '*NOMORE '
     *
     C                   when      aslcmd = '*BEFORE '
     C                   eval      aslcmd = '*AFTER  '
     C                   eval      tmprtn = '*OK     '
     *
     C                   other
     C                   eval      aslcmd = '*BEFORE '
     C                   eval      tmprtn = '*OK     '
     *
     C                   endsl
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR11'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETASL'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETBLD  Get next build code for slot search.
     *
     *    This routine will get heavier codes before it will
     *    look at lighter codes.
     *
     *    Build code weights are based on a user entered
     *    sequence number, where 0 is the heaviest and 99 is the
     *    lightest.
     *
     C     getbld        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETBLD  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      tmprtn = '*OK     '
     C                   select
     *
     *   Set pointer to first code to look for or ...
     *
     C                   when      bldcmd = '*RESET  '
     C                   eval      bldpos = bldbeg
     *
     *   Get next code to look for on a priority basis.
     *
     C                   other
     C                   select
     *
     *      Working with heavier codes.
     *        - If there are no more heavier codes then try to get
     *          lighter codes. If there are no lighter codes
     *          then return *NOMORE.
     *
     C                   when      bldpos <= bldbeg
     C                   eval      bldpos = bldpos - 1
     C                   if        bldpos = 0
     C                   if        bldbeg = lstbld
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      bldpos = bldbeg
     C                   else
     C     bldbeg        add       1             bldpos
     C                   endif
     C                   endif
     *
     *      Working with lighter codes.
     *        - If there are no lighter codes then return *NOMORE.
     *
     C                   other
     C                   if        bldpos = lstbld
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      bldpos = bldbeg
     C                   else
     C                   add       1             bldpos
     C                   endif
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   if        tmprtn = '*NOMORE '
     C                   eval      bldcmd = '*RESET  '
     C                   else
     C                   eval      bldcmd = '*NEXT   '
     C                   endif
     *
     C                   eval      k6bld = bld(bldpos)
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR12'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETBLD'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETDEF  Get next tie/high definition for slot search.
     *
     *    This routine will get lower priority definitions before it
     *    will look at higher priority definitions.
     *
     *    Tie/High definition priorities are based on the number of
     *    pallets that would be need where the least number of pallets
     *    would be the highest prioritiy.
     *
     C     getdef        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETDEF  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      tmprtn = '*OK     '
     C                   select
     *
     *   Set pointer to first code to look for or ...
     *
     C                   when      defcmd = '*RESET  '
     C                   eval      defpos = defbeg
     *
     *   Get next code to look for on a priority basis.
     *
     C                   other
     C                   select
     *
     *      Working with lower priority codes.
     *        - If there are no more lower codes then try to get
     *          higher priority codes. If there are no higher codes
     *          then return *NOMORE.
     *
     C                   when      defpos >= defbeg
     C                   add       1             defpos
     C                   if        defpos > lstdef
     C                   if        defbeg = 1
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      defpos = defbeg
     C                   else
     C                   eval      defpos = defbeg - 1
     C                   endif
     C                   endif
     *
     *      Working with higer priority codes.
     *        - If there are no higher codes then return *NOMORE.
     *
     C                   other
     C                   if        defpos = 1
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      defpos = defbeg
     C                   else
     C                   eval      defpos = defpos - 1
     C                   endif
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   if        tmprtn = '*NOMORE '
     C                   eval      defcmd = '*RESET  '
     C                   else
     C                   eval      defcmd = '*NEXT   '
     C                   endif
     *
     C                   eval      svgrp = ocr(defpos)
     C     svocur        occur     defs
     C                   eval      k6sdef = dssdef
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR13'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETDEF'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  GETLVL  Get next level for slot search.
     *
     *    This routine starts at the highest level and works down.
     *
     C     getlvl        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETLVL  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      tmprtn = '*OK     '
     C                   select
     *
     *   Set pointer to first code to look for or ...
     *
     C                   when      lvlcmd = '*RESET  '
     C                   eval      k7rlvl = lvlbeg
     *
     *   Get lower level to look for.
     *
     C                   other
     C                   if        k7rlvl = 1
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      k7rlvl = lvlbeg
     C                   else
     C                   eval      k7rlvl = k7rlvl - 1
     C                   endif
     *
     C                   endsl
     *
     C                   if        tmprtn = '*NOMORE '
     C                   eval      lvlcmd = '*RESET  '
     C                   else
     C                   eval      lvlcmd = '*NEXT   '
     C                   endif
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR14'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETLVL'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
217 A*
217 A*  GETPAS  Get next aisle for PIR slot search.
217 A*
217 A*    This routine will bounce back and forth between aisles
217 A*    before and after the aisle of the picking slot.
217 A*    If item doesn't exist in warehouse, we only execute to
217 A*    set parameters.
217 A*
217 AC     getpas        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETPAS  '    trsubr
413aAC                   exsr      zztrck
217 A*
217 AC                   if        prfind = *off
217 AC                   select
217 AC                   when      aslcmd = '*RESET  '
217 AC                   eval      tmprtn = '*OK     '
217 AC                   eval      aslcmd = '*OK     '
217 AC                   other
217 AC                   eval      tmprtn = '*NOMORE '
217 AC                   eval      aslcmd = '*RESET  '
217 AC                   endsl
217 AC                   goto      endpas
217 AC                   endif
217 A*
217 AC     tryag1        tag
217 A*
217 AC                   select
217 A*
217 A*   Do one of the following...
217 A*
217 A*      Reset values to picking aisle.
217 A*
217 AC                   when      aslcmd = '*RESET  '
217 AC                   eval      k7aisl = pckasl
217 AC                   eval      bfrrtn = '*OK     '
217 AC                   eval      bfrasl = pckasl
217 AC                   eval      aftrtn = '*OK     '
217 AC                   eval      aftasl = pckasl
217 A*
217 A*      Get an aisle that is before the picking slot aisle.
217 A*
217 AC                   when      aslcmd = '*BEFORE '
217 AC                   eval      k1aisl = bfrasl
217 AC     keys1b        setll     slot1
217 AC     keys1a        readpe(n) slot1                                  79
217 AC                   if        not *in79
217 AC                   eval      k7aisl = slaisl
217 AC                   eval      bfrasl = slaisl
217 AC                   else
217 AC                   eval      bfrrtn = '*NOMORE '
217 AC                   if        aftrtn <> '*NOMORE '
217 AC                   eval      aslcmd = '*AFTER  '
217 AC                   goto      tryag1
217 AC                   endif
217 AC                   endif
217 A*
217 A*      Get an aisle that is after the picking slot aisle.
217 A*
217 AC                   when      aslcmd = '*AFTER  '
217 AC                   eval      k1aisl = aftasl
217 AC     keys1b        setgt     slot1
217 AC     keys1a        reade(n)  slot1                                  79
217 AC                   if        not *in79
217 AC                   eval      k7aisl = slaisl
217 AC                   eval      aftasl = slaisl
217 AC                   else
217 AC                   eval      aftrtn = '*NOMORE '
217 AC                   if        bfrrtn <> '*NOMORE '
217 AC                   eval      aslcmd = '*BEFORE '
217 AC                   goto      tryag1
217 AC                   endif
217 AC                   endif
217 A*
217 AC                   endsl
217 A*
217 A*   Prepare for next time around.
217 A*
217 AC                   select
217 AC                   when      bfrrtn = '*NOMORE '  and
217 AC                             aftrtn = '*NOMORE '
217 AC                   eval      aslcmd = '*RESET  '
217 AC                   eval      tmprtn = '*NOMORE '
217 A*
217 AC                   when      aslcmd = '*BEFORE '
217 AC                   eval      aslcmd = '*AFTER  '
217 AC                   eval      tmprtn = '*OK     '
217 A*
217 AC                   other
217 AC                   eval      aslcmd = '*BEFORE '
217 AC                   eval      tmprtn = '*OK     '
217 AC                   if        oppfrc = 'Y'
217 AC                   eval      aslcmd = '*RESET  '
217 AC                   eval      tmprtn = '*NOMORE '
217 AC                   endif
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR15'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETPAS'
413aAC                   exsr      zztrck
413aAC                   endif
217 A*
217 AC                   endsl
217 A*
217 AC     endpas        endsr
     *----------------------------------------------------------------
     *
     *  GETSID  Get next side for slot search while in picking aisle.
     *
     C     getsid        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'GETSID  '    trsubr
413aAC                   exsr      zztrck
     *
     C                   eval      tmprtn = '*OK     '
     *
     C                   select
     *
     *   Set pointer to the picking slot side of the aisle or ...
     *
     C                   when      sidcmd = '*RESET  '
     C                   if        k7aisl = pckasl
     C                   eval      cursid = pcksid
     C                   else
     C                   eval      cursid = '*EITHER '
     C                   endif
     *
     *   Flip to other side.
     *
     C                   other
     C                   select
     *
     *      If we are not in the picking aisle then we don't care
     *      about which side we are on so get out.
     *
     C                   when      k7aisl <> pckasl
     C                   eval      tmprtn = '*NOMORE '
     *
     *      If we are on the picking side then flip to the other side.
     *
     C                   when      cursid = pcksid
     C                   if        cursid = '*ODD    '
     C                   eval      cursid = '*EVEN   '
     C                   else
     C                   eval      cursid = '*ODD    '
     C                   endif
     *
     *      Otherwise, there are no more sides to try.
     *
     C                   other
     C                   eval      tmprtn = '*NOMORE '
     C                   eval      cursid = pcksid
     *
     C                   endsl
     *
     C                   endsl
     *
     C                   if        tmprtn = '*NOMORE '
     C                   eval      sidcmd = '*RESET  '
     C                   else
     C                   eval      sidcmd = '*NEXT   '
     C                   endif
413aAC                   if        tmprtn <> '*NOMORE '
413aAC                   eval      trnbr = 'TR16'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'GETSID'
413aAC                   exsr      zztrck
413aAC                   endif
     *
     C     endgs         endsr

610bA*----------------------------------------------------------------
610bA*  chkUsage   Check slot usage
610bA*----------------------------------------------------------------
610bAC     chkUsage      begsr

     C                   call      'CHKUSAGE'
     C                   parm      slwhse        $uWhse
     C                   parm      slwhdp        $uWhdp
     C                   parm      sldisp        $uDisp
640gAC                   parm      slrsrv        $uRsrv
     C                   parm      #sitem        $uItem
640bAC                   parm                    $uEntDte
640bAC                   parm                    $uExpDte
640gDC**                 parm      0             $uCube
     C                   parm      0             $uPieces
     C                   parm      0             $uRecs
     C                   parm      ' '           $uDiffItem
640bAC                   parm      ' '           $uDiffEntd
640bAC                   parm      ' '           $uDiffExpd

WSTaAC                   if        client = westside
WSTaAc                   eval      $uDiffEntd = 'N'
WSTaAc                   endif
640aA*  Add what has been put away in this call to RC160
640aA*    ($uCube is not used in program so is not calculated here)
640aA
640aAC     1             do        lstlbl        z
640aAC                   eval      savslt = slt(z)
640dAC                   if        savwhdp = slwhdp and savdsp = sldisp
640aAC                   eval      $uPieces += savq1 + savq2 + savq3
640aAC                   eval      $uRecs += 1
640dAC                   endif
640aAC                   enddo

640bAC                   eval      $uEntDte = 0
640bAC                   eval      $uExpDte = 0
     C                   endsr
     *----------------------------------------------------------------
     *
     *  INIT    Initialize arrays.
     *
     C     init          begsr
413aA*
413aA*  Initialize tracking key.
413aA*
413aAC                   eval      trwhse = $pwhse
413aAC                   if        $pcmd = '*RETURN '
413aAC                   eval      trpo = $pcmd
413aAC                   else
413aAC                   eval      trpo = $ppo
413aAC                   endif
413aAC                   eval      tritem = $pitem
413aAC                   eval      trrcdt = today
413aAC                   time                    trrctm
413aAC                   eval      trdev = #job
413aAC                   eval      truser = #user
413aAC                   eval      r = *zeros
413aAC                   eval      trsubr = *blanks
413aAC                   eval      trrfld = *blanks
413dAC                   eval      trsq10 = *zeros
413dAC                   eval      trsq11 = *zeros
413dAC                   eval      trsq40 = *zeros
413dAC                   eval      trsq50 = *zeros
413aAC                   eval      trldef = *zeros
413aAC                   eval      trnbr = *blanks
413aAC                   eval      cvt2a = *blanks
413aAC                   eval      cvt3a = *blanks
413aAC                   eval      cvt5a = *blanks
413aAC                   eval      trkey = *blanks
413bAC                   eval      wodesg = *off
413aAC                   eval      flgsys = *off
413aAC                   eval      flgrcv = *off
413aAC                   eval      flgitm = *off
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'INIT'        trsubr
413aAC                   exsr      zztrck
     C                   eval      error = *off
217 AC                   eval      prfind = *off
217 AC                   eval      pckasl = *blanks
730aA /free
730aA   if %parms >= 31;
730aA     jobuser = $puser;
730aA   else;
730aA     jobuser = #curruser;
730aA   endif;
730aA /end-free
610aA*
610aA*    Get User's employee number
610aA*
610aAC                   call      'GETUSER'
730aDC*                  parm      #curruser     $code            10
730aMC                   parm      jobuser       $code            10
610aAC                   parm      0             $whse             3 0
610aAC                   parm      0             $emp#             5 0
610aAC                   parm      *blanks       $fnam            15
610aAC                   parm      *blanks       $init             1
610aAC                   parm      *blanks       $lnam            20
610aAC                   parm      *blanks       $whdp             5
610aAC                   parm      *blanks       $styp             1
610aAC                   parm      *blanks       $shft             6
610aAC                   parm      *blanks       $crew             6
610aAC                   parm      0             $nhrs             3 1
610aAC                   parm      *blanks       $rtn              8
     *
     *  Initialize quantity left.
     *
     C                   eval      q1lft = $pqty1
     C                   eval      q2lft = $pqty2
     C                   eval      q3lft = $pqty3
     C                   eval      lstlbl = 0
     C                   eval      slt = *blanks
     *
     *  Initialize priority to use for new slots.
     *
     C                   if        $pcmd = '*RETURN '
     C                   eval      prirty = -(9)
     C                   else
     C                   eval      prirty = 0
     C                   endif
     *
     *   Get highest rack level in warehouse.
     *
     C                   if        first = *on
    D*                    Z-ADD1         LVLBEG  20
    MC                   eval      lvlbeg = 0
     C     keyrk         setll     racks                                  79
     C                   dou       forevr <> forevr
     C     keyrk         reade     racks                                  79
     C                   if        *in79
     C                   leave
     C                   endif
410 A*  If a rack code ends with a '*' it is assumed to be levels
410 A*  11-20 for the corresponding rack without the '*'.
410 AC                   movea     rkcode        a5
410 AC                   eval      uprflg = *off
410 AC     1             do        5             x
410 AC                   eval      y = 6 - x
410 AC                   if        a5(y) = *blanks
410 AC                   iter
410 AC                   endif
410 AC                   if        a5(y) = '*'
410 AC                   eval      uprflg = *on
410 AC                   endif
410 AC                   leave
410 AC                   enddo
410 A*
     C                   eval      x = 10
410 AC                   if        uprflg = *on
410 AC                   eval      y = 20
410 AC                   else
410 AC                   eval      y = x
410 AC                   endif
    D*          1         DO   9
    MC     1             do        10
     C                   if        rkl(x) <> *blanks  and
410 MC                             y > lvlbeg
410 D*R         X         ANDGTLVLBEG
410 MC                   eval      lvlbeg = y
410 D*R                   Z-ADDX         LVLBEG
     C                   leave
     C                   endif
410 D*R         X         IFEQ LVLBEG
410 MC                   if        y = lvlbeg
     C                   leave
     C                   else
     C                   eval      x = x - 1
410 AC                   eval      y = y - 1
     C                   endif
     C                   enddo
     C                   enddo
    AC                   if        lvlbeg = 0
410 D*R                   Z-ADD10        LVLBEG
410 MC                   eval      lvlbeg = 20
    AC                   endif
     C                   endif
416fA*
416fA*  Get Feature option.
416fA*
416fAC                   eval      opcode = '*FEATURE'
416fAC     keyop         chain     options                            79
416fAC                   if        *in79
416fAC                   eval      opfeat = '2'
416fAC                   else
416fAC                   eval      opdat3 = opdata
416fAC                   endif
416fAC                   if        opfeat = '1'
416fAC                   eval      locatr = *on
416fAC                   else
416fAC                   eval      locatr = *off
416fAC                   endif
412eA*
412eA*   Get System options.
412eA*
412eAC                   eval      kywhse = *zeros
412eAC                   eval      opcode = '*SYSTEM '
412eAC     optsky        chain     options                            79
412eAC                   if        *in79
412eAC                   eval      opmpck = 'N'
413aAC                   eval      flgsys = *on
412eAC                   else
412eAC                   eval      opdat2 = opdata
412eAC                   endif
     *
     *  Get receiving options.
     *
     C                   eval      opcode = '*RCVLBL '
     C     keyop         chain     options                            79
     C                   if        *in79
412eAC                   eval      opapck = 'N'
     C                   eval      error = *on
     C                   eval      $prtn = '*NOOPT  '
413aAC                   eval      flgrcv = *on
413aD*R                   GOTO ENDINT
     C                   endif
     *
     *  Get item information.
     *
610aAC                   exsr      clr$item
610aAC                   eval      $itwhse  = $pwhse
610aAC                   eval      $ititem  = $pitem
610aA
610aAC                   eval      $dricommand = '*ITEM'
610aAC                   eval      $drisubcmd  = '%GETALL'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      ck4err = *on
610aAC                   exsr      zzzdricop
610aAC                   if        error
     C                   eval      $prtn = '*INVALID'
413aAC                   eval      flgitm = *on
610aMC                   eval      $imnrpk = *zeros
     C                   endif
413bA*
413bA*   Get misc. item information.
413bA*
610aMC     $itdesg       chain     desig                              79
413bAC                   if        *in79
413bAC                   eval      dstype = 'H'
413bAC                   endif
411 A*
411 A*  Save information about item being received (Item that was ordered)
411 A*
610aMC                   eval      #otype = $ittype
610aMC                   eval      #oitem = $ititem
610aMC                   eval      #odesc = $itdesc
610aMC                   eval      #opdsc = $itpdsc
610aMC                   eval      #bitem = $ititem
610aMC                   eval      #sitem = $ititem
610aMC                   eval      #bdesc = $itdesc
610aMC                   eval      #bpdsc = $itpdsc
610aMC                   eval      kydesg = $itdesg
411 A*
411 A*  If Contract, Alias or SSB Item
411 A*   Then verify Base item exists.
411 A*
610aMC                   if        $ittype = 'C'  or
610aMC                             $ittype = 'A'  or
610aMC                             $ittype = 'S'
411 A*
411 AC                   call      'GETBASE'
411 AC                   parm      $pwhse        $gwhse            3 0
411 AC                   parm      $pitem        $gitem           15
411 AC                   parm      ' '           #bitem
411 AC                   parm                    #bityp            1
411 AC                   parm                    #bdesc           30
411 AC                   parm                    #bpdsc           15
411 AC                   parm                    #bwhdp            5
411 AC                   parm                    #bstyp            1
411 AC                   parm                    #bum              2
411 AC                   parm                    #bum2             2
411 AC                   parm                    #bumq2            3 0
411 AC                   parm                    #bum3             2
411 AC                   parm                    #bumq3            3 0
411 AC                   parm      ' '           #bcitm           15
411 AC                   parm                    #bctyp            1
411 AC                   parm                    #bcdsc           30
411 AC                   parm                    #bcpds           15
411 AC                   parm                    #bcwdp            5
411 AC                   parm                    #bcstp            1
411 AC                   parm                    #bcum             2
411 AC                   parm                    #bcum2            2
411 AC                   parm                    #bcuq2            3 0
411 AC                   parm                    #bcum3            2
411 AC                   parm                    #bcuq3            3 0
411 AC                   parm                    #brtn             8
411 A*
411 AC                   endif
417cA*
417cA*   Then get Base Slot item.
417cA*
610aMC                   call      'GETSLOTITM'
610aMC                   parm      $itwhse       $gwhse
610aMC                   parm      $ititem       $gitem
417bAC                   parm      ' '           #sitem
417bAC                   parm                    #sityp            1
417bAC                   parm                    #sdesc           30
417bAC                   parm                    #spdsc           15
417bAC                   parm                    #srtn            10
417bAC                   parm                    #smsg            60
411 A*
411 A*  If Same Slot Breakdown Item
411 A*   Then quantities need to be changed into corresponding
411 A*        Base breakdown quantities.
411 A*
610aMC                   if        $ittype = 'S'  or
610aMC                             $ittype = 'A'  and
417dAC                             #bityp = 'S'
411 AC                   eval      q3lft = q2lft
411 AC                   eval      q2lft = q1lft
411 AC                   eval      q1lft = 0
411 AC                   endif
411 A*
411 A*  Save initial quantities for comparison at end of mainline code.
411 A*
411 AC                   eval      #bqty1 = q1lft
411 AC                   eval      #bqty2 = q2lft
411 AC                   eval      #bqty3 = q3lft
     *
     *  Make sure breakdown qty's are not greater than unit of
     *  measure quantity.
     *
610aMC                   dow       q3lft >= $itumq3  and
610aMC                             $itumq3 <> 0
610aMC                   eval      q3lft = q3lft - $itumq3
     C                   add       1             q2lft
     C                   enddo
     *
610aMC                   dow       q2lft >= $itumq2  and
610aMC                             $itumq2 <> 0
610aMC                   eval      q2lft = q2lft - $itumq2
     C                   add       1             q1lft
     C                   enddo
     *
     *   Get "normal" tie/high definitions for item.
     *
     C                   eval      lstdef = 0
     C                   eval      curdef = 0
     C                   move      *hival        ocr
     *
     C     keyid1        setll     itemdef1
     *
     C                   dou       lstdef = 9
     C     keyid1        reade     itemdef1                               79
     C                   if        *in79
     C                   leave
     C                   endif
402 A*
402 AC                   if        idtie = 0  and
402 AC                             idhigh = 0
402 AC                   iter
402 AC                   endif
     *
     C                   add       1             lstdef
     C     lstdef        occur     defs
     C                   eval      dssdef = idsdef
     C                   eval      dstie = idtie
     C                   eval      dshigh = idhigh
     C                   select
     C                   when      idtie = 0
     C                   eval      dspqty = idhigh
     C                   when      idhigh = 0
     C                   eval      dspqty = idtie
     C                   other
     C     idtie         mult      idhigh        dspqty
     C                   endsl
     C                   eval      dspos = sdpos
     C                   if        sdpos < 1
     C                   eval      dsposf = 1
     C                   else
     C                   eval      dsposf = sdpos
     C                   endif
610eDC**                 eval      dstqty = dspqty * dspos
610eMC                   eval      dstqty = dspqty * dsposf
640iA
640iA*    If receiving single pallet that can't be split,
640iA*       and qty is greater than pallet qty,
640iA*       Then remove definition from list.
640iA
640iAC                   if        $pcmd = '*RECEIV1'
640iAC                             and $pqty1 > dspqty
640kAC                             or $pcmd = '*RETURN1'
640kAC                             and $pqty1 > dspqty
640iAC                   eval      lstdef -= 1
640iAC                   endif
     *
     C                   enddo
     *
     *  Error if no definitions found.
     *
     C                   if        lstdef = 0  and
500bAC                             $pcmd <> '*SPRECV '  and
413aAC                             error = *off
     C                   eval      error = *on
640iAC                   if        $pcmd = '*RECEIV1'
640kac                             or $pcmd = '*RETURN1'
640iAC                   eval      $prtn = '*NODEF2 '
640iAC                   else
     C                   eval      $prtn = '*NODEF  '
640iAC                   endif
640hAC                   leavesr
     C                   endif
500bAC                   if        lstdef = 0  and
500bAC                             $pcmd = '*SPRECV '
500bAC                   eval      dstie = 1
500bAC                   eval      dshigh = 1
500bAC                   endif
     *
     *  Position to starting build code.
     *
     C                   eval      bldpos = 1
     C     1             do        lstbld        x
610aMC                   if        $itbld = bld(x)
     C                   eval      bldpos = x
     C                   leave
     C                   endif
     C                   enddo
     C                   eval      bldbeg = bldpos
     *
     *  Position to starting activity zone.
     *
     C                   eval      actpos = lstact
     C     1             do        lstact        x
610aMC                   if        $itactv = act(x)
     C                   eval      actpos = x
     C                   leave
     C                   endif
     C                   enddo
     C                   eval      actbeg = actpos
    A*
    A*  Calculate definition totals for best fit.
    A*
    AC                   exsr      recalc
     *
412eA*  Check to see if Fixed item has a pick slot.
412eA*  Only do this test if receiving option allows
412eA*  pick slots to be automatically assigned.
412eA*
412eAC                   select
610aMC                   when      $itstyp = 'F'  and
412eAC                             $pcmd = '*RECEIVE'  and
412eAC                             opapck = 'Y'  and
413aAC                             flgitm = *off  or                            Valid item
650fA*
650fAC                             $itstyp = 'F'  and
650fAC                             $pcmd = '*RECEIV1'  and
650fAC                             opapck = 'Y'  and
650fAC                             flgitm = *off  or                            Valid item
412eA*
610aMC                             $itstyp = 'F'  and
412eAC                             $pcmd = '*RETURN '  and
412eAC                             opapck = 'Y'  and
413aAC                             flgitm = *off                                Valid item
412eA*
412eAC                   eval      pckslt = '*NO '
412eAC                   eval      nbrpck = *zeros
412eAC                   eval      k3stat = 'A '
412eAC                   eval      k3pick = 'Y'
650gDC***  keys3         setll     slot3
650gMC     keys3         setll     slot13
412eAC                   dou       forevr <> forevr
650gDC***  keys3         reade(n)  slot3                                7879
650gMC     keys3         reade(n)  slot13                               7879
412eAC                   if        *in79
412eAC                   leave
412eAC                   endif
412eA*
412eAC                   eval      pckslt = '*YES'
412eAC                   add       1             nbrpck
412eAC                   enddo
412eA*
412eA*  Compute number of pick slots needed.
412eA*
610aMC                   eval      nrshrt = $imnrpk - nbrpck
412eA*
412eA*  If item not assigned to pick slot, then find available slot.
412eA*
412eAC                   select
412eAC                   when      pckslt = '*NO '  and
412eAC                             opapck = 'Y'  and
610aMC                             $imnrpk > 0  or
412eA*
412eAC                             pckslt = '*YES'  and
412eAC                             opapck = 'Y'  and
412eAC                             nrshrt > *zeros
413aAC                   eval      trnbr = 'TR72'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'INIT'
413aAC                   exsr      zztrck
412eAC                   exsr      asnslt
412eAC                   endsl
412eAC                   endsl
     C                   eval      first = *off
     *
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV002 '                          System options
413aAC                   exsr      zztrck
413aAC                   eval      trcode = '*RCV003 '                          Rcv options
413aAC                   exsr      zztrck
413aAC                   eval      trcode = '*RCV020 '                          Activity zones
413aAC                   exsr      zztrck
413aAC                   eval      trcode = '*RCV030 '                          Build codes
413aAC                   exsr      zztrck
     C     endint        endsr
     *----------------------------------------------------------------
     *
     *  POST    Post receiving.
     *
     C     post          begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'POST    '    trsubr
413aAC                   exsr      zztrck
    A*
    A*  Get batch number for labels.
    A*
    AC                   call      'PIRBAT#'                                                   GFG
    AC                   parm      *zeros        $pbat             7 0                         GFG
650jA*
650jA*     - Create batch control record.
650jA*
650jAC                   eval      btbat# = $pbat
650jAC                   eval      btwhse = $pwhse
650jAC                   eval      bttype = '*RCV    '
650jAC                   eval      btstat = ' '
650jAC                   eval      btrte = ' '
650jAC                   eval      $cvcmd = '*CURCMD '
650jAC                   call      @cvtdt
650jAC                   parm                    $cvtdt
650jAC                   eval      btstrd = $cvd8o
650jAC                   time                    btstrt
650jAC                   eval      btstrb = #user
650jAC                   write     btrec
     *
     *  Get sequence number to be used for PO detail file.
218 A*   If sequence number wasn't passed in PARMS.
     *
     C                   if        $pcmd = '*RECEIVE'  or
500aAC                             $pcmd = '*SPRECV '
650bAc                             or $pcmd = '*RECEIV1'
218 AC                   if        $pseq = 0
218 MC     keyph         setgt     podtl
218 MC     keyph         readpe(n) podtl                                  79
     C                   if        *in79
218 MC                   eval      svseq = 1
     C                   else
218 MC     pdseq         add       1             svseq
     C                   endif
218 AC                   else
218 AC                   eval      svseq = $pseq
218 AC                   endif
     C                   endif
     *
     *   Inz. quantities for return with no put away.
416a C                   if        $ppo = '*NOSTOCK'
416a C                   eval      lstlbl = 1
416a C                   eval      savlbl = 1
416a C                   eval      savq1 = $pqty1
416a C                   eval      savq2 = $pqty2
416a C                   eval      savq3 = $pqty3
416a C                   eval      savtie = 0
416a C                   eval      savhgh = 0
416a C                   endif
416a *
     C     1             do        lstlbl        y
610aDC**   $ppo          cabeq     '*NOSTOCK'    nostk1
     C                   eval      savslt = slt(y)
     C                   add       savq1         $prq1
     C                   add       savq2         $prq2
     C                   add       savq3         $prq3
     C                   add       savlbl        $prpal
     C     savtie        mult      savhgh        palqty
610aAC     $ppo          cabeq     '*NOSTOCK'    nostk1
610aDC**
610aDC** Get slot record. Update status if necessary.
610aDC**
610aDC**                 eval      k2disp = savdsp
610aDC**                 if        savsta = 'V '
610aDC**   keys2         chain     slot2                              7978
610aDC**                 eval      slstat = 'A '
610aDC**                 update    s2rec
610aDC**
610aDC**                 else
610aDC**   keys2         chain(n)  slot2                              7978
610aDC**                 endif
610aDC**
610aDC** Add stock to warehouse quantity.
610aDC**
610aDC**   If Alias or SSB item
610aDC**     Then DO NOT update quantity of item being received.
610aDC**
610aDC**                 if        ittype <> 'A'  and
610aDC**                           ittype <> 'S'
610aDC**                 eval      $acmd = '*STOCK  '
610aDC**                 eval      $aprg = #prog
610aDC**                 eval      $atype = '*BATCH  '
610aDC**                 eval      $awhse = $pwhse
610aDC**                 eval      $aitem = $pitem
610aDC**                 eval      $aqty1 = savq1
610aDC**                 eval      $aqty2 = savq2
610aDC**                 eval      $aqty3 = savq3
610aDC**                 call      'ADJQTY'
610aDC**                 parm                    $acmd             8
610aDC**                 parm                    $aprg            10
610aDC**                 parm                    $atype            8
610aDC**                 parm                    $awhse            3 0
610aDC**                 parm                    $aitem           15
610aDC**                 parm                    $aqty1            7 0
610aDC**                 parm                    $aqty2            7 0
610aDC**                 parm                    $aqty3            7 0
610aDC**                 parm                    $artq1            7 0
610aDC**                 parm                    $artq2            7 0
610aDC**                 parm                    $artq3            7 0
610aDC**                 parm                    $artn             8
610aDC**                 parm                    $aerm
610aDC**                 endif
610aDC**
610aDC** If Alias, Contract or SSB item
610aDC**  Then add stock to Base item warehouse quantity.
610aDC**
610aDC**                 if        ittype = 'A'  or
610aDC**                           ittype = 'C'  or
610aDC**                           ittype = 'S'
610aDC**                 eval      $acmd = '*STOCK  '
610aDC**                 eval      $aprg = #prog
610aDC**                 eval      $atype = '*BATCH  '
610aDC**                 eval      $awhse = $pwhse
610aDC**                 eval      $aitem = #sitem
610aDC**                 eval      $aqty1 = savq1
610aDC**                 eval      $aqty2 = savq2
610aDC**                 eval      $aqty3 = savq3
610aDC**                 call      'ADJQTY'
610aDC**                 parm                    $acmd
610aDC**                 parm                    $aprg
610aDC**                 parm                    $atype
610aDC**                 parm                    $awhse
610aDC**                 parm                    $aitem
610aDC**                 parm                    $aqty1
610aDC**                 parm                    $aqty2
610aDC**                 parm                    $aqty3
610aDC**                 parm                    $artq1
610aDC**                 parm                    $artq2
610aDC**                 parm                    $artq3
610aDC**                 parm                    $artn
610aDC**                 parm                    $aerm
610aDC**                 endif
610aDC**
610aDC** If Co-Item
610aDC**  Then allocate stock from Base item warehouse quantity.
610aDC**
610aDC**                 if        ittype = 'C'
610aDC**                 eval      $acmd = '*ALLOC  '
610aDC**                 eval      $aprg = #prog
610aDC**                 eval      $atype = '*BATCH  '
610aDC**                 eval      $awhse = $pwhse
610aDC**                 eval      $aitem = #sitem
610aDC**                 eval      $aqty1 = savq1
610aDC**                 eval      $aqty2 = savq2
610aDC**                 eval      $aqty3 = savq3
610aDC**                 call      'ADJQTY'
610aDC**                 parm                    $acmd
610aDC**                 parm                    $aprg
610aDC**                 parm                    $atype
610aDC**                 parm                    $awhse
610aDC**                 parm                    $aitem
610aDC**                 parm                    $aqty1
610aDC**                 parm                    $aqty2
610aDC**                 parm                    $aqty3
610aDC**                 parm                    $artq1
610aDC**                 parm                    $artq2
610aDC**                 parm                    $artq3
610aDC**                 parm                    $artn
610aDC**                 parm                    $aerm
610aDC**                 endif
     *
     *  Do the following for each label to print.
     *
     *    - Create transaction record.
     *    - Create label record for each quantity type.
     *    - Print label(s).
     *
640jA*   Put item (not qty) into selected slot.
640jA*     (no need to do this for *NOSTOCK)
640jA*
700cAC                   if        $pcmd = '*SPRECV'
700cAC                             and $slstat = 'Z'
700cAC                   goto      nostk1
700cAC                   endif
640jAC                   exsr      clr$slot
640jAC                   eval      $slwhseu = *on
640jAC                   eval      $slwhse  = $pwhse
640jAC                   eval      $slwhdpu = *on
640jAC                   eval      $slwhdp  = savwhdp
640jAC                   eval      $sldispu = *on
640jAC                   eval      $sldisp  = savdsp
640jAC                   eval      $saitemu = *on
640jAC                   eval      $saitem  = #sitem
640jA
640jAC                   eval      $saqtyu  = *on
640jAC                   eval      $saqty1  = 0
640jAC                   eval      $saqty2  = 0
640jAC                   eval      $saqty2  = 0
WSTaAc                   if        client = westside
WSTaAC                   if        $pfifo > 0
WSTaAC                   eval      $slentdu = *on
WSTaAC                   eval      $slentd = $pfifo
WSTaAC                   endif
WSTaAC                   endif
640jA
640jAC                   eval      $dricommand = '*SLOT'
640jAC                   eval      $drisubcmd  = '%DPPUT'
640jAC                   eval      $drisys2upd = 'D'
640jAC                   eval      ck4err = *off
640jAC                   eval      zmsflag = *off
640jAC                   exsr      zzzdricop
640jAC                   if        $drireturn = '*OK'
640jAC                   eval      savdsp = $sldisp
640jAC                   endif
640jA*
416a C     nostk1        tag
     C                   eval      tmpflg = *off
610aDC**   1             do        savlbl        x
610aDC**
610aDC**    Normal quantity.
610aDC**
610aDC**                 if        savq1 > 0
610aDC**
610aDC**       Get transaction number.
610aDC**
610aDC**                 call      'PIRTRN#'
610aDC**                 parm                    pttrn#            7 0
610aDC**
610aDC**       Calculate qty for label. If on the last label use
610aDC**       the qty left otherwise use the full pallet qty.
610aDC**
610aDC**                 if        x = savlbl
     C                   eval      lblqty = savq1
610aDC**                 else
610aDC**                 eval      lblqty = palqty
610aDC**                 endif
610aDC**                 eval      savq1 = savq1 - lblqty
     *
     *        Create label record for Normal qty.
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
610aMC                   eval      lbwhdp = savwhdp
610aAC                   eval      lbdisp = savrcvdsp
610aMC                   eval      lbaisl = savrcvaisl
610aMC                   eval      lbloc = savrcvloc
610aMC                   eval      lbrlvl = savrcvlvl
610aMC                   eval      lbhand = savrcvhand
610aMC                   eval      lbpseq = savrcvpseq
610aMC                   eval      lbstyp = savstyp
610aAC                   eval      lbwhd2 = savwhdp
610aAC                   eval      lbdsp2 = savdsp
610aAC                   eval      lbasl2 = savaisl
610aAC                   eval      lbloc2 = savloc
610aAC                   eval      lblvl2 = savlvl
610aAC                   eval      lbhnd2 = savhand
610aMC                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
610aDC**                 eval      lbdisp = sldisp
     C                   eval      lbitem = $pitem
218 MC                   eval      lbseq = svseq
    MC                   eval      lbpbat = $pbat
     C                   eval      lbpo = $ppo
     C                   eval      lbord = $pord
610aDC**                 eval      lbutyp = 'N'
610aDC**                 eval      lbucod = $itum1
     C                   eval      lbqalc = lblqty
416b C                   if        $ppo = '*NOSTOCK'
416b C                   eval      lbqpck = 0
416b C                   else
     C                   eval      lbqpck = lblqty
416b C                   endif
610aA
610aAC                   select
610aAC                   when      savq1 <> 0
610aAC                   eval      lbutyp = 'N'
610aAC                   when      savq2 <> 0
610aAC                   eval      lbutyp = '1'
610aAC                   when      savq3 <> 0
610aAC                   eval      lbutyp = '2'
610aAC                   endsl
610aA
610aAC                   select
610aA
610aAC                   when      lbutyp = 'N' and #otype <> 'S'
610aAC                   eval      lbucod = $itum1
610aMC                   eval      lbucub = $itcube
     C     lbucub        mult      lblqty        lbcube
610aMC                   eval      lbuwgt = $itswgt
     C     lbuwgt        mult      lblqty        lbswgt
610aA
610aAC                   when      lbutyp = 'N' and #otype = 'S'
610aAC                             or lbutyp = '1' and #otype <> 'S'
610aAC                   eval      lbucod = $itum2
610aAC                   if        $itumq2 <> 0
610aAC     $itcube       div(h)    $itumq2       lbucub
610aAC     lbucub        mult      savq2         lbcube
610aAC     $itswgt       div(h)    $itumq2       lbuwgt
610aAC     lbuwgt        mult      savq2         lbswgt
610aAC                   endif
610aA
610aAC                   when      lbutyp = '1' and #otype = 'S'
610aAC                             or lbutyp = '2' and #otype <> 'S'
610aAC                   eval      lbucod = $itum3
610aAC                   if        $itumq2 <> 0  and
610aAC                             $itumq3 <> 0
610aAC     $itcube       div(h)    $itumq2       lbucub
610aAC     lbcube        div(h)    $itumq3       lbucub
610aAC     lbucub        mult      savq3         lbcube
610aAC     $itswgt       div(h)    $itumq2       lbuwgt
610aAC     lbswgt        div(h)    $itumq3       lbuwgt
610aAC     lbuwgt        mult      savq3         lbswgt
610aAC                   endif
610aA
610aAC                   endsl
610aA
     C                   eval      lbtie = savtie
     C                   eval      lbhigh = savhgh
610aDC**                 eval      lbtrn# = pttrn#
610aMC                   eval      lbtrn# = savtr#
610aDC**                 call      'PIRLBL#'
610aDC**                 parm                    lblbl#
610aMC                   eval      lblbl# = savlb#
213 AC                   eval      lbgrp1 = @pgrp1
213 AC                   eval      lbgrp2 = @pgrp2
     C                   eval      lbtype = 'P'
     C                   eval      lbstat = 'P'
     C                   eval      lbsdte = today
     C                   time                    lbstim
213 AC                   eval      lbrdte = today
650hAc                   if        savas2 <> ' '
416fAC                   eval      lbasl2 = savas2
650hAc                   endif
     C                   write     lbrec
     *
     *         Print label.
     *
     C                   eval      $acmd = '*LABEL  '
     C                   eval      $atie = savtie
     C                   eval      $ahigh = savhgh
     C                   eval      $aqty = lblqty
610aMC                   if        $itstyp = 'P'
     C                   eval      $apslt = savdsp
     C                   else
     C                   eval      $apslt = pckdsp
     C                   endif
     C                   eval      $aum = lbucod
     C                   if        $pexpd = 0
     C                   eval      $aexpd = 0
     C                   else
     C                   eval      $cvcmd = '*CMDMDY '
     C                   move      $pexpd        $cvd8i
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      $aexpd = $cvd6o
     C                   endif
     *
700aA /free
700bA   if opplcn = 'N';
700aA     // parse out the program name and label set name
700aA     if %subst(oplpgm:1:4) = 'RFMT';
700aA       lblset = %subst(oplpgm: 5 : 6);
700aA       lblpgm = %subst(oplpgm: 1 : 4);
700aA /end-free
740aA /free
740aA   if %parms >= 32 and
740aA      $ppsr = 'Y';
740aA   else;
740aA /end-free
700aAC                   call      lblpgm
700aAC                   parm                    $acmd             8
700aAC                   parm                    lblset            6
700aAC                   parm      ' '           $plfmt            8
700aAC                   parm      savtr#        $atrn#            7 0
700aAC                   parm                    $pwhse
700aAC                   parm                    savwhdp
700aAC                   parm                    savstyp
700aAC                   parm                    savdsp
700aAC                   parm                    $apslt
700aAC                   parm                    $aqty             5 0
700aAC                   parm                    $aum              2
700aAC                   parm                    $atie             4 0
700aAC                   parm                    $ahigh            2 0
700aAC                   parm                    $pitem
700aAC                   parm                    $itdesc
700aAC                   parm                    $itpdsc
700aAC                   parm                    $itupc
700aAC                   parm                    $pven
700aAC                   parm                    $pvitm
700aAC                   parm                    $ppo
700aAC                   parm                    today6
700aAC                   parm                    $aexpd            6 0
700aAC                   parm                    $pdev
700aAC                   parm                    $pform
700gAC                   parm                    blanks15         15
700gAC                   parm                    $imbrnd
740aAc                   endif
700aA /free
700aA     else;
700aA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd             8
610aDC**                 parm                    pttrn#
610aMC                   parm      savtr#        $atrn#            7 0
     C                   parm                    $pwhse
610aDC**                 parm                    slwhdp
610aDC**                 parm                    slstyp
610aDC**                 parm                    sldisp
610aMC                   parm                    savwhdp
610aMC                   parm                    savstyp
610aMC                   parm                    savdsp
     C                   parm                    $apslt
     C                   parm                    $aqty             5 0
     C                   parm                    $aum              2
     C                   parm                    $atie             4 0
     C                   parm                    $ahigh            2 0
     C                   parm                    $pitem
610aMC                   parm                    $itdesc
610aMC                   parm                    $itpdsc
610aMC                   parm                    $itupc
     C                   parm                    $pven
     C                   parm                    $pvitm
     C                   parm                    $ppo
     C                   parm                    today6
     C                   parm                    $aexpd            6 0
     C                   parm                    $pdev
     C                   parm                    $pform
700aA /free
700aA     endif;
700bA   endif;
700aA /end-free
     *
     *        Create transaction record.
     *
210eAC                   call      @addtr
218 AC                   parm      '*CREATE '    @pcmd             8
210eAC                   parm                    #job
610aDC**                 parm      pttrn#        @ptrn#            7 0
610aMC                   parm      savtr#        @ptrn#            7 0
210eAC                   parm                    @ptask            6
210eAC                   parm      $pwhse        @pwhse            3 0
610aDC**                 parm      slwhdp        @pwhdp            5
610aDC**                 parm      slstyp        @pstyp            1
610aMC                   parm      savwhdp       @pwhdp            5
610aMC                   parm      savstyp       @pstyp            1
210eAC                   parm      lbcube        @pcube            9 3
210eAC                   parm      lbswgt        @pswgt            9 2
210eAC                   parm      lbqpck        @ppcs             5 0
210eAC                   parm      1             @paisl            5 0
210eAC                   parm      1             @pqty1            5 0
210eAC                   parm      0             @pqty2            5 0
210eAC                   parm      0             @pqty3            5 0
210eAC                   parm      ' '           @prte             5
210eAC                   parm      $ppo          @ppo              9
213 AC                   parm                    @pgrp1            1
213 AC                   parm                    @pgrp2            1
210eAC                   parm      ' '           @prtn             8
210eAC                   parm      ' '           @pmsg             4
405 A*
405 A*        Close transaction if it is a for cross dock.
405 A*
405 AC                   if        slaisl = 'XDK'  or
416fAC                             savas2 = 'XDK'
405 AC                   eval      $lcmd = '*CLOSE  '
405 AC                   eval      $ltype = '*INTER  '
405 AC                   eval      $lwhse = 0
405 AC                   eval      $lrte = *blanks
405 AC                   eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aMC                   eval      $ltrn# = savtr#
405 A*
405 AC                   call      'PT132'
405 AC                   parm                    $lparm
405 AC                   endif
416aA*
416aA*        Close transaction if *RETURN with no put away.
416aA*
416aAC                   if        $ppo = '*NOSTOCK'
416aAC                   eval      $lcmd = '*CLOSE  '
416aAC                   eval      $ltype = '*INTER  '
416aAC                   eval      $lwhse = 0
416aAC                   eval      $lrte = *blanks
416aAC                   eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aMC                   eval      $ltrn# = savtr#
416aA*
416aAC                   call      'PT132'
416aAC                   parm                    $lparm
416aAC                   endif
     *
610aDC**                 endif
610aDC**
610aDC**    Breakdown 1 quantity.
610aDC**
610aDC**                 if        savq2 > 0
610aDC**
610aDC**       Get transaction number.
610aDC**
610aDC**                 call      'PIRTRN#'
610aDC**                 parm                    pttrn#
610aDC**
610aDC**       Create label record for breakdown 1 qty.
610aDC**
610aDC**                 clear                   lbrec
610aDC**                 eval      lbwhse = $pwhse
610aDC**                 eval      lbwhdp = slwhdp
610aDC**                 eval      lbaisl = slaisl
610aDC**                 eval      lbloc = slloc
610aDC**                 eval      lbrlvl = slrlvl
610aDC**                 eval      lbhand = slhand
610aDC**                 eval      lbpseq = slpseq
610aDC**                 eval      lbstyp = slstyp
610aDC**                 if        slstyp = 'P'
610aDC**                 eval      lbqryf = 1
610aDC**                 else
610aDC**                 eval      lbqryf = 0
610aDC**                 endif
610aDC**                 eval      lbdisp = sldisp
610aDC**                 eval      lbitem = $pitem
610aDC**                 eval      lbseq = svseq
610aDC**                 eval      lbpbat = $pbat
610aDC**                 eval      lbpo = $ppo
610aDC**                 eval      lbord = $pord
610aDC**                 eval      lbutyp = *on
610aDC**                 eval      lbucod = $itum2
610aDC**                 eval      lbqalc = savq2
610aDC**                 if        $ppo = '*NOSTOCK'
610aDC**                 eval      lbqpck = 0
610aDC**                 else
610aDC**                 eval      lbqpck = savq2
610aDC**                 endif
610aDC**                 if        $itumq2 <> 0
610aDC**   $itcube       div(h)    $itumq2       lbucub
610aDC**   lbucub        mult      savq2         lbcube
610aDC**   $itswgt       div(h)    $itumq2       lbuwgt
610aDC**   lbuwgt        mult      savq2         lbswgt
610aDC**                 endif
610aDC**                 eval      lbtie = savtie
610aDC**                 eval      lbhigh = savhgh
610aDC**                 eval      lbtrn# = pttrn#
610aDC**                 call      'PIRLBL#'
610aDC**                 parm                    lblbl#
610aDC**                 eval      lbgrp1 = @pgrp1
610aDC**                 eval      lbgrp2 = @pgrp2
610aDC**                 eval      lbtype = 'P'
610aDC**                 eval      lbstat = 'P'
610aDC**                 eval      lbsdte = today
610aDC**                 time                    lbstim
610aDC**                 eval      lbrdte = today
610aDC**                 eval      lbasl2 = savas2
610aDC**                 write     lbrec
610aDC**
610aDC**        Print label.
610aDC**
610aDC**                 eval      $acmd = '*LABEL  '
610aDC**                 eval      $atie = savtie
610aDC**                 eval      $ahigh = savhgh
610aDC**                 eval      $aqty = savq2
610aDC**                 if        $itstyp = 'P'
610aDC**                 eval      $apslt = savdsp
610aDC**                 else
610aDC**                 eval      $apslt = pckdsp
610aDC**                 endif
610aDC**                 eval      $aum = lbucod
610aDC**                 if        $pexpd = 0
610aDC**                 eval      $aexpd = 0
610aDC**                 else
610aDC**                 eval      $cvcmd = '*CMDMDY '
610aDC**                 move      $pexpd        $cvd8i
610aDC**                 call      @cvtdt
610aDC**                 parm                    $cvtdt
610aDC**                 eval      $aexpd = $cvd6o
610aDC**                 endif
610aDC**
610aDC**                 call      oplpgm
610aDC**                 parm                    $acmd
610aDC**                 parm                    pttrn#
610aDC**                 parm                    $pwhse
610aDC**                 parm                    slwhdp
610aDC**                 parm                    slstyp
610aDC**                 parm                    sldisp
610aDC**                 parm                    $apslt
610aDC**                 parm                    $aqty
610aDC**                 parm                    $aum
610aDC**                 parm                    $atie
610aDC**                 parm                    $ahigh
610aDC**                 parm                    $pitem
610aDC**                 parm                    $itdesc
610aDC**                 parm                    $itpdsc
610aDC**                 parm                    $itupc
610aDC**                 parm                    $pven
610aDC**                 parm                    $pvitm
610aDC**                 parm                    $ppo
610aDC**                 parm                    today6
610aDC**                 parm                    $aexpd
610aDC**                 parm                    $pdev
610aDC**                 parm                    $pform
610aDC**
610aDC**       Create transaction record.
610aDC**
610aDC**                 call      @addtr
610aDC**                 parm      '*CREATE '    @pcmd
610aDC**                 parm                    #job
610aDC**                 parm      pttrn#        @ptrn#
610aDC**                 parm                    @ptask
610aDC**                 parm      $pwhse        @pwhse
610aDC**                 parm      slwhdp        @pwhdp
610aDC**                 parm      slstyp        @pstyp
610aDC**                 parm      lbcube        @pcube
610aDC**                 parm      lbswgt        @pswgt
610aDC**                 parm      lbqpck        @ppcs
610aDC**                 parm      1             @paisl
610aDC**                 parm      1             @pqty1
610aDC**                 parm      0             @pqty2
610aDC**                 parm      0             @pqty3
610aDC**                 parm      ' '           @prte
610aDC**                 parm      $ppo          @ppo
610aDC**                 parm                    @pgrp1
610aDC**                 parm                    @pgrp2
610aDC**                 parm      ' '           @prtn
610aDC**                 parm      ' '           @pmsg
610aDC**
610aDC**       Close transaction if it is a for cross dock.
610aDC**
610aDC**                 if        slaisl = 'XDK'  or
610aDC**                           savas2 = 'XDK'
610aDC**                 eval      $lcmd = '*CLOSE  '
610aDC**                 eval      $ltype = '*INTER  '
610aDC**                 eval      $lwhse = 0
610aDC**                 eval      $lrte = *blanks
610aDC**                 eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aDC**
610aDC**                 call      'PT132'
610aDC**                 parm                    $lparm
610aDC**                 endif
610aDC**
610aDC**       Close transaction if *RETURN with no put away.
610aDC**
610aDC**                 if        $ppo = '*NOSTOCK'
610aDC**                 eval      $lcmd = '*CLOSE  '
610aDC**                 eval      $ltype = '*INTER  '
610aDC**                 eval      $lwhse = 0
610aDC**                 eval      $lrte = *blanks
610aDC**                 eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aDC**
610aDC**                 call      'PT132'
610aDC**                 parm                    $lparm
610aDC**                 endif
610aDC**
610aDC**                 eval      savq2 = 0
610aDC**                 endif
610aDC**
610aDC**    Breakdown 2 quantity.
610aDC**
610aDC**                 if        savq3 > 0
610aDC**
610aDC**       Get transaction number.
610aDC**
610aDC**                 call      'PIRTRN#'
610aDC**                 parm                    pttrn#
610aDC**
610aDC**       Create label record for breakdown 2 qty.
610aDC**
610aDC**                 clear                   lbrec
610aDC**                 eval      lbwhse = $pwhse
610aDC**                 eval      lbwhdp = slwhdp
610aDC**                 eval      lbaisl = slaisl
610aDC**                 eval      lbloc = slloc
610aDC**                 eval      lbrlvl = slrlvl
610aDC**                 eval      lbhand = slhand
610aDC**                 eval      lbpseq = slpseq
610aDC**                 eval      lbstyp = slstyp
610aDC**                 if        slstyp = 'P'
610aDC**                 eval      lbqryf = 1
610aDC**                 else
610aDC**                 eval      lbqryf = 0
610aDC**                 endif
610aDC**                 eval      lbdisp = sldisp
610aDC**                 eval      lbitem = $pitem
610aDC**                 eval      lbseq = svseq
610aDC**                 eval      lbpbat = $pbat
610aDC**                 eval      lbpo = $ppo
610aDC**                 eval      lbord = $pord
610aDC**                 eval      lbutyp = '2'
610aDC**                 eval      lbucod = $itum3
610aDC**                 eval      lbqalc = savq3
610aDC**                 if        $ppo = '*NOSTOCK'
610aDC**                 eval      lbqpck = 0
610aDC**                 else
610aDC**                 eval      lbqpck = savq3
610aDC**                 endif
610aDC**                 if        $itumq2 <> 0  and
610aDC**                           $itumq3 <> 0
610aDC**   $itcube       div(h)    $itumq2       lbucub
610aDC**   lbcube        div(h)    $itumq3       lbucub
610aDC**   lbucub        mult      savq3         lbcube
610aDC**   $itswgt       div(h)    $itumq2       lbuwgt
610aDC**   lbswgt        div(h)    $itumq3       lbuwgt
610aDC**   lbuwgt        mult      savq3         lbswgt
610aDC**                 endif
610aDC**                 eval      lbtie = savtie
610aDC**                 eval      lbhigh = savhgh
610aDC**                 eval      lbtrn# = pttrn#
610aDC**                 call      'PIRLBL#'
610aDC**                 parm                    lblbl#
610aDC**                 eval      lbgrp1 = @pgrp1
610aDC**                 eval      lbgrp2 = @pgrp2
610aDC**                 eval      lbtype = 'P'
610aDC**                 eval      lbstat = 'P'
610aDC**                 eval      lbsdte = today
610aDC**                 time                    lbstim
610aDC**                 eval      lbrdte = today
610aDC**                 eval      lbasl2 = savas2
610aDC**                 write     lbrec
610aDC**
610aDC**        Print label.
610aDC**
610aDC**                 eval      $acmd = '*LABEL  '
610aDC**                 eval      $atie = savtie
610aDC**                 eval      $ahigh = savhgh
610aDC**                 eval      $aqty = savq3
610aDC**                 if        $itstyp = 'P'
610aDC**                 eval      $apslt = savdsp
610aDC**                 else
610aDC**                 eval      $apslt = pckdsp
610aDC**                 endif
610aDC**                 eval      $aum = lbucod
610aDC**                 if        $pexpd = 0
610aDC**                 eval      $aexpd = 0
610aDC**                 else
610aDC**                 eval      $cvcmd = '*CMDMDY '
610aDC**                 move      $pexpd        $cvd8i
610aDC**                 call      @cvtdt
610aDC**                 parm                    $cvtdt
610aDC**                 eval      $aexpd = $cvd6o
610aDC**                 endif
610aDC**
610aDC**                 call      oplpgm
610aDC**                 parm                    $acmd
610aDC**                 parm                    pttrn#
610aDC**                 parm                    $pwhse
610aDC**                 parm                    slwhdp
610aDC**                 parm                    slstyp
610aDC**                 parm                    sldisp
610aDC**                 parm                    $apslt
610aDC**                 parm                    $aqty
610aDC**                 parm                    $aum
610aDC**                 parm                    $atie
610aDC**                 parm                    $ahigh
610aDC**                 parm                    $pitem
610aDC**                 parm                    $itdesc
610aDC**                 parm                    $itpdsc
610aDC**                 parm                    $itupc
610aDC**                 parm                    $pven
610aDC**                 parm                    $pvitm
610aDC**                 parm                    $ppo
610aDC**                 parm                    today6
610aDC**                 parm                    $aexpd
610aDC**                 parm                    $pdev
610aDC**                 parm                    $pform
610aDC**
610aDC**       Create transaction record.
610aDC**
610aDC**                 call      @addtr
610aDC**                 parm      '*CREATE '    @pcmd
610aDC**                 parm                    #job
610aDC**                 parm      pttrn#        @ptrn#
610aDC**                 parm                    @ptask
610aDC**                 parm      $pwhse        @pwhse
610aDC**                 parm      slwhdp        @pwhdp
610aDC**                 parm      slstyp        @pstyp
610aDC**                 parm      lbcube        @pcube
610aDC**                 parm      lbswgt        @pswgt
610aDC**                 parm      lbqpck        @ppcs
610aDC**                 parm      1             @paisl
610aDC**                 parm      1             @pqty1
610aDC**                 parm      0             @pqty2
610aDC**                 parm      0             @pqty3
610aDC**                 parm      ' '           @prte
610aDC**                 parm      $ppo          @ppo
610aDC**                 parm                    @pgrp1
610aDC**                 parm                    @pgrp2
610aDC**                 parm      ' '           @prtn
610aDC**                 parm      ' '           @pmsg
610aDC**
610aDC**       Close transaction if it is a for cross dock.
610aDC**
610aDC**                 if        slaisl = 'XDK'  or
610aDC**                           savas2 = 'XDK'
610aDC**                 eval      $lcmd = '*CLOSE  '
610aDC**                 eval      $ltype = '*INTER  '
610aDC**                 eval      $lwhse = 0
610aDC**                 eval      $lrte = *blanks
610aDC**                 eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aDC**
610aDC**                 call      'PT132'
610aDC**                 parm                    $lparm
610aDC**                 endif
610aDC**
610aDC**       Close transaction if *RETURN with no put away.
610aDC**
610aDC**                 if        $ppo = '*NOSTOCK'
610aDC**                 eval      $lcmd = '*CLOSE  '
610aDC**                 eval      $ltype = '*INTER  '
610aDC**                 eval      $lwhse = 0
610aDC**                 eval      $lrte = *blanks
610aDC**                 eval      $lpo = *blanks
610aDC**                 eval      $ltrn# = pttrn#
610aDC**
610aDC**                 call      'PT132'
610aDC**                 parm                    $lparm
610aDC**                 endif
610aDC**
610aDC**                 eval      savq3 = 0
610aDC**                 endif
610aDC**
610aDC**                 enddo
     *
     C                   enddo
     *
     *   Flush labels out of spool file.
     *
     C                   eval      $acmd = '*FLUSH  '
700aA /free
700aA   // parse out the program name and label set name
700aA   if %subst(oplpgm:1:4) = 'RFMT';
700aA     lblset = %subst(oplpgm: 5 : 6);
700aA     lblpgm = %subst(oplpgm: 1 : 4);
700aA /end-free
740aA /free
740aA   if %parms >= 32 and
740aA      $ppsr = 'Y';
740aA   else;
740aA /end-free
700aAC                   call      lblpgm
700aAC                   parm                    $acmd
700aAC                   parm      ' '           lblset            6
700aAC                   parm      ' '           $plfmt            8
700aAC                   parm                    pttrn#
700aAC                   parm                    $pwhse
700aAC                   parm                    slwhdp
700aAC                   parm                    slstyp
700aAC                   parm                    sldisp
700aAC                   parm                    $apslt
700aAC                   parm                    $aqty
700aAC                   parm                    $aum
700aAC                   parm                    $atie
700aAC                   parm                    $ahigh
700aAC                   parm                    $pitem
700aAC                   parm                    $itdesc
700aAC                   parm                    $itpdsc
700aAC                   parm                    $itupc
700aAC                   parm                    $pven
700aAC                   parm                    $pvitm
700aAC                   parm                    $ppo
700aAC                   parm                    today6
700aAC                   parm                    $aexpd
700aAC                   parm                    $pdev
700aAC                   parm                    $pform
700gAC                   parm                    blanks15         15
700gAC                   parm                    $imbrnd
740aAc                   endif
700aA /free
700aA   else;
700aA /end-free
     C                   call      oplpgm
     C                   parm                    $acmd
     C                   parm                    pttrn#
     C                   parm                    $pwhse
     C                   parm                    slwhdp
212 AC                   parm                    slstyp
     C                   parm                    sldisp
     C                   parm                    $apslt
     C                   parm                    $aqty
     C                   parm                    $aum
     C                   parm                    $atie
     C                   parm                    $ahigh
     C                   parm                    $pitem
610aMC                   parm                    $itdesc
610aMC                   parm                    $itpdsc
610aMC                   parm                    $itupc
     C                   parm                    $pven
     C                   parm                    $pvitm
     C                   parm                    $ppo
     C                   parm                    today6
     C                   parm                    $aexpd
     C                   parm                    $pdev
     C                   parm                    $pform
700aA /free
700aA   endif;
700aA /end-free
     *
     *  Create P.O. or return record.
     *
     C                   select
     *
     *     P.O. record for receiving.
     *
     C                   when      $pcmd = '*RECEIVE'  or
500aAC                             $pcmd = '*SPRECV '
650bAc                             or $pcmd = '*RECEIV1'
     *
     *        Create P.O. header record.
     *
218 MC     keyph         chain(n)  pohdr                              79
     C                   if        *in79
     C                   clear                   phrec
     C                   eval      phwhse = $pwhse
     C                   eval      phpo = $ppo
     C                   eval      phven = $pven
     C                   eval      phvnam = $pvnam
     C                   write     phrec
     C                   endif
     *
218 M*        Create or update PO detail record.
218 M*         Seq # is retreived at the beginning of this routine -
218 M*         or was passed in parm $PSEQ.
218 D*        Create P.O. detail record. Seq# is retreived at the
218 D*         beginning of this routine.
     *
700eA * Detemine if item sent in is a branded Item
700eA * if so we will need to deal with podtl records
700eA * for Parent and Branded Item.
700eA /free
700eA   bCmd = '*GET4BITM';
700eA   bBrand = ' ';
700eA   bParentItm = ' ';
700eA   bBrandItm = $pitem;
700eA   bBrandFlg = ' ';
700eA   GetBranded(bCmd: lbwhse: bParentItm: bBrand:
700eA              bBrandItm: bBrandFlg);
700eA
700eA   if bParentItm <> ' ';
700eA     chain ($pwhse: $ppo: svseq: bParentItm) podtl;
700eA   else;
700eA     chain ($pwhse: $ppo: svseq: $pitem) podtl;
700eA   endif;
700eA /end-free
700eDC*    keypd         chain     podtl                              79
700eDC*                  if        *in79
700eMC                   if        not %found(podtl)
409 MC                   clear                   pdrec
     C                   eval      pdwhse = $pwhse
     C                   eval      pdpo = $ppo
218 AC                   eval      pdseq = svseq
700eAc                   if        bParentItm <> ' '
700eAC                   eval      pditem = bParentItm
700eAc                   else
     C                   eval      pditem = $pitem
700eAc                   endif
     C                   eval      pdvitm = $pvitm
     C                   eval      pdspcl = *blanks
     C                   eval      pdqor1 = $prq1
     C                   eval      pdqor2 = $prq2
     C                   eval      pdqor3 = $prq3
218 MC                   eval      pdqrc1 = $prq1
218 MC                   eval      pdqrc2 = $prq2
218 MC                   eval      pdqrc3 = $prq3
219 AC                   eval      pddwgt = $pdwgt
     C                   write     pdrec
218 AC                   else
650cDC*                  add       $prq1         pdqrc1
650cDC*                  add       $prq2         pdqrc2
650cDC*                  add       $prq3         pdqrc3
650cMC                   add       $pqty1        pdqrc1
650cMC                   add       $pqty2        pdqrc2
650cMC                   add       $pqty3        pdqrc3
406 MC                   add       $pdwgt        pddwgt
218 AC                   update    pdrec
218 AC                   endif
     *
700eA* Now deal with the branded item PODTL record
700eA /free
700eA   if bParentItm <> ' ';
700eA     chain ($pwhse: $ppo: $pitem) podtl1;
700eA     if %found(podtl1);
700eA /end-free
700eAC                   add       $pqty1        br_pdqrc1
700eAC                   add       $pqty2        br_pdqrc2
700eAC                   add       $pqty3        br_pdqrc3
700eAC                   add       $pdwgt        br_pddwgt
700eAC                   add       $pqty1        br_pdqor1
700eAC                   add       $pqty2        br_pdqor2
700eAC                   add       $pqty3        br_pdqor3
700eAC                   update    pdrec1
700eA /free
700eA     else;
700eA       // need to get seq# and add a record
700eA       NewSeq# = 99999;
700eA       dow forever = forever;
700eA         chain(n) ($pwhse: $ppo: NewSeq#) podtl;
700eA         if %found(podtl);
700eA           NewSeq# = NewSeq# - 1;
700eA         else;
700eA           // load fields and write podtl
700eA           pdwhse = $pwhse;
700eA           pdpo   = $ppo;
700eA           pdseq  = NewSeq#;
700eA           pditem = $pitem;
700eA           pdspcl = 'BR';
700eA           pdqrc1 = $prq1;
700eA           pdqrc2 = $prq2;
700eA           pdqrc3 = $prq3;
700eA           pddwgt = $pdwgt;
700eA           pdqor1 = $prq1;
700eA           pdqor2 = $prq2;
700eA           pdqor3 = $prq3;
700eA           write  pdrec;
700eA           leave;
700eA         endif;
700eA       enddo;
700eA     endif;
700eA   endif;
700eA /end-free
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  PUTABV  Try to put item above picking slot.
     *
     C     putabv        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTABV  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR49'
413aAC                   eval      trsr50 = 'PUTABV'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
     *  Look for slots directly above picking slot.
     *
     C                   eval      k1aisl = pckasl
     C                   eval      k1loc = pckloc
     C     pcklvl        add       1             k1rlvl
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS1D'
413aAC                   eval      trsr50 = 'PUTABV'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C     keys1d        setll     slot1
     *
     C                   dou       forevr <> forevr
610aDC**   keys1c        reade     slot1                                7879
610aMC     keys1c        reade(n)  slot1                                7879
     C                   if        *in79
     C                   leave
     C                   endif
610bA
610bA*   Skip Virtual slots
610bA
610bAC                   if        slrsrv = 'V'
610bAC                   iter
610bAC                   endif
413bA*
413bA*   For first pass for both hard/soft designations,switch
413bA*   WODESG will be off.
413bA*
     C                   if        *in78  or
     C                             slstat <> 'V '  or
     C                             slpick = 'Y'  or
610aMC                             sldesg <> $itdesg  and
413bAC                             wodesg = *off  or
413bA*
413bA*   For second pass, for soft designations, we are looking
413bA*   only for slots with no desigination so we will bypass
413bA*   any slot with a desigination.
413bA*
610aMC                             sldesg <> $itdesg  and
413bAC                             dstype = 'S'  and
413bAC                             wodesg = *on  and
413bAC                             sldesg > *blanks
413aAC                   eval      trnbr = 'TR17'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'PUTABV'
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
     *
     *     Get matching slot tie/high definition.
     *
     C                   eval      tmpflg = *off
     C     1             do        lstdef        curdef
     C     curdef        occur     defs
     C                   if        slsdef = dssdef
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     *     Ignore slot if no matching definition.
     *
     C                   if        tmpflg = *off
413aAC                   eval      trnbr = 'TR18'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'PUTABV'
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
610bA
610bA*     Ignore slot if no slot positions left
610bA
640cAC                   if        $pfifo = 0
640cAC                   eval      $uEntDte = today
640cAC                   else
640cAC                   eval      $uEntDte = $pfifo
640cAC                   endif
640cAC                   if        $itflgd = 'Y'
640cAC                   eval      $uExpDte = $pexpd
640cAC                   else
640cAC                   eval      $uExpDte = 0
640cAC                   endif
640cA
610bAC                   exsr      chkUsage
610bAC                   if        $uRecs >= dsposf
640cMC                   eval      trnbr = 'TR26'
640cMC                   eval      trsr50 = 'PUTABV'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   iter
610bAC                   endif
640cA
640cA*     Ignore slot it contains different item
640cA
640bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTABV'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
640bAC                   iter
640bAC                   endif
640cA
640cA*     Ignore slot it contains same item with differnt dates
640cA
610cAC                   if        $uRecs > 0
640cMC                   if        $uDiffEntd = 'Y' or $uDiffExpd = 'Y'
640cMC                   eval      trnbr = 'TR30'
640cMC                   eval      trsr50 = 'PUTABV'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
640cMC                   iter
640cMC                   endif
640cMC                   endif
610aDC**
610aDC**     Fill up slot.
610aDC**
610aDC**        If breakdown quantity exists then just throw it on the
610aDC**        pallet.
610aDC**
610aDC**                 eval      slrcv1 = dssqty
610aDC**                 eval      q1lft = q1lft - dssqty
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 eval      q2lft = 0
610aDC**                 z-add     q3lft         slrcv3
610aDC**                 eval      q3lft = 0
610aDC**                 eval      dsslts = dsslts - 1
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 if        dsslts > 0
610aDC**                 eval      savlbl = dsposf
610aDC**                 else
610aDC**                 eval      savlbl = dsplts
610aDC**                 endif
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 eval      slstat = '@R'
610aDC**                 eval      slitem = #sitem
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = prirty
610aDC**                 update    s1rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = dssqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= dssqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
416bA*
413aAC                   eval      trnbr = 'TR19'
413aAC                   movel     '*RCV050'     trcode
413aAC                   eval      trsr50 = 'PUTABV'
413aAC                   exsr      zztrck
     *
     *      If there is no more quantity to put away then leave.
     *      otherwise, recalculate tie/highs and look for another
     *      slot.
     *
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
     C                   leave
     C                   else
     C                   exsr      recalc
640dA*        Now we leave after 1 pallet.
640dAC                   leave
     C                   endif
     *
     C                   enddo
     *
     C     endabv        endsr
     *----------------------------------------------------------------
     *
     *  PUTACT  Try to put fixed item in an existing active slot.
     *
     C     putact        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTACT  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR24'
413aAC                   eval      trsr50 = 'PUTACT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   eval      sldisp = *blanks
413aAC                   exsr      zztrck
     *
     *  Loop through active, non-picking slots for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'N'
650gDC***  keys3         setll     slot3
650gMC     keys3         setll     slot13
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTACT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   dou       forevr <> forevr
650gDC***  keys3         reade     slot3                                7879
650gMC     keys3         reade     slot13                               7879
     C                   if        *in79
     C                   leave
     C                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTACT'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   iter
610bAC                   endif
     *
     *     Ignore slot if it is already occupied.
     *
610bDC**                 if        slstk1 > 0  or
610bDC**                           slstk2 > 0  or
610bDC**                           slstk3 > 0  or
610bDC**                           slalc1 > 0  or
610bDC**                           slalc2 > 0  or
610bDC**                           slalc3 > 0  or
610bDC**                           sltfr1 > 0  or
610bDC**                           sltfr2 > 0  or
610bDC**                           sltfr3 > 0  or
610bDC**                           slpck1 > 0  or
610bDC**                           slpck2 > 0  or
610bDC**                           slpck3 > 0  or
610bDC**                           slrcv1 > 0  or
610bDC**                           slrcv2 > 0  or
610bDC**                           slrcv3 > 0
610bAC                   if        $uPieces > 0
413aAC                   eval      trnbr = 'TR60'
413aAC                   eval      trsr50 = 'PUTACT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Get matching slot tie/high definition.
     *
     C                   eval      tmpflg = *off
     C     1             do        lstdef        curdef
     C     curdef        occur     defs
     C                   if        slsdef = dssdef
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     *     Ignore slot if no matching definition.
     *
     C                   if        tmpflg = *off
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTACT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
610aDC**
610aDC**     Fill up slot.
610aDC**
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 eval      slrcv1 = dssqty
610aDC**                 eval      q1lft = q1lft - dssqty
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 eval      q2lft = 0
610aDC**                 z-add     q3lft         slrcv3
610aDC**                 eval      q3lft = 0
610aDC**                 eval      dsslts = dsslts - 1
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 if        dsslts > 0
610aDC**                 eval      savlbl = dsposf
610aDC**                 else
610aDC**                 eval      savlbl = dsplts
610aDC**                 endif
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = prirty
610aDC**                 update    s3rec
416bA*
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTACT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = dssqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= dssqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
     *
     *      If there is no more quantity to put away -or-
     *      we only need one more slot of this type but it doesn't
     *      meet the slot usage percentage requirements, then leave.
     *
     *
     C                   if        q1lft = 0  and
     C                             q2lft = 0  and
     C                             q3lft = 0
     C                   leave
408 AC                   else
408 AC                   exsr      recalc
640dA*        Now we leave after 1 pallet.
640dAC                   leave
     C                   endif
     *
     C                   enddo
     *
     C                   endsr
412dA*----------------------------------------------------------------
412dA*
412dA*  PUTAOF  Try to put fixed item in an active overflow slot.
610aA*          Try to put entire qty or full pallet into slot with
610aA*          matching ent/exp date.
412dA*
610cA*          With license tracking we no longer need to match
610cA*          ent/exp date.
412dA*
412dAC     putaof        begsr
610aA
610aA*  This routine is not used in licenae tracking
610aA
610aAC*********          leavesr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTAOF  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR57'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dA*
412dA*  Get first active overflow slot for item.
412dA*
412dAC                   eval      k3stat = 'A '
412dAC                   eval      k3pick = 'N'
650gDC***  keys3         setll     slot3
650gMC     keys3         setll     slot13
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dAC                   dou       forevr <> forevr
650gDC***  keys3         reade     slot3                                7879
650gMC     keys3         reade     slot13                               7879
412dAC                   if        *in79
412dAC                   goto      endaof
412dAC                   endif
412dA*
412dAC                   if        *in78
412dAC                   iter
412dAC                   endif
650iA /free
650iA    // if high tracking item, and slot is a virtual
650iA    // need to use base slot in place of virtual
720aD    //if $imltrk = 'H' or $imltrk = 'M';
720aM    if $imltrk = 'H' or $imltrk = 'M' or $imltrk = 'U';
650iA      chain ($pwhse: $itwhdp: sldisp) vslot1;
650i       if %found(vslot1);
650i         sldisp = v_vspdis;
650i       endif;
650i     endif;
650i  /end-free
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
640bAC                   if        $pfifo = 0
640bAC                   eval      $uEntDte = today
640bAC                   else
640bAC                   eval      $uEntDte = $pfifo
640bAC                   endif
640bAC                   if        $itflgd = 'Y'
640bAC                   eval      $uExpDte = $pexpd
640bAC                   else
640bAC                   eval      $uExpDte = 0
640bAC                   endif
640bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTAOF'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   iter
610bAC                   endif
412dA*
412dA*     Ignore slot if it is empty.
412dA*
610bDC**                 if        slstk1 = 0  and
610bDC**                           slstk2 = 0  and
610bDC**                           slstk3 = 0  and
610bDC**                           slalc1 = 0  and
610bDC**                           slalc2 = 0  and
610bDC**                           slalc3 = 0  and
610bDC**                           sltfr1 = 0  and
610bDC**                           sltfr2 = 0  and
610bDC**                           sltfr3 = 0  and
610bDC**                           slpck1 = 0  and
610bDC**                           slpck2 = 0  and
610bDC**                           slpck3 = 0  and
610bDC**                           slrcv1 = 0  and
610bDC**                           slrcv2 = 0  and
610bDC**                           slrcv3 = 0
610bAC                   if        $uPieces = 0
413aAC                   eval      trnbr = 'TR58'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dAC                   iter
412dAC                   endif
610cDC**
610cDC**    Bypass slot if entered date/exp date don't match.
610cDC**
610cDC**                 if        $pfifo = 0
610cDC**                 if        slentd <> today  or
610cDC**                           slexpd <> $pexpd  and
610cDC**                           $itflgd = 'Y'
640bMC                   if        $uDiffEntd = 'Y'
640bMC                             or $uDiffExpd = 'Y'
640bMC                   eval      trnbr = 'TR30'
640bMC                   eval      trsr50 = 'PUTAOF'
640bMC                   eval      trcode = '*RCV050 '
640bMC                   exsr      zztrck
640bMC                   iter
640bMC                   endif
610cDC**                 else
610cDC**                 if        slentd <> $pfifo  or
610cDC**                           slexpd <> $pexpd  and
610cDC**                           $itflgd = 'Y'
610cDC**                 eval      trnbr = 'TR30'
610cDC**                 eval      trsr50 = 'PUTAOF'
610cDC**                 eval      trcode = '*RCV050 '
610cDC**                 exsr      zztrck
610cDC**                 iter
610cDC**                 endif
610cDC**                 endif
412dA*
412dA*     Get matching slot tie/high definition.
412dA*
412dAC                   eval      tmpflg = *off
412dAC     1             do        lstdef        curdef
412dAC     curdef        occur     defs
412dAC                   if        slsdef = dssdef
412dAC                   eval      tmpflg = *on
412dAC                   leave
412dAC                   endif
412dAC                   enddo
412dA*
412dA*     Ignore slot if no matching definition.
412dA*
412dAC                   if        tmpflg = *off
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dAC                   iter
412dAC                   endif
412dA*
412dA*   Calculate empty space in slot.
412dA*
610cDC**    Call program to calculate availabe slot quantities.
610cDC**
610cDC**                 call      'SLOTQTY'
610cDC**                 parm                    slstk1
610cDC**                 parm                    slstk2
610cDC**                 parm                    slstk3
610cDC**
610cDC**                 parm                    slalc1
610cDC**                 parm                    slalc2
610cDC**                 parm                    slalc3
610cDC**
610cDC**                 parm                    sltfr1
610cDC**                 parm                    sltfr2
610cDC**                 parm                    sltfr3
610cDC**
610cDC**                 parm                    slpck1
610cDC**                 parm                    slpck2
610cDC**                 parm                    slpck3
610cDC**
610cDC**                 parm                    slrcv1
610cDC**                 parm                    slrcv2
610cDC**                 parm                    slrcv3
610cDC**
610cDC**                 parm                    stock1            5 0
610cDC**                 parm                    stock2            3 0
610cDC**                 parm                    stock3            3 0
610cDC**
610cDC**                 parm                    avail1            5 0
610cDC**                 parm                    avail2            3 0
610cDC**                 parm                    avail3            3 0
412dA*
412dA*     Calculate free space for slot.
412dA*
412dA*
610cAC                   eval      avail1 = $uPieces
412dAC                   if        avail1 >= 0
412dAC                   eval      emptyq = dstqty - avail1
412dAC                   else
412dAC                   eval      emptyq = dstqty
412dAC                   endif
412dA*
412dA*   Bypass if no free space.
412dA*
412dAC                   if        emptyq <= 0
413aAC                   eval      trnbr = 'TR26'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dAC                   iter
412dAC                   endif
412dA*
412dA*   Calculate how much (if any) we can put in the slot.
412dA*
412dAC                   eval      putqty = 0
412dAC                   eval      putpal = 0
412dA*
412dAC                   select
412dA*
412dA*      Try to put entire quantity in slot.
412dA*
412dAC                   when      q1lft <= emptyq
412dAC                   eval      putqty = q1lft
412dAC     putqty        div       dspqty        putpal
412dAC                   mvr                     extra
412dAC                   if        extra > 0  or
412dAC                             putpal = 0
412dAC                   add       1             putpal
412dAC                   endif
412dA*
412dA*      Try to put in as many full pallets as we can.
412dA*
412dAC                   other
412dAC                   eval      tmplft = q1lft
412dAC                   z-add     emptyq        tmpemp
412dAC                   dow       dspqty <= tmpemp  and
412dAC                             tmplft >= dspqty
412dAC                   add       dspqty        putqty
412dAC                   add       1             putpal
412dAC                   eval      tmplft = tmplft - dspqty
412dAC                   eval      tmpemp = tmpemp - dspqty
412dAC                   enddo
412dAC                   endsl
412dA*
412dA*     If we can't put anything into this slot then try next slot.
412dA*
412dAC                   if        putqty = 0  and
412dAC                             q2lft = 0  and
412dAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR28'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dAC                   iter
412dAC                   endif
412dA*
412dA*      Otherwise, put the quantity in the slot.
412dA*
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 add       putqty        slrcv1
610aDC**                 add       q2lft         slrcv2
610aDC**                 add       q3lft         slrcv3
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = putqty
610aDC**                 eval      savq2 = q2lft
610aDC**                 eval      savq3 = q3lft
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = putpal
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = putqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= putqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
416bA*
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTAOF'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412dA*
412dA*      Recalculate tie/high definitions.
412dA*
610aDC**                 eval      q1lft = q1lft - putqty
610aDC**                 eval      q2lft = 0
610aDC**                 eval      q3lft = 0
412dAC                   if        q1lft = 0  and
412dAC                             q2lft = 0  and
412dAC                             q3lft = 0
412dAC                   leave
412dAC                   else
412dAC                   exsr      recalc
640dA*        Now we leave after 1 pallet.
640dAC                   leave
412dAC                   endif
412dAC                   enddo
412dA*
412dAC     endaof        endsr
412AA*----------------------------------------------------------------
412AA*
412AA*  PUTAPK  Try to put fixed item in an existing active pick slot.
412AA*
412AAC     putapk        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTAPK  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR25'
413aAC                   eval      trsr50 = 'PUTAPK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AA*
412AA*  Loop through active, picking slots for item.
412AA*
412AAC                   eval      k3stat = 'A '
412AAC                   eval      k3pick = 'Y'
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTAPK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
650gDC***  keys3         setll     slot3
650gMC     keys3         setll     slot13
412AAC                   dou       forevr <> forevr
650gDC***  keys3         reade     slot3                                7879
650gMC     keys3         reade     slot13                               7879
412AAC                   if        *in79
412AAC                   leave
412AAC                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTAPK'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   iter
610bAC                   endif
412AA*
412AA*     Ignore slot if it is already occupied.
412AA*
610bDC**                 if        slstk1 > 0  or
610bDC**                           slstk2 > 0  or
610bDC**                           slstk3 > 0  or
610bDC**                           slalc1 > 0  or
610bDC**                           slalc2 > 0  or
610bDC**                           slalc3 > 0  or
610bDC**                           sltfr1 > 0  or
610bDC**                           sltfr2 > 0  or
610bDC**                           sltfr3 > 0  or
610bDC**                           slpck1 > 0  or
610bDC**                           slpck2 > 0  or
610bDC**                           slpck3 > 0  or
610bDC**                           slrcv1 > 0  or
610bDC**                           slrcv2 > 0  or
610bDC**                           slrcv3 > 0
610bAC                   if        $uPieces > 0
413aAC                   eval      trnbr = 'TR23'
413aAC                   eval      trsr50 = 'PUTAPK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AAC                   iter
412AAC                   endif
412AA*
412AA*     Get matching slot tie/high definition.
412AA*
412AAC                   eval      tmpflg = *off
412AAC     1             do        lstdef        curdef
412AAC     curdef        occur     defs
412AAC                   if        slsdef = dssdef
412AAC                   eval      tmpflg = *on
412AAC                   leave
412AAC                   endif
412AAC                   enddo
412AA*
412AA*     Ignore slot if no matching definition.
412AA*
412AAC                   if        tmpflg = *off
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTAPK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AAC                   iter
412AAC                   endif
610aDC**
610aDC**     Fill up slot.
610aDC**
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 eval      slrcv1 = dssqty
610aDC**                 eval      q1lft = q1lft - dssqty
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 eval      q2lft = 0
610aDC**                 z-add     q3lft         slrcv3
610aDC**                 eval      q3lft = 0
610aDC**                 eval      dsslts = dsslts - 1
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 if        dsslts > 0
610aDC**                 eval      savlbl = dsposf
610aDC**                 else
610aDC**                 eval      savlbl = dsplts
610aDC**                 endif
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = prirty
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = dssqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= dssqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
416bA*
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTAPK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AA*
412AA*      If there is no more quantity to put away -or-
412AA*      we only need one more slot of this type but it doesn't
412AA*      meet the slot usage percentage requirements, then leave.
412AA*
412AA*
412AAC                   if        q1lft = 0  and
412AAC                             q2lft = 0  and
412AAC                             q3lft = 0
412AAC                   leave
412AAC                   else
412AAC                   exsr      recalc
640dA*        Now we leave after 1 pallet.
640dAC                   leave
412AAC                   endif
412AA*
412AAC                   enddo
412AA*
412AAC                   endsr
412AA*----------------------------------------------------------------
412AA*
412AA*  PUTLST  Try to put item in last picking slot.
412AA*
412AAC     putlst        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTLST  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR50'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412bAC                   eval      sventd = -(1)
412AA*
412AA*  Get last picking slot for item.
412AA*
412AAC                   eval      k3stat = 'A '
412AAC                   eval      k3pick = 'Y'
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
650gDC***  keys3         setgt     slot3
650gMC     keys3         setgt     slot13
412bAC                   dou       forevr <> forevr
412AAC     #lst01        tag
650gDC***  keys3         readpe    slot3                                7879
650gMC     keys3         readpe    slot13                               7879
412AAC                   if        *in79
412AAC                   goto      endlst
412AAC                   endif
412bAC                   if        *in78
413aAC                   eval      trnbr = 'TR17'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412bAC                   iter
412bAC                   endif
610AD **
610AD **    Ignore slot if Virtual slots exist for it.
610AD **
610ADC**                 exsr      chkvsl
610ADC**                 if        vsfind = *on
610aDC**                 unlock    slot3
610ADC**                 goto      endlst
610ADC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
640bAC                   if        sventd < 0
640bAC                   eval      $uEntDte = slentd
640bAC                   else
640bAC                   eval      $uEntDte = sventd
640bAC                   endif
640bAC                   if        $itflgd = 'Y'
640bAC                   eval      $uExpDte = $pexpd
640bAC                   else
640bAC                   eval      $uExpDte = 0
640bAC                   endif
640bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTLST'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   goto      endlst
610bAC                   endif
412AA*
412AA*     Ignore slot if it is completely empty.
412AA*
610bDC**                 if        slstk1 = 0  and
610bDC**                           slstk2 = 0  and
610bDC**                           slstk3 = 0  and
610bDC**                           slalc1 = 0  and
610bDC**                           slalc2 = 0  and
610bDC**                           slalc3 = 0  and
610bDC**                           sltfr1 = 0  and
610bDC**                           sltfr2 = 0  and
610bDC**                           sltfr3 = 0  and
610bDC**                           slpck1 = 0  and
610bDC**                           slpck2 = 0  and
610bDC**                           slpck3 = 0  and
610bDC**                           slrcv1 = 0  and
610bDC**                           slrcv2 = 0  and
610bDC**                           slrcv3 = 0
610bAC                   if        $uPieces = 0
413aAC                   eval      trnbr = 'TR29'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AAC                   goto      #lst01
412AAC                   endif
610cDC**
610cDC**    Check expiration date, if not the same then exit.
610cDC**        As of 4.12b it is 'iterate', not 'exit'.
610cDC**
610cDC**                 if        $pexpd <> slexpd  and
610cDC**                           $itflgd = 'Y'
640bMC                   if        $uDiffExpd = 'Y'
640bMC                   eval      trnbr = 'TR30'
640bMC                   eval      trsr50 = 'PUTLST'
640bMC                   eval      trcode = '*RCV050 '
640bMC                   exsr      zztrck
640bMC                   iter
640bMC                   endif
610cDC**
610cDC**    Only allowed to put product into slot with same
610cDC**      entered date of first slot used to keep FIFO order.
610cDC**
610cDC**                 if        sventd < 0
610cDC**                 eval      sventd = slentd
610cDC**                 endif
610cDC**                 if        slentd <> sventd
640bMC                   if        $uDiffEntd = 'Y'
640bMC                   eval      trnbr = 'TR30'
640bMC                   eval      trsr50 = 'PUTLST'
640bMC                   eval      trcode = '*RCV050 '
640bMC                   exsr      zztrck
640bMC                   iter
640bMC                   endif
412AA*
412AA*     Get matching slot tie/high definition.
412AA*
412AAC                   eval      tmpflg = *off
412AAC     1             do        lstdef        curdef
412AAC     curdef        occur     defs
412AAC                   if        slsdef = dssdef
412AAC                   eval      tmpflg = *on
412AAC                   leave
412AAC                   endif
412AAC                   enddo
412AA*
412AA*     Ignore slot if no matching definition.
412AA*
412AAC                   if        tmpflg = *off
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412bMC                   iter
412AAC                   endif
412AA*
412AA*   Calculate empty space in slot.
412AA*
610cDC**    Call program to calculate availabe slot quantities.
610cDC**
610cDC**                 call      'SLOTQTY'
610cDC**                 parm                    slstk1
610cDC**                 parm                    slstk2
610cDC**                 parm                    slstk3
610cDC**
610cDC**                 parm                    slalc1
610cDC**                 parm                    slalc2
610cDC**                 parm                    slalc3
610cDC**
610cDC**                 parm                    sltfr1
610cDC**                 parm                    sltfr2
610cDC**                 parm                    sltfr3
610cDC**
610cDC**                 parm                    slpck1
610cDC**                 parm                    slpck2
610cDC**                 parm                    slpck3
610cDC**
610cDC**                 parm                    slrcv1
610cDC**                 parm                    slrcv2
610cDC**                 parm                    slrcv3
610cDC**
610cDC**                 parm                    stock1
610cDC**                 parm                    stock2
610cDC**                 parm                    stock3
610cDC**
610cDC**                 parm                    avail1
610cDC**                 parm                    avail2
610cDC**                 parm                    avail3
412AA*
412AA*     Calculate free space for slot.
412AA*
610cAC                   eval      avail1 = $uPieces
412AAC                   if        avail1 >= 0
412AAC                   eval      emptyq = dstqty - avail1
412AAC                   else
412AAC                   eval      emptyq = dstqty
412AAC                   endif
412AA*
412AA*   Get out if no free space.
412bA*     As of 4.12b we loop instead of getting out.
412AA*
412AAC                   if        emptyq <= 0
413aAC                   eval      trnbr = 'TR26'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412bAC                   iter
412AAC                   endif
412AA*
412AA*   If this is not a return we are only allowed to use the
412AA*   pick slot if it is the only slot containing this item.
412AA*
412AAC                   if        $pcmd <> '*RETURN '
412AA*
412AA*
412AA*   Note: Actual check is done in routine CHKMLT which is
412AA*         called from routines AWYFIX and AWYPIR.
412AA*
412AAC                   if        mltflg = *on
650eAC                             and $itstyp <> 'P'
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR27'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AAC                   goto      endlst
412AAC                   endif
412AA*
412AAC                   endif
412AA*
412AA*   Calculate how much (if any) we can put in the slot.
412AA*
412AAC                   eval      putqty = 0
412AAC                   eval      putpal = 0
412AA*
412AAC                   select
412AA*
412AA*      Try to put entire quantity in slot.
412AA*
412AAC                   when      q1lft <= emptyq
412AAC                   eval      putqty = q1lft
412AAC     putqty        div       dspqty        putpal
412AAC                   mvr                     extra
412AAC                   if        extra > 0  or
412AAC                             putpal = 0
412AAC                   add       1             putpal
412AAC                   endif
412AA*
412AA*      Try to put in as many full pallets as we can.
412AA*
412AAC                   other
412AAC                   eval      tmplft = q1lft
412AAC                   z-add     emptyq        tmpemp
412AAC                   dow       dspqty <= tmpemp  and
412AAC                             tmplft >= dspqty
412AAC                   add       dspqty        putqty
412AAC                   add       1             putpal
412AAC                   eval      tmplft = tmplft - dspqty
412AAC                   eval      tmpemp = tmpemp - dspqty
412AAC                   enddo
412AAC                   endsl
412AA*
412AA*     If we can't put anything into this slot then leave because
412AA*     we only wanted to use the first picking slot we came to.
412bA*       As of 4.12b we look for other slots with same entered
412bA*       and expire dates.
412AA*
412AAC                   if        putqty = 0  and
412AAC                             q2lft = 0  and
412AAC                             q3lft = 0
413aAC                   eval      trnbr = 'TR28'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412bAC                   iter
412AAC                   endif
412AA*
412AA*      Otherwise, put the quantity in the slot.
610aDC**
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 add       putqty        slrcv1
610aDC**                 add       q2lft         slrcv2
610aDC**                 add       q3lft         slrcv3
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = putqty
610aDC**                 eval      savq2 = q2lft
610aDC**                 eval      savq3 = q3lft
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = putpal
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 if        slentd = 0  or
610aDC**                           avail1 = 0  and
610aDC**                           avail2 = 0  and
610aDC**                           avail3 = 0
610aDC**                 if        $pfifo = 0
610aDC**                 eval      slentd = today
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 endif
610aDC**
610aDC**                 if        slexpd = 0  or
610aDC**                           $pexpd < slexpd
610aDC**                 eval      slexpd = $pexpd
610aDC**                 endif
610aDC**
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = putqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
416bA*
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTLST'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
412AA*
412AA*      Recalculate tie/high definitions.
412bA*        and loop around to look for more slots
412bA*        Otherwise, getout.
412AA*
412AAC                   eval      q1lft = q1lft - putqty
412AAC                   eval      q2lft = 0
412AAC                   eval      q3lft = 0
412AAC                   if        q1lft <> 0  or
412AAC                             q2lft <> 0  or
412AAC                             q3lft <> 0
412AAC                   exsr      recalc
640dA*        Now we leave after 1 pallet.
640dAC                   leave
412bAC                   else
412bAC                   leave
412AAC                   endif
412AA*
412bAC                   enddo
412bA*
412AAC     endlst        endsr
     *----------------------------------------------------------------
     *
     *  PUTPCK  Try to put item in first picking slot.
     *
     *    12/21/94 DAS
     *      - This routine is now always called. Previously, it was
     *        only called for returns. Now a product can be put into
     *        the pick slot when it is the only slot that contains
     *        the item or no slots contain the item.
     *
     C     putpck        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTPCK  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR51'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
     *  Get first picking slot for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
650gDC***  keys3         setll     slot3
650gDC***  keys3         reade     slot3                                7879
650gMC     keys3         setll     slot13
650gMC     keys3         reade     slot13                               7879
     C                   if        *in79  or
     C                             *in78
500bAC                   if        $pcmd = '*SPRECV '
500bAC                   eval      error = *on
500bAC                   eval      $prtn = '*NOPICKS'
500bAC                   endif
     C                   goto      endpck
     C                   endif
     *
412cAC                   if        $pcmd = '*RETURN '  or
500aAC                             $pcmd = '*SPRECV '
412cAC                   eval      putqty = q1lft
412cAC                   eval      putpal = 1
412cAC                   goto      slamit
412cAC                   endif
     *
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610aDC**                 unlock    slot3
610bDC**                 goto      endpck
610bDC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTPCK'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   goto      endpck
610bAC                   endif
     *
     *     Get matching slot tie/high definition.
     *
     C                   eval      tmpflg = *off
     C     1             do        lstdef        curdef
     C     curdef        occur     defs
     C                   if        slsdef = dssdef
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     *     Ignore slot if no matching definition.
     *
     C                   if        tmpflg = *off
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   goto      endpck
     C                   endif
     *
     *   Calculate empty space in slot.
     *
     *     Call program to calculate availabe slot quantities.
     *
     C                   call      'SLOTQTY'
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     *
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     *
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     *
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     *
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     *
     C                   parm                    stock1            5 0
     C                   parm                    stock2            3 0
     C                   parm                    stock3            3 0
     *
     C                   parm                    avail1            5 0
     C                   parm                    avail2            3 0
     C                   parm                    avail3            3 0
     *
     *     Calculate free space for slot.
     *
    AC                   if        avail1 >= 0
    AC                   eval      emptyq = dstqty - avail1
    AC                   else
    AC                   eval      emptyq = dstqty
    AC                   endif
    A*
    A*   Get out if no free space.
    A*
    AC                   if        emptyq <= 0
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR26'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
    AC                   goto      endpck
    AC                   endif
    A*
    A*   If this is not a return we are only allowed to use the
    A*   pick slot if it is the only slot containing this item.
    A*
    AC                   if        $pcmd <> '*RETURN '
411 A*
411 A*
411 A*   Note: Actual check is done in routine CHKMLT which is
411 A*         called from routines AWYFIX and AWYPIR.
411 A*
411 AC                   if        mltflg = *on
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR27'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
411 AC                   goto      endpck
411 AC                   endif
    A*
    AC                   endif
     *
     *   Calculate how much (if any) we can put in the slot.
     *
     C                   eval      putqty = 0
     C                   eval      putpal = 0
     *
     C                   select
     *
     *      Try to put entire quantity in slot.
     *
     C                   when      q1lft <= emptyq
     C                   eval      putqty = q1lft
    AC     putqty        div       dspqty        putpal
    AC                   mvr                     extra
    AC                   if        extra > 0  or
    AC                             putpal = 0
    AC                   add       1             putpal
    AC                   endif
     *
     *      Try to put in as many full pallets as we can.
     *
     C                   other
     C                   eval      tmplft = q1lft
     C                   z-add     emptyq        tmpemp
     C                   dow       dspqty <= tmpemp  and
     C                             tmplft >= dspqty
     C                   add       dspqty        putqty
     C                   add       1             putpal
     C                   eval      tmplft = tmplft - dspqty
     C                   eval      tmpemp = tmpemp - dspqty
     C                   enddo
     C                   endsl
     *
     *     If we can't put anything into this slot then leave because
     *     we only wanted to use the first picking slot we came to.
     *
     C                   if        putqty = 0  and
    AC                             q2lft = 0  and
    AC                             q3lft = 0
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR28'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
    AC                   goto      endpck
     C                   endif
     *
412cAC     slamit        tag
     *
     *      Otherwise, put the quantity in the slot.
     *
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 add       putqty        slrcv1
610aDC**                 add       q2lft         slrcv2
610aDC**                 add       q3lft         slrcv3
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = putqty
610aDC**                 eval      savq2 = q2lft
610aDC**                 eval      savq3 = q3lft
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = putpal
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 if        slentd = 0
610aDC**                 if        $pfifo = 0
610aDC**                 eval      slentd = today
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 endif
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = putqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   if        $pcmd = '*SPRECV '
610aAC                   exsr      zzzRcvInSpcl
610aAC                   else
610aAC                   exsr      zzzRcvIn
610aAC                   endif
610aA
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTPCK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
     *      Recalculate tie/high definitions.
     *
     C                   eval      q1lft = q1lft - putqty
     C                   eval      q2lft = 0
     C                   eval      q3lft = 0
     C                   if        q1lft <> 0  or
     C                             q2lft <> 0  or
     C                             q3lft <> 0
     C                   exsr      recalc
     C                   endif
     *
     C     endpck        endsr
     *----------------------------------------------------------------
     *
     *  PUTPIR  Put away in PIR floating slot by priorities.
     *
     C     putpir        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTPIR  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR52'
413aAC                   eval      trsr50 = 'PUTPIR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
217 A*
217 A*  Loop through active slots for item. Start just after the
217 A*  active slots and work backwards. Stop after the first
217 A*  active slot it read.
217 A*
217 AC                   if        pckasl = *blanks
217 AC                   eval      k3stat = 'A '
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3B'
413aAC                   eval      trsr50 = 'PUTPIR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
650gDC**   keys3b        setgt     slot3
650gDC**   keys3b        readpe(n) slot3                                7879
650gMC     keys3b        setgt     slot13
650gMC     keys3b        readpe(n) slot13                               7879
217 AC                   if        not *in79
217 AC                   eval      pckasl = slaisl
217 AC                   eval      prfind = *on
217 AC                   endif
217 AC                   endif
     *
     C                   eval      bldcmd = '*RESET  '
     C                   eval      actcmd = '*RESET  '
     C                   eval      defcmd = '*RESET  '
217 AC                   eval      aslcmd = '*RESET  '
     *
217 M*   Go through build codes, activity zones, same aisle, and
     *   tie/high definitions in user defined priority order.
     *
     C                   dou       forevr <> forevr
     C     oppbld        caseq     1             getbld
     C     oppact        caseq     1             getact
     C     oppdef        caseq     1             getdef
217 AC     oppasl        caseq     1             getpas
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     oppbld        caseq     2             getbld
     C     oppact        caseq     2             getact
     C     oppdef        caseq     2             getdef
217 AC     oppasl        caseq     2             getpas
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     oppbld        caseq     3             getbld
     C     oppact        caseq     3             getact
     C     oppdef        caseq     3             getdef
217 AC     oppasl        caseq     3             getpas
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     oppbld        caseq     4             getbld
     C     oppact        caseq     4             getact
     C     oppdef        caseq     4             getdef
217 AC     oppasl        caseq     4             getpas
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     *      Try to put quantity away.
     *
     C                   eval      found = *off
217 AC                   if        prfind = *on
217 AC                   eval      k6aisl = k7aisl
217 AC                   endif
     C                   exsr      trypir
217 A*
217 A*      Get out if all SLT array elements used up.
217 A*
217 AC                   if        lstlbl = 50
217 AC                   goto      endpp
217 AC                   endif
     *
     *      If quantity is left over ...
     *
     *        When only some of the quantity has been put away we
     *        need to recalculate the tie/high totals to see if there
     *        is a better fitting definition and then reset all the
     *        codes and try to put the rest away.
     *
     *        When none of the quantity was put away then we just
     *        continue in our loop to get the next combination to
     *        look for.
     *
     C                   select
     C                   when      q1lft > 0  or
     C                             q2lft > 0  or
     C                             q3lft > 0
     *
     C                   if        found = *on
     C                   exsr      recalc
     C                   eval      bldcmd = '*RESET  '
     C                   eval      actcmd = '*RESET  '
     C                   eval      defcmd = '*RESET  '
217 AC                   eval      aslcmd = '*RESET  '
     C                   leave
     C                   endif
     *
     *      Otherwise, get out.
     *
     C                   other
     C                   goto      endpp
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   if        found = *on
     C                   leave
     C                   endif
     C                   enddo
     *
217 AC                   if        found = *on
217 AC                   leave
217 AC                   endif
217 AC                   enddo
     *
     C                   enddo
     *
     C     endpp         endsr
     *----------------------------------------------------------------
     *
     *  PUTPR   Try to put PIR item in a reserved active slot.
     *
     C     putpr         begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTPR   '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR53'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
213 AC                   eval      prflag = *off                                               GFG
     *
     *  Loop through active slots for item. Start just after the
     *  active slots and work backwards. Stop after the first
     *  reserved slot is read.
     *
     C                   eval      k3stat = 'A '
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS3B'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
650gDC***  keys3b        setgt     slot3
650gMC     keys3b        setgt     slot13
     C                   dou       forevr <> forevr
650gDC***  keys3b        readpe    slot3                                7879
650gMC     keys3b        readpe    slot13                               7879
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Ignore slot if it is not a reserved slot.
     *
     C                   if        slrsrv <> 'Y'
413aAC                   eval      trnbr = 'TR37'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
610bA
610bA*     Ignore slot if different item exists in slot.
610bA
610bAC                   exsr      chkUsage
610bAC                   if        $uDiffItem = 'Y'
640cMC                   eval      trnbr = 'TR77'
640cMC                   eval      trsr50 = 'PUTPR'
640cMC                   eval      trcode = '*RCV050 '
640cMC                   exsr      zztrck
610bAC                   iter
610bAC                   endif
     *
213 AC                   eval      prflag = *on                                 Reserved slot  GFG
217 AC                   eval      pckasl = slaisl                              Use for same aisle
217 AC                   eval      prfind = *on                                 Item exists in PIR
     *
     *     Get matching slot tie/high definition.
     *
     C                   eval      tmpflg = *off
     C     1             do        lstdef        curdef
     C     curdef        occur     defs
     C                   if        slsdef = dssdef
     C                   eval      tmpflg = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     *     Leave if no matching definition because we only wanted
     *     to work with the first reserved slot.
     *
     C                   if        tmpflg = *off
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR18'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     *   Calculate empty space in slot.
     *
610cDC**    Call program to calculate availabe slot quantities.
610cDC**
610cDC**                 call      'SLOTQTY'
610cDC**                 parm                    slstk1
610cDC**                 parm                    slstk2
610cDC**                 parm                    slstk3
610cDC**
610cDC**                 parm                    slalc1
610cDC**                 parm                    slalc2
610cDC**                 parm                    slalc3
610cDC**
610cDC**                 parm                    sltfr1
610cDC**                 parm                    sltfr2
610cDC**                 parm                    sltfr3
610cDC**
610cDC**                 parm                    slpck1
610cDC**                 parm                    slpck2
610cDC**                 parm                    slpck3
610cDC**
610cDC**                 parm                    slrcv1
610cDC**                 parm                    slrcv2
610cDC**                 parm                    slrcv3
610cDC**
610cDC**                 parm                    stock1
610cDC**                 parm                    stock2
610cDC**                 parm                    stock3
610cDC**
610cDC**                 parm                    avail1
610cDC**                 parm                    avail2
610cDC**                 parm                    avail3
     *
     *     Calculate free space for slot.
     *
610cAC                   eval      avail1 = $uPieces
    AC                   if        avail1 >= 0
    AC                   eval      emptyq = dstqty - avail1
    AC                   else
    AC                   eval      emptyq = dstqty
    AC                   endif
    A*
    A*   Get out if no free space.
    A*
    AC                   if        emptyq <= 0
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR26'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
    AC                   goto      endpr
    AC                   endif
     *
     *   Calculate how much (if any) we can put in the slot.
     *
     C                   eval      putqty = 0
     C                   eval      putpal = 0
    A*
    A*      Put as much as we can in the slot.
    A*
    AC                   if        q1lft <= emptyq
    AC                   eval      putqty = q1lft
    AC                   else
    AC                   z-add     emptyq        putqty
    AC                   endif
    AC     putqty        div       dspqty        putpal
    AC                   mvr                     extra
    AC                   if        extra > 0  or
    AC                             putpal = 0
    AC                   add       1             putpal
    AC                   endif
     *
     *     If we can't put anything into this slot then leave because
     *     we wanted to use the first reserved slot we came to.
     *
     C                   if        putqty = 0  and
    AC                             q2lft = 0  and
    AC                             q3lft = 0
610aDC**                 unlock    slot3
413aAC                   eval      trnbr = 'TR28'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     *      Otherwise, put the quantity in the slot.
     *
610aDC**       If breakdown exists then throw it on pallet.
610aDC**
610aDC**                 add       putqty        slrcv1
610aDC**                 add       q2lft         slrcv2
610aDC**                 add       q3lft         slrcv3
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = putqty
610aDC**                 eval      savq2 = q2lft
610aDC**                 eval      savq3 = q3lft
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = putpal
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 if        slentd = 0
610aDC**                 if        $pfifo = 0
610aDC**                 eval      slentd = today
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 endif
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = putqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aA
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
     *      Recalculate tie/high definitions.
     *
     C                   eval      q1lft = q1lft - putqty
     C                   eval      q2lft = 0
     C                   eval      q3lft = 0
     C                   if        q1lft <> 0  or
     C                             q2lft <> 0  or
     C                             q3lft <> 0
     C                   exsr      recalc
     C                   endif
     *
     *      We are done with the first reserved slot so we can leave.
     *
     C                   leave
     *
     C                   enddo
     *
     C     endpr         endsr
TMP A*----------------------------------------------------------------
TMP A*
TMP A*  PUTSLT  Put item into specific slot.
TMP A*
TMP AC     putslt        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTSLT  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR54'
413aAC                   eval      trsr50 = 'PUTSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
TMP A*
TMP A*  Get slot record.
TMP A*
TMP AC                   eval      k2disp = $pslot
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS2'
413aAC                   eval      trsr50 = 'PUTSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
TMP AC     keys2         chain     slot2                              7978
TMP AC                   if        *in79  or
TMP AC                             *in78
413aAC                   eval      trnbr = 'TR31'
413aAC                   eval      trsr50 = 'PUTSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
TMP AC                   goto      endslt
TMP AC                   endif
TMP A*
TMP A*   Put everything into slot (User is controlling this one).
TMP A*
610aDC**                 eval      slrcv1 = q1lft
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 z-add     q3lft         slrcv3
610aDC**
610aDC**  Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = q1lft
610aDC**                 eval      savq2 = q2lft
610aDC**                 eval      savq3 = q3lft
610aDC**                 eval      savtie = 0
610aDC**                 eval      savhgh = 0
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = 1
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**     Update slot record.
610aDC**
610aDC**                 eval      slitem = #sitem
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = prirty
610aDC**                 update    s2rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      forceOnePallet = *on
610aAC                   eval      rcvInQty1 = q1lft
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aA
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'PUTSLT'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
TMP A*
TMP AC                   eval      q1lft = 0
TMP AC                   eval      q2lft = 0
TMP AC                   eval      q3lft = 0
TMP A*
TMP AC     endslt        endsr
     *----------------------------------------------------------------
     *
     *  PUTUPR  Try to put item in upper level by picking slot.
     *
     C     putupr        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTUPR  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR55'
413aAC                   eval      trsr50 = 'PUTUPR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   eval      aslcmd = '*RESET  '
     C                   eval      sidcmd = '*RESET  '
     C                   eval      lvlcmd = '*RESET  '
     C                   eval      defcmd = '*RESET  '
     *
     *   Go through build codes, activity zones and tie/high
     *   definitions in user defined priority order.
     *
     C                   dou       forevr <> forevr
     C     opfasl        caseq     1             getasl
     C     opfsid        caseq     1             getsid
     C     opflvl        caseq     1             getlvl
     C     opfdef        caseq     1             getdef
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     opfasl        caseq     2             getasl
     C     opfsid        caseq     2             getsid
     C     opflvl        caseq     2             getlvl
     C     opfdef        caseq     2             getdef
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     opfasl        caseq     3             getasl
     C     opfsid        caseq     3             getsid
     C     opflvl        caseq     3             getlvl
     C     opfdef        caseq     3             getdef
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     opfasl        caseq     4             getasl
     C     opfsid        caseq     4             getsid
     C     opflvl        caseq     4             getlvl
     C     opfdef        caseq     4             getdef
     C                   endcs
     C                   if        tmprtn = '*NOMORE '
     C                   leave
     C                   endif
     *
     *      Try to put quantity away.
     *
     C                   eval      found = *off
     C                   exsr      tryfix
217 A*
217 A*      Get out if all SLT array elements used up.
217 A*
217 AC                   if        lstlbl = 50
217 AC                   goto      endpu
217 AC                   endif
     *
     *      If quantity is left over ...
     *
     *        When only some of the quantity has been put away we
     *        need to recalculate the tie/high totals to see if there
     *        is a better fitting definition and then reset all the
     *        codes and try to put the rest away.
     *
     *        When none of the quantity was put away then we just
     *        continue in our loop to get the next combination to
     *        look for.
     *
     C                   select
     C                   when      q1lft > 0  or
     C                             q2lft > 0  or
     C                             q3lft > 0
     *
     C                   if        found = *on
     C                   exsr      recalc
     C                   eval      aslcmd = '*RESET  '
     C                   eval      sidcmd = '*RESET  '
     C                   eval      lvlcmd = '*RESET  '
     C                   eval      defcmd = '*RESET  '
     C                   leave
     C                   endif
     *
     *      Otherwise, get out.
     *
     C                   other
     C                   goto      endpu
     *
     C                   endsl
     *
     C                   enddo
     *
     C                   if        found = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     *
     C                   if        found = *on
     C                   leave
     C                   endif
     C                   enddo
     *
     C                   enddo
     *
     *
     C     endpu         endsr
404 A*----------------------------------------------------------------
404 A*
404 A*  PUTXDK  Try to put item into cross dock slots.
404 A*
404 AC     putxdk        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'PUTXDK  '    trsubr
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR56'
413aAC                   eval      trsr50 = 'PUTXDK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
404 A*
404 A*  P.O. detail info must have been sent to program.
404 A*
404 AC     $pseq         cabeq     0             endpx
416cA*
416cA*   See if host is providing an xdock quantity.
416cA*
610aDC**                 exsr      zzzx2d
610aAC                   exsr      clr$xdock
610aAC                   eval      $xdwhseu = *on
610aAC                   eval      $xdwhse = $pwhse
610aAC                   eval      $xditemu = *on
610aAC                   eval      $xditem = $pitem
610aAC                   eval      $xdpou = *on
610aAC                   eval      $xdpo = $ppo
610aAC                   eval      $xdseq#u = *on
610aAC                   eval      $xdseq# = $pseq
610aAC                   eval      $xdqtyu = *off
610aaC                   eval      $xdqty1 = 0
610aaC                   eval      $xdqty2 = 0
610aAC                   eval      $xdqty3 = 0
     *
416cAC                   eval      dricmd = '*XDOCK'
416cAC                   eval      drisub = '*GETQTY'
610aMC                   exsr      zzzdricop
610aMC                   if        $xdqty1 > 0  or
610aMC                             $xdqty2 > 0  or
610aMC                             $xdqty3 > 0
416fAC                   if        locatr = *on
416fMC                   exsr      putxlc
416fAC                   else
416fAC                   exsr      putxfl
416fAC                   endif
416fMC                   goto      endxdk
416cAC                   endif
404 A*
404 A*  Loop through any cross dock records for line item.
404 A*
404 AC                   eval      xdkupd = *off
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYCD2'
413aAC                   eval      trsr50 = 'PUTXDK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
404 AC     keycd2        setll     crossdk2
404 AC                   dow       forevr = forevr
404 AC     keycd2        reade     crossdk2                               77
404 AC                   if        *in77
404 AC                   leave
404 AC                   endif
404 A*
404 A*  Get slot assigned to cross dock item.
404 A*
404 AC                   eval      k2disp = cdslot
404 AC     keys2x        chain     slot2                              76
404 AC                   if        *in76
413aAC                   eval      trnbr = 'TR32'
413aAC                   eval      trsr50 = 'PUTXDK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
404 AC                   iter
404 AC                   endif
404 A*
404 A*  Calculate qty still needed.
404 A*
404 A*  Call program to calculate available slot quantities.
404 A*
404 AC                   call      'SLOTQTY'
404 AC                   parm                    slstk1
404 AC                   parm                    slstk2
404 AC                   parm                    slstk3
404 A*
404 AC                   parm                    slalc1
404 AC                   parm                    slalc2
404 AC                   parm                    slalc3
404 A*
404 AC                   parm                    sltfr1
404 AC                   parm                    sltfr2
404 AC                   parm                    sltfr3
404 A*
404 AC                   parm                    slpck1
404 AC                   parm                    slpck2
404 AC                   parm                    slpck3
404 A*
404 AC                   parm                    slrcv1
404 AC                   parm                    slrcv2
404 AC                   parm                    slrcv3
404 A*
404 AC                   parm                    stock1
404 AC                   parm                    stock2
404 AC                   parm                    stock3
404 A*
404 AC                   parm                    avail1
404 AC                   parm                    avail2
404 AC                   parm                    avail3
404 A*
404 A*   With cross docks, quantity is needed if the available qty
404 A*   is negative.  Cross dock slots are the only slots that allow
404 A*   the available quantity to go negative.
404 A*
404 AC                   if        avail1 >= 0
404 AC                   eval      need1 = 0
404 AC                   else
404 AC                   eval      need1 = -(avail1)
404 AC                   endif
404 AC                   if        avail2 >= 0
404 AC                   eval      need2 = 0
404 AC                   else
404 AC                   eval      need2 = -(avail2)
404 AC                   endif
404 AC                   if        avail3 >= 0
404 AC                   eval      need3 = 0
404 AC                   else
404 AC                   eval      need3 = -(avail3)
404 AC                   endif
404 A*
404 A*   Get out if nothing needed.
404 A*
404 AC                   if        need1 = 0  and
404 AC                             need2 = 0  and
404 AC                             need3 = 0
610aDC**                 unlock    slot2
413aAC                   eval      trnbr = 'TR33'
413aAC                   eval      trsr50 = 'PUTXDK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
404 AC                   iter
404 AC                   endif
404 A*
404 A*   Make sure breakdown qty's are not greater than unit of
404 A*   measure quantity.
404 A*
404 AC                   dow       need3 >= $itumq3  and
404 AC                             $itumq3 <> 0
404 AC                   eval      need3 = need3 - $itumq3
404 AC                   add       1             need2
404 AC                   enddo
404 A*
404 AC                   dow       need2 >= $itumq2  and
404 AC                             $itumq2 <> 0
404 AC                   eval      need2 = need2 - $itumq2
404 AC                   add       1             need1
404 AC                   enddo
404 A*
404 A*   Receive needed quantity.
404 A*   If breakdown quantity is needed and a corresponding breakdown
404 A*   qty is not being received, then take it.
404 A*   If breakdown quantity is needed but a corresponding breakdown
404 A*   qty is not being received, then increase the qty needed by
404 A*   the next larger breakdown by 1. We don't want the receivers
404 A*   to breakdown boxes.  That job is left for the selectors.
404 A*
404 AC                   if        need3 > 0
404 AC                   select
404 AC                   when      q3lft = 0
404 AC                   add       1             need2
404 AC                   when      need3 <= q3lft
404 AC                   z-add     need3         slrcv3
404 AC                   eval      q3lft = q3lft - need3
404 AC                   other
404 AC                   z-add     q3lft         slrcv3
404 AC                   eval      q3lft = 0
404 AC                   add       1             need2
404 AC                   endsl
404 AC                   endif
404 A*
404 AC                   if        need2 > 0
404 AC                   select
404 AC                   when      q2lft = 0
404 AC                   add       1             need1
404 AC                   when      need2 <= q2lft
404 AC                   z-add     need2         slrcv2
404 AC                   eval      q2lft = q2lft - need2
404 AC                   other
404 AC                   z-add     q2lft         slrcv2
404 AC                   eval      q2lft = 0
404 AC                   add       1             need1
404 AC                   endsl
404 AC                   endif
404 A*
404 AC                   if        need1 > 0
404 AC                   select
404 AC                   when      need1 <= q1lft
404 AC                   eval      slrcv1 = need1
404 AC                   eval      q1lft = q1lft - need1
404 AC                   other
404 AC                   eval      slrcv1 = q1lft
404 AC                   eval      q1lft = 0
404 AC                   endsl
404 AC                   endif
610aDC**
610aDC**  Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = 0
610aDC**                 eval      savhgh = 0
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = 1
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**  Update slot record.
610aDC**
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = 0
610aDC**                 update    s2rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      forceOnePallet = *on
610aAC                   eval      rcvInQty1 = slrcv1
610aAC                   eval      rcvInQty2 = slrcv2
610aAC                   eval      rcvInQty3 = slrcv3
610aAC                   exsr      zzzRcvIn
610aA
404 AC                   eval      xdkupd = *on
413aAC                   eval      trnbr = 'TR34'
413aAC                   eval      trsr50 = 'PUTXDK'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
404 A*
404 A*   Get out if when nothing left.
404 A*
404 AC                   if        q1lft = 0  and
404 AC                             q2lft = 0  and
404 AC                             q3lft = 0
404 AC                   leave
404 AC                   endif
404 A*
404 AC                   enddo
404 A*
416fAC     endxdk        tag
404 A*
404 AC                   if        xdkupd = *on
404 AC                   exsr      recalc
404 AC                   endif
404 A*
404 AC     endpx         endsr
416fA*----------------------------------------------------------------
416fA*
416fA*  PUTXFL  DRI crossdocking for Full system.
416fA*
416fAC     putxfl        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*RCV040 '
     C                   movel     'PUTXFL  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
610aMC                   if        $xdqty1 > q1lft
     C                   eval      need1 = q1lft
     C                   else
610aMC                   eval      need1 = $xdqty1
     C                   endif
610aMC                   if        $xdqty2 > q2lft
     C                   eval      need2 = q2lft
     C                   else
610aMC                   eval      need2 = $xdqty2
     C                   endif
610aMC                   if        $xdqty3 > q3lft
     C                   eval      need3 = q3lft
     C                   else
610aMC                   eval      need3 = $xdqty3
     C                   endif
     *
     *  See if xdock slot exists
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %GETXDOCK.
     *
     C                   eval      k3stat = 'XD'
650gDC***  keys3b        setll     slot3
650gMC     keys3b        setll     slot13
     C                   dow       forevr = forevr                                              DO2
650gDC***                read      slot3                                  79
650gMC                   read      slot13                                 79
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *    Double verify that slot is an xdock slot in same department.
     *
     C                   if        slaisl <> 'XDK'  or
     C                             slwhdp <> $itwhdp
     C                   iter
     C                   endif
     *
     *    XDock slot found for item. Update receiving.
     *
610aDC**                 add       need1         slrcv1
610aDC**                 add       need2         slrcv2
610aDC**                 add       need3         slrcv3
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = 0
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      xdkupd = *on
610aAC                   eval      savas2 = 'XDK'
610aAC                   eval      forceOnePallet = *on
610aAC                   eval      rcvInQty1 = need1
610aAC                   eval      rcvInQty2 = need2
610aAC                   eval      rcvInQty3 = need3
610aAC                   exsr      zzzRcvIn
610aAC                   eval      savas2 = ' '
     *
416dMC                   if        drirtn = '*OK'
     C                   goto      savxdr
     C                   endif                                                                 END2
     *
     C                   leave
     *
     C                   enddo                                                                 END2
FPRaA*
FPRaAC***                if        client = FoodPro
FPRaA*      XDK slot not found, so get out and look for SO slot.
FPRaAC***                if        $pcmd = '*SPRECV'
FPRaAC***                goto      endxfl
FPRaAC***                endif
FPRaA*
FPRaAC***                endif
     *
     *  XDock slot not found for item. Create one.
     *
     *     Note: When program is updated to work directly with
     *           DRI interface, this can be replaced with %CRTXDOCK.
     *
     *    Find next available XDK slot to use.
     *
     C                   eval      tmploc = 1
     C                   eval      k1aisl = 'XDK'
     C     keys1b        setll     slot1
     C                   dow       forevr = forevr
     C     keys1b        reade(n)  slot1                                  79
     C                   if        *in79  or
     C                             slloc > tmploc
     C                   leave
     C                   endif
     C     slloc         add       1             tmploc
     C                   enddo
     *
     *    Initialize slot fields.
     *
     C                   clear                   s1rec
     C                   eval      slwhse = $pwhse
     C                   eval      slwhdp = $itwhdp
     C                   eval      slaisl = 'XDK'
     C                   eval      slloc = tmploc
     C                   eval      slrlvl = 1
     C                   eval      slhand = *blanks
     C                   eval      slstyp = 'X'
     C                   eval      slpseq = tmploc
     C                   eval      slitem = $pitem
     C                   eval      slstat = 'XD'
     C                   eval      slsdte = today
     C                   time                    slstim
     C                   eval      slpick = 'N'
     C                   eval      slrsrv = 'N'
     C     slloc         div       2             dummy
     C                   mvr                     slside
     C                   if        slside < 0
     C                   eval      slside = -(slside)
     C                   endif
417cAC                   if        $pfifo = 0
     C                   move      today         slentd
417cAC                   else
417cAC                   eval      slentd = $pfifo
417cAC                   endif
     C                   eval      slexpd = $pexpd
     C                   eval      slprty = 0
610aDC**                 eval      slrcv1 = need1
610aDC**                 z-add     need2         slrcv2
610aDC**                 z-add     need3         slrcv3
     *
     *    Format display slot.
     *
     C                   call      'FRMTSL'
     C                   parm                    slwhse
     C                   parm                    slwhdp
     C                   parm                    slaisl
     C                   parm                    slloc
     C                   parm                    slrlvl
     C                   parm                    slhand
     C                   parm                    slstyp
     C                   parm                    slpseq
     C                   parm                    sldisp
     *
     *    Add record
     *
     C                   write     s1rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      xdkupd = *on
610aAC                   eval      savas2 = 'XDK'
610aAC                   eval      forceOnePallet = *on
610aAC                   eval      rcvInQty1 = need1
610aAC                   eval      rcvInQty2 = need2
610aAC                   eval      rcvInQty3 = need3
610aAC                   exsr      zzzRcvIn
610aAC                   eval      savas2 = ' '
     *
     *   Save info for final post.
     *
     C     savxdr        tag
610aDC**                 eval      xdkupd = *on
610aDC**                 eval      savas2 = 'XDK'
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = need1
610aDC**                 eval      savq2 = need2
610aDC**                 eval      savq3 = need3
610aDC**                 eval      savtie = 0
610aDC**                 eval      savhgh = 0
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = 1
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**                 eval      savas2 = *blanks
416dA*
416dA*   Tell host quantity received into xdock slot.
416dA*
610aDC**                 exsr      zzzx2d
610aAC                   exsr      clr$xdock
610aAC                   eval      $xdwhseu = *on
610aAC                   eval      $xdwhse = $pwhse
610aAC                   eval      $xditemu = *on
610aAC                   eval      $xditem = $pitem
610aAC                   eval      $xdpou = *on
610aAC                   eval      $xdpo = $ppo
610aAC                   eval      $xdseq#u = *on
610aAC                   eval      $xdseq# = $pseq
610aAC                   eval      $xdqtyu = *off
610aMC                   eval      $xdqty1 = need1
610aMC                   eval      $xdqty2 = need2
610aMC                   eval      $xdqty3 = need3
416dAC                   eval      dricmd = '*XDOCK'
416dAC                   eval      drisub = '*RECEIVE'
610aMC                   exsr      zzzdricop
     *
416dA*
416dA*   Update qty left and then recalc.
416dA*
     C                   eval      q1lft = q1lft - need1
     C                   eval      q2lft = q2lft - need2
     C                   eval      q3lft = q3lft - need3
     *
416fAC     endxfl        endsr
FPRaA*
FRPaA*----------------------------------------------------------------
FPRaA*
FPRaA*  putxfl_FPR  Modified DRI crossdocking for FoodPro.
FPRaA*              Will only putaway to XDK if slot exists.
FPRaA*
FPRaAC     putxfl_FPR    begsr
FPRaA*
FPRaA*  See if xdock slot exists
FPRaA*
FPRaA*     Note: When program is updated to work directly with
FPRaA*           DRI interface, this can be replaced with %GETXDOCK.
FPRaA*
FPRaAC                   eval      k3stat = 'XD'
FPRaAC     keys3b        setll     slot3
FPRaAC                   dow       forevr = forevr
FPRaAC     keys3b        reade     slot3
FPRaAC                   if        %eof(slot3)
FPRaAC                   leavesr
FPRaAC                   endif
FPRaA*
FPRaA*    Looking for existingi XDK slot for received item.
FPRaA*
FPRaAC                   if              slwhdp <> $itwhdp
FPRaAC                   iter
FPRaAC                   endif
FPRaA*
FPRaAC                   leave
FPRaAC                   enddo
FPRaA*
FPRaA*     Get transaction and label numbers
FPRaA*     This needs to be done so they can be sent to drislot.
FPRaA*
FPRaAC                   call      'PIRTRN#'
FPRaAC                   parm                    pttrn#            7 0
FPRaA
FPRaAC                   call      'PIRLBL#'
FRPaAC                   parm                    newlbl#
FPRaA*
FPRaAC                   eval      $slwhseu = *on
FPRaAC                   eval      $slwhse  = slwhse
FPRaAC                   eval      $slwhdpu = *on
FPRaAC                   eval      $slwhdp  = slwhdp
FPRaAC                   eval      $sldispu = *on
FPRaAC                   eval      $sldisp  = sldisp
FPRaAC                   eval      $saitemu = *on
FPRaAC                   eval      $saitem  = #sitem
FPRaA
FPRaAC                   eval      $saqtyu = *on
FPRaAC                   eval      $saqty1 = q1lft
FPRaAC                   eval      $saqty2 = q2lft
FPRaAC                   eval      $saqty3 = q3lft
FPRaA
FPRaAC                   eval      $sacwtau = *on
FPRaAC                   eval      $sacwta  = 0
FPRaAC                   eval      $sacodeu = *on
FPRaAC                   eval      $sacode  = '@@'
FPRaAC                   eval      $samemou = *on
FPRaAC                   eval      $samemo  = ' '
FPRaAC                   eval      $sabyu   = *on
FPRaAC                   eval      $saby    = #curruser
FPRaA
FPRaAC                   eval      $saActionU = *on
FPRaAC                   eval      $saAction = 'XDK'
FPRaAC                   eval      $saTrn#U = *on
FPRaAC                   eval      $saTrn# = pttrn#
FPRaAC                   eval      $saETrn#U = *on
FPRaAC                   eval      $saETrn# = 0
FPRaAC                   eval      $saLbl#U = *on
FPRaAC                   eval      $saLbl# = newlbl#
FPRaAC                   eval      $saToPosU = *on
FPRaAC                   eval      $saToPos = 1
FPRaAC                   eval      $saToLcnsU = *on
FPRaAC                   eval      $saToLcns = '*XD'
FPRaAC                                       + %editc(pttrn#:'X')
FPRaAC                   eval      $saToVrfyU = *on
FPRaAC                   eval      $saToVrfy = 'Y'
FPRaAC                   eval      $saFrmLcnsU = *on
FPRaAC                   eval      $saFrmLcns = $saToLcns
FPRaAC                   eval      $saOLcnsU = *on
FPRaAC                   eval      $saOLcns = $saToLcns
FPRaA
FPRaAC                   eval      $dricommand = '*SLOT'
FPRaAC                   eval      $drisubcmd  = '%ADJUSTOSS'
FPRaAC                   eval      $drisys2upd = 'D'
FPRaAC                   eval      ck4err = *on
FPRaAC                   eval      zmflag  = *on
FPRaAC                   exsr      zzzdricop
FPRaA*
FPRaA*       Cross dock slot updated successfully.
FPRaAC                   if        $drireturn = '*OK'
FPRaA*
FPRaAC                   eval      q1lft = 0
FPRaAC                   eval      q2lft = 0
FPRaAC                   eval      q3lft = 0
FPRaAC                   endif
FPRaA*
FPRaAC     endxfl_fpr    endsr
FPRaA*
416fA*----------------------------------------------------------------
416fA*
416fA*  PUTXLC  DRI crossdocking for Locator system.
416fA*
416fAC     putxlc        begsr
     *
     *  Write out tracking record.
     *
     C                   eval      trcode = '*RCV040 '
     C                   movel     'PUTXLC  '    trsubr
     C                   exsr      zztrck
     *
     C                   eval      xdkupd = *off
     *
     *   Calculate quantity needed.
     *
610aMC                   if        $xdqty1 > q1lft
     C                   eval      need1 = q1lft
     C                   else
610aMC                   eval      need1 = $xdqty1
     C                   endif
610aMC                   if        $xdqty2 > q2lft
     C                   eval      need2 = q2lft
     C                   else
610aMC                   eval      need2 = $xdqty2
     C                   endif
610aMC                   if        $xdqty3 > q3lft
     C                   eval      need3 = q3lft
     C                   else
610aMC                   eval      need3 = $xdqty3
     C                   endif
     *
     *  Put crossdock into first pick slot for item.
     *
     C                   eval      k3stat = 'A '
     C                   eval      k3pick = 'Y'
650gDC***  keys3         setll     slot3
650gDC***  keys3         reade     slot3                                  79
650gMC     keys3         setll     slot13
650gMC     keys3         reade     slot13                                 79
     *
     *    If it doesn't exist, throw error.
     *
     C                   if        *in79
     C                   eval      error = *on
     C                   eval      $prtn = '*NOPICK '
     C                   goto      endxlc
     C                   endif
     *
     *    Otherwise, update slot.
     *
610aDC**     Add crossdock qty to receive quantity.
610aDC**
610aDC**                 add       need1         slrcv1
610aDC**                 add       need2         slrcv2
610aDC**                 add       need3         slrcv3
610aDC**
610aDC**     Update entered date if necessary.
610aDC**
610aDC**                 if        slentd = 0  or
610aDC**                           slstk1 = 0  and
610aDC**                           slstk2 = 0  and
610aDC**                           slstk3 = 0  and
610aDC**                           slalc1 = 0  and
610aDC**                           slalc2 = 0  and
610aDC**                           slalc3 = 0  and
610aDC**                           sltfr1 = 0  and
610aDC**                           sltfr2 = 0  and
610aDC**                           sltfr3 = 0  and
610aDC**                           slpck1 = 0  and
610aDC**                           slpck2 = 0  and
610aDC**                           slpck3 = 0  and
610aDC**                           slrcv1 = 0  and
610aDC**                           slrcv2 = 0  and
610aDC**                           slrcv3 = 0
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = 0
610aDC**                 endif
610aDC**
610aDC**     Update expiration date if necessary.
610aDC**
610aDC**                 if        slexpd = 0  or
610aDC**                           $pexpd < slexpd
610aDC**                 eval      slexpd = $pexpd
610aDC**                 endif
610aDC**
610aDC**     Update record.
610aDC**
610aDC**                 update    s3rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      xdkupd = *on
610aAC                   eval      savas2 = 'XDK'
610aAC                   eval      forceOnePallet = *on
610aAC                   eval      rcvInQty1 = need1
610aAC                   eval      rcvInQty2 = need2
610aAC                   eval      rcvInQty3 = need3
610aAC                   exsr      zzzRcvIn
610aAC                   eval      savas2 = ' '
610aDC**
610aDC**  Save info for final post.
610aDC**
610aDC**                 eval      xdkupd = *on
610aDC**                 eval      savas2 = 'XDK'
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = need1
610aDC**                 eval      savq2 = need2
610aDC**                 eval      savq3 = need3
610aDC**                 eval      savtie = 0
610aDC**                 eval      savhgh = 0
610aDC**                 eval      savsta = slstat
610aDC**                 eval      savlbl = 1
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**                 eval      savas2 = *blanks
416dA*
416dA*   Tell host quantity received into xdock slot.
416dA*
610aDC**                 exsr      zzzx2d
610aAC                   exsr      clr$xdock
610aAC                   eval      $xdwhseu = *on
610aAC                   eval      $xdwhse = $pwhse
610aAC                   eval      $xditemu = *on
610aAC                   eval      $xditem = $pitem
610aAC                   eval      $xdpou = *on
610aAC                   eval      $xdpo = $ppo
610aAC                   eval      $xdseq#u = *on
610aAC                   eval      $xdseq# = $pseq
610aAC                   eval      $xdqtyu = *off
610aMC                   eval      $xdqty1 = need1
610aMC                   eval      $xdqty2 = need2
610aMC                   eval      $xdqty3 = need3
416dAC                   eval      dricmd = '*XDOCK'
416dAC                   eval      drisub = '*RECEIVE'
610aMC                   exsr      zzzdricop
     *
416dA*
416dA*   Update qty left and then recalc.
416dA*
     C                   eval      q1lft = q1lft - need1
     C                   eval      q2lft = q2lft - need2
     C                   eval      q3lft = q3lft - need3
     *
416fAC     endxlc        endsr
     *----------------------------------------------------------------
     *
     *  RECALC  Recalculate definition variables.
     *
     C     recalc        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'RECALC  '    trsubr
413aAC                   exsr      zztrck
     *
     C     1             do        lstdef        x
     C     x             occur     defs
     *
     *     Calculate number of pallets needed. Save overflow quantity.
     *
     C                   if        q1lft = 0
     C                   if        idtie = 0
     C     1             div(h)    idhigh        palets
     C                   else
     C     1             div(h)    idtie         palets
     C                   endif
     C                   else
    MC     q1lft         div(h)    dspqty        palets
     C                   endif
     C                   eval      dsplts = palets
     C                   if        palets > dsplts
     C                   add       1             dsplts
     C                   endif
     *
     *     Calculate number of slots needed.
     *
    MC     palets        div(h)    dsposf        slots
     C                   z-add     slots         dsupct
     C                   if        dsupct = 0
     C                   eval      dsslts = slots
     C                   else
     C                   eval      dsslts = slots + 1
     C                   endif
     *
     *     Calculate actual quantity to go into next slot found.
610dA*     Revised to only use a maximum of 1 pallet.
     *
640eAC                   if        q1lft < dspqty
610dMC                   eval      dssqty = q1lft
610dMC                   else
610dMC                   eval      dssqty = dspqty
610dMC                   endif

640eDC**                 if        dsslts = 1
640eDC**                 eval      dssqty = q1lft
640eDC**                 else
610dDC**   dsposf        mult      dspqty        dssqty
640eDC**                 eval      dssqty = dspqty
640eDC**                 endif
     *
     *     Save slots needed in array for later sorting.
     *
210 AC                   if        dsslts = 1  and
210 AC                             dsupct < opupct  and
210 AC                             dsupct <> 0
210 AC                   eval      svflag = *on
210 AC                   else
210 AC                   eval      svflag = *off
210 AC                   endif
     C                   eval      svslts = dsslts
210 AC     1             sub       dsupct        svupct
     C                   z-add     x             svocur
     C                   eval      ocr(x) = svgrp
     *
     C                   enddo
     *
     *  Sort definition array by the number of slots needed.
     *
     C                   sorta     ocr
     *
     *  Position to starting Tie/High definition.
     *
210 A*    The array now comes out in the proper priority order after
210 A*    being sorted.  This is because of the flag field and the
210 A*    empty percentage field being added to the array.
210 A*    The array is sorted by flag, by number of slots need, and
210 A*    by empty percentage. If only one slot is needed but the
210 A*    percent of the slot used does not meet the optimal usage
210 A*    percent entered by the user, the flag field is set to '1'
210 A*    so it will be sorted at the end of the array.
210 A*
     C                   eval      defpos = 1
     C                   eval      defbeg = defpos
     *
413aAC                   eval      trcode = '*RCV010 '                          Item defs
413aAC                   exsr      zztrck
413aAC                   eval      trnbr = 'TR61'
413aAC                   eval      trsr50 = 'RECALC'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   endsr
     *----------------------------------------------------------------
     *
     *  TRYFIX  Try to put item away in fixed slot with specific
     *          aisle, tie/high definition and level.
     *
     C     tryfix        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'TRYFIX  '    trsubr
413aAC                   exsr      zztrck
     *
     *   If there are no matching slots then get out. The key has
     *   been setup through the GET routines.
     *
     C     keys7a        setll     slot7                                  50
413aAC                   if        not *in50
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS7A'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
413aAC                   endif
     C     *in50         cabeq     *off          endtf
     *
     *   When we are in the same aisle as the picking slot we want
     *   to find the slot closest to the picking slot. Also, which
     *   side of the aisle the slot is on becomes important.
     *
     C                   if        k7aisl = pckasl
     C                   eval      bfrdif = 0
     C                   eval      aftdif = 0
413eAC                   eval      bfrloc = 0
413eAC                   eval      aftloc = 0
     *
     *     Whip through the slots from the beginning of the aisle.
     *
     C     keys7a        setll     slot7
     C                   dou       forevr <> forevr
     C     keys7a        reade(n)  slot7                                  79
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        slpick = 'Y'
     C                   iter
     C                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
640dD **
640dD **    Ignore slot if any item exists in slot.
640dD **
640dDC**                 exsr      chkUsage
640dDC**                 if        $uRecs > 0
640dDC**                 iter
640dDC**                 endif
640dA
640dA*     Ignore slot if no slot positions left
640dA
640dAC                   if        $pfifo = 0
640dAC                   eval      $uEntDte = today
640dAC                   else
640dAC                   eval      $uEntDte = $pfifo
640dAC                   endif
640dAC                   if        $itflgd = 'Y'
640dAC                   eval      $uExpDte = $pexpd
640dAC                   else
640dAC                   eval      $uExpDte = 0
640dAC                   endif
640dA
640dAC                   exsr      chkUsage
640dAC                   if        $uRecs >= dsposf
640dMC                   eval      trnbr = 'TR26'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dAC                   iter
640dAC                   endif
640dA
640dA*     Ignore slot it contains different item
640dA
640dAC                   if        $uDiffItem = 'Y'
640dMC                   eval      trnbr = 'TR77'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dAC                   iter
640dAC                   endif
640dA
640dA*     Ignore slot it contains same item with differnt dates
640dA
610dAC                   if        $uRecs > 0
640dMC                   if        $uDiffEntd = 'Y' or $uDiffExpd = 'Y'
640dMC                   eval      trnbr = 'TR30'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dMC                   iter
640dMC                   endif
640dMC                   endif
     *
     *        Make sure slot is on the side we are working with.
     *
     C     slloc         div       2             temp3n
     C                   mvr                     temp1n
     C                   if        temp1n = 0  and
     C                             cursid = '*ODD    '  or
     C                             temp1n = 1  and
     C                             cursid = '*EVEN   '
     C                   iter
     C                   endif
     *
     *        Calculate how far away the slot is.  If we have gone
     *        past the picking slot we can stop.
     *
     C                   if        slloc < pckloc
     C                   eval      bfrdif = pckloc - slloc
     C                   eval      bfrloc = slloc
     C                   else
     C                   eval      aftdif = slloc - pckloc
     C                   eval      aftloc = slloc
413aAC                   eval      trnbr = 'TR36'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   leave
     C                   endif
     *
     C                   enddo
     *
     *     If no slots found then get out.
     *
413eMC                   if        bfrloc = 0  and
413eMC                             aftloc = 0
     C                   goto      endtf
     C                   endif
     *
     *     Otherwise, position to the closest slot found.
     *
     C                   select
413eMC                   when      bfrloc = 0
     C                   eval      k7loc = aftloc
413eMC                   when      aftloc = 0
     C                   eval      k7loc = bfrloc
     C                   when      bfrdif <= aftdif
     C                   eval      k7loc = bfrloc
     C                   other
     C                   eval      k7loc = aftloc
     C                   endsl
     *
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS7A'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C     keys7b        setll     slot7
     *
     C                   endif
     *
     *   Now, get a matching slot and fill it.
     *
     C                   dou       forevr <> forevr
     C     keys7a        reade     slot7                                7879
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        *in78  or
     C                             slpick = 'Y'
413aAC                   eval      trnbr = 'TR17'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     *
     *     Make sure slot is on the side we are working with.
     *     Only if we are in the picking slot aisle.
     *
     C                   if        slaisl = pckasl
     C     slloc         div       2             temp3n
     C                   mvr                     temp1n
     C                   if        temp1n = 0  and
     C                             cursid = '*ODD    '  or
     C                             temp1n = 1  and
     C                             cursid = '*EVEN   '
413aAC                   eval      trnbr = 'TR40'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
     C                   endif
640dA
640dA*     Ignore slot if no slot positions left
640dA
640dAC                   if        $pfifo = 0
640dAC                   eval      $uEntDte = today
640dAC                   else
640dAC                   eval      $uEntDte = $pfifo
640dAC                   endif
640dAC                   if        $itflgd = 'Y'
640dAC                   eval      $uExpDte = $pexpd
640dAC                   else
640dAC                   eval      $uExpDte = 0
640dAC                   endif
640dA
640dAC                   exsr      chkUsage
640dAC                   if        $uRecs >= dsposf
640dMC                   eval      trnbr = 'TR26'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dAC                   iter
640dAC                   endif
640dA
640dA*     Ignore slot it contains different item
640dA
640dAC                   if        $uDiffItem = 'Y'
640dMC                   eval      trnbr = 'TR77'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dAC                   iter
640dAC                   endif
640dA
640dA*     Ignore slot it contains same item with differnt dates
640dA
610dAC                   if        $uRecs > 0
640dMC                   if        $uDiffEntd = 'Y' or $uDiffExpd = 'Y'
640dMC                   eval      trnbr = 'TR30'
640dMC                   eval      trsr50 = 'TRYFIX'
640dMC                   eval      trcode = '*RCV050 '
640dMC                   exsr      zztrck
640dMC                   iter
640dMC                   endif
640dMC                   endif
610aDC**
610aDC**    Fill up slot.
610aDC**
610aDC**      If breakdown quantity exists then throw it on pallet.
610aDC**
610aDC**                 eval      found = *on
610aDC**                 eval      slrcv1 = dssqty
610aDC**                 eval      q1lft = q1lft - dssqty
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 eval      q2lft = 0
610aDC**                 z-add     q3lft         slrcv3
610aDC**                 eval      q3lft = 0
610aDC**                 eval      dsslts = dsslts - 1
610aDC**
610aDC**     Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 if        dsslts > 0
610aDC**                 eval      savlbl = dsposf
610aDC**                 else
610aDC**                 eval      savlbl = dsplts
610aDC**                 endif
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**    Update slot record.
610aDC**
610aDC**                 eval      slstat = '@R'
610aDC**                 eval      slitem = #sitem
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 eval      slprty = prirty
610aDC**                 update    s7rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = dssqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= dssqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
610aA
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'TRYFIX'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
640dAC                   eval      found = *on
     C                   leave
     *
     C                   enddo
     *
     C     endtf         endsr
     *----------------------------------------------------------------
     *
     *  TRYPIR  Try to put item away in PIR slot with specific
     *          tie/high defintion, build code, activity zone,
     *          and aisle.
     *
     C     trypir        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'TRYPIR  '    trsubr
413aAC                   exsr      zztrck
     *
     *   Loop through matching slots. Key has been setup through
     *   the GET routines.
217 A*   Use KEYS6A when using specific aisle.
     *
217 AC                   if        prfind = *on
217 AC     keys6a        setll     slot6                                  50
217 AC                   else
     C     keys6         setll     slot6                                  50
217 AC                   endif
413aAC                   if        not *in50
413aAC                   eval      trnbr = 'TR22'
413aAC                   eval      trkey = 'KEYS6A'
413aAC                   eval      trsr50 = 'TRYPIR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
413aAC                   endif
     C     *in50         cabeq     *off          endtp
     *
     C                   dou       forevr <> forevr
217 AC                   if        prfind = *on
610aDC**   keys6a        reade     slot6                                7879
610aMC     keys6a        reade(n)  slot6                                7879
217 AC                   else
610aDC**   keys6         reade     slot6                                7879
610aMC     keys6         reade(n)  slot6                                7879
217 AC                   endif
     C                   if        *in79
     C                   leave
     C                   endif
     C                   if        *in78
413aAC                   eval      trnbr = 'TR17'
413aAC                   eval      trsr50 = 'TRYPIR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     C                   iter
     C                   endif
610bD **
610bD **    Ignore slot if Virtual slots exist for it.
610bD **
610bDC**                 exsr      chkvsl
610bDC**                 if        vsfind = *on
610bDC**                 iter
610bDC**                 endif
640gD **
640gD **    Ignore slot if any item exists in slot.
640gD **
640gDC**                 exsr      chkUsage
640gDC**                 if        $uRecs > 0
640gDC**                 iter
640gDC**                 endif
640gA
640gA*     Ignore slot if no slot positions left
640gA
640gAC                   if        $pfifo = 0
640gAC                   eval      $uEntDte = today
640gAC                   else
640gAC                   eval      $uEntDte = $pfifo
640gAC                   endif
640gAC                   if        $itflgd = 'Y'
640gAC                   eval      $uExpDte = $pexpd
640gAC                   else
640gAC                   eval      $uExpDte = 0
640gAC                   endif
640gA
640gAC                   exsr      chkUsage
640gAC                   if        $uRecs >= dsposf
640gMC                   eval      trnbr = 'TR26'
640gMC                   eval      trsr50 = 'TRYFIX'
640gMC                   eval      trcode = '*RCV050 '
640gMC                   exsr      zztrck
640gAC                   iter
640gAC                   endif
640gA
640gA*     Ignore slot it contains different item
640gA
640gAC                   if        $uDiffItem = 'Y'
640gMC                   eval      trnbr = 'TR77'
640gMC                   eval      trsr50 = 'TRYFIX'
640gMC                   eval      trcode = '*RCV050 '
640gMC                   exsr      zztrck
640gAC                   iter
640gAC                   endif
640gA
640gA*     Ignore slot it contains same item with differnt dates
640gA
610gAC                   if        $uRecs > 0
640gMC                   if        $uDiffEntd = 'Y' or $uDiffExpd = 'Y'
640gMC                   eval      trnbr = 'TR30'
640gMC                   eval      trsr50 = 'TRYFIX'
640gMC                   eval      trcode = '*RCV050 '
640gMC                   exsr      zztrck
640gMC                   iter
640gMC                   endif
640gMC                   endif
610aDC**
610aDC**  Fill up slot.
610aDC**
610aDC**    If breakdown quantity exists then throw it on pallet.
610aDC**
610aDC**                 eval      found = *on
610aDC**                 eval      slrcv1 = dssqty
610aDC**                 eval      q1lft = q1lft - dssqty
610aDC**                 z-add     q2lft         slrcv2
610aDC**                 eval      q2lft = 0
610aDC**                 z-add     q3lft         slrcv3
610aDC**                 eval      q3lft = 0
610aDC**                 eval      dsslts = dsslts - 1
610aDC**
610aDC**  Save info for final post.
610aDC**
610aDC**                 eval      savdsp = sldisp
610aDC**                 eval      savq1 = slrcv1
610aDC**                 eval      savq2 = slrcv2
610aDC**                 eval      savq3 = slrcv3
610aDC**                 eval      savtie = dstie
610aDC**                 eval      savhgh = dshigh
610aDC**                 eval      savsta = slstat
610aDC**                 if        dsslts > 0
610aDC**                 eval      savlbl = dsposf
610aDC**                 else
610aDC**                 eval      savlbl = dsplts
610aDC**                 endif
610aDC**   lstlbl        add       1             x
610aDC**                 eval      slt(x) = savslt
610aDC**                 eval      lstlbl = x
610aDC**
610aDC**                 eval      pckasl = slaisl
610aDC**                 eval      prfind = *on
610aDC**
610aDC**  Update slot record.
610aDC**
610aDC**                 eval      slstat = '@R'
610aDC**                 eval      slitem = #sitem
610aDC**                 move      today         slsdte
610aDC**                 time                    slstim
610aDC**                 if        $pfifo = 0
610aDC**                 move      today         slentd
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = $pexpd
610aDC**                 if        prflag = *on                                 Reserved slot  GFG
610aDC**                 eval      slprty = -(9)                                Pick from 1st  GFG
610aDC**                 else                                                                  GFG
610aDC**                 eval      slprty = prirty
610aDC**                 endif                                                                 GFG
610aDC**                 update    s6rec
610aA
610aA*      Put qty into RCV slot.
610aA
610aAC                   eval      rcvInQty1 = dssqty
610aAC                   eval      rcvInQty2 = q2lft
610aAC                   eval      rcvInQty3 = q3lft
610aAC                   exsr      zzzRcvIn
610aAC                   eval      q1lft -= dssqty
610aAC                   eval      q2lft = 0
610aAC                   eval      q3lft = 0
610aA
413aAC                   eval      trnbr = 'TR19'
413aAC                   eval      trsr50 = 'TRYPIR'
413aAC                   eval      trcode = '*RCV050 '
413aAC                   exsr      zztrck
     *
640gAC                   eval      found = *on
     C                   leave
     *
     C                   enddo
     *
     C     endtp         endsr
     *----------------------------------------------------------------
     *
     *  UNDO    Backout of receiving because of an error.
     *
     C     undo          begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'UNDO    '    trsubr
413aAC                   exsr      zztrck
     *
     C     1             do        lstlbl        x
     C                   eval      savslt = slt(x)
411 A*
411 A*  Add label quantities to received quantities.
411 A*
411 A*  If Same Slot Breakdown Item
411 A*   Then quantities need to be changed back to the proper
411 A*        receive quantity types.
411 A*
411 AC                   if        #otype = 'S'
411 AC                   add       savq2         $prq1
411 AC                   add       savq3         $prq2
411 AC                   else
     C                   add       savq1         $prq1
     C                   add       savq2         $prq2
     C                   add       savq3         $prq3
411 AC                   endif
     C                   add       savlbl        $prpal
610aDC**
610aDC** Get slot record. Update status if necessary.
610aDC**
610aDC**                 eval      k2disp = savdsp
610aDC**   keys2         chain     slot2                              7978
610aDC**                 select
610aDC**                 when      savsta = 'V '
610aDC**                 eval      slstat = 'V '
610aDC**                 eval      slitem = *blanks
610aDC**                 eval      slrcv1 = 0
610aDC**                 if        $pfifo = 0
610aDC**                 eval      slentd = 0
610aDC**                 else
610aDC**                 eval      slentd = $pfifo
610aDC**                 endif
610aDC**                 eval      slexpd = 0
610aDC**                 eval      slsdte = 0
610aDC**                 eval      slstim = 0
610aDC**                 move      '0'           slprty
610aDC**
610aDC**                 other
610aDC**                 eval      slrcv1 = slrcv1 - savq1
610aDC**                 sub       savq2         slrcv2
610aDC**                 sub       savq3         slrcv3
610aDC**
610aDC**                 endsl
610aDC**
610aDC**                 update    s2rec
610aA
610aA*    Undo RCV slot
610aA
610aAC                   exsr      clr$slot
610aAC                   eval      $slwhseu = *on
610aAC                   eval      $slwhse  = $pwhse
610aAC                   eval      $slwhdpu = *on
610aAC                   eval      $slwhdp  = savwhdp
610aAC                   eval      $sldispu = *on
610aAC                   eval      $sldisp  = savrcvdsp
610aAC                   eval      $saitemu = *on
610aAC                   eval      $saitem  = #sitem
610aA
610aAC                   eval      $sacodeu = *on
610aAC                   eval      $sacode  = '@R'
610aAC                   eval      $samemou = *on
610aAC                   eval      $samemo  = 'RC160 - Lbl#'
610aAC                                      + %editc(savlb#:'P')
610aAC                   eval      $sabyu   = *on
730aDC*                  eval      $saby    = #curruser
730aMC                   eval      $saby    = jobuser
610aA
610aAC                   eval      $saqtyu  = *on
610aAC                   eval      $saqty1  = -(savq1)
610aAC                   eval      $saqty2  = -(savq2)
610aAC                   eval      $saqty2  = -(savq3)
610aA
610aAC                   eval      $saActionU = *on
610aAC                   eval      $saAction = 'DPT'
610aAC                   eval      $saTrn#U = *on
610aAC                   eval      $saTrn# = savtr#
610aAC                   eval      $saETrn#U = *on
610aAC                   eval      $saETrn# = 0
610aAC                   eval      $saLbl#U = *on
610aAC                   eval      $saLbl# = savlb#
610aA
610aAC                   eval      $dricommand = '*SLOT'
610aAC                   eval      $drisubcmd  = '%ADJUST'
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      ck4err = *on
610aAC                   eval      zmsflag = *on
610aAC                   exsr      zzzdricop
416dA*
416dA*     If xdock slot, tell host quantity removed from slot.
416dA*
416dAC                   if        savsta = 'XD'
610aDC**                 exsr      zzzx2d
610aAC                   exsr      clr$xdock
610aAC                   eval      $xdwhseu = *on
610aAC                   eval      $xdwhse = $pwhse
610aAC                   eval      $xditemu = *on
610aAC                   eval      $xditem = $pitem
610aAC                   eval      $xdpou = *on
610aAC                   eval      $xdpo = $ppo
610aAC                   eval      $xdseq#u = *on
610aAC                   eval      $xdseq# = $pseq
610aAC                   eval      $xdqtyu = *off
610aMC                   eval      $xdqty1 = -(savq1)
610aMC                   eval      $xdqty2 = -(savq2)
610aMC                   eval      $xdqty3 = -(savq3)
416dAC                   eval      dricmd = '*XDOCK'
416dAC                   eval      drisub = '*RECEIVE'
610aMC                   exsr      zzzdricop
416dAC                   endif
     *
     C                   enddo
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
413aA*
413aA*  Write out tracking record.
413aA*
413aAC                   eval      trcode = '*RCV040 '
413aAC                   movel     'ZMSMSG  '    trsubr
413aAC                   exsr      zztrck
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     RC16020  Everything was ok.
     *
     C     zm20          begsr
     C                   eval      #msgid = 'RC16020'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = *blanks
     *
     *     Convert string to quantities.
     *
     C                   eval      $cqty1 = $prq1
     C                   eval      $cqty2 = $prq2
     C                   eval      $cqty3 = $prq3
     C                   eval      $ccmd = '*QTY2STR'
     C                   eval      $cprg = #prog
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
     C                   eval      erqty = $cqstr
     C                   eval      erpal = $prpal
     C                   eval      eritem = $pitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
412eA*----------------------------------------------------------------
412eA*     RC16021  xxx of yyy slots assigned to fixed item.
412eA*
412eAC     zm20a         begsr
412eAC                   eval      #msgid = 'RC16021'
412eAC                   eval      #msgtp = '*DIAG  '
412eAC                   eval      errmsg = *blanks
412eAC                   eval      ersl01 = nrasgn
610aMC                   eval      ersl02 = $imnrpk
412eAC                   eval      eritm = $pitem
412eAC                   movea     errmsg        $md(1)
412eAC                   exsr      zmsmsg
412eAC                   eval      $pmsg = #msgk
412eAC                   endsr
     *----------------------------------------------------------------
     *     RC15521  Item does not exist.
     *
     C     zm21          begsr
     C                   eval      #msgid = 'RC15521'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     $pitem        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     RC15522  Tie/High definitions do not exist for item.
     *
     C     zm22          begsr
     C                   eval      #msgid = 'RC15522'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   movea     $pitem        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
416fA*----------------------------------------------------------------
416fA*     RC16022  No pick slot found for crossdock.
416fA*
416fAC     zm22a         begsr
416fAC                   eval      #msgid = 'RC16022'
416fAC                   eval      #msgtp = '*DIAG  '
416fAC                   eval      $md = *blanks
416fAC                   exsr      zmsmsg
416fAC                   eval      $pmsg = #msgk
416fAC                   endsr
500bA*----------------------------------------------------------------
500bA*     RC16023  No pick slot for Special Receive.
500bA*
500bAC     zm23a         begsr
500bAC                   eval      #msgid = 'RC16023'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   eval      $md = *blanks
500bAC                   exsr      zmsmsg
500bAC                   eval      $pmsg = #msgk
500bAC                   endsr
     *----------------------------------------------------------------
     *     RC15523  Receiving options not defined.
     *
     C     zm23          begsr
     C                   eval      #msgid = 'RC15523'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     RC15524  No slot available for put away.
     *
     C     zm24          begsr
     C                   eval      #msgid = 'RC15524'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
640iA*----------------------------------------------------------------
640iA*     RC16024  No def large enough to hold qty
640iA*
640iAC     zm24a         begsr
     C                   eval      #msgid = 'RC16024'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      errmsg = *blanks
     C                   eval      erqty24 = $pqty1
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     RC15525  Not enough slots available for put away.
     *
     C     zm25          begsr
     C                   eval      #msgid = 'RC15525'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
217 A*     RC15526  No slot available for put away in same aisle.
217 A*
217 AC     zm26          begsr
217 AC                   eval      #msgid = 'RC15526'
217 AC                   eval      #msgtp = '*DIAG  '
217 AC                   eval      $md = *blanks
217 AC                   exsr      zmsmsg
217 AC                   eval      $pmsg = #msgk
217 AC                   endsr
     *----------------------------------------------------------------
217 A*     RC15527  Not enough slots available for put away in same aisle
217 A*
217 AC     zm27          begsr
217 AC                   eval      #msgid = 'RC15527'
217 AC                   eval      #msgtp = '*DIAG  '
217 AC                   eval      $md = *blanks
217 AC                   exsr      zmsmsg
217 AC                   eval      $pmsg = #msgk
217 AC                   endsr
HMW A*
HMW A*----------------------------------------------------------------
HMW A*
HMW A*  ZZSPCLPCK  Check if JIT/Special Order Pick Slot Needs to be Created
HMW A*
HMW AC     zzspclpck     begsr
HMW A*
HMW AC                   eval      sverror  = error
HMW AC     keys3         setll     slot3
HMW AC     keys3         reade     slot3
HMW AC                   if        not %eof(slot3)
HMW A*      Item has pick slot, so leave.
HMW AC                   leavesr
HMW AC                   endif
HMW A*
HMW AC     keysl5        setll     slot5
HMW AC                   dow       forevr = forevr
HMW AC     keysl5        reade     slot5
HMW AC                   if        %eof(slot5)
HMW A*      Restore error flag back status upon entry in routine.
HMW AC                   eval      error  = sverror
HMW A*      End of slots with designation.
HMW AC                   leave
HMW AC                   endif
HMW A*
HMW AC                   if            slpick <> 'Y'
HMW AC                              or slrsrv = 'V'
HMW AC                   iter
HMW AC                   endif
HMW A*
HMW AC                   exsr      clr$slot
HMW AC                   eval      $slwhseu = *on
HMW AC                   eval      $slwhse  = $pwhse
HMW AC                   eval      $slwhdpu = *on
HMW AC                   eval      $slwhdp  = slwhdp
HMW AC                   eval      $sldispu = *on
HMW AC                   eval      $sldisp  = sldisp
HMW AC                   eval      $slitemu = *on
HMW AC                   eval      $slitem  = #sitem
HMW AC                   eval      $slaislu = *on
HMW AC                   eval      $slaisl = slaisl
HMW AC                   eval      $dricommand = '*SLOT'
HMW AC                   eval      $drisubcmd = '%CRTVPICK'
HMW AC                   eval      $drisys2upd = 'D'
HMW AC                   eval      ck4err = *on
HMW AC                   exsr      zzzdricop
HMW AC                   if        $drireturn = 'VRTPCKCRT'
HMW AC                   eval      error = '0'
HMW AC                   endif
HMW A*
HMW AC                   if        error = *on
HMW A*      Virtual slot couldn't be created. Look for next available.
HMW AC                   iter
HMW AC                   else
HMW A*      Virtual slot created. Get out.
HMW AC                   eval      error = '0'
HMW AC                   eval      $prtn = ' '
HMW AC                   leave
HMW AC                   endif
HMW A*
HMW AC                   enddo
HMW A*
HMW AC                   endsr
FPR A*
FPR A*----------------------------------------------------------------
FPR A*
FPR A*  ZZSPCLPCK_FPR  Check if Special Order Pick Slot Needs to be Created
FPR A*
FPR AC     zzspclpck_fpr begsr
FPR A*
FPR AC                   eval      sverror  = error
FPR AC     keys3         setll     slot3
FPR AC     keys3         reade     slot3
FPR AC                   if        not %eof(slot3)
FPR A*      Item has pick slot, so leave.
FPR AC                   leavesr
FPR AC                   endif
FPR A*
FPR AC     keysl5        setll     slot5
FPR AC                   dow       forevr = forevr
FPR AC     keysl5        reade     slot5
FPR AC                   if        %eof(slot5)
FPR A*      Restore error flag back status upon entry in routine.
FPR AC                   eval      error  = sverror
FPR A*      End of slots with designation.
FPR AC                   leave
FPR AC                   endif
FPR A*
FPR AC                   if            slpick <> 'Y'
FPR AC                              or slrsrv = 'V'
FPR AC                   iter
FPR AC                   endif
FPR A*
FPR AC                   exsr      clr$slot
FPR AC                   eval      $slwhseu = *on
FPR AC                   eval      $slwhse  = $pwhse
FPR AC                   eval      $slwhdpu = *on
FPR AC                   eval      $slwhdp  = slwhdp
FPR A*
FPR AC                   select
FPR AC                   when      $slwhdp = 'CLR'
FPR AC                   eval      sldisp = 'C S/O'
FPR AC                   when      $slwhdp = 'DRY'
FPR AC                   eval      sldisp = 'D S/O'
FPR AC                   when      $slwhdp = 'FRZ'
FPR AC                   eval      sldisp = 'F S/O'
FPR AC                   endsl
FPR A*
FPR AC                   eval      $sldispu = *on
FPR AC                   eval      $sldisp  = sldisp
FPR AC                   eval      $slitemu = *on
FPR AC                   eval      $slitem  = #sitem
FPR AC                   eval      $slaislu = *on
FPR AC                   eval      $slaisl = slaisl
FPR AC                   eval      $dricommand = '*SLOT'
FPR AC                   eval      $drisubcmd = '%CRTVPICK'
FPR AC                   eval      $drisys2upd = 'D'
FPR AC                   eval      ck4err = *on
FPR AC                   exsr      zzzdricop
FPR AC                   if        $drireturn = 'VRTPCKCRT'
FPR AC                   eval      error = '0'
FPR AC                   endif
FPR A*
FPR AC                   if        error = *on
FPR A*      Virtual slot couldn't be created. Look for next available.
FPR AC                   iter
FPR AC                   else
FPR A*      Virtual slot created. Get out.
FPR AC                   eval      error = '0'
FPR AC                   eval      $prtn = ' '
FPR AC                   leave
FPR AC                   endif
FPR A*
FPR AC                   enddo
FPR A*
FPR AC                   endsr
FPR A*
413aA*----------------------------------------------------------------
413aA*     ZZTRCK - Write tracking records to tracking file
413aA*
413aAC     zztrck        begsr
413aAC                   select
413aAC                   when      trcode = '*RCV001 '                          Item info
413aAC                   eval      trrcq1 = $pqty1
610aMC                   eval      truom1 = $itum1
413aAC                   eval      trrcq2 = $pqty2
610aMC                   eval      truom2 = $itum2
413aAC                   eval      trrcq3 = $pqty3
610aMC                   eval      truom3 = $itum3
413aAC                   eval      trexpd = $pexpd
610aMC                   eval      trstyp = $itstyp
610aMC                   eval      trtype = $ittype
610aMC                   eval      trwhdp = $itwhdp
610aMC                   eval      trdesg = $itdesg
610aMC                   eval      trbld = $itbld
610aMC                   eval      tractv = $itactv
610aMC                   eval      trnrpk = $imnrpk
413aAC                   eval      trpcmd = $pcmd
413aAC                   eval      trpprg = $pprg
413aAC                   eval      trven# = $pven
413aAC                   eval      trseq = $pseq
413bAC                   eval      trdstp = dstype
413aAC                   move      lvlbeg        trlbeg
413aAC                   eval      triflg = flgitm
417dD**                   MOVE #BITEM    TRBITM
417dMC                   eval      trbitm = #sitem
413aAC                   select
413aAC                   when      svrtn = '*OK     '
413aAC                   eval      trrcst = tr65
413aAC                   when      svrtn = '*INVALID'
413aAC                   eval      trrcst = tr69
413aAC                   when      svrtn = '*NODEF  '
413aAC                   eval      trrcst = tr66
413aAC                   when      svrtn = '*NOOPT  '
413aAC                   eval      trrcst = tr70
413aAC                   when      svrtn = '*NOSLOT '
413aAC                   eval      trrcst = tr67
413aAC                   when      svrtn = '*NOTENGH'
413aAC                   eval      trrcst = tr68
413aAC                   endsl
413aAC                   eval      trdata = tr01ds
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr01rec
413aA*
413aAC                   when      trcode = '*RCV002 '                          System options
413aAC                   if        flgsys = *on
413aAC                   eval      trdata = trerr
413aAC                   else
413aAC                   eval      trdata = opdat2
413aAC                   endif
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr02rec
413aA*
413aAC                   when      trcode = '*RCV003 '                          Rcv options
413aAC                   if        flgrcv = *on
413aAC                   eval      trdata = trerr
413aAC                   else
413aAC                   eval      trdata = opdata
413aAC                   endif
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr03rec
413aA*
413aAC                   when      trcode = '*RCV010 '                          Item defs
413aAC                   add       1             trsq10
413aAC     1             do        lstdef        x
413aAC     x             occur     defs
413aAC                   eval      trdt10 = defs
413aAC                   eval      trdata = tr10ds
413aAC                   eval      trsqnr = trsq10
413aAC                   write     tr10rec
413aAC                   enddo
413aAC                   eval      trcode = '*RCV011 '
413aAC                   movea(p)  ocr           trdt11
413aAC                   eval      trldef = lstdef
413aAC                   eval      trdata = tr11ds
413aAC                   write     tr11rec
413aA*
413aAC                   when      trcode = '*RCV020 '                          Activity zones
413aAC                   movea(p)  act           trdata
413aAC                   if        trdata > *blanks
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr20rec
413aAC                   endif
413aA*
413aAC                   when      trcode = '*RCV030 '                          Build codes
413aAC                   movea(p)  bld           trdata
413aAC                   if        trdata > *blanks
413aAC                   eval      trsqnr = *zeros
413aAC                   write     tr30rec
413aAC                   endif
413aA*
413aAC                   when      trcode = '*RCV040 '                          Subr entered
413aAC                   add       1             r
413aA*    Array is full, add to file and then reset array.
413aAC                   if        r > 25
413aAC                   add       1             trsq40
413aAC                   eval      trsqnr = trsq40
413aAC                   eval      trdata = tr40ds
413aAC                   write     tr40rec
413aAC                   eval      trrfld = *blanks
413aAC                   eval      r = 1
413aAC                   endif
413aAC                   eval      trr(r) = trsubr
413aA*
413aAC                   when      trcode = '*RCV050 '                          Tracking msgs
413aAC                   add       1             trsq50
413aAC                   select
413aAC                   when      trnbr = 'TR01'
610aMC                   eval      trdt50 = %trimr(tr01) + ' ' + $itbld
413aAC     trdt50        cat       tr02:1        trdt50
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR02'
413aA*
413aAC                   when      trnbr = 'TR03'
413aAC                   eval      trdt50 = tr03
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR04'
413aAC                   eval      trdt50 = tr04
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR05'
413aAC                   eval      trdt50 = tr05
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR06'
413aAC                   eval      trdt50 = tr06
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR07'
413aAC                   eval      trdt50 = tr07
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR08'
413aAC                   eval      trdt50 = tr08
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR09'
413aAC                   eval      trdt50 = tr09
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR10'
413aAC                   eval      trdt50 = %trimr(tr10) + ' ' + k6actv
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR11'
413aAC                   eval      trdt50 = %trimr(tr11) + ' ' + k7aisl
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR12'
413aAC                   eval      trdt50 = %trimr(tr12) + ' ' + k6bld
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR13'
413aAC                   eval      trdt50 = %trimr(tr13) + ' ' + k6sdef
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR14'
413aAC                   move      k7rlvl        cvt2a
413aAC                   eval      trdt50 = %trimr(tr14) + ' ' + cvt2a
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR15'
413aAC                   eval      trdt50 = %trimr(tr15) + ' ' + k7aisl
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR16'
413aAC                   eval      trdt50 = %trimr(tr16) + ' ' + cursid
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR17'
413aAC                   eval      trdt50 = %trimr(tr17) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR18'
413aAC                   eval      trdt50 = %trimr(tr18) + ' ' + sldisp
413aAC     trdt50        cat       '/':1         trdt50
413aAC     trdt50        cat       slsdef:1      trdt50
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR19'
413aAC                   eval      trdt50 = %trimr(tr19) + ' ' + sldisp
413aAC     trdt50        cat       tr20:2        trdt50
413aAC                   eval      $ccmd = '*QTY2STR'
413aAC                   eval      $cqty1 = savq1
413aAC                   eval      $cqty2 = savq2
413aAC                   eval      $cqty3 = savq3
413aAC                   eval      $cqstr = *blanks
413aAC                   exsr      zzcvqy
413aAC     trdt50        cat       $cqstr:1      trdt50
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR20'
413aAC                   eval      trdt50 = %trimr(tr20) + ' ' + ' '
413aA*
413aAC                   when      trnbr = 'TR21'
413aAC                   eval      trdt50 = %trimr(tr21) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR22'
413aAC                   eval      trdt50 = %trimr(tr41) + trkey
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   select
413aAC                   when      trkey = 'KEYCD2'
413aAC                   eval      trdt50 = tr38
413aA*
413aAC                   when      trkey = 'KEYS1D'
413aAC     trdt50        cat       'Aisl:':1     trdt50
413aAC     trdt50        cat       k1aisl:0      trdt50
413aAC     trdt50        cat       'Loc:':1      trdt50
413aAC                   move      k1loc         cvt3a
413aAC     trdt50        cat       cvt3a:0       trdt50
413aAC     trdt50        cat       'Rlvl:':1     trdt50
413aAC                   move      k1rlvl        cvt2a
413aAC     trdt50        cat       cvt2a:0       trdt50
413aA*
413aAC                   when      trkey = 'KEYS2'
413aAC     trdt50        cat       'Slot:':1     trdt50
413aAC     trdt50        cat       k2disp:0      trdt50
413aA*
413aAC                   when      trkey = 'KEYS3'
413aAC     trdt50        cat       'Stat:':1     trdt50
413aAC     trdt50        cat       k3stat:0      trdt50
413aAC     trdt50        cat       'Pick:':1     trdt50
413aAC     trdt50        cat       k3pick:1      trdt50
413aA*
413aAC                   when      trkey = 'KEYS3B'
413aAC     trdt50        cat       'Stat:':1     trdt50
413aAC     trdt50        cat       k3stat:0      trdt50
413aA*
413aAC                   when      trkey = 'KEYS6'
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aAC     trdt50        cat       'Bldc:':1     trdt50
413aAC     trdt50        cat       k6bld:0       trdt50
413aAC     trdt50        cat       'Actv:':1     trdt50
413aAC     trdt50        cat       k6actv:0      trdt50
413aAC                   if        trsr50 = 'TRYPIR'
413bAC     trdt50        cat       'Desg:':1     trdt50
413bAC     trdt50        cat       kydesg:0      trdt50
413aAC     trdt50        cat       tr39:3        trdt50
413aAC                   endif
413aA*
413aAC                   when      trkey = 'KEYS6A'
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aAC     trdt50        cat       'Bldc:':1     trdt50
413aAC     trdt50        cat       k6bld:0       trdt50
413aAC     trdt50        cat       'Actv:':1     trdt50
413aAC     trdt50        cat       k6actv:0      trdt50
413aAC     trdt50        cat       'Aisl:':1     trdt50
413aAC     trdt50        cat       k6aisl:0      trdt50
413aAC                   if        trsr50 = 'TRYPIR'
413bAC     trdt50        cat       'Desg:':1     trdt50
413bAC     trdt50        cat       kydesg:0      trdt50
413aAC     trdt50        cat       tr39:3        trdt50
413aAC                   endif
413aA*
413aAC                   when      trkey = 'KEYS6B'
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aAC     trdt50        cat       'Bldc:':1     trdt50
413aAC     trdt50        cat       k6bld:0       trdt50
413aA*
413aAC                   when      trkey = 'KEYS6C'
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aA*
413aAC                   when      trkey = 'KEYS7A'
413aAC     trdt50        cat       'Aisl:':1     trdt50
413aAC     trdt50        cat       k7aisl:0      trdt50
413aAC     trdt50        cat       'Rlvl:':1     trdt50
413aAC                   move      k7rlvl        cvt2a
413aAC     trdt50        cat       cvt2a:0       trdt50
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aAC                   if        trsr50 = 'TRYFIX'
413bAC     trdt50        cat       'Desg:':1     trdt50
413bAC     trdt50        cat       kydesg:0      trdt50
413aAC     trdt50        cat       tr39:3        trdt50
413aAC                   endif
413aA*
413aAC                   when      trkey = 'KEYS7B'
413aAC     trdt50        cat       'Aisl:':1     trdt50
413aAC     trdt50        cat       k7aisl:0      trdt50
413aAC     trdt50        cat       'Rlvl:':1     trdt50
413aAC                   move      k7rlvl        cvt2a
413aAC     trdt50        cat       cvt2a:0       trdt50
413aAC     trdt50        cat       'Sdef:':1     trdt50
413aAC     trdt50        cat       k6sdef:0      trdt50
413aAC     trdt50        cat       'Loc:':1      trdt50
413aAC                   move      k7loc         cvt3a
413aAC     trdt50        cat       cvt3a:0       trdt50
413bAC     trdt50        cat       'Desg:':1     trdt50
413bAC     trdt50        cat       kydesg:0      trdt50
413aAC                   endsl
413aA*
413aAC                   when      trnbr = 'TR23'
413aAC                   eval      trdt50 = %trimr(tr23) + ' ' + sldisp
413aAC     trdt50        cat       tr25:1        trdt50
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR24'
413aAC                   eval      trdt50 = %trimr(tr24) + ' ' + sldisp
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR25'
413aAC                   eval      trdt50 = %trimr(tr25) + ' ' + ' '
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR26'
413aAC                   eval      trdt50 = %trimr(tr26) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR27'
413aAC                   eval      trdt50 = %trimr(tr27) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR28'
413aAC                   move      putqty        cvt5a
413aAC                   eval      trdt50 = %trimr(tr28) + ' ' + cvt5a
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR29'
413aAC                   eval      trdt50 = %trimr(tr29) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR30'
413aAC                   eval      trdt50 = %trimr(tr30) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR31'
413aAC                   eval      trdt50 = %trimr(tr31) + ' ' + $pslot
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR32'
413aAC                   eval      trdt50 = %trimr(tr32) + ' ' + k2disp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR33'
413aAC                   eval      trdt50 = %trimr(tr33) + ' ' + slitem
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR34'
413aAC                   eval      trdt50 = %trimr(tr34) + ' ' + sldisp
413aAC     trdt50        cat       tr20:2        trdt50
413aAC                   eval      $ccmd = '*QTY2STR'
413aAC                   eval      $cqty1 = savq1
413aAC                   eval      $cqty2 = savq2
413aAC                   eval      $cqty3 = savq3
413aAC                   eval      $cqstr = *blanks
413aAC                   exsr      zzcvqy
413aAC     trdt50        cat       $cqstr:1      trdt50
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR35'
413aAC                   eval      trdt50 = %trimr(tr35) + ' ' + k7aisl
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR36'
413aAC                   eval      trdt50 = %trimr(tr36) + ' ' + sldisp
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR37'
413aAC                   eval      trdt50 = %trimr(tr37) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR38'
413aAC                   eval      trdt50 = tr38
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR39'
413aAC                   when      trnbr = 'TR40'
413aAC                   eval      trdt50 = tr40
413aAC                   eval      trmsgt = 'D'                                 Detail
413aA*
413aAC                   when      trnbr = 'TR43'
413aAC                   eval      trdt50 = %trimr(tr42) + ' ' + tr43
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR44'
413aAC                   eval      trdt50 = %trimr(tr42) + ' ' + tr44
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR45'
413aAC                   eval      trdt50 = %trimr(tr42) + ' ' + tr45
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR46'
413aAC                   eval      trdt50 = %trimr(tr42) + ' ' + tr46
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR47'
413aAC                   eval      trdt50 = %trimr(tr42) + ' ' + tr47
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR48'
413aAC                   eval      trdt50 = tr48
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR49'
413aAC                   eval      trdt50 = tr49
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR50'
413aAC                   eval      trdt50 = tr50
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR51'
413aAC                   eval      trdt50 = tr51
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR52'
413aAC                   eval      trdt50 = tr52
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR53'
413aAC                   eval      trdt50 = tr53
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR54'
413aAC                   eval      trdt50 = tr54
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR55'
413aAC                   eval      trdt50 = tr55
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR56'
413aAC                   eval      trdt50 = tr56
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR57'
413aAC                   eval      trdt50 = tr57
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR58'
413aAC                   eval      trdt50 = %trimr(tr58) + ' ' + sldisp
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413bAC                   when      trnbr = 'TR59'
413bAC                   eval      trdt50 = tr59
413aAC                   eval      trmsgt = 'S'                                 Summary
413bA*
413bAC                   when      trnbr = 'TR60'
413aAC                   eval      trdt50 = %trimr(tr60) + ' ' + sldisp
413aAC                   eval      trmsgt = 'D'                                 Detail
413bA*
413aAC                   when      trnbr = 'TR61'
413aAC                   eval      trdt50 = tr61
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR62'
413aAC                   eval      trdt50 = tr62
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR63'
413aAC                   eval      trdt50 = tr63
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR64'
413aAC                   eval      trdt50 = %trimr(tr64) + ' ' + sldisp
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR71'
413aAC                   eval      trdt50 = tr71
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   when      trnbr = 'TR72'
413aAC                   eval      trdt50 = tr72
413aAC                   move      nrshrt        cvt3a
413aAC     trdt50        cat       cvt3a:1       trdt50
413aAC                   eval      trmsgt = 'S'                                 Summary
413aA*
413aAC                   endsl
413aA*
413aAC                   eval      trdata = tr50ds
413aAC                   eval      trmsgn = trnbr
413aAC                   eval      trsqnr = trsq50
413aAC                   write     tr50rec
413aAC                   endsl
413aAC                   endsr
413aA*----------------------------------------------------------------
413aA*     ZZCVQY - Convert receive qty's to string for msg display
413aA*
413aAC     zzcvqy        begsr
413aAC                   call      'CVTQTY'
413aAC                   parm                    $ccmd
413aAC                   parm                    $cprg
413aAC                   parm                    $cqty1
413aAC                   parm                    $cqty2
413aAC                   parm                    $cqty3
413aAC                   parm                    $cum1
413aAC                   parm                    $cum2
413aAC                   parm                    $cum3
413aAC                   parm                    $cqstr
413aAC                   parm                    $custr
413aAC                   parm                    $crtn
413aAC                   parm                    $cerm
413aAC                   endsr
416bA*----------------------------------------------------------------
416bA*     ZZZCOP - Call realtime interface.
416bA*
416bAC     zzzcop        begsr
416eA*
416eA*  Write out tracking record.
416eA*
416eAC                   eval      trcode = '*RCV040 '
416eAC                   movel     'ZZZCOP  '    trsubr
416eAC                   exsr      zztrck
416eA*
     C                   eval      error = *off
     *
416cAC                   select
416cAC                   when      dricmd = '*SLOT'
416cAC                   eval      drisys = 'D'
     C                   movel     $slot         dridt1
     C                   move      $slot         dridt2
     *
416cAC                   when      dricmd = '*XDOCK'
416cAC                   eval      drisys = 'H'
416cAC                   movel     $xdock        dridt1
416cAC                   move      $xdock        dridt2
416cAC                   eval      drirtn = *blanks
416cAC                   eval      ck4err = *off
416cAC                   endsl
     *
     C                   call      'DRICOPL'
416cMC                   parm                    dricmd           10
     C                   parm                    drisub           10
416cMC                   parm                    drisys            1
     C                   parm      #prog         dripgm           10
     C                   parm                    drirtn           10
     C                   parm      ' '           drimsg           60
     C                   parm                    dridt1          256
     C                   parm                    dridt2          256
     *
416cAC                   select
416cAC                   when      dricmd = '*SLOT'
     C                   movel     dridt1        $slot
     C                   move      dridt2        $slot
416cAC                   when      dricmd = '*XDOCK'
     C                   movel     dridt1        $xdock
     C                   move      dridt2        $xdock
416cAC                   endsl
     *
416cAC                   if        ck4err = *on  and
416cAC                             drirtn <> '*OK'
416cAC                   eval      error = *on
416cAC                   endif
     *
416cAC                   eval      ck4err = *off
416bAC                   endsr
FPRaA*
FPRaA*----------------------------------------------------------------
FPRaA*     ZZZS2D - Copy slot fields into data structure fields.
FPRaA*
FPRaAC     zzzs2d        begsr
FPRaA*
FPRaAC                   eval      $slwhseu = *on
FPRaAC                   eval      $slwhse = slwhse
FPRaA*
FPRaAC                   eval      $slwhdpu = *on
FPRaAC                   eval      $slwhdp = slwhdp
FPRaA*
FPRaAC                   eval      $sldispu = *on
FPRaAC                   eval      $sldisp = sldisp
FPRaA*
FPRaAC                   eval      $slaislu = *on
FPRaAC                   eval      $slaisl = slaisl
FPRaA*
FPRaAC                   eval      $sllocu = *on
FPRaAC                   eval      $slloc = slloc
FPRaA*
FPRaAC                   eval      $slrlvlu = *on
FPRaAC                   eval      $slrlvl = slrlvl
FPRaA*
FPRaAC                   eval      $slhandu = *on
FPRaAC                   eval      $slhand = slhand
FPRaA*
FPRaAC                   eval      $slsideu = *off
FPRaAC                   eval      $slside = slside
FPRaA*
FPRaAC                   eval      $slstypu = *off
FPRaAC                   eval      $slstyp = slstyp
FPRaA*
FPRaAC                   eval      $slstatu = *off
FPRaAC                   eval      $slstat = slstat
FPRaA*
FPRaAC                   eval      $slsdteu = *off
FPRaAC                   eval      $slsdte = slsdte
FPRaA*
FPRaAC                   eval      $slstimu = *off
FPRaAC                   eval      $slstim = slstim
FPRaA*
FPRaAC                   eval      $slsdefu = *off
FPRaAC                   eval      $slsdef = slsdef
FPRaA*
FPRaAC                   eval      $sldesgu = *off
FPRaAC                   eval      $sldesg = sldesg
FPRaA*
FPRaAC                   eval      $slactvu = *off
FPRaAC                   eval      $slactv = slactv
FPRaA*
FPRaAC                   eval      $slbldu = *off
FPRaAC                   eval      $slbld = slbld
FPRaA*
FPRaAC                   eval      $slpicku = *off
FPRaAC                   eval      $slpick = slpick
FPRaA*
FPRaAC                   eval      $slpsequ = *off
FPRaAC                   eval      $slpseq = slpseq
FPRaA*
FPRaAC                   eval      $slprtyu = *off
FPRaAC                   eval      $slprty = slprty
FPRaA*
FPRaAC                   eval      $slentdu = *off
FPRaAC                   eval      $slentd = slentd
FPRaA*
FPRaAC                   eval      $slexpdu = *off
FPRaAC                   eval      $slexpd = slexpd
FPRaA*
FPRaAC                   eval      $slslfdu = *off
FPRaAC                   eval      $slslfd = slslfd
FPRaA*
FPRaAC                   eval      $slrsrvu = *off
FPRaAC                   eval      $slrsrv = slrsrv
FPRaA*
FPRaAC                   eval      $slitemu = *off
FPRaAC                   eval      $slitem = slitem
FPRaA*
FPRaAC                   eval      $slstk1 = slstk1
FPRaAC                   eval      $slstk2 = slstk2
FPRaAC                   eval      $slstk3 = slstk3
FPRaAC                   eval      $slalc1 = slalc1
FPRaAC                   eval      $slalc2 = slalc2
FPRaAC                   eval      $slalc3 = slalc3
FPRaAC                   eval      $sltfr1 = sltfr1
FPRaAC                   eval      $sltfr2 = sltfr2
FPRaAC                   eval      $sltfr3 = sltfr3
FPRaAC                   eval      $slpck1 = slpck1
FPRaAC                   eval      $slpck2 = slpck2
FPRaAC                   eval      $slpck3 = slpck3
FPRaAC                   eval      $slrcv1 = slrcv1
FPRaAC                   eval      $slrcv2 = slrcv2
FPRaAC                   eval      $slrcv3 = slrcv3
FPRaAC                   eval      $slphy1 = 0
FPRaAC                   eval      $slphy2 = 0
FPRaAC                   eval      $slphy3 = 0
FPRaAC                   eval      $slavl1 = 0
FPRaAC                   eval      $slavl2 = 0
FPRaAC                   eval      $slavl3 = 0
FPRaAC                   eval      $sladj1 = 0
FPRaAC                   eval      $sladj2 = 0
FPRaAC                   eval      $sladj3 = 0
FPRaA*
FPRaAC                   eval      $saitemu = *off
FPRaAC                   eval      $saitem = *blanks
FPRaA*
FPRaAC                   eval      $saqtyu = *off
FPRaAC                   eval      $saqty1 = 0
FPRaAC                   eval      $saqty2 = 0
FPRaAC                   eval      $saqty3 = 0
FPRaA*
FPRaAC                   eval      $saorgu = *off
FPRaAC                   eval      $saorg1 = 0
FPRaAC                   eval      $saorg2 = 0
FPRaAC                   eval      $saorg3 = 0
FPRaA*
FPRaAC                   eval      $sacwtau = *off
FPRaAC                   eval      $sacwta = 0
FPRaA*
FPRaAC                   eval      $sacodeu = *off
FPRaAC                   eval      $sacode = *blanks
FPRaA*
FPRaAC                   eval      $samemou = *off
FPRaAC                   eval      $samemo = *blanks
FPRaA*
FPRaAC                   eval      $sabyu = *off
FPRaAC                   eval      $saby = *blanks
FPRaA*
FPRaAC                   eval      $sadateu = *off
FPRaAC                   eval      $sadate = 0
FPRaA*
FPRaAC                   eval      $satimeu = *off
FPRaAC                   eval      $satime = 0
FPRaA*
FPRaAC                   eval      $saFrmVrfyu = *off
FPRaAC                   eval      $saFrmVrfy = *blanks
FPRaA*
FPRaAC                   eval      $satrn#u = *off
FPRaAC                   eval      $satrn# = 0
FPRaA*
FPRaAC                   eval      $saFrmLcnsu = *off
FPRaAC                   eval      $saFrmLcns = *blanks
FPRaA*
FPRaAC                   eval      $satasku = *off
FPRaAC                   eval      $satask = *blanks
FPRaA*
FPRaAC                   eval      $sacdspu = *off
FPRaAC                   eval      $sacdsp = *blanks
FPRaA*
FPRaAC                   endsr

610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------
610aA*                     DRI SUBROUTINES
610aA*----------------------------------------------------------------
610aA*----------------------------------------------------------------

610aA*----------------------------------------------------------------
610aA*  clr$item  Clear $item data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
     C                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$license  Clear $license data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = $emp#
730aDC*                  eval      $liuser = #curruser
730aMC                   eval      $liuser = jobuser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = $pwhse
     C                   eval      $liTowhseu = *on
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$slot  Clear $slot data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = $emp#
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  clr$xdock  Clear $xdock data structure fields
610aA*----------------------------------------------------------------
610aA
610aAC     clr$xdock     begsr
     C                   eval      savever# = $slver#
     C                   clear                   $xdock
     C                   eval      $slver# = savever#
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  zzzdricop  Call DRICOP
610aA*----------------------------------------------------------------
610aA
610aAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $dridata = $xdock
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $dridata = $licinfo
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $dridata = $license
     C                   eval      $dridata2 = $license2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
     C                             or $dricommand = '*SLOT'
     C                             or $dricommand = '*LICENSE'
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

     C                   when      %error and ck4err = *on
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #pgm
     C                   select
     C                   when      zmsflag
     C***                exsr      zm0105s
     C                   when      zmflag
     C***                exsr      zm0105
     C                   endsl

     C                   when      $drireturn <> '*OK' and ck4err = *on
     C                   eval      error = *on
     C                   select
     C                   when      zmsflag
     C***                exsr      zm0001s
     C                   when      zmflag
     C***                exsr      zm0001
     C*                  exsr      zzerrind
     C                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*XDOCK'
     C                   eval      $xdock = $dridata
     C                   when      $dricommand = '*LICINFO'
     C                   eval      $licinfo = $dridata
     C                   when      $dricommand = '*LICENSE'
     C                   eval      $license = $dridata
     C                   eval      $license2 = $dridata2
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      ck4err = *off
     C     enddricop     endsr

610aA*----------------------------------------------------------------
610aA*  zzzRcvIn   Create RCV slot for putaway
610aA*----------------------------------------------------------------
610aA
610aAC     zzzRcvIn      begsr

     *  Loop once for each qty

     C                   for       i = 1 to 3

     *    Loop until we run out of qty

     C                   dow       i = 1 and rcvInQty1 > 0
     C                             or i = 2 and rcvInQty2 > 0
     C                             or i = 3 and rcvInQty3 > 0

     *      Get transaction and label numbers

     C                   call      'PIRTRN#'
     C                   parm                    rcvInTrn#

     C                   call      'PIRLBL#'
     C                   parm                    rcvInLbl#

     *      Create RCV slot for qty.

     C                   eval      rcvInArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = slwhdp
     C                   eval      $slitemu = *on
     C                   if        #otype = 'S'
     C                   eval      $slitem  = #sitem
     C                   else
     C                   eval      $slitem  = #oitem
     C                   endif
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = slstyp
     C                   if        $pfifo > 0
     C                   eval      $slentdu = *on
     C                   eval      $slentd = $pfifo
     C                   endif
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $slprtyu = *on
     C                   eval      $slprty = prirty
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   select

     C                   when      i = 1
     C                   if        rcvInQty1 < dspqty
     C                             or forceOnePallet
     C                   eval      $saqty1 = rcvInQty1
     C                   else
     C                   eval      $saqty1 = dspqty
     C                   endif
     C                   eval      #rcvQty1 = $saqty1
     C                   eval      rcvInQty1 -= $saqty1
     C                   if        #otype = 'S'
     C                   eval      $saqty2 = rcvInQty2
     C                   eval      #rcvQty2 = $saqty2
     C                   eval      rcvInQty2 = 0
     C                   endif

     C                   when      i = 2
     C                   eval      $saqty2 = rcvInQty2
     C                   eval      #rcvQty2 = $saqty2
     C                   eval      rcvInQty2 = 0

     C                   when      i = 3
     C                   eval      $saqty3 = rcvInQty3
     C                   eval      #rcvQty3 = $saqty3
     C                   eval      rcvInQty3 = 0

     C                   endsl

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'DPT'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = rcvInTrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = rcvInLbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*DP'
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = rcvInArea

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Create corresponding License record

     C     keyLI         chain(e)  license
     C                   if        not %found
     C                   eval      liwhse = $pwhse
     C                   eval      lilcns = $saToLcns
     C                   eval      litrn# = rcvInTrn#
     C                   write     lirec
     C                   else
     C                   eval      litrn# = rcvInTrn#
     C                   update    lirec
     C                   endif

     *      Save slot information

     C                   eval      savdsp = sldisp
     C                   eval      savwhdp = slwhdp
     C                   eval      savaisl = slaisl
     C                   eval      savloc = slloc
     C                   eval      savlvl = slrlvl
     C                   eval      savhand = slhand
     C                   eval      savstyp = slstyp
     C                   eval      savrcvdsp = $sldisp
     C                   eval      savrcvaisl = $slaisl
     C                   eval      savrcvloc = $slloc
     C                   eval      savrcvlvl = $slrlvl
     C                   eval      savrcvhand = $slhand
     C                   eval      savrcvpseq = $slpseq

     C                   eval      savq1 = 0
     C                   eval      savq2 = 0
     C                   eval      savq3 = 0

     C                   select

     C                   when      i = 1
     C                   if        #otype = 'S'
     C                   eval      savq1 = (#rcvQty1*$itumq2) + #rcvQty2
     C                   else
     C                   eval      savq1 = #rcvQty1
     C                   endif

     C                   when      i = 2
     C                   eval      savq2 = #rcvQty2

     C                   when      i = 3
     C                   if        #otype = 'S'
     C                   eval      savq2 = #rcvQty3
     C                   else
     C                   eval      savq3 = #rcvQty3
     C                   endif

     C                   endsl

     C                   if        savas2 = 'XDK'
     C                   eval      savtie = 0
     C                   eval      savhgh = 0
     C                   else
     C                   eval      savtie = dstie
     C                   eval      savhgh = dshigh
     C                   endif
     C                   eval      savsta = $slstat
     C                   eval      savtr# = rcvInTrn#
     C                   eval      savlb# = rcvInLbl#
     C                   eval      savlbl = 1
     C     lstlbl        add       1             x
     C                   eval      slt(x) = savslt
     C                   eval      lstlbl = x

     C                   enddo

     C                   endfor

     C                   eval      forceOnePallet = *off
     C                   endsr

610aA*----------------------------------------------------------------
610aA*  zzzRcvInSpcl   Put directly into Pick slot
610aA*----------------------------------------------------------------
610aA
610aAC     zzzRcvInSpcl  begsr

650cM*    Loop once for each qty

650cMC                   for       i = 1 to 3

650cMC                   if        i = 1 and rcvInQty1 = 0
650cMC                             or i = 2 and rcvInQty2 = 0
650cMC                             or i = 3 and rcvInQty3 = 0
650cMC                   iter
650cMC                   endif
     *  Get transaction and label numbers

     C                   call      'PIRTRN#'
     C                   parm                    rcvInTrn#

     C                   call      'PIRLBL#'
     C                   parm                    rcvInLbl#

     *  Create RCV slot for qty.

     C                   eval      rcvInArea = 'DOCK'

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = slwhdp
     C                   eval      $slitemu = *on
     C                   if        #otype = 'S'
     C                   eval      $slitem  = #sitem
     C                   else
     C                   eval      $slitem  = #oitem
     C                   endif
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = slstyp
     C                   if        $pfifo > 0
     C                   eval      $slentdu = *on
     C                   eval      $slentd = $pfifo
     C                   endif
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = $pexpd
     C                   eval      $slprtyu = *on
     C                   eval      $slprty = prirty
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $slitem

     C                   eval      $saqtyu = *on
650cAC                   eval      $saqty1 = 0
650cAC                   eval      $saqty2 = 0
650cAC                   eval      $saqty3 = 0

650cAC                   select

650cAC                   when      i = 1
650cAC                   eval      $saqty1 = rcvInQty1
650cAC                   eval      #rcvQty1 = $saqty1
650cAC                   eval      rcvInQty1 -= $saqty1
650cAC                   if        #otype = 'S'
650cAC                   eval      $saqty2 = rcvInQty2
650cAC                   eval      #rcvQty2 = $saqty2
650cAC                   eval      rcvInQty2 = 0
650cAC                   endif

650cAC                   when      i = 2
650cAC                   eval      $saqty2 = rcvInQty2
650cAC                   eval      #rcvQty2 = $saqty2
650cAC                   eval      rcvInQty2 = 0

650cAC                   when      i = 3
650cAC                   eval      $saqty3 = rcvInQty3
650cAC                   eval      #rcvQty3 = $saqty3
650cAC                   eval      rcvInQty3 = 0

650cAC                   endsl
650cDC*                  eval      $saqty1 = rcvInQty1
650cDC*                  eval      $saqty2 = rcvInQty2
650cDC*                  eval      $saqty3 = rcvInQty3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'DPT'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = rcvInTrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = rcvInLbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*DP'
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = rcvInArea

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%RCVIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   eval      #rcvdisp = $sldisp
     C                   eval      #rcvlcns = $saToLcns
     C                   eval      #rcvQty1 = $saqty1
     C                   eval      #rcvQty2 = $saqty2
     C                   eval      #rcvQty3 = $saqty3

     *  Transfer into USR slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = slwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #rcvdisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #sitem

     C                   eval      $saqtyu = *on
650cDC*                  eval      $saqty1 = rcvInQty1
650cDC*                  eval      $saqty2 = rcvInQty2
650cDC*                  eval      $saqty3 = rcvInQty3

650cMC                   eval      $saqty1 = #rcvQty1
650cMC                   eval      $saqty2 = #rcvQty2
650cMC                   eval      $saqty3 = #rcvQty3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'DPT'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = rcvInTrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = rcvInLbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = #rcvLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'U'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'User'
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = #rcvLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%TFR2USR'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   eval      #usrdisp = $sldisp

     *  Transfer from USR slot into Pick slot

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = slwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = slwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = sldisp
     C                   eval      $sacwhdu = *on
     C                   eval      $sacwhd  = slwhdp
     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp  = #usrDisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = #sitem

     C                   eval      $saqtyu = *on
650cDC*                  eval      $saqty1 = rcvInQty1
650cDC*                  eval      $saqty2 = rcvInQty2
650cDC*                  eval      $saqty3 = rcvInQty3

650cMC                   eval      $saqty1 = #rcvQty1
650cMC                   eval      $saqty2 = #rcvQty2
650cMC                   eval      $saqty3 = #rcvQty3

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'DPT'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = rcvInTrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = rcvInLbl#
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = #rcvLcns
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'S'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = 'Slot'
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = #rcvLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      ck4err = *on
     C                   eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *  Create corresponding License record

     C     keyLI         chain(e)  license
     C                   if        not %found
     C                   eval      liwhse = $pwhse
     C                   eval      lilcns = $saToLcns
     C                   eval      litrn# = rcvInTrn#
     C                   write     lirec
     C                   else
     C                   eval      litrn# = rcvInTrn#
     C                   update    lirec
     C                   endif

     *  Save slot information

650cDC*                  if        #otype = 'S'
650cDC*                  eval      #rcvQty1 = (rcvInQty1*$itumq2) + rcvInQty2
650cDC*                  eval      #rcvQty2 = rcvInQty3
650cDC*                  eval      #rcvQty3 = 0
650cDC*                  else
650cDC*                  eval      #rcvQty1 = rcvInQty1
650cDC*                  eval      #rcvQty2 = rcvInQty2
650cDC*                  eval      #rcvQty3 = rcvInQty3
650cDC*                  endif

     *    Loop once for each qty

650cDC*                  for       i = 1 to 3

650cDC*                  if        i = 1 and #rcvQty1 = 0
650cDC*                            or i = 2 and #rcvQty2 = 0
650cDC*                            or i = 3 and #rcvQty3 = 0
650cDC*                  iter
650cDC*                  endif

     C                   eval      savdsp = sldisp
     C                   eval      savwhdp = slwhdp
     C                   eval      savaisl = slaisl
     C                   eval      savloc = slloc
     C                   eval      savlvl = slrlvl
     C                   eval      savhand = slhand
     C                   eval      savstyp = slstyp
     C                   eval      savrcvdsp = $sldisp
     C                   eval      savrcvaisl = $slaisl
     C                   eval      savrcvloc = $slloc
     C                   eval      savrcvlvl = $slrlvl
     C                   eval      savrcvhand = $slhand
     C                   eval      savrcvpseq = $slpseq

     C                   eval      savq1 = 0
     C                   eval      savq2 = 0
     C                   eval      savq3 = 0

     C                   select
     C                   when      i = 1
650cAC                   if        #otype = 'S'
650cAC                   eval      savq1 = (#rcvQty1*$itumq2) + #rcvQty2
650cAC                   else
     C                   eval      savq1 = #rcvQty1
650cAC                   endif
     C                   when      i = 2
     C                   eval      savq2 = #rcvQty2
     C                   when      i = 3
650cAC                   if        #otype = 'S'
650cAC                   eval      savq2 = #rcvQty3
650cAC                   else
     C                   eval      savq3 = #rcvQty3
650cAC                   endif
     C                   endsl

     C                   if        savas2 = 'XDK'
     C                   eval      savtie = 0
     C                   eval      savhgh = 0
     C                   else
     C                   eval      savtie = dstie
     C                   eval      savhgh = dshigh
     C                   endif
     C                   eval      savsta = $slstat
     C                   eval      savtr# = rcvInTrn#
     C                   eval      savlb# = rcvInLbl#
     C                   eval      savlbl = 1
     C     lstlbl        add       1             x
     C                   eval      slt(x) = savslt
     C                   eval      lstlbl = x

     C                   endfor

     C                   endsr
