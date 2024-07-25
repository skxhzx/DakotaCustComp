      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  IT352  Inventory transfer - Change
     *  29 March, 2000
     *  Roxanne Harrison
     *  Hemant Kapadia
     *
     *
     *  03/29/00 HNK 4.13
     *    Created - Mirror of IT252 except the size of screen and some
     *              command keys.
     *
     *
     *  Notes:
     *
     *    12/21/99  RH
     *      - Disabled F8=Slot Info and F21=Tie/Hi Info.
     *        The called programs are full screen and a fork driver
     *        will not want or have time to check the info.
     *    12/20/99  RH  Created using IT152
     *      - This program can use virtual slots and manual put away.
     *        If an item is date sensitive and exists in the 'TO'
     *        physical location with a different date, display error.
     *        If item exists with same date, increment slot qty.
     *        If manual put away,
     *          if item doesn't exist in physical location and a
     *            if normal slot is empty, put in that slot
     *            otherwise create next possible virtual slot.
     *        Virtual slot status is updated the same as normal slots.
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *    02/10/98  RH   4.09
     *      - Major revision to use virtual slots.
     *        Previous revision commemts were removed.
     *        Original IT152 was renamed IT152X
409bA*    06/17/98  RH   4.09
     *      - Add call to ADJQTY with *HOLD/*RELEASE for inactive slot
412 A*    09/10/99  RH   4.12
     *      - Add check in ZZCHK1, To slot can't be blank
     *      - Add ZZUNDO to reverse from slot and itemadj records if
     *        error and can't complete the transfer successfully.
412 A*    09/21/99  RH   4.12
     *      - Allow transfer to different dept. must be item's dept.
     *      - If item is date sensitive, allow mix dates in slot,
     *        display warning, greater date will be used for slot date
     *      - Display item's dept. on screen.
412aA*    09/21/99  RH   4.12a
     *      - Call CHKSSB to enable breakdown field for item with
     *        a same slot breakdown.
     *
412 A*    09/24/99  DAS  4.12
     *      - Changed program to format virtual slot display from
     *        FRMTSL to FRMTVS.
     *      - Changed to create vslot with Pick type of physical slot.
     *      - Revised ZZCKNS routine to check handstack of physical
     *        slot. If both characters being used then getout. If
     *        only one char being used then limit the possible
     *        virtual handstack so that the first character must
     *        equal the last character of the physical handstack.
     *        Remember, the handstack is right justified so if
     *        the physical slot already has handstack ' A', then
     *        the possible virtual handstacks are 'AA', 'AB' . . .
     *
413 A*    09/24/99  DAS 4.13
     *      - Removed 412a changes dealing with CHKSSB.
     *      - Added description field to screen for corresponding
     *        SSB item if one exists.
     *      - Removed department fields from screen. Department
     *        code will be included in warehouse description.
     *      - Revised ZZINZ2 to combine warehouse & dept.
     *      - Revised ZZINZ2 to get SSB item if one exists.
     *      - Revised logic to non-display/protect breakdown Qty's.
     *      - Added @FMTIT to format item description fields.
     *
413aA*    12/29/99  DAS 4.13a
     *      - Revised ZZCKNS to set ERROR *OFF if slot does not have
     *        item.
     *
413bA*    01/17/99  RH  4.13b
     *      - Revised ZZCHK1 to condition checks if OVRRID is Off.
413CA*    01/26/00  RH   4.13C
     *      - Add code to not create virtual pick slots,
     *        comment code if virtual pick slots should be created.
413dA*    02/03/00  RH/DAS  4.13d
     *      - Remove 4.13B change,
     *      - Revise ZZCHK1 to save slot and restore on error.
     *
413eA*    02/07/00  HNK  4.13e
     *      - Remove slot entry from screen 1 and put Item entry
     *        instead.
     *      - Add screen 2 for slot entry.
     *
414 A*    06/29/00  HNK  4.14
     *      - Adjust warehouse qty if item number changed.
     *
414aA*    06/29/00  DAS  4.14
     *      - Initialize EXIST flag.
414bA*    07/19/00  RRH  4.14b
     *      - Correct # for Do loop in ZZCKNS
414cA*    08/01/00  RRH  4.14c
     *      - Add OPTIONS, ITEMMSC to check multiple pick options.
     *      - Note: IMNRPK can = 0 to allow no pick slots.
414dA*    08/02/00  RRH  4.14d
     *      - Add error check, Item and slot section must match.
414eA*    08/23/00  HNK  4.14e
     *      - Do not chain to slot file if new virtual slot is to be
     *        created.
414fA*    08/30/00  HNK  4.14f
     *      - Do not check for # of pick slots, if both "From" and
     *        "To" slots are overflow slots.
414gA*    10/25/00  RRH  4.14g
     *      - Don't lock VSLOT records in ZZCKSL.
415 A*    12/06/00  HNK  4.15
     *      - Create adj records when item number is changed.
415aA*    12/19/00  HNK  4.15a
     *      - Correct key for ITEMMSC file.
415bA*    02/20/01  MLB  4.15b
     *      - Revised program to check designation of To-slot.
     *      - Changed row# when prompting for slot.
415cA*    03/05/01  MLB  4.15c
     *      - Revised routine ZZCRTL to create label records for
     *        each qty being transferred.
415dA*    05/04/01  MLB  4.15d
     *      - Revised program to check quantity in pick slot before
     *        updating expiration date, entered date. When updating
     *        expiration dates with qty in the pick slot, the oldest
     *        date will take precedence. If slot is empty, then date
     *        from replenishment slot will be updated.
415eA*    05/30/01  MLB  4.15e
     *      - Revised routine SC2 to loop around if error occurs.
     *      - Revised routine ZZCLSE to send error to user if not
     *        able to close the the transfer transaction.
     *      - Revised routine ZZABRT to subtract the transfer qty
     *        from the receive bucket of the To Slot.
415fA*    06/04/01  MLB  4.15f
     *      - Revised routine ZZCLSE to pass warehouse to PT132.
     *
415gA*    07/09/01  MLB  4.15g
     *      - Revised routine ZZUPD2 to seton flag when To Slot has
     *        updated.
     *      - Revised ZZABRT to only update To Slot when it was updated
     *        in routine ZZUPD2.
     *      - Revised SCR02I, ZZINZ2 to initialize flag TOSLUP.
     *
416 A*    10/01/01  MLB  4.16
     *      - Initialize NEWVS flag in ZZCKNS routine.
416aA*    12/14/01  MLB  4.16a
     *      - Added file PIRTRAN1.
     *      - Revised ZZTASK to first look at PIRTRAN1 for a status
     *        '2' record. This will save reading through every record
     *        for the employee.
416bA*    01/29/02  HNK  4.16b
     *      - Use KEYIT1 key for PIRITEM file and use TOWHDP to create
     *        second label record.
416cA*    04/16/02  RH   4.16c
     *      - If new item is type B or S, calculate breakdown quantity
     *      - If item # changes, allow entry of adjustment code.
416dA*    04/19/02  RH   4.16d
     *      - Create "to slot" label rec with status of P.
     *      - Fix - *IN92 was not being set to *OFF after first time
416eA*    05/11/02  HNK/RH 416e
     *      - Fix - Initialize SVUMQ2 to 1 instead of 0.
416fA*    07/02/02  RH   4.16f
     *      - Recompiled, ITEMMSC changed.
416gA*    08/05/02  MLB  4.16g
     *      - Fix: Revised ZZCHK1 to convert available quantity into
     *        total available quantity for breakdown1,2 quantity
     *        transfers.
416hA*    09/25/02  RH   4.16h
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
416iA*    10/10/02  RH   4.16i
     *      - FIX - Update held quantities for item.
416jA*    10/10/02  RH   4.16j
     *      - FIX - Was not updating to slot with correct qty when
     *        item changed.
416kA*    01/22/03  MLB  4.16k
     *      - Fix - Revised ZZIDLE to initialize PTRDTE with
     *        a valid date.
     *
417 A*    02/13/03  MLB  4.17
     *      - Fix: Revised ZZCLSE to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
417aA*    04/03/03  RH   4.17a
     *      - Recompiled, ITEMMSC file changed.
417bA*    04/17/03  RH   4.17b
     *      - FIX - To Label qty was not correct when item changed.
417cA*    08/20/03  MLB  4.17c
     *      - Fix: Revised ZZUPD2 to not allow expiration dates
     *        less than current date to update pick slot.
417dA*    10/13/03  RH   4.17d
     *      - Fix: Reverse 416d change, *IN93 & *IN93 were always on
     *
500 A*    01/20/05  MLB  5.00
     *      - Enh: Add support to program to retrieve *VIRTUAL slot
     *        options.
500aA*    01/20/05  MLB  5.00a
     *      - Enh: Revised program to add support for Client id
500bA*    03/04/05  RH   5.00b
     *      - Fix: Do not allow virtual slot to be scanned for putaway
     *
500cA*    03/30/05  DAS  5.00c
     *      - Enh: Converted to ILE.
     *      - Enh: Revised to use DRI interfaces.
     *      - Enh: Added License History logic.
     *
500dA*    04/07/05  DAS  5.00d
     *      - Fix: Revised to send Enter date in %CLSTFICHG command.
     *
500eA*    04/11/05  DAS  5.00e
     *      - Fix: w1qt03 was being moved into qty2 fields.
     *
500fA*    04/13/05  DAS  5.00f
     *      - Revised PULDROP to undo pull if *NOTFND returned.
     *
500gA*    04/26/05  DAS  5.00g
     *      - Revised CANCEL routines to use %TFROUTCHG.
     *
500hA*    04/28/05  DAS  5.00h
     *      - Revised CANCEL routine to unconditionally return pallet(s)
     *        to slot.
     *
500iA*    04/29/05  DAS  5.00i
     *      - Revised LT210 UNDO's to PUTAWYA's.
     *
500jA*    04/30/05  DAS  5.00j
     *      - Enh: Added $tnorm1/2/3 parms.
     *      - Fix: Revised ZZCHK1 to verify qty is not negative.
     *
500kA*    05/04/05  DAS  5.00k
     *      - Added LT210 command *RMVZERO to remove (inactivate)
     *        a zero lichist record.
     *      - Revised to create all label records with status of 'C'.
     *
500lA*    05/10/05  DAS  5.00l
     *      - Revised to send From slot for vfytfichg and clstfichg.
     *
500mA*    05/18/05  DAS  5.00m
     *      - Revised to redisplay screen 2 if user cancels from LT210.
510cA*    05/12/07  RH   5.10c
     *      - Fix: Do not allow negative quantity to be entered for
     *        any uom quantity.  Was allowing negative bk1 UOM qty
     *        when normal UOM quantity was positive (+1, -44)
     *      - Fix: Message PIR0009 does not exist, should be PIR0109
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
600aA*    12/07/07  LMC  6.00a
     *      - This mod is merged from PIRENH510/IT352 mod 500e RH  05/18/05
     *      - FIX: Create 1st label record for break 1 quantity with
     *        from slot department when moving to a different dept.
600bA*    12/07/07  LMC  6.00b
     *      - This mod is merged from PIRENH510/IT352 mod 500g MLB 12/28/05
     *      - Enh: Revised program to compute extended catchweight
     *        when a "Change Item Number" transfer is done.
600cA*    12/28/07  LMC  6.00c
     *      - Per Dave use the logic from PIRENH510 version which sets
     *        LBSTAT field different then the PIRLIC500 version.
     *        when a "Change Item Number" transfer is done.
600dA*    04/08/08  DAS  6.00d
     *      - Removed qty check from zzchk1 because it is in DRISLOT.
     *      - Revised negative qty check in zzchk1 to user w1qt01/02/03
     *        instead of w1qty1/2/3.
     *      - Remove w1qty1/2/3 from program.
600eA*    01/11/09  DAS  6.00e
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Changed all #user to #curruser.
600fA*    03/04/09  CWM  6.00f
     *      - Revised to use WORKUSR3 instead of WORKTFR.
600gA*    03/08/09  DAS  6.00g
     *      - Added wuPulBase to WORKUSR file.
     *      - Added $slPullLcns, $saPullDisp, $saPullBase to c#slot.
600hA*    03/04/09  DAS  6.00h
     *      - Revised to delay writing work record until zzupd1.
600iA*    05/11/09  DAS  6.00i
     *      - Revised to delete work record after putaway.
600jA*    05/13/09  DAS  6.00j
     *      - Added $slPullWhdp to c#slot.
     *      - Revised what is sent for $sacitem for %TFR2USR.
600kA*    05/17/09  DAS  6.00k
     *      - Revised to identify returning item to slot it was
     *        pulled from.
600lA*    05/20/09  DAS  6.00l
     *      - Revised zzchk2 to set $saAction appropriately for
     *        %VFYTFICHG.
600mA*    05/22/09  DAS  6.00m
     *      - Revised to not allow the scanning of an RCV/STG slot. These
     *        slots are tied to open receiving transaction sot they
     *        need to be handled through the putaway program.
600nA*    05/29/09  DAS  6.00n
     *      - Added *CHANGEX, which allows transfer from RCV/STG slots.
610aA*    08/26/09  GJA  6.10a
     *      - Fix:  Not sending license to LT210 when canceling
530aA*    10/22/09  RH   5.30a
     *      - Renamed screen format to IT35201
     *      - Enh: Add CW to screen if item changed and is CW.
530bA*    11/02/09  RH   5.30b
     *      - Fix: Add code in ZZCHK2 goto ENDCK2 on adj code error
610bA*    12/04/09  DAS  6.10b
     *      - Fix:  When doing a transfer from an USR slot, the qty
     *        entered must match the qty in the USR slot.
610cA*    12/04/09  DAS  6.10c
     *      - Fix:  Revised zero / negative check in zzchk1.
610dA*    01/19/10  DAS  6.10d
     *      - Revised to use %TFR2USRR (reverse) when transferring
     *        from a Pick slot and the item is not being changed.
     *        Re: This type of transfer is assumed to be done after
     *        a qty was put into the Pick slot and is now being moved
     *        into an overflow slot. Therefore, we want to take the
     *        license in LIFO (reverse) instead of FIFO.
530dA*    01/27/10  GJA  5.30d
     *      - Display pick slot on SC1
610e *    05/05/10  GJA  6.10e
     *      - Fix:  Need to make sure that when transfer is from pick
     *        slot that we check status if to slot is a pick.
610fA*    11/01/10  DAS  6.10f
     *      - Revised zzfil2 to call LT210 *PUTAWYB. Re: In order to
     *        ask use for a new license plate before scanning the
     *        slot number.
     *      - Revised zzupd2 to use new skipLT210 flag.
     *
620 A*    01/25/11  MLB  6.20
     *      - Fix:  Revised program to disable 6.00c mod that set LABEL
     *        transfer records to Printed status instead of LBSTAT=C.
     *
640aA*    06/02/11  DAS  6.40a
     *      - Added Eastland change.
     *      - Added #fromslstat and #toslstat.
     *      - Setting new DRISLOT parm $saItmChg.
     *
640bA*    06/09/11  JCJ  6.40b
     *      - Fix:  Added code to ignore status check in 610e mod if
     *        the slot status is 'RP'.
     *
640cA*    06/09/11  JCJ  6.40c
     *      - Fix:  Added code to ignore status check in 610e mod if
     *        multiple pick slots.
640dA*    07/26/11  JCJ  6.40d
     *      - Fix:  Reverse 640c using OPMPCK = 'N', was not updating
     *        status to 'Z' during change pick slot.
640e *    10/02/11  GJA  6.40e
     *      - Fix:  EVAL statement correction.  When transferring
     *        to new pick slot breakdown qty was wrong.
640f *    12/13/11  RTR  6.40f
     *      - Fix:  Corrected spelling on DRICOP error "occured".
640g *    01/12/12  RH   6.40g
     *      - Fix:  ZZCHK1 was not checking W1QT03 field for qty chk.
     *        Causing error when W1QT03 field was only qty entered.
640h *    11/12/12  LMC  6.40h
     *      - Fix:  Condition call to DRISLOT with %setstat for fixed
     *        only. Was causing problem at MJK with PIR getting an
     *        error message, after the transfer was completed.
640iA*    10/08/12  DAS  6.40i
     *      - Revised zzchk2 to stop user from using a TO slot that
     *        contains a different item.
650aA*    03/01/13  DAS  6.50a
     *      - Revised to save date/time of %TFR2 and use it for the
     *        'from' ITEMADJ record if the item is changed. This is
     *        done so record can be connected back LICLOG record.
650bA*    12/30/13  RH/LMC 6.50b
     *      - Fix:  Condition error to not display for %setstat when
     *        multple pick slots allowed. Was displaying error after
     *        transfer was complete.
650cA*    04/01/14  RH     6.50c
     *      - Fix:  Set catch weight flag TOCWGT when transfer for
     *        breakdown1 and/or breakdown2 uom
650dA*    06/18/14  KDE  6.50d
     *      - Enh: changed to create virtual pick slot for on demand
     *        repack items
650eA*    07/22/14  KDE  6.50e
     *      - Enh: changed to create virtual slot for production
     *        WIP and LIN slots when to slot does not exist
     *
650fA*    12/05/14  LMC  6.50f
     *      - Enh: When item is changed to a SSB item, add logic
     *        to replace that item information with the case item#
650gA*    03/18/15  RH   6.50g
     *      - Enh: If transfer is to slot with different status,
     *        display warning.
700aA*    03/25/15  LMC  7.00a
     *      - Enh: Added ITEMCHG file.
     *
700bA*    05/05/15  LMC  7.00b
     *      - Display file changed to IT35203
700cA*    07/10/15  RH   7.00c
     *      - Fix: add code to return to SC1 if F12 taken in LT210
     *        in ZZFIL2 before SC2 is displayed.
     *        F12 in LT210 was continuing and displaying Screen2.
700dA*    12/01/15  KDE  7.00d
     *      - Enh: Revised to allow breakdown entry when entry is
     *        production slot
700eA*    12/30/15  LMC/RH  7.00e
     *      - Fix: Condition 640J for WestSide only to not allow
     *        different directed put away items to be mixed in slot.
700fA*    10/06/15  DAS  7.00f
     *      - Fix: Removed #Yfrom fields. Used #from fields instead.
700gA*    03/03/16  MLB  7.00g
     *      - Fix: Revised 6.50e mod. Revised routine, ZZCHK2 to chk
     *        for w2disp > blanks. Was causing a substring error because
     *        w2disp was blank and nothing to pull in positions 1-3.
700hA*    03/22/16  MLB  7.00h
     *      - Fix: Mod 640i should only execute chkusage if the
     *        item is in a department that is doing directed put away.
     *
700iA*    07/15/16  LMC  7.00i
     *      - Fix: changed code to set nxtscr = EOJ
     *        if F12 taken in LT210
     *        in ZZFIL2 before SC2 is displayed.
     *        Also added exsr zzcancel so epm data is updated just
     *        like when the user does f12 from screen 1.
     *      - Fix: F12 from Sc2 will also execute the same way
     *        set nxtscr = EOJ
     *        Also added exsr zzcancel so epm data is updated just
     *        like when the user does f12 from screen 1.
700jA*    12/06/16  MR   7.00j
     *      - Remove Transfer qty greater than zero error message.
700kA*    01/23/17  MR   7.00k
     *      - Change Transfer qty greater than zero error message
     *        to something meaningful.
710a *    01/24/17  GJA  7.10a
     *      - Fix: Revised 7.00g mod. Revised routine, ZZCHK2 to chk
     *        for w2disp > blanks. Was causing a substring error because
     *        w2disp was less than 3 long.
710b *    04/07/17  LMC  7.10b
     *      - Fix: When cancelling out of a transfer on an item with
     *        a pick qty in the slot, the license records were getting
     *        corrupted, because we are in fact moving a partial qty.
     *        But the partial flag was not being set correctly.
     *        The available qty to transfer is reduced by the pick qty
710c *    09/01/17  KDE  7.10c
     *      - Fix: Create Repack RPK slot when not available for To Slot
710d *    11/05/17  RH   7.10d
     *      - Fix: Add RTN to 600M mod to not allow scan of RCV, STG
     *        or RTN slot, they are tied to open put away.
720 A*    03/26/18  RH/KDE  7.20
     *      - Fix: Added 710c & 710d missed in update.
     *      - Add F11 to scroll through available pick slots scrn2
     *      - Also take updates in 720 mod for GETPSLT for this to work
720a *    01/22/18  RTR  7.20a
     *      - Fix: When canceling twice from a transfer, true license
     *      was getting lost and item was put back with *SP license.
720bA*    05/19/18  KDE  7.20b
     *      - Fix:  Do not display *NONE if only 1 pick slot with
     *        MOD 720 above
720cA*    08/20/18  LMC  7.20c
     *      - Fix:  Moved the check for catch weight to ZZGET2, can't
     *        check the fields until we have gotten the data.
     *        Was in ZZUPD1, but the item being changed to data is not
     *        populated until the zzget2 routine.
720dA*    07/19/16  LMC  7.20d
     *      - Enh: Added parm to call on LT210 for UCI tracking
730a *    09/24/19  LMC  7.30a
     *      - Enh: Add RWO to not allow scan of RCV, STG, RTN or RWO
     *        they are tied to open put away.
730bA*    09/11/19  NLK/DAM  7.30b (DAMCO-Sachin)
     *      - Fix: Changed zzcancel2 to save slot status, so that it
     *        remains persistent in pgm DRISLOT, if we cancel out of
     *        a transfer.
740aA*    08/10/20  RH   7.40a
     *      - Enh: Add F4 look up for valid Change item
     *        Rename IT35204 to IT35205
750aA*    05/05/21  LMC/RH 7.50a
     *      - Fix: Add WOROW/WOCOL for APICVTSLT to work like IT252
     *        Rename IT35205 to IT35206
750bA*    07/28/21  NLK/RH 7.50b
     *      - Fix: XD/HD to 'V' should give warning message
750CA*    02/25/22  LMC/RH 7.50C
     *      - Fix: Remove mod 750b, it is issuing warning message to
     *        client everytime the move a pallet from any active slot
     *        to a verified slot. So basically every transfer.
     *        Nancy will need to review what she was trying to do and
     *        recode it differently.
     *
765aA*    08/17/22  Jothi 7.65a
     *      - Enh: For any edits that have the RCV,STG,OSS,USR,RTN,RWO
     *        aisle as part of an edit,add the check for SLDESG ='BFC'
760aA*    12/06/22  DAS  7.60a
     *      - Revised to ensure the date/times match between LABEL and
     *        ITEMADJ. Re: Adjustment export IT726S uses this connection
     *        to get license information.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
BIR A*    01/20/05  MLB  BIR
     *      - Revised ZZCKNS to only allow virtual pick slots to be
     *        created for PIR slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
CWa A*    11/13/07  RH   CWa
     *      - Revised to disable tie hi check.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Bros.
     *
CBIbA*    09/09/08  CBI-JGD
     *      - Add logic to load new update log file.
     *        Item location changes will be monitored
     *        thru this new file.
     *
CBIcA*    04/17/09  CBI-JGD
     *      - Added logic to allow authorized users only to have
     *        access to function key F21=Tie/High maint.
     *
CBIdA*    08/04/11  CBI-JGD
     *      - Maintain new file TIHIGHSND, keeps track of daily
     *        item location change, also used by IT112/tie-high change
CBIeA*    01/25/16  DAS  CBIa
     *      - Revised to automatically Zero Verify the From Pick slot
     *        when transferring entire qty to another Pick slot.
     *        Re: Don't want to add a Zero Verify screen at this time.
     *        IT252 has SCREEN3 for this. This program doesn't because
     *        it was assumed a full screen user wasn't in front of the
     *        slot.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
CSPa *    01/16/14  RH   CSPa
     *      - Default CI change item to code '10'
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
EFCa *    06/02/11  DAS  ECFa
     *      - Revised to put the slot status code at the end of
     *        the iamemo field.
     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
EGFa *    01/11/10  RH   EGFa
     *      - Default CI change item to code 'X '
     *----------------------------------------------------------------
     *  Client Custom Revisions: Glazier
GFCa *    04/13/11  GJA  GFCa
     *      - Default CI change item to code 'BT'
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYaA*    09/17/09  RH   HSYa
     *      - Default CI change item to code 15.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
SVLaA*    11/02/09  RH   SVLa
     *      - Enh: Default adjust code to *blanks for change item so
     *      user can enter specific code for change item.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
GMMaA*    09/10/12  RH   GMMa
     *      - Default CI change item to code 13.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPRaA*    05/05/15  LMC  FPRa
     *      - Enh: Protect normal uom qty when normal UOM = MP.
FPRcA*    05/07/15  RH   FPRc
     *      - Enh: Default adjust code to *blanks for change item so
     *      user can enter specific code for change item.
     *----------------------------------------------------------------
SPIaA*  Client Custom Revisions: Stern Produce
SPIaA*
SPIaA*    08/24/17  RTR  SPIa
SPIaA*      - Enh: Changed to get unique number and use in memo for
SPIaA*             adjustments. Needed for Thyme to match parts of
SPIaA*             repack adjustments for cost handling.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Seashore Fruit & Produce
     *
SFPa *    02/26/18  RTR  SFPa
     *      - Enh: Added Seashore to mod SPIa for Thyme repack/packout.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Merit
     *
MRTaA*    08/20/18  LMC  MRTa
     *      - Enh: Load weight into both adjustment records if a
     *        change item occurs, and if either of the items are
     *        catch weight.
MRTbA*    08/21/18  LMC  MRTb
     *      - Enh: We want to display the weight field for Merit
     *        anytine a change item is done. Is not based on the
     *        catch weight flag on either item.
     *        To capture weight on Entre transfers.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Kelly's Foods
KFSaA*    02/12/19  RH   KFSa
     *      - Default CI change item to code IA.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Holt Paper
HPCaA*    01/17/20  RH   HPCa
     *      - Default CI change item to code 8 .
     *----------------------------------------------------------------
     *  Client Custom Revisions: CPJ Miami
CPJaA*    02/12/20  RH   CPJa
     *      - Add APICVTSLT to add '-' like RF transfer.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
PFCa *    04/08/21  RTR  PFCa
     *      - Added PFC to CPJa mod to use APICVTSLT.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Renzi
RNZaA*    07/23/08  RH   RNZa
     *      - Revised to disable tie hi check.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 10   Position cursor indicators
     *  21 - 30   Reverse display indicators
600bA*  59        User changed item number during transfer.
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
600fA*----------------------------------------------------------------
600fA*  Binding Directories
600fA*----------------------------------------------------------------
600fA*
600fAHbnddir('BFCBND')
600fA*
     *----------------------------------------------------------------
     *  File Specs
     *
530aDF*t352fm   cf   e             workstn
530aMF*t35201   cf   e             workstn
700bDF*it35202   cf   e             workstn
720 DF*it35203   cf   e             workstn
740aDF*it35204   cf   e             workstn
750adF*it35205   cf   e             workstn
750aMFit35206   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fslotstat  if   e           k disk
     Funmesr    if   e           k disk
     Foptiond   if   e           k disk
414cAFoptions   if   e           k disk
600fDF* worktfr   uf a e           k disk
600fAFworkUsr3  uf a e           k disk
413EAFLabel     o  a e           k disk
415 AFitemadj   o  a e           k disk
650dAFkititem   if   e           k disk
CBIbA*
CBIbAFpiruser   if   e           k disk
CBIbAFlocslog   O    E           K DISK
CBIdAFtihighsnd uf a e           k disk
700aAFitemchg   if a e           k disk
650eAFplined    if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
412 AD a2              s              1    dim(2)
412 AD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
CBIcDD*desc            s             50    dim(3) ctdata perrcd(1)
CBIcMD desc            s             50    dim(6) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
650eAD prdslt          S              3    dim(100)
500aA*----------------------------------------------------------------
500aA*  Customer id
500aA*
     D @getcl          c                   const('GETCLIENT')
500aA*
500aA /COPY QCOPYSRC,ID#BIRITE
CBIeA /COPY QCOPYSRC,Id#CHENEY
CWa A /COPY QCOPYSRC,ID#CITYWHO
HSYaA /COPY QCOPYSRC,ID#HALSEY
SVLaA /COPY QCOPYSRC,ID#SAVAL
EGFaA /COPY QCOPYSRC,ID#EGF
EFCaA /COPY QCOPYSRC,id#eastlan
GFCaA /COPY QCOPYSRC,ID#GLAZIER
CSPaA /COPY QCOPYSRC,id#coastal
GMMaA /COPY QCOPYSRC,ID#GMM
FPRaA /copy qcopysrC,id#fpr
700eA /copy qcopysrc,id#westsid
SPIaA /copy qcopysrc,id#spi
SFPaA /copy qcopysrc,id#sfp
MRTaA /copy qcopysrc,id#mrt
KFSaA /copy qcopysrc,id#kfs
HPCaA /copy qcopysrc,id#hpc
CPJaA /copy qcopysrc,id#cpj
PFCaA /copy qcopysrc,id#pfc
RNZaA /copy qcopysrc,id#renzi

500cA*----------------------------------------------------------------
500cA*  DRI parameters
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#DRIPARMS
500cA
500cA*----------------------------------------------------------------
500cA*  Data Formats
500cA*----------------------------------------------------------------
500cA
500cA /COPY *libl/qcopysrc,C#ITEM
500cA /COPY *libl/qcopysrc,C#SLOT
500cA /COPY *libl/qcopysrc,C#SLOTDEF
500cAD saveVer#        s                   like($slver#)
500cAD save$slot       s                   like($slot)

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
     D  $pwhdp                22     26
     D  $pdisp                27     38
     D  $pitem                39     53

500cA*----------------------------------------------------------------
500cA*  LT210 parameters
500cA*----------------------------------------------------------------

     D  $tcmd          s              8
     D  $tprogram      s             10
     D  $ttype         s              3
     D  $thead         s             20
     D  $twhse         s              3  0
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
500jAD  $tnorm1        s              5  0
500jAD  $tnorm2        s              3  0
500jAD  $tnorm3        s              3  0
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
720dAD  $ttoslot       s             12
720dAD  $tpartime      s               Z
640iAD $uDiffItem      s              1
640iAD $uCube          s              9  3
640iAD $uDisp          s             12
640iAD $uItem          s             15
640iAD $uPieces        s              5  0
640iAD $uRecs          s              3  0
640iAD $uRsrv          s              1
640iAD $uWhdp          s              5
640iAD $uWhse          s              3  0
640iAD $uEntDte        s              8  0
640iAD $uExpDte        s              8  0
640iAD $uDiffEntd      s              1
640iAD $uDiffExpd      s              1
600fAD  wkType         s              3    INZ('TFR')
600fA*----------------------------------------------------------------
600fA*  Time variables
600fA*----------------------------------------------------------------
600fA
600fAD CurrStamploc    s               z
600fAD CurrStampsys    s               z
600fAD CurrStampuc     s               z
600fA
600fAD bfcoffset       s              3  0 inz(0)
600fA*----------------------------------------------------------------
600fA* Function prototypes.
600fA*----------------------------------------------------------------
600fA
600fA /copy qcopysrc,p.bfcdteti

SPIaAD GetRecId        pr                  extpgm('GETRECID')
SPIaAD  grWhse                        3s 0 const
SPIaAD  grFile                       10    const
SPIaAD  grRecId                      11p 0

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
     *----------------------------------------------------------------
     *  *PICK  -  Picking options
     *----------------------------------------------------------------
     *
     * Fields
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
     *    OPPBRK  -  Break pallets by aisle (Y,N).
     *    OPMPUT  -  Manual Put away (Y,N).
     *
     * Data structure
     *
     D opddta          ds
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
     D  opmput                34     34
     D  opdend               117    117
     *
500 A*----------------------------------------------------------------
500 A*  *VIRTUAL  -  Virtual Slot options
500 A*----------------------------------------------------------------
500 A*
500 A* Fields
500 A*
500 A*    OPVALL  -  Always create Virtual slot. (Y/N)
500 A*    OPVPCK  -  Allow Virtual pick slots to be created.  (Y/N)
500 A*    OPVSLT  -  Create Virtual slot for item when base slot and
500 A*               corresponding Virtual slot(s) item(s) are different.
500 A*               Always Yes.
500 A*    OPVEXP  -  Create Virtual slot when item exists and
500 A*               expiration date is different.  (Y/N)
500 A*    OPVEND  -  Create Virtual slot when item exists and
500 A*               entered date is different.  (Y/N)
500 A*    OPVSAM  -  Merge product when entered/expiration dates
500 A*               are the same.  (Y/N)
500 A*    OPVEDF  -  Merge product when entered dates are different and
500 A*               expiration dates are the same.  (Y/N)
500 A*
500 A* Data structure
500 A*
500 AD opdtav          ds
500 AD  opvall                 1      1
500 AD  opvpck                 2      2
500 AD  opvslt                 3      3
500 AD  opvexp                 4      4
500 AD  opvend                 5      5
500 AD  opvsam                 6      6
500 AD  opvedf                 7      7
500 AD  optenv               117    117
500 A*
414cA*----------------------------------------------------------------
414cA*  *SYSTEM  -  System options.
414cA*----------------------------------------------------------------
414cA*
414cA* Fields
414cA*
414cA*    OPEPM   -  Using EPM module (Y,N).
414cA*    OPRF    -  Using RF module (Y,N).
414cA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
414cA*    OPLETD  -  Print letdown labels (Y,N).
414cA*    OPWRNC  -  Perform catch weight variance check (Y,N).
414cA*    OPRG1C  -  Catch weight low variance percentage.
414cA*    OPRG2C  -  Catch weight high variance percentage.
414cA*    OPIMPI  -  Import item fields from host.(Y,N).
414cA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y,N).
414cA*
414cA* Data structure
414cA*
414cAD opdat2          ds
414cAD  opepm                  1      1
414cAD  oprf                   2      2
414cAD  opcapc                 3      3
414cAD  opletd                 4      4
414cAD  opwrnc                 5      5
414cAD  oprg1c                 6      8  1
414cAD  oprg2c                 9     11  1
414cAD  opimpi                12     12
414cAD  opmpck                14     14
414cAD  opten2               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
413 AD @fmtit          c                   const('FRMTIT')
413eAD @adjtr          c                   const('ADJTRAN  ')
413eAD @adjtd          c                   const('ADJTSKDET')
413EAD @addtr          c                   const('ADDSTDTRN')
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
413EAD  $ltype                81     88
     *
     *   Redefine key
     *
     D  $lcode                19     20
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
     *
     D  $lfdsp                27     38
     D  $lfitm                39     53
     *
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
413eAD  $litm                 22     36
740aAD  $ltitm                37     51
     *
413EAD  $lrte                 22     26
413EAD  $lpo                  27     35
413EAD  $ltrn#                36     42  0
415bA*
415bAD  $ldsg                 19     23
415bAD  $ltyp                 24     24
     *
500cAD  $lwhse2               19     21  0
500cAD  $lwhdp2               22     26
500cAD  $ldisp2               27     38
500cAD  $litem2               39     53
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
CPJaA*----------------------------------------------------------------
CPJaA*  API programs
CPJaA*
CPJa D @apics          c                   const('APICVTSLT ')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D  erqty                  1     10
     D  eritem                11     25
     D  erfrom                26     37
     D  erto                  38     49
     *
     D  erdisp                 1     12
     *
650gAD  erfsts                 1      2
650gAD  ertsts                 3      4
414cA*
414cAD  ernpck                 1      3p 0
414cAD  erapck                 4      6p 0
415bA*
415bAD  eritdp                 1      5
415bAD  erslds                 6     17
415bAD  ersldp                18     22
415bAD  eritsc                23     23
415bAD  erslsc                24     24
416gA*----------------------------------------------------------------
416gA*  Working variables.
416gA*
416gAD  bkdwn1                 1      4    inz('*NO ')
416gAD  bkdwn2                 5      8    inz('*NO ')
416gAD  avlqty                 9     17  0 inz(0)
416gAD  chkqty                18     26  0 inz(0)
SPIaAd RpkID           s             11p 0 inz(0)
     *----------------------------------------------------------------
     *
     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
     *
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
600eA /Copy qcopysrc,c#pgminfds
600eDD**              sds
600eDD**#prog            *proc
600eDD**#pgm             *proc
600eDD**#job                 244    253
600eDD**#user                254    263
600eDD**#jobn                264    269
600eDD**#jobdt               276    281  0
600eDD**#jobtm               282    287  0
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
     *----------------------------------------------------------------
     *  PIRTRAN record layout for use as parameters
     *
     D ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Variables
     *
     D $msgf           s             10
     D $ptrn#          s              7  0
     D $rtncd          s              8
     D $vaisl          s              3
     D $vloc           s              3  0
     D $vpick          s              1
     D $vpseq          s              5  0
     D $vrlvl          s              2  0
     D $vstyp          s              1
     D $vwhdp          s              5
     D $vwhse          s              3  0
     D #msgid          s              7
     D #msgtp          s              7
     D #pgmq           s             10
720bAd prvPick         s                   like($sldisp)

500cAD #frombasesldsp  s                   like($sldisp)

500cAD #fromslwhdp     s                   like($slwhdp)
500cAD #fromslstyp     s                   like($slstyp)
500cAD #fromsldisp     s                   like($sldisp)
500cAD #fromslaisl     s                   like($slaisl)
500cAD #fromslloc      s                   like($slloc)
500cAD #fromslpseq     s                   like($slpseq)
500cAD #fromslrlvl     s                   like($slrlvl)
500cAD #fromslhand     s                   like($slhand)
640aAD #fromslstat     s                   like($slstat)
500cAD #fromslrsrv     s                   like($slrsrv)
500cAD #fromslentd     s                   like($slentd)
500cAD #fromslexpd     s                   like($slexpd)
500cAD #fromslslfd     s                   like($slslfd)
500cAD #fromslactv     s                   like($slactv)
500cAD #fromslbld      s                   like($slbld)
500cAD #fromslpick     s                   like($slpick)
500cAD #fromslitem     s                   like($slitem)
500cAD #fromslsdef     s                   like($slsdef)
500cAD #fromslpos      s                   like($sdpos)
500cAD #fromslvirt     s                   like($sfvirt)
500cAD #fromslstk1     s                   like($slstk1)
500cAD #fromslstk2     s                   like($slstk2)
640eMD #fromslstk3     s                   like($slstk3)
640eDD*#fromslstk3     s                   like($slstk2)
500cAD #fromslalc1     s                   like($slalc1)
500cAD #fromslalc2     s                   like($slalc2)
500cAD #fromslalc3     s                   like($slalc3)
500cAD #fromsltfr1     s                   like($sltfr1)
500cAD #fromsltfr2     s                   like($sltfr2)
500cAD #fromsltfr3     s                   like($sltfr3)
500cAD #fromslpck1     s                   like($slpck1)
500cAD #fromslpck2     s                   like($slpck2)
500cAD #fromslpck3     s                   like($slpck3)
500cAD #fromslrcv1     s                   like($slrcv1)
500cAD #fromslrcv2     s                   like($slrcv2)
500cAD #fromslrcv3     s                   like($slrcv3)
500cAD #fromslphy1     s                   like($slphy1)
500cAD #fromslphy2     s                   like($slphy2)
500cAD #fromslphy3     s                   like($slphy3)
500cAD #fromslavl1     s                   like($slavl1)
500cAD #fromslavl2     s                   like($slavl2)
500cAD #fromslavl3     s                   like($slavl3)
600eAD #fromToLcns     s                   like($saToLcns)
600eMD #fromToPos      s                   like($satopos)
600eAD #fromOLcns      s                   like($saOLcns)

500cAD #toslwhdp       s                   like($slwhdp)
500cAD #tosldisp       s                   like($sldisp)
500cAD #tosldispnew    s                   like($sldisp)
500cAD #toslaisl       s                   like($slaisl)
500cAD #toslloc        s                   like($slloc)
500cAD #toslrlvl       s                   like($slrlvl)
500cAD #toslhand       s                   like($slhand)
640aAD #toslstat       s                   like($slstat)
500cAD #toslpick       s                   like($slpick)
500cAD #toslitem       s                   like($slitem)
500cAD #toslsdef       s                   like($slsdef)

500cAD #fromititem     s                   like($ititem)
500cAD #fromittype     s                   like($ittype)
500cAD #fromitdesc     s                   like($itdesc)
500cAD #fromitpdsc     s                   like($itpdsc)
500cAD #fromithead     s             70
500cAD #fromitwhdp     s                   like($itwhdp)
500cAD #fromitstyp     s                   like($itstyp)
500cAD #fromitdesg     s                   like($itdesg)
500cAD #fromitum1      s                   like($itum1)
500cAD #fromitflg1     s                   like($itflg1)
500cAD #fromitum2      s                   like($itum2)
500cAD #fromitumq2     s                   like($itumq2)
500cAD #fromitflg2     s                   like($itflg2)
500cAD #fromitum3      s                   like($itum3)
500cAD #fromitumq3     s                   like($itumq3)
500cAD #fromitnrpk     s                   like($imnrpk)
500cAD #fromitflgd     s                   like($itflgd)
500cAD #fromitcube     s                   like($itcube)
500cAD #fromitswgt     s                   like($itswgt)
500cAD #fromitcwgt     s                   like($itcwgt)
500cAD #fromitmitem    s                   like($itmitem)
500cAD #fromitsdef     s                   like($idsdef)
500cAD #fromittie      s                   like($idtie)
500cAD #fromithigh     s                   like($idhigh)
600eAD #fromimltrk     s                   like($imltrk)

500cAD #fromssbititem  s                   like($ititem)
500cAD #fromssbittype  s                   like($ittype)
500cAD #fromssbitdesc  s                   like($itdesc)
500cAD #fromssbitpdsc  s                   like($itpdsc)
500cAD #fromssbitwhdp  s                   like($itwhdp)
500cAD #fromssbitstyp  s                   like($itstyp)
500cAD #fromssbitdesg  s                   like($itdesg)
500cAD #fromssbitum1   s                   like($itum1)
500cAD #fromssbitum2   s                   like($itum2)
500cAD #fromssbitumq2  s                   like($itumq2)
500cAD #fromssbitum3   s                   like($itum3)
500cAD #fromssbitumq3  s                   like($itumq3)
600eAD #fromssbimltrk  s                   like($imltrk)

500cAD #newfromititem  s                   like($ititem)
500cAD #newfromittype  s                   like($ittype)
500cAD #newfromitdesc  s                   like($itdesc)
500cAD #newfromitpdsc  s                   like($itpdsc)
500cAD #newfromitwhdp  s                   like($itwhdp)
500cAD #newfromithead  s             70
500cAD #newfromitstyp  s                   like($itstyp)
500cAD #newfromitdesg  s                   like($itdesg)
500cAD #newfromitum1   s                   like($itum1)
500cAD #newfromitflg1  s                   like($itflg1)
500cAD #newfromitum2   s                   like($itum2)
500cAD #newfromitumq2  s                   like($itumq2)
500cAD #newfromitflg2  s                   like($itflg2)
500cAD #newfromitum3   s                   like($itum3)
500cAD #newfromitumq3  s                   like($itumq3)
500cAD #newfromitnrpk  s                   like($imnrpk)
500cAD #newfromitflgd  s                   like($itflgd)
500cAD #newfromitcube  s                   like($itcube)
500cAD #newfromitswgt  s                   like($itswgt)
500cAD #newfromitcwgt  s                   like($itcwgt)
500cAD #newfromitmitm  s                   like($itmitem)
500cAD #newfromitsdef  s                   like($idsdef)
500cAD #newfromittie   s                   like($idtie)
500cAD #newfromithigh  s                   like($idhigh)
600eAD #newfromimltrk  s                   like($imltrk)

500cAD #newssbititem   s                   like($ititem)
500cAD #newssbittype   s                   like($ittype)
500cAD #newssbitdesc   s                   like($itdesc)
500cAD #newssbitpdsc   s                   like($itpdsc)
500cAD #newssbitwhdp   s                   like($itwhdp)
500cAD #newssbitstyp   s                   like($itstyp)
500cAD #newssbitdesg   s                   like($itdesg)
500cAD #newssbitum1    s                   like($itum1)
500cAD #newssbitum2    s                   like($itum2)
500cAD #newssbitumq2   s                   like($itumq2)
500cAD #newssbitum3    s                   like($itum3)
500cAD #newssbitumq3   s                   like($itumq3)
600eAD #newssbimltrk   s                   like($imltrk)

700fDD*#Yfromslwhse    s                   like($slwhse)
700fDD*#Yfromslwhdp    s                   like($slwhdp)
700fDD*#Yfromsldisp    s                   like($sldisp)
700fDD*#Yfromslpick    s                   like($slpick)
700fDD*#Yfromslitem    s                   like($slitem)
700fDD*#Yfromslpos     s                   like($sdpos)
700fDD*#Yfromslstk1    s                   like($slstk1)
700fDD*#Yfromslstk2    s                   like($slstk2)
640hDD*#Yfromslstk3    s                   like($slstk2)
700fDD*#Yfromslstk3    s                   like($slstk3)
700fDD*#Yfromslstat    s                   like($slstat)
610eAD Ypickslot       s               n

650dAD odrslot         s             12
700jAD allowZrou       s              1
700jAD allowZero       s              1
     D brkq1           s              5  0
500cAD chk4err         s               n
     D ckdate          s              8  0
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
500cAD curlic#         s                   like($tlic#)
500cAD curtrn#         s              7  0
     D curtrn          s              7  0
     D curtsk          s              6
     D curtyp          s              1
650gAD dfchk           s              1
     D dteofl          s              1
     D dteold          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
500cMD error           s               n
     D exist           s              1
500cDD*expd            s                   like(slexpd)
600bAD exwgfm          s                   like(iacwta)
500cDD*fintim          s                   like(ptetim)
500cDD*flaghs          s              1
500iAD fmcube          s                   like(lbcube)
600bAD fmcwgt          s                   like($itcwgt)
500iAD fmdisp          s                   like(lbdisp)
     D fmitem          s             15
     D fmpick          s              1
     D fmqmq2          s              5  0
500iAD fmswgt          s                   like($itswgt)
     D fmtype          s              1
500cMD fmumq2          s                   like($itumq2)
500iMD fmumq3          s                   like($itumq3)
     D fmwhdp          s              5
500cAD forever         s               n
     D forevr          s              1
     D found           s              1
     D help            s              5  0
650eAd hldprdDisp      s             12
     D i               s              2  0
     D itdtyp          s                   like($ltyp)
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
500cDD*kyitem          s                   like($pitem)
500cDD*kystat          s                   like(ptstat)
     D kywhse          s                   like($pwhse)
500cDD*k3pick          s                   like(slpick)
500cDD*k3stat          s                   like(slstat)
500cDD*lftq1           s              5  2
     D lock            s              1
     D msgk            s              4  0
500cDD*nbrpck          s              5  0
500cDD*newqt1          s                   like(slstk1)
500cDD*newqt2          s                   like(slstk2)
500cDD*newqt3          s                   like(slstk3)
500cAD newssbflg       s              1
     D newtrn          s              4
500cDD*newvs           s              1
500cDD*newwhd          s              5
500cDD*nwstat          s              2
500cDD*nwstk1          s                   like(slstk1)
500cDD*nwstk2          s                   like(slstk2)
500cDD*nwstk3          s                   like(slstk3)
     D nxtscr          s              3
500cMD odisp           s                   like($sldisp)
     D ovrrid          s              1
500cAD partial         s               n
500cDD*phactv          s                   like(slactv)
500cDD*phaisl          s                   like(slaisl)
500cDD*phbld           s                   like(slbld)
500cDD*phdesg          s                   like(sldesg)
500cDD*phdisp          s                   like(sldisp)
500cDD*phhand          s                   like(slhand)
500cDD*phloc           s                   like(slloc)
500cDD*phpseq          s                   like(slpseq)
500cDD*phrlvl          s                   like(slrlvl)
500cDD*phsdef          s                   like(slsdef)
500cDD*phside          s                   like(slside)
500cDD*phslfd          s                   like(slslfd)
500cDD*phstat          s                   like(slstat)
500cDD*phstyp          s                   like(slstyp)
500cDD*phwhdp          s                   like(slwhdp)
500cDD*phwhse          s                   like(slwhse)
650eAD prdtfr          s               n
500mAD redspl          s               n
600kAD rtnToOrig       s               n
     D rolldn          s              5  0
     D rollup          s              5  0
500cDD*savqt1          s                   like($cqty1)
500cDD*savqt2          s                   like($cqty2)
500cDD*savqt3          s                   like($cqty3)
500cDD*savst           s                   like(slstat)
     D sclear          s              1
610fAD skipLT210       s               n
     D sldtyp          s                   like($ltyp)
650eAD sltc            s              3  0
     D ssbflg          s              1
500cDD*stdate          s                   like(ptsdte)
500cDD*strtim          s                   like(ptstim)
500cDD*sttime          s                   like(ptstim)
500cDD*svactv          s                   like(slactv)
500cDD*svbld           s                   like(slbld)
500cDD*svcub1          s                   like(ptcube)
500cDD*svcub2          s                   like(ptcube)
500cDD*svcub3          s                   like(ptcube)
500cDD*sventd          s                   like(slentd)
500cDD*svexpd          s                   like(slexpd)
500cDD*svitem          s                   like(slitem)
500cDD*svpick          s                   like(slpick)
500cDD*svprty          s                   like(slprty)
500cDD*svslfd          s                   like(slslfd)
500cDD*svtlen          s                   like(ptdmin)
500cDD*svtrn#          s                   like(pttrn#)
     D svtrn1          s                   like(pttrn#)
     D svtrn2          s                   like(pttrn#)
     D svtrn3          s                   like(pttrn#)
500cDD*svtype          s                   like(ittype)
500cDD*svumq2          s                   like(itumq2)
500cDD*svwgt1          s                   like(ptswgt)
500cDD*svwgt2          s                   like(ptswgt)
500cDD*svwgt3          s                   like(ptswgt)
500cDD*t#task          s              6
650aAD tfr2usrDate     s                   like(iadate)
650aAD tfr2usrTime     s                   like(iatime)
760aAD adjDate         s                   like(iadate)
760aAD adjTIme         s                   like(iatime)
500cAD tfroutflag      s               n
500cDD*timlen          s                   like(ptdmin)
500cDD*tmpbeg          s              4  0
500cDD*tmpend          s              4  0
600bAD tocwgt          s                   like($itcwgt)
     D today           s              8  0
     D todisp          s             12
     D toitem          s             15
     D topick          s              1
     D toqty1          s                   like($cqty1)
     D toslup          s              1
     D totype          s              1
     D toumq2          s              5  0
     D towhdp          s              5
500cDD*ulexpd          s                   like(slexpd)
500cDD*ulstk1          s                   like(slstk1)
500cDD*ulstk2          s                   like(slstk2)
500cDD*ulstk3          s                   like(slstk3)
     D umq2            s              5  0
     D usesc           s              1  0
500cAD verifyzero      s               n
CBIeAD w3zero          s              1
     D warn            s              1
     D whse            s              3  0
650eAd wkaisl          s              3
500cDD*wkcube          s                   like(ptcube)
500cDD*wkpcs           s                   like(ptpcs)
500cDD*wkswgt          s                   like(ptswgt)
500cDD*wotrn#          s                   like(pttrn#)
500cDD*wowhse          s              3
500cDD*w1crew          s                   like(uscrew)
500cDD*w1emp#          s                   like(usemp#)
600dDD*w1qty1          s                   like($cqty1)
600dDD*w1qty2          s                   like($cqty2)
600dDD*w1qty3          s                   like($cqty3)
500cDD*w1shft          s                   like(usshft)
     D w1task          s              6
     D w1whdp          s              5
     D w2qty           s              7
     D w2um1           s              5
     D w2um2           s              5
     D w2um3           s              5
500cAD zmsflag         s               n
500cDD*zzedte          s                   like(ptedte)
500cDD*zzetim          s                   like(ptetim)
500cDD*zzsdte          s                   like(ptsdte)
500cDD*zzstim          s                   like(ptstim)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *ADD     - Create new batch.
     *              *EDIT    - Edit batch.
     *              *DELETE  - Delete batch.
     *              *PRINT   - Print batch edit listing.
     *              *POST    - Post batch.
     *      $PPRG   Program to send messages back to.
     *      $PUKY   Contains key for everything by *ADD.
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
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      *in92 = *off
     C                   eval      *in93 = *off
     C                   eval      error = *off
     C                   eval      $prtn = *blanks
     C                   eval      $perm = *blanks
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
500cAC                   exsr      zzzdriclose
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
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     *
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
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
     C                   setoff                                       363738
     C                   setoff                                       3940
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
500mAC                   eval      redspl = *off
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
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft1
     C                   else
     *
     *  Otherwise get existing record(s).
     *
     C                   eval      *in91 = *on
     C                   exsr      zzget1
     C                   exsr      zzfil1
     C                   endif
     C                   eval      ovrrid = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
415gAC                   eval      toslup = *off
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
415cAC                   eval      newtrn = '*NO '
500cDC**                 eval      svtrn1 = *zeros
500cDC**                 eval      svcub1 = *zeros
500cDC**                 eval      svwgt1 = *zeros
500cDC**                 eval      svtrn2 = *zeros
500cDC**                 eval      svcub2 = *zeros
500cDC**                 eval      svwgt2 = *zeros
500cDC**                 eval      svtrn3 = *zeros
500cDC**                 eval      svcub3 = *zeros
500cDC**                 eval      svwgt3 = *zeros
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
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
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*EXIT   '
500cAC                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
500cAC                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
413EMC                   exsr      zzupd1
413eMC     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine.
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
413EMC                   eval      nxtscr = '01 '
     C                   eval      $prtn = '*EXIT   '
500cAC                   exsr      zzcancel2
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
     C                   exsr      scr02i
     C                   endif
     C                   goto      endsc2
     C                   endif
720 A*
720 A*      F11 - Request next Pick Slot
720 A*
720 AC                   if        *inkk
720 AC                   eval      $scmd = '*NEXT'
720 AC                   exsr      zzfil2
720 AC                   goto      endsc2
720 AC                   else
720 AC                   eval      $scmd = '*FIRST'
720 AC                   eval      woslot = *blanks
720 AC                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
700iDC*                  eval      nxtscr = '01 '
700iMC                   eval      nxtscr = 'EOJ'
     C                   eval      $prtn = '*CANCEL '
500cAC                   exsr      zzcancel2
700iAC                   exsr      zzcancel
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   if        $pcmd = '*ADD    '  or
     C                             $pcmd = '*CHANGE '
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
750aAC     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
500mAC     redspl        cabeq     *on           endsc2
     C                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   eval      nxtscr = 'EOJ'
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
500aA*
500aA* Get client id.
500aA*
500aAC                   call      @getcl
500aAC                   parm                    client           10
500aA*
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
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
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
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
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

500cA*----------------------------------------------------------------
500cA*    DRI0001  Local system caused error
500cA*----------------------------------------------------------------
500cA
500cAC     zm0001        begsr
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
     C                   endsr

500cA*----------------------------------------------------------------
500cA*    DRI0001s Local system caused error (send to different program)
500cA*----------------------------------------------------------------
500cA
500cAC     zm0001s       begsr
     C                   if        %subst($drimessage:1:2) = 'H:'
     C                   move      'DRI0002'     #msgid
     C                   eval      $drimessage = %subst($drimessage:3)
     C                   else
     C                   move      'DRI0001'     #msgid
     C                   endif
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $drimessage + $drireturn
     C                                    + $dricommand + $drisubcmd
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr

     *----------------------------------------------------------------
415bA*    IT27004  Slot designation not same as item.
415bA*
415bAC     zm7004        begsr
415bAC                   eval      #msgid = 'IT27004'
415bAC                   eval      #msgtp = '*DIAG  '
415bAC                   movea     errmsg        $md(1)
415bAC                   exsr      zmpmsg
415bAC                   endsr
     *----------------------------------------------------------------
     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
510cDC*                  eval      #msgid = 'PIR0009'
510cMC                   eval      #msgid = 'PIR0109'
     C                   eval      #msgtp = '*DIAG  '
510cDC*                  movea     desc          errmsg
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
500cA*----------------------------------------------------------------
500cA*      0105s
500cA*
500cAC     zm0105s       begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0201  Code must be entered for create.
     *
     C     zm0201        begsr
     C                   eval      #msgid = 'PIR0201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   eval      #msgid = 'PIR0202'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Field cna't be blank.
     *
     C     zm0203        begsr
     C                   eval      #msgid = 'PIR0203'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
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
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   eval      #msgid = 'PIR7973'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   eval      #msgid = 'PIR7974'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
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
     *   PIR0110  Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   eval      #msgid = 'PIR0110'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
416c *     ZM01  No linked record for item.
416c *
416c C     zm01          begsr
416cAC                   eval      #msgid = 'IT12001'
416cAC                   eval      #msgtp = '*DIAG  '
416cAC                   eval      $md = *blanks
416cAC                   exsr      zmpmsg
416cAC                   endsr
     *----------------------------------------------------------------
     *     ZM07  Warning - No record exists in Tie/High def. file.
     *
     C     zm07          begsr
     C                   eval      #msgid = 'IT13207'
     C                   eval      #msgtp = '*DIAG  '
500cMC                   eval      erdisp = #tosldisp
500cMC                   eval      eritem = #toslitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12216  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   eval      #msgid = 'IT12216'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   eval      #msgid = 'IT12215'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   eval      #msgid = 'IT12217'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   eval      #msgid = 'IT12273'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12274  Adjustment not completed - Record locked.
     *
     C     zm74          begsr
     C                   eval      #msgid = 'IT12274'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15201  Transfer completed successfully.
     *
     C     zm1521        begsr
     C                   eval      #msgid = 'IT15201'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT15202  From and To slot cannot be same.
     *
     C     zm1522        begsr
     C                   eval      #msgid = 'IT15202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15203  To slot contains a different item.
     *
     C     zm1523        begsr
     C                   eval      #msgid = 'IT15203'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   eval      #msgid = 'IT15204'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500bA*----------------------------------------------------------------
500bA*   RC20017  Can't scan virtual slot.
500bA*
500bAC     zm2017        begsr
500bAC                   eval      #msgid = 'RC20017'
500bAC                   eval      #msgtp = '*DIAG  '
500bAC                   eval      $md = *blanks
500bAC                   exsr      zmpmsg
500bAC                   endsr
     *----------------------------------------------------------------
     *     IT25201  Date sensitive item exists in to slot with dif dte
     *
     C     zm2521        begsr
     C                   eval      #msgid = 'IT25201'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25202  WARNING:
     *              Date Sensitive item exists in to slot with dif dte
     *
     C     zm2522        begsr
     C                   eval      #msgid = 'IT25202'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
413eA*     IT25203  Slot and Item department do not match.
413eA*
413eAC     zm2523        begsr
413eAC                   eval      #msgid = 'IT25203'
413eAC                   eval      #msgtp = '*DIAG  '
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
416cA*----------------------------------------------------------------
416cA*   IT35201   No brk qty defined for base item.
416cA*
416cAC     zm3521        begsr
416cAC                   eval      #msgid = 'IT35201'
416cAC                   eval      #msgtp = '*DIAG  '
416cAC                   movea     errmsg        $md(1)
416cAC                   exsr      zmpmsg
416cAC                   endsr
650g *----------------------------------------------------------------
650g *     IT35202  From/To slot status don't match.
650g *
650g C     zm3502        begsr
650g C                   eval      #msgid = 'IT35202'
650g C                   eval      #msgtp = '*DIAG  '
650g C                   eval      errmsg = *blanks
650g C                   eval      $md = *blanks
650g C                   eval      erfsts = #fromslstat
650g C                   eval      ertsts = #toslstat
650g C                   movea     errmsg        $md(1)
650g C                   exsr      zmpmsg
650g C                   endsr
     *----------------------------------------------------------------
413eA*     IT25204  Qty entered cannot be > available qty in FROM slot
413eA*
413eAC     zm5204        begsr
413eAC                   eval      #msgid = 'IT25204'
413eAC                   eval      #msgtp = '*DIAG  '
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
     *----------------------------------------------------------------
413eA*     IT25205  Item number changed.
413eA*
413eAC     zm5205        begsr
413eAC                   eval      #msgid = 'IT25205'
413eAC                   eval      #msgtp = '*DIAG  '
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
     *----------------------------------------------------------------
414dA*     IT25207  Slot and Item section do not match.
414dA*
414dAC     zm5207        begsr
414dAC                   eval      #msgid = 'IT25207'
414dAC                   eval      #msgtp = '*DIAG  '
414dAC                   eval      $md = *blanks
414dAC                   exsr      zmpmsg
414dAC                   endsr
416j *----------------------------------------------------------------
416jA*     IT25208  Invalid item type, use base item.
416jA*
416jAC     zm5208        begsr
416jAC                   eval      #msgid = 'IT25208'
416jAC                   eval      #msgtp = '*DIAG  '
416jAC                   eval      $md = *blanks
416jAC                   exsr      zmpmsg
416jAC                   endsr
416j *----------------------------------------------------------------
416jA*     IT25209  Invalid quantity, not multiple of base/brk qty.
416jA*
416jAC     zm5209        begsr
416jAC                   eval      #msgid = 'IT25209'
416jAC                   eval      #msgtp = '*DIAG  '
416jAC                   eval      $md = *blanks
416jAC                   exsr      zmpmsg
416jAC                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZCANCEL   User canceled from screen 1.
500cA*----------------------------------------------------------------
500cA
500cAC     zzcancel      begsr

     *  If TFROUT has already been done, reverse it.

     C                   if        tfroutflag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp
     C                   eval      $saitemu = *on
     C                   eval      $saitem = #fromslitem
600eAC                   eval      $sacwhdu = *on
600fDC*                  eval      $sacwhd  = wkUsrWhdp
600fAC                   eval      $sacwhd  = wuUsrWhdp
600eAC                   eval      $sacdspu = *on
600fDC*                  eval      $sacdsp  = wkUsrDisp
600fAC                   eval      $sacdsp  = wuUsrDisp
500gAC                   eval      $sacitemu = *on
500gAC                   eval      $sacitem  = w1itm
     C                   eval      $saqtyu  = *on
600eDC**                 eval      $saqty1 = -(w1qt01)
600eDC**                 eval      $saqty2 = -(w1qt02)
600eDC**                 eval      $saqty3 = -(w1qt03)
600fDC*                  eval      $saqty1 = wkRemQty1
600fDC*                  eval      $saqty2 = wkRemQty2
600fDC*                  eval      $saqty3 = wkRemQty3
600fAC                   eval      $saqty1 = wuRemQty1
600fAC                   eval      $saqty2 = wuRemQty2
600fAC                   eval      $saqty3 = wuRemQty3
600eA
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'TFR'
600eAC                   eval      $saTrn#U = *on
600eAC                   eval      $saTrn# = curtrn#
600eAC                   eval      $saETrn#U = *on
600eAC                   eval      $saETrn# = 0
600eAC**                 eval      $saLbl#U = *on
600eAC**                 eval      $saLbl# = lblbl#
600eAC                   eval      $saToLcnsU = *on
600fDC*                  eval      $saToLcns = wkPulLcns
600fAC                   eval      $saToLcns = wuPulLcns
600eAC**                 eval      $saToPosU = *on
600eAC**                 eval      $saToPos = $tslotpos
600eAC                   eval      $saToVrfyU = *on
600eAC                   eval      $saToVrfy = 'N'
600eAC                   eval      $saToCodeu = *on
600eAC                   eval      $saToCode = 'S'
600eAC                   eval      $saToAreaU = *on
600eAC                   eval      $saToArea = 'Slot'
600eAC                   eval      $saFrmLcnsU = *on
600fDC*                  eval      $saFrmLcns = wkUsrLcns
600fAC                   eval      $saFrmLcns = wuUsrLcns
600eAC                   eval      $saOLcnsU = *on
600fDC*                  eval      $saOLcns = wkpulolcns
600fAC                   eval      $saOLcns = wuPulolcns
600jAC                   eval      $sapullwhdpu = *on
600jAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns

600gAC                   eval      $saexcdU = *on
600gAC                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
500gDC**                 eval      $drisubcmd  = '%TFROUT'
600eDC**                 eval      $drisubcmd  = '%TFROUTCHG'
600eMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   endif

     C                   endif

     *  Close transaction.

     *  Note: the start time of this tran is sent back in order to
     *        be used as the start time of the following Idle tran.

     C                   call      'ADJTRAN2'
     C                   parm      '*ABORT'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
600eA
600eA*  Delete work record(s).
600eA
600eAC                   exsr      zzwrkinz

     *  Start idle.

     *  Note: The start time for this tran is taken from the start
     *        time of the tran just aborted.

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm                    @pwhdp            5
     C                   parm                    @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm                    @ppcs             5 0
     C                   parm                    @paisl            5 0
     C                   parm                    @pqty1            5 0
     C                   parm                    @pqty2            5 0
     C                   parm                    @pqty3            5 0
     C                   parm                    @prte             5
     C                   parm                    @ppo              9
     C                   parm                    @pgrp1            1
     C                   parm                    @pgrp2            1
     C                   parm                    @pdate            8 0
     C                   parm                    @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm                    @prtn             8
     C                   parm                    @pmsg             4
500hDC**
500hDC**  Undo pulling of license plate.
500hDC**
500hDC**                 if        tfroutflag
500hDC**                 exsr      zzzclr$lt210
500hDC**                 eval      $tcmd  = '*PULUNDO'
500hDC**                 eval      $twhse = $pwhse
500hDC**                 eval      $tlic# = curlic#
500hDC**                 exsr      zzzcall$lt210
500hDC**                 endif
500hA
500hA*  Return pallets to slot (pulled in ZZINZ2).
500hA
500hAC                   exsr      zzzclr$lt210
500hAC                   eval      $tcmd   = '*PULRTN'
500hAC                   eval      $twhse  = $pwhse
500hAC                   eval      $twhdp  = #fromslwhdp
500hAC                   eval      $tslot  = #fromsldisp
500hAC                   eval      $titem  = #fromslitem
500hAC                   eval      $titemdsc = #fromithead
610aAC                   eval      $tlic# = curlic#
610aAC                   eval      $tinlic# = curlic#
610aAC                   eval      $toutlic# = curlic#
500hAC                   exsr      zzzcall$lt210

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZCANCEL2  User canceled from screen 2.
500cA*----------------------------------------------------------------
500cA
500cAC     zzcancel2     begsr

     *  If TFROUT has already been done, reverse it.

     C                   if        tfroutflag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp
730bAC                   eval      $slstatu = *on
730bAC                   eval      $slstat  = #fromslstat
     C                   eval      $saitemu = *on
     C                   eval      $saitem = #fromslitem
600eAC                   eval      $sacwhdu = *on
600fDC*                  eval      $sacwhd  = wkUsrWhdp
600fAC                   eval      $sacwhd  = wuUsrWhdp
600eAC                   eval      $sacdspu = *on
600fDC*                  eval      $sacdsp  = wkUsrDisp
600fAC                   eval      $sacdsp  = wuUsrDisp
500gAC                   eval      $sacitemu = *on
600eDC**                 eval      $sacitem  = w1itm
600eMC                   eval      $sacitem  = #fromslitem
     C                   eval      $saqtyu  = *on
600eDC**                 eval      $saqty1 = -(w1qt01)
600eDC**                 eval      $saqty2 = -(w1qt02)
600eDC**                 eval      $saqty3 = -(w1qt03)
600fDC*                  eval      $saqty1 = wkRemQty1
600fDC*                  eval      $saqty2 = wkRemQty2
600fDC*                  eval      $saqty3 = wkRemQty3
600fAC                   eval      $saqty1 = wuRemQty1
600fAC                   eval      $saqty2 = wuRemQty2
600fAC                   eval      $saqty3 = wuRemQty3
600eA
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'TFR'
600eAC                   eval      $saTrn#U = *on
600eAC                   eval      $saTrn# = curtrn#
600eAC                   eval      $saETrn#U = *on
600eAC                   eval      $saETrn# = 0
600eAC**                 eval      $saLbl#U = *on
600eAC**                 eval      $saLbl# = lblbl#
600eAC                   eval      $saToLcnsU = *on
600eAC                   eval      $saToLcns = wuPulLcns
600eAC**                 eval      $saToPosU = *on
600eAC**                 eval      $saToPos = $tslotpos
600eAC                   eval      $saToVrfyU = *on
600eAC                   eval      $saToVrfy = 'N'
600eAC                   eval      $saToCodeu = *on
600eAC                   eval      $saToCode = 'S'
600eAC                   eval      $saToAreaU = *on
600eAC                   eval      $saToArea = 'Slot'
600eAC                   eval      $saFrmLcnsU = *on
600eAC                   eval      $saFrmLcns = wuUsrLcns
600eAC                   eval      $saOLcnsU = *on
600fDC*                  eval      $saOLcns = wkpulolcns
600fAC                   eval      $saOLcns = wuPulolcns
600jAC                   eval      $sapullwhdpu = *on
600jAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns

600gAC                   eval      $saexcdU = *on
600gAC                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
500gDC**                 eval      $drisubcmd  = '%TFROUT'
600eDC**                 eval      $drisubcmd  = '%TFROUTCHG'
600eMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   endif

     C                   endif
500iDC**
500iDC**  Undo pulling of license plate.
500iDC**
500iDC**                 exsr      zzzclr$lt210
500iDC**                 eval      $tcmd  = '*PULUNDO'
500iDC**                 eval      $twhse = $pwhse
500iDC**                 eval      $tlic# = curlic#
500iDC**                 exsr      zzzcall$lt210
500iA
500iA*    Return quantity that was put into transit.
500iA
500iAC                   exsr      zzzclr$lt210
500iAC                   eval      $tcmd     = '*PUTAWYA'
500iAC                   eval      $tnexttask= 'PUTAWAY'
500iAC                   eval      $tlic#    = curlic#
500iAC                   eval      $tinlic#  = curlic#
500iAC                   eval      $toutlic# = curlic#
500iAC                   eval      $twhse    = $pwhse
500iAC                   eval      $twhdp    = #fromslwhdp
500iAC                   eval      $tslot    = #fromsldisp
500iAC                   eval      $titem    = #fromslitem
500iAC                   eval      $titemdsc = #fromithead
500iAC                   eval      $tpartial = *off
500iAC                   eval      $tqty1    = w1qt01
500iAC                   eval      $tqty2    = w1qt02
500iAC                   eval      $tqty3    = w1qt03
500jAC                   eval      $tnorm1   = w1qt01
500jAC                   eval      $tnorm2   = w1qt02
500jAC                   eval      $tnorm3   = w1qt03
500iAC                   exsr      zzzcall$lt210
500iA
500iA*    Pull pallet back down, but don't ask user any questions.
500iA
500iAC                   exsr      zzzclr$lt210
500iAC                   eval      $tcmd  = '*NQDROP'
500iAC                   eval      $twhse = $pwhse
500iAC                   eval      $twhdp = #fromslwhdp
500iAC                   eval      $tslot = #fromsldisp
500iAC                   eval      $titem = #fromslitem
500iAC                   eval      $titemdsc = #fromithead
600eAC                   eval      $tlic# = curlic#
500iAC                   exsr      zzzcall$lt210
500iAC                   eval      curlic# = $tlic#
600eA
600eA*  Delete work record(s).
600eA
600eAC                   exsr      zzwrkinz

     C                   eval      tfroutflag = *off
     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
700jA*
700jA*   If zero qty entered, all slot buckets are zero, and
700jA*   item did not change, set allowZero flags to *on.
700jA*
700jAC                   eval      allowZrou = *off
700jAC                   eval      allowZero = 'N'
700jAC                   if        (w1qt01=0 and w1qt02=0 and w1qt03=0)
700jAC                             and #fromslalc1 = 0
700jAC                             and #fromslalc2 = 0
700jAC                             and #fromslalc3 = 0
700jAC                             and #fromslrcv1 = 0
700jAC                             and #fromslrcv2 = 0
700jAC                             and #fromslrcv3 = 0
700jAC                             and #fromsltfr1 = 0
700jAC                             and #fromsltfr2 = 0
700jAC                             and #fromsltfr3 = 0
700jAC                             and #fromslstk1 = 0
700jAC                             and #fromslstk2 = 0
700jAC                             and #fromslstk3 = 0
700jAC                             and w1itm = #fromslitem
700jAC                   eval      allowZrou = *on
700jAC                   eval      allowZero = 'Y'
700jAC                   endif
500jA*
500jA*  Verify quantity is greater than zero.
500jA*
700jAC                   if        allowZrou = *off
610cDC**                 if        w1qt01 <= 0  and
610cDC**                           w1qt02 <= 0  and
610cDC**                           w1qt03 <= 0
640gDC*                  if        (w1qt01=0 and w1qt02=0 and w1qt02=0)
640gMC                   if        (w1qt01=0 and w1qt02=0 and w1qt03=0)
700kD *                            or w1qt01 < 0
700kD *                            or w1qt02 < 0
700kD *                            or w1qt03 < 0
500jAC                   eval      error = *on
500jAC                   eval      *in22 = *on
500jAC                   eval      *in02 = *on
500jAC                   eval      errmsg = *blanks
500jAC                   movea     desc(3)       errmsg
510cDC*                  exsr      zm0110
700kD *                  exsr      zm0009
700kAC                   eval      errmsg = 'Quantity cannot be zero'
700kAC                   exsr      zm0105
500jAC                   goto      endck1
500jAC                   endif
700jA*  If non-zero transfer, quantity must not be negative
700kAC                   if        w1qt01 < 0
700kAC                             or w1qt02 < 0
700kAC                             or w1qt03 < 0
700kAC                   eval      error = *on
700kAC                   eval      *in22 = *on
700kAC                   eval      *in02 = *on
700kAC                   eval      errmsg = *blanks
700kAC                   movea     desc(3)       errmsg
700kA *                  exsr      zm0110
700kAC                   exsr      zm0009
700kAC                   goto      endck1
700kAC                   endif
700jAC                   else
700jA*  if zero transfer, make sure quantity is not negative
700jAC                   if        w1qt01 < 0
700jAC                             or w1qt02 < 0
700jAC                             or w1qt03 < 0
700jAC                   eval      error = *on
700jAC                   eval      *in22 = *on
700jAc                   eval      *in02 = *on
700jAC                   eval      errmsg = *blanks
700kD *                  movea     desc(3)       errmsg
700kD *                  exsr      zm0009
700kAC                   eval      errmsg = 'Quantity cannot be negative'
700kAC                                      + ' for a zero transfer'
700kAC                   exsr      zm0105
700jAC                   goto      endck1
700jAC                   endif
700jAC                   endif
610bA
610bA*  When transfering from a USR slot, qty entered must
610bA*  match USR slot qty.
610bA
610bAC                   if        #fromslaisl = 'USR'
610bAC                   if        w1qt01 <> #fromslavl1
610bAC                             or w1qt02 <> #fromslavl2
610bAC                             or w1qt03 <> #fromslavl3
610bAC                   eval      error = *on
610bAC                   eval      *in22 = *on
610bAC                   eval      *in02 = *on
610bAC                   eval      errmsg = 'Entire qty must be taken '
610bAC                                    + 'for a USR slot'
610bAC                   exsr      zm0105
610bAC                   goto      endck1
610bAC                   endif
610bAC                   endif
500cA
500cA*  Use DRI interface to do most of the verifications.
500cA
     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = #fromslitem
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = w1itm
700jAC                   eval      $saAllowZrou = allowZrou
700jAC                   eval      $saAllowZero = allowZero

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYTFOCHG'
     C                   eval      $drisys2upd = 'D'
700jAC                   eval      $saAllowZrou = allowZrou
700jAC                   eval      $saAllowZero = allowZero
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   exsr      zm0001
     C                   goto      endck1
     C                   endif


     *
     *   Item changed, display warning.
     *
     C                   if        ovrrid = *off
500cMC                   if        w1itm <> #fromslitem
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   eval      *in28 = *on
     C                   eval      *in08 = *on
     C                   exsr      zm5205
     C                   goto      endck1
     C                   endif
     C                   endif
     *
     C     endck1        tag
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
650g C*   DFCHK Flags are used to force F20 for each test
650g C*   Values: Flag = 0 Do check.
650g C*           Flag = 1 Check was done, ok.
650g C*           Flag = 2 Warning condition.
650g C*
     C                   eval      error = *off
CPJaA*
CPJaA*  Call API for slot.
CPJaA*
CPJaAC                   if        client = CPJ
PFCaAC                             or client = Presto
CPJaAC                   call      @apics
CPJaAC                   parm                    w2disp
750aMC                   parm      16            worow
750aMC                   parm      11            wocol
750aDC*                  parm                    row#
750aDC*                  parm                    col#
CPJaAC                   parm                    @artn             8
CPJaAC                   if        @artn = '*REDSPLY'
750aAC                   if        client = Presto
750aAC                   move      *on           redspl
750aAC                   goto      endck2
750aAC                   else
CPJaAC                   eval      redspl = *on
CPJaAC                   eval      error = *on
CPJaAC                   eval      *in21 = *on
CPJaAC                   eval      *in01 = *on
CPJaAC                   eval      errmsg = *blanks
CPJaAC                   movea     desc(1)       errmsg
CPJaAC                   exsr      zm0203
CPJaAC                   goto      endck2
750aAC                   endif
CPJaAC                   endif
CPJaAC                   endif
650eA /free
650eA    // if production slot ensure virtual is created for to slot
650eA                    prdtfr = *off;
650eA                    sltc = 0;
710aD                    //wkaisl = ' ';
710aD                    //if w2disp > ' ';
710aD                    //  wkaisl = %subst(%trim(w2disp):1:3);
710aM                      wkaisl = %subst(w2disp:1:3);
710aD                    //endif;
650eA                    sltc = %lookup(wkaisl:prdslt:1);
710cD                    //if sltc <> 0 and wkaisl <> ' ';
710cM                    if (sltc <> 0 and wkaisl <> ' ') or wkaisl='RPK';
650eA                       prdtfr = *on;
650eA                       exsr clr$slot;
650eA                       $slwhseu = *on;
650eA                       $slwhse  = $pWhse;
650eA                       $slwhdpu = *on;
650eA                       $slwhdp  = #newfromitwhdp;
650eA                       $slitemu = *on;
650eA                       $slitem  = w1itm;
650eA                       $sldispu = *on;
650eA                       $sldisp  = w2disp;
650eA                       $slstatu = *on;
650eA                       $slstat  = 'PR';
650eA
650eA                       $dricommand = '*SLOT';
710cA                       if wkaisl = 'RPK';
710cA                          $slstat  = 'RP';
710cA                          $drisubcmd  = '%CRTREPAKP';
710cA                       else;
650eA                       $drisubcmd  = '%CRTPROD';
710cA                       endif;
650eA                       $drisys2upd = 'D';
650eA                       chk4err = *on;
650eA                       exsr zzzdricop;
650eA                       hldprdDisp = $sldisp;
650eA                       error = *off;
650eA                    endif;
650eA /end-free
530bAC                   move      w2disp        odisp
416c *  If item changed, verify adjustment code.
500cMC                   if        #fromslitem <> w1itm
416c C                   eval      $lcmd = '*VERIFY '
416c C                   eval      $lcode = w2adj
416c C                   call      'AD900'
416c C                   parm                    $lparm
416c C                   if        $lrtn = '*ERROR  '
416c C                   eval      error = *on
416c C                   eval      *in22 = *on
416c C                   eval      *in02 = *on
416c C                   movel     $lerm         errmsg
416c C                   exsr      zm0105
530bAC                   goto      endck2
416c C                   else
416c C                   if        $lrtn = '*PGMQ   '
416c C                   eval      error = *on
416c C                   eval      *in22 = *on
416c C                   eval      *in02 = *on
416c C                   eval      #msgk = $lmsg
416c C                   exsr      zmqmsg
530bAC                   goto      endck2
416c C                   endif
416c C                   endif
416c C                   endif
     *
530bDC*                  eval      odisp = w2disp
     *
     *  "To Slot" can't be blank.
     *
     C                   if        w2disp = *blanks
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
     C                   movea     desc(1)       errmsg
     C                   exsr      zm0203
     C                   goto      endck2
650dA*
650dA*  If transfer to represents a Repack Item verify on-demand slot
650dA*  exists
650dA*
650dA /free
650dA    if #newfromitType = 'R';
650dA       chain ($pWhse:w1itm) kititem;
650dA       if not %error and %found;
650dA          if kidisp <> ' ';
650dA             exsr clr$slot;
650dA             $slwhseu = *on;
650dA             $slwhse  = $pWhse;
650dA             $slwhdpu = *on;
650dA             $slwhdp  = #newfromitwhdp;
650dA             $slitemu = *on;
650dA             $slitem  = w1itm;
650dA             $sldispu = *on;
650dA             $sldisp  = kidisp;
650dA
650dA             $dricommand = '*SLOT';
650dA             $drisubcmd  = '%CRTREPAKD';
650dA             $drisys2upd = 'D';
650dA             chk4err = *on;
650dA             exsr zzzdricop;
650dA             odrSlot = $sldisp;
650dA             error = *off;
650dA          endif;
650dA       endif;
650dA     endif;
650dA /end-free
     C                   endif
     *
     *  Verify "To Slot" number.
     *
500cAC                   exsr      clr$slot
500cAC                   eval      $slwhseu  = *on
500cAC                   eval      $slwhse   = $pwhse
500cAC                   eval      $slwhdpu  = *on
500cAC                   eval      $slwhdp   = #newfromitwhdp
500cAC                   eval      $sldispu  = *on
650eAc                   if        prdtfr
650eAC                   eval      $sldisp   = hldprdDisp
650eAc                   else
500cAC                   eval      $sldisp   = w2disp
650eAc                   endif
500cAC                   eval      $slexpdu  = *on
500cAC                   eval      $slexpd   = #fromslexpd
500cAC                   eval      $saitemu  = *on
500cAC                   eval      $saitem   = w1itm
500cAC                   eval      $saqtyu   = *on
500cAC                   eval      $saqty1   = w1qt01
500cAC                   eval      $saqty2   = w1qt02
500cAC                   eval      $saqty3   = w1qt03
500cAC                   eval      $sacitemu = *on
500cAC                   eval      $sacitem  = #fromslitem
500lAC                   eval      $sacdspu  = *on
500lAC                   eval      $sacdsp   = #fromsldisp
700jAC                   eval      $saAllowZrou = allowZrou
700jAC                   eval      $saAllowZero = allowZero
600lA
600lAC                   eval      $saActionU = *on
600lAC                   eval      $saAction = 'TFR'
500cA
500cAC                   eval      $dricommand = '*SLOT'
500cAC                   eval      $drisubcmd  = '%VFYTFICHG'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      chk4err = *on
500cAC                   eval      zmsflag = *off
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   eval      *in21 = *on
500cAC                   eval      *in01 = *on
500cAC                   goto      endck2
500cAC                   endif
500cA
500cAC                   eval      #toslwhdp = $slwhdp
500cAC                   eval      #tosldisp = $sldisp
500cAC                   eval      #toslaisl = $slaisl
500cAC                   eval      #toslloc  = $slloc
500cAC                   eval      #toslrlvl = $slrlvl
500cAC                   eval      #toslhand = $slhand
500cAC                   eval      #toslpick = $slpick
500cAC                   eval      #toslsdef = $slsdef
650gAC                   eval      #toslstat = $slstat
640iA
640iA*  See if something alread in slot location.
640iA
700hAC                   if        opmput = 'N'
640iAC                   call      'CHKUSAGE'
640iAC                   parm      $slwhse       $uWhse
640iAC                   parm      $slwhdp       $uWhdp
640iAC                   parm      $sldisp       $uDisp
640iAC                   parm      $slrsrv       $uRsrv
640iAC                   parm      $saitem       $uItem
640iAC                   parm      $slentd       $uEntDte
640iAC                   parm      $slexpd       $uExpDte
640iAC                   parm      0             $uPieces
640iAC                   parm      0             $uRecs
640iAC                   parm      ' '           $uDiffItem
640iAC                   parm      ' '           $uDiffEntd
640iAC                   parm      ' '           $uDiffExpd
640iA
640iA*  For directed putaway, To slot cannot have different item.
640iA
700eAC                   select
700eAC                   when      client = westside
640iAC                   if        opmput = 'N' and $uDiffItem = 'Y'
640iAC                   eval      error = *on
640iAC                   eval      *in21 = *on
640iAC                   eval      *in01 = *on
640iAC                   exsr      zm1523
640iAC                   goto      endck2
640iAC                   endif
700eAC                   endsl
700hA*
700hAC                   endif
500cA
500cA*  Save tie/high info if defined for item.
500cA
500cAC                   eval      #newfromitsdef = ' '
500cAC                   eval      #newfromittie  = 0
500cAC                   eval      #newfromithigh = 0
500cAC     1             do        5             i
500cAC                   if        $idsdef(i) = #toslsdef
500cAC                   eval      #newfromitsdef = $idsdef(i)
500cAC                   eval      #newfromittie  = $idtie(i)
500cAC                   eval      #newfromithigh = $idhigh(i)
500cAC                   leave
500cAC                   endif
500cAC                   enddo
     *
500cMC                   eval      topick = $slpick
     *
     *   Verify record exists in itemdef (tie/high) file.
     *   If no record is found, display warning message.
     *
     C                   if        ovrrid = *off
CWa AC                             and client <> 'CITYWHO'
RNZaAC                             and client <> renzi
500cMC                   if        #toslpick = 'Y' and #newfromitsdef = ' '
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm07
     C                   endif
     C                   endif
650gA
650gA*  Set override to check slot status change (to / from inactive)
650g C                   if        dfchk  = '0' and
650g C                             ovrrid = *on
650g C                   eval      ovrrid = *off
650g C                   endif
650g C
650g C                   if        dfchk  = '2' and
650g C                             ovrrid = *on
650g C                   eval      dfchk  = '1'
650g C                   endif
650gA*  Warning if transfer is to different slot status.
650gAC                   if        dfchk <> '1'
650gAC                   eval      dfchk = '1'
650gA*  Warning if transfer is to different slot status.
750bA*          even if toslstat is 'V'
650gA * 750bD            if        #toslstat <> 'V' and
650gA * 750bM                      #toslstat <> 'Z'
650gAC* 750cD            if        #toslstat <> 'Z'
750cMc                   if        #toslstat <> 'V' and
750cMc                             #toslstat <> 'Z'
650gA
650gAC                   if        #toslstat <> #fromslstat
650gAC                   eval      error = *on
650gAC                   eval      *in21 = *on
650gAC                   eval      *in01 = *on
650gAC                   eval      dfchk = '2'
650gAC                   eval      warn = *on
650gAC                   exsr      zm3502
650gAC                   goto      endck2
650gAC                   endif
650gAC                   endif
650gAC                   endif
     *
     *  If error has occured then skip the rest of the checks.
     *
     C     error         cabeq     *on           endck2
     *
413dAC     endck2        tag
413dAC                   if        error = *on
413dAC                   eval      w2disp = odisp
413dAC                   endif
     *
     C                   endsr
CBIeA*----------------------------------------------------------------
CBIeA*  ZZCHKZROVFY   See if we should ask user to zero verify slot.
CBIeA*----------------------------------------------------------------
CBIeA
CBIeAC     zzchkzrovfy   begsr

     *  See if zero verify flag should be set.

     C                   eval      verifyzero = *off
     C                   dow       forever = forever

     *      Ask the user to zero verify slot if ...

     *      ... the slot only has 1 pallet position.

700jD *                  if        #fromslpos > 1
700jD *                  leave
700jD *                  endif

     *      ... the slot doesn't have a virtual slot associated with it.

     C                   if        #fromslvirt = 'Y'
     C                   leave
     C                   endif

     *      ... %TFR2USR, which is called just before calling this
     *          routine, says the slot is empty.

     C                   if        wuPulVfy <> 'Y'
     C                   leave
     C                   endif

     *      ... slot is either not a virtual slot or
     *          it is the only virtual and the base slot is empty.

     C                   if        #fromslrsrv = 'V'

     *            Get base slot info.

     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #frombasesldsp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   leave
     C                   endif

     *            Status must be 'Z' or 'V'

     C                   if        $slstat <> 'V' and $slstat <> 'Z'
     C                   leave
     C                   endif

     *            See if any other virtuals are associated with slot.

     C                   eval      $sacdspu = *on
     C                   eval      $sacdsp = $sldisp
     C                   eval      $sldisp = ' '
     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%NXTVSLOT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   dow       forever = forever
     C                   exsr      zzzdricop
     C                   if        error or $drireturn = 'EOF'
     C                   eval      error = *off
     C                   leave
     C                   endif
     C                   if        $sldisp = #fromsldisp
     C                   iter
     C                   endif
     C                   leave
     C                   enddo
     C                   if        $drireturn <> 'EOF'
     C                   leave
     C                   endif

     C                   endif

     *      Whew! We have finally determined that we can have the user
     *         verify if the slot is physically empty.

     C                   eval      verifyzero = *on

     C                   leave
     C                   enddo

     C                   endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
740aA*
740aA*  Test for F4 - Lookup
740aA*
740aAC                   if        *inkd
740aAC                   move      *on           cmdtkn
740aAC                   z-add     0             row#
740aAC                   eval      row = rowin
740aAC                   z-add     0             col#
740aAC                   eval      col = colin
740aA*
740aAC                   select
740aA*     Change Item.
740aA*
740aAC                   when      row# = 17
740aAC                   eval      *in03 = *on
740aAC                   eval      $lcmd = '*LOOKUP '
740aAC                   eval      $lwhse = $pwhse
740aAC                   eval      $litm = $ititem
740aAC                   call      'CI900'
740aAC                   parm                    $lparm
740aAC                   if        $lrtn = '*SELECT '
740aAC                   eval      w1itm = $ltitm
740aAC                   endif
740aA*
     *
     *     Cursor not on a valid lookup field.
740aA*
740aAC                   other
740aAC                   eval      error = *on
740aAC                   exsr      zm9905
740aAC                   endsl
740aAC                   goto      endcm1
740aAC                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
413 AC     zzcmd2        begsr
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Adjustment code.
     *
416c C                   when      row# = 15
416c C                   if        *in59
416c C                   eval      *in02 = *on
416c C                   eval      $lcmd = '*LOOKUP '
416c C                   eval      $lcode = w2adj
416c C                   call      'AD900'
416c C                   parm                    $lparm
416c C                   if        $lrtn = '*SELECT '
416c C                   eval      w2adj = $lcode
416c C                   endif
416c C                   endif
     *
     *     SLOT.
     *
415bMC                   when      row# = 16
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*GENERAL'
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = $pwhdp
     C                   eval      $litem = *blanks
     C                   eval      $ldisp = w2disp
     C                   call      'SL900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w2disp = $ldisp
     C                   endif
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm2
     C                   endif
     *
     *      F8 - View item slot information.
     *
     C                   if        *inkh
     C                   eval      cmdtkn = *on
     C                   eval      $lwhse = $pwhse
     C                   eval      $lwhdp = $pwhdp
     C                   eval      $lfdsp = w2disp
500cMC                   eval      $lfitm = w1itm
     C                   call      'IT135'
     C                   parm                    $lparm
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
     C                   eval      ovrrid = *on
     C                   endif
     *
     *      F21 - Item Tie/High Maintenance.
     *
     C                   if        *inkv
CBIcAC*
CBIcAC*  Verify if user has update authorization.
CBIcAC*
CBIcACSR                 call      'CHKLIST'
CBIcACSR                 parm                    #prog
CBIcACSR                 parm      ' '           #opt             20
CBIcACSR                 parm                    #user
CBIcACSR                 parm      ' '           @prtn             8
     C*
CBIcACSR   @prtn         ifeq      '*no'
CBIcACSR                 move      '1'           error
CBIcACSR                 seton                                        19
CBIcACSR                 movel     desc(6)       errmsg
CBIcACSR                 exsr      zm0105
CBIcACSR                 goto      endcm2
CBIcACSR                 endif
     C                   eval      cmdtkn = *on
     C                   eval      whse = $pwhse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    w1itm
     C                   endif
     *
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCRTL   Create Label records.
     *
     C     zzcrtl        begsr
     *
760aA /free
760aA    adjDate = today;
760aA    adjTime =%Dec(%Time():*ISO);
760aA /end-free
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = $pwhdp
600bAC                   eval      exwgfm = *zeros
     *
     *  FROM Slot.
     *
500cMC                   eval      lbaisl = #fromslaisl
500cMC                   eval      lbloc = #fromslloc
500cMC                   eval      lbrlvl = #fromslrlvl
500cMC                   eval      lbhand = #fromslhand
500cMC                   eval      lbpseq = #fromslpseq
500cMC                   eval      lbstyp = #fromslstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
500cMC                   eval      fmwhdp = #fromslwhdp
500cMC                   eval      fmdisp = #fromsldisp
500cMC                   eval      fmitem = #fromslitem
     *
     * FROM ITEM
     *
600bAC                   eval      fmcwgt = #fromitcwgt
MRTaAc                   if        client = merit
MRTbDC*                  if        #fromitcwgt = 'Y'
MRTbDc*                            or #newfromitcwgt = 'Y'
MRTaAC                   eval      fmcwgt = 'Y'
MRTbDC*                  endif
MRTaAc                   endif
500iAC                   eval      fmcube = #fromitcube
500iAC                   eval      fmswgt = #fromitswgt
500iAC                   eval      fmumq2 = #fromitumq2
500iAC                   eval      fmumq3 = #fromitumq3
500cMC                   if        #fromslitem <> w1itm
500cMC                   if        #fromitumq2 <> 0
416e C                   endif
416c C                   endif
415cA*
415cA*    Create label records for case transfer.
415cA*
415cAC                   select
415cAC                   when      w1qt01 <> 0
500cMC                   eval      lbucod = #fromitum1
     C                   eval      lbqalc = w1qt01
     C                   eval      lbqpck = w1qt01
500cMC                   eval      lbucub = #fromitcube
     C     lbucub        mult      w1qt01        lbcube
500cMC                   eval      lbuwgt = #fromitswgt
     C     lbuwgt        mult      w1qt01        lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
     *
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
600bAC                   eval      tocwgt = #newfromitcwgt
     *
500cMC                   eval      lbwhs2 = $pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
     *
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
     C                   eval      lbrte = *blanks
     C                   eval      toitem = w1itm
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = 'N'
500cMC                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbitem = fmitem
     C                   eval      lbdisp = fmdisp
     C                   eval      lbdsp2 = todisp
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = '1'
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   eval      lbitem = toitem
416bAC                   eval      lbwhdp = towhdp
     C                   eval      lbdisp = todisp
     C                   eval      lbdsp2 = fmdisp
500cMC                   eval      lbucod = #newfromitum1
416j C                   z-add     toqty1        lbqalc
416j C                   z-add     toqty1        lbqpck
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = '1'
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
     C                   eval      lbrdte = today
     C                   write     lbrec
500cMC                   eval      svtrn1 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
415cA*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 1 qty.
415cA*
415cAC                   select
415cAC                   when      w1qt02 <> 0
500cMC                   eval      lbucod = #fromitum2
415cAC                   eval      lbqalc = w1qt02
415cAC                   eval      lbqpck = w1qt02
500cMC                   if        #fromitumq2 > 0
500cMC     #fromitcube   div(h)    #fromitumq2   lbucub
500cMC     #fromitswgt   div(h)    #fromitumq2   lbuwgt
415cAC                   else
500cMC                   eval      lbuwgt = #fromitswgt
500cMC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      w1qt02        lbcube
415cAC     lbuwgt        mult      w1qt02        lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650cAC                   eval      tocwgt = #newfromitcwgt
650cA*
500cMC                   eval      lbwhs2 = $pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
415cA*
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   eval      toitem = w1itm
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = *on
415cAC                   if        newtrn = '*YES'
500cAC                   exsr      zztrnclose
500cAC                   exsr      zztrnstart
500cAC                   endif
415cA*
500cMC                   eval      lbtrn# = $ptrn#
500 AC                   eval      svtrn2 = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
600aAC                   eval      lbwhdp = fmwhdp
415cAC                   eval      lbitem = fmitem
415cAC                   eval      lbdisp = fmdisp
415cAC                   eval      lbdsp2 = todisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
600aAC                   eval      lbwhdp = towhdp
415cAC                   eval      lbitem = toitem
415cAC                   eval      lbdisp = todisp
415cAC                   eval      lbdsp2 = fmdisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500cMC                   eval      svtrn2 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
500cA*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 2 qty.
415cA*
415cAC                   select
415cAC                   when      w1qt03 <> 0
500cMC                   eval      lbucod = #fromitum3
415cAC                   eval      lbqalc = w1qt03
415cAC                   eval      lbqpck = w1qt03
500cMC                   if        #fromitumq3 > 0
500cMC     #fromitcube   div(h)    #fromitumq3   lbucub
500cMC     #fromitswgt   div(h)    #fromitumq3   lbuwgt
415cAC                   else
500cMC                   eval      lbuwgt = #fromitswgt
500cMC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      w1qt03        lbcube
415cAC     lbuwgt        mult      w1qt03        lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500cMC                   eval      lbtie = #fromittie
500cMC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650cAC                   eval      tocwgt = #newfromitcwgt
650cA*
500cMC                   eval      lbwhs2 = $pwhse
500cMC                   eval      lbwhd2 = #toslwhdp
500cMC                   eval      towhdp = #toslwhdp
500cMC                   eval      lbasl2 = #toslaisl
415cA*
500cMC                   eval      lbloc2 = #toslloc
500cMC                   eval      lblvl2 = #toslrlvl
500cMC                   eval      lbhnd2 = #toslhand
500cMC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   eval      toitem = w1itm
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = '2'
415cAC                   if        newtrn = '*YES'
500cAC                   exsr      zztrnclose
500cAC                   exsr      zztrnstart
500cAC                   endif
415cA*
500cMC                   eval      lbtrn# = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   eval      lbitem = fmitem
415cAC                   eval      lbdisp = fmdisp
415cAC                   eval      lbdsp2 = todisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
620 DC*                  eval      lbstat = 'P'
620 MC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   eval      lbitem = toitem
415cAC                   eval      lbdisp = todisp
415cAC                   eval      lbdsp2 = fmdisp
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = '1'
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
760aDC**                 eval      lbsdte = today
760aDC**                 time                    lbstim
760aA    lbsdte = adjDate;
760aA    lbstim = adjTime;
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500cMC                   eval      svtrn3 = curtrn#
415cAC                   eval      newtrn = '*YES'
500cA*
500cA*     - Update current transaction.
500cA*
500cAC                   exsr      zztrnupdate
500cA*
415cAC                   endsl
500cA*
500cA*  Close current transaction.
500cA*
500cAC                   exsr      zztrnclose
     *
414 AC                   if        fmitem <> toitem
     *  Create adjustment record for "From" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = $pwhse
415 AC                   eval      iaitem = fmitem
650aDC**                 eval      iadate = today
650aDC**                 time                    iatime
760aDC**                 eval      iadate = tfr2usrDate
760aDC**                 eval      iatime = tfr2usrTime
760aA    iadate = adjDate;
760aA    iatime = adjTime;
600eMC                   eval      iaby = #curruser
415 AC                   eval      iawhdp = fmwhdp
415 AC                   eval      iadisp = fmdisp
600bA*    Catchweight item, update extended weight transferred.
600bAC                   if        fmcwgt = 'Y'
MRTbAc                             or client = merit
MRTbAc                             and w2cwt <> 0
530aAC                   if        w2cwt = 0
600bAC                   eval      iacwta = -(exwgfm)
530aAC                   else
530aAC                   eval      iacwta = -(w2cwt)
530aAC                   endif
600bAC                   else
415 AC                   eval      iacwta = 0
600bAC                   endif
415 AC                   eval      iaqty1 = -(w1qt01)
415 AC                   eval      iaqty2 = -(w1qt02)
415 AC                   eval      iaqty3 = -(w1qt03)
416cMC                   eval      iacode = w2adj
416cD**                   MOVE 'CI'      IACODE           Change Item
415 AC     'To'          cat       toitem:1      iamemo

EFCaA*    Add slot status to end of memo for some clients.
EFCaA
EFCaAC                   if        client = eastland
EFCaAC                   eval      %subst(iamemo:28:3) = '-' + #toslstat
EFCaAC                   endif
SPIaA /free
SPIaA   // Call program to get 11 digit batch id
SPIaA   select;
SPIaA     when client = SternProduce
SFPaA      or client = Seashore;
SPIaA       GetRecId($pwhse: 'WR112': RpkId);
SPIaA       iamemo = 'RPK ' + %editc(RpkID:'X');
SPIaA   endsl;
SPIaA /end-free

415 AC                   write     iarec
     *  Create adjustment record for "To" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = $pwhse
415 AC                   eval      iaitem = toitem
760aDC**                 eval      iadate = today
760aDC**                 time                    iatime
760aA    iadate = adjDate;
760aA    iatime = adjTime;
600eMC                   eval      iaby = #curruser
415 AC                   eval      iawhdp = towhdp
415 AC                   eval      iadisp = todisp
600bA*    Catchweight item, update extended weight transferred.
600bAC                   if        tocwgt = 'Y'
MRTbAc                             or client = merit
MRTbAc                             and w2cwt <> 0
530aAC                   if        w2cwt = 0
600bAC                   eval      iacwta = exwgfm
530aAC                   else
530aAC                   eval      iacwta = w2cwt
530aAC                   endif
600bAC                   else
415 AC                   eval      iacwta = 0
600bAC                   endif
416jAC                   z-add     toqty1        iaqty1
415 AC                   eval      iaqty2 = w1qt02
415 AC                   eval      iaqty3 = w1qt03
416cMC                   eval      iacode = w2adj
415 AC     'From'        cat       fmitem:1      iamemo

EFCaA*    Add slot status to end of memo for some clients.
EFCaA
EFCaAC                   if        client = eastland
EFCaAC                   eval      %subst(iamemo:28:3) = '-' + #fromslstat
EFCaAC                   endif

SPIaA /free
SPIaA   // Call program to get 11 digit batch id
SPIaA   select;
SPIaA     when client = SternProduce
SFPaA      or client = Seashore;
SPIaA       iamemo = 'RPK ' + %editc(RpkID:'X');
SPIaA   endsl;
SPIaA /end-free

415 AC                   write     iarec
     *
414 AC                   endif
     *
700aA /free
700aA   if fmitem <> toitem;
700aA     // write change item record
700aA     icwhse = $pwhse;
700aA     icfitm = fmitem;
700aA     ictitm = toitem;
700aA     chain (icwhse: icfitm: ictitm) itemchg;
700aA     if %found(itemchg);
700aA     else;
700aA       write icrec;
700aA     endif;
700aA   endif;
700aA /end-free
     C     endcrl        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT2   Get default values for add.
     *
     C     zzdft2        begsr
     *
     *   This program is only called with *CHANGE.
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr
500cMC                   move      $slitem       w1item
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg
     *
500cMC                   eval      $cqty1 = $slavl1
500cMC                   eval      $cqty2 = $slavl2
500cMC                   eval      $cqty3 = $slavl3
     *
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
     C                   movel     $cqstr        w1curq
     *
     *  Get status description.
     *
500cMC     $slstat       chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
500cMC                   movel     $slstat       ssdesc
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
413 D*   Get Unit of measure fields
     *
416j C                   eval      fmtype = *blanks
416j C                   eval      totype = *blanks
416j C                   eval      umq2 = 0
416j C                   eval      fmqmq2 = 0
416j C                   eval      toumq2 = 0
     *
     *   Get item record.
     *
500cMC                   eval      fmtype = #fromittype
500cMC                   eval      fmumq2 = #fromitumq2
500cMC                   eval      $iitem = #fromititem
500cMC                   eval      $idesc = #fromitdesc
500cMC                   eval      $ipdsc = #fromitpdsc
413 AC                   eval      $istr = *blanks
413 AC                   call      @fmtit
413 AC                   parm                    $iitem           15
413 AC                   parm                    $idesc           30
413 AC                   parm                    $ipdsc           15
413 AC                   parm                    $istr            70
413 DC                   eval      w1item = *blanks
413 AC                   movel     $istr         w1item
500cMC                   eval      w1itm = #fromititem
413 A*
413 A*   Get SSB item, if one exists
413 A*
413 AC                   eval      w1lbls = *blanks
413 AC                   eval      w1itms = *blanks
413 A*
413 AC                   eval      w1um1 = *blanks
413 AC                   eval      w1um2 = *blanks
413 AC                   eval      w1um3 = *blanks
413 AC                   exsr      zzuom
500cAC                   if        ssbflg = *on
413 AC                   movel     'SSB ('       w1lbls
413 AC     w1lbls        cat       w1um2:0       w1lbls
413 AC     w1lbls        cat       ')':0         w1lbls
413 AC                   move      ':'           w1lbls
413 A*
413 AC                   eval      $istr = *blanks
413 AC                   call      @fmtit
500cMC                   parm                    #fromssbititem
500cMC                   parm                    #fromssbitdesc
500cMC                   parm                    #fromssbitpdsc
413 AC                   parm                    $istr
413 AC                   movel     $istr         w1itms
413 A*
413 AC                   endif
    A*
500cMC                   eval      w1whdp = #fromitwhdp
500cMC                   eval      w1styp = #fromitstyp
     *
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
500cMC                   eval      fmdisp = $sldisp
500cMC                   eval      w1itm = $slitem
500cA
500cA*   Slot position
500cA
500cAC                   eval      w1slp = 'Pos: '
600eMC                                   + %trim(%editc(#fromToPos:'3'))
     *
FPRaA* protect normal qty if normal uom = 'MP'
FPRaA /free
FPRaA   if client = foodpro;
FPRaA     if #fromitum1 = 'MP' and #fromitum2 <> ' ';
FPRaA       *in41 = *on;
FPRaA     else;
FPRaA       *in41 = *off;
FPRaA     endif;
FPRaA   endif;
FPRaA /end-free
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
610fA
610fA*  Call LT210 before getting the To slot.
610fA*  Re: Normally, a user will put a pallet into a slot, then
610fA*  scan the slot. Before, we would then ask for a new
610fA*  license under certain conditions. But, the license is now
610fA*  way up in the air and may not be scanable anymore.
610fA*  Therefore, we want to ask for the license now, before the
610fA*  screen is displayed asking for the license.
610fA
720 Ac                   if        not *inkk
610fAC                   eval      skipLT210 = *off
610fA
610fA*    Determine if we are returning qty to original slot.
610fA*    (If this logic is changed, also change in ZZUPD2)
610fA
610fAC                   if        #toslwhdp = wuPulWhdp
610fAC                             and #tosldisp = wuPulDisp
610fAC                             and w1itm = wuPulItem
610fAC                   eval      rtnToOrig = *on
610fAC                   else
610fAC                   eval      rtnToOrig = *off
610fAC                   endif
610fA
610fA*    Call license tracking for putaway - Before update
610fA*    Only call when not returning to original slot.
510fA
610fAC                   if        rtnToOrig = *off
610fA
610fAC                   exsr      zzzclr$lt210
610fAC                   eval      $tcmd     = '*PUTAWYB'
610fAC                   eval      $tlic#    = wuUsrLcns
610fAC                   eval      $tpartial = partial
610fAC                   eval      $twhse    = $pwhse
610fAC                   eval      $twhdp    = #toslwhdp
610fAC                   eval      $tslot    = #tosldisp
610fAC                   eval      $titem    = w1itm
610fAC                   eval      $titemdsc = #newfromithead
610fAC                   eval      $tqty1    = toqty1
610fAC                   eval      $tqty2    = w1qt02
610fAC                   eval      $tqty3    = w1qt03
610fAC                   eval      $tnorm1   = toqty1
610fAC                   eval      $tnorm2   = w1qt02
610fAC                   eval      $tnorm3   = w1qt03
610fAC                   exsr      zzzcall$lt210
700cA*    If *CANCEL sent back,
700cAC                   if        $treturn = '*CANCEL'
700cAC                   exsr      zzcancel2
700iAC                   exsr      zzcancel
700iDC*                  move      '01 '         nxtscr
700iMC                   move      'EOJ'         nxtscr
700cAC                   eval      $prtn = '*CANCEL '
700cAC                   goto      endfl2
700cAC                   endif
610fA*
610fA*    If *OK sent back,
610fA*      Set flag to skip LT210 call in ZZUPD2.
610fA*    Otherwise,
610fA*      Let the program continue and LT210 will be called again
610fA*      in ZZUPD2.
610fA*
610fAC                   if        $treturn = '*OK'
610fAC                   eval      skipLT210 = *on
610fAC                   endif
610fA
610fAC                   endif
720 AC                   endif
     *
     *   Initialize entry fields
     *
     C                   eval      w2qty = *blanks
413eAC                   eval      w2disp = *blanks
530aAC                   eval      w2cwt = *zero
500cMC                   if        #fromslitem <> w1itm
416cAC                   eval      w2adj = 'CI'
416cAC                   else
416cAC                   eval      w2adj = *blanks
416cAC                   endif
GFCaAC                   if        client = glazier
GFCaAC                             and w2adj = 'CI'
GFCaAC                   eval      w2adj = 'BT'
GFCaAC                   endif
CSPaAC                   if        client = CoastalSunbelt
CSPaAC                             and w2adj = 'CI'
CSPaAC                   eval      w2adj = '10'
CSPaAC                   endif
HSYaAC                   if        client = halsey
HSYaAC                             and w2adj = 'CI'
HSYaAC                   eval      w2adj = '15'
HSYaAC                   endif
GMMaAC                   if        client = menumaker
GMMaAC                             and w2adj = 'CI'
GMMaAC                   eval      w2adj = '13'
GMMaAC                   endif
KFSaAC                   if        client = kellys
KFSaAC                             and w2adj = 'CI'
KFSaAC                   eval      w2adj = 'IA'
KFSaAC                   endif
HPCaAC                   if        client = holtpaper
HPCaAC                             and w2adj = 'CI'
HPCaAC                   eval      w2adj = '8 '
HPCaAC                   endif
EGFaAC                   if        client = egf
EGFaAC                             and w2adj = 'CI'
EGFaAC                   eval      w2adj = 'X '
EGFaAC                   endif
SVLaAC                   if        client = saval
SVLaAC                             and w2adj = 'CI'
SVLaAC                   eval      w2adj = *blanks
SVLaAC                   endif
FPRcAC                   if        client = FoodPro
FPRcAC                             and w2adj = 'CI'
FPRcAC                   eval      w2adj = *blanks
FPRcAC                   endif
SPIaAC                   if        client = SternProduce
SFPaAC                             or client = Seashore
SPIaAC                             and w2adj = 'CI'
SPIaAC                   eval      w2adj = 'PA'
SPIaAC                   endif
     *
     *   Get item record.
     *
413eAC                   eval      $iitem = w1itm
500cMC                   eval      $idesc = #newfromitdesc
500cMC                   eval      $ipdsc = #newfromitpdsc
413eAC                   eval      $istr = *blanks
413eAC                   call      @fmtit
413eAC                   parm                    $iitem
413eAC                   parm                    $idesc
413eAC                   parm                    $ipdsc
413eAC                   parm                    $istr
413eAC                   eval      w2item = *blanks
413eAC                   movel     $istr         w2item
415bA*
415bA*    Retrieve hard/soft item designation code.
415bA*
415bAC                   eval      itdtyp = *blanks
500cMC                   if        $itdesg > *blanks
415bAC                   eval      $lcmd = '*VERIFY '
500cMC                   eval      $ldsg = $itdesg
415bAC                   call      'DS900'
415bAC                   parm                    $lparm
415bAC                   select
415bAC                   when      $lrtn = '*OK     '
415bAC                   eval      itdtyp = $ltyp
415bAC                   when      $lrtn = '*ERROR  '
415bAC                   eval      error = *on
415bAC                   eval      *in23 = *on
415bAC                   eval      *in03 = *on
415bAC                   movel     $lerm         errmsg
415bAC                   exsr      zm0105
415bAC                   when      $lrtn = '*PGMQ   '
415bAC                   eval      error = *on
415bAC                   eval      *in25 = *on
415bAC                   eval      *in05 = *on
415bAC                   eval      #msgk = $lmsg
415bAC                   exsr      zmqmsg
415bAC                   endsl
415bAC                   endif
     *
     *   Get SSB item, if one exists
     *
413eAC                   eval      w2lbls = *blanks
413eAC                   eval      w2itms = *blanks
413eA*
500cMC                   if        newssbflg = *on
413eAC                   eval      w2um1 = *blanks
413eAC                   eval      w2um2 = *blanks
413eAC                   eval      w2um3 = *blanks
500 MC                   exsr      zzuomnew
413eAC                   movel     'SSB ('       w2lbls
413eAC     w2lbls        cat       w2um2:0       w2lbls
413eAC     w2lbls        cat       ')':0         w2lbls
413eAC                   move      ':'           w2lbls
500cA*
500cAC                   eval      w1um1 = *blanks
500cAC                   eval      w1um2 = *blanks
500cAC                   eval      w1um3 = *blanks
500cAC                   exsr      zzuom
413eA*
413eAC                   eval      $istr = *blanks
413eAC                   call      @fmtit
500cMC                   parm                    #newfromititem
500cMC                   parm                    #newfromitdesc
500cMC                   parm                    #newfromitpdsc
413eAC                   parm                    $istr
413eAC                   movel     $istr         w2itms
413eA*
413eAC                   endif
     *  Show the qty from screen 1
413eAC                   eval      $cqty1 = w1qt01
413eAC                   eval      $cqty2 = w1qt02
413eAC                   eval      $cqty3 = w1qt03
413eA*
413eAC                   call      'CVTQTY'
413eAC                   parm                    $ccmd
413eAC                   parm                    $cprg
413eAC                   parm                    $cqty1
413eAC                   parm                    $cqty2
413eAC                   parm                    $cqty3
413eAC                   parm                    $cum1
413eAC                   parm                    $cum2
413eAC                   parm                    $cum3
413eAC                   parm                    $cqstr
413eAC                   parm                    $custr
413eAC                   parm                    $crtn
413eAC                   parm                    $cerm
413eAC                   movel     $cqstr        w2curq
530dA*
530dA*    Retrieve pick slot.
530dA*
530dAC                   eval      w1pslt = *blanks
720 DC*                  eval      $scmd = '*FIRST  '
530dAC                   call      'GETPSLT'
530dAC                   parm                    $scmd             8
530dAC                   parm      $itwhse       $swhse            3 0
530dAC                   parm      $iitem        $sitem           15
720 DC*                  parm      *blanks       woslot           12
720 AC                   parm                    woslot           12
530dAC                   parm      *blanks       $saisl            3
530dAC                   parm      *zeros        $sloc             3 0
530dAC                   parm      *zeros        $srlvl            2 0
530dAC                   parm      *blanks       $shand            2
530dAC                   parm      *blanks       $srtn             8
530dA*
530dAC                   if        $srtn = '*OKPICK '
530dAC                   eval      w1pslt = woslot
720bAc                   eval      prvPick = woslot
530dAC                   else
720bAc                   if        not *inkk
530dAC                   eval      w1pslt = '*NONE       '
720bAc                   else
720bAc                   eval      w1pslt = prvPick
720bAc                   endif
530dAC                   endif
700cMC     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
500cA
500cA*  Use DRI interface to get slot information.
500cA
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%GETCHKV'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt1
     C                   endif

     C                   eval      #fromslwhdp = $slwhdp
     C                   eval      #fromslstyp = $slstyp
     C                   eval      #fromsldisp = $sldisp
     C                   eval      #fromslaisl = $slaisl
     C                   eval      #fromslloc  = $slloc
     C                   eval      #fromslpseq = $slpseq
     C                   eval      #fromslrlvl = $slrlvl
     C                   eval      #fromslhand = $slhand
640aAC                   eval      #fromslstat = $slstat
     C                   eval      #fromslrsrv = $slrsrv
     C                   eval      #fromslentd = $slentd
     C                   eval      #fromslexpd = $slexpd
     C                   eval      #fromslslfd = $slslfd
     C                   eval      #fromslactv = $slactv
     C                   eval      #fromslbld  = $slbld
     C                   eval      #fromslpick = $slpick
     C                   eval      #fromslitem = $slitem
     C                   eval      #fromslsdef = $slsdef
     C                   eval      #fromslvirt = $sfvirt
     C                   eval      #fromslstk1 = $slstk1
     C                   eval      #fromslstk2 = $slstk2
     C                   eval      #fromslstk3 = $slstk3
     C                   eval      #fromslalc1 = $slalc1
     C                   eval      #fromslalc2 = $slalc2
     C                   eval      #fromslalc3 = $slalc3
     C                   eval      #fromsltfr1 = $sltfr1
     C                   eval      #fromsltfr2 = $sltfr2
     C                   eval      #fromsltfr3 = $sltfr3
     C                   eval      #fromslpck1 = $slpck1
     C                   eval      #fromslpck2 = $slpck2
     C                   eval      #fromslpck3 = $slpck3
     C                   eval      #fromslrcv1 = $slrcv1
     C                   eval      #fromslrcv2 = $slrcv2
     C                   eval      #fromslrcv3 = $slrcv3
     C                   eval      #fromslphy1 = $slphy1
     C                   eval      #fromslphy2 = $slphy2
     C                   eval      #fromslphy3 = $slphy3
     C                   eval      #fromslavl1 = $slavl1
     C                   eval      #fromslavl2 = $slavl2
     C                   eval      #fromslavl3 = $slavl3
600eAC                   eval      #fromToLcns = $saToLcns
600eMC                   eval      #fromToPos  = $saToPos
600eAC                   eval      #fromOLcns = $saOLcns

     C                   eval      #frombasesldsp = $sacdsp
     *
     *  Slot does not contain an item.
     *
500cMC                   if        $slitem = *blanks
     C                   eval      error = *on
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
     C                   goto      endgt1
     C                   endif
500cA
500cA*  Use DRI interface to get slot definition.
500cA
     C                   exsr      clr$slotdef
     C                   eval      $sdwhse  = $slwhse
     C                   eval      $sdcode  = $slsdef

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      error = *off
     C                   eval      $sdpos = 1
     C                   endif
     C                   eval      #fromslpos = $sdpos
500cA
500cA*  Use DRI interface to get item.
500cA
     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETALL'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt1
     C                   endif

     C                   eval      #fromititem = $ititem
     C                   eval      #fromittype = $ittype
     C                   eval      #fromitdesc = $itdesc
     C                   eval      #fromitpdsc = $itpdsc
     C                   eval      #fromitwhdp = $itwhdp
     C                   eval      #fromitstyp = $itstyp
     C                   eval      #fromitdesg = $itdesg
     C                   eval      #fromitum1  = $itum1
     C                   eval      #fromitflg1 = $itflg1
     C                   eval      #fromitum2  = $itum2
     C                   eval      #fromitumq2 = $itumq2
     C                   eval      #fromitflg2 = $itflg2
     C                   eval      #fromitum3  = $itum3
     C                   eval      #fromitumq3 = $itumq3
     C                   eval      #fromitnrpk = $imnrpk
     C                   eval      #fromitflgd = $itflgd
     C                   eval      #fromitcube = $itcube
     C                   eval      #fromitswgt = $itswgt
     C                   eval      #fromitcwgt = $itcwgt
     C                   eval      #fromitmitem = $itmitem
600eAC                   eval      #fromimltrk = $imltrk
     C                   eval      #fromitsdef = ' '
     C                   eval      #fromittie  = 0
     C                   eval      #fromithigh = 0

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #fromititem
     C                   parm                    #fromitdesc
     C                   parm                    #fromitpdsc
     C                   parm      ' '           #fromithead
500cA
500cA*  Save tie/high info if defined for item.
500cA
     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
500cA
500cA*  Use DRI interface to get corresponding SSB item, if any.
500cA
     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = $slitem

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      ssbflg  = *off
     C                   eval      #fromssbititem = ' '
     C                   eval      #fromssbittype = ' '
     C                   eval      #fromssbitdesc = ' '
     C                   eval      #fromssbitpdsc = ' '
     C                   eval      #fromssbitwhdp = ' '
     C                   eval      #fromssbitstyp = ' '
     C                   eval      #fromssbitdesg = ' '
     C                   eval      #fromssbitum1  = ' '
     C                   eval      #fromssbitum2  = ' '
     C                   eval      #fromssbitumq2 = 0
     C                   eval      #fromssbitum3  = ' '
     C                   eval      #fromssbitumq3 = 0
600eAC                   eval      #fromssbimltrk = 'L'
     C                   else
     C                   eval      ssbflg  = *on
     C                   eval      #fromssbititem = $ititem
     C                   eval      #fromssbittype = $ittype
     C                   eval      #fromssbitdesc = $itdesc
     C                   eval      #fromssbitpdsc = $itpdsc
     C                   eval      #fromssbitwhdp = $itwhdp
     C                   eval      #fromssbitstyp = $itstyp
     C                   eval      #fromssbitdesg = $itdesg
     C                   eval      #fromssbitum1  = $itum1
     C                   eval      #fromssbitum2  = $itum2
     C                   eval      #fromssbitumq2 = $itumq2
     C                   eval      #fromssbitum3  = $itum3
     C                   eval      #fromssbitumq3 = $itumq3
600eAC                   eval      #fromssbimltrk = $imltrk
     C                   endif
     *
     C     endgt1        endsr
     *----------------------------------------------------------------
     *
     *  ZZGET2   Get record(s) for screen 2.
     *
     C     zzget2        begsr
     *
413eD**                   EXSR ZZGET1
500cA
500cA*  Get new item information.
500cA
500cA*    When item number didn't change.
500cA
     C                   if        w1itm = $pitem
     C                   eval      #newfromititem = #fromititem
     C                   eval      #newfromittype = #fromittype
     C                   eval      #newfromitdesc = #fromitdesc
     C                   eval      #newfromitpdsc = #fromitpdsc
     C                   eval      #newfromithead = #fromithead
     C                   eval      #newfromitwhdp = #fromitwhdp
     C                   eval      #newfromitstyp = #fromitstyp
     C                   eval      #newfromitdesg = #fromitdesg
     C                   eval      #newfromitum1  = #fromitum1
     C                   eval      #newfromitflg1 = #fromitflg1
     C                   eval      #newfromitum2  = #fromitum2
     C                   eval      #newfromitumq2 = #fromitumq2
     C                   eval      #newfromitflg2 = #fromitflg2
     C                   eval      #newfromitum3  = #fromitum3
     C                   eval      #newfromitumq3 = #fromitumq3
     C                   eval      #newfromitnrpk = #fromitnrpk
     C                   eval      #newfromitflgd = #fromitflgd
     C                   eval      #newfromitcube = #fromitcube
     C                   eval      #newfromitswgt = #fromitswgt
     C                   eval      #newfromitcwgt = #fromitcwgt
     C                   eval      #newfromitmitm = #fromitmitem
     C                   eval      #newfromitsdef = #fromitsdef
     C                   eval      #newfromittie  = #fromittie
     C                   eval      #newfromithigh = #fromithigh
     C                   eval      newssbflg  = ssbflg
     C                   eval      #newssbititem = #fromssbititem
     C                   eval      #newssbittype = #fromssbittype
     C                   eval      #newssbitdesc = #fromssbitdesc
     C                   eval      #newssbitpdsc = #fromssbitpdsc
     C                   eval      #newssbitwhdp = #fromssbitwhdp
     C                   eval      #newssbitstyp = #fromssbitstyp
     C                   eval      #newssbitdesg = #fromssbitdesg
     C                   eval      #newssbitum1  = #fromssbitum1
     C                   eval      #newssbitum2  = #fromssbitum2
     C                   eval      #newssbitumq2 = #fromssbitumq2
     C                   eval      #newssbitum3  = #fromssbitum3
     C                   eval      #newssbitumq3 = #fromssbitumq3
     C                   goto      endgt2
     C                   endif
500cA
500cA*    When item number changed.
500cA
     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETMAIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      $prtn = '*PGMQ   '
     C                   goto      endgt2
     C                   endif
650fA
650fA*    When item number changed is an SSB item - must use case item
650fAc
650fAc                   if        $ittype = 'S'
650fAc                   eval      w1itm = $itmitem
650fAC                   exsr      clr$item
650fAC                   eval      $itwhse  = $slwhse
650fAC                   eval      $ititem  = w1itm

650fAC                   eval      $dricommand = '*ITEM'
650fAC                   eval      $drisubcmd  = '%GETMAIN'
650fAC                   eval      $drisys2upd = 'D'
650fAC                   eval      chk4err = *on
650fAC                   eval      zmsflag = *on
650fAC                   exsr      zzzdricop
650fAC                   if        error
650fAC                   eval      $prtn = '*PGMQ   '
650fAC                   goto      endgt2
650fAC                   endif
650fAc                   endif

     C                   eval      #newfromititem = $ititem
     C                   eval      #newfromittype = $ittype
     C                   eval      #newfromitdesc = $itdesc
     C                   eval      #newfromitpdsc = $itpdsc
     C                   eval      #newfromitwhdp = $itwhdp
     C                   eval      #newfromitstyp = $itstyp
     C                   eval      #newfromitdesg = $itdesg
     C                   eval      #newfromitum1  = $itum1
     C                   eval      #newfromitflg1 = $itflg1
     C                   eval      #newfromitum2  = $itum2
     C                   eval      #newfromitumq2 = $itumq2
     C                   eval      #newfromitflg2 = $itflg2
     C                   eval      #newfromitum3  = $itum3
     C                   eval      #newfromitumq3 = $itumq3
     C                   eval      #newfromitnrpk = $imnrpk
     C                   eval      #newfromitflgd = $itflgd
     C                   eval      #newfromitcube = $itcube
     C                   eval      #newfromitswgt = $itswgt
     C                   eval      #newfromitcwgt = $itcwgt
     C                   eval      #newfromitmitm = $itmitem
600eAC                   eval      #newfromimltrk = $imltrk

     *  Create heading description.

     C                   call      'FRMTIT'
     C                   parm                    #newfromititem
     C                   parm                    #newfromitdesc
     C                   parm                    #newfromitpdsc
     C                   parm      ' '           #newfromithead
500cA
500cA*  Use DRI interface to get corresponding SSB item, if any.
500cA
     C                   exsr      clr$item
     C                   eval      $itwhse  = $slwhse
     C                   eval      $ititem  = w1itm

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%GETSSB'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        $drireturn = 'SSBNOTFND'
     C                   eval      newssbflg  = *off
     C                   eval      #newssbititem = ' '
     C                   eval      #newssbittype = ' '
     C                   eval      #newssbitdesc = ' '
     C                   eval      #newssbitpdsc = ' '
     C                   eval      #newssbitwhdp = ' '
     C                   eval      #newssbitstyp = ' '
     C                   eval      #newssbitdesg = ' '
     C                   eval      #newssbitum1  = ' '
     C                   eval      #newssbitum2  = ' '
     C                   eval      #newssbitumq2 = 0
     C                   eval      #newssbitum3  = ' '
     C                   eval      #newssbitumq3 = 0
600eAC                   eval      #newssbimltrk = 'L'
     C                   else
     C                   eval      newssbflg  = *on
     C                   eval      #newssbititem = $ititem
     C                   eval      #newssbittype = $ittype
     C                   eval      #newssbitdesc = $itdesc
     C                   eval      #newssbitpdsc = $itpdsc
     C                   eval      #newssbitwhdp = $itwhdp
     C                   eval      #newssbitstyp = $itstyp
     C                   eval      #newssbitdesg = $itdesg
     C                   eval      #newssbitum1  = $itum1
     C                   eval      #newssbitum2  = $itum2
     C                   eval      #newssbitumq2 = $itumq2
     C                   eval      #newssbitum3  = $itum3
     C                   eval      #newssbitumq3 = $itumq3
600eAC                   eval      #newssbimltrk = $imltrk
     C                   endif
     *  Move here from zzupd1
720cAc                   if        #fromslitem <> w1itm
720cMc                   if        #fromitcwgt = 'Y'
720cMc                             or #newfromitcwgt = 'Y'
720cMc                   eval      *in60 = *on
720cMc                   else
720cMc                   eval      *in60 = *off
720cMc                   endif
720cAc                   else
720cAc                   eval      *in60 = *off
720cAc                   endif
MRTbAc                   if        #fromslitem <> w1itm
MRTbAc                   if        client = merit
MRTbMc                   eval      *in60 = *on
MRTbAc                   endif
MRTbAc                   endif
     *
     C     endgt2        endsr
600fA*----------------------------------------------------------------
600fA*  getcurrstamp  Get current timestamps
600fA*----------------------------------------------------------------
600fA
600fAC     zzgetcurrstampbegsr

600fAC                   callp     getmicrotime(currstampuc:currstampsys)
600fAC     currstampsys  adddur    bfcoffset:*H  currstamploc

600fAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define partial key for options file.
     *
     C     keyopd        klist
     C                   kfld                    kycode
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
414c *
414c *  Define key for options file, System values.
414c *
414cAC     optsky        klist
414cAC                   kfld                    kywhse
414cAC                   kfld                    opcode
600eA*
600eA*  Define full key for WORKTFR file.
600eA*
600fDC*    wktkey        klist
600fDC*                  kfld                    #curruser
600fDC*                  kfld                    #fromsldisp
600eA*
600eA*  Define partial key for WORKTFR file.
600eA*
600fDC*    wktkeyu       klist
600fDC*                  kfld                    #curruser
600fA*
600fA*  Define full Key For WORKUSR3
600fA*
600fAC     keyUsr3a      klist
600fAC                   kfld                    wkType
600fAC                   kfld                    #emp#
600fAC                   kfld                    $pwhse
600fAC                   kfld                    $pwhdp
600fAC                   kfld                    $pdisp
600fA*
600fA*  Define Partial Key For WORKUSR3
600fA*
600fAC     keyUsr3b      klist
600fAC                   kfld                    wkType
600fAC                   kfld                    #emp#
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
417cAC                   eval      ckdate = $cvd8o
     *
413EAC                   eval      forevr = *off
415cAC                   eval      newtrn = '*NO '
415dAC                   eval      dteold = *off
415dAC                   eval      dteofl = *off
415gAC                   eval      toslup = *off
     C                   eval      $lprg = #prog
     *
CBIdA*
CBIdA*  Define key for TIHIGHSND file.
CBIdA*
CBIdAC     tisndkey      klist
CBIdAC                   kfld                    $slwhse
CBIdAC                   kfld                    $slitem
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
720 AC                   eval      $scmd = '*FIRST'
720 AC                   eval      woslot = *blanks
650eA   // setup array to verify production slots for WIP and Lines
650eA /free
650eA                    sltc = 1;
650eA                    dow sltc < 101;
650eA                       prdslt(sltc) = '   ';
650eA                       sltc = sltc +1;
650eA                    enddo;
650eA
650eA                    setll (*zeros:*zeros) plined;
650eA                    read plined;
650eA                    dow not %eof(plined);
650eA
650eA                       sltc = 1;
650eA                       // look for raw material aisle location
650eA                       dow sltc < 101;
650eA                          if prdslt(sltc) = '   '
650eA                              or prdslt(sltc) = inRcvAisl;
650eA                             leave;
650eA                          endif;
650eA                          sltc = sltc +1;
650eA                       enddo;
650eA                       // if comes out blank it means we should
650eA                       // add to the array of prod slot aisles
650eA                       if prdslt(sltc) = '   ';
650eA                          prdslt(sltc) = inRcvAisl;
650eA                       endif;
650eA
650eA                       sltc = 1;
650eA                       // look for WIP Stock aisle location
650eA                       dow sltc < 101;
650eA                          if prdslt(sltc) = '   '
650eA                              or prdslt(sltc) = inWipAisl;
650eA                             leave;
650eA                          endif;
650eA                          sltc = sltc +1;
650eA                       enddo;
650eA                       // if comes out blank it means we should
650eA                       // add to the array of prod slot aisles
650eA                       if prdslt(sltc) = '   ';
650eA                          prdslt(sltc) = inWipAisl;
650eA                       endif;
650eA
650eA                       read plined;
650eA                    enddo;
650eA /end-free
650gAC                   move      '0'           dfchk
500cAC                   eval      tfroutflag = *off
750aA*
750aAC                   eval      worow = 0
750aAC                   eval      wocol = 0
     *
765aA*   Call interface to do verification.

765aAC                   exsr      clr$slot
765aAC                   eval      $slwhseu = *on
765aAC                   eval      $slwhse  = $pwhse
765aAC                   eval      $slwhdpu = *on
765aAC                   eval      $slwhdp  = $pwhdp
765aAC                   eval      $sldispu = *on
765aAC                   eval      $sldisp  = $pdisp

765aAC                   eval      $dricommand = '*SLOT'
765aAC                   eval      $drisubcmd  = '%GET'
765aAC                   eval      $drisys2upd = 'D'
765aAC                   eval      chk4err = *on
765aAC                   eval      zmsflag = *off
765aAC                   exsr      zzzdricop
600mA*
600mA*  Do not allow the transfer from a RCV/STG slot.
600nA*    except for *CHANGEX
600mA*
600nAC                   if        $pcmd = '*CHANGEX'
600nAC                   eval      $pcmd = '*CHANGE'
600nAC                   else
600mAC**765aD            if        %subst($pdisp:1:3) = 'RCV'
765aAC                   if        $sldesg ='BFC' and
765aMC                             (%subst($pdisp:1:3) = 'RCV'
600mAC                             or %subst($pdisp:1:3) = 'STG'
710dAC                             or %subst($pdisp:1:3) = 'RTN'
765aMC                             or %subst($pdisp:1:3) = 'RWO')
600mAC                   eval      error = *on
600mAC                   eval      *in23 = *on
600mAC                   eval      *in03 = *on
730aMC                   eval      errmsg = 'RCV/STG/RTN/RWO slot not '
730aMC                                    + 'allowed - use Putaway'
730aDC*                  eval      errmsg = 'RCV/STG/RTN slot not '
730aDC*                                   + 'allowed - use Putaway'
710dDC*                  eval      errmsg = 'RCV/STG slot not allowed '
710dDC*                                   + '- use Putaway'
600mAC                   exsr      zm0105s
600mAC                   eval      nxtscr = 'EOJ'
600mAC                   leavesr
600mAC                   endif
600nAC                   endif
500cA*
500cA*    - Get default values for the user.
500cA*
500cAC                   call      'GETUSER'
600eMC                   parm                    #curruser
500cAC                   parm      0             #whse             3 0
500cAC                   parm      0             #emp#             5 0
500cAC                   parm                    #fnam            15
500cAC                   parm                    #init             1
500cAC                   parm                    #lnam            20
500cAC                   parm                    #whdp             5
500cAC                   parm                    #styp             1
500cAC                   parm                    #shft             6
500cAC                   parm                    #crew             6
500cAC                   parm      0             #nhrs             3 1
500cAC                   parm                    #rtn              8
600eAC                   parm                    e$bpu             1
600eAC                   parm                    e$lng             2
600eAC                   if        #rtn <> '*OK'
600eAC                   eval      e$lng = 'EN'
600eAC                   endif
600eA*
600eA*   Clear work file for user.
600eA*
600eAC                   exsr      zzwrkinz
     *
     *   Get warehouse description.
     *
     C     $pwhse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = *blanks
     C                   endif
     C                   move      $pwhse        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFT   '    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         wowhse
414c *
414cA*
414cA*   Get system options.
414cA*
414cAC                   eval      kywhse = *zeros
414cAC                   eval      opcode = '*SYSTEM '
414cAC     optsky        chain     options                            79
414cAC                   if        *in79
414cAC                   eval      opmpck = 'N'
414cAC                   else
414cAC                   eval      opdat2 = opdata
414cAC                   endif
     *
     *   Get department description.
     *
     C     keywd         klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp
     C     keywd         chain     whdept                             79
     C                   if        *in79
     C                   eval      wdcode = *blanks
     C                   eval      wddesc = *blanks
     C                   endif
     *
     *   Get department Options.
     *
     C                   eval      kycode = '*PICK   '
     C     keyopd        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
500 A*
500 AC                   eval      kywhse = $pwhse
     *
     *   Select first screen to display.
     *
412 AC                   eval      odisp = *blanks
     C                   eval      lock = *off
     C                   eval      exist = *off
     C                   eval      usesc = 1
     C                   exsr      scr01i
412 AC                   eval      odisp = *blanks
500cA
500cA*   If an error didn't occur and we are staying in this pgm ...
500cA
500cAC                   if        nxtscr <> 'EOJ'
600eA
600eAC                   eval      curlic# = #fromToLcns
500cA
500cA*    Call program that will (if necessary) ...
500cA*      - Prompt user to pull pallet.
500cA*      - Have user verify license being pulled.
500cA*      - Update license information.
500cA
500cAC                   exsr      zzzclr$lt210
500cAC                   eval      $tcmd  = '*PULDROP'
500cAC                   eval      $twhse = $pwhse
500cAC                   eval      $twhdp = #fromslwhdp
500cAC                   eval      $tslot = #fromsldisp
500cAC                   eval      $titem = #fromslitem
500cAC                   eval      $titemdsc = #fromithead
600eAC                   eval      $tlic# = #fromToLcns
500cAC                   exsr      zzzcall$lt210
600eDC**                 eval      curlic# = $tlic#
500cA
500cAC                   if        $treturn = '*CANCEL'
500cAC                   eval      nxtscr = 'EOJ'
500cAC                   endif
500cA
500cAC                   if        $treturn = '*NOTFND'
500fA
500fAC                   exsr      zzzclr$lt210
500fAC                   eval      $tcmd   = '*PULRTN'
500fAC                   eval      $twhse  = $pwhse
500fAC                   eval      $twhdp  = #fromslwhdp
500fAC                   eval      $tslot  = #fromsldisp
500fAC                   eval      $titem  = #fromslitem
500fAC                   eval      $titemdsc = #fromithead
600eAC                   eval      $tlic# = #fromToLcns
500fAC                   exsr      zzzcall$lt210
500fA
500cAC                   eval      nxtscr = 'EOJ'
500cAC                   endif
500cA
500cAC                   endif
500cA
500cA*    Start transaction.
600eA*    Add record to work file.
500cA
500cAC                   if        nxtscr <> 'EOJ'
500cAC                   eval      lbwhdp = #fromslwhdp
500cAC                   eval      lbstyp = #fromslstyp
500cAC                   exsr      zztrnstart
600hDC**                 exsr      zzwrkadd
500cAC                   endif
CBIaAC     USKEY         KLIST
CBIaAC                   KFLD                    #USER
CBIaAC*
CBIaAC     USKEY         CHAIN     PIRUSER                            79
CBIaAC     *IN79         IFEQ      *OFF
CBIaAC                   Z-ADD     USEMP#        W1EMP#           10 0
CBIaAC                   ELSE
CBIaAC                   Z-ADD     0             W1EMP#
CBIaAC                   ENDIF
500cA
     C                   endsr
CBIbAC*----------------------------------------------------------------
CBIbAC*
CBIbAC*  ZZLOG  Log the info of the item location change being done.
CBIbAC*
CBIbAC     zzlog         begsr
CBIbAC*
CBIbAC                   clear                   locrec
CBIbAC                   z-add     $slwhse       locwhs
CBIbAC                   move      $slwhdp       locdpt
CBIbDC                   move      #fromslitem   locitm
CBIbMC                   move      fmdisp        locfrm
CBIbAC                   move      #tosldisp     locto
CBIbAC*    Get todays date.
CBIbAC                   move      '*CURCMD '    $cvcmd
     C                   call      @cvtdt
     C                   parm                    $cvtdt
CBIbAC                   z-add     $cvd8o        locdte
CBIbAC                   time                    loctim
CBIbAC                   move      #user         locusr
CBIbAC                   z-add     w1emp#        locemp
CBIbAC*
CBIbAC                   write     locrec
CBIbAC*
CBIdAC     tisndkey      chain     tihighsnd                          79
CBIdAC                   eval      snwhse = $slwhse
CBIdMC                   eval      snitem = #fromslitem
CBIdAC                   eval      sntie  = *zeros
CBIdAC                   eval      snhigh = *zeros
CBIdAC                   eval      snsdef = *blanks
CBIdAC                   eval      snsend = 'N'
CBIdAC                   if        *in79 = *off
CBIdAC                   update    sndrec
CBIdAC                   else
CBIdAC                   write     sndrec
CBIdAC                   endif
CBIbAC*
CBIbAC     endlog        endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNCLOSE  Close a transaction
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnclose    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CLOSE'      @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      curtrn#       @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNIDLE   Start and IDLE transaction.
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnidle     begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'IDLE'        @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNSTART  Start a transaction
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnstart    begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*CRTSTRT'    @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      0             @ptrn#            7 0
     C                   parm      'TFRMOV'      @ptask            6
     C                   parm      $pwhse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm      0             @pcube            9 3
     C                   parm      0             @pswgt            9 2
     C                   parm      0             @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      'T'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   eval      curtrn# = @ptrn#
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
500cA*----------------------------------------------------------------
500cA
500cAC     zztrnupdate   begsr

     C                   call      'ADJTRAN2'
     C                   parm      '*INCTTL'     @pcmd            10
     C                   parm      #pgm          @pprg            10
     C                   parm      '*BATCH'      @ptype            8
     C                   parm      lbtrn#        @ptrn#            7 0
     C                   parm      ' '           @ptask            6
     C                   parm      0             @pwhse            3 0
     C                   parm      ' '           @pwhdp            5
     C                   parm      ' '           @pstyp            1
     C                   parm      lbcube        @pcube            9 3
     C                   parm      lbswgt        @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      ' '           @prte             5
     C                   parm      ' '           @ppo              9
     C                   parm      ' '           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
     C                   parm      0             @pdate            8 0
     C                   parm      0             @ptime            6 0
600eMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4

     C                   endsr

     *----------------------------------------------------------------
     *
     *  ZZUOM    Get Unit Of Measure Normal, Breakdown1, Breakdown2.
     *
     C     zzuom         begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
     *
416gAC                   eval      bkdwn1 = '*NO '
416gAC                   eval      bkdwn2 = '*NO '
416dAC                   eval      *in92 = *off
500cMC                   if        #fromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
700dA /free
700dA                    if %lookup(%subst($pdisp:1:3):prdslt) > 0;
700dA                       if #fromitum2<>' ';
700dA                          #fromitflg1 = 'Y';
700dA                       endif;
700dA                       if #fromitum3<>' ';
700dA                          #fromitflg2 = 'Y';
700dA                       endif;
700dA                    endif;
700dA /end-free
500cMC                   if        #fromitflg1 = 'N'  and
413 MC                             ssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
500cMC                   if        #fromitflg2 = 'N'  and
413 AC                             ssbflg = *off  or
500cMC                             #fromitflg2 = 'N'  and
413 AC                             ssbflg = *on  and
500cMC                             #fromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
500cMC     #fromitum1    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
416gA*
416gA*    Breakdown 1  qty's supported.
500cMC                   if        #fromitumq2 > *zeros
416gAC                   eval      bkdwn1 = '*YES'
416gAC                   endif
500cMC     #fromitum2    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
416gA*
416gA*    Breakdown 2  qty's supported.
500cMC                   if        #fromitumq3 > *zeros
416gAC                   eval      bkdwn2 = '*YES'
416gAC                   endif
500cMC     #fromitum3    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
500cA*----------------------------------------------------------------
500cA*
500cA*  ZZUOMNEW   Get Unit Of Measure Normal, Breakdown1, Breakdown2.
500cA*
500cAC     zzuomnew      begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
416pAC                   eval      bkdwn1 = '*NO '
416pAC                   eval      bkdwn2 = '*NO '
417gAC                   eval      *in92 = *off
500cMC                   if        #newfromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduomnew
     C                   else
500cMC                   if        #newfromitflg1 = 'N'  and
413 MC                             newssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
500cMC                   if        #newfromitflg2 = 'N'  and
413 AC                             newssbflg = *off  or
500cMC                             #newfromitflg2 = 'N'  and
413 AC                             newssbflg = *on  and
500cMC                             #newfromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
500cMC     #newfromitum1 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um1 = umshrt
     C                   else
     C                   eval      w2um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
416pA*
416pA*    Breakdown 1  qty's supported.
500cMC                   if        #newfromitumq2 > *zeros
416pAC                   eval      bkdwn1 = '*YES'
416pAC                   endif
500cMC     #newfromitum2 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um2 = umshrt
     C                   else
     C                   eval      w2um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
416pA*
416pA*    Breakdown 2  qty's supported.
500cMC                   if        #newfromitumq3 > *zeros
416pAC                   eval      bkdwn2 = '*YES'
416pAC                   endif
500cMC     #newfromitum3 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um3 = umshrt
     C                   else
     C                   eval      w2um3 = *blanks
     C                   endif
     C                   endif
     C     enduomnew     endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update record.
     *
     C     zzupd1        begsr
     C                   eval      error = *off
416c *
416c *   Item changed, set flag for adjustment code entry.
500cMC                   if        #fromslitem <> w1itm
416cAC                   eval      *in59 = *on
720cDC*                  if        #fromitcwgt = 'Y'
720cDC*                            or #newfromitcwgt = 'Y'
720cDC*                  eval      *in60 = *on
720cDC*                  else
720cDC*                  eval      *in60 = *off
720cDC*                  endif
416cAC                   else
416cAC                   eval      *in59 = *off
530aAC                   eval      *in60 = *off
416cAC                   endif
600eM*
600eM*  Set partial quantity flag.
600eM*
600eM*    These values were recalculated and sent back from
600eM*    the VFYTFOCHG command. If all of the original #FROM
600eM*    buckets were zero and the new Avail quantities are
600eM*    zero, then the entire quantity is being taken.
600eM*
600eMC                   if        $slavl1 = 0 and
600eMC                             $slavl2 = 0 and
600eMC                             $slavl3 = 0 and
600eMC                             #fromslalc1 = 0 and
600eMC                             #fromslalc2 = 0 and
600eMC                             #fromslalc3 = 0 and
600eMC                             #fromslrcv1 = 0 and
600eMC                             #fromslrcv2 = 0 and
600eMC                             #fromslrcv3 = 0 and
710bMC                             #fromslpck1 = 0 and
710bMC                             #fromslpck2 = 0 and
710bMC                             #fromslpck3 = 0 and
600eMC                             #fromsltfr1 = 0 and
600eMC                             #fromsltfr2 = 0 and
600eMC                             #fromsltfr3 = 0
600eMC                   eval      partial = *off
600eMC                   else
600eMC                   eval      partial = *on
600eMC                   endif
600eM
600eM*  License plate tracking item. Update to show in transit.
600eM
600eMC                   exsr      zzzclr$lt210
600eMC                   eval      $tcmd     = '*PULTRAN'
600eMC                   eval      $tlic#    = curlic#
600eMC                   eval      $tnewlic# = curlic#
600eMC                   eval      $twhse    = $pwhse
600eMC                   eval      $titem    = #fromslitem
600eMC                   eval      $titemdsc = #fromithead
600eMC                   eval      $tpartial = partial
600eMC                   eval      $tqty1    = w1qt01
600eMC                   eval      $tqty2    = w1qt02
600eMC                   eval      $tqty3    = w1qt03
600eMC                   eval      $tnorm1   = w1qt01
600eMC                   eval      $tnorm2   = w1qt02
600eMC                   eval      $tnorm3   = w1qt03
600eMC                   exsr      zzzcall$lt210
600eM
600eMC                   if        $treturn <> '*OK'
600eMC                   endif
600eM
600eMC                   eval      curlic# = $tinlic#
500cA
500cA*  Use DRI interface to update From slot.
500cA*    Note: The $sl info that was retrieved in ZZGET1.
500cA
500cAC                   exsr      clr$slot
500cAC                   eval      $slwhseu  = *on
500cAC                   eval      $slwhse   = $pwhse
500cAC                   eval      $slwhdpu  = *on
500cAC                   eval      $slwhdp   = #fromslwhdp
500cAC                   eval      $sldispu  = *on
500cAC                   eval      $sldisp   = #fromsldisp
500cAC                   eval      $saitemu  = *on
500cAC                   eval      $saitem   = #fromslitem
500cAC                   eval      $saqtyu   = *on
500cAC                   eval      $saqty1   = w1qt01
500cAC                   eval      $saqty2   = w1qt02
500eMC                   eval      $saqty3   = w1qt03
500cAC                   eval      $sacitemu = *on
600jDC**                 eval      $sacitem  = w1itm
600jMC                   eval      $sacitem  = #fromslitem

600eAC                   eval      $satasku = *on
600eMC                   eval      $satask  = 'TFRMOV'
600eA
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'TFR'
600eAC                   eval      $saTrn#U = *on
600eAC                   eval      $saTrn# = curtrn#
600eAC                   eval      $saETrn#U = *on
600eAC                   eval      $saETrn# = 0
600eAC**                 eval      $saLbl#U = *on
600eAC**                 eval      $saLbl# = lblbl#
600eAC                   eval      $saToLcnsU = *on
600eAC                   eval      $saToLcns = $tinlic#
600eAC                   eval      $saToPosU = *on
600eAC                   eval      $saToPos = $tslotpos
600eAC                   eval      $saToVrfyU = *on
600eAC                   eval      $saToVrfy = 'N'
600eAC                   eval      $saToCodeu = *on
600eAC                   eval      $saToCode = 'U'
600eAC                   eval      $saToAreaU = *on
600eAC                   eval      $saToArea = 'User'
600eAC                   eval      $saFrmLcnsU = *on
600eAC                   eval      $saFrmLcns = $toutlic#
600eAC                   eval      $saOLcnsU = *on
600fDC*                  eval      $saOLcns = wkpulolcns
600fAC                   eval      $saOLcns = wuPulolcns
640aA
640aA*     Set item change flag
640aA
640aAC                   if        #fromslitem <> w1itm
640aAC                   eval      $saItmChgU = *on
640aAC                   eval      $saItmChg = 'Y'
640aAC                   endif
500cA
500cAC                   eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd  = '%TFROUTCHG'
610dA
610dA*     Do Reverse transfer if Pick slot and item didn't change.
610dA
610dAC                   if        #fromslpick = 'Y'
610dAC                             and #fromslitem = w1itm
610eAC                   eval      Ypickslot   = *on
700fD **   If FROM slot is pick, save data just in case TO slot
700fD **           is a pick slot.  Moving to USR slot and need
700fD **           copy FROM slot data.
700fD **** The #Yfrom fields are unnecessary, as #from fields can be used.
700fDC**                 eval      #Yfromslwhse =  $slwhse
700fDC**                 eval      #Yfromslwhdp =  $slwhdp
700fDC**                 eval      #Yfromsldisp =  $sldisp
700fDC**                 eval      #Yfromslpick =  $slpick
700fDC**                 eval      #Yfromslitem =  $slitem
700fDC**                 eval      #Yfromslstk1 =  $slstk1
700fDC**                 eval      #Yfromslstk2 =  $slstk2
640hDC***                eval      #Yfromslstk3 =  $slstk2
700fDC**                 eval      #Yfromslstk3 =  $slstk3
700fDC**                 eval      #Yfromslstat =  $slstat
700jAC                   eval      $saAllowZrou = allowZrou
700jAC                   eval      $saAllowZero = allowZero
610eA
610dAC                   eval      $drisubcmd  = '%TFR2USRR'
610dAC                   else
600eMC                   eval      $drisubcmd  = '%TFR2USR'
610dAC                   endif
610dA
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      chk4err = *on
500cAC                   eval      zmsflag = *off
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   goto      endup1
500cAC                   endif
650aAC                   eval      tfr2usrDate = today
650aAC                   time                    tfr2usrTime
500cAC                   eval      tfroutflag = *on
600eAC                   eval      curlic# = $saToLcns
600eAC                   eval      $tinlic# = $saToLcns
330fA
CBIeA*  Override $saFrmEmpty for an empty Pick slot.
CBIeA*  Re: We want to ask a user if the slot is empty just in case he is
CBIeA*  moving the item to another Pick slot and we are allow to auto verify.
CBIeA
CBIeAC                   if        client = cheney
CBIeAC                   if        Ypickslot   = *on
CBIeAC                             and partial = *off
CBIeAC                   eval      $saFrmEmpty = 'Y'
CBIeAC                   endif
CBIeAC                   endif
600eA*
600hM*  Create work record.
600eA*
600hDC**                 exsr      zzwrkupd
600hMC                   exsr      zzwrkadd
500cA
500cA*    Then tell user to put back an pulled pallets.
500cA*         and move on to the putaway process.
500cA
500cAC                   exsr      zzzclr$lt210
500cAC                   eval      $tcmd  = '*PULRTN'
500cAC                   eval      $twhse = $pwhse
500cAC                   eval      $twhdp = #fromslwhdp
500cAC                   eval      $tslot = #fromsldisp
500cAC                   eval      $titem = #fromslitem
500cAC                   eval      $titemdsc = #fromithead
610aAC                   eval      $tinlic# = $saToLcns
610aAC                   eval      $tlic#   = $saToLcns
500cAC                   exsr      zzzcall$lt210
500cAC                   if        $treturn <> '*OK'
500cAC                   endif
CBIeA
CBIeA*  Check if slot can be verified after transfer complete.
CBIeA
CBIeAC                   if        client = cheney
CBIeAC                   exsr      zzchkzrovfy
CBIeAC                   else
CBIeAC                   eval      verifyzero = *off
CBIeAC                   endif
CBIeAC                   if        verifyzero
CBIeAC                   eval      w3zero = 'Y'
CBIeAC                   else
CBIeAC                   eval      w3zero = 'N'
CBIeAC                   endif
610eA
500cAC                   exsr      scr02i
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
415dAC                   eval      dteold = *off
415dAC                   eval      dteofl = *off
417cA*    Get todays date.
417cAC                   eval      $cvcmd = '*CURCMD '
417cAC                   call      @cvtdt
417cAC                   parm                    $cvtdt
417cAC                   eval      ckdate = $cvd8o
417cA*
     *   Change quantity to breakdown quantity if needed.
500cMC                   if        #fromslitem <> w1itm
500cMC                   if        #fromittype = ' '
500cMC                   if        #newfromittype = 'S'  or
500cMC                             #newfromittype = 'B'  and
500cMC                             #fromitumq2 <> 0
500cMC                   eval      toqty1 = w1qt01 * #fromitumq2
     C                   else
500cMC                   eval      toqty1 = w1qt01
     C                   endif
     C                   endif
     *
500cMC                   if        #fromittype = 'S'  or
500cMC                             #fromittype = 'B'
500cMC                   if        #newfromittype = ' '  and
500cMC                             #newfromitumq2 <> 0
500cMC                   eval      toqty1 = w1qt01 / #newfromitumq2
     C                   else
500cMC                   eval      toqty1 = w1qt01
     C                   endif
     C                   endif
     C                   else
500cMC                   eval      toqty1 = w1qt01
     C                   endif
600kA
600kA*    Determine if we are returning qty to original slot.
610fA*    (If this logic is changed, also change in ZZUPD2)
600kA
600kAC                   if        #toslwhdp = wuPulWhdp
600kAC                             and #tosldisp = wuPulDisp
600kAC                             and w1itm = wuPulItem
600kAC                   eval      rtnToOrig = *on
600kAC                   else
600kAC                   eval      rtnToOrig = *off
600kAC                   endif
500cA
500cA*    Call license tracking for putaway - Before update
600kA*    Only call when not returning to original slot.
500cA
600kAC                   if        rtnToOrig = *on
600kA
600kAC                   eval      $tinlic# = wuPulLcns
600kAC                   eval      $tslotpos = wuPulPos
600kAC                   eval      $toutlic# = wuUsrLcns
600kA
600kAC                   else
600kA
610fAC                   if        not skipLT210
600fA
500cAC                   exsr      zzzclr$lt210
500cAC                   eval      $tcmd     = '*PUTAWYB'
600kDC**                 eval      $tlic#    = curlic#
600kMC                   eval      $tlic#    = wuUsrLcns
600eDC**                 eval      $tpartial = *off
600eMC                   eval      $tpartial = partial
500cAC                   eval      $twhse    = $pwhse
500cAC                   eval      $twhdp    = #toslwhdp
500cAC                   eval      $tslot    = #tosldisp
600eMC**                 eval      $twhdp    = wkUsrWhdp
600eMC**                 eval      $tslot    = wkUsrDisp
500cAC                   eval      $titem    = w1itm
500cAC                   eval      $titemdsc = #newfromithead
500cAC                   eval      $tqty1    = toqty1
500cAC                   eval      $tqty2    = w1qt02
500cAC                   eval      $tqty3    = w1qt03
500jAC                   eval      $tnorm1   = toqty1
500jAC                   eval      $tnorm2   = w1qt02
500jAC                   eval      $tnorm3   = w1qt03
500cAC                   exsr      zzzcall$lt210
500cA*
500cAC                   if        $treturn <> '*OK'
500mAC                   eval      redspl = *on
600eAC                   eval      error = *on
600eAC                   eval      errmsg = $terrmsg
600eAC                   exsr      zm0105
500cAC                   goto      endup2
500cAC                   endif
600fA
610fAC                   endif
600kA
600kAC                   endif
500cA
600eM*  Use DRI interface to tfr qty from USR slot to To slot.
500cA
500cAC                   exsr      clr$slot
500cAC                   eval      $slwhseu  = *on
500cAC                   eval      $slwhse   = $pwhse
500cAC                   eval      $slwhdpu  = *on
500cAC                   eval      $slwhdp   = #toslwhdp
500cAC                   eval      $sldispu  = *on
650eAc                   if        prdtfr
650eAC                   eval      $slstatu  = *on
650eAC                   eval      $slstat   = 'PR'
650eAC                   eval      $sldisp   = hldprdDisp
650eAc                   else
500cAC                   eval      $sldisp   = #tosldisp
650eAc                   endif
500dAC                   eval      $slentdu  = *on
500dAC                   eval      $slentd   = #fromslentd
500cAC                   eval      $slexpdu  = *on
500cAC                   eval      $slexpd   = #fromslexpd
500cAC                   eval      $saitemu  = *on
500cAC                   eval      $saitem   = w1itm
500cAC                   eval      $saqtyu   = *on
500cAC                   eval      $saqty1   = w1qt01
500cAC                   eval      $saqty2   = w1qt02
500eMC                   eval      $saqty3   = w1qt03
500cAC                   eval      $sacitemu = *on
500cAC                   eval      $sacitem  = #fromslitem
600eAC                   eval      $sacwhdu = *on
600fDC*                  eval      $sacwhd  = wkUsrWhdp
600fAC                   eval      $sacwhd  = wuUsrWhdp
600lAC                   eval      $sacdspu  = *on
600eDC**                 eval      $sacdsp   = #fromsldisp
600fDC*                  eval      $sacdsp   = wkUsrDisp
600fAC                   eval      $sacdsp   = wuUsrDisp
600eMC                   eval      $saToposu = *on
600eMC                   eval      $saTopos  = $tslotpos
600eA
600eAC                   eval      $saActionU = *on
600eAC                   eval      $saAction = 'TFR'
600eAC                   eval      $saTrn#U = *on
600eAC                   eval      $saTrn# = curtrn#
600eAC                   eval      $saETrn#U = *on
600eAC                   eval      $saETrn# = 0
600eAC**                 eval      $saLbl#U = *on
600eAC**                 eval      $saLbl# = lblbl#
600eAC                   eval      $saToLcnsU = *on
600eAC                   eval      $saToLcns = $tinlic#
600eAC                   eval      $saToPosU = *on
600eAC                   eval      $saToPos = $tslotpos
600eAC                   eval      $saToVrfyU = *on
600eAC                   eval      $saToVrfy = 'N'
600eAC                   eval      $saToCodeu = *on
600eAC                   eval      $saToCode = 'S'
600eAC                   eval      $saToAreaU = *on
600eAC                   eval      $saToArea = 'Slot'
600eAC                   eval      $saFrmLcnsU = *on
600eAC                   eval      $saFrmLcns = $toutlic#
600eAC                   eval      $saOLcnsU = *on
600fDC*                  eval      $saOLcns = wkpulolcns
600fAC                   eval      $saOLcns = wuPulolcns
600jAC                   eval      $sapullwhdpu = *on
600jAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns
700jAC                   eval      $saAllowZrou = allowZrou
700jAC                   eval      $saAllowZero = allowZero
640aA
640aA*     Set changed item flag if necessary.
640aA
640aAC                   if        #fromslitem <> w1itm
640aAC                   eval      $saItmChgU = *on
640aAC                   eval      $saItmChg = 'Y'
640aAC                   endif
600kA
600kAC                   if        rtnToOrig = *on
600kAC                   eval      $saexcdU = *on
600kAC                   eval      $saexcd  = 'RTNORIG'
600kAC                   endif
600cA
720dAc                   if        $tpartial = *on
720dAc                   eval      $saUCIts = $tpartime
720dAc                   eval      $saUCItsU = *on
720dAc                   endif

500cAC                   eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd  = '%CLSTFICHG'
600eMC                   eval      $drisubcmd  = '%USR2PUT'
500cAC                   eval      $drisys2upd = 'D'
500cAC                   eval      chk4err = *on
500cAC                   eval      zmsflag = *off
500cAC                   exsr      zzzdricop
500cAC                   if        error
500cAC                   eval      *in21 = *on
500cAC                   eval      *in01 = *on
500cAC                   goto      endup2
500cAC                   endif
500cA
500cA*  Update #TO slot info in case item was put into a virtual slot.
500cA
500cAC                   eval      #toslhand = $slhand
500cAC                   eval      #tosldisp = $sldisp
650eAc                   if        prdtfr
650eAC                   eval      #toslstat = 'PR'
650eAc                   else
640aAC                   eval      #toslstat = $slstat
650eAc                   endif
600eD **
600eD ** Use DRI interface to update From slot.
600eD **
600eDC**                 exsr      clr$slot
600eDC**                 eval      $slwhseu  = *on
600eDC**                 eval      $slwhse   = $pwhse
600eDC**                 eval      $slwhdpu  = *on
600eDC**                 eval      $slwhdp   = #fromslwhdp
600eDC**                 eval      $sldispu  = *on
600eDC**                 eval      $sldisp   = #fromsldisp
600eDC**                 eval      $saitemu  = *on
600eDC**                 eval      $saitem   = #fromslitem
600eDC**                 eval      $saqtyu   = *on
600eDC**                 eval      $saqty1   = w1qt01
600eDC**                 eval      $saqty2   = w1qt02
600eDC**                 eval      $saqty3   = w1qt03
600eDC**                 eval      $saorgu   = *on
600eDC**                 eval      $saorg1   = w1qt01
600eDC**                 eval      $saorg2   = w1qt02
600eDC**                 eval      $saorg3   = w1qt03
600eDC**                 eval      $sacitemu = *on
600eDC**                 eval      $sacitem  = w1itm
600eDC**
600eDC**                 eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd  = '%CLSTFOCHG'
600eDC**                 eval      $drisys2upd = 'D'
600eDC**                 eval      chk4err = *on
600eDC**                 eval      zmsflag = *off
600eDC**                 exsr      zzzdricop
600eDC**                 if        error
600eDC**                 eval      *in21 = *on
600eDC**                 eval      *in01 = *on
600eDC**                 goto      endup2
600eDC**                 endif
500cA
500cA*    Call license tracking for putaway - After update
500cA*      Values are left over from "Before" call.
500cA
500cAC                   eval      $tcmd     = '*PUTAWYA'
500cAC                   eval      $tslot    = #tosldisp
500cAC                   exsr      zzzcall$lt210
500cA*
500cAC                   if        $treturn <> '*OK'
500cAC                   endif
600eD **
600eD **   If #to slot not the same as the #from slot,
600eD **     Then see if a zero lichist rec needs to be removed.
600eD **
600eDC**                 if        #toslwhdp <> #fromslwhdp
600eDC**                           or #tosldisp <> #fromsldisp
600eDC**                 exsr      zzzclr$lt210
600eDC**                 eval      $tcmd  = '*RMVZERO'
600eDC**                 eval      $twhse  = $pwhse
600eDC**                 eval      $twhdp  = #fromslwhdp
600eDC**                 eval      $tslot  = #fromsldisp
600eDC**                 eval      $titem  = #fromslitem
600eDC**                 eval      $titemdsc = #fromithead
600eDC**                 exsr      zzzcall$lt210
600eDC**                 if        $treturn <> '*OK'
600eDC**                 endif
600eDC**                 endif
500cA
610eA ** Use DRI interface to update From slot.
610eA **
610eAC                   if        Ypickslot = *on
610eAC                             and $slpick = 'Y'
640bAC                             and $slstat <> 'RP'
640hAC                             and $slstyp = 'F'
640dDC***                          and opmpck = 'N'
610eAC                   exsr      clr$slot
610eAC                   eval      $slwhseu  = *on
700fDC**                 eval      $slwhse   = #Yfromslwhse
700fMC                   eval      $slwhse   = $pwhse
610eAC                   eval      $slwhdpu  = *on
700fDC**                 eval      $slwhdp   = #Yfromslwhdp
700fMC                   eval      $slwhdp   = #fromslwhdp
610eAC                   eval      $sldispu  = *on
700fDC**                 eval      $sldisp   = #Yfromsldisp
700fMC                   eval      $sldisp   = #fromsldisp
610eAC                   eval      $slitemu  = *on
700fDC**                 eval      $slitem   = #Yfromslitem
700fMC                   eval      $slitem   = #fromslitem
610eAC                   eval      $slstat   = *off
700fDC**                 eval      $slstat   = #Yfromslstat
700fMC                   eval      $slstat   = #fromslstat
610eAC                   eval      $dricommand = '*SLOT'
610eAC                   eval      $drisubcmd  = '%SETSTAT  '
610eAC                   eval      $drisys2upd = 'D'
610eAC                   eval      chk4err = *on
610eAC                   eval      zmsflag = *off
610eAC                   exsr      zzzdricop
610eAC                   eval      Ypickslot = *off
650bAC                   if        $drireturn = 'NOTZROSTAT'
650bAC                   eval      error = *off
650bAC                   endif
610eAC                   if        error
610eAC                   eval      *in21 = *on
610eAC                   eval      *in01 = *on
640cD ***                goto      endup2
610eAC                   endif
610eAC                   endif
610eAC                   eval      Ypickslot = *off
500cA*  Create label(s), create extra trans, close trans.
500cA
500cAC                   exsr      zzcrtl
600iA
600iA*  Delete work record
600xi
600iAC                   exsr      zzwrkdel
CBIeA
CBIeA*  Use DRI interface to zero verify From slot if needed.
CBIeA
CBIeAC                   if        verifyzero and w3zero = 'Y'
CBIeAC                   exsr      clr$slot
CBIeAC                   eval      $slwhseu = *on
CBIeAC                   eval      $slwhse  = $pwhse
CBIeAC                   eval      $slwhdpu = *on
CBIeAC                   eval      $slwhdp  = #fromslwhdp
CBIeAC                   eval      $sldispu = *on
CBIeAC                   eval      $sldisp  = #fromsldisp
CBIeA
CBIeAC                   eval      $dricommand = '*SLOT'
CBIeAC                   eval      $drisubcmd  = '%ZEROVFY'
CBIeAC                   eval      $drisys2upd = 'D'
CBIeAC                   eval      chk4err = *off
CBIeAC                   eval      zmsflag = *off
CBIeAC                   exsr      zzzdricop
CBIeAC                   if        error
CBIeAC                   endif
CBIeAC                   endif
500cA
500cA*  Start idle tran.
500cA
500cAC                   exsr      zztrnidle
     *
     *   Send back info message.
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      errmsg = *blanks
     C                   move      w2qty         erqty
500cMC                   eval      eritem = #fromslitem
     C                   eval      erfrom = fmdisp
413eMC                   eval      erto = w2disp
     C                   exsr      zm1521
     *
CBIbAC*   Create an update log record
CBIbAC                   exsr      zzlog
CBIbAC*
     C     endup2        endsr
600eA
600eA*----------------------------------------------------------------
600eA*  zzwrkadd   Add record to work file for user.
600eA*----------------------------------------------------------------
600eA
600eAC     zzwrkadd      begsr

600fDC*                  clear                   wktrec

600fDC*                  eval      wktuser = #curruser
600fDC*                  eval      wkttrn# = curtrn#
600fDC*                  eval      wktwhse = $pwhse
600fDC*                  eval      wkpulwhdp = #fromslwhdp
600fDC*                  eval      wkpuldisp = #fromsldisp
600fDC*                  eval      wkpulitem = #fromslitem
600fDC*                  eval      wkpullcns = #fromToLcns
600fDC*                  eval      wkpulolcns = #fromOLcns

600fDC*                  write     wktrec
600fAC*
600fAC***
600fAC*
600fAC                   exsr      zzgetcurrstamp
600fA
600fAC                   clear                   wuRec
      *
600fAC                   eval      wutrn# = curtrn#
600fAC                   eval      wuwhse = $pwhse
600fAC                   eval      wuscannbr = #fromToLcns
600fAC                   eval      wuscantype = 'P'
600fAC                   eval      wupulwhdp = #fromslwhdp
600gAC                   eval      wupulbase = #frombasesldsp
600fAC                   eval      wupuldisp = #fromsldisp
600fAC                   eval      wupulitem = #fromslitem
600fAC                   eval      wupullcns = #fromToLcns
600fAC                   eval      wupulolcns = #fromOLcns
CBIeAC                   eval      wupulvfy   = $saFrmEmpty
600hA
600hAC                   eval      wuUsrWhdp = $slwhdp
600hAC                   eval      wuUsrDisp = $sldisp
600hAC                   eval      wuNewItem = w1itm
600hA
600hAC                   eval      wuRemQty1 = w1qt01
600hAC                   eval      wuRemQty2 = w1qt02
600hAC                   eval      wuRemQty3 = w1qt03
600hA
720aDC***                eval      wuPullCns = $toutlic#
600hAC                   eval      wuUsrLcns = $tinlic#
600eAC*
600fAC                   eval      wuRecType = wkType
600fAC                   eval      wuaddts  = currstampsys
600fAC                   eval      wuadduc  = currstampuc
600fAC                   eval      wuaddpgm = #pgm
600fAC                   eval      wuaddemp = #emp#
600fAC                   eval      wuaddeusr = #curruser
600fAC                   eval      wuaddjusr = #user
600fAC                   eval      wuaddjob = #job
600fAC                   eval      wuaddnbr = #jobnbr
600fAc*
600fAC                   write     wuRec

     C                   endsr
600eA
600eA*----------------------------------------------------------------
600eA*  zzwrkdel   Delete work file record
600eA*----------------------------------------------------------------
600eA
600eAC     zzwrkdel      begsr

600fDC*    wktkey        chain(e)  worktfr

600fDC*                  delete    wktrec

600fAC     keyUsr3a      chain(e)  workusr3
600fAC                   delete    wuRec

     C                   endsr
600eA
600eA*----------------------------------------------------------------
600eA*  zzwrkinz   Delete existing work records for user.
600eA*             Don't try to put anything back.
600eA*----------------------------------------------------------------
600eA
600eAC     zzwrkinz      begsr
     *
600fDC*    wktkeyu       setll     worktfr
600fAC     keyUsr3b      setll     workUsr3
     C                   dow       forever = forever
600fDC*    wktkeyu       reade     worktfr
600fAC     keyUsr3b      reade     workUsr3
600fDC*                  if        %eof(worktfr)
600fAC                   if        %eof(workUsr3)
     C                   leave
     C                   endif
600fDC*                  delete    wktrec
600fAC                   delete    wuRec
     C                   enddo

     C                   endsr
600eA
600eA*----------------------------------------------------------------
600eA*  zzwrkupd   Update work file record
600eA*----------------------------------------------------------------
600eA
600eAC     zzwrkupd      begsr

600fDC*    wktkey        chain(e)  worktfr

600fDC*                  eval      wkusrwhdp = $slwhdp
600fDC*                  eval      wkusrdisp = $sldisp
600fDC*                  eval      wknewitem = w1itm

600fDC*                  eval      wkremqty1 = w1qt01
600fDC*                  eval      wkremqty2 = w1qt02
600fDC*                  eval      wkremqty3 = w1qt03

600fDC*                  eval      wkpullcns = $toutlic#
600fDC*                  eval      wkusrlcns = $tinlic#

600fDC*                  update    wktrec

600fAC     keyUsr3a      chain(e)  workUsr3

600fAC                   eval      wuUsrWhdp = $slwhdp
600fAC                   eval      wuUsrDisp = $sldisp
600fAC                   eval      wuNewItem = w1itm

600fAC                   eval      wuRemQty1 = w1qt01
600fAC                   eval      wuRemQty2 = w1qt02
600fAC                   eval      wuRemQty3 = w1qt03

600fAC                   eval      wuPullCns = $toutlic#
600fAC                   eval      wuUsrLcns = $tinlic#

600fAC                   update    wuRec
     C                   endsr

500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------
500cA*                     DRI SUBROUTINES
500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------

500cA*----------------------------------------------------------------
500cA*  clr$item  Clear $item data structure fields
500cA*----------------------------------------------------------------
500cA
500cAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600eAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  clr$slot  Clear $slot data structure fields
500cA*----------------------------------------------------------------
500cA
500cAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600eAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600dAC                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

500cA*----------------------------------------------------------------
500cA*  clr$slotdef  Clear $slotdef data structure fields
500cA*----------------------------------------------------------------
500cA
500cAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
500cA
500cA*----------------------------------------------------------------
500cA*  zzzdriclose   Close any open files or programs.
500cA*----------------------------------------------------------------
500cA
500cAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      zmsflag = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

     C                   endsr
500cA
500cA*----------------------------------------------------------------
500cA*  zzzdricop  Call DRICOP
500cA*----------------------------------------------------------------
500cA
500cAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600eAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600eAC                             or $dricommand = '*SLOT'
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
640fMC*                  eval      errmsg    = 'Error occured on call to '
640fMC                   eval      errmsg    = 'Error occurred on call to '
     C                                       + 'DRICOP'
     C                                       + '/' + %trim($drisubcmd)
     C                                       + ' from ' + #prog
     C                   if        zmsflag
     C                   exsr      zm0105s
     C                   else
     C                   exsr      zm0105
     C                   endif

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
     C                   if        zmsflag
     C                   exsr      zm0001s
     C                   else
     C                   exsr      zm0001
     C***                exsr      zzerrind
     C                   endif

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600eAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
     C                   endsl

     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------
500cA*  License Plate Tracking Routines
500cA*----------------------------------------------------------------
500cA*----------------------------------------------------------------

500cA*----------------------------------------------------------------
500cA*  ZZZCLR$LT210  -  Clear LT210 parameters.
500cA*----------------------------------------------------------------
500cA
500cAC     ZZZCLR$LT210  begsr

     C                   clear                   $tcmd
     C                   clear                   $tprogram
     C                   clear                   $ttype
     C                   clear                   $thead
     C                   clear                   $twhse
     C                   clear                   $titem
     C                   clear                   $titemdsc
     C                   clear                   $twhdp
     C                   clear                   $tslot
     C                   clear                   $tslotpos
     C                   clear                   $templ#
     C                   clear                   $ttran#
     C                   clear                   $tlic#
     C                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
500jAC                   clear                   $tnorm1
500jAC                   clear                   $tnorm2
500jAC                   clear                   $tnorm3
     C                   clear                   $tpartial
     C                   clear                   $tpulled
     C                   clear                   $tinslot
     C                   clear                   $tsamepos
     C                   clear                   $tdiffpos
     C                   clear                   $tpsplit
     C                   clear                   $tinlic#
     C                   clear                   $toutlic#
     C                   clear                   $tnexttask
     C                   clear                   $treturn
     C                   clear                   $terrmsg
     C                   clear                   $tmsgid
720dAC                   clear                   $ttoslot
720dAC                   clear                   $tpartime

     C                   endsr

500cA*----------------------------------------------------------------
500cA*  ZZZCALL$LT210  -  Call LT210 program.
500cA*----------------------------------------------------------------
500cA
500cAC     ZZZCALL$LT210 begsr

700jA* if a zero transfer, then not license required.
700jAC                   if        allowZero = 'Y'
700jAC                   eval      $treturn = '*OK'
700jAc                   goto      endlt210
700jAc                   endif
700jA*
     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'TFR'         $ttype
     C                   parm      'Transfer'    $thead
     C                   parm                    $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      #emp#         $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
     C                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
500jAC                   parm                    $tnorm1
500jAC                   parm                    $tnorm2
500jAC                   parm                    $tnorm3
     C                   parm                    $tpartial
     C                   parm                    $tpulled
     C                   parm                    $tinslot
     C                   parm                    $tsamepos
     C                   parm                    $tdiffpos
     C                   parm                    $tpsplit
     C                   parm                    $tinlic#
     C                   parm                    $toutlic#
     C                   parm                    $tnexttask
     C                   parm                    $treturn
     C                   parm                    $terrmsg
     C                   parm                    $tmsgid
720dAC                   parm                    $ttoslot
720dAC                   parm                    $tpartime

700jAC     endlt210      TAG
     C                   endsr

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Adjustment Type
Transfer Quantity
Verify Zero
Adj not completed: wrong Dept or non-existing Slot
Not authorized to use F-Key function F21.
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
