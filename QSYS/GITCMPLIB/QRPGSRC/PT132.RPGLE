520dA /COPY *libl/qcopysrc,hspecs
520dDH*COPYRIGHT('(c) Copyright BFC Software, Inc - 2006')
520dDH*OPTION(*NODEBUGIO)

     *****************************************************************
     * TEMP CHANGES MADE REMOVING W6ORSQ STUFF. MARKED with TMP.
     *****************************************************************

     *----------------------------------------------------------------
     *   Copyright (C) 2006 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT132     Close transaction
     *  12 October 1994
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
414aA*    04/19/00  MLB  4.14a
     *      - Revised ZZCH10 to check warehouse available qty to make
     *        sure closing a replenishment will not leave a negative qty
     *        or take qty allocated to a contract item.
     *      - Added new error message routine ZM3209.
414bA*    05/04/00  MLB  4.14b
     *      - Revised ZZPICK, ZZPCKB to not flag an error when unable
     *        to update the slot record for any item type that is
     *        being closed to zero.
     *      - Revised ZZUPDP, ZZUPPQ to seton 70 if error updating
     *        SLREC.
414cA*    08/02/00  MLB  4.14c
     *      - Revised ZZINZ2 to support new standard task code REPLTF.
     *        Revised ZZPICK to support new standard task code REPLTF.
     *        Revised ZZUPDP to not change status of slot if task code
     *        is REPLTF and from slot & to slot are the same.
414dA*    08/12/00  DAS  4.14d
     *      - Deleted lines that prevented catchweight check for
     *        *CLOSE.
     *
414eA*    08/18/00  DAS  4.14e
     *      - Added command *VRFYCW to verify that catchweights have
     *        been correctly entered BEFORE closing transaction.
414fA*    09/16/00  DAS  4.14f
     *      - Revised format to be opened within program only when
     *        program has been called interactively. This was
     *        necessary because of FTP Host Picked Will Calls. To the
     *        system an FTP job looks like a batch job. When Host
     *        Picked Will Calls calls this program to automatically
     *        close the transactions, it blew up when it tried to
     *        open the screen format as part of a batch job.
414gA*    09/18/00  DAS  4.14g
     *      - Created new routine ZZUP6A to close a *FIXED or *PIR
     *        transaction when program is being run in batch mode.
     *      - Revised routine ZZINZ2 to call ZZUP6A instead of
     *        ZZUPD6 when program is being run in batch mode.
     *
415aA*    12/01/00  MLB  4.15a
     *      - Revised ZZUPDP to condition error test to not flag an
     *        error if available qty in from slot is negative when
     *        calling Secularism LT105. LT105 performs this test prior
     *        to calling this program.
415bA*    01/07/01  MLB  4.15b
     *      - Revised ZZCH10 to condition error test to not flag an
     *        error when calling program is LT105.
415cA*    06/04/01  MLB  4.15c
     *      - Revised ZZUPD2, ZZUPD3, ZZUPD4 and ZZUPD6 to not call
     *        catchweight entry programs when running in batch mode.
415dA*    06/04/01  MLB  4.15d
     *      - Revised program to retrieve *FEATURE options.
     *      - Revised ZZCHK5 to only check available qty when running
     *        full sytem. Ignore when user is on Locator System.
415eA*    06/05/01  DAS  4.15e
     *      - Revised ZZUPDP routine to allow closing transaction
     *        even if slot does not have enough quantity.
     *      - Revised to create zero adjustment for above situation.
     *        Adjustment code comes from *CLOSE option record and
     *        field OPNSCD. Memo field will contain rteid and lbl#.
     *      - Revised to fill in adjustment memo field when adjustment
     *        is created for and OUT that was picked.
     *      - Revised to get today's date in ZZINZ2 instead of ZZINZ.
415fA*    06/12/01  RH   4.15f
     *      - Revised ZZCHK6 to calculate Max quantity that can be
     *        entered for the range.
415gA*      - Revised ZZCHK2, ZZHCK3, ZZCHK4 to calcualte Max
     *        quantity that can be entered for the range.
     *
415iA*    06/20/01  HNK  4.15i
     *      - Revised to treat '***'(in LWASL2 field) as 'OUT' label.
     *        This is for the clients who would be using truck builder
     *        without picking on BFC side.
415JA*    06/26/01  RH   4.15J
     *      - Add Item # to screen 5.
     *
415kA*    07/18/01  DAS  4.15k
     *      - Created routine ZZZDTE to get today's date.
     *      - Revised every place that used TODAY to see if time went
     *        past midnight. If it did, ZZZDTE is called.
     *
415lA*    07/20/01  DAS  4.15l
     *      - Added logic to write label adjustment record when
     *        adjustment record is created for OUT record.
     *
416 A*    10/16/01  MLB  4.16
     *      - Added logic to check if user can change qty on return
     *        transaction.  If user is allowed to change qty, then
     *        the ORRTN file will be updated accordingly.
     *      - Added new optionds rcd: *RETURNS.
416aA*    10/17/01  RH   4.16a
     *      - Allow the transactions to close with a negative available
     *        quantity after transfer.
     *        Ex: Pick slot = -10 , Transfer = 6, Avail = -4.
