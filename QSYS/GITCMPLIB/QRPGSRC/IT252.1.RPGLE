      /copy *libl/qcopysrc,hspecs
600fAH dftactgrp(*NO) actgrp(*NEW)
600dA*----------------------------------------------------------------
600dA*  Multilingual Verision
600dA*  Every screen and message has a corresponding Spanish version.
600dA*  Any changes must be made to both languages.
600dA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 1993 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT252  RF Inventory transfer - Change
     *  21 December, 1999
     *  Roxanne Harrison
     *
     *----------------------------------------------------------------
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
     *      - Major revision to use virtual slots.                    d
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
     *      - Enable F20 on screen 1.
     *      - Adjust warehouse qty if item number changed.
414aA*    06/29/00  DAS  4.14a
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
414gA*    06/22/00  DAS  4.14g
     *      - Added APICVTSLT to ZZCHK2 routine.                      d
414hA*    10/25/00  RRH  4.14g
     *      - Don't lock VSLOT records in ZZCKSL.
     *
415 A*    12/06/00  HNK  4.15
     *      - Create adj records when item number is changed.
415aA*    12/19/00  HNK  4.15a
     *      - Correct key for ITEMMSC file.
415bA*    05/03/01  MLB  4.15b
     *      - Revised program to check designation of To-slot.
415cA*    05/03/01  MLB  4.15c
     *      - Revised routine ZZCRTL to create label records for
     *        each qty being transferred.
415dA*    05/04/01  MLB  4.15d
     *      - Revised program to check quantity in slot before
     *        updating expiration date, entered date. When updating
     *        expiration dates with qty in the slot, the oldest
     *        date will take precedence. If slot is empty, then date
     *        from From slot will be updated.
415eA*    05/30/01  MLB  4.15e
     *      - Revised routine SC2 to loop around if error occurs.
     *      - Revised routine ZZCLSE to send error to user if not
     *        able to close the the transfer transaction.
     *      - Revised routine ZZABRT to subtract the transfer qty
     *        from the receive bucket of the To Slot.
415fA*    06/04/01  MLB  4.15f
     *      - Revised routine ZZCLSE to pass warehouse to PT132.
     *
415gA*    05/16/01  DAS  4.15g
     *      - Created a 16-line version of SCREEN1 named SCREEN61.
     *      - Add special message screens for 16-line display.
     *      - Added call to program to get screen size being used.
     *      - Revised to initialize PTRDTE in ZZIDLE routine.
415hA*    07/09/01  MLB  4.15h
     *      - Revised routine ZZUPD2 to seton flag when To Slot has
     *        updated.
     *      - Revised ZZABRT to only update To Slot when it was updated
     *        in routine ZZUPD2.
     *      - Revised SCR02I, ZZINZ2 to initialize flag TOSLUP.
     *
416 A*    09/29/01  MLB  4.16
     *      - Revised routine ZZCKNS to set off NEWVS each time
     *        routine is executed.
416aA*    12/04/01  MLB  4.16a
     *      - Revised program to add support for veryifying slots
     *        if the transfer will leave the slot at zero.
416bA*    12/06/01  MLB  4.16b
     *      - Added file PIRTRAN1.
     *      - Revised ZZTASK to first look at PIRTRAN1 for a status
     *        '2' record. This will save reading through every record
     *        for the employee.
416cA*    12/21/01  MLB  4.16c
     *      - Revised routine ZZVFY to load key fields.
     *        Changed key fields on key list SVFKEY.
     *
416eA*    01/31/02  DAS  4.16e
     *      - Added external data structure $SLOT.
     *      - Added routines ZZZS2D, ZZZCOP, ZZZISF, ZZZFS1, ZZZFS2
     *
416fA*    01/30/02  HNK  4.16f
     *      - Use KEYIT1 key for PIRITEM file and use TOWHDP to create
     *        second label record.
     *
416gA*    02/14/02  MLB  4.16g
     *      - Revised routine SC3 to run ZZABRT when F3/F12
     *        is selected by the user.
     *      - Added flag ABORT to test in SC3 when abort
     *        transaction should be run.
     *
416hA*    02/21/02  DAS  4.16h
     *      - Revised routine ZZABRT to call interface with @NOUPD.
416iA*    04/04/02  MLB  4.16i
     *      - Fix: Revised SC2 to only run routine ZZABRT when
     *             user hasn't been prompted to verify slot.
     *      - Fix: Revised SCR02I to only turn off TOSLUP when
     *             user hasn't been prompted to verify slot.
416jA*    04/16/02  RH   4.16j
     *      - If new item is type B or S, calculate breakdown quantity
     *      - If item # changes, allow entry of adjustment code.
416kA*    04/19/02  RH   4.16k
     *      - Create "to slot" label rec with status of P.
     *      - Fix - *IN92 was not being set to *OFF after first time
416lA*    05/11/02  HNK/RH 416l
     *      - Fix - Initialize SVUMQ2 to 1 instead of 0.
416mA*    02/20/02  MLB  4.16m
     *      - Revised SCR01I, SCR03I to setoff TOSLUP flag.
416nA*    06/11/02  DAS  4.16n
     *      - Changed A$LIC# from 7.0 to 15.
     *
416oA*    08/03/02  DAS  4.16o
     *      - Revised ZZFIL1 to initialize W1ITM to SLITEM at the
     *        beginning of the routine. It was be set to blanks.
     *        ZZUOM relies on this field. Since it was blank,
     *        *IN94/94 weren't being set correctly.
416pA*    08/05/02  MLB  4.16p
     *      - Fix: Revised ZZCHK1 to convert available quantity into
     *        total available quantity for breakdown1,2 quantity
     *        transfers.
416qA*    09/25/02  RH   4.16q
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
416rA*    10/10/02  RH   4.16r
     *      - FIX - Update held quantities for item.
416sA*    10/10/02  RH   4.16s
     *      - FIX - Was not updating to slot with correct qty when
     *        item changed.
416tA*    12/04/02  MLB  4.16t
     *      - Enh: Added support to program to prevent product from
     *        being transfered to an inactive slot.
416uA*    01/31/03  MLB  4.16u
     *      - Fix: Revised ZZEXCP to use new fields for item and
     *        task being loaded into exception record.
     *        Revised ZZUPD3 to use new fields for qty
     *        being loaded into exception record.
416vA*    04/14/03  DAS  4.16v
     *      - Revised ZZCRTL routined to call DRI with *ADJUSTTFR
     *        for each adjustment record created.
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
     *      - Fix - To Label qty was not correct when item changed.
417cA*    12/31/02  MLB  4.17c
     *      - Enh: Added support for lot/license plate tracking.
417dA*    02/28/03  MLB  4.17d
     *      - Enh: Added support for new Expiration/Entered date update
     *        options.
417eA*    05/29/03  MLB  4.17e
     *      - Enh: Added support for virtual slot options.
417fA*    05/30/03  MLB  4.17f
     *      - Enh: Revised SCR01I to set W3ZERO to blanks.
417gA*    10/14/03  RH   4.17g
     *      - Fix: error in 417b code, not updating TOQTY1 correctly
     *      - Fix: error in 416k code, not setting *IN92 off.
     *
417hA*    11/27/03  DAS  4.17h
     *      - Enh: Added SCREEN4/64 to get license plate.
     *
500 A*    01/12/05  DAS  5.00
     *      - Enh: Converted to ILE.
     *      - Enh: Revised to use LT210.
     *      - Enh: Removed 4.17h change. Now done in LT210.
     *      - Enh: Removed unnecessary LIC* routines.
     *
500aA*    03/30/05  DAS  5.00a
     *      - Created routine zzcancel2 to be called from SC2.
     *      - Moved logic from zzcancel into zzcancel2 that reverses
     *        license history and tfrout.
     *
500bA*    03/31/05  DAS  5.00b
     *      - Revised ZZUPD2 to calculate toqty1.
     *      - Revised LT210 *PUTAWYB to send toqty1 instead of w1qt01.
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
510cA*    08/10/06  RH   5.10c
     *      - Enh: Add pick slot to screen2 and screen62.             .
510dA*    05/12/07  RH   5.10d
     *      - Fix: Do not allow negative quantity to be entered for
     *        any uom quantity.  Was allowing negative bk1 UOM qty
     *        when normal UOM quantity was positive (+1, -44)
     *      - Fix: Message PIR0009 does not exist, should be PIR0109
520 A*    07/10/08  RH   5.20  (not needed in ver 6.00)
     *      - Enh: Converted to ILE, changed IL#XX to ID#XX copysrc
     *        Use KYWHS2 packed field to call RTNSTAT.
520bA*    11/25/08  RH   5.20b  (not needed in ver 6.00)
     *      - Fix: Call UPDSLTDTE with *FIX to correct qty in SLOTDTE
     *        is wrong if slot had negative stock before put away.
520cA*    04/07/09  MLB/RH  5.20c  (not needed in ver 6.00)
     *      - Fix: Revised ZZZERO to loop when chain to SLOT2
     *        encounters a record lock error while removing
     *        virtual slots that are at Zero status.
600 A*    05/17/08  DAS  6.00  P#00045
     *      - License Tracking
600aA*    12/28/07  LMC  6.00A
     *      - This mod is merged from PIRENH510/IT252
     *        01/20/05  MLB  5.00
     *      - Enh: Revised program to add support for Client id
600bA*    01/02/08  LMC  6.00b
     *      - This mod is merged from PIRENH510/IT252
     *        12/28/05  MLB  5.00g
     *      - Enh: Revised program to compute extended catchweight
     *        when a "Change Item Number" transfer is done.
600cA*    01/02/08  LMC  6.00c
     *      - This mod is merged from PIRENH510/IT252
     *        04/13/06  RH   5.00h
     *      - Enh: Add Check "To Slot" qty option.
     *      - Enh: Revised program call SL635 to view slot qty &
     *        create exception if option is Y.
600dA*    01/17/08  LMC  6.00d
     *      - This mod is merged from PIRENH510/IT252
     *        05/26/06  JCJ  5.00  500k
     *          - Added Multilingual logic.
     *      - Also deleted some code that is no longer needed
600eA*    11/01/08  DAS  6.00e
     *      - Revised to work with new STG/RCV/USR slots.
     *      - Changed all #user to #curruser.
600fA*    02/23/09  CWM  6.00f
     *      - Revised to use WORKUSR3 instead of WORKTFR.
600gA*    03/03/09  DAS  6.00g
     *      - Added wuPulBase to WORKUSR file.
     *      - Added $slPullLcns, $saPullDisp, $saPullBase to c#slot.
600hA*    03/04/09  DAS  6.00h
     *      - Revised to delay writing work record until zzupd1.
600iA*    05/13/09  DAS  6.00i
     *      - Added $slPullWhdp to c#slot.
600jA*    05/17/09  DAS  6.00j
     *      - Revised to identify returning item to slot it was
     *        pulled from.
600kA*    05/20/09  DAS  6.00k
     *      - Revised zzchk2 to set $saAction appropriately for
     *        %VFYTFICHG.
600lA*    05/22/09  DAS  6.00l
     *      - Changed screen format to IT25201.
     *      - Added F9=OSS to create oss label/slot/lcns to screen 2.
600mA*    05/27/09  DAS  6.00m
     *      - Revised to not allow the scanning of an RCV/STG slot. These
     *        slots are tied to open receiving transaction sot they
     *        need to be handled through the putaway program.
600nA*    06/10/09  DAS  6.00n
     *      - Revised to write $saFrmEmpty to workusr file after
     *        %TFR2USR.
     *      - Revised to use new wupulvfy to determine if 'empty'
     *        screen should be displayed.
     *      - Revised to use %GETCHKVX instead of %GETCHKV. %GETCHKVX
     *        will not count the slot that was sent.
600oA*    06/10/09  DAS  6.00o
     *      - Revised PUTAWYB to use To slot instead of user slot.
610aA*    08/04/09  RH   6.10a
     *      - Renamed screen format to IT25202
     *      - Create 16 X 20 SCREEN71, SCREEN72, SCREEN73
610bA*    08/19/09  RH   6.10b
     *      - Change to use field to display choice Y,N or 1,9.
610cA*    09/10/09  GJA  6.10c
     *      - Fix:  Call to LT210 did not have license populated
530aA*    10/21/09  RH   5.30a
     *      - Renamed screen format to IT25203
     *      - Enh: Add CW to screen if item changed and is CW.
530bA*    11/02/09  RH   5.30b
     *      - Fix: Add code in ZZCHK2 goto ENDCK2 on adj code error
610dA*    12/04/09  DAS  6.10d
     *      - Fix:  When doing a transfer from an USR slot, the qty
     *        entered must match the qty in the USR slot.
610eA*    01/19/10  DAS  6.10e
     *      - Revised to use %TFR2USRR (reverse) when transferring
     *        from a Pick slot and the item is not being changed.
     *        Re: This type of transfer is assumed to be done after
     *        a qty was put into the Pick slot and is now being moved
     *        into an overflow slot. Therefore, we want to take the
     *        license in LIFO (reverse) instead of FIFO.
610f *    05/11/10  GJA  6.10f
     *      - Fix:  Need to make sure that when transfer is from pick
     *        slot that we check status if to slot is a pick.
610gA*    06/07/10  RH/DAS  6.10g
     *      - Added phrase logging.
610hA*    06/09/10  RH  6.10h
     *      - Fix: Change SC2 to always return to SC1 for F3 / F12.
610iA*    11/01/10  DAS  6.10i
     *      - Revised zzfil2 to call LT210 *PUTAWYB. Re: In order to
     *        ask use for a new license plate before scanning the
     *        slot number.
     *      - Revised zzupd2 to use new skipLT210 flag.
640aA*    03/04/11  JCJ  6.40a
     *      - Enh: Added License plate processing.
640bA*    03/21/11  RH   6.40b
     *      - Fix: Set passed in license to current license.
640cA*    04/14/11  DAS  6.40c
     *      - Fix: Revised zzupd2 to do *ZEROVFY after workusr
     *        records are deleted.
     *
640dA*    06/07/11  DAS  6.40d
     *      - Added Eastland change.
     *      - Added #fromslstat and #toslstat.
     *      - Setting new DRISLOT parm $saItmChg.
     *
640eA*    06/08/11  JCJ  6.40d
     *      - Fix:  Added code to ignore status check in 610f mod if
     *        the slot status is 'RP'.
640fA*    06/09/11  JCJ  6.40e
     *      - Fix:  Added code to ignore status check in 610e mod if
     *        multiple pick slots.
640gA*    07/26/11  JCJ  6.40g
     *      - Fix:  Reverse 640f using OPMPCK = 'N', was not updating
     *        status to 'Z' during change pick slot.
640hA*    10/02/11  GJA  6.40h
     *      - Fix:  EVAL statement was wrong when transferring between
     *        picks slots with STK2.
640i *    11/12/12  LMC  6.40i
     *      - Fix:  Condition call to DRISLOT with %setstat for fixed
     *        only. Was causing problem at MJK with PIR getting an
     *        error message, after the transfer was completed.
640jA*    10/08/12  DAS  6.40i (was 640i at Westside)
     *      - Revised zzchk2 to stop user from using a TO slot that
     *        contains a different item.
     *
650aA*    03/01/13  DAS  6.50a
     *      - Revises to save date/time of %TFR2 and use it for the
     *        'from' ITEMADJ record if the item is changed. This is
     *        done so record can be connected back LICLOG record.
650bA*    03/08/13  MLB  6.50b
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650cA*    07/24/13  RH   6.50c
     *      - Enh: Add F8 call IT233 list pick slot for linked items
     *        Change to use IT25204 format member
650dA*    07/30/13  RH   6.50d
     *      - Enh: Add F8 call IT233 to all size screens.
650eA*    12/30/13  RH/LMC 6.50e
     *      - Fix:  Condition error to not display for %setstat when  99
     *        multple pick slots allowed. Was displaying error after
     *        transfer was complete.
650fA*    08/23/13  RH   6.50f
     *      - Enh: Force new license when product is pulled from pick
     *        slot
650gA*    04/01/14  RH     6.50g
     *      - Fix:  Set catch weight flag TOCWGT when transfer for    99
     *        breakdown1 and/or breakdown2 uom
650hA*    06/18/14  KDE  6.50h
     *      - Enh: changed to create virtual pick slot for on demand  99
     *        repack items
650iA*    12/05/14  LMC  6.50i
     *      - Enh: When item is changed to a SSB item, add logic
     *        to replace that item information with the case item#
650jA*    03/18/15  RH   6.50j
     *      - Enh: If transfer is to slot with different status,
     *        display warning.
650kA*    07/22/14  KDE  6.50k
     *      - Enh: changed to create virtual slot for production      99
     *        WIP and LIN slots when to slot does not exist
700aA*    03/25/15  LMC  7.00a
     *      - Enh: Added ITEMCHG file.
     *
700bA*    05/05/15  LMC  7.00b
     *      - Display file changed to IT25205
700cA*    07/10/15  RH   7.00c
     *      - Fix: add code to return to SC1 if F12 taken in LT210
     *        in ZZFIL2 before SC2 is displayed.
     *        F12 in LT210 was continuing and displaying Screen2.
700dA*    10/06/15  DAS  7.00d
     *      - Fix: Removed #Yfrom fields. Used #from fields instead.
700eA*    10/06/15  DAS  7.00e
     *      - Enh: Revised to handle zero verification of From Pick
     *        slot when transferring to another Pick slot.
700fA*    12/01/15  KDE  7.00f
     *      - Enh: Revised to allow breakdown entry when entry no
     *        but production slot
700gA*    12/30/15  LMC/RH  7.00g
     *      - Fix: Condition 640J for WestSide only to not allow
     *        different directed put away items to be mixed in slot.
700hA*    01/22/16  RH     7.00h
     *      - Enh: See SBR custom change below.  Allow transfer to    99
     *        OSS using generic license.  Should be base change but   99
     *        currently custom only.                                  99
700iA*    03/03/16  MLB  7.00i
     *      - Fix: Revised 6.50k mod. Revised routine, ZZCHK2 to chk
     *        for w2disp > blanks. Was causing a substring error because
     *        w2disp was blank and nothing to pull in positions 1-3.
700jA*    03/07/16  RH   7.00j
     *      - Enh: Rename IT25205, Add PEND if item has pending qty
700kA*    03/22/16  MLB  7.00k
     *      - Fix: Mod 640j should only execute chkusage if the
     *        item is in a department that is doing directed put away.
700l *    05/25/16  RTR  7.00l
     *      - Enh: Adding *PCKSWAP option for Pick Slot Swap in IT256.
700m *    07/11/16  LMC  7.00m
     *      - Enh: Recompile only - DB change to workoss.
     *
700nA*    07/15/16  LMC  7.00n
     *      - Fix: changed code to set nxtscr = EOJ
     *        if F12 taken in LT210
     *        in ZZFIL2 before SC2 is displayed.
     *        Also added exsr zzcancel so epm data is updated just
     *        like when the user does f12 from screen 1.
     *      - Fix: F12 from Sc2 will also execute the same way
     *        set nxtscr = EOJ
     *        Also added exsr zzcancel so epm data is updated just
     *        like when the user does f12 from screen 1.
700o *    09/20/16  RH   7.00o
     *      - Enh: Change to use IT25207 to allow F10=Exception.
710a *    01/24/17  GJA  7.10a
     *      - Fix: Revised 7.00i mod. Revised routine, ZZCHK2 to chk
     *        for w2disp > blanks. Was still causing a substring error
     *        w2disp was less than 3 positions.
710b *    04/07/17  LMC  7.10b
     *      - Fix: When cancelling out of a transfer on an item with
     *        a pick qty in the slot, the license records were gettingse
     *        corrupted, because we are in fact moving a partial qty. se
     *        But the partial flag was not being set correctly.       se
     *        The available qty to transfer is reduced by the pick qtyse
710cA*    05/10/17  LMC  7.10c
     *      - Revised to not allow the scanning of an RTN slot. These
     *        slots are tied to open return transaction sot they
     *        need to be handled through the putaway program.
710dA*    05/23/17  LMC  7.10d
     *      - Revised for outside storage, added new print field.
     *        changed display file to IT25208.
     *        Set new w9prt to N as default.
     *        This will allow clients to transfer existing license
     *        to outside storage and use existing license if they
     *        don't choose to print a special OSS license.
710eA*    06/20/17  NLK  7.10e
     *      - ENH: Don't allow transfer if From and To Slots are the
     *        same, selector accidently scanned same slot on transfer.
710f *    09/01/17  KDE  7.10f
     *      - Fix: Create Repack RPK slot when not available for To Slot
720 A*    03/26/18  KDE  7.20
     *      - Add F11 to scroll through available pick slots scrn2
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
720eA*    12/21/18  KDE  7.20e
     *      - Correct breakdown field name
730aA*    09/24/19  LMC  7.30a
     *      - Revised to not allow the scanning of an RWO slot. These
     *        slots are tied to open receipts with no PO transaction
     *        so they need to be handled through the putaway program.
740aA*    05/12/20  DAS  7.40a
     *      - Added whs-to-whs checks
     *      - Added DRISLOT %GET after %VFYTFICHG in ZZCHK2 in order
     *        to get the information for the #TO fields like #TOSLAISL
740bA*    07/03/20  MLB  7.40b  ZD#2125
     *      - Enh: Changed @PRTPG to BFCPRTLBL from PRTLBL due to
     *        conflict with TL Ashford pgm of the same name.
740cA*    08/04/20  RH   7.40c
     *      - Enh: Add F4 look up for valid Change item
750a *    05/12/21  RTR  7.50a
     *      - Enh: Changed to not call SL635 for *PCKSWAP
750bA *    09/11/19  NLK    (7.30b in IT352)
      *      - Fix:  Changed zzcancel2 to save slot status, so that it
      *        remains persistent in pgm DRISLOT, if we cancel out of
      *        a transfer.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Customized Distribution
CDIa *    01/19/07  RH   CDIa
     *      - Custom to not check for missing tie/hi.
      *----------------------------------------------------------------
     *  Client Custom Revisions: City Wholesale
CWa  *    12/12/07  LMC  CWa
     *      - Revised to by pass tie/high edit.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Coastal Sunbelt
CSPa *    05/27/10  GJA  CSPa
     *      - Default CI change item to code 10.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Eastland
     *
EFCa *    03/03/11  GJA  EFCa
     *      - Fill external storage window default values
EFCb *    06/07/11  DAS  ECFb
     *      - Revised to put the slot status code at the end of
     *        the iamemo field.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Halsey
HSYaA*    09/17/09  RH   HSYa
     *      - Default CI change item to code 15.
HSYbA*    11/05/09  RH   HSYb
     *      - Display pick slot on SC1
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    08/04/09  RH   SVLa
     *      - Enh: Use Custom 16 X 20 screens for RF 16 line.
SVLbA*    08/19/09  RH   SVLb
     *      - Enh: Use 1,9 for Y,N because of handheld RF keys.
SVLcA*    11/02/09  RH   SVLc    (applied by GJA)
     *      - Enh: Default adjust code to *blanks for change item so
     *      user can enter specific code for change item.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Graves Menu Maker
GMMa *    09/10/12  RH   GMMa
     *      - Default CI change item to code 13.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
     *
SGCaA*    05/22/09  DAS  SGCa
     *      - Enh:  If willow default to LP7, if Kansas default to LP8
SGCbA*    02/20/13  JCJ  SGCb
     *      - Enh:  Changed label set name from sato to zebra format
SGCcA*    09/25/20  RH   SGCc
     *      - Enh:  Do not allow transfer to create virtual pick slot
     *        RC200 RF Put away has same mod.
SGCdA*    09/28/20  RH   SGCd
     *      - Enh:  Allow virtual pick slots for DRY aisle DR, level 2
     *        location 200 to 246 per Adam.  (Fellers product slots)
SGCeA*    09/30/20  RH   SGCe
     *      - Enh:  Allow virtual pick slots for CLR aisle CB, CN, CE
     *        limited locations per Ben M email 9-30
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: EG Forrest
     *
EGFa *    01/11/10  RH   EGFa
     *      - Default CI change item to code 'X '
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Greenleaf Produce
     *
GLPaA*    04/09/13  LMC  GLPA
     *      - Enh: Use 1,9 for Y,N because of handheld RF keys.
SVLbA*    08  same as saval mod SLVb.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Chefs warehouse
     *
DRYaA*    04/23/16  JCJ  DRYa
     *      - Enh: hardcode label set name for chef's
DRYbA*    11/16/20  JCJ  DRYb
     *      - Custom to not check for missing tie/hi.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Food Pro
     *
FPR A*    04/21/15  MLB  FPR
     *      - Revised pgm to use 5.30a mod that added support for
     *        capture of catchweight being transferred. Needed to send
     *        back to Retalix.
FPRaA*    05/05/15  LMC  FPRa
     *      - Enh: Protect normal uom qty when normal UOM = MP.
FPRcA*    05/07/15  RH   FPRc
     *      - Enh: Default adjust code to *blanks for change item so
     *      user can enter specific code for change item.
FPRdA*    03/07/16  RH   FPRd
     *      - Enh: Disable slot status change warning per Eli email
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney
CBIa *    05/08/17  NLK  CBIa
     *      - Fix: transfer of an item with different status is
     *        beign bypassed.  Don't allow dfchk to be changed back.
     *----------------------------------------------------------------
     *  Client Custom Revisions: S.Bertram
     *
SBRa *    01/22/16  RH   SBRa
     *      - Enh: Allow transfer to OSS using generic license, not   .
     *        system generated/printed.                               .
SBRb *    02/03/17  LMC  SBRb
     *      - Enh: Require new license on all transfers from OSS.     .
     *----------------------------------------------------------------
     *  Client Custom Revisions: A&D Foods
ADFaA*    05/01/17  RH   ADFa
     *      - Allow transfer to OSS, add to SBRa mod.
ADFbA*    06/02/17  RH   ADFb
     *      - Add ADF to SBRb mod to force license from OSS slot.
     *----------------------------------------------------------------
MQSa *    03/19/18  RTR  MQSa
     *      - Enh: Added Marques to SBRa mod to allow transfer offsite.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Foods Galore
FGLa *    08/22/16  RH   FGLa
     *      - Enh: Add to SBRa & SBRb mods for OSS transfer.          .
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
     *  Client Custom Revisions: Global Imports
GIGa *    11/11/21  RH   GIGa
     *      - Custom to not check for missing tie/hi.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Southwest Traders
SWTa *    01/11/22  RH   SWTa
     *      - Custom to not check for missing tie/hi.
     *----------------------------------------------------------------
     *  Client Custom Revisions: Earl's Organic Produce
EOPa *    02/15/22  LMC  EOPa
     *      - Custom to not check for missing tie/hi.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Customized Distribution
SFP A*    08/28/22  MLB/RH  SFP
     *      - Custom to not check for missing tie/hi.
     *
      *----------------------------------------------------------------
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
600fA
600fAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
600lDF*t252fm   cf   e             workstn
610aDF*t25201   cf   e             workstn
610aMF*t25202   cf   e             workstn
530aMF*t25203   cf   e             workstn
700bDF*it25204   cf   e             workstn
700jDF*it25205   cf   e             workstn
700oDF*it25206   cf   e             workstn
710dDF*it25207   cf   e             workstn
720 DF*it25208   cf   e             workstn
740cDF*it25209   cf   e             workstn
740cMFit25210   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
     Fwarehs    if   e           k disk
     Fwhdept    if   e           k disk
     Fslotstat  if   e           k disk
650hAFkititem   if   e           k disk
     Funmesr    if   e           k disk
     Foptiond   if   e           k disk
414cAFoptions   if   e           k disk
600fDF* worktfr   uf a e           k disk
600fAFworkUsr3  uf a e           k disk
413EAFLabel     o  a e           k disk
415 AFitemadj   o  a e           k disk
416aAFitmexcp   o    e           k disk
600lAFworkoss   uf a e           k disk
600lAFworkoss1  uf   e           k disk
600lAF                                     rename(worec:worec1)
650kAFplined    if   e           k disk
700aAFitemchg   if a e           k disk
SGCcAFslot2     if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
412 AD a2              s              1    dim(2)
412 AD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
     D hnd             s              2    dim(702)
600lDD*desc            s             50    dim(5) ctdata perrcd(1)
600lMD desc            s             50    dim(6) ctdata perrcd(1)
     D ltr             s              1    dim(27) ctdata perrcd(27)