416bA*    11/01/01  RH   4.16b
     *      - Process Return with no putaway (no slot or itemqty update
     *      - ORRTN file changed.
416cA*    01/29/02  MLB  4.16c
     *      - Add tracking support for closing pick transactions.
416dA*    01/29/02  HNK  4.16d
     *      - Fix label read loop for transfers. Read only records
     *        with status 'P'.
     *
416eA*    03/28/02  MLB  4.16e
     *      - Correction to 416c mod to prevent exception records
     *        from being duplicated.
     *
416fA*    04/10/02  DAS  4.16f
     *      - Revised 'OUT' logic. If OUT label has an associated pick
     *        slot then reduce the stock quantity of that slot, thus
     *        letting it go negative. Otherwise, create adjustment.
     *
416gA*    03/12/02  RH   4.16g
    A*      - File ORDSLCT changed, Re-compile only.
     *
416hA*    04/19/02  RH   4.16h
    A*      - Reverse 416d changes for transfers.
    A*      - Skip error check in ZZCHK5 for transfers.
    A*      - Read 2nd label record for transfers to process brk qty.
     *
416iA*    04/23/02  RH   4.16i
     *      - Check option OPEADJ to close outs without adjustments,
     *        allows slots to go negative.
     *
416jA*    05/23/02  RRH  4.16j
     *      - Change W8LCN# to 15 Alphanumeric.
     *
416kA*    05/30/02  HNK  4.16k
     *      - Skip label type 'A' for Catch weight entry.
     *
416lA*    01/22/02  DAS  4.16l
     *      - Major revision to use DRI interface programs.
     *      - Added necessary D-specs.
     *      - Added ZZZ routines.
     *      - Rewrote ZZITEM routine.
     *      - Revised ZZUPDR to utilize interface.
     *
416mA*    10/31/02  DAS  4.16m
     *      - Revised ZZUPDW to initialize $AQTY's
416nA*    11/11/02  MLB  4.16n
     *      - Fix: Revised ZZINZ2 to loop looking for more customer
     *        return label records to close. Used same logic from
     *        receiving put-away.
     *      - Fix: Revised ZZUPD9. Correction to 4.16 mod to not
     *        write out record to ORRTN file when return put-aways
     *        are closed. When doing put-aways via RC200 (RF) user
     *        cannot change qty. Variance record was being written
     *        to ORRTN file in error.
416oA*    12/12/02  MLB  4.16o
     *      - Fix: Revised size of variable MXQTY to 7,0 from 5,0.
     *
416pA*    06/11/03  DAS  4.16p
     *      - C#ITEM revised to have two data structures, $item and $item2.
     *      - Revised program to work with second data structure.
     *
417 A*    05/02/03  MLB  4.17
     *      - Enh: Revised ZZINZ2 to process bulk picks using SCREEN 6
     *        instead of SCREEN 2 and SCREEN 3. This is being done be-
     *        cause bulk picks now support multiple label records.
417aA*    08/07/02  MLB  4.17a
     *      - Fix: Revised ZZCHK2, ZZCHK3, ZZCHK4 to load LBQALC for
     *        MXQTY when LBQPCK is zero. Original change was missed in V416
417bA*    08/07/03  MLB  4.17b
     *      - Fix: Revised ZZFIL6 to omit any record where LBVRFY = '0'.
     *        Item was outed in allocate and/or pick processing.
     *      - Fix: Revised ZZFIL6 to reverse image W6DISP for 'OUT'
     *        label records.
417cA*    08/14/03  DAS  4.17c
     *      - Fix: Revised ZZFIL6 to omit any record where LBTYPE = 'A'.
417dA*    11/26/03  MLB  4.17d
     *      - Enh: Revised pgm to initialize employee number when closing
     *        Open Letdown transactions called from PT170A.
417eA*    12/17/03  MLB  4.17e
     *      - Enh: Revised pgm to loop when closing REPL, REPLBK trans-
     *        actions. With Pushback/Eaches replenishments, REPL, REPLBK
     *        tasks will have multiple LABEL records attached.
417fA*    12/17/03  RH   4.17f
     *      - Enh: Don't allow pick trans to close if multiple trans  -
     *             is still open.                                     -
417gA*    01/15/04  HNK  4.17g
     *      - ENH: Don't allow pick trans to close if flags (shorts)
     *        exists for this transaction (LBVRFY='F')
     *      - ENH: Blank out LBVRFY if qty changed on screen 6.
     *             Display flag if LBVRFY='F'
417hA*    02/04/04  DAS  4.17h
     *      - ENH: Revised new check loop in ZZCMD6 to leave for eof.
417iA*    02/16/04  HNK  4.17i
     *      - ENH: Revised to clear flag when cursor is on subfile
     *             line and F7 is pressed.
417jA*    03/22/04  DAS/MLB  4.17j
     *      - Fix: Removed D-Specs for #bumq2/3.
     *        Already defined when calling GETBASE.
417kA*    04/30/04  MLB  4.17k
     *      - Enh: Added item number, description and license plate
     *        to screen 9 - Customer Returns.
417lA*    07/07/04  RH   4.17l
     *      - Enh: Added position to label # to Screen 6
417mA*    08/10/04  RH   4.17m
     *      - Fix: Add call to GETSLOTITM to get the item for a
     *        alias item for a SSB item.
417nA*    08/12/04  RH   4.17n
     *      - Fix: Add code to update ORDD qty correctly for alias
     *        same slot breakdown item.
417oA*    08/16/04  MLB  4.17o
     *      - Fix: Revise start/end positions for field OPEADJ in
     *        *GENPICK data structure.
417pA*    08/18/04  RH   4.17p
     *      - Fix: Change ZZCHK5 to skip check for min qty to replenish
     *        LT105 already allows a user to close a letdown to 0.
417qA*    08/19/04  MLB  4.17q
     *      - ENH: Revised 4.17g mod to not allow pick trans to close
     *        if LBVRFY = 'F' or 'I'. If LBVRFY is 'I', this means
     *        inventory control has to try and find item. This gives
     *        3 chances to try and find missing product before outing
     *        or shorting item. Qty changes are not allowed if item
     *        is flagged with 'F'.
     *      - Added file RUNNER to pgm.
417rA*    08/25/04  RH   4.17r
     *      - FIX: PIRTRAN record was locked and caused error if
     *        transaction was still being selected by voice user.
     *        Record was locked in ZZGET1 for use if LBITEM=*PIRPICK
     *        This is no longer used.  Changed to not lock record.
     *
500 A*    12/10/04  MLB  5.00
     *      - Fix: Revised ZZPICK to not clear LBVRFY flag for label
     *        type 'O' unless qty changed.
500bA*    01/06/04  MLB  5.00b
     *      - Enh: Revised ZZPICK to add one more condition when
     *        LBVRFY can be cleared; LBVRFY = 'I'. When qty changes,
     *        3rd attempt to find item has been completed.
500cA*    05/10/05  HNK/MLB 5.00c
     *      - Enh: Revised ZZPICK to update LBVRFY with a "T" instead
     *             of " ".
500dA*    07/11/05  MLB 5.00d
     *      - Enh: Revised program to add support for new Flag Types
     *        and update record tests.
     *      - Removed file RUNNER from program. Replaced with call to
     *        RU300.
500eA*    07/18/05  MLB  5.00e
     *      - Fix: Revised ZZPOS6 to not clear POSREC field. This was
     *        causing a terminal display error when a invalid label
     *        number was keyed by the user.
500fA*    11/03/05  RH   5.00f
     *      - Enh: Add Client support for client id
500gA*    12/06/05  RLP  5.00g
     *      - Enh: Slight revision to 4.17d mod, initialize PTSDTE,
     *             PTSTIM with current DATE/TIME when calling pgm is
     *             PT170A. This was done to correct a situation where
     *             bad times were being calc for PTDMIN. Required
     *             moving existing 4.17d code to BEFORE the call to
     *             ADJTSKDET in ZZPICK and ZZPCKB.
500hA*    12/19/05  RH   5.00h
     *      - ENH: Don't allow pick trans to close if SOS work record
     *        exists for this transaction (Qty needs to be moved)
500iA*    01/03/06  RH   5.00i
     *      - Fix: Add PT170C with 500g change for PT170A.
500kA*    01/15/06  MLB  5.00k
     *      - Enh: Revised program to add status test for Out Flag
     *        types to prevent label from being changed before Out
     *        flag is closed.
500lA*    04/17/06  MLB  5.00l
     *      - Fix: Revised program to not set LBVRFY=T for all
     *        labels. Only set LBVRFY=T when W6MRG=' '.
510aA*    08/14/06  RH   510a
     *      - FIX: Revised program to create Ajdustment record when OUT
     *        label doesn't have a slot. Made ISYa, CLDa and ADWa
     *        permanent.
510bA*    08/21/06  RH   5.10b
     *      - Fix: Revised program to not execute ZZUPPQ for OUT label
510cA*    09/08/06  RH   5.10c
     *      - Fix: Revised ZZUPPQ to not allow pick to go negative.
     *        Problem when item has OUT and normal pick records.
510dA*    11/02/06  RH   5.10d
     *      - Enh: Use *FEATURE to include stand alone code (500j).
500jA*    12/13/05  JCJ  5.00j
     *      - Enh: Remove all references to file SLOT1.
     *             Remove any calls to program ADJQTY.
     *             Remove any calls to program SLOTQTY.
     *             Remove any calls to program CHKSTAT.
     *             Remove all references to file ITEMADJ.
     *        This is used with Dakota Voice SA (stand-alone).
510eA*    03/15/07  TJ   5.10e
     *      - Enh: Add ability to handle Repack Task.
510fA*    04/27/07  RBD  5.10f
     *      - Fix: Catchweight maintenance was being bypassed if
     *             user changed qty picked to 0, thus, the user
     *             was not deleting the ORDC catchweight records.
     *             Also, fix ordc klist ... code is not being used
     *             right now, but in case it ever will be again.
510gA*    05/14/07  RBD  5.10g
     *      - Fix: Check to see if ordc records exist before
     *             calling CW113 and CW112 when picked qty = 0.
510hA*    11/01/07  RBD  5.10h
     *      - Fix: Error PT13014 was incorrectly being issued for
     *             the error condition 'item not found'.  Added
     *             new error PT13201 for item not found. Also, ignore
     *             'item not found' and 'slot not found' errors when
     *             opfeat = 3, Stand-alone.  Most, but not all, 'slot
     *             not found' conditions were already being skipped
     *             when opfeat = 3.
510iA*    11/19/07  RBD  5.10i
     *      - Fix: When closing transaction with $pcmd '*ZERO   '
     *             update transaction with user id's employee#.
     *
520aA*    04/10/08  JCJ  520a-P#00000
     *      - Revised program to call UPDSLTDTE to reduce quantity
     *        onhand in the pick slot by date.
520bA*    09/11/08  HNK  5.20b
     *      - Fix: Validate Repl qty to make sure it does not exceed
     *             the label quantity.
520cA*    09/25/08  RH   5.20c
     *      - Fix: When closing transaction with brk1 qty, program
     *        was filling slstk2 with 4 digits and truncating 1st
     *        digit causing slot quantity to be wrong. Change to
     *        limit qty to only 3 digits in ZZUPDP
520dA*    10/04/08  DAS  5.20d  P#00140
     *      - Revised to up qty before updating Whse/Slot qtys.
     *        Re: We were running into breakdown 1 ordered qtys
     *            that were greater than 999.
     *      - Reversed 520c change
520eA*    02/05/09  CWM/MLB 5.20   1/26  2/02
     *      - Enh: Added support for new extended stop number
     *             Retrieve stop# in routine ZZFGTS and pgm GETSTOP
520fA*    04/01/09  RH  5.20f
     *      - Enh: Added F8 to screen 6 to call RH182 for subs.
520gA*    04/08/09  JCJ 5.20g
     *      - Added 9999999999 support
520hA*    02/25/09  GJA/RH  5.20h
     *      - Fix: Allow closing an OUT label when status is "Z",
     *        PIR item, allow negative.
520iA*    08/14/09  JCJ  5.20i
     *      - Fix: Logic in ZZUPDO was not handling the quantity
     *             picked processing for 'S' & 'A' type items if the
     *             UOM type was '1' or '2'.  If TB split one of these
     *             items and created two label records the quantity
     *             picked field in ORDD was getting the Quantity
     *             replaced by the second label record instead of
     *             accumulating the quantity.
     *
600 A*    02/24/09  DAS  6.00  P#00045
     *      - License Tracking
600bA*    02/24/09  DAS  6.00b
     *      - Putaway, Transfer and Replenishments no longer call
     *        this program.
     *      - Revised to call DRISLOT with %SYNCLCNS after slot update
     *        for selection.
     *      - Changed all #user to #curruser.
600cA*    06/16/09  DAS  6.00c
     *      - Removed call to UPDSLTDTE.
530aA*    12/07/09  RH   5.30a
     *      - Add Designation code to parms for CHKSTAT.
530bA*    01/18/10  RH   5.30b
     *      - Add pick slot end of item desc on SCREEN8
530cA*    05/21/10  JCJ  5.30c
     *      - Call CW112 with *CHKNONE when F10 is pressed.
530dA*    05/27/10  JCJ  5.30d
     *      -  Prevent user from changing the quantity if LBSTAT = 'C'
     *         and the LBTYPE = 'O' or 'B'.
530fA*    07/13/10  RH   5.30f
     *    original change was 07/20/07  MLB  5.10h missed in update.
     *      - Enh: Revised 5.10a change to add check for slot
     *             = '*NONE*' when closing OUT labels.
530gA*    10/14/10  RH   5.30g
     *      - Add pick slot end of Dept desc on SCREEN9
530hA*    03/11/10  MLB  5.30h
     *      - Fix: Revised ZZINZ2 to allow routine to loop looking
     *        for multiple label records to close for task REPLBK.
     *        This is needed by LT107 which allows the user to pull
     *        1 or more breakdown items for replenishment.
530iA*    11/05/10  MLB  5.30i
     *      - Fix: Revision to 5.30c mod. Corrected problem in ZZCHK6
     *        where pgm was trying to check for missing catchwgt rcds
     *        for Merge label records.
610 A*    11/09/10  MLB  6.10
     *      - Enh: Revised program to load LBSEQ into W6ORSQ, defined 5,0
     *        to be used when RH182 is called. W6SEQ in the subfile is
     *        4,0 and cannot hold a 5 digit order sequence number.
620aA*    11/29/10  DAS  6.20a
     *      - Enh: Revised to make adjustments into PRE slot when
     *        closing a prepick route label.
     *
640 A*    02/07/11  MLB  6.40
     *      - Enh: Revised program when updating label type O=Order or
     *        B=Bulk picks to zero pick quantity, to delete any catch-
     *        weights on file for the item.
     *
640aA*    03/04/11  DAS  6.40a
     *      - Added *FTP options
     *      - Added Cheney custom logic.
640bA*    06/03/11  RH   6.40b
     *      - Enh: Add error for SOS, can't close to > qty picked
     *        Renamed format to PT13202 to allow F20 on SC6.
640cA*    06/14/11  RH   6.40c
     *      - Enh: Add error flags to allow error override and then
     *        F10 for close on Screen 6
     *        Renamed format to PT13203
     *
640dA*    06/16/11  DAS  6.40d
     *      - Enh: Continued 640c enhancement.
640eA*    08/17/11  MLB  6.40e
     *      - Enh: Revised program to add code from ZZUPD2 into routine
     *        ZZUPD6 to delete any catchwgt rcds when pick qty = zero.
     *        Mod 6.40e is in addition to mod 6.40.
640fA*    11/15/11  RH   6.40f
     *      - Call HQ245 to try to find slot for OUT label with no
     *        slot.
640gA*    11/30/11  RH   6.40g
     *      - Enh: Only call HQ245 if *FEATURE = 2 (Full)
640hA*    01/05/12  MLB/RH 6.40h
     *      - Fix: Revised to not update slot pick qty for OUT label
     *        OUT label does not add qty to Slot pick qty when created
640iA*    01/23/12  RTR  6.40i
     *      - Fix: Truncate stop number to prevent error if stop > 999
640jA*    06/04/12  DAS  6.40j
     *      - Mods in progress
640kA*    06/04/12  DAS  6.40k
     *      - Mods in progress
640lA*    06/04/12  DAS  6.40l
     *      - Mods in progress
640mA*    06/05/12  MLB  6.40m
     *      - Fix: Revised PT132 to send error message to pgm
     *        if call to RH182 returned with *ERROR.
     *      - This is rev 640h at Glazier.
640nA*    10/03/12  MLB  6.40n
     *      - Fix: Allow closing an OUT label when status is "Z",
     *        for Fixed item, allow negative.
     *      - Enhancement to 5.20h mod.
640oA*    06/06/12  LMC  6.40o
     *      - Enh: Added call to WRTTRAN1 for PIRTRAND.
640pA*    07/24/12  LMC  6.40p
     *      - Enh: Don't call WRTTRAN1 multiple times for same tran#
640qA*    11/13/12  JCJ  6.40q
     *      - Fix: Added logic for F12 Cancel.
640rA*    09/12/12  RBD  6.40r
     *      - Added item substitutes logic.
     *        If the user selects cmd F8=Subs, check to see if subs
     *        are allowed and if they're not, display an error.
     *        If subs are allowed, retrieve the first item substitute
     *        defined (if any) and pass it to RH182.
650aA*    02/19/13  LMC  6.50a
     *      - Fix - Whse was causing decimal data in GETITEMSUB.
650b *    03/29/13  GJA  6.50B
     *      - Fix - in progress to zero verify BULK slot
650c *    04/30/13  RTR  6.50c
     *      - Fix - When no label records for trans, close trans.
650d *    06/04/13  KDE  6.50d
     *      - Enh - do not Zero flag on-demand pick slot
     *        if overflow slot exists
650eA*    03/14/13  LMC  6.50e
     *      - Enh: Added CWLOG. This adds a call to a new program
     *        CW800 and new file CWLOG.
650fA*    06/20/13  RBD  6.50f
     *      - Reserved, stop/drop revisions to come.
650gA*    02/19/14  MLB/RH  6.50g
     *      - Fix: Revised ZZPICK to correctly load qty fields when
     *        sending label info to pgm HQ245 when processing OUT
     *        label for SSB items.  Was causing SLSTK3 field in SLOT
     *        file to be updated in error.
650hA*    02/19/14  MLB/RH  6.50h
     *      - Fix: Revised dspf, PT13205 to increase size of field,
     *        W6SEQ to 5,0 from 4,0. Was causing MCH1210 Receiver value
     *        too small to hold result.
     *      - Created new dispf, PT13205 for this fix.
650iA*    02/28/14  MLB/RH  6.50i
     *      - Fix: Correction to 6.50d mod. k-list has the wrong
     *        fields specified on the k-list.
650jA*    02/28/14  KDE     6.50j
     *      - Fix: Changed to create on-demand slot on the fly if     99
     *        closing transaction and find the original slot gone     99
650kA*    04/08/14  KDE  6.50k
     *      - Fix: Mod 650d was leaving more slots open than it should99
     *
650mA*    04/09/14  DAS  6.50m
     *      - Added command *UPDSLBL to vfy/upd selection label.
     *        Initial purpose was to be used by GUI program.
     *      - Added $plbl#, $pqpck, $pwarn parms.
     *      - Revised to return selection error messages as text through
     *        $perm if TEXT is sent in $prtn.
     *
650nA*    04/29/14  DAS  6.50n
     *      - Revised to clear $prtn and $perm in zzinz2.
650oA*    03/02/15  MLB  6.50o
     *      - Fix: Revised 6.50n mod to only clear $PERM when $PCMD
     *        = *UPDSLBL. Was causing completion msgs to not be sent
     *        to callling program.
650pA*    03/09/15  LMC  6.50p
     *      - Fix: Now using *UPDSLBL command - needs a few changes
     *        to the logic.
700aA*    08/07/15  NLK  7.00a
     *      - ENH: adding in AMPxRef file - Advanded Merge Pick
700bA*    03/10/16  DAS  7.00b
     *      - FIX: Revised zzpickAMPupd to handle SSB items.
     *      - FIX: Revised zzpreupd to handle SSB items.
700cA*    01/20/16  MLB/JCJ  7.00b  (originally added to Silberman)
     *    03/28/16  NLK      7.00c  (added to ENH700 & S.Bertram)
     *      - Fix: Revised 6.50m mod to move added fields to save
     *        fields upon entry into pgm. Error msgs loaded into
     *        $perm where corrupting $PLBL# and $PQPCK causing MCH1202.
700dA*    04/28/16  NLK  7.00d
     *      - FIX: If AMP, don't go to DRISLOT if quanities are zero
700eA*    12/16/16  MLB  7.00e
     *      - Enh: Revised dspf, PT13206 changed from PT13205.
     *        Three new hidden fields added to DETAIL 6 subfile.
     *        Needed as part of CBIj mod.
700fA*    12/21/16  MLB  7.00f
     *      - Fix: Revised routine ZZUP6V to set $LCMD = *EDITCLS
     *        when clsflg = 1 and $pcmd = *CLOSEV. When Check C/wgt
     *        variances option set to C=Check at close, variance was
     *        only checked with $lcmd = *EDITCLS. Was allowing trans-
     *        action with out of tolerance wgts to be closed/exported.
700gA*    10/09/15  DAS  7.00g  (PIRMODSCBI 640b)
     *      - Added command *CLOSEV to be called by voice to
     *        automatically close a transaction.
     *      - Added routine zzup6v to be called for *CLOSEV.
     *
700hA*    10/15/15  DAS  7.00h
     *      - Revised to not display message for *CLOSEV.
710  *    07/25/17  KDE  7.10
     *      - Enh:  Add task code REPLPD for Production Module
710aA*    10/04/17  MLB  7.10a
     *      - Enh: Revised routines ZZCHK6, ZZCHK6A to not allow pick
     *        quantity to be greater than qty on label rcd.
710bA*    10/04/17  MLB  7.10b
     *      - Enh: Revised routine ZZCHK6 to remove quantity
     *        check from code that determinues whether RU300 should be
     *        called to verify if Runner Flags are still open. Was
     *        allowing user to change pick qty to ordered qty with Runner
     *        Flag still open. Then when Runner Flag is cleared, it was
     *        doubling the pick qty in error. Found at Jordanos.
     *
710cA*    11/15/17  JCJ  7.10c
     *      - Enh: Added new stop/drop field.
     *
720aA*    04/06/18  RBD  7.20a
     *      - Renamed format to PT13207.
     *      - On detail6 color item pink if it's been subbed.
     *      - Added subbed comment to head6.
     *
720bA*    06/26/18  KDE  7.20
     *      - Enh: Pass in GUI User to record proper user from Dakota GUI
     *
720cA*    08/24/18  DAS  7.20c
     *      - Revised how pallet generation is checked. DD2 may use
     *        generations greater than 3.
     *      - Added subroutine GetGenInfo and gGen fields to go with it.
     *
720dA*    09/08/18  DAS  7.20d
     *      - Revised to use PSTYPE='P' for TruckBuilder Enhanced.
     *
730aA*    01/18/19  DAS  7.30a
     *      - Revised to prevent closing transaction if open order
     *        audit exists.
     *
730b *    01/24/19  DAS  7.30b
     *      - Added pltid parm to chkordaud.
730cA*    03/07/19  MLB  7.30c
     *      - Enh: Revised pgm to pass department and slot display value
     *        to CHKSTAT in routine ZZUPDP only.
     *        Needed as part of EOPd mod.
730dA*    05/23/19  LMC  7.30d
     *      - Fix: When check maxqty check again svpqpck if command
     *        *UPDSLBL.
730eA*    07/11/19  LMC  7.30e
     *      - Enh: Added call to AUTOTFR to do automatic transfers
     *        when lbspcl = 'XE'.
730fA*    07/22/19  NLK  7.30f
     *      - FIX: zzchk6 - If Cheney, only allows Cheney to con't
     *        Details: 2=Change/Close; F10 Close; THEN F12 to skip
     *        catch weight -- BUT -- then the tran Closed w/o cw rcds
730gA*    08/16/19  DAS  7.30a
     *      - Revised zzfil6 to not allow change for UCI Selection item.
730hA*    09/16/19  LMC  7.30h
     *      - Enh - Added Pick to wgt logic.
730iA*    10/03/19  LMC  7.30i
     *      - Treat OPFTP = 'R' same as OPFTP = 'S'.
     *        R=Real time staging export.
730jA*    11/06/19  MLB  7.30j - CBI RIV *reserved
730kA*    11/06/19  MLB  7.30k - CBI RIV *reserved
740 A*    09/18/20  KDE  7.40
     *      - Enh: Handle Drop Pick inactive status slightly different
     *        than other inactive status codes sent in order status
750aA*    06/09/21  LMC  7.50a
     *      - Enh: The gui user doing the actual close is not being
     *        sent properly. Because PT132 doesn't seton LR. The job
     *        keeps the original user from when the program was opened
     *        The code to get the gui user that was sent in is only
     *        executing in *inzsr.
750bA*    08/19/21  RBD  7.50b
     *      - Include new runner status 'L' records when retrieving
     *        flag info.
     *
     *----------------------------------------------------------------
     *  Custom Revisions - Andrews
     *
ADWaA*    08/14/06  RH   ADWa
     *      - FIX: Revised program to create Ajdustment record when OUT
     *        label doesn't have a slot. Same as ISYa and CLDa
     *----------------------------------------------------------------
     *  Custom Revisions - Cheney
     *
CBI A*    07/10/03  MLB  CBI
     *      - Chg: Revised ZZPICK to set off ADJFLG to off when
     *        closing non-stock items. This is being done to prevent
     *        item adjustment and exception label records from being
     *        created when closing non-stock items.
CBIaA*    07/17/03  MLB  CBIa
     *      - Chg: Revised program to not check for catchweight entry
     *        for non-stock items. Any item where LBASL2 = '***'.
CBIbA*    07/17/03  MLB  CBIb
     *      - Chg: Revised program to not allow pick quantity to exceed
     *        order quantity. Routines chg'd: ZZCHK2, ZZCHK3, ZZCHK4 and
     *        ZZCHK6.
CBIcA*    08/20/03  DAS  CBIc
     *      - Revised to ignore catchweights for merge pallets and
     *        instead, work with catchweights for merge labels
     *        associated with truck pallets.
CBIdA*    10/22/03  RH   CBId
     *      - Revised ZZFIL6 to not allow quantity to change for
     *        MEAT-INSP or PRE-PICK.
CBIeA*    03/17/04  DAS  CBIe
     *      - Revised ZZFIL6 to not allow quantity to change for
     *        trucks MEAT-INSP, PRE-PICK and CONTAINER.
CBIfA*    10/08/04  RH   CBIf
     *      - Revised to not do catch weight check if called with
     *        *CLOSENC.
CBIgA*    11/09/04  HNK  CBIg
     *      - Revised to not allow anybody to change qty except users
     *        in the PT640usr file.
CBIhA*    03/04/11  DAS  CBIh
     *      - Revised export transaction to staging files when closed.
CBIiA*    03/13/17  DAS  CBIi*already use*
CBIiA*    11/28/16  DAS/JCJ  CBIi
     *      - Added CBIc LBPAL# < 20000 check to routines zzchk6 and zzck6a.
CBIjA*    12/12/16  MLB  CBIj
     *      - Added additional checks to ZZCHK6 and ZZCK6A to omit Export
     *        routes among others from c/wgt checks.
CBIkA*    12/22/16  MLB  CBIk
     *      - Added additional checks to ZZUP6V to omit Export routes, PIR
     *        zones from c/wgt checks.
CBImA*    03/01/17  MLB  CBIm
     *      - Chg to CBIj mod. Corrected reference to W6QPCK from LBQPCK.
     *        Was allowing wgt checks on PIR items in error.
CBInA*    03/20/17  DAS  CBIi chg to CBIn
     *      - Added command *CLOSEC1 to close any label record that
     *        has LBASL2='***' and ITCAT='PALLET'.
     *
     *----------------------------------------------------------------
     *  Custom Revisions - City Line
     *
CLDaA*    12/20/04  MLB  CLDa
     *      - FIX: Revised program to create Ajdustment record when OUT
     *        label doesn't have a slot.
     *----------------------------------------------------------------
     *  Custom Revisions - Eastland
     *
EFCaA*    06/03/11  RH   EFCa
     *      - ENH: Add error if SOS quantity picked < quantity orderedT
     *        and warehouse quantity available. Allow override.
     *----------------------------------------------------------------
     *  Custom Revisions - I-Supply
     *
ISYaA*    05/03/06  RH   ISYa
     *      - FIX: Same change for ISUPPLY as CLDa above.             T
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jordano's
JORaA*    06/19/09  RH   JORa
     *      - FIX: Allow non-reserved pick slots to go negative for OUT
     *        if item is special order (6 characters long, not ended in 'E')
JORbA*    07/14/09  RH   JORb
     *      - ENH: For OUT PIR label, check for PIR slot for item, update label
     *        with slot, close without X1 adjustment.
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP Foodservice
     *
VIP A*    04/14/07  MLB  VIP
     *      - Revised program to call UPDSLTDTE to reduce quantity
     *        onhand in the pick slot by date.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
     *
DRY A*    03/31/10  MLB  DRY
     *      - Revised ZZUPD6 to skip call to CW112 when CLSFLG = On.
     *        Weights have been verified at entry time.
DRYaA*    05/05/10  MLB  DRYa
     *      - Disabled DRY mod above.  Modification was allowing c/w
     *        items to be closed with qty picked and no weights entered.
DRYbA*    05/06/10  MLB  DRYb
     *      - Revised original DRY mod to pass *EDITCLS to CW113 when
     *        CLSFLG='1'. If total weight is out of tolerance, then
     *        CW112 screen will be displayed to the user.
DRYcA*    08/05/19  MLB  DRYc
     *      - Revised pgm to remove limit to over pick qty check.
     *        Per Hemant IM, 08.05.2019.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Avalon Foodservice
     *
AVL A*    12/05/11  MLB  AVL
     *      - Added new field to HEAD6 to display Retalix unit of work#.
     *        that is passed in from PT640.
     *      - Changed dspf to PT13204 from pt13203.
     *----------------------------------------------------------------
     *  Client custom Revisions: Hearn Kirkwood
     *
HKW A*    09/26/13  JCJ  HKWa
     *      - Do not execute the CW edits in ZZUPD6.                  #.
     *----------------------------------------------------------------
     *  Client custom Revisions: HM Wagner
     *
HMWaA*    11/18/14  JCJ  HMWa
     *      - Do not execute the CW edits in ZZUPD6.
     *      - Added HMWa to HKWa mod.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Graves Menu Maker
GMM A*    08/01/14  RH   GMMa
     *       - Do not execute the CW edits in ZZUPD6, added to HKW mod
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Fischer Foods
FSHaA*    11/06/14  JCJ  FSHa
     *       - Do not execute the CW edits in ZZUPD6, added to HKW mod
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite Foodservice
BIR A*    03/24/14  MLB  BIR
     *      - Revised routine ZZPICK to have non-stock items (LBASL2=***)
     *        bypass slot update.
BIRaA*    07/30/14  MLB  BIRa
     *      - Chg: Revised ZZUPDW to skip updates when processing
     *        non-stock items.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Sofo Foods
SOFaA*    11/18/15  MLB  SOFa
     *      - Chg: Revised ZZUPDW to skip updates when processing
     *        non-stock items.
     *
411 A*----------------------------------------------------------------
     *  Client custom Revisions: City Wholesale
CWa A*    09/20/15  RH   CWa
     *      - Chg: Revised program to not allow pick quantity to excee
     *        order quantity. Routines chg'd: ZZCHK2, ZZCHK3, ZZCHK4 a
     *        ZZCHK6. (added to CBIb mod)
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
KFS A*    03/04/19  MLB  KFS
     *      - Revised routine ZZPICK to have non-stock items (LBASL2=***)
     *        bypass slot update.
     *        Added KFS to BIR mod.
KFSaA*    03/04/19  MLB  KFSa
     *      - Chg: Revised ZZUPDW to skip updates when processing
     *        non-stock items.
     *        Added KFSa to BIRa mod.
KFSbA*    03/12/19  MLB  KFSb
     *      - Chg: Revised ZZUPDP to skip updates to stock qty for
     *        non-stock items.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Greco & Sons
GRC A*    05/15/19  MLB  GRC
     *      - Chg: Revised program to not allow pick quantity to exceed
     *        order quantity. Routines chg'd: ZZCHK2, ZZCHK3, ZZCHK4 a
     *        ZZCHK6.
     *      - Added GRC to CBIa mod.
     *
     *----------------------------------------------------------------
     *  Client custom Revisions: Y-Hata
411 A*----------------------------------------------------------------
     *  Quantity Types Notes
     *
411 A*   Contract Receiving
     *     - Quantity recieved is added to the warehouse stock
     *       quantity of the Contract item.
     *     - Quantity recieved is added to the warehouse stock
     *       and allocated quantities of the Base item.
     *     - Slot record will contain Base item number.
     *     - Quantity recieved is added to the slot's stock
     *       quantity.
     *     - Label record will contain Contraact item number.
     *     - Label record type will correspond to quantity type being
     *       received (Normal, Brk1, Brk2).
     *
     *   Same Slot Breakdown (SSB) Item Receiving
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
411 A*----------------------------------------------------------------
     *  Misc Notes
     *
411 A*    - Each item defined in the PIRITEM file, no matter the type,
     *      must contain its own detail information (ie. Description,
     *      Dimensions, Weight, Tie/Highs, Etc . . .).  This program
     *      will always deal with the Item information for the item
     *      in the label record.
     *      In the case of Alias, Contract and Same Slot Breakdown
     *      items the information should be identical to its
     *      corresponding Base item.
417 A*
417 A*    - Bulk picks now support multiple label records.  This is due
417 A*      to changes made to RF Bulk pick programs OR680,OR681
417 A*      allowing users to pick qty from multiple locations.
417 A*      Bulk picks will be closed using normal item selection
417 A*      screen processing.
     *
     *----------------------------------------------------------------
     *
     *  Notes
     *
     *    This is not a standard update program like IT112 because
     *    it can bypass the entry screens.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   Field position to
     *  21 - 40   Field input error (reverse display)
417bA*  65        Reverse image slot display on DETAIL6.
414bA*  70        Error on update to SLOT1 record
     *  81        Display subfile records (SFLDSP)
     *  82        Display subfile screen (SFLDSPCTL)
     *  83        Clear subfile (SFLCLR)
     *  84        Allow subfile to display '+' (SFLEND)
     *  85        Manually set subfile change flag (SFLNXTCHG)
     *  90        View mode (Protect input fields)
     *  91        Change mode (protect key)
     *  97        Error message subfile indicator
     *  98        Error on screen (sound buzzer)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
414fD**132FM CF  E                    WORKSTN
720aMFpt13207   cf   e             workstn usropn
720aDF*pt13206   cf   e             workstn usropn
700eDF*pt13205   cf   e             workstn usropn
650hDF*pt13204   cf   e             workstn usropn
AVL DF*pt13203   cf   e             workstn usropn
640cDF*t13202   cf   e             workstn usropn
414fDF*t132fm   cf   e             workstn usropn
     F                                     infds(infds)
     F                                     sfile(detail6:recno)
     F                                     sfile(detail7:recno)
     F                                     sfile(msgrec:msgk)
     FLabel7    if   e           k disk
530cMFpiritem   if   e           k disk    prefix(CW)
     Fpirtran   uf   e           k disk
     Fslot1     uf   e           k disk
650dAFslot3     if   e           k disk    rename(slrec:slrec3)
650dAf                                     prefix(s3_)
415lD**BEL   UF  E           K        DISK
415lMFLabel     uf a e           k disk
     Fordd      uf   e           k disk
720aAFordd1     if   e           k disk    rename(odrec:odrec1)
720aAf                                     prefix(od1_)
     Fordc      uf a e           k disk
510gAFordc1     if   e           k disk    rename(ocrec:ocrec1)
520fAFordh      if   e           k disk
     Fordslct2  uf   e           k disk
     Funmesr    if   e           k disk
     Fpltsum4   if   e           k disk
     Frtehed    if   e           k disk
     Foptions   if   e           k disk
     FLicense1  if   e           k disk
     FLabel71   if   e           k disk
417f FMultran1  if   e           k disk
417g FLabel90   if   e           k disk
417g F                                     rename(lbrec:lbrec1)
500dDF*runner    if   e           k disk
500hAFworksos2  if   e           k disk
CBIe Fpt640usr  if   e           k disk
     Fitemadj   o  a e           k disk
412gD*OG132  O   E                    DISK                      A
520gAForddm     if   e           k disk
650jAFkititem   if   e           k disk
620aAFprexref   if   e           k disk
620aAFprexref4  if   e           k disk    rename(pxrec:pxrec4)
700aAFampxref   if   e           k disk
730hA*----------------------------------------------------------------
730hA* Function prototypes.
730hA*----------------------------------------------------------------

730hA /copy qcopysrc,p.umlabel


     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------

     D a10             s              1    dim(10)
415eAD a30             s              1    dim(30)
415eD**                  DESC    1   3 50
530cD ** desc            s             50    dim(5) ctdata perrcd(1)
640bD **esc            s             50    dim(6) ctdata perrcd(1)
640qD **desc            s             50    dim(7) ctdata perrcd(1)
640qMD desc            s             50    dim(8) ctdata perrcd(1)

500fA*----------------------------------------------------------------
500fA*  Customer id
500fA*----------------------------------------------------------------
500fA
500fA /copy qcopysrc,id#jordano
500fA /copy qcopysrc,id#cheney
CLDaA /copy qcopysrc,id#citylin
ISYaA /copy qcopysrc,id#isupply
ADWaA /copy qcopysrc,id#andrews
VIP A /copy qcopysrc,id#vip
DRY A /copy qcopysrc,id#dairyla
EFCaA /copy qcopysrc,id#eastlan
AVL A /copy qcopysrc,id#avalon
HKWaA /copy qcopysrc,id#hkw
HMWaA /copy qcopysrc,id#hmwagne
GMMaA /copy qcopysrc,id#gmm
BIR A /copy qcopysrc,id#birite
FSHbA /copy qcopysrc,id#fischer
SOF A /copy qcopysrc,id#sofo
CWa A /copy qcopysrc,id#citywho
KFS A /copy qcopysrc,id#kfs
GRC A /copy qcopysrc,id#grc

     *----------------------------------------------------------------
     *  DRI parameters
     *----------------------------------------------------------------

416lA /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     *  Data Formats
     *----------------------------------------------------------------

416lA /COPY *libl/qcopysrc,C#SLOT
416lA /COPY *libl/qcopysrc,C#ITEM
650eA /COPY *libl/qcopysrc,C#CWLOG
520gA /copy qcopysrc,orddm1_rtx
416lAD savever#        s                   like($slver#)
416lAD piritemflds   e ds                  extname(piritem)

     *----------------------------------------------------------------
     *  Verify Subprogram Variables.
     *----------------------------------------------------------------

416lAD $vcommand       s              8
416lAD $vdesc          s             30
416lAD $vmessage       s             60
416lAD $vmsgk          s              4
416lAD $vprg           s             10
416lAD $vreturn        s             10

416lAD $vwhse          s              3p 0

730hA*----------------------------------------------------------------
730hA*  Standard variables and constants
730hA*----------------------------------------------------------------

730hA /copy qcopysrc,c#stdvar
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

640rAD $cmd            s             10
640rAD $isub           s             15
     D $gum            s              2
     D $msgf           s             10
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s                   like(itdesc)
     D #oitem          s                   like(ititem)
     D #opdsc          s                   like(itpdsc)
     D #otype          s              1
     D #pgmq           s             10
     D #sitem          s             15
     D actcub          s                   like($itcube)
     D chk4err         s               n
520c D ckstk2          s              3  0
     D clear           s              5  0
     D clsflg          s              1
     D cmdchk          s              8
     D cmdtkn          s              1
730aAD coaWhse         s              3  0
730aAD coaRtid         s              5
730aAD coaTran         s              7  0
730aAD coaOrdId        s              7  0
730bAD coaPltId        s              7  0
730aAD coaRtn          s             10
730aAD coaMsg          s            100
     D comand          s              5  0
     D cvt5a           s              5
510gAD cwflg           s              1
     D difcub          s                   like(lbcube)
     D difpck          s                   like(lbqpck)
     D difrpl          s                   like(lbqrmn)
     D difwgt          s                   like(lbswgt)
     D drierrmsg       s               n
     D e               s              2  0
730hDD*enter           s              5  0
730hDD*eof             s              1
730hDD*error           s               n
     D error2          s               n
     D error6          s               n
     D exwgt           s              9  2
     D fillscreen      s              3
     D flag8           s               n
     D forevr          s               n
730hDD*forever         s               n
650cAD foundlabel      s               n
720cAD gGen            s              1  0
720cAD gGenTruck       s               n
720cAD gGenMerge       s               n
720cAD gGenOverflow    s               n
720cAD gGenTruckExt    s               n
720cAD gPltId          s                   like(lbpal#)
     D help            s              5  0
     D hirng           s              9  2
     D hivar           s              9  2
     D itmflg          s               n
     D kyitem          s                   like(lbitem)
520f D kyord           s                   like(lbord)
     D kywhse          s                   like(lbwhse)
     D lsttim          s              6  0
650jAD odrslot         s             12
     D lwrng           s              9  2
     D lwvar           s              9  2
520c D maxq            s              3  0
     D msgk            s              4  0
416oDD*mxqty           s              5  0
416oMD mxqty           s              7  0
     D n               s              3  0
650dAD nbrovr          s              5  0
     D newcub          s                   like(lbcube)
     D newpck          s                   like(lbqpck)
     D newrpl          s                   like(lbqrmn)
     D newwgt          s                   like(lbswgt)
720bAd newUser         s             10
     D nxtscr          s              3
     D outadj          s               n
     D outlbl          s               n
     D ovrrid          s              1
     D pckcnt          s              3  0
     D pckqty          s                   like(lbqpck)
     D posrec          s              4  0
620aAD normPrepick     s               n
620aAD prepickLabel    s               n
700aAD AMPpickLabel    s               n
     D prg1c           s              4  3
     D prg2c           s              4  3
640cAD qtchk           s              1    inz('0')
     D reccnt          s              4  0
     D recno           s              4  0
     D redspl          s              1
     D refrsh          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
650pDD*rtnMsgType      s               n
650pMD rtnMsgType      s                   like($prtn)
     D savdif          s                   like(difrpl)
640dAD saveError       s               n
     D savitm          s                   like(lbitem)
     D savnew          s                   like(newrpl)
     D sclear          s              1
     D sumav1          s              5  0
416hAD svdsp2          s                   like(lbdsp2)
     D svitem          s                   like(lbitem)
520aDD svnewpck        s                   like(lbqpck)
     D svqpck          s                   like(lbqpck)
     D svqrmn          s                   like(lbqrmn)
520aDD svqty2          s                   like(lbqpck)
     D svstat          s                   like(lbstat)
     D svutyp          s                   like(lbutyp)
     D tempa7          s              7
     D tfctr           s              1  0
     D tfrqty          s                   like(lbqpck)
     D tlcwgt          s              9  2
     D tmpflg          s              1
     D today           s              8  0
     D trcode          s              8
     D trdata          s            150
     D trerr           s              1
     D trnbr           s              4
416cAD trqpck          s                   like(lbqpck)
     D tskflg          s              1
     D tstrpl          s                   like(newrpl)
730hDD*warn            s              1
     D wgtflg          s              1
     D wkcode          s                   like(opcode)
     D wkwhse          s                   like(opwhse)
     D woitm2          s             15
     D wrgitm          s              1
640oAD wrtpcmd         s             10
640oAD wrtpwait        s              2  0
640oAD wrtpwhse        s              3  0
640oAD wrtptran#       s                   like(pttrn#)
640oAD wrtpfrmdate     s              8  0
640oAD wrtptodate      s              8  0
640oAd wrtpemp#        s                   like(ptemp#)
640pAD wrtsaveptran#   s                   like(pttrn#)
640pAD wrtsaveptstat   s                   like(ptstat)
     D w8desc          s             30
     D w8item          s             15
416jDD**8lcn#          s              7  0
416jMD w8lcn#          s             15
     D zmsflag         s               n

     D #bwhse          s                   like($itwhse)
     D #bitem          s                   like($ititem)
     D #btype          s                   like($itdesc)
     D #bdesc          s                   like($itdesc)
     D #bpdsc          s                   like($itpdsc)
     D #bstyp          s                   like($itstyp)
     D #bwhdp          s                   like($itwhdp)
     D #bdesg          s                   like($itdesg)
     D #bactv          s                   like($itactv)
     D #bupc           s                   like($itupc)
     D #bbld           s                   like($itbld)
     D #bven#          s                   like($itven#)
     D #bvit#          s                   like($itvit#)
     D #bum1           s                   like($itum1)
     D #bum2           s                   like($itum2)
417jDD*#bumq2          s                   like($itumq2)
     D #bflg1          s                   like($itflg1)
     D #bum3           s                   like($itum3)
417jDD*#bumq3          s                   like($itumq3)
     D #bflg2          s                   like($itflg2)
     D #bulen          s                   like($itulen)
     D #buwdt          s                   like($ituwdt)
     D #buhgt          s                   like($ituhgt)
     D #bcube          s                   like($itcube)
     D #bswgt          s                   like($itswgt)
     D #bcwgt          s                   like($itcwgt)
     D #breor          s                   like($itreor)
     D #brepl          s                   like($itrepl)
     D #brcvd          s                   like($itrcvd)
     D #bflgd          s                   like($itflgd)
     D #bflgb          s                   like($itflgb)
     D #bslif          s                   like($itslif)
     D #bnday          s                   like($itnday)
CBIf D flagnc          s              1
CBIn D flagc1          s               n
650eAD  CWcmd          s             10
650eAD  CWpgm          s             10
650eAD  CWrtn          s             10
650eAD  CWmsg          s             60
650eAD  CWdata         s            512
650eAD  processstatus  s             10
720dAd tbEnhanced      s               n
720dAd tbPalletType    s              1
720dAd tbType          s              1
720dAd tbWhse          s              3  0

730hAD Pick2lbs        s              6  2
730hAd hlddifpck       s                   like(lbqpck)
730hAd savelabel       s                   like(LBULBL#)

CBId *----------------------------------------------------------------
CBId *  Variable data
CBId D dsmisc          ds
CBId D  dssdte                 1      8
CBId D  dsspcl                 9     11
CBId D  dsrpck                12     12
CBId D  dxdoor                13     14
CBId D  dsmeat                15     15
CBId D  dsppck                17     17
     *----------------------------------------------------------------
     *  Program parameters
     *----------------------------------------------------------------

700cAD                 ds
700cAD svplbl#                 1      7  0  inz(0)
700cAD svpqpck                 8     12  0  inz(0)
700cA*
     D $parms          ds
     D  $pcmd                  1      8
     D  $pprg                  9     18
     D  $puky                 19     68
     D  $prtn                 69     76
     D  $perm                 77    136
     D  $pmsg                 77     80
     D  $ptype                81     88
     D  $pmput                89     89
650mAD  $plbl#                90     96  0
650mAD  $pqpck                97    101  0
650mAD  $pwarn               102    102
     *
     *   Redefine key
     *
     D  $pwhse                19     21  0
     D  $prte                 22     26
     D  $ppo                  27     35
     D  $ptrn#                36     42  0
720bAd  $pguiUser             43     52
AVLaAD  $puow#                60     68
     *
     * Data structure
     *
     D opdata          ds
     *                                       1   1 OPEPM
     *                                       2   2 OPRF
     *                                       3   3 OPCAPC
     *                                       4   4 OPLETD
     *                                       5   5 OPWRNC
     *                                       6   81OPRG1C
     *                                       9  111OPRG2C
     *                                     117 117 OPTEND
     D  opend                117    117
     *----------------------------------------------------------------
     *  *SYSTEM  -  System options.
     *
     * Fields
     *
     *    OPEPM   -  Using EPM module (Y,N).
     *    OPRF    -  Using RF module (Y,N).
     *    OPCAPC  -  Capture catch weights at pick closing (Y,N).
     *    OPLETD  -  Print letdown labels (Y,N).
     *    OPWRNC  -  Perform catch weight variance check (Y,N).
     *    OPRG1C  -  Catch weight low variance percentage.
     *    OPRG2C  -  Catch weight high variance percentage.
     *
     * Data structure
     *
     D sysopt          ds
     D  opepm                  1      1
     D  oprf                   2      2
     D  opcapc                 3      3
     D  opletd                 4      4
     D  opwrnc                 5      5
     D  oprg1c                 6      8  1
     D  oprg2c                 9     11  1
     D  optend               117    117
     *----------------------------------------------------------------
     *  *CLOSE   -  Transaction close options.
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPEXCD  -  Exception labels picked - code.
     *    OPNSCD  -  Not enough stock to close transaction - code.
     *    OPDICD  -  Different item found in slot - code.
     *
     * Data structure
     *
     D clsopt          ds
     D  opexcd                 1      2
     D  opnscd                 3      4
     D  opdicd                 5      6
     D  clsend               117    117
415dA*----------------------------------------------------------------
415dA*  *FEATURE  -  PIR Feature options.
415dA*----------------------------------------------------------------
415dA*
415dA* Fields
415dA*
415dA*    OPFEAT  -  PIR Installed feature.
415dA*
415dA* Data structure
415dA*
415dAD ftropt          ds
415dAD  opfeat                 1      1
415dAD  ftrend               117    117
416 A*----------------------------------------------------------------
416 A*  *RETURNS -  Customer Returns options
416 A*----------------------------------------------------------------
416 A*
416 A* Fields
416 A*
416 A*    OPRQCH  -  Allow changes to return quantity. (Y,N).
416 A*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
416 A*
416 A* Data structure
416 A*
416 AD rtnopt          ds
416 AD  oprqch                 1      1
416 AD  oprqec                 2      2
416 AD  rtnend               117    117
416iA*----------------------------------------------------------------
410iA*  *GENPICK -  General picking options.
416iA*----------------------------------------------------------------
416iA*
416iA* Fields
416iA*
416iA*    OPERPT  -  Print exception (short) error report (Y,N).
416iA*    OPELBL  -  Print exception (short) labels (Y,N)
416iA*    OPRFWC  -  Using RF will call (Y,N).
416iA*    OPNRSC  -  Number of pallet sections (1-9).
416iA*    OPHPWC  -  Host pick Will Call (Y/N).
416iA*    OPEADJ  -  Close short labels without adjustment (Y,N).
416iA*
416iA* Data structure
416iA*
416iAD genopt          ds
416iAD  operpt                 1      1
416iAD  opelbl                 2      2
416iAD  oprfwc                 3      3
416iAD  opnrsc                 4      4  0
416iAD  ophpwc                 5      5
417oDD* opeadj                 6      6
417oAD  opeadj                 8      8
416iAD  genend               117    117
640aA*----------------------------------------------------------------
640aA*  *FTP      -  FTP options
640aA*----------------------------------------------------------------
     *
     * Fields
     *
     *    OPFTP   -  Use FTP for exporting (Y,N)
     *    OPSRVR  -  FTP Server name
     *    OPUSER  -  FTP User id
     *    OPPWD   -  FTP Password
     *
     * Data structure
     *
     D ftpopt          ds
     D  opftp                  1      1
     D  opsrvr                 2     33
     D  opuser                34     48
     D  oppwd                 49     63
     D  ftpend               117    117
416cA*----------------------------------------------------------------
416cA*
416cA* The following data structures are for capturing close
416cA* tracking info.
416cA*
416cA*----------------------------------------------------------------
416cA*  *PCK001   -  Close Route info
416cA*----------------------------------------------------------------
416cA*
416cA* Fields
416cA*
416cA*    TRPCMD  -  Program processing option
416cA*    TRPPRG  -  Calling program
416cA*    TROTYP  -  Order type (' '=Reg, W=Will Call, T=Transfer)
416cA*    TRRORD  -  Not used in this format.  Defaults to 0.
416cA*    TRPKST  -  Closing status
416cA*    TRFLPK  -  Not used in this format.  Defaults to 0.
416cA*    TRFLTK  -  Not used in this format.  Defaults to 0.
416cA*
416cA* Data structure
416cA*
416cAD tr01ds          ds
416cAD  trpcmd                 1      8
416cAD  trprg                  9     18
416cAD  trotyp                19     19
416cAD  trrord                20     26  0 inz(0)
416cAD  trpkst                27     46
416cAD  trflpk                47     47  0 inz(0)
416cAD  trfltk                48     48  0 inz(0)
416cAD  trdt01                 1    150
416cA*----------------------------------------------------------------
416cA*  *PCK050  -  Tracking message(s)
416cA*----------------------------------------------------------------
416cA*
416cA* Fields
416cA*
416cA*    TRSR50  -  Subroutine sending message
416cA*    TRDT50  -  Tracking message(s)
416cA*
416cA* Data structure
416cA*
416cAD tr50ds          ds
416cAD  trsr50                 1     10
416cAD  trdt50                11    150
416cA*----------------------------------------------------------------
416cA*  Tracking messages
416cA*----------------------------------------------------------------
     D tr01            c                   const('Pick Qty Changed.')
     D tr02            c                   const('Bf:')
     D tr03            c                   const('Af:')
     D tr04            c                   const('Diff:')
     D tr80            c                   const('Closed - No Chg')
     D tr81            c                   const('Closed - W/Chg''s')
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
416cAD $cerm           ds
416cAD  xcerm                  1     60
416cAD  $cmsg                  1      4
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
640fAD  $lmem                 77    106
     *
     *   Redefine key
     *
     *                                      19  250$LTRN#
     D  $lwhse                19     21  0
     D  $ltrn#                22     28  0
     D  $litem                29     43
     D  $lseq#                44     48  0
     D  $llbl#                49     55  0
     *
520f D  $lsrte                22     26
520f D  $lscor                27     33  0
520f D  $lsord                34     40  0
520f D  $lsseq                41     45  0
520f D  $lsitm                46     60
     *
640fAd  $lwhdp                22     26
640fAd  $litm                 27     41
640fAd  $lqp1                 42     48  0
640fAd  $lqp2                 49     55  0
640fAd  $lqp3                 56     62  0
640fAd  $ladj                 63     64
     *
     *----------------------------------------------------------------
     *  Called programs
     *
     D @adjtd          c                   const('ADJTSKDET')
     D @cvtdt          c                   const('CVTDTE')
417m D @getsi          c                   const('GETSLOTITM')
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
     *
     D  erdisp                 1     12
     D  eritm1                13     27
     D  erdif                 13     16p 0
     *
     D  eritm2                 1     15
     *
     D  ertrn#                 1      4p 0
     *
     D  erfld                  1     30
     D  erfrom                31     40
     D  erto                  41     50
     *
     D  ertcwt                 1      5p 2
     D  erlrng                 6     10p 2
     D  erhrng                11     15p 2
     D  errg1c                16     17p 1
     D  errg2c                18     19p 1
     D  erexwt                20     24p 2
     *
     D  erqrpl                 1      3p 0
     D  erqpck                 4      6p 0
     D  erumq2                 7      9p 0
     D  erum2                 10     14
     D  erum                  15     19
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
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
600bAD  #curruser            358    367
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
640oA*----------------------------------------------------------------
640oA*  Prototypes
640oA*----------------------------------------------------------------
720dAd/copy qcopysrc,p.gettbtyp
650eA /copy qcopysrc,p.cw800
730aA /copy qcopysrc,p.chkordau
640oA
640oAD wrttran1        pr                  extpgm('WRTTRAN1')
640oA * Input
640oAD   ppcmd                        8
640oAD   ppwait                       2  0
640oAD   ppwhse                       3  0
640oAD   pptran#                      7  0
640oAD   ppfromdate                   8  0
640oAD   pptodate                     8  0
640oAD   ppemp#                       5  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *OPEN    - Open program and return.
     *              *CHANGE  - Change before closing.
     *              *VIEW    - View transaction.
     *              *CLOSE   - Close without changing.
CBIf *              *CLOSENC - Close without checking catch weights
     *              *ZERO    - Close with zero quantity.
414eA*              *VRFYCW  - Verify catchweights.
650mA*              *UPDSLBL - Verfy/Update label
     *      $PPRG   Program to send messages back to.
     *      $PTYPE  *INTER   - Interactive mode.
     *              *BATCH   - Batch mode.
     *      $PUKY   Contains key of transaction.
     *      $PMPUT  ???
650mA*      $PLBL#  Label number for *UPDSLBL
650mA*      $PRTN   'TEXT' - Put error messages into $PERM
650mA*              ' '    - Put error messages into message queue
     *
     *    Returned Parameters
     *      $PUKY   Contains new batch number for *ADD.
     *              Unchanged for everything else.
     *      $PRTN   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $parms
     *----------------------------------------------------------------
     *  Main line
     *
     C     $pcmd         cabeq     '*OPEN   '    bottom
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C     nxtscr        caseq     '03 '         sc3
     C     nxtscr        caseq     '04 '         sc4
     C     nxtscr        caseq     '05 '         sc5
     C     nxtscr        caseq     '06 '         sc6
     C     nxtscr        caseq     '07 '         sc7
     C     nxtscr        caseq     '08 '         sc8
     C     nxtscr        caseq     '09 '         sc9
     C     nxtscr        caseq     '10 '         sc10
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   unlock    pirtran
     C                   if        $jtype = *on
     C                   exsr      zsclr
     C                   endif
     *
     C     bottom        tag
     C                   return
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
     C                   select
     C                   when      nxtscr = '01 '
     C                   exfmt     screen1                              50
     *
     C                   when      nxtscr = '02 '
     C                   exfmt     screen2                              50
     *
     C                   when      nxtscr = '03 '
     C                   exfmt     screen3                              50
     *
     C                   when      nxtscr = '04 '
     C                   exfmt     screen4                              50
     *
     C                   when      nxtscr = '05 '
     C                   exfmt     screen5                              50
     *
     C                   when      nxtscr = '06 '
     C                   exsr      sfldsp
     C                   read      head6                                  50
     *
     C                   when      nxtscr = '07 '
     C                   exsr      sfldsp
     C                   read      head7                                  50
     *
     C                   when      nxtscr = '08 '
     C                   exfmt     screen8                              50
     *
     C                   when      nxtscr = '09 '
     C                   exfmt     screen9                              50
     *
     C                   when      nxtscr = '10 '
     C                   exfmt     screen10                             50
     C                   endsl
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
     C                   setoff                                       333435
720aDC**                 setoff                                       363738
720aMC                   setoff                                         3738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      redspl = *off
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
     C                   move      '01 '         nxtscr
     C                   if        refrsh = *on
     C                   exsr      zzfil1
     C                   endif
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   move      '02 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil2
     C                   endif
     C                   eval      refrsh = *off
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 03 initialization
     *
     C     scr03i        begsr
     C                   move      '03 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil3
     C                   endif
     C                   eval      refrsh = *off
     C     end03i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 04 initialization
     *
     C     scr04i        begsr
     C                   move      '04 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil4
     C                   endif
     C                   eval      refrsh = *off
     C     end04i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 05 initialization
     *
     C     scr05i        begsr
     C                   move      '05 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil5
     C                   endif
     C                   eval      refrsh = *off
     C     end05i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 06 initialization
     *
     C     scr06i        begsr
     C                   move      '06 '         nxtscr
EFCbAC                   eval      ovrrid = *off
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
AVL A*
AVL AC                   if        client = Avalon
AVL AC                   eval      w6uow# = 'UoW#: ' + %trim($puow#)
AVL AC                   endif
AVL A*
     C                   exsr      zzfil6
     C                   endif
     C                   eval      refrsh = *off
     C     end06i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 07 initialization
     *
     C     scr07i        begsr
     C                   move      '07 '         nxtscr
     C                   eval      ovrrid = *off
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil7
     C                   endif
     C                   eval      refrsh = *off
     C     end07i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 08 initialization
     *
     C     scr08i        begsr
     C                   move      '08 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil8
     C                   endif
     C                   eval      refrsh = *off
     C     end08i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 09 initialization
     *
     C     scr09i        begsr
     C                   move      '09 '         nxtscr
416 MC                   if        $pcmd = '*VIEW   ' or
416 A*
416 A*    Quantity change not allowed during close of Returns.
416 AC                             oprqch = 'N'
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfil9
     C                   endif
     C                   eval      refrsh = *off
     C     end09i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 10 initialization
     *
     C     scr10i        begsr
     C                   move      '10 '         nxtscr
     C                   if        $pcmd = '*VIEW   '
     C                   eval      *in90 = *on
     C                   endif
     C                   if        refrsh = *on
     C                   exsr      zzfi10
     C                   endif
     C                   eval      refrsh = *off
     C     end10i        endsr
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
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr01i
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd1
     C     error         cabeq     *on           endsc1
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr02i
     C                   endif
     Csr                 goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc2
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
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc3
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr03i
     C                   endif
     Csr                 goto      endsc3
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc3
     C                   endif
     *
     *  Test for other command keys
     *
     *R                   EXSR ZZCMD3
     *R         CMDTKN    CABEQ*ON       ENDSC3
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
     *
     C                   exsr      zzchk3
     C     error         cabeq     *on           endsc3
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr04i
     C                   endif
     Csr                 goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc4
     C                   endif
     *
     *  Test for other command keys
     *
     *R                   EXSR ZZCMD4
     *R         CMDTKN    CABEQ*ON       ENDSC4
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc5
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr05i
     C                   endif
     Csr                 goto      endsc5
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc5
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd5
     C     cmdtkn        cabeq     *on           endsc5
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk5
     C     error         cabeq     *on           endsc5
     C                   exsr      zzupd5
     C     error         cabeq     *on           endsc5
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc6
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr06i
     C                   endif
     Csr                 goto      endsc6
     C                   endif
     *
417i *  Test for F7 - Clear flag
     *
417i C                   if        *inkg
417i C                   if        rtnrrn > 0
417i C                   eval      posrec = rtnrrn
417i C     rtnrrn        chain     detail6                            79
417qAC                   if        *in79 = *on
417qAC                   eval      w6lbl# = 0
417qAC                   endif
417qA*
417qA*  Check if label entered in Runner Flag file.
500dDC*    w6lbl#        chain     runner
500dA*
500dAC                   call      'RU300'
500dAC                   parm      '*STATUS '    $rucmd            8
500dAC                   parm      $pwhse        $ruwhse           3 0
500dAC                   parm      w6lbl#        $rulbl#           7 0
500dAC                   parm      ' '           $rutype           1
500dAC                   parm      ' '           $rustat           1
500dAC                   parm      '        '    $rurtn            8
500dDC*                  if        not %found(runner)
500dDC*                  eval      rustat = ' '
500dDC*                  endif
417qA*
417qA*  If Runner status is Open or Picked. Clear not available.
500dA*  or Replenished, Clear not available.
500dDC*                  if        not *in79 and
500dMC                   if        $rurtn = '*OK' and
417qAC                             w6mrg = 'F'
500kAC                             or $rurtn = '*OK' and
500kAC                                 w6mrg = 'I'
500dDC*                  if        rustat = 'O'
500dMC                   if        $rustat = 'O'
500dDC*                            or rustat = 'P'
500dMC                             or $rustat = 'P'
500dAC                             or $rustat = 'R'
750bAC                             or $rustat = 'L'
417qAC                   eval      *in21  = *on
417qAC                   eval      *in01  = *on
417qAC                   eval      errmsg = *blanks
417qAC                   exsr      zm1061
417qAC                   update    detail6
417qAC                   endif
417qAC                   endif
417qA*
417qA*
417qA*  If Runner status is Open or Picked. Clear not available.
500dDC*                  if        not *in79 and
500dMC                   if        $rurtn = '*OK' and
417i C                             w6mrg = 'F'
500dDC*                            and rustat <> 'O'
500dMC                             and $rustat <> 'O'
500dDC*                            and rustat <> 'P'
500dMC                             and $rustat <> 'P'
500dAC                             and $rustat <> 'R'
750bAC                             and $rustat <> 'L'
417q *
500dDC*                            or not *in79 and
500dMC                             or $rurtn = '*OK'
500dAC                             and $rustat <> 'O'
500dAC                             and $rustat <> 'P' and
750bAC                             $rustat <> 'L' and
417q C                             w6mrg = 'I'
417i C                   eval      w6mrg=*blanks
417i C                   update    detail6
417i C                   endif
417i C                   goto      endsc6
417i C                   endif
417i C                   endif
     *
520f *  Test for F8 - Call Substitute program
     *
520f C                   if        *inkh
     *
520f C                   if        rtnrrn > 0
520f C                   eval      posrec = rtnrrn
520f C     rtnrrn        chain     detail6                            79
520fAC                   if        *in79 = *on
520fAC                   eval      w6ord = 0
520fAC                   endif
520fAC                   eval      kywhse = lbwhse
520fAC                   eval      kyord = w6ord
520fAC     keyoh         chain     ordh                               79
640rAC                   if        not %found
640rAC                   eval      $lrtn = '*ERROR  '
640rAC                   eval      error = *on
640rAC                   eval      errmsg = 'Order header not found'
640rAC                   movel     errmsg        $lerm
640rAC                   exsr      zm0105
640rAC                   goto      endsc6
640rAC                   endif
520fAC                   if        %found(ordh)
520fAC                   eval      $lcmd = '*SUB    '
520fAC                   eval      $lwhse = lbwhse
520fAC                   eval      $lsrte = lbrte
520fAC                   eval      $lscor = ohcord
520fAC                   eval      $lsord = w6ord
610 DC*                  eval      $lsseq = w6seq
TMP DC**                 eval      $lsseq = w6orsq
TMP MC                   eval      $lsseq = w6seq
520fAC                   eval      $lsitm = w6item
520fA*
640rAC                   eval      $cmd = '*GET      '
650aAC                   eval      $whs30 = $pwhse
640rAC                   call      'GETITEMSUB'
640rAC                   parm                    $cmd
650aDC*                  parm                    $lwhse
650aMC                   parm                    $whs30            3 0
640rAC                   parm                    $litem
640rAC                   parm                    ohcust
640rAC                   parm                    $isub
640rAC                   parm                    $lrtn
640rAC                   parm                    $lerm
640rA
640rAC                   if        $lrtn = '*OK     '
520fAC                   call      'RH182'
520fAC                   parm                    $lparm
640rAC                   parm                    $isub
640rAC                   endif
520f C                   if        $lrtn = '*ERROR'
640mAC                   eval      error = *on
640mAC                   movel     $lerm         errmsg
640mAC                   exsr      zm0105
520fAC                   endif
520fA*
520f C                   goto      endsc6
520fAC                   endif
520fAC                   endif
520fA*
520fAC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc6
     C                   endif
     *
     *  Test for other command keys
     *
     *R                   EXSR ZZCMD6
     *R         CMDTKN    CABEQ*ON       ENDSC6
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   eval      cmdchk = '*BEFORE '
     C                   exsr      zzcmd6
417f C     error         cabeq     *on           endsc6
     C     cmdtkn        cabeq     *on           endsc6
     *
     *  Some other key pressed.
417l C     ptinp1        ifgt      0
417l C                   exsr      zzpos6
417l C                   goto      endsc6
417l C                   endif
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk6
     C     error         cabeq     *on           endsc6
640dAC     *inku         cabeq     *on           endsc6
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
     *  SC7  -  Screen 7
     *
     C     sc7           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc7
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr07i
     C                   endif
     Csr                 goto      endsc7
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc7
     C                   endif
     *
     *  Test for other command keys
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
     *
     C                   exsr      zzchk7
     C     error         cabeq     *on           endsc7
     C                   exsr      zzupd7
     C     error         cabeq     *on           endsc7
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc8
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr08i
     C                   endif
     Csr                 goto      endsc8
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc8
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd8
     C     cmdtkn        cabeq     *on           endsc8
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk8
     C     error         cabeq     *on           endsc8
     C                   exsr      zzupd8
     C     error         cabeq     *on           endsc8
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
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr09i
     C                   endif
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      endsc9
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd9
     C     cmdtkn        cabeq     *on           endsc9
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzchk9
     C     error         cabeq     *on           endsc9
     C                   exsr      zzupd9
     C     error         cabeq     *on           endsc9
     *
     C     endsc9        endsr
     *----------------------------------------------------------------
     *
     *  SC10  -  Screen 10
     *
     C     sc10          begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*EXIT   '
     Csr                 goto      ends10
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   move      *on           refrsh
     C                   exsr      scr10i
     C                   endif
     Csr                 goto      ends10
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
     Csr                 goto      ends10
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcm10
     C     cmdtkn        cabeq     *on           ends10
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     *
     C                   exsr      zzch10
     C     error         cabeq     *on           ends10
     C                   exsr      zzup10
     C     error         cabeq     *on           ends10
     *
     C     ends10        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr

     C                   move      *on           forevr
720dMc*
720dMc*   Determine if using TruckBUilder Enhanced
720dMc*
720dA /free
720dA      tbWhse = $pwhse;
720dA      GetTBType(tbWhse: $prte: tbType);
720dA      if tbType = 'E';
720dA        tbEnhanced = *on;
720dA        tbPalletType = 'P';
720dA      else;
720dA        tbEnhanced = *off;
720dA        tbPalletType = 'O';
720da      endif;
720dA /end-free
     *
     *  Initialize special keys
     *
730hDC*                  eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *   Get job type (0 = Batch, 1 = Interactive)
     *
     C                   call      'GETJTYPE'
     C                   parm                    $jtype            1
     *
     *   Open display file if this program is being run interactively.
     *
     C                   if        $jtype = *on
640bDC*                  open      pt132fm
640cDC*                  open      pt13202
AVL DC*                  open      pt13203
650hDC*                  open      pt13204
700eDC*                  open      pt13205
720aDC*                  open      pt13206
720aMC                   open      pt13207
     C                   endif
     *
     *  Initialize message handling
     *
     C                   if        $jtype = *on
     C                   exsr      zmimsg
     C                   endif
     *
     *  Initialize subfile values
     *
     *                    Z-ADD1         RECNO
     *                    WRITEDETAIL7                79
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLADD   Add record to subfile
     *
     C     sfladd        begsr
     C                   add       1             reccnt
     C                   eval      recno = reccnt
     C                   select
     C                   when      nxtscr = '06 '
     C                   write     detail6
     C                   when      nxtscr = '07 '
     C                   write     detail7
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLCLR   Clear display subfile
     *
     C     sflclr        begsr
     *
     *  CLEAR DISPLAY SUBFILE
     *
     C                   eval      recno = 0
     C                   eval      reccnt = 0
     C                   eval      posrec = 1
     *
     C                   eval      *in81 = *off
     C                   eval      *in82 = *off
     C                   eval      *in83 = *on
     C                   eval      *in84 = *on
     C                   select
     C                   when      nxtscr = '06 '
     C                   write     head6
     C                   when      nxtscr = '07 '
     C                   write     head7
     C                   endsl
     C                   eval      *in82 = *on
     C                   eval      *in83 = *off
     C                   endsr
     *----------------------------------------------------------------
     *
     *  SFLDSP   Display subfile
     *
     C     sfldsp        begsr
     *
     *  WRITE COMMAND LINE TO DISPLAY
     *
     C                   write     cmdrec
     *
     *  WRITE SUBFILE TO DISPLAY
     *
     C                   if        reccnt > 0
     C                   eval      *in81 = *on
     C                   endif
     C                   eval      recno = posrec
     C                   select
     C                   when      nxtscr = '06 '
     C                   write     head6
     C                   when      nxtscr = '07 '
     C                   write     head7
     C                   endsl
     C                   endsr
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
     C                   move      '*CLEAR '     #msgid
     C                   move      '*NULL  '     #msgtp
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
700hAC                   if        $pcmd = '*CLOSEV '
700hAC                   eval      #msgdt = *blanks
700hAC                   eval      $msgf = *blanks
700hAC                   leavesr
700hAC                   endif
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
     C                   move      *on           sclear
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgf         $msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr

     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *    DRI0001  Local system caused error
     *----------------------------------------------------------------

     C     zm0001        begsr
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    DRI0001s Local system caused error (send to different program)
     *----------------------------------------------------------------

     C     zm0001s       begsr
     C                   if        $drisys2upd = 'D'
     C                   eval      #msgid = 'DRI0001'
     C                   else
     C                   eval      #msgid = 'DRI0002'
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error.
     *----------------------------------------------------------------

     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmpmsg
     C                   endsr

     *----------------------------------------------------------------
     *    PIR0105  Generic error (send to different program)
     *----------------------------------------------------------------

     C     zm0105s       begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = errmsg
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'OUTOFRNG'
650mAC                   eval      $perm = %trim(desc(1)) + ' '
650mAC                                   + 'not in range '
650mAC                                   + '(' + %trim(erfrom) + ' thru '
650mAC                                   + %trim(erto) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PIR0112'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0123  Breakdown item replenishment qty not mult of pick qty
     *
     C     zm0123        begsr
     C                   move      'PIR0123'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   move      'PIR9905'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
417qA*----------------------------------------------------------------
417qA*    PIR1060  Qty Change not Allowed when Runner Flag = 'F'.
417qA*
417qAC     zm1060        begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'RUNFLAG'
650mAC                   eval      $perm = 'Quantity change not allowed '
650mAC                                   + 'when Runner flag is open'
650mAC                   leavesr
650mAC                   endif
417qAC                   move      'PIR1060'     #msgid
417qAC                   move      '*DIAG  '     #msgtp
417qAC                   movea     errmsg        $md
417qAC                   exsr      zmpmsg
417qAC                   endsr
417qA*----------------------------------------------------------------
417qA*    PIR1061  Runner flag not closed. F7=Clear not available.
417qA*
417qAC     zm1061        begsr
417qAC                   move      'PIR1061'     #msgid
417qAC                   move      '*DIAG  '     #msgtp
417qAC                   movea     errmsg        $md
417qAC                   exsr      zmpmsg
417qAC                   endsr
     *----------------------------------------------------------------
     *    PT12010  Slot does not exist.
     *
     C     zm10          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'INVLDSLT'
650mAC                   eval      $perm = 'Invalid slot '
650mAC                                   + '(' + %trim(erdisp) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PT13010'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12011  Item does not occupy slot anymore.
     *
     C     zm11          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'DIFFITEM'
650mAC                   eval      $perm = 'Item not in slot '
650mAC                                   + '(' + %trim(eritm1) + '/'
650mAC                                   + %trim(erdisp) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PT13011'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12012  Transaction does not exist.
     *
     C     zm12          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'INVLDTRN'
650mAC                   eval      $perm = 'Invalid transaction '
650mAC                                   + '(' + %char(ertrn#) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PT13012'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12013  Order detail does not exist.
     *
     C     zm13          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ODNOTFND'
650mAC                   eval      $perm = 'Order detail record not found '
650mAC                                   + '(' + %char(lbord) + '/'
650mAC                                   + %char(lbseq) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PT13013'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12014  Label record does not exist.
     *
     C     zm14          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'INVLDLBL'
650mAC                   eval      $perm = 'Invalid label number '
650mAC                                   + '(' + %char(ertrn#) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   move      'PT13014'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12015  Tran not completed - Receive slot doesn't exist.
     *
     C     zm15          begsr
     C                   move      'PT13015'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12016  Tran not completed - Item not in receive slot.
     *
     C     zm16          begsr
     C                   move      'PT13016'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT12017  P.O. detail does not exist.
     *
     C     zm17          begsr
     C                   move      'PT13017'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT13018  Not enough stock in slot.
     *
     C     zm18          begsr
     C                   move      'PT13018'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PT13019  Warning: Entered catch weight not within +/- range.
     *
     C     zm19          begsr
     C                   move      'PT13019'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *    PT13031  Not enough quantity replenished to slot.
     *      Note: PT13032 same msg just formatted to 40 char.
     *
     C     zm31          begsr
     C                   move      'PT13031'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     *
     C                   select
     C                   when      $pcmd = '*CLOSE  '
     C                   move      'PT13032'     #msgid
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ   '
     C                   other
     C                   exsr      zmpmsg
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
520b *    PT13036  Tran cannot be closed - qty > label qty
     *
520b C     zm36          begsr
     C                   move      'PT13036'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
520b C                   endsr
     *----------------------------------------------------------------
510hA*    PT13201  Transaction can not be closed. Item not found.
     *
510hAC     zm01          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'INVLDITM'
650mAC                   eval      $perm = 'Tran cannot be closed, '
650mAC                                   + 'invalid item '
650mAC                                   + '(' + %trim(eritm2) + ')'
650mAC                   leavesr
650mAC                   endif
510hAC                   move      'PT13201'     #msgid
510hAC                   move      '*DIAG  '     #msgtp
510hAC                   movea     errmsg        $md
510hAC                   exsr      zmpmsg
510hAC                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Record does not exist.
     *
     C     zm73          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'INVLDTRN'
650mAC                   eval      $perm = 'Transaction record not found '
650mAC                                   + '(' + %char($ptrn#) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   select
     C                   when      $ptype = '*INTER  '
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ   '
     *
     C                   other
     C                   eval      $prtn = '*INVALID'
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Record is locked.
     *
     C     zm74          begsr
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'TRNLOCK'
650mAC                   eval      $perm = 'Transaction record locked '
650mAC                                   + '(' + %char($ptrn#) + ')'
650mAC                   leavesr
650mAC                   endif
     C                   select
     C                   when      $ptype = '*INTER  '
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ   '
     *
     C                   other
     C                   eval      $prtn = '*LOCKED '
     *
     C                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *     IT13209  Warehouse short qty needed for transfer.
     *
     C     zm3209        begsr
     C                   move      'IT13209'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*PGMQ   '
     C                   endsr
     *----------------------------------------------------------------
     *     PT13030  Transaction closed successfully.
     *
     C     zm30          begsr
     C                   select
     C                   when      $ptype = '*INTER  '
     C                   move      'PT13030'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   eval      $prtn = '*OK     '
     *
     C                   other
     C                   eval      $prtn = '*OKOKOK '
     *
     C                   endsl
     C                   endsr
416 A*----------------------------------------------------------------
416 A*     PT14001  Return exported. Qty change not allowed.
416 A*
416 AC     zm1401        begsr
416 AC                   move      'PT14001'     #msgid
416 AC                   move      '*DIAG  '     #msgtp
416 AC                   eval      $md = *blanks
416 AC                   exsr      zmpmsg
416 AC                   endsr
417fA*----------------------------------------------------------------
417fA*     PT6401   Multi trans, end using task entry.
417fA*
417fAC     zm6401        begsr
417fAC                   move      'PT64001'     #msgid
417fAC                   move      '*DIAG  '     #msgtp
417fAC                   eval      $md = *blanks
417fAC                   exsr      zmpmsg
417fAC                   endsr
     C*----------------------------------------------------------------
417g C*      6403  Flags exists, cannot close transaction.
417g C*
417g C     zm6403        begsr
417g C                   move      'PT64003'     #msgid
417g C                   move      '*DIAG  '     #msgtp
417g C                   eval      $md = *blanks
417g C                   exsr      zmpmsg
417g C                   endsr
     C*----------------------------------------------------------------
500h C*      6406  WORKSOS rec exists, cannot close transaction.
500h C*
500h C     zm6406        begsr
500h C                   move      'PT64006'     #msgid
500h C                   move      '*DIAG  '     #msgtp
500h C                   eval      $md = *blanks
500h C                   exsr      zmpmsg
500h C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   move      *off          error
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck2
     *
     *  Verify quanitity is within range.
     *
     *     Calculate max pick quantity for range.
     C                   eval      mxqty = 0
417a C                   if        lbqpck= 0
417a C                   eval      mxqty = lbqalc
417a C                   else
CBId C                   if        client= cheney
CBId C                   eval      mxqty = lbqalc
CBId C                   else
     C                   eval      mxqty = lbqpck * 10
CBId C                   endif
417a C                   endif
     C                   if        w2qty < 0  or
     C                             w2qty > mxqty
     *R         W2QTY     ORGT 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     mxqty         erto
     *R                   MOVEL'99999'   ERTO
     C                   exsr      zm0112
     C                   endif
     *
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK3   Screen 3 error checking.
     *
     C     zzchk3        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck3
     *
     *  Verify quanitity is within range.
     *
     *     Calculate max pick quantity for range.
     C                   eval      mxqty = 0
417a C                   if        lbqpck= 0
417a C                   eval      mxqty = lbqalc
417a C                   else
CBIbDC*                  if        client= cheney
CWa MC                   if        client= cheney or
CWa MC                             client= citywh
GRC AC                             or client= Greco
CBIbMC                   eval      mxqty = lbqalc
CBIb C                   else
     C                   eval      mxqty = lbqpck * 10
CBIb C                   endif
417a C                   endif
     C                   if        w3qty < 0  or
     C                             w3qty > mxqty
     *R         W3QTY     ORGT 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     mxqty         erto
     *R                   MOVEL'99999'   ERTO
     C                   exsr      zm0112
     C                   endif
     *
     C     endck3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK4   Screen 4 error checking.
     *
     C     zzchk4        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck4
     *
     *  Verify quanitity picked is within range.
     *
     *     Calculate max pick quantity for range.
     C                   eval      mxqty = 0
417a C                   if        lbqpck= 0
417a C                   eval      mxqty = lbqalc
417a C                   else
CBIbDC*                  if        client= cheney
CWa MC                   if        client= cheney or
CWa AC                             client= citywh
GRC AC                             or client= Greco
CBIbMC                   eval      mxqty = lbqalc
CBIb C                   else
     C                   eval      mxqty = lbqpck * 10
CBIb C                   endif
417a C                   endif
     C                   if        w4qpck < 0  or
     C                             w4qpck > mxqty
     *R         W4QPCK    ORGT 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     mxqty         erto
     *R                   MOVEL'99999'   ERTO
     C                   exsr      zm0112
     C                   endif
     *
     *  Verify quanitity replenished is within range.
     *
     C                   if        w4qrpl < 0  or
     C                             w4qrpl > 99999
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     C     endck4        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK5   Screen 5 error checking.
     *
     C     zzchk5        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck5
416hAC     pttask        cabeq     'TFRMOV'      endck5
     *
     *  Verify quantity replenished is within range.
     *
     C                   if        $pcmd <> '*CLOSE  '
     C                   if        w5qrpl < 0  or
     C                             w5qrpl > 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     C                   endif
     *
     *  Grab label record.
     *
     C     lblbl#        chain(n)  label                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endck5
     C                   endif
     *
     *    Verify Available Qty does not go NEGATIVE.
     *    Note: Only test when user is running full system. When user is
     *          on Locator system, there are times when slot will be neg.
     *
     C                   if        w5qrpl <> lbqpck  or
     C                             $pcmd = '*CLOSE  '  and
     C                             opfeat = '2'
     *
     *    Slot record.
     *
     C     keysl2        chain(n)  slot1                              79
     C                   if        *in79
510hAC                             and opfeat <> '3'
510hAC                             and lbdisp > ' '
510hAC                             and lbdisp <> '*NONE'
     *
510hA*  Ignore slot not found error if Stand-alone.
     *
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdsp2
     C                   exsr      zm15
     Csr                 goto      endck5
     C                   endif
510hA*
510hA*    Clear slot quantity fields if slot not found.
510hAC                   if        *in79
510hAC                   eval      slstk1 = 0
510hAC                   eval      slstk2 = 0
510hAC                   eval      slstk3 = 0
510hAC                   eval      slalc1 = 0
510hAC                   eval      slalc2 = 0
510hAC                   eval      slalc3 = 0
510hAC                   eval      slpck1 = 0
510hAC                   eval      slpck2 = 0
510hAC                   eval      slpck3 = 0
510hAC                   eval      sltfr1 = 0
510hAC                   eval      sltfr2 = 0
510hAC                   eval      sltfr3 = 0
510hAC                   eval      slrcv1 = 0
510hAC                   eval      slrcv2 = 0
510hAC                   eval      slrcv3 = 0
510hAC                   endif
     *
     *    Compute change if any in replenishment quantitity.
     *
     C                   eval      difrpl = lbqpck - w5qrpl
500j *    Do not calculate availabe slot quantities for Stand-alone.
500j C     opfeat        cabeq     '3'           endck5
     C                   eval      slrcv1 = slrcv1 - difrpl
     *
     *    Call program to calculate availabe slot quantities.
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
     *   NOTE:  The following tests for available quanties
     *          is being conditioned to not test when the calling
     *          program is LT105. LT105 already does these tests
     *          prior to calling PT132 to close the transaction.
     *          A negative available qty may happen when there
     *          is more than 1 open replenishment transactions
     *          waiting to be processed.
     *
     C                   if        avail1 < 0  and
416aMC                             $pprg <> 'LT105   '  and
416aAC                             $pprg <> 'IT252   '  and
417pAC                             $pprg <> 'PT170A  '  and
416aAC                             $pprg <> 'IT352   '
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = sldisp
     *    Compute minimum quantity needed to close transaction.
     *    Which is quantity we wanted to close with plus quantity
     *    that we are short.
     C                   eval      avail1 = -(avail1)
     C                   eval      erdif = w5qrpl + avail1
     C                   exsr      zm31
     Csr                 goto      endck5
     C                   endif
     C                   endif
     *
     C     endck5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK6   Screen 6 error checking.
     *
650mA*   *** Changes here must be added to ZZCK6A ***
     *
640d *   Note: only one warning will be cleared at a time.
     *
640d *   w6warn values: 0 = Do check.
640d *                  1 = Check was done, ok.
640d *                  2 = Warning condition.
640d *
     C     zzchk6        begsr
     C                   move      *off          error
640dAC                   eval      saveError = *off
     C     $pcmd         cabeq     '*VIEW   '    endck6
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
640dAC                   eval      error = *off
     C                   readc     detail6                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     *     Ignore *PIRPICK labels because there is nothing to check.
     *
     C                   if        w6item = '*PIRPICK'
     C                   iter
     C                   endif
     *
     C                   eval      *in01 = *off
     C                   eval      *in21 = *off
     *
     *     Verify quanitity replenished is within range.
     *
640cA*     If qty changed, clear warning flag and turn off override flag.
640dA
640dMC                   if        w6sqty <> w6qty
640dMC                   eval      w6warn = '0'
640dMC                   eval      ovrrid = *off
640cAC                   endif
640dA
640dAC                   eval      w6sqty= w6qty
640dA
     *     Calculate max pick quantity for range.
     C                   eval      mxqty = 0
640bAC                   select
640bDC*                  if        client= cheney or
640bMC                   when      client= cheney
CBIb C                   eval      mxqty = w6qpck
CWa AC                   when      client= citywh
GRC AC                             or client= Greco
CWa AC                   eval      mxqty = w6qpck
DRYcA*
DRYcAC                   when      client= Dairyland
DRYcAC                   eval      mxqty = 99999
DRYcA*
640bDC*                  else
640bMC                   other
640dMC                   if        w6grp1 = 'S' and w6grp2 = 'S'
640bAC                   eval      mxqty = w6qpck
640bAC                   else
710aDC*                  eval      mxqty = w6qpck * 10
710aMC                   eval      mxqty = w6qpck
     C                   endif
640bAC                   endsl
640bAC*
     C                   if        w6qty < 0  or
     C                             w6qty > mxqty
     *R         W6QTY     ORGT 99999
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     mxqty         erto
     *R                   MOVEL'99999'   ERTO
     C                   exsr      zm0112
     C                   endif
417qA*
417qA*     Qty changes not allowed when item has Runner Flag attached.
500kA*
500kAC                   call      'RU300'
500kAC                   parm      '*STATUS '    $rucmd            8
500kAC                   parm      $pwhse        $ruwhse           3 0
500kAC                   parm      w6lbl#        $rulbl#           7 0
500kAC                   parm      ' '           $rutype           1
500kAC                   parm      ' '           $rustat           1
500kAC                   parm      '        '    $rurtn            8
710bDC*                  if        w6qty <> w6qpck
710bDC*                            and w6mrg = 'F'
710bMC                   if            w6mrg = 'F'
710bAC                             and $rurtn = '*OK'
710bAC                             and $rustat <> 'C'
500kA*
500kA*     or qty change not allowed when Out Flag still open.
710bDC*                            or  w6qty <> w6qpck
710bDC*                            and w6mrg = 'I'
710bMC                             or  w6mrg = 'I'
500kAC                             and $rurtn = '*OK'
500kAC                             and $rustat <> 'C'
417qAC                   eval      error = *on
417qAC                   eval      *in21 = *on
417qAC                   eval      *in01 = *on
417qAC                   eval      errmsg = *blanks
417qAC                   exsr      zm1060
417qAC                   endif
530cA*
530cAC     keyit         chain     piritem
530cAC                   if        not %found(piritem)
530cAC                   eval      cwitcwgt = 'N'
530cAC                   endif
720cAC                   eval      gPltId = w6pal#
720cAC                   exsr      GetGenInfo
530cAC                   if        clsflg = *on
CBInAC                             and flagc1 = *off
530cAC                             and cwitcwgt = 'Y'
530iAC                             and w6mrg <> 'Y'
530iAC                             and w6mrg <> 'F'
530iAC                             and w6mrg <> 'I'
730fAC                   if        client <> cheney
730fMC                             or client = cheney
730fD **                 if   **   client = cheney
CBIjDC**                           and lbpal# <  20000
720cDC**                           and (w6pal# <  20000
720cMC                             and (gGenTruck
CBIjAC                             and w6qpck > 0
CBIjAC                             and w6type <> 'A'
CBIjAC                             and w6asl2 <> '***'
CBIjA*
CBImMC                             or  w6qpck = 0)
CBImDC*                            or  lbqpck = 0)
CBIjA*
530cAC                   eval      $lwhse = $pwhse
530cAC                   eval      $ltrn# = $ptrn#
530cAC                   eval      $litem = w6item
530cAC                   eval      $lseq# = w6seq
530cAC                   eval      $llbl# = w6lbl#
530cAC                   eval      $lcmd = '*EDITCLS'
530cAC                   call      'CW113'
530cAC                   parm                    $lparm
530cAC                   if        $lrtn = '*ERROR'
530cA*
530cAC                   eval      $lcmd  = '*CHKNONE'
530cAC                   eval      $lwhse = $pwhse
530cAC                   eval      $ltrn# = $ptrn#
530cAC                   eval      $litem = w6item
530cAC                   eval      $lseq# = w6seq
530cAC                   eval      $llbl# = w6lbl#
530cAC                   call      'CW112'
530cAC                   parm                    $lparm
530cAC                   if        $lrtn = '*CANCEL'
530cAC                   eval      error = *on
530cAC                   eval      *in21 = *on
530cAC                   eval      *in01 = *on
530cAC                   eval      errmsg = *blanks
530cAC                   movel     desc(6)       errmsg
530cAC                   exsr      zm0105
530cAC                   endif
530cAC                   endif
CBIiAC                   endif
530cAC                   endif
EFCaA
EFCaA*  Extra SOS check for certain clients.
EFCaA*    Warning if qty picked less than qty ordered
EFCaA*               and available qty on hand.
EFCaA
EFCaAC                   if        w6grp1 = 'S' and  w6grp2 = 'S'
EFCaAC                             and error = *off
EFCaA
EFCaAC                   select
EFCaAC                   when      client= eastland
640dA
640dMC                   if        w6warn = '2' and ovrrid = *on
640dMC                   eval      w6warn = '1'
640cAC                   eval      ovrrid = *off
640cAC                   endif
EFCaA
EFCaA*    Get available qty
EFCaAC                   eval      $aprg = #prog
EFCaAC                   eval      $atype = '*INTER  '
EFCaAC                   eval      $awhse = lbwhse
EFCaAC                   eval      $aitem = lbitem
EFCaA*
EFCaAC                   call      'ADJQTY'
EFCaAC                   parm      '*AVAIL  '    $acmd             8
EFCaAC                   parm                    $aprg            10
EFCaAC                   parm                    $atype            8
EFCaAC                   parm                    $awhse            3 0
EFCaAC                   parm                    $aitem           15
EFCaAC                   parm                    $aqty1            7 0
EFCaAC                   parm                    $aqty2            7 0
EFCaAC                   parm                    $aqty3            7 0
EFCaAC                   parm                    $artq1            7 0
EFCaAC                   parm                    $artq2            7 0
EFCaAC                   parm                    $artq3            7 0
EFCaAC                   parm                    $artn             8
EFCaAC                   parm                    $aerm
EFCaAC                   if        $artn = '*PGMQ   '
EFCaAC                   move      *on           error
EFCaAC                   eval      #msgk = $amsg
EFCaAC                   exsr      zmqmsg
EFCaAC                   goto      endck6
EFCaAC                   endif
640dA
640dMC                   if        w6warn <> '1'
640dMC                   eval      w6warn = '1'
EFCaAC                   if        w6qty < w6qpck and $artq1 > 0
EFCaAC                   eval      w6warn = '2'
EFCaAC                   eval      error = *on
EFCaAC                   eval      *in21 = *on
EFCaAC                   eval      *in01 = *on
EFCaAC                   eval      errmsg = *blanks
EFCaAC                   movel     desc(7)       errmsg
EFCaAC                   exsr      zm0105
EFCaAC                   endif
640cAC                   endif
640cA
EFCaAC                   endsl
640cA
EFCaAC                   endif
640dA
640dA*  Looks like we are okay with this record so update it.
640dA
     C                   eval      *in85 = *on
     C                   update    detail6
     C                   if        posrec = 0
     C                   if        *in21
     C                   eval      posrec = recno
     C                   endif
     C                   endif
640dAC                   if        error
640dAC                   eval      saveError = *on
640dAC                   endif
     C                   enddo
     C                   endif
     *
640dAC                   if        posrec = 0
640dAC                   eval      posrec = 1
640dAC                   endif

640dAC                   if        saveError
640dAC                   eval      error = *on
640dAC                   endif
     C     endck6        endsr
650mA*----------------------------------------------------------------
650mA*
650mA*  ZZCK6A   Screen 6 error checking for *UPDSLBL
650mA*
650mA*   *** Changes here may need to be added to ZZCHK6 ***
650mA*
650mAC     zzck6a        begsr
     C                   move      *off          error

     *   Do pick update for each label record.

     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79

     C                   if        *in79
     C                   if        $pcmd = '*UPDSLBL'
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     C                   endif
     C                   leave
     C                   endif

     *    For *UPDSLBL only work with label that was sent

700cD **                 if        $pcmd = '*UPDSLBL' and lblbl# <> $plbl#
700cAC                   if        $pcmd = '*UPDSLBL' and lblbl# <> svplbl#
     C                   iter
     C                   endif

     *    No checks for *PIRPICK labels

     C                   if        lbitem = '*PIRPICK'
     C                   if        $pcmd = '*UPDSLBL'
     C                   leave
     C                   endif
     C                   iter
     C                   endif

     *     Verify quanitity replenished is within range.

     *     Calculate max pick quantity for range.
     C                   eval      mxqty = 0
640bAC                   select
640bMC                   when      client= cheney
CBIb C                   eval      mxqty = lbqalc
CWa AC                   when      client= citywh
GRC AC                             or client= Greco
CWa AC                   eval      mxqty = lbqalc
DRYcA*
DRYcAC                   when      client= Dairyland
DRYcAC                   eval      mxqty = 99999
DRYcA*
640bMC                   other
640dMC                   if        lbgrp1 = 'S' and lbgrp2 = 'S'
640bAC                   eval      mxqty = lbqalc
640bAC                   else
710aDC*                  eval      mxqty = lbqalc * 10
710aMC                   eval      mxqty = lbqalc
     C                   endif
640bAC                   endsl
640bAC*
730dAC                   select
730dAc                   when      $pcmd = '*UPDSLBL'
730dAC                   if        svpqpck < 0  or
730dAC                             svpqpck > mxqty
730dAC                   eval      error = *on
730dAC                   eval      *in21 = *on
730dAC                   eval      *in01 = *on
730dAC                   eval      errmsg = *blanks
730dAC                   movel     desc(1)       erfld
730dAC                   movel     '0'           erfrom
730dAC                   movel     mxqty         erto
730dAC                   exsr      zm0112
730dAC                   leave
730dAC                   endif
730dAc                   other
     C                   if        lbqpck < 0  or
     C                             lbqpck > mxqty
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     mxqty         erto
     C                   exsr      zm0112
     C                   leave
     C                   endif
730dAc                   endsl

530cAC     keyit         chain     piritem
530cAC                   if        not %found(piritem)
650mMC                   eval      itcwgt = 'N'
530cAC                   endif
720cAC                   eval      gPltId = lbpal#
720cAC                   exsr      GetGenInfo
530cAC                   if        clsflg = *on
650mAC                             and itcwgt = 'Y'
530iAC                             and lbtype <> 'M'
530iAC                             and lbvrfy <> 'F'
530iAC                             and lbvrfy <> 'I'
CBIiAC                   if        client = cheney
720cDC**                           and lbpal# <  20000
720cMC                             and gGenTruck

530cAC                   eval      $lwhse = lbwhse
530cAC                   eval      $ltrn# = lbtrn#
530cAC                   eval      $litem = lbitem
530cAC                   eval      $lseq# = lbseq
530cAC                   eval      $llbl# = lblbl#
530cAC                   eval      $lcmd = '*EDITCLS'
530cAC                   call      'CW113'
530cAC                   parm                    $lparm
530cAC                   if        $lrtn = '*ERROR'
530cAC                   eval      error = *on
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ERRCWGT'
650mAC                   eval      $perm = 'Catchweight error'
650mAC                   leave
650mAC                   else
530cAC                   eval      *in21 = *on
530cAC                   eval      *in01 = *on
     C                   eval      errmsg = 'Catchweight error'
530cAC                   exsr      zm0105
650mAC                   leave
650mAC                   endif
530cAC                   endif
CBIiAC                   endif
530cAC                   endif
EFCaA
EFCaA*  Extra SOS check for certain clients.
EFCaA*    Warning if qty picked less than qty ordered
EFCaA*               and available qty on hand.
EFCaA
EFCaAC                   if        lbgrp1 = 'S' and  lbgrp2 = 'S'
EFCaAC                             and error = *off
EFCaA
EFCaAC                   select
EFCaAC                   when      client= eastland
EFCaA
EFCaA*    Get available qty
EFCaAC                   eval      $aprg = #prog
     C                   if        rtnMsgType = 'TEXT'
     C                   eval      $atype = '*BATCH  '
     C                   else
EFCaAC                   eval      $atype = '*INTER  '
     C                   endif
EFCaAC                   eval      $awhse = lbwhse
EFCaAC                   eval      $aitem = lbitem
EFCaA*
EFCaAC                   call      'ADJQTY'
EFCaAC                   parm      '*AVAIL  '    $acmd             8
EFCaAC                   parm                    $aprg            10
EFCaAC                   parm                    $atype            8
EFCaAC                   parm                    $awhse            3 0
EFCaAC                   parm                    $aitem           15
EFCaAC                   parm      0             $aqty1            7 0
EFCaAC                   parm      0             $aqty2            7 0
EFCaAC                   parm      0             $aqty3            7 0
EFCaAC                   parm      0             $artq1            7 0
EFCaAC                   parm      0             $artq2            7 0
EFCaAC                   parm      0             $artq3            7 0
EFCaAC                   parm                    $artn             8
EFCaAC                   parm                    $aerm
640dA
640dMC                   if        $pwarn <> '1'
640dMC                   eval      $pwarn = '1'
700cD **                 if        $pqpck < lbqalc and $artq1 > 0
700cAC                   if        svpqpck < lbqalc and $artq1 > 0
EFCaAC                   eval      $pwarn = '2'
EFCaAC                   eval      error = *on
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'QTYWARN'
650mAC                   eval      $perm = %trim(desc(7))
650mAC                   leave
650mAC                   else
EFCaAC                   eval      *in21 = *on
EFCaAC                   eval      *in01 = *on
EFCaAC                   eval      errmsg = *blanks
EFCaAC                   movel     desc(7)       errmsg
EFCaAC                   exsr      zm0105
650mAC                   leave
650mAC                   endif
EFCaAC                   endif
640cAC                   endif
640cA
EFCaAC                   endsl
640cA
EFCaAC                   endif

     *    For *UPDSLBL only work with label that was sent, so get out.

     C                   if        $pcmd = '*UPDSLBL'
     C                   leave
     C                   endif

     C                   enddo

     C     endck6a       endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK7   Screen 7 error checking.
     *
     C     zzchk7        begsr
     C                   eval      error = *off
     C     $pcmd         cabeq     '*VIEW   '    endck7
     C                   eval      tlcwgt = 0
     *
     *   Verify changed subfile records.
     *
     C                   if        reccnt > 0
     C                   eval      posrec = 0
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail7                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in01 = *off
     C                   eval      *in21 = *off
     *
     *     Accumulate total catch weight entered.
     *
     C                   add       w7cwgt        tlcwgt
     *
     *     Verify quanitity replenished is within range.
     *
     C                   if        w7cwgt < 0  or
     C                             w7cwgt > 99999.99
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(3)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999.99'    erto
     C                   exsr      zm0112
     C                   endif
     *
     C                   eval      *in85 = *on
     C                   update    detail7
     C                   if        posrec = 0
     C                   if        *in21
     C                   eval      posrec = recno
     C                   endif
     C                   endif
     C                   enddo
     *R                   ENDIF
     *
     *     Compare total catchweight to expected catchweight
     *
     C                   if        opwrnc = 'Y'  and
     C                             ovrrid = *off
     C                   if        tlcwgt < lwrng  or
     C                             tlcwgt > hirng
     C                   eval      posrec = 1
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertcwt = tlcwgt
     C                   eval      erlrng = lwrng
     C                   eval      erhrng = hirng
     C                   eval      errg1c = oprg1c
     C                   eval      errg2c = oprg2c
     C                   exsr      zm19
     C                   endif
     C                   endif
     C                   endif
     *
     C     endck7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK8   Screen 8 error checking.
     *
     C     zzchk8        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck8
     *
     *  Verify quanitity replenished is within range.
     *
     C                   if        w8qrpl < 0  or
     C                             w8qrpl > 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     *
     C     endck8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK9   Screen 8 error checking.
     *
     C     zzchk9        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endck9
     *
     *  Verify quanitity replenished is within range.
     *
     C                   if        w9qrpl < 0  or
     C                             w9qrpl > 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
416 A*
416 A*    Verify Return rcd has not been exported.
416 A*
416 AC                   if        oprqch = 'Y'  and
416 AC                             w9qrpl <> lbqpck
416 A*
416 A*    Retrieve return record status.
416 AC                   call      'RN170'
416 AC                   parm      lbwhse        $rwhse            3 0
416 AC                   parm      lbpbat        $rpbat            7 0
416 AC                   parm      lbitem        $ritem           15
416 AC                   parm      *blanks       $rstat            8
416 A*
416 AC                   select
416 A*
416 A*    Changes to return quantity are allowed, but not after export.
416 A*    Return has been exported - Flag error no change to qty allowed.
416 AC                   when      oprqch = 'Y'  and
416 AC                             oprqec = 'N'  and
416 AC                             $rstat = '*EXPORT '
416 AC                   move      *on           error
416 AC                   eval      *in21 = *on
416 AC                   eval      *in01 = *on
416 AC                   exsr      zm1401
416 A*
416 A*    Changes to return quantity are allowed, but not after export.
416 A*    Return has not been exported - Qty change allowed.
416 AC                   when      oprqch = 'Y'  and
416 AC                             oprqec = 'N'  and
416 AC                             $rstat = '*OK     '
416 A*
416 AC                   endsl
416 AC                   endif
     *
     C     endck9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCH10   Screen 10 error checking.
     *
     C     zzch10        begsr
     C                   move      *off          error
     C     $pcmd         cabeq     '*VIEW   '    endc10
     *
     *    Get base item number.
     *
     C                   move      lbwhse        $gwhse
     C                   eval      $gitem = lbitem
     C                   dow       forevr = forevr
     C                   call      'GETBASE'
     C                   parm                    $gwhse            3 0
     C                   parm                    $gitem           15
     C                   parm      ' '           #bitem
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
     *    If item type is not blank, loop again to
     *    get base item.
     *
     C                   select
     C                   when      #bityp = *blanks  or
     C                             #brtn = '*ERROR  '
     C                   leave
     *
     C                   when      #bityp > *blanks
     C                   move      #bitem        $gitem
     C                   endsl
     C                   enddo
     *
     C                   if        #brtn = '*ERROR  '
     C                   eval      #bumq2 = *zeros
     C                   endif
     *
     *    Verify Qty Replenished is a multiple of Qty Picked.
     *
     C                   if        $pcmd <> '*CLOSE  '
     C                   eval      tstrpl = w4qpck * #bumq2
     C                   if        tstrpl <> w4qrpl
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erqrpl = w4qrpl
     C                   eval      erqpck = w4qpck
     C                   eval      erumq2 = #bumq2
     C                   eval      erum2 = woum2
     C                   eval      erum = woum
     C                   exsr      zm0123
     C                   endif
     C                   endif
     *
     *  Verify quanitity picked is within range.
     *
     C                   if        $pcmd <> '*CLOSE  '
     C                   if        w4qpck < 0  or
     C                             w4qpck > 99999
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(1)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     C                   endif
     *
     *  Verify quanitity replenished is within range.
     *
     C                   if        $pcmd <> '*CLOSE  '
     C                   if        w4qrpl < 0  or
     C                             w4qrpl > 99999
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   movel     desc(2)       erfld
     C                   movel     '0'           erfrom
     C                   movel     '99999'       erto
     C                   exsr      zm0112
     C                   endif
     C                   endif
     *
     *  Grab label record.
     *
     C     lblbl#        chain(n)  label                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endc10
     C                   endif
     *
     *    Verify Available Qty does not go NEGATIVE.
     *
     C                   if        w4qrpl <> lbqrmn  or
     C                             $pcmd = '*CLOSE  '
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   eval      sumav1 = 0
500j C                   goto      endc10
500j C                   endif
     *
     *    Slot record.
     *
     C     keysl2        chain(n)  slot1                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdsp2
     C                   exsr      zm15
     Csr                 goto      endc10
     C                   endif
     *
     *    Compute change if any in replenishment quantitity.
     *
     C                   eval      difrpl = lbqrmn - w4qrpl
     C                   eval      slrcv1 = slrcv1 - difrpl
     *
     *    Call program to calculate availabe slot quantities.
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
     C                   parm                    stock1
     C                   parm                    stock2
     C                   parm                    stock3
     *
     C                   parm                    avail1
     C                   parm                    avail2
     C                   parm                    avail3
     *
     C                   if        avail1 < 0  and
416aMC                             $pprg <> 'LT105'     and
416aAC                             $pprg <> 'IT252   '  and
416aAC                             $pprg <> 'IT352   '
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = sldisp
     *    Compute minimum quantity needed to close transaction.
     *    Which is quantity we wanted to close with plus quantity
     *    that we are short.
     C                   eval      avail1 = -(avail1)
     C                   eval      erdif = w4qrpl + avail1
     C                   exsr      zm31
     Csr                 goto      endc10
     C                   endif
     *
     *    Check available warehouse quantity and make sure closing
     *    transaction will not leave negative available quantity or
     *    take quantity allocated to contract item.
     *
     C                   if        lbqpck = *zeros
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     *
     C                   call      'ADJQTY'
     C                   parm      '*AVAIL  '    $acmd             8
     C                   parm                    $aprg            10
     C                   parm                    $atype            8
     C                   parm                    $awhse            3 0
     C                   parm                    $aitem           15
     C                   parm                    $aqty1            7 0
     C                   parm                    $aqty2            7 0
     C                   parm                    $aqty3            7 0
     C                   parm                    $artq1            7 0
     C                   parm                    $artq2            7 0
     C                   parm                    $artq3            7 0
     C                   parm                    $artn             8
     C                   parm                    $aerm
     C                   if        $artn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
     Csr                 goto      endc10
     C                   endif
     *
     C                   eval      sumav1 = 0
     C                   eval      sumav1 = $artq1 - lbqrmn
     *
     *    Cannot close transaction, if the available warehouse qty
     *    is not enough.  Check only when letdown is closed to zero.
     *
     C                   if        sumav1 < 0  and
     C                             $pprg <> 'LT105'
     C                   move      *on           error
     C                   exsr      zm3209
     Csr                 goto      endc10
     C                   endif
     C                   endif
     C                   endif
     *
     C     endc10        endsr
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
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *      F10 - Save & Close
     *
     C                   if        *inkj
     C                   move      *on           clsflg
     C                   else
     C                   move      *off          clsflg
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD3   User defined command keys for screen 3.
     *
     C     zzcmd3        begsr
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *      F10 - Save & Close
     *
     C                   if        *inkj
     C                   move      *on           clsflg
     C                   else
     C                   move      *off          clsflg
     C                   endif
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
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     *      F10 - Save & Close
     *
     C                   if        *inkj
     C                   move      *on           clsflg
     C                   else
     C                   move      *off          clsflg
     C                   endif
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
     C                   move      *off          cmdtkn
     C     endcm5        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD6   User defined command keys for screen 6.
     *
     C     zzcmd6        begsr
     C                   move      *off          cmdtkn
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
EFCbA*
EFCbA*      F20 - Accept Warning.
EFCbA*
EFCbAC                   if        *inku and
EFCbAC                             client= eastland
EFCbAC                   move      *on           ovrrid
EFCbAC                   else
EFCbAC                   move      *off          ovrrid
EFCbAC                   endif
     *
     *      F10 - Save & Close
     *
     C                   if        *inkj
417f C     $ptrn#        chain     multran1                           77
417f C                   if        not *in77 and
417f C                             mustat = '1'
417f C                   move      *on           error
417f C                   move      *off          clsflg
417f C                   exsr      zm6401
417f C                   goto      endcm6
417f C                   else
     *
     C                   move      *on           clsflg
417f C                   endif
730aA*  Prevent user from closing a transaction if it
730aA*  contains an open order audit.
730aAC                   exsr      zzchkordaud
730aAC                   if        error = *on
730aAC                   goto      endcm6
730aAC                   endif
     *  Check for flags
417g C     l90key        setll     label90
417g C     forevr        doweq     forevr
417g C     l90key        reade     label90                                79
417h C                   if        *in79
417h C                   move      *on           clsflg
417h C                   leave
417h C                   endif
417g C                   if        not *in79 and
417g C                             lbvrfy = 'F'
417q C                             or not *in79 and
417q C                             lbvrfy = 'I'
417g C                   move      *on           error
417g C                   move      *off          clsflg
417g C                   exsr      zm6403
417g Csr                 goto      endcm6
417g C                   else
417g *
417g C                   move      *on           clsflg
417g C                   endif
417g C                   enddo
500h *  Check for WORKSOS rec
500h C     wsokey        setll     worksos2
500h C     forevr        doweq     forevr
500h C     wsokey        reade     worksos2                               79
 00h C                   if        *in79
500h C                   move      *on           clsflg
500h C                   leave
500h C                   endif
500h C                   if        not *in79
500h C                   move      *on           error
500h C                   move      *off          clsflg
500h C                   exsr      zm6406
500h Csr                 goto      endcm6
500h C                   else
500h *
500h C                   move      *on           clsflg
500h C                   endif
500h C                   enddo
      *
     C                   else
     C                   move      *off          clsflg
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm6        endsr
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
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   move      *on           ovrrid
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C                   move      *off          cmdtkn
     C     endcm7        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD8   User defined command keys for screen 8.
     *
     C     zzcmd8        begsr
     C                   move      *off          cmdtkn
     C     endcm8        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD9   User defined command keys for screen 9.
     *
     C     zzcmd9        begsr
     C                   move      *off          cmdtkn
     C     endcm9        endsr
     *----------------------------------------------------------------
     *
     *  ZZCM10   User defined command keys for screen 10.
     *
     C     zzcm10        begsr
     C                   move      *off          cmdtkn
     C                   endsr
     *----------------------------------------------------------------
     *
510gA*  ZZCW     Check to see if c/w records exist before calling
510gA*           CW113 and CW112.
     *
510gAC     zzcw          begsr
510gAC                   eval      cwflg = *off
510gAC     keyoc1        setll     ordc1
510gAC                   dow       forevr = forevr
510gAC     keyoc1        reade     ordc1
510gAC                   if        %eof
510gAC                   leave
510gAC                   else
510gAC                   eval      cwflg = *on
510gAC                   leave
510gAC                   endif
510gAC                   enddo
510gAC                   endsr
640 A*
640 A*----------------------------------------------------------------
640 A*
640 A*  ZZCWDEL   Delete c/w records when label has zero qty picked.
640 A*
640 AC     zzcwdel       begsr
640 A*
640 AC     keyoca        setll     ordc
640 AC                   dow       forevr = forevr
640 AC     keyoca        reade     ordc
640 AC                   if        %eof(ordc)
640 AC                   leave
640 AC                   else
640 AC                   delete    ocrec
650eAc                   eval      processstatus = '*DELETE'
650eAc                   exsr      processCWLog
640 AC                   endif
640 AC                   enddo
640 A*
640 AC                   endsr
650cA*
650cA*----------------------------------------------------------------
650cA*
650cA*  ZZEMPTY   Close empty transaction - no label records
650cA*
650cAC     zzempty       begsr
650cA*
650cAC     $ptrn#        chain     pirtran                              78
650cA*
650cAC                   if        *in78 = *off
650cAC                   eval      ptstat = '4'
650cAC                   eval      ptemp# = #emp#
650cAC                   eval      ptshft = #shft
650cAC                   eval      ptcrew = #crew
650cAC                   time                    ptctim
650cAC                   eval      ptcdte = today
650cAC                   update    ptrec
650cAc                   exsr      zzwrttrand
650cAC                   eval      ertrn# = $ptrn#
650cAC                   exsr      zm30
650cAC                   endif
650cA*
650cAC                   endsr
520eA*
520eA*----------------------------------------------------------------
520eA*
520eA*  ZZFGTS   Get Host Stop Number
520eAC*
520eAC     ZZFGTS        BEGSR
520eAC*
520eAC*    Get Stop From RTESTP
520eAC*
520eMC                   z-add     lbStop        $sDSTP
520eAC*
520eAC                   CALL      'GETSTOP'
520eMC                   PARM      '*ORDSTP '    $sCMD             8
520eMC                   PARM      lbwhse        $sWHSe            3 0
520eMC                   PARM      lbrte         $sRTID            5
520eMC                   PARM      lbord         $sORD             7 0
520eMC                   PARM                    $sDSTP            2 0
520eMC                   PARM                    $sSTP             5 0
710cAc                   parm                    $pDdrop           3
710cAc                   parm                    $pDextd          30
710cAc                   parm                    $pDsd             9
520eAC*
520eAC                   ENDSR
520eAC*
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     C                   eval      w2qty = lbqpck
416cAC                   eval      trqpck = lbqpck
416cAC                   z-add     lbord         w2ord
416cAC                   move      lbitem        w2item
520eA*
520eAC                   exsr      zzfgts
520eAC                   if        $sstp > 0
520eAC                   eval      dspstp = $sstp
520eAC                   else
520eAC                   eval      dspstp = lbstop
520eAC                   endif
520eA*
     C                   move      *off          wgtflg
     C                   if        itcwgt = 'Y'
     C                   move      *on           wgtflg
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL3   Fill screen 3 fields with info from file.
     *
     C     zzfil3        begsr
416cAC                   z-add     lbord         w2ord
416cAC                   move      lbitem        w2item
520eA*
520eAC                   exsr      zzfgts
520eAC                   if        $sstp > 0
520eAC                   eval      dspstp = $sstp
520eAC                   else
520eAC                   eval      dspstp = lbstop
520eAC                   endif
520eA*
     C                   eval      w3qty = lbqpck
416cAC                   eval      trqpck = lbqpck
     C                   move      *off          wgtflg
     C                   if        itcwgt = 'Y'
     C                   move      *on           wgtflg
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL4   Fill screen 4 fields with info from file.
     *
     C     zzfil4        begsr
416cAC                   z-add     lbord         w4ord
416cAC                   move      lbitem        w4item
520eA*
520eAC                   exsr      zzfgts
520eAC                   if        $sstp > 0
520eAC                   eval      dspstp = $sstp
520eAC                   else
520eAC                   eval      dspstp = lbstop
520eAC                   endif
520eA*
     C                   eval      w4qpck = lbqpck
416cAC                   eval      trqpck = lbqpck
     C                   eval      w4qrpl = lbqrmn
     C                   move      *off          wgtflg
     C                   if        itcwgt = 'Y'
     C                   move      *on           wgtflg
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL5   Fill screen 5 fields with info from file.
     *
     C     zzfil5        begsr
     C                   eval      w5qrpl = lbqpck
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL6   Fill screen 6 fields with info from file.
     *
     C     zzfil6        begsr
730gAC                   eval      kywhse = lbwhse
730gAC                   eval      kyitem = lbitem
730gAC                   exsr      zzitem
     *
     *   Get pallet record for transaction.
     *
     C     $ptrn#        setll     pltsum4
     C     $ptrn#        reade     pltsum4                                75
     C                   if        *in75
     C                   eval      psszon = *blanks
     C                   eval      w6zdsc = *blanks
     C                   eval      w6ptyp = *blanks
     C                   else
     C                   eval      w6zdsc = *blanks
     C                   if        psgen = 1
     C                   eval      w6ptyp = 'Truck'
     C                   else
     C                   eval      w6ptyp = 'Stage'
     C                   endif
     C                   endif
     *
     *   Load detail into subfile.
     *
     C                   move      *off          wgtflg
     C                   move      *off          tmpflg
     C                   eval      pckcnt = 0
     C                   eval      w6line = 0
     C                   exsr      sflclr
720dDC**                 if        pstype = 'O'
720dMC                   if        pstype = tbPalletType
     C     keylb7        setll     label71
     C                   else
     C     keylb7        setll     label7
     C                   endif
     C                   dou       forevr <> forevr
720dDC**                 if        pstype = 'O'
720dMC                   if        pstype = tbPalletType
     C     keylb7        reade     label71                                79
     C                   else
     C     keylb7        reade     label7                                 79
     C                   endif
     C                   if        *in79
     C                   leave
     C                   endif
417cA
417cA*    Skip Adjustment label records (created by closing OUT's).
417cA
417cAC                   if        lbtype = 'A'
417cAC                   iter
417cAC                   endif
417bA*
417bA*    Skip items that were outed during allocate/pick processing.
417bAC                   if        lbvrfy = '0'
417bAC                   iter
417bAC                   endif
520gA*
520gAC                   if        lbitem = '9999999999'
520gAC     keyod         chain     orddm
520gAC                   if        %found(orddm)
520gAC                   eval      rtxdm1_base = ommsc1
520gAC                   if        rtxdm1_omcwcd = 'Y'
520gAC                   eval      itcwgt = 'Y'
520gAC                   endif
520gAC                   endif
520gAC                   endif
417bA*
417bA*    Reverse image 'OUT' label records.
417bAC                   if        lbasl2 = 'OUT'
417lAC                   eval      w6out = *on
417bAC                   eval      *in65 = *on
417bAC                   else
417bAC                   eval      *in65 = *off
417lAC                   eval      w6out = *off
417bAC                   endif
417bA*

720aA*    Color item pink if item has been subbed
720aA /free

720aA   setll ($pwhse: lbord) ordd1;

720aA   dou forever <> forever;

720aA     reade ($pwhse: lbord) ordd1;
720aA     *in35 = *off;
720aA     hldi35 = *off;
720aA     if %eof(ordd1);
720aA       leave;
720aA     endif;

720aA     //  If you find an 'original item' value that matches the label item
720aA     //  then you've got a line item which has been subbed ... color it pink

720aA     if lbitem = od1_odoitm;
720aA       *in35 = *on;
720aA       hldi35 = *on;
720aA       *in36 = *on;
720aA       leave;
720aA     endif;

720aA   enddo;

720aA /end-free

     C                   if        tmpflg = *off
     *          LBSTYP    IFEQ 'P'
     *                    MOVE 'PIR  '   W6SECT
     *                    ELSE
     *                    MOVE 'Fixed'   W6SECT
     *                    ENDIF
     C                   move      *on           tmpflg
     C                   endif
     C                   add       1             w6line
     C                   eval      w6lbl# = lblbl#
416cAC                   eval      w6ord = lbord
610 DC*                  z-add     lbseq         w6seq
610 MC                   z-add (h) lbseq         w6seq
TMP DC**                 z-add     lbseq         w6orsq
     C                   eval      w6item = lbitem
     C                   eval      w6stop = lbstop
520eA*
520eAC                   exsr      zzfgts
520eAC                   if        $sstp > 0
640iDC*****              eval      dspstp = $sstp
640iMC                   eval      dspstp =
640iMC                               %dec(%subst(%editc($sstp:'X'):3:3):3:0)
520eAC                   else
520eAC                   eval      dspstp = lbstop
520eAC                   endif
520eA*
     C                   eval      w6disp = lbdisp
     C                   if        itcwgt = 'Y'
     C                   eval      w6cwgt = 'Y'
     C                   eval      wgtflg = *on
     C                   else
     C                   eval      w6cwgt = ' '
     C                   endif
     C                   if        lbstat = 'C'
     C                   eval      w6stat = 'Y'
     C                   else
     C                   eval      w6stat = ' '
     C                   endif
     C                   eval      woum = umshrt
     *R                   Z-ADDLBQPCK    W6QPCK
     C                   eval      w6qpck = lbqalc
     C                   eval      w6qty = lbqpck
      *
     C                   if        lbtype = 'M'
     C                   eval      w6mrg = 'Y'
     C                   else
     C                   eval      w6mrg = ' '
     C                   endif
      *
417g C                   if        lbvrfy = 'F'
417g C                   eval      w6mrg = 'F'
417g C                   endif
      *
417q C                   if        lbvrfy = 'I'
417q C                   eval      w6mrg = 'I'
417q C                   endif
      *
     C                   eval      *in85 = *on
     C                   if        lbitem = '*PIRPICK'
     C                   eval      *in90 = *on
     C                   add       1             pckcnt
     C                   endif
CBId C                   if        client = cheney
CBId C                   movel     ohmisc        dsmisc
CBId C                   endif
CBId C                   if        client = cheney
CBId C                   if        lbtype = 'M'
CBId C                             or dsmeat = 'Y'
CBId C                             or dsppck = 'Y'
CBId C                   eval      *in90 = *on
CBId C                   endif
CBId C                   else
     C                   if        lbtype = 'M'
     C                   eval      *in90 = *on
     C                   endif
CBId C                   endif
     *
     C     rtkey         chain     rtehed                             77
     C                   if        not *in77
     C                   eval      w6rte = rhrte
     C                   else
     C                   eval      w6rte = *blanks
CBIe C                   if        client = cheney
CBIeAC                   eval      rhtruk = ohtruk
CBIe C                   endif
     C                   endif

CBIeA*  See if we should prevent user from changing the quantity.

CBIe C                   if        client = cheney
CBIg C**                 if        rhtruk = 'MEAT-INSP'
CBIg C**                           or rhtruk = 'PRE-PICK'
CBIg C**                           or rhtruk = 'CONTAINER'
600bMC     #curruser     chain     pt640usr
CBIeAC                   if        not %found
CBIeAC                   eval      *in90 = *on
CBIeAC                   endif
CBIg C**                 endif
CBIeAC                   endif
530dA*  See if we should prevent user from changing the quantity.
530dAC                   if        lbstat = 'C'
530dAC                             and  lbtype = 'O'
530dAC                             or   lbstat = 'C'
530dAC                             and  lbtype = 'B'
530dAC                   eval      *in90 = *on
530dAC                   endif

730gA*
730gA*   Do not allow change for a UCI Selection item
730gAC                   if        $ifsltmth = '2'
730gAC                   eval      *in90 = *on
730gAC                   endif

640dA*  Initialize warning flag.
640dA
640dAC                   eval      w6warn = '0'

640dA*  Save label group fields
640dA*    Yes, looks silly. LABEL7 doesn't include the GRP fields
640dA*    and we didn't want to change the file.
640dA
640cAC     lblbl#        chain(n)  label
640dAC                   if        %found(label)
640dAC                   eval      w6grp1 = lbgrp1
640dAC                   eval      w6grp2 = lbgrp2
640dAC                   else
640dAC                   eval      w6grp1 = ' '
640dAC                   eval      w6grp2 = ' '
640dAC                   endif
700eA*
700eAC                   eval      w6type = lbtype
700eAC                   eval      w6pal# = lbpal#
700eAC                   eval      w6asl2 = lbasl2
     *
     C                   exsr      sfladd
     *          LBITEM    IFEQ '*PIRPICK'
     *          $PCMD     ANDNE'*VIEW   '
     C                   if        $pcmd <> '*VIEW   '
     C                   eval      *in90 = *off
     C                   endif
     C                   enddo
     *
     C                   eval      posrec = 1
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL7   Fill screen 7 fields with info from file.
     *
     C     zzfil7        begsr
     *
     C                   if        lbstyp = 'P'
     C                   eval      w7sect = 'PIR  '
     C                   else
     C                   eval      w7sect = 'Fixed'
     C                   endif
     *
     C     rtkey         chain     rtehed                             77
     C                   if        not *in77
     C                   eval      w7rte = rhrte
     C                   else
     C                   eval      w7rte = *blanks
     C                   endif
520eA*
520eAC                   exsr      zzfgts
520eAC                   if        $sstp > 0
520eAC                   eval      dspstp = $sstp
520eAC                   else
520eAC                   eval      dspstp = lbstop
520eAC                   endif
520eA*
     *
     *   If verify catch weight = yes,
     *     Calculate total expected catch weight,
     *     Calculate low/high ranges.
     C                   if        opwrnc = 'Y'
     C                   eval      lwvar = 0
     C                   eval      hivar = 0
     C                   eval      lwrng = 0
     C                   eval      hirng = 0
     C                   eval      exwgt = 0
     C     lbqpck        mult      lbuwgt        exwgt
     C     oprg1c        div       100           prg1c
     C     oprg2c        div       100           prg2c
     *
     C                   if        oprg1c > 0
     C                   eval      lwvar = exwgt * prg1c
     C                   endif
     C                   eval      lwrng = exwgt - lwvar
     C                   if        oprg2c > 0
     C                   eval      hivar = exwgt * prg2c
     C                   endif
     C                   eval      hirng = exwgt + hivar
     *
     C                   endif
     *
     C                   exsr      sflclr
     *
     C     1             do        lbqpck        w7line
     C     keyoc         chain     ordc                               79
     C                   if        not *in79
     C                   eval      w7cwgt = occwgt
     C                   else
     C                   eval      w7cwgt = 0
     C                   endif
     C                   exsr      sfladd
     C                   enddo
     *
     C                   eval      posrec = 1
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL8   Fill screen 8 fields with info from file.
     *
     C     zzfil8        begsr
     C                   if        $pcmd = '*ZERO   '
     C                   eval      w8qrpl = 0
     C                   else
     C                   eval      w8qrpl = lbqpck
     C                   endif
     *
     C                   move      lbwhse        kywhse
     C                   move      lbitem        kyitem
     C                   exsr      zzitem
     C                   movel     #bitem        w8item
     C                   eval      w8desc = #bdesc
     *
     C     lckey         chain     license1                           79
     C                   if        not *in79
     C                   eval      w8lcn# = lilcns
     C                   else
416jAC                   eval      lilcns = *blanks
416jDC**                 eval      w8lcn# = 0
416jMC                   eval      w8lcn# = *blanks
     C                   endif
530bA*  Get pick slot for item
530bA*
530bAC                   eval      $scmd = '*FIRST  '
530bAC                   call      'GETPSLT'
530bAC                   parm                    $scmd             8
530bAC                   parm      lbwhse        $swhse            3 0
530bAC                   parm      lbitem        $sitem           15
530bAC                   parm      *blanks       woslot           12
530bAC                   parm      *blanks       $saisl            3
530bAC                   parm      *zeros        $sloc             3 0
530bAC                   parm      *zeros        $srlvl            2 0
530bAC                   parm      *blanks       $shand            2
530bAC                   parm      *blanks       $srtn             8
530bA*
530bAC                   if        $srtn = '*OKPICK '
530bAC                   move      woslot        wddesc
530bAC*                  else
530bAC*                  eval      w8disp = '*NONE       '
530bAC                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL9   Fill screen 9 fields with info from file.
     *
     C     zzfil9        begsr
417kA*
417kAC                   move      lbwhse        kywhse
417kAC                   move      lbitem        kyitem
417kAC                   exsr      zzitem
417kAC                   movel     #bitem        w9item
417kAC                   eval      w9desc = #bdesc
417kA*
417kAC     lckey         chain     license1                           79
417kAC                   if        not *in79
417kAC                   eval      w9lcn# = lilcns
417kAC                   else
417kAC                   eval      lilcns = *blanks
417kMC                   eval      w9lcn# = *blanks
417kAC                   endif
417kA*
     C                   eval      w9qrpl = lbqpck
530gA*  Get pick slot for item
530gA*
530gAC                   eval      $scmd = '*FIRST  '
530gAC                   call      'GETPSLT'
530gAC                   parm                    $scmd             8
530gAC                   parm      lbwhse        $swhse            3 0
530gAC                   parm      lbitem        $sitem           15
530gAC                   parm      *blanks       woslot           12
530gAC                   parm      *blanks       $saisl            3
530gAC                   parm      *zeros        $sloc             3 0
530gAC                   parm      *zeros        $srlvl            2 0
530gAC                   parm      *blanks       $shand            2
530gAC                   parm      *blanks       $srtn             8
530gA*
530gAC                   if        $srtn = '*OKPICK '
530gAC                   move      woslot        wddesc
530gAC                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFI10   Fill screen 10 fields with info from file.
     *
     C     zzfi10        begsr
     C                   eval      w4qpck = lbqpck
     C                   eval      w4qrpl = lbqrmn
     *R                   CALL 'GETFULL'
     *R                   PARM LBWHSE    $GWHSE  30
     *R                   PARM LBITEM    $GITEM 15
     *R                   PARM ' '       WOITM2 15
     *R                   PARM           $GDESC 30
     *R                   PARM           $GPDSC 15
     *R                   PARM           $GWHDP  5
     *R                   PARM           $GSTYP  1
     *R                   PARM           $GUM    2
     *R                   PARM           $GUM2   2
     *R                   PARM           $GUMQ2  30
     *
     C                   move      lbwhse        kywhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     *
     C                   if        ittype = 'C'
     C                   eval      woitm2 = #bcitm
     C                   move      #bcum         $gum
     C                   else
     C                   move      #bitem        woitm2
     C                   move      #bum          $gum
     C                   endif
     C     $gum          chain     unmesr                             77
     C                   if        *in77
     C                   eval      woum = *blanks
     C                   movel     $gum          woum
     C                   eval      woum3 = woum
     C                   else
     C                   eval      woum = umshrt
     C                   eval      woum3 = umshrt
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
     *
     *   Get record from main file.
     *
417r *   No longer want to lock record.
     C                   if        $pcmd = '*VIEW   '
     C     $ptrn#        chain(n)  pirtran                            7978
     C                   else
417rMC     $ptrn#        chain(n)  pirtran                            7978
417rDC*    $ptrn#        chain     pirtran                            7978
     C                   endif
     *
     *  Record locked.
     *
     C                   if        *in78
     C                   move      *on           error
     C                   exsr      zm74
     Csr                 goto      endgt1
     C                   endif
     *
     *  Record not found.
     *
     C                   if        *in79
     C                   move      *on           error
     C                   exsr      zm73
     Csr                 goto      endgt1
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
500fA
500fA* Get client id.
500fA
500fAC                   call      'GETCLIENT'
500fAC                   parm                    client           10

     *
     *  Define save fields for different item types.
     *
     C                   eval      #otype = *blanks
     *
     *  Define partial key for LABEL7 file.
     *
     C     keylb7        klist
     C                   kfld                    $ptrn#
     *
     *  Define key for SLOT1 file.
     *
     C     keysl1        klist
     C                   kfld                    lbwhse
     C                   kfld                    lbwhdp
     C                   kfld                    lbaisl
     C                   kfld                    lbloc
     C                   kfld                    lbrlvl
     C                   kfld                    lbhand
     *
     *  Define key for SLOT1 file.
     *
     C     keysl2        klist
     C                   kfld                    lbwhs2
     C                   kfld                    lbwhd2
     C                   kfld                    lbasl2
     C                   kfld                    lbloc2
     C                   kfld                    lblvl2
     C                   kfld                    lbhnd2
     *
     *  Define key for ORDD file.
     *
     C     keyod         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     *
     *  Define key for ORDC file.
     *
     C     keyoc         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbord
     C                   kfld                    lbseq
     C                   kfld                    lbitem
510fDC**                 kfld                    lbtrn#
510fMC                   kfld                    lblbl#
     C                   kfld                    w7line
640 A*
640 AC     keyoca        klist
640 AC                   kfld                    lbwhse
640 AC                   kfld                    lbord
640 AC                   kfld                    lbseq
640 AC                   kfld                    lbitem
640 AC                   kfld                    lblbl#
     *
510gA*  Define key for ORDC1 file.
     *
510gAC     keyoc1        klist
510gAC                   kfld                    $pwhse
510gAC                   kfld                    lblbl#
520f *
520f *  Define key for ORDH file.
520f *
520f C     keyoh         klist
520f C                   kfld                    kywhse
520f C                   kfld                    kyord
     *
     *  Define key for POD file.
     *
     C     keypd         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbpo
     C                   kfld                    lbseq
     C                   kfld                    lbitem
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
530cMC                   kfld                    $pwhse
530cMC                   kfld                    w6item
530cD ***                kfld                    kywhse
530cD ***                kfld                    kyitem
     *R                   KFLD           SLWHSE
     *R                   KFLD           SLITEM
     *
     *  Define key for RTEHED file.
     *
     C     rtkey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbrte
     *
     *  Define partial key for OPTIONS file.
     *
     C     keyop         klist
     C                   kfld                    $pwhse
     C                   kfld                    opcode
     *  Define partial key for ORDSLCT file.
     *
     C     slctky        klist
     C                   kfld                    $pwhse
     C                   kfld                    pttrn#
     *
     *  Define key for OPTIONS file.
     *
     C     opkey         klist
     C                   kfld                    wkwhse
     C                   kfld                    wkcode
     *
417g *  Define key for OPTIONS file.
     *
417g C     l90key        klist
417g C                   kfld                    $pwhse
417g C                   kfld                    $ptrn#
650dA*
650dAC     keyS3         klist
650dAC                   kfld                    slWhse
650dAC                   kfld                    slItem
650iDC*                  kfld                    slStat
650iDC*                  kfld                    slPick
650iMC                   kfld                    s3_slStat
650iMC                   kfld                    s3_slPick
650dA*
500h *  Define key for WORKSOS2 file.
     *
500h C     wsokey        klist
500h C                   kfld                    $pwhse
500h C                   kfld                    $ptrn#
     *R  Following code was moved to ZZINZ2
     *R         OPKEY     CHAINOPTIONS              79
     *R         *IN79     IFEQ *ON
     *R                   MOVE 'Y'       OPCAPC
     *R                   MOVE 'N'       OPWRNC
     *R                   Z-ADD0         OPRG1C
     *R                   Z-ADD0         OPRG2C
     *R                   ENDIF
     *  Define key for LICENSE File.
     *
     C     lckey         klist
     C                   kfld                    lbwhse
     C                   kfld                    lbtrn#
     **
     ** Convert today's date into century format.
     **
     **                   MOVE '*CURCMD '$CVCMD
     **                   CALL @CVTDT
     **                   PARM           $CVTDT
     **                   Z-ADD$CVD8O    TODAY   80
     *
     C                   move      *off          clsflg
720bA
720bA *   Setup Dakota GUI User if populated
720bAc                   if        $pguiUser <> *blanks
720bAc                   eval      newUser = $pguiUser
720bAc                   else
720bAc                   eval      newUser = #curruser
720bAc                   endif
750aAc*    moved the get user code into zzinzusr - have the need to
750aAc*    execute it more than at program init.
750aAc                   exsr      zzinzusr
     *
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     C                   move      *off          error
     C                   move      *off          wrgitm
416lAC                   eval      lilcns = *blanks
720aAC                   eval      *in36 = *off
750aA
750aA *   Setup Dakota GUI User if populated
750aAc                   if        $pguiUser <> *blanks and
750aAc                             $pguiUser <> newUser
750aAc                   eval      newUser = $pguiUser
750aAc                   exsr      zzinzusr
750aAc                   endif

700cA*  Move passed in fields to save fields for duration of processing.
700cA*  Fields were getting corrupted when error message data loaded
700cA*  into $PERM.
700cA
700cAC                   if        $pcmd = '*UPDSLBL'
700cAC                   eval      svplbl# = $plbl#
700cAC                   eval      svpqpck = $pqpck
730hAC                   eval      savelabel = $plbl#
730hA /free
730hA
730hA  monitor;
730hA    umWhse = lbwhse;
730hA    umlabel('*GET': umRtnCode: umRtnMsg:
730hA            $pWhse: savelabel:
730hA            umFlexPickFlag:
730hA            lbualq1: lbualu1: lbualq2: lbualu2: lbualq3: lbualu3);
730hA  on-error;
730hA    umRtnCode = '*ERROR';
730hA  endmon;
730hA
730hA  if umRtnCode = '*OK';
730hA    select;
730hA      when umFlexPickFlag = 'P2W';
730hA        pick2lbs = lbswgt;
730hA      when umFlexPickFlag = 'PAQ';
730hA    endsl;
730hA  endif;
730hA
730hA /end-free
700cAC                   endif

650mA*  Get out if label # is not passed in for *UPDSLBL
650mA
650mAC                   if        $pcmd = '*UPDSLBL'
650pDC*                            and (%parms < 9 or $plbl# <= 0)
700cAC                             and svplbl# <= 0
700cD **                           and $plbl# <= 0
650mAC                   eval      error = *on
650mAC                   eval      $prtn = '*NOLBL'
650mAC                   eval      $perm = 'Label parameter must be sent '
650mAC                                   + 'for *UPDSLBL'
650mAC                   leavesr
650mAC                   endif

650mA*  Set return message type from $prtn value
650mA
650mAC                   eval      rtnMsgType = $prtn
650nAC                   eval      $prtn = ' '
650oA*
650pDC*                  if        $pcmd = '*UPDSLBL'
650pDC*                  eval      $perm = ' '
650pDC*                  endif
     *
     *  Convert today's date into century format.
     *
     C                   exsr      zzzdte
     *
     *  Initialize close flag.
     *
     *    This flag is currently only being used for closing
     *    picking transactions. For all other transactions
     *    it will be set to *ON.
     *
     C                   move      *off          clsflg
     *
     C                   move      '*SYSTEM '    wkcode
     C                   eval      wkwhse = 0
     C     opkey         chain     options                            79
     C                   eval      sysopt = opdata
     C                   if        *in79
     C                   eval      opcapc = 'Y'
     C                   eval      opwrnc = 'N'
     C                   eval      oprg1c = 0
     C                   eval      oprg2c = 0
     C                   endif
     *    Get Feature options from options file.
     C                   eval      opcode = '*FEATURE'
     C     keyop         chain     options                            79
     C                   eval      ftropt = opdata
     C                   if        *in79
     C                   eval      opfeat = '2'
     C                   endif
416 A*    Get return options from options file.
416 AC                   eval      opcode = '*RETURNS'
416 AC     keyop         chain     options                            79
416 AC                   eval      rtnopt = opdata
416 AC                   if        *in79
416 AC                   eval      oprqch = 'Y'
416 AC                   eval      oprqec = 'N'
416 AC                   endif
416iA*    Get GENPICK options from options file.
416iAC                   eval      opcode = '*GENPICK'
416iAC     keyop         chain     options                            79
416iAC                   eval      genopt = opdata
416iAC                   if        *in79
416iAC                   eval      operpt = 'Y'
416iAC                   eval      opelbl = 'N'
416iAC                   eval      oprfwc = 'N'
416iAC                   eval      opnrsc = 1
416iAC                   eval      ophpwc = 'N'
416iAC                   eval      opeadj = 'N'
416iAC                   endif
     *    Get close options from options file.
     C                   eval      opcode = '*CLOSE  '
     C     keyop         chain     options                            79
     C                   eval      clsopt = opdata
     C                   if        *in79
     C                   eval      opexcd = 'X1'
     C                   eval      opnscd = 'X2'
     C                   eval      opdicd = 'X3'
     C                   endif
     *
640aA*   Get FTP options from options file.
640aA*
640aAC                   eval      wkwhse = 0
640aAC                   eval      wkcode = '*FTP    '
640aAC     opkey         chain     options                            79
640aAC                   eval      ftpopt = opdata
640aAC                   if        *in79
640aAC                   eval      opftp = 'N'
640aAC                   endif
     *
CBIf *
CBIf *   Set No Catch Weight Check flag.
CBIf *   Only set on if called with *CLOSENC
CBIf C                   if        client = cheney
CBIf C                   if        $pcmd = '*CLOSENC'
CBIf C                   eval      flagnc = *ON
CBIf C                   eval      $pcmd = '*CLOSE  '
CBIf C                   else
CBIf C                   eval      flagnc = *OFF
CBIf C                   endif
CBIf C                   endif
CBIn
CBIn *   Special Cheney close
CBIn
CBIn C                   if        client = cheney
CBIn C                   if        $pcmd = '*CLOSEC1'
CBIn C                   eval      flagc1 = *ON
CBIn C                   eval      $pcmd = '*CLOSE  '
CBIn C                   else
CBIn C                   eval      flagc1 = *OFF
CBIn C                   endif
CBIn C                   endif
     *
     *   Get transaction record.
     *
     C                   exsr      zzget1
     C                   if        error = *on
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE *BLANKS   LGTASK
     **                   Z-ADD0         LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD2606      LGLINE
     **                   WRITELGREC
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endzi2
     C                   endif
     *
     *   Initialize the screen variables no matter what.
     *
     *   If we are only trying to close a transaction then we skip
     *   the entry screen and go directly to update.
     *
     C                   move      *on           refrsh
     C                   move      *off          flag8
650cAC                   move      *off          foundlabel
     C     keylb7        setll     label7
     C     more8         tag
     C     keylb7        reade     label7                                 79
416hD*R         *IN79     CABEQ*ON       ENDIT2           Added in 409d
416hD*
416hDC*                  if        not *in79  and
416hDC*                            lbstat = 'C'
416hDC*r                 goto      more8
416hDC*                  endif
416dA*
     C                   if        *in79
     **         FLAG8     IFEQ *OFF
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE *BLANKS   LGTASK
     **                   Z-ADD0         LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD2620      LGLINE
     **                   WRITELGREC
     **                   ENDIF
650cAC                   if        not foundlabel
650cAC                             and $pcmd = '*CLOSE'
650cAC                   if        pttask = 'FIXED'
650cAC                             or pttask = 'PIR'
650cAC                             or pttask = 'BULKF'
650cAC                   exsr      zzempty
650cAC                   endif
650cAC                   endif
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endit2
     C                   endif
416cA*
650cAC                   move      *on           foundlabel
416cAC                   eval      trcode = *blanks
416cAC                   eval      trdata = *blanks
416cAC                   eval      trnbr = *blanks
416cAC                   eval      cvt5a = *blanks
416cAC                   eval      trqpck = *zeros
416cAC                   move      *off          trerr
     *
     C                   if        lbstat = 'C'
     C                   eval      wostat = 'Closed'
     C                   else
     C                   eval      wostat = 'Open  '
     C                   endif
     *
     C                   eval      woum = umshrt
     C                   eval      woum2 = umshrt
     C                   eval      woum3 = umshrt
     C                   eval      woum4 = umshrt
     *
     C                   select
     *
     *       Bulk pick - Full pallet.
     *
     *          PTTYPE    WHEQ 'BF'
     C                   when      pttask = 'BULKF '
417 DC*                  exsr      scr02i
650mAC                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
417 MC                   exsr      scr06i
650mAC                   endif
     C                   if        $pcmd = '*CLOSE  '  or
     C                             $pcmd = '*VRFYCW '
     C                   move      *on           clsflg
417 DC*                  exsr      zzupd2
650mAC                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
650mAC                   exsr      zzchk6
650mAC                   if        error = *on
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   eval      $prtn = '*ERROR'
650mAC                   eval      $perm = 'Transaction Close process Canceled'
650mAC                   goto      endzi2
650mAC                   endif
417 MC                   exsr      zzupd6
650mAC                   else
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
650mAC                   exsr      zzup6a
650mAC                   endif
650mAC                   endif
     C                   endif
650mAC                   if        $pcmd = '*UPDSLBL'
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
650mAC                   exsr      zzup6a
650mAC                   endif
650mAC                   endif
700gAC                   if        $pcmd = '*CLOSEV '
700gAC                   move      *on           clsflg
700gAC                   exsr      zzup6v
700gAC                   endif
     *
     *       Bulk pick - Partial pallet.
     *
     *          PTTYPE    WHEQ 'BP'
     C                   when      pttask = 'BULKP '
417 DC*                  exsr      scr03i
650mAC                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
417 MC                   exsr      scr06i
650mAC                   endif
     C                   if        $pcmd = '*CLOSE  '  or
     C                             $pcmd = '*VRFYCW '
     C                   move      *on           clsflg
417 DC*                  exsr      zzupd3
650mAC                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
650mAC                   exsr      zzchk6
650mAC                   if        error = *on
650mAC                   move      'EOJ'         nxtscr
650mAC                   eval      $prtn = '*ERROR'
650mAC                   eval      $perm = 'Transaction Close process Canceled'
650mAC                   goto      endzi2
650mAC                   endif
417 MC                   exsr      zzupd6
650mAC                   else
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
650mAC                   exsr      zzup6a
650mAC                   endif
650mAC                   endif
     C                   endif
650mAC                   if        $pcmd = '*UPDSLBL'
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
650mAC                   exsr      zzup6a
650mAC                   endif
650mAC                   endif
700gAC                   if        $pcmd = '*CLOSEV '
700gAC                   move      *on           clsflg
700gAC                   exsr      zzup6v
700gAC                   endif
     *
     *       Bulk pick with replenishment.
     *
     *          PTTYPE    WHEQ 'BR'
     C                   when      pttask = 'BULKR '
     C                   exsr      scr04i
     C                   if        $pcmd = '*CLOSE  '  or
     C                             $pcmd = '*VRFYCW '
     C                   move      *on           clsflg
     C                   exsr      zzupd4
417 A*
417 A*    Bulk picks support multiple label records. Loop
417 A*    to ensure all are closed.
417 ACSR                 eval      Flag8  = *ON
417 ACSR                 eval      Refrsh = *ON
417 ACSR                 goto      More8
     C                   endif
     *
     *       Replenishment/Transfer.
     *
     *          PTTYPE    WHEQ 'RP'
     C                   when      pttask = 'REPL  '  or
     C                             pttask = 'TFRMOV'  or
     C                             pttask = 'REPLTF'
     C                   move      *on           clsflg
     C                   exsr      scr05i
     C                   if        $pcmd = '*CLOSE  '
     C                   exsr      zzchk5
     *
     *    We force EOJ here because calling pgm is a RF pgm and
     *    may not be able to display error screen.
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   else
     C                   exsr      zzupd5
417eA*
417eA*    Loop looking for more label records to close.
417eA*    With support for pushback replenishments added,
417eA*    Replenishments can now have multiple label rcds.
530hA*    Same is true for Breakdown replenishments from LT107.
417eA*
417eACSR                 if        pttask = 'REPL  '
530hAC                             or pttask = 'REPLBK'
417eACSR                 eval      Flag8  = *ON
417eACSR                 eval      Refrsh = *ON
417eACSR                 goto      More8
417eACSR                 Endif
     C                   endif
     C                   endif
     *
     *       Floor Pick / PIR Pick.
     *
     C                   when      pttask = 'FIXED '  or
     C                             pttask = 'PIR   '
     C                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
     C                   exsr      scr06i
     C                   endif
     C                   if        $pcmd = '*CLOSE  '  or
     C                             $pcmd = '*VRFYCW '
     C                   move      *on           clsflg
     C                   if        $jtype = *on
700gAC                             and $pcmd <> '*CLOSEV '
640qAC                   exsr      zzchk6
640qAC                   if        error = *on
640qAC                   move      'EOJ'         nxtscr
640qAC                   eval      $prtn = '*ERROR'
640qAC                   eval      $perm = 'Transaction Close process Canceled'
640qAC                   goto      endzi2
640qAC                   endif
     C                   exsr      zzupd6
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     C                   else
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
     C                   exsr      zzup6a
650mAC                   endif
     C                   endif
     C                   endif
650mAC                   if        $pcmd = '*UPDSLBL'
650mAC                   exsr      zzck6a
650mAC                   if        error
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   goto      endzi2
650mAC                   else
650mAC                   exsr      zzup6a
650mAC                   endif
650mAC                   endif
700gAC                   if        $pcmd = '*CLOSEV '
700gAC                   move      *on           clsflg
700gAC                   exsr      zzup6v
700gAC                   endif
     *
     *       Put-away - Receiving.
     *
     *          PTTYPE    WHEQ 'PA'
     C                   when      pttask = 'PUTEMP'  or
     C                             pttask = 'PUTMOV'
     C                   move      *on           clsflg
     C                   exsr      scr08i
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE LBSTAT    LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD2692      LGLINE
     **                   WRITELGREC
     C                   if        $pcmd = '*CLOSE  '  or
     C                             $pcmd = '*ZERO   '
     C                   exsr      zzupd8
     C                   if        $pmput = 'Y'
     C                   move      *on           flag8
     C                   move      *on           refrsh
     Csr                 goto      more8
     C                   endif
     C                   endif
     *
     *       Put-away - Customer returns.
     *
     *          PTTYPE    WHEQ 'RN'
     C                   when      pttask = 'PUTRTN'
     C                   move      *on           clsflg
     C                   exsr      scr09i
     C                   if        $pcmd = '*CLOSE  '
     C                   exsr      zzupd9
416nA*
416nA*    Manual put-away - Loop looking for more return
416nA*    label records to close.
416nACSR                 if        $pmput = 'Y'
416nACSR                 eval      Flag8  = *ON
416nACSR                 eval      Refrsh = *ON
416nACSR                 goto      More8
416nACSR                 Endif
     C                   endif
     *
     *       Broken case / repack replenishment
     *
     C                   when      pttask = 'REPLBK'
510eAC                             or pttask = 'REPLRP'
710 AC                             or pttask = 'REPLPD'
     C                   move      *on           clsflg
     C                   exsr      scr10i
     C                   if        $pcmd = '*CLOSE  '
     C                   exsr      zzch10
     *
     *    We force EOJ here because calling pgm is a RF pgm and
     *    may not be able to display error screen. (size limitation)
     *
     C                   if        error = *on
     C                   move      'EOJ'         nxtscr
     C                   else
     C                   exsr      zzup10
     C                   endif
510eA*
510eA*    Loop looking for more label records to close.
510eA*    With support for repack replenishments added,
510eA*    Replenishments can now have multiple label rcds.
510eA*
510eAC                   if        pttask = 'REPLRP'
710 AC                             or pttask = 'REPLPD'
510eAC                   eval      Flag8  = *ON
510eAC                   eval      Refrsh = *ON
510eAC                   goto      More8
510eAC                   Endif
     C                   endif
     *
     C                   endsl
     *
     *   Now what do we do?
     *
     *     If we only wanted to close the order and no errors
     *     occured we return to the calling program. Otherwise,
     *     display the entry screen.
     *
     C     endit2        tag
700gDC**                 if        $pcmd = '*CLOSE  '  and
700gAC                   if        $pcmd = '*CLOSEV '  or
700gMC                             $pcmd = '*CLOSE  '  and
     C                             error = *off
     C                   move      'EOJ'         nxtscr
     C                   endif
650mAC                   if        $pcmd = '*UPDSLBL'
650mAC                   eval      nxtscr = 'EOJ'
650mAC                   endif
     *
     C                   move      *off          error
     *
     C     endzi2        endsr

750aA*----------------------------------------------------------------
750aA *
750aA*  ZZINZUSR Get the user info.
750aA*
750aAC     zzinzusr      begsr
750aAC
750aAC*** this code was moved from *inzsr
417dAC*
417dAC*    - Get employee number, crew and shift.
417dAC*
417dACSR                 call      'GETUSER'
720bMCSR                 parm                    newUser
417dACSR                 parm      0             #WHSE             3 0
417dACSR                 parm      0             #EMP#             5 0
417dACSR                 parm                    #FNAM            15
417dACSR                 parm                    #INIT             1
417dACSR                 parm                    #LNAM            20
417dACSR                 parm                    #WHDP             5
417dACSR                 parm                    #STYP             1
417dACSR                 parm      *blanks       #SHFT             6
417dACSR                 parm      *blanks       #CREW             6
417dACSR                 parm      0             #NHRS             3 1
417dACSR                 parm                    #RTN              8
720bA
720bA *
720bA *   If $pguiUser was sent and return is not *OK send #curruser
720bA *
720bAc                   if        $pguiUser<>*blanks and #rtn<>'*OK'
720bAC                   call      'GETUSER'
720bAC                   parm                    #currUser
720bAC                   parm      0             #WHSE             3 0
720bAC                   parm      0             #EMP#             5 0
720bAC                   parm                    #FNAM            15
720bAC                   parm                    #INIT             1
720bAC                   parm                    #LNAM            20
720bAC                   parm                    #WHDP             5
720bAC                   parm                    #STYP             1
720bAC                   parm      *blanks       #SHFT             6
720bAC                   parm      *blanks       #CREW             6
720bAC                   parm      0             #NHRS             3 1
720bAC                   parm                    #RTN              8
720bAc                   else
720bAc                   eval      #currUser = newUser
720bAc                   endif
750aAC                   endsr
416lM*----------------------------------------------------------------
416lM*  ZZITEM   Get item information.
416lM*
416lM*    Input:  KYWHSE, KYITEM
416lM*----------------------------------------------------------------

416lMC     zzitem        begsr
     C                   eval      error2 = *off

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisys2upd = 'D'

     C                   eval      savever# = $itver#
     C                   clear                   $item
416pAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   eval      $itwhse = kywhse
     C                   eval      $ititem = kyitem

     *  Get item information.

     C                   eval      $drisubcmd = '*GETMAIN'
     C                   eval      chk4err = *on
     C                   eval      drierrmsg = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error2 = *on
     C                   eval      itumq2 = 0
     C                   eval      itumq3 = 0
     C                   endif

     C                   exsr      zzzds2item
     C                   exsr      zzzds2#b
417m C                   eval      #sitem = #bitem

     *  If Contract, Alias or Same Slot Breakdown item
     *   Then verify Base item exists.

     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'B'

     C                   eval      $drisubcmd = '*GETBASE'
     C                   eval      chk4err = *on
     C                   eval      drierrmsg = *off
     C                   exsr      zzzdricop
     C                   if        not error
     C                   exsr      zzzds2#b
     C                   endif

     C                   endif

     *    Determine slot item.

     C                   if        ittype = 'A'  or
     C                             ittype = 'C'  or
     C                             ittype = 'S'
417mMCSR                 call      @getsi
417mACSR                 parm      itwhse        $gwhse            3 0
417mACSR                 parm      ititem        $gitem           15
417mACSR                 parm      ' '           #sitem
417mACSR                 parm                    #sityp            1
417mACSR                 parm                    #sdesc           30
417mACSR                 parm                    #spdsc           15
417mACSR                 parm                    #srtn            10
417mACSR                 parm                    #smsg            60
     C                   parm      '*END    '    $lcmd
417mDC**                 eval      #sitem = #bitem
     C                   else
     C                   eval      #sitem = ititem
     C                   endif

     C                   eval      itmflg = *on
     C                   eval      error = error2
     C     enditm        endsr

     *----------------------------------------------------------------
     *
     *  ZZPICK   Close picking transaction.
     *
     C     zzpick        begsr
     *
     *  Grab label record.
     *
     C     lblbl#        chain     label                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endpck
     C                   endif
620aA
620aA*  Check if prepick label.
620aA
620aAC                   exsr      zzprechk
700aA*  Check if AMPpick label.
700aA
700aAC                   exsr      zzpickAMPchk
416fA*
416fA*  Set OUT flag.
416iAC                   if        opeadj = 'Y'
416iAC                   move      *off          outadj
CLDaA*
510aA*  If slot is blank, force pgm to create adjustment.
510aA*  Was custom, changed to standard change 5.10a
510aAC                   if        Lbdisp = ' '
530fAC                             or Lbdisp = '*NONE*'
510aAC                   move      *on           outadj
510aAC                   endif
CLDaAC*                  if        client = cityline
CLDaAC*                            and Lbdisp = ' ' or
ISYaAC*                            client = isupply
ISYaAC*                            and Lbdisp = ' ' or
ADWaAC*                            client = andrews
ADWaAC*                            and Lbdisp = ' '
CLDaAC*                  move      *on           outadj
CLDaAC*                  endif
CLDaA*
416iAC                   else
416iAC                   move      *on           outadj
416iAC                   endif
416fA*
416fAC                   select
416fAC                   when      lbasl2 = '***'
416fAC                   move      *on           outlbl
416fD**                   MOVE *OFF      OUTADJ  1
416fA*
416fAC                   when      lbasl2 = 'OUT'  and
416fAC                             lbdisp = *blanks
416fAC                   move      *on           outlbl
416iD**                   MOVE *ON       OUTADJ
416fA*
416fAC                   when      lbasl2 = 'OUT'  and
416fAC                             lbdisp <> *blanks
416fAC                   move      *on           outlbl
416iD**                   MOVE *OFF      OUTADJ
416fA*
416fAC                   other
416fAC                   move      *off          outlbl
416iD**                   MOVE *OFF      OUTADJ
416fA*
416fAC                   endsl
     *
     *  Get item information.
     *
     C                   move      lbwhse        kywhse
     C                   move      lbitem        kyitem
     C                   exsr      zzitem
     C                   if        error = *on
510hAC                             and opfeat <> '3'
     C                   eval      errmsg = *blanks
510hD**                 eval      ertrn# = lblbl#
510hMC                   eval      eritm2 = lbitem
510hD**                 exsr      zm14
510hMC                   exsr      zm01
     Csr                 goto      endpck
510hAC                   else
510hAC                   eval      error = *off
     C                   endif
CBInA*
CBInA*  Only work with LBASL2='***' and $IFCAT='PALLET'
CBInA*
CBInAC                   if        flagC1
CBInAC                             and (lbasl2 <> '***'
CBInAC                                  or $ifcat <> 'PALLET')
CBInAC                   leavesr
CBInAC                   endif
     *
     *  Calculate qty, cube and weight.
     *
     *     New qty, cube and weight.
     *
730hAc                   if        umFlexPickFlag = 'P2W'
730hAC                   eval      newcub = lbcube
730hA /free
730hA   newwgt = 0;
730hA   setll ($pwhse: $plbl#) ordc1;
730hA   dow forever = forever;
730hA     reade ($pwhse: $plbl#) ordc1;
730hA     if %eof(ordc1);
730hA       leave;
730hA     endif;
730hA     newwgt = newwgt + OCCWGT;
730hA   enddo;
730hA /end-free
730hAc                   else
     C                   eval      newcub = lbucub * newpck
     C                   eval      newwgt = lbuwgt * newpck
730hAc                   endif
     *
     *     Difference in qty, cube and weight.
     *
730hAc                   if        umFlexPickFlag = 'P2W'
730hAC                   eval      difpck = 0
730hAC                   eval      difcub = 0
730hAC                   eval      difwgt = lbswgt - newwgt
730hAC                   eval      hlddifpck = lbqpck - newpck
730hAc                   else
     C                   eval      difpck = lbqpck - newpck
     C                   eval      difcub = lbcube - newcub
     C                   eval      difwgt = lbswgt - newwgt
     C                   eval      difrpl = lbqrmn - newrpl
730hAc                   endif
730hAc                   if        umFlexPickFlag = 'P2W'
730hAc                   eval      difpck = hlddifpck
730hAc                   endif
     *
     *  If this is a closing adjustment and there was no change
     *  then skip to the bottom becuase there is nothing to do.
     *
     C                   if        lbstat = 'C'  and
     C                             difpck = 0
     C                   unlock    label
     Csr                 goto      endpck
     C                   endif
JORx *  Check if OUT label for PIR
JORx *  Update label record with first pick slot if found.
JORbAC                   if        client = jordanos
JORbAC                   if        lbasl2 = 'OUT' and
JORbAC                             lbstyp = 'P'  and
JORbAC                             lbdisp = *blanks and
JORbAC                             difpck = 0
JORbAC                   eval      $scmd = '*FIRST  '
JORbAC                   call      'GETPSLT'
JORbAC                   parm                    $scmd             8
JORbAC                   parm      lbwhse        $swhse            3 0
JORbAC                   parm      lbitem        $sitem           15
JORbAC                   parm      *blanks       $sslot           12
JORb C                   parm      *blanks       $saisl            3
JORb C                   parm      *zeros        $sloc             3 0
JORb C                   parm      *zeros        $srlvl            2 0
JORb C                   parm      *blanks       $shand            2
JORb C                   parm      *blanks       $srtn             8

JORb *   If pick slot found, update label with new pick slot
JORb C                   if        $sslot <> '*NONE*'
JORb C                   move      $saisl        lbaisl
JORb C                   z-add     $srlvl        lbrlvl
JORb C                   z-add     $sloc         lbloc
JORb C                   move      $sslot        lbdisp
JORb C                   move      $shand        lbhand
JORb C                   move      '__UPD'       lbdsp2
JORbAC                   move      *off          outadj
JORb C***                update    lbrec
JORb C                   endif

JORbAC                   endif
JORbAC                   endif
     *
     *  Grab records that need to be updated.
     *
416fDC**                 if        lbasl2 <> 'OUT'  and
416fDC**                           lbasl2 <> '***'
416fAC                   if        outlbl = *off  or
416fAC                             outlbl = *on  and
416fAC                             outadj = *off
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
520gAC                             or lbitem = '9999999999'
BIR A*
BIR AC                             or client = Birite
BIR AC                             and (lbasl2 = '***')
KFS A*
KFS AC                             or client = Kellys
KFS AC                             and (lbasl2 = '***')
BIR A*
500j C                   move      *off          wrgitm
500j C                   goto      jmpsa1
500j C                   endif
     *     Slot record.
     *
     C     keysl1        chain     slot1                              79
650jA*
650jA*  Create on-demand slot on the fly if closing transaction and
650jA*  find slot is missing
650jA*
650jA /free
650jA    if ittype = 'R' and *in79;
650jA       chain (lbwhse:lbitem) kititem;
650jA       if not %error and %found;
650jA          if kidisp <> ' ';
650jA             exsr clr$slot;
650jA             $slwhseu = *on;
650jA             $slwhse  = lbwhse;
650jA             $slwhdpu = *on;
650jA             $slwhdp  = lbWhdp;
650jA             $slitemu = *on;
650jA             $slitem  = lbitem;
650jA             $sldispu = *on;
650jA             $sldisp  = kidisp;
650jA
650jA             $dricommand = '*SLOT';
650jA             $drisubcmd  = '%CRTREPAKD';
650jA             $drisys2upd = 'D';
650jA             chk4err = *on;
650jA             exsr zzzdricop;
650jA             odrSlot = $sldisp;
650jA             error = *off;
650jA /end-free
650jAc                   if        $driReturn = '*OK'
650jA*       coming in here means it was successful in recreating
650jA*       the missing slot and it will reset the read on the slot
650jA*       file to continue the close process
650jAC     keysl1        chain     slot1                              79
650jAc                   else
650jA*       if it comes in here it most likely means the original
650jA*       ODR slot was Zero Verified and some other process has
650jA*       already created the next virtual in line so this code
650jA*       gets that new slot and resets the slot fields and
650jA*       moves forward with the close process
650jA /free
650jA                    $drisubcmd  = '%GETODRRPK';
650jA                    exsr zzzdricop;
650jA                    if $driReturn = '*OK';
650jA                       odrSlot = $sldisp;
650jA                       lbaisl = $slaisl;
650jA                       lbrlvl = $slrlvl;
650jA                       lbloc = $slloc;
650jA                       lbdisp = $sldisp;
650jA                       lbhand = $slhand;
650jA /end-free
650jAC     keysl1        chain     slot1                              79
650jA /free
650jA                    endif;
650jA /end-free
650jAc                   endif
650jA /free
650jA          endif;
650jA       endif;
650jA    endif;
650jA /end-free
     *
     C                   if        *in79  and
     C                             newpck <> *zeros
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   exsr      zm10
     Csr                 goto      endpck
     C                   endif
     *
     *    If transaction is being closed to zero and
     *    slot NOT found - clear fields.
     *
     C                   if        *in79  and
     C                             newpck = *zeros
     C                   clear                   slrec
     C                   endif
     *
520hA*
520hA*       If OUT label, PIR, same item, allow negative
520hA*
520hAC                   if        slstat = 'Z '     and
520hAC                             slstyp = 'P'      and
520hAC                             newpck <> *zeros  and
520hAC                             opeadj = 'Y'      and
520hAC                             slitem = #sitem
640nA*
640nAC                             or slstat = 'Z '  and
640nAC                             slstyp = 'F'      and
640nAC                             newpck <> *zeros  and
640nAC                             opeadj = 'Y'      and
640nAC                             slitem = #sitem
640nA*
JORa C                             or client = jordanos and
JORa C                             slstat = 'Z '     and
JORa C                             slstyp = 'F'      and
JORa C                             newpck <> *zeros  and
JORa C                             opeadj = 'Y'      and
JORa C                             %subst(lbitem:6:1) <> ' ' and
JORa C                             %subst(lbitem:6:1) <> 'E' and
JORa C                             slitem = #sitem
520hAC                   move      'A '          slstat
520hAC                   else
     *       Make sure item is still in the slot.
     *
     C                   if        slstat = 'Z '  and
     C                             newpck <> *zeros  or
     C                             slstat = 'V '  and
     C                             newpck <> *zeros  or
     C                             slitem <> #sitem  and
     C                             newpck <> *zeros
     *R         SLITEM    ORNE LBITEM
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   eval      eritm1 = lbitem
     C                   exsr      zm11
     Csr                 goto      endpck
     C                   endif
520hAC                   endif
     *
     C                   endif
     *
     *    If wrong item in slot, set switch on so slot is not updated.
     *
     C                   if        slitem <> #sitem  and
     C                             newpck = *zeros
     C                   move      *on           wrgitm
     C                   unlock    slot1
     C                   else
     C                   move      *off          wrgitm
     C                   endif
500j C     jmpsa1        tag
     *
     *     Transaction record.
     *
     C     lbtrn#        chain     pirtran                            79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lbtrn#
     C                   exsr      zm12
     Csr                 goto      endpck
     C                   endif
     *
     *        Make sure task has been ended.
     *
     C                   if        tskflg = *off
500gA*
500gA*        Update transaction with user info when Letdowns
500gA*        are closed from Close Open Letdowns program.
500gAC                   if        $pprg  = 'PT170A' and
500gAC                             clsflg = *on      or
500iAC                             $pprg  = 'PT170C' and
500iAC                             clsflg = *on
500gAC                   if        pttask =  'REPL  '  or
500gAC                             pttask =  'REPLBK'  or
500gAC                             pttask =  'REPLTF'
500gAC                   eval      ptemp# = #emp#
500gAC                   eval      ptshft = #shft
500gAC                   eval      ptcrew = #crew
500gAC                   eval      ptsdte = today
500gAC                   time                    ptstim
500gAC                   endif
500gAC                   endif
     *
     C                   move      *on           tskflg
     C                   call      @adjtd
     C                   parm      '*END    '    $lcmd
     C                   parm      $ptype        $ltype            8
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*END    '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     *     Order detail record (Ignore if Replenishment transaction).
     *
     *          PTTYPE    IFNE 'RP'
     C                   if        pttask <> 'REPL  '  and
     C                             pttask <> 'TFRMOV'  and
     C                             pttask <> 'REPLTF'
     C     keyod         chain     ordd                               79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      eritm2 = lbitem
     C                   exsr      zm13
     Csr                 goto      endpck
     C                   endif
     C                   endif
     *
     *  Update records.
     *
     *
     *     Warehouse record (Ignore if Replenishment transaction).
     *
     *          PTTYPE    IFNE 'RP'
     *                    EXSR ZZUPDW
     *          ERROR     CABEQ*ON       ENDPCK
     *                    ENDIF
     *
     *     Picking slot record.
     *
416fDC**                 if        lbasl2 <> 'OUT'  and
416fDC**                           lbasl2 <> 'OUT'
416fAC                   if        outlbl = *off  or
416fAC                             outlbl = *on  and
416fAC                             outadj = *off
     *
     *          PTTYPE    IFEQ 'RP'
     C                   if        pttask = 'REPL  '  or
     C                             pttask = 'TFRMOV'  or
     C                             pttask = 'REPLTF'
     C                   eval      pckqty = 0
     C                   eval      tfrqty = lbqpck
     C                   else
620aAC                   if        normPrepick
620aAC                   eval      pckqty = lbqalc
620aAC                   eval      tfrqty = 0
620aAC                   else
     C                   eval      pckqty = lbqpck
     C                   eval      tfrqty = lbqrmn
620aAC                   endif
     C                   endif
     C                   eval      kywhse = lbwhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzupdp
     C     error         cabeq     *on           endpck
     *
     *     Warehouse record (Ignore if Replenishment transaction).
     *
     *          PTTYPE    IFNE 'RP'
     C                   if        pttask <> 'REPL  '  and
     C                             pttask <> 'TFRMOV'  and
     C                             pttask <> 'REPLTF'
     C                   exsr      zzupdw
     C     error         cabeq     *on           endpck
     C                   endif
     *
     C                   endif
     *
     *     Transaction record.
     *
     *        Update transaction record fields.
     *
     C                   if        clsflg = *on
     C                   eval      ptstat = '4'
417dA*
417dA*        Update transaction with user info when Letdowns
417dA*        are closed from Close Open Letdowns program.
500gDC*                  if        $pprg  = 'PT170A'
500gDC*                  if        pttask =  'REPL  '  or
500gDC*                            pttask =  'REPLBK'  or
500gDC*                            pttask =  'REPLTF'
500gDC*                  eval      ptemp# = #emp#
500gDC*                  eval      ptshft = #shft
500gDC*                  eval      ptcrew = #crew
500gDC*                  endif
500gDC*                  endif
417dA*
     C                   endif
     C                   if        difpck <> 0
     C                   eval      ptpcs = ptpcs - difpck
     C                   eval      ptcube = ptcube - difcub
     C                   eval      ptswgt = ptswgt - difwgt
     C                   endif
     *                    Z-ADDTODAY     PTEDTE
     *                    TIME           PTETIM
     C                   if        clsflg = *on
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   endif
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     *
     *        Update ORDSLCT record fields.
     *
     C     slctky        setll     ordslct2
     C     slctky        reade     ordslct2                               76
     C                   if        not *in76  and
     C                             clsflg = *on
     C                   eval      osstat = '4'
     C                   update    osrec
     C                   endif
     *
     *     Label record.
     *
     C                   eval      svstat = lbstat
     *          PTTYPE    IFEQ 'RP'
     C                   if        pttask = 'REPL  '  or
     C                             pttask = 'TFRMOV'  or
     C                             pttask = 'REPLTF'
     C                   eval      svqrmn = lbqpck
     C                   else
     C                   eval      svqrmn = lbqrmn
     C                   endif
     C                   if        difpck <> 0
     C                   eval      lbqpck = newpck
     C                   eval      lbcube = newcub
     C                   eval      lbswgt = newwgt
     C                   endif
     C                   if        difrpl <> 0
     C                   eval      lbqrmn = newrpl
     C                   endif
     C                   if        lbstat <> 'C'  and
     C                             clsflg = *on
     C                   eval      lbstat = 'C'
     **                   Z-ADDTODAY     LBSDTE
     C                   time                    lbstim
     C                   if        lbstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      lbsdte = today
     C                   endif
417gA * If selection label and qty changed then blank LBVRFY flag.
500 DC*                  if        lbtype = 'O' and
500 MC                   if        lbtype = 'O' and
500bAC                             lbvrfy = 'I' and
500 AC                             w6qpck <> w6qty or
417gAC                             lbtype = 'B' and
500bAC                             lbvrfy = 'I' and
417gAC                             w6qpck <> w6qty
500c C                   eval      lbvrfy = 'T'
500c C**                 eval      lbvrfy = ' '
417gAC                   endif
      *
500lA *    User cleared flag w/F7 and no qty change.
417i C                   if        w6mrg = *blanks
500lAC                             and (lbvrfy= 'F'
500lAC                             or lbvrfy= 'I')
500cDC**                 eval      lbvrfy = ' '
500cMC                   eval      lbvrfy = 'T'
417i C                   endif
      *
     C                   update    lbrec
     *
     *     Create adjustment record for exception.
CBI A*
CBI A*  Set off the adjustment flag when closing non-stock items.
CBI A*  We don't want the system to generate any adjustment records
CBI A*  when closing non-stock items.
CBI AC                   if        client = cheney
CBI AC                   move      outadj        svoutadj          1
CBI AC                   if        lbasl2 = '***'
CBI AC                   move      *off          outadj
CBI AC                   Endif
CBI AC                   endif
CBI A*
     *
416fDC**                 if        lbasl2 = 'OUT'  and
416fAC                   if        outlbl = *on  and
416fAC                             outadj = *on  and
     C                             lbqpck > 0  and
     C                             clsflg = *on
     *
640gA* Only if *feature = full system,
640fA* Try to reduce from current slot if slot is blank.
640gAC                   if        opfeat = '2'
640fAC                   if        lbdisp = *blanks or
640fAC                             lbdisp = '*NONE'
640fAC                   eval      $lcmd = '*OUTCHG '
640fAC                   eval      $lwhse =  $pwhse
640fAC                   eval      $lwhdp =  lbwhdp
640fAC                   eval      $litm =  lbitem
640fAC                   eval      $ladj =  'XS'
640fAC                   eval      $lqp1 =  0
640fAC                   eval      $lqp2 =  0
640fAC                   eval      $lqp3 =  0
640fAC                   movea     desc(4)       a30
640fAC                   movea     lbrte         a30(16)
640fAC                   move      lbtrn#        tempa7
640fAC                   movea     tempa7        a30(24)
640fAC                   movea     a30           $lmem
640fAC                   select
640fAC                   when      lbutyp = 'N'
650gA*
650gA*     SSB Items need qty sent in Qty 1 field.
650gAC                              or lbutyp = '1'
650gAC                             and ittype = 'S'
650gA*
650gA*     Alias items of SSB Items need qty sent in Qty 1 field.
650gAC                              or lbutyp = '1'
650gAC                             and ittype = 'A'
650gAC                             and #bityp = 'S'
650gA*
640fAC                   eval      $lqp1 =  lbqpck
640fAC                   when      lbutyp = '1'
640fAC                   eval      $lqp2 =  lbqpck
640fAC                   when      lbutyp = '2'
640fAC                   eval      $lqp3 =  lbqpck
640fAC                   endsl
640fAC                   call      'HQ245'
640fAC                   parm                    $lparm
640fAC                   if        $lrtn = '*OK'
640f C                   goto      jmpsa2
640fAC                   endif
640fAC                   endif
640gAC                   endif
640fA*
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa2
500j C                   endif
     C                   clear                   iarec
     C                   eval      iawhse = lbwhse
     C                   if        ittype = 'A'
     C                   move      #bitem        iaitem
     C                   else
     C                   eval      iaitem = lbitem
     C                   endif
     **                   Z-ADDTODAY     IADATE
     C                   time                    iatime
     C                   if        iatime < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      iadate = today
600bMC                   eval      iaby = #curruser
     C                   eval      iawhdp = lbwhdp
     C                   eval      iadisp = lbdisp
     C                   eval      iacwta = 0
     *
     *       For SSB item, qty must be converted from Base qty type
     *         into SSB qty type (ie. Brkdwn1 into Normal).
     *
     C                   if        ittype = 'S'
     C                   select
     C                   when      lbutyp = '1'
     C                   eval      iaqty1 = lbqpck
     C                   when      lbutyp = '2'
     C                   eval      iaqty2 = lbqpck
     C                   endsl
     C                   else
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      iaqty1 = lbqpck
     C                   when      lbutyp = '1'
     C                   eval      iaqty2 = lbqpck
     C                   when      lbutyp = '2'
     C                   eval      iaqty3 = lbqpck
     C                   endsl
     C                   endif
     *
     C                   movea     desc(4)       a30
     C                   movea     lbrte         a30(16)
     C                   move      lbtrn#        tempa7
     C                   movea     tempa7        a30(24)
     C                   movea     a30           iamemo
     *
     C                   eval      iacode = opexcd
     C                   write     iarec
     *
     *
     *       Create label adjustment record.
     *
     C                   eval      lbctr# = lblbl#
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbgrp1 = *blanks
     C                   eval      lbgrp2 = *blanks
     C                   eval      lbtype = 'A'
     C                   eval      lbstat = 'C'
     C                   time                    lbstim
     C                   if        lbstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      lbsdte = today
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
500j C     jmpsa2        tag
     C                   endif
CBI A*
CBI A*     Restore Out Adjustment flag to original setting.
CBI  C                   if        client = cheney
CBI AC                   move      svoutadj      outadj
CBI  C                   endif
620aA
620aA*  Update PRE slot for prepick label
620aA
620aAC                   if        prepickLabel
     C                             and clsflg = *on
620aAC                   exsr      zzpreupd
620aAC                   endif
700aA*  Update AMP slot for AMPpick label
700aA
700aAC                   if        AMPpickLabel
700aAC                             and clsflg = *on
700aAC                   exsr      zzpickAMPupd
700aAC                   endif
     *
     *     Order detail record (Ignore if Replenishment transaction).
     *
     *          PTTYPE    IFNE 'RP'
     C                   if        pttask <> 'REPL  '  and
     C                             pttask <> 'TFRMOV'  and
     C                             pttask <> 'REPLTF'  and
     C                             clsflg = *on
     C                   exsr      zzupdo
     C     error         cabeq     *on           endpck
     C                   endif
     *
     *     Update corresponding PLTSUM and PLTSTP records.
     *
     C                   if        lbtype = 'O'  or
     C                             lbqalc <> lbqpck
     C                   call      'PT133'
     C                   parm                    lbwhse
     C                   parm                    lbrte
     C                   parm                    lbtrn#
     C                   parm                    lblbl#
     C                   parm                    lbpal#
     C                   parm                    lbctr#
     C                   parm                    lbstop
     C                   parm                    difpck
     C                   parm                    difcub
     C                   parm                    difwgt
     C                   endif
     *
     *   Update is finished.
     *
     C     endpck        tag
     *
     C                   if        error = *on  or
     C                             clsflg = *off
     C                   unlock    slot1
     C                   unlock    pirtran
     C                   unlock    label
     C                   unlock    ordd
     C                   unlock    ordslct2
     C                   endif
     *
     C                   endsr
700aA*----------------------------------------------------------------
700aA*  ZZpickAMPCHK   Check if AMPpick label.
700aA*----------------------------------------------------------------
700aA
700aAC     zzpickAMPchk  begsr

     *  See if label record is a AMPpick label (add key whse with label)

700aMC     keyoc1        chain     ampxref
     C                   if        %found
     C                   eval      AMPpickLabel = *on
     C                   else
     C                   eval      AMPpickLabel = *off
     C                   endif

     C                   endsr

700aA*----------------------------------------------------------------
700aA*  ZZpickAMPUPD   Update AMP slot for amppick label
700aA*----------------------------------------------------------------
700aA
700aAC     zzpickAMPupd  begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = axwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = axawhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = axadisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = lbitem

     C                   eval      $saqtyu  = *on
     C                   select
     C                   when      lbutyp = 'N'
700bA*
700bA*     SSB Items need qty sent in Qty 1 field.
700bAC                              or lbutyp = '1'
700bAC                             and ittype = 'S'
700bA*
700bA*     Alias items of SSB Items need qty sent in Qty 1 field.
700bAC                              or lbutyp = '1'
700bAC                             and ittype = 'A'
700bAC                             and #bityp = 'S'
     C                   eval      $saqty1  = newpck
700bAC*
     C                   when      lbutyp = '1'
700bA*
700bA*     SSB Items need qty sent in Qty 2 field.
700bAC                              or lbutyp = '2'
700bAC                             and ittype = 'S'
700bA*
700bA*     Alias items of SSB Items need qty sent in Qty 2 field.
700bAC                              or lbutyp = '2'
700bAC                             and ittype = 'A'
700bAC                             and #bityp = 'S'
     C                   eval      $saqty2  = newpck
700bAC*
     C                   when      lbutyp = '2'
     C                   eval      $saqty3  = newpck
     C                   endsl

     C**                 eval      $sacwtau = *on
     C**                 eval      $sacwta  = w1cwtr
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = '@P'
     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'AMPpick'
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'AMP'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = lbtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*AMP'

700dAC                   if        $saqty1 = 0  and
700dAC                             $saqty2 = 0  and
700dAC                             $saqty3 = 0  and
700dAC                             $saorg1 = 0  and
700dAC                             $saorg2 = 0  and
700dAC                             $saorg3 = 0  and
700dAC                             $sacwta = 0
700dACsr                 goto      endAMPupd
700dAC                   else

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   eval      drierrmsg = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif
700dAC                   endif

700dMC     endAMPupd     endsr

     *----------------------------------------------------------------
     *
     *  ZZPCKB   Close picking transaction for brkn case replenishments
     *
     C     zzpckb        begsr
     *
     *  Grab label record.
     *
     C     lblbl#        chain     label                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endpkb
     C                   endif
     C                   eval      savitm = lbitem
     *
     *  Get full case item number.
     *
     *R                   CALL 'GETFULL'
     *R                   PARM LBWHSE    $GWHSE  30
     *R                   PARM SAVITM    $GITEM 15
     *R                   PARM ' '       LBITEM
     *R                   PARM           $GDESC 30
     *R                   PARM           $GPDSC 15
     *R                   PARM           $GWHDP  5
     *R                   PARM           $GSTYP  1
     *R                   PARM           $GUM    2
     *R                   PARM           $GUM2   2
     *R                   PARM           $GUMQ2  30
     *
     *  Get item information for label item.
     *
     C                   move      lbwhse        kywhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     C                   if        error = *on
510hAC                             and opfeat <> '3'
     C                   eval      errmsg = *blanks
510hD**                 eval      ertrn# = lblbl#
510hMC                   eval      eritm2 = lbitem
510hD**                 exsr      zm14
510hMC                   exsr      zm01
     Csr                 goto      endpkb
510hAC                   else
510hAC                   eval      error = *off
     C                   endif
     *
     *  Fool the system by changing LBITEM. Also, if we are
     *    working with a Contract item, go and get the base
     *    information for the Contract full case item.
     *
     C                   if        ittype = 'C'
     C                   eval      lbitem = #bcitm
     C                   move      lbwhse        kywhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     C                   if        error = *on
510hAC                             and opfeat <> '3'
     C                   eval      errmsg = *blanks
510hD**                 eval      ertrn# = lblbl#
510hMC                   eval      eritm2 = lbitem
510hD**                 exsr      zm14
510hMC                   exsr      zm01
     Csr                 goto      endpkb
510hAC                   else
510hAC                   eval      error = *off
     C                   endif
     C                   else
     C                   move      #bitem        lbitem
     C                   move      #bitem        #sitem
     C                   endif
     *
     *  Calculate qty, cube and weight.
     *
     *     New qty, cube and weight.
     *
     C                   eval      newcub = lbucub * newpck
     C                   eval      newwgt = lbuwgt * newpck
     *
     *     Difference in qty, cube and weight.
     *
     C                   eval      difpck = lbqpck - newpck
     C                   eval      difcub = lbcube - newcub
     C                   eval      difwgt = lbswgt - newwgt
     C                   eval      difrpl = lbqrmn - newrpl
730hAc                   if        umFlexPickFlag = 'P2W'
730hAc                   eval      difpck = hlddifpck
730hAc                   endif
     *
     *  If this is a closing adjustment and there was no change
     *  then skip to the bottom becuase there is nothing to do.
     *
     C                   if        lbstat = 'C'  and
     C                             difpck = 0
     C                   unlock    label
     Csr                 goto      endpkb
     C                   endif
     *
     *  Grab records that need to be updated.
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa3
500j C                   endif
     *     Slot record.
     *
     C     keysl1        chain     slot1                              79
     C                   if        *in79  and
     C                             newpck <> *zeros
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   exsr      zm10
     Csr                 goto      endpkb
     C                   endif
     *
     *    If transaction is being closed to zero and
     *    slot NOT found - clear fields.
     *
     C                   if        *in79  and
     C                             newpck = *zeros
     C                   clear                   slrec
     C                   endif
     *
     *       Make sure item is still in the slot.
     *
     C                   if        slstat = 'Z '  and
     C                             newpck <> *zeros  or
     C                             slstat = 'V '  and
     C                             newpck <> *zeros  or
     C                             slitem <> #sitem  and
     C                             newpck <> *zeros
     *R         SLITEM    ORNE LBITEM
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   eval      eritm1 = lbitem
     C                   exsr      zm11
     Csr                 goto      endpkb
     C                   endif
     *
     *    If wrong item in slot, set switch on so slot is not updated.
     *
     C                   if        slitem <> #sitem  and
     C                             newpck = *zeros
     C                   move      *on           wrgitm
     C                   unlock    slot1
     C                   else
     C                   move      *off          wrgitm
     C                   endif
500j C     jmpsa3        tag
     *
     *     Transaction record.
     *
     C     lbtrn#        chain     pirtran                            79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lbtrn#
     C                   exsr      zm12
     Csr                 goto      endpkb
     C                   endif
     *
     *        Make sure task has been ended.
     *
     C                   if        tskflg = *off
500gA*
500gA*        Update transaction with user info when Letdowns
500gA*        are closed from Close Open Letdowns program.
500gAC                   if        $pprg  = 'PT170A'   or
500iAC                             $pprg  = 'PT170C'
500gAC                   if        pttask =  'REPL  '  or
500gAC                             pttask =  'REPLBK'  or
500gAC                             pttask =  'REPLTF'
500gAC                   eval      ptemp# = #emp#
500gAC                   eval      ptshft = #shft
500gAC                   eval      ptcrew = #crew
500gAC                   eval      ptsdte = today
500gAC                   time                    ptstim
500gAC                   endif
500gAC                   endif
     *
     C                   move      *on           tskflg
     C                   call      @adjtd
     C                   parm      '*END    '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*END    '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     *  Update records.
     *
     *
     *     Picking slot record.
     *
     C                   eval      pckqty = 0
     C                   eval      tfrqty = lbqpck
     C                   eval      savnew = newrpl
     C                   eval      savdif = difrpl
     C                   eval      newrpl = 0
     C                   eval      difrpl = 0
     C                   exsr      zzupdp
     C                   eval      newrpl = savnew
     C                   eval      difrpl = savdif
     C     error         cabeq     *on           endpkb
     *
     *     Warehouse record
     *
     C                   exsr      zzupdw
     C     error         cabeq     *on           endpkb
     *
     *     Transaction record.
     *
     *        Update transaction record fields.
     *
     C                   eval      ptstat = '4'
417dA*
417dA*        Update transaction with user info when Letdowns
417dA*        are closed from Close Open Letdowns program.
500gDC*                  if        $pprg  = 'PT170A'
500gDC*                  if        pttask =  'REPL  '  or
500gDC*                            pttask =  'REPLBK'  or
500gDC*                            pttask =  'REPLTF'
500gDC*                  eval      ptemp# = #emp#
500gDC*                  eval      ptshft = #shft
500gDC*                  eval      ptcrew = #crew
500gDC*                  endif
500gDC*                  endif
417dA*
     C                   if        difpck <> 0
     C                   eval      ptpcs = ptpcs - difpck
     C                   eval      ptcube = ptcube - difcub
     C                   eval      ptswgt = ptswgt - difwgt
     C                   endif
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     *
     *     Label record.
     *
     C                   move      lbstat        svstat
     C                   eval      svqrmn = lbqrmn
     C                   if        difpck <> 0
     C                   eval      lbqpck = newpck
     C                   eval      lbcube = newcub
     C                   eval      lbswgt = newwgt
     C                   endif
     C                   eval      lbqrmn = newrpl
     C                   if        lbstat <> 'C'
     C                   eval      lbstat = 'C'
     **                   Z-ADDTODAY     LBSDTE
     C                   time                    lbstim
     C                   if        lbstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      lbsdte = today
     C                   endif
     C                   move      savitm        lbitem
     C                   update    lbrec
     *
     *     Get item information for broken case item.
     *
     C                   move      lbwhse        kywhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     C                   if        error = *on
510hAC                             and opfeat <> '3'
     C                   eval      errmsg = *blanks
510hD**                 eval      ertrn# = lblbl#
510hMC                   eval      eritm2 = lbitem
510hD**                 exsr      zm14
510hMC                   exsr      zm01
     Csr                 goto      endpkb
510hAC                   else
510hAC                   eval      error = *off
     C                   endif
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa4
500j C                   endif
     *   Update warehouse qty if replenishment qty changed.
     *
     C                   if        ittype = 'B'  and
     C                             difrpl <> 0  or
     C                             ittype = 'C'  and
     C                             difrpl <> 0
     *
     *    More qty was replenished than calculated, change
     *    sign and update qty.
     *
     C                   select
     C                   when      difrpl < 0
     C                   eval      $acmd = '*STOCK  '
     C                   eval      $aqty1 = -(difrpl)
     *
     C                   when      difrpl > 0
     C                   eval      $acmd = '*UNSTOCK'
     C                   eval      $aqty1 = difrpl
     *
     C                   endsl
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     C                   eval      $aqty2 = *zeros
     C                   eval      $aqty3 = *zeros
     C                   exsr      zzwhse
     *
     C                   endif
500j C     jmpsa4        tag
     *
     *   Update is finished.
     *
     C     endpkb        tag
     *
     C                   if        error = *on
     C                   unlock    slot1
     C                   unlock    pirtran
     C                   unlock    label
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZPCKM   Close 'merge' picking transaction.
     *
     C     zzpckm        begsr
     *
     *  Grab label record.
     *
     C     lblbl#        chain     label                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endpkm
     C                   endif
620aA
620aA*  Check if prepick label.
620aA
620aAC                   exsr      zzprechk
700aA*  Check if AMPpick label.
700aA
700aAC                   exsr      zzpickAMPchk
     *
     *  Skip if already closed.
     *
     C                   if        lbstat = 'C'
     C                   unlock    label
     Csr                 goto      endpkm
     C                   endif
     *
     *     Transaction record.
     *
     C     lbtrn#        chain     pirtran                            79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lbtrn#
     C                   exsr      zm12
     Csr                 goto      endpkm
     C                   endif
     *
     *        Make sure task has been ended.
     *
     C                   if        tskflg = *off
     C                   move      *on           tskflg
     C                   call      @adjtd
     C                   parm      '*END    '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   endif
     *
     *     Transaction record.
     *
     *        Update transaction record fields.
     *
     C                   eval      ptstat = '4'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     *
     *     Label record.
     *
     C                   eval      lbstat = 'C'
     **                   Z-ADDTODAY     LBSDTE
     C                   time                    lbstim
     C                   if        lbstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      lbsdte = today
     C                   update    lbrec
620aA
620aA*  Update PRE slot for prepick label
620aA
620aAC                   if        prepickLabel
     C                             and clsflg = *on
620aAC                   exsr      zzpreupd
620aAC                   endif
700aA
700aA*  Update AMP slot for AMPpick label
700aA
700aAC                   if        AMPpickLabel
700aAC                             and clsflg = *on
700aAC                   exsr      zzpickAMPupd
700aAC                   endif
     *
     *   Update is finished.
     *
     C     endpkm        tag
     *
     C                   if        error = *on
     C                   unlock    pirtran
     C                   unlock    label
     C                   endif
     *
     C                   endsr
417l *----------------------------------------------------------------
417l *
417l *  ZZPOS6   Screen 6 Position to.
417l *
417l C     zzpos6        begsr
417l C                   move      *off          error
417l C     $pcmd         cabeq     '*VIEW   '    endps6
417l *
417l *   Verify changed subfile records.
417l *
417l C                   if        reccnt > 0
500eDC*                  eval      posrec = 0
417l C                   eval      *in79 = *off
417l C                   dou       *in79
417l C                   readc     detail6                                79
417l *
417l C                   if        *in79
417l C                   leave
417l C                   endif
417l *
417l *     Ignore *PIRPICK labels because there is nothing to check.
417l *
417l C                   if        w6item = '*PIRPICK'
417l C                   iter
417l C                   endif
417l *
417l C                   eval      *in01 = *off
417l C                   eval      *in21 = *off
417l *     Set reverse image for out labels.
417l C                   if        w6out = *on
417l C                   eval      *in65 = *on
417l C                   else
417l C                   eval      *in65 = *off
417l C                   endif
417l *
417l C                   eval      *in85 = *on
417l C                   if        w6lbl# = ptinp1
417l C                   eval      *in01 = *on
417l C                   eval      posrec = recno
417l C                   endif
417l C                   update    detail6
417l C                   if        posrec = 0
417l C                   if        *in21
417l C                   eval      posrec = recno
417l C                   endif
417l C                   endif
417l *
417l C                   if        w6lbl# = ptinp1
417l C                   leave
417l C                   endif
417l *
417l C                   enddo
417l C                   endif
417l C                   eval      ptinp1 = 0
417l *
417l C     endps6        endsr

620aA*----------------------------------------------------------------
620aA*  ZZPRECHK   Check if prepick label.
620aA*----------------------------------------------------------------
620aA
620aAC     zzprechk      begsr

     *  See if label record is a normal label with an
     *  associated prepick slot.

      /free

           setll (lbwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           reade (lbwhse: lbrte: lbord: lbseq: lbwhdp: lbdisp)
                 prexref4;

           if %eof(prexref4);
             normPrepick = *off;
           else;
             normPrepick = *on;
           endif;

      /end-free

     *  See if label record is a prepick label

     C     lblbl#        chain     prexref
     C                   if        %found
     C                   eval      prepickLabel = *on
     C                   else
     C                   eval      prepickLabel = *off
     C                   endif

     C                   endsr

620aA*----------------------------------------------------------------
620aA*  ZZPREUPD   Update PRE slot for prepick label
620aA*----------------------------------------------------------------
620aA
620aAC     zzpreupd      begsr

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = pxwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = pxsdep
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = pxdisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = lbitem

     C                   eval      $saqtyu  = *on
     C                   select
     C                   when      lbutyp = 'N'
700bA*
700bA*     SSB Items need qty sent in Qty 1 field.
700bAC                              or lbutyp = '1'
700bAC                             and ittype = 'S'
700bA*
700bA*     Alias items of SSB Items need qty sent in Qty 1 field.
700bAC                              or lbutyp = '1'
700bAC                             and ittype = 'A'
700bAC                             and #bityp = 'S'
     C                   eval      $saqty1  = newpck
700bAC*
     C                   when      lbutyp = '1'
700bA*
700bA*     SSB Items need qty sent in Qty 2 field.
700bAC                              or lbutyp = '2'
700bAC                             and ittype = 'S'
700bA*
700bA*     Alias items of SSB Items need qty sent in Qty 2 field.
700bAC                              or lbutyp = '2'
700bAC                             and ittype = 'A'
700bAC                             and #bityp = 'S'
     C                   eval      $saqty2  = newpck
700bAC*
     C                   when      lbutyp = '2'
     C                   eval      $saqty3  = newpck
     C                   endsl

     C**                 eval      $sacwtau = *on
     C**                 eval      $sacwta  = w1cwtr
     C                   eval      $sacodeu = *on
     C                   eval      $sacode  = '@P'
     C                   eval      $samemou = *on
     C                   eval      $samemo  = 'Prepick'
     C                   eval      $sabyu   = *on
     C                   eval      $saby    = #curruser

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'PRE'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = lbtrn#
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = lblbl#
     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = '*PRE'

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%ADJUST'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   eval      drierrmsg = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZPUT    Close Put-away transaction.
     *
     C     zzput         begsr
     *
     *  Grab label record.
     *
     C     lblbl#        chain     label                              79
     C                   if        *in79
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3423      LGLINE
     **                   WRITELGREC
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lblbl#
     C                   exsr      zm14
     Csr                 goto      endput
     C                   endif
     *
     *  Get item information.
     *
     C                   move      lbwhse        kywhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzitem
     C                   if        error = *on
510hAC                             and opfeat <> '3'
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3436      LGLINE
     **                   WRITELGREC
     C                   eval      errmsg = *blanks
510hD**                 eval      ertrn# = lblbl#
510hMC                   eval      eritm2 = lbitem
510hD**                 exsr      zm14
510hMC                   exsr      zm01
     Csr                 goto      endput
510hAC                   else
510hAC                   eval      error = *off
     C                   endif
     *
     *  Calculate qty, cube and weight.
     *
     *     New qty, cube and weight.
     *
     C                   eval      newcub = lbucub * newpck
     C                   eval      newwgt = lbuwgt * newpck
     *
     *     Difference in qty, cube and weight.
     *
     C                   eval      difpck = lbqpck - newpck
     C                   eval      difcub = lbcube - newcub
     C                   eval      difwgt = lbswgt - newwgt
     *
730hAc                   if        umFlexPickFlag = 'P2W'
730hAc                   eval      difpck = hlddifpck
730hAc                   endif
     *
     *  If this is a closing adjustment and there was no change
     *  then skip to the bottom becuase there is nothing to do.
     *
     C                   if        lbstat = 'C'  and
     C                             difpck = 0
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3460      LGLINE
     **                   WRITELGREC
     C                   unlock    label
     Csr                 goto      endput
     C                   endif
416bA*
416bA*  Skip slot rec. for Return with no put away.
416bAC                   if        lbtype = 'P'  and
416bAC                             lbgrp1 = 'R'  and
416bAC                             lbdisp = *blanks
416bACsr                 goto      nostk1
416bAC                   endif
     *
     *  Grab records that need to be updated.
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa5
500j C                   endif
     *     Slot record.
     *
     C     keysl1        chain     slot1                              79
     C                   if        *in79
     C                   if        $pmput = 'N'
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3470      LGLINE
     **                   WRITELGREC
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   exsr      zm10
     Csr                 goto      endput
     C                   endif
     *R                   ENDIF
     C                   else
     *
     *       Make sure item is still in the slot.
     *
     C                   if        slstat = 'Z '  or
     C                             slstat = 'V '  or
     C                             slitem <> #sitem
     *R         SLITEM    ORNE LBITEM
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3486      LGLINE
     **                   WRITELGREC
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdisp
     C                   eval      eritm1 = lbitem
     C                   exsr      zm11
     Csr                 goto      endput
     C                   endif
     C                   endif
     *
500j C     jmpsa5        tag
416bAC     nostk1        tag
     *     Transaction record.
     *
     C                   if        flag8 = *off
     C     lbtrn#        chain     pirtran                            79
     C                   if        *in79
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3500      LGLINE
     **                   WRITELGREC
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = lbtrn#
     C                   exsr      zm12
     Csr                 goto      endput
     C                   endif
     C                   endif
     *
     *        Make sure task has been ended.
     *
     C                   if        tskflg = *off
     C                   move      *on           tskflg
     C                   call      @adjtd
     C                   parm      '*END    '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*END    '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     *     P.O. detail record .
     *
     *R         LBPO      IFNE *BLANKS
     *R         KEYPD     CHAINPOD                  79
     *R         *IN79     IFEQ *ON
     *R                   MOVE *ON       ERROR
     *R                   MOVE *BLANKS   ERRMSG
     *R                   MOVE LBITEM    ERITM2
     *R                   EXSR ZM17
     *R                   GOTO ENDPUT
     *R                   ENDIF
     *R                   ENDIF
     *
416bA*
416bA*  Skip whse qty. for Return with no put away.
416bAC                   if        lbtype = 'P'  and
416bAC                             lbgrp1 = 'R'  and
416bAC                             lbdisp = *blanks
416bACsr                 goto      nostk2
416bAC                   endif
     *     Picking slot record.
     *
     C                   eval      svqrmn = lbqpck
     C                   eval      newrpl = newpck
     C                   eval      difrpl = difpck
     C                   eval      kywhse = lbwhse
     C                   eval      kyitem = lbitem
     C                   exsr      zzupdr
     C     error         cabeq     *on           endput
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa6
500j C                   endif
     *     Update warehouse qty by difference.
     *
     C                   if        $pmput <> 'Y'
     C                   if        difpck <> 0
     C                   eval      $acmd = '*UNSTOCK'
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     *
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      $aqty1 = difpck
     C                   when      lbutyp = '1'
     C                   eval      $aqty2 = difpck
     C                   when      lbutyp = '2'
     C                   eval      $aqty3 = difpck
     C                   endsl
500j C     jmpsa6        tag
     C                   exsr      zzwhse
     **         ERROR     IFEQ *ON
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD3569      LGLINE
     **                   WRITELGREC
     **                   ENDIF
     C     error         cabeq     *on           endput
     C                   endif
     C                   endif
     *
     *     Update warehouse qty by qty put away.
     *
     *R         $PMPUT    IFEQ 'Y'
     *R                   MOVE '*STOCK  '$ACMD
     *R                   MOVE #PROG     $APRG
     *R                   MOVE '*INTER  '$ATYPE
     *R                   Z-ADDLBWHSE    $AWHSE
     *R                   MOVE LBITEM    $AITEM
     *
     *R                   Z-ADD0         $AQTY1
     *R                   Z-ADD0         $AQTY2
     *R                   Z-ADD0         $AQTY3
     *R                   SELEC
     *R         LBUTYP    WHEQ 'N'
     *R                   Z-ADDNEWPCK    $AQTY1
     *R         LBUTYP    WHEQ '1'
     *R                   Z-ADDNEWPCK    $AQTY2
     *R         LBUTYP    WHEQ '2'
     *R                   Z-ADDNEWPCK    $AQTY3
     *R                   ENDSL
     *R                   EXSR ZZWHSE
     *R         ERROR     CABEQ*ON       ENDPUT
     *R                   ENDIF
     *
     *     Picking slot record.
     *
     *R                   Z-ADDLBQPCK    SVQRMN
     *R                   Z-ADDNEWPCK    NEWRPL
     *R                   Z-ADDDIFPCK    DIFRPL
     *R                   EXSR ZZUPDR
     *R         ERROR     CABEQ*ON       ENDPUT
     *
416bAC     nostk2        tag
     *     Transaction record.
     *
     *        Update transaction record fields.
     *
     C                   if        flag8 = *off
     C                   eval      ptstat = '4'
     C                   if        difpck <> 0
     C                   eval      ptpcs = ptpcs - difpck
     C                   eval      ptcube = ptcube - difcub
     C                   eval      ptswgt = ptswgt - difwgt
     C                   endif
     *                    Z-ADDTODAY     PTEDTE
     *                    TIME           PTETIM
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     *
510iA*     When closing transaction with $pcmd '*ZERO   ',
510iA*      update transaction with user id's employee#.
510iAC                   if        $pcmd = '*ZERO   '
510iAC                   eval      ptemp# = #emp#
510iAC                   endif
     *
     *        Update transaction record.
     *
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     C                   endif
     *
     *     Label record.
     *
     C                   move      lbstat        svstat
     C                   if        difpck <> 0
     C                   eval      lbqpck = newpck
     C                   eval      lbcube = newcub
     C                   eval      lbswgt = newwgt
     C                   endif
     C                   if        lbstat <> 'C'
     C                   eval      lbstat = 'C'
     **                   Z-ADDTODAY     LBSDTE
     C                   time                    lbstim
     C                   if        lbstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      lbsdte = today
     C                   endif
     C                   update    lbrec
     *
     *     P.O. detail record.
     *
     *R         LBPO      IFNE *BLANKS
     *R                   EXSR ZZUPPO
     *R         ERROR     CABEQ*ON       ENDPUT
     *R                   ENDIF
     *
     *   Update is finished.
     *
     C     endput        tag
     *
     C                   if        error = *on
     C                   unlock    slot1
     C                   unlock    pirtran
     C                   unlock    label
     *R                   UNLCKPOD
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZRCV    Close receiving transaction.
     *
     C     zzrcv         begsr
     *
416hA*  Grab label record.
     *
416hAC                   if        pttask = 'TFRMOV'
416hAC     lblbl#        chain     label                              79
416hAC                   if        *in79
416hAC                   move      *on           error
416hAC                   eval      errmsg = *blanks
416hAC                   eval      ertrn# = lblbl#
416hAC                   exsr      zm14
416hACsr                 goto      endrcv
416hAC                   else
416hAC                   eval      svqrmn = lbqpck
416hAC                   endif
416hAC                   endif
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa7
500j C                   endif
     *     Slot record.
     *
     C     keysl2        chain     slot1                              79
     C                   if        *in79
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdsp2
     C                   exsr      zm15
     Csr                 goto      endrcv
     C                   endif
     *
     *       Make sure item is still in the slot.
     *
     C                   if        pttask <> 'TFRMOV'
     C                   if        slstat = 'Z '  or
     C                             slstat = 'V '  or
     C                             slitem <> #sitem
     *R         SLITEM    ORNE LBITEM
     C                   move      *on           error
     C                   eval      errmsg = *blanks
     C                   eval      erdisp = lbdsp2
     C                   eval      eritm1 = lbitem
     C                   exsr      zm16
     Csr                 goto      endrcv
     C                   endif
     C                   endif
     *
     *  Update records.
     *
     *     Receiving slot record.
     *
     C                   eval      kywhse = slwhse
     C                   eval      kyitem = slitem
     C                   exsr      zzupdr
500j C     jmpsa7        tag
     C     error         cabeq     *on           endrcv
     *
416hAC                   if        pttask = 'TFRMOV'
416hAC                   if        lbstat <> 'C'  and
416hAC                             clsflg = *on
416hAC                   eval      lbstat = 'C'
416hAC                   time                    lbstim
416hAC                   if        lbstim < lsttim
416hAC                   exsr      zzzdte
416hAC                   endif
416hAC                   eval      lbsdte = today
416hAC                   endif
     *
416hAC                   update    lbrec
416hAC                   endif
     *
     *   Update is finished.
     *
     C     endrcv        tag
     *
     C                   if        error = *on
     C                   unlock    slot1
416hAC                   unlock    label
     C                   endif
     *
     C                   endsr
416cA*----------------------------------------------------------------
416cA*     ZZTRCK - Write tracking records to tracking file
416cA*
416cAC     zztrck        begsr
416cAC                   select
416cAC                   when      trcode = '*PCK001 '
416cAC                   eval      trpcmd = '*CLOSE  '
416cAC                   eval      trprg = $pprg
416cA*
416cA*    Qty changes made - load chg status msg.
416cAC                   if        trerr = *on
416cAC                   eval      trpkst = tr81
416cA*
416cA*    No Qty changes made - load No Chg status msg.
416cAC                   else
416cAC                   eval      trpkst = tr80
416cAC                   endif
416cA*
416cAC                   move      '0'           trflpk
416cAC                   move      '0'           trfltk
416cAC                   eval      trotyp = ohtype
416cAC                   movel(p)  tr01ds        trdata
416cA*
416cA*    Write Close tracking record to tracking file.
416cAC                   call      'OR803'
416cAC                   parm      trcode        $tcode            8
416cAC                   parm      $pwhse        $twhse            3 0
416cAC                   parm      'PT132   '    $tprg             9
416cAC                   parm      *blanks       $titem           15
416cAC                   parm      #job          $tdev            10
600bMC                   parm      #curruser     $tuser           10
416cAC                   parm      lbrte         $trtid            5
416cAC                   parm      *zeros        $tstop            2 0
416cAC                   parm      lbpbat        $tpbat            7 0
416cAC                   parm      *zeros        $tord             7 0
416cAC                   parm      ' '           $tmsgt            1
416cAC                   parm      ' '           $tmsgn            4
416cAC                   parm      trdata        $tdata          150
416cA*
416cAC                   when      trcode = '*PCK050 '
416cA*
416cAC                   select
416cAC                   when      trnbr = 'TR01'
416cAC                   eval      $tmsgt = 'S'
416cAC                   eval      trerr = *on
416cAC                   eval      trdt50 = tr01
416cAC                   select
416cA*    Use Screen 2 values.
416cAC                   when      nxtscr = '02 '
416cAC                   eval      $tord = w2ord
416cAC                   eval      $tstop = lbstop
416cAC                   move      w2item        $titem
416cAC                   eval      $cqty1 = w2qty - trqpck
416cA*
416cAC                   eval      trdt50 = %trimr(trdt50) + ' ' + tr02
416cAC                   move      trqpck        cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cAC     trdt50        cat(p)    tr03:2        trdt50
416cAC                   move      w2qty         cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cA*    Use Screen 3 values.
416cAC                   when      nxtscr = '03 '
416cAC                   eval      $tord = w3ord
416cAC                   eval      $tstop = lbstop
416cAC                   move      w3item        $titem
416cAC                   eval      $cqty1 = w3qty - trqpck
416cA*
416cAC                   eval      trdt50 = %trimr(trdt50) + ' ' + tr02
416cAC                   move      trqpck        cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cAC     trdt50        cat(p)    tr03:2        trdt50
416cAC                   move      w3qty         cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cA*    Use Screen 4 values.
416cAC                   when      nxtscr = '04 '
416cAC                   eval      $tord = w4ord
416cAC                   eval      $tstop = lbstop
416cAC                   move      w4item        $titem
416cAC                   eval      $cqty1 = w4qpck - trqpck
416cA*
416cAC                   eval      trdt50 = %trimr(trdt50) + ' ' + tr02
416cAC                   move      trqpck        cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cAC     trdt50        cat(p)    tr03:2        trdt50
416cAC                   move      w4qpck        cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cA*    Use Detail 6 values.
416cAC                   other
416cAC                   eval      $tord = w6ord
416cAC                   eval      $tstop = w6stop
416cAC                   eval      $titem = w6item
416cAC                   eval      $cqty1 = w6qty - w6qpck
416cA*
416cAC                   eval      trdt50 = %trimr(trdt50) + ' ' + tr02
416cAC                   move      w6qpck        cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cA*
416cAC     trdt50        cat(p)    tr03:2        trdt50
416cAC                   move      w6qty         cvt5a
416cAC                   eval      trdt50 = %trimr(trdt50) + cvt5a
416cAC                   endsl
416cA*
416cAC                   eval      $ccmd = '*QTY2STR'
416cAC                   eval      $cqstr = *blanks
416cAC                   exsr      zzcvqy
416cA*
416cAC     trdt50        cat(p)    tr04:2        trdt50
416cAC     trdt50        cat       $cqstr:1      trdt50
416cAC                   endsl
416cA*
416cAC                   movel(p)  tr50ds        trdata
416cA*
416cA*    Write Close tracking record to tracking file.
416cAC                   call      'OR803'
416cAC                   parm      trcode        $tcode
416cAC                   parm      $pwhse        $twhse
416cAC                   parm      'PT132   '    $tprg
416cAC                   parm                    $titem
416cAC                   parm      #job          $tdev
600bMC                   parm      #curruser     $tuser
416cAC                   parm      lbrte         $trtid
416cAC                   parm                    $tstop
416cAC                   parm      lbpbat        $tpbat
416cAC                   parm                    $tord
416cAC                   parm                    $tmsgt
416cAC                   parm      trnbr         $tmsgn
416cAC                   parm      trdata        $tdata
416cA*
416cAC                   endsl
416cA*
416cAC                   endsr
416cA*----------------------------------------------------------------
416cA*     ZZCVQY - Convert receive qty's to string for msg display
416cA*
416cAC     zzcvqy        begsr
416cAC                   call      'CVTQTY'
416cAC                   parm                    $ccmd             8
416cAC                   parm                    $cprg            10
416cAC                   parm                    $cqty1            7 0
416cAC                   parm                    $cqty2            7 0
416cAC                   parm                    $cqty3            7 0
416cAC                   parm                    $cum1             2
416cAC                   parm                    $cum2             2
416cAC                   parm                    $cum3             2
416cAC                   parm                    $cqstr           10
416cAC                   parm                    $custr           17
416cAC                   parm                    $crtn             8
416cAC                   parm                    $cerm
416cAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     *    Screen 1 is a carry over from the original PT130 program
     *    and is no longer used.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup2
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     Csr                 goto      chkcw2
     C                   endif
     *
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w2qty
     C                   eval      newrpl = 0
     C                   exsr      zzpick
     C     error         cabeq     *on           endup2
416cA*
416cA*    User changed pick quantity. Log change in tracking file.
416cAC                   if        error = *off  and
416eMC                             w2qty <> trqpck and
416eAC                             $pcmd = '*CHANGE '
416cAC                   move      'TR01'        trnbr
416cAC                   move      '*PCK050 '    trcode
416cAC                   movel     'ZZUPD2  '    trsr50
416cAC                   exsr      zztrck
416cAC                   endif
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     C     chkcw2        tag
     *
     *
     *  See if we should move on to catch weights.
     *  Note: Only check for wgt's when running in interactive mode.
     *
     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on  and
     C                             $jtype = *on
     *
     C                   if        wgtflg = *off
     ***        $PCMD     OREQ '*CLOSE  '
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   else
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   leave
     C                   endif
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
CBIa C                   if        client = cheney
CBIa C                   if        itcwgt = 'Y'  and
CBIa C                             lbqpck > 0  and
CBIa C                             lbtype <> 'M' and
CBIa C                             lbtype <> 'A'
510gDC**                           and lbasl2 <> '***'
510gMC                             and lbasl2 <> '***' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
CBIa C                   goto      jmp1
CBIa C                   else
CBIa C                   goto      jmp1e
CBIa C                   endif
CBIa C                   endif
640 A*
640 A*  Delete catchwgt rcds on file, if zero qty picked when closing rcds.
640 AC                   if            itcwgt = 'Y'
640  C                             and lbqpck = 0
640 AC                             and lbtype <> 'M'
640 AC                             and lbtype <> 'A'
640 AC                             and cwflg = *on
640 AC                             and clsflg = *on
640 AC                   exsr      zzcwdel
640 AC                   goto      jmp1e
640 AC                   endif
640 A*
640 A*
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
416kMC                             lbtype <> 'M' and
510gDC**                           lbtype <> 'A'
510gMC                             lbtype <> 'A' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
     *R                   MOVE *ON       REFRSH
     *R                   EXSR SCR07I
     *R                   LEAVE
CBIa C     jmp1          tag
DRYbA*
DRYbAC                   if        clsflg = '1'
DRYbAC                             and (client = Dairyland)
DRYbAC                   eval      $lcmd = '*EDITCLS'
DRYbAC                   else
     C                   eval      $lcmd = '*EDIT   '
DRYbAC                   endif
DRYbA*
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
530cAC                   eval      $lcmd = '*EDITCLS'
     C                   call      'CW113'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR'
     C                   if        $pcmd = '*VRFYCW '
     C                   eval      $lcmd = '*CHANGE '
     C                   else
     *R                   MOVE '*CHANGE '$LCMD
     C                   eval      $lcmd = '*CHANGEP'
530cAC                   eval      $lcmd = '*CHKNONE'
     C                   endif
     C                   call      'CW112'
     C                   parm                    $lparm
     C                   endif
     C                   endif
CBIa C     jmp1e         tag
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup2
     C                   endif
     *
     C                   if        error = *off
     C                   if        clsflg = *on
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   endif
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C     endup2        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD3   Update for screen 3.
     *
     C     zzupd3        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup3
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     Csr                 goto      chkcw3
     C                   endif
     *
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w3qty
     C                   eval      newrpl = 0
     C                   exsr      zzpick
     C     error         cabeq     *on           endup3
416cA*
416cA*    User changed pick quantity. Log change in tracking file.
416cAC                   if        error = *off  and
416eMC                             w3qty <> trqpck and
416eAC                             $pcmd = '*CHANGE '
416cAC                   move      'TR01'        trnbr
416cAC                   move      '*PCK050 '    trcode
416cAC                   movel     'ZZUPD3  '    trsr50
416cAC                   exsr      zztrck
416cAC                   endif
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     *
     C     chkcw3        tag
     *
     *
     *  See if we should move on to catch weights.
     *  Note: Only check for wgt's when running in interactive mode.
     *
     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on  and
     C                             $jtype = *on
     *
     C                   if        wgtflg = *off
     ***        $PCMD     OREQ '*CLOSE  '
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   else
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   leave
     C                   endif
520gA*
520gAC                   if        lbitem = '9999999999'
520gAC     keyod         chain     orddm
520gAC                   if        %found(orddm)
520gAC                   eval      rtxdm1_base = ommsc1
520gAC                   if        rtxdm1_omcwcd = 'Y'
520gAC                   eval      itcwgt = 'Y'
520gAC                   endif
520gAC                   endif
520gAC                   endif
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
CBIa C                   if        client = cheney
CBIa C                   if        itcwgt = 'Y'  and
CBIa C                             lbqpck > 0  and
CBIa C                             lbtype <> 'M' and
CBIa C                             lbtype <> 'A'
510gDC**                           and lbasl2 <> '***'
510gMC                             and lbasl2 <> '***' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
CBIa C                   goto      jmp2
CBIa C                   else
CBIa C                   goto      jmp2e
CBIa C                   endif
CBIa C                   endif
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
416kAC                             lbtype <> 'M' and
510gDC**                           lbtype <> 'A'
510gMC                             lbtype <> 'A' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
     *R                   MOVE *ON       REFRSH
     *R                   EXSR SCR07I
     *R                   LEAVE
CBIa C     jmp2          tag
DRYbA*
DRYbAC                   if        clsflg = '1'
DRYbAC                             and (client = Dairyland)
DRYbAC                   eval      $lcmd = '*EDITCLS'
DRYbAC                   else
     C                   eval      $lcmd = '*EDIT   '
DRYbAC                   endif
DRYbA*
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
     C                   call      'CW113'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR'
     C                   if        $pcmd = '*VRFYCW '
     C                   eval      $lcmd = '*CHANGE '
     C                   else
     C                   eval      $lcmd = '*CHANGEP'
     C                   endif
     C                   call      'CW112'
     C                   parm                    $lparm
     C                   endif
     C                   endif
CBIa C     jmp2e         tag
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup3
     C                   endif
     *
     C                   if        error = *off
     C                   if        clsflg = *on
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   endif
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C     endup3        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD4   Update for screen 4.
     *
     C     zzupd4        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup4
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     Csr                 goto      chkcw4
     C                   endif
     *
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w4qpck
     C                   eval      newrpl = w4qrpl
     C                   exsr      zzpick
     C     error         cabeq     *on           endup4
416cA*
416cA*    User changed pick quantity. Log change in tracking file.
416cAC                   if        error = *off  and
416eMC                             w4qpck <> trqpck and
416eAC                             $pcmd = '*CHANGE '
416cAC                   move      'TR01'        trnbr
416cAC                   move      '*PCK050 '    trcode
416cAC                   movel     'ZZUPD4  '    trsr50
416cAC                   exsr      zztrck
416cAC                   endif
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     *
     C                   exsr      zzrcv
     C     error         cabeq     *on           endup4
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     C                   endif
     *
     *
     C     chkcw4        tag
     *
     *
     *  See if we should move on to catch weights.
     *  Note: Only check for wgt's when running in interactive mode.
     *
     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on  and
     C                             $jtype = *on
     *
     C                   if        wgtflg = *off
     **         $PCMD     OREQ '*CLOSE  '
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   else
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   leave
     C                   endif
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
CBIa C                   if        client = cheney
CBIa C                   if        itcwgt = 'Y'  and
CBIa C                             lbqpck > 0  and
CBIa C                             lbtype <> 'M' and
CBIa C                             lbtype <> 'A'
510gDC**                           and lbasl2 <> '***'
510gMC                             and lbasl2 <> '***' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
CBIa C                   goto      jmp3
CBIa C                   else
CBIa C                   goto      jmp3e
CBIa C                   endif
CBIa C                   endif
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
416kMC                             lbtype <> 'M' and
510gDC**                           lbtype <> 'A'
510gMC                             lbtype <> 'A' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
     *R                   MOVE *ON       REFRSH
     *R                   EXSR SCR07I
     *R                   LEAVE
CBIa C     jmp3          tag
DRYbA*
DRYbAC                   if        clsflg = '1'
DRYbAC                             and (client = Dairyland)
DRYbAC                   eval      $lcmd = '*EDITCLS'
DRYbAC                   else
     C                   eval      $lcmd = '*EDIT   '
DRYbAC                   endif
DRYbA*
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
     C                   call      'CW113'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR'
     C                   if        $pcmd = '*VRFYCW '
     C                   eval      $lcmd = '*CHANGE '
     C                   else
     C                   eval      $lcmd = '*CHANGEP'
     C                   endif
     C                   call      'CW112'
     C                   parm                    $lparm
     C                   endif
     C                   endif
CBIa C     jmp3e         tag
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup4
     C                   endif
     *
     C                   if        error = *off
     C                   if        clsflg = *on
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   endif
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C     endup4        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD5   Update for screen 5.
     *
     C     zzupd5        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup5
     C                   endif
     *
     C                   move      *off          tskflg
     *
416hA*  Grab label record.
416hA*
416hAC     lblbl#        chain(n)  label                              79
416hAC                   eval      tfctr = 0
416hAC     nxttf         tag
416hAC                   if        pttask = 'TFRMOV'  and
416hAC                             lbgrp2 = 'B'
416hACsr                 goto      tfrb
416hAC                   endif
     *
416haC                   if        pttask = 'TFRMOV'
416hAC                   eval      newpck = lbqpck
416haC                   else
     C                   eval      newpck = w5qrpl
416haC                   endif
     C                   eval      newrpl = 0
     C                   exsr      zzpick
     C     error         cabeq     *on           endup5
     *
416hAC     tfrb          tag
416haC                   if        pttask = 'TFRMOV'  and
416hAC                             lbgrp2 = 'A'
416hACsr                 goto      tfra
416hAC                   endif
416hAC                   if        pttask = 'TFRMOV'
416hAC                   eval      newrpl = lbqpck
416hAC                   else
     C                   eval      newrpl = w5qrpl
416hAC                   endif
     C                   eval      difrpl = svqrmn - newrpl
416hAC                   if        pttask = 'TFRMOV'  and
416hAC                             lbgrp2 = 'B'
416hAC                   move      lbdsp2        svdsp2
416hAC                   eval      lbdsp2 = lbdisp
416hAC                   endif
     C                   exsr      zzrcv
416hAC                   if        pttask = 'TFRMOV'  and
416hAC                             lbgrp2 = 'B'
416hAC                   move      svdsp2        lbdsp2
416hAC                   endif
     C     error         cabeq     *on           endup5
     *
416hAC     tfra          tag
416hAC                   add       1             tfctr
416hAC                   if        pttask = 'TFRMOV'  and
416hAC                             tfctr < 2
416hAC     keylb7        reade     label7                                 79
416hA*  Grab label record.
416hAC     lblbl#        chain(n)  label                              79
416hAC     *in79         cabeq     *off          nxttf
416hAC                   endif
     *
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     C     endup5        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD6   Update for screen 6.
     *
     C     zzupd6        begsr
CBI  *  Use custom update for screen 6.
CBI  C                   if        client = cheney
CBI  C                   exsr      zzup6c
CBI  C                   goto      endup6
CBI  C                   endif
CBI  C*
     C                   move      *off          error6
     C                   if        $pcmd = '*VIEW   '  or
     C                             reccnt = 0
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup6
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     Csr                 goto      chkcw6
     C                   endif
     *
     *
     *   Special handling if transaction only has *PIRPICK records.
     *       Note: PIRTRAN record was locked in ZZINZ2 routine.
     *
     C                   if        pckcnt = reccnt
     C                   if        ptstat < '4'
     C                   eval      ptstat = '4'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     C                   endif
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup6
     C                   endif
     *
     *   Do pick update for each subfile record.
     *
     C                   if        reccnt > 0
     *          $PCMD     ANDNE'*VIEW   '
     C                   eval      posrec = 0
     *
     C                   move      *off          tskflg
     *
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail6                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        w6item = '*PIRPICK'
     C                   iter
     C                   endif
     *
     C                   eval      *in01 = *off
     C                   eval      *in21 = *off
     *
     C                   eval      error = *off
     C                   eval      newpck = w6qty
     C                   eval      newrpl = 0
     C                   eval      lblbl# = w6lbl#
     C                   if        w6mrg = 'Y'
     C                   if        clsflg = *on
     C                   exsr      zzpckm
     C                   endif
     C                   else
     C                   exsr      zzpick
416cA*
416cA*    User changed pick quantity. Log change in tracking file.
416cAC                   if        error = *off  and
416eMC                             w6qpck <> w6qty and
416eAC                             $pcmd = '*CHANGE '
416cAC                   move      'TR01'        trnbr
416cAC                   move      '*PCK050 '    trcode
416cAC                   movel     'ZZUPD6  '    trsr50
416cAC                   exsr      zztrck
416cAC                   endif
     C                   endif
     C                   if        error = *on
     C                   move      *on           error6
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   update    detail6
     C                   endif
     *
     C                   enddo
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     C                   if        error6 = *on
     C                   if        clsflg = *on
     C     $ptrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptstat = '3'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     C                   endif
     C                   endif
     C                   move      *on           error
     Csr                 goto      endup6
     C                   endif
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   endif
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
     C     chkcw6        tag
     *
     *  See if we should move on to catch weights.
     *  Note: Only check for wgt's when running in interactive mode.
     *
     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on  and
     C                             $jtype = *on
     *
     C                   if        wgtflg = *off
     ***        $PCMD     OREQ '*CLOSE  '
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   else
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   leave
     C                   endif
520gA*
520gAC                   if        lbitem = '9999999999'
520gAC     keyod         chain     orddm
520gAC                   if        %found(orddm)
520gAC                   eval      rtxdm1_base = ommsc1
520gAC                   if        rtxdm1_omcwcd = 'Y'
520gAC                   eval      itcwgt = 'Y'
520gAC                   endif
520gAC                   endif
520gAC                   endif
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
640eA*
640eA*  Delete catchwgt rcds on file, if zero qty picked when closing rcds.
640eAC                   if            itcwgt = 'Y'
640eAC                             and lbqpck = 0
640eAC                             and lbtype <> 'M'
640eAC                             and lbtype <> 'A'
640eAC                             and cwflg = *on
640eAC                             and clsflg = *on
640eAC                   exsr      zzcwdel
640eAC                   endif
640eA*
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
416kMC                             lbtype <> 'M' and
510gDC**                           lbtype <> 'A'
510gMC                             lbtype <> 'A' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
     *R                   MOVE *ON       REFRSH
     *R                   EXSR SCR07I
     *R                   LEAVE
DRYbA*
DRYbAC                   if        clsflg = '1'
DRYbAC                             and (client = Dairyland)
DRYbAC                   eval      $lcmd = '*EDITCLS'
DRYbAC                   else
     C                   eval      $lcmd = '*EDIT   '
DRYbAC                   endif
DRYbA*
HKWaAC                   select
HKWaAC                   when      client = hkw
HMWaAC                   when      client = hmwagner
GMMaAC                   when      client = menumaker
FSHaAC                   when      client = fischerfoods
HKWaAC                   other
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
530cAC                   eval      $lcmd = '*EDITCLS'
     C                   call      'CW113'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR'
     C                   if        $pcmd = '*VRFYCW '
     C                   eval      $lcmd = '*CHANGE '
     C                   else
     C                   eval      $lcmd = '*CHANGEP'
     C                   endif
DRYaD**
DRYaD**     Skip call to CW112 when closing transactions.
DRYaDC**                 if        clsflg = '1'
DRYaDC**                           and (client = Dairyland)
DRYaDC**                 else
     C                   call      'CW112'
     C                   parm                    $lparm
DRYaDC**                 endif
DRYaD**
     C                   endif
HKWaAC                   endsl
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup6
     C                   endif
     *
     C                   if        error = *off
     C                   if        clsflg = *on
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   endif
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C     endup6        endsr
     *----------------------------------------------------------------
     *
     *  ZZUP6A   Update for screen 6 when running in batch mode.
     *
     C     zzup6a        begsr
     C                   move      *off          error6
     *
     *   Do pick update for each label record.
     *
     C                   move      *off          tskflg
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        lbitem = '*PIRPICK'
     C                   iter
     C                   endif

650mA*    For *UPDSLBL only work with label that was sent
650mA
700cD **                 if        $pcmd = '*UPDSLBL' and lblbl# <> $plbl#
700cAC                   if        $pcmd = '*UPDSLBL' and lblbl# <> svplbl#
650mAC                   iter
650mAC                   endif
     *
     C                   move      *off          error
650pA*    For *UPDSLBL newpck gets set to pick qty sent in
650pAC                   if        $pcmd = '*UPDSLBL'
700cD **                 eval      newpck = $pqpck
700cAC                   eval      newpck = svpqpck
650pAc                   else
     C                   eval      newpck = lbqpck
650pAc                   endif
     C                   eval      newrpl = 0
     C                   if        lbtype = 'M'
     C                   if        clsflg = *on
     C                   exsr      zzpckm
     C                   endif
     C                   else
     C                   exsr      zzpick
     C                   endif
     *
     C                   if        error = *on
     C                   move      *on           error6
     C                   endif
     *
     C                   enddo
     *
     C                   if        error6 = *on
     C                   if        clsflg = *on
     C     $ptrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptstat = '3'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     C                   endif
     C                   endif
     C                   move      *on           error
     Csr                 goto      endu6a
     C                   endif
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
640aAC                   if        client = cheney
640aAC                   exsr      zzzExport
640aAC                   endif
     C                   endif
     *
     C     endu6a        tag
     *
     *    We force ERROR *OFF because if it is left on, the program
     *    will try and display the entry screen. Not a good idea
     *    when running in batch mode.
     *
     C                   move      *off          error
     *
     C                   endsr
     *----------------------------------------------------------------
     *
CBI  *  ZZUP6C   Update for screen 6 Custom of ZZUPD6
     *
     C     zzup6c        begsr
     C                   move      *off          error6
     C                   if        $pcmd = '*VIEW   '  or
     C                             reccnt = 0
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endu6c
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     Csr                 goto      chkc6c
     C                   endif
     *
     *
     *   Special handling if transaction only has *PIRPICK records.
     *       Note: PIRTRAN record was locked in ZZINZ2 routine.
     *
     C                   if        pckcnt = reccnt
     C                   if        ptstat < '4'
     C                   eval      ptstat = '4'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
640aAC                   exsr      zzzExport
     C                   endif
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endu6c
     C                   endif
     *
     *   Do pick update for each subfile record.
     *
     C                   if        reccnt > 0
     *          $PCMD     ANDNE'*VIEW   '
     C                   eval      posrec = 0
     *
     C                   move      *off          tskflg
     *
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail6                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   if        w6item = '*PIRPICK'
     C                   iter
     C                   endif
     *
     C                   eval      *in01 = *off
     C                   eval      *in21 = *off
     *
     C                   eval      error = *off
     C                   eval      newpck = w6qty
     C                   eval      newrpl = 0
     C                   eval      lblbl# = w6lbl#
     C                   if        w6mrg = 'Y'
     C                   if        clsflg = *on
     C                   exsr      zzpckm
     C                   endif
     C                   else
     C                   exsr      zzpick
416cA*
416cA*    User changed pick quantity. Log change in tracking file.
416cAC                   if        error = *off  and
416eMC                             w6qpck <> w6qty and
416eAC                             $pcmd = '*CHANGE '
416cAC                   move      'TR01'        trnbr
416cAC                   move      '*PCK050 '    trcode
416cAC                   movel     'ZZUPD6  '    trsr50
416cAC                   exsr      zztrck
416cAC                   endif
     C                   endif
     C                   if        error = *on
     C                   move      *on           error6
     C                   eval      *in01 = *on
     C                   eval      *in21 = *on
     C                   eval      *in85 = *on
     C                   update    detail6
     C                   endif
     *
     C                   enddo
416cA*
416cA*    Write out Close route Header in tracking file.
416cAC                   move      '*PCK001 '    trcode
416cAC                   exsr      zztrck
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     C                   if        error6 = *on
     C                   if        clsflg = *on
     C     $ptrn#        chain     pirtran                            79
     C                   if        not *in79
     C                   eval      ptstat = '3'
     **                   Z-ADDTODAY     PTCDTE
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
640oAc                   exsr      zzwrttrand
     C                   endif
     C                   endif
     C                   move      *on           error
     Csr                 goto      endu6c
     C                   endif
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     C                   endif
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
     C     chkc6c        tag
     *
     *  See if we should move on to catch weights.
     *  Note: Only check for wgt's when running in interactive mode.
CBIf *        AND PT132 was not called with *CLOSENC.
CBIn *        AND PT132 was not called with *CLOSEC1.
     *
     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on  and
CBIf C                             $jtype = *on  and
CBInMC                             flagnc = *off and
CBInAC                             flagc1 = *off
     *
     C                   if        wgtflg = *off
     ***        $PCMD     OREQ '*CLOSE  '
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   else
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     *R                   Z-ADD$PTRN#    ERTRN#
     *R                   EXSR ZM30
     *R                   MOVE 'EOJ'     NXTSCR
     C                   leave
     C                   endif
520gA*
520gAC                   if        lbitem = '9999999999'
520gAC     keyod         chain     orddm
520gAC                   if        %found(orddm)
520gAC                   eval      rtxdm1_base = ommsc1
520gAC                   if        rtxdm1_omcwcd = 'Y'
520gAC                   eval      itcwgt = 'Y'
520gAC                   endif
520gAC                   endif
520gAC                   endif
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
720cAC                   eval      gPltId = lbpal#
720cAC                   exsr      GetGenInfo
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
CBIcDC**                           lbtype <> 'M' and
720cDC**                           lbpal# <  20000 and
720cMC                             gGenTruck and
416kAC                             lbtype <> 'A'
510gDC**                           and lbasl2 <> '***'
510gMC                             and lbasl2 <> '***' or
510gAC                             itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
     *R                   MOVE *ON       REFRSH
     *R                   EXSR SCR07I
     *R                   LEAVE
     C                   eval      $lcmd = '*EDIT   '
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
     C                   call      'CW113'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR'
     C                   if        $pcmd = '*VRFYCW '
     C                   eval      $lcmd = '*CHANGE '
     C                   else
     C                   eval      $lcmd = '*CHANGEP'
     C                   endif
     C                   call      'CW112'
     C                   parm                    $lparm
     C                   endif
     C                   endif
     C                   enddo
     C                   endif
     *
     C                   endif
     *
     C                   if        $pcmd = '*VRFYCW '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endu6c
     C                   endif
     *
     C                   if        error = *off
     C                   if        clsflg = *on
640aAC                   exsr      zzzExport
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   endif
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C     endu6c        endsr
700gA*----------------------------------------------------------------
700gA*  ZZUP6V   Update for screen 6 when called from Voice
700gA*----------------------------------------------------------------
700gA
700gAC     zzup6v        begsr
     C                   move      *off          error6

     *   First, check for catchweight problems.
     *   If any found,
     *     Then get out and tran will have to be closed normally.

     C                   if        opcapc = 'Y'  and
     C                             clsflg = *on
     *
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7
     C                   if        %eof(label7)
     C                   leave
     C                   endif
520gA*
510gA*  Set on c/w flag if c/w records exist.
510gAC                   exsr      zzcw
720cAC                   eval      gPltId = lbpal#
720cAC                   exsr      GetGenInfo
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
416kMC                             lbtype <> 'M' and
CBIkDC*                            lbtype <> 'A' or
CBIkMC                             lbtype <> 'A'
CBIkAC                             and client <> Cheney
CBIkA*
CBIkDC*                            itcwgt = 'Y'  and
CBIkMC                             or itcwgt = 'Y'  and
510gAC                             lbqpck = 0  and
510gAC                             cwflg = *on
CBIkAC                             and client <> Cheney
CBIkA*
CBIkAC                             or client = Cheney
CBIkAC                             and itcwgt = 'Y'
CBIkAC                             and lbqpck > 0
CBIkAC                             and lbtype <> 'M'
CBIkAC                             and lbtype <> 'A'
720cDC**                           and lbpal# < 20000
720cMC                             and gGenTruck
CBIkAC                             and lbasl2 <> '***'
DRYbA*
     C                   eval      $lwhse = $pwhse
     C                   eval      $ltrn# = $ptrn#
     C                   eval      $litem = lbitem
     C                   eval      $lseq# = lbseq
     C                   eval      $llbl# = lblbl#
700fA
700fAC                   if        clsflg = '1'
700fAC                   eval      $lcmd = '*EDITCLS'
700fAC                   else
700fA
     C                   eval      $lcmd = '*EDIT'
700fAC                   endif
700fA
     C                   call      'CW113'
     C                   parm                    $lparm

     C                   if        $lrtn = '*ERROR'
     C                   goto      endu6z
     C                   endif

     C                   endif

     C                   enddo

     C                   endif

     *   No catchweight problems, so close the label records.

     C                   move      *off          tskflg
     C     keylb7        setll     label7
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7

     C                   if        %eof(label7)
     C                   leave
     C                   endif
     *
     C                   if        lbitem = '*PIRPICK'
     C                   iter
     C                   endif
     *
     C                   move      *off          error
     C                   eval      newpck = lbqpck
     C                   eval      newrpl = 0
     C                   if        lbtype = 'M'
     C                   if        clsflg = *on
     C                   exsr      zzpckm
     C                   endif
     C                   else
     C                   exsr      zzpick
     C                   endif

     C                   if        error = *on
     C                   eval      error6 = *on
     C                   leave
     C                   endif

     C                   enddo

     C                   if        error6 = *on
     C                   if        clsflg = *on
     C     $ptrn#        chain     pirtran
     C                   if        %found(pirtran)
     C                   eval      ptstat = '3'
     C                   time                    ptctim
     C                   if        ptctim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      ptcdte = today
     C                   update    ptrec
     C                   endif
     C                   endif
     C                   goto      endu6z
     C                   endif
     *
     C                   if        clsflg = *on
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
CBIhAC                   exsr      zzzExport
     C                   endif

     C     endu6z        tag

     *    We force ERROR *OFF because if it is left on, the program
     *    will try and display the entry screen. Not a good idea
     *    when running in batch mode.

     C                   move      *off          error

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD7   Update for screen 7.
     *
     C     zzupd7        begsr
     C                   move      *off          error
     *R         $PCMD     IFEQ '*VIEW   '
     *R                   MOVE 'EOJ'     NXTSCR
     *R                   GOTO ENDUP7
     *R                   ENDIF
     *
     *   Update catch weight for each subfile record.
     *
     C                   if        reccnt > 0  and
     C                             $pcmd <> '*VIEW   '
     C                   eval      posrec = 0
     *
     C                   eval      *in79 = *off
     C                   dou       *in79
     C                   readc     detail7                                79
     *
     C                   if        *in79
     C                   leave
     C                   endif
     *
     C                   eval      *in01 = *off
     C                   eval      *in21 = *off
     *
     C     keyoc         chain     ordc                               78
     *
     C                   select
     C                   when      w7cwgt = 0
     C                   if        not *in78
     C                   delete    ocrec
650eAc                   eval      processstatus = '*DELETE'
650eAc                   exsr      processCWLog
     C                   endif
     *
     C                   other
     C                   if        not *in78
     C                   eval      occwgt = w7cwgt
     C                   update    ocrec
650eAc                   eval      processstatus = '*CHK4UPD'
650eAc                   exsr      processCWLog
     C                   else
     C                   eval      ocwhse = lbwhse
     C                   eval      ocord = lbord
     C                   eval      ocseq# = lbseq
     C                   eval      ocitem = lbitem
     C                   eval      ocseq = w7line
     C                   eval      octran = lbtrn#
     C                   eval      occwgt = w7cwgt
     C                   write     ocrec
650eAc                   eval      processstatus = '*ADD'
650eAc                   exsr      processCWLog
     C                   endif
     C                   endsl
     *
     C                   enddo
     *
     C                   if        posrec = 0
     C                   eval      posrec = 1
     C                   endif
     *
     C                   endif
     *
     C                   dou       forevr <> forevr
     C     keylb7        reade     label7                                 79
     C                   if        *in79
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     C                   leave
     C                   endif
     C                   if        itcwgt = 'Y'  and
     C                             lbqpck > 0  and
     C                             lbtype <> 'M'
     C                   move      *on           refrsh
     C                   exsr      scr07i
     C                   leave
     C                   endif
     C                   enddo
     C     endup7        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD8   Update for screen 8.
     *
     C     zzupd8        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup8
     C                   endif
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w8qrpl
     C                   exsr      zzput
     C     error         cabeq     *on           endup8
     *
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     C     endup8        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD9   Update for screen 9.
     *
     C     zzupd9        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endup9
     C                   endif
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w9qrpl
     C                   exsr      zzput
     C     error         cabeq     *on           endup9
     *
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
416 A*    Return quantity changed. Write variance rcd to returns file.
416nA*    Note: Only do this when closing progam is not RC200 - RF Put-
416nA*    away program.
416 AC                   if        w9qrpl <> lbqalc  and
416 AC                             oprqch = 'Y'
416nAC                             and $pprg <> 'RC200'
416 A*
416 A*    Calculate return quantity change.
416 AC                   eval      $rrqty = w9qrpl - lbqalc
416 A*
416 A*    Write variance rcd to returns file.
416 AC                   call      'RN175'
416 AC                   parm      lbwhse        $rwhse
416 AC                   parm      lbpbat        $rpbat
416 AC                   parm      lbtrn#        $rtrn#            7 0
416 AC                   parm      lbitem        $ritem
416 AC                   parm                    $rrqty            7 0
416 AC                   parm      lbucod        $rucod            2
416 AC                   parm      lbutyp        $rutyp            1
416 AC                   parm      itcwgt        $rcwgt            1
416 AC                   parm      itswgt        $rswgt            7 2
416 AC                   parm      itum2         $rum2             2
416 AC                   parm      itumq2        $rumq2            3 0
416 AC                   parm      itum3         $rum3             2
416 AC                   parm      itumq3        $rumq3            3 0
416 AC                   parm      *blanks       $rstat
416 A*
416 AC                   endif
416 A*
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     C     endup9        endsr
     *----------------------------------------------------------------
     *
     *  ZZUP10   Update for screen 10.
     *
     C     zzup10        begsr
     C                   move      *off          error
     C                   if        $pcmd = '*VIEW   '
     C                   move      'EOJ'         nxtscr
     Csr                 goto      endu10
     C                   endif
     *
     C                   move      *off          tskflg
     *
     C                   eval      newpck = w4qpck
     C                   eval      newrpl = w4qrpl
     C                   exsr      zzpckb
     C     error         cabeq     *on           endu10
     *
     C                   exsr      zzrcv
     C     error         cabeq     *on           endu10
     *
     C                   call      @adjtd
     C                   parm      '*CLOSE  '    $lcmd
     C                   parm      $ptype        $ltype
     C                   parm                    ptparm
     C                   parm                    $lrtn
     C                   parm                    $lmsg
     *                    PARM '*CLOSE  '$PCMD   8
     *                    PARM '*INTER  '$PTYPE  8
     *                    PARM           PTPARM
     *                    PARM           $PRTN   8
     *                    PARM           $PMSG   4
     *
     C                   eval      ertrn# = $ptrn#
     C                   exsr      zm30
     C                   move      'EOJ'         nxtscr
     C     endu10        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDO   Update order detail record.
     *
     C     zzupdo        begsr
     *
     C                   select
     *
     *   First time closing label.
     *
     C                   when      svstat <> 'C'
     *
     *      Increase picked qty by actual qty entered by user.
     *
     *
     *       For SSB item, qty must be converted from Base qty type
     *         into SSB qty type (ie. Brkdwn1 into Normal).
     *
     C                   if        ittype = 'S'
417n C                             or ittype = 'A'
417n C                             and #bityp = 'S'
     C                   select
     C                   when      lbutyp = '1'
520iD ***                eval      odqpk1 = newpck
520iMC                   eval      odqpk1 += newpck
     C                   when      lbutyp = '2'
520iD ***                eval      odqpk2 = newpck
520iMC                   eval      odqpk2 += newpck
     C                   endsl
     C                   else
     C                   select
     C                   when      lbutyp = 'N'
     C                   add       newpck        odqpk1
     C                   when      lbutyp = '1'
     C                   add       newpck        odqpk2
     C                   when      lbutyp = '2'
     C                   add       newpck        odqpk3
     C                   endsl
     C                   endif
     *
     *   Closing adjustment.
     *
     C                   other
     *
     *      Decrease picked qty by difference.
     *
     C                   select
     C                   when      lbutyp = 'N'
     C                   eval      odqpk1 = odqpk1 - difpck
     C                   when      lbutyp = '1'
     C                   eval      odqpk2 = odqpk2 - difpck
     C                   when      lbutyp = '2'
     C                   eval      odqpk3 = odqpk3 - difpck
     C                   endsl
     *
     C                   endsl
     *
     *   Update order detail record.
     *
     C                   update    odrec
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPPO   Update P.O. detail record.
     *
     *R         ZZUPPO    BEGSR
     *
     *R                   SELEC
     *
     *   First time closing label.
     *
     *R         SVSTAT    WHNE 'C'
     *
     *      Increase received qty by actual qty entered by user.
     *
     *R                   SELEC
     *R         LBUTYP    WHEQ 'N'
     *R                   ADD  NEWPCK    PDQRC1
     *R         LBUTYP    WHEQ '1'
     *R                   ADD  NEWPCK    PDQRC2
     *R         LBUTYP    WHEQ '2'
     *R                   ADD  NEWPCK    PDQRC3
     *R                   ENDSL
     *
     *   Closing adjustment.
     *
     *R                   OTHER
     *
     *      Decrease received qty by difference.
     *
     *R                   SELEC
     *R         LBUTYP    WHEQ 'N'
     *R                   SUB  DIFPCK    PDQRC1
     *R         LBUTYP    WHEQ '1'
     *R                   SUB  DIFPCK    PDQRC2
     *R         LBUTYP    WHEQ '2'
     *R                   SUB  DIFPCK    PDQRC3
     *R                   ENDSL
     *
     *R                   ENDSL
     *
     *   Update P.O. detail record.
     *
     *R                   UPDATPDREC
     *
     *R                   ENDSR
     *----------------------------------------------------------------
     *
     *  ZZUPDP   Update picking slot record.
     *
     C     zzupdp        begsr

416lA*   Initialize interface quantities.

416lAC                   eval      $drisubcmd = ' '
416lAC                   exsr      zzzinit$slot
VIP A*
520aD **                 select
520aD **                 when      client = VIP
600cDC**                 eval      $uqty1 = 0
600cDC**                 eval      $uqty2 = 0
600cDC**                 eval      $uqty3 = 0
520aD **                 endsl
VIP A*
     *
     *    Wrong item in slot, bypass all slot updates.
     *
     C     wrgitm        cabeq     *on           endupp
     *
510b *    Don't execute ZZUPPQ for OUT label.
     C                   if        clsflg = *off
510bAC                   if        outlbl = *off
     C                   exsr      zzuppq
510b C                   endif
     Csr                 goto      endupp
     C                   endif
     *
     *R                   MOVE *OFF      ITMFLG
     *R         ITMFLG    IFEQ *OFF
     *R         KEYIT     CHAINPIRITEM              75
     *R         *IN75     IFEQ *ON
     *R                   Z-ADD0         ITUMQ2
     *R                   Z-ADD0         ITUMQ3
     *R                   ENDIF
     *R                   MOVE *ON       ITMFLG  1
     *R                   ENDIF
     *
     C                   if        itmflg = *off
     C                   move      lbwhse        kywhse
     C                   move      lbitem        kyitem
     C                   exsr      zzitem
     C                   endif
     *
     C                   select
     *
     *   First time closing label.
     *
     C                   when      lbstat <> 'C'
416lAC                   eval      $saorgu = *on
416lAC                   eval      $saqtyu = *on
     *
     *      Reduce picked qty by label picked quantity.
     *
     *        Note: Picked qty shouldn't go negative but protect
     *              against it anyway.
     *
     C                   if        pckqty > 0
416lAC                   eval      $drisubcmd  = '%CLSPICK'
     C                   select
     C                   when      lbutyp = 'N'
416lAC                   eval      $saorg1 = pckqty
VIP A*
520aD **                 if        client = VIP
600cDC**                 eval      $uqty1  = -(pckqty)
520aD **                 endif
VIP A*
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
640hAC                             and outlbl = *off
     C                   if        pckqty > slpck1
     C                   eval      slpck1 = 0
     C                   else
     C                   eval      slpck1 = slpck1 - pckqty
     C                   endif
500j C                   endif
520dA
520dAC*        DRI program not being used for update
520dAC*        so just commented brkdn2 fields for now.
     C                   when      lbutyp = '1'
520dDC**                 eval      $saorg2 = pckqty
VIP A*
520aD **                 if        client = VIP
520dDC**                 eval      $uqty2  = -(pckqty)
520aD **                 endif
VIP A*
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
640hAC                             and outlbl = *off
520dAC                   if        pckqty < 0
520dAC                   eval      svqty2 = -(pckqty)
520dAC                   exsr      zzAlloc1
520dAC                   else
520dAC                   eval      svqty2 = pckqty
520dAC                   exsr      zzUnpick1
520dAC                   endif
520dDC**                 if        pckqty > slpck2
520dDC**                 eval      slpck2 = 0
520dDC**                 else
520dDC**                 eval      slpck2 = slpck2 - pckqty
520dDC**                 endif
500j C                   endif
520dA
     C                   when      lbutyp = '2'
416lAC                   eval      $saorg3 = pckqty
VIP A*
520aD **                 if        client = VIP
600cDC**                 eval      $uqty3  = -(pckqty)
520aD **                 endif
VIP A*
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
640hAC                             and outlbl = *off
     C                   if        pckqty > slpck3
     C                   eval      slpck3 = 0
     C                   else
     C                   eval      slpck3 = slpck3 - pckqty
     C                   endif
500j C                   endif
     C                   endsl
     C                   endif
     *
     *      Reduce transfer qty by label qty picked for transfer.
     *
     *        Note: Transfer qty shouldn't go negative but protect
     *              against it anyway.
     *
     C                   if        tfrqty > 0
416lAC                   eval      $drisubcmd  = '%CLSTFROUT'
     C                   select
     C                   when      lbutyp = 'N'
416lAC                   eval      $saorg1 = tfrqty
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        tfrqty > sltfr1
     C                   eval      sltfr1 = 0
     C                   else
     C                   eval      sltfr1 = sltfr1 - tfrqty
     C                   endif
500j C                   endif
     C                   when      lbutyp = '1'
416lAC                   eval      $saorg2 = tfrqty
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        tfrqty > sltfr2
     C                   eval      sltfr2 = 0
     C                   else
     C                   eval      sltfr2 = sltfr2 - tfrqty
     C                   endif
500j C                   endif
     C                   when      lbutyp = '2'
416lAC                   eval      $saorg3 = tfrqty
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        tfrqty > sltfr3
     C                   eval      sltfr3 = 0
     C                   else
     C                   eval      sltfr3 = sltfr3 - tfrqty
     C                   endif
500j C                   endif
     C                   endsl
     C                   endif
     *
     *      Reduce stock by actual qty picked for order plus actual
     *      quantity picked for transfer (if any).
     *
     *        Note: Stock quantity could go negative if a receiving
     *              transaction has not been closed yet so let it be.
     *
     C                   select
520dA
KFSbAC                   when          client = Kellys
KFSbAC                             and lbasl2 = '***'
KFSbA*    Skip update of stock qty when non-stock item.
KFSbA*
     C                   when      lbutyp = 'N'
416lAC                   eval      $saqty1 = newpck + newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slstk1 = slstk1 - newpck
     C                   eval      slstk1 = slstk1 - newrpl
500j C                   endif
520dA
520dAC*        DRI program not being used for update
520dAC*        so just commented brkdn2 fields for now.
     C                   when      lbutyp = '1'
520dDC**                 eval      $saqty2 = newpck + newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
520dAC                   exsr      zzPick1
520dDC**                 eval      slstk2 = slstk2 - newpck
     C                   eval      slstk2 = slstk2 - newrpl
500j C                   endif
520dA
     C                   when      lbutyp = '2'
416lAC                   eval      $saqty3 = newpck + newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slstk3 = slstk3 - newpck
     C                   eval      slstk3 = slstk3 - newrpl
500j C                   endif
     C                   endsl
     *
     *   Closing adjustment.
     *
     C                   other

416lAC                   eval      $drisubcmd  = '%STOCK'
416lAC                   eval      $saqtyu = *on

     *
     *      Increase stock by difference.
     *
     *        Note: Stock quantity could go negative if a receiving
     *              transaction has not been closed yet so let it be.
     *
     C                   select
520dA
     C                   when      lbutyp = 'N'
416lAC                   eval      $saqty1 = difpck + difrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   add       difpck        slstk1
     C                   add       difrpl        slstk1
500j C                   endif
520dA
520dAC*        DRI program not being used for update
520dAC*        so just commented brkdn2 fields for now.
     C                   when      lbutyp = '1'
416lAC                   eval      $saqty2 = difpck + difrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
520dDC**                 add       difpck        slstk2
520dMC                   exsr      zzAddDif1
     C                   add       difrpl        slstk2
500j C                   endif
520dA
     C                   when      lbutyp = '2'
416lAC                   eval      $saqty3 = difpck + difrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   add       difpck        slstk3
     C                   add       difrpl        slstk3
500j C                   endif
     C                   endsl
     *
     C                   endsl
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      jmpsa8
500j C                   endif
     *   Adjust breakdown qty's so they are not negative.
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
     C                   parm                    stock1
     C                   parm                    stock2
     C                   parm                    stock3
     *
     C                   parm                    avail1
     C                   parm                    avail2
     C                   parm                    avail3
     *
     *     Breakdown 1 quantity.
     *
     *        Break carton if we need more stock.
     *
     *R         AVAIL2    DOWLT0
     C                   dow       stock2 < 0
     *R         ITMFLG    IFEQ *OFF
     *R         KEYIT     CHAINPIRITEM              75
     *R         *IN75     IFEQ *ON
     *R                   Z-ADD0         ITUMQ2
     *R                   Z-ADD0         ITUMQ3
     *R                   ENDIF
     *R                   MOVE *ON       ITMFLG  1
     *R                   ENDIF
     C                   if        itumq2 <= 0
     C                   leave
     C                   endif
520dDC**                 eval      ckstk2 = slstk2
520dDC**                 if        ckstk2 < 0
520dDC**                 eval      ckstk2 = ckstk2 * -1
520dDC**                 endif
520dDC**                 eval      maxq = 999 - ckstk2
520dDC**                 if        itumq2 > maxq
520dDC**                 leave
520dDC**                 endif
     C                   eval      slstk1 = slstk1 - 1
     C                   eval      avail1 = avail1 - 1
     C                   eval      stock1 = stock1 - 1
     C                   add       itumq2        slstk2
     C                   add       itumq2        avail2
     C                   add       itumq2        stock2
     C                   enddo
     *
     *     Breakdown 2 quantity.
     *
     *        Break carton if we need more stock.
     *
     *R         AVAIL3    DOWLT0
     C                   dow       stock3 < 0
     *R         ITMFLG    IFEQ *OFF
     *R         KEYIT     CHAINPIRITEM              75
     *R         *IN75     IFEQ *ON
     *R                   Z-ADD0         ITUMQ2
     *R                   Z-ADD0         ITUMQ3
     *R                   ENDIF
     *R                   MOVE *ON       ITMFLG
     *R                   ENDIF
     C                   if        itumq2 <= 0  or
     C                             itumq3 <= 0
     C                   leave
     C                   endif
     **         AVAIL2    IFGT 0
     C                   if        stock2 > 0
     C                   eval      slstk2 = slstk2 - 1
     C                   eval      avail2 = avail2 - 1
     C                   eval      stock2 = stock2 - 1
     C                   add       itumq3        slstk3
     C                   add       itumq3        avail3
     C                   add       itumq3        stock3
     C                   else
     C                   eval      slstk1 = slstk1 - 1
     C                   eval      avail1 = avail1 - 1
     C                   eval      stock1 = stock1 - 1
     C                   add       itumq2        slstk2
     C                   add       itumq2        avail2
     C                   add       itumq2        stock2
     *
     C                   eval      slstk2 = slstk2 - 1
     C                   eval      avail2 = avail2 - 1
     C                   eval      stock2 = stock2 - 1
     C                   add       itumq3        slstk3
     C                   add       itumq3        avail3
     C                   add       itumq3        stock3
     C                   endif
     *
     C                   enddo
     *
     *   Even though stock qty can go negative the available qty
     *   should never go negative. If it does, display error that
     *   there is not enough stock in slot for transaction.
     *
     *   Truck Build has changed the above statement.  Because Truck
     *   Build allows a pause between allocation and picking the
     *   available qty can be negative for a Fixed Pick (Home) slot.
     *   For a Fixed item everything is allocated from its Pick slot.
     *   If the quantity needed is in the warehouse but not in the
     *   Pick slot, then the available quantity would go negative.
     *   During the picking phase letdowns are created to bring the
     *   available quantity back to a positive quantity or the
     *   quantity to be picked it reduced because of not enough
     *   stock.
     *
     *   Therefore, the logic below has been change to look at the
     *   STOCK quantities calculated above instead of the available
     *   quantity. The STOCK quanity is the slot's Stock Qty plus
     *   the slot's Receive Qty.  The quantity being picked can not
     *   be greater than the STOCK quantity in the slot.
     *
     *   NOTE:  The following tests for negative stock quanties
     *          is being conditioned to not test when the calling
     *          program is LT105. LT105 already does these tests
     *          prior to calling PT132 to close the transaction.
     *          A negative available qty may happen when there
     *          is more than 1 open replenishment transactions
     *          waiting to be processed.
     *
     *   Another note ...
     *
     *     In the past we forced a user to do a letdown if the any
     *     of the quantity being letdown had already been picked. By
     *     doing this we kept the slot quantity positive. This has
     *     now changed so the letdown user can zero out the letdown
     *     even if it is needed by picking. The ripple effect to this
     *     is that the user closing picking transactions is more
     *     likely to get a 'Not enough stock' error. To get around
     *     this, we decided to not make that a hard error. Instead,
     *     we will create a zero adjustment record to flag that this
     *     occured.
     *
416fA*     Now we are going to also base it on the OUTFLG field.
416fA*
     *          AVAIL1    IFLT 0
     C                   if        lbutyp = 'N'  and
     C                             stock1 < 0  and
     C                             $pprg <> 'LT105   '  or
     C                             lbutyp = '1'  and
     C                             stock2 < 0  and
     C                             $pprg <> 'LT105   '  or
     C                             lbutyp = '2'  and
     C                             stock3 < 0  and
     C                             $pprg <> 'LT105   '
416fA*
416fAC                   if        outlbl = *off  or
416fAC                             outlbl = *on  and
416fAC                             outadj = *on
416fA*
     C                   if        newpck <> 0
     **                   MOVE *ON       ERROR
     **                   MOVE *BLANKS   ERRMSG
     **                   MOVE SLDISP    ERDISP
     **         DIFPCK    ADD  DIFRPL    ERDIF
     **                   Z-SUBERDIF     ERDIF
     **                   EXSR ZM18
     **                   GOTO ENDUPP
     *
     *        Create adjustment record for exception.
     *        Since the qty will be 0, we can use the label item #.
     *
     C                   clear                   iarec
     C                   eval      iawhse = lbwhse
     C                   eval      iaitem = lbitem
     **                   Z-ADDTODAY     IADATE
     C                   time                    iatime
     C                   if        iatime < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      iadate = today
600bMC                   eval      iaby = #curruser
     C                   eval      iawhdp = lbwhdp
     C                   eval      iadisp = lbdisp
     C                   eval      iacwta = 0
     C                   eval      iaqty1 = 0
     C                   eval      iaqty2 = 0
     C                   eval      iaqty3 = 0
     *
     C                   movea     desc(5)       a30
     C                   movea     lbrte         a30(16)
     C                   move      lbtrn#        tempa7
     C                   movea     tempa7        a30(24)
     C                   movea     a30           iamemo
     *
     C                   eval      iacode = opexcd
     C                   write     iarec
     *
     C                   endif
     C                   endif
416fA*
416fAC                   endif
     *
     *   See if we need to change the slot status to 'Z '.
     *
     *     - All quantities have to be less than or equal to zero.
     *     - Slot must have one of the following characteristics:
     *         - PIR slot.
     *         - Fixed slot, non-reserved.
     *         - Fixed slot, reserved, non-picking.
     *     - Reserved picking slots are left alone.
     *
     *          SLSTK1    IFLE 0
     *          SLSTK2    ANDLE0
     *          SLSTK3    ANDLE0
     *          SLALC1    ANDLE0
     *          SLALC2    ANDLE0
     *          SLALC3    ANDLE0
     *          SLTFR1    ANDLE0
     *          SLTFR2    ANDLE0
     *          SLTFR3    ANDLE0
     *          SLPCK1    ANDLE0
     *          SLPCK2    ANDLE0
     *          SLPCK3    ANDLE0
     *          SLRCV1    ANDLE0
     *          SLRCV2    ANDLE0
     *          SLRCV3    ANDLE0
     *
     *          SLSTYP    IFEQ 'P'
     *
     *          SLSTYP    OREQ 'F'
     *          SLRSRV    ANDEQ'N'
     *
     *          SLSTYP    OREQ 'F'
     *          SLRSRV    ANDEQ'Y'
     *          SLPICK    ANDEQ'N'
     *
     *                    MOVE 'Z '      SLSTAT
     *                    Z-ADDTODAY     SLSDTE
     *                    TIME           SLSTIM
     *
     *                    ENDIF
     *                    ENDIF
     *
     *   Check if status needs to be changed
     *
     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
530aAC                   parm                    sldesg
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnews            2
     C                   parm                    $crtn             8
730cAC                   parm      lbwhdp        $cwhdp            5
730cAC                   parm      lbdisp        $cdisp           12
730cA*
650dA*  if item on-demand pick slot and overflow slots exist do not
650dA*  mark as zero status
650dAc                   if        slrsrv='V' and slpick='Y'
650dAc                              and $crtn = '*CHANGED'
650kAc                              and ittype = 'R'
650dAc                   exsr      chkovr
650dAc                   if        nbrovr > 0
650dAc                   eval      $crtn = '*OK'
650dAc                   endif
650dAc                   endif
     *
     C                   if        $crtn = '*CHANGED'  and
     C                             pttask <> 'REPLTF'  or
     *
     C                             $crtn = '*CHANGED'  and
     C                             pttask = 'REPLTF'  and
     C                             lbdisp <> lbdsp2
     *
     C                   eval      slstat = $cnews
     **                   Z-ADDTODAY     SLSDTE
     C                   time                    slstim
     C                   if        slstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      slsdte = today

416lAC                   eval      $slstatu = *on
416lAC                   eval      $slsdteu = *on
416lAC                   eval      $slstimu = *on

     C                   endif
     *
     *      Make sure breakdown qty's are not greater than
     *        quantity in the unit of measure.
     *
     *          SLSTK3    DOWGEITUMQ3
     *R         AVAIL3    DOWGEITUMQ3
     C                   dow       stock3 >= itumq3  and
     C                             itumq3 <> 0
     C                   eval      slstk3 = slstk3 - itumq3
     *R                   SUB  ITUMQ3    AVAIL3
     C                   eval      stock3 = stock3 - itumq3
     C                   add       1             slstk2
     C                   add       1             avail2
     C                   add       1             stock2
     C                   enddo
     *
     *          SLSTK2    DOWGEITUMQ2
     *R         AVAIL2    DOWGEITUMQ2
520dDC**                 dow       stock2 >= itumq2  and
520dDC**                           itumq2 <> 0
520dDC**                 eval      slstk2 = slstk2 - itumq2
520dDC**                 eval      avail2 = avail2 - itumq2
520dDC**                 eval      stock2 = stock2 - itumq2
520dDC**                 add       1             slstk1
520dDC**                 add       1             avail1
520dDC**                 add       1             stock1
520dDC**                 enddo
520dA
520dAC                   exsr      avail
520dAC                   dow       avail2 >= itumq2
520dAC                              and slstk2 >= itumq2
520dAC                              and itumq2 > 0
520dAC                   eval      slstk1 += 1
520dAC                   eval      slstk2 -= itumq2
520dAC                   eval      avail2 -= itumq2
520dAC                   enddo
520dAC                   exsr      avail
     *
     *   Update slot record.
     *
     *R                   UPDATSLREC
     C                   update    slrec                                70
VIP A*
520aD **                 select
520aD **                 when      client = VIP
VIP A*
600cDC**                 if           $uqty1 <> 0
600cDC**                           or $uqty2 <> 0
600cDC**                           or $uqty3 <> 0
VIP A*
600cDC**                 call      'UPDSLTDTE'
600cDC**                 parm      '*FIFO   '    $ucmd             8
600cDC**                 parm      #prog         $upgm            10
600cDC**                 parm      ' '           $upgm2           10
600cDC**                 parm      slwhse        $uwhse            3 0
600cDC**                 parm      slwhdp        $uwhdp            5
600cDC**                 parm      sldisp        $uslot           12
600cDC**                 parm      slpick        $upick            1
600cDC**                 parm      slitem        $uitem           15
600cDC**                 parm      ' '           $unewi           15
600cDC**                 parm      slentd        $uentd            8 0
600cDC**                 parm      slexpd        $uexpd            8 0
600cDC**                 parm                    $uqty1            5 0
600cDC**                 parm                    $uqty2            5 0
600cDC**                 parm                    $uqty3            5 0
600cDC**                 parm                    $urtn             8
VIP A*
600cDC**                 endif
VIP A*
520aD **                 endsl
VIP A*

416lAC                   exsr      zzzslot2ds
416lAC                   eval      $saitem = slitem
416lAC                   eval      $saitemu = *on
416lAC                   eval      $satrn# = pttrn#
416lAC                   eval      $satrn#u = *on
416lAC                   eval      $satask = pttask
416lAC                   eval      $satasku = *on
600bDC*****              eval      $salic# = lilcns
600bDC*****              eval      $salic#u = *on
416lAC                   eval      $dricommand = '*SLOT'
520dAC*        When this is changed to actually do update,
520dAC*        the update of the brkdn2 fields need to be revisited.
520dAC*        They are commented out above because we were running
520dAC*        into brkdn1 qtys greater than 999.
416lAC                   eval      $drireturn  = '*NOUPDATE*'
416lAC                   eval      chk4err = *off
416lAC                   eval      drierrmsg = *off
600bDC**********         exsr      zzzdricop
     *
600bAC                   exsr      zzzinit$slot
600bAC                   eval      $slwhseu = *on
600bAC                   eval      $slwhse  = slwhse
600bAC                   eval      $slwhdpu = *on
600bAC                   eval      $slwhdp  = slwhdp
600bAC                   eval      $sldispu = *on
600bAC                   eval      $sldisp  = sldisp
600bA
600bAC                   eval      $saActionU = *on
600bAC                   eval      $saAction = 'SEL'
600bAC                   eval      $saTrn#U = *on
600bAC                   eval      $saTrn# = pttrn#
600bAC                   eval      $saETrn#U = *on
600bAC                   eval      $saETrn# = 0
600bAC                   eval      $saLbl#U = *on
600bAC                   eval      $saLbl# = lblbl#
600bAC                   eval      $saToOrdU = *on
600bAC                   eval      $saToOrd = lbord
600bAC                   eval      $saToSeqU = *on
600bAC                   eval      $saToSeq = lbseq
600bA
600bAC                   eval      $dricommand = '*SLOT'
600bAC                   eval      $drisubcmd  = '%SYNCLCNS'
416lAC                   eval      $drireturn  = ' '
600bAC                   eval      $drisys2upd = 'D'
600bAC                   eval      chk4err = *off
600bAC                   eval      zmsflag = *off
600baC                   exsr      zzzdricop
730eAc*** auto transfer for lbspcl = 'XE'
730eAc                   if        lbspcl = 'XE'
730eAc                   eval      $auqty1 = 0
730eAc                   eval      $auqty2 = 0
730eAc                   eval      $auqty3 = 0
730eAc                   Select
730eAc                   when      lbutyp = 'N'
730eAc                   eval      $auqty1 = lbqpck
730eAc                   when      lbutyp = '1'
730eAc                   eval      $auqty2 = lbqpck
730eAc                   when      lbutyp = '2'
730eAc                   eval      $auqty3 = lbqpck
730eAc                   endsl
730eAc                   call      'AUTOTFR'
730eAc                   parm      '*CLRNEGAVL'  $aucmd           10
730eAc                   parm      $pwhse        $auwhse           3 0
730eAc                   parm      lbwhdp        $audept           5
730eAc                   parm      '*PICK'       $aufrmslot       12
730eAc                   parm      ''            $aufrmlcns       15
730eAc                   parm      lbdisp        $autoslot        12
730eAc                   parm                    $auqty1           5 0
730eAc                   parm                    $auqty2           5 0
730eAc                   parm                    $auqty3           5 0
730eAc                   endif
     *
500j C     jmpsa8        tag
     *                    ENDSR
     C     endupp        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDR   Update receiving slot record.
     *
     C     zzupdr        begsr

416lA*   Initialize interface quantities.

500j C                   if        opfeat <> '3'
416lAC                   eval      $drisubcmd = ' '
416lAC                   exsr      zzzinit$slot
500j C                   endif

     *   If Manual Put Away and stock not yet put in slot, don't
     *   update slot record.
     C                   if        $pmput = 'Y'  and
     C                             lbdisp = *blanks
     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD4840      LGLINE
     **                   WRITELGREC
     Csr                 goto      endpdr
     C                   endif
     *
     *R         KEYIT     CHAINPIRITEM              75
     *R         *IN75     IFEQ *ON
     *R                   Z-ADD0         ITUMQ2
     *R                   Z-ADD0         ITUMQ3
     *R                   ENDIF
     *
     C                   select
     *
     *   First time closing label.
     *
     C                   when      svstat <> 'C'

     C                   if        %subst(pttask:1:3) = 'PUT'
416lAC                   eval      $drisubcmd  = '%CLSRCV'
416lAC                   else
416lAC                   eval      $drisubcmd  = '%CLSTFRIN'
416lAC                   endif
416lAC                   eval      $saorgu = *on
416lAC                   eval      $saqtyu = *on
     *
     *      Reduce receive qty by label transfer quantity.
     *
     *        Note: Receive qty shouldn't go negative but protect
     *              against it anyway.
     *
     C                   select
     C                   when      lbutyp = 'N'
416lAC                   eval      $saorg1 = svqrmn
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        svqrmn > slrcv1
     C                   eval      slrcv1 = 0
     C                   else
     C                   eval      slrcv1 = slrcv1 - svqrmn
     C                   endif
500j C                   endif
     C                   when      lbutyp = '1'
416lAC                   eval      $saorg2 = svqrmn
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        svqrmn > slrcv2
     C                   eval      slrcv2 = 0
     C                   else
     C                   eval      slrcv2 = slrcv2 - svqrmn
     C                   endif
500j C                   endif
     C                   when      lbutyp = '2'
416lAC                   eval      $saorg3 = svqrmn
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   if        svqrmn > slrcv3
     C                   eval      slrcv3 = 0
     C                   else
     C                   eval      slrcv3 = slrcv3 - svqrmn
     C                   endif
500j C                   endif
     C                   endsl
     *
     *      Increase stock by actual qty transfer qty.
     *
     C                   select
     C                   when      lbutyp = 'N'
416lAC                   eval      $saqty1 = newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   add       newrpl        slstk1
500j C                   endif
     C                   when      lbutyp = '1'
416lAC                   eval      $saqty2 = newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   add       newrpl        slstk2
500j C                   endif
     C                   when      lbutyp = '2'
416lAC                   eval      $saqty3 = newrpl
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   add       newrpl        slstk3
500j C                   endif
     C                   endsl
     *
     *   Closing adjustment.
     *
     C                   other

416lAC                   eval      $drisubcmd = '%STOCK'
416lAC                   eval      $saqtyu = *on

     **                   Z-ADD$PTRN#    LGTRN#
     **                   TIME           LGDTTM
     **                   MOVE PTTASK    LGTASK
     **                   Z-ADDLBLBL#    LGLBL#
     **                   MOVE $PPRG     LGPGM
     **                   MOVE #USER     LGUSER
     **                   Z-ADD4896      LGLINE
     **                   WRITELGREC
     *
     *      Decrease stock by difference.
     *
     *        Note: Stock quantity could go negative if a receiving
     *              transaction has not been closed yet so let it be.
     *
     C                   select
     C                   when      lbutyp = 'N'
416lAC                   eval      $saqty1 = -(difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slstk1 = slstk1 - difrpl
500j C                   endif
     C                   when      lbutyp = '1'
416lAC                   eval      $saqty2 = -(difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slstk2 = slstk2 - difrpl
500j C                   endif
     C                   when      lbutyp = '2'
416lAC                   eval      $saqty3 = -(difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slstk3 = slstk3 - difrpl
500j C                   endif
     C                   endsl
     *
     C                   endsl
     *
     *   See if we need to change the slot status to 'Z '.
     *
     *     - All quantities have to be less than or equal to zero.
     *     - Slot must have one of the following characteristics:
     *         - PIR slot.
     *         - Fixed slot, non-reserved.
     *         - Fixed slot, reserved, non-picking.
     *     - Reserved picking slots are left alone.
     *
     *          SLSTK1    IFLE 0
     *          SLSTK2    ANDLE0
     *          SLSTK3    ANDLE0
     *          SLALC1    ANDLE0
     *          SLALC2    ANDLE0
     *          SLALC3    ANDLE0
     *          SLTFR1    ANDLE0
     *          SLTFR2    ANDLE0
     *          SLTFR3    ANDLE0
     *          SLPCK1    ANDLE0
     *          SLPCK2    ANDLE0
     *          SLPCK3    ANDLE0
     *          SLRCV1    ANDLE0
     *          SLRCV2    ANDLE0
     *          SLRCV3    ANDLE0
     *
     *          SLSTYP    IFEQ 'P'
     *
     *          SLSTYP    OREQ 'F'
     *          SLRSRV    ANDEQ'N'
     *
     *          SLSTYP    OREQ 'F'
     *          SLRSRV    ANDEQ'Y'
     *          SLPICK    ANDEQ'N'
     *
     *                    MOVE 'Z '      SLSTAT
     *                    Z-ADDTODAY     SLSDTE
     *                    TIME           SLSTIM
     *
     *R                   ENDIF
     *                    ENDIF
     *
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat = '3'
500j C                   goto      endpdr
500j C                   endif
     *   Check if status needs to be changed
     *
     C                   call      'CHKSTAT'
     C                   parm                    slwhse
     C                   parm                    slitem
     C                   parm                    slstyp
     C                   parm                    slrsrv
     C                   parm                    slpick
     C                   parm                    slstat
530aAC                   parm                    sldesg
     C                   parm                    slstk1
     C                   parm                    slstk2
     C                   parm                    slstk3
     C                   parm                    slalc1
     C                   parm                    slalc2
     C                   parm                    slalc3
     C                   parm                    sltfr1
     C                   parm                    sltfr2
     C                   parm                    sltfr3
     C                   parm                    slpck1
     C                   parm                    slpck2
     C                   parm                    slpck3
     C                   parm                    slrcv1
     C                   parm                    slrcv2
     C                   parm                    slrcv3
     C                   parm                    $cnews
     C                   parm                    $crtn
     *
     C                   if        $crtn = '*CHANGED'
     C                   eval      slstat = $cnews
     **                   Z-ADDTODAY     SLSDTE
     C                   time                    slstim
     C                   if        slstim < lsttim
     C                   exsr      zzzdte
     C                   endif
     C                   eval      slsdte = today

416lAC                   eval      $slstatu = *on
416lAC                   eval      $slsdteu = *on
416lAC                   eval      $slstimu = *on

     C                   endif
     *
     *      Calculate available quantity
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
     C                   parm                    stock1
     C                   parm                    stock2
     C                   parm                    stock3
     *
     C                   parm                    avail1
     C                   parm                    avail2
     C                   parm                    avail3
     *
     *
     *      Make sure breakdown qty's are not greater than
     *        quantity in the unit of measure.
     *
     *          SLSTK3    DOWGEITUMQ3
     C                   dow       avail3 >= itumq3  and
     C                             itumq3 <> 0
     C                   eval      slstk3 = slstk3 - itumq3
     C                   eval      avail3 = avail3 - itumq3
     C                   add       1             slstk2
     C                   add       1             avail2
     C                   enddo
     *
     *          SLSTK2    DOWGEITUMQ2
     C                   dow       avail2 >= itumq2  and
     C                             itumq2 <> 0
     C                   eval      slstk2 = slstk2 - itumq2
     C                   eval      avail2 = avail2 - itumq2
     C                   add       1             slstk1
     C                   add       1             avail1
     C                   enddo
     *
     *   Update slot record.
     *
     C                   update    slrec

416lAC                   exsr      zzzslot2ds
416lAC                   eval      $saitem = slitem
416lAC                   eval      $saitemu = *on
416lAC                   eval      $satrn# = pttrn#
416lAC                   eval      $satrn#u = *on
416lAC                   eval      $satask = pttask
416lAC                   eval      $satasku = *on
600bDC***                eval      $salic# = lilcns
600bDC***                eval      $salic#u = *on
416lAC                   eval      $dricommand = '*SLOT'
416lAC                   eval      $drireturn  = '*NOUPDATE*'
416lAC                   eval      chk4err = *off
416lAC                   eval      drierrmsg = *off
416lAC                   exsr      zzzdricop
     *
     C     endpdr        tag
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDW   Update warehouse quantities.
     *
     C     zzupdw        begsr
     *
BIRaAC                   if        client = Birite
KFSaAC                             or client = Kellys
SOFaAC                             or client = SofoFoods
BIRaA*      Bypass whse qty update for non-stock items.
BIRaAC                   if        lbasl2 = '***'
BIRaAC                   goto      endupw
BIRaAC                   endif
BIRaAC                   endif
BIRaA*
     C                   if        clsflg = *off
     C                   exsr      zzupwq
     Csr                 goto      endupw
     C                   endif
     *
500j *    For Stand-alone.
500j C                   if        opfeat = '3'
500j *      Reduce allocation by label picked quantity except when
500j *      label is for a special order.
500j C                   if        lbspcl = *blanks
500j C                   exsr      zzwhse
500j C     error         cabeq     *on           endupw
500j C                   endif
500j C                   goto      endupw
500j C                   endif
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     *
     C                   select
     *
     *   First time closing label.
     *
     C                   when      lbstat <> 'C'
     *
     *      Reduce allocation by label picked quantity except when
     *      label is for a special order.
     *
     C                   if        (lbspcl = *blanks
640hAC                             and outlbl = *off)
740 A**     The reason we reduced from quantity allocated for Drop Picks
740 A**     is because OR610 allocates to Drop Pick slots even thought
740 A**     they have inactive status because stock is not there until
740 A**     the replenishment is completed.  We need the allocation to
740 A**     reserve those pieces.  For the short time between both the
740 A**     allocation and replenishment being picked and prior to the
740 A**     close transaction being completed available will reflect double
740 A**     the quantity being pulled between the allocation and on hold qtys
740 AC                             or (lbspcl = 'DP'
740 AC                             and outlbl = *off)
520dDC**                 eval      $acmd = '*UNALLOC'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
520dAC                   eval      $acmd = '*UNALOCN'
     C                   eval      $aqty1 = lbqpck
     C                   when      lbutyp = '1'
520dAC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty2 = lbqpck
     C                   when      lbutyp = '2'
520dAC                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty3 = lbqpck
     C                   endsl
     C                   exsr      zzwhse
     C     error         cabeq     *on           endupw
     C                   endif
     *
     *      Reduce stock qty by the actual qty picked plus the
     *      actual qty transfered (if any).
     *
520dDC**                 eval      $acmd = '*UNSTOCK'
     *                    Z-ADD0         $AQTY1
     *                    Z-ADD0         $AQTY2
     *                    Z-ADD0         $AQTY3
416mAC                   eval      $aqty1 = 0
416mAC                   eval      $aqty2 = 0
416mAC                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
     *          NEWPCK    ADD  NEWRPL    $AQTY1
520dAC                   eval      $acmd = '*UNSTCKN'
     C                   eval      $aqty1 = newpck
     C                   when      lbutyp = '1'
     *          NEWPCK    ADD  NEWRPL    $AQTY2
520dAC                   eval      $acmd = '*UNSTCK1'
     C                   eval      $aqty2 = newpck
     C                   when      lbutyp = '2'
     *          NEWPCK    ADD  NEWRPL    $AQTY3
520dAC                   eval      $acmd = '*UNSTCK2'
     C                   eval      $aqty3 = newpck
     C                   endsl
     C                   exsr      zzwhse
     C     error         cabeq     *on           endupw
     *
     *      Reduce hold qty for special orders by the actual qty
     *      picked plus the actual qty transfered (if any).
     *
     C                   if        lbspcl <> *blanks
520dDC**                 eval      $acmd = '*RELEASE'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
520dAC                   eval      $acmd = '*RELEASN'
     C                   eval      $aqty1 = newpck + newrpl
     C                   when      lbutyp = '1'
520dAC                   eval      $acmd = '*RELEAS1'
     C                   eval      $aqty2 = newpck + newrpl
     C                   when      lbutyp = '2'
520dAC                   eval      $acmd = '*RELEAS2'
     C                   eval      $aqty3 = newpck + newrpl
     C                   endsl
     C                   exsr      zzwhse
     C     error         cabeq     *on           endupw
     C                   endif
     *
     *   Closing adjustment.
     *
     C                   other
     *
     *      Increase stock qty by difference.
     *
520dDC**                 eval      $acmd = '*STOCK  '
     *                    Z-ADD0         $AQTY1
     *                    Z-ADD0         $AQTY2
     *                    Z-ADD0         $AQTY3
416mAC                   eval      $aqty1 = 0
416mAC                   eval      $aqty2 = 0
416mAC                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
     *          DIFPCK    ADD  DIFRPL    $AQTY1
520dAC                   eval      $acmd = '*STOCKN '
     C                   eval      $aqty1 = difpck
     C                   when      lbutyp = '1'
     *          DIFPCK    ADD  DIFRPL    $AQTY2
520dAC                   eval      $acmd = '*STOCK1 '
     C                   eval      $aqty2 = difpck
     C                   when      lbutyp = '2'
     *          DIFPCK    ADD  DIFRPL    $AQTY3
520dAC                   eval      $acmd = '*STOCK2 '
     C                   eval      $aqty3 = difpck
     C                   endsl
     C                   exsr      zzwhse
     C     error         cabeq     *on           endupw
     *
     *      Increase hold qty for special order by difference.
     *
     C                   if        lbspcl <> *blanks
520dDC**                 eval      $acmd = '*HOLD   '
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
520dAC                   eval      $acmd = '*HOLDN  '
     C                   eval      $aqty1 = difpck + difrpl
     C                   when      lbutyp = '1'
520dAC                   eval      $acmd = '*HOLD1  '
     C                   eval      $aqty2 = difpck + difrpl
     C                   when      lbutyp = '2'
520dAC                   eval      $acmd = '*HOLD2  '
     C                   eval      $aqty3 = difpck + difrpl
     C                   endsl
     C                   exsr      zzwhse
     C     error         cabeq     *on           endupw
     C                   endif
     *
     C                   endsl
     *
     C     endupw        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPDQ   Update picking slot record when CLSFLG = *NO.
     *
     *    This routine is called from ZZUPDP when CLSFLG = *NO.
     *    Essentially, this routine replaces ZZUPDP in that situation.
     *    All this routine does, is to update the SLPCK and SLTFR
     *    quantities with the calculated difference.
     *
     C     zzuppq        begsr

416lA*   Initialize interface quantities.

416lAC                   eval      $drisubcmd = ' '
416lAC                   exsr      zzzinit$slot
     *
     C                   if        itmflg = *off
     C                   move      lbwhse        kywhse
     C                   move      lbitem        kyitem
     C                   exsr      zzitem
     C                   endif
     *
     *      Reduce picked/tfr qty by difference.
     *         (Diff = Label Qty - New Qty)
     *
     C                   select
520dA
     C                   when      lbutyp = 'N'
     C                   eval      $saqty1 = -(difpck + difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
640hAC                             and outlbl = *off
     C                   eval      slpck1 = slpck1 - difpck
     C                   eval      sltfr1 = sltfr1 - difrpl
500j C                   endif
510C *   Prevent negative pick quantity.
510c C                   if        slpck1 < 0
510c C                   eval      slpck1 = 0
510c C                   endif
520dA
     C                   when      lbutyp = '1'
     C                   eval      $saqty2 = -(difpck + difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
640hAC                             and outlbl = *off
520dDC**                 eval      slpck2 = slpck2 - difpck
520dAC                   if        difpck < 0
520dAC                   eval      svqty2 = -(difpck)
520dAC                   exsr      zzAlloc1
520dAC                   else
520dAC                   eval      svqty2 = difpck
520dAC                   exsr      zzUnpick1
520dAC                   endif
     C                   eval      sltfr2 = sltfr2 - difrpl
500j C                   endif
510C *   Prevent negative pick quantity.
510c C                   if        slpck2 < 0
510c C                   eval      slpck2 = 0
510c C                   endif
520dA
     C                   when      lbutyp = '2'
     C                   eval      $saqty3 = -(difpck + difrpl)
500j *    Skip to do nothing for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      slpck3 = slpck3 - difpck
     C                   eval      sltfr3 = sltfr3 - difrpl
500j C                   endif
510C *   Prevent negative pick quantity.
510c C                   if        slpck3 < 0
510c C                   eval      slpck3 = 0
510c C                   endif
520dA
     C                   endsl
     *
     *   Update slot record.
     *
     *R                   UPDATSLREC
500j *    Skip to do nothing for Stand-alone.
500j C     opfeat        cabeq     '3'           endupq
     C                   update    slrec                                70

     *   Call interface.

     *     Note: It is assumed that a transaction will not be updating
     *           the Pick and Transfer buckets at the same time. The
     *           only possibility of this would be for a BULKR task,
     *           which is no longer allowed.

     C                   if        difpck <> 0
     C                   eval      $drisubcmd = '%PICK'
     C                   else
     C                   eval      $drisubcmd = '%TFROUT'
     C                   endif

416lAC                   exsr      zzzslot2ds
416lAC                   eval      $saitem = slitem
416lAC                   eval      $saitemu = *on
416lAC                   eval      $satrn# = pttrn#
416lAC                   eval      $satrn#u = *on
416lAC                   eval      $satask = pttask
416lAC                   eval      $satasku = *on
600bDC***                eval      $salic# = lilcns
600bDC***                eval      $salic#u = *on
416lAC                   eval      $saqtyu  = *on
416lAC                   eval      $dricommand = '*SLOT'
416lAC                   eval      $drireturn  = '*NOUPDATE*'
416lAC                   eval      chk4err = *off
416lAC                   eval      drierrmsg = *off
416lAC                   exsr      zzzdricop
     *
     C     endupq        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPWQ   Update warehouse quantities when CLSFLG = *OFF
     *
     *    This routine is called from ZZUPDW when CLSFLG = *NO.
     *    Essentially, this routine replaces ZZUPDW in that situation.
     *    All this routine does, is to update the allocated warehouse
     *    quantities with the calculated difference.
     *
     C     zzupwq        begsr
     *
500j *    Skip for Stand-alone.
500j C                   if        opfeat <> '3'
     C                   eval      $aprg = #prog
     C                   eval      $atype = '*INTER  '
     C                   eval      $awhse = lbwhse
     C                   eval      $aitem = lbitem
     *
     *      Reduce allocation by difference except when
     *      label is for a special order.
     *
     C                   if        lbspcl = *blanks
520aDC**                 eval      $acmd = '*UNALLOC'
     C                   eval      $aqty1 = 0
     C                   eval      $aqty2 = 0
     C                   eval      $aqty3 = 0
     C                   select
     C                   when      lbutyp = 'N'
520dAC                   eval      $acmd = '*UNALOCN'
     C                   eval      $aqty1 = difpck
     C                   when      lbutyp = '1'
520dAC                   eval      $acmd = '*UNALOC1'
     C                   eval      $aqty2 = difpck
     C                   when      lbutyp = '2'
520dAC                   eval      $acmd = '*UNALOC2'
     C                   eval      $aqty3 = difpck
     C                   endsl
     C                   exsr      zzwhse
     C                   endif
500j C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZWHSE   Update warehouse quantities.
     *
     C     zzwhse        begsr
     *
500j *    Do nothing for Stand-alone.
500j C     opfeat        cabeq     '3'           endzzw
     C                   move      $aitem        svitem
     *
     *    If Alias item or Same Slot Breakdown item
     *      Then DO NOT update quantity of label item.
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   move      *on           error
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ADJQTYE1'
650mAC                   eval      $perm = 'Error updating warehouse qty'
650mAC                   else
     *R                   MOVE $LMSG     #MSGK
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
650mAC                   endif
     C                   endif
     C                   endif
     *
     *  If Alias or SSB item
     *   Then update Base item warehouse quantity.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
417mDC**                 move      #bitem        $aitem
417mMC                   move      #sitem        $aitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   move      *on           error
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ADJQTYE2'
650mAC                   eval      $perm = 'Error updating warehouse qty'
650mAC                   else
     *R                   MOVE $LMSG     #MSGK
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
650mAC                   endif
     C                   endif
     C                   endif
     *
     *  If Contract item and *STOCK or *UNSTOCK
     *   Then update Base item warehouse quantity.
     *    and allocate/unallocate Base item warehouse quantity.
     *
     *  Note: The *UNALLOC command does not effect the Contract
     *        item's Base item Allocated quantities.
     *
     C                   if        ittype = 'C'
     C                   if        $acmd <> '*UNALLOC'
520dAC                             and $acmd <> '*UNALOCN'
520dAC                             and $acmd <> '*UNALOC1'
520dAC                             and $acmd <> '*UNALOC2'
417mDC**                 move      #bitem        $aitem
417mMC                   move      #sitem        $aitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   move      *on           error
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ADJQTYE3'
650mAC                   eval      $perm = 'Error updating warehouse qty'
650mAC                   else
     *R                   MOVE $LMSG     #MSGK
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
650mAC                   endif
     C                   endif
     C                   endif
     *
     C                   if        $acmd = '*STOCK  '  or
     C                             $acmd = '*UNSTOCK'
     C                   if        $acmd = '*STOCK  '
     C                   eval      $acmd = '*ALLOC  '
     C                   else
     C                   eval      $acmd = '*UNALLOC'
     C                   endif
417mDC**                 move      #bitem        $aitem
417mMC                   move      #sitem        $aitem
     C                   call      'ADJQTY'
     C                   parm                    $acmd
     C                   parm                    $aprg
     C                   parm                    $atype
     C                   parm                    $awhse
     C                   parm                    $aitem
     C                   parm                    $aqty1
     C                   parm                    $aqty2
     C                   parm                    $aqty3
     C                   parm                    $artq1
     C                   parm                    $artq2
     C                   parm                    $artq3
     C                   parm                    $artn
     C                   parm                    $aerm
     *R         $LRTN     IFEQ '*PGMQ   '
     C                   if        $artn = '*PGMQ   '
     C                   move      *on           error
650mAC                   if        rtnMsgType = 'TEXT'
650mAC                   eval      $prtn = 'ADJQTYE4'
650mAC                   eval      $perm = 'Error updating warehouse qty'
650mAC                   else
     *R                   MOVE $LMSG     #MSGK
     C                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
650mAC                   endif
     C                   endif
     C                   endif
     C                   endif
     *
     C                   move      svitem        $aitem
     C     endzzw        endsr
     *----------------------------------------------------------------
     *
     *  ZZZDTE   Get date.
     *
     C     zzzdte        begsr
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    lsttim
     *
     C                   endsr

640aA*----------------------------------------------------------------
640aA*  ZZZExport  Export transaction to staging files.
640aA*----------------------------------------------------------------
640aA
640aAC     zzzExport     begsr

730iDC*                  if        opftp <> 'S'
730iDC*                  leavesr
730iDC*                  endif
730iAc                   select
730iAc                   when      opftp = 'S'
730iAc                   when      opftp = 'R'
730iAc                   other
730iAc                   leavesr
730iAc                   endsl

     C                   call      'RH155ST'
     C                   parm      $pwhse        $bwhse            3 0
     C                   parm      $ptrn#        $btrn#            7 0

     C                   endsr

620aA*----------------------------------------------------------------
620aA*  clr$slot  Clear $slot data structure fields
620aA*----------------------------------------------------------------
620aA
620aAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   clear                   $slot2
     C                   eval      $slver# = savever#
     C                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

416lA*----------------------------------------------------------------
416lA*  zzzdricop  Call DRICOP
416lA*----------------------------------------------------------------

416lAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
416pAC                   eval      $dridata2 = $item2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600bAC                   eval      $dridata2 = $slot2
     C                   endsl

416pAC                   select
416pA
416pAC                   when      $dricommand = '*ITEM'
600bMC                             or $dricommand = '*SLOT'
416pAC                   call(e)   'DRICOP'
416pAC                   parm                    $dricommand
416pAC                   parm                    $drisubcmd
416pAC                   parm                    $drisys2upd
416pAC                   parm      #prog         $driprogram
416pAC                   parm                    $drireturn
416pAC                   parm      ' '           $drimessage
416pAC                   parm                    $dridata
416pAC                   parm                    $dridata2
416pA
416pAC                   other
     C                   call(e)   'DRICOP'
     C                   parm                    $dricommand
     C                   parm                    $drisubcmd
     C                   parm                    $drisys2upd
     C                   parm      #prog         $driprogram
     C                   parm                    $drireturn
     C                   parm      ' '           $drimessage
     C                   parm                    $dridata
416pA
416pAC                   endsl

     C                   select

     C                   when      %error and chk4err
     C                   eval      error = *on
     C                   eval      errmsg    = 'Error occured on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        drierrmsg
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif
     C                   endif

     C                   when      $drireturn <> '*OK' and chk4err
     C                   eval      error = *on
     C                   if        drierrmsg
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C*******            exsr      zzerrind
     C                   endif
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
416pAC                   eval      $item2 = $dridata2
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600bMC                   eval      $slot2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

416lA*----------------------------------------------------------------
416lA*  zzzds2item  Move item ds fields into std item fields.
416lA*----------------------------------------------------------------

416lAC     zzzds2item    begsr

     C                   eval      itwhse = $itwhse
     C                   eval      ititem = $ititem
     C                   eval      ittype = $ittype
     C                   eval      itdesc = $itdesc
     C                   eval      itpdsc = $itpdsc
     C                   eval      itstyp = $itstyp
     C                   eval      itwhdp = $itwhdp
     C                   eval      itdesg = $itdesg
     C                   eval      itactv = $itactv
     C                   eval      itupc  = $itupc
     C                   eval      itbld  = $itbld
     C                   eval      itven# = $itven#
     C                   eval      itvit# = $itvit#
     C                   eval      itum1  = $itum1
     C                   eval      itum2  = $itum2
     C                   eval      itumq2 = $itumq2
     C                   eval      itflg1 = $itflg1
     C                   eval      itum3  = $itum3
     C                   eval      itumq3 = $itumq3
     C                   eval      itflg2 = $itflg2
     C                   eval      itulen = $itulen
     C                   eval      ituwdt = $ituwdt
     C                   eval      ituhgt = $ituhgt
     C                   eval      itcube = $itcube
     C                   eval      itswgt = $itswgt
     C                   eval      itcwgt = $itcwgt
     C                   eval      itreor = $itreor
     C                   eval      itrepl = $itrepl
     C                   eval      itrcvd = $itrcvd
     C                   eval      itflgd = $itflgd
     C                   eval      itflgb = $itflgb
     C                   eval      itslif = $itslif
     C                   eval      itnday = $itnday

     C     endds2item    endsr

416lA*----------------------------------------------------------------
416lA*  zzzds2slot  Move slot ds fields into std slot fields
416lA*----------------------------------------------------------------

416lAC     zzzds2slot    begsr

500j *    Do nothing for Stand-alone.
500j C     opfeat        cabeq     '3'           endds2
     C* Move information to data structure.

     C                   eval      slwhse = $slwhse
     C                   eval      slwhdp = $slwhdp
     C                   eval      sldisp = $sldisp
     C                   eval      slaisl = $slaisl
     C                   eval      slloc  = $slloc
     C                   eval      slrlvl = $slrlvl
     C                   eval      slhand = $slhand
     C                   eval      slside = $slside
     C                   eval      slstyp = $slstyp
     C                   eval      slstat = $slstat
     C                   eval      slsdte = $slsdte
     C                   eval      slstim = $slstim
     C                   eval      slsdef = $slsdef
     C                   eval      sldesg = $sldesg
     C                   eval      slactv = $slactv
     C                   eval      slbld  = $slbld
     C                   eval      slpick = $slpick
     C                   eval      slpseq = $slpseq
     C                   eval      slprty = $slprty
     C                   eval      slentd = $slentd
     C                   eval      slexpd = $slexpd
     C                   eval      slslfd = $slslfd
     C                   eval      slrsrv = $slrsrv
     C                   eval      slitem = $slitem
     C                   eval      slstk1 = $slstk1
     C                   eval      slstk2 = $slstk2
     C                   eval      slstk3 = $slstk3
     C                   eval      slalc1 = $slalc1
     C                   eval      slalc2 = $slalc2
     C                   eval      slalc3 = $slalc3
     C                   eval      sltfr1 = $sltfr1
     C                   eval      sltfr2 = $sltfr2
     C                   eval      sltfr3 = $sltfr3
     C                   eval      slpck1 = $slpck1
     C                   eval      slpck2 = $slpck2
     C                   eval      slpck3 = $slpck3
     C                   eval      slrcv1 = $slrcv1
     C                   eval      slrcv2 = $slrcv2
     C                   eval      slrcv3 = $slrcv3

     C     endds2        endsr

416lA*----------------------------------------------------------------
416lA*  zzzds2#b    Move item ds fields into #b fields.
416lA*----------------------------------------------------------------

416lAC     zzzds2#b      begsr

     C                   eval      #bwhse = $itwhse
     C                   eval      #bitem = $ititem
     C                   eval      #btype = $ittype
417n C                   eval      #bityp = $ittype
     C                   eval      #bdesc = $itdesc
     C                   eval      #bpdsc = $itpdsc
     C                   eval      #bstyp = $itstyp
     C                   eval      #bwhdp = $itwhdp
     C                   eval      #bdesg = $itdesg
     C                   eval      #bactv = $itactv
     C                   eval      #bupc  = $itupc
     C                   eval      #bbld  = $itbld
     C                   eval      #bven# = $itven#
     C                   eval      #bvit# = $itvit#
     C                   eval      #bum1  = $itum1
     C                   eval      #bum2  = $itum2
     C                   eval      #bumq2 = $itumq2
     C                   eval      #bflg1 = $itflg1
     C                   eval      #bum3  = $itum3
     C                   eval      #bumq3 = $itumq3
     C                   eval      #bflg2 = $itflg2
     C                   eval      #bulen = $itulen
     C                   eval      #buwdt = $ituwdt
     C                   eval      #buhgt = $ituhgt
     C                   eval      #bcube = $itcube
     C                   eval      #bswgt = $itswgt
     C                   eval      #bcwgt = $itcwgt
     C                   eval      #breor = $itreor
     C                   eval      #brepl = $itrepl
     C                   eval      #brcvd = $itrcvd
     C                   eval      #bflgd = $itflgd
     C                   eval      #bflgb = $itflgb
     C                   eval      #bslif = $itslif
     C                   eval      #bnday = $itnday

     C     endds2#b      endsr

416lA*----------------------------------------------------------------
416lA*  zzzinit$slot  Initialize $slot data structure fields.
416lA*----------------------------------------------------------------

416lAC     zzzinit$slot  begsr

     C                   eval      savever# = $slver#
     C                   clear                   $slot
600bAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600bAC                   eval      $saemp#U = *on
600bAC                   eval      $saemp# = #emp#

     C                   endsr

416lA*----------------------------------------------------------------
416lA*  zzzslot2ds  Move slot fields to data structure fields
416lA*----------------------------------------------------------------

416lAC     zzzslot2ds    begsr

500j *    Do nothing for Stand-alone.
500j C     opfeat        cabeq     '3'           end2ds
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

     C                   eval      $slwhseu = *on
     C                   eval      $slwhdpu = *on
     C                   eval      $slaislu = *on
     C                   eval      $sllocu  = *on
     C                   eval      $slrlvlu = *on
     C                   eval      $slhandu = *on
     C                   eval      $sldispu = *on

     C     end2ds        endsr

520dAC*----------------------------------------------------------------
520dAC*  zzAddDif1   Add Difpck for breakdown 1 to stock
520dAC*----------------------------------------------------------------
520dA
520dAC     zzAddDif1     begsr

     C*  If difpck is negative, then call zzpick1 routine.

     C                   if        difpck < 0
     C                   eval      svnewpck = newpck
     C                   eval      newpck = -(difpck)
     C                   exsr      zzpick1
     C                   eval      newpck = svnewpck
     C                   leavesr
     C                   endif

     C*  Otherwise, proceed

     C                   eval      svqty2 = difpck

     C*  Return full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then return the rest from the brkdn1 qty.

     C                   eval      slpck2 += svqty2

     C*  Now see if pick brkdn1 can be converted to cases.

     C                   dow       slpck2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      slpck2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 is needed to cover brkdn1 allocated.

     C                   exsr      avail
     C                   dow       avail2 < 0
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   enddo

     C                   endsr

520dAC*----------------------------------------------------------------
520dAC*  zzAlloc1    Allocate increased pick qty
520dAC*----------------------------------------------------------------
520dA
520dAC     zzAlloc1      begsr

     C*  Allocate full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then return the rest from the brkdn1 qty.

     C                   eval      slpck2 += svqty2

     C*  Now see if pick brkdn1 can be converted to cases.

     C                   dow       slpck2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slpck1 += 1
     C                   eval      slpck2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 is needed to cover brkdn1 allocated.

     C                   exsr      avail
     C                   dow       avail2 < 0
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   enddo

     C                   endsr

730aA*----------------------------------------------------------------
730aA*  zzChkOrdAud  Check for open order audits for transaction
730aA*----------------------------------------------------------------
730aA*
730aAC     zzChkOrdAud   begsr

      /free

       coaWhse = $pwhse;
       coaTran = $ptrn#;
       monitor;
         chkordaud ('*TRAN': coaWhse: coaRtid: coaTran: coaOrdId:
730bM               coaPltId: coaRtn: coaMsg);

         if coaRtn = '*OPEN';
           error = *on;
           errmsg = 'Cannot close tran '
                  + %TrimL(%editc($ptrn#:'P'))
                  + ' - Open order audit exists';
           exsr zm0105;
         endif;
       on-error;
       endmon;

      /end-free

     C                   endsr

520dAC*----------------------------------------------------------------
520dAC*  zzPick1     Pick breakdown qty 1 from stock
520dAC*----------------------------------------------------------------
520dA
520dAC     zzPick1       begsr
     C                   exsr      avail
     C                   eval      svqty2 = newpck

     C*  Pick full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      avail1 -= 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then pick remaining qty from brkdn1 qty.

     C                   dow       svqty2 > 0

     C*    If enough available, pick entire qty.

     C                   if        svqty2 <= avail2
     C                   eval      slstk2 -= svqty2
     C                   eval      avail2 -= svqty2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif

     C*    Not enough available, break down a case and loop.

     C                   if        slstk1 > 0
     C                   eval      slstk1 -= 1
     C                   eval      avail1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   iter
     C                   endif

     C*    Case not available, take what we can get.

     C                   if        avail2 > 0
     C                   eval      svqty2 -= avail2
     C                   eval      slstk2 -= avail2
     C                   eval      avail2 -= 0
     C                   endif

     C                   leave
     C                   enddo

     C*  Pick entire qty, even if stock goes negative.

     C                   if        svqty2 > 0
     C                   dow       svqty2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      avail1 -= 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C                   if        svqty2 > 0
     C                   eval      slstk2 -= svqty2
     C                   eval      avail2 -= svqty2
     C                   eval      svqty2 = 0
     C                   endif

     C                   endif

     C                   endsr

520dAC*----------------------------------------------------------------
520dAC*  zzUnpick1   Unpick breakdown qty 1
520dAC*----------------------------------------------------------------
520dA
520dAC     zzUnpick1     begsr

     C*  Unpick full cases first.

     C                   dow       svqty2 >= itumq2
     C                              and slpck1 > 0
     C                              and itumq2 > 0
     C                   eval      slpck1 -= 1
     C                   eval      svqty2 -= itumq2
     C                   enddo

     C*  Then undo the rest from the brkdn 1 qty

     C                   dow       svqty2 > 0

     C*     If enough avaialble, unallocate entire qty.

     C                   if        svqty2 <= slpck2
     C                   eval      slpck2 -= svqty2
     C                   eval      svqty2 = 0
     C                   leave
     C                   endif

     C*     Not enough avaialble, break down a case and loop.

     C                   if        slpck1 > 0
     C                              and itumq2 > 0
     C                   eval      slpck1 -= 1
     C                   eval      slpck2 += itumq2
     C                   iter
     C                   endif

     C*     Case not available, zero out allocated qty.

     C                   eval      slpck2 = 0

     C                   leave
     C                   enddo

     C*  Now see if stock brkdn1 can be converted to cases.

     C                   exsr      avail
     C                   dow       avail2 >= itumq2
     C                              and slstk2 >= itumq2
     C                              and itumq2 > 0
     C                   eval      slstk1 += 1
     C                   eval      slstk2 -= itumq2
     C                   eval      avail2 -= itumq2
     C                   enddo

     C*  Now see if stock brkdn1 is needed to cover brkdn1 allocated.

     C                   exsr      avail
     C                   dow       avail2 < 0
     C                              and slstk1 > 0
     C                              and itumq2 > 0
     C                   eval      slstk1 -= 1
     C                   eval      slstk2 += itumq2
     C                   eval      avail2 += itumq2
     C                   enddo

     C                   endsr

640oA*----------------------------------------------------------------*********
640oA*
640oA*  ZZWRTTRAND Execute new WRTTRAN1 program to add/update PIRTRANDn
640oA*
640oA /free
640oA   begsr zzwrttrand;
640pA     if wrtsaveptran# = pttrn# and wrtsaveptstat = ptstat;
640pa       leavesr;
640pa     endif;

640oA     wrtpcmd = '*ONETRAN';
640oA     wrtpwait = 0;
640oA     wrtpwhse = ptwhse;
640oA     wrtptran# = pttrn#;
640oA     wrtpfrmdate = 0;
640oA     wrtptodate = 0;
640oA     wrtpemp# = 0;
640pA     wrtsaveptran# = pttrn#;
640pA     wrtsaveptstat = ptstat;
640oA
640oA     wrttran1 (wrtpcmd: wrtpwait: wrtpwhse: wrtptran#:
640oA               wrtpfrmdate: wrtptodate: wrtpemp#);
640oA   endsr;
640oA /end-free
650dA*------------------------------------------------------------------
650dA* chkovr - Check for overflow slots for item.
650dA*------------------------------------------------------------------
650dA
650dAC     chkovr        begsr
650dA
650dAC                   eval      s3_slStat = 'A '
650dAC                   eval      s3_slPick = 'N'
650dAC     keyS3         setll     slot3
650dAC                   eval      nbrovr = 0
650dA
650dAC                   dow       forever = forever
650dA
650dAC     keyS3         reade     slot3
650kDC*                  if        %eof
650kAC                   if        %eof(slot3)
650kAc                              or not %found(slot3)
650dAC                   leave
650dAC                   else
650dAC                   eval      nbrovr = nbrovr + 1
650dAC                   endif
650dAC                   enddo
650dA
650dAC                   endsr

520dAC*----------------------------------------------------------------
520dAC*  avail   Calculate slot available qtys
520dAC*----------------------------------------------------------------
520dA
520dAC     avail         begsr

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

     C                   endsr

650eA*----------------------------------------------------------------
650eA*  clrCWLog     Clear $cwlog   data structure fields
650eA*----------------------------------------------------------------

650eA /free
650eA   begsr ClrCWLog;

650eA     savever# = $cwver#;
650eA     clear $cwlog;
650eA     $cwver# = savever#;
650eA     $cwaddemp = #emp#;
650eA     $cwaddusr = #curruser;
650eA     $cwaddpgm  = #prog;
650eA     $cwaddjob  = #job;
650eA     $cwaddnbr = #jobn;

650eA   endsr;
650eA /end-free

650eA*----------------------------------------------------------------
650eA*  ProcessCWLog  Process the CWLOG file Add/Update/Delete
650eA*----------------------------------------------------------------

650eA /free
650eA   begsr processCWlog;
650eA     exsr clrCWLog;
650eA     $cwwhse = ocwhse;
650eA     $cwitem = ocitem;
650eA     $cwseltrn# = octran;
650eA     $cwsellbl# = oclbl#;
650eA     $cwselord  = ocord;
650eA     $cwselseq  = ocseq#;
650eA     $cwselcseq = ocseq;
650eA     $cwwgtlbs = occwgt;
650eA     $cwentflg = 3;

650eA     cwdata = $cwlog;
650eA     cw800(processstatus: cwpgm: cwrtn: cwmsg: cwdata);

650eA     $cwlog = cwdata;

650eA   endsr;
650eA /end-free

720cA*----------------------------------------------------------------
720cA*  GetGenInfo    Get pallet generation info
720cA*----------------------------------------------------------------
720cAC     GetGenInfo    begsr
      /free

        gGen = 1;
        gGenTruck = *off;
        gGenMerge = *off;
        gGenOverflow = *off;
        gGenTruckExt = *off;

        select;

          when gPltId < 20000;
            gGen = 1;
            gGenTruck = *on;

          when gPltId < 30000;
            gGen = 2;
            gGenMerge = *on;

          when gPltId < 40000;
            gGen = 3;
            gGenMerge = *on;

          when gPltId < 50000;
            gGen = 4;

          when gPltId < 60000;
            gGen = 5;
            gGenTruck = *on;
            gGenOverflow = *on;

          when gPltId < 70000;
            gGen = 6;
            gGenTruck = *on;
            gGenTruckExt = *on;

        endsl;
      /end-free
     C                   endsr

     *----------------------------------------------------------------*********
     *  COMPILE TIME TABLES
     *----------------------------------------------------------------*********
**
Quantity Picked
Quantity Replenished
Catch Weight
Out Lbl Pckd R:99999 L:9999999
No Stk 4 Cls R:99999 L:9999999
No Catch Weights Entered
Warning: Quantity available
Closing request cancelled