650kAD prdslt          S              3    dim(100)
600lDD*descsp          s             50    dim(5) ctdata perrcd(1)
600lMD descsp          s             50    dim(6) ctdata perrcd(1)
600aA*----------------------------------------------------------------
600aA*  Customer id
600aA*
600aAD @getcl          c                   const('GETCLIENT')
600aA*
600aA /COPY QCOPYSRC,ID#BIRITE
SGCaA /COPY QCOPYSRC,ID#SGC
SVLaA /COPY QCOPYSRC,ID#SAVAL
HSYaA /COPY QCOPYSRC,ID#HALSEY
EGFaA /COPY QCOPYSRC,ID#EGF
CWa A /copy qcopysrc,id#citywho
CDIaA /copy qcopysrc,id#cdi
CSPaA /copy qcopysrc,id#coastal
EFCaA /COPY QCOPYSRC,Id#Eastlan
GLPaA /COPY QCOPYSRC,ID#GLP
GMMaA /COPY QCOPYSRC,ID#GMM
DRYaA /copy qcopysrc,id#dairyla
FPRaA /copy qcopysrC,id#fpr
700gA /copy qcopysrC,id#westsid
SBRaA /COPY QCOPYSRC,ID#SBR
ADFaA /copy qcopysrC,id#adf
FGLaA /COPY QCOPYSRC,ID#fgl
MQSaA /COPY QCOPYSRC,ID#mqs
CBIaA /copy qcopysrc,id#cheney
MRTaA /copy qcopysrc,id#mrt
KFSaA /copy qcopysrc,id#kfs
HPCaA /copy qcopysrc,id#hpc
GIGaA /copy qcopysrc,id#gig
SWTaA /copy qcopysrc,id#swt
EOPaA /copy qcopysrc,id#eop
SFP A /copy qcopysrc,id#sfp
500 D *----------------------------------------------------------------
500 D*  External data structure for Dakota Realtime Interface.
500 D*
500 DD*$slot         e ds                  extname(c#slotdds)
500 DD*@noupd          c                   const('*NOUPDATE*')
500 DD*@vfysl          c                   const('%SET2VFY')

500 A*----------------------------------------------------------------
500 A*  DRI parameters
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#DRIPARMS
500 A
500 A*----------------------------------------------------------------
500 A*  Data Formats
500 A*----------------------------------------------------------------
500 A
500 A /COPY *libl/qcopysrc,C#ITEM
500 A /COPY *libl/qcopysrc,C#SLOT
500 A /COPY *libl/qcopysrc,C#SLOTDEF
500 AD saveVer#        s                   like($slver#)
500 AD save$slot       s                   like($slot)

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
640aAD  $plcns                54     68

500 A*----------------------------------------------------------------
500 A*  LT210 parameters
500 A*----------------------------------------------------------------

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
720dAD  $tuci          s            100
640jAD $uDiffItem      s              1
640jAD $uCube          s              9  3
640jAD $uDisp          s             12
640jAD $uItem          s             15
640jAD $uPieces        s              5  0
640jAD $uRecs          s              3  0
640jAD $uRsrv          s              1
640jAD $uWhdp          s              5
640jAD $uWhse          s              3  0
640jAD $uEntDte        s              8  0
640jAD $uExpDte        s              8  0
640jAD $uDiffEntd      s              1
640jAD $uDiffExpd      s              1
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
610gA*----------------------------------------------------------------
610gA*  Phrase Variables
610gA*----------------------------------------------------------------
610gA
610gA /COPY *libl/qcopysrc,c#phrasvar
610gAD  currFile       s             10
610gAD  currRoutine    s             20
610gAD  lastnxtscr     s              3
610g D  stackCount     s              3  0
610g D  aRoutine       s             20    dim(30)
610gA
610gA*----------------------------------------------------------------
610gA*  Phrases
610gA*----------------------------------------------------------------
610gA
610gA /COPY *libl/qcopysrc,c#phrases

600fA*----------------------------------------------------------------
600fA* Function prototypes.
600fA*----------------------------------------------------------------
600fA
600fA /copy qcopysrc,p.bfcdteti
740aA /copy qcopysrc,p.wwtfr

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $aerm           ds
     D  xaerm                  1     60
     D  $amsg                  1      4
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4
417dA*----------------------------------------------------------------
417dA*  *DATEOPT  -  Expiration/Entered date options
417dA*----------------------------------------------------------------
417dA*
417dA* Fields
417dA*
417dA*    OPLTDN  -  Letdown transactions.  <1-3>
417dA*    OPODRP  -  On-demand replenishment transactions. <1-3>
417dA*    OPSLTF  -  Slot transfer transactions. <1-3>
417dA*    OPPARC  -  Product put-away - Receiving transactions. <1-3>
417dA*    OPPART  -  Product put-away - Returns transactions. <1-3>
417dA*
417dA*     Destination options:
417dA*       1=Use From Slot date.
417dA*       2=Use oldest date.
417dA*       3=Use From Slot date if To Slot available qty is zero.
417dA*
417dA*     Note: For Receiving/Returns, substitute date captured during
417dA*           receiving/returns processing for From Slot date.
417dA*
417dA* Data structure
417dA*
417dAD opdta1          ds
417dAD  opltdn                 1      1
417dAD  opodrp                 2      2
417dAD  opsltf                 3      3
417dAD  opparc                 4      4
417dAD  oppart                 5      5
417dAD  opendd               117    117
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
417eA*----------------------------------------------------------------
417eA*  *VIRTUAL  -  Virtual Slot options
417eA*----------------------------------------------------------------
417eA*
417eA* Fields
417eA*
417eA*    OPVALL  -  Always create Virtual slot. (Y/N)
417eA*    OPVPCK  -  Allow Virtual pick slots to be created.  (Y/N)
417eA*    OPVSLT  -  Create Virtual slot for item when base slot and
417eA*               corresponding Virtual slot(s) item(s) are different.
417eA*               Always Yes.
417eA*    OPVEXP  -  Create Virtual slot when item exists and
417eA*               expiration date is different.  (Y/N)
417eA*    OPVEND  -  Create Virtual slot when item exists and
417eA*               entered date is different.  (Y/N)
417eA*    OPVSAM  -  Merge product when entered/expiration dates
417eA*               are the same.  (Y/N)
417eA*    OPVEDF  -  Merge product when entered dates are different and
417eA*               expiration dates are the same.  (Y/N)
417eA*
417eA* Data structure
417eA*
417eAD opdtav          ds
417eAD  opvall                 1      1
417eAD  opvpck                 2      2
417eAD  opvslt                 3      3
417eAD  opvexp                 4      4
417eAD  opvend                 5      5
417eAD  opvsam                 6      6
417eAD  opvedf                 7      7
417eAD  optenv               117    117
417eA*
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
600cA*----------------------------------------------------------------
600cA*  *REPLEN  -  Replenishment options.
600cA*----------------------------------------------------------------
600cA*
600cA* Fields
600cA*
600cA*    OPRPLB  -  Replenishment basis (*AVGQTY, *ORDQTY).
600cA*    OPOQRP  -  Order qty replenishment (Y/N).
600cA*    OPRPEX  -  Allow replenishment on expired items.
600cA*               1=Allow, 2=Don't allow, 3=Warn
600cA*    OPRPFI  -  Allow replenishments out of FIFO order.
600cA*               1=Allow, 3=Warn
600cA*    OPLMTS  -  Limit Specific Slot replenishment program to
600cA*               to display only one overflow location at a
600cA*               time. (Y/N)
600cA*    OPCQTY  -  Check quantity of "To Slot" during replenish/
600cA*               letdown/transfer. (Y/N)
600cA*
600cA* Data structure
600cA*
600cAD opdta3          ds
600cAD  oprplb                 1      8
600cAD  opoqrp                 9      9
600cAD  oprpex                10     10
600cAD  oprpfi                11     11
600cAD  oplmts                12     12
600cAD  opcqty                13     13
600cAD  opcend               117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
     D @fmtit          c                   const('FRMTIT')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjtd          c                   const('ADJTSKDET')
     D @addtr          c                   const('ADDSTDTRN')
     D @llptr          c                   const('UPDLLPTRK')
740bAD @prtpg          c                   const('BFCPRTLBL')
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
     D  $litem                27     41
     D  $ldisp                42     53
     D  $ldesg                54     58
     D  $lstat                59     60
     D  $lsdef                61     62
     D  $lactv                63     64
     *
413eAD  $litm                 22     36
740cAD  $ltitm                37     51
     *
413EAD  $lrte                 22     26
413EAD  $lpo                  27     35
413EAD  $ltrn#                36     42  0
415bA*
415bAD  $ldsg                 19     23
415bAD  $ltyp                 24     24
     *
500 AD  $lwhse2               19     21  0
500 AD  $lwhdp2               22     26
500 AD  $ldisp2               27     38
500 AD  $litem2               39     53
417cA*----------------------------------------------------------------
417cA*
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
414gA*----------------------------------------------------------------
414gA*  API programs
414gA*
     D @apics          c                   const('APICVTSLT ')
417cA*
417cA*----------------------------------------------------------------
417cA*  Working fields.
417cA*
417cAD                 ds
417cAD  lottrk                 1      4
417cAD  lictrk                 5      8
417cAD  llptp1                 9     16
417cAD  llptp2                17     24
417cAD  llptp3                25     32
417cAD  savllp                33     47
417cAD  newllp                48     62
600dDD*llp01           c                   const('Scan lic nbr:     ')
600dDD*llp02           c                   const('Scan lot nbr:     ')
600dDD*llp03           c                   const('Scan new lic#:    ')
600dDD*llp04           c                   const('Scan new lot#:    ')
600dDD*llp05           c                   const('Original lic#:    ')
600dDD*llp06           c                   const('Original lot#:    ')
417cA*
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
650jAD  erfsts                 1      2
650jAD  ertsts                 3      4
414cA*
414cAD  ernpck                 1      3p 0
414cAD  erapck                 4      6p 0
415bA*
415bAD  eritdp                 1      5
415bAD  erslds                 6     17
415bAD  ersldp                18     22
415bAD  eritsc                23     23
415bAD  erslsc                24     24
     *
416eAD  erdmsg                 1     60
416eAD  erdrtn                61     70
416eAD  erdcmd                71     80
416eAD  erdsub                81     90
416pA*----------------------------------------------------------------
416pA*  Working variables.
416pA*
416pAD  bkdwn1                 1      4    inz('*NO ')
416pAD  bkdwn2                 5      8    inz('*NO ')
416pAD  avlqty                 9     17  0 inz(0)
416pAD  chkqty                18     26  0 inz(0)
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
600dAD #msgsp          c                   const('PIRMSGFSP ')
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

500 AD #frombasesldsp  s                   like($sldisp)

500 AD #fromslwhdp     s                   like($slwhdp)
500 AD #fromslstyp     s                   like($slstyp)
500 AD #fromsldisp     s                   like($sldisp)
500 AD #fromslaisl     s                   like($slaisl)
500 AD #fromslloc      s                   like($slloc)
500 AD #fromslpseq     s                   like($slpseq)
500 AD #fromslrlvl     s                   like($slrlvl)
500 AD #fromslhand     s                   like($slhand)
640dAD #fromslstat     s                   like($slstat)
500 AD #fromslrsrv     s                   like($slrsrv)
500 AD #fromslentd     s                   like($slentd)
500 AD #fromslexpd     s                   like($slexpd)
500 AD #fromslslfd     s                   like($slslfd)
500 AD #fromslactv     s                   like($slactv)
500 AD #fromslbld      s                   like($slbld)
500 AD #fromslpick     s                   like($slpick)
500 AD #fromslitem     s                   like($slitem)
500 AD #fromslsdef     s                   like($slsdef)
500 AD #fromslpos      s                   like($sdpos)
500 AD #fromslvirt     s                   like($sfvirt)
500 AD #fromslstk1     s                   like($slstk1)
500 AD #fromslstk2     s                   like($slstk2)
640hDD*#fromslstk3     s                   like($slstk2)
640hMD #fromslstk3     s                   like($slstk3)
500 AD #fromslalc1     s                   like($slalc1)
500 AD #fromslalc2     s                   like($slalc2)
500 AD #fromslalc3     s                   like($slalc3)
500 AD #fromsltfr1     s                   like($sltfr1)
500 AD #fromsltfr2     s                   like($sltfr2)
500 AD #fromsltfr3     s                   like($sltfr3)
500 AD #fromslpck1     s                   like($slpck1)
500 AD #fromslpck2     s                   like($slpck2)
500 AD #fromslpck3     s                   like($slpck3)
500 AD #fromslrcv1     s                   like($slrcv1)
500 AD #fromslrcv2     s                   like($slrcv2)
500 AD #fromslrcv3     s                   like($slrcv3)
500 AD #fromslphy1     s                   like($slphy1)
500 AD #fromslphy2     s                   like($slphy2)
500 AD #fromslphy3     s                   like($slphy3)
500 AD #fromslavl1     s                   like($slavl1)
500 AD #fromslavl2     s                   like($slavl2)
500 AD #fromslavl3     s                   like($slavl3)
600eAD #fromToLcns     s                   like($saToLcns)
600eAD #fromToPos      s                   like($saToPos)
600eAD #fromOLcns      s                   like($saOLcns)

500 AD #toslwhdp       s                   like($slwhdp)
500 AD #tosldisp       s                   like($sldisp)
500 AD #tosldispnew    s                   like($sldisp)
500 AD #toslaisl       s                   like($slaisl)
500 AD #toslloc        s                   like($slloc)
500 AD #toslrlvl       s                   like($slrlvl)
500 AD #toslhand       s                   like($slhand)
640dAD #toslstat       s                   like($slstat)
500 AD #toslpick       s                   like($slpick)
500 AD #toslitem       s                   like($slitem)
500 AD #toslsdef       s                   like($slsdef)

500 AD #fromititem     s                   like($ititem)
500 AD #fromittype     s                   like($ittype)
500 AD #fromitdesc     s                   like($itdesc)
500 AD #fromitpdsc     s                   like($itpdsc)
500 AD #fromithead     s             70
500 AD #fromitwhdp     s                   like($itwhdp)
500 AD #fromitstyp     s                   like($itstyp)
500 AD #fromitdesg     s                   like($itdesg)
500 AD #fromitum1      s                   like($itum1)
500 AD #fromitflg1     s                   like($itflg1)
500 AD #fromitum2      s                   like($itum2)
500 AD #fromitumq2     s                   like($itumq2)
500 AD #fromitflg2     s                   like($itflg2)
500 AD #fromitum3      s                   like($itum3)
500 AD #fromitumq3     s                   like($itumq3)
500 AD #fromitnrpk     s                   like($imnrpk)
500 AD #fromitflgd     s                   like($itflgd)
500 AD #fromitcube     s                   like($itcube)
500 AD #fromitswgt     s                   like($itswgt)
500 AD #fromitcwgt     s                   like($itcwgt)
500 AD #fromitmitem    s                   like($itmitem)
500 AD #fromitsdef     s                   like($idsdef)
500 AD #fromittie      s                   like($idtie)
500 AD #fromithigh     s                   like($idhigh)
600eAD #fromimltrk     s                   like($imltrk)

500 AD #fromssbititem  s                   like($ititem)
500 AD #fromssbittype  s                   like($ittype)
500 AD #fromssbitdesc  s                   like($itdesc)
500 AD #fromssbitpdsc  s                   like($itpdsc)
500 AD #fromssbitwhdp  s                   like($itwhdp)
500 AD #fromssbitstyp  s                   like($itstyp)
500 AD #fromssbitdesg  s                   like($itdesg)
500 AD #fromssbitum1   s                   like($itum1)
500 AD #fromssbitum2   s                   like($itum2)
500 AD #fromssbitumq2  s                   like($itumq2)
500 AD #fromssbitum3   s                   like($itum3)
500 AD #fromssbitumq3  s                   like($itumq3)
600eAD #fromssbimltrk  s                   like($imltrk)

500 AD #newfromititem  s                   like($ititem)
500 AD #newfromittype  s                   like($ittype)
500 AD #newfromitdesc  s                   like($itdesc)
500 AD #newfromitpdsc  s                   like($itpdsc)
500 AD #newfromitwhdp  s                   like($itwhdp)
500 AD #newfromithead  s             70
500 AD #newfromitstyp  s                   like($itstyp)
500 AD #newfromitdesg  s                   like($itdesg)
500 AD #newfromitum1   s                   like($itum1)
500 AD #newfromitflg1  s                   like($itflg1)
500 AD #newfromitum2   s                   like($itum2)
500 AD #newfromitumq2  s                   like($itumq2)
500 AD #newfromitflg2  s                   like($itflg2)
500 AD #newfromitum3   s                   like($itum3)
500 AD #newfromitumq3  s                   like($itumq3)
500 AD #newfromitnrpk  s                   like($imnrpk)
500 AD #newfromitflgd  s                   like($itflgd)
500 AD #newfromitcube  s                   like($itcube)
500 AD #newfromitswgt  s                   like($itswgt)
500 AD #newfromitcwgt  s                   like($itcwgt)
500 AD #newfromitmitm  s                   like($itmitem)
500 AD #newfromitsdef  s                   like($idsdef)
500 AD #newfromittie   s                   like($idtie)
500 AD #newfromithigh  s                   like($idhigh)
600eAD #newfromimltrk  s                   like($imltrk)

500 AD #newssbititem   s                   like($ititem)
500 AD #newssbittype   s                   like($ittype)
500 AD #newssbitdesc   s                   like($itdesc)
500 AD #newssbitpdsc   s                   like($itpdsc)
500 AD #newssbitwhdp   s                   like($itwhdp)
500 AD #newssbitstyp   s                   like($itstyp)
500 AD #newssbitdesg   s                   like($itdesg)
500 AD #newssbitum1    s                   like($itum1)
500 AD #newssbitum2    s                   like($itum2)
500 AD #newssbitumq2   s                   like($itumq2)
500 AD #newssbitum3    s                   like($itum3)
500 AD #newssbitumq3   s                   like($itumq3)
600eAD #newssbimltrk   s                   like($imltrk)

700dDD*#Yfromslwhse    s                   like($slwhse)
700dDD*#Yfromslwhdp    s                   like($slwhdp)
700dDD*#Yfromsldisp    s                   like($sldisp)
700dDD*#Yfromslpick    s                   like($slpick)
700dDD*#Yfromslitem    s                   like($slitem)
700dDD*#Yfromslpos     s                   like($sdpos)
700dDD*#Yfromslstk1    s                   like($slstk1)
700dDD*#Yfromslstk2    s                   like($slstk2)
640hDD*#Yfromslstk3    s                   like($slstk2)
700dDD*#Yfromslstk3    s                   like($slstk3)
700dDD*#Yfromslstat    s                   like($slstat)
610fAD Ypickslot       s               n

     D abort           s              4
     D a58             s             58
     D brkq1           s              5  0
     D bszero          s              1
     D cancel          s              1
650hAD odrslot         s             12
500 DD*chgqt1          s                   like(slstk1)
500 DD*chgqt2          s                   like(slstk2)
500 DD*chgqt3          s                   like(slstk3)
500 DD*ck4err          s              1
500 AD chk4err         s               n
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D curent          s              1
500 AD curlic#         s                   like($tlic#)
500 AD curtrn#         s              7  0
     D curtsk          s              6
     D curtyp          s              1
650jAD dfchk           s              1
     D drierr          s              1
     D dteofl          s              1
     D dteold          s              1
     D e               s              2  0
     D enter           s              5  0
     D eof             s              1
500 MD error           s               n
     D exist           s              1
500 DD*expd            s                   like(slexpd)
600bAD exwgfm          s                   like(iacwta)
500 DD*fintim          s                   like(ptetim)
500 DD*flaghs          s              1
600bAD fmcwgt          s                   like($itcwgt)
     D fmdisp          s                   like($sldisp)
     D fmitem          s             15
     D fmpick          s              1
     D fmqmq2          s              5  0
     D fmtype          s              1
     D fmumq2          s                   like($itumq2)
     D fmwhdp          s              5
500 AD forever         s               n
     D forevr          s              1
     D found           s              1
SGCaAD goodsl          s              1
500 DD*hasvs           s              1
     D help            s              5  0
650kAd hldprdDisp      s             12
     D i               s              2  0
     D itdtyp          s                   like($ltyp)
     D j               s              2  0
     D k               s              3  0
     D kycode          s                   like(opdcod)
500 DD*kydisp          s                   like(lbdisp)
500 DD*kyitem          s                   like($pitem)
500 DD*kystat          s                   like(ptstat)
     D kywhdp          s                   like(lbwhdp)
     D kywhse          s                   like($pwhse)
500 DD*k3pick          s                   like(slpick)
500 DD*k3stat          s                   like(slstat)
500 DD*lftq1           s              5  2
     D lock            s              1
     D msgk            s              4  0
500 DD*nbrpck          s              5  0
500 DD*newqt1          s                   like(slstk1)
500 DD*newqt2          s                   like(slstk2)
500 DD*newqt3          s                   like(slstk3)
     D newtrn          s              4
500 DD*newvs           s              1
500 DD*newwhd          s              5
500 DD*nwstat          s              2
500 DD*nwstk1          s                   like(slstk1)
500 DD*nwstk2          s                   like(slstk2)
500 DD*nwstk3          s                   like(slstk3)
     D nxtscr          s              3
     D odisp           s                   like($sldisp)
600lAD ossDisp         s             12
     D ovrrid          s              1
500 AD partial         s               n
500 DD*phactv          s                   like(slactv)
500 DD*phaisl          s                   like(slaisl)
500 DD*phbld           s                   like(slbld)
500 DD*phdesg          s                   like(sldesg)
500 DD*phdisp          s                   like(sldisp)
500 DD*phhand          s                   like(slhand)
500 DD*phloc           s                   like(slloc)
500 DD*phpseq          s                   like(slpseq)
500 DD*phrlvl          s                   like(slrlvl)
500 DD*phsdef          s                   like(slsdef)
500 DD*phside          s                   like(slside)
500 DD*phslfd          s                   like(slslfd)
500 DD*phstat          s                   like(slstat)
500 DD*phstyp          s                   like(slstyp)
500 DD*phwhdp          s                   like(slwhdp)
500 DD*phwhse          s                   like(slwhse)
650kAD prdtfr          s               n
     D redspl          s              1
     D rolldn          s              5  0
     D rollup          s              5  0
600jAD rtnToOrig       s               n
500 DD*savqt1          s                   like($cqty1)
500 DD*savqt2          s                   like($cqty2)
500 DD*savqt3          s                   like($cqty3)
500 DD*savst           s                   like(slstat)
     D sclear          s              1
610iAD skipLT210       s               n
     D skpslt          s              1
     D sldtyp          s                   like($ltyp)
650kAD sltc            s              3  0
     D ssbflg          s              1
500 AD newssbflg       s              1
500 DD*stdate          s                   like(ptsdte)
500 DD*strtim          s                   like(ptstim)
500 DD*sttime          s                   like(ptstim)
500 DD*svactv          s                   like(slactv)
500 DD*svbld           s                   like(slbld)
500 DD*svcub1          s                   like(ptcube)
500 DD*svcub2          s                   like(ptcube)
500 DD*svcub3          s                   like(ptcube)
500 DD*sventd          s                   like(slentd)
500 DD*svexpd          s                   like(slexpd)
500 DD*svfdis          s                   like(lbdisp)
500 DD*svitem          s                   like(slitem)
500 DD*svpick          s                   like(slpick)
500 DD*svprty          s                   like(slprty)
500 DD*svslfd          s                   like(slslfd)
500 DD*svtlen          s                   like(ptdmin)
500 DD*svtrn#          s                   like(pttrn#)
SGCcAD svaisl          s                   like(slaisl)
SGCcAD svloc           s                   like(slloc)
SGCcAD svrlvl          s                   like(slrlvl)
     D svtrn1          s              7  0
     D svtrn2          s              7  0
     D svtrn3          s              7  0
500 DD*svtype          s                   like($ittype)
500 DD*svumq2          s                   like($itumq2)
500 DD*svwgt1          s                   like(ptswgt)
500 DD*svwgt2          s                   like(ptswgt)
500 DD*svwgt3          s                   like(ptswgt)
500 DD*t#task          s              6
     D tempa2          s              2
650aAD tfr2usrDate     s                   like(iadate)
650aAD tfr2usrTime     s                   like(iatime)
500 AD tfroutflag      s               n
500 DD*timlen          s                   like(ptdmin)
500 DD*tmpbeg          s              4  0
500 DD*tmpend          s              4  0
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
500 DD*ulexpd          s                   like(slexpd)
500 DD*ulstk1          s                   like(slstk1)
500 DD*ulstk2          s                   like(slstk2)
500 DD*ulstk3          s                   like(slstk3)
     D umq2            s              5  0
     D usesc           s              1  0
500 AD verifyzero      s               n
     D vfyslt          s              4
     D vrtslt          s              1
     D warn            s              1
     D whse            s              3  0
650kAd wkaisl          s              3
500 DD*wkcube          s                   like(ptcube)
500 DD*wkpcs           s                   like(ptpcs)
500 DD*wkswgt          s                   like(ptswgt)
500 DD*wotrn#          s                   like(pttrn#)
500 DD*wowhse          s              3
500 DD*w1crew          s                   like(uscrew)
500 DD*w1emp#          s                   like(usemp#)
600 DD*w1qty1          s                   like($cqty1)
600 DD*w1qty2          s                   like($cqty2)
600 DD*w1qty3          s                   like($cqty3)
500 DD*w1shft          s                   like(usshft)
500 DD*w1styp          s                   like(usstyp)
     D w1task          s              6
     D w1whdp          s              5
     D w2qty           s              7
     D w2um1           s              5
     D w2um2           s              5
     D w2um3           s              5
740aAD wwrtn           s             10
740aAD wwmsg           s             99    varying
500 DD*zzedte          s                   like(ptedte)
500 DD*zzetim          s                   like(ptetim)
500 AD zmsflag         s               n
500 DD*zzsdte          s                   like(ptsdte)
500 DD*zzstim          s                   like(ptstim)
600lAD #rcvarea        s              6
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
610gAC                   eval      stackCount = 0
610gAC                   eval      currRoutine = 'main'
610gAC                   exsr      phpgmV1V2V3s

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
     C                   move      'EOJ'         nxtscr
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
416aAC     nxtscr        caseq     '03 '         sc3
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
600lAC                   exsr      zzwodltjob
     C                   exsr      zsclr
500 AC                   exsr      zzzdriclose
610gAC                   exsr      phpgmV1V2V3e
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
610gA*
610gA*   Write tracking phrase of which screen is being displayed.
610gA*
610gAC                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
415gAC                   select
700lAC                   when      $pcmd = '*PCKSWAP'
700lAC                   eval      W1QT01 = $slavl1
700lAC                   eval      W1QT02 = $slavl2
700lAC                   eval      W1QT03 = $slavl3
600dAC                   when      #lline = '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn61sp                             50
610aAC                   when      #lline = '16' and client = saval
610aAC                   exfmt     screen71                             50
415gAC                   when      #lline = '16'
415gAC                   exfmt     screen61                             50
600dAC                   when      #lline <> '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn1sp                              50
415gAC                   other
     C                   exfmt     screen1                              50
415gAC                   endsl
     C                   endif
     *
     C                   if        nxtscr = '02 '
415gAC                   select
600dAC                   when      #lline = '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn62sp                             50
610aAC                   when      #lline = '16' and client = saval
610aAC                   exfmt     screen72                             50
415gAC                   when      #lline = '16'
415gAC                   exfmt     screen62                             50
600dAC                   when      #lline <> '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn2sp                              50
415gAC                   other
     C                   exfmt     screen2                              50
415gAC                   endsl
     C                   endif
416aA*
416aAC                   if        nxtscr = '03 '
416aAC                   select
700lAC                   when      $pcmd = '*PCKSWAP'
700lAC                   eval      W3ZERO = 'Y'
600dAC                   when      #lline = '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn63sp                             50
610aAC                   when      #lline = '16' and client = saval
610aAC                   exfmt     screen73                             50
416aAC                   when      #lline = '16'
416aAC                   exfmt     screen63                             50
600dAC                   when      #lline <> '16'  and  e$lng = 'SP'
600dAC                   exfmt     scrn3sp                              50
416aAC                   other
416aAC                   exfmt     screen3                              50
416aAC                   endsl
416aAC                   endif
610gA*
610gA*   Write tracking phrase of what was pressed.
610gA*
610gAC                   exsr      phV2onV1
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
417cAC                   eval      cancel = *off
     C                   eval      cmdtkn = *off
414gAC                   eval      redspl = *off
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
416mAC                   eval      toslup = *off
417fD*R                   MOVE 'N'       W3ZERO
417fMC                   eval      w3zero = ' '
416aAC                   move      '*NO '        vfyslt
416gAC                   move      '*NO '        abort
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
     C                   move      '02 '         nxtscr
416iA*
416iA*    Only reset flag when user has NOT been prompted
416iA*    to verify From slot.
416iAC                   if        vfyslt <> '*YES'
415hAC                   eval      toslup = *off
416iAC                   endif
     *
     *  Get field defaults if this is an add.
     *
     C                   if        $pcmd = '*ADD    '
     C                   exsr      zzdft2
     C                   else
     *
     *  Otherwise get existing record(s).
     *
415cAC                   move      '*NO '        newtrn
500 DC**                 eval      svtrn1 = *zeros
500 DC**                 eval      svcub1 = *zeros
500 DC**                 eval      svwgt1 = *zeros
500 DC**                 eval      svtrn2 = *zeros
500 DC**                 eval      svcub2 = *zeros
500 DC**                 eval      svwgt2 = *zeros
500 DC**                 eval      svtrn3 = *zeros
500 DC**                 eval      svcub3 = *zeros
500 DC**                 eval      svwgt3 = *zeros
     C                   eval      *in91 = *on
     C                   exsr      zzget2
     C                   exsr      zzfil2
     C                   endif
     C                   eval      ovrrid = *off
     C     end02i        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  Screen 03 initialization
416aA*
416aAC     scr03i        begsr
416aAC                   move      '03 '         nxtscr
416mAC                   eval      toslup = *off
416aA*
416aA*  Get field defaults if this is an add.
416aA*
416aAC                   if        $pcmd = '*ADD    '
416aAC                   exsr      zzdft3
416aAC                   else
416aA*
416aA*  Otherwise get existing record(s).
416aA*
416aAC                   exsr      zzget3
416aAC                   exsr      zzfil3
416aAC                   endif
416aA*
416aAC     end03i        endsr
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
     C                   eval      $prtn = '*EXIT   '
500 AC                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   if        $pcmd <> '*VIEW   '
700lAC                             and $pcmd <> '*PCKSWAP'
     C                   exsr      scr01i
     C                   endif
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   move      'EOJ'         nxtscr
     C                   eval      $prtn = '*CANCEL '
500 AC                   exsr      zzcancel
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   exsr      zzcmd1
413 AC                   if        cmdtkn = *on
413 AC                   write     clrbtm
413 AC                   endif
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
417cAC     cancel        cabeq     *on           endsc1
413EMC                   exsr      zzupd1
413eMC     error         cabeq     *on           endsc1
     C                   endif
     *
700lAC                   if        $pcmd = '*PCKSWAP'
700lAC                   exsr      zzupd1
700lAC     error         cabeq     *on           endsc1
     C                   endif
     *
     *  Everything went fine.
     *
413eA*
413eA*   Get current task.
413eA*
500 DC**                 exsr      zztask
500 DC**                 select
500 DC**                 when      curtyp = 'D'
413eA*   End current task.
500 DC**                 exsr      zzend
500 DC**                 when      curtyp = 'I'
413eA*  End current task and any previous open tasks.
500 DC**                 move      *on           found
500 DC**                 dow       found = *on
500 DC**                 eval      curtsk = *blanks
500 DC**                 eval      curtyp = *blanks
500 DC**                 move      *off          curent
500 DC**                 exsr      zztask
500 DC**                 if        found = *off
500 DC**                 leave
500 DC**                 endif
500 DC**                 exsr      zzend
500 DC**                 enddo
500 DC**                 endsl
413eA*
500 DC**                 exsr      zzstrt
500 DC**                 eval      $rtncd = '*OK     '
500 DC**                 move      '*YES'        abort
416aA*
416aA*    Check if slot can be verified after transfer complete.
500 DC**                 exsr      zzvfy
416aA*
500 DC**                 select
416aA*    Slot can be verified.
500 DC**                 when      vfyslt = '*YES'
500 DC**                 exsr      scr03i
416aA*
416aA*    Slot can't be verified.
500 DC**                 when      vfyslt = '*NO '
500 DC**                 exsr      scr02i
413eA*
500 DC**                 endsl
413eA*
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
416aA*
416aA*    Verify slot screen previously displayed, return there.
610hDC*                  if        vfyslt = '*YES'
610hDC*                  move      '03 '         nxtscr
610hDC*                  else
700nDC*                  move      '01 '         nxtscr
700nMC                   move      'EOJ'         nxtscr
610hDC*                  endif
416aA*
416iA*    Only run Abort when user has NOT been prompted
416iA*    to verify From slot.
500 DC**                 if        vfyslt <> '*YES'
500 DC**                 exsr      zzabrt
500 DC**                 move      '*NO '        abort
500 DC**                 endif
500aAC                   exsr      zzcancel2
700nAC                   exsr      zzcancel
     C                   eval      $prtn = '*EXIT   '
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
416aA*
416aA*    Verify slot screen previously displayed, return there.
610hDC*                  if        vfyslt = '*YES'
610hDC*                  move      '03 '         nxtscr
610hDC*                  else
700nDC*                  move      '01 '         nxtscr
700nMC                   move      'EOJ'         nxtscr
610hDC*                  endif
416aA*
416iA*    Only run Abort when user has NOT been prompted
416iA*    to verify From slot.
500 DC**                 if        vfyslt <> '*YES'
500 DC**                 exsr      zzabrt
500 DC**                 move      '*NO '        abort
500 DC**                 endif
500aAC                   exsr      zzcancel2
700nAC                   exsr      zzcancel
     C                   eval      $prtn = '*CANCEL '
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
700lAC                             or $pcmd = '*PCKSWAP'
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
414gAC     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
500mAC     redspl        cabeq     *on           endsc2
     C                   endif
     *
     *  Create and close Label records.
     *
500 DC**                 exsr      zzcrtl
     *
     *  Close Transaction record and start IDLE task.
     *
500 DC**                 move      *off          error
500 DC**                 if        svtrn1 <> 0
500 DC**                 eval      $ltrn# = svtrn1
500 DC**                 eval      wkpcs = w1qt01
500 DC**                 eval      wkswgt = svwgt1
500 DC**                 eval      wkcube = svcub1
500 DC**                 exsr      zzclse
415eA*    Error during close, re-display current screen.
500 DC**   error         cabeq     *on           endsc2
500 DC**                 endif
415cA*
415cA*    Close breakdown 1 transfer transaction.
500 DC**                 if        svtrn2 <> 0
500 DC**                 eval      $ltrn# = svtrn2
500 DC**                 eval      wkpcs = w1qt02
500 DC**                 eval      wkswgt = svwgt2
500 DC**                 eval      wkcube = svcub2
500 DC**                 exsr      zzclse
415eA*    Error during close, re-display current screen.
500 DC**   error         cabeq     *on           endsc2
500 DC**                 endif
415cA*
415cA*    Close breakdown 2 transfer transaction.
500 DC**                 if        svtrn3 <> 0
500 DC**                 eval      $ltrn# = svtrn3
500 DC**                 eval      wkpcs = w1qt03
500 DC**                 eval      wkswgt = svwgt3
500 DC**                 eval      wkcube = svcub3
500 DC**                 exsr      zzclse
415eA*    Error during close, re-display current screen.
500 DC**   error         cabeq     *on           endsc2
500 DC**                 endif
416aA*
416aA*    User chose to verify slot.
500 DC**                 select
500 DC**                 when      vfyslt = '*YES'  and
500 DC**                           w3zero = 'Y'
500 DC**                 exsr      zzzero
416aA*
500 DC**                 endsl
600c *
600c *  Get option to check TO slot.
600cAC                   if        opcqty = 'Y'
750aAc                             and $pcmd <> '*PCKSWAP'
600c *  Call program to verify slot quantity.
600cAC                   eval      $pdisp = w2disp
600cAC                   eval      $pwhdp = w1whdp
600c C                   eval      whse = $pwhse
600cAC                   call      'SL635'
600cAC                   parm                    whse
600cAC                   parm                    $pwhdp
600cAC                   parm                    $pdisp
600cAC                   endif
     *
     *  Everything went fine so get out of program.
     *
     C                   move      'EOJ'         nxtscr
     C     endsc2        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  SC3  -  Screen 3
416aA*
416aAC     sc3           begsr
416aA*
416aA*  Test for F3 - Exit
416aA*
416aAC                   if        *inkc
416aAC                   move      '01 '         nxtscr
416gA*    Abort transaction for user.
500 DC**                 if        abort = '*YES'
500 DC**                 exsr      zzabrt
500 DC**                 endif
610hAC                   exsr      zzcancel2
416aAC                   eval      $prtn = '*EXIT   '
416aAC                   goto      endsc3
416aAC                   endif
416aA*
416aA*  Test for F5 - Refresh
416aA*
416aAC                   if        *inke
416aAC                   if        $pcmd <> '*VIEW   '
416aAC                   exsr      scr03i
416aAC                   endif
416aAC                   goto      endsc3
416aAC                   endif
416aA*
416aA*  Test for F12 - Previous
416aA*
416aAC                   if        *inkl
416aMC                   move      '01 '         nxtscr
416gA*    Abort transaction for user.
500 DC**                 if        abort = '*YES'
500 DC**                 exsr      zzabrt
500 DC**                 endif
610hAC                   exsr      zzcancel2
416aAC                   eval      $prtn = '*CANCEL '
416aAC                   goto      endsc3
416aAC                   endif
416aA*
416aA*  Test for other command keys BEFORE verification and update.
416aA*
416aAC                   exsr      zzcmd3
416aAC     cmdtkn        cabeq     *on           endsc3
416aA*
416aA*  Some other key pressed.
416aA*
416aA*     Check input and write/update record.
416aA*
416aAC                   if        $pcmd = '*ADD    '  or
416aAC                             $pcmd = '*CHANGE '
700lAC                             or $pcmd = '*PCKSWAP'
416aAC                   exsr      zzchk3
416aAC     error         cabeq     *on           endsc3
416aAC                   exsr      zzupd3
416aAC     error         cabeq     *on           endsc3
416aAC                   endif
416aA*
416aAC     endsc3        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
600aA*
600aA* Get client id.
600aA*
600aAC                   call      @getcl
600aAC                   parm                    client           10
600aA*
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
414cA*---------------------------------------------------------------
414cA*  Retrieve number of pick slots for item and accumulate
414cA*  number of pick slots assigned to item.
414cA*
500 DC**   chkpck        begsr
500 DC**   itkey         chain     itemmsc                            79
500 DC**                 if        *in79
500 DC**                 eval      imnrpk = 1
500 DC**                 endif
414cA*
414cA*    Accumulate number of pick slots assigned to item.
414cA*
500 DC**                 move      'A '          k3stat
500 DC**                 move      'Y'           k3pick
500 DC**   keys3         setll     slot3
500 DC**                 eval      nbrpck = *zeros
500 DC**                 move      *off          eof
500 DC**                 dow       eof = *off
500 DC**   keys3         reade     slot3                                  79
500 DC**                 move      *in79         eof
500 DC**                 if        not *in79
500 DC**                 add       1             nbrpck
500 DC**                 endif
500 DC**                 enddo
500 DC**                 endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   write     m16ctl
415gAC                   other
     C                   write     msgctl
415gAC                   endsl
     C                   eval      msgk = *zeros
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   write     m16clr
415gAC                   other
     C                   write     msgclr
415gAC                   endsl
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
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   write     m16ctl
415gAC                   other
     C                   write     msgctl
415gAC                   endsl
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
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   eval      $msgf = #msgsp
600dAC                   other
     C                   eval      $msgf = #msgf
600dAC                   endsl
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
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   write     m16rec
415gAC                   other
     C                   write     msgrec
415gAC                   endsl
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
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   write     m16rec
415gAC                   other
     C                   write     msgrec
415gAC                   endsl
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   eval      $msgf = #msgsp
600dAC                   other
     C                   move      #msgf         $msgf
600dAC                   endsl
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

500 A*----------------------------------------------------------------
500 A*    DRI0001  Local system caused error
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001        begsr
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

500 A*----------------------------------------------------------------
500 A*    DRI0001s Local system caused error (send to different program)
500 A*----------------------------------------------------------------
500 A
500 AC     zm0001s       begsr
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

415bA*----------------------------------------------------------------
415bA*    IT27004  Slot designation not same as item.
415bA*
415bAC     zm7004        begsr
415bAC                   move      'IT27004'     #msgid
415bAC                   move      '*DIAG  '     #msgtp
415bAC                   movea     errmsg        $md(1)
415bAC                   exsr      zmpmsg
415bAC                   endsr
     *----------------------------------------------------------------
     *   PIR0009  Number can not be negative.
     *
     C     zm0009        begsr
510dDC*                  move      'PIR0009'     #msgid
510dMC                   eval      #msgid = 'PIR0109'
     C                   move      '*DIAG  '     #msgtp
510dDC*                  movea     desc          errmsg
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
500 A*----------------------------------------------------------------
500 A*      0105s
500 A*
500 AC     zm0105s       begsr
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
     C                   move      'PIR0201'     #msgid
     C                   move      '*DIAG  '     #msgtp
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   movea     descsp        errmsg
600dAC                   other
     C                   movea     desc          errmsg
600dAC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0202  Code already exists.
     *
     C     zm0202        begsr
     C                   move      'PIR0202'     #msgid
     C                   move      '*DIAG  '     #msgtp
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   movea     descsp        errmsg
600dAC                   other
     C                   movea     desc          errmsg
600dAC                   endsl
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0203  Field cna't be blank.
     *
     C     zm0203        begsr
     C                   move      'PIR0203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416aA*----------------------------------------------------------------
416aA*   PIR1005  Value must be 'Y' or 'N'
416aA*
416aAC     zm1005        begsr
416aAC                   move      'PIR1005'     #msgid
416aAC                   move      '*DIAG  '     #msgtp
416aAC                   movea     errmsg        $md
416aAC                   exsr      zmpmsg
416aAC                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   move      'PIR7971'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   move      'PIR7972'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7973  Slot record does not exist.
     *
     C     zm7973        begsr
     C                   move      'PIR7973'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     PIR7974  Slot record is locked.
     *
     C     zm7974        begsr
     C                   move      'PIR7974'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
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
     *   PIR0110  Quantity must be greater than 0.
     *
     C     zm0110        begsr
     C                   move      'PIR0110'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1001  Invalid value entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
416j *     ZM01  No linked record for item.
416j *
416j C     zm01          begsr
416jAC                   move      'IT12001'     #msgid
416jAC                   move      '*DIAG  '     #msgtp
416jAC                   eval      $md = *blanks
416jAC                   exsr      zmpmsg
416jAC                   endsr
     *----------------------------------------------------------------
     *     ZM07  Warning - No record exists in Tie/High def. file.
     *
     C     zm07          begsr
     C                   move      'IT13207'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      erdisp = #tosldisp
     C                   eval      eritem = #toslitem
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12216  Quantity can not be negative when replacing.
     *
     C     zm16          begsr
     C                   move      'IT12216'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12215  Slot does not contian item.
     *
     C     zm15          begsr
     C                   move      'IT12215'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT12217  Warning: Slot quanitiy changed before adjustment.
     *
     C     zm17          begsr
     C                   move      'IT12217'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Adjustment not completed - Record doesn't exist.
     *
     C     zm73          begsr
     C                   move      'IT12273'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12274  Adjustment not completed - Record locked.
     *
     C     zm74          begsr
     C                   move      'IT12274'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15201  Transfer completed successfully.
     *
     C     zm1521        begsr
     C                   move      'IT15201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   eval      $pmsg = #msgk
     C                   endsr
     *----------------------------------------------------------------
     *     IT15202  From and To slot cannot be same.
     *
     C     zm1522        begsr
     C                   move      'IT15202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT15203  To slot contains a different item.
     *
     C     zm1523        begsr
     C                   move      'IT15203'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
412 A*     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   move      'IT15204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
416tA*----------------------------------------------------------------
416tA*   PIR2007  Invalid slot, slot inactive.
416tA*
416tAC     zm2007        begsr
416tAC                   move      'PIR2007'     #msgid
416tAC                   move      '*DIAG  '     #msgtp
416tAC                   eval      $md = *blanks
416tAC                   exsr      zmpmsg
416tAC                   endsr
     *----------------------------------------------------------------
     *     IT25201  Date sensitive item exists in to slot with dif dte
     *
     C     zm2521        begsr
     C                   move      'IT25201'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT25202  WARNING:
     *              Date Sensitive item exists in to slot with dif dte
     *
     C     zm2522        begsr
     C                   move      'IT25202'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
413eA*     IT25203  Slot and Item department do not match.
413eA*
413eAC     zm2523        begsr
413eAC                   move      'IT25203'     #msgid
413eAC                   move      '*DIAG  '     #msgtp
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
     *----------------------------------------------------------------
413eA*     IT25204  Qty entered cannot be > available qty in FROM slot
413eA*
413eAC     zm5204        begsr
413eAC                   move      'IT25204'     #msgid
413eAC                   move      '*DIAG  '     #msgtp
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
     *----------------------------------------------------------------
413eA*     IT25205  Item number changed.
413eA*
413eAC     zm5205        begsr
413eAC                   move      'IT25205'     #msgid
413eAC                   move      '*DIAG  '     #msgtp
413eAC                   eval      $md = *blanks
413eAC                   exsr      zmpmsg
413eAC                   endsr
     *----------------------------------------------------------------
414cA*     IT25206  # of pick slots exceeds # allowed.
414cA*
500 DC**   zm5206        begsr
500 DC**                 move      'IT25206'     #msgid
500 DC**                 move      '*DIAG  '     #msgtp
500 DC**                 eval      ernpck = nbrpck
500 DC**                 eval      erapck = imnrpk
500 DC**                 movea     errmsg        $md(1)
500 DC**                 exsr      zmpmsg
500 DC**                 endsr
     *----------------------------------------------------------------
414dA*     IT25207  Slot and Item section do not match.
414dA*
414dAC     zm5207        begsr
414dAC                   move      'IT25207'     #msgid
414dAC                   move      '*DIAG  '     #msgtp
414dAC                   eval      $md = *blanks
414dAC                   exsr      zmpmsg
414dAC                   endsr
416s *----------------------------------------------------------------
416sA*     IT25208  Invalid item type, use base item.
416sA*
416sAC     zm5208        begsr
416sAC                   move      'IT25208'     #msgid
416sAC                   move      '*DIAG  '     #msgtp
416sAC                   eval      $md = *blanks
416sAC                   exsr      zmpmsg
416sAC                   endsr
416s *----------------------------------------------------------------
416sA*     IT25209  Invalid quantity, not multiple of base/brk qty.
416sA*
416sAC     zm5209        begsr
416sAC                   move      'IT25209'     #msgid
416sAC                   move      '*DIAG  '     #msgtp
416sAC                   eval      $md = *blanks
416sAC                   exsr      zmpmsg
416sAC                   endsr
417cA*----------------------------------------------------------------
417cA*     IT29007  Wrong license plate scanned.
417cA*
417cAC     zm9007        begsr
417cAC                   move      'IT29007'     #msgid
417cAC                   move      '*DIAG  '     #msgtp
417cAC                   movea     errmsg        $md(1)
417cA******               EXSR ZMPMSW
417cAC                   endsr
417cA*----------------------------------------------------------------
417cA*     IT29008  Lic#/Lot# found. Try again.
417cA*
417cAC     zm9008        begsr
417cAC                   move      'IT29008'     #msgid
417cAC                   move      '*DIAG  '     #msgtp
417cAC                   movea     errmsg        $md(1)
417cA******               EXSR ZMPMSW
417cAC                   endsr
416jA*----------------------------------------------------------------
416jA*   IT35201   No brk qty defined for base item.
416jA*
416jAC     zm3521        begsr
416jAC                   move      'IT35201'     #msgid
416jAC                   move      '*DIAG  '     #msgtp
416jAC                   movea     errmsg        $md(1)
416jAC                   exsr      zmpmsg
416jAC                   endsr
650j *----------------------------------------------------------------
650j *     IT35202  From/To slot status don't match.
650j *
650j C     zm3502        begsr
650j C                   eval      #msgid = 'IT35202'
650j C                   eval      #msgtp = '*DIAG  '
650j C                   eval      errmsg = *blanks
650j C                   eval      $md = *blanks
650j C                   eval      erfsts = #fromslstat
650j C                   eval      ertsts = #toslstat
650j C                   movea     errmsg        $md(1)
650j C                   exsr      zmpmsg
650j C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZCANCEL   User canceled from screen 1.
500 A*----------------------------------------------------------------
500 A
500 AC     zzcancel      begsr

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
600iAC                   eval      $sapullwhdpu = *on
600iAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns

600gAC                   eval      $saexcdU = *on
600gAC                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
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
600eAC                   eval      $tlic# = #fromToLcns
500hAC                   exsr      zzzcall$lt210

500 AC                   endsr

500aA*----------------------------------------------------------------
500aA*  ZZCANCEL2  User canceled from screen 2.
500aA*----------------------------------------------------------------
500aA
500aAC     zzcancel2     begsr

     *  If TFROUT has already been done, reverse it.

     C                   if        tfroutflag

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #fromslwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = #fromsldisp
750bAC                   eval      $slstatu = *on
750bAC                   eval      $slstat  = #fromslstat
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
600dDC**                 eval      $saqty1 = -(w1qt01)
600dDC**                 eval      $saqty2 = -(w1qt02)
600dDC**                 eval      $saqty3 = -(w1qt03)
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
600iAC                   eval      $sapullwhdpu = *on
600iAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns

600gAC                   eval      $saexcdU = *on
600gAC                   eval      $saexcd  = 'CANCEL'

     C                   eval      $dricommand = '*SLOT'
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
610cAC                   eval      $tinlic#  = curlic#
610cAC                   eval      $toutlic# = curlic#
500iAC                   exsr      zzzcall$lt210
500iAC                   eval      curlic# = $tlic#
600eA
600eA*  Delete work record(s).
600eA
600eAC                   exsr      zzwrkinz

     C                   eval      tfroutflag = *off
500 AC                   endsr

     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   move      *off          error
500jA*
500jA*  Verify quantity is greater than zero.
500jA*
720eDC*                  if        (w1qt01=0 and w1qt02=0 and w1qt02=0)
720eAC                   if        (w1qt01=0 and w1qt02=0 and w1qt03=0)
510dMC                             or w1qt01 < 0
510dMC                             or w1qt02 < 0
510dMC                             or w1qt03 < 0
500jAC                   eval      error = *on
500jAC                   eval      *in22 = *on
500jAC                   eval      *in02 = *on
500jAC                   eval      errmsg = *blanks
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   movea     descsp(3)     errmsg
600dAC                   other
500jAC                   movea     desc(3)       errmsg
600dAC                   endsl
510dMC                   exsr      zm0009
500jAC                   goto      endck1
500jAC                   endif
610dA
610dA*  When transfering from a USR slot, qty entered must
610dA*  match USR slot qty.
610dA
610dAC                   if        #fromslaisl = 'USR'
610dAC                   if        w1qt01 <> #fromslavl1
610dAC                             or w1qt02 <> #fromslavl2
610dAC                             or w1qt03 <> #fromslavl3
610dAC                   eval      error = *on
610dAC                   eval      *in22 = *on
610dAC                   eval      *in02 = *on
610dAC                   eval      errmsg = 'Entire qty must be taken '
610dAC                                    + 'for a USR slot'
610dAC                   exsr      zm0105
610dAC                   goto      endck1
610dAC                   endif
610dAC                   endif
500 A
500 A*  Use DRI interface to do most of the verifications.
500 A
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

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYTFOCHG'
     C                   eval      $drisys2upd = 'D'
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
500 MC                   if        w1itm <> #fromslitem
     C                   move      *on           error
     C                   move      *on           warn
     C                   eval      errmsg = *blanks
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
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
650j C*   DFCHK Flags are used to force F20 for each test
650j C*   Values: Flag = 0 Do check.
650j C*           Flag = 1 Check was done, ok.
650j C*           Flag = 2 Warning condition.
650j C*
     C                   eval      error = *off
650kA /free
650kA    // if production slot ensure virtual is created for to slot
650kA                    prdtfr = *off;
650kA                    sltc = 0;
710aD                    //wkaisl = ' ';
710aD                    //if w2disp > ' ';
710aD                    //wkaisl = %subst(%trim(w2disp):1:3);
710aM                      wkaisl = %subst(w2disp:1:3);
710aD                    //endif;
650kA                    sltc = %lookup(wkaisl:prdslt:1);
710fD                    //if sltc <> 0 and wkaisl <> ' ';
710fM                    if (sltc <> 0 and wkaisl <> ' ') or wkaisl='RPK';
650kA                       prdtfr = *on;
650kA                       exsr clr$slot;
650kA                       $slwhseu = *on;
650kA                       $slwhse  = $pWhse;
650kA                       $slwhdpu = *on;
650kA                       $slwhdp  = #newfromitwhdp;
650kA                       $slitemu = *on;
650kA                       $slitem  = w1itm;
650kA                       $sldispu = *on;
650kA                       $sldisp  = w2disp;
650kA                       $slstatu = *on;
650kA                       $slstat  = 'PR';
650kA
650kA                       $dricommand = '*SLOT';
710fA                       if wkaisl = 'RPK';
710fA                          $slstat  = 'RP';
710fA                          $drisubcmd  = '%CRTREPAKP';
710fA                       else;
650kA                       $drisubcmd  = '%CRTPROD';
710fA                       endif;
650kA                       $drisys2upd = 'D';
650kA                       chk4err = *on;
650kA                       exsr zzzdricop;
650kA                       hldprdDisp = $sldisp;
650kA                       error = *off;
650kA                    endif;
      /end-free
530bAC                   move      w2disp        odisp
416j *  If item changed, verify adjustment code.
500 MC                   if        #fromslitem <> w1itm
416j C                   eval      $lcmd = '*VERIFY '
416j C                   eval      $lcode = w2adj
416j C                   call      'AD900'
416j C                   parm                    $lparm
416j C                   if        $lrtn = '*ERROR  '
416j C                   move      *on           error
416j C                   eval      *in22 = *on
416j C                   eval      *in02 = *on
416j C                   movel     $lerm         errmsg
416j C                   exsr      zm0105
530bAC                   goto      endck2
416j C                   else
416j C                   if        $lrtn = '*PGMQ   '
416j C                   move      *on           error
416j C                   eval      *in22 = *on
416j C                   eval      *in02 = *on
416j C                   eval      #msgk = $lmsg
416j C                   exsr      zmqmsg
530bAC                   goto      endck2
416j C                   endif
416j C                   endif
416j C                   endif
     *
530bDC*                  move      w2disp        odisp
     *
     *  "To Slot" can't be blank.
     *
     C                   if        w2disp = *blanks
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      errmsg = *blanks
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   movea     descsp(1)     errmsg
600dAC                   other
     C                   movea     desc(1)       errmsg
600dAC                   endsl
     C                   exsr      zm0203
     C                   goto      endck2
     C                   endif
710e *
710e *  "Same Slot" From and To Slot can't be the same.
710e *
710eAC                   if        #fromsldisp = w2disp
710eAC                   move      *on           error
710eAC                   eval      *in21 = *on
710eAC                   eval      *in01 = *on
710eAC                   eval      errmsg = *blanks
710eAC                   select
710eAC                   when      e$lng = 'SP'
710eAC                   movea     descsp(1)     errmsg
710eAC                   other
710eAC                   movea     desc(1)       errmsg
710eAC                   endsl
710eAC                   exsr      zm1522
710eAC                   goto      endck2
710eAC                   endif
650hA*
650hA*  If transfer to represents a Repack Item verify on-demand slot
650hA*  exists
650hA*
650hA /free
650hA    if #newfromitType = 'R';
650hA       chain ($pWhse:w1itm) kititem;
650hA       if not %error and %found;
650hA          if kidisp <> ' ';
650hA             exsr clr$slot;
650hA             $slwhseu = *on;
650hA             $slwhse  = $pWhse;
650hA             $slwhdpu = *on;
650hA             $slwhdp  = #newfromitwhdp;
650hA             $slitemu = *on;
650hA             $slitem  = w1itm;
650hA             $sldispu = *on;
650hA             $sldisp  = kidisp;
650hA
650hA             $dricommand = '*SLOT';
650hA             $drisubcmd  = '%CRTREPAKD';
650hA             $drisys2upd = 'D';
650hA             chk4err = *on;
650hA             exsr zzzdricop;
650hA             odrSlot = $sldisp;
650hA             error = *off;
650hA          endif;
650hA       endif;
650hA     endif;
650hA /end-free
414gA*
414gA*  Call API for slot.
414gA*
414gAC                   call      @apics
414gAC                   parm                    w2disp
414gAC                   parm      6             worow
414gAC                   parm      11            wocol
414gAC                   parm                    @artn             8
414gAC                   if        @artn = '*REDSPLY'
414gAC                   move      *on           redspl
414gAC                   goto      endck2
414gAC                   endif
SGCcA*
SGCcA*  Verify 'To Slot' pick slot is empty or has the same item.
SGCcA*  Do not allow virtual pick slot to be created.
SGCcAC                   if        client = sgc
SGCcAC                   move      *off          goodsl
SGCcAC                   eval      svaisl = *blanks
SGCcAC     slotky        setll     slot2
SGCcAC                   dow       forever = forever
SGCcAC     slotky1       reade     slot2
SGCcAC                   if        svaisl = *blanks
SGCcAC                   eval      svaisl = slaisl
SGCcAC                   eval      svloc = slloc
SGCcAC                   eval      svrlvl = slrlvl
SGCcAC                   endif
SGCcAC                   if        %eof
SGCcAC                   leave
SGCcAC                   endif
SGCcA*  Test read is past scanned slot
SGCcAC                   if        slaisl <> svaisl
SGCcAC                             or slloc <> svloc
SGCcAC                             or slrlvl <> svrlvl
SGCcAC                   leave
SGCcAC                   endif
SGCdA*  Allow virtual pick slots for DR aisle level 2, 200 to 246
SGCdAC                   if        slaisl = ' DR'
SGCdAC                             and slrlvl = 2
SGCdAC                             and slloc >199
SGCdAC                             and slloc <247
SGCdAC                   eval      goodsl = *on
SGCdAC                   leave
SGCdAC                   endif
SGCeA*  Allow virtual pick slots CB aisle level 2-4, 216 to 226 even
SGCeAC                   if        slaisl = ' CB'
SGCeAC                             and slrlvl > 1
SGCeAC                             and slrlvl <51
SGCeAC                             and slloc >215
SGCeAC                             and slloc <227
SGCeAC                             and slside = 0
SGCeAC                   eval      goodsl = *on
SGCeAC                   leave
SGCeAC                   endif
SGCeA*  Allow virtual pick slots CN aisle 188 to 208 even
SGCeAC                   if        slaisl = ' CN'
SGCeAC                             and slloc >187
SGCeAC                             and slloc <209
SGCeAC                             and slside = 0
SGCeAC                   eval      goodsl = *on
SGCeAC                   leave
SGCeAC                   endif
SGCeA*  Allow virtual pick slots CE aisle
SGCeAC                   if        slaisl = ' CE'
SGCeAC                   eval      goodsl = *on
SGCeAC                   leave
SGCeAC                   endif
SGCeA*
SGCcAC                   select
SGCcAC                   when      slpick = 'N'
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   when      slitem = #fromslitem
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   when      slitem = *blanks
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   endsl
SGCcAC                   iter
SGCcAC                   enddo
SGCcAC                   if        goodsl = *off
SGCcAC                   eval      error = *on
SGCcAC                   eval      *in21 = *on
SGCcAC                   eval      *in01 = *on
SGCcAC                   exsr      zm1523
SGCcAC                   goto      endck2
SGCcAC                   endif
SGCcAC                   endif
600lA
600lA*  If slot starts with 'OS' then it must match ossDisp.
600lA*  (ossDisp is generated with F9=OSS.
600lA
600lAC                   if        %subst(w2disp:1:2)='OS'
600lAC                             and w2disp <> ossDisp
600lAC                   move      *on           error
600lAC                   eval      *in21 = *on
600lAC                   eval      *in01 = *on
600lAC                   eval      errmsg = *blanks
600lAC                   select
600lAC                   when      e$lng = 'SP'
600lAC                   movea     descsp(6)     errmsg
600lAC                   other
600lAC                   movea     desc(6)       errmsg
600lAC                   endsl
600lAC                   exsr      zm0105
600lAC                   goto      endck2
600lAC                   endif
     *
     *  Verify "To Slot" number.
     *
500 A
     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #newfromitwhdp
     C                   eval      $sldispu  = *on
650kAc                   if        prdtfr
650kAC                   eval      $sldisp   = hldprdDisp
650kAc                   else
     C                   eval      $sldisp   = w2disp
650kAc                   endif
600lAC                   eval      $slentdu  = *on
600lAC                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
     C                   eval      $saitem   = w1itm
     C                   eval      $saqtyu   = *on
     C                   eval      $saqty1   = w1qt01
     C                   eval      $saqty2   = w1qt02
     C                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
600lDC**                 eval      $sacdspu  = *on
600lDC**                 eval      $sacdsp   = #fromsldisp
600lAC                   eval      $sacwhdu = *on
600lAC                   eval      $sacwhd  = wuUsrWhdp
600lAC                   eval      $sacdspu  = *on
600lAC                   eval      $sacdsp   = wuUsrDisp
600kA
600kAC                   eval      $saActionU = *on
600kAC                   eval      $saAction = 'TFR'
600lA
600lAC                   if        w2disp = ossDisp
600lAC                   eval      $sapullwhdpu = *on
600lAC                   eval      $sapullwhdp  = #newfromitwhdp
600lAC                   eval      $sapulldispu = *on
600lAC                   eval      $sapulldisp  = w2disp
600lAC                   eval      $sapullbaseu = *on
600lAC                   eval      $sapullbase  = 'OSS' + #rcvarea
600lAC                   eval      $sapulllcnsu = *on
600lAC                   eval      $sapulllcns  = ossLcns
600lAC                   else
600iAC                   eval      $sapullwhdpu = *on
600lAC                   eval      $sapullwhdp  = wuPulWhdp
600lAC                   eval      $sapulldispu = *on
600lAC                   eval      $sapulldisp  = wuPulDisp
600lAC                   eval      $sapullbaseu = *on
600lAC                   eval      $sapullbase  = wuPulBase
600lAC                   eval      $sapulllcnsu = *on
600lAC                   eval      $sapulllcns  = wuPulLcns
600lAC                   endif

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYTFICHG'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endck2
     C                   endif

740aA*  *VFYTFICHG does not return the info needed for the #to fields.
740aA*  Therefore, do a *GET to get the information.
740aA
740aAC                   eval      $dricommand = '*SLOT'
740aAC                   eval      $drisubcmd  = '%GET'
740aAC                   eval      $drisys2upd = 'D'
740aAC                   eval      chk4err = *off
740aAC                   eval      zmsflag = *off
740aAC                   exsr      zzzdricop

     C                   eval      #toslwhdp = $slwhdp
     C                   eval      #tosldisp = $sldisp
     C                   eval      #toslaisl = $slaisl
     C                   eval      #toslloc  = $slloc
     C                   eval      #toslrlvl = $slrlvl
     C                   eval      #toslhand = $slhand
     C                   eval      #toslpick = $slpick
     C                   eval      #toslsdef = $slsdef
650jAC                   eval      #toslstat = $slstat
640jA
640jA*  See if something alread in slot location.
640jA
700kAC                   if        opmput = 'N'
640jAC                   call      'CHKUSAGE'
640jAC                   parm      $slwhse       $uWhse
640jAC                   parm      $slwhdp       $uWhdp
640jAC                   parm      $sldisp       $uDisp
640jAC                   parm      $slrsrv       $uRsrv
640jAC                   parm      $saitem       $uItem
640jAC                   parm      $slentd       $uEntDte
640jAC                   parm      $slexpd       $uExpDte
640jAC                   parm      0             $uPieces
640jAC                   parm      0             $uRecs
640jAC                   parm      ' '           $uDiffItem
640jAC                   parm      ' '           $uDiffEntd
640jAC                   parm      ' '           $uDiffExpd
640jA
640jA*  For directed putaway, To slot cannot have different item.
640jA
700gAC                   select
700gAC                   when      client = westside
640jAC                   if        opmput = 'N' and $uDiffItem = 'Y'
640jAC                   eval      error = *on
640jAC                   eval      *in21 = *on
640jAC                   eval      *in01 = *on
640jAC                   exsr      zm1523
640jAC                   goto      endck2
640jAC                   endif
700gAC                   endsl
700kA*
700kAC                   endif
740aA
740aA*  Do warehouse-to-warehouse (GLOWWTFR) checks.
740aA
740aA /free
740aA    monitor;
740aA      WWTFR('*VFYTFRIN': #toslaisl: #toslloc: $pwhse: #user: wwrtn: wwmsg);
740aA      if wwrtn = '*ERROR';
740aA        errmsg = wwmsg;
740aA        error = *on;
740aA        *in21 = *on;
740aA        *in01 = *on;
740aA        exsr zm0105;
740aA        leavesr;
740aA      endif;
740aA    on-error;
740aA    endmon;
740aA /end-free
600lA
500 A
500 A*  Save tie/high info if defined for item.
500 A
     C                   eval      #newfromitsdef = ' '
     C                   eval      #newfromittie  = 0
     C                   eval      #newfromithigh = 0
     C     1             do        5             i
     C                   if        $idsdef(i) = #toslsdef
     C                   eval      #newfromitsdef = $idsdef(i)
     C                   eval      #newfromittie  = $idtie(i)
     C                   eval      #newfromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
     *
     *   Verify record exists in itemdef (tie/high) file.
     *   If no record is found, display warning message.
     *
     C                   if        ovrrid = *off
CWa  C                             and client <> 'CIYTWHO'
CDIaAC                             and client <> 'CDI'
GIGaAC                             and client <> GlobalImport
SWTaAC                             and client <> swt
DRYbAC                             and client <> dairyland
EOPaAC                             and client <> EarlsOrganic
SFP AC                             and client <> Seashore
500 MC                   if        #toslpick = 'Y' and #newfromitsdef = ' '
     C                   eval      error = *on
     C                   eval      warn = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm07
     C                   endif
     C                   endif
650jA
650jA*  Set override to check slot status change (to / from inactive)
650j C                   if        dfchk  = '0' and
650j C                             ovrrid = *on
650j C                   eval      ovrrid = *off
650j C                   endif
650j C
650j C                   if        dfchk  = '2' and
650j C                             ovrrid = *on
650j C                   eval      dfchk  = '1'
650j C                   endif
650jA*  Warning if transfer is to different slot status.
CBIa *  F20 override not allow at Cheney on status - keep checking.
650jAC                   if        dfchk <> '1'
CBIaAC                             or client = cheney
650jAC                   eval      dfchk = '1'
FPRdA*  Skip error for Food Pro
650jAC                   if        #toslstat <> 'V' and
650jAC                             #toslstat <> 'Z' and
FPRdAC                             client <> foodpro
650jA
650jAC                   if        #toslstat <> #fromslstat
650jAC                   eval      error = *on
650jAC                   eval      *in21 = *on
650jAC                   eval      *in01 = *on
650jAC                   eval      dfchk = '2'
650jAC                   eval      warn = *on
650jAC                   exsr      zm3502
650jAC                   goto      endck2
650jAC                   endif
650jAC                   endif
650jAC                   endif
     *
413dAC     endck2        tag
413dAC                   if        error = *on
413dAC                   move      odisp         w2disp
413dAC                   endif
     *
     C                   endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCHK3   Screen 3 error checking.
416aA*
416aAC     zzchk3        begsr
416aAC                   move      *off          error
SVLb C                   if        client = saval
GLPaAC                             or client = greenleaf
SVLb C                   if        w3zero = '1'
SVLb C                   eval      w3zero  = 'Y'
SVLb C                   endif
SVLb C                   if        w3zero = '9'
SVLb C                   eval      w3zero = 'N'
SVLb C                   endif
SVLb C                   endif
416aA*
416aA*    Verify Zero, Y,N
416aA*
416aAC                   if        w3zero <> 'Y'  and
416aAC                             w3zero <> 'N'
416aAC                   move      *on           error
416aAC                   eval      *in21 = *on
416aAC                   eval      *in01 = *on
416aAC                   eval      errmsg = *blanks
600dAC                   select
600dAC                   when      e$lng = 'SP'
600dAC                   movea     descsp(4)     errmsg
600dAC                   other
416aAC                   eval      errmsg = desc(4)
600dAC                   endsl
416aAC                   exsr      zm1005
416aAC                   endif
416aA*
416aAC                   endsr
     *----------------------------------------------------------------
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   move      *off          cmdtkn
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
740cA*     Change Item.
740cA*
740cAC                   when      row# = 6
740cAC                   eval      *in03 = *on
740cAC                   eval      $lcmd = '*LOOKUP '
740cAC                   eval      $lwhse = $pwhse
740cAC******             eval      $litm = w1item
740cAC                   eval      $litm = $ititem
740cAC                   call      'CI900'
740cAC                   parm                    $lparm
740cAC                   if        $lrtn = '*SELECT '
740cAC                   eval      w1itm = $ltitm
740cAC                   endif
740cA*
     *
     *     Cursor not on a valid lookup field.
     *
     C                   other
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   goto      endcm1
     C                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
414 AC                   eval      ovrrid = *on
414 AC                   endif
     *
     *
     *      F21 - Item Tie/High Maintenance.
     *
     C                   if        *inkv
     C                   eval      cmdtkn = *on
     C                   z-add     $pwhse        whse
     C                   call      'IT141'
     C                   parm                    whse
     C                   parm                    w1itm
     C                   endif
     *
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   exsr      zzcmd1
     *
     *      F8 - View item slot information.
     *
650c *      Code removed to allow 650a F8 mods.
413eAC**                 if        *inkh
413eAC**                 eval      cmdtkn = *on
500 AC**                 eval      $lwhse2 = $pwhse
500 AC**                 eval      $lwhdp2 = $pwhdp
500 MC**                 eval      $ldisp2 = w2disp
500 MC**                 eval      $litem2 = w1itm
413eAC**                 call      'IT135'
500 MC**                 parm                    $lparm
413eAC**                 endif
650c *      F8 - View linked item pick slots
650c *
650cAC                   if        *inkh
650cAC                   eval      cmdtkn = *on
650cAC                   eval      $lwhse = $pwhse
650cAC**                 eval      $lwhdp = $pwhdp
650cMC                   eval      $litm = w1itm
650cAC                   call      'IT233'
650cMC                   parm                    $luky
650cMC                   parm                    $lrtn
650cAC                   call      'IT234'
650cMC                   parm                    $luky
650cMC                   parm                    $lrtn
650cAC                   endif
600aA*
600aA*  Test for F9  - Offsite Storage License Print
600aA*
600aAC                   if        *inki
600aAC                   eval      cmdtkn = *on
600aAC                   exsr      zzextstg
600aAC                   endif
700oA*
700oA*  Test for F10 - Create Exception
700oA*
700oAC                   if        *inkj
700oAC                   eval      cmdtkn = *on
700oAC                   eval      exerid = 'Slot   '
700oAC                   move      w2qty         exqty
700oAC                   exsr      zzexcp
700oAC                   endif
     *
     *      F20 - Accept Warning.
     *
     C                   if        *inku
413eAC                   move      *on           ovrrid
413eAC                   endif
     *
     C     endcm2        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCMD3   User defined command keys for screen 3.
416aA*
416aAC     zzcmd3        begsr
416aAC     endcm3        endsr
     *----------------------------------------------------------------
     *
     *  ZZCRTL   Create Label records.
     *
     C     zzcrtl        begsr
     *
     C                   clear                   lbrec
     C                   eval      lbwhse = $pwhse
     C                   eval      lbwhdp = $pwhdp
600bAC                   eval      exwgfm = *zeros
     *
     *  FROM Slot.
     *
500 MC                   eval      lbaisl = #fromslaisl
500 MC                   eval      lbloc = #fromslloc
500 MC                   eval      lbrlvl = #fromslrlvl
500 MC                   eval      lbhand = #fromslhand
500 MC                   eval      lbpseq = #fromslpseq
500 MC                   eval      lbstyp = #fromslstyp
     C                   if        lbstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif
500 MC                   eval      fmwhdp = #fromslwhdp
500 MC                   eval      fmdisp = #fromsldisp
500 MC                   eval      fmitem = #fromslitem
     *
     * FROM ITEM
     *
600bAC                   eval      fmcwgt = #fromitcwgt
MRTaAc                   if        client = merit
MRTaAC                   eval      fmcwgt = 'Y'
MRTaAc                   endif
500 MC                   if        #fromslitem <> w1itm
500 MC                   if        #fromitumq2 <> 0
416l C                   endif
416j C                   endif
415cA*
415cA*    Create label records for case transfer.
415cA*
415cAC                   select
415cAC                   when      w1qt01 <> 0
500 MC                   eval      lbucod = #fromitum1
     C                   eval      lbqalc = w1qt01
     C                   eval      lbqpck = w1qt01
500 MC                   eval      lbucub = #fromitcube
     C     lbucub        mult      w1qt01        lbcube
500 MC                   eval      lbuwgt = #fromitswgt
     C     lbuwgt        mult      w1qt01        lbswgt
     *
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
500 MC                   eval      lbtie = #fromittie
500 MC                   eval      lbhigh = #fromithigh
     *
     * TO Slot.
     *
600bAC                   eval      tocwgt = #newfromitcwgt
500 MC                   eval      lbwhs2 = $pwhse
500 MC                   eval      lbwhd2 = #toslwhdp
500 MC                   eval      towhdp = #toslwhdp
500 MC                   eval      lbasl2 = #toslaisl
     *
500 MC                   eval      lbloc2 = #toslloc
500 MC                   eval      lblvl2 = #toslrlvl
500 MC                   eval      lbhnd2 = #toslhand
500 MC                   eval      todisp = #tosldisp
500 MC                   eval      lbrte = *blanks
500 MC                   eval      toitem = w1itm
     C                   eval      lbpbat = 0
     C                   eval      lbutyp = 'N'
500 MC                   eval      lbtrn# = curtrn#
     C                   eval      lbctr# = 0
     *     - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      fmitem        lbitem
     C                   move      fmdisp        lbdisp
     C                   move      todisp        lbdsp2
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'A'
     C                   eval      lbtype = 'T'
500kMC                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
     *
     *     - Create second label record
     *         - Get new label number.
     C                   call      'PIRLBL#'
     C                   parm                    lblbl#
     C                   move      toitem        lbitem
416fAC                   move      towhdp        lbwhdp
     C                   move      todisp        lbdisp
     C                   move      fmdisp        lbdsp2
500 MC                   eval      lbucod = #newfromitum1
416s C                   eval      lbqalc = toqty1
416s C                   eval      lbqpck = toqty1
     C                   if        fmitem = toitem
     C                   eval      lbgrp1 = *on
     C                   else
     C                   eval      lbgrp1 = '2'
     C                   endif
     C                   eval      lbgrp2 = 'B'
     C                   eval      lbtype = 'T'
500kMC                   eval      lbstat = 'C'
     C                   eval      lbsdte = today
     C                   time                    lbstim
     C                   eval      lbrdte = today
     C                   write     lbrec
500 MC                   eval      svtrn1 = curtrn#
415cAC                   move      '*YES'        newtrn
500 A*
500 A*     - Update current transaction.
500 A*
500 AC                   exsr      zztrnupdate
415cA*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 1 qty.
415cA*
415cAC                   select
415cAC                   when      w1qt02 <> 0
500 MC                   eval      lbucod = #fromitum2
415cAC                   eval      lbqalc = w1qt02
415cAC                   eval      lbqpck = w1qt02
500 MC                   if        #fromitumq2 > 0
500 MC     #fromitcube   div(h)    #fromitumq2   lbucub
500 MC     #fromitswgt   div(h)    #fromitumq2   lbuwgt
415cAC                   else
500 MC                   eval      lbuwgt = #fromitswgt
500 MC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      w1qt02        lbcube
415cAC     lbuwgt        mult      w1qt02        lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500 MC                   eval      lbtie = #fromittie
500 MC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650gAC                   eval      tocwgt = #newfromitcwgt
650gA*
500 MC                   eval      lbwhs2 = $pwhse
500 MC                   eval      lbwhd2 = #toslwhdp
500 MC                   eval      towhdp = #toslwhdp
500 MC                   eval      lbasl2 = #toslaisl
415cA*
500 MC                   eval      lbloc2 = #toslloc
500 MC                   eval      lblvl2 = #toslrlvl
500 MC                   eval      lbhnd2 = #toslhand
500 MC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   move      w1itm         toitem
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = *on
415cAC                   if        newtrn = '*YES'
500 AC                   exsr      zztrnclose
500 AC                   exsr      zztrnstart
500 AC                   endif
415cA*
500 MC                   eval      lbtrn# = curtrn#
500 AC                   eval      svtrn2 = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   move      fmitem        lbitem
415cAC                   move      fmdisp        lbdisp
415cAC                   move      todisp        lbdsp2
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = *on
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
500kMC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   move      toitem        lbitem
415cAC                   move      todisp        lbdisp
415cAC                   move      fmdisp        lbdsp2
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = *on
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500 DC                   eval      svtrn2 = curtrn#
415cAC                   move      '*YES'        newtrn
500 A*
500 A*     - Update current transaction.
500 A*
500 AC                   exsr      zztrnupdate
500 A*
415cAC                   endsl
415cA*
415cA*    Create transfer record for breakdown 2 qty.
415cA*
415cAC                   select
415cAC                   when      w1qt03 <> 0
500 MC                   eval      lbucod = #fromitum3
415cAC                   eval      lbqalc = w1qt03
415cAC                   eval      lbqpck = w1qt03
500 MC                   if        #fromitumq3 > 0
500 MC     #fromitcube   div(h)    #fromitumq3   lbucub
500 MC     #fromitswgt   div(h)    #fromitumq3   lbuwgt
415cAC                   else
500 MC                   eval      lbuwgt = #fromitswgt
500 MC                   eval      lbucub = #fromitcube
415cAC                   endif
415cAC     lbucub        mult      w1qt03        lbcube
415cAC     lbuwgt        mult      w1qt03        lbswgt
600bA*    Save extended weight for item adjustment record.
600bAC                   add       lbswgt        exwgfm
415cA*
500 MC                   eval      lbtie = #fromittie
500 MC                   eval      lbhigh = #fromithigh
415cA*
415cA* TO Slot.
415cA*
650gAC                   eval      tocwgt = #newfromitcwgt
650gA*
500 MC                   eval      lbwhs2 = $pwhse
500 MC                   eval      lbwhd2 = #toslwhdp
500 MC                   eval      towhdp = #toslwhdp
500 MC                   eval      lbasl2 = #toslaisl
415cA*
500cMC                   eval      lbloc2 = #toslloc
500 MC                   eval      lblvl2 = #toslrlvl
500 MC                   eval      lbhnd2 = #toslhand
500 MC                   eval      todisp = #tosldisp
415cAC                   eval      lbrte = *blanks
415cAC                   move      w1itm         toitem
415cAC                   eval      lbpbat = 0
415cAC                   eval      lbutyp = '2'
415cAC                   if        newtrn = '*YES'
500 AC                   exsr      zztrnclose
500 AC                   exsr      zztrnstart
500 AC                   endif
415cA*
500 MC                   eval      lbtrn# = curtrn#
500 AC                   eval      svtrn3 = curtrn#
415cAC                   eval      lbctr# = 0
415cA*     - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   move      fmitem        lbitem
415cAC                   move      fmdisp        lbdisp
415cAC                   move      todisp        lbdsp2
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = *on
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'A'
415cAC                   eval      lbtype = 'T'
500kMC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
415cA*
415cA*     - Create second label record
415cA*         - Get new label number.
415cAC                   call      'PIRLBL#'
415cAC                   parm                    lblbl#
415cAC                   move      toitem        lbitem
415cAC                   move      todisp        lbdisp
415cAC                   move      fmdisp        lbdsp2
415cAC                   if        fmitem = toitem
415cAC                   eval      lbgrp1 = *on
415cAC                   else
415cAC                   eval      lbgrp1 = '2'
415cAC                   endif
415cAC                   eval      lbgrp2 = 'B'
415cAC                   eval      lbtype = 'T'
415cAC                   eval      lbstat = 'C'
415cAC                   eval      lbsdte = today
415cAC                   time                    lbstim
415cAC                   eval      lbrdte = today
415cAC                   write     lbrec
500 MC                   eval      svtrn3 = curtrn#
415cAC                   move      '*YES'        newtrn
500 A*
500 A*     - Update current transaction.
500 A*
500 AC                   exsr      zztrnupdate
500 A*
415cAC                   endsl
500 A*
500 A*  Close current transaction.
500 A*
500 AC                   exsr      zztrnclose
     *
414 AC                   if        fmitem <> toitem
FPR AC                             and (client <> FoodPro)
     *  Create adjustment record for "From" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = $pwhse
415 AC                   move      fmitem        iaitem
650aDC**                 eval      iadate = today
650aDC**                 time                    iatime
650aMC                   eval      iadate = tfr2usrDate
650aMC                   eval      iatime = tfr2usrTime
600eMC                   eval      iaby = #curruser
415 AC                   move      fmwhdp        iawhdp
415 AC                   move      fmdisp        iadisp
600bA*    Catchweight item, update extended weight transferred.
600bAC                   if        fmcwgt = 'Y'
MRTbAc                             or client = merit
MRTbAc                             and w2cwt <> 0
530aAC                   if        w2cwt  = 0
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
416jMC                   eval      iacode = w2adj
415 AC     'To'          cat       toitem:1      iamemo

EFCbA*    Add slot status to end of memo for some clients.
EFCbA
EFCbAC                   if        client = eastland
EFCbAC                   eval      %subst(iamemo:28:3) = '-' + #toslstat
EFCbAC                   endif

415 AC                   write     iarec
     *  Create adjustment record for "To" item.
415 AC                   clear                   iarec
415 AC                   eval      iawhse = $pwhse
415 AC                   move      toitem        iaitem
415 AC                   eval      iadate = today
415 AC                   time                    iatime
600eMC                   eval      iaby = #curruser
415 AC                   move      towhdp        iawhdp
415 AC                   move      todisp        iadisp
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
416SAC                   eval      iaqty1 = toqty1
415 AC                   eval      iaqty2 = w1qt02
415 AC                   eval      iaqty3 = w1qt03
416jMC                   eval      iacode = w2adj
415 AC     'From'        cat       fmitem:1      iamemo

EFCbA*    Add slot status to end of memo for some clients.
EFCbA
EFCbAC                   if        client = eastland
EFCbAC                   eval      %subst(iamemo:28:3) = '-' + #fromslstat
EFCbAC                   endif

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
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZDFT3   Get default values for add.
416aA*
416aAC     zzdft3        begsr
416aA*
416aA*   This program is only called with *CHANGE.
416aA*
416aAC                   endsr
417 A*
     *----------------------------------------------------------------
     *
     *  ZZFIL0   Fill screen 1 & 2 heading fields.
     *
     C     zzfil0        begsr
500 MC                   move      $slitem       w1item
     *
     *   Convert quantity to string.
     *
     C                   eval      $ccmd = '*QTY2STR'
     C                   move      '#PROG   '    $cprg            10
     *
500 MC                   eval      $cqty1 = $slavl1
500 MC                   eval      $cqty2 = $slavl2
500 MC                   eval      $cqty3 = $slavl3
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
700jAC                   if        $slalc1 <> 0
700jAC                             or $slalc2 <> 0
700jAC                             or $slalc3 <> 0
700jAC                             or $slpck1 <> 0
700jAC                             or $slpck2 <> 0
700jAC                             or $slpck3 <> 0
700jAC                   eval      *in42 = *on
700jAC                   eval      w1pend = 'PEND'
700jAC                   else
700jAC                   eval      *in42 = *off
700jAC                   eval      w1pend = '    '
700jAC                   endif
     *
     *  Get status description.
     *
500 MC     $slstat       chain     slotstat                           79
     C                   if        *in79
     C                   eval      ssdesc = *blanks
500 MC                   movel     $slstat       ssdesc
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
416s C                   eval      fmtype = *blanks
416s C                   eval      totype = *blanks
416s C                   eval      umq2 = 0
416s C                   eval      fmqmq2 = 0
416s C                   eval      toumq2 = 0
     *
     *   Get item record.
     *
500 MC                   eval      fmumq2 = #fromitumq2
500 MC                   eval      $iitem = #fromititem
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   eval      $idesc = *blanks
500 MC                   eval      w61dsc = #fromitdesc
610aAC                   if        client = saval
610aMC                   movel     w61dsc        w71ds1
610aMC                   move      w61dsc        w71ds2
610aAC                   endif
     *
415gAC                   other
500 MC                   eval      $idesc = #fromitdesc
415gAC                   endsl
500 MC                   eval      $ipdsc = #fromitpdsc
413 AC                   eval      $istr = *blanks
413 AC                   call      @fmtit
413 AC                   parm                    $iitem           15
413 AC                   parm                    $idesc           30
413 AC                   parm                    $ipdsc           15
413 AC                   parm                    $istr            70
413 DC                   eval      w1item = *blanks
413 AC                   movel     $istr         w1item
415gAC                   movel     $istr         w61itm
500 MC                   eval      w1itm = #fromititem
500 DC**
500 DC**  Get SSB item, if one exists
500 DC**
413 AC                   eval      w1lbls = *blanks
413 AC                   eval      w1itms = *blanks
413 A*
413 AC                   eval      w1um1 = *blanks
413 AC                   eval      w1um2 = *blanks
413 AC                   eval      w1um3 = *blanks
413 AC                   exsr      zzuom
500 MC                   if        ssbflg = *on
413 AC                   movel     'SSB ('       w1lbls
413 AC     w1lbls        cat       w1um2:0       w1lbls
413 AC     w1lbls        cat       ')':0         w1lbls
413 AC                   move      ':'           w1lbls
413 A*
413 AC                   eval      $istr = *blanks
413 AC                   call      @fmtit
500 MC                   parm                    #fromssbititem
500 MC                   parm                    #fromssbitdesc
500 MC                   parm                    #fromssbitpdsc
413 AC                   parm                    $istr
413 AC                   movel     $istr         w1itms
413 A*
413 AC                   endif
    A*
500 MC                   move      #fromitwhdp   w1whdp
     *
HSYbAC                   eval      w1pslt = *blanks
HSYbA*
HSYbA*    Retrieve pick slot.
HSYbA*
HSYbAC                   if        client = halsey
HSYbAC                   eval      $scmd = '*FIRST  '
HSYbAC                   call      'GETPSLT'
HSYbAC                   parm                    $scmd             8
HSYbAC                   parm      $itwhse       $swhse            3 0
HSYbAC                   parm      $iitem        $sitem           15
HSYbAC                   parm      *blanks       woslot           12
HSYbAC                   parm      *blanks       $saisl            3
HSYbAC                   parm      *zeros        $sloc             3 0
HSYbAC                   parm      *zeros        $srlvl            2 0
HSYbAC                   parm      *blanks       $shand            2
HSYbAC                   parm      *blanks       $srtn             8
HSYbA*
HSYbAC                   if        $srtn = '*OKPICK '
HSYbAC                   eval      w1pslt = woslot
HSYbAC                   else
HSYbAC                   eval      w1pslt = '*NONE       '
HSYbAC                   endif
HSYbAC                   endif
     *   Initialize entry fields
     *
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     C                   eval      w1qt01 = 0
     C                   eval      w1qt02 = 0
     C                   eval      w1qt03 = 0
     *
     *   Initialize header fields. Save quantities and status for
     *     comparison before updating.
     *
     C                   exsr      zzfil0
500 MC                   move      $sldisp       fmdisp
413EAC                   eval      w1itm = $slitem
     *
415gAC                   eval      wofrom = $pdisp
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
650fA*    Force new license if tranfer from pick slot.
650fAC                   if        Ypickslot = *on
650fAC                             and partial = *off
SBRbAc                             or #FROMSLAISL = 'OSS'
SBRbAc                             and partial = *off
SBRbAc                             and client = SBertram
ADFbAc                             or #FROMSLAISL = 'OSS'
ADFbAc                             and partial = *off
ADFbAc                             and client = AandDFoods
FGLaAc                             or #FROMSLAISL = 'OSS'
FGLaAC                             and partial = *off
FGLaAC                             and client = FoodsGalore
MQSaAc                             or #FROMSLAISL = 'OSS'
MQSaAC                             and partial = *off
MQSaAC                             and client = Marques
650fAC                   eval      $tlic#    = '*MULTIPLE'
650fAC                   endif
610fAC                   exsr      zzzcall$lt210
700cA*    If *CANCEL sent back,
700cAC                   if        $treturn = '*CANCEL'
700cAC                   exsr      zzcancel2
700nAC                   exsr      zzcancel
700nDC*                  move      '01 '         nxtscr
700nMC                   move      'EOJ'         nxtscr
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
510cAC                   eval      w2pslt = *blanks
530aAC                   eval      w2cwt = *zero
500 MC                   if        #fromslitem <> w1itm
416jAC                   eval      w2adj = 'CI'
416jAC                   else
416jAC                   eval      w2adj = *blanks
416jAC                   endif
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
SVLcAC                   if        client = saval
SVLcAC                             and w2adj = 'CI'
SVLcAC                   eval      w2adj = *blanks
SVLcAC                   endif
FPRcAC                   if        client = FoodPro
FPRcAC                             and w2adj = 'CI'
FPRcAC                   eval      w2adj = *blanks
FPRcAC                   endif
     *
     *   Get item record.
     *
413eAC                   eval      $iitem = w1itm
415gAC                   select
415gAC                   when      #lline = '16'
415gAC                   eval      $idesc = *blanks
500 MC                   eval      w62dsc = #newfromitdesc
610aAC                   if        client = saval
610aMC                   movel     w62dsc        w72ds1
610aMC                   move      w62dsc        w72ds2
610aAC                   endif
     *
415gAC                   other
500 MC                   eval      $idesc = #newfromitdesc
415gAC                   endsl
500 MC                   eval      $ipdsc = #newfromitpdsc
413eAC                   eval      $istr = *blanks
413eAC                   call      @fmtit
413eAC                   parm                    $iitem
413eAC                   parm                    $idesc
413eAC                   parm                    $ipdsc
413eAC                   parm                    $istr
413eAC                   eval      w2item = *blanks
413eAC                   movel     $istr         w2item
415gAC                   movel     $istr         w62itm
510cA*
510cA*    Retrieve hard/soft item designation code.
510cA*
720 DC*                  eval      $scmd = '*FIRST  '
510cAC                   call      'GETPSLT'
510cAC                   parm                    $scmd             8
510cAC                   parm      $itwhse       $swhse            3 0
510cAC                   parm      $iitem        $sitem           15
720 DC*                  parm      *blanks       woslot           12
720 Ac                   parm                    woslot           12
510cAC                   parm      *blanks       $saisl            3
510cAC                   parm      *zeros        $sloc             3 0
510cAC                   parm      *zeros        $srlvl            2 0
510cAC                   parm      *blanks       $shand            2
510cAC                   parm      *blanks       $srtn             8
510cA*
510cAC                   if        $srtn = '*OKPICK '
510cAC                   eval      w2pslt = woslot
720bAc                   eval      prvPick = woslot
510cAC                   else
720bAc                   if        not *inkk
510cAC                   eval      w2pslt = '*NONE       '
720bAc                   else
720bAc                   eval      w2pslt = prvPick
720bAc                   endif
510cAC                   endif
415bA*
415bA*    Retrieve hard/soft item designation code.
415bA*
     C                   eval      itdtyp = *blanks
500 MC                   if        $itdesg > *blanks
415bAC                   eval      $lcmd = '*VERIFY '
500 MC                   eval      $ldsg = $itdesg
415bAC                   call      'DS900'
415bAC                   parm                    $lparm
415bAC                   select
415bAC                   when      $lrtn = '*OK     '
415bAC                   move      $ltyp         itdtyp
415bAC                   when      $lrtn = '*ERROR  '
415bAC                   move      *on           error
415bAC                   eval      *in21 = *on
415bAC                   eval      *in01 = *on
415bAC                   movel     $lerm         errmsg
415bAC                   exsr      zm0105
415bAC                   when      $lrtn = '*PGMQ   '
415bAC                   move      *on           error
415bAC                   eval      *in21 = *on
415bAC                   eval      *in01 = *on
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
500 MC                   if        newssbflg = *on
413eAC                   eval      w2um1 = *blanks
413eAC                   eval      w2um2 = *blanks
413eAC                   eval      w2um3 = *blanks
500 MC                   exsr      zzuomnew
413eAC                   movel     'SSB ('       w2lbls
413eAC     w2lbls        cat       w2um2:0       w2lbls
413eAC     w2lbls        cat       ')':0         w2lbls
413eAC                   move      ':'           w2lbls
413eA*
500 AC                   eval      w1um1 = *blanks
500 AC                   eval      w1um2 = *blanks
500 AC                   eval      w1um3 = *blanks
500sAC                   exsr      zzuom
413eA*
413eAC                   eval      $istr = *blanks
413eAC                   call      @fmtit
500 MC                   parm                    #newfromititem
500 MC                   parm                    #newfromitdesc
500 MC                   parm                    #newfromitpdsc
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
700cMC     endfl2        endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZFIL3   Fill screen 3 fields with info from file.
416aA*
416aAC     zzfil3        begsr
416aA*
415gAC                   select
416aA*
416aA*    16 Line screen in use.
415gAC                   when      #lline = '16'
416aAC                   eval      w63itm = w61itm
416aAC                   eval      w63dsc = w61dsc
610aAC                   if        client = saval
610aMC                   movel     w63dsc        w73ds1
610aMC                   move      w63dsc        w73ds2
610aAC                   endif
     *
416aA*
416aAC                   other
416aA*
416aAC                   eval      w3item = w1item
416aAC                   eval      w3lbls = w1lbls
416aAC                   eval      w3itms = w1itms
416aA*
416aAC                   endsl
416aA*
416aAC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGET1   Get record(s) for screen 1.
     *
     C     zzget1        begsr
500 A
500 A*  Use DRI interface to get slot information.
500 A
     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $pwhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $pdisp

     C                   eval      $dricommand = '*SLOT'
600nDC**                 eval      $drisubcmd  = '%GETCHKV'
600nMC                   eval      $drisubcmd  = '%GETCHKVX'
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
640dAC                   eval      #fromslstat = $slstat
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
500 AC                   eval      #fromslstk1 = $slstk1
500 AC                   eval      #fromslstk2 = $slstk2
500 AC                   eval      #fromslstk3 = $slstk3
500 AC                   eval      #fromslalc1 = $slalc1
500 AC                   eval      #fromslalc2 = $slalc2
500 AC                   eval      #fromslalc3 = $slalc3
500 AC                   eval      #fromsltfr1 = $sltfr1
500 AC                   eval      #fromsltfr2 = $sltfr2
500 AC                   eval      #fromsltfr3 = $sltfr3
500 AC                   eval      #fromslpck1 = $slpck1
500 AC                   eval      #fromslpck2 = $slpck2
500 AC                   eval      #fromslpck3 = $slpck3
500 AC                   eval      #fromslrcv1 = $slrcv1
500 AC                   eval      #fromslrcv2 = $slrcv2
500 AC                   eval      #fromslrcv3 = $slrcv3
500 AC                   eval      #fromslphy1 = $slphy1
500 AC                   eval      #fromslphy2 = $slphy2
500 AC                   eval      #fromslphy3 = $slphy3
500 AC                   eval      #fromslavl1 = $slavl1
500 AC                   eval      #fromslavl2 = $slavl2
500 AC                   eval      #fromslavl3 = $slavl3
600eAC                   eval      #fromToLcns = $saToLcns
600eAC                   eval      #fromToPos  = $saToPos
600eAC                   eval      #fromOLcns = $saOLcns

     C                   eval      #frombasesldsp = $sacdsp
500 A
     *
     *  Slot does not contain an item.
     *
500 MC                   if        $slitem = *blanks
     C                   move      *on           error
     C                   eval      $prtn = '*PGMQ   '
     C                   exsr      zm15
     C                   goto      endgt1
     C                   endif
500 A
500 A*  Use DRI interface to get slot definition.
500 A
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
500 A
500 A*  Use DRI interface to get item.
500 A
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
500 A
500 A*  Save tie/high info if defined for item.
500 A
     C     1             do        5             i
     C                   if        $idsdef(i) = #fromslsdef
     C                   eval      #fromitsdef = $idsdef(i)
     C                   eval      #fromittie  = $idtie(i)
     C                   eval      #fromithigh = $idhigh(i)
     C                   leave
     C                   endif
     C                   enddo
500 A
500 A*  Use DRI interface to get corresponding SSB item, if any.
500 A
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
500 A
500 A*  Get new item information.
500 A
500 A*    When item number didn't change.
500 A
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
500 A
500 A*    When item number changed.
500 A
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
650iA
650iA*    When item number changed is an SSB item - must use case item
650iAc
650iAc                   if        $ittype = 'S'
650iAc                   eval      w1itm = $itmitem
650iAC                   exsr      clr$item
650iAC                   eval      $itwhse  = $slwhse
650iAC                   eval      $ititem  = w1itm

650iAC                   eval      $dricommand = '*ITEM'
650iAC                   eval      $drisubcmd  = '%GETMAIN'
650iAC                   eval      $drisys2upd = 'D'
650iAC                   eval      chk4err = *on
650iAC                   eval      zmsflag = *on
650iAC                   exsr      zzzdricop
650iAC                   if        error
650iAC                   eval      $prtn = '*PGMQ   '
650iAC                   goto      endgt2
650iAC                   endif
650iAc                   endif

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
500 A
500 A*  Use DRI interface to get corresponding SSB item, if any.
500 A
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
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZGET3   Get record(s) for screen 3.
416aA*
416aAC     zzget3        begsr
416aAC     endgt3        endsr
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
600fDC     wktkeyu       klist
600fDC                   kfld                    #curruser
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
600lA*
600lA*  Define key for WORKOSS file.
600lA*
600lAC     keywo         klist
600lAC                   kfld                    $pwhse
600lAC                   kfld                    osslcns
600lA*
600lA*  Define partial key for WORKOSS1 file.
600lA*
600lAC     keywo1        klist
600lAC                   kfld                    #curruser
600lAC                   kfld                    #job
600lAC                   kfld                    #jobnbr
SGCcA*
SGCcA*  Define full Key For SLOT2
SGCcA*
SGCcAC     slotky        klist
SGCcAC                   kfld                    $pwhse
SGCcAC                   kfld                    $pwhdp
SGCcAC                   kfld                    w2disp
SGCcA*
SGCcA*  Define part Key For SLOT2
SGCcA*
SGCcAC     slotky1       klist
SGCcAC                   kfld                    $pwhse
SGCcAC                   kfld                    $pwhdp
     *
     *  Convert today's date into century format.
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     *
413EAC                   move      *off          forevr
415cAC                   move      '*NO '        newtrn
415dAC                   move      *off          dteold
415dAC                   move      *off          dteofl
415hAC                   move      *off          toslup
416aAC                   move      *off          skpslt
SVLbAC                   if        client = saval
GLPaAc                             or client = greenleaf
SVLbAC                   eval      woyn = '(1,9)'
610bAC                   else
610bAC                   eval      woyn = '(Y,N)'
SVLbAC                   endif
     *
     C                   eval      $lprg = #prog
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
720 AC                   eval      $scmd = '*FIRST'
720 AC                   eval      woslot = *blanks
650kA   // setup array to verify production slots for WIP and Lines
650kA /free
650kA                    sltc = 1;
650kA                    dow sltc < 101;
650kA                       prdslt(sltc) = '   ';
650kA                       sltc = sltc +1;
650kA                    enddo;
650kA
650kA                    setll (*zeros:*zeros) plined;
650kA                    read plined;
650kA                    dow not %eof(plined);
650kA
650kA                       sltc = 1;
650kA                       // look for raw material aisle location
650kA                       dow sltc < 101;
650kA                          if prdslt(sltc) = '   '
650kA                              or prdslt(sltc) = inRcvAisl;
650kA                             leave;
650kA                          endif;
650kA                          sltc = sltc +1;
650kA                       enddo;
650kA                       // if comes out blank it means we should
650kA                       // add to the array of prod slot aisles
650kA                       if prdslt(sltc) = '   ';
650kA                          prdslt(sltc) = inRcvAisl;
650kA                       endif;
650kA
650kA                       sltc = 1;
650kA                       // look for WIP Stock aisle location
650kA                       dow sltc < 101;
650kA                          if prdslt(sltc) = '   '
650kA                              or prdslt(sltc) = inWipAisl;
650kA                             leave;
650kA                          endif;
650kA                          sltc = sltc +1;
650kA                       enddo;
650kA                       // if comes out blank it means we should
650kA                       // add to the array of prod slot aisles
650kA                       if prdslt(sltc) = '   ';
650kA                          prdslt(sltc) = inWipAisl;
650kA                       endif;
650kA
650kA                       read plined;
650kA                    enddo;
650kA /end-free
610gAC                   eval      currRoutine = 'zzinz2'
610gAC                   exsr      phpgmV1V2V3s
650jAC                   move      '0'           dfchk
     C                   eval      tfroutflag = *off
600lAC                   eval      ossDisp = ' '
600lAC                   eval      ossLcns = ' '
     *
414gAC                   eval      worow = 0
414gAC                   eval      wocol = 0
600mA*
600mA*  Do not allow the transfer from a RCV/STG file.
600mA*
600mAC                   if        %subst($pdisp:1:3) = 'RCV'
600mAC                             or %subst($pdisp:1:3) = 'STG'
710cAC                             or %subst($pdisp:1:3) = 'RTN'
730aAC                             or %subst($pdisp:1:3) = 'RWO'
600mAC                   eval      error = *on
730aDC*                  eval      errmsg = 'RCV/STG slot not allowed '
730aMC                   eval      errmsg = 'RCV/STG/RTN/RWO  slot not allowed '
600mAC                                    + '- use Putaway'
600mAC                   exsr      zm0105s
600mAC                   eval      nxtscr = 'EOJ'
600mAC                   leavesr
600mAC                   endif
415gA*
415gA*   Get screen size being used.
415gA*
415gAC                   call      'PIRRFSCR'
415gAC                   parm      '*GET'        #lcmd             8
415gAC                   parm                    #lline            2
415gAC                   parm                    #lcol             3
417cA*
417cA*    - Get default values for the user.
417cA*
417cAC                   call      'GETUSER'
600eMC                   parm                    #curruser
417cAC                   parm      0             #whse             3 0
417cAC                   parm      0             #emp#             5 0
417cAC                   parm                    #fnam            15
417cAC                   parm                    #init             1
417cAC                   parm                    #lnam            20
417cAC                   parm                    #whdp             5
417cAC                   parm                    #styp             1
417cAC                   parm                    #shft             6
417cAC                   parm                    #crew             6
417cAC                   parm      0             #nhrs             3 1
417cAC                   parm                    #rtn              8
600dAC                   parm                    e$bpu             1
600dAC                   parm                    e$lng             2
600dAC                   if        #rtn <> '*OK'
600dAC                   eval      e$lng = 'EN'
600dAC                   endif
600eA*
600eA*   Clear work file for user.
600eA*
600eAC                   exsr      zzwrkinz
600lAC                   exsr      zzwodltjob
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
600cA*
600cA*    Retrieve Check "To Slot" quantity option.
600cA*
600cAC                   exsr      zzcqty
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
414cA*
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
     C                   move      '*PICK   '    kycode
     C     keyopd        chain     optiond                            79
     C                   if        *in79
     C                   eval      opmput = 'N'
     C                   endif
     *
     *   Select first screen to display.
     *
412 AC                   eval      odisp = *blanks
416aAC                   eval      vfyslt = *blanks
416aAC                   eval      vrtslt = *off
     C                   eval      lock = *off
     C                   eval      exist = *off
     C                   eval      usesc = 1
     C                   exsr      scr01i
412 AC                   eval      odisp = *blanks
500 A
500 A*   If an error didn't occur and we are staying in this pgm
640aA*  and license not passed in...
500 A
500 AC                   if        nxtscr <> 'EOJ'
640bD ***                          and $plcns = *blanks
640bAC                   select
640bAC                   when      $plcns = *blanks
600eA
600eAC                   eval      curlic# = #fromToLcns
500 A
500 A*    Call program that will (if necessary) ...
500 A*      - Prompt user to pull pallet.
500 A*      - Have user verify license being pulled.
500 A*      - Update license information.
500 A
500 AC                   exsr      zzzclr$lt210
500 AC                   eval      $tcmd  = '*PULDROP'
500 AC                   eval      $twhse = $pwhse
500 AC                   eval      $twhdp = #fromslwhdp
500 AC                   eval      $tslot = #fromsldisp
500 AC                   eval      $titem = #fromslitem
500 AC                   eval      $titemdsc = #fromithead
600eAC                   eval      $tlic# = #fromToLcns
500 AC                   exsr      zzzcall$lt210
600eDC**                 eval      curlic# = $tlic#
500 A
500 AC                   if        $treturn = '*CANCEL'
500 AC                   eval      nxtscr = 'EOJ'
500 AC                   endif
500 A
500 AC                   if        $treturn = '*NOTFND'
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
500 AC                   eval      nxtscr = 'EOJ'
500 AC                   endif
500 A
640bAC                   other
640bAC                   eval      curlic# = $plcns
640bAC                   endsl
500 AC                   endif
500 A
500 A*    Start transaction.
600eA*    Add record to work file.
500 A
500 AC                   if        nxtscr <> 'EOJ'
500 AC                   eval      lbwhdp = #fromslwhdp
500 AC                   eval      lbstyp = #fromslstyp
500 AC                   exsr      zztrnstart
600hDC**                 exsr      zzwrkadd
500 AC                   endif
500 A
     C                   endsr
500 A
600cA*----------------------------------------------------------------
600cA*
600cA*  ZZCQTY   Retrieve Check "To Slot" quantity option.
600cA*
600cAC     zzcqty        begsr
600cA*
600cAC                   eval      kywhse = $pwhse
600cAC                   eval      opcode = '*REPLEN '
600cAC     optsky        chain     options                            79
600cA*
600cA*    Record not found. Set defaults to No
600cA*
600cAC                   if        *in79
600cAC                   eval      opcqty = 'N'
600cA*
600cA*    Record found. Load file data structure.
600cAC                   else
600cAC                   eval      opdta3 = opdata
600cA*
600cAC                   endif
600cA*
600cAC                   endsr
600cA*
500 A*----------------------------------------------------------------
500 A*  ZZCHKZROVFY   See if we should ask user to zero verify slot.
500 A*----------------------------------------------------------------
500 A
500 AC     zzchkzrovfy   begsr

     *  See if zero verify flag should be set.

     C                   eval      verifyzero = *off
     C                   dow       forever = forever

     *      Ask the user to zero verify slot if ...

     *      ... the slot only has 1 pallet position.

     C                   if        #fromslpos > 1
     C                   leave
     C                   endif

     *      ... the slot doesn't have a virtual slot associated with it.

     C                   if        #fromslvirt = 'Y'
     C                   leave
     C                   endif
600nA
600nA*      ... %TFR2USR, which is called just before calling this
600nA*          routine, says the slot is empty.
600nA
600nAC                   if        wuPulVfy <> 'Y'
600nAC                   leave
600nAC                   endif
600nDC**
600nDC**     ... slot quantities don't reflect other activity.
600nDC**
600nDC**                 if        #fromslalc1 <> 0 or
600nDC**                           #fromslalc2 <> 0 or
600nDC**                           #fromslalc3 <> 0 or
600nDC**                           #fromslrcv1 <> 0 or
600nDC**                           #fromslrcv2 <> 0 or
600nDC**                           #fromslrcv3 <> 0 or
600nDC**                           #fromsltfr1 <> 0 or
600nDC**                           #fromsltfr2 <> 0 or
600nDC**                           #fromsltfr3 <> 0
600nDC**                 leave
600nDC**                 endif
600nDC**
600nDC**     ... no stock will be left in slot.
600nDC**
600nDC**         (These values were recalculated and sent back from doing
600nDC**          the TFROUTCHG command. Since all of the original #FROM
600nDC**          buckets were zero, if the new Avail quantities are not
600nDC**          all zero, then the entire quantity is not being taken.
600nDC**
600nDC**                 if        $slavl1 <> 0 or
600nDC**                           $slavl2 <> 0 or
600nDC**                           $slavl3 <> 0
600nDC**                 leave
600nDC**                 endif

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

500 A
500 AC                   endsr
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZCVDT  Convert date to proper format.
416aA*
416aAC     zzcvdt        begsr
416aA*
416aA*    Convert date into proper format.
416aA*
416aAC                   call      @cvtdt
416aAC                   parm                    $cvtdt
416aA*
416aAC     endcvd        endsr
417dA*
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZEXCP Write item exception record to file.
416aA*
416aAC     zzexcp        begsr
416aA*
416aA*    Write an item exception record.
416aAC                   eval      exwhse = $pwhse
416aAC                   eval      exwhdp = $pwhdp
416aAC                   eval      exstyp = #fromslstyp
4164MC                   eval      exitem = #fromslitem
416aAC                   eval      exfdis = #fromsldisp
416aAC                   eval      extdis = *blanks
416uMC                   eval      extask = 'TFRMOV'
416aA*    Get todays date.
416aAC                   eval      $cvcmd = '*CURCMD '
416aAC                   exsr      zzcvdt
416aAC                   eval      exgdte = $cvd8o
416aAC                   time                    exgtim
600eMC                   eval      exgby = #curruser
416aAC                   eval      exesta = '1 '
416aAC                   write     exrec
416aA*
416aAC     endexc        endsr
600lA*----------------------------------------------------------------
600lA*
600lA*  ZZEXTSTG   Offsite Storage Label creation
600lA*
     C     zzextstg      begsr
     C                   eval      w9dev  = '*JOB'
     C                   eval      w9stg  = 'E'
710dAC                   eval      w9prt  = 'N'

     *  Springfield setup defaults for screen

SGCaAC                   if        client = sgc
SGCaAC                   if        #newfromitwhdp = 'DRY  '
SGCaAC                   eval      w9stg = 'K'
SGCaAC                   eval      w9dev  = 'LP8'
SGCaAC                   else
SGCaAC                   eval      w9stg = 'W'
SGCaAC                   eval      w9dev  = 'LP7'
SGCaAC                   endif
710dAC                   eval      w9prt  = 'Y'
SGCaAC                   endif

EFCaAC                   if        client = eastland
EFCaAC                   if        #newfromitwhdp = 'CB   '
EFCaAC                   eval      w9stg = 'G'
EFCaAC                   else
EFCaAC                   eval      w9stg = 'F'
EFCaAC                   endif
710dAC                   eval      w9prt  = 'Y'
EFCaAC                   endif
     *  Process window to produce license plates for external storage

     C                   dow       forevr = forevr
     C                   exfmt     WEXTSTG
     C                   if        *inkl = *on
     C                   leave
     C                   endif

     *     No errors, create slot and print label

     C                   exsr      zzextstg2
     C                   if        not error
     C                   eval      w2disp = ossdisp
     C                   endif
     C                   leave

     C                   enddo

     C                   endsr
600lA*----------------------------------------------------------------
600lA*
600lA*  ZZEXTSTG2  Create OSS slot
600lA*
600lAC     zzextstg2     begsr

     *  Set #rcvarea to apppropriate OSS area.

     C                   select

     C                   when      client = sgc
     C                             and w9stg = 'K'
     C                   eval      #rcvarea = 'KANSAS'

     C                   when      client = sgc
     C                             and w9stg = 'W'
     C                   eval      #rcvarea = 'WILLOW'

EFCaAC                   when      client = eastland
EFCaAC                             and w9stg = 'G'
EFCaAC                   eval      #rcvarea = 'CGEN'

EFCaAC                   when      client = eastland
EFCaAC                             and w9stg = 'F'
EFCaAC                   eval      #rcvarea = 'CFROZ'

     C                   other
     C                   eval      #rcvarea = w9stg

     C                   endsl
SBRaA*  Use generic license OR create special license
710dA*  Change the client specific logic to use the new print field.
700hAC                   select
710dDC*                  when      client = SBertram or
710dDC*                            client = FoodsGalore
710dAc                   When      w9prt <> 'Y'
SBRaA
SBRaA*    Call license tracking for putaway - Before update
SBRaA*    to force new license.
SBRaA
SBRaAC***                if        rtnToOrig = *off
SBRaA
SBRaAC                   exsr      zzzclr$lt210
SBRaAC                   eval      $tcmd     = '*PUTAWYB'
SBRaAC                   eval      $tlic#    = wuUsrLcns
SBRaAC                   eval      $tpartial = partial
SBRaAC                   eval      $twhse    = $pwhse
SBRaAC                   eval      $twhdp    = #toslwhdp
SBRaAC                   eval      $tslot    = #tosldisp
SBRaAC                   eval      $titem    = w1itm
SBRaAC                   eval      $titemdsc = #newfromithead
SBRaAC                   eval      $tqty1    = toqty1
SBRaAC                   eval      $tqty2    = w1qt02
SBRaAC                   eval      $tqty3    = w1qt03
SBRaAC                   eval      $tnorm1   = toqty1
SBRaAC                   eval      $tnorm2   = w1qt02
SBRaAC                   eval      $tnorm3   = w1qt03
SBRaA*    Force new license if tranfer to OSS
710dAc                   Select
710dAC                   when      client = SBertram or
710dAC                             client = FoodsGalore
ADFaAC                             or client = AandDFoods
SBRaAC                   eval      $tlic#    = '*MULTIPLE'
710dAc                   other
710dAc                   if        %subst(wuUsrLcns:1:1) = '*'
710dAC                   eval      $tlic#    = '*MULTIPLE'
710dAc                   else
710dAC                   eval      $tlic#    = ' '
710dAc                   endif
710dAc                   endsl
SBRaAC                   exsr      zzzcall$lt210
SBRaA*
710dAc                   if        $tlic# = '*MULTIPLE'
SBRaAC                   eval      ossLcns = $tinlic#
710dAc                   else
710dAC                   eval      ossLcns = ' '
710dAc                   endif

700hAC                   other
     *  Create special license

     C                   call      'PIROSSLCN'
     C                   parm                    $pwhse
     C                   parm                    w9stg
     C                   parm      ' '           ossLcns          15
700hAC                   endsl

     *  Initialize slot fields

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $pwhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = #newfromitwhdp
     C                   eval      $slitemu = *on
     C                   eval      $slitem  = w1itm
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = ' '
     C                   eval      $slstypu = *on
     C                   eval      $slstyp = #newfromitstyp
     C                   eval      $slentdu = *on
     C                   eval      $slentd  = #fromslentd
     C                   eval      $slexpdu = *on
     C                   eval      $slexpd = #fromslexpd
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = w1itm

     C                   eval      $saqtyu = *on
     C                   eval      $saqty1 = 0
     C                   eval      $saqty2 = 0
     C                   eval      $saqty3 = 0

     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'TFR'
     C                   eval      $saTrn#U = *on
     C                   eval      $saTrn# = 0
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0
     C                   eval      $saLbl#U = *on
     C                   eval      $saLbl# = 0
     C                   eval      $saToPosU = *on
     C                   eval      $saToPos = 1
     C                   eval      $saToVrfyU = *on
     C                   eval      $saToVrfy = 'N'
     C                   eval      $saToCodeu = *on
     C                   eval      $saToCode = 'D'
     C                   eval      $saToAreaU = *on
     C                   eval      $saToArea = #rcvarea

     C                   eval      $saToLcnsU = *on
     C                   eval      $saToLcns = ossLcns
     C                   eval      $saOLcnsU = *on
     C                   eval      $saOLcns = ossLcns

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%OSSIN'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C**                 eval      zmflag  = *on
     C                   exsr      zzzdricop
     C                   if        error
     C                   leavesr
     C                   endif

     C                   eval      ossDisp = $sldisp

     *  Create workoss record

     C                   eval      wowhse  = $slwhse
     C                   eval      wowhdp  = $slwhdp
     C                   eval      wodisp  = $sldisp
     C                   eval      wolcns  = ossLcns
     C                   eval      woaddts   = %timestamp()
     C                   eval      woaddcusr = #curruser
     C                   eval      woaddjob  = #job
     C                   eval      woaddnbr  = #jobnbr
     C                   write(e)  worec

     *  Print label

SBRaA*  Don't print if using Generic license
700hAC                   select
710dAc                   when      w9prt <> 'Y'
SBRaAC                   when      client = SBertram
SBRaA*
FGLaAC                   when      client = FoodsGalore
FGLaA*
ADFaAC                   when      client = AandDFoods
ADFaA*
MQSaAC                   when      client = Marques
MQSaA*
DRYaAC                   when      client = dairyland
DRYaAC                   eval      $plset = 'ZBRDRY'
700hAC                   other
     C                   eval      $plfmt = 'STORAGE'
     C                   if        client = sgc
SGCbDC***                eval      $plset = 'STOSFG'
SGCbMC                   eval      $plset = 'ZBRSF2'
     C                   else
     C                   eval      $plfmt = 'PLBL40'
     C                   endif
     *  *** testing purposes ***
SGCbDC***                eval      $plset = 'STOSFG'

     C                   if        w9dev <> '*JOB'
     C                   eval      $pdev  = w9dev
     C                   endif

     C                   eval      $pexpda = %editc(#fromslexpd:'X')
     C                   eval      $pindta = %editc(#fromslentd:'X')

740bMC                   call      @PRTPG
     C                   parm                    $pcmd             8
     C                   parm                    $plset            6
     C                   parm                    $plfmt            8
     C                   parm      $pwhse        $plwhse           3 0
     C                   parm                    $pwhsd           30
     C                   parm                    $slwhdp
     C                   parm                    $sldisp
     C                   parm                    $pdispa           1
     C                   parm                    $pdispb          11
     C                   parm                    $pchkd1           3
     C                   parm                    $pchkd2           3
     C                   parm                    $pchkd3           3
     C                   parm                    ossLcns
     C                   parm                    $plcn2           15
     C                   parm                    $slitem
     C                   parm                    $pbrnd           10
     C                   parm                    $ppdesc          15
     C                   parm                    $itdesc          30
     C                   parm                    $ptxt1           30
     C                   parm                    $ptxt2           30
     C                   parm                    $ptxt3           30
     C                   parm                    $ptrailr          8
     C                   parm                    $psize            3
     C                   parm                    $pdev            10
     C                   parm                    $pform           10
     C                   parm                    $pexpda           8
     C                   parm                    $pindta           8
700hAC                   endsl

     C                   endsr
600lA*----------------------------------------------------------------
600lA*
600lA*  ZZWODLTJOB     Delete WORKOSS records for current job
600lA*
600lAC     zzWoDltJob    begsr

     C     keywo1        setll     workoss1

     C                   dow       forevr = forevr
     C     keywo1        reade     workoss1
     C                   if        %eof(workoss1)
     C                   leave
     C                   endif

     *    Delete oss slot that was created.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = wowhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = wowhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = wodisp

     *    Note: Action must be OSS for DRISLOT to delete licactive rec.
     C                   eval      $saActionU = *on
     C                   eval      $saAction = 'OSS'
     C                   eval      $saETrn#U = *on
     C                   eval      $saETrn# = 0

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%DELETEX'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C**                 eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   endif

     *    Delete workoss record.

     C                   delete(e) workoss1

     C                   enddo

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZTRNCLOSE  Close a transaction
500 A*----------------------------------------------------------------
500 A
500 AC     zztrnclose    begsr

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

500 A*----------------------------------------------------------------
500 A*  ZZTRNIDLE   Start and IDLE transaction.
500 A*----------------------------------------------------------------
500 A
500 AC     zztrnidle     begsr

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

500 A*----------------------------------------------------------------
500 A*  ZZTRNSTART  Start a transaction
500 A*----------------------------------------------------------------
500 A
500 AC     zztrnstart    begsr

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

500 A*----------------------------------------------------------------
500 A*  ZZTRNUPDATE  Update transaction pcs, cube and weight.
500 A*----------------------------------------------------------------
500 A
500 AC     zztrnupdate   begsr

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
416pAC                   eval      bkdwn1 = '*NO '
416pAC                   eval      bkdwn2 = '*NO '
417gAC                   eval      *in92 = *off
500 MC                   if        #fromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduom
     C                   else
700fA /free
700fA                    if %lookup(%subst($pdisp:1:3):prdslt) > 0;
700fA                       if #fromitum2<>' ';
700fA                          #fromitflg1 = 'Y';
700fA                       endif;
700fA                       if #fromitum3<>' ';
700fA                          #fromitflg2 = 'Y';
700fA                       endif;
700fA                    endif;
700fA /end-free
500 MC                   if        #fromitflg1 = 'N'  and
413 MC                             ssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
500 MC                   if        #fromitflg2 = 'N'  and
413 AC                             ssbflg = *off  or
500 MC                             #fromitflg2 = 'N'  and
413 AC                             ssbflg = *on  and
500 MC                             #fromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
500 MC     #fromitum1    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um1 = umshrt
     C                   else
     C                   eval      w1um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
416pA*
416pA*    Breakdown 1  qty's supported.
500 MC                   if        #fromitumq2 > *zeros
416pAC                   eval      bkdwn1 = '*YES'
416pAC                   endif
500 MC     #fromitum2    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um2 = umshrt
     C                   else
     C                   eval      w1um2 = *blanks
     C                   endif
     C                   endif
     *
     C                   if        not *in93
416pA*
416pA*    Breakdown 2  qty's supported.
500 MC                   if        #fromitumq3 > *zeros
416pAC                   eval      bkdwn2 = '*YES'
416pAC                   endif
500 MC     #fromitum3    chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w1um3 = umshrt
     C                   else
     C                   eval      w1um3 = *blanks
     C                   endif
     C                   endif
     C     enduom        endsr
500 A*----------------------------------------------------------------
500 A*
500 A*  ZZUOMNEW   Get Unit Of Measure Normal, Breakdown1, Breakdown2.
500 A*
500 AC     zzuomnew      begsr
     *
     *   Get Unit of Measures.
     *    *IN92=Protect & non-display breakdown1 unit of measure
     *    *IN93=Protect & non-display breakdown2 unit of measure
     *
416pAC                   eval      bkdwn1 = '*NO '
416pAC                   eval      bkdwn2 = '*NO '
417gAC                   eval      *in92 = *off
500 MC                   if        #newfromititem = ' '
     C                   eval      *in92 = *on
     C                   eval      *in93 = *on
     C                   goto      enduomnew
     C                   else
500 MC                   if        #newfromitflg1 = 'N'  and
413 MC                             newssbflg = *off
     C                   eval      *in92 = *on
     C                   endif
500 MC                   if        #newfromitflg2 = 'N'  and
413 AC                             newssbflg = *off  or
500 MC                             #newfromitflg2 = 'N'  and
413 AC                             newssbflg = *on  and
500 MC                             #newfromitum3 = *blanks
     C                   eval      *in93 = *on
     C                   endif
     C                   endif
     *
500 MC     #newfromitum1 chain     unmesr                             75
     C                   if        not *in75
     C                   eval      w2um1 = umshrt
     C                   else
     C                   eval      w2um1 = *blanks
     C                   endif
     *
     C                   if        not *in92
416pA*
416pA*    Breakdown 1  qty's supported.
500 MC                   if        #newfromitumq2 > *zeros
416pAC                   eval      bkdwn1 = '*YES'
416pAC                   endif
500 MC     #newfromitum2 chain     unmesr                             75
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
500 MC                   if        #newfromitumq3 > *zeros
416pAC                   eval      bkdwn2 = '*YES'
416pAC                   endif
500 MC     #newfromitum3 chain     unmesr                             75
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
     C                   move      *off          error
416j *
416j *   Item changed, set flag for adjustment code entry.
500 MC                   if        #fromslitem <> w1itm
416jAC                   eval      *in59 = *on
720cDC*                  if        #fromitcwgt = 'Y'
720cDC*                            or #newfromitcwgt = 'Y'
720cDC*                  eval      *in60 = *on
720cDC*                  else
720cDC*                  eval      *in60 = *off
720cDC*                  endif
416jAC                   else
416jAC                   eval      *in59 = *off
530aAC                   eval      *in60 = *off
416jAC                   endif
FPR AC*
FPR AC                   if        client = FoodPro
FPR AC*
FPR AC                   if           #fromitcwgt = 'Y'
FPR AC                             or #newfromitcwgt = 'Y'
FPR AC                   eval      *in60 = *on
FPR AC                   else
FPR AC                   eval      *in60 = *off
FPR AC                   endif
FPR AC*
FPR AC                   endif
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
500 A
500 A*  Use DRI interface to update From slot.
500 A*    Note: The $sl info was retrieved in ZZGET1.
500 A
     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #fromslwhdp
     C                   eval      $sldispu  = *on
     C                   eval      $sldisp   = #fromsldisp
     C                   eval      $saitemu  = *on
500 AC                   eval      $saitem   = #fromslitem
     C                   eval      $saqtyu   = *on
500 AC                   eval      $saqty1   = w1qt01
500 AC                   eval      $saqty2   = w1qt02
500eMC                   eval      $saqty3   = w1qt03
     C                   eval      $sacitemu = *on
600eDC**                 eval      $sacitem  = w1itm
600eMC                   eval      $sacitem  = #fromslitem

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
640dA
640dA*     Set item change flag
640dA
640dAC                   if        #fromslitem <> w1itm
640dAC                   eval      $saItmChgU = *on
640dAC                   eval      $saItmChg = 'Y'
640dAC                   endif

     C                   eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd  = '%TFROUTCHG'
610eA
610eA*     Do Reverse transfer if Pick slot and item didn't change.
610eA
610eAC                   if        #fromslpick = 'Y'
610eAC                             and #fromslitem = w1itm
610fAC                   eval      Ypickslot   = *on
700dD **   If FROM slot is pick, save data just in case TO slot
700dD **           is a pick slot.  Moving to USR slot and need
700dD **           copy FROM slot data.
700dD **** The #Yfrom fields are unnecessary, as #from fields can be used.
700dDC**                 eval      #Yfromslwhse =  $slwhse
700dDC**                 eval      #Yfromslwhdp =  $slwhdp
700dDC**                 eval      #Yfromsldisp =  $sldisp
700dDC**                 eval      #Yfromslpick =  $slpick
700dDC**                 eval      #Yfromslitem =  $slitem
700dDC**                 eval      #Yfromslstk1 =  $slstk1
700dDC**                 eval      #Yfromslstk2 =  $slstk2
640hDC***                eval      #Yfromslstk3 =  $slstk2
700dDC**                 eval      #Yfromslstk3 =  $slstk3
700dDC**                 eval      #Yfromslstat =  $slstat
610fA
610eAC                   eval      $drisubcmd  = '%TFR2USRR'
610eAC                   else
600eMC                   eval      $drisubcmd  = '%TFR2USR'
610eAC                   endif
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   goto      endup1
     C                   endif
650aAC                   eval      tfr2usrDate = today
650aAC                   time                    tfr2usrTime
     C                   eval      tfroutflag = *on
600eAC                   eval      curlic# = $saToLcns
600eAC                   eval      $tinlic# = $saToLcns
700eA
700eA*  Override $saFrmEmpty for an empty Pick slot.
700eA*  Re: We want to ask a user if the slot is empty just in case he is
700eA*  moving the item to another Pick slot and we are allow to auto verify.
700eA
700eAC                   if        Ypickslot   = *on
700eAC                             and partial = *off
700eAC                   eval      $saFrmEmpty = 'Y'
700eAC                   endif
600eA*
600hM*  Create work record.
600eA*
600hDC**                 exsr      zzwrkupd
600hMC                   exsr      zzwrkadd
500 A
500 A*    Then tell user to put back an pulled pallets.
500 A*         and move on to the putaway process.
500 A
500 AC                   exsr      zzzclr$lt210
500 AC                   eval      $tcmd  = '*PULRTN'
500 AC                   eval      $twhse = $pwhse
500 AC                   eval      $twhdp = #fromslwhdp
500 AC                   eval      $tslot = #fromsldisp
500 AC                   eval      $titem = #fromslitem
500 AC                   eval      $titemdsc = #fromithead
610cAC                   eval      $tlic#    = $saToLcns
500 AC                   exsr      zzzcall$lt210
500 AC                   if        $treturn <> '*OK'
500 AC                   endif
500 A
500 A*  Check if slot can be verified after transfer complete.
500 A
500 AC                   exsr      zzchkzrovfy
500 AC                   if        verifyzero
500 AC                   exsr      scr03i
500 AC                   else
500 AC                   exsr      scr02i
500 AC                   endif
     *
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update record.
     *
     C     zzupd2        begsr
     C                   move      *off          error
415dAC                   move      *off          dteold
415dAC                   move      *off          dteofl
     *   Change quantity to breakdown quantity if needed.
500bAC                   if        #fromslitem <> w1itm
500bMC                   if        #fromittype = ' '
500bMC                   if        #newfromittype = 'S'  or
500bMC                             #newfromittype = 'B'  and
500bMC                             #fromitumq2 <> 0
500bMC                   eval      toqty1 = w1qt01 * #fromitumq2
500bMC                   else
500bMC                   eval      toqty1 = w1qt01
500bMC                   endif
500bMC                   endif
     *
500bMC                   if        #fromittype = 'S'  or
500bMC                             #fromittype = 'B'
500bMC                   if        #newfromittype = ' '  and
500bMC                             #newfromitumq2 <> 0
500bMC                   eval      toqty1 = w1qt01 / #newfromitumq2
500bMC                   else
500bMC                   eval      toqty1 = w1qt01
500bMC                   endif
500bMC                   endif
500bMC                   else
500bMC                   eval      toqty1 = w1qt01
500bMC                   endif
600jA
600jA*    Determine if we are returning qty to original slot.
600jA
600jAC                   if        #toslwhdp = wuPulWhdp
600jAC                             and #tosldisp = wuPulDisp
600jAC                             and w1itm = wuPulItem
600jAC                   eval      rtnToOrig = *on
600jAC                   else
600jAC                   eval      rtnToOrig = *off
600jAC                   endif
500 A
500 A*    Call license tracking for putaway - Before update
600jA*    Only call when not returning to original slot.
500 A
600lAC                   select
600lA
600lAC                   when      w2disp = ossDisp
710dAC                             and ossLcns <> ' '
600lAC                   eval      $tinlic# = ossLcns
600lAC                   eval      $tslotpos = wuPulPos
600lAC                   eval      $toutlic# = wuUsrLcns
600lA
600lMC                   when      rtnToOrig = *on
600jA
600jAC                   eval      $tinlic# = wuPulLcns
600jAC                   eval      $tslotpos = wuPulPos
600jAC                   eval      $toutlic# = wuUsrLcns
600jA
600lMC                   other
600jA
610iAC                   if        not skipLT210
600iA
500 AC                   exsr      zzzclr$lt210
500 AC                   eval      $tcmd     = '*PUTAWYB'
600jDC**                 eval      $tlic#    = curlic#
600jAC                   eval      $tlic#    = wuUsrLcns
600eDC**                 eval      $tpartial = *off
600eMC                   eval      $tpartial = partial
500 AC                   eval      $twhse    = $pwhse
600oMC                   eval      $twhdp    = #toslwhdp
600oMC                   eval      $tslot    = #tosldisp
600fDC*                  eval      $twhdp    = wkUsrWhdp
600fDC*                  eval      $tslot    = wkUsrDisp
600oDC**                 eval      $twhdp    = wuUsrWhdp
600oDC**                 eval      $tslot    = wuUsrDisp
500 AC                   eval      $titem    = w1itm
500 AC                   eval      $titemdsc = #newfromithead
500bMC                   eval      $tqty1    = toqty1
500 AC                   eval      $tqty2    = w1qt02
500 AC                   eval      $tqty3    = w1qt03
500jAC                   eval      $tnorm1   = toqty1
500jAC                   eval      $tnorm2   = w1qt02
500jAC                   eval      $tnorm3   = w1qt03
500 AC                   exsr      zzzcall$lt210
500 A*
500 AC                   if        $treturn <> '*OK'
500mAC                   eval      redspl = *on
600dAC                   eval      error = *on
600dAC                   eval      errmsg = $terrmsg
600dAC                   exsr      zm0105
     C                   goto      endup2
500 AC                   endif
600fA
610fAC                   endif
600jA
600lMC                   endsl
500 A
600eA*  Use DRI interface to tfr qty from USR slot to To slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu  = *on
     C                   eval      $slwhse   = $pwhse
     C                   eval      $slwhdpu  = *on
     C                   eval      $slwhdp   = #toslwhdp
     C                   eval      $sldispu  = *on
650kAc                   if        prdtfr
650kAC                   eval      $slstatu  = *on
650kAC                   eval      $slstat   = 'PR'
650kAC                   eval      $sldisp   = hldprdDisp
650kAc                   else
     C                   eval      $sldisp   = #tosldisp
650kAc                   endif
500dAC                   eval      $slentdu  = *on
500dAC                   eval      $slentd   = #fromslentd
     C                   eval      $slexpdu  = *on
     C                   eval      $slexpd   = #fromslexpd
     C                   eval      $saitemu  = *on
500 AC                   eval      $saitem   = w1itm
     C                   eval      $saqtyu   = *on
500 AC                   eval      $saqty1   = w1qt01
500 AC                   eval      $saqty2   = w1qt02
500eMC                   eval      $saqty3   = w1qt03
FPR AC*
FPR AC                   if        client = FoodPro
FPR AC*
FPR AC                   if           #fromitcwgt    = 'Y'
FPR AC                             or #newfromitcwgt = 'Y'
FPR AC                   eval      $sacwtau = '1'
FPR AC                   eval      $sacwta = w2cwt
FPR AC                   else
FPR AC                   eval      $sacwtau = '0'
FPR AC                   endif
FPR AC*
FPR AC                   endif
FPR AC*
     C                   eval      $sacitemu = *on
     C                   eval      $sacitem  = #fromslitem
500lAC                   eval      $sacdspu  = *on
600eAC                   eval      $sacwhdu = *on
600fDC*                  eval      $sacwhd  = wkUsrWhdp
600fAC                   eval      $sacwhd  = wuUsrWhdp
600eDC**                 eval      $sacdsp   = #fromsldisp
600fDC*                  eval      $sacdsp   = wkUsrDisp
600fAC                   eval      $sacdsp   = wuUsrDisp
600eMC                   eval      $saToPosu = *on
600eMC                   eval      $saToPos  = $tslotpos
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
600lA
600lAC                   if        w2disp = ossDisp
600lAC                   eval      $sapullwhdpu = *on
600lAC                   eval      $sapullwhdp  = #toslwhdp
600lAC                   eval      $sapulldispu = *on
600lAC                   eval      $sapulldisp  = #tosldisp
600lAC                   eval      $sapullbaseu = *on
600lAC                   eval      $sapullbase  = 'OSS' + #rcvarea
600lAC                   eval      $sapulllcnsu = *on
710dAc                   if        ossLcns <> ' '
600lAC                   eval      $sapulllcns  = ossLcns
710dAc                   else
710dAC                   eval      $sapulllcns  = wuPulLcns
710dAc                   endif
600lAC                   else
600iAC                   eval      $sapullwhdpu = *on
600iAC                   eval      $sapullwhdp  = wuPulWhdp
600gAC                   eval      $sapulldispu = *on
600gAC                   eval      $sapulldisp  = wuPulDisp
600gAC                   eval      $sapullbaseu = *on
600gAC                   eval      $sapullbase  = wuPulBase
600gAC                   eval      $sapulllcnsu = *on
600gAC                   eval      $sapulllcns  = wuPulLcns
600lAC                   endif
640dA
640dA*     Set changed item flag if necessary.
640dA
640dAC                   if        #fromslitem <> w1itm
640dAC                   eval      $saItmChgU = *on
640dAC                   eval      $saItmChg = 'Y'
640dAC                   endif
600jA
600jAC                   if        rtnToOrig = *on
600jAC                   eval      $saexcdU = *on
600jAC                   eval      $saexcd  = 'RTNORIG'
600jAC                   endif


720dAc                   if        $tpartial = *on
720dAc                   eval      $saUCIts = $tpartime
720dAc                   eval      $saUCItsU = *on
720dAc                   endif

     C                   eval      $dricommand = '*SLOT'
600eDC**                 eval      $drisubcmd  = '%CLSTFICHG'
600eMC                   eval      $drisubcmd  = '%USR2PUT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmsflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   goto      endup2
     C                   endif
500 A
500 A*  Update #TO slot info in case item was put into a virtual slot.

     C                   eval      #toslhand = $slhand
     C                   eval      #tosldisp = $sldisp
650kAc                   if        prdtfr
650kAC                   eval      #toslstat = 'PR'
650kAc                   else
640dAC                   eval      #toslstat = $slstat
650kAc                   endif
740aA
740aA*  Update warehouse-to-warehouse (GLOWWTFR) transfer for To slot.
740aA
740aA /free
740aA    monitor;
740aA      WWTFR('*TFRIN': #toslaisl: #toslloc: $pwhse: #user: wwrtn: wwmsg);
740aA    on-error;
740aA    endmon;
740aA /end-free
740aA
740aA*  Update warehouse-to-warehouse (GLOWWTFR) transfer for From slot.
740aA
740aA /free
740aA    monitor;
740aA      WWTFR('*TFROUT': #fromslaisl: #fromslloc: $pwhse: #user:wwrtn:wwmsg);
740aA    on-error;
740aA    endmon;
740aA /end-free
600lA
600lA*  Delete workoss records
600lA
600lAC                   if        w2disp = ossDisp
600lAC     keywo         chain     workoss
600lAC                   if        %found(workoss)
600lAC                   delete(e) workoss
600lAC                   endif
600lAC                   endif
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
600eD **
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
500 A
640cD ** Use DRI interface to zero verify From slot if needed.
640cD **
640cDC**                 if        verifyzero and w3zero = 'Y'
640cDC**                 exsr      clr$slot
640cDC**                 eval      $slwhseu = *on
640cDC**                 eval      $slwhse  = $pwhse
640cDC**                 eval      $slwhdpu = *on
640cDC**                 eval      $slwhdp  = #fromslwhdp
640cDC**                 eval      $sldispu = *on
640cDC**                 eval      $sldisp  = #fromsldisp
640cD **
640cDC**                 eval      $dricommand = '*SLOT'
640cDC**                 eval      $drisubcmd  = '%ZEROVFY'
640cDC**                 eval      $drisys2upd = 'D'
640cDC**                 eval      chk4err = *off
640cDC**                 eval      zmsflag = *off
640cDC**                 exsr      zzzdricop
640cDC**                 if        error
640cDC**                 endif
640cDC**                 endif
500 A
500 A*    Call license tracking for putaway - After update
500 A*      Values are left over from "Before" call.
500 A
500 AC                   eval      $tcmd     = '*PUTAWYA'
640cAC                   eval      $twhdp    = #toslwhdp
500 AC                   eval      $tslot    = #tosldisp
500 AC                   exsr      zzzcall$lt210
500 A*
500 AC                   if        $treturn <> '*OK'
500 AC                   endif
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
610fA ** Use DRI interface to update From slot.
610fA **
610fAC                   if        Ypickslot = *on
610fAC                             and $slpick = 'Y'
640eAC                             and $slstat <> 'RP'
640iAC                             and $slstyp = 'F'
640gAC*****                        and opmpck = 'N'
610fAC                   exsr      clr$slot
610fAC                   eval      $slwhseu  = *on
700dDC**                 eval      $slwhse   = #Yfromslwhse
700dMC                   eval      $slwhse   = $pwhse
610fAC                   eval      $slwhdpu  = *on
700dDC**                 eval      $slwhdp   = #Yfromslwhdp
700dMC                   eval      $slwhdp   = #fromslwhdp
610fAC                   eval      $sldispu  = *on
700dDC**                 eval      $sldisp   = #Yfromsldisp
700dMC                   eval      $sldisp   = #fromsldisp
610fAC                   eval      $slitemu  = *on
700dDC**                 eval      $slitem   = #Yfromslitem
700dMC                   eval      $slitem   = #fromslitem
700dDC**                 eval      $slstat   = *off
700dMC                   eval      $slstatu  = *off
700dDC**                 eval      $slstat   = #Yfromslstat
700dMC                   eval      $slstat   = #fromslstat
610fAC                   eval      $dricommand = '*SLOT'
610fAC                   eval      $drisubcmd  = '%SETSTAT  '
610fAC                   eval      $drisys2upd = 'D'
610fAC                   eval      chk4err = *on
610fAC                   eval      zmsflag = *off
610fAC                   exsr      zzzdricop
610fAC                   eval      Ypickslot = *off
650eAC                   if        $drireturn = 'NOTZROSTAT'
650eAC                   eval      error = *off
650eAC                   endif
610fAC                   if        error
610fAC                   eval      *in21 = *on
610fAC                   eval      *in01 = *on
640fD ***                goto      endup2
610fAC                   endif
610fAC                   endif
640fAC                   eval      Ypickslot = *off
500 A
500 A*  Create label(s), create extra trans, close trans.
500 A
500 AC                   exsr      zzcrtl
600eA
600eA*  Delete work record
600eA
600eAC                   exsr      zzwrkdel
640cA
640cA*  Use DRI interface to zero verify From slot if needed.
640cA
640cAC                   if        verifyzero and w3zero = 'Y'
700lAC                             or $pcmd = '*PCKSWAP'
640cAC                   exsr      clr$slot
640cAC                   eval      $slwhseu = *on
640cAC                   eval      $slwhse  = $pwhse
640cAC                   eval      $slwhdpu = *on
640cAC                   eval      $slwhdp  = #fromslwhdp
640cAC                   eval      $sldispu = *on
640cAC                   eval      $sldisp  = #fromsldisp
640cA
640cAC                   eval      $dricommand = '*SLOT'
640cAC                   eval      $drisubcmd  = '%ZEROVFY'
640cAC                   eval      $drisys2upd = 'D'
640cAC                   eval      chk4err = *off
640cAC                   eval      zmsflag = *off
640cAC                   exsr      zzzdricop
640cAC                   if        error
640cAC                   endif
640cAC                   endif
500 A
500 A*  Start idle tran.
500 A
500 AC                   exsr      zztrnidle
     *
     *   Send back info message.
     *
     C                   eval      $prtn = '*OK     '
     C                   eval      errmsg = *blanks
     C                   move      w2qty         erqty
     C                   move      #fromslitem   eritem
     C                   move      fmdisp        erfrom
413eMC                   eval      erto = w2disp
     C                   exsr      zm1521
     *
     C     endup2        endsr
416aA*
416aA*----------------------------------------------------------------
416aA*
416aA*  ZZUPD3   Update record.
416aA*
416aAC     zzupd3        begsr
416aAC                   move      *off          error
416aA*
416aA*    If user says that the slot is not empty, log an exception.
416aA*    System says slot should be empty.
416aAC                   if        w3zero = 'N'
416aAC                   eval      exerid = 'NOTEMTY'
650bA*
650bAC                   if        w1qt01 > 999
650bAC                   eval      exqty = 999
650bAC                   else
650bA*
416uMC                   z-add     w1qt01        exqty
650bAC                   endif
650bA*
416aAC                   exsr      zzexcp
416aAC                   endif
416aA*
416aAC                   exsr      scr02i
416aA*
416aAC     endup3        endsr
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
600fAC                   exsr      zzgetcurrstamp
600eAC*
600fAC                   clear                   wuRec
600fA
600fAC                   eval      wutrn# = curtrn#
600fAC                   eval      wuwhse = $pwhse
600fAC                   eval      wuscannbr = #fromToLcns
600fAC                   eval      wuscantype = 'P'
600fAC                   eval      wupulwhdp = #fromslwhdp
600gAC                   eval      wupulbase = #frombasesldsp
600fAC                   eval      wupuldisp = #fromsldisp
600fAC                   eval      wupulitem = #fromslitem
600fAC                   eval      wupullcns = #fromToLcns
600nAc                   eval      wupulolcns = #fromOLcns
600nAC                   eval      wupulvfy   = $saFrmEmpty
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
600fA
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
600fAC                   if        %found
600fAC                   delete    wuRec
600fAC                   endif

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
600aDC                   delete    wuRec
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

600fDC*                  eval
600fDC*                  eval      wkremqty2 = w1qt02
600fDC*                  eval      wkremqty3 = w1qt03

600fDC*                  eval      wkpullcns = $toutlic#
600fDC*                  eval      wkusrlcns = $tinlic#

600fDC*                  update    wktrec
      *
600fAC     keyUsr3a      chain(e)  workUsr3
600fAC                   if        not %found
600fAC                   eval      i = i
600fAC                   endif

600fAC                   eval      wuUsrWhdp = $slwhdp
600fAC                   eval      wuUsrDisp = $sldisp
600fAC                   eval      wuNewItem = w1itm

600fAC                   eval      wuRemQty1 = w1qt01
600fAC                   eval      wuRemQty2 = w1qt02
600fAC                   eval      wuRemQty3 = w1qt03

600fAC                   eval      wuPullcns = $toutlic#
600fAC                   eval      wuUsrLcns = $tinlic#

600fAC                   update    wuRec

     C                   endsr

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*                     DRI SUBROUTINES
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  clr$item  Clear $item data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600eAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slot  Clear $slot data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600eAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600dAC                   eval      $saemp#U = *on
     C                   eval      $saemp# = #emp#
     C                   endsr

500 A*----------------------------------------------------------------
500 A*  clr$slotdef  Clear $slotdef data structure fields
500 A*----------------------------------------------------------------
500 A
500 AC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdriclose   Close any open files or programs.
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdriclose   begsr

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
500 A
500 A*----------------------------------------------------------------
500 A*  zzzdricop  Call DRICOP
500 A*----------------------------------------------------------------
500 A
500 AC     zzzdricop     begsr
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
     C                   eval      errmsg    = 'Error occured on call to '
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

500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------
500 A*  License Plate Tracking Routines
500 A*----------------------------------------------------------------
500 A*----------------------------------------------------------------

500 A*----------------------------------------------------------------
500 A*  ZZZCLR$LT210  -  Clear LT210 parameters.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCLR$LT210  begsr

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
720dAC                   clear                   $tuci

     C                   endsr

500 A*----------------------------------------------------------------
500 A*  ZZZCALL$LT210  -  Call LT210 program.
500 A*----------------------------------------------------------------
500 A
500 AC     ZZZCALL$LT210 begsr

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
720dAC                   parm      ' '           $tuci

     C                   endsr

600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------
600bA*  Phrase Routines
600bA*----------------------------------------------------------------
600bA*----------------------------------------------------------------

600bA*----------------------------------------------------------------
600bA*  pushRoutine  -  Add routine to stack
600bA*----------------------------------------------------------------
600bA
      /free
       begsr pushRoutine;

         for i = stackCount downto 1;
           eval aRoutine(i+1) = aRoutine(i);
         endfor;

         aRoutine(1) = currRoutine;
         stackCount += 1;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  popRoutine  -  Remove routine from stack
600bA*----------------------------------------------------------------
600bA
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

600bA*----------------------------------------------------------------
600bA*  phClearVars  - Clear phrase variables
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phClearVars;

         v1 = ' ';
         v2 = ' ';
         v3 = ' ';
         v4 = ' ';
         v5 = ' ';

       endsr;
      /end-free


600bA*----------------------------------------------------------------
600bA*  zzWrtPhrase  - Write logging phrase
600bA*----------------------------------------------------------------

      /free
       begsr phWrtPhrase;

         pWhse = 0;
         pEmp# = #emp#;
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

600bA*----------------------------------------------------------------
600bA*  phV2onV1
600bA*----------------------------------------------------------------
600bA
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

600bA*----------------------------------------------------------------
600bA*  phScrV1pgmV2
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phScrV1pgmV2;

         pPhraseId = scrV1pgmV2;

         exsr phClearVars;

         v1 = nxtscr;
         select;
600bA      when nxtscr <> lastnxtscr;
600bA        v2 = 'displayed';
600bA      when error = *on;
600bA        v2 = 'redisplayed with error';
600bA      when warn = *on;
600bA        v2 = 'redisplayed with warning';
600bA      other;
600bA        v2 = 'redisplayed';
600bA    endsl;
600bA    lastnxtscr = nxtscr;

         exsr phWrtPhrase;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phPgmV1V2V3e
600bA*----------------------------------------------------------------
600bA
      /free
       begsr phPgmV1V2V3e;

         pPhraseId = pgmV1V2V3;

         exsr phClearVars;
         v1 = $pcmd;
         v2 = currRoutine;
         v3 = 'End';

         exsr phWrtPhrase;

         exsr popRoutine;

       endsr;
      /end-free

600bA*----------------------------------------------------------------
600bA*  phPgmV1V2V3s
600bA*----------------------------------------------------------------
600bA
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

     *----------------------------------------------------------------     ****
     *
     *  COMPILE TIME TABLES
     *
**
Slot
Adjustment Type
Transfer Quantity
Verify Zero
F10 not allowed - Mult Lic Exist
Invalid OSS slot - Print new label
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
** Descsp
Slot
Tipo de ajustamiento
Cantidad de transferencia
Verificar Zero
F10 no permitido- Mult Lic existe
Ranura OSS no válida-imprima una etiqueta nueva
