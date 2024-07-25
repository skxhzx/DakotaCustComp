      /COPY *libl/qcopysrc,hspecs
600eAH dftactgrp(*NO) actgrp(*NEW)
500uA*----------------------------------------------------------------
500uA*  Multilingual Verision
500uA*  Every screen and message has a corresponding Spanish version.
500uA*  Any changes must be made to both languages.
500uA*  If necessary, contact appropriate person to do translation.
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RC200     RF Put-Away
     *  04 February, 1997
     *  Dave Sommerville
     *  Hemant Kapadia
     *
     *  Notes
     *       8 X 20 Screens for hand held scanners
     *
     *
SFC  *   *** Revised to not allow Virtual Pick Slots ***
     *
     *----------------------------------------------------------------
     *  Revisions
     *
221 A*    05/19/97  RH   2.21
     *      - Use option for Use generic license.
     *      - Add access info by transaction #.
     *      - IF no LABEL7 rec is found, display sc2 fields with blanks.
222 A*    06/27/97  RH   2.22
     *      - Move current value to WOTRN# in ZZCHK1.
409 A*    06/03/98  RH   4.09
     *      - Add screen3 for Manual Put away, V-slot.
409aA*    07/14/98  RH   4.09
     *      - Move value to W3ITEM in ZZGETI.
410 A*    10/22/98  RH   4.10
     *      - Add chain to SLOT file in ZZCKSL, had wrong slot rec.
410 A*    12/08/98  HNK  4.10
     *      - Revised to end current task and start an 'IDLE' task
     *        when there is no open task. ZZEND, ZZIDLE and ZZTASK
     *        routines added.
     *
412 A*    07/15/99  DAS  4.12
     *      - Revised to deal with new item types.
412 A*    08/27/99  RH   4.12
     *      - Add department to Screen 3.
412CA*    08/31/99  RH   4.12
     *      - Add *IN92 to not allow F3 or F12 if partial putaway
     *        was started for VS put away.
     *      - If date sensitive, when all slot qtys = 0, ignore
     *        expiration date test.
412dA*    09/07/99  HNK/DAS 4.12d
     *      - ITEMQTY file updated in this prog instead of PT132, for
     *        manual putaway.
     *      - ZZWHSE routine added.
     *
412eA*    09/15/99  DAS 4.12e
     *      - Took of ODISP IF statment from routine ZZUPD3. Now,
     *        a slot will be checked every time through for existance.
     *
412fA*    09/24/99  DAS  4.12f
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
413 A*    10/27/99  DAS  4.13
     *      - Revised ZZCKNS to set ERROR to *OFF if item is blank.
413aA*    12/15/99  DAS  4.13a
     *      - Fix to position to license field for license option.
     *
413bA*    01/24/00  DAS  4.13b
     *      - Revised ZZUPD3 to fill SLPICK correctly with $VPICK.
     *
413cA*    01/26/00  RH   4.13c
     *      - Add code to not create virtual pick slot. This code
     *        defaults to being commented out. To stop the creation
     *        of virtual pick slots, you must uncomment the code.
     *
413dA*    02/10/00  RH/DAS  4.13d
     *      - Revised routine DSPSCR to not set off indicator 92.
     *
413eA*    02/02/00  MLB  4.13e
     *      - Revised routine ZZWHSE to correct IF statements from
     *        $PRTN to $ARTN.
     *      - Revised routine ZZWHSE to correct statements from
     *        $PMSG to $AMSG.
     *
413fA*    02/14/00  HNK  4.13
     *      - Revised to ignore Idle task in ZZCKU2 routine.
     *        Only indirect task used to subtract overlapping task.
413gA*    03/28/00  DAS  4.13g
     *      - Added file PIRTRAN1.
     *      - Revised ZZTASK to first look at PIRTRAN1 for a status
     *        '2' record. This will save reading through every record
     *        for the employee.
414 A*    06/22/99  DAS  4.14
     *      - Added APICVTSLT to ZZCHK2/3 routines.
414aA*    07/17/00  RRH  4.14a
     *      - For Virtual (Manual) put away,
     *        Can put in pick slot if NO overflow slots exist for item
414bA*    07/17/00  RRH  4.14b
     *      - For Virtual (Manual) put away,
     *        If item has hard designation code, can only put into
     *        slot with matching designation code.
414cA*    07/19/00  RRH  4.14c
     *      - Correct # for Do loop in ZZCKNS
414dA*    07/19/00  RRH  4.14d
     *      - Change for staging, can have multiple license #
     *        records in license file.
414eA*    09/13/00  HNK  4.14e
     *      - Display Y/N if there is stock in any overflow slot
     *        for the item.
414hA*    10/25/00  RRH  4.14g
     *      - Don't lock VSLOT records in ZZCKSL.
414hA*    10/25/00  RRH  4.14g
     *      - Don't lock VSLOT records in ZZCKSL.
415aA*    11/20/00  RRH  4.15a
     *      - Fix, when pick slot is empty, status=A, expiration
     *        date was not getting set to new expiration date.
415bA*    01/08/00  RRH  4.15b
     *      - Fix, Allow return trans. PUTRTN.
415cA*    01/08/01  RH   4.15c
     *      - Add scan label #.
     *      - If multiple label records exist in Label Link file,
     *        call LL145 list program.
     *      - If label# scanned, get trans # from cross reference file
415dA*    02/08/01  RH   4.15d
     *      - For returns, not fixed pick slot, set pick priority = 9.
415eA*    04/03/01  RH   4.15e
     *      - Allow override to put Non date sensitive item into
     *        Pick slot.
415fA*    04/10/01  MLB  4.15f
     *      - Revised pgm to retrieve pick slot for item or last
     *        overflow slot if no pick found.
415gA*    05/17/01  RH   4.15g
     *      - Fix 4.13d code. Wrong line was commented out and allowed
     *        F12 when it should have been protected.
415hA*    05/29/01  RH   4.15h
     *      - Add ITEMMSC to check multiple pick options.
     *      - Note: IMNRPK can = 0 to allow no pick slots.
     *      - Do not check for # of pick slots if overflow slot.
415iA*    06/29/01  RH   4.15i
     *      - Do not allow put away to Inactive slot (status=I).
415jA*    07/27/01  DAS  4.15j
     *      - Added verification for scanned slot.
415kA*    08/02/01  DAS/RH  4.15k
     *      - Added SCREEN4 to verify pallet quantity.
     *      - Add log file LOG200 to track verify quantity.
     *         - Not implemented at this time.
415lA*    07/03/01  MLB  4.15l
     *      - Fix, F5=Refresh was re-activating F12=Cancel when user
     *        only performed a partial put away, thereby allowing the
     *        user to exit.
415mA*    08/16/01 RH/HNK 4.15M
     *      - Error only for # of pick slots if putting in pick slot.
     *
415nA*    08/23/01  DAS  4.15n
     *      - Revised to handle SSB items correctly.
     *      - Note: LBUTYP accurately reflects the quantity bucket
     *        to be updated.
     *
416aA*    09/21/01  RH   4.16a
     *      - Fix - Update entered date if slot is empty.
416bA*    12/05/01  DAS  4.16b
     *      - Added to 4.15m to only do check for fixed slots.
416cA*    10/30/01  MLB  4.16c
     *      - Revised routine ZZCKNS to set off NEWVS each time
     *        routine is executed.
416dA*    01/08/02  MLB  4.16d
     *      - Revised program to add support for scanning multiple
     *        license plates during put away.
416eA*    02/20/02  MLB  4.16e
     *      - Revised msgid RC20008 to include user that scanned in
     *        license/label#.
     *      - Revised ZZCHK6 to only delete an entry whose status has
     *        changed if the number entered same as match number.
416fA*    05/23/02  RRH  4.16
     *      - Change W1LCNS, W5LCNS to 15 Alphanumeric.
     *      - Left justify, remove leading blanks for license
416gA*    07/02/02  RH   4.16g
     *      - Recompiled, ITEMMSC changed.
416hA*    02/06/02  MLB  4.16h
     *      - Revised program to correct situation in ZZUPD5 where
     *        the wrong transaction number was being processed after
     *        returning from a later display and then returning to
     *        the same display.
416iA*    08/13/02  MLB  4.16i
     *      - Fix: Revised ZZUPD3 to do a Z-SUB instead of Z-ADD when
     *        updating SLPRTY.
     *      - Fix: Revised ZZUPD3 to only update SLEXPD when SVEXPD
     *        is greater than zero.
416jA*    08/15/02  MLB  4.16j
     *      - Fix: Revised ZZUPD5 to load 'L' adding label numbers.
     *      - Fix: Revised ZZUPD5 to Read WORKPUT file when only one
     *        record left to make sure correct record is read.
     *        Added error message if "putaway transaction" isn't found.
416kA*    08/21/02  RH   4.16k
     *      - Revised ZZUPD3 to use the oldest expiration date to
     *        update the slot.
     *      - Revised ZZUPD3 for return put away to NOT set priority
     *        to -9 for a reserved pick slot.
416lA*    08/26/02  RH   4.16l
     *      - Revised ZZCHK3 to only check overflow slots for existing
     *        product with quantity and different date.
416mA*    09/25/02  RH   4.16m
     *      - Revised to create virutal slot with same status as base
     *        if base is not Z or V.
416nA*    10/01/02  RH   4.16n
     *      - Process skipped records after all others.
416oA*    11/01/02  MLB  4.16o
     *      - Revised routine ZZCKSL to set off NEWVS each time
     *        routine is executed.
416pA*    11/20/02  MLB  4.16p
     *      - Fix: Revised routine ZZUPD6 to clear CURTSK,CURTYP
     *        prior to ZZTASK being called.
416qA*    12/04/02  MLB  4.16q
     *      - Enh: Revised program to verify that slot selected
     *        for putaway is not at inactive status.
416rA*    12/18/02  MLB  4.16r
     *      - Fix: Revised routine ZZGET3 to load 'None' instead
     *        of '*NONE*' in W3TOSL. Was causing RF equip lockups.
     *
417 A*    02/13/03  MLB  4.17
     *      - Fix: Revised ZZCLSE to call new routine ZZENDI to close
     *        any open(inuse) Indirect tasks before closing current
     *        direct task.  Having Indirect tasks still open while
     *        closing the current task was causing the direct task
     *        to be updated with negative direct minutes.
417aA*    03/19/03  MLB  4.17a
     *      - Fix: Revised ZZFIL6 to use $IDSP to load W6DSP.
417bA*    04/03/03  RH   4.17b
     *      - Recompiled, ITEMMSC file changed.
417cA*    04/28/03  MLB  4.17c
     *      - Revised ZZCHK1,ZZCHK5 to use *LEFTNOZ for call to ADJUST.
417dA*    04/30/03  MLB  4.17d
     *      - Revised ZZGET6 to setoff SKIP6 indicator when position to
     *        top is done. Revised ZZDLP1 to decrement W6CNT1 counter
     *        when a putaway has been skipped.
417eA*    05/14/03  MLB  4.17e  *** Removed with 4.17q revision ***
     *      - Enh: Added lot/license plate tracking support to program.
417fA*    06/25/03  MLB  4.17f
     *      - Fix: Revised ZZFIL4 to get item description. Wrong
     *        description was being displayed.
417gA*    06/26/03  MLB  4.17g
     *      - Enh: Added new option to *RFPUT. Added option to
     *        allow multiple license/labels to be scanned during
     *        putaway. If set to N=No, then the user can scan in
     *        only one license/label at a time for putaway.
     *        Revised ZZUPD1, ZZUPD4 to check if multiple license,
     *        labels can be scanned during putaway.
417hA*    07/24/03  MLB  4.17h
     *      - Fix: Revise program to save start date/time from putaway
     *        transaction for use as start date/time for IDLE task if
     *        user cancels out of putaway transaction. This will correct
     *        time gaps in EPM tracking.
417iA*    09/22/03  RH   4.17i
     *      - Enh: Add F9 to display stage screens and process
     *      - If only staging part of the product, must putaway
     *        product first, then stage remaining.
     *      - Can not stage part of the remaining quantity.
417jA*    10/15/03  RH   4.17j
     *      - Enh: Verify product is not already expired.
417lA*    10/17/03  MLB  4.17l
     *      - Fix - Revise routine ZZCKU2 to READE using partial key
     *        of employee number.  This will prevent incorrect times
     *        from being calculated.
417mA*    10/20/03  RH   4.17m
     *      - Fix - ZZUPDS was using LIKEY, the wrong license record
     *        was getting updated in 417i change.
417mA*    11/03/03  RH   4.17m
     *      - Fix: Move WKPNBR to KYLCNS, wrong license record updated
417nA*    11/17/03  RH   4.17n
     *      - Fix: Change SC8 to not execute ZZABT3 for F12.
417nA *    11/20/03  RH   4.17n
      *      - Fix: Move ZZSTAG from SCR07I to ZZUPD8 to allow F12 on
      *        screen 8. Restart original put away transaction for F12
      *        on screen 7.
417oA*    12/05/03  MLB  4.17o
     *      - Enh: Added support for new *VIRTUAL slot options.
417pA*    12/05/03  MLB  4.17p
     *      - Enh: Added support for new expiration/entered
     *        *DATEOPT options.
417qA*    12/15/03  DAS  4.17q
     *      - Enh: Converted to ILE.
     *      - Enh: Removed 4.17e revisions.
     *      - Enh: Added calls to LT210 for license tracking.
417rA*    01/21/04  RH   4.17r
     *      - Enh: Use FIFO date for MOVE IN PO.
417sA*    08/05/04  RH   4.17s
     *      - Fix: Set transaction # to new put away trans # if F12
     *        is taken from screen 7 (Stage) after partial put away.
417tA*    08/13/04  RH   4.17t
     *      - Fix: Add call to GETSLOTITM to get the slot item for a
     *        alias item for a SSB item.
417uA*    10/18/04  RH   4.17u
     *      - Fix: Update trans correctly when F12 taken on stage
     *        after partial putaway.  Extra label record was created.
500 A*    09/04/04  DAS  5.00
     *      - Added parameter to LT210.
500aA*    11/10/04  RH   5.00a
     *      - Fix: Default OPMSCN to 'Y' if blank.
500bA*    11/15/04  RH   5.00b
     *      - Fix: Create new POMFR rec for partial staged qty.  POMFR
     *        contains the expiration date for put away.
500cA*    11/24/04  DAS  5.00c
     *      - Fix: Changed handstack loop in ZZCKNS to be LT 702
     *        instead of LE 702.
500dA*    11/24/04  RH   5.00d
     *      - Fix: Do not allow virtual slot to be scanned for putaway
500eA*    11/24/04  RH   5.00e
     *      - Fix: Do not lock POMFR record on chain.
     *
500fA*    01/01/05  DAS  5.00f
     *      - Fix: Set SVPNBR appropriately in ZZUPD1.
     *
500gA*    01/23/05  DAS  5.00g
     *      - Fix: Split *PUTAWAY into *PUTAWYB/A.
     *
500hA*    01/28/05  DAS  5.00h
     *      - Enh: Revised to use DRI interface for verifying and updating.
     *
500iA*    03/28/05  DAS  5.00i
     *      - Fix: Revised zzupd3 to skip to end of routine when
     *        %putaway returns with an error.
     *
500jA*    04/13/05  DAS  5.00j
     *      - Fix: Revised ZZFIL6 to verify that wkpasl <= 'ZZZ'. This is
     *        because wkpasl is set to *hival when a slot doesn't exist for
     *        the item. This was then sent to the screen where LXE RF
     *        terminals couldn't deal with it.
     *
500kA*    04/30/05  DAS  5.00k
     *      - Enh: Added $tnorm1/2/3 parms.
     *
500mA*    06/08/05  MLB  5.00m
     *      - Fix: Revised ZZCHK3 to activate test of W3QTY against
     *        W3RQTY to prevent putaway qty from exceeding rcv'd qty.
     *
     *****************************************************************
510gA*  ***** Start of merging PIRENH510 500f - 510f changes *****
510gA*  ***** Actual changes will be 501f - 511f             *****
     *
501fA*    01/20/05  MLB  5.00f / 501f
     *      - Enh: Revised program to add support for Client id
501gA*    01/20/05  RH   5.00g / 5.01g
     *      - Fix: Only create POMFR rec if item is date sensititve.
     *      - Fix: Clear PS saved fields used to create POMFR rec.
501hA*    03/04/05  HNK/MLB  5.00h / 5.01h
     *      - Fix: Revised ZZCMLT to remove reserved check for PIR.
501iA*    03/11/05  MLB  5.00i / 5.01i
     *      - Enh: Revised ZZGET3 to get *FIRST PIR slot when doing
     *        customer returns putaways.
501jA*    03/11/05  MLB  5.00j / 5.01j
     *      - Fix: Revise ZZUPD2 to call ZZCLSP to close Direct Putaway
     *        transaction instead of ZZCLSE - Close staged transaction.
501kA*    02/09/05  MLB  5.00k
     *      - Fix: Revised ZZVRTO, ZZDTEO to use opkey to access
     *        file OPTIONS.
501nA*    03/30/05  MLB  5.00n / 5.01n
     *      - Fix: Revise ZZCHK3 to prevent user from putting item into
     *        wrong section type for item. Added msgid RC20020.
501oA*    07/15/05  MLB  5.00o / 5.01o
     *      - Fix: Revised ZZUPD3 update expiration date when item is
     *        put into Zero slot.
501pA*    07/29/05  MLB  5.00p / 5.01p
     *      - SCREEN4, W4QTY field size changed to 7,0 from 5,0. No program
     *        changes. Re-compiled only.
501rA*    09/27/05  RLP  5.00r / 501r
     *      - Enh: added new msg RC20021 to be displayed when the scanned
     *        license has been deleted.
     *      - added file PORCV1 and revised ZZCHK1, ZZCHK5 to check
     *        for deleted license.
     *
501sA*    10/06/05  DAS  5.00s / 5.01s
     *      - Fix: Revised to compare tran#'s when getting a POMFR record.
501tA*    05/01/06  MLB  5.00t / 5.01t
     *      - Enh: Revised program to call GETIRPL to check for
     *        replenishments that can be done in the area. Screen 9
     *        added to support this enhancement.
     *
501uA*    06/04/06  JCJ  5.00u / 5.01u
     *      - Added Multilingual logic.
     *
511aA*    06/09/06  DAS  5.10a / 5.11a
     *      - Enh: Revised ZZUPD3 to call UPDSLTDTE.
511bA*    08/17/06  RH   5.10b / 5.11b
     *      - Fix: Revised ZZGETI to get base item for alias of S item
511cA*    08/22/06  RH   5.10c / 5.11c
     *      - Fix: Revised to set GTITEM value before ZZGETI.
511dA*    10/23/06  RH   5.10d / 5.11d see 500k
     *      - Fix: Add parms to LT210 call.
511eA*                   5.10e / 5.11e
     *      - Enh: Add DTCHK flag to allow override of expired date.
     *
     *  J      E
     * 500h / 501k
     * 500h / 501n
     * 500h / 501o
     * 510a / 511a
     *        BIR
     *        CBIa
     *        CBIb
     *        JPF
     *****************************************************************
510gA*    06/15/07  JCJ  5.10g
     *      - Merged changes 500f - 510f into PIRENH510/RC200.
     *      - Any changes after this point need to also be made
     *        to PIRENH510/RC200.
510hA*    07/05/07  JCJ  5.10h
     *      - Added logic to putaway product comming from the repack
     *        area.  This logic will act like a transfer for the
     *        from slot.
510iA*    05/29/07  RBD  5.10i
     *      - Enh: When putaway is a return to a pick slot, only set
     *        SLPRTY to -9 if client = VIGO.
520cA*    03/21/08  RH   5.20c  (not needed in ver 6.00)
     *      - Fix: 510f fix was leaving # of pick slots incremented
     *        after first check for ZZCKSL, reduce # after check if
     *        last slot read was active and we did not find item.
520dA*    11/21/08  RH   5.20d  (not needed in ver 6.00)
     *      - Fix: Call UPDSLTDTE with *FIX to correct qty in SLOTDTE
     *        is wrong if slot had negative stock before put away.
520eA*    01/13/09  RH   5.20e  (not needed in ver 6.00)
     *      - Fix: Change to not check # of pick slots for PIR.
520fA*    02/11/09  GJA  5.20f  (not needed in ver 6.00)
     *      - Fix: Incorporate options setting for slot date
520gA*    02/11/09  RH   5.20g  (not needed in ver 6.00)
     *      - Fix: Set error indicators to position cursor to W3scan
     *
600 A*    07/04/08  DAS  6.00  P#00045
     *      - License Tracking
     *      - LIC version used as base, then 510 changes added.
     *
600aA*    07/08/08  DAS  6.00a
     *      - Revised to update trn#/lbl# of license history record.
     *
600bA*    07/17/08  DAS  6.00b
     *      - Added phrase logging.
     *
600cA*    10/27/08  DAS  6.00c
     *      - Removed all commented code for readability.
     *        Original version is RC200.1028.
     *      - Removed ability to enter tran# on screen 1.
     *      - Renamed format to RC20001.
     *      - Replaced PIRTRAN file interactions with ADJTRAN2
     *        and DRIPIRTRAN.
     *      - Deleted ZZEND, ZZCKU2, ZZTIME routines.
     *      - Replace LICENSE file with DIRLICENSE and DRILICINFO.
     *
600dA*    10/27/08  DAS  6.00c
     *      - Revised to work with new RCV/STG/OSS/USR slots.
     *      - Revised to always write a record to WORKPUT even if
     *        multiple license plates are not allowed.
     *      - Changed all #user to #curruser.
     *
600eA*    02/17/09  CWM  6.00e
     *      - Revised to use the fields in new file WORKUSR where
     *      - WORKPUT us to be used.
     *
600fA*    05/17/09  DAS  6.00f
     *      - Revised how label # is handled.
     *
600gA*    05/18/09  DAS  6.00g
     *      - Revised to ignore special slots when determining
     *        if overflow exists.
     *
600hA*    05/19/09  DAS  6.00h
     *      - Fix: Screen 6 was not verifying lic# correctly.
     *
600iA*    05/21/09  DAS  6.00i
     *      - Revised how label # is handled in screen 5.
     *
600jA*    05/21/09  DAS  6.00j
     *      - ZZUPPK and ZZDLP1 were using a partial key to get the
     *        WORKUSR record to update/delete. Changed to use the
     *        full key.
610aA*    07/31/09  RH   6.10a
     *      - Fix: Get date for TODAY in ZZINZ, did not have value
     *        for TODAY when LBSDTE was updated.
610bA*    08/03/09  RH   6.10b
     *      - Enh: Renamed format to RC20002.
     *      - Enh: Created 16-line version of screens,
     *        SCREEN1=SCREEN61, No Screen62 for DIRECTED put away.
610cA*    09/01/09  DAS  6.10c
     *      - Revised how Directed Putaway is handled.
610dA*    09/02/09  RH   6.10d
     *      - Enh: Renamed format to RC20003.
     *      - Enh: Add Item designation code to screen3.
610eA*    09/09/09  DAS  6.10e
     *      - Revised to update label record with new slot when
     *        qty put into USR slot, STG slot, or putawy is canceled.
530aA*    10/20/09  RH   5.30a
     *      - Enh: Revise to warn if product has expired, allow override
530bA*    09/09/10  JCJ  5.30b
     *      - Enh: increase label entry to 10 positions for Trax.
610fA*    11/26/09  DAS  6.10f
     *      - Revised routine zzckdt to not lock POMFR record on Chain.
610gA*    11/25/09  DAS  6.10g
     *      - Revised zzdlpk to reset tran back to '1' if it is at
     *        stat '2' for the employee.
610hA*    01/21/10  DAS  6.10h
     *      - Fix: Revised ZZUPDS to use wuScanNbr instead of w1lcns.
610i *    01/26/10  GJA  6.10i
     *      - Fix: F12 from screen7 was leaving label open.
610j *    04/19/10  DAS  6.10j
     *      - Added opitonal license parameter.
530b *    07/14/10  GJA/JJ  5.30b
     *      - Fix: Commented out REPACK is not used anymore.
610k *    08/16/10  RH   6.10k
     *      - Fix: PKKEY2 was using wrong key fields, use KY fields.
TMPaA*    08/24/10  DAS  TMPa
     *      - Added extra phrase logging.
610l *    08/16/10  RH   6.10l
     *      - Fix: PKKEY2 was using wrong key values, use KY fields
610m *    10/12/10  RH   6.10m
     *      - Fix: WORKPUT2 key changed to include pulled item.
610n *    11/03/10  DAS  6.10n
     *      - Fix: Revised to write received item to workusr file.
     *        Re: Had a problem with Alias items, where the workusr
     *        record would not be deleted and the program thought
     *        there was another license to process.
     *
620 A*    01/25/11  MLB  6.20
     *      - Fix: Revised routine ZZCHK7 to use value from W7SCAN
     *        instead of W7ZONE when processing stage request.
     *      - Fix: Revised routine ZZUPD8 to use value from W7SCAN
     *        instead of W7ZONE when processing stage request.
     *
640aA*    04/21/11  RBD  6.40a
     *      - Enh: Assign the status code from the RCV/STG slot
     *        to the putaway slot.
     *      - Enh: Do not allow a user to put qty into the Pick slot
     *        if the status of the from slot is not 'A'.
     *      - Enh: Revised zzdlpk to capture the slot status of the
     *        USR slot and replicate it in the RCV slot when a USR
     *        slot gets reverted back to a RCV dock slot.
640bA*    07/13/11  RH   6.40b
     *      - Fix: Clear label field W1LBL#B in ZZFIL1.
640cA*    08/17/11  RH   6.40c
     *      - Enh: Add Overflow Stock Y/N to screen6.
     *        Rename format to RC20006
640dA*    10/21/11  RH   6.40d
     *      - Fix: Do not allow put away quantity to be negative.
640eA*    12/08/11  RH   6.40e
     *      - Fix: Fix: Skip special BFC desig slots when looking for
     *             stage zone.
640fA*    08/02/12  RH   6.40f
     *      - Fix: Was not moving slot information for screen 6
     *        16 line.
640gA*    08/13/12  RH   6.40g
     *      - Fix: Blank W5lbl#b in ZZFIL5.
640hA*    08/29/12  RTR  6.40h
     *      - Fix: Add call to cvtbarsel to screen 6 for Trax bar codes.
640iA*    11/12/12  DAS  6.40i
     *     - Revised %TFR2USR to use actual item received instead of
     *       slot item. This will ensure that the proper item number
     *       is used in the license log file.
640j *    10/14/12  GJA  6.40j (was 640i at Westside)
     *      - Fix: USR slot left after F12
640kA*    11/14/12  DAS  6.40k
     *     - Revised zzupd2 to close transaction after doing %usr2put.
     *       Re: We want to delay closing the transaction until we know
     *       the slot has been updated successfully.
     *
650aA*    01/21/13  LMC  6.50a
     *     - Fix: In zzchk6 - if user is scanning license do not call
     *       cvtbarsel, it was messing up the license number.
650bA*    01/24/13  RBD  6.50b
     *     - Fix: revised zzadpk to shift breakdown qty's for ssb items.
650cA*    02/25/13  LMC  6.50c
     *     - Enh: Sent slot designation to dri programs to be used to
     *       condition the quantity calculations for BFC designation
     *       slots.
     *     - Enh: Revove mod 650b, no longer needed with this enhanced
     *       feature.
650dA*    03/08/13  MLB  6.50d
     *      - Fix: Revised pgm to check if value loaded into exqty > 999
     *        and if yes, then set exqty = 999. Error found at Get
     *        Fresh who stores watermelon in lbs in qty fields.
650eA*    04/12/13  LMC  6.50e
     *      - Enh: F8 added to screen3, to allow user to look up a
     *        slot to put the product.
     *        Due to time limitations this mod is not a subfile, if
     *        in the future a client needs more than 4 slots displayed
     *        Subfile processing will need to be added.
650fA*    06/03/13  KDE  6.50f
     *      - Enh: changed workd order repack to allow creation of
     *        on-demand repack items.  Putaway must change to put
     *        stock in virtual of on-demand slot instead of base slot
650gA*    01/21/14  RH   6.50g
     *      - Fix: Only send status to DRISLOT if special status
     *        entered during receiving to allow normal put away into
     *        slot to use putaway slot status.
650hA*    02/12/14  RH   6.50h
     *      - Fix: Rename format to RC20008 to use Trax label on
     *        small handheld screens.
650iA*    05/30/14  RBD  6.50i
     *      - If called from PO236 only show screen1 if there's an
     *        error, otherwise, when finished with screen1 processing
     *        show screen3 without having displayed screen1. Then when
     *        you've finished screen3, get out and go back to PO236.
650jA*    07/28/14  MLB  6.50j
     *      - Fix: Revised routines ZZCHK1, ZZCHK5 to validate data on
     *        on license plate. If any invalid characters are found,
     *        they will be replaced with blanks. This mod was done to
     *        resolve terminal pgm errors when data scanned that
     *        contained characters less than hex 40.
650kA*    10/06/14  LMC  6.50k
     *      - Fix: zzchk3 - Problem at presto when F20 override - slot
     *        would go thru convert slot to check for double scan,
     *        skip converting slot if the w3scan = savdsp, if slot has
     *        not changed.
650lA*    01/21/15  MLB  6.50l
     *      - Fix: Revised 6.50j mod. Added * to list of valid license
     *        plate characters. Was not allowing system generated
     *        license plates to be put-away.
650m *    03/24/15  RTR  6.50m
     *      - Fix: old records in PORCV causing trans number found
     *        and considered as deleted and giving error.
700aA*    06/12/15  LMC/RH  7.00a
     *      - Fix: zzupd3 - W3rqty for cancel from LT210.
     *        Remaining qty was already reduced before call to LT210
     *        F12 cancel was leaving remain qty wrong and qty stuck
     *        in USR slot with NO license (*NONE)
700bA*    08/27/15  LMC/RH  7.00b
     *      - Enh: Only display older product in stock put in overflow
     *        warning if the older product in stock is an older date.
     *        We now pass the entered date to DRISLOT so we can check
     *        for older overflow not just any overflow.
700cA*    08/27/15  RH  7.00c
     *      - Fix: RF Put Away OPMSCN='N' to NOT scan multiple license
     *        didn't have SVPTYP set='P', ZZDLP1 didn't find WORKUSR2
     *        record, W5CNT was not reduced, wrong scrn(6) processed
700dA*    09/22/15  MLB  7.00d
     *      - Enh: Revised pgm to send completion msg, RC20030 with
     *        license and to slot information. Requested from CBI.
700eA*    03/10/16  RH   7.00e
     *      - Enh: Add section after 'NONE' if no slot is found.
700fA*    03/22/16  RH   7.00f
     *      - Fix: ZZCHK3 did not allow putaway to PIR slot if status
     *        was QU from receiving.  Added check for PIR slot.
700gA*    06/08/16  LMC  7.00g
     *      - Enh: Putaway for a breakdown will display the *Each pick
     *        slot if it exist. The user will also be forced to put
     *        the product into the *each pick slot.
     *
700hA*    07/20/16  LMC  7.00h
     *      - Reserved - UCI Tracking
700iA*    11/03/16  LMC  7.00i
     *      - Enh: changed display file from RC20009 to RC20010.
     *        w2tie field was getting truncated because display file
     *        only displayed 3 positions, when the label file had 4.
     *        At Westside this was causing a program error.
700jA*    01/05/17  LMC  7.00j
     *      - Enh - Added RTN to valid aisles.
     *      - Fix - zzdlpk logic when
     *        USR slot does not exist but licactive shows that the
     *        license is in the USR slot according to above check,
     *        Then force license back into a RCV/STG/OSS slot.
     *        This code was always using command RCVIN this nees to
     *        be based on the WUPULAISL and send the appropriate
     *        command - RCVIN/RTNIN/STGIN/OSSIN.
710aA*    05/16/17  NLK  7.10a
     *      - Enh - OVFSTK *in42 to display on HandHeld
710bA*    05/16/17  LMC 7.10b
     *      - Fix: RF Put Away OPMSCN='N' to NOT scan multiple license
     *        didn't have SVPTYP set='L', ZZDLP1 didn't find WORKUSR2
     *        record, W5CNT was not reduced, wrong scrn(6) processed
710cA*    06/15/17  LMC 7.10c
     *      - Fix: ZZUPPK  - mod 600e is updating the wuusrlcns with
     *        the wuscannbr - this is causing a problem if the user
     *        is returninig by label. Only updating the wuusrlcns to
     *        the wuscannbr if the return is not being put away by
     *        the label.
     *      - Fix: zzupd3
     *        Remaining qty was already reduced before call to LT210
     *        reset w3rqty when $treturn <> '*OK'.
     *      - Fix: zzupd3
     *        completion message wasn't working if we put a return
     *        by label balance qty into a overflow slot. Was showing
     *        the *RT license was put away even if the user assigned a
     *        license.
710dA*    09/11/17  RH  7.10d
     *      - Fix: Screen6 was not displaying overflow Y/N for correct
     *        item/license.  Change to use KEYS3A orig mod 6.40c
710eA*    09/19/17  NLK 7.10e
     *      - Fix: Screen3 position cursor to Slot not Qty if error
     *        of invalid slot from DriCop *slot
710fA*    09/19/17  RH  7.10f
     *      - Fix: ZZCHK6 was sending license thru CVTBARSEL.  Set
     *        PTATYP in ZZCHK5 to use for select in ZZCHK6.
     *      - Fix: Set W5lcns & W5lbl#b=blanks if 0 for no more keyed.
710gA*    10/30/17  KDE 7.10g
     *      - Fix: Add code for Production Putaway Task
710hA*    12/14/17  LMC  710h
     *      - Allow override when putting product into an inactive
     *        slot edit.
     *      - Based on new option field.
720a *    03/05/18  GJA  7.20a
     *      - Rename:  RC2000012 to RC2000013
     *      - Enh:  Show if XDK slots exist
720b *    03/26/18  KDE  7.20b
     *      - Rename:  RC2000013 to RC2000014
     *      - Enh:  Add F11 key to toogle between Pick Slots
720c *    06/06/18  NLK  7.20c
     *      - Enh:  Need to add a few Spanish entries in descsp
720dA*    07/20/16  LMC  7.20d  Reserved
     *      - Enh: Added parm to call on LT210 for UCI tracking
     *      - UCI Tracking.
720e *    12/14/18  GJA  7.20e
     *      - Rename:  RC2000014 to RC2000015
     *      - Fix: F9=Stage needed the color blue
720f *    02/27/19  RH   7.20f
     *      - Rename:  RC2000015 to RC2000016
     *      - Fix: Spanish screen 1 was missing F20
730aA*    09/24/19  LMC  7.30a
     *      - Enh - Added RWO to valid aisles.
740aA*    05/23/20  DAS  7.40a
     *      - Added whs-to-whs checks
740bA*    06/05/20  RH   7.40b
     *      - Enh: Rename RC20016 to RC20017.  Add W3osts to display
     *        putaway special status.
750aA*    04/07/21  NLK  7.50a
     *      - FIX: When selection 4. Handheld 16-line, if error on
     *        screen RC200.07S, threw session/device error
     *        zmpcpf missing 'when #lline = 16'
750bA*    06/11/21  LMC  7.50b
     *      - ENH: Adding Return Pallet License process.
     *      - ENH: Replace pomfr2 with pomfr3. pomfr2 has a mismatch
     *        on the keys at existing clients.
750cA*    07/19/21  LMC  7.50c
     *      - ENH: When processing return pallet if a license that
     *        is attached to the return pallet has already been
     *        put away skip loading it.
750dA*    01/26/22  DAS  7.50d
     *      - Reserved for Android changes
760aA*    12/28/22  LMC   7.60a
     *      - Fix: In ZZDLPK, if the user slot exist, and the
     *        transaction is at status 1 or 2, then put the license
     *        back on the dock(rcv/rtn/rwo)
     *      - Fix: In ZZDLPK, if the user slot exist, and the
     *        transaction is at status 3 do not put the
     *        license back on the dock, leave the license in the
     *        USR slot, allowing the client to transfer the product
     *        to the slot the product was located to.
     *        We will also close the transaction, so it will no longer
     *        appear on the open receiving transactions in an ended
     *        status.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: BiRite
BIR A*    01/20/05  MLB  BIR
     *      - Revised ZZCKNS to only allow virtual pick slots to be
     *        created for PIR slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Cheney Brothers
CBIaA*    02/01/07  RH   CBIa
     *      - Revised to display special designation code pick slot
     *        for special desig. item with no pick slot.
CBIbA*    02/07/07  RH   CBIb
     *      - Revised to display special desig pick slot or *NONE
     *        when overflow exists and no qty in pick slot.
     *
     *  --------------------------------------------------------------
     *  Upgrade 7.1 - add these CBI mod marks c,d,e,i,j,x,6,7  9.14.17
     *                                        f                9.20.17
     *      - Enh: Renamed format to RC20012. (4,5,a)
CBI0 *        Wrap 'cheney' around code
     *  --------------------------------------------------------------
     *
CBIcA*    02/07/07  RH   CBIc
     *      - Revised to display special desig pick slot or *NONE
     *        when overflow exists and no qty in pick slot.
CBIdA*    06/08/07  CBId-JDG
     *      - Added field 'W3EXPD' (Item exp date (Y/N))
CBIeA*    06/21/10  CBIe-JGD
     *      Add function key "F6" and its logic to generate a
     *      screen showing a list of available overstocks close
     *      to the pick slot of the item being put away starting
     *      with the closest one.
     *
     *      This function is utilized by the fork lift operator
     *      when puting away a received item.
CBIfA*    12/06/16  ---  CBIf
     *      - Enh: added logic to allow expiration date edit override.
      *
CBIiA *    12/04/14  CBIi-JGD
      *      Replace file POMFR1 with new logical POMFR2, the reason
      *      being, to get the actual receiving information (Exp Date).
      *      Before this change, if a received item info was loaded into
      *      POMFR and later an item return transaction was processed,
      *      this information is also loaded into POMFR without a PO #,
      *      because is a return, and if this return record is carrying
      *      the same label # as the receiving record (due to POMFR
      *      file weekly clean up no being working, thus creating label
      *      duplication) then when the receiving information is being
      *      retrieved thru PUTAWAY process using the transaction # to
      *      chain to PORCV to get the label # (PORLBL) to be used to
      *      chain to POMFR1, the record obtained is the Return record
      *      above described, and when the transaction # from file
      *      PORCV (which is the actual Receiving transaction #) is
      *      compared to the obtained POMFR1 transacion # (which
      *      is the Return transaction) not transaction match is
      *      obtained, disableing the retrieving of the Expiration
      *      Date, and the load of this date into the record
      *      identifying the location the item is being putaway.
CBIjA*    05/09/17  NLK  CBIj
     *      - Fix: Don't allow PutAway in non-active slot.
      *
CBIxA*    10/31/16  JCJ  CBIx
     *      - Revised to disable F8 on screen 3.
CBI6A*    09/13/01  HNK  CBI6
     *      - Display "Special Item" for item #>=997000.  Display
     *        designation code on screen 3.
     *
CBI7A*    02/06/17  NLK  CBI7
     *      - Do NOT allow putaway in QU slot. Hard Code.
     *        Req 2016141, User can putaway then can't transfer out
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Jack Palmer Foodservice
     *
JPFaA*    05/10/11  RH   JPFa
     *      - Revised to allow override of expired product on SC1
     *
ISYaA*----------------------------------------------------------------
     *  Client Custom Revisions: I Supply
ISY  *      - REMOVE 416F CHANGES.
ISYa *    04/12/04  RH   ISYa
     *      - Add screen7 to capture "FROM" location for standards pgm
     *      - Write to ISFLABEL, type D=Dock, S=Slot, L=Location
ISYb *    06/10/04  MLB  ISYb
     *      - Revise ZZCHK7 to override department to COOLR when dept
     *        FROZ is scanned and from location starts with 'C'.
ISYc *    01/30/06  RH   ISYc
     *      - Restore 4.16f changes for update to V4.17
ISYd *    02/07/06  RH   ISYd
     *      - Change SC7 to SC9 for 4.17 update.
     *      - Fix - sc1 was not going to sc9 for all cases.
ISYe *    08/24/09  GJA  ISYe
     *      - Change SC9 to SC9A for 5.10 update.
ISYf *    10/16/09  GJA  ISYf
     *      - Conversion of ISY mods for license tracking.
ISYg *    01/16/12  JCJ  ISYg
     *      - Fix: Fix description array elemetes missing.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Royal
RylaA*    02/28/08  JCJ  RYLa
     *      - Enh: added logic to allow expiration date edit override.
     *      - Enh: added item exception output for date edit override.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: FreshSense (Royal)
FSFa *    03/05/18  GJA  FSFa
     *      - Enh: Allow ability to show XDK
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Saval
     *
SVLaA*    08/04/09  RH   SVLa
     *      - Enh: Use Custom 16 X 20 screens for RF 16 line.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: VIP
VIPaA*    11/20/06  RH   VIPa
     *      - Revised to allow override of expired product on SC1
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Packers
PCKaA*    05/09/07  TJ   PCKa
     *      - Revised to ignore the inactive slot status code edit.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Westside
WST A*    05/07/14  LMC  WSTa
     *      - Added logic for pallet rotation if needed.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: Dairyland
DRYbA*    07/06/16  MR  DRYb
     *      - Per Hemant - Only allow quarantined products
     *        to be put in quarantined putaway slots.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions: SGC
SGCaA*    09/25/20  RH   SGCa
     *      - Enh:  Do not allow transfer to create virtual pick slot
     *        IT252 RF transfer has same mod.
SGCbA*    09/28/20  RH   SGCb
     *      - Enh:  Allow virtual pick slots for DRY aisle DR, level 2
     *        location 200 to 246 per Adam.  (Fellers product slots)
SGCcA*    09/30/20  RH   SGCc
     *      - Enh:  Allow virtual pick slots for CLR aisle CB, CN, CE
     *        limited locations per Ben M email 9-30
     *----------------------------------------------------------------
     *  Client Custom Revisions: Presto Foods
     *
PFCa *    09/07/20 RTR PFCa
     *      - Enh: Add support to program to capture information
     *        needed for APT Interface.
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  01 - 20   FIELD POSITION TO
     *  21 - 40   FIELD INPUT ERROR (REVERSE DISPLAY)
     *  90        VIEW MODE (PROTECT INPUT FIELDS)
     *  91        CHANGE MODE (PROTECT KEY)
417eA*  92        Manual putaway. Qty being split between multiple slots.
417eA*            Exit not allowed until entire qty has been slotted.
417eA*  93        Lot/license tracking item - Qty split not allowed.
     *  97        ALWAYS ON (USED FOR SFLEND KEYWORD)
     *  98        ERROR ON SCREEN (SOUND BUZZER)
     *  99        UNIVERSAL RECORD INDICATOR (VERY TEMPORARY USAGE)
     *
     *----------------------------------------------------------------

600eA*----------------------------------------------------------------
600eA*  Binding Directories
600eA*----------------------------------------------------------------
600eA
600eAHbnddir('BFCBND')

     *----------------------------------------------------------------
     *  File Specs
     *
600cDF*c200fm   cf   e             workstn
610aDF*c20001   cf   e             workstn
610dDF*c20002   cf   e             workstn
530bDF*c20003   cf   e             workstn
530bMF*c20004   cf   e             workstn
ISYeAF*c20005   cf   e             workstn
650eDF*rc20006   cf   e             workstn
650hDF*rc20007   cf   e             workstn
WSTaDF*rc20008   cf   e             workstn
700iDF*rc20009   cf   e             workstn
710aDF*rc20010   cf   e             workstn
710aDF*rc20011   cf   e             workstn
720bDF*rc20013   cf   e             workstn
720bDF*rc20014   cf   e             workstn
720eMF*rc20015   cf   e             workstn
740bMF*rc20016   cf   e             workstn
PFCaMF*rc20017   cf   e             workstn
PFCaMFrc20018   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     F                                     sfile(m16rec:msgk)
600cDF*irtran   uf a e           k disk
     FLabel7    if   e           k disk
WSTaAFlabel12   if   e           k disk    rename(lbrec:lb12) prefix(lb_)
417i FLicense   uf a e           k disk
WSTaAFLicense1  if   e           k disk    rename(lirec:lic) prefix(li_)
221 AFoptions   if   e           k disk
409 AFslot3     if   e           k disk
650eAFslot11    if   e           k disk    rename(slrec:sl11) prefix(s11_)
640aDF*slot2     uf a e           k disk
640aMFslot2     if   e           k disk
     F                                     rename(slrec:record)
640aAF                                     prefix(s_)
650fAFkititem   if   e           k disk
409 AFvslot2    uf a e           k disk
500bMFpomfr1    uf a e           k disk
500bDF*omfr1    if   e           k disk
750bDF*pomfr2    uf a e           k disk
750bMFpomfr3    uf a e           k disk
CBIi F                                     rename(pmrec:pmrec2)
409 AFLabel     uf a e           k disk
410 AFtask      if   e           k disk
600cDF*irtran2  if   e           k disk
600cDF*                                    rename(ptrec:ptrec2)
410 AFpiruser   if   e           k disk
412 AFpiritem   if   e           k disk
600cDF*irtran1  if   e           k disk
600cDF*                                    rename(ptrec:ptrec1)
414bAFdesig     if   e           k disk
CBIcAFdesigsp   if   e           k disk
415cAFLabelnk1  if   e           k disk
415hAFitemmsc   if   e           k disk
600eDF*orkput   uf a e           k disk
600eDF*orkput1  if   e           k disk
600eDF*                            rename(wkprec:wkprec1)
600eDF*orkput2  if   e           k disk
600eDF*                            rename(wkprec:wkprec2)
600eAFworkusr2  uf a e           k disk
600eAFworkusr5  if   e           k disk
     F                                     rename(wuRec:wurec5)
416dAFworkusr1  if   e           k disk
     F                                     rename(wuRec:wurec1)
417iAFstagh     if   e           k disk
417iAFstagd2    if   e           k disk
417rAFpofifo    if   e           k disk
501rAFporcv1    if   e           k disk
RylaAFitmexcp   uf a e           k disk
ISYaAFdocdoor   if   e           k disk
ISYaAFisflabel  o    e           k disk
750bAFpltlcns   uf   e           k disk

501fA*----------------------------------------------------------------
501fA*  Customer id
501fA*
501fAD @getcl          c                   const('GETCLIENT')
501fAD*
501fA /COPY QCOPYSRC,ID#BIRITE
CBIaA /COPY QCOPYSRC,ID#CHENEY
DRYaA /COPY QCOPYSRC,ID#DAIRYLA
VIPaA /COPY QCOPYSRC,ID#VIP
PCKaA /COPY QCOPYSRC,ID#PACKERS
JPF A /COPY QCOPYSRC,ID#PALMER
RYLaA /COPY QCOPYSRC,ID#ROYAL
510iA /COPY QCOPYSRC,ID#VIGO
SVLaA /COPY QCOPYSRC,ID#SAVAL
ISY A /COPY QCOPYSRC,ID#ISUPPLY
WSTaA /copy qcopysrc,id#westsid
SGCaA /copy qcopysrc,id#sgc
     *----------------------------------------------------------------
     *  Table and array definitions
     *
412fAD a2              s              1    dim(2)
412fAD a2n             s              1    dim(2)
     D a10             s              1    dim(10)
530bD *** desc            s             50    dim(4) ctdata perrcd(1)
530bM *** desc            s             50    dim(5) ctdata perrcd(1)
ISYaM *** desc            s             50    dim(8) ctdata perrcd(1)
CBIeMD desc            s             50    dim(10) ctdata perrcd(1)
409 AD hnd             s              2    dim(702)
409 AD ltr             s              1    dim(27) ctdata perrcd(27)
501uAD*** descsp          s             50    dim(4) ctdata perrcd(1)
720cMD descsp          s             50    dim(8) ctdata perrcd(1)

500hA*----------------------------------------------------------------
500hA*  DRI parameters
500hA*----------------------------------------------------------------
500hA
500hA /COPY *libl/qcopysrc,C#DRIPARMS
500hA
500hA*----------------------------------------------------------------
500hA*  Data Formats
500hA*----------------------------------------------------------------
500hA
500hA /COPY *libl/qcopysrc,C#ITEM
600aA /COPY *libl/qcopysrc,C#LICHIST
600dA /COPY *libl/qcopysrc,C#LICENSE
600cA /COPY *libl/qcopysrc,C#LICINFO
600cA /COPY *libl/qcopysrc,C#PIRTRAN
500hA /COPY *libl/qcopysrc,C#SLOT
500hA /COPY *libl/qcopysrc,C#SLOTDEF
500hAD saveVer#        s                   like($slver#)
600dDD*save$slot       s                   like($slot)
500hAD savepicke       s                   like($slpicke)
PAKdAD slpicke         s                   like($slpicke)
710hAD savedispe       s                   like($sldispe)

600dAD rcv$lcns        ds                  likeds($license)
600dAD sav$lcns        ds                  likeds($license)
600dAD rcv$slot        ds                  likeds($slot)
600dAD rcv$slot2       ds                  likeds($slot2)
600dAD usr$slot        ds                  likeds($slot)
600dAD usr$slot2       ds                  likeds($slot2)

600eA*----------------------------------------------------------------
600eA* Function prototypes.
600eA*----------------------------------------------------------------
600eA
600eA /copy qcopysrc,p.bfcdteti
740aA /copy qcopysrc,p.wwtfr

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

417qA*----------------------------------------------------------------
417qA*  Variables
417qA*----------------------------------------------------------------

     D $IAISL          s              3
     D $IDISP          s             12
     D $IDSP           s             38
     D $IWHDP          s              5
     D $LLWHS          s              3  0
     D $MSGF           s             10
610jAD $pLicense       s             15
610jAD $pLicense2      s             15
650iAD $pprg           s             10
650iAD $pprg2          s             10
     D $VAISL          s              3
     D $VLOC           s              3  0
     D $VPICK          s              1
     D $VPSEQ          s              5  0
     D $VRLVL          s              2  0
     D $VSTYP          s              1
     D $VWHDP          s              5
     D $VWHSE          s              3  0
     D #BITEM          s                   like(ITITEM)
     D #MSGID          s              7
     D #MSGTP          s              7
     D #ODESC          s                   like(ITDESC)
     D #ODESG          s                   like(ITDESG)
     D #OITEM          s                   like(ITITEM)
     D #OPDSC          s                   like(ITPDSC)
     D #OTYPE          s              1
     D #OWHDP          s                   like(ITWHDP)
     D #PGMQ           s             10
     D #todisp         s                   like(sldisp)
     D ACTCNT          s              1  0
650fAD odrslot         s             12
610bAD #odrslavl1      s                   like($slavl1)
600dAD actvLcnsExists  s               n
     D ASLFLG          s              1
     D ASLZON          s                   like(SDZONE)
     D BRKFLG          s              1
500hAD chk4err         s               n
     D CLEAR           s              5  0
     D CMDCHK          s              8
     D CMDTKN          s              1
     D COMAND          s              5  0
     D CURENT          s              1
     D CURTRN          s              7  0
     D CURTSK          s              6
     D CURTYP          s              1
511e D DTCHK           s              1
     D E               s              2  0
     D ENTER           s              5  0
     D EOF             s              1
500hMD error           s               n
     D EXIST           s              1
600cMD FINTIM          s                   like($PTETIM)
     D FLAGHS          s              1
     D FOREVR          s              1
     D forever         s               n
     D FOUND           s              1
     D FRSTPS          s              1
650iAD FRSTPS1         s              1
     D GOODLI          s              1
SGCaAD GOODSL          s              1
511c D GTITEM          s                   like(LBITEM)
600cAD gttrn#          s                   like($pttrn#)
     D HELP            s              5  0
     D I               s              2  0
501tAD interlvrpl      s              4    inz('*NO ')
     D ITMINF          s              1
     D J               s              2  0
     D K               s              3  0
     D KYAISL          s                   like(LBAISL)
     D KYLCNS          s                   like(LILCNS)
     D KYLOC1          s                   like(LBLOC)
     D KYLOC2          s                   like(LBLOC)
600eDD*KYPNBR          s                   like(WKPNBR)
600eDD*KYPTYP          s                   like(WKPTYP)
600eAD KYPNBR          s                   like(WUSCANNBR)
600eAD KYPTYP          s                   like(WUSCANTYPE)
600cMD KYSTAT          s                   like($PTSTAT)
     D KYSTYP          s                   like(LBSTYP)
     D KYWHSE          s                   like(W1WHSE)
     D KYZONE          s                   like(SDZONE)
     D K3PICK          s                   like(SLPICK)
     D K3STAT          s                   like(SLSTAT)
     D LBCNT           s              2  0
650jAD lccnt           s              3  0 inz(1)
650jAD lcpos           s              3  0 inz(0)
     D LFLAG           s              1
     D LKTRN#          s              7  0
     D LSTSCR          s              3
600dAD lsttim          s              6  0
     D MLTFLG          s              1
     D MSGK            s              4  0
     D NBRPCK          s              5  0
     D NEWLB           s              1
600aAD newlbl#         s                   like(lblbl#)
600aAD newtrn#         s                   like(lbtrn#)
     D NEWVS           s              1
     D NOMORE          s              1
     D NXTSCR          s              3
     D OCODE           s              8
     D ODISP           s                   like(SLDISP)
     D OTAISL          s              5  0
600cMD OTCREW          s                   like($PTCREW)
     D OTCUBE          s              9  3
600cMD OTEMP#          s                   like($PTEMP#)
     D OTGRP1          s              1
     D OTGRP2          s              1
     D OTPCS           s              5  0
     D OTPO            s              9
     D OTQTY1          s              5  0
     D OTQTY2          s              5  0
     D OTQTY3          s              5  0
600cMD OTSDTE          s                   like($PTSDTE)
600cMD OTSHFT          s                   like($PTSHFT)
600cMD OTSTIM          s                   like($PTSTIM)
     D OTSTYP          s              1
     D OTSWGT          s              9  2
     D OTTASK          s              6
     D OTWHDP          s              5
     D OVRRID          s              1
     D PHACTV          s                   like(SLACTV)
     D PHAISL          s                   like(SLAISL)
     D PHBLD           s                   like(SLBLD)
     D PHDESG          s                   like(SLDESG)
     D PHDISP          s                   like(SLDISP)
     D PHHAND          s                   like(SLHAND)
     D PHLOC           s                   like(SLLOC)
     D PHPSEQ          s                   like(SLPSEQ)
     D PHRLVL          s                   like(SLRLVL)
     D PHSDEF          s                   like(SLSDEF)
     D PHSIDE          s                   like(SLSIDE)
     D PHSLFD          s                   like(SLSLFD)
     D PHSTAT          s                   like(SLSTAT)
     D PHSTYP          s                   like(SLSTYP)
     D PHWHDP          s                   like(SLWHDP)
     D PHWHSE          s                   like(SLWHSE)
     D psexpd          s                   like(pmexpd)
     D psitem          s                   like(pmitem)
     D psmfgd          s                   like(pmmfgd)
     D pspo            s                   like(pmpo)
     D psseq           s                   like(pmseq)
     D pswhse          s                   like(pmwhse)
     D PTATYP          s              8
     D REDSPL          s              1
     D REFRSH          s              1
     D ROLLDN          s              5  0
     D ROLLUP          s              5  0
WSTaAD PutPalletDate   s                   like($litoentd)
WSTaAD OthPalletDate   s                   like($litoentd)
     D SBAISL          s                   like(LBAISL)
     D SBDISP          s                   like(LBDISP)
     D SBDSP2          s                   like(LBDSP2)
     D SBGRP1          s                   like(LBGRP1)
     D SBGRP2          s                   like(LBGRP2)
     D SBHAND          s                   like(LBHAND)
     D SBHIGH          s                   like(LBHIGH)
     D SBITEM          s                   like(LBITEM)
     D SBLOC           s                   like(LBLOC)
     D SBORD           s                   like(LBORD)
     D SBPAL#          s                   like(LBPAL#)
     D SBPBAT          s                   like(LBPBAT)
     D SBPO            s                   like(LBPO)
     D SBPSEQ          s                   like(LBPSEQ)
     D SBQRYF          s                   like(LBQRYF)
     D SBRDTE          s                   like(LBRDTE)
     D SBRLVL          s                   like(LBRLVL)
     D SBSEQ           s                   like(LBSEQ)
     D SBSTAT          s                   like(LBSTAT)
     D SBSTYP          s                   like(LBSTYP)
     D SBTIE           s                   like(LBTIE)
     D SBTRN#          s                   like(LBTRN#)
     D SBTYPE          s                   like(LBTYPE)
     D SBUCOD          s                   like(LBUCOD)
     D SBUCUB          s                   like(LBUCUB)
     D SBUTYP          s                   like(LBUTYP)
     D SBUWGT          s                   like(LBUWGT)
     D SBWHDP          s                   like(LBWHDP)
     D SBWHSE          s                   like(LBWHSE)
     D SCLEAR          s              1
CBIc D sdesig          s              1
     D SKIP6           s              1
     D SLCHK           s              1
600cMD STDATE          s                   like($PTSDTE)
     D STPFLG          s              1
     D STPZON          s                   like(SDZONE)
600cMD STRTIM          s                   like($PTSTIM)
600cMD STTIME          s                   like($PTSTIM)
SGCaAD SVAISL          s                   like(SLAISL)
SGCaAD SVLOC           s                   like(SLLOC)
SGCaAD SVRLVL          s                   like(SLRLVL)
     D SVDISP          s                   like(SLDISP)
     D SVEXPD          s                   like(SLEXPD)
     D SVITEM          s                   like($AITEM)
600eDD*SVPNBR          s                   like(WKPNBR)
600eDD*SVPTYP          s                   like(WKPTYP)
600eAD SVPNBR          s                   like(WUSCANNBR)
600eAD SVPTYP          s                   like(WUSCANTYPE)
640aAD svstatUSR       s                   like(SLSTAT)
600cMD SVTLEN          s                   like($PTDMIN)
600cMD SVTRN#          s                   like($PTTRN#)
     D SVWHSE          s                   like(W1WHSE)
     D T#TASK          s              6
600cMD TIMLEN          s                   like($PTDMIN)
     D TMPBEG          s              4  0
     D TMPEND          s              4  0
     D TODAY           s              8  0
     D TRNDTE          s              8  0
600cAD trnFound        s               n
     D TRNTIM          s              6  0
     D USESTR          s              4
600dAD usrSlotExists   s               n
600dAD actSlotExists   s               n
     D WARN            s              1
     D WDPFLG          s              1
     D WDPZON          s                   like(SDZONE)
     D WKLBL#          s                   like(W1LBL#)
     D WKLCNS          s                   like(W1LCNS)
650jAD wklicense       s                   like(w1lcns)
     D WOLBL#          s              7  0
     D WORQTY          s              5  0
     D WOTRN#          s              7  0
     D W1CREW          s                   like(USCREW)
     D W1EMP#          s                   like(USEMP#)
     D W1SHFT          s                   like(USSHFT)
     D W1STYP          s                   like(USSTYP)
     D W1TASK          s              6
     D W1WHDP          s                   like(USWHDP)
     D W3AQTY          s              7  0
     D W3RQTY          s              7  0
     D W7ZONE          s              6
     D W8CNT           s              2  0
     D ZDESC           s             30
500hAD zmsflag         s               n
500hAD zmflag          s               n
     D ZONE            s                   like(SDZONE)
600cMD ZZEDTE          s                   like($PTEDTE)
600cMD ZZETIM          s                   like($PTETIM)
600cMD ZZSDTE          s                   like($PTSDTE)
600cMD ZZSTIM          s                   like($PTSTIM)
530bAD w1lbl#          s              7  0
530bAD w5lbl#          s              7  0
530bD ***repack          s              1
510hAD yes             s              1    inz('Y')
510hAD no              s              1    inz('N')
510hAD #fromsldisp     s             12
510hAD kypick          s                   like(SLPICK)
610mAD kypitm          s                   like(LBITEM)
510hAD kyitem          s                   like(LBITEM)
rylaAD zzexpd          s              8  0
rylaAD warnp           s              1    inz('0')
rylaAD warno           s              1    inz('0')
600eAD wkRecType       s              3    inz('PUT')
700gAD save$pcmd       s                   like($pcmd)
700gAD FndEachPickSlt  s               n
710hAD warnIS          s              1    inz('0')
     D frloc           s              1
     D rtncd           s              8
     D slot            s             12
     D whse            s              3
     D wofrom          s             12
     D wotype          s              1
     D w9door          s              3  0
     D w9stag          s              6
740aAD wwrtn           s             10
740aAD wwmsg           s             99    varying
740aAD wwwhse          s              3s 0
750bAd holdrtnplt      s                   like(w1lcns)
     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------
ISYaAD   digit         C                   Const('0123456789')
650lAD valid           c                   const('0123456789 ABCDEFGHI-
     D                                     JKLMNOPQRSTUVWXYZabc-
     D                                     defghijklmnopqrstuvw-
     D                                     xyz* ')
     *----------------------------------------------------------------
414aA*  *RCVLBL  -  Receiving options
414aA*----------------------------------------------------------------
414aA*
414aA* Fields
414aA*
414aA*    OPLPGM  -  Receiving label program.
414aA*    OPUPCT  -  Ideal slot usage percentage.
414aA*    OPPDEF  -  PIR minimum number of slots priority.
414aA*    OPPBLD  -  PIR same build code priority.
414aA*    OPPACT  -  PIR same activity zone priority.
414aA*    OPPASL  -  PIR same aisle priority.
414aA*    OPPFRC  -  Forced PIR same aisle priority.
414aA*    OPFDEF  -  Fixed minimum number or slots priority.
414aA*    OPFASL  -  Fixed same aisle priority.
414aA*    OPFSID  -  Fixed same side priority.
414aA*    OPFLVL  -  Fixed highest level priority.
414aA*    OPPASL  -  PIR same aisle priority.
414aA*    OPPFRC  -  Force PIR same aisle priority.
414aA*    OPPLCN  -  Use generic license plates.
414aA*    OPPCHM  -  Check chimney (Y,N)
414aA*    OPPMIX  -  Allow mixed expiration dates in fixed home slot(Y,N)
414aA*    OPAPCK  -  Assign pick slots automatically for fixed items(Y,N)
221 A* Data structure
221 A*
417oMD oprdta          ds
221 AD  oplpgm                 1     10
221 AD  opupct                11     13  0
221 AD  oppdef                14     14  0
221 AD  oppbld                15     15  0
221 AD  oppact                16     16  0
221 AD  opfdef                17     17  0
221 AD  opfasl                18     18  0
221 AD  opfsid                19     19  0
221 AD  opflvl                20     20  0
221 AD  oppasl                21     21  0
221 AD  oppfrc                22     22
221 AD  opplcn                23     23
221 AD  optend               117    117
415jA*----------------------------------------------------------------
415jA*  *RFPUT   -  RF Putaway options
415jA*----------------------------------------------------------------
415jA*
415jA* Fields
415jA*
415jA*    OPVRFY  -  Verify scanned slot for manual putaway (Y,N)
417gA*    OPPQTY  -  Verify pallet quantity (Y,N)
417gA*    OPMSCN  -  Allow multiple license/labels to be scanned during
417gA*               putaway? (Y/N)
710hA*    OPISWN  -  Allow warning override on inactive slot edit.    g
417gA*
415jA*
415jA* Data structure
415jA*
415jAD opdat3          ds
415jAD  opvrfy                 1      1
415kAD  oppqty                 2      2
417gAD  opmscn                 3      3
710hAD  opiswn                 4      4
415jAD  opten3               117    117
750bA*----------------------------------------------------------------
750bA*  *RETURNS -  Customer Returns options
750bA*----------------------------------------------------------------
750bA*
750bA* Fields
750bA*
750bA*    OPRQCH  -  Allow changes to return quantity. (Y,N).
750bA*    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
750bA*    OPRFLB  -  Force return label entry. (Y/N)
750bA*    OPREXQ  -  Export Quick returns.(Y/N)
750bA*    OPRULB  -  Use label for putaway.(Y/N)
750bA*    OPREAD  -  Export as adjustments. (Y/N)
750bA*    OPREAC  -  Adjustment code to use.
750bA*    OPPLTL  -  Allow Pallet License.(Y/N)
750bA*
750bA* Data structure
750bA*
750bAD oprtndta        ds
750bAD  oprqch                 1      1
750bAD  oprqec                 2      2
750bAD  oprflb                 3      3
750bAD  oprexq                 4      4
750bAD  oprulb                 5      5
750bAD  opread                 6      6
750bAD  opreac                 7      8
750bAD  oppltl                 9      9
750bAD  optendrtn            117    117
     *----------------------------------------------------------------
     *  Called programs
     *
     D @cvtdt          c                   const('CVTDTE')
417t D @getsi          c                   const('GETSLOTITM')
     D @fmtit          c                   const('FRMTIT')
     D @fmtsl          c                   const('FRMTSL3')
     D @adjtr          c                   const('ADJTRAN  ')
     D @adjt2          c                   const('ADJTRAN2')
     D @adjtd          c                   const('ADJTSKDET')
     D @llptr          c                   const('UPDLLPTRK')
     D @addtr          c                   const('ADDSTDTRN')
530bAD @cvtbarsel      c                   const('CVTBARSEL')
CBIeAD @vzlist         c                   const('RC201CL')

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
     D  $ltype                81     88
409 AD  $lmput                89     89
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $lwhdp                22     26
ISYa D  $litem                27     41
ISYa D  $ldisp                42     53
     *
     D  $lrte                 22     26
     D  $lpo                  27     35
     D  $ltrn#                36     42  0
     *
221 AD  $ltrn1                19     25  0
     *
415cAD  $llblo                19     25  0
415cAD  $ltrn2                26     32  0
501tA*
501tA*   Interleaving replenishments parameters
501tA*
501tAD $rparm          ds
501tAD  $rcmd                  1      8
501tAD  $rprg                  9     18
501tAD  $ruky                 19     68
501tAD  $rrtn                 69     76
501tAD  $rerm                 77    136
501tAD  $rmsg                 77     80
501tAD  $rtype                81     88
501tA*
501tA*   Redefine key
501tA*
501tAD  $rwhse                19     21  0
501tAD  $rwhdp                22     26
501tAD  $raisl                27     29
501tAD  $rloc                 30     32  0
501tAD  $rrlvl                33     34  0
501tAD  $rhand                35     36
501tAD  $rdisp                37     48
501tA*
501tAD  $rtrn#                49     55  0
501tAD  $rrplt                56     57
501tA*
501tA*   Location info for interleave replenishment.
501tA*
501tAD $parm2          ds
501tAD  $whse2                 1      3  0
501tAD  $whdp2                 4      8
501tAD  $fasl2                 9     11
501tAD  $floc2                12     14  0
501tAD  $flvl2                15     16  0
501tAD  $fhnd2                17     18
501tAD  $fdis2                19     30
501tAD  $tasl2                31     33
501tAD  $tloc2                34     36  0
501tAD  $tlvl2                37     38  0
501tAD  $thnd2                39     40
501tAD  $tdis2                41     52
501tAD  $titem2               53     67
501tAD  $qrpl2                68     72  0
501tAD  $rplt2                73     74
501tAD  $ucod2                75     76
501tAD  $trn#2                77     83  0
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

417qA*----------------------------------------------------------------
417qA*  LT210 parameters
417qA*----------------------------------------------------------------

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
500 AD  $tnewlic#      s             15
     D  $tqty1         s              5  0
     D  $tqty2         s              3  0
     D  $tqty3         s              3  0
500kAD  $tnorm1        s              5  0
500kAD  $tnorm2        s              3  0
500kAD  $tnorm3        s              3  0
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

     D                 ds
     D  dshms                  1      6  0
     D  dshm                   1      4  0
     D  dshh                   1      2  0
     D  dsmm                   3      4  0
     D  dsss                   5      6  0
414 A*----------------------------------------------------------------
414 A*  API programs
414 A*
     D @apics          c                   const('APICVTSLT ')
416dA*----------------------------------------------------------------
416dA*  Screen text.
416dA*
     D w5txt1          c                   const('Last lic#:')
     D w5txt2          c                   const('Last lbl#:')
     D w5err1          c                   const('End of putaways. Sca-
     D                                     n new nbr.')
     D w6txt1          c                   const('Lic#')
     D w6txt2          c                   const('Lbl#')
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  erfld                  1     30
     *
     D  ertrn#                 1      4p 0
415hA*
415hAD  ernpck                 1      3p 0
415hAD  erapck                 4      6p 0
416dA*
416dAD  erptxt                 1     10
416dAD  erpnbr                11     14p 0
416eAD  erpusr                15     24
417iA*
417iAD  errqty                 1      4p 0
501nA*
501nAD  erdisp                 1     12
501nAD  eristyp               13     17
501nAD  ersstyp               18     22
600dA*
600dAD  erlcns                 1     15
600dAD  erdisp2               16     27
600dAD  erstat                28     28
600dAD  eritem                28     42
600dAD  eritem2               43     57
600dAD  ertrn#2               16     19p 0
600dAD  ertask                20     25
416dA*
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     D #msgfc          c                   const('QCPFMSG   ')
501uAD #msgsp          c                   const('PIRMSGFSP ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
600cD**----------------------------------------------------------------
600cD**  PIRTRAN record layout for use as parameters
600cD**
600cD**ptparm        e ds                  extname(pirtran)
     *----------------------------------------------------------------
     *  Program info data structure
     *
600dA /Copy qcopysrc,c#pgminfds
600dDD**              sds
600dDD**#prog            *proc
600dDD**#pgm             *proc
600dDD**#job                 244    253
600dDD**#user                254    263
600dDD**#jobn                264    269
600dDD**#jobdt               276    281  0
600dDD**#jobtm               282    287  0
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

RylaA*----------------------------------------------------------------
RylaA*  Redefinition data structures
RylaA*
RylaAD                 ds
RylaAD  dspo                   1      9
RylaAD  dslbl                 10     16  0
RylaAD  dsexpd                17     24  0
RylaAD  dsfdis                 1     12
RylaAD  dstdis                13     24
RylaA*
PFCaA*----------------------------------------------------------------
PFCaA*  Constants/Variables for APT
PFCaA
PFCaAd logapt          s               n   inz(*on)
PFCaAd rptsk1          c                   const('*PUTAWYBEG')
PFCaAd rptsk2          c                   const('*PUTAWYPLC')
PFCaAd rptsk3          c                   const('*PUTAWYEND')
PFCaAd rptsk4          c                   const('*PUTRTNBEG')
PFCaAd rptsk5          c                   const('*PUTRTNPLC')
PFCaAd rptsk6          c                   const('*PUTRTNEND')
PFCaAd rptsk7          c                   const('*PUTAWPLCE')
PFCaAd rptsk8          c                   const('*PUTRTPLCE')
PFCaA
PFCaAd                 ds
PFCaAd putbeg                  1      4
PFCaAd putplc                  5      8
PFCaAd putend                  9     12
PFCaA *
PFCaAd                 ds
PFCaAd aptype                 13     13
PFCaAd aploc                   1     20
PFCaAd svtask                 21     26
PFCaA *

600eA*----------------------------------------------------------------
600eA*  Time variables
600eA*----------------------------------------------------------------
600eA
600eAD CurrStamploc    s               z
600eAD CurrStampsys    s               z
600eAD CurrStampuc     s               z
600eA
600eAD bfcoffset       s              3  0 inz(0)

600bA*----------------------------------------------------------------
600bA*  Phrase Variables
600bA*----------------------------------------------------------------
600bA
600bA /COPY *libl/qcopysrc,c#phrasvar
600aAD  currFile       s             10
600aAD  currRoutine    s             20
600aAD  lastnxtscr     s              3
     D  stackCount     s              3  0
     D  aRoutine       s             20    dim(30)
600bA
600bA*----------------------------------------------------------------
600bA*  Phrases
600bA*----------------------------------------------------------------
600bA
600bA /COPY *libl/qcopysrc,c#phrases

600eDI*kprec2
600eDI*             wkpusr                      w2pusr
600eDI*             wkpnbr                      w2pnbr
600eDI*             wkptyp                      w2ptyp
600eDI*             wkptrn                      w2ptrn
600eDI*             wkpsts                      w2psts
600eDI*             wkpwhs                      w2pwhs
600eDI*             wkpwhd                      w2pwhd
600eDI*             wkpasl                      w2pasl
600eDI*             wkploc                      w2ploc
600eDI*             wkplvl                      w2plvl
600eDI*             wkphnd                      w2phnd
600eDI*             wkpdsp                      w2pdsp
600eD
600eAIwuRec1
600eAI              wuScanNbr                   w2pnbr
600eAI              wuScanType                  w2ptyp
600eAI              wuTrn#                      w2ptrn
600eAI              wuStat                      w2psts
600eAI              wuWhse                      w2pwhs
600eAI              wuPckWhdp                   w2pwhd
600eAI              wuPckAisl                   w2pasl
600eAI              wuPckLoc                    w2ploc
600eAI              wuPckrLvl                   w2plvl
600eAI              wuPckHand                   w2phnd
600eAI              wuPckDisp                   w2pdsp
600eAI              wuAddEUsr                   w2pusr
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
610jA*      pLicense - License (optional)
     *
     *    Returned Parameters
     *      None
     *
610jA*----------------------------------------------------------------
610jA*  Let the show begin .....
610jA*
610jAC     *entry        plist
610jAC                   parm                    $pLicense
650iAC                   parm                    $pprg
610jA
610jAC                   if        %parms >= 1
610jAC                   eval      $pLicense2 = $pLicense
610jAC                   else
610jAC                   eval      $pLicense2 = ' '
610jAC                   endif
610jA
650iAC                   if        %parms >= 2
650iAC                   eval      $pprg2 = $pprg
650iAC                   else
650iAC                   eval      $pprg2 = ' '
650iAC                   endif
650iA
     *----------------------------------------------------------------
     *  Main line
     *
600aAC                   eval      stackCount = 0
600bAC                   eval      currRoutine = 'main'
600bAC                   exsr      phpgmV1V2V3s

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
409 AC     nxtscr        caseq     '03 '         sc3
415kAC     nxtscr        caseq     '04 '         sc4
416dAC     nxtscr        caseq     '05 '         sc5
416dAC     nxtscr        caseq     '06 '         sc6
417iAC     nxtscr        caseq     '07 '         sc7
417iAC     nxtscr        caseq     '08 '         sc8
ISYaAC     nxtscr        caseq     '09A'         sc9a
501tAC     nxtscr        caseq     '09 '         sc9
650eAC     nxtscr        caseq     '10 '         sc10
650eAC     nxtscr        caseq     '11 '         sc11
PFCaAc     nxtscr        caseq     'APT'         scapt
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
600bAC                   exsr      phpgmV1V2V3e
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
600bA*
600bA*   Write tracking phrase of which screen is being displayed.
600bA*
600bAC                   exsr      phscrV1PgmV2
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
650iAC                             and frstps1 <> *on
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn61s                              50
610bAC                   else
610bAC                   exfmt     scrn1sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen61                             50
610bAC                   else
     C                   exfmt     screen1                              50
610bAC                   endif
500uAC                   endsl
     C                   endif
610b *
     C                   if        nxtscr = '02 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn62s                              50
610bAC                   else
501uAC                   exfmt     scrn2sp                              50
610bAC                   endif
501uAC                   other
     C                   exfmt     screen2                              50
501uAC                   endsl
     C                   endif
610b *
409 AC                   if        nxtscr = '03 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn63s                              50
610bAC                   else
501uAC                   exfmt     scrn3sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen63                             50
610bAC                   else
CBI0AC                   eval      *in46 = *off
CBI0AC                   if        client = cheney
CBI0AC                   eval      *in46 = *on
CBI0AC                   endif
409 AC                   exfmt     screen3                              50
610bAC                   endif
501uAC                   endsl
409 AC                   endif
610b *
415kAC                   if        nxtscr = '04 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn64s                              50
610bAC                   else
501uAC                   exfmt     scrn4sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen64                             50
610bAC                   else
415kAC                   exfmt     screen4                              50
610bAC                   endif
501uAC                   endsl
415kAC                   endif
610bAC*
416dAC                   if        nxtscr = '05 '
501uAC                   select
750bAc                   when      holdrtnplt <> ' ' and oppltl = 'Y'
750bAc                             and error = *off
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn65s                              50
610bAC                   else
501uAC                   exfmt     scrn5sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen65                             50
610bAC                   else
416dAC                   exfmt     screen5                              50
610bAC                   endif
501uAC                   endsl
416dAC                   endif
610bAC*
416dAC                   if        nxtscr = '06 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn66s                              50
610bAC                   else
501uAC                   exfmt     scrn6sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen66                             50
610bAC                   else
416dAC                   exfmt     screen6                              50
610bAC                   endif
501uAC                   endsl
416dAC                   endif
610bAC*
417iAC                   if        nxtscr = '07 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn67s                              50
610bAC                   else
501uAC                   exfmt     scrn7sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen67                             50
610bAC                   else
417iAC                   exfmt     screen7                              50
610bAC                   endif
501uAC                   endsl
417iAC                   endif
610bAC*
417iAC                   if        nxtscr = '08 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn68s                              50
610bAC                   else
501uAC                   exfmt     scrn8sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen68                             50
610bAC                   else
417iAC                   exfmt     screen8                              50
610bAC                   endif
501uAC                   endsl
417iAC                   endif
501tA*
PFCaAc                   if        nxtscr = 'APT'
PFCaAc                   exfmt     aptscrn                              50
PFCaAc                   endif

ISYaAC                   if        nxtscr = '09A'
ISYaAC                   exfmt     screen9A                             50
ISYaAC                   endif
ISYaA*
501tAC                   if        nxtscr = '09 '
501uAC                   select
501uAC                   when      e$lng = 'SP'
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     scrn69s                              50
610bAC                   else
501uAC                   exfmt     scrn9sp                              50
610bAC                   endif
501uAC                   other
610b C                   if        #lline = '16' and client = saval
610bAC                   exfmt     screen69                             50
610bAC                   else
501tAC                   exfmt     screen9                              50
610bAC                   endif
501uAC                   endsl
501tAC                   endif
650eA*
650eAC                   if        nxtscr = '10 '
650eAC                   select
650eAC                   when      e$lng = 'SP'
650eAC                   if        #lline = '16' and client = saval
650eAC                   exfmt     scrn610s                             50
650eAC                   else
650eAC                   exfmt     scrn10sp                             50
650eAC                   endif
650eAC                   other
650eAC                   if        #lline = '16' and client = saval
650eAC                   exfmt     screen610                            50
650eAC                   else
650eAC                   exfmt     screen10                             50
650eAC                   endif
650eAC                   endsl
650eAC                   endif
650eA*
650eAC                   if        nxtscr = '11 '
650eAC                   select
650eAC                   when      e$lng = 'SP'
650eAC                   if        #lline = '16' and client = saval
650eAC                   exfmt     scrn611s                             50
650eAC                   else
650eAC                   exfmt     scrn11sp                             50
650eAC                   endif
650eAC                   other
650eAC                   if        #lline = '16' and client = saval
650eAC                   exfmt     screen611                            50
650eAC                   else
650eAC                   exfmt     screen11                             50
650eAC                   endif
650eAC                   endsl
650eAC                   endif
600bA*
600bA*   Write tracking phrase of what was pressed.
600bA*
600bAC                   exsr      phV2onV1
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
413aMC                   setoff                                       3334
     C                   setoff                                       363738
     C                   setoff                                       3940
710aAC                   setoff                                       42
415gMC                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
414 AC                   eval      redspl = *off
     C                   eval      e = 0
650iAC                   eval      frstps1 = *off
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
409 AC                   eval      $lmput = 'N'
415lAC                   eval      *in92 = *off
415lAC                   eval      newlb = *off
415lAC                   eval      newvs = *off
416dAC                   eval      w5txt = *blanks
416fMC                   eval      w5lst# = *blanks
416dAC                   eval      w5cnt = *zeros
     C                   eval      ptatyp = *zeros
     C                   exsr      zzfil1
     C                   eval      refrsh = *off
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
409 AC                   eval      $lmput = 'N'
     C                   exsr      zzfil2
     C                   eval      refrsh = *off
     C     end02i        endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  Screen 03 initialization
409 A*
409 AC     scr03i        begsr
409  C                   eval      nxtscr = '03 '
409 AC                   eval      *in06 = *on
409 AC                   eval      $lmput = 'Y'
409 AC                   eval      exist = *off
415lA*
415lA*    Partial put-away in progress. Load qty remaining.
415lA*
415lAC                   if        lbqrmn <> *zeros
415lAC                   z-add     lbqrmn        w3rqty
415lAC                   else
409 AC                   z-add     lbqpck        w3rqty
415lAC                   endif
409 AC                   z-add     lbqalc        w3aqty
409 AC                   exsr      zzget3
409 AC                   exsr      zzfil3
409 AC                   eval      refrsh = *off
415eAC                   eval      ovrrid = *off
409 AC     end03i        endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  Screen 04 initialization  (Screen 1A)
415kA*
415kAC     scr04i        begsr
415kAC                   eval      nxtscr = '04 '
415kAC                   eval      *in06 = *on
415kAC                   eval      $lmput = 'Y'
415kAC                   eval      exist = *off
415kAC                   eval      newvs = *off
415kAC                   eval      newlb = *off
415kAC                   exsr      zzget4
415kAC                   exsr      zzfil4
415kAC                   eval      refrsh = *off
415kAC     end04i        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  Screen 05 initialization
416dA*
416dAC     scr05i        begsr
416dAC                   eval      nxtscr = '05 '
416dAC                   eval      exist = *off
416dAC                   eval      newvs = *off
416dAC                   eval      newlb = *off
416hAC                   eval      frstps = *off
416dAC                   exsr      zzget5
416dAC                   exsr      zzfil5
416dAC                   eval      refrsh = *off
416dAC     end05i        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  Screen 06 initialization
416dA*
416dAC     scr06i        begsr
416dAC                   eval      nxtscr = '06 '
416dAC                   eval      exist = *off
416dAC                   eval      newvs = *off
416dAC                   eval      newlb = *off
416dA*
416dA*    User hasn't skipped a put away. Start with first one.
416dA*
416dAC                   if        skip6 = *off
600eDC**   pkkey1        setll     workput1
600jMC     wkkey2p       setll     workUsr5
416dAC                   eval      w6cnt1 = *zeros
416dAC                   endif
416dAC                   exsr      zzget6
416dA*
416dA*    End of putaways for this user - Return to Screen 1.
416dA*
416dAC                   if        nomore = *on
416dA*
501tA*    Check if any Interleaving Replenishments are available.
416dA*
501tAC                   eval      $rcmd = '*START  '
501tAC                   exsr      zzckirpl
416dA*
501tA*    User has selected an Interleaving Replenishment.
416dA*
501tAC                   If        interlvrpl = '*YES'
501tAC                   exsr      scr09i
501tAC                   else
416dAC                   exsr      scr01i
501tAC                   endif
416dAC                   goto      end06i
416dAC                   endif
416dAC                   exsr      zzfil6
416dAC                   move      *off          refrsh
416dAC     end06i        endsr
417i *----------------------------------------------------------------
417i *
417iA*  Screen 07 initialization
417i *
417iAC     scr07i        begsr
417nAC     *inkl         cabeq     *on           skp07i
417i *
417i *  If part was put away before stage.
417i *
417i C                   if        w3rqty <> worqty
417i *
417i *  Save original put away transaction.
417i *
417i C                   exsr      zzsavt
417i *
417i *  Close original put away transaction.
417i *
417i C                   exsr      zzclsp
417i *
417i *  Create new putawy trans and label for staged qty.
417i *
417i C                   exsr      zzupds
610iAC                   eval      newlb=*off
417i C                   else
417i *
417i *  If staging total qty, re-set previous put away transaction.
417i *
417i C                   exsr      zzrset
417i C                   exsr      zzsavt
417i C                   endif
417i *
417n *  Create stage transaction and label record.
417i *
417n CSR   skp07i        tag
417i C                   eval      nxtscr = '07 '
417i C                   exsr      zzfil7
417iAC     end07i        endsr
417i *----------------------------------------------------------------
417i *
417iA*  Screen 08 initialization
417i *
417i C     scr08i        begsr
417i C                   eval      nxtscr = '08 '
417i C                   exsr      zzget8
417i C                   exsr      zzfil8
417iAC     end08i        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  Aptscrn initialization
PFCaA*
PFCaAc     scrapti       begsr
PFCaA
PFCaAc                   move      'APT'         nxtscr            3
PFCaAc                   eval      *in06 = *on
PFCaAc                   eval      exist = *off
PFCaA
PFCaAc                   exsr      zzfil7
PFCaAc                   eval      refrsh = *off
PFCaAc                   eval      ovrrid = *off
PFCaA
PFCaAc     endapti       endsr
ISYa *----------------------------------------------------------------
ISYa *
ISYaA*  Screen 09A initialization
ISYa *
ISYa C     scr09ai       begsr
ISYa C                   eval      nxtscr = '09A'
ISYaAC                   eval      *in06 = *on
ISYaAC                   eval      exist = *off
ISYa C                   exsr      zzfil9A
ISYa C                   eval      refrsh = *off
ISYaAC                   eval      ovrrid = *off
ISYaAC     end09ai       endsr
501tA*----------------------------------------------------------------
501tA*
501tA*  Screen 09 initialization
501tA*
501tAC     scr09i        begsr
501tA*
501tAC                   eval      nxtscr = '09 '
501tAC                   exsr      zzfil9
501tA*
501tAC     end09i        endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  Screen 10 initialization
650eA*
650eAC     scr10i        begsr
650eAC                   eval      nxtscr = '10 '
650eAC                   exsr      zzfil10
650eAC                   eval      refrsh = *off
650eAC     end10i        endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  Screen 11 initialization
650eA*
650eAC     scr11i        begsr
650eAC                   eval      nxtscr = '11 '
650eAC                   exsr      zzfil11
650eAC                   eval      refrsh = *off
650eAC     end11i        endsr
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
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
416dAC                   eval      lstscr = nxtscr
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
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
     C                   exsr      zzabrt
     C                   eval      nxtscr = 'EOJ'
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
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
     C                   eval      refrsh = *off
     C                   exsr      zzabrt
     *
640jA*    Remove any existing previously scanned in entries for this user.
     *
640jAC                   exsr      zzdlpk
640jAC*
416dAC                   select
     *
416dA*    Return to select screen to select new putaway.
     *
416dAC                   when      lstscr = '06 '
416dAC                   exsr      scr06i
416dA*
416dA*    Return to scan screen to scan in more putaways.
     *
416dAC                   when      lstscr = '05 '
416dAC                   exsr      scr05i
416dA*
416dAC                   other
416dA*
     C                   exsr      scr01i
416dAC                   endsl
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
414 AC     redspl        cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     *
     *  Test for other command keys AFTER verification and update.
     *
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     C     endsc2        endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  SC3  -  Screen 3
409 A*
409 AC     sc3           begsr
409 A*
409 A*  Test for F3 - Exit
409 A*
409 AC                   if        *inkc  and
412CAC                             not *in92
409 AC                   exsr      zzabrt
     C                   eval      nxtscr = 'EOJ'
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
409 AC                   goto      endsc3
409 AC                   endif
409 A*
409 A*  Test for F5 - Refresh
409 A*
409 AC                   if        *inke
409 AC                   eval      refrsh = *on
409 AC                   exsr      scr03i
409 AC                   goto      endsc3
409 AC                   endif
720bA*
720bA*      F11 - Request next Pick Slot
720bA*
720bAC                   if        *inkk
720bAC                   eval      $pcmd = '*NEXT'
720bAC                   exsr      zzget3
720bAC                   goto      endsc3
720bAC                   endif
409 A*
409 A*  Test for F12 - Previous
409 A*
409 AC                   if        *inkl  and
412CAC                             not *in92
409 AC                   eval      refrsh = *off
409 AC                   exsr      zzabrt
416dAC                   select
     *
416dA*    Return to select screen to select new putaway.
     *
416dAC                   when      lstscr = '06 '
416dAC                   exsr      scr06i
416dA*
416dA*    Return to scan screen to scan in more putaways.
     *
416dAC                   when      lstscr = '05 '
416dAC                   exsr      scr05i
416dA*
416dAC                   other
416dA*
409 AC                   exsr      scr01i
416dAC                   endsl
409 AC                   goto      endsc3
409 AC                   endif
409 A*
409 A*  Test for other command keys BEFORE verification and update.
409 A*
409 AC                   move      '*BEFORE '    cmdchk
409 AC                   exsr      zzcmd3
409 AC     cmdtkn        cabeq     *on           endsc3
417iAC     error         cabeq     *on           endsc3
CBIeAC     redspl        cabeq     *on           endsc3

409 A*
409 A*  Some other key pressed.
409 A*
409 A*     Check input and write/update record.
409 A*
409 AC                   exsr      zzchk3
409 AC     error         cabeq     *on           endsc3
414 AC     redspl        cabeq     *on           endsc3
409 AC                   exsr      zzupd3
409 AC     error         cabeq     *on           endsc3
409 A*
409 A*  Test for other command keys AFTER verification and update.
409 A*
409 AC                   move      '*AFTER  '    cmdchk
409 AC                   exsr      zzcmd3
409 AC     cmdtkn        cabeq     *on           endsc3
409 A*
409 AC     endsc3        endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  SC4  -  Screen 4  (Screen1A)
415kA*
415kAC     sc4           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc  and
     C                             not *in92
416dA*
416dA*    Abort needed only when transaction# scanned in. For all
416dA*    other types, transaction not put into inuse status until
416dA*    transaction scanned for putaway.
417gA*    Note: If OPMSCN is N, then putaway is limited to one at a time.
     *
416dAC                   if        ptatyp = '*TRAN   '  or
417gAC                             opmscn = 'N'
     C                   exsr      zzabrt
416dAC                   endif
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   eval      refrsh = *on
     C                   exsr      scr04i
     C                   goto      endsc4
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl  and
     C                             not *in92
     C                   eval      refrsh = *off
416dA*
416dA*    Abort needed only when transaction# scanned in. For all
416dA*    other types, transaction not put into inuse status until
416dA*    transaction scanned for putaway.
417gA*    Note: If OPMSCN is N, then putaway is limited to one at a time.
     *
416dAC                   if        ptatyp = '*TRAN   '  or
417gAC                             opmscn = 'N'
     C                   exsr      zzabrt
416dAC                   endif
416daC                   select
     *
416dA*    Return to scan in more lic#/lbl#'s.
     *
416dAC                   when      lstscr = '05 '
416dAC                   exsr      scr05i
416dAC                   other
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
     C                   exsr      scr01i
416dAC                   endsl
     C                   goto      endsc4
     C                   endif
     *
     *  Test for other command keys BEFORE verification and update.
     *
     C                   move      '*BEFORE '    cmdchk
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
     C                   move      '*AFTER  '    cmdchk
     C                   exsr      zzcmd4
     C     cmdtkn        cabeq     *on           endsc4
     *
     C     endsc4        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  SC5  -  Screen 5
416dA*
416dAC     sc5           begsr
416dA*
416dA*  Test for F3 - Exit
416dA*
416dAC                   if        *inkc
416dAC                   eval      refrsh = *off
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
416dAC                   exsr      scr01i
416dAC                   goto      endsc5
416dAC                   endif
416dA*
416dA*  Test for F5 - Refresh
416dA*
416dAC                   if        *inke
416dAC                   eval      refrsh = *on
416dAC                   exsr      scr05i
416dAC                   goto      endsc5
416dAC                   endif
416dA*
416dA*  Test for F12 - Previous
416dA*
416dAC                   if        *inkl
416dAC                   eval      refrsh = *off
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
416dAC                   exsr      scr01i
416dAC                   goto      endsc5
416dAC                   endif
416dA*
416dA*  Test for other command keys BEFORE verification and update.
416dA*
416dAC                   move      '*BEFORE '    cmdchk
416dAC                   exsr      zzcmd5
416dAC     cmdtkn        cabeq     *on           endsc5
416dA*
416dA*  Some other key pressed.
416dA*
416dA*     Check input and write/update record.
416dA*
416dAC                   exsr      zzchk5
416dAC     error         cabeq     *on           endsc5
416dAC                   exsr      zzupd5
416dAC     error         cabeq     *on           endsc5
416dA*
416dA*  Test for other command keys AFTER verification and update.
416dA*
416dAC                   move      '*AFTER  '    cmdchk
416dAC                   exsr      zzcmd5
416dAC     cmdtkn        cabeq     *on           endsc5
416dA*
416dAC     endsc5        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  SC6  -  Screen 6
416dA*
416dAC     sc6           begsr
416dA*
416dA*  Test for F3 - Exit
416dA*
416dAC                   if        *inkc
416dAC                   eval      refrsh = *off
416dAC                   exsr      scr05i
416dAC                   goto      endsc6
416dAC                   endif
416dA*
416dA*  Test for F5 - Refresh
416dA*
416dAC                   if        *inke
416dAC                   eval      refrsh = *on
416dAC                   exsr      scr06i
416dAC                   goto      endsc6
416dAC                   endif
416dA*
416dA*  Test for F12 - Previous
416dA*
416dAC                   if        *inkl
416dAC                   eval      refrsh = *off
416dAC                   exsr      scr05i
416dAC                   goto      endsc6
416dAC                   endif
416dA*
416dA*  Test for other command keys BEFORE verification and update.
416dA*
416dAC                   move      '*BEFORE '    cmdchk
416dAC                   exsr      zzcmd6
416dAC     cmdtkn        cabeq     *on           endsc6
416dA*
416dA*  Some other key pressed.
416dA*
416dA*     Check input and write/update record.
416dA*
416dAC                   exsr      zzchk6
416dAC     error         cabeq     *on           endsc6
416dAC                   exsr      zzupd6
416dAC     error         cabeq     *on           endsc6
416dA*
416dA*  Test for other command keys AFTER verification and update.
416dA*
416dAC                   move      '*AFTER  '    cmdchk
416dAC                   exsr      zzcmd6
416dAC     cmdtkn        cabeq     *on           endsc6
416dA*
416dAC     endsc6        endsr
417i *----------------------------------------------------------------
417i *
417iA*  SC7  -  Screen 7
417i *
417i C     sc7           begsr
417i *
417i *  Test for F3 - Exit
417i *
417i C                   if        *inkc
417i C                   eval      nxtscr = 'EOJ'
417i C                   goto      endsc7
417i C                   endif
417i *
417i *  Test for F5 - Refresh
417i *
417i C                   if        *inke
417i C                   exsr      scr07i
417i C                   goto      endsc7
417i C                   endif
417i *
417i *  Test for F12 - Previous
417i *
 17i C                   if        *inkl
     *
417s *  No partial quantity was put away, restart original putaway.
     *
417nAC                   if        w3rqty = worqty
600cD**    ptkey         chain(n)  pirtran                            79
417uAC                   eval      @ptrn# = wotrn#
417uAC                   else
600cD**    pntrn#        chain(n)  pirtran                            79
417uAC                   eval      @ptrn# = pntrn#
610iAC                   eval      newlb=*off
417uAC                   endif
600cA
600cAC                   eval      gttrn#  = @ptrn#
600cAC                   exsr      zzgett
600cA
417n C                   eval      @pdate = otsdte
417n C                   eval      @ptime = otstim
417n C                   call      @adjt2
417n C                   parm      '*START  '    @pcmd2
417n C                   parm                    #job
417n C                   parm      '*INTER  '    @ptype
417uMC                   parm                    @ptrn#            7 0
417n C                   parm      ottask        @ptask
417n C                   parm      w1whse        @pwhse
417n C                   parm      otwhdp        @pwhdp
417n C                   parm      otstyp        @pstyp
417n C                   parm      otcube        @pcube
417n C                   parm      otswgt        @pswgt
417n C                   parm      otpcs         @ppcs
417n C                   parm      otaisl        @paisl
417n C                   parm      otqty1        @pqty1
417n C                   parm      otqty2        @pqty2
417n C                   parm      otqty3        @pqty3
417n C                   parm      otpo          @prte
417n C                   parm      otpo          @ppo
417n C                   parm      otgrp1        @pgrp1
417n C                   parm      otgrp2        @pgrp2
417n C                   parm                    @pdate
417n C                   parm                    @ptime
600dMC                   parm      #curruser     @puser
417n C                   parm      ' '           @prtn
417n C                   parm      ' '           @pmsg
417i *
417i C                   exsr      scr03i
417i C                   goto      endsc7
417i C                   endif
417i *
417i *  Test for other command keys BEFORE verification and update.
417i *
417i C                   move      '*BEFORE '    cmdchk
417i C                   exsr      zzcmd7
417i C     cmdtkn        cabeq     *on           endsc7
417i *
417i *  Some other key pressed.
417i *
417i *     Check input and write/update record.
417i *
417i C                   exsr      zzchk7
417i C     error         cabeq     *on           endsc7
417i C                   exsr      zzupd7
417i C     error         cabeq     *on           endsc7
417i *
417i *  Test for other command keys AFTER verification and update.
417i *
417i C                   move      '*AFTER  '    cmdchk
417i C                   exsr      zzcmd7
417i C     cmdtkn        cabeq     *on           endsc7
417i *
417iAC     endsc7        endsr
417i *----------------------------------------------------------------
417i *
417iA*  SC8  -  Screen 8
417i *
417iAC     sc8           begsr
417i *
417i *  Test for F3 - Exit
417i *
417i C                   if        *inkc  and
417i C                             not *in92
417i C                   eval      nxtscr = 'EOJ'
417i C                   goto      endsc8
417i C                   endif
417i *
417i *  Test for F5 - Refresh
417i *
417i C                   if        *inke
417i C                   exsr      scr08i
417i C                   goto      endsc8
417i C                   endif
417i *
417i *  Test for F12 - Previous
417i *
417nMC                   if        *inkl
417uAC                   eval      newlb = *off
417i C                   exsr      scr07i
417i C                   goto      endsc8
417i C                   endif
417i *
417i *  Test for other command keys BEFORE verification and update.
417i *
417i C                   move      '*BEFORE '    cmdchk
417i C                   exsr      zzcmd8
417i C     cmdtkn        cabeq     *on           endsc8
417i *
417i *  Some other key pressed.
417i *
417i *     Check input and write/update record.
417i *
417i C                   exsr      zzchk8
417i C     error         cabeq     *on           endsc8
417i C                   exsr      zzupd8
417i C     error         cabeq     *on           endsc8
417i *
417i *  Test for other command keys AFTER verification and update.
417i *
417i C                   move      '*AFTER  '    cmdchk
417i C                   exsr      zzcmd8
417i C     cmdtkn        cabeq     *on           endsc8
417i *
417iAC     endsc8        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  SCAPT -  APT Screen
PFCaA*
PFCaAc     scapt         begsr
PFCaA
PFCaAc*  Test for F3 - Exit
PFCaA
PFCaAc                   if        *inkc = *on and *in92 = *off
PFCaAc                   exsr      zzabrt
PFCaAc                   move      'EOJ'         nxtscr
PFCaAc*    Remove any existing previously scanned in entries for this user.
PFCaAc                   exsr      zzdlpk
PFCaAc                   goto      endscapt
PFCaAc                   endif
PFCaA
PFCaAc*  Test for F5 - Refresh
PFCaA
PFCaAc                   if        *inke = *on
PFCaAc                   eval      refrsh = *on
PFCaAc                   exsr      scrapti
PFCaAc                   goto      endscapt
PFCaAc                   endif
PFCaA
PFCaAc*  Test for F12 - Previous
PFCaA
PFCaAc                   if        *inkl = *on and *in92 = *off
PFCaAc                   eval      refrsh = *off
PFCaAc                   exsr      zzabrt
PFCaAc                   select
PFCaAc*    Return to select screen to select new putaway.
PFCaAc                   when      lstscr = '08 '
PFCaAc                   exsr      scr08i
PFCaA
PFCaAc*    Return to scan screen to scan in more putaways.
PFCaAc                   when      lstscr = '07 '
PFCaAc                   exsr      scr07i
PFCaA
PFCaAc                   other
PFCaA
PFCaAc                   exsr      scr01i
PFCaAc                   endsl
PFCaAc                   goto      endscapt
PFCaAc                   endif
PFCaA
PFCaAc*  Test for other command keys BEFORE verification and update.
PFCaA
PFCaAc                   move      '*BEFORE '    cmdchk            8
PFCaAc                   exsr      zzcmdapt
PFCaAc     cmdtkn        cabeq     *on           endscapt
PFCaA
PFCaAc*  Some other key pressed.
PFCaA
PFCaAc*     Check input and write/update record.
PFCaA
PFCaAc                   exsr      zzchkapt
PFCaAc     error         cabeq     *on           endscapt
PFCaAc     redspl        cabeq     *on           endscapt
PFCaAc                   exsr      zzupdapt
PFCaAc     error         cabeq     *on           endscapt
PFCaA
PFCaAc*  Test for other command keys AFTER verification and update.
PFCaA
PFCaAc                   move      '*AFTER  '    cmdchk
PFCaAc                   exsr      zzcmdapt
PFCaAc     cmdtkn        cabeq     *on           endscapt
PFCaA
PFCaAc     endscapt      endsr
ISY  *----------------------------------------------------------------
ISY  *
ISY A*  SC9A -  Screen 9A
ISY  *
ISY AC     sc9A          begsr
ISY  *
ISY  *  Test for F3 - Exit
ISYa *
ISYa C                   if        *inkc  and
ISYa C                             not *in92
ISYa C                   exsr      zzabrt
ISYa C                   eval      nxtscr = 'EOJ'
ISYa **  Remove any existing previously scanned in entries for this user
ISYa C                   exsr      zzdlpk
ISYa C                   goto      endsc9a
ISYa C                   endif
ISYa *
ISYa *  Test for F5 - Refresh
ISYa *
ISYa C                   if        *inke
ISYa C                   eval      refrsh = *on
ISYa C                   exsr      scr09ai
ISYa C                   goto      endsc9a
ISYa C                   endif
ISYa *
ISYa *  Test for F12 - Previous
ISYa *
ISYa C                   if        *inkl  and
ISYa C                             not *in92
ISYaAC                   eval      refrsh = *on
ISYa C                   exsr      zzabrt
ISYaAC                   select
ISYa *  Return to select screen to select new put away
ISYaAC                   when      lstscr = '06 '
ISYa C                   exsr      scr06i
ISYa *  Return to scan screen to scan in more putaways.
ISYaAC                   when      lstscr = '05 '
ISYa C                   exsr      scr05i
ISYa C                   other
ISYa C                   exsr      scr01i
ISYa C                   endsl
ISYa C                   goto      endsc9a
ISYa C                   endif
ISYa *
ISYa *  Test for other command keys BEFORE verification and update.
ISYa *
ISYa C                   move      '*BEFORE '    cmdchk
ISYa C                   exsr      zzcmd9a
ISYa C     cmdtkn        cabeq     *on           endsc9a
ISYa *
ISYa *  Some other key pressed.
ISYa *
ISYa *     Check input and write/update record.
ISYa *
ISYa C                   exsr      zzchk9a
ISYa C     error         cabeq     *on           endsc9a
ISYa C     redspl        cabeq     *on           endsc9a
ISYa C                   exsr      zzupd9a
ISYa C     error         cabeq     *on           endsc9a
ISYa *
ISYa *  Test for other command keys AFTER verification and update.
ISYa *
ISYa C                   move      '*AFTER  '    cmdchk
ISYa C                   exsr      zzcmd9a
ISYa C     cmdtkn        cabeq     *on           endsc9a
ISYa *
ISYaAC     endsc9a       endsr
501tA*
501tA*----------------------------------------------------------------
501tA*
501tA*  SC9  -  Screen 9
501tA*
501tAC     sc9           begsr
501tA*
501tA*  Test for F3 - Exit
501tA*
501tAC                   if        *inkc
501tAC                   eval      refrsh = *off
501tAC                   exsr      scr01i
501tAC                   goto      endsc9
501tAC                   endif
501tA*
501tA*  Test for F5 - Refresh
501tA*
501tAC                   if        *inke
501tAC                   eval      refrsh = *on
501tAC                   exsr      scr09i
501tAC                   goto      endsc9
501tAC                   endif
501tA*
501tA*  Test for F12 - Previous
501tA*
501tAC                   if        *inkl
501tAC                   eval      refrsh = *off
501tAC                   exsr      scr09i
501tAC                   goto      endsc9
501tAC                   endif
501tA*
501tA*  Test for other command keys BEFORE verification and update.
501tA*
501tAC                   move      '*BEFORE '    cmdchk
501tAC                   exsr      zzcmd9
501tAC     cmdtkn        cabeq     *on           endsc9
501tA*
501tA*  Some other key pressed.
501tA*
501tA*     Check input and write/update record.
501tA*
501tAC                   exsr      zzchk9
501tAC     error         cabeq     *on           endsc9
501tAC                   exsr      zzupd9
501tAC     error         cabeq     *on           endsc9
501tA*
501tA*  Test for other command keys AFTER verification and update.
501tA*
501tAC                   move      '*AFTER  '    cmdchk
501tAC                   exsr      zzcmd9
501tAC     cmdtkn        cabeq     *on           endsc9
501tA*
501tAC     endsc9        endsr
501tA*
650eA*----------------------------------------------------------------
650eA*
650eA*  SC10 -  Screen 10
650eA*
650eAC     sc10          begsr
650eA*
650eA*
650eA*  Test for F12 - Previous
650eA*
650eAC                   if        *inkl
650eA*
650eA*    Remove any existing previously scanned in entries for this user.
650eA*
650eAC                   exsr      scr03i
650eAC                   goto      endsc10
650eAC                   endif
650eA*
650eA*  Test for other command keys BEFORE verification and update.
650eA*
650eAC                   move      '*BEFORE '    cmdchk
650eAC                   exsr      zzcmd10
650eAC     cmdtkn        cabeq     *on           endsc10
650eA*
650eA*  Some other key pressed.
650eA*
650eA*     Check input and write/update record.
650eA*
650eAC                   exsr      zzchk10
650eAC     error         cabeq     *on           endsc10
650eAC                   exsr      zzupd10
650eAC     error         cabeq     *on           endsc10
650eA*
650eA*  Test for other command keys AFTER verification and update.
650eA*
650eAC                   move      '*AFTER  '    cmdchk
650eAC                   exsr      zzcmd10
650eAC     cmdtkn        cabeq     *on           endsc10
650eA*
650eAC     endsc10       endsr
650eA*
650eA*  SC11 -  Screen 11
650eA*
650eAC     sc11          begsr
650eA*
650eA*
650eA*  Test for F12 - Previous
650eA*
650eAC                   if        *inkl
650eA*
650eA*    Remove any existing previously scanned in entries for this user.
650eA*
650eAC                   exsr      scr03i
650eAC                   goto      endsc11
650eAC                   endif
650eA*
650eA*  Test for other command keys BEFORE verification and update.
650eA*
650eAC                   move      '*BEFORE '    cmdchk
650eAC                   exsr      zzcmd11
650eAC     cmdtkn        cabeq     *on           endsc11
650eA*
650eA*  Some other key pressed.
650eA*
650eA*     Check input and write/update record.
650eA*
650eAC                   exsr      zzchk11
650eAC     error         cabeq     *on           endsc11
650eAC                   exsr      zzupd11
650eAC     error         cabeq     *on           endsc11
650eA*
650eA*  Test for other command keys AFTER verification and update.
650eA*
650eAC                   move      '*AFTER  '    cmdchk
650eAC                   exsr      zzcmd11
650eAC     cmdtkn        cabeq     *on           endsc11
650eA*
650eAC     endsc11       endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
501tm*  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
501fA*
501fA* Get client id.
501fA*
501fAC                   call      @getcl
501fAC                   parm                    client           10
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   z-add     01122         rollup
     C                   z-add     01123         rolldn
     C                   z-add     01124         clear
     C                   z-add     01125         help
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
610bAC                   select
610bAC                   when      #lline = '16'
610bAC                   write     m16ctl
610bAC                   other
     C                   write     msgctl
610bAC                   endsl
     C                   eval      msgk = *zeros
610bAC                   select
610bAC                   when      #lline = '16'
610bAC                   write     m16clr
610bAC                   other
     C                   write     msgclr
610bAC                   endsl
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
610bAC                   select
610bAC                   when      #lline = '16'
610bAC                   write     m16ctl
610bAC                   other
     C                   write     msgctl
610bAC                   endsl
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
501uAC                   select
501uAC                   when      e$lng  = 'SP'
501uAC                   eval      $msgf  = #msgsp
501uAC                   other
     C                   eval      $msgf = #msgf
501uAC                   endsl
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
610bAC                   select
610bAC                   when      #lline = '16'
610bAC                   write     m16rec
610bAC                   other
     C                   write     msgrec
610bAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *----------------------------------------------------------------
     *    ZMPCPF  Add CPF message record to subfile
     *
     C     zmpcpf        begsr
     C                   if        $msgf = *blanks
     C                   move      #msgfc        $msgf
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
750aAC                   select
750aAC                   when      #lline = '16'
750aAC                   write     m16rec
750aAC                   other
     C                   write     msgrec
750aAC                   endsl
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
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
610bAC                   select
610bAC                   when      #lline = '16'
610bAC                   write     m16rec
610bAC                   other
     C                   write     msgrec
610bAC                   endsl
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------

500hA*----------------------------------------------------------------
500hA*    DRI0001  Local system caused error
500hA*----------------------------------------------------------------
500hA
500hAC     zm0001        begsr
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
417jA*----------------------------------------------------------------
417jA*    PIR4002  Product expired.
417jA*
417jAC     zm4002        begsr
417jAC                   move      'PIR4002'     #msgid
417jAC                   move      '*DIAG  '     #msgtp
417jAC                   movea     errmsg        $md
417jAC                   exsr      zmpmsg
417jAC                   endsr
     *----------------------------------------------------------------
     *     PIR7979  Record does not exist.
     *
     C     zm7979        begsr
     C                   move      'PIR7979'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   LP11022  Invalid license number.
     *
     C     zm1022        begsr
     C                   move      'LP11022'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20001  Invalid slot entered.(TO)
     *
     C     zm2001        begsr
     C                   move      'RC20001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   RC20002 Transaction is closed.
     *
     C     zm2002        begsr
     C                   move      'RC20002'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
409 A*----------------------------------------------------------------
409 A*   RC20003 Quantity must be > 0.
409 A*
409 AC     zm2003        begsr
409 AC                   move      'RC20003'     #msgid
409 AC                   move      '*DIAG  '     #msgtp
409 AC                   movea     errmsg        $md(1)
409 AC                   exsr      zmpmsg
409 AC                   endsr
409 A*----------------------------------------------------------------
409 A*   RC20004 Quantity can't be > quantity to put away.
409 A*
409 AC     zm2004        begsr
409 AC                   move      'RC20004'     #msgid
409 AC                   move      '*DIAG  '     #msgtp
409 AC                   movea     errmsg        $md(1)
409 AC                   exsr      zmpmsg
409 AC                   endsr
414aA*----------------------------------------------------------------
414aA*   RC20005 Can't put in pick slot, overflow exists.
414aA*
414aAC     zm2005        begsr
414aAC                   move      'RC20005'     #msgid
414aAC                   move      '*DIAG  '     #msgtp
414aAC                   movea     errmsg        $md(1)
414aAC                   exsr      zmpmsg
414aAC                   endsr
414bA*----------------------------------------------------------------
414bA*   RC20006 For hard designation code, slot desig. doesn't match.
414bA*
414bAC     zm2006        begsr
414bAC                   move      'RC20006'     #msgid
414bAC                   move      '*DIAG  '     #msgtp
414bAC                   movea     errmsg        $md(1)
414bAC                   exsr      zmpmsg
414bAC                   endsr
415iA*----------------------------------------------------------------
415iA*   RC20007 Can't put in inactive slot.
415iA*
415iAC     zm2007        begsr
415iAC                   move      'RC20007'     #msgid
415iAC                   move      '*DIAG  '     #msgtp
415iAC                   movea     errmsg        $md(1)
415iAC                   exsr      zmpmsg
415iAC                   endsr
416DA*----------------------------------------------------------------
416dA*   RC20008 License/Label already scanned in.
416dA*
416dAC     zm2008        begsr
416dAC                   move      'RC20008'     #msgid
416dAC                   move      '*DIAG  '     #msgtp
416dAC                   movea     errmsg        $md(1)
416dAC                   exsr      zmpmsg
416dAC                   endsr
417iA*----------------------------------------------------------------
417iA*   RC20009 Must stage total remaining quantity.
417i *
417iAC     zm2009        begsr
417i C                   move      'RC20009'     #msgid
417i C                   move      '*DIAG  '     #msgtp
417i C                   eval      errqty = w3rqty
417i C                   movea     errmsg        $md(1)
417i C                   exsr      zmpmsg
417iAC                   endsr
500dA*----------------------------------------------------------------
500dA*   RC20017 Can't scan virtual slot.
500dA*
500dAC     zm2017        begsr
500dAC                   move      'RC20017'     #msgid
500dAC                   move      '*DIAG  '     #msgtp
500dAC                   movea     errmsg        $md(1)
500dAC                   exsr      zmpmsg
500dAC                   endsr
501nA*----------------------------------------------------------------
501nA*   RC20020 Slot not in &1 section.
501nA*
501nAC     zm2020        begsr
501nAC                   move      'RC20020'     #msgid
501nAC                   move      '*DIAG  '     #msgtp
501nAC                   movea     errmsg        $md(1)
501nAC                   exsr      zmpmsg
501nAC                   endsr
501rA*----------------------------------------------------------------
501rA*   RC20021 Deleted License, contact receiving clerk.
501rA*
501rAC     zm2021        begsr
501rAC                   move      'RC20021'     #msgid
501rAC                   move      '*DIAG  '     #msgtp
501rAC                   movea     errmsg        $md(1)
501rAC                   exsr      zmpmsg
501rAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20022 License not found in LICACTIVE file.
600cA*
600cAC     zm2022        begsr
600cAC                   move      'RC20022'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20023 License not found in LICINFO file.
600cA*
600cAC     zm2023        begsr
600cAC                   move      'RC20023'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20024 License not in RCV/STG/OSS location.
600cA*
600cAC     zm2024        begsr
600cAC                   move      'RC20024'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20025 License slot not found
600cA*
600cAC     zm2025        begsr
600cAC                   move      'RC20025'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20026 License slot not active
600cA*
600cAC     zm2026        begsr
600cAC                   move      'RC20026'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20027 Wrong item found in license slot
600cA*
600cAC     zm2027        begsr
600cAC                   move      'RC20027'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20028 License transaction not found
600cA*
600cAC     zm2028        begsr
600cAC                   move      'RC20028'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
600cA*----------------------------------------------------------------
600cA*   RC20029 License transaction not a putaway transaction
600cA*
600cAC     zm2029        begsr
600cAC                   move      'RC20029'     #msgid
600cAC                   move      '*DIAG  '     #msgtp
600cAC                   movea     errmsg        $md(1)
600cAC                   exsr      zmpmsg
600cAC                   endsr
700dA*----------------------------------------------------------------
700dA*   RC20030 License successfully putaway to slot.
700dA*
700dAC     zm2030        begsr
700dAC                   move      'RC20030'     #msgid
700dAC                   move      '*DIAG  '     #msgtp
700dAC                   movea     errmsg        $md(1)
700dAC                   exsr      zmpmsg
700dAC                   endsr
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   move      'PIR0105'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
530bA*----------------------------------------------------------------
530bA*      0110  Number must be > 0
530bA*
530bAC     zm0110        begsr
530bAC                   move      'PIR0110'     #msgid
530bAC                   move      '*DIAG  '     #msgtp
530bAC                   movea     errmsg        $md(1)
530bAC                   exsr      zmpmsg
530bAC                   endsr
650eA*----------------------------------------------------------------
650eA*      0122  invalide aisle
650eA*
650eAC     zm0122        begsr
650eAC                   move      'PIR0122'     #msgid
650eAC                   move      '*DIAG  '     #msgtp
650eAC                   movea     errmsg        $md(1)
650eAC                   exsr      zmpmsg
650eAC                   endsr
     *----------------------------------------------------------------
221 A*   PIR0204  Enter only one value.
221 A*
221 AC     zm0204        begsr
221 AC                   move      'PIR0204'     #msgid
221 AC                   move      '*DIAG  '     #msgtp
221 AC                   eval      $md = *blanks
221 AC                   exsr      zmpmsg
221 AC                   endsr
221 A*----------------------------------------------------------------
221 A*   PIR0205  Must enter one value.
221 A*
221 AC     zm0205        begsr
221 AC                   move      'PIR0205'     #msgid
221 AC                   move      '*DIAG  '     #msgtp
221 AC                   eval      $md = *blanks
221 AC                   exsr      zmpmsg
221 AC                   endsr
     *----------------------------------------------------------------
     *    PIR1001  Invalid option entered.
     *
     C     zm1001        begsr
     C                   move      'PIR1001'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR1005  Value must be 'Y' or 'N'
     *
     C     zm1005        begsr
     C                   move      'PIR1005'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
SGCaA*----------------------------------------------------------------
SGCaA*     IT15203  To slot contains a different item.
SGCaA*
SGCaAC     zm1523        begsr
SGCaAC                   move      'IT15203'     #msgid
SGCaAC                   move      '*DIAG  '     #msgtp
SGCaAC                   eval      $md = *blanks
SGCaAC                   exsr      zmpmsg
SGCaAC                   endsr
     *----------------------------------------------------------------
412fA*     IT15204  Virtual slot could not be created.
     *
     C     zm1524        begsr
     C                   move      'IT15204'     #msgid
     C                   move      '*DIAG  '     #msgtp
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
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
415hA*     IT25206  # of pick slots exceeds # allowed.
415hA*
415hAC     zm5206        begsr
415hAC                   move      'IT25206'     #msgid
415hAC                   move      '*DIAG  '     #msgtp
415hAC                   eval      ernpck = nbrpck
415hAC                   eval      erapck = imnrpk
415hAC                   movea     errmsg        $md(1)
415hAC                   exsr      zmpmsg
415hAC                   endsr
     *----------------------------------------------------------------
417iA*   CPF9898  Generic error message
417i *
417i C     zm9898        begsr
417i C                   move      'CPF9898'     #msgid
417i C                   move      '*DIAG  '     #msgtp
417i C                   movea     errmsg        $md
417i C                   exsr      zmpcpf
417iAC                   endsr
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
     *
     *  ZZABRT   Abort a transaction
     *
     C     zzabrt        begsr
600cMC                   eval      @ptask = $pttask
     C                   eval      @pcube = lbcube
     C                   eval      @pswgt = lbswgt
417hAC                   eval      @pcmd2 = '*UNDO'
417hMC                   call      @adjt2
417hMC                   parm                    @pcmd2           10
     C                   parm                    #job
417hAC                   parm      '*INTER  '    @ptype            8
600cMC                   parm      $pttrn#       @ptrn#            7 0
     C                   parm                    @ptask            6
     C                   parm      w1whse        @pwhse            3 0
     C                   parm      lbwhdp        @pwhdp            5
     C                   parm      lbstyp        @pstyp            1
     C                   parm                    @pcube            9 3
     C                   parm                    @pswgt            9 2
     C                   parm      lbqpck        @ppcs             5 0
     C                   parm      0             @paisl            5 0
     C                   parm      0             @pqty1            5 0
     C                   parm      0             @pqty2            5 0
     C                   parm      0             @pqty3            5 0
     C                   parm      '0'           @prte             5
     C                   parm      ' '           @ppo              9
410 AC                   parm      'P'           @pgrp1            1
     C                   parm      ' '           @pgrp2            1
417hAC                   parm      0             @pdate            8 0
417hAC                   parm      0             @ptime            6 0
600dMC                   parm      #curruser     @puser           10
     C                   parm      ' '           @prtn             8
     C                   parm      ' '           @pmsg             4
     *
417hA*    Use Transaction start time as start time for IDLE task.
     *
417hAC                   eval      trndte = @pdate
417hAC                   eval      trntim = @ptime
417hAC                   move      '*YES'        usestr
     *
410 A*    Start an 'IDLE' task.
     *
410 AC                   exsr      zzidle
417hAC                   move      '*NO '        usestr
417hA*
     C     endabr        endsr
     *----------------------------------------------------------------
417i *
417i *  ZZABT2   Abort a transaction BEFORE staging started.
417i *
417i C     zzabt2        begsr
417i *
417i *   Delete transaction
417i *
417iAC                   eval      @pcmd2 = '*ABORT'
417iMC                   call      @adjt2
417iMC                   parm                    @pcmd2
417i C                   parm                    #job
417i C                   parm      '*INTER  '    @ptype
417i C                   parm      pntrn#        @ptrn#
417i C                   parm                    @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      ' '           @pwhdp
417i C                   parm      ' '           @pstyp
417i C                   parm      0             @pcube
417i C                   parm      0             @pswgt
417i C                   parm      0             @ppcs
417i C                   parm      0             @paisl
417i C                   parm      0             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      '0'           @prte
417i C                   parm      ' '           @ppo
417i C                   parm      ' '           @pgrp1
417i C                   parm      ' '           @pgrp2
417i C                   parm      0             @pdate
417i C                   parm      0             @ptime
600dMC                   parm      #curruser     @puser
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
     *
417i *    Use Transaction start time as start time for IDLE task.
     *
417i C                   eval      trndte = @pdate
417i C                   eval      trntim = @ptime
417i C                   move      '*YES'        usestr
417i *
417i *    Start an 'IDLE' task.
417i *
417i C                   exsr      zzidle
417i C                   move      '*NO '        usestr
417i *
417i C     endab2        endsr
417i *----------------------------------------------------------------
417i *
417i *  ZZABT3   Abort a transaction AFTER staging started
417i *
417i C     zzabt3        begsr
417i *
417i *   Delete existing work records and remove amts from tran rec.
417i *
417i C                   eval      @ppcs = 0
417i C                   eval      @pcube = 0
417i C                   eval      @pswgt = 0
417i C                   eval      @pqty1 = 0
417i *
417i *      Add amounts to totals
417i *
600cMC                   add       $ptpcs        @ppcs
600cMC                   add       $ptcube       @pcube
600cMC                   add       $ptswgt       @pswgt
417i C                   add       1             @pqty1
417i *
417i *
417i *   Reduce task and transaction totals.
417i *
417i C                   call      @adjtr
417i C                   parm      '*DECTTL '    @pcmd             8
417i C                   parm                    #job
417i C                   parm      pntrn#        @ptrn#
417i C                   parm      ' '           @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      ' '           @pwhdp
417i C                   parm      ' '           @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417i C                   parm                    @ppcs
417i C                   parm      0             @paisl
417i C                   parm                    @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      '0'           @prte
417i C                   parm      ' '           @ppo
417i C                   parm      ' '           @pgrp1
417i C                   parm      ' '           @pgrp2
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
417i *
417i *   Close transaction.
417i *
417i C                   call      @adjtr
417i C                   parm      '*CLOSE  '    @pcmd
417i C                   parm                    #job
417i C                   parm      pntrn#        @ptrn#
417i C                   parm      ' '           @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      ' '           @pwhdp
417i C                   parm      ' '           @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417i C                   parm                    @ppcs
417i C                   parm      0             @paisl
417i C                   parm      0             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      '0'           @prte
417i C                   parm      ' '           @ppo
417i C                   parm      ' '           @pgrp1
417i C                   parm      ' '           @pgrp2
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
417i *
417i *   Start an 'IDLE' task.
417i *
417i C                   move      '*NO '        usestr
417i C                   exsr      zzidle
417i *
417i C     endab3        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  ZZAPT    Call APT Interface
PFCaA*
PFCaAc     zzapt         begsr
PFCaA
PFCbAc                   eval      apcmd = '*PUTAWYBEG'
PFCbAc                   eval      apseq# = apseq# + 1
PFCbAc                   eval      aptype = wotype
PFCbAc                   eval      aploc  = wofrom
PFCbA
PFCbAc*    Create APT output record.
PFCbA
PFCbAc                   call      'APTMAIN'
PFCbAc                   parm                    apcmd            10
PFCbAc                   parm      #prog         appgm            10
PFCbAc                   parm      lbwhse        apwhse            3 0
PFCbAc                   parm      lblbl#        aplbl#            7 0
PFCbAc                   parm                    aptrn#            7 0
PFCbAc                   parm      #user         apuser           10
PFCbAc                   parm      w1emp#        apemp#            5 0
PFCbAc                   parm      *blanks       aprtid            5
PFCbAc                   parm      *blanks       aprte             5
PFCbAc                   parm                    aploc            20
PFCbAc                   parm                    apseq#            5 0
PFCbAc                   parm                    aprtn            10
PFCbAc                   parm                    apmsg            60
PFCbA
PFCbDc**                 eval      apcmd = '*JOB0100  '
PFCbMc                   eval      apcmd = '*PUTAWYPLC'
PFCaAc                   eval      apseq# = apseq# + 1
PFCaAc                   eval      aptype = wotype
PFCaAc                   eval      aploc  = wofrom
PFCaA
PFCaAc*    Create APT output record.
PFCaA
PFCaAc                   call      'APTMAIN'
PFCaAc                   parm                    apcmd            10
PFCaAc                   parm      #prog         appgm            10
PFCaAc                   parm      lbwhse        apwhse            3 0
PFCaAc                   parm      lblbl#        aplbl#            7 0
PFCaAc                   parm                    aptrn#            7 0
PFCaAc                   parm      #user         apuser           10
PFCaAc                   parm      w1emp#        apemp#            5 0
PFCaAc                   parm      *blanks       aprtid            5
PFCaAc                   parm      *blanks       aprte             5
PFCaAc                   parm                    aploc            20
PFCaAc                   parm                    apseq#            5 0
PFCaAc                   parm                    aprtn            10
PFCaAc                   parm                    apmsg            60
PFCaA
PFCaAc                   endsr
750bA*----------------------------------------------------------------
750bA*
750bA*  ZZGETRTNPLT Get licenses attached to return pallet
750bA*
750bAC     zzgetrtnplt   begsr
750bA /free
750bA   reade(n) (w1whse: holdrtnplt) pltlcns;
750bA /end-free
750bAc
750bAC                   endsr
     *----------------------------------------------------------------
417i *
417i *  ZZCLSE   Close a transaction (Stage, no label records)
     *
417i C     zzclse        begsr
     *
417iA*    Close any open(Inuse) Indirect tasks.
     *
417iAC                   exsr      zzendi
PFCbA
PFCbAc                   if        logapt
PFCbAc*    Send APT Transaction.
PFCbAc                   eval      aptrn# = @ptrn#
PFCbAc                   exsr      zzapt
PFCbAc                   endif
417iA*
417i *   Close transaction.
417i *
417i *    Note: We can use the ADJTRAN program instead of PT132
417i *          because there are no label records associted
417i *          with a staging transaction.
417i *
417i C                   call      @adjt2
417i C                   parm      '*CLOSE  '    @pcmd2
417i C                   parm                    #job
417i C                   parm      '*INTER  '    @ptype
417i C                   parm      pntrn#        @ptrn#
417i C                   parm      ' '           @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      ' '           @pwhdp
417i C                   parm      ' '           @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417i C                   parm                    @ppcs
417i C                   parm      0             @paisl
417i C                   parm      0             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      '0'           @prte
417i C                   parm      ' '           @ppo
417i C                   parm      ' '           @pgrp1
417i C                   parm      ' '           @pgrp2
417i C                   parm      0             @pdate
417i C                   parm      0             @ptime
600dMC                   parm      #curruser     @puser
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
PFCaAc                   if        logapt
PFCaAc*    Send APT Transaction.
PFCaAc                   eval      aptrn# = lbtrn#
PFCaAc                   exsr      zzapt
PFCaAc                   endif
417i *
417i *   Start an 'IDLE' task, if no open task.
417i *
417i C                   move      '*NO '        usestr
417i C                   exsr      zzidle
417i *
417i C     endcls        endsr
     *----------------------------------------------------------------
     *
417iA*  This is ZZCLSE renamed so the new ZZCLSE can be used.
417i *  ZZCLSP   Close a transaction (Putaway has labels)
     *
417iMC     zzclsp        begsr
     *
     *    Close any open(Inuse) Indirect tasks.
     *
     C                   exsr      zzendi
     *
600dDC**                 eval      $lcmd = '*CLOSE  '
600dDC**                 eval      $ltype = '*INTER  '
600dDC**                 eval      $lwhse = 0
600dDC**                 eval      $lrte = *blanks
600dDC**                 eval      $lpo = *blanks
600dDC**                 eval      $ltrn# = $pttrn#
600dDC**
600dDC**                 call      'PT132'
600dDC**                 parm                    $lparm
600dD**
600dD**   Calculate the time in minutes it took to complete this task.
600dD**   PTCTIM is used for end time instead of PTETIM, because close
600dD**   time and End time are the same in this case.
600dD**
600dD**    ptkey         chain     pirtran                            79
600dD**                  eval      strtim = ptstim
600dD**                  eval      fintim = ptctim
600dD**                  exsr      zztime
600dD**                  eval      ptdmin = timlen
600dD**                  update    ptrec
600dD**
600dD**        There is a posibility that a manual task might have
600dD**        been added before the current task was ended. Hence
600dD**        adjust the current task just ended, if there is
600dD**        any overlapping manual task.
600dD**
600dD**                  z-add     pttrn#        svtrn#
600dD**
600dD**  Past overnight. (PTEDTE > PTSDTE)
600dD**
600dD**                  if        ptedte > ptsdte
600dD**                  z-add     ptedte        stdate
600dD**                  else
600dD**                  z-add     ptsdte        stdate
600dD**                  endif
600dD**                  z-add     ptsdte        zzsdte
600dD**                  z-add     ptedte        zzedte
600dD**                  z-add     ptstim        zzstim
600dD**                  z-add     ptetim        zzetim
600dD**                  exsr      zzcku2
600dA*
600dA*   Close transaction
600dA*
600dAC                   call      @adjt2
600dAC                   parm      '*CLOSE  '    @pcmd2
600dAC                   parm                    #job
600dAC                   parm      '*INTER  '    @ptype
600dAC                   parm      $pttrn#       @ptrn#
600dAC                   parm      ' '           @ptask
600dAC                   parm      w1whse        @pwhse
600dAC                   parm      ' '           @pwhdp
600dAC                   parm      ' '           @pstyp
600dAC                   parm                    @pcube
600dAC                   parm                    @pswgt
600dAC                   parm                    @ppcs
600dAC                   parm      0             @paisl
600dAC                   parm      0             @pqty1
600dAC                   parm      0             @pqty2
600dAC                   parm      0             @pqty3
600dAC                   parm      '0'           @prte
600dAC                   parm      ' '           @ppo
600dAC                   parm      ' '           @pgrp1
600dAC                   parm      ' '           @pgrp2
600dAC                   parm      0             @pdate
600dAC                   parm      0             @ptime
600dAC                   parm      #curruser     @puser
600dAC                   parm      ' '           @prtn
600dAC                   parm      ' '           @pmsg
     *
PFCaAc                   if        logapt
PFCaAc*    Send APT Transaction.
PFCaAc                   eval      aptrn# = lbtrn#
PFCaAc                   exsr      zzapt
PFCaAc                   endif
     *
410 A*   Start an 'IDLE' task, if no open task.
417iA*     Do not start idle if closing put away to partial stage.
     *
417nMC                   if        w3rqty = 0
410 AC                   eval      curtrn = 0
410 AC                   eval      curtsk = *zeros
410 AC                   eval      curtyp = *zeros
410 AC                   move      *off          curent
410 AC                   exsr      zztask
410 AC                   if        curent = *off
410 AC                   move      'IDLE  '      w1task
417hAC                   move      '*NO '        usestr
410 AC                   exsr      zzidle
410 AC                   endif
417iAC                   endif
     *
417i C     endclp        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     *
511e *   DTCHK, Flags are used to force F20 for each test
511e *   Values: Flag = 0 Do check.
511e *           Flag = 1 Check was done, ok.
511e *           Flag = 2 Warning condition.
     *
     C                   move      *off          error
530bD ***                eval      repack = no
     *
     *   Verify warehouse and get description.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   move      *on           error
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
750bA /free
750bA   if %subst(w1lcns:1:6) = 'RTNPLT' and oppltl = 'Y';
750bA     // go get data from PLTLCNS
750bA     holdrtnplt = w1lcns;
750bA     setll (w1whse: holdrtnplt) pltlcns;
750bA     dow forever = forever;
750bA       exsr zzgetrtnplt;
750bA       if %eof(pltlcns);
750bA         error = *on;
750bA         *in22 = *on;
750bA         *in02 = *on;
750bA         errmsg = 'Nothing to putaway for the pallet license';
750bA         exsr zm0105;
750bA         leavesr;
750bA       endif;
750bA       if rnlput = 'Y';
750bA         iter;
750bA       endif;
750bA       // load up first license
750bA       if rnltype = 'L';
750bA         w1lcns = rnllcns;
750bA         w1lbl#b = ' ';
750bA       else;
750bA         w1lbl#b= rnlplbl;
750bA         w1lcns = ' ';
750bA       endif;
750cA       exsr zzvfylcnsRP;
750cA       if error;
750cA         error = *off;
750cA         w1lcns = ' ';
750cA         iter;
750cA       else;
750bA         leave;
750cA       endif;
750bA     enddo;
750bA
750bA   endif;
750bA /end-free
650jA*
650jA*  Validate scanned license for invalid characters. If found, replace with
650jAC                   eval      wklicense = w1lcns
650jAC                   exsr      zzcklicense
650jAC                   eval      w1lcns = %subst(wklicense:1:15)
     *
415cM*  Enter only one, license, trans # or label #.
221 A*
416fMC                   if        w1lcns <> *blanks  and
600cDC**                           w1trn# <> 0  and
530bD ***                          w1lbl# <> 0
530bMC                             w1lbl#B <> *blanks
221 AC                   move      *on           error
221 AC                   eval      *in22 = *on
221 AC                   eval      *in02 = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   exsr      zm0204
221 AC                   endif
     *
415cM*  Must enter one, license, transaction or label number.
221 A*
416fMC                   if        w1lcns = *blanks  and
600cDC**                           w1trn# = 0  and
530bMC                             w1lbl#b = *blanks
530bD ***                          w1lbl# = 0
221 AC                   eval      error = *on
221 AC                   eval      *in22 = *on
221 AC                   eval      *in02 = *on
221 AC                   eval      *in23 = *on
221 AC                   eval      *in03 = *on
221 AC                   exsr      zm0205
221 AC                   endif
530bD
530bD*    Set repack flag.
530bD
530bD**                  if        $ptgrp1 = 'K'
530bD**                  eval      repack = yes
530bD**                  else
530bD**                  eval      repack = no
530bD**                  endif


600dDC**
600dDC** Left justify license.
600dDC**
600dDC**                 eval      $cstr = *blanks
600dDC**                 move      w1lcns        $cstr
600dDC**                 call      'ADJUST'
600dDC**                 parm      '*LEFTNOZ'    $ccmd             8
600dDC**                 parm                    $cstr            30
600dDC**                 movel     $cstr         w1lcns
600dDC**
600dDC** Verify license plate number.
600dDC**
600dDC**                 if        w1lcns <> *blanks  and
600dDC**                           w1trn# = 0
600dDC**                 move      *off          goodli
600dDC**   likey         setll     license
600dDC**   nxtli         tag
600dDC**   likey         reade(n)  license                                78
600dDC**                 if        not *in78
600dDC**   litrn#        chain(n)  pirtran                            79
600dDC**                 if        not *in79
600dDC**                 if        $pttask <> 'PUTEMP'  and
600dDC**                           $pttask <> 'PUTRTN'
600dDC**                 goto      nxtli
600dDC**                 else
600dDC**                 move      *on           goodli
600dDC**
600dDC** See if this is a repack putaway.
600dDC**
600dDC**                 if        $ptgrp1 = 'K'
600dDC**                 eval      repack = yes
600dDC**                 endif
600dDC**
600dDC**                 endif
600dDC**                 else
600dDC**                 goto      nxtli
600dDC**                 endif
600dDC**                 endif
600dDC**
600dDC**                 if        goodli = *off
600dDC**                 move      *on           error
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 exsr      zm1022
600dDC**                 goto      endck1
600dDC**                 endif
600dDC**                 endif
600dDC**
600dDC** Check to see if license is deleted and display error if it is.
600dDC**
600dDC**                 if        goodli = *on
600dDC**   litrn#        setgt     porcv1
600dDC**   litrn#        readpe    porcv1                                 79
600dDC**                 if        not *in79
600dDC**                 if        poract <> 'D'
600dDC**                 else
600dDC**                 eval      goodli = *off
600dDC**                 eval      error = *on
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 exsr      zm2021
600dDC**                 goto      endck1
600dDC**                 endif
600dDC**                 endif
600dDC**                 endif
600cD **
600cD ** Verify transaction number.
600cD **
600cDC**                 if        w1trn# <> 0  and
600cDC**                           w1lcns = *blanks
600cDC**                 eval      $lcmd = '*VERIFY '
600cDC**                 eval      $ltrn1 = w1trn#
600cDC**                 call      'PT900'
600cDC**                 parm                    $lparm
600cDC**                 if        $lrtn = '*PGMQ   '
600cDC**                 move      *on           error
600cDC**                 eval      *in23 = *on
600cDC**                 eval      *in03 = *on
600cDC**                 eval      #msgk = $lmsg
600cDC**                 exsr      zmqmsg
600cDC**                 endif
600cDC**                 endif
415cA*
415cA*  Verify label number.
416dA*    Note: Label number can only be used when doing putaways
416dA*          for customer returns.
415cA*
415cAC                   eval      wolbl# = 0
600dDC**                 eval      wotrn# = 0
530bD ***                if        w1lbl# <> 0
530bMC                   if        w1lbl#b <> *blanks
     * grab label#
530bAC                   move      w1whse        $pwhseb
530bAC                   movel     w1lbl#b       $pbarcode
530bAC                   call      @cvtbarsel
530bAC                   parm                    $pwhseb           3
530bAC                   parm                    $pbarcode        15
530bAC                   parm                    $plbl#            7 0
530bAC                   parm                    $prtid            5
530bAC                   parm                    $punq#            5
530bAC                   parm                    $preturn          8
530bAC                   parm                    $perrmsg         60
530bAC                   if        $preturn = '*OK'
530bAC                   eval      w1lbl# = $plbl#
530bAC                   move      *blanks       w1lbl#b
530bAC                   move      $plbl#        w1lbl#b
530bAC                   else
530bAC                   eval      error = *on
530bAC                   eval      *in22 = *on

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(5)
720cAC                   other
530bAC                   eval      errmsg = desc(5)
720cAC                   endsl

530bAC                   exsr      zm0110
530bAC                   endif
415cAC                   z-add     w1lbl#        wolbl#
415cAC                   eval      lbcnt = 0
415cAC     llkey1        setll     labelnk1
415cAC     nxtlb         tag
415cAC     llkey1        reade     labelnk1                               78
415cAC                   if        not *in78
415cA*
     C                   if        ptstat <> '1'
415cAC                   goto      nxtlb
415cAC                   else
415cAC                   add       1             lbcnt
415cAC                   z-add     lltrn#        lktrn#
415cAC                   endif
415cA*
415cAC                   if        lbcnt > 1
415cAC                   eval      $lcmd = '*LOOKUP '
415cAC                   eval      $llwhs = w1whse
415cAC                   eval      $llblo = lllblo
 15cAC                   eval      $ltrn2 = 0
415cAC                   call      'LL145'
415cAC                   parm                    $lparm
415cAC                   parm                    $llwhs
415cAC                   if        $lrtn = '*ERROR  '
415cAC                   move      *on           error
415cAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
415cAC                   eval      errmsg = desc(2)
501uAC                   endsl
415cAC                   eval      *in24 = *on
415cAC                   eval      *in04 = *on
415cAC                   exsr      zm1001
600fAC                   leavesr
415cAC                   else
415cA*
415cAC                   if        $lrtn = '*PGMQ   '
415cAC                   eval      error = *on
415cAC                   eval      *in21 = *on
415cAC                   eval      *in01 = *on
415cAC                   eval      #msgk = $lmsg
415cAC                   exsr      zmqmsg
600fAC                   leavesr
415cAC                   else
415cAC                   z-add     $ltrn2        lktrn#
415cAC                   endif
415cAC                   endif
415cAC                   else
415cAC                   goto      nxtlb
415cAC                   endif
415cAC                   endif
415cA*
415cAC                   if        $lrtn = '*CANCEL'  or
415cAC                             $lrtn = '*ERROR '  or
415cAC                             $lrtn = '*PGMQ  '
415cAC                   move      *on           error
600fAC                   leavesr
415cAC                   endif
415cA*
415cAC                   if        lbcnt = 0
415cAC                   move      *on           error
415cAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
415cAC                   eval      errmsg = desc(2)
501uAC                   endsl
415cAC                   eval      *in24 = *on
415cAC                   eval      *in04 = *on
415cAC                   exsr      zm1001
600fAC                   leavesr
415cAC                   endif
600fA
600fA*    Create license used for label#.
600fA
600fAC                   eval      w1lcns = '*RT'
600fAC                                    + %trim(%editc(lktrn#:'X'))
600fA
415cAC                   endif
600dDC**
600dDC** Make sure that the transaction is open.
600dDC**
600dDC**                 if        wotrn# = 0
600dDC**                 select
600cDC**                 when      w1trn# <> 0
600cDC**                 z-add     w1trn#        wotrn#
600dDC**                 when      w1lbl# <> 0
600dDC**                 eval      wotrn# = lktrn#
600dDC**                 other
600dDC**                 z-add     litrn#        wotrn#
600dDC**                 endsl
600dDC**                 endif
600cDC**   ptkey         chain(n)  pirtran                            79
600cDC**                 if        not *in79  and
600dDC**                           ptstat <> '1'
600dDC**                 eval      error = *on
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 eval      ertrn# = wotrn#
600dDC**                 exsr      zm2002
600dDC**                 endif
600fA
600fA*    Verify license
600fA
600fAC                   exsr      zzvfylcns
600fAC                   if        error
600fAC                   leavesr
600fAC                   endif
600dA
600dA*    Set wotrn# field.
600dA
600dAC                   eval      wotrn# = $pttrn#
     *
     * Check if product is expired.
     *
511eAC                   if        w1lbl# <> wklbl# or
511eAC                             w1lcns <> wklcns
511eAC                   eval      dtchk = *off
511eAC                   endif
417jAC                   move      w1lbl#        wklbl#
417jAC                   move      w1lcns        wklcns
511e *
511eAC                   if        dtchk = '2'  and
511eAC                             ovrrid = *on
511eAC                   eval      dtchk = *on
511eAC                   endif
511e *
511eAC                   if        dtchk <> '1'
511eAC                   eval      dtchk = *on
417jAC                   exsr      zzckdt
511eAC                   endif
650fA*
650fA*  If putaway represents a Repack Item verify on-demand slot
650fA*  exists
650fA*
650fA /free
650fA    if $litoiType = 'R';
650fA       chain (w1whse:$litoitem) kititem;
650fA       if not %error and %found;
650fA          if kidisp <> ' ';
650fA             exsr clr$slot;
650fA             $slwhseu = *on;
650fA             $slwhse  = w1whse;
650fA             $slwhdpu = *on;
650fA             $slwhdp  = $litoWhdp;
650fA             $slitemu = *on;
650fA             $slitem  = $litoitem;
650fA             $sldispu = *on;
650fA             $sldisp  = kidisp;
650fA
650fA             $dricommand = '*SLOT';
650fA             $drisubcmd  = '%CRTREPAKD';
650fA             $drisys2upd = 'D';
650fA             chk4err = *on;
650fA             exsr zzzdricop;
650fA             odrSlot = $sldisp;
650fA             #odrslavl1 = $slavl1;
650fA             error = *off;
650fA          endif;
650fA       endif;
650fA    endif;
650fA /end-free
     *
600bAC     endck1        tag
600bMC                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   move      *off          error
414 A*
414 A*  Call API for slot.
414 A*
414 AC                   call      @apics
414 AC                   parm                    w2scan
414 AC                   parm      6             worow
414 AC                   parm      7             wocol
414 AC                   parm                    @artn             8
414 AC                   if        @artn = '*REDSPLY'
414 AC                   move      *on           redspl
414 AC                   goto      endck2
414 AC                   endif
     *
     *  Verify display.(SCAN slot)
     *
     C                   if        w2scan <> w2tosl
     C                   move      *on           error
     C                   eval      *in25 = *on
     C                   eval      *in05 = *on
     C                   eval      errmsg = *blanks
     C                   movel     w2tosl        errmsg
     C                   exsr      zm2001
     C                   endif
     *
     C     endck2        endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  ZZCHK3   Screen 3 error checking.
409 A*
409 AC     zzchk3        begsr
     *
413c *   SLCHK, Flags are used to force F20 for each test
413c *   Values: Flag = 0 Do check.
413c *           Flag = 1 Check was done, ok.
413c *           Flag = 2 Warning condition.
413c *
409 AC                   move      *off          error
650kA * need to skip slot conversion if svdisp = w3scan and override is on
650kAc                   if        svdisp <> w3scan
650kAc                             or *inku = *off
414 A*
414 A*  Call API for slot.
414 A*
414 AC                   call      @apics
414 AC                   parm                    w3scan
414 AC                   parm      6             worow
414 AC                   parm      7             wocol
414 AC                   parm                    @artn
414 AC                   if        @artn = '*REDSPLY'
414 AC                   move      *on           redspl
414 AC                   goto      endck3
414 AC                   endif
650kAC                   endif
     *
414 AC                   eval      #todisp = w3scan

740aA*  Call DRISLOT to get slot info.
740aA*  Need individual slot fields for for WWTFR check.
740aA
740aAC                   exsr      clr$slotw
740aAC                   eval      $slwhseu = *on
740aAC                   eval      $slwhse  = w1whse
740aAC                   eval      $slwhdpu = *on
740aAC                   eval      $slwhdp  = lbwhdp
740aAC                   eval      $sldispu = *on
740aAC                   eval      $sldisp  = w3scan
740aAC                   eval      $dricommand = '*SLOT'
740aAC                   eval      $drisubcmd  = '%GET'
740aAC                   eval      $drisys2upd = 'D'
740aAC                   eval      chk4err = *off
740aAC                   eval      zmsflag = *off
740aAC                   exsr      zzzdricop
740aA
740aA*  Do warehouse-to-warehouse (GLOWWTFR) checks.
740aA
740aA /free
740aA    //monitor;
740aA      wwwhse = w1whse;
740aA      WWTFR('*VFYTFRIN': $slaisl: $slloc: wwwhse: #user: wwrtn: wwmsg);
740aA      if wwrtn = '*ERROR';
740aA        errmsg = wwmsg;
740aA        error = *on;
740aA        ovrrid = *off;
740aA        *in26 = *on;
740aA        *in06 = *on;
740aA        exsr zm0105;
740aA        leavesr;
740aA      endif;
740aA    //on-error;
740aA    //endmon;
740aA /end-free
     *
640dA*  QUANTITY CAN'T BE NEGATIVE.
     *
640dAC                   if        w3qty < 0
640dAC                   eval      error = *on
640dAC                   eval      *in27 = *on
640dAC                   eval      *in07 = *on
640dAC                   exsr      zm2004
640dAC                   endif
409 A*  QUANTITY CAN'T BE > QUANTITY TO BE PUT AWAY.
     *
500mMC                   if        w3qty > w3rqty
500mMC                   eval      error = *on
500mMC                   eval      *in27 = *on
500mMC                   eval      *in07 = *on
500mMC                   exsr      zm2004
500mMC                   endif
500mMC     error         cabeq     *on           endck3
415jA*
415jA*    Have user verify slot.
415jA*
415jAC                   if        opvrfy = 'Y'
415jAC                   call      'RC200V'
415jAC                   parm                    w3scan
415jAC                   parm                    $vrfy             1
415jAC                   if        $vrfy <> 'Y'
415jAC                   eval      redspl = *on
415jAC                   goto      endck3
415jAC                   endif
415jAC                   endif
SGCaA*
SGCaA*  Verify 'To Slot' pick slot is empty or has the same item.
SGCaA*  Do not allow virtual pick slot to be created.
SGCaAC                   if        client = sgc
SGCaAC                   move      *off          goodsl
SGCaAC                   eval      svaisl = *blanks
SGCaAC     tokey         setll     slot2
SGCaAC                   dow       forever = forever
SGCaAC     tokey1        reade     slot2
SGCaAC                   if        svaisl = *blanks
SGCaAC                   eval      svaisl = s_slaisl
SGCaAC                   eval      svloc = s_slloc
SGCaAC                   eval      svrlvl = s_slrlvl
SGCaAC                   endif
SGCaAC                   if        %eof
SGCaAC                   leave
SGCaAC                   endif
SGCaA*  Test read is past scanned slot
SGCaAC                   if        s_slaisl <> svaisl
SGCaAC                             or s_slloc <> svloc
SGCaAC                             or s_slrlvl <> svrlvl
SGCaAC                   leave
SGCaAC                   endif
SGCbA*  Allow virtual pick slots for DR aisle level 2, 200 to 246
SGCbAC                   if        s_slaisl = ' DR'
SGCbAC                             and s_slrlvl = 2
SGCbAC                             and s_slloc >199
SGCbAC                             and s_slloc <247
SGCbAC                   eval      goodsl = *on
SGCbAC                   leave
SGCbAC                   endif
SGCcA*  Allow virtual pick slots CB aisle level 2-4, 216 to 226 even
SGCcAC                   if        s_slaisl = ' CB'
SGCcAC                             and s_slrlvl > 1
SGCcAC                             and s_slrlvl <51
SGCcAC                             and s_slloc >215
SGCcAC                             and s_slloc <227
SGCcAC                             and s_slside = 0
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   endif
SGCcA*  Allow virtual pick slots CN aisle 188 to 208 even
SGCcAC                   if        s_slaisl = ' CN'
SGCcAC                             and s_slloc >187
SGCcAC                             and s_slloc <209
SGCcAC                             and s_slside = 0
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   endif
SGCcA*  Allow virtual pick slots CE aisle
SGCcAC                   if        s_slaisl = ' CE'
SGCcAC                   eval      goodsl = *on
SGCcAC                   leave
SGCcAC                   endif
SGCcA*
SGCaAC                   select
SGCaAC                   when      s_slpick = 'N'
SGCaAC                   eval      goodsl = *on
SGCaAC                   leave
SGCaAC                   when      s_slitem = lbitem
SGCaAC                   eval      goodsl = *on
SGCaAC                   leave
SGCaAC                   when      s_slitem = *blanks
SGCaAC                   eval      goodsl = *on
SGCaAC                   leave
SGCaAC                   endsl
SGCaAC                   iter
SGCaAC                   enddo
SGCaAC                   if        goodsl = *off
SGCaAC                   eval      error = *on
SGCaAC                   eval      *in21 = *on
SGCaAC                   eval      *in01 = *on
SGCaAC                   exsr      zm1523
SGCaAC                   goto      endck3
SGCaAC                   endif
SGCaAC                   endif
700gA*
700gA*    When putting away product for *each pick slot
700gA*    Force the user to use the pick slot displayed
700gA*
700gAC                   if        FndEachPickSlt
700gAC                   if        w3scan <> w3tosl
700gAC                   eval      error = *on
700gAC                   eval      *in26 = *on
700gAC                   eval      *in06 = *on
700gAC                   eval      errmsg = *blanks
700gAC                   exsr      zm2001
700gAC                   goto      endck3
700gAC                   endif
700gAC                   endif
500hA
500hA*   Handle warnings.
500hA
500hAC                   if        svdisp <> w3scan
500hAC                   eval      $slpicke = '0'
500hAC                   endif
RylaAC                   if        client = royal
RylaAC                             and $slpicke = '3'
RylaAC                             and ovrrid = *on
RylaAC                   eval      $slpicke = '4'
RylaAC                   eval      slpicke = *on
RylaAC                   eval      warno = *on
RylaAC                   endif
500hAC                   if        $slpicke = '2' and ovrrid = *on
500hAC                   eval      $slpicke = '3'
500hAC                   endif
710hAC                   if        svdisp <> w3scan
710hAC                   eval      warnIS = '0'
710hAC                   eval      $sldispe = '0'
710hAC                   endif
710hAc                   Select
710hAc                   When      opiswn = 'Y'   and
710hAc                             $sldispe = '2' and
710hAc                             warnis = '1' and ovrrid  = '1'
710hAc                   eval      $sldispe = '3'
710hAc                   endsl
500hA*   Call DRI interface to do error checking.
500hA
500hAC                   exsr      clr$slotw
500hAC                   eval      $slwhseu = *on
500hAC                   eval      $slwhse  = w1whse
500hAC                   eval      $slwhdpu = *on
500hAC                   eval      $slwhdp  = lbwhdp
500hAC                   eval      $sldispu = *on
500hAC                   eval      $sldisp  = w3scan
640aAC                   eval      $slstatu = *on
640aAC                   eval      $slstat  = ' '
640aAC                   eval      $slpicku = *on
640aAC                   eval      $slpick  = ' '
700bAC                   eval      $slentdu = *on
700bAC                   eval      $slentd  = $LITOENTD
500hAC                   eval      $slexpdu = *on
500hAC                   eval      $slexpd  = svexpd
500hA
600cMC                   if        $pttask = 'PUTRTN'
500hAC                   eval      $slprtyu = *on
500hAC                   eval      $slprty  = -9
500hAC                   endif
500hA
500hAC                   eval      $saitemu = *on
500hAC                   eval      $saitem  = lbitem
500hAC                   eval      $saqtyu = *on
500hAC                   select
500hAC                   when      lbutyp = 'N'
500hAC                   eval      $saqty1 = w3qty
500hAC                   when      lbutyp = '1'
500hAC                   eval      $saqty2 = w3qty
500hAC                   when      lbutyp = '2'
500hAC                   eval      $saqty3 = w3qty
500hAC                   endsl
500hAC                   eval      $satrn#u = *on
600cMC                   eval      $satrn#  = $pttrn#
500hAC                   eval      $satasku = *on
600cMC                   eval      $satask  = $pttask
600dDC**                 eval      $salic#u = *on
600dDC**                 eval      $salic#  = w1lcns
500hA
500hAC                   eval      $dricommand = '*SLOT'
600cMC                   if        $pttask = 'PUTRTN'
500hAC                   eval      $drisubcmd  = '%VERIFYRTN'
500hAC                   else
500hAC                   eval      $drisubcmd  = '%VERIFYPUT'
500hAC                   endif
500hAC                   eval      $drisys2upd = 'D'
500hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *on
500hAC                   exsr      zzzdricop
500hAC                   if        error
710hAc                   Select
710hAc                   When      opiswn = 'Y'   and
710hAc                             $drireturn = 'SLTNOTACTV' and
710hAc                             $sldispe = '2'
710hAc                   eval      warnis = '1'
710hAc                   endsl
rylaAC                   else
rylaAC                   if        client = royal
rylaAC                   exsr      zzgetp
rylaAC                   if        $slexpd < slexpd and warnp = *off
rylaAC                   eval      slpicke = *on
rylaAC                   eval      $slpicke = '4'
rylaAC                   move      *on           error
rylaAC                   eval      errmsg = 'Newer product in pick slot'
rylaAC                   eval      warnp = *on
rylaAC                   exsr      zm0105
rylaAC                   endif
rylaAC                   endif
500hAC                   endif
     *
640aA*   Get status of USR slot.
640aAC     keys2         chain     slot2
640aAC                   if        not %found(slot2)
640aAC                   eval      s_slstat = *blanks
640aAC                   endif
640aA*
     *
640aAC                   if        s_slstat <> 'A ' and $slpick = 'Y'
700fAC                             and $slstyp = 'F'
640aAC                   move      *on           error
640aAC                   eval      errmsg = 'From status not A, cannot +
640aAC                                       put qty in pick slot.'
640aAC                   exsr      zm0105
640aAC                   endif

     *   2016-141 Req to Hard Code QU not allowed on Putaway
CBI7AC                   if        client = cheney
CBI7AC                   if        s_slstat='QU'
CBI7AC                   eval      error = *on
CBI7AC                   eval      ovrrid = *off
CBI7AC                   eval      errmsg = 'Cannot put in this slot. +
CBI7AC                                       status QU.'
CBI7AC                   exsr      zm0105
CBI7AC                   endif
CBI7AC                   endif

DRYbA*   if client = dairyland then do not allow for quarantined
DRYbA*   products to go to slots that already have products, just
DRYbA*   quarantined or empty slots.
DRYbAC                   if        client = dairyland
DRYbAC                   if        s_slstat='QU' and $slstat <> 'QU'
DRYbAC                   if        $slstat <> 'Z' and $slstat <> 'V'
DRYbAC                   eval      error = *on
DRYbAc                   eval      ovrrid = *off
DRYbAC                   eval      errmsg = 'Cannot put in this slot. +
DRYbAC                                       Status mismatch.'
DRYbAC                   exsr      zm0105
DRYbAC                   endif
DRYbAC                   endif
DRYbA*   if rcv status is A and base slot status is QU, then show error.
DRYbAC                   if        s_slstat='A' and $slstat = 'QU'
DRYbAC                   eval      error = *on
DRYbAc                   eval      ovrrid = *off
DRYbAC                   eval      errmsg = 'Cannot put in this slot. +
DRYbAC                                       Status mismatch.'
DRYbAC                   exsr      zm0105
DRYbAC                   endif
DRYbAC                   endif
DRYbA
CBIjA*   if client = cheney then do not allow for mismatch status.
CBIjA*   if rcv status is A and base slot status not A, then show error.
CBIjAC                   if        client = cheney
CBIjAC                   if        s_slstat='A'
CBIjAC                             and ($slstat='I' or $slstat='QU'
CBIjAC                             or $slstat='S')
CBIjAC                   eval      error = *on
CBIjAC                   eval      ovrrid = *off
CBIjAC                   eval      errmsg = 'Cannot put in this slot. +
CBIjAC                                       status mismatch.'
CBIjAC                   exsr      zm0105
CBIjAC                   endif
CBIjAC                   endif

500hA
415e C     enderr        tag
     C                   move      w3scan        odisp
409 A*
415eA*   Save screen fields.
     *
415eAC                   move      w3scan        svdisp
409 A*
409 AC     endck3        endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  ZZCHK4   Screen 4 error checking.
415kA*
415kAC     zzchk4        begsr
     C                   move      *off          error
     *
     *  QUANTITY MUST BE = PUT AWAY QUANTITY
     *
     C                   if        w4qty <> lbqpck
     C                   move      *on           error
     C                   eval      *in27 = *on
     C                   eval      *in07 = *on
     C                   exsr      zm2003
     C                   exsr      zzlog4
     C                   endif
     *
     C     error         cabeq     *on           endck4
     *
     C     endck4        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZCHK5   Screen 5 error checking.
416dA*
416dAC     zzchk5        begsr
TMPaAC                   eval      currRoutine = 'zzchk5'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   eval      error = *off
710fDC*****              eval      ptatyp = *blanks
416dA*
416dA*  If none are entered, user has finished scanning entries.
416dA*
710fAC                   select
710fAC                   when      w5lcns = '0'
710fAC                   eval      w5lcns = *blanks
710fAC                   when      w5lbl#b = '0'
710fAC                   eval      w5lbl#b = *blanks
710fAC                   endsl
416fMC                   if        w5lcns = *blanks  and
530bMC                             w5lbl#b = *blanks
530bD ***                          w5lbl# = 0
416dAC                   goto      endck5
416dAC                   endif
650jA*
710fAC                   eval      ptatyp = *blanks
650jA*  Validate scanned license for invalid characters. If found, replace with
650jAC                   eval      wklicense = w5lcns
650jAC                   exsr      zzcklicense
650jAC                   eval      w5lcns = %subst(wklicense:1:15)
416dA*
416dA*  Enter only one, license, or label #.
416dA*
416fMC                   if        w5lcns <> *blanks  and
530bMC                             w5lbl#b <> *blanks
530bD ***                          w5lbl# <> 0
416dAC                   eval      error = *on
416dAC                   eval      *in22 = *on
416dAC                   eval      *in02 = *on
416dAC                   eval      *in24 = *on
416dAC                   eval      *in04 = *on
416dAC                   exsr      zm0204
416dAC                   goto      endck5
416dAC                   endif
600cA
600dAC                   if        w5lcns <> *blanks
600dDC                   move      '*LICENSE'    ptatyp
600dAC                   endif
530bD
530bD*    Set repack flag.
530bD
530bD **                 if        $ptgrp1 = 'K'
530bD **                 eval      repack = yes
530bD **                 else
530bD **                 eval      repack = no
530bD **                 endif


600dDC**
600dDC** Left justify license.
600dDC**
600dDC**                 eval      $cstr = *blanks
600dDC**                 move      w5lcns        $cstr
600dDC**                 call      'ADJUST'
600dDC**                 parm      '*LEFTNOZ'    $ccmd
600dDC**                 parm                    $cstr
600dDC**                 movel     $cstr         w5lcns
600dDC**
600dDC** Verify license plate number.
600dDC**
600dDC**                 if        w5lcns <> *blanks  and
600dDC**                           w5lbl# = 0
600dDC**
600dDC**                 move      '*LICENSE'    ptatyp
600dDC**                 move      *off          goodli
600dDC**                 eval      kylcns = w5lcns
600dDC**   likey2        setll     license
600dDC**
600dDC**   nxtli5        tag
600dDC**
600dDC**   likey2        reade(n)  license                                78
600dDC**                 if        not *in78
600dDC**   litrn#        chain(n)  pirtran                            79
600dDC**                 if        not *in79
600dDC**   Wrong transaction record found. Read next license.
600dDC**                 if        $pttask <> 'PUTEMP'  and
600dDC**                           $pttask <> 'PUTRTN'
600dDC**                 goto      nxtli5
600dDC**                 else
600dDC**                 move      *on           goodli
600dDC**                 endif
600dDC**                 else
600dDC**                 goto      nxtli5
600dDC**                 endif
600dDC**                 endif
600dDC**
600dDC**   License plate entered is NOT valid.
600dDC**
600dDC**                 if        goodli = *off
600dDC**                 move      *on           error
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 exsr      zm1022
600dDC**                 goto      endck5
600dDC**                 endif
600dDC**                 endif
600dDC**
600dDC** Check to see if license is deleted and display error if it is.
600dDC**
600dDC**                 if        goodli = *on
600dDC**   litrn#        setgt     porcv1
600dDC**   litrn#        readpe    porcv1                                 79
600dDC**                 if        not *in79
600dDC**                 if        poract <> 'D'
600dDC**                 else
600dDC**                 eval      goodli = *off
600dDC**                 eval      error = *on
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 exsr      zm2021
600dDC**                 goto      endck5
600dDC**                 endif
600dDC**                 endif
600dDC**                 endif
416dA*
416dA*  Verify label number.
416dA*
416dAC                   eval      wolbl# = 0
600dDC**                 eval      wotrn# = 0
530bD ***                if        w5lbl# <> 0
530bMC                   if        w5lbl#b <> *blanks
     * grab label#
530bAC                   move      w1whse        $pwhseb
530bAC                   movel     w5lbl#b       $pbarcode
530bAC                   call      @cvtbarsel
530bAC                   parm                    $pwhseb
530bAC                   parm                    $pbarcode
530bAC                   parm                    $plbl#
530bAC                   parm                    $prtid
530bAC                   parm                    $punq#
530bAC                   parm                    $preturn
530bAC                   parm                    $perrmsg
530bAC                   if        $preturn = '*OK'
530bAC                   eval      w5lbl# = $plbl#
530bAC                   move      *blanks       w5lbl#b
530bAC                   move      $plbl#        w5lbl#b
530bAC                   else
530bAC                   eval      error = *on
530bAC                   eval      *in22 = *on

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(5)
720cAC                   other
530bAC                   eval      errmsg = desc(5)
720cAC                   endsl

530bAC                   exsr      zm0110
530bAC                   endif
416dAC                   move      '*LABEL  '    ptatyp
416dAC                   eval      wolbl# = w5lbl#
416dAC                   eval      lbcnt = 0
416dAC     llkey1        setll     labelnk1
416dAC     nxtlb5        tag
416dAC     llkey1        reade     labelnk1                               78
416dAC                   if        not *in78
416dA*
     C                   if        ptstat <> '1'
416dAC                   goto      nxtlb5
416dAC                   else
416dAC                   add       1             lbcnt
416dAC                   eval      lktrn# = lltrn#
416dAC                   endif
416dA*
416dAC                   if        lbcnt > 1
416dAC                   eval      $lcmd = '*LOOKUP '
416dAC                   eval      $llwhs = w1whse
416dAC                   eval      $llblo = lllblo
416dAC                   eval      $ltrn2 = 0
TMPaAC                   eval      currRoutine = 'LL145'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   call      'LL145'
416dAC                   parm                    $lparm
416dAC                   parm                    $llwhs
TMPaAC                   exsr      phpgmV1V2V3e
416dAC                   if        $lrtn = '*ERROR  '
416dAC                   move      *on           error
416dAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
416dAC                   eval      errmsg = desc(2)
501uAC                   endsl
416dAC                   eval      *in24 = *on
416dAC                   eval      *in04 = *on
416dAC                   exsr      zm1001
TMPaAC                   exsr      phpgmV1V2V3e
600iAC                   leavesr
416dAC                   else
416dA*
416dAC                   if        $lrtn = '*PGMQ   '
416dAC                   eval      error = *on
416dAC                   eval      *in24 = *on
416dAC                   eval      *in04 = *on
416dAC                   eval      #msgk = $lmsg
416dAC                   exsr      zmqmsg
TMPaAC                   exsr      phpgmV1V2V3e
600iAC                   leavesr
416dAC                   else
416dAC                   z-add     $ltrn2        lktrn#
416dAC                   endif
416dAC                   endif
416dAC                   else
416dAC                   goto      nxtlb5
416dAC                   endif
416dAC                   endif
416dA*
416dAC                   if        $lrtn = '*CANCEL'  or
416dAC                             $lrtn = '*ERROR '  or
416dAC                             $lrtn = '*PGMQ  '
416dAC                   move      *on           error
TMPaAC                   exsr      phpgmV1V2V3e
600iAC                   leavesr
416dAC                   endif
416dA*
416dAC                   if        lbcnt = 0
416dAC                   move      *on           error
416dAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
416dAC                   eval      errmsg = desc(2)
501uAC                   endsl
416dAC                   eval      *in24 = *on
416dAC                   eval      *in04 = *on
416dAC                   exsr      zm1001
TMPaAC                   exsr      phpgmV1V2V3e
600iAC                   leavesr
416dAC                   endif
600iA
600iA*    Create license used for label#.
600iA
600iAC                   eval      w5lcns = '*RT'
600iAC                                    + %trim(%editc(lktrn#:'X'))
600iA
416dAC                   endif
600dDC**
600dDC** Make sure that the transaction is open.
600dDC**
600dDC**                 if        wotrn# = 0
600dDC**                 select
600dDC**                 when      w5lcns <> *blanks
600dDC**                 z-add     litrn#        wotrn#
600dDC**                 when      w5lbl# <> 0
600dDC**                 eval      wotrn# = lktrn#
600dDC**                 endsl
600dDC**                 endif
600cDC**   ptkey         chain(n)  pirtran                            79
600dDC**
600dDC**   Putaway transaction no longer at open status.
600dDC**
600cDC**                 if        not *in79  and
600dDC**                           $ptstat <> '1'
600dDC**                 eval      error = *on
600dDC**                 select
600dDC**
600dDC**   License entered - position cursor.
600dDC**
600dDC**                 when      w5lcns <> *blanks  and
600dDC**                           w5lbl# = 0
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**
600dDC**   Label entered - position cursor.
600dDC**
600dDC**                 when      w5lcns = *blanks  and
600dDC**                           w5lbl# <> 0
600dDC**                 eval      *in24 = *on
600dDC**                 eval      *in04 = *on
600dDC**                 endsl
600dDC**                 eval      errmsg = *blanks
600dDC**                 eval      ertrn# = wotrn#
600dDC**                 exsr      zm2002
600dDC**                 endif
600dA
600dA*  Verify license
600dA
600dAC                   eval      w1lcns = w5lcns
TMPaAC                   eval      currRoutine = 'zzvfylcns'
TMPaAC                   exsr      phpgmV1V2V3s
600dAC                   exsr      zzvfylcns
TMPaAC                   exsr      phpgmV1V2V3e
600dAC                   if        error
TMPaAC                   exsr      phpgmV1V2V3e
600dAC                   leavesr
600dAC                   endif
600dA
600dA*    Set wotrn# field.
600dA
600dAC                   eval      wotrn# = $pttrn#
     *
     * Check if product is expired.
511e *
511eAC                   if        w5lbl# <> wklbl# or
511eAC                             w5lcns <> wklcns
511eAC                   eval      dtchk = *off
511eAC                   endif
511e *
417jAC                   move      w5lbl#        wklbl#
417jAC                   move      w5lcns        wklcns
511e *
511eAC                   if        dtchk = '2'  and
511eAC                             ovrrid = *on
511eAC                   eval      dtchk = *on
511eAC                   endif
511e *
511eAC                   if        dtchk <> '1'
511eAC                   eval      dtchk = *on
TMPaAC                   eval      currRoutine = 'zzckdt'
TMPaAC                   exsr      phpgmV1V2V3s
417jAC                   exsr      zzckdt
TMPaAC                   exsr      phpgmV1V2V3e
511eAC                   endif
     *
416dA*
416dA*    Load key values.
     *
     C                   select
     *
416dA*    Load key values. License scanned.
     *
     C                   when      w5lcns <> *blanks  and
     C                             w5lbl# = 0
416fMC                   move      w5lcns        kypnbr
416dAC                   move      'P'           kyptyp
     *
416dA*    Load key values. Label scanned.
     *
600iDC**                 when      w5lcns = *blanks  and
600iDC**                           w5lbl# <> 0
600iMC                   when      w5lbl# <> 0
600iMC                   eval      kypnbr = %editc(w5lbl#:'X')
     C                   move      'L'           kyptyp
     C                   endsl
     *
416dA*    Check if license/Label already scanned in.
     *
416dAC                   eval      wuScanNbr = kypnbr
TMPaAC                   eval      currRoutine = 'zzckpk'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      zzckpk
TMPaAC                   exsr      phpgmV1V2V3e
416dAC                   if        error = *on
416dAC                   goto      endck5
416dAC                   endif
416hA*
416hA*    Flag to signal a valid entry was made.
     *
416hAC                   move      *on           frstps
416dA*
TMPAAC     endck5        tag
TMPaAC                   exsr      phpgmV1V2V3e
TMPaDC**   endck5        endsr
TMPaMC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZCHK6   Screen 6 error checking.
416dA*
416dAC     zzchk6        begsr
416dAC                   move      *off          error
640hA* grab label#
710fAC                   select
750bDC*                  when      ptatyp = '*LABEL  '
750bMC                   when      WUSCANTYPE = 'L'
416dAC                   if        w6nxt# <> w6mtch
640hAC                   move      w1whse        $pwhseb
640hAC                   movel     w6nxt#        $pbarcode
640hAC                   call      @cvtbarsel
640hAC                   parm                    $pwhseb
640hAC                   parm                    $pbarcode
640hAC                   parm                    $plbl#
640hAC                   parm                    $prtid
640hAC                   parm                    $punq#
640hAC                   parm                    $preturn
640hAC                   parm                    $perrmsg
640hAC                   if        $preturn = '*OK'
640hAC                   eval      w6nxt# = %editc($plbl#:'X')
640hMC**                 eval      w6nxt# = %char($plbl#)
640hAC                   endif
640hAC                   endif
710fAC                   endsl
416dA*
416dA*  Scanned in license, or label number must match check value.
416dA*
416dAC                   if        w6nxt# <> w6mtch
416dAC                   move      *on           error
416dAC                   eval      *in28 = *on
416dAC                   eval      *in08 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   select
     *
416dA*    License plate scanned - invalid number.
     *
416dAC                   when      w6txt = w6txt1
600hDC**                 exsr      zm1022
600hMC                   eval      errmsg = 'License does not match'
600hMC                   exsr      zm0105
     *
416dA*    Label scanned - invalid number.
     *
416dAC                   when      w6txt = w6txt2
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
416dAC                   eval      errmsg = desc(2)
501uAC                   endsl
416dAC                   exsr      zm0205
416dAC                   endsl
600hAC                   if        error
600hAC                   leavesr
600hAC                   endif
416dAC                   endif
416dA*
416dA*  Verify license plate number.
416dA*
416fMC                   if        w6nxt# <> *blanks  and
416dAC                             w6txt = w6txt1
416dA*
640hA* grab label#
650aDC*                  move      w1whse        $pwhseb
650aDC*                  movel     w6nxt#        $pbarcode
650aDC*                  call      @cvtbarsel
650aDC*                  parm                    $pwhseb
650aDC*                  parm                    $pbarcode
650aDC*                  parm                    $plbl#
650aDC*                  parm                    $prtid
650aDC*                  parm                    $punq#
650aDC*                  parm                    $preturn
650aDC*                  parm                    $perrmsg
650aDC*                  if        $preturn = '*OK'
640hDC**                 eval      w6nxt# = %editc($plbl#:'X')
650aDC*                  eval      w6nxt# = %char($plbl#)
650aDC*                  endif
640hA*
416dAC                   move      '*LICENSE'    ptatyp
416dAC                   move      *off          goodli
416fMC                   move      w6nxt#        kylcns
416dAC     likey2        setll     license
416dA*
416dAC     nxtli6        tag
416dA*
417iMC     likey2        reade(n)  license                                78
416dAC                   if        not *in78
600cDC**   litrn#        chain(n)  pirtran                            79
600cDC**                 if        not *in79
600cAC                   eval      gttrn# = litrn#
600cAC                   exsr      zzgett
600cAC                   if        trnFound
     *
416dA*    Wrong transaction record found. Read next license.
     *
600cMC                   if        $pttask <> 'PUTEMP'  and
710dMC                             $pttask <> 'PUTRTN'  and
710dAC                             $pttask <> 'PUTPD '
416dAC                   goto      nxtli6
416dAC                   else
416dAC                   move      *on           goodli
416dAC                   endif
416dAC                   else
416dAC                   goto      nxtli6
416dAC                   endif
416dAC                   endif
416dA*
416dA*    License plate entered is NOT valid.
     *
416dAC                   if        goodli = *off
416dAC                   move      *on           error
416dAC                   eval      *in22 = *on
416dAC                   eval      *in02 = *on
416dAC                   eval      errmsg = *blanks
416dAC                   exsr      zm1022
416dAC                   goto      endck6
416dAC                   endif
416dAC                   endif
416dA*
416dA*  Verify label number.
416dA*
416dAC                   eval      wolbl# = 0
416dAC                   eval      wotrn# = 0
416fMC                   if        w6nxt# <> *blanks  and
416dAC                             w6txt = w6txt2
640hA* grab label#
640hAC                   move      w1whse        $pwhseb
640hAC                   movel     w6nxt#        $pbarcode
640hAC                   call      @cvtbarsel
640hAC                   parm                    $pwhseb
640hAC                   parm                    $pbarcode
640hAC                   parm                    $plbl#
640hAC                   parm                    $prtid
640hAC                   parm                    $punq#
640hAC                   parm                    $preturn
640hAC                   parm                    $perrmsg
640hAC                   if        $preturn = '*OK'
640hAC                   eval      w6nxt# = %editc($plbl#:'X')
640hAC                   else
640hAC                   eval      error = *on
640hAC                   eval      *in22 = *on

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(5)
720cAC                   other
640hAC                   eval      errmsg = desc(5)
720cAC                   endsl

640hAC                   exsr      zm0110
640hAC                   goto      endck6
640hAC                   endif
640hA*
416dAC                   move      '*LABEL  '    ptatyp
416fMC                   movel     w6nxt#        wolbl#
416dAC                   eval      lbcnt = 0
416dAC     llkey1        setll     labelnk1
416dAC     nxtlb6        tag
416dAC     llkey1        reade     labelnk1                               78
416dAC                   if        not *in78
416dA*
     C                   if        ptstat <> '1'
416dAC                   goto      nxtlb6
416dAC                   else
416dAC                   add       1             lbcnt
416dAC                   eval      lktrn# = lltrn#
416dAC                   endif
416dA*
416dAC                   if        lbcnt > 1
416dAC                   eval      $lcmd = '*LOOKUP '
416dAC                   eval      $llwhs = w1whse
416dAC                   eval      $llblo = lllblo
416dAC                   eval      $ltrn2 = 0
416dAC                   call      'LL145'
416dAC                   parm                    $lparm
416dAC                   parm                    $llwhs
416dAC                   if        $lrtn = '*ERROR  '
416dAC                   move      *on           error
416dAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
416dAC                   eval      errmsg = desc(2)
501uAC                   endsl
416dAC                   eval      *in28 = *on
416dAC                   eval      *in08 = *on
416dAC                   exsr      zm1001
416dAC                   else
416dA*
416dAC                   if        $lrtn = '*PGMQ   '
416dAC                   eval      error = *on
416dAC                   eval      *in28 = *on
416dAC                   eval      *in08 = *on
416dAC                   eval      #msgk = $lmsg
416dAC                   exsr      zmqmsg
416dAC                   else
416dAC                   z-add     $ltrn2        lktrn#
416dAC                   endif
416dAC                   endif
416dAC                   else
416dAC                   goto      nxtlb6
416dAC                   endif
416dAC                   endif
416dA*
416dAC                   if        $lrtn = '*CANCEL'  or
416dAC                             $lrtn = '*ERROR '  or
416dAC                             $lrtn = '*PGMQ  '
416dAC                   move      *on           error
416dAC                   endif
416dA*
416dAC                   if        lbcnt = 0
416dAC                   move      *on           error
416dAC                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(2)
501uAC                   other
416dAC                   eval      errmsg = desc(2)
501uAC                   endsl
416dAC                   eval      *in28 = *on
416dAC                   eval      *in08 = *on
416dAC                   exsr      zm1001
416dAC                   endif
416dAC                   endif
416dA*
416dA*  Make sure that the transaction is open.
416dA*
416dAC                   if        wotrn# = 0
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
416dAC                   z-add     litrn#        wotrn#
416dAC                   when      ptatyp = '*LABEL  '
416dAC                   eval      wotrn# = lktrn#
416dAC                   endsl
416dAC                   endif
600cDC**   ptkey         chain(n)  pirtran                            79
600cAC                   eval      gttrn# = wotrn#
600cAC                   exsr      zzgett
416dA*
416dA*    Putaway transaction no longer at open status.
     *
600cDC**                 if        not *in79  and
600cMC                   if        not trnFound or
600cMC                             $ptstat <> '1'
416dAC                   eval      error = *on
416dAC                   eval      errmsg = *blanks
600cMC                   eval      ertrn# = $pttrn#
416dAC                   exsr      zm2002
     *
416dA*    Entry status changed. Delete entry from file.
     *
416eAC                   if        w6nxt# = w6mtch
416dAC                   exsr      zzdlp1
416eAC                   endif
416dAC                   endif
416dA*
416dAC     endck6        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZCHK7   Screen 7 error checking.
417i *
417i C     zzchk7        begsr
417i C                   move      *off          error
417i *
417i *  Zone must be entered.
     *
417i C                   if        w7scan = *blanks
417i C                   move      *on           error
417i C                   eval      *in21 = *on
417i C                   eval      *in01 = *on
417i C                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(4)
501uAC                   other
417i C                   eval      errmsg = desc(4)
501uAC                   endsl
417i C                   exsr      zm9898
417i C                   goto      endck7
417i C                   endif
     *
417i *  Verify zone scanned zone.
     *
620 DC*                  move      w7zone        zone
620 MC                   move      w7scan        zone
417i C     keyzh         chain     stagh                              79
417i C                   if        *in79
417i C                   move      *on           error
417i C                   eval      *in21 = *on
417i C                   eval      *in01 = *on
417i C                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(4)
501uAC                   other
417i C                   eval      errmsg = desc(4)
501uAC                   endsl
417i C                   exsr      zm9898
417i C                   eval      zdesc = *blanks
417i C                   goto      endck7
417i C                   else
417i C                   movel     shdesc        zdesc
417i C                   endif
417i *
417iAC     endck7        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZCHK8   Screen 8 error checking.
417i *
417iAC     zzchk8        begsr
417i C                   move      *off          error
417i *
417i *  Left justify license.
     *
417i C                   eval      $cstr = *blanks
417i C                   move      w8scan        $cstr
417i C                   call      'ADJUST'
417i C                   parm      '*LEFTNOZ'    $ccmd
417i C                   parm                    $cstr
417i C                   movel     $cstr         w8scan
417i *
417i *  Verify lic# scanned matches lic# displayed
417i *
417i C                   if        w8scan <> w8lic#
417i C                   move      *on           error
417i C                   eval      *in21 = *on
417i C                   eval      *in01 = *on
417i C                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(3)
501uAC                   other
417i C                   eval      errmsg = desc(3)
501uAC                   endsl
417i C                   exsr      zm9898
417i C                   goto      endck8
417i C                   endif
417i *
417iAC     endck8        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  ZZCHKAPT   aptscrn error checking.
PFCaA*
PFCaAc     zzchkapt      begsr
PFCaAc*   SLCHK, Flags are used to force F20 for each test
PFCaAc*   Values: Flag = 0 Do check.
PFCaAc*           Flag = 1 Check was done, ok.
PFCaAc*           Flag = 2 Warning condition.
PFCaA
PFCaAc                   eval      error = *off
PFCaA
PFCaAc*  Call API for slot.
PFCaA
PFCaAc                   select
PFCaAc                   when      watype = 'S'
PFCaAc                   call      @APICS
PFCaAc                   parm                    wafrom
PFCaAc                   parm      6             worow
PFCaAc                   parm      7             wocol
PFCaAc                   parm                    @artn             8
PFCaAc                   if        @artn = '*REDSPLY'
PFCaAc                   move      *on           redspl
PFCaAc                   goto      endckapt
PFCaAc                   endif
PFCaA
PFCaAc*  Verify Slot.
PFCaAc                   move      '*VERIFY '    $lcmd
PFCaAc                   z-add     w1whse        $lwhse
PFCaAc                   move      wuPckWhdp     $lwhdp
PFCaAc                   move      *blanks       $litem
PFCaAc                   move      wafrom        $ldisp
PFCaAc                   call      'SL900'
PFCaAc                   parm                    $lparm
PFCaA
PFCaAc                   if        $lrtn = '*ERROR  '
PFCaAc                   move      *on           error
PFCaAc                   move      *on           *in26
PFCaAc                   move      *on           *in06
PFCaAc                   movel     $lerm         errmsg
PFCaAc                   exsr      zm0105
PFCaAc                   else
PFCaA
PFCaAc                   if        $lrtn = '*PGMQ   '
PFCaAc                   move      *on           error
PFCaAc                   move      *on           *in26
PFCaAc                   move      *on           *in06
PFCaAc                   move      $lmsg         #msgk
PFCaAc                   exsr      zmqmsg
PFCaAc                   endif
PFCaAc*
PFCaAc                   endif
PFCaA
PFCaAc*  Verify Dock door.
PFCaA
PFCaAc                   when      watype = 'D'
PFCaAc                   move      *off          *in81
PFCaAc     digit         check     wafrom                                 81
PFCaA
PFCaAc*  *IN81 = *ON - Found character other than that contained
PFCaAc*           in the field DIGIT.
PFCaA
PFCaAc                   if        *in81 = *on
PFCaAc                   move      *on           error
PFCaAc                   move      *on           *in26
PFCaAc                   move      *on           *in06
PFCaAc                   move      *blanks       errmsg
PFCaAc                   movel     desc(4)       errmsg
PFCaAc                   exsr      zm1001
PFCaAc                   else
PFCaAc                   z-add     0             wadoor            3 0
PFCaAc                   move      *blanks       $cstr
PFCaAc                   movel     wafrom        $cstr
PFCaAc                   call      'ADJUST'
PFCaAc                   parm      '*RTSTRIP'    $ccmd             8
PFCaAc                   parm                    $cstr            30
PFCaAc                   move      $cstr         wadoor
PFCaA
PFCaAc*    Verify dock door isn't greater than 999.
PFCaAc                   z-add     0             watest           13 0
PFCaAc                   move      $cstr         watest
PFCaAc                   if        watest > 999
PFCaAc                   move      *on           error
PFCaAc                   move      *on           *in26
PFCaAc                   move      *on           *in06
PFCaAc                   move      *blanks       errmsg
PFCaAc                   movel     desc(4)       errmsg
PFCaAc                   eXSR      zm1001
PFCaAc                   endif
PFCaA
PFCaAc                   if        error = *off
PFCaAc     dockey        setll     docdoor
PFCaAc     dockey        reade     docdoor                                78
PFCaAc                   if        *in78 = '1'
PFCaAc                   move      *ON           error
PFCaAc                   move      *ON           *in26
PFCaAc                   move      *ON           *in06
PFCaAc                   move      *blanks       errmsg
PFCaAc                   movel     desc(4)       errmsg
PFCaAc                   exsr      zm1001
PFCaAc                   else
PFCaAc*    Don't strip off leading zeros from dock door number.
PFCaAc                   movel     wadoor        wafrom
PFCaAc                   endif
PFCaAc                   endif
PFCaAc                   endif
PFCaAc*  Error if not D or S.
PFCaAc                   other
PFCaAc                   move      *on           error
PFCaAc                   move      *on           *in27
PFCaAc                   move      *on           *in07
PFCaAc                   move      *blanks       errmsg
PFCaAc                   movel     desc(6)       errmsg
PFCaAc                   exsr      zm1001
PFCaA
PFCaAc                   endsl
PFCaAc*  Must enter FROM value.
PFCaAc     wafrom        ifeq      *blanks
PFCaAc                   move      *ON           error
PFCaAc                   move      *ON           *in26
PFCaAc                   move      *ON           *in06
PFCaAc                   exsr      zm0205
PFCaAc                   endif
PFCaAc*
PFCaAc     enderapt      tag
PFCaA*
PFCaAc     endckapt      endsr
ISYa *----------------------------------------------------------------
ISYa *
ISYaA*  ZZCHK9a  Screen 9A error checking.
ISYa *
ISYaAC     zzchk9a       begsr
ISYa *
ISYa *  SLCHK, Flags are used to force F20 for each test
ISYa *  Values: Flag = 0 Do check
ISYa *          Flag = 1 Check was done, ok.
ISYa *          Flag = 2 Warning condition.
ISYa *
ISYa C                   move      *off          error
ISYa *
ISYa *  Call API for slot
ISYa *
ISYa C                   select
ISYa C                   when      w9atype = 'S'
ISYa C                   call      @APICS
ISYa C                   parm                    w9afrom
ISYa C                   parm      6             worow
ISYa C                   parm      7             wocol
ISYa C                   parm                    @artn             8
ISYa C                   if        @artn = '*REDSPLY'
ISYa C                   eval      redspl = *on
ISYa C                   goto      endck9a
ISYa C                   endif
ISYa *  Verify slot.
ISYa C                   eval      $lcmd = '*VERIFY '
ISYa C                   z-add     w1whse        $lwhse
ISYb *  If dept=FROZ, override to use COOLR.  Do this because the
ISYb *  location whee FROZ products are picked up is located in
ISYb *  the COOLR department.
ISYb C                   movel     w9afrom       frloc             1
ISYb C                   if        frloc = 'C' and
ISYfMC                             wuPckwhdp = 'FROZ '
ISYbDC***************              wkpwhd = 'FROZ '
ISYb C                   move      'COOLR'       $lwhdp
ISYb C                   else
ISYfMC                   move      wuPckwhdp     $lwhdp
ISYbDC***************    move      wkpwhd        $lwhdp
ISYb C                   endif
ISYa C                   move      *blanks       $litem
ISYa C                   move      w9afrom       $ldisp
ISYa C                   call      'SL900'
ISYa C                   parm                    $lparm
ISYa C                   if        $lrtn = '*ERROR  '
ISYa C                   eval      error = *on
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   movel     $lerm         errmsg
ISYa C                   exsr      zm0105
ISYa C                   else
ISYa C                   if        $lrtn = '*PGMQ   '
ISYa C                   move      *on           error
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   eval      #msgk = $lmsg
ISYa C                   exsr      zmqmsg
ISYa C                   endif
ISYa C                   endif
ISYa *  Verify Dock door.
ISYa C                   when      w9atype = 'D'
ISYa C                   eval      *in81 = *off
ISYa C     digit         check     w9afrom                              81
ISYa *  IN81 = *on - Found character other than that contained
ISYa *               in the field DIGIT.
ISYa C                   if        *in81 = *on
ISYa C                   move      *on           error
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   move      *blanks       errmsg
ISYgD ***                eval      errmsg = desc(5)

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(6)
720cAC                   other
ISYgMC                   eval      errmsg = desc(6)
720cAC                   endsl

ISYa C                   exsr      zm1001
ISYa C                   else
ISYa C*                  eval      w9door = 0
ISYa C                   z-add     0             w9door            3 0
ISYa C                   move      *blanks       $cstr
ISYa C                   movel     w9afrom       $cstr
ISYa C                   call      'ADJUST'
ISYa C                   parm      '*RIGHT  '    $ccmd
ISYa C                   parm                    $cstr
ISYcDC*                  movel     $cstr         w9door
ISYcMC                   move      $cstr         w9door
ISYa C     dockey        setll     docdoor
ISYa C     dockey        reade     docdoor                                78
ISYa C                   if        *in78
ISYa C                   move      *on           error
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   move      *blanks       errmsg
ISYgD ***                eval      errmsg = desc(5)

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(6)
720cAC                   other
ISYgMC                   eval      errmsg = desc(6)
720cAC                   endsl

ISYa C                   exsr      zm1001
ISYa C                   endif
ISYa C                   endif
ISYa *  Verify stage location
ISYa C                   when      w9atype = 'L'
ISYa C                   movel     w9afrom       w9stag            6
ISYa C     stgkey        chain     stagh                              78
ISYa C                   if        *in78 = *on
ISYa C                   move      *on           error
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   move      *blanks       errmsg
ISYgD ***                eval      errmsg = desc(6)

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(7)
720cAC                   other
ISYgMC                   eval      errmsg = desc(7)
720cAC                   endsl

ISYa C                   exsr      zm1001
ISYa C                   endif
ISYa *  Error if not D, L, or S.
ISYa C                   other
ISYa C                   move      *on           error
ISYa C                   eval      *in27 = *on
ISYa C                   eval      *in07 = *on
ISYa C                   move      *blanks       errmsg
ISYgD ***                eval      errmsg = desc(7)

720cAC                   select
720cAC                   when      e$lng = 'SP'
720cAC                   eval      errmsg = descsp(8)
720cAC                   other
ISYgMC                   eval      errmsg = desc(8)
720cAC                   endsl

ISYa C                   exsr      zm1001
ISYa C                   endsl
ISYa C* Must enter FROM value.
ISYa C                   if        w9afrom = *blanks
ISYa C                   move      *on           error
ISYa C                   eval      *in26 = *on
ISYa C                   eval      *in06 = *on
ISYa C                   exsr      zm0205
ISYa C                   endif
ISYa C*                                                                7
ISYaAC     ender9a       tag
ISYa *  Save screen fields.
ISYa C     endck9a       endsr
501tA*
501tA*----------------------------------------------------------------
501tA*
501tA*  ZZCHK9   Screen 9 error checking.
501tA*
501tAC     zzchk9        begsr
501tAC                   move      *off          error
501tA*
501tAC     endck9        endsr
501tA*
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZCHK10  Screen 10 error checking.
650eA*
650eAC     zzchk10       begsr
650eA*
650eA*
650eAC                   move      *off          error
650eA*
650eA*   Verify aisle
650eA*
650eA */ right adjust what the user enters - removing blanks
650eAc                   call      'ADJUST'
650eAc                   parm      '*RTSTRIP'    $ccmd             8
650eAC                   parm      w10aisle      $cstr            30
650eAC                   move      $cstr         w10aisle
650eA /free
650eA    setll (w1whse:w10aisle) slot11;
650eA    reade (w1whse:w10aisle) slot11;
650eA    if %eof(slot11);
650eA      error = *on;
650eA      eval *in41 = *on;
650eA      exsr zm0122;
650eA      exsr zmqmsg;
650eA      leavesr;
650eA    endif;
650eA /end-free
650eA*
650eAC     endck10       tag
650eAC                   endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZCHK11  Screen 11 error checking.
650eA*
650eAC     zzchk11       begsr
650eA*
650eA*
650eAC                   move      *off          error
650eA*
650eAC     endck11       tag
650eAC                   endsr
417j *----------------------------------------------------------------
417j *
417j *
417jA*  ZZCKDT   Check if date is expired.
417j *
417j C     zzckdt        begsr
     *
417j * Get label # if trans or license was entered.
     *
417j C                   if        wklbl# = 0  and
417j C                             error = *off
417j C     lbky7a        setll     label7
417j C     lbky7a        reade     label7                                 79
417j C                   if        not *in79

CBI0AC                   if        client = cheney
CBIiA * Get PO # from LABEL file to load POMFR2 key below,
CBIiA * LABEL7 file does not have "Lbpo" field in it.
CBIiAC     lblbl#        chain(n)  label                              79
750bDC*    mfr2ky        chain(n)  pomfr2                             77
750bMC     mfr3ky        chain(n)  pomfr3                             77
CBIiAC                   else


610fDC**   lblbl#        chain     pomfr1                             77
610fMC     lblbl#        chain(n)  pomfr1                             77
CBI0AC                   endif

417j C                   if        not *in77  and
501s C                             pmtrn# = lbtrn# and
417j C                             pmexpd <= today
417j C                   move      *off          goodli
417j C                   move      *on           error
VIPaAC                   eval      dtchk = '2'
VIPaAC                   eval      warn = *on
417j C                   select
417j C                   when      wklcns <> *blanks
417j C                   eval      *in22 = *on
417j C                   eval      *in02 = *on
417j C                   when      wklbl# <> 0
417j C                   eval      *in24 = *on
417j C                   eval      *in04 = *on
417j C                   other
417j C                   eval      *in23 = *on
417j C                   eval      *in03 = *on
417j C                   endsl
417j C                   eval      errmsg = *blanks
417j C                   exsr      zm4002
417j C                   endif
417j C                   endif
417j C                   endif
417j C     endckd        endsr
650jA*
650jA*----------------------------------------------------------------
650jA*
650jA*  ZZCKLICENSE   Check for invalid characters in scanned license.
650jA*
650jAC     zzcklicense   begsr
650jA*
650jAC                   eval      lccnt = 1
650jAC     1             do        15            lccnt
650jAC     valid         check     wklicense     lcpos
650jA*
650jA*  LcPos = 0 - No invalid characters found in license.
650jAC                   if        lcpos = 0
650jAC                   leave
650jAC                   endif
650jA*
650jA*  LcPos > 0 - One of the positions did not have valid value
650jAC                   if        lcpos > 0
650jAC                   eval      wklicense = %replace(' ':wklicense:lcpos:1)
650jAC                   endif
650jAC                   enddo
650jA*
650jAC     endcklicense  endsr
650jA*
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
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   move      *on           cmdtkn
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     C                   select
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
510e *
511e *      F20 - Accept Warning.
530aAC                   if        *inku
511e *
511e *      F20 - Allowed for VIP only
530aDC*                  if        *inku and
530aDC*                            Client = vip
511eAC                   move      *on           ovrrid
511eAC                   else
511eAC                   move      *off          ovrrid
511eAC                   endif
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
     *
     *  Test for F10 - EXCEPTION
     *
     C                   if        *inkj
     C                   eval      cmdtkn = *on
     C                   goto      endcm2
     C                   endif
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm2        endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  ZZCMD3   User defined command keys for screen 3.
409 A*
409 AC     zzcmd3        begsr
409 A*
409 A*  Command keys to check BEFORE verification and update.
409 A*
409 AC                   if        cmdchk = '*BEFORE '

CBI0AC                   if        client = cheney
CBIeA*
CBIeA*  Test for F6 - Disp Z/Verify OverStock List
CBIeA*
CBIeAC                   if        *inkf
CBIeAC                   move      w1whse        whse
CBIeAC                   eval      rtncd = *blanks
CBIeAC                   eval      slot = *blanks
CBIeA*
CBIeAC                   call      @vzlist
CBIeAC                   parm                    whse
CBIeAC                   parm                    lbwhdp
CBIeAC                   parm                    lbitem
CBIeAC                   parm                    lbtrn#
CBIeAC                   parm                    slot
CBIeAC                   parm                    rtncd
CBIeA*
CBIeAC                   if        rtncd = '*ERROR  '
CBIeAC                   move      *on           error
CBIeAC                   eval      errmsg = *blanks
CBIeAC                   eval      errmsg = desc(10)
CBIeAC                   exsr      zm0105
CBIeAC                   goto      endcm3
CBIeAC                   endif
CBIeAC                   if        slot   <> *blanks
CBIeAC                   eval      w3scan =  slot
CBIeAC                   eval      redspl = *on
CBIeAC                   goto      endcm3
CBIeAC                   endif
CBIeAC                   endif
CBI0AC                   endif

650eA*
650eA*  Test for F8 - Slot display
650eA*
650eAC                   if        *inkh
650eA*
650eAC                   exsr      scr10i
650eAC                   move      *on           cmdtkn
650eAC                   goto      endcm3
650eAC                   endif
417iA*
417iA*  Test for F9 - Stage
417iA*
417iAC                   if        *inki
     *
417iA*  Error if not staging total remaining quantity.
     *
417iAC                   if        w3qty <> w3rqty
417iAC                   eval      error = *on
417iAC                   eval      *in27 = *on
417iAC                   eval      *in07 = *on
417iAC                   eval      *in26 = *off
417iAC                   eval      *in06 = *off
417iAC                   eval      errmsg = *blanks
417iAC                   exsr      zm2009
417iAC                   goto      endcm3
417iAC                   endif
417iA*
417mA*  Set key for license
     *
600eDC**                 move      wkpnbr        kylcns
600eAC                   move      wuScanNbr     kylcns
417iAC                   exsr      scr07i
417iAC                   move      *on           cmdtkn
417iAC                   goto      endcm3
417iAC                   endif
409 A*
409 A*  Test for F10 - EXCEPTION
409 A*
409 AC                   if        *inkj
409 AC                   move      *on           cmdtkn
409 AC                   goto      endcm3
409 AC                   endif
415e *
415e *      F20 - Accept Warning.
415e *
415eAC                   if        *inku
415eAC                   move      *on           ovrrid
415eAC                   else
415eAC                   move      *off          ovrrid
415eAC                   endif
409 AC                   endif
409 A*
409 A*  Command keys to check AFTER verification and update.
409 A*
409 AC                   if        cmdchk = '*AFTER  '
409 AC                   endif
409 AC     endcm3        endsr
 15kA*----------------------------------------------------------------
415kA*
415kA*  ZZCMD4   User defined command keys for screen 4.
415kA*
415kAC     zzcmd4        begsr
     *
     *  Command keys to check BEFORE verification and update.
     *
     C                   if        cmdchk = '*BEFORE '
     *
     C                   endif
     *
     *  Command keys to check AFTER verification and update.
     *
     C                   if        cmdchk = '*AFTER  '
     C                   endif
     C     endcm4        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZCMD5   User defined command keys for screen 5.
416dA*
416dAC     zzcmd5        begsr
416dA*
416dA*  Command keys to check BEFORE verification and update.
416dA*
416dAC                   if        cmdchk = '*BEFORE '
510e *
510e *      F20 - Accept Warning.
510e *
415e *      F20 - Allowed for VIP only
     *
511eAC                   if        *inku and
VIP AC                             Client = vip or
JPFaAC                             *inku and
JPFaAC                             Client = palmer
750bAC                             or *inku and
750bAC                             holdrtnplt <> ' '
511eAC                   move      *on           ovrrid
511eAC                   else
511eAC                   move      *off          ovrrid
511eAC                   endif
416dA*
416dAC                   endif
416dA*
416dA*  Command keys to check AFTER verification and update.
416dA*
416dAC                   if        cmdchk = '*AFTER  '
416dAC                   endif
416dAC     endcm5        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZCMD6   User defined command keys for screen 6.
416dA*
416dAC     zzcmd6        begsr
416dA*
416dA*  Command keys to check BEFORE verification and update.
416dA*
416dAC                   if        cmdchk = '*BEFORE '
416dA*
416dAC                   select
416dA*    Test for F9 - Skip current putaway.
     *
416dAC                   when      *inki
416dAC                   move      *on           cmdtkn
416dAC                   move      *on           skip6
416dAC                   exsr      scr06i
416dAC                   endsl
416dA*
416dAC                   endif
416dA*
416dA*  Command keys to check AFTER verification and update.
416dA*
416dAC                   if        cmdchk = '*AFTER  '
416dAC                   endif
416dAC     endcm6        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZCMD7   User defined command keys for screen 7.
417i *
417iAC     zzcmd7        begsr
417i *
417i *  Command keys to check BEFORE verification and update.
417i *
417i C                   if        cmdchk = '*BEFORE '
417i C                   endif
417i *
417i *  Command keys to check AFTER verification and update.
417i *
417i C                   if        cmdchk = '*AFTER  '
417i C                   endif
417iAC     endcm7        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZCMD8   User defined command keys for screen 8.
417i *
417iAC     zzcmd8        begsr
417i *
417i *  Command keys to check BEFORE verification and update.
417i *
417i C                   if        cmdchk = '*BEFORE '
417i C                   endif
417i *
417i *  Command keys to check AFTER verification and update.
417i *
417i C                   if        cmdchk = '*AFTER  '
417i C                   endif
417iAC     endcm8        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  ZZCMDAPT  User defined command keys for aptscrn.
PFCaA*
PFCaAc     zzcmdapt      begsr
PFCaAc*
PFCaA*  Command keys to check BEFORE verification and update.
PFCaAc*
PFCaAc                   if        cmdchk = '*BEFORE '
PFCaAc                   endif
PFCaAc*
PFCaA*  Command keys to check AFTER verification and update.
PFCaAc*
PFCaAc                   if        cmdchk = '*AFTER  '
PFCaAc                   endif
PFCaA*
PFCaAc     endcmdapt     endsr
ISYi *----------------------------------------------------------------
ISYa *
ISYaA*  ZZCMD9A  User defined command keys for screen 9.
ISYa *
ISYaAC     zzcmd9a       begsr
ISYa *
ISYa *  Command keys to check BEFORE verification and update.
ISYa *
ISYa C                   if        cmdchk = '*BEFORE '
ISYa C                   endif
ISYa *
ISYa *  Command keys to check AFTER verification and update.
ISYa *
ISYa C                   if        cmdchk = '*AFTER  '
ISYa C                   endif
ISYaAC     endcm9a       endsr
501tA*
501tA*----------------------------------------------------------------
501tA*
501tA*  ZZCMD9   User defined command keys for screen 9.
501tA*
501tAC     zzcmd9        begsr
501tA*
501tA*  Command keys to check BEFORE verification and update.
501tA*
501tAC                   if        cmdchk = '*BEFORE '
501tAC                   endif
501tA*
501tA*  Command keys to check AFTER verification and update.
501tA*
501tAC                   if        cmdchk = '*AFTER  '
501tAC                   endif
501tA*
501tAC     endcm9        endsr
501tA*
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZCMD10  User defined command keys for screen 10.
650eA*
650eAC     zzcmd10       begsr
650eA*
650eA*  Command keys to check BEFORE verification and update.
650eA*
650eAC                   if        cmdchk = '*BEFORE '
650eA*
650eA*  Test for F4 - Lookup
650eA*
650eA*
650eA*
650eA*
650eA*  Command keys to check AFTER verification and update.
650eA*
650eAC                   if        cmdchk = '*AFTER  '
650eAC                   endif
650eAC                   endif
650eAC     endcm10       endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZCMD11  User defined command keys for screen 11.
650eA*
650eAC     zzcmd11       begsr
650eA*
650eA*  Command keys to check BEFORE verification and update.
650eA*
650eAC                   if        cmdchk = '*BEFORE '
650eA*
650eA*  Test for F4 - Lookup
650eA*
650eA*
650eA*
650eA*
650eA*  Command keys to check AFTER verification and update.
650eA*
650eAC                   if        cmdchk = '*AFTER  '
650eAC                   endif
650eAC                   endif
650eAC     endcm11       endsr
417 A*----------------------------------------------------------------
417 A*
417 A*  ZZENDI  End current Indirect task.
417 A*
417 AC     zzendi        begsr
417 A*
417 A*    Send currect Direct transaction number to ensure that this
417 A*    transaction doesn't get closed by mistake.
     *
600cMC                   eval      @ptrn# = $pttrn#
417 A*
417 AC                   call      @adjtr
417 AC                   parm      '*CLOSEI '    @pcmd
417 AC                   parm                    #job
417 AC                   parm                    @ptrn#
417 AC                   parm      *blanks       @ptask
417 AC                   parm      w1whse        @pwhse
417 AC                   parm      *blanks       @pwhdp
417 AC                   parm      *blanks       @pstyp
417 AC                   parm      0             @pcube
417 AC                   parm      0             @pswgt
417 AC                   parm      0             @ppcs
417 AC                   parm      0             @paisl
417 AC                   parm      0             @pqty1
417 AC                   parm      0             @pqty2
417 AC                   parm      0             @pqty3
417 AC                   parm      '0'           @prte
417 AC                   parm      ' '           @ppo
417 AC                   parm      ' '           @pgrp1
417 AC                   parm      ' '           @pgrp2
417 AC                   parm      ' '           @prtn
417 AC                   parm      ' '           @pmsg
417 A*
417 AC                   endsr
     *----------------------------------------------------------------
     *
RylaA*  ZZEXCPRYL
RylaA*
RylaAC     zzexcpryl     begsr

     C                   eval      $slpicke = '4'
     C                   eval      slpicke = *off
     C                   eval      exwhse = w1whse
     C                   eval      exwhdp = lbwhdp
     C                   eval      exstyp = lbstyp
     C                   eval      exitem = lbitem
     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#
     C                   eval      dsexpd = zzexpd
     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis
     C                   eval      exgdte = lbsdte
     C                   eval      exgtim = lbstim
     *
     C                   if        lbqpck > 999
     C                   eval      exqty = 999
     C                   else
     *
     C                   z-add     lbqpck        exqty
     C                   endif
     *
     C                   eval      exqty2 = *zeros
     C                   eval      exqty3 = *zeros
     C                   eval      excitm = *blanks
     C                   eval      extask = 'PUT'
     C                   eval      exgby = #user
     C                   eval      exuser = *blanks
     C                   select
     C                   when      $slpicke = '4' and warno = *on
     C                   eval      exerid = 'OG-DOVR'
     C                   other
     C                   eval      exerid = 'OH-DOVR'
     C                   endsl
     C                   eval      exesta = '1 '
     C                   eval      excdte = *zeros
     C                   eval      exctim = *zeros
     C                   write     exrec
     C                   eval      warno = *off

     C                   endsr
     *----------------------------------------------------------------
     *
CBIfA*  ZZEXCPCBI
CBIfA*
CBIfAC     zzexcpcbi     begsr

     *    Write an item exception record.

     C                   eval      dspo = lbpo
     C                   eval      dslbl = lblbl#

     C                   eval      exwhse = slwhse
     C                   eval      exwhdp = slwhdp
     C                   eval      exstyp = slstyp
     C                   eval      exitem = slitem

     C                   eval      exfdis = dsfdis
     C                   eval      extdis = dstdis

     C                   eval      exqty  = lbqpck
     C                   eval      exerid = 'FIFOROT'
     C                   eval      extask = 'PUTEMP'

     *    Get todays date.

     C                   move      '*CURCMD '    $cvcmd
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   z-add     $cvd8o        exgdte
     C                   time                    exgtim

     C                   move      #user         exgby
     C                   move      '1 '          exesta

     *    Loop to generate unique timestamp for item exception.

     C     exkey         setll     itmexcp                            79
     C     *in79         doweq     *on
     C                   add       1             exgtim
     C     exkey         setll     itmexcp                            79
     C                   enddo

     C                   write     exrec

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL1   Fill screen 1 fields with info from file.
     *
     C     zzfil1        begsr
     *
610jDC**                 eval      w1lcns = *blanks
610jMC                   eval      w1lcns = $pLicense2
610jMC                   eval      $pLicense2 = ' '
600cDC**                 eval      w1trn# = 0
415cAC                   eval      w1lbl# = 0
640bAC                   eval      w1lbl#b = *blanks
750bAc                   eval      holdrtnplt = ' '
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
610cDC**                 eval      w2tosl = lbdisp
610cMC                   eval      w2tosl = lbdsp2
     C                   eval      w2qty = lbqpck
     C                   z-add     lbtie         w2tie
     C                   eval      w2high = lbhigh
     C                   eval      w2scan = *blanks
640bAC                   eval      w1lbl#b = *blanks
WSTaA*  check for existing license in slot for date rotation
WSTaAC                   if        client = westside
WSTaAc                   eval      w2msg = ' '
WSTaAc                   exsr      zzchkexist
WSTaAc                   endif
     C                   endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  ZZFIL3   Fill screen 3 fields with info from file.
409 A*
409 AC     zzfil3        begsr
409 AC                   eval      w3qty = w3rqty
409 AC                   eval      w3scan = *blanks
610dAC                   eval      w3odsg = *blanks
610dAC                   eval      w3odsg = #odesg

CBI6AC                   eval      w3spcl = *blanks
CBIdAC                   eval      w3expd = *blanks
CBI0AC                   setoff                                       4445
CBI0AC                   if        client = cheney
CBI0AC                   eval      *in44 = *on
CBIdAC                   eval      w3expd = itflgd
CBIgAC                   if        itactv = '99'
CBI6AC                   movel     desc(5)       w3spcl
CBI0AC                   eval      *in45 = *on
CBI6AC                   endif
CBI0AC                   endif

720aA* New Select field and plug slot and qty
720aA /free
720aA     Select;
720aA       when w11slot1s <> ' ';
720aA         w3scan = w11slot1;
720aA         If w11slot1q < 0;
720aA           w11slot1q = w11slot1q * -1;
720aA         If w11slot1q <= w3qty;
720aA           w3qty = w11slot1q;
720aA         endif;
720aA         endif;
720aA         w11slot1s = ' ';
720aA       when w11slot2s <> ' ';
720aA         w3scan = w11slot2;
720aA         If w11slot2q < 0;
720aA           w11slot2q = w11slot2q * -1;
720aA         If w11slot2q <= w3qty;
720aA           w3qty = w11slot2q;
720aA         endif;
720aA         endif;
720aA       when w11slot3s <> ' ';
720aA         w3scan = w11slot3;
720aA         If w11slot3q < 0;
720aA           w11slot3q = w11slot3q * -1;
720aA         If w11slot3q <= w3qty;
720aA           w3qty = w11slot3q;
720aA         endif;
720aA         endif;
720aA       when w11slot4s <> ' ';
720aA         w3scan = w11slot4;
720aA         If w11slot4q < 0;
720aA           w11slot4q = w11slot4q * -1;
720aA         If w11slot4q <= w3qty;
720aA           w3qty = w11slot4q;
720aA         endif;
720aA         endif;
720aA     endsl;
720aA         w11slot1s = ' ';
720aA         w11slot2s = ' ';
720aA         w11slot3s = ' ';
720aA         w11slot4s = ' ';
720aA /end-free
409 AC                   endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  ZZFIL4   Fill screen 4 fields with info from file.
415kA*
415kAC     zzfil4        begsr
     *
417fA*    Retrieve item description.
     *
511cAC                   move      lbitem        gtitem
417fAC                   exsr      zzgeti
415kAC                   eval      w4qty = 0
415kAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZFIL5   Fill screen 5 fields with info from file.
416dA*
416dAC     zzfil5        begsr
416dA*
416dAC                   select
     *
416dA*    License plate scanned - position cursor in plate fld.
     *
416dAC                   when      w5txt = w5txt1
416dAC                   eval      *in02 = *on
     *
416dA*    Label scanned - position cursor in plate fld.
     *
416dAC                   when      w5txt = w5txt2
416dAC                   eval      *in04 = *on
416dAC                   endsl
416fMC                   eval      w5lcns = *blanks
416dAC                   eval      w5lbl# = *zeros
640gAC                   eval      w5lbl#b = *blanks
750bA /free
750bA   if holdrtnplt<> ' ' and oppltl = 'Y';
750bA     // go get data from PLTLCNS
750bA     dow forever = forever;
750bA       exsr zzgetrtnplt;
750bA       if %eof(pltlcns);
750bA         // no more to scan will skip the exfmt on screen5
750bA         leavesr;
750bA       endif;
750bA       if rnlput = 'Y';
750bA         iter;
750bA       endif;
750bA       // load up next license
750bA       if rnltype = 'L';
750bA         w5lcns = rnllcns;
750bA         w5lbl#b= ' ';
750bA       else;
750bA         w5lbl#b= rnlplbl;
750bA         w5lcns = ' ';
750bA       endif;
750cA       w1lcns = w5lcns;
750cA       exsr zzvfylcnsRP;
750cA       if error;
750cA         error = *off;
750cA         w1lcns = ' ';
750cA         w5lcns = ' ';
750cA         iter;
750cA       else;
750bA         leave;
750cA       endif;
750bA     enddo;
750bA
750bA   endif;
750bA /end-free
416dA*
416dAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZFIL6   Fill screen 6 fields with info from file.
416dA*
416dAC     zzfil6        begsr
416dA*
416dA*    Build item description.
     *
416dAC                   eval      w6item = *blanks
416dAC                   eval      $iitem = lbitem
416dAC                   eval      $idesc = itdesc
416dAC                   eval      $ipdsc = itpdsc
416dAC                   eval      $istr = *blanks
416dAC                   call      @fmtit
416dAC                   parm                    $iitem           15
416dAC                   parm                    $idesc           30
416dAC                   parm                    $ipdsc           15
416dAC                   parm                    $istr            70
416dAC                   movel     $istr         w6item
610b C                   movel     $iitem        w6itm
610b C                   movel     $idesc        w6it1
610b C                   move      $idesc        w6it2
610b C                   movel     $ipdsc        w6it3
416dA*
416dAC                   add       1             w6cnt1
416dAC                   eval      w6cnt2 = w5cnt
600eDC**                 move      wkpwhd        $iwhdp
600eAC                   move      wuPckWhdp     $iwhdp
600eDC**                 if        wkpasl > 'ZZZ'
600eAC                   if        wuPckAisl > 'ZZZ'
500jAC                   move      *blanks       $iaisl
500jAC                   else
600eDC**                 move      wkpasl        $iaisl
600eAC                   move      wuPckAisl     $iaisl
500jAC                   endif
600eDC**                 move      wkpdsp        $idisp
600eAC                   move      wuPckDisp     $idisp
416fAC                   eval      $idsp = *zeros
416fAC                   call      @fmtsl
416fAC                   parm                    $iwhdp
416fAC                   parm                    $iaisl
416fAC                   parm                    $idisp
416fAC                   parm                    $idsp
610bAC                   select
610bAC                   when      #lline = '16'
640fDC*                  movel     $iwhdp        w6whdp
640fDC*                  movel     $iaisl        w6aisl
640fDC*                  movel     $idisp        w6disp
640fAC                   movel     $idsp         w6dsp
610bAC                   other
417aMC                   movel     $idsp         w6dsp
610bAC                   endsl
720a *
720aA*  See if any XDK exist.
720aA*
720aAC                   eval      w3oxdk = 'N'
720aAC                   move      'XD'          k3stat
720aAC                   eval      kypick = 'N'
720aAC                   eval      kyitem = lbitem
720aAC     keys3a        chain     slot3
720aAC                   if        %found(slot3)
720aAC                   eval      w3oxdk = 'Y'
720aAC                   endif
     *
740bA*   Get status of USR slot, display special status
740bAC                   eval      w6osts = *blanks
740bAC     keys2         chain     slot2
740bAC                   if        %found(slot2)
740bAC                   if        s_slstat <> 'A '
740bAC                   eval      w6osts = s_slstat
740bAC                   endif
740bAC                   endif
740bA*
     *
     *
640cA*  See if any stock in overflow slot.
640cA*
640cAC                   eval      w3ostk = 'N'
710aAC                   eval      *in42 = *off
640cAC                   move      'A '          k3stat
710dDC*                  eval      k3pick = 'N'
710dMC                   eval      kypick = 'N'
640cAC                   eval      kyitem = lbitem
710dDC*    keys3         setll     slot3
710dMC     keys3a        setll     slot3
640cAC                   dow       forevr = forevr
710dDC*    keys3         reade     slot3                                  79
710dMC     keys3a        reade     slot3                                  79
640cA*
640cAC                   if        *in79
640cAC                   leave
640cAC                   endif
640cA*
640cAC                   if        sldesg = 'BFC'
640cAC                   iter
640cAC                   endif
640cA*
640cAC                   if        not *in79
640cAC                   if        slstk1 > 0  or
640cAC                             slstk2 > 0  or
640cAC                             slstk3 > 0
640cAC                   eval      w3ostk = 'Y'
710aAC                   eval      *in42 = *on
640cAC                   leave
640cAC                   endif
640cAC                   endif
640cAC                   enddo
640cA*
416dAC                   select
     *
416dA*    License plate scanned.
     *
600eDC**                 when      wkptyp = 'P'
600eAC                   when      wuScanType = 'P'
416dAC                   eval      w6txt = w6txt1
     *
416dA*    Label scanned - position cursor in plate fld.
     *
600eDC**                 when      wkptyp = 'L'
600eAC                   when      wuScanType = 'L'
416dAC                   eval      w6txt = w6txt2
416dAC                   endsl
416fMC                   eval      w6nxt# = *blanks
600eDC**                 eval      w6mtch = wkpnbr
600eAC                   eval      w6mtch = wuScanNbr
600jAC                   eval      kypnbr = wuScanNbr
600jAC                   eval      kyptyp = wuScanType
416dA*
416dAC                   endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZFIL7   Fill screen 7 fields with info from file.
417i *
417iAC     zzfil7        begsr
417i C                   exsr      zzgetz
417i C                   move      zone          w7zone
417i C                   eval      w7scan = *blanks
417iAC                   endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZFIL8   Fill screen 8 fields with info from file.
417i *
417iAC     zzfil8        begsr
417i *
417i *  Initialize screen variables
417i *
417i C                   add       1             w8cnt
417i C                   move      zone          w8zone
610bAC                   select
610bAC                   when      #lline = '16'
610b C                   movel     zdesc         w8zds1
610b C                   move      zdesc         w8zds2
610bAC                   other
417i C                   move      zdesc         w8zdsc
610bAC                   endsl
600eDC**                 eval      w8lic# = wkpnbr
600eAC                   eval      w8lic# = wuScanNbr
417i C                   eval      w8qty = w3rqty
417i C                   eval      w8scan = *blanks
417i *
417iAC                   endsr
ISYa *----------------------------------------------------------------
ISYa *
ISYaA*  ZZFIL9A  Fill screen 9a fields with info from file.
ISYa *
ISYaAC     zzfil9a       begsr
ISYa *
ISYa *  Initialize screen variables
ISYa *
ISYa C                   move      *blanks       w9afrom
ISYa C                   if        wotype = *blanks
ISYa C                   move      'S'           w9atype
ISYa C                   else
ISYa C                   move      wotype        w9atype
ISYa C                   endif
ISYa *
ISYaAC                   endsr
501tA*----------------------------------------------------------------
501tA*
501tA*  ZZFIL9   Fill screen 9 fields with info from file.
501tA*
501tAC     zzfil9        begsr
501tA*
501tAC                   eval      w9whdp = $whdp2
501taC                   eval      w9fdis = $fdis2
501tAC                   eval      w9tdis = $tdis2
501tAC                   eval      itminf = *on
501tAC                   eval      lbitem = $titem2
511cAC                   move      lbitem        gtitem
501tAC                   exsr      zzgeti
501tAC                   eval      itminf = *off
501tA*
501tA*      Format item# + description for display.
     *
501tAC                   eval      $iitem = $titem2
501tAC                   eval      $idesc = itdesc
501tAC                   eval      $ipdsc = itpdsc
501tAC                   eval      $istr = *blanks
501tAC                   call      @fmtit
501tAC                   parm                    $iitem
501tAC                   parm                    $idesc
501tAC                   parm                    $ipdsc
501tAC                   parm                    $istr
501tAC                   eval      w9item = $istr
501tAC                   eval      w9qty  = $qrpl2
501tAC                   eval      w9ucod = $ucod2
501tA*
501tAC                   endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZFIL10  Fill screen 10 fields with info from file.
650eA*
650eAC     zzfil10       begsr
650eA*
650eAC                   eval      w10aisle = ' '
650eAC                   endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZFIL11  Fill screen 11 fields with info from file.
650eA*
650eAC     zzfil11       begsr
650eA*
650eA /free
650eA   w11slot1 = ' ';
650eA   w11slot2 = ' ';
650eA   w11slot3 = ' ';
650eA   w11slot4 = ' ';
720aA   w11slot1s = ' ';
720aA   w11slot2s = ' ';
720aA   w11slot3s = ' ';
720aA   w11slot4s = ' ';
720aA   w11slot1q = *zeros;
720aA   w11slot2q = *zeros;
720aA   w11slot3q = *zeros;
720aA   w11slot4q = *zeros;


650eA   setll (w1whse:w10aisle) slot11;
650eA   dow forever = forever;
650eA     reade (w1whse:w10aisle) slot11;
650eA     if %eof(slot11);
650eA       if w11slot1 = ' ';
650eA         w11slot1 = '*NONE';
650eA       endif;
650eA       leavesr;
650eA     endif;
650eA     // include only slstat = 'V'
FSFaA     if client <> Freshsense;
650eA     if s11_slstat <> 'V';
650eA       iter;
650ea     endif;
650eA     if s11_slpick <> 'Y';
650eA       iter;
650ea     endif;
650eA     if s11_slitem <> ' ';
650eA       iter;
650ea     endif;
FSFaA     else;
FSFaA     if w10aisle <> 'XDK';
FSFaA       iter;
FSFaA     endif;
FSFaA     if w10aisle = 'XDK'
FSFaA        and $iitem <> s11_slitem;
FSFaA       iter;
FSFaA     endif;
FSFaA     endif;
650eA     Select;
650eA       when w11slot1 = ' ';
650eA         w11slot1 = s11_sldisp;
720aA         w11slot1q = s11_slstk1 - s11_slpck1;
650eA       when w11slot2 = ' ';
650eA         w11slot2 = s11_sldisp;
720aA         w11slot2q = s11_slstk1 - s11_slpck1;
650eA       when w11slot3 = ' ';
650eA         w11slot3 = s11_sldisp;
720aA         w11slot3q = s11_slstk1 - s11_slpck1;
650eA       when w11slot4 = ' ';
650eA         w11slot4 = s11_sldisp;
720aA         w11slot4q = s11_slstk1 - s11_slpck1;
650eA       other;
650eA         leavesr;
650eA     endsl;
650eA   enddo;
650eA /end-free
650eAC                   endsr
501tA*
417i *----------------------------------------------------------------
417i *
417iA*  ZZGBRK  See if slot is within breakdowns.
417i *
417iAC     zzgbrk        begsr
417i *
417i C     keyas2        setll     stagd2
417i C                   dou       forevr <> forevr
417i C     keyas2        reade     stagd2                                 79
417i C                   if        *in79
417i C                   leave
417i C                   endif
417i *
417i *      See if slot matches criteria.
417i *
417i C                   select
417i *
417i *        Location
417i *
417i C                   when      sdloc2 > 0
417i *
417i C                   if        lbloc >= sdloc1  and
417i C                             lbloc <= sdloc2
417i C                   move      sdzone        zone
417i C                   endif
417i C                   iter
417i *
417i C                   endsl
417i *
417i C                   enddo
417i *
417iAC                   endsr
409 A*----------------------------------------------------------------
409 A*
409 A*  ZZGET3   Get screen 3 info.
409 A*
409 AC     zzget3        begsr
     *
     *  Get first picking slot for item.
     *
415fAC                   if        #bstyp = 'P'
600cMC                             and $pttask <> 'PUTRTN'
415fAC                   eval      $pcmd = '*LAST   '
415fAC                   else
415fAC                   eval      $pcmd = '*FIRST  '
415fAC                   endif
720bA*
720bA*  If F11 pressed to toggle between picks we should
720bA*
720bAc                   if        *inkk
720bAc                   if        $pcmd = '*FIRST'
720bAc                   eval      $pcmd = '*NEXT'
720bAc                   endif
720bAc                   endif
700gA* when putaway is for a breakdown uom first we need to check
700gA* for *each pick slot if one exist it will be used.
700gA* If *each pick slot does not exist we will do normal process
700gAc                   eval      FndEachPickSlt = *off
700gAc                   if        lbutyp <> 'N'
700gA * save the $pcmd for later processing.
700gAc                   eval      save$pcmd = $pcmd
700gA*
700gAC                   call      'GETPSLT'
700gAC                   parm      '*FIRSTEA'    $pcmd             8
700gAC                   parm      w1whse        $pwhse            3 0
700gAC                   parm      #sitem        $pitem           15
700gAC                   parm      *blanks       $pslot           12
700gAC                   parm      *blanks       $paisl            3
700gAC                   parm      *zeros        $ploc             3 0
700gAC                   parm      *zeros        $prlvl            2 0
700gAC                   parm      *blanks       $phand            2
700gAC                   parm      *blanks       $prtn             8
700gA*
700gAC                   move      #owhdp        w3whdp
700gAC                   if        $pslot = '*NONE*  '
700gAC* restore the $pcmd
700gAc                   eval      $pcmd = save$pcmd
700gA*
700gAC                   else
700gAC                   eval      w3tosl = $pslot
700gAc                   eval      FndEachPickSlt = *on
700gAC                   endif
700gAC                   endif
700gAc                   if        lbutyp <>  'N' and
700gAC                             FndEachPickSlt = *off
700gAc                             or lbutyp = 'N'
415fAC                   call      'GETPSLT'
415fAC                   parm                    $pcmd             8
415fAC                   parm      w1whse        $pwhse            3 0
417tMC                   parm      #sitem        $pitem           15
720bDC*                  parm      *blanks       $pslot           12
720bMC                   parm      w3tosl        $pslot           12
416dAC                   parm      *blanks       $paisl            3
416dAC                   parm      *zeros        $ploc             3 0
416dAC                   parm      *zeros        $prlvl            2 0
416dAC                   parm      *blanks       $phand            2
415fAC                   parm      *blanks       $prtn             8
415fA*
415fAC                   move      #owhdp        w3whdp
416rAC                   if        $pslot = '*NONE*  '
700eDC*                  eval      w3tosl = 'None'
700eMC                   eval      w3tosl = 'None' + ' / ' + (#BSTYP)
416rAC                   else
415fAC                   eval      w3tosl = $pslot
416rAC                   endif
700gAC                   endif
      *
CBIcA* Try to display Special Designation slot.
CBIcAC                   select
CBIcAC                   when      client = cheney
CBIcD **                 if        $pslot = '*NONE*  '
CBIcAC                   if        sdesig = *on
CBIcAC                   eval      w3tosl = dssdsp
CBIcAC                   else
CBIcAC                   if        $pslot = '*NONE*  '
CBIcAC                   eval      w3tosl = 'None'
CBIcAC                   endif
CBIcAC                   endif
CBIcAC                   endsl
720a *
720aA*  See if any XDK exist.
720aA*
720aAC                   eval      w3oxdk = 'N'
720aAC                   move      'XD'          k3stat
720aAC                   eval      kypick = 'N'
720aAC                   eval      kyitem = lbitem
720aAC     keys3a        chain     slot3
720aAC                   if        %found(slot3)
720aAC                   eval      w3oxdk = 'Y'
720aAC                   endif
     *
740bA*   Get status of USR slot, display special status
740bAC                   eval      w3osts = *blanks
740bAC     keys2         chain     slot2
740bAC                   if        %found(slot2)
740bAC                   if        s_slstat <> 'A '
740bAC                   eval      w3osts = s_slstat
740bAC                   endif
740bAC                   endif
740bA*
     *
414eA*  See if any stock in overflow slot.
414eA*
414eAC                   eval      w3ostk = 'N'
710aAC                   eval      *in42 = *off
700gAc                   if        FndEachPickSlt = *off
414eAC                   move      'A '          k3stat
414eAC                   eval      k3pick = 'N'
414eAC     keys3         setll     slot3
414eAC                   dow       forevr = forevr
414eAC     keys3         reade     slot3                                  79
414eA*
414eAC                   if        *in79
414eAC                   leave
414eAC                   endif
600gA*
600gAC                   if        sldesg = 'BFC'
600gAC                   iter
600gAC                   endif
414eA*
414eAC                   if        not *in79
414eAC                   if        slstk1 > 0  or
414eAC                             slstk2 > 0  or
414eAC                             slstk3 > 0
414eAC                   eval      w3ostk = 'Y'
710aAC                   eval      *in42 = *on
414eAC                   leave
414eAC                   endif
414eAC                   endif
414eAC                   enddo
700gAc                   endif
     *
     C                   z-add     0             svexpd               80
501g C                   eval      pswhse = 0
501g C                   eval      pspo = *blanks
501g C                   eval      psseq = 0
501g C                   eval      psitem = *blanks
501g C                   eval      psexpd = 0
501g C                   eval      psmfgd = 0

CBI0AC                   if        client = cheney
CBIiA * Get PO # from LABEL file to load POMFR2 key below,
CBIiA * LABEL7 file does not have "Lbpo" field in it.

CBIiAC     lblbl#        chain(n)  label

750bDC*    mfr2ky        chain(n)  pomfr2                             79
750bMC     mfr3ky        chain(n)  pomfr3                             79
CBIiAC                   else
500eMC     lblbl#        chain(n)  pomfr1                             79
CBI0AC                   endif

     C                   if        not *in79
501sAC                             and pmtrn# = lbtrn#
     C                   eval      svexpd = pmexpd
500b C                   eval      pswhse = pmwhse
500b C                   eval      pspo = pmpo
500b C                   eval      psseq = pmseq
500b C                   eval      psitem = pmitem
500b C                   eval      psexpd = pmexpd
500b C                   eval      psmfgd = pmmfgd
     C                   endif
     *
     *   Save label record to create new label rec if needed.
     *
     C     lblbl#        chain(n)  label                              79
     C                   if        not *in79
     C                   z-add     lbwhse        sbwhse
     C                   move      lbwhdp        sbwhdp
     C                   eval      sbpseq = 0
     C                   eval      sbqryf = 0
     C                   movel     '*MANUAL'     sbdsp2
     C                   move      lbitem        sbitem
     C                   z-add     lbpbat        sbpbat
     C                   eval      sbutyp = lbutyp
     C                   move      lbucod        sbucod
     C                   z-add     lbucub        sbucub
     C                   z-add     lbuwgt        sbuwgt
     C                   z-add     lbseq         sbseq
     C                   move      lbpo          sbpo
     C                   z-add     lbord         sbord
     C                   eval      sbtie = 0
     C                   eval      sbhigh = 0
     C                   eval      sbgrp1 = lbgrp1
     C                   eval      sbgrp2 = lbgrp2
     C                   eval      sbtype = lbtype
     C                   z-add     lbpal#        sbpal#
     C                   z-add     lbtrn#        sbtrn#
     C                   z-add     lbrdte        sbrdte
     C                   eval      sbstat = lbstat
     C                   endif
     *
409 AC                   endsr
415kA*----------------------------------------------------------------
415kA*
415kAC     zzget4        begsr
415kAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZGET5   Get screen 5 info.
416dA*
416dAC     zzget5        begsr
416dAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZGET6   Get screen 6 info.
416dA*
416dAC     zzget6        begsr
416dAC                   eval      nomore = *off
416dA*
416dAC     #top6         tag
600eDC**   pkkey1        reade     workput1                        79
600jMC     wkkey2p       reade     workUsr5                               79
416dA*
416dAC                   select
     *
416dA*    EOF reached, See if any records left for user.
     *
416dAC                   when      *in79
416dA*
600eDC**   pkkey1        setll     workput1                        79
600jMC     wkkey2p       setll     workUsr5                               79
416dAC                   select
     *
416dA*    Records found - Start over at the top.
     *
416dAC                   when      *in79
416dAC                   eval      w6cnt1 = *zeros
417dAC                   move      *off          skip6
416dAC                   goto      #top6
416dA*
416dA*    No records found - End putaway.
     *
416dAC                   when      not *in79
416dAC                   move      *on           nomore
416dAC                   endsl
416dA*
416dA*    Record read, find matching label record.
     *
416dAC                   when      not *in79
416dA*
416dA*    Retrieve label record for item information.
     *
600eDC**                 z-add     wkptrn        wotrn#
600eAC                   z-add     wuTrn#        wotrn#
416dAC     lbky7a        setll     label7
416dAC     lbky7a        reade     label7                                 79
416dA*
416dAC                   endsl
416dA*
416dAC                   endsr
417i *----------------------------------------------------------------
417i *
417i *  ZZGET8   Get screen 8 info.
417i *
417i C     zzget8        begsr
     *
     *   Get next work record.
     *
     C                   eval      w8cnt = 0
     *
     C                   endsr

600eA*----------------------------------------------------------------
600eA*  getcurrstamp  Get current timestamps
600eA*----------------------------------------------------------------
600eA
600eAC     zzgetcurrstampbegsr

     C                   callp     getmicrotime(currstampuc:currstampsys)
     C     currstampsys  adddur    bfcoffset:*H  currstamploc

     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZGETI   Get item description and pack description.
     *
     C     zzgeti        begsr
416dAC     itminf        cabeq     *on           #geti
     *
     *  LABEL7 file is a Join file with PIRITEM and hence, no need
     *  to chain to that file.
     *
     C                   eval      w2item = *blanks
409aAC                   eval      w3item = *blanks
415kAC                   eval      w4item = *blanks
417iAC                   eval      w8item = *blanks
ISYaAC                   eval      w9aitem = *blanks
     C                   eval      $iitem = lbitem
     C                   eval      $idesc = itdesc
     C                   eval      $ipdsc = itpdsc
     C                   eval      $istr = *blanks
     C                   call      @fmtit
     C                   parm                    $iitem
     C                   parm                    $idesc
     C                   parm                    $ipdsc
     C                   parm                    $istr
     C                   movel     $istr         w2item
409aAC                   movel     $istr         w3item
415kAC                   movel     $istr         w4item
417iAC                   movel     $istr         w8item
ISYaAC                   movel     $istr         w9aitem
610bA*
610b C                   movel     $iitem        w2itm
610b C                   movel     $idesc        w2it1
610b C                   move      $idesc        w2it2
610b C                   movel     $ipdsc        w2it3
610b C                   movel     $iitem        w3itm
610b C                   movel     $idesc        w3it1
610b C                   move      $idesc        w3it2
610b C                   movel     $ipdsc        w3it3
610b C                   movel     $iitem        w4itm
610b C                   movel     $idesc        w4it1
610b C                   move      $idesc        w4it2
610b C                   movel     $ipdsc        w4it3
610b C                   movel     $iitem        w6itm
610b C                   movel     $idesc        w6it1
610b C                   move      $idesc        w6it2
610b C                   movel     $ipdsc        w6it3
610b C                   movel     $iitem        w8itm
610b C                   movel     $idesc        w8it1
610b C                   move      $idesc        w8it2
610b C                   movel     $ipdsc        w8it3
610b C                   movel     $iitem        w9itm
610b C                   movel     $idesc        w9it1
610b C                   move      $idesc        w9it2
610b C                   movel     $ipdsc        w9it3
511bA*
511bAC                   move      lbitem        gtitem           15
412 A*
412 A*  Get item record.  Yes, the LABEL7 file contains item information,
412 A*    but it does not contain the item type field ITTYPE.
412 A*
416dAC     #geti         tag
412 AC     keyit         chain     piritem                            79
412 AC                   if        *in79
412 AC                   eval      ittype = *blanks
412 AC                   endif
CBIcAC                   if        client = cheney
CBIcAC     itdesg        chain     desigsp                            79
CBIcAC                   if        *in79 = *off
CBIcAC                   eval      sdesig = *on
CBIcAC                   else
CBIcAC                   eval      sdesig = *off
CBIcAC                   eval      dsscde = *blanks
CBIcAC                   eval      dssdsp = *blanks
CBIcAC                   endif
CBIcAC                   endif
412 A*
412 A*  Save information about item being received (Item that was ordered)
412 A*
412 AC                   eval      #otype = ittype
412 AC                   move      lbitem        #oitem
412CAC                   move      itwhdp        #owhdp
412 AC                   move      itdesc        #odesc
412 AC                   move      itpdsc        #opdsc
412 AC                   move      lbitem        #bitem
417tAC                   move      lbitem        #sitem
412 AC                   eval      #bdesc = itdesc
412 AC                   eval      #bpdsc = itpdsc
414bAC                   move      itdesg        #odesg
415fAC                   eval      #bitem = ititem
417tAC                   eval      #sitem = ititem
415fAC                   eval      #bstyp = itstyp
412 A*
412 A*  If Contract, Alias or SSB Item
412 A*   Then verify Base item exists.
412 A*
412 AC                   if        ittype = 'C'  or
412 AC                             ittype = 'A'  or
412 AC                             ittype = 'S'
412 A*
412 AC                   call      'GETBASE'
412 AC                   parm      lbwhse        $gwhse            3 0
511bMC                   parm      gtitem        $gitem           15
412 AC                   parm      ' '           #bitem
412 AC                   parm                    #bityp            1
412 AC                   parm                    #bdesc           30
412 AC                   parm                    #bpdsc           15
412 AC                   parm                    #bwhdp            5
412 AC                   parm                    #bstyp            1
412 AC                   parm                    #bum              2
412 AC                   parm                    #bum2             2
412 AC                   parm                    #bumq2            3 0
412 AC                   parm                    #bum3             2
412 AC                   parm                    #bumq3            3 0
412 AC                   parm      ' '           #bcitm           15
412 AC                   parm                    #bctyp            1
412 AC                   parm                    #bcdsc           30
412 AC                   parm                    #bcpds           15
412 AC                   parm                    #bcwdp            5
412 AC                   parm                    #bcstp            1
412 AC                   parm                    #bcum             2
412 AC                   parm                    #bcum2            2
412 AC                   parm                    #bcuq2            3 0
412 AC                   parm                    #bcum3            2
412 AC                   parm                    #bcuq3            3 0
412 AC                   parm                    #brtn             8
412 A*
511bAC                   if        #bityp = 'C'  or
511bAC                             #bityp = 'A'  or
511bAC                             #bityp = 'S'
511bAC                   eval      gtitem = #bitem
511bAC                   goto      #geti
511bAC                   endif
412 A*
412 AC                   endif
412 A*
417tACSR                 call      @getsi
417tACSR                 parm      lbwhse        $gwhse            3 0
417tACSR                 parm      lbitem        $gitem           15
417tACSR                 parm      ' '           #sitem           15
417tACSR                 parm                    #sityp            1
417tACSR                 parm                    #sdesc           30
417tACSR                 parm                    #spdsc           15
417tACSR                 parm                    #srtn            10
417tACSR                 parm                    #smsg            60
     C                   endsr
600cA*----------------------------------------------------------------
600cA*
600cA*  ZZGETT   Get transaction.
600cA*
600cAC     zzgett        begsr

     C                   exsr      clr$pirtran
     C                   eval      $pttrn#u = *on
     C                   eval      $pttrn#  = gttrn#
     C                   eval      $dricommand = '*PIRTRAN'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
510hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      trnFound = *off
     C                   else
     C                   eval      trnFound = *on
     C                   endif
     C                   eval      error = *off

     C                   endsr

417i *----------------------------------------------------------------
417i *
417i *  ZZGETZ   Get zone for put away slot or pick slot.
417i *
417i C     zzgetz        begsr
417i *
417i *  If manual putaway then get first pick slot for item.
417i *     If no pick slot exists, get first overflow slot.
417i *     If no overflow slot exists, use item's dept and stype.
417i *
417i C                   if        lbdsp2 = '*MANUAL'
417i *
417i C                   eval      found = *off
417i C                   move      'A '          k3stat
417i C                   eval      k3pick = 'Y'
417i C     keys3         setll     slot3
417i C     keys3         reade     slot3                                  79
417i C                   if        not *in79
640eAC                             and sldesg <> 'BFC'
417i C                   eval      found = *on
417i C                   eval      lbdisp = sldisp
417i C                   eval      lbwhdp = slwhdp
417i C                   eval      lbstyp = slstyp
417i C                   eval      lbaisl = slaisl
417i C                   eval      lbloc = slloc
417i C                   endif
417i C                   if        found = *off
417i C                   move      'A '          k3stat
417i C                   move      'N'           k3pick
417i C     keys3         setll     slot3
417i C     keys3         reade     slot3                                  79
417i C                   if        not *in79
640eAC                             and sldesg <> 'BFC'
417i C                   move      *on           found
417i C                   eval      lbdisp = sldisp
417i C                   eval      lbwhdp = slwhdp
417i C                   eval      lbstyp = slstyp
417i C                   eval      lbaisl = slaisl
417i C                   eval      lbloc = slloc
417i C                   endif
417i C                   if        found = *off
417i C                   eval      lbwhdp = itwhdp
417i C                   eval      lbstyp = itstyp
417i C                   endif
417i C                   endif
417i *
417i C                   endif
417i *
417i *    See if there is a global dept record.
417i *
417i C     keywdp        setll     stagd2                                 78
417i C                   if        *in78
417i C     keywdp        reade     stagd2                                 78
417i C                   eval      wdpflg = *on
417i C                   move      sdzone        kyzone
417i C                   move      sdzone        wdpzon
417i C                   else
417i C                   eval      wdpflg = *off
417i C                   endif
417i *
417i *    See if there is a global section record.
417i *
417i C     keystp        setll     stagd2                                 78
417i C                   if        *in78
417i C     keystp        reade     stagd2                                 78
417i C                   eval      stpflg = *on
417i C                   move      sdzone        stpzon
417i C                   move      sdzone        kyzone
417i C                   else
417i C                   eval      stpflg = *off
417i C                   endif
417i *
417i *    See if there is a global aisle record.
417i *      Also, see if there are any futher breakdown records.
417i *
417i C     keyasl        setll     stagd2                                 78
417i C                   if        *in78
417i C     keyasl        reade     stagd2                                 78
417i C                   eval      aslflg = *on
417i C                   move      sdzone        aslzon
417i C                   move      sdzone        kyzone
417i C                   else
417i C                   eval      aslflg = *off
417i C                   endif
417i C     keyas2        reade     stagd2                                 76
417i C                   if        not *in76
417i C                   eval      brkflg = *on
417i C                   else
417i C                   eval      brkflg = *off
417i C                   endif
417i *
417i *    Determine zone for slot.
417i *
417i C                   exsr      zzgzon
417i *
417i C                   endsr
rylaA*----------------------------------------------------------------
rylaA*
rylaA*  ZZGETP   Get pick slot.
rylaA*
rylaAC     zzgetp        begsr
rylaA*
rylaAC                   move      'A '          k3stat
rylaAC                   eval      k3pick = 'Y'
rylaAC                   eval      zzexpd = *zeros
rylaAC     keys3         setll     slot3
rylaAC                   dow       forevr = forevr
rylaAC     keys3         reade     slot3                                  79
rylaA*
rylaAC                   select
rylaAC                   when      %eof(slot3)
rylaAC                   leave
rylaAC                   other
rylaA*
rylaAC                   if        zzexpd = *zeros
rylaAC                             or slexpd > zzexpd
rylaAC                   eval      zzexpd = slexpd
rylaAC                   endif
rylaA*
rylaAC                   endsl
rylaA*
rylaAC                   enddo
rylaA*
rylaAC                   endsr
417i *----------------------------------------------------------------
417i *
417i *  ZZGZON  Determine zone for slot.
417i *
417i C     zzgzon        begsr
417i C                   eval      zone = *blanks
417i *
417i *   Records with a level or location range defined are the
417i *   highest order of precedence.  If any records exist,
417i *   see if we find a match.  If we do, we have our zone so
417i *   we can leave.  Otherwise, we keep searching.
417i *
417i C                   if        brkflg = *on
417i C                   exsr      zzgbrk
417i C     zone          cabne     *blanks       endget
417i C                   endif
417i *
417i *   Now we move on to global definitions.  These are
417i *   searched in order of precedence.  When we find a
417i *   match we have our zone and can leave.
417i *
417i *      Entire aisle.
417i *
417i C                   if        aslflg = *on
417i C                   move      aslzon        zone
417i C                   goto      endget
417i C                   endif
417i *
417i *      Entire section.
417i *
417i C                   if        stpflg = *on
417i C                   move      stpzon        zone
417i C                   goto      endget
417i C                   endif
417i *
417i *      Entire department.
417i *
417i C                   if        wdpflg = *on
417i C                   move      wdpzon        zone
417i C                   goto      endget
417i C                   endif
417i *
417i C     endget        endsr
     *----------------------------------------------------------------
     *
     *  ZZIDLE   Create and Start an Idle task.
     *
410 AC     zzidle        begsr
600cDC**                 call      'PIRTRN#'
600cDC**                 parm                    pttrn#
600cDC**                 eval      ptstat = '2'
600cDC**                 eval      pttask = 'IDLE  '
600cDC**                 eval      t#task = 'IDLE  '
600cDC**   tkkey         chain     task                               77
600cDC**                 eval      ptcat = tkcat
600cDC**                 eval      ptsub = tksub
600cDC**                 select
600cDC**                 when      tktlvl = 'S'
600cDC**                 eval      ptwhse = w1whse
600cDC**                 move      w1whdp        ptwhdp
600cDC**                 move      w1styp        ptstyp
600cDC**                 when      tktlvl = 'D'
600cDC**                 eval      ptwhse = w1whse
600cDC**                 move      w1whdp        ptwhdp
600cDC**                 eval      ptstyp = *blanks
600cDC**                 other
600cDC**                 eval      ptwhse = w1whse
600cDC**                 eval      ptwhdp = *blanks
600cDC**                 eval      ptstyp = *blanks
600cDC**                 endsl
600cDC**                 move      w1shft        ptshft
600cDC**                 move      w1crew        ptcrew
600cDC**                 eval      ptemp# = w1emp#
600cDC**                 eval      ptcube = 0
600cDC**                 eval      ptswgt = 0
600cDC**                 eval      ptpcs = 0
600cDC**                 eval      ptaisl = 0
600cDC**                 eval      ptqty1 = 0
600cDC**                 eval      ptqty2 = 0
600cDC**                 eval      ptqty3 = 0
600cDC**                 eval      $cvcmd = '*CURCMD '
600cDC**                 call      @cvtdt
600cDC**                 parm                    $cvtdt
600cDC**                 eval      ptgdte = $cvd8o
600cDC**                 time                    ptgtim
600cDC**
600cDC**   User canceled out of putaway, use putaway transaction
600cDC**   start date/time for IDLE task start date/time.
600cDC**
600cDC**                 if        usestr = '*YES'
600cDC**                 eval      ptsdte = trndte
600cDC**                 eval      ptstim = trntim
600cDC**                 else
600cDC**                 eval      ptsdte = $cvd8o
600cDC**                 time                    ptstim
600cDC**                 endif
600cDC**                 eval      ptedte = 0
600cDC**                 eval      ptetim = 0
600cDC**                 eval      ptetyp = *blanks
600cDC**                 eval      ptcdte = 0
600cDC**                 eval      ptctim = 0
600cDC**                 eval      ptdmin = 0
600cDC**                 eval      ptimin = 0
600cDC**                 eval      ptrtpo = *blanks
600cDC**                 write     ptrec                                79
600cDC**                 if        *in79
600cDC**                 move      '1'           error
600cDC**                 exsr      zm71
600cDC**                 goto      endidl
600cDC**                 endif
     *
600cA*    User canceled out of putaway, use putaway transaction
600cA*    start date/time for IDLE task start date/time.
600cA*
600cAC                   if        usestr = '*YES'
600cAC                   eval      @pdate = trndte
600cAC                   eval      @ptime = trntim
600cAC                   else
600cAC                   eval      @pdate = 0
600cAC                   eval      @ptime = 0
600cAC                   endif
600cA
600cAC                   call      'ADJTRAN2'
600cAC                   parm      '*CRTSTRT'    @pcmd2
600cAC                   parm                    #pgm
600cAC                   parm      '*INTER'      @ptype
600cAC                   parm      0             @ptrn#
600cAC                   parm      'IDLE'        @ptask
600cAC                   parm      w1whse        @pwhse
600cAC                   parm                    @pwhdp
600cAC                   parm                    @pstyp
600cAC                   parm                    @pcube
600cAC                   parm                    @pswgt
600cAC                   parm                    @ppcs
600cAC                   parm                    @paisl
600cAC                   parm                    @pqty1
600cAC                   parm                    @pqty2
600cAC                   parm                    @pqty3
600cAC                   parm                    @prte
600cAC                   parm                    @ppo
600cAC                   parm                    @pgrp1
600cAC                   parm                    @pgrp2
600cAC                   parm                    @pdate
600cAC                   parm                    @ptime
600dMC                   parm      #curruser     @puser
600cAC                   parm                    @prtn
600cAC                   parm                    @pmsg

410 AC     endidl        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     C                   eval      $lprg = #prog
     C                   eval      $cvprg = #prog
410 AC                   move      *off          forevr
411 A*
411 A*  Define save fields for different item types.
411 A*
411 AC                   eval      #otype = *blanks
     *
     *  Define key for LICENSE file.
     *
     C     likey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1lcns
416dAC     likey2        klist
416dAC                   kfld                    w1whse
416dAC                   kfld                    kylcns
     *
     *  Define partial key for LABEL7 file.
     *
     C     lbkey7        klist
600cMC                   kfld                    $pttrn#
416dAC     lbky7a        klist
416dAC                   kfld                    wotrn#
     *
412 A*  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    lbwhse
511bMC                   kfld                    gtitem
511bDC*                  kfld                    lbitem
600cD**
600cD**  Define key for PIRTRAN file.
600cD**
600cD**    ptkey         klist
600cD**                  kfld                    wotrn#
     *
221 A*     OPTIONS
221 A*
221 AC     opkey         klist
221 AC                   kfld                    w1whse
221 AC                   kfld                    ocode
     *
414aA*  Define key for options file, System values.
414aA*
414aAC     optsky        klist
414aAC                   kfld                    kywhse
414aAC                   kfld                    opcode
414aA*
640aA*
640aA*  Define full key for SLOT2 file.
640aA*
640aAC     keys2         klist
640aAC                   kfld                    w1whse
640aAC                   kfld                    wuusrwhdp
640aAC                   kfld                    wuusrdisp
409 A*
SGC A*  Define partial key for SLOT2 file.
SGC A*
SGC AC     tokey1        klist
SGC AC                   kfld                    w1whse
SGC AC                   kfld                    lbwhdp
409 A*
409 A*  Define partial key for SLOT3 file.
409 A*
409 AC     keys3         klist
409 AC                   kfld                    w1whse
417tMC                   kfld                    #sitem
409 AC                   kfld                    k3stat
409 AC                   kfld                    k3pick
510hA*
510hAC     keys3a        klist
510hAC                   kfld                    w1whse
510hMC                   kfld                    kyitem
510hAC                   kfld                    k3stat
510hAC                   kfld                    kypick
414aA*
414aAC     keys3c        klist
414aAC                   kfld                    w1whse
417tMC                   kfld                    #sitem
640aA*
409 AC     tokey         klist
409 AC                   kfld                    w1whse
409 AC                   kfld                    lbwhdp
409 AC                   kfld                    w3scan
409 A*
417rAC     slkey         klist
417rAC                   kfld                    w1whse
417rAC                   kfld                    lbwhdp
417rAC                   kfld                    w2scan
415cA*
415cA*  Define partial key for LABELNK1 file.
415cA*
415cAC     llkey1        klist
415cAC                   kfld                    wolbl#
415cA*
415cA*  Define  key for LABELNK1 file.
415cA*
415cAC     llkey2        klist
415cAC                   kfld                    wolbl#
415cAC                   kfld                    $ltrn2
415hA*
415hA*  Define key for ITEMMSC file.
415hA*
415hAC     itkey         klist
415hAC                   kfld                    w1whse
417tMC                   kfld                    #sitem
CBIfA*
CBIfA*  Define key for ITMEXCP file.
CBIfA*
CBIfAC     exkey         klIST
CBIfAC                   kfld                    exwhse
CBIfAC                   kfld                    exwhdp
CBIfAC                   kfld                    exstyp
CBIfAC                   kfld                    exitem
CBIfAC                   kfld                    exgdte
CBIfAC                   kfld                    exgtim
CBIiA*
CBIiA*  Define key for POMFR2 file.
CBIiA*
CBIiAC     mfr2ky        klist
CBIiAC                   kfld                    lbpo
CBIiAC                   kfld                    lblbl#
750bA*
750bA*  Define key for POMFR3 file.
750bA*
750bAC     mfr3ky        klist
750bAC                   kfld                    lbwhse
750bAC                   kfld                    lbpo
750bAC                   kfld                    lblbl#
ISYaA*
ISYaA*  Define key for DOCDOOR file.
ISYaA*
ISYaAC     dockey        klist
ISYaAC                   kfld                    w1whse
ISYaMC                   kfld                    w9door
ISYaA*
ISYaA*  Define key for STAGH file.
ISYaA*
ISYaAC     stgkey        klist
ISYaAC                   kfld                    w1whse
ISYaMC                   kfld                    w9stag
417i *
417iA*  Define search keys for zone lookup
417i *
417iAC                   eval      kystyp = *blanks
417iAC                   eval      kyaisl = *blanks
417iAC                   eval      kyloc1 = 0
417iAC                   eval      kyloc2 = 0
417iA*
417iA*  Define fields used by zone lookup
417iA*
417iAC                   move      *off          wdpflg
417iAC                   move      *off          stpflg
417iAC                   move      *off          aslflg
417iAC                   move      *off          brkflg
417iA*
417iAC                   eval      wdpzon = *blanks
417iAC                   eval      stpzon = *blanks
417iAC                   eval      aslzon = *blanks
417iA*
417iA*  Define key for STAGH file.
417iA*
417iAC     keyzh         klist
417iAC                   kfld                    w1whse
417iAC                   kfld                    zone
417iA*
417iAC     keywdp        klist
417iAC                   kfld                    w1whse
417iAC                   kfld                    lbwhdp
417iAC                   kfld                    kystyp
417iAC                   kfld                    kyaisl
417iAC                   kfld                    kyloc1
417iAC                   kfld                    kyloc2
417iA*
417iA*     Section
417iA*
417iAC     keystp        klist
417iAC                   kfld                    w1whse
417iAC                   kfld                    lbwhdp
417iAC                   kfld                    lbstyp
417iAC                   kfld                    kyaisl
417iAC                   kfld                    kyloc1
417iAC                   kfld                    kyloc2
417iA*
417iA*     Aisle
417iA*
417iAC     keyasl        klist
417iAC                   kfld                    w1whse
417iAC                   kfld                    lbwhdp
417iAC                   kfld                    lbstyp
417iAC                   kfld                    lbaisl
417iAC                   kfld                    kyloc1
417iAC                   kfld                    kyloc2
417iA*
417iA*     Further break down
417iA*
417iAC     keyas2        klist
417iAC                   kfld                    w1whse
417iAC                   kfld                    lbwhdp
417iAC                   kfld                    lbstyp
417iAC                   kfld                    lbaisl
     *
     *
     *  Convert today's date into century format.
     *
600dAC                   eval      $cvcmd = '*CURCMD '
610aAC                   exsr      zzzdte
600dDC**                 eval      $cvcmd = '*CURCMD '
600dDC**                 call      @cvtdt
600dDC**                 parm                    $cvtdt
600dDC**                 eval      today = $cvd8o
409 A*
409 A*
     *
     *    - Get default warehouse for the user.
     *
     C                   call      'GETWHSE'
600dMC                   parm                    #curruser
     C                   parm      0             #whse             3 0
     *
     C                   eval      w1whse = #whse
417oAC                   eval      svwhse = #whse
     *
     *    - Get employee number, default dept and section.
     *
410 AC     uskey         klist
600dMC                   kfld                    #curruser
410 A*
410 AC     uskey         chain     piruser                            79
410 AC                   if        not *in79
410 AC                   z-add     usemp#        w1emp#
410 AC                   move      uswhdp        w1whdp
410 AC                   move      usstyp        w1styp
410 AC                   move      usshft        w1shft
410 AC                   move      uscrew        w1crew
410 AC                   else
410 AC                   eval      w1emp# = 0
410 AC                   eval      w1whdp = *zeros
410 AC                   eval      w1styp = *zeros
410 AC                   eval      w1shft = *zeros
410 AC                   eval      w1crew = *zeros
410 AC                   endif
     *
410 AC     tkkey         klist
410 AC                   kfld                    t#task
600cD**
600cD**  Define key for PIRTRAN2 file.
600cD**
600cD**    ptke22        klist
600cD**                  kfld                    w1emp#
600cD**                  kfld                    stdate
600cD**                  kfld                    sttime
600cD**
600cD**  Define partial key for PIRTRAN2 file.
600cD**
600cD**    ptkey2        klist
600cD**                  kfld                    w1emp#
600cD**                  kfld                    stdate
600cD **
600cD ** Define key for PIRTRAN1 file.
600cD **
600cDC**   ptkey1        klist
600cDC**                 kfld                    w1emp#
600cDC**                 kfld                    kystat
416dA*
416dA*  Define key for WORKPUT file.
416dA*
416dAC     pkkey         klist
600dMC                   kfld                    #curruser
416dAC     pkkya         klist
600dMC                   kfld                    #curruser
600eAC                   kfld                    wuscannbr
600eAC                   kfld                    wuScanType
600eDC**                 kfld                    wkpnbr
600eDC**                 kfld                    wkptyp
416dA*
416dA*  Define key for WORKPUT1 file.
416dA*
416dAC     pkkey1        klist
600dMC                   kfld                    #curruser
416dA*
600jM*  Define full key for WORKUSR2 file.
416dA*
600eAC     wkkey2        klist
600eaC                   kfld                    wkRecType
600dMC                   kfld                    w1emp#
600jAC                   kfld                    w1whse
600jAC                   kfld                    kypnbr
600jAC                   kfld                    kyptyp
610mAC                   kfld                    kypitm
600jA*  Define partial key for WORKUSR2 file.
600jA*
600jAC     wkkey2p       klist
600jAC                   kfld                    wkRecType
600jAC                   kfld                    w1emp#
416dA*
416dA*  600eD Delete Define key for WORKPUT2 file.
416dA*  Define key for WORKUSR8 file.
416dA*
416dAC     pkkey2        klist
610kAC                   kfld                    kyWhse
610kAC                   kfld                    kypnbr
610kAC                   kfld                    kyptyp
610kDC*                  kfld                    wuWhse
610kDC*                  kfld                    wuScanNbr
610kDC*                  kfld                    wuScanType
600eDC**                 kfld                    kypnbr
600eDC**                 kfld                    kyptyp
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
600bAC                   eval      currRoutine = 'zzinz2'
600bAC                   exsr      phpgmV1V2V3s
610bA*
610bA*   Get screen size being used.
610bA*
610bAC                   call      'PIRRFSCR'
610bAC                   parm      '*GET'        #lcmd             8
610bAC                   parm                    #lline            2
610bAC                   parm                    #lcol             3
501uA *
501uA * Get employee options.
501uA *
501uAC                   call      'GETUSER'
600dMC                   parm      #curruser     e$code           10
501uAC                   parm                    e$whse            3 0
501uAC                   parm                    e$emp#            5 0
501uAC                   parm                    e$fnam           15
501uAC                   parm                    e$init            1
501uAC                   parm                    e$lnam           20
501uAC                   parm                    e$whdp            5
501uAC                   parm                    e$styp            1
501uAC                   parm                    e$shft            6
501uAC                   parm                    e$crew            6
501uAC                   parm                    e$nhrs            3 1
501uAC                   parm                    e$rtn             8
501uAC                   parm                    e$bpu             1
501uAC                   parm                    e$lng             2
501uAC                   if        e$rtn <> '*OK'
501uAC                   eval      e$lng = 'EN'
501uAC                   endif

414 AC                   eval      worow = 0
414 AC                   eval      wocol = 0
415eAC                   move      '0'           slchk
416dAC                   eval      ptatyp = *zeros
416dAC                   eval      lstscr = *zeros
416dAC                   move      *off          skip6
416dAC                   move      *off          itminf
416hAC                   move      *off          frstps
650iAC                   if        $pprg2 = 'PO236'
650iAC                   eval      frstps1 = *on
650iAC                   endif
417hAC                   eval      trndte = *zeros
417hAC                   eval      trntim = *zeros
417hAC                   move      '*NO '        usestr
     *
     *   Load handstack array with codes (A..Z, AA..AZ, ...)
     *
     C                   eval      k = 0
     C     1             do        27            i
     C     2             do        27            j
     C                   add       1             k
     C     ltr(i)        cat       ltr(j)        hnd(k)
     C                   enddo
     C                   enddo
     *
417pA*
750bAc                   exsr      zzretopt
415jAC                   exsr      zzropt
221 AC                   exsr      zzlcns
     *
416dA*    Remove any existing previously scanned in entries for this user.
     *
416dAC                   exsr      zzdlpk
     C                   move      *on           refrsh
     C                   exsr      scr01i
600aAC                   exsr      phpgmV1V2V3e
     C                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZADPK   Add license plates to work file for user.
416dA*
416dAC     zzadpk        begsr
600dA
600dA*  Initialize workput fields.
416dA*
600eDC**                 clear                   wkprec
600eAC                   clear                   wuRec
416dA*
600eDC**                 eval      wkpusr = #curruser
600eDC**                 move      svpnbr        wkpnbr
600eDC**                 move      svptyp        wkptyp
600eDC**                 eval      wkptrn = $pttrn#
600eDC**                 eval      wkplbl = lblbl#
600eDC**                 eval      wkpwhs = w1whse
600eDC**                 eval      wkpwhd = lbwhdp
600eAC                   move      svpnbr        wuScanNbr
600eAC                   move      svptyp        wuScanType
600eAC                   eval      wuTrn# = $pttrn#
600eAC                   eval      wuLbl# = lblbl#
600eAC                   eval      wuWhse = w1whse
600eAC                   eval      wuPckWhdp = lbwhdp
416dA*
416dAC                   select
     *
416dA*    Manual putaway - Retrieve pick slot.
     *
416dAC                   when      lbdsp2 = '*MANUAL '
416dA*
416dAC                   if        #bstyp = 'P'
416dAC                   eval      $pcmd = '*LAST   '
416dAC                   else
416dAC                   eval      $pcmd = '*FIRST  '
416dAC                   endif
416dA*
416dAC                   move      *on           itminf
     *
416dA*    Retrieve item info.
     *
511cAC                   move      lbitem        gtitem
416dAC                   exsr      zzgeti
416dAC                   move      *off          itminf
416dA*
416dA*    Item is a contract/alias/SSB item, use base item#
416dA*    to retrieve slot information.
     *
417tAC                   if        ittype = 'S'
417tAC                             or ittype = 'A'
417tAC                             and #bityp = 'S'
417tAC                   movel     #sitem        $pitem
416dA*
416dA*    Else...... use item# from label record.
     *
416dAC                   else
416dAC                   eval      $pitem = lbitem
416dAC                   endif
416dA*
416dAC                   call      'GETPSLT'
416dAC                   parm                    $pcmd
416dAC                   parm      w1whse        $pwhse
416dAC                   parm                    $pitem
416dAC                   parm      *blanks       $pslot
416dAC                   parm      *blanks       $paisl
416dAC                   parm      *zeros        $ploc
416dAC                   parm      *zeros        $prlvl
416dAC                   parm      *blanks       $phand
416dAC                   parm      *blanks       $prtn
416dAC                   select
     *
416dA*    No pick or overflow slot found. Load hi values to
416dA*    position at end of putaways.
     *
416dAC                   when      $prtn = '*NONE   '
600eDC**                 move      *hival        wkpasl
600eDC**                 move      *hival        wkploc
600eDC**                 move      *hival        wkplvl
600eDC**                 move      *hival        wkphnd

600eAC                   move      *hival        wuPckAisl
600eAC                   move      *hival        wuPckLoc
600eAC                   move      *hival        wuPckrLvl
600eAC                   move      *hival        wuPckHand
     *
416dA*    Pick or overflow slot found.
     *
416dAC                   other
600eDC**                 eval      wkpasl = $paisl
600eDC**                 eval      wkploc = $ploc
600eDC**                 eval      wkplvl = $prlvl
600eDC**                 eval      wkphnd = $phand
600eDC**                 eval      wkpdsp = $pslot

600eAC                   eval      wuPckAisl = $paisl
600eAC                   eval      wuPckLoc = $ploc
600eAC                   eval      wuPckrLvl = $prlvl
600eAC                   eval      wuPckHand = $phand
600eAC                   eval      wuPckDisp = $pslot
416dAC                   endsl
416dA*
416dA*    Directed putaway - Retrieve slot info from label record.
     *
416dAC                   other
600eDC**                 eval      wkpasl = lbaisl
600eDC**                 eval      wkploc = lbloc
600eDC**                 eval      wkplvl = lbrlvl
600eDC**                 eval      wkphnd = lbhand
600eDC**                 eval      wkpdsp = lbdisp

610cDC**                 eval      wuPckAisl = lbaisl
610cDC**                 eval      wuPckLoc = lbloc
610cDC**                 eval      wuPckrLvl = lbrlvl
610cDC**                 eval      wuPckHand = lbhand
610cDC**                 eval      wuPckDisp = lbdisp

610cMC                   eval      wuPckAisl = lbasl2
610cMC                   eval      wuPckLoc = lbloc2
610cMC                   eval      wuPckrLvl = lblvl2
610cMC                   eval      wuPckHand = lbhnd2
610cMC                   eval      wuPckDisp = lbdsp2
416dA*
416dAC                   endsl
600dA
600dA* 600eD Delete   Put current license slot into workput record.
600eA*    Put current license slot into WorkUsr record.
600dA
600eDC**                 eval      wkplic = rcv$lcns.$liToLcns
600eDC**                 eval      wkpqt1 = rcv$lcns.$liToRQty1
600eDC**                 eval      wkpqt2 = rcv$lcns.$liToRQty2
600eDC**                 eval      wkpqt3 = rcv$lcns.$liToRQty3
600eDC**                 eval      wkpitm = rcv$lcns.$liToSitem
600eDC**                 eval      wkfcod = rcv$lcns.$liToCode
600eDC**                 eval      wkfara = rcv$lcns.$liToArea
600eDC**                 eval      wkfwhs = rcv$lcns.$liToWhse
600eDC**                 eval      wkfwhd = rcv$lcns.$liToWhdp
600eDC**                 eval      wkfdsp = rcv$lcns.$liToDisp
600eDC**                 eval      wkfasl = rcv$lcns.$liToAisl
600eDC**                 eval      wkfloc = rcv$lcns.$liToLoc
600eDC**                 eval      wkflvl = rcv$lcns.$liToRlvl
600eDC**                 eval      wkfhnd = rcv$lcns.$liToHand
600dA
600eAC                   eval      wuPulLcns = rcv$lcns.$liToLcns
600eAC                   eval      wuPulOLcns = rcv$lcns.$liOLcns
600eAC                   eval      wuUsrLcns = rcv$lcns.$liToLcns
600eAC                   eval      wuRemQty1 = rcv$lcns.$liToRQty1
600eAC                   eval      wuRemQty2 = rcv$lcns.$liToRQty2
600eAC                   eval      wuRemQty3 = rcv$lcns.$liToRQty3
610nDC**                 eval      wuPulItem = rcv$lcns.$liToSitem
610nMC                   eval      wuPulItem = rcv$lcns.$liToItem
600eAC                   eval      wuPulCode = rcv$lcns.$liToCode
600eAC                   eval      wuPulArea = rcv$lcns.$liToArea
600eAC                   eval      wuWhse = rcv$lcns.$liToWhse
600eAC                   eval      wuPulWhdp = rcv$lcns.$liToWhdp
600eAC                   eval      wuPulDisp = rcv$lcns.$liToDisp
600eAC                   eval      wuPulAisl = rcv$lcns.$liToAisl
600eAC                   eval      wuPulloc = rcv$lcns.$liToLoc
600eAC                   eval      wupulrlvl = rcv$lcns.$liToRlvl
600eAC                   eval      wuPulHand = rcv$lcns.$liToHand
600dA
600dA*    Transfer license to USR slot.
600dA
600dAC                   exsr      clr$slot
600dAC                   eval      $slwhseu = *on
600dAC                   eval      $slwhse  = rcv$slot.$slwhse
600dAC                   eval      $slwhdpu = *on
600dAC                   eval      $slwhdp  = rcv$slot.$slwhdp
600dAC                   eval      $sldispu = *on
600dAC                   eval      $sldisp  = rcv$slot.$sldisp
650cAC                   eval      $sldesgu = *on
650cAc                   eval      $sldesg  = rcv$slot.$sldesg
600dAC                   eval      $saitemu = *on
640iDC**                 eval      $saitem  = rcv$slot.$slitem
640iMC                   eval      $saitem  = wuPulItem
600dA
600dAC                   eval      $saqtyu = *on
650cDC*                  if        ittype <> 'S'
600dAC                   eval      $saqty1 = rcv$lcns.$liToRQty1
600dAC                   eval      $saqty2 = rcv$lcns.$liToRQty2
600dAC                   eval      $saqty3 = rcv$lcns.$liToRQty3
650cDC*                  else
650cDC*                  eval      $saqty1 = rcv$lcns.$liToRQty2
650cDC*                  eval      $saqty2 = rcv$lcns.$liToRQty3
650cDC*                  eval      $saqty3 = 0
650cDC*                  endif
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'PUT'
600dAC                   eval      $saTrn#U = *on
600dAC                   eval      $saTrn# = $pttrn#
600dAC                   eval      $saETrn#U = *on
600dAC                   eval      $saETrn# = 0
600dAC                   eval      $saLbl#U = *on
600dAC                   eval      $saLbl# = lblbl#
600dAC                   eval      $saToLcnsU = *on
600dAC                   eval      $saToLcns = rcv$lcns.$liToLcns
600dAC                   eval      $saToPosU = *on
600dAC                   eval      $saToPos = 1
600dAC                   eval      $saToVrfyU = *on
600dAC                   eval      $saToVrfy = 'Y'
600dAC                   eval      $saToCodeu = *on
600dAC                   eval      $saToCode = 'U'
600dAC                   eval      $saToAreaU = *on
600dAC                   eval      $saToArea = 'User'
600dAC                   eval      $saOLcnsU = *on
600dAC                   eval      $saOLcns = rcv$lcns.$liOLcns
600dA
600dAC                   eval      $dricommand = '*SLOT'
600dAC                   eval      $drisubcmd  = '%TFR2USR'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   eval      *in22 = *on
600dAC                   eval      *in02 = *on
600dAC                   eval      errmsg = 'Error transfering '
600dAC                                    + %trim($liToDisp)
600dAC                                    + ' to USR slot'
600dAC                   exsr      zm0105
600dAC                   exsr      zm0001
600dAC                   leavesr
600dAC                   endif
600dA
600dA*    Save user slot info
600dA
600dAC                   eval      usr$slot = $slot
600dAC                   eval      usr$slot2 = $slot2
610eA
610eA*        Update label with RCV/STG/OSS slot.
610eA
610eAC     lblbl#        chain     label
610eAC                   if        %found(label)
610eAC                   eval      lbaisl = $slaisl
610eAC                   eval      lbloc = $slloc
610eAC                   eval      lbrlvl = $slrlvl
610eAC                   eval      lbhand = $slhand
610eAC                   eval      lbdisp = $sldisp
610eAC                   update(e) lbrec
610eAC                   if        %error
610eAC                   endif
610eAC                   endif
600dA
600dA* 600eD Delete   Put new USR slot into workput record.
600eA*    Put new USR slot into WorkUsr record.
600dA
600eDC**                 eval      wkuwhs = usr$slot.$slwhse
600eDC**                 eval      wkuwhd = usr$slot.$slwhdp
600eDC**                 eval      wkudsp = usr$slot.$sldisp
600eDC**                 eval      wkuasl = usr$slot.$slaisl
600eDC**                 eval      wkuloc = usr$slot.$slloc
600eDC**                 eval      wkulvl = usr$slot.$slrlvl
600eDC**                 eval      wkuhnd = usr$slot.$slhand
600dA
600eAC                   eval      wuWhse = usr$slot.$slwhse
600eAC                   eval      wuUsrWhdp = usr$slot.$slwhdp
600eAC                   eval      wuUsrDisp = usr$slot.$sldisp
600dA
600dA*    Update License with USR slot
600dA
     C*                  exsr      clr$license

     C*                  eval      $liLTrnU = *on
     C*                  eval      $liLTrn = 0
     C*                  eval      $liActionU = *on
     C*                  eval      $liAction = 'PUT'
     C*                  eval      $liTrn#U = *on
     C*                  eval      $liTrn# = $pttrn#
     C*                  eval      $liETrn#U = *on
     C*                  eval      $liETrn# = 0
     C*                  eval      $liLbl#U = *on
     C*                  eval      $liLbl# = lblbl#
     C*                  eval      $liToLcnsU = *on
     C*                  eval      $liToLcns = rcv$lcns.$liToLcns
     C*                  eval      $liOLcnsU = *on
     C*                  eval      $liOLcns = rcv$lcns.$liOLcns
     C*                  eval      $liToItemU = *on
     C*                  eval      $liToItem = rcv$lcns.$liToItem

     C*                  eval      $liAQty1U = *on
     C*                  eval      $liAQty1 = rcv$lcns.$liAQty1
     C*                  eval      $liAQty2 = rcv$lcns.$liAQty2
     C*                  eval      $liAQty3 = rcv$lcns.$liAQty3

     C*                  eval      $liToRQty1U = *on
     C*                  eval      $liToRQty1 = rcv$lcns.$liToRQty1
     C*                  eval      $liToRQty2 = rcv$lcns.$liToRQty2
     C*                  eval      $liToRQty3 = rcv$lcns.$liToRQty3

     C*                  eval      $liToCodeu = *on
     C*                  eval      $liToCode = 'U'
     C*                  eval      $liToAreaU = *on
     C*                  eval      $liToArea = 'User'
     C*                  eval      $liToWhdpU = *on
     C*                  eval      $liToWhdp = usr$slot.$slwhdp
     C*                  eval      $liToDispU = *on
     C*                  eval      $liToDisp = usr$slot.$sldisp
     C*                  eval      $liToAislu = *on
     C*                  eval      $liToAisl = usr$slot.$slaisl
     C*                  eval      $liToLocU = *on
     C*                  eval      $liToLoc = usr$slot.$slloc
     C*                  eval      $liToRlvlU = *on
     C*                  eval      $liToRlvl = usr$slot.$slrlvl
     C*                  eval      $liToHandU = *on
     C*                  eval      $liToHand = usr$slot.$slhand
     C*                  eval      $liToBaseU = *on
     C*                  eval      $liToBase = usr$slot.$sacdsp
     C*                  eval      $liToPosU = *on
     C*                  eval      $liToPos = 1

     C*                  eval      $liFrmOldLcnsU = *on
     C*                  eval      $liFrmOldLcns = rcv$lcns.$liToLcns
     C*                  eval      $liFrmNewLcnsU = *on
     C*                  eval      $liFrmNewLcns = $liFrmOldLcns
     C*                  eval      $liFrmWhseU = *on
     C*                  eval      $liFrmWhse = rcv$lcns.$liToWhse
     C*                  eval      $liFrmWhdpU = *on
     C*                  eval      $liFrmWhdp = rcv$lcns.$liToWhdp
     C*                  eval      $liFrmDispU = *on
     C*                  eval      $liFrmDisp = rcv$lcns.$liToDisp

     C*                  eval      $liFrmRQty1U = *on
     C*                  eval      $liFrmRQty1 = 0
     C*                  eval      $liFrmRQty2 = 0
     C*                  eval      $liFrmRQty3 = 0

     C*                  eval      $dricommand = '*LICENSE'
     C*                  eval      $drisubcmd  = '%TFRLCNS'
     C*                  eval      $drisys2upd = 'D'
     C*                  eval      chk4err = *on
     C*                  eval      zmflag  = *off
     C*                  exsr      zzzdricop
     C*                  if        error
600dAC*                  eval      *in22 = *on
600dAC*                  eval      *in02 = *on
600dAC*                  eval      errmsg = 'Error updating LICACTIVE '
600dAC*                                   + '('
600dAC*                                   + %trim(w1lcns)
600dAC*                                   + '/'
600dAC*                                   + %trim($sldisp)
600dAC*                                   + ')'
600dAC*                  exsr      zm0105
600dAC*                  exsr      zm0001
600dAC*                  leavesr
     C*                  endif
600dA
600dA* 600eD Delete   Write workput record.
600eA*    Write WorkUsr record.
416dA*
600eDC**                 write     wkprec
600eA*
600eAC                   exsr      zzgetcurrstamp
600eA
600eAC                   eval      wuaddts  = currstampsys
600eAC                   eval      wuadduc  = currstampuc
600eAC                   eval      wuaddpgm = #pgm
600eAC                   eval      wuaddemp = e$emp#
600eAC                   eval      wuaddeusr = #curruser
600eAC                   eval      wuaddjusr = #user
600eAC                   eval      wuaddjob = #job
600eAC                   eval      wuaddnbr = #jobnbr
600eA
600eAC                   eval      wuRecType = 'PUT'
600eAC                   write     wuRec
600eA*
416dAC                   add       1             w5cnt
600dD **
600dD **   License tracking item. Update tracking record.
600dD **
600dDC**                 exsr      zzzclr$lt210
600dDC**                 eval      $tcmd   = '*PUTTRAN'
600dDC**                 eval      $titem  = $pitem
600dDC**                 eval      $tlic#  = svpnbr
600dDC**                 exsr      zzzcall$lt210
416dA*
416dAC                   endsr
WSTaA*----------------------------------------------------------------
WSTaA*  ZZCHKEXIST  See if item exists in base slot.
WSTaA*----------------------------------------------------------------
WSTaA
WSTaAC     zzchkexist    begsr
WSTaA
WSTaA /free
WSTaA   exsr clr$license;
WSTaA   $liToWhseU = *on;
WSTaA   $liToWhse = lbWhse;
WSTaA   $liToWhdpU = *on;
WSTaA   $liToWhdp = lbwhdp;
WSTaA   $liToDispU = *on;
WSTaA   $liToDisp = lbdsp2;
WSTaA   $liToBaseU = *on;
WSTaA   $liToBase = lbdsp2;
WSTaA   $liToSItemU = *on;
WSTaA   $liToSItem = lbitem;
WSTaA
WSTaA   $dricommand = '*LICENSE';
WSTaA   $drisubcmd  = '%CHKROTATE';
WSTaA   $drisys2upd = 'D';
WSTaA   exsr zzzdricop;
WSTaA   error = *off;
WSTaA   OthPalletDate = 0;
WSTaA   PutPalletDate = 0;
WSTaA   if $litoentd > 0;
WSTaA     OthPalletDate = $litoentd;
WSTaA
WSTaA     exsr clr$license;
WSTaA     $liToLcnsU = *on;
WSTaA     $liToLcns = wuUsrLcns;
WSTaA     $dricommand = '*LICENSE';
WSTaA     $drisubcmd  = '%GETLCNS';
WSTaA     $drisys2upd = 'D';
WSTaA     chk4err = *on;
WSTaA     zmflag  = *off;
WSTaA     exsr zzzdricop;
WSTaA     if error;
WSTaA     else;
WSTaA       // compare dates
WSTaA       if $litoentd > OthPalletDate;
WSTaA         w2msg = 'Rotate Pallets';
WSTaA         exsr zzexception;
WSTaA       else;
WSTaA         w2msg = ' ';
WSTaA       endif;
WSTaA     endif;
WSTaA   else;
WstaA     // check open putaways
WSTaA     // get date for license being put away
WSTaA     exsr clr$license;
WSTaA     $liToLcnsU = *on;
WSTaA     $liToLcns = wuUsrLcns;
WSTaA     $dricommand = '*LICENSE';
WSTaA     $drisubcmd  = '%GETLCNS';
WSTaA     $drisys2upd = 'D';
WSTaA     chk4err = *on;
WSTaA     zmflag  = *off;
WSTaA     exsr zzzdricop;
WSTaA     if error;
WSTaA     else;
WSTAA       PutPalletDate = $litoentd;
WSTaA       // Look for RCV slots (open Putaway labels)
WSTaA
WSTAA       setll (lbWhse: 'P': ' ': lbWhdp: lbDsp2) label12;
WSTaA       dow forever = forever;
WSTaA
WSTAA         reade (lbWhse: 'P': ' ': lbWhdp: lbDsp2) label12;
WSTaA         if %eof(label12);
WSTaA           leave;
WSTAA         else;
WSTaA           // get license#
WSTaA           chain (lb_lbwhse: lb_lbtrn#) license1;
WSTAA           if %found(license1);
WSTaA             exsr clr$license;
WSTaA             $liToLcnsU = *on;
WSTAA             $liToLcns = li_lilcns;
WSTaA             $dricommand = '*LICENSE';
WSTaA             $drisubcmd  = '%GETLCNS';
WSTAA             $drisys2upd = 'D';
WSTaA             chk4err = *on;
WSTaA             zmflag  = *off;
WSTaA             exsr zzzdricop;
WSTaA             // compare dates
WSTAA             if PutPalletDate > $litoentd;
WSTaA               w2msg = 'Rotate Pallets';
WSTaA               exsr zzexception;
WSTaA               leave;
WSTAA             else;
WSTaA               w2msg = ' ';
WSTaA             endif;
WSTaA           endif;
WSTaA         endif;
WSTaA       enddo;
WSTaA     endif;
WSTaA   endif;
WSTAA /end-free

WSTaAC                   endsr

416dA*----------------------------------------------------------------
416dA*
416dA*  ZZCKPK   Check if number scanned is in the file already.
416dA*
416dAC     zzckpk        begsr
416dA*
600eDC**   pkkey2        setll     workput2                        76
600eAC     pkkey2        setll     workUsr1                               76
416dAC                   select
     *
416dA*    License or label already scanned in by another user.
     *
416dAC                   when      *in76
     *
416eA*    Retrieve record so we know who scanned in record.
     *
600eDC**   pkkey2        reade     workput2                        76
600eAC     pkkey2        reade     workUsr1                               76
416eaC                   if        *in76
416eAC                   eval      w2pusr = *blanks
416eAC                   endif
416dAC                   move      *on           error
416fMC                   move      kypnbr        erpnbr
416eAC                   eval      erpusr = w2pusr
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
416dAC                   eval      *in02 = *on
416dAC                   eval      *in22 = *on
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   movel     descsp(3)     erptxt
501uAC                   other
416dAC                   movel     desc(3)       erptxt
501uAC                   endsl
416dA*
416dAC                   when      ptatyp = '*LABEL  '
416dAC                   eval      *in04 = *on
416dAC                   eval      *in24 = *on
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   movel     descsp(2)     erptxt
501uAC                   other
416dAC                   movel     desc(2)       erptxt
501uAC                   endsl
416dA*
416dAC                   endsl
416dAC                   exsr      zm2008
416dAC                   endsl
416dA*
416dAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZDLPK   Delete existing work records for user.
416dA*
416dAC     zzdlpk        begsr
416dA*
600eDC**          pkkey         setll     workput
600eDC**          pkkey         reade     workput
600eDC**                        if        %eof(workput)
600eDC**                        delete    wkprec
416dA*
600jMC     wkkey2p       setll     workUsr2
416dAC                   dow       forevr = forevr
600jMC     wkkey2p       reade     workUsr2
600eAC                   if        %eof(workUsr2)
600dMC                   leave
600dAC                   endif

600dA* 600eD  Delete workput record.
600eA*      Delete WorkUsr record.
600dA
600eAC                   delete    wurec
600dA
600dA*      Put license back into RCV/STG/OSS slot.
600dA
600dA*        See if valid USR slot exists.
600dA
600dAC                   exsr      clr$slot
600dAC                   eval      $slwhseu = *on
600eDC**                 eval      $slwhse  = wkuwhs
600eAC                   eval      $slwhse  = wuWhse
600dAC                   eval      $slwhdpu = *on
600eDC**                 eval      $slwhdp  = wkuwhd
600eAC                   eval      $slwhdp  = wuUsrWhdp
600dAC                   eval      $sldispu = *on
600eDC**                 eval      $sldisp  = wkudsp
600eAC                   eval      $sldisp  = wuUsrDisp
640aAC                   eval      $slstatu = *on
600dAC                   eval      $saitemu = *on
600eDC**                 eval      $saitem  = wkpitm
600eAC                   eval      $saitem  = wuPulItem
600dA
600dAC                   eval      $dricommand = '*SLOT'
600dAC                   eval      $drisubcmd  = '%VFYLICSLT'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   eval      usrSlotExists = *off
600dAC                   eval      error = *off
600dAC                   else
600dAC                   eval      usrSlotExists = *on
640aAC                   eval      svstatUSR = $slstat
600dAC                   endif
600dA
600dA*        Get license from licactive file.
600dA
600dAC                   exsr      clr$license
600dAC                   eval      $liToLcnsU = *on
600eDC**                 eval      $liToLcns = wkplic
600eAC                   eval      $liToLcns = wuUsrLcns
600dAC                   eval      $dricommand = '*LICENSE'
600dAC                   eval      $drisubcmd  = '%GETLCNS'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag  = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   eval      actvLcnsExists = *off
600dAC                   eval      error = *off
600dAC                   else
600dAC                   eval      actvLcnsExists = *on
600dAC                   endif
600dA
600dA*        If USR slot doesn't exist and licactive doesn't exist,
600dA*          Then move on because all license info has disappeared.
600dA
600dAC                   if        not usrSlotExists and not actvLcnsExists
600dAC                   iter
600dAC                   endif
600dA
600dA*        If USR slot does not exist and licactive doesn't show
600dA*        license is in the USR slot,
600dA*          Then move on because license has been transfered somewhere else
600dA
600dAC                   if        not usrSlotExists
600dAC                             and wuUsrDisp <> $liToDisp
600eDC**                           and wkudsp <> $liToDisp
600dAC                   iter
600dAC                   endif
600dA
600dA*        If USR slot does not exist but licactive shows that the license
600dA*        is in the USR slot according to above check,
600dA*          Then force license back into a RCV/STG/OSS slot.
600dA
600dAC                   if        not usrSlotExists
600dAC                   exsr      clr$slot
600dAC                   eval      $slwhseu = *on
600eDC**                 eval      $slwhse  = wkfwhs
600eAC                   eval      $slwhse  = wuWhse
600dAC                   eval      $slwhdpu = *on
600eDC**                 eval      $slwhdp  = wkfwhd
600eAC                   eval      $slwhdp  = wuPulWhdp
600dAC                   eval      $sldispu = *on
600dAC                   eval      $sldisp  = ' '
600dAC                   eval      $slstypu = *on
600dAC                   eval      $slstyp = 'F'
600dAC                   eval      $slentdu = *on
600dAC                   eval      $slentd = $liToEntd
600dAC                   eval      $slexpdu = *on
600dAC                   eval      $slexpd = $liToExpd
600dAC                   eval      $saitemu = *on
600dAC                   eval      $saitem  = $liToSItem
600dA
600dAC                   eval      $saqtyu = *on
600eDC**                 eval      $saqty1 = wkpqt1
600eDC**                 eval      $saqty2 = wkpqt2
600eDC**                 eval      $saqty3 = wkpqt3
600dA
600eAC                   eval      $saqty1 = wuRemQty1
600eAC                   eval      $saqty2 = wuRemQty2
600eAC                   eval      $saqty3 = wuRemQty3
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'PUT'
600dAC                   eval      $saTrn#U = *on
600eDC**                 eval      $saTrn# = wkptrn
600eAC                   eval      $saTrn# = wuTrn#
600dAC                   eval      $saETrn#U = *on
600dAC                   eval      $saETrn# = 0
600dAC                   eval      $saLbl#U = *on
600eDC**                 eval      $saLbl# = wkplbl
600eAC                   eval      $saLbl# = wuLbl#
600dAC                   eval      $saToLcnsU = *on
600eDC**                 eval      $saToLcns = wkplic
600eAC                   eval      $saToLcns = wuUsrLcns
600dAC                   eval      $saToPosU = *on
600dAC                   eval      $saToPos = 1
600dAC                   eval      $saToVrfyU = *on
600dAC                   eval      $saToVrfy = 'N'
600dAC                   eval      $saToCodeu = *on
600eDC**                 eval      $saToCode = wkfcod
600eAC                   eval      $saToCode = wuPulCode
600dAC                   eval      $saToAreaU = *on
600eDC**                 eval      $saToArea = wkfara
600eAC                   eval      $saToArea = wuPulArea
600dAC                   eval      $saOLcnsU = *on
600dAC                   if        not actvLcnsExists
600eDC**                 eval      $saOLcns = wkplic
600eAC                   eval      $saOLcns = wuUsrlCns
600dAC                   else
600dAC                   eval      $saOLcns = sav$lcns.$liOLcns
600dAC                   endif
600dA
600dAC                   eval      $saExcdU = *on
600dAC                   eval      $saExcd = 'CANCEL'
600dA
600dAC                   eval      $dricommand = '*SLOT'
700jA * the command needs be be based on WUPULAISL
700jAC                   eval      $drisubcmd  = '%'
700jAC                                         + %subst(wuPulAisl:1:3)
700jaC                                         + 'IN'
700jDC*                  eval      $drisubcmd  = '%RCVIN'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   eval      error = *off
600dAC                   endif
600dAC                   endif
600dA
760aD**        Otherwise, if USR slot exists,
760aM*        Otherwise, if USR slot exists, and ptstat <=2
600dA*          Then transfer license from USR slot back to RCV/STG/OSS slot.
600dA
760aA /free
760aA   gttrn# = wutrn#;
760aA   exsr zzgett;
760aA /end-free
600dAC                   if        usrSlotExists
760aAc                             and trnfound
760aAc                             and $ptstat <= '2'
600dAC                   exsr      clr$slot
600dAC                   eval      $slwhseu = *on
600eDC**                 eval      $slwhse  = wkuwhs
600dAC                   eval      $slwhse  = wUWhse
600dAC                   eval      $slwhdpu = *on
600eDC**                 eval      $slwhdp  = wkuwhd
600dAC                   eval      $slwhdp  = wuPckWhdp
600dAC                   eval      $sldispu = *on
600eDC**                 eval      $sldisp  = wkudsp
600dAC                   eval      $sldisp  = wuUsrDisp
650cAC                   eval      $sldesgu = *on
650cAC                   eval      $sldesg  = 'BFC'
640aAC                   eval      $slstatu = *on
640aAC                   eval      $slstat  = svstatUSR
600dAC                   eval      $saitemu = *on
600eDC**                 eval      $saitem  = wkpitm
600dAC                   eval      $saitem  = wuPulItem
600dA
600dAC                   eval      $saqtyu = *on
600eDC**                 eval      $saqty1 = wkpqt1
600eDC**                 eval      $saqty2 = wkpqt2
600eDC**                 eval      $saqty3 = wkpqt3
600dA
600dAC                   eval      $saqty1 = wuRemQty1
600dAC                   eval      $saqty2 = wuRemQty2
600dAC                   eval      $saqty3 = wuRemQty3
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'PUT'
600dAC                   eval      $saTrn#U = *on
600eDC**                 eval      $saTrn# = wkptrn
600eAC                   eval      $saTrn# = wuTrn#
600dAC                   eval      $saETrn#U = *on
600dAC                   eval      $saETrn# = 0
600dAC                   eval      $saLbl#U = *on
600eDC**                 eval      $saLbl# = wkplbl
600eAC                   eval      $saLbl# = wuLbl#
600dAC                   eval      $saToLcnsU = *on
600eDC**                 eval      $saToLcns = wkplic
600eAC                   eval      $saToLcns = wuUsrLcns
600dAC                   eval      $saToPosU = *on
600dAC                   eval      $saToPos = 1
600dAC                   eval      $saToVrfyU = *on
600dAC                   eval      $saToVrfy = 'N'
600dAC                   eval      $saToCodeu = *on
600eDC**                 eval      $saToCode = wkfcod
600eAC                   eval      $saToCode = wuPulCode
600dAC                   eval      $saToAreaU = *on
600eDC**                 eval      $saToArea = wkfara
600eAC                   eval      $saToArea = wuPulArea
600dAC                   eval      $saOLcnsU = *on
600dAC                   if        not actvLcnsExists
600eDC**                 eval      $saOLcns = wkplic
600eAC                   eval      $saOLcns = wuUsrLcns
600dAC                   else
600dAC                   eval      $saOLcns = sav$lcns.$liOLcns
600dAC                   endif
600dA
600dAC                   eval      $saExcdU = *on
600dAC                   eval      $saExcd = 'CANCEL'
600dA
600dAC                   eval      $dricommand = '*SLOT'
600dAC                   eval      $drisubcmd  = '%USR2'
600dAC                                         + %subst(wuPulAisl:1:3)
600eDC**                                       + %subst(wkfasl:1:3)
700jA ** because drislot already uses command USR2RTN to complete the
700jA ** putaway of the return. We needed to use command USR2RTNO
700jAc                   if        $drisubcmd = '%USR2RTN'
700jAc                   eval      $drisubcmd = '%USR2RTNO'
700jAc                   endif
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   eval      error = *off
600dAC                   endif
600dAC                   endif
610eA
610eA*        Update label with RCV/STG/OSS slot.
610eA
610eAC     wuLbl#        chain     label
610eAC                   if        %found(label)
760aAc                   select
760aAC                   when      usrSlotExists
760aAc                             and trnFound
760aAc                             and $ptstat = '3'
760aAc                   eval      lbstat = 'C'
760aAC                   when      not usrSlotExists
760aAc                             and trnFound
760aAc                             and $ptstat >= '3'
760aAc                   eval      lbstat = 'P'
760aAC                   eval      lbaisl = $slaisl
760aAC                   eval      lbloc = $slloc
760aAC                   eval      lbrlvl = $slrlvl
760aAC                   eval      lbhand = $slhand
760aAC                   eval      lbdisp = $sldisp
760aAc                   other
610eAC                   eval      lbaisl = $slaisl
610eAC                   eval      lbloc = $slloc
610eAC                   eval      lbrlvl = $slrlvl
610eAC                   eval      lbhand = $slhand
610eAC                   eval      lbdisp = $sldisp
760aAC                   endsl
610eAC                   update(e) lbrec
610eAC                   if        %error
610eAC                   endif
610eAC                   endif
610gA
610gA*        If tran is status '2', reset back to '1'.
610gA
760aDC*                  eval      gttrn# = lbtrn#
760aDC*                  exsr      zzgett
610gAC                   if        trnFound
610gAC                             and $ptstat = '2'
610gAC                             and $ptemp# = e$emp#
760aAC                             or not usrSlotExists
760aAC                             and $ptstat > '1'
760aAC                             and $ptstat < '4'
760aAC                             and $ptemp# = e$emp#
610gAC                   exsr      zzabrt
610gAC                   endif
600dA
760aA*        Otherwise, if USR slot exists, and ptstat =3
760aA*          close the transation, leave usr slot for client to    S slot.
760aA*          transfer to correct slot.                             S slot.
760aA
760aAC                   if        usrSlotExists
760aAc                             and trnFound
760aAc                             and $ptstat = '3'
760aA*        If tran is status '3', close transaction
760aA
760aAC                   exsr      zzclsp
760aAC                   endif
600dA *        Update License with RCV/STG/OSS slot.
600dA *
600dAC*                  eval      sav$lcns = $license
600dAC*                  exsr      clr$license
600dA
600dAC*                  eval      $liLTrnU = *on
600dAC*                  eval      $liLTrn = 0
600dAC*                  eval      $liActionU = *on
600dAC*                  eval      $liAction = 'PUT'
600dAC*                  eval      $liTrn#U = *on
600dAC*                  eval      $liTrn# = wkptrn
600dAC*                  eval      $liETrn#U = *on
600dAC*                  eval      $liETrn# = 0
600dAC*                  eval      $liLbl#U = *on
600dAC*                  eval      $liLbl# = wkplbl
600dAC*                  eval      $liToLcnsU = *on
600dAC*                  eval      $liToLcns = wkplic
600dAC*                  eval      $liOLcnsU = *on
600dAC*                  if        not actvLcnsExists
600dAC*                  eval      $liOLcns = wkplic
600dAC*                  else
600dAC*                  eval      $liOLcns = sav$lcns.$liOLcns
600dAC*                  endif
600dAC*                  eval      $liToVrfyU = *on
600dAC*                  eval      $liToVrfy = 'N'
600dA
600dAC*                  eval      $liAQty1U = *on
600dAC*                  if        actvLcnsExists
600dAC*                  eval      $liAQty1 = 0
600dAC*                  eval      $liAQty2 = 0
600dAC*                  eval      $liAQty3 = 0
600dAC*                  else
600dAC*                  eval      $liAQty1 = wkpqt1
600dAC*                  eval      $liAQty2 = wkpqt2
600dAC*                  eval      $liAQty3 = wkpqt3
600dAC*                  endif
600dA
600dAC*                  eval      $liToRQty1U = *on
600dAC*                  eval      $liToRQty1 = wkpqt1
600dAC*                  eval      $liToRQty2 = wkpqt2
600dAC*                  eval      $liToRQty3 = wkpqt3
600dA
600dAC*                  eval      $liToCodeu = *on
600dAC*                  eval      $liToCode = wkfcod
600dAC*                  eval      $liToAreaU = *on
600dAC*                  eval      $liToArea = wkfara
600dAC*                  eval      $liToWhdpU = *on
600dAC*                  eval      $liToWhdp = $slwhdp
600dAC*                  eval      $liToDispU = *on
600dAC*                  eval      $liToDisp = $sldisp
600dAC*                  eval      $liToAislu = *on
600dAC*                  eval      $liToAisl = $slaisl
600dAC*                  eval      $liToLocU = *on
600dAC*                  eval      $liToLoc = $slloc
600dAC*                  eval      $liToRlvlU = *on
600dAC*                  eval      $liToRlvl = $slrlvl
600dAC*                  eval      $liToHandU = *on
600dAC*                  eval      $liToHand = $slhand
600dAC*                  eval      $liToBaseU = *on
600dAC*                  eval      $liToBase = $sacdsp
600dAC*                  eval      $liToPosU = *on
600dAC*                  eval      $liToPos = 1
600dAC*                  eval      $liToItemU = *on
600dAC*                  eval      $liToItem = wkpitm
600dAC*                  eval      $liToPrtyU = *on
600dAC*                  eval      $liToPrty = $slprty
600dAC*                  eval      $liToEntdU = *on
600dAC*                  eval      $liToEntd = $slentd
600dAC*                  eval      $liToExpdU = *on
600dAC*                  eval      $liToExpd = $slexpd

     C*                  eval      $liFrmOldLcnsU = *on
     C*                  eval      $liFrmOldLcns = wkplic
     C*                  eval      $liFrmNewLcnsU = *on
     C*                  eval      $liFrmNewLcns = $liFrmOldLcns
     C*                  eval      $liFrmWhseU = *on
     C*                  eval      $liFrmWhse = wkuwhs
     C*                  eval      $liFrmWhdpU = *on
     C*                  eval      $liFrmWhdp = wkuwhd
     C*                  eval      $liFrmDispU = *on
     C*                  eval      $liFrmDisp = wkudsp

     C*                  eval      $liFrmRQty1U = *on
     C*                  eval      $liFrmRQty1 = 0
     C*                  eval      $liFrmRQty2 = 0
     C*                  eval      $liFrmRQty3 = 0
600dA
600dAC*                  eval      $dricommand = '*LICENSE'
600dAC*                  eval      $drisubcmd  = '%TFRLCNS'
600dAC*                  eval      $drisys2upd = 'D'
600dAC*                  eval      chk4err = *on
600dAC*                  eval      zmflag  = *off
600dAC*                  exsr      zzzdricop
600dAC*                  if        error
600dAC*                  eval      error = *off
600dAC*                  endif
600dD **
600dD **   If license plate tracking item not putaway, undo inuse flag.
600dD **
600dDC**                 if        wkptyp = 'P'
600dDC**                 exsr      zzzclr$lt210
600dDC**                 eval      $tcmd   = '*PUTUNDO'
600dDC**                 eval      $tlic#  = wkpnbr
600dDC**                 exsr      zzzcall$lt210
600dDC**                 endif
417qA
416dAC                   enddo
416dA*
416dAC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZDLP1   Delete single work record.
416dA*
416dAC     zzdlp1        begsr
416dA*
610mAC                   eval      kypitm = lbitem
600eDC**                 if        wkpnbr = *blanks
600eAC                   if        wuScanNbr = *blanks
600eDC**                 eval      wkpnbr = w6nxt#
600eAC                   eval      wuScanNbr = w6nxt#
510hAC                   endif
600eDC**                 if        wkpnbr = *blanks
600eAC                   if        wuScanNbr = *blanks
600eAC                   eval      wuScanNbr = svpNbr
600eDC**                 eval      wkpnbr = svpnbr
510hAC                   endif
417dA*
600eDC**   pkkya         chain     workput                            79
417dA*
600eAC     wkkey2        chain     workUsr2                           79
416dAC                   select
416dAC                   when      not *in79
600eDC**                 delete    wkprec
600eAC                   delete    wuRec
416dAC                   eval      w5cnt = w5cnt - 1
417dA*
417dA*    Previous putaway was skipped. Reduce index counter.
     *
417dAC                   if        skip6 = *on
417dAC                   eval      w6cnt1 = w6cnt1 - 1
417dAC                   endif
416dAC                   endsl
416dA*
416dAC                   endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZDSCZ   Get Zone description.
417i *
417iAC     zzdscz        begsr
417i C     keyzh         chain     stagh                              79
417i C                   if        *in79
417i C                   move      zone          shzone
417i C                   eval      shdesc = *blanks
417i C                   eval      shzseq = 0
417i C                   endif
417i C                   movel     shdesc        zdesc
417iAC                   endsr
417pA*
501tA*----------------------------------------------------------------
501tA*
501tA*  ZZCKIRPL  Check for Available Interleaving Replenishments.
501tA*
501tAC     zzckIrpl      begsr
501tA*
501tA*      Call Retrieve Interleaving replenishment pgm.
501tA*
501tA*      Send slot info from last putaway.
     *
501tAC                   eval      $rwhse = lbwhse
501tAC                   eval      $rwhdp = lbwhdp
501tAC                   eval      $raisl = lbaisl
501tAC                   eval      $rloc  = lbloc
501tAC                   eval      $rrlvl = lbrlvl
501tAC                   eval      $rhand = lbhand
501tAC                   eval      $rdisp = lbdisp
501tAC                   eval      $rtrn# = 0
501tAC                   clear                   $parm2
501tA*
501tAC                   call      'GETIRPL'
501tAC                   parm                    $rparm
501tAC                   parm                    $parm2
501tA*
501tAC                   select
501tAC                   when      $rrtn = '*FOUND'
501tAC                   eval      interlvrpl = '*YES'
501tA*
501tA*      Interleave replen's not active or none found.
     *
501tAC                   when         $rrtn = '*OFF    '
501tAC                             or $rrtn = '*NOREPL '
501tAC                   eval      interlvrpl = '*NO '
501tA*
501tAC                   other
501tAC                   eval      interlvrpl = '*NO '
501tAC                   endsl
501tA*
501tAC     endckrpl      endsr
WSTaA*----------------------------------------------------------------
WSTaA*  ZZEXCEPTION Write rotation exception record on each warning.
WSTaA*----------------------------------------------------------------
WSTaA
WSTaAC     zzexception   begsr
WSTaA
WSTaA /free
WSTaA   exwhse = lbwhse;
WSTaA   exwhdp = lbwhdp;
WSTaA   exwhdp = lbwhdp;
WSTaA   exstyp = lbstyp;
WSTaA   exitem = lbitem;
WSTaA   dspo = lbpo;
WSTaA   dslbl = lblbl#;
WSTaA   dsexpd = zzexpd;
WSTaA   exfdis = wuUsrLcns;
WSTaA   extdis = lbdsp2;
WSTaA   exgdte = lbsdte;
WSTaA   exgtim = lbstim;
WSTaA   if lbqpck > 999;
WSTaA   exqty = 999;
WSTaA   else;
WSTaA   exqty = lbqpck;
WSTaA   endif;
WSTaA   exqty2 = *zeros;
WSTaA   exqty3 = *zeros;
WSTaA   excitm = *blanks;
WSTaa   extask = 'PUT';
WSTaA   exgby = #user;
WSTaA   exesta = '1 ';
WSTaA   exuser = *blanks;
WSTaA   excdte = *zeros;
WSTaA   exctim = *zeros;
WSTaA   exerid = 'ROTATE ';
WSTaA   write exrec;
WSTaA /end-free
WSTaAC                   endsr
     *----------------------------------------------------------------
     *
221 A*  ZZLCNS   Get use generic license option
     *
221 AC     zzlcns        begsr
     *
221 A*   Get use generic license option.
     *
221 AC                   move      *off          lflag
221 AC                   eval      *in35 = *off
221 AC                   move      '*RCVLBL '    ocode
     *
221 AC     opkey         chain     options                            79
221 AC                   if        not *in79
417oAC                   eval      oprdta = opdata
221 AC                   if        opplcn = 'Y'
221 AC                   move      '1'           lflag
221 AC                   eval      *in35 = *on
221 AC                   endif
221 AC                   endif
     *
221 AC                   endsr
750bA*----------------------------------------------------------------
750bA*
750bA*  ZZRETOPT Get Allow pallet license on returns option
750bA*
750bAC     zzretopt      begsr
750bA*
750bA*   Get Allow pallet license on returns option
750bA*
750bAC                   move      '*RETURNS'    ocode
750bA*
750bAC     opkey         chain     options                            79
750bAC                   if        not *in79
750bAC                   eval      oprtndta = opdata
750bAC                   endif
750bA*
750bAC                   endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  ZZLOG4   Write log record for verify qty entered on Screen4
415kA*
415kAC     zzlog4        begsr
     C                   endsr
     *
415jA*----------------------------------------------------------------
415jA*
415jA*  ZZROPT   Get use RF Putaway options.
415jA*
415jAC     zzropt        begsr
     *
     C                   eval      kywhse = *zeros
     C                   eval      opcode = '*RFPUT  '
     C     optsky        chain     options                            79
     C                   if        *in79
     C                   eval      opvrfy = 'N'
417gAC                   eval      oppqty = 'N'
417gAC                   eval      opmscn = 'Y'
710aAC                   eval      opiswn = 'N'
     C                   else
     C                   eval      opdat3 = opdata
500aAC                   if        opmscn = ' '
500aAC                   eval      opmscn = 'Y'
500aAC                   endif
     C                   endif
     *
     C                   endsr
     *----------------------------------------------------------------
     *
417iA*  ZZRSET Reset previous task.
     *
417iAC     zzrset        begsr
     *
417i *  get started settings
     *
417i C                   eval      wotrn# = lbtrn#
600cDC**   ptkey         chain(n)  pirtran                            79
600cDC**                 if        not *in79
600cAC                   eval      gttrn# = wotrn#
600cAC                   exsr      zzgett
600cAC                   if        trnFound
600cMC                   eval      otshft = $ptshft
600cMC                   eval      otcrew = $ptcrew
600cMC                   eval      otemp# = $ptemp#
600cMC                   eval      otsdte = $ptsdte
600cMC                   eval      otstim = $ptstim
417i C                   endif
417i *
417i C                   if        w3qty = worqty
600cMC                   eval      @ptask = $pttask
417i C                   eval      @pcube = lbcube
417i C                   eval      @pswgt = lbswgt
417i C                   eval      @pcmd2 = '*UNDO'
417i C                   call      @adjt2
417i C                   parm                    @pcmd2
417i C                   parm                    #job
417i C                   parm      '*INTER  '    @ptype
600cMC                   parm      wotrn#        @ptrn#
417i C                   parm                    @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      lbwhdp        @pwhdp
417i C                   parm      lbstyp        @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417i C                   parm      lbqpck        @ppcs
417i C                   parm      0             @paisl
417i C                   parm      0             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      '0'           @prte
417i C                   parm      ' '           @ppo
417i C                   parm      'P'           @pgrp1
417i C                   parm      ' '           @pgrp2
417i C                   parm      0             @pdate
417i C                   parm      0             @ptime
600dMC                   parm      #curruser     @puser
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
417i C                   endif
417i *
417iAC     endrst        endsr
     *----------------------------------------------------------------
     *
417iA*  ZZSAVT Save transaction fields.
     *
417iAC     zzsavt        begsr
417i *
417i *  Save put away transaction record
417i *
600cMC                   eval      otsdte = $ptsdte
600cMC                   eval      otstim = $ptstim
600cMC                   eval      otemp# = $ptemp#
600cMC                   move      $pttask       ottask
600cMC                   eval      otcube = $ptcube
600cMC                   eval      otswgt = $ptswgt
600cMC                   eval      otpcs = $ptpcs
600cMC                   eval      otaisl = $ptaisl
600cMC                   eval      otqty1 = $ptqty1
600cMC                   eval      otqty2 = $ptqty2
600cMC                   eval      otqty3 = $ptqty3
600cMC                   move      $ptrtpo       otpo
600cMC                   move      $ptgrp1       otgrp1
600cMC                   move      $ptgrp2       otgrp2
600cMC                   move      $ptwhdp       otwhdp
600cMC                   move      $ptstyp       otstyp
417i *
417iAC     endsvt        endsr
     *
417i *----------------------------------------------------------------
417i *
417iA*  ZZSTAG   Create stage transaction and label record
417i *
417iAC     zzstag        begsr
417i *
417i *  Get new transaction number for staging.
417i *
417i C                   call      'PIRTRN#'
417i C                   parm                    pntrn#            7 0
417i *
417i *        Create and start transaction.
417i *
417i C                   eval      @ppcs = w3rqty
     *
417i *    Calculate cube and weight for put away qty.
     *
417i C                   eval      @pcube = sbucub * w3rqty
417i C                   eval      @pswgt = sbuwgt * w3rqty
417i *
417i *   Start time for new trans will be end time of previous trans.
     *
417i C                   eval      @pdate = 0
417i C                   eval      @ptime = 0
417i C                   if        w3rqty <> worqty
600cDC**   svtrn#        chain(n)  pirtran                            79
600cDC**                 if        not *in79
600cAC                   eval      gttrn# = svtrn#
600cAC                   exsr      zzgett
600cAC                   if        trnFound
600cMC                   eval      @pdate = $ptedte
600cMC                   eval      @ptime = $ptetim
417i C                   endif
417i C                   endif
417i C                   call      @adjt2
417i C                   parm      '*CRTSTRT'    @pcmd2
417i C                   parm                    #job
417i C                   parm      '*INTER  '    @ptype
417i C                   parm      pntrn#        @ptrn#
417i C                   parm      'PUTSTG'      @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      otwhdp        @pwhdp
417i C                   parm      otstyp        @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417i C                   parm                    @ppcs
417i C                   parm      0             @paisl
417i C                   parm      1             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      ' '           @prte
417i C                   parm      otpo          @ppo
417i C                   parm      otgrp1        @pgrp1
417i C                   parm      otgrp2        @pgrp2
417i C                   parm                    @pdate
417i C                   parm                    @ptime
600dMC                   parm      #curruser     @puser
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
417i *
417iAC     endstg        endsr
     *----------------------------------------------------------------
     *
     *  ZZSTRT   Start a new transaction
     *
     C     zzstrt        begsr
     *
     *     - Get label record. Put-Away has only one label record
     *       per transaction number.
     *
     C     lbkey7        setll     label7
     C     lbkey7        reade     label7                                 79
600cMC                   eval      @ptask = $pttask
     C                   eval      @pcube = lbcube
     C                   eval      @pswgt = lbswgt
     C                   call      @adjtr
     C                   parm      '*START  '    @pcmd
     C                   parm                    #job
600cMC                   parm      $pttrn#       @ptrn#
     C                   parm                    @ptask
     C                   parm      w1whse        @pwhse
     C                   parm      lbwhdp        @pwhdp
     C                   parm      lbstyp        @pstyp
     C                   parm                    @pcube
     C                   parm                    @pswgt
     C                   parm      lbqpck        @ppcs
     C                   parm      0             @paisl
     C                   parm      0             @pqty1
     C                   parm      0             @pqty2
     C                   parm      0             @pqty3
     C                   parm      '0'           @prte
     C                   parm      ' '           @ppo
410 MC                   parm      'P'           @pgrp1
     C                   parm      ' '           @pgrp2
     C                   parm      ' '           @prtn
     C                   parm      ' '           @pmsg
     *
     C     endstr        endsr
     *----------------------------------------------------------------
     *
     *  ZZTASK  Get current task.
     *
410 AC     zztask        begsr
600cDC**                 eval      stdate = *hival
600cDC**                 eval      sttime = *hival
600cDC**
600cDC**                 move      '2'           kystat
600cDC**   ptkey1        setll     pirtran1
600cDC**   ptkey1        reade     pirtran1                               79
600cDC**                 if        *in79
600cDC**                 move      *off          found
600cDC**                 goto      endtsk
600cDC**                 endif
600cDC**
600cDC**   ptke22        setll     pirtran2
600cDC**                 dow       forevr = forevr
600cDC**                 read      pirtran2                               79
600cDC**                 if        *in79  or
600cDC**                           ptemp# <> w1emp#
600cDC**                 move      *off          found
600cDC**                 leave
600cDC**                 endif
600cDC**                 if        ptstat <> '2'
600cDC**                 iter
600cDC**                 endif
600cA*
600cA*   Get current task for employee
600cA*
600cAC                   exsr      clr$pirtran
600cAC                   eval      $ptemp#u = *on
600cAC                   eval      $ptemp#  = w1emp#
600cAC                   eval      $dricommand = '*PIRTRAN'
600cAC                   eval      $drisubcmd  = '%GETCUR'
600cAC                   eval      $drisys2upd = 'D'
510hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *off
600cAC                   exsr      zzzdricop
600cAC                   if        error
600cAC                   eval      error = *off
600cAC                   goto      endtsk
600cAC                   endif
     *
410 A*   Found an active transaction
     *
410 AC                   move      *on           curent
600cDC**                 eval      curtrn = pttrn#
600cDC**                 move      pttask        t#task
600cMC                   eval      curtrn = $pttrn#
600cMC                   eval      t#task = $pttask
410 AC     tkkey         chain     task                               79
410 AC                   if        not *in79
410 AC                   move      tkcode        curtsk
410 AC                   move      tktype        curtyp
410 AC                   endif
600cDC**                 leave
600cDC**                 enddo
410 AC     endtsk        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD1   Update for screen 1.
     *
     C     zzupd1        begsr
     C                   move      *off          error
     C                   move      *on           refrsh
500hA
500hA*   Initialize all *SLOT parms now. CLR$SLOTW will be used later.
500hA
500hAC                   exsr      clr$slot
500hA
417oA*
417oA*   Check if warehouse changed. If yes, get all new options.
417oA*
417oAC                   if        w1whse <> svwhse
417oAC                   z-add     w1whse        svwhse
417oAC                   z-add     w1whse        kywhse
417oA*
417oA*    Get generic license plate options.
     *
417oAC                   exsr      zzlcns
417oAC                   endif
600cD**
600cD**   Get current task.
600cD**
600cD**   Only end current task when starting putaway using
600cD**   transaction number or putaways are limited to one
600cD**   at a time. The IDLE task will stay active until
600cD**   user starts a putaway transaction.
600cD**
600cD**                  if        w1trn# <> 0  or
600cD**                            opmscn = 'N'
600cD**
600cD**                  exsr      zztask
600cD**                  select
600cD**                  when      curtyp = 'D'
600cD**
600cD**   End current task.
600cD**
600cD**                  exsr      zzend
600cD**                  when      curtyp = 'I'
600cD**
600cD**  End current task and any previous open tasks.
600cD**
600cD**                  move      *on           found
600cD**                  dow       found = *on
600cD**                  eval      curtsk = *zeros
600cD**                  eval      curtyp = *zeros
600cD**                  move      *off          curent
600cD**                  exsr      zztask
600cD**                  if        found = *off
600cD**                  leave
600cD**                  endif
600cD**                  exsr      zzend
600cD**                  enddo
600cD**                  endsl
600cD**                  endif
417hA*
600iAC                   select
600iMC                   when      w1lbl# <> 0
600dDC**                 eval      wotrn# = lktrn#
416dAC                   move      '*LABEL  '    ptatyp
600iDC**                 endif
600cDC**                 if        w1trn# <> 0
600cDC**                 z-add     w1trn#        wotrn#
600cDC**                 move      '*TRAN   '    ptatyp
600cDC**                 endif
600iMC                   when      w1lcns <> *blanks
600dDC**                 z-add     litrn#        wotrn#
416dAC                   move      '*LICENSE'    ptatyp
600iMC                   endsl
600dDC**
600dDC**  Get transaction record for put-away.
600dDC**      ** already retrieved in zzchk1 **
600cDC**   ptkey         chain(n)  pirtran                            79
600dDC**
600dDC**    Record not found.
600dDC**
600cDC**                 if        *in79
600dDC**                 move      *on           error
600dDC**                 eval      *in22 = *on
600dDC**                 eval      *in02 = *on
600dDC**                 eval      errmsg = *blanks
600dDC**                 select
600dDC**                 when      e$lng = 'SP'
600dDC**                 eval      errmsg = descsp(1)
600dDC**                 other
600dDC**                 eval      errmsg = desc(1)
600dDC**                 endsl
600dDC**                 exsr      zm7979
600dDC**                 goto      endup1
600dDC**                 endif
416dA*
416dA*    Load key values.
     *
610kAC                   z-add     w1whse        kywhse
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
500fAC                   move      w1lcns        svpnbr
416fMC                   move      w1lcns        kypnbr
416dAC                   move      'P'           kyptyp
700cAC                   move      'P'           svptyp
416dAC                   when      ptatyp = '*LABEL  '
600iDC**                 movel     w1lbl#        svpnbr
600iDC**                 movel     w1lbl#        kypnbr
600iMC                   eval      svpnbr = %editc(w1lbl#:'X')
600iMC                   eval      kypnbr = svpnbr
416dAC                   move      'L'           kyptyp
710bAC                   move      'L'           svptyp
416dAC                   endsl
416dA*
416dA*    Check if license/label already scanned in.
417gA*    Note: If OPMSCN is Y, then user can scan in more than one
417gA*          license/label at a time. Otherwise, it must be one
417gA*          at a time.
     *
600dDC**                 select
600dDC**                 when      ptatyp = '*LICENSE'  and
600dDC**                           opmscn = 'Y'  or
600dDC**                           ptatyp = '*LABEL  '  and
600dDC**                           opmscn = 'Y'
416dAC                   exsr      zzckpk
416dAC                   if        error = *on
416dAC                   goto      endup1
416dAC                   endif
416dA*
416dA*    Retrieve label record for writing to work file.
     *
416dAC     lbkey7        setll     label7
416dAC     lbkey7        reade     label7                                 79
     *
600dDC**  Start new transaction.
600dDC**    Note: Only set to Inuse when transaction# has been entered.
600dDC**   Note: If OPMSCN is N, then putaway is limited to one at a time.
600dDC**
600dDC**                 when      ptatyp = '*TRAN   '  or
600dDC**                           opmscn = 'N'
600dDC**
600dDC**                 exsr      zzstrt
600dDC**                 move      lbitem        gtitem
600dDC**                 exsr      zzgeti
600dDC**
600dDC**   License tracking item. Update tracking record.
600dDC**
600dDC**                 exsr      zzzclr$lt210
600dDC**                 eval      $tcmd   = '*PUTTRAN'
600dDC**                 eval      $titem  = lbitem
600dDC**                 eval      $tlic#  = svpnbr
600dDC**                 exsr      zzzcall$lt210
600dDC**                 endsl
     *
416dA*    Perform qty check for lic#/lbl#/trn# scanned in.
     *
415kAC                   if        oppqty = 'Y'
416dA*
416dA*    Save entered license plate info.
     *
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
416fMC                   move      w1lcns        svpnbr
416dAC                   move      'P'           svptyp
     *
416dA*    Save entered label info.
     *
416dAC                   when      ptatyp = '*LABEL  '
600iDC**                 movel     w1lbl#        svpnbr
600iMC                   eval      svpnbr = %editc(w1lbl#:'X')
416dAC                   move      'L'           svptyp
416dAC                   endsl
416dA*
416dAC                   move      '01 '         lstscr
415kAC                   exsr      scr04i
416dA*
416dA*    No qty check being performed.
     *
415kAC                   else
416dA*
416dA*    License plate/label scanned in. Setup to scan in more.
417gA*    Note: If OPMSCN is Y, then user can scan in more than one
417gA*          license/label at a time. Otherwise, it must be one
417gA*          at a time.
     *
     C                   select
600dAC                   when      opmscn = 'Y'
600dDC**                 when      ptatyp = '*LICENSE'  and
600dDC**                           opmscn = 'Y'  or
600dDC**                           ptatyp = '*LABEL  '  and
600dDC**                           opmscn = 'Y'
416dA*
416dAC                   select
     *
416dA*    Add license plate to work file.
     *
416dAC                   when      ptatyp = '*LICENSE'
416fMC                   eval      w5lst# = w1lcns
416fMC                   eval      svpnbr = w1lcns
416dAC                   move      'P'           svptyp
416dAC                   eval      w5txt = w5txt1
416dAC                   exsr      zzadpk
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
     *
416dA*    Add label to work file.
     *
416dAC                   when      ptatyp = '*LABEL  '
600iDC**                 move      w1lbl#        w5lst#
600iDC**                 movel     w1lbl#        svpnbr
600iMC                   eval      w5lst# = %editc(w1lbl#:'X')
600iMC                   eval      svpnbr = %editc(w1lbl#:'X')
416dAC                   move      'L'           svptyp
416dAC                   eval      w5txt = w5txt2
416dAC                   exsr      zzadpk
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
416dAC                   endsl
416dA*
416dAC                   move      '01 '         lstscr
416dAC                   exsr      scr05i
416dA*
416dA*    Transaction# scanned in. Process as one.
417gA*    or only single license/label can be scanned.
     *
     C                   other
ISYaAC                   if        Client = isupply
ISYaAC                   move      '01 '         lstscr
ISYaAC                   exsr      scr09ai
ISYaA*    The following code will be executed in ZZUPD9A
ISYaAC                   goto      jmp1
ISYaAC                   endif
600dA
600dAC                   exsr      zzadpk
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
600dA
600dAC                   exsr      zzstrt
600dAC                   move      lbitem        gtitem
600dAC                   exsr      zzgeti
416dA*
409 AC                   if        lbdsp2 = '*MANUAL'
409 AC                   eval      worqty = lbqpck
416dAC                   move      '01 '         lstscr
409 AC                   exsr      scr03i
409 AC                   else
416dAC                   move      '01 '         lstscr
     C                   exsr      scr02i
409 AC                   endif
ISY AC     jmp1          tag
416dA*
     C                   endsl
415kAC                   endif
416dA*
     C     endup1        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   move      *off          error
     C                   move      *on           refrsh

PFCaAc                   if        logapt
PFCaAc                   move      pttask        svtask
PFCaAc                   endif

ISYa *  Update the "From" record.
ISYaAC                   if        Client = isupply
ISYaAC                   eval      lflbl# = lblbl#
ISYaAC                   eval      lftype = wotype
ISYbDC*                  eval      lffrom = wofrom
ISYbAC                   eval      lffloc = wofrom
ISYaAC                   write     lfrec                                79
ISYaAC                   if        *in79 = *on
ISYa C                   move      *on           error
ISYa C                   exsr      zm71
ISYa C                   goto      endup2
ISYa C                   endif
ISYa C                   endif
500gA*
500gA*    License tracking item. Do Putaway Before update processing.
500gA*
500gAC                   exsr      zzzclr$lt210
500gAC                   eval      $tcmd   = '*PUTAWYB'
500gAC                   eval      $titem  = lbitem
500gAC                   eval      $titemdsc = w2item
500gAC                   eval      $twhdp  = lbwhdp
500gAC                   eval      $tslot  = w2scan
610cAC                   select
610cAC                   when      lbutyp = 'N'
610cAC                   eval      $tqty1  = w2qty
610cAC                   eval      $tnorm1 = w2qty
610cAC                   when      lbutyp = '1'
610cAC                   eval      $tqty2  = w2qty
610cAC                   eval      $tnorm2 = w2qty
610cAC                   when      lbutyp = '2'
610cAC                   eval      $tqty3  = w2qty
610cAC                   eval      $tnorm3 = w2qty
610cAC                   endsl
610cAC                   eval      $tpartial = *off
600dDC**                 eval      $tlic#  = svpnbr
600eDC**                 eval      $tlic#  = wkplic
600eAC                   eval      $tlic#  = wuUsrLcns
500gAC                   exsr      zzzcall$lt210
500gAC                   select
500gAC                   when      $treturn = '*CANCEL'
500gAC                   goto      endup2
500gAC                   when      $treturn <> '*OK'
500gAC                   eval      *in21 = *on
500gAC                   eval      *in01 = *on
500gAC                   goto      endup2
500gAC                   endsl
500gA*
640kD **   Close transaction and update label and slot records.
640kD **   -- Moved after updating slot and label --
640kD **
640kDC**                 exsr      zzclsp
610cDC**   lblbl#        chain     pofifo                             79
610cDC**                 if        not *in79
610cDC**   slkey         chain     record                             78
610cDC**                 if        not *in78
610cDC**                 eval      slentd = pffifo
610cDC**
610cDC*** Update slot record
610cDC**
610cDC**                 update    record                               78
610cDC**                 endif
610cDC**                 endif
610aA
610cA*   Call DRI interface to do update.
610cA
610cAC                   exsr      clr$slotw
610cAC                   eval      $slwhseu = *on
610cAC                   eval      $slwhse  = w1whse
610cAC                   eval      $slwhdpu = *on
610cAC                   eval      $slwhdp  = lbwhdp
610cAC                   eval      $sldispu = *on
610cAC                   eval      $sldisp  = w2scan
650gAC                   if        s_slstat = 'A'
650gAC                   eval      $slstatu = *off
650gAC                   eval      $slstat  = *blanks
650gAC                   else
640aAC                   eval      $slstatu = *on
640aAC                   eval      $slstat  = slstat
650gAC                   endif
610cAC                   eval      $slexpdu = *on
610cAC                   eval      $slexpd  = svexpd
610cAC                   eval      $sacwhdu = *on
610cAC                   eval      $sacwhd  = wuUsrWhdp
610cAC                   eval      $sacdspu = *on
610cAC                   eval      $sacdsp  = wuUsrDisp
610cA
610cAC                   if        $pttask = 'PUTRTN'
610cAC                   eval      $slprtyu = *on
610cAC                   eval      $slprty  = -9
610cAC                   endif
610cA
610cAC                   eval      $saitemu = *on
610cAC                   eval      $saitem  = lbitem
610cAC                   eval      $saqtyu = *on
610cAC                   select
610cAC                   when      lbutyp = 'N'
610cAC                   eval      $saqty1 = w2qty
610cAC                   when      lbutyp = '1'
610cAC                   eval      $saqty2 = w2qty
610cAC                   when      lbutyp = '2'
610cAC                   eval      $saqty3 = w2qty
610cAC                   endsl
610cAC                   eval      $satrn#u = *on
610cAC                   eval      $satrn#  = $pttrn#
610cAC                   eval      $satasku = *on
610cAC                   eval      $satask  = $pttask
610cA
610cAC                   eval      $saActionU = *on
610cAC                   eval      $saAction = 'PUT'
610cAC                   eval      $saTrn#U = *on
610cAC                   eval      $saTrn# = $pttrn#
610cAC                   eval      $saETrn#U = *on
610cAC                   eval      $saETrn# = 0
610cAC                   eval      $saLbl#U = *on
610cAC                   eval      $saLbl# = lblbl#
610cAC                   eval      $saToLcnsU = *on
610cAC                   eval      $saToLcns = $tinlic#
610aAC                   eval      $saToPosU = *on
610aAC                   eval      $saToPos = $tslotpos
610aAC                   eval      $saToVrfyU = *on
610aAC                   eval      $saToVrfy = 'N'
610aAC                   eval      $saToCodeu = *on
610aAC                   eval      $saToCode = 'S'
610aAC                   eval      $saToAreaU = *on
610aAC                   eval      $saToArea = 'Slot'
610aAC                   eval      $saFrmLcnsU = *on
610aAC                   eval      $saFrmLcns = $toutlic#
610aAC                   eval      $saOLcnsU = *on
610aAC                   eval      $saOLcns = rcv$lcns.$liOLcns
610aA
720dAc                   if        $tpartial = *on
720dAc                   eval      $saUCIts = $tpartime
720dAc                   eval      $saUCItsU = *on
720dAc                   endif

610aAC                   eval      $dricommand = '*SLOT'
610aAC                   if        $pttask = 'PUTRTN'
610aAC                   eval      $drisubcmd  = '%USR2RTN'
610aAC                   else
610aAC                   eval      $drisubcmd  = '%USR2PUT'
610aAC                   endif
610aAC                   eval      $drisys2upd = 'D'
610aAC                   eval      chk4err = *on
610aMC                   eval      zmflag = *on
610aAC                   exsr      zzzdricop
610aAC                   if        error
610aAC                   goto      endup2
610aAC                   endif
610aA*
610aA*   Update the LABEL record with slot.
610aA*
610aAC     lblbl#        chain     label                              79
610aAC                   if        not *in79
610aA*
610aAC                   eval      lbaisl = $slaisl
610aAC                   eval      lbloc = $slloc
610aAC                   eval      lbrlvl = $slrlvl
610aAC                   eval      lbhand = $slhand
610aAC                   eval      lbstyp = $slstyp
610aAC                   eval      lbdisp = $sldisp
610aAC                   if        $slstyp = 'P'
610aAC                   eval      lbqryf = 1
610aAC                   else
610aAC                   eval      lbqryf = 0
610aAC                   endif
610aA
610aAC                   eval      lbstat = 'C'
610aAC                   time                    lbstim
610aAC                   if        lbstim < lsttim
610aAC                   exsr      zzzdte
610aAC                   endif
610aAC                   eval      lbsdte = today
610aA*
610aAC                   update    lbrec                                79
610aAC                   if        *in79
610aAC                   move      *on           error
610aAC                   exsr      zm72
610aAC                   goto      endup2
610aAC                   endif
610aA*
610aAC                   endif
640kA*
640kA*    Close transaction and update label and slot records.
640kA*
640kAC                   exsr      zzclsp
     *
417qA*
500gM*    License tracking item. Do Putaway After update processing.
500gM*    Note, parms remembered from Before processing.
417qA*
500gMC                   eval      $tcmd   = '*PUTAWYA'
600dAC                   eval      $tlic#  = $tinlic#
417qAC                   exsr      zzzcall$lt210
610cAC                   eval      wuScanNbr = $toutlic#
610cAC                   exsr      zzuppk
416dA*
416dA*    Multiple license plates, labels scanned. Get next one.
     *
416dAC                   if        w5cnt > 0
416dAC                   exsr      zzdlp1
416dAC                   exsr      scr06i
416dA*
416dAC                   else
     *
501tA*    Check if any Interleaving Replenishments are available.
     *
501tAC                   exsr      zzckirpl
     *
501tA*    User has selected an Interleaving Replenishment.
     *
501tAC                   If        interlvrpl = '*YES'
501tAC                   exsr      scr09i
501tAC                   else
     C                   exsr      scr01i
501tAC                   endif
416dAC                   endif
416dA*
     C     endup2        endsr
     *
409 A*----------------------------------------------------------------
409 A*
409 A*  ZZUPD3   Update for screen 3.
409 A*
409 AC     zzupd3        begsr
409 AC                   move      *off          error
rylaAC                   eval      warnp = *off
409 AC                   eval      refrsh = *on
409 AC                   eval      w3rqty = w3rqty - w3qty
ISYa *  Update the "From" record.
ISYaAC                   if        Client = isupply
ISYaAC                   eval      lflbl# = lblbl#
ISYaAC                   eval      lftype = wotype
ISYbDC*                  eval      lffrom = wofrom
ISYbAC                   eval      lffloc = wofrom
ISYaAC                   write     lfrec                                79
ISYaAC                   if        *in79 = *on
ISYa C                   move      *on           error
ISYa C                   exsr      zm71
ISYa C                   goto      endup3
ISYa C                   endif
ISYa C                   endif
500gA
500gA*  License tracking item. Do Putaway Before update processing.
500gA
500gAC                   exsr      zzzclr$lt210
500gAC                   eval      $tcmd   = '*PUTAWYB'
500gAC                   eval      $titem  = lbitem
500gAC                   eval      $titemdsc = w3item
600dDC**                 eval      $twhdp  = lbwhdp
600dDC**                 eval      $tslot  = #todisp
600dMC                   eval      $twhdp  = lbwhdp
600dMC                   eval      $tslot  = w3scan
500gAC                   select
500gAC                   when      lbutyp = 'N'
500gAC                   eval      $tqty1  = w3qty
500kAC                   eval      $tnorm1 = w3qty
500gAC                   when      lbutyp = '1'
500gAC                   eval      $tqty2  = w3qty
500kAC                   eval      $tnorm2 = w3qty
500gAC                   when      lbutyp = '2'
500gAC                   eval      $tqty3  = w3qty
500kAC                   eval      $tnorm3 = w3qty
500gAC                   endsl
500gAC                   if        w3rqty > 0
500gAC                   eval      $tpartial = *on
500gAC                   else
500gAC                   eval      $tpartial = *off
500gAC                   endif
600dDC**                 eval      $tlic#  = wkpnbr
600eDC**                 eval      $tlic#  = wkplic
600eAC                   eval      $tlic#  = wuUsrLcns
500gAC                   exsr      zzzcall$lt210
500gAC                   select
500gAC                   when      $treturn = '*CANCEL'
700aAC                   eval      w3rqty = w3rqty + w3qty
500gAC                   goto      endup3
500gAC                   when      $treturn <> '*OK'
600eAC                   eval      error = *on
500gAC                   eval      *in21 = *on
500gAC                   eval      *in01 = *on
500gAC                   eval      errmsg = $terrmsg
500gAC                   exsr      zm0105
710cAC                   eval      w3rqty = w3rqty + w3qty
500gAC                   goto      endup3
500gAC                   endsl

510hA*   Call DRI interface to update From slot.

530bD ***                if        repack = Yes
530bD ***                exsr      zzupd3rpk
530bD ***                endif
600dA*
600dA*   Get new label # if necessary.
600dA*     Re: We need it so it can be sent to DRISLOT.
600dA*
600dAC                   if        newlb = *on
600dAC                   call      'PIRLBL#'
600dAC                   parm                    lblbl#
600dAC                   eval      newlbl# = lblbl#
600dAC                   endif
RylaA*   Allow override of differing expiration dates (bypass error)
RylaAC                   select
RylaAC                   when      client = royal
RylaAC                             and slpicke = *on
RylaAC                   exsr      zzexcpryl

CBIfAC                   when      client = cheney
CBIfAC                             and ovrrid  = *on
CBIfAC                             and $slpicke = '3'
CBIfAC                   exsr      zzexcpcbi
RylaAC                   endsl

500hA
500hA*   Call DRI interface to do update.
500hA
500hAC                   exsr      clr$slotw
500hAC                   eval      $slwhseu = *on
500hAC                   eval      $slwhse  = w1whse
500hAC                   eval      $slwhdpu = *on
500hAC                   eval      $slwhdp  = lbwhdp
500hAC                   eval      $sldispu = *on
500hAC                   eval      $sldisp  = w3scan
650gAC                   if        s_slstat = 'A'
650gAC                   eval      $slstatu = *off
650gAC                   eval      $slstat  = *blanks
650gAC                   else
640aAC                   eval      $slstatu = *on
640aAC                   eval      $slstat  = slstat
650gAC                   endif
500hAC                   eval      $slexpdu = *on
500hAC                   eval      $slexpd  = svexpd
600dAC                   eval      $sacwhdu = *on
600eDC**                 eval      $sacwhd  = wkuwhd
600eAC                   eval      $sacwhd  = wuUsrWhdp
600dAC                   eval      $sacdspu = *on
600eDC**                 eval      $sacdsp  = wkudsp
600eAC                   eval      $sacdsp  = wuUsrDisp
500hA
600cMC                   if        $pttask = 'PUTRTN'
500hAC                   eval      $slprtyu = *on
500hAC                   eval      $slprty  = -9
500hAC                   endif
500hA
500hAC                   eval      $saitemu = *on
500hAC                   eval      $saitem  = lbitem
500hAC                   eval      $saqtyu = *on
500hAC                   select
500hAC                   when      lbutyp = 'N'
500hAC                   eval      $saqty1 = w3qty
500hAC                   when      lbutyp = '1'
500hAC                   eval      $saqty2 = w3qty
500hAC                   when      lbutyp = '2'
500hAC                   eval      $saqty3 = w3qty
500hAC                   endsl
500hAC                   eval      $satrn#u = *on
600cMC                   eval      $satrn#  = $pttrn#
500hAC                   eval      $satasku = *on
600cMC                   eval      $satask  = $pttask
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'PUT'
600dAC                   eval      $saTrn#U = *on
600dAC                   eval      $saTrn# = $pttrn#
600dAC                   eval      $saETrn#U = *on
600dAC                   eval      $saETrn# = 0
600dAC                   eval      $saLbl#U = *on
600dAC                   eval      $saLbl# = lblbl#
600dAC                   eval      $saToLcnsU = *on
600dAC                   eval      $saToLcns = $tinlic#
600dAC                   eval      $saToPosU = *on
600dAC                   eval      $saToPos = $tslotpos
600dAC                   eval      $saToVrfyU = *on
600dAC                   eval      $saToVrfy = 'N'
600dAC                   eval      $saToCodeu = *on
600dAC                   eval      $saToCode = 'S'
600dAC                   eval      $saToAreaU = *on
600dAC                   eval      $saToArea = 'Slot'
600dAC                   eval      $saFrmLcnsU = *on
600dAC                   eval      $saFrmLcns = $toutlic#
600dAC                   eval      $saOLcnsU = *on
600dAC                   eval      $saOLcns = rcv$lcns.$liOLcns
500hA
720dAc                   if        $tpartial = *on
720dAc                   eval      $saUCIts = $tpartime
720dAc                   eval      $saUCItsU = *on
720dAc                   endif

500hAC                   eval      $dricommand = '*SLOT'
600cMC                   if        $pttask = 'PUTRTN'
600dDC**                 eval      $drisubcmd  = '%RETURN'
600dMC                   eval      $drisubcmd  = '%USR2RTN'
500hAC                   else
600dDC**                 eval      $drisubcmd  = '%PUTAWAY'
600dMC                   eval      $drisubcmd  = '%USR2PUT'
500hAC                   endif
500hAC                   eval      $drisys2upd = 'D'
500hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *on
500hAC                   exsr      zzzdricop
500hAC                   if        error
500iAC                   goto      endup3
500hAC                   endif
740aA
740aA*  Update warehouse-to-warehouse (GLOWWTFR) transfer for To slot.
740aA
740aA /free
740aA    monitor;
740aA      wwwhse = w1whse;
740aA      WWTFR('*TFRIN': $slaisl: $slloc: wwwhse: #user: wwrtn: wwmsg);
740aA    on-error;
740aA    endmon;
740aA /end-free
     *
     *   Update the LABEL record with slot.
     *
     C                   if        newlb = *off
     C     lblbl#        chain     label                              79
     C                   if        not *in79
     C                   z-add     w3qty         lbqpck
     C                   eval      lbqrmn = w3rqty
     C                   eval      lbqalc = w3aqty
     *
     *    Calculate cube and weight for put away qty.
     *
     C     sbucub        mult      w3qty         lbcube
     C                   eval      lbswgt = sbuwgt * w3qty
     *
     *    Move slot info to label record.
     *
500hMC                   eval      lbaisl = $slaisl
500hMC                   eval      lbloc = $slloc
500hMC                   eval      lbrlvl = $slrlvl
500hMC                   eval      lbhand = $slhand
500hMC                   eval      lbstyp = $slstyp
500hMC                   eval      lbdisp = $sldisp
500hMC                   if        $slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif

600dAC                   eval      lbstat = 'C'
600dAC                   time                    lbstim
600dAC                   if        lbstim < lsttim
600dAC                   exsr      zzzdte
600dAC                   endif
600dAC                   eval      lbsdte = today
     *
     C                   update    lbrec                                79
     C                   if        *in79
     C                   move      *on           error
     C                   exsr      zm72
     C                   goto      endup3
     C                   endif
     C                   move      *on           newlb
     C                   endif
     *
     C                   else
     C                   clear                   lbrec
     *
600dA*   Label# is now retreived before call to DRISLOT.
600dDC**                 call      'PIRLBL#'
600dDC**                 parm                    lblbl#
600dAC                   eval      lblbl# = newlbl#
     *
     *   Use saved label rec to create new label rec.
     *
     C                   eval      lbwhse = sbwhse
     C                   move      sbwhdp        lbwhdp
     C                   eval      lbqryf = sbqryf
     C                   move      sbdsp2        lbdsp2
     C                   move      sbitem        lbitem
     C                   move      sbutyp        lbutyp
     C                   move      sbucod        lbucod
     C                   eval      lbucub = sbucub
     C                   eval      lbuwgt = sbuwgt
     C                   eval      lbseq = sbseq
     C                   eval      lbpbat = sbpbat
     C                   move      sbpo          lbpo
     C                   eval      lbord = sbord
     C                   eval      lbtie = sbtie
     C                   eval      lbhigh = sbhigh
     C                   move      sbgrp1        lbgrp1
     C                   move      sbgrp2        lbgrp2
     C                   move      sbtype        lbtype
     C                   eval      lbpal# = sbpal#
     C                   eval      lbtrn# = sbtrn#
     C                   eval      lbrdte = sbrdte
600dDC**                 move      sbstat        lbstat
     *
     C                   z-add     w3qty         lbqpck
     C                   eval      lbqrmn = w3rqty
     C                   eval      lbqalc = w3aqty
     *
     *    Calculate cube and weight for put away qty.
     *
     C     sbucub        mult      w3qty         lbcube
     C                   eval      lbswgt = sbuwgt * w3qty
     *
     *    Move slot info to label record.
     *
500hMC                   eval      lbaisl = $slaisl
500hMC                   eval      lbloc = $slloc
500hMC                   eval      lbrlvl = $slrlvl
500hMC                   eval      lbhand = $slhand
500hMC                   eval      lbstyp = $slstyp
500hMC                   eval      lbdisp = $sldisp
500hMC                   if        $slstyp = 'P'
     C                   eval      lbqryf = 1
     C                   else
     C                   eval      lbqryf = 0
     C                   endif

600dAC                   eval      lbstat = 'C'
600dAC                   time                    lbstim
600dAC                   if        lbstim < lsttim
600dAC                   exsr      zzzdte
600dAC                   endif
600dAC                   eval      lbsdte = today
     *
     C                   write     lbrec                                79
     C                   if        *in79
     C                   move      *on           error
     C                   exsr      zm71
     C                   goto      endup3
     C                   endif
600dD **
600dD **  Update license history record with new lbl#
600dD **
600dDC**                 eval      kylcns  = wkpnbr
600dDC**                 eval      newtrn# = lbtrn#
600dDC**                 eval      newlbl# = lblbl#
600dDC**                 exsr      zzupdtrnlbl
600a
501g C                   if        itflgd='Y'
     *
500b *   Use saved POMFR rec to create new POMFR rec.
     *
CBI  *    added clear w BFC use of pomfr1/cheney pomfr2
CBI0AC                   if        client = cheney
CBI0AC                   clear                   pmrec2
CBI0AC                   else
500b C                   clear                   pmrec
CBI0AC                   endif
500b C                   eval      pmwhse = pswhse
500b C                   eval      pmpo = pspo
500b C                   eval      pmseq = psseq
500b C                   eval      pmitem = psitem
500b C                   eval      pmexpd = psexpd
500b C                   eval      pmmfgd = psmfgd
500b C                   eval      pmtrn# = lbtrn#
500b C                   eval      pmlbl# = lblbl#
CBI0AC                   if        client = cheney
CBI0AC                   write     pmrec2                               79
CBI0AC                   else
500b C                   write     pmrec                                79
CBI0AC                   endif
500b C                   if        *in79
500b C                   eval      error = *on
500b C                   exsr      zm71
500b C                   goto      endup3
500b C                   endif
500b *
501g C                   endif
     C                   endif
600dA
600dA*    Update License information
600dA
600dAC*                  exsr      clr$license
600dA
600dAC*                  eval      $liLTrnU = *on
600dAC*                  eval      $liLTrn = 0
600dAC*                  eval      $liActionU = *on
600dAC*                  eval      $liAction = 'PUT'
600dAC*                  eval      $liTrn#U = *on
600dAC*                  eval      $liTrn# = $pttrn#
600dAC*                  eval      $liETrn#U = *on
600dAC*                  eval      $liETrn# = 0
600dAC*                  eval      $liLbl#U = *on
600dAC*                  eval      $liLbl# = lblbl#
600dAC*                  eval      $liToLcnsU = *on
600dAC*                  eval      $liToLcns = $tinlic#
600dAC**                 eval      $liOLcnsU = *on
600dAC**                 eval      $liOLcns = rcv$lcns.$liOLcns
600dAC*                  eval      $liToItemU = *on
600dAC*                  eval      $liToItem = $saitem
600dA
600dAC*                  eval      $liAQty1U = *on
600dAC*                  eval      $liAQty1 = $saqty1
600dAC*                  eval      $liAQty2 = $saqty2
600dAC*                  eval      $liAQty3 = $saqty3
600dA
600dAC*                  eval      $liToRQty1U = *on
600dAC*                  eval      $liToRQty1 = $saqty1
600dAC*                  eval      $liToRQty2 = $saqty2
600dAC*                  eval      $liToRQty3 = $saqty3
600dA
600dAC*                  eval      $liToCodeu = *on
600dAC*                  eval      $liToCode = 'S'
600dAC*                  eval      $liToAreaU = *on
600dAC*                  eval      $liToArea = 'Slot'
600dAC*                  eval      $liToWhdpU = *on
600dAC*                  eval      $liToWhdp = $slwhdp
600dAC*                  eval      $liToDispU = *on
600dAC*                  eval      $liToDisp = $sldisp
600dAC*                  eval      $liToAislu = *on
600dAC*                  eval      $liToAisl = $slaisl
600dAC*                  eval      $liToLocU = *on
600dAC*                  eval      $liToLoc = $slloc
600dAC*                  eval      $liToRlvlU = *on
600dAC*                  eval      $liToRlvl = $slrlvl
600dAC*                  eval      $liToHandU = *on
600dAC*                  eval      $liToHand = $slhand
600dAC*                  eval      $liToPosU = *on
600dAC*                  eval      $liToPos = $tslotpos
600dA
600dAC*                  eval      $liFrmNewLcnsU = *on
600dAC*                  eval      $liFrmNewLcns = $toutlic#
600dAC*                  eval      $liFrmOldLcnsU = *on
600dAC*                  eval      $liFrmOldLcns = rcv$lcns.$liToLcns
600dA
600dAC*                  eval      $liFrmRQty1U = *on
600dAC*                  eval      $liFrmRQty1 = $saqty1
600dAC*                  eval      $liFrmRQty2 = $saqty2
600dAC*                  eval      $liFrmRQty3 = $saqty3
600dA
600dAC*                  eval      $liFrmWhseU = *on
600dAC*                  eval      $liFrmWhse = wkuwhs
600dAC*                  eval      $liFrmWhdpU = *on
600dAC*                  eval      $liFrmWhdp = wkuwhd
600dAC*                  eval      $liFrmDispU = *on
600dAC*                  eval      $liFrmDisp = wkudsp
600dAC*                  eval      $liFrmItemU = *on
600dAC*                  eval      $liFrmItem = $saitem
600dA
600dAC*                  eval      $dricommand = '*LICENSE'
600dAC*                  eval      $drisubcmd  = '%TFRLCNS'
600dAC*                  eval      $drisys2upd = 'D'
600dAC*                  eval      chk4err = *on
600dAC*                  eval      zmflag  = *off
600dAC*                  exsr      zzzdricop
600dAC*                  if        error
600dAC*                  eval      *in22 = *on
600dAC*                  eval      *in02 = *on
600dAC*                  eval      errmsg = 'Error updating LICACTIVE '
600dAC*                                   + '('
600dAC*                                   + %trim(w1lcns)
600dAC*                                   + '/'
600dAC*                                   + %trim($sldisp)
600dAC*                                   + ')'
600dAC*                  exsr      zm0105
600dAC*                  exsr      zm0001
600dAC*                  leavesr
600dAC*                  endif
     *
409 AC                   eval      w3aqty = w3rqty
409 AC                   if        w3rqty > 0
409 AC                   eval      w3scan = *blanks
610dAC                   eval      w3odsg = *blanks
409 AC                   eval      w3qty = w3rqty
412CAC                   eval      *in92 = *on
417qA
500gM*    License tracking item. Do Putaway After update processing.
500gM*    Note, parms remembered from Before processing.
417qA
500gMC                   eval      $tcmd   = '*PUTAWYA'
417qAC                   eval      $twhdp  = $slwhdp
417qAC                   eval      $tslot  = $sldisp
600dAC                   eval      $tlic#  = $tinlic#
417qAC                   exsr      zzzcall$lt210
600eDC**                 eval      wkpnbr = $toutlic#
600eAC                   eval      wuScanNbr = $toutlic#
600dAC                   exsr      zzuppk
700dA*
700dA*      Send completion message to user.
700dAC                   eval      errmsg = ' '
700dAC                   eval      erlcns = $tinlic#
700dAC                   eval      erdisp2 = $sldisp
700dAC                   exsr      zm2030
417qA
     C                   else
417qA
412CAC                   eval      *in92 = *off
417i C                   exsr      zzclsp
417qA
417qA*    License tracking item. Do Putaway After update processing.
500gM*    Note, parms remembered from Before processing.
417qA
500gMC                   eval      $tcmd   = '*PUTAWYA'
417qAC                   eval      $twhdp  = $slwhdp
417qAC                   eval      $tslot  = $sldisp
600dAC                   eval      $tlic#  = $tinlic#
417qAC                   exsr      zzzcall$lt210
600eDC**                 eval      wkpnbr = $toutlic#
600eAC                   eval      wuScanNbr = $toutlic#
600dAC                   exsr      zzuppk
700dA*
700dA*      Send completion message to user.
700dAC                   eval      errmsg = ' '
710cDC*                  eval      erlcns = $toutlic#
710cMC                   eval      erlcns = $tinlic#
700dAC                   eval      erdisp2 = $sldisp
700dAC                   exsr      zm2030

650iA*    When called from PO236, you're done, go back to PO236.
650iA*    RC200 gets called from PO236 when PO236 gets called from
650iA*    RC180 which allows user to receive an item without a PO.
650iA
650iAC                   if        $pprg2 = 'PO236'
650iAC                   move      'EOJ'         nxtscr
650iAC                   goto      endup3
650iAC                   endif
750bA*
750bA*    Using pallet License for put away. Update pltlcns file
750bA*
750bA /free
750bA   chain (w1whse:holdrtnplt:wuUsrLcns) pltlcns;
750bA   if %found(pltlcns);
750bA     exsr zzgetcurrstamp;
750bA     rnlputts = currstampsys;
750bA     rnlputuc = currstampuc;
750bA     rnlput = 'Y';
750bA     update rnlrec;
750bA   endif;
750bA /end-free
416dA*
416dA*    Multiple license plates, labels scanned. Get next one.
     *
416dAC                   if        w5cnt > 0
416dAC                   exsr      zzdlp1
416dAC                   exsr      scr06i
416dA*
416dAC                   else
     *
501tA*    Check if any Interleaving Replenishments are available.
     *
501tAC                   eval      $rcmd = '*START  '
501tAC                   exsr      zzckirpl
     *
501tA*    User has selected an Interleaving Replenishment.
     *
501tAC                   If        interlvrpl = '*YES'
501tAC                   exsr      scr09i
501tAC                   else
409 AC                   exsr      scr01i
501tAC                   endif
416dAC                   endif
     C                   endif
416dA*
409 AC     endup3        endsr
510hA*----------------------------------------------------------------
510hA*
510hA*  ZZUPD3rpk   Update for screen 3.(Screen3) Repack Putaway.
510hA*
510hAC     zzupd3rpk     begsr

510hA*  Get repack item from slot.

510hAC                   eval      #fromsldisp = *blanks
510hAC                   eval      kywhse = w1whse
510hAC                   eval      kyitem = lbitem
510hAC                   eval      k3stat = 'RP'
510hAC                   eval      kypick = 'N'
510hAC     keys3a        chain     slot3
510hAC                   if        %found(slot3)
510hAC                   eval      #fromsldisp = sldisp
510hAC                   endif

510hA*  Use DRI interface to update From slot.

510hAC                   exsr      clr$slotw
510hAC                   eval      $slwhseu  = *on
510hAC                   eval      $slwhse   = w1whse
510hAC                   eval      $slwhdpu  = *on
510hAC                   eval      $slwhdp   = lbwhdp
510hAC                   eval      $sldispu  = *on
510hAC                   eval      $sldisp   = #fromsldisp
510hAC                   eval      $saitemu  = *on
510hAC                   eval      $saitem   = lbitem
510hAC                   eval      $saqtyu   = *on
510hAC                   eval      $saqty1   = w3qty
510hAC                   eval      $saqty2   = *zeros
510hAC                   eval      $saqty3   = *zeros
510hAC                   eval      $sacitemu = *on
510hAC                   eval      $sacitem  = lbitem

510hAC                   eval      $dricommand = '*SLOT'
510hAC                   eval      $drisubcmd  = '%TFROUTCHG'
510hAC                   eval      $drisys2upd = 'D'
510hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *on
510hAC                   exsr      zzzdricop
510hAC                   if        error
510hAC                   endif

510hA*  Use DRI interface to update From slot.

510hAC                   exsr      clr$slotw
510hAC                   eval      $slwhseu  = *on
510hAC                   eval      $slwhse   = w1whse
510hAC                   eval      $slwhdpu  = *on
510hAC                   eval      $slwhdp   = lbwhdp
510hAC                   eval      $sldispu  = *on
510hAC                   eval      $sldisp   = #fromsldisp
510hAC                   eval      $saitemu  = *on
510hAC                   eval      $saitem   = lbitem
510hAC                   eval      $saqtyu   = *on
510hAC                   eval      $saqty1   = w3qty
510hAC                   eval      $saqty2   = *zeros
510hAC                   eval      $saqty3   = *zeros
510hAC                   eval      $saorgu   = *on
510hAC                   eval      $saorg1   = w3qty
510hAC                   eval      $saorg2   = *zeros
510hAC                   eval      $saorg3   = *zeros
510hAC                   eval      $sacitemu = *on
510hAC                   eval      $sacitem  = lbitem

510hAC                   eval      $dricommand = '*SLOT'
510hAC                   eval      $drisubcmd  = '%CLSTFOCHG'
510hAC                   eval      $drisys2upd = 'D'
510hAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *on
510hAC                   exsr      zzzdricop
510hAC                   if        error
510hAC                   endif

510hAC                   endsr
415kA*----------------------------------------------------------------
415kA*
415kA*  ZZUPD4   Update for screen 4.(Screen1A)
415kA*
415kAC     zzupd4        begsr
     C                   move      *off          error
     C                   move      *on           refrsh
     *
416dA*    License plate/label scanned in. Add to work file.
     *
416dAC                   select
600aDC                   when      opmscn = 'Y'
600dDC**                 when      ptatyp = '*LICENSE'  and
600dDC**                           opmscn = 'Y'  or
600dDC**                           ptatyp = '*LABEL  '  and
600dDC**                           opmscn = 'Y'
416dA*
416dA*    License# scanned last time.
     *
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
416dAC                   eval      w5txt = w5txt1
416dA*
416dAC                   select
     *
416dA*      Load last scanned value.
     *
416dAC                   when      lstscr = '05 '
416fMC                   eval      w5lst# = w5lcns
416dAC                   other
416fMC                   eval      w5lst# = w1lcns
416dAC                   endsl
416dA*
416dA*    Label scanned last time.
     *
416dAC                   when      ptatyp = '*LABEL  '
416dAC                   eval      w5txt = w5txt2
416dAC                   select
     *
416dA*      Load last scanned value.
     *
416dAC                   when      lstscr = '05 '
416fMC                   move      w5lbl#        w5lst#
416dAC                   other
416fMC                   move      w1lbl#        w5lst#
416dAC                   endsl
416dAC                   endsl
416dA*
416dA*    Add lic#/lbl# to work file.
     *
416dAC                   exsr      zzadpk
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
416dA*
416dA*    Setup to scan more entries.
     *
416dAC                   exsr      scr05i
416dA*
416dA*   Transaction# scanned in. Process as one.
     *
416dAC                   other

PFCaAc                   select
PFCaAc                   when      logapt
PFCaAc                   z-add     lbqpck        worqty
PFCaAc                   exsr      scr07i
PFCaA
PFCaAc                   other
PFCaA
ISYaAC                   if        Client = isupply
ISYaAC                   z-add     lbqpck        worqty            5 0
ISYaAC                   exsr      scr09ai
ISYaA*    The following code will be executed in ZZUPD9A
ISYaAC                   goto      jmp4
ISYaAC                   endif
600dA
600dAC                   exsr      zzadpk
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
600dA
600dAC                   exsr      zzstrt
600dAC                   move      lbitem        gtitem
600dAC                   exsr      zzgeti
416dA*
     C                   if        lbdsp2 = '*MANUAL'
     C                   eval      worqty = lbqpck
     C                   exsr      scr03i
     C                   else
     C                   exsr      scr02i
     C                   endif
ISYa C     jmp4          tag
PFCaA*
PFCaAc                   endsl
416dAC                   endsl
416dA*
     C     endup4        endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZUPD5   Update for screen 5.
416dA*
416dAC     zzupd5        begsr
TMPaAC                   eval      currRoutine = 'zzupd5'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   move      *off          error
     *
416dAC                   select
     *
416dA*    End of scanned entries - proceed to putaway.
     *
416fMC                   when      w5lcns = *blanks  and
416dAC                             w5lbl# = *zeros
416dA*
416dAC                   select
     *
416dA*    Only 1 entry scanned - Go to putaway screen.
     *
416dAC                   when      w5cnt = 1
600cD**
600cD**   Get current task.
600cD**
600cD**                  eval      curtsk = *blanks
600cD**                  eval      curtyp = *blanks
600cD**                  move      *off          curent
600cD**                  exsr      zztask
600cD**                  select
600cD**                  when      curtyp = 'D'
600cD**
600cD**   End current task.
600cD**
600cD**                  exsr      zzend
600cD**                  when      curtyp = 'I'
600cD**
600cD**  End current task and any previous open tasks.
600cD**
600cD**                  move      *on           found
600cD**                  dow       found = *on
600cD**                  eval      curtsk = *blanks
600cD**                  eval      curtyp = *blanks
600cD**                  move      *off          curent
600cD**                  exsr      zztask
600cD**                  if        found = *off
600cD**                  leave
600cD**                  endif
600cD**                  exsr      zzend
600cD**                  enddo
600cD**                  endsl
416hA*
416hA*      User returned to this display from later
416hA*      display.  Refresh transaction record to have
416hA*      the correct data after creating/closing Idle
416hA*      transaction records.
     *
416hAC                   select
416hAC                   when      frstps = *off
     *
416hA*    Build key to work file to retrieve transaction#.
     *
416hAC                   select
     *
416hA*      Last record scanned - License plate.
     *
416hAC                   when      ptatyp = '*LICENSE'
600eDC**                 eval      wkptyp = 'P'
600eAC                   eval      wuScanType = 'P'
     *
416hA*      Last record scanned - Label.
     *
416hAC                   when      ptatyp = '*LABEL '
600eDC**                 eval      wkptyp = 'L'
600eAC                   eval      wuScanType = 'L'
416hAC                   endsl
600eDC**                 eval      wkpnbr = w5lst#
600eAC                   eval      wuScanNbr = w5lst#
     *
416hA*    Retrieve transaction#.
     *
600eDC**   pkkey1        setll     workput
600eDC**   pkkey1        reade(n)  workput                        79
600jMC     wkKey2p       setll     workUsr2
600jMC     wkKey2p       reade(n)  workUsr2                               79
416hAC                   select
416hAC                   when      *in79
600eDC**                 eval      wkptrn = *zeros
600eAC                   eval      wuTrn# = *zeros
416jAC                   move      *on           error
416jAC                   eval      errmsg = w5err1
416jAC                   exsr      zm0105
416jAC                   goto      endup5
416hAC                   endsl
600eDC**                 eval      wotrn# = wkptrn
600eAC                   eval      wotrn# = wuTrn#
416hA*
416hA*    Retrieve transaction# record.
     *
600cDC**   ptkey         chain(n)  pirtran                            79
600cAC                   eval      gttrn# = wotrn#
TMPaAC                   eval      currRoutine = 'zzgett'
TMPaAC                   exsr      phpgmV1V2V3s
600cAC                   exsr      zzgett
TMPaAC                   exsr      phpgmV1V2V3e
416hA*
416hA*    Putaway transaction no longer at open status.
     *
600cDC**                 if        not *in79  and
600cMC                   if        trnFound  and
600cMC                             $ptstat <> '1'
416hAC                   move      *on           error
416hAC                   eval      errmsg = *blanks
600cMC                   eval      ertrn# = wotrn#
416hAC                   exsr      zm2002
416hAC                   goto      endup5
416jAC                   else
600cDC**                 if        *in79
600cMC                   if        not trnFound
416jAC                   move      *on           error
416jAC                   eval      errmsg = w5err1
416jAC                   exsr      zm0105
416jAC                   goto      endup5
416jAC                   endif
416hAC                   endif
416hAC                   endsl
416hAC                   move      *off          frstps
416dA*
416dA*    Retrieve label record for writing to work file.
416dA*
TMPaAC                   eval      currRoutine = 'zzstrt'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      zzstrt
TMPaAC                   exsr      phpgmV1V2V3e
511cAC                   move      lbitem        gtitem
TMPaAC                   eval      currRoutine = 'zzgeti'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      zzgeti
TMPaAC                   exsr      phpgmV1V2V3e
ISYaAC                   if        Client = isupply
ISYaAC                   z-add     lbqpck        worqty
ISYaAC                   move      '05 '         lstscr
ISYaAC                   exsr      scr09ai
ISYaA*    The following code will be executed in ZZUPD9A
ISYaAC                   goto      jmp5
ISYaAC                   endif
416dA*
416dAC                   if        lbdsp2 = '*MANUAL'
416dAC                   eval      worqty = lbqpck
416dAC                   move      '05 '         lstscr
TMPaAC                   eval      currRoutine = 'scr03i'
TMPaAC                   exsr      phpgmV1V2V3s
416ddC                   exsr      scr03i
TMPaAC                   exsr      phpgmV1V2V3e
416dAC                   else
416dAC                   move      '05 '         lstscr
416dAC                   exsr      scr02i
416dAC                   endif
ISYaAC     jmp5          tag
416dA*
416dA*    More than 1 entry scanned - Go to select screen.
     *
416dAC                   when      w5cnt > 1
416dAC                   move      '05 '         lstscr
416nAC                   move      *off          skip6
TMPaAC                   eval      currRoutine = 'scr06i'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      scr06i
TMPaAC                   exsr      phpgmV1V2V3e
416dA*
416dAC                   endsl
416dA*
416dA*    Have user verify qty from pallet to license plate.
     *
416dAC                   when      oppqty = 'Y'
416dA*
416dA*    Retrieve label record for writing to work file.
     *
416dAC     lbkey7        setll     label7
416dAC     lbkey7        reade     label7                                 79
416dA*
416dA*    Add license plate to work file.
     *
416dAC                   select
416dAC                   when      ptatyp = '*LICENSE'
416fMC                   move      w5lcns        svpnbr
416dAC                   move      'P'           svptyp
     *
416dA*    Add label to work file.
     *
416dAC                   when      ptatyp = '*LABEL  '
600iMC                   eval      svpnbr = %editc(w5lbl#:'X')
416dAC                   move      'L'           svptyp
416dAC                   endsl
416dAC                   move      '05 '         lstscr
416dA*
TMPaAC                   eval      currRoutine = 'scr04i'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      scr04i
TMPaAC                   exsr      phpgmV1V2V3e
416dA*
416dA*    Otherwise, go back to scan in more plates/labels.
     *
416dAC                   other
416dA*
416dA*    Retrieve label record for writing to work file.
     *
416dAC     lbkey7        setll     label7
416dAC     lbkey7        reade     label7                                 79
416dAC                   select
     *
416dA*    Add license plate to work file.
     *
416dAC                   when      ptatyp = '*LICENSE'
416dAC                   eval      w5txt = w5txt1
416fMC                   eval      w5lst# = w5lcns
416fMC                   eval      svpnbr = w5lcns
416dAC                   move      'P'           svptyp
TMPaAC                   eval      currRoutine = 'zzadpk'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      zzadpk
TMPaAC                   exsr      phpgmV1V2V3e
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
TMPaAC                   eval      currRoutine = 'scr05i'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      scr05i
TMPaAC                   exsr      phpgmV1V2V3e
416dA*
416dA*    Add label to work file.
     *
416dAC                   when      ptatyp = '*LABEL  '
416dAC                   eval      w5txt = w5txt2
600iMC                   eval      w5lst# = %editc(w5lbl#:'X')
600iMC                   eval      svpnbr = %editc(w5lbl#:'X')
416jMC                   move      'L'           svptyp
TMPaAC                   eval      currRoutine = 'zzadpk'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      zzadpk
TMPaAC                   exsr      phpgmV1V2V3e
600dAC                   if        error
600dAC                   leavesr
600dAC                   endif
TMPaAC                   eval      currRoutine = 'scr05i'
TMPaAC                   exsr      phpgmV1V2V3s
416dAC                   exsr      scr05i
TMPaAC                   exsr      phpgmV1V2V3e
416dAC                   endsl
416dAC                   endsl
416dA*
TMPaAC     endup5        tag
TMPaAC                   exsr      phpgmV1V2V3e
TMPaDC**   endup5        endsr
TMPaMC                   endsr
416dA*----------------------------------------------------------------
416dA*
416dA*  ZZUPD6   Update for screen 6.
416dA*
416dAC     zzupd6        begsr
416dAC                   move      *off          error
416dA*
416dA*    Proceed to putaway.
416dA*
600cD**   Get current task.
600cD**
600cD**                  eval      curtsk = *blanks
600cD**                  eval      curtyp = *blanks
600cD**                  move      *off          curent
600cD**                  exsr      zztask
600cD**                  select
600cD**                  when      curtyp = 'D'
600cD**
600cD**   End current task.
600cD**
600cD**                  exsr      zzend
600cD**                  when      curtyp = 'I'
600cD**
600cD**  End current task and any previous open tasks.
600cD**
600cD**                  move      *on           found
600cD**                  dow       found = *on
600cD**                  eval      curtsk = *blanks
600cD**                  eval      curtyp = *blanks
600cD**                  move      *off          curent
600cD**                  exsr      zztask
600cD**                  if        found = *off
600cD**                  leave
600cD**                  endif
600cD**                  exsr      zzend
600cD**                  enddo
600cD**                  endsl
416dA*
416dAC                   select
     *
416dA*    User scanned in a license plate.
     *
416dAC                   when      ptatyp = '*LICENSE'
416dAC                   eval      wotrn# = litrn#
416dA*
416dA*    User scanned in a label.
     *
416dAC                   when      ptatyp = '*LABEL  '
416dAC                   eval      wotrn# = lktrn#
416dA*
416dAC                   endsl
     *
     *   Get transaction record for put-away.
     *
600cDC**   ptkey         chain(n)  pirtran                            79
600cAC                   eval      gttrn# = wotrn#
600cAC                   exsr      zzgett
     *
     *     Record not found.
     *
600cDC**                 if        *in79
600cMC                   if        not trnFound
     C                   move      *on           error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
501uAC                   select
501uAC                   when      e$lng = 'SP'
501uAC                   eval      errmsg = descsp(1)
501uAC                   other
     C                   eval      errmsg = desc(1)
501uAC                   endsl
     C                   exsr      zm7979
     C                   goto      endup6
     C                   endif
     *
     *   Start new transaction.
     *
     C                   exsr      zzstrt
511cAC                   move      lbitem        gtitem
     C                   exsr      zzgeti
PFCaA*
PFCaA*    Reset APT flags for next put-away.
PFCaAC                   if        logapt
PFCaA*    Chg'd so that only one "obtain" is created when 2+
PFCaA*    license plates/labels scanned.
PFCaAc                   move      '*NO '        putplc
PFCaAc                   move      *zeros        apseq#
PFCaAc                   move      watype        wotype
PFCaAc                   move      wafrom        wofrom
PFCaAc                   endif

ISYaAC                   if        Client = isupply
ISYaAC                   z-add     lbqpck        worqty
ISYaAC                   move      '06 '         lstscr
ISYaAC                   exsr      scr09ai
ISYaA*    The following code will be executed in ZZUPD9A
ISYaAC                   goto      jmp6
ISYaAC                   endif
416dA*
416dAC                   if        lbdsp2 = '*MANUAL'
416dAC                   eval      worqty = lbqpck
416dAC                   move      '06 '         lstscr
416ddC                   exsr      scr03i
416dAC                   else
416dAC                   move      '06 '         lstscr
416dAC                   exsr      scr02i
416dAC                   endif
ISYaAC     jmp6          tag
416dA*
416daC     endup6        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZUPD7   Update for screen 7.
417i *
417iAC     zzupd7        begsr
417i C                   move      *off          error
417i *
417i *  Display screen 8. Screen fields already initialized.
417i *
417i C                   move      '08 '         nxtscr
417i C                   exsr      scr08i
     *
417iAC     endup7        endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZUPD8   Update for screen 8.
417i *
417iAC     zzupd8        begsr
417i C                   move      *off          error
     *
417n *  Create stage transaction record.
417n *
417n C                   exsr      zzstag
600dA
600dA*   Call DRI interface to do update.
600dA
600dAC                   exsr      clr$slot
600dAC                   eval      $slwhseu = *on
600eDC**                 eval      $slwhse  = wkuwhs
600eAC                   eval      $slwhse  = wuWhse
600dAC                   eval      $slwhdpu = *on
600eDC**                 eval      $slwhdp  = wkuwhd
600eAC                   eval      $slwhdp  = wuUSrWhdp
600dAC                   eval      $sldispu = *on
600eDC**                 eval      $sldisp  = wkudsp
600eAC                   eval      $sldisp  = wuUsrDisp
600dAC                   eval      $saitemu = *on
600dAC                   eval      $saitem  = lbitem
600dA
600dAC                   eval      $saqtyu = *on
600dAC                   select
600dAC                   when      lbutyp = 'N'
600dAC                   eval      $saqty1 = w3rqty
600dAC                   when      lbutyp = '1'
600dAC                   eval      $saqty2 = w3rqty
600dAC                   when      lbutyp = '2'
600dAC                   eval      $saqty3 = w3rqty
600dAC                   endsl
600dA
600dAC                   eval      $satrn#u = *on
600dAC                   eval      $satrn#  = pntrn#
600dAC                   eval      $satasku = *on
600dAC                   eval      $satask  = $pttask
600dA
600dAC                   eval      $saActionU = *on
600dAC                   eval      $saAction = 'STG'
600dAC                   eval      $saTrn#U = *on
600dAC                   eval      $saTrn# = pntrn#
600dAC                   eval      $saETrn#U = *on
600dAC                   eval      $saETrn# = 0
600dAC                   eval      $saLbl#U = *on
600dAC                   eval      $saLbl# = lblbl#
600dAC                   eval      $saToLcnsU = *on
600eDC**                 eval      $saToLcns = wkplic
600eAC                   eval      $saToLcns = wuUsrLCns
600dAC                   eval      $saOLcnsU = *on
600dAC                   eval      $saOLcns = rcv$lcns.$liOLcns
600dAC                   eval      $saToPosU = *on
600dAC                   eval      $saToPos = 1
600dAC                   eval      $saToVrfyU = *on
600dAC                   eval      $saToVrfy = 'Y'
600dAC                   eval      $saToCodeu = *on
600dAC                   eval      $saToCode = 'A'
600dAC                   eval      $saToAreaU = *on
620 DC*                  eval      $saToArea = w7zone
DRYaAC                   select
DRYaAC                   when      client = dairyland
DRYaAC                   eval      $saToArea = %subst(w7scan:2)
DRYaAC                   other
620 MC                   eval      $saToArea = w7scan
DRYaAC                   endsl
600dA
600dAC                   eval      $dricommand = '*SLOT'
600dMC                   eval      $drisubcmd  = '%USR2STG'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dMC                   eval      zmflag = *on
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   goto      endup8
600dAC                   endif
610eA
610eA*        Update label with RCV/STG/OSS slot.
610eA
610eAC     lblbl#        chain     label
610eAC                   if        %found(label)
610eAC                   eval      lbaisl = $slaisl
610eAC                   eval      lbloc = $slloc
610eAC                   eval      lbrlvl = $slrlvl
610eAC                   eval      lbhand = $slhand
610eAC                   eval      lbdisp = $sldisp
610eAC                   update(e) lbrec
610eAC                   if        %error
610eAC                   endif
610eAC                   endif
417i *
417i *  Create staging license record.
417i *
417i C                   eval      liwhse = w1whse
600eDC**                 eval      lilcns = wkpnbr
600eAC                   eval      lilcns = wuScanNbr
417i C                   eval      litrn# = pntrn#
417i C                   write     lirec                                79
500aA
500aA*    License tracking item. Mark tracking record(s) putaway/closed.
500aA
500aAC                   exsr      zzzclr$lt210
500aAC                   eval      $tcmd   = '*PUTAREA'
500aAC                   eval      $titem  = #oitem
500aAC                   eval      $titemdsc = w8item
500aAC                   eval      $tslot  = w7scan
500aAC                   select
500aAC                   when      lbutyp = 'N'
500aAC                   eval      $tqty1  = w3rqty
500kAC                   eval      $tnorm1 = w3rqty
500aAC                   when      lbutyp = '1'
500aAC                   eval      $tqty2  = w3rqty
500kAC                   eval      $tnorm2 = w3rqty
500aAC                   when      lbutyp = '2'
500aAC                   eval      $tqty3  = w3rqty
500kAC                   eval      $tnorm3 = w3rqty
500aAC                   endsl
500aAC                   eval      $tpartial = *off
500aAC                   eval      $tlic#  = w8lic#
500aAC                   exsr      zzzcall$lt210
417i *
417i *  No more to stage, close transaction.
417i *
417i C                   exsr      zzclse
PFCaA*
PFCaAc                   move      'APT'         nxtscr
PFCaAc                   exsr      scrapti
417i *
417i *    Multiple license plates, labels scanned. Get next one.
     *
417i C                   if        w5cnt > 0
417i C                   exsr      zzdlp1
417i C                   exsr      scr06i
417i *
417i C                   else
417i C                   exsr      scr01i
417i C                   endif
417i *
417iAC     endup8        endsr
PFCaA*----------------------------------------------------------------
PFCaA*
PFCaA*  ZZUPDAPT  Update for aptscrn.
PFCaA*
PFCaAc     zzupdapt      begsr
PFCaA
PFCaAc                   move      *off          error
PFCaAc                   move      *on           refrsh
PFCaAc                   move      watype        wotype            1
PFCaAc                   move      wafrom        wofrom           12
PFCaAc                   move      *zeros        apseq#
PFCaAc                   move      '*NO '        putbeg
PFCaAc                   move      '*NO '        putplc
PFCaAc                   move      '*NO '        putend
PFCaA
PFCaAc*-------------------------------------------------------------------
PFCaAc                   select
PFCaAc*    Perform qty check for lic#/lbl#/trn# scanned in.
PFCaAc                   when      oppqty = 'Y'
PFCaAc                   exsr      scr04i
PFCaAc*    Process scanned in transaction number.
PFCaAc                   when      ptatyp = '*TRAN   '
PFCaA
PFCaAc                   if        lbdsp2 = '*MANUAL'
PFCaAc                   z-add     lbqpck        worqty            5 0
PFCaAc                   move      '01 '         lstscr
PFCaAc                   exsr      scr03i
PFCaAc                   else
PFCaAc                   move      '01 '         lstscr
PFCaAc                   exsr      scr02i
PFCaAc                   endif
PFCaA
PFCaAc*    Process scanned in license plate or label number.
PFCaAc                   other
PFCaAc                   exsr      scr05i
PFCaA
PFCaAc                   endsl
PFCaA
PFCaAC     endupapt      endsr
ISYa *----------------------------------------------------------------
ISYa *
ISYaA*  ZZUPD9A  Update for screen 9.
ISYa *
ISYaAC     zzupd9a       begsr
ISYa C                   move      *off          error
ISYa C                   move      *on           refrsh
ISYa C                   move      w9atype       wotype            1
ISYa C                   move      w9afrom       wofrom           12
ISYa *
ISYa C                   if        lbdsp2 = '*MANUAL'
ISYa C                   z-add     lbqpck        worqty            5 0
ISYa C                   exsr      scr03i
ISYa C                   else
ISYa C                   exsr      scr02i
ISYa C                   endif
ISYa *
ISYaAC     endup9a       endsr
501tA*----------------------------------------------------------------
501tA*
501tA*  ZZUPD9   Update for screen 9.
501tA*
501tAC     zzupd9        begsr
501tAC                   move      *off          error
501tA*
501tA*      Call Replenishment program.
501tA*
501tAC                   eval      $rcmd  = '*INTERLV'
501tAC                   eval      $rwhse = $whse2
501tAC                   eval      $rwhdp = $whdp2
501taC                   eval      $raisl = $tasl2
501taC                   eval      $rloc  = $tloc2
501taC                   eval      $rrlvl = $tlvl2
501taC                   eval      $rhand = $thnd2
501taC                   eval      $rdisp = $tdis2
501tAC                   eval      $rtrn# = 0
501tAC                   eval      $rtrn# = $trn#2
501tAC                   eval      $rrplt = $rplt2
501tA*
501tAC                   call      'LT105'
501tAC                   parm                    $rparm
501tA*
501tAC                   select
     *
501tA*      User canceled replenishment. Return to putaway.
     *
501tAC                   when      $rrtn = '*CANCEL '
501tAC                   exsr      scr01i
501tAC                   other
     *
501tA*      See if user can do another interleaving replenishment.
     *
501tAC                   eval      $rcmd = '*NEXT   '
501tAC                   exsr      zzckirpl
     *
501tA*      User has selected an Interleaving Replenishment.
     *
501tAC                   If        interlvrpl = '*YES'
501tAC                   exsr      scr09i
501tAC                   else
     *
501tA*      Return user to initial putaway screen.
     *
501tAC                   exsr      scr01i
501tAC                   endif
501tA*
501tAC                   endsl
501tA*
501tAC     endup9        endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZUPD10  Update for screen 10.
650eA*
650eAC     zzupd10       begsr
650eAC                   move      *off          error
650eAC                   move      *on           refrsh
650eA*
650eAC                   move      '10 '         lstscr
650eAC                   exsr      scr11i
650eA*
650eAC     endup10       endsr
650eA*----------------------------------------------------------------
650eA*
650eA*  ZZUPD11  Update for screen 11.
650eA*
650eAC     zzupd11       begsr
650eAC                   move      *off          error
650eAC                   move      *on           refrsh
650eA*
650eAC                   move      '11 '         lstscr
650eAC                   exsr      scr03i
650eA*
650eAC     endup11       endsr
417i *----------------------------------------------------------------
417i *
417iA*  ZZUPDS   Update for screen 3 Staging
417i *
417iAC     zzupds        begsr
417i *
417i *  Create new put away transaction for staged qty.
417i *
417i *  Get new transaction number for staging.
417i *
417i C                   call      'PIRTRN#'
417i C                   parm                    pntrn#
417i *
417i *        Create and start transaction.
417i *
417i C                   eval      @ppcs = w3rqty
     *
417i *    Calculate cube and weight for put away qty.
     *
417i C                   eval      @pcube = sbucub * w3rqty
417i C                   eval      @pswgt = sbuwgt * w3rqty
417i *
417i C                   call      @adjt2
417i C                   parm      '*CREATE '    @pcmd2
417i C                   parm                    #job
417i C                   parm      '*INTER  '    @ptype
417i C                   parm      pntrn#        @ptrn#
417i C                   parm      ottask        @ptask
417i C                   parm      w1whse        @pwhse
417i C                   parm      otwhdp        @pwhdp
417i C                   parm      otstyp        @pstyp
417i C                   parm                    @pcube
417i C                   parm                    @pswgt
417iMC                   parm                    @ppcs
417i C                   parm      0             @paisl
417i C                   parm      1             @pqty1
417i C                   parm      0             @pqty2
417i C                   parm      0             @pqty3
417i C                   parm      ' '           @prte
417i C                   parm      otpo          @ppo
417i C                   parm      otgrp1        @pgrp1
417i C                   parm      otgrp2        @pgrp2
417i C                   parm      otsdte        @pdate
417i C                   parm      otstim        @ptime
600dMC                   parm      #curruser     @puser
417i C                   parm      ' '           @prtn
417i C                   parm      ' '           @pmsg
600dA
600dA*    Update transaction number for license.
600dA
600dAC                   exsr      clr$licinfo
600dA
610hDC**                 eval      $lnlcns  = w1lcns
610hMC                   eval      $lnlcns  = wuScanNbr
600dAC                   eval      $lntype  = 'P'
600dA
600dAC                   eval      $lncodeu(1) = *on
600dAC                   eval      $lncode(1) = '*RCVTRN#'
600dAC                   eval      $lncseq(1) = 1
600dAC                   eval      $lnvaltyp(1) = 'N'
600dAC                   eval      $lnvalchr(1) = ' '
600dAC                   eval      $lnvalnum(1) = pntrn#
600dA
600dAC                   eval      $dricommand = '*LICINFO'
600dAC                   eval      $drisubcmd  = '%CHANGE'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *on
600dAC                   eval      zmflag  = *off
600dAC                   exsr      zzzdricop
600dAC                   if        error
600dAC                   endif
417i *
417i *   Create new putaway label record for staged quantity.
     *
417i C                   clear                   lbrec
417i *
417i C                   call      'PIRLBL#'
417i C                   parm                    lblbl#
     *
417i *   Use saved label rec to create new label rec.
417i *
417i C                   eval      lbwhse = sbwhse
417i C                   move      sbwhdp        lbwhdp
417i C                   eval      lbqryf = sbqryf
417i C                   move      sbdsp2        lbdsp2
417i C                   move      sbitem        lbitem
417i C                   move      sbutyp        lbutyp
417i C                   move      sbucod        lbucod
417i C                   eval      lbucub = sbucub
417i C                   eval      lbuwgt = sbuwgt
417i C                   eval      lbseq = sbseq
417i C                   eval      lbpbat = sbpbat
417i C                   move      sbpo          lbpo
417i C                   eval      lbord = sbord
417i C                   eval      lbtie = sbtie
417i C                   eval      lbhigh = sbhigh
417i C                   move      sbgrp1        lbgrp1
417i C                   move      sbgrp2        lbgrp2
417i C                   move      sbtype        lbtype
417i C                   eval      lbpal# = sbpal#
417i C                   eval      lbtrn# = pntrn#
417i C                   eval      lbrdte = sbrdte
417i C                   move      sbstat        lbstat
417i *
417i C                   eval      lbqpck = w3rqty
417i C                   eval      lbqrmn = w3rqty
417i C                   eval      lbqalc = w3aqty
     *
417i *    Calculate cube and weight for put away qty.
     *
417i C                   eval      lbcube = sbucub * w3rqty
417i C                   eval      lbswgt = sbuwgt * w3rqty
417i *
417i C                   write     lbrec                                79
417i C                   if        *in79
417i C                   move      *on           error
417i C                   exsr      zm71
417i C                   goto      endups
417i C                   endif
501g C                   if        itflgd = 'Y'
     *
500b *   Use saved POMFR rec to create new POMFR rec.
     *
CBI0AC                   if        client = cheney
CBI0AC                   clear                   pmrec2
CBI0AC                   else
500b C                   clear                   pmrec
CBI0AC                   endif
500b C                   eval      pmwhse = pswhse
500b C                   eval      pmpo = pspo
500b C                   eval      pmseq = psseq
500b C                   eval      pmitem = psitem
500b C                   eval      pmexpd = psexpd
500b C                   eval      pmmfgd = psmfgd
500b C                   eval      pmtrn# = lbtrn#
500b C                   eval      pmlbl# = lblbl#
CBI0AC                   if        client = cheney
CBI0AC                   write     pmrec2                               79
CBI0AC                   else
500b C                   write     pmrec                                79
CBI0AC                   endif
500b C                   if        *in79
500b C                   eval      error = *on
500b C                   exsr      zm71
500b C                   goto      endups
500b C                   endif
500b *
501g C                   endif
417i *
417i *  Update license record with new putaway transaction.
417i *
417m C     likey2        chain     license                            79
417i C                   eval      litrn# = pntrn#
417i C                   update    lirec                                79
600dD **
600dD ** Update license history record with new tran#/lbl#
600dD **
600dDC**                 eval      newtrn# = pntrn#
600dDC**                 eval      newlbl# = lblbl#
600dDC**                 exsr      zzupdtrnlbl
417i *
417i *
417i C     endups        endsr
600dD **---------------------------------------------------------------
600dD **
600dD ** ZZUPDTRNLBL   Update license trn#/lbl#
600dD **
600dDC**   zzupdtrnlbl   begsr
600dDC**                 eval      error = *off
600dD **
600dDC**                 exsr      clr$lichist
600dDC**                 eval      $lrlcnsu = *on
600dDC**                 eval      $lrlcns  = kylcns
600dDC**                 eval      $lrtrn#u = *on
600dDC**                 eval      $lrtrn#  = newtrn#
600dDC**                 eval      $lrlbl#u = *on
600dDC**                 eval      $lrlbl#  = newlbl#
600dD **
600dDC**                 eval      $dricommand = '*LICHIST'
600dDC**                 eval      $drisubcmd  = '%UPDTRNLBL'
600dDC**                 eval      $drisys2upd = 'D'
600dDC**                 exsr      zzzdricop
600dDC**                 if        error
600dDC**                 eval      error = *off
600dDC**                 endif
600dD **
600dDC**   endupdtrnlbl  endsr
417oA*
600dA*----------------------------------------------------------------
600dA*
600dA*  ZZUPPK   Update work record.
600dA*
600dAC     zzuppk        begsr

600eDC**   pkkya         chain     workput
610mAC                   eval      kypitm = lbitem
600eAC     wkkey2        chain     workusr2
     C                   if        %found
600eDC**                 eval      wkplic = wkpnbr
710cAc                   if        wuscantype <> 'L'
600eAC                   eval      wuUsrLcns = wuScanNbr
710cAc                   endif
     C                   select
     C                   when      lbutyp = 'N'
600eDC**                 eval      wkpqt1 = w3qty
600eAC                   eval      wuRemQty1 = w3qty
     C                   when      lbutyp = '1'
600eDC**                 eval      wkpqt2 = w3qty
600eAC                   eval      wuRemQty2 = w3qty
     C                   when      lbutyp = '2'
600eDC**                 eval      wkpqt3 = w3qty
600eAC                   eval      wuRemQty3 = w3qty
     C                   endsl
600eDC**                 update    wkprec
600eAC                   update    wuRec
     C                   endif

     C                   endsr

600dA*----------------------------------------------------------------
600dA*  ZZVFYLCNS   Verify license
600dA*----------------------------------------------------------------
600dA
600dAC     zzvfylcns     begsr
     C                   eval      goodli = *off

     *    Left justify license.

     C                   eval      $cstr = *blanks
     C                   move      w1lcns        $cstr
     C                   call      'ADJUST'
     C                   parm      '*LEFTNOZ'    $ccmd             8
     C                   parm                    $cstr            30
     C                   movel     $cstr         w1lcns

     *    Get license from licactive file.

     C                   exsr      clr$license
     C                   eval      $liToLcnsU = *on
     C                   eval      $liToLcns = w1lcns
     C                   eval      $dricommand = '*LICENSE'
     C                   eval      $drisubcmd  = '%GETLCNS'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w1lcns
     C                   exsr      zm2022
     C                   leavesr
     C                   endif

     *    License must be a RCV or STG slot.

     C                   if        $liToAisl <> 'RCV'
700jAC                             and $liToAisl <> 'RTN'
730aAC                             and $liToAisl <> 'RWO'
     C                             and $liToAisl <> 'STG'
     C                             and $liToAisl <> 'OSS'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w1lcns
     C                   eval      erdisp2 = $liToDisp
     C                   exsr      zm2024
     C                   leavesr
     C                   endif

     *    Verify license slot.

     C                   exsr      clr$slot
     C                   eval      $slwhseu = *on
     C                   eval      $slwhse  = $liToWhse
     C                   eval      $slwhdpu = *on
     C                   eval      $slwhdp  = $liToWhdp
     C                   eval      $sldispu = *on
     C                   eval      $sldisp  = $liToDisp
650cAC                   eval      $sldesgu = *on
650cAc                   eval      $sldesg  = $litodesg
     C                   eval      $saitemu = *on
     C                   eval      $saitem  = $liToSItem

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%VFYLICSLT'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   select
     C                   when      $drireturn = 'INVLDSLOT'
     C                   eval      erlcns = w1lcns
     C                   exsr      zm2025
     C                   when      $drireturn = 'SLTNOTAV'
     C                   eval      erlcns = w1lcns
     C                   eval      erdisp2 = $sldisp
     C                   eval      erstat  = $slstat
     C                   exsr      zm2026
     C                   when      $drireturn = 'ITMNOTMTCH'
     C                   eval      erlcns = w1lcns
     C                   eval      erdisp2 = $sldisp
     C                   eval      eritem  = $liToSItem
     C                   eval      eritem2 = $slitem
     C                   exsr      zm2027
     C                   other
     C                   exsr      zm0001
     C                   endsl
     C                   leavesr
     C                   endif

     *    Get transaction number for license.

     C                   exsr      clr$licinfo

     C                   eval      $lnlcns  = w1lcns
     C                   eval      $lntype  = 'P'

     C                   eval      $lncodeu(1) = *on
     C                   eval      $lncode(1) = '*RCVTRN#'
     C                   eval      $lncseq(1) = 1
     C                   eval      $lnvaltyp(1) = 'N'
     C                   eval      $lnvalchr(1) = ' '
     C                   eval      $lnvalnum(1) = 0

     C                   eval      $dricommand = '*LICINFO'
     C                   eval      $drisubcmd  = '%GET'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *on
     C                   eval      zmflag  = *off
     C                   exsr      zzzdricop
     C                   if        error
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w1lcns
     C                   exsr      zm2023
     C                   leavesr
     C                   endif

     *    Get transaction record for license.

     C                   eval      gttrn#  = $lnvalnum(1)
     C                   exsr      zzgett
     C                   if        not trnFound
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w1lcns
     C                   eval      ertrn#2 = gttrn#
     C                   exsr      zm2028
     C                   leavesr
     C                   endif

     *    Transaction must be a putaway tranaction.

     C                   if        $pttask <> 'PUTEMP'  and
710dMC                             $pttask <> 'PUTRTN'  and
710dAC                             $pttask <> 'PUTPD '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      erlcns = w1lcns
     C                   eval      ertrn#2 = $pttrn#
     C                   eval      ertask  = $pttask
     C                   exsr      zm2029
     C                   leavesr
     C                   endif

     *    Transaction must be open

     C                   if        $ptstat <> '1'
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   eval      ertrn# = $ptTrn#
     C                   exsr      zm2002
     C                   leavesr
     C                   endif

     *    Check to see if license is deleted and display error if it is.

     C     $pttrn#       setgt     porcv1
     C     $pttrn#       readpe    porcv1                                 79
     C                   if        %found and poract = 'D'
650mAC                             and porlic = w1lcns
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      errmsg = *blanks
     C                   exsr      zm2021
     C                   leavesr
     C                   endif

     *  Congrats, we have a good license plate

     C                   eval      goodli = *on

     *    Save license and slot info.

     C                   eval      rcv$lcns = $license
     C                   eval      rcv$slot = $slot
     C                   eval      rcv$slot2 = $slot2

     C                   endsr
750cA*----------------------------------------------------------------
750cA*  ZZVFYLCNSRP   Verify licenses attached to the return pallet
750cA*----------------------------------------------------------------
750cA
750cAC     zzvfylcnsRP   begsr
750cAC                   eval      goodli = *off

750cA*    Left justify license.

750cAC                   eval      $cstr = *blanks
750cAC                   move      RNLLCNS       $cstr
750cAC                   call      'ADJUST'
750cAC                   parm      '*LEFTNOZ'    $ccmd             8
750cAC                   parm                    $cstr            30
750cAC                   movel     $cstr         w1lcns

750cA*    Get license from licactive file.

750cAC                   exsr      clr$license
750cAC                   eval      $liToLcnsU = *on
750cAC                   eval      $liToLcns = w1lcns
750cAC                   eval      $dricommand = '*LICENSE'
750cAC                   eval      $drisubcmd  = '%GETLCNS'
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *on
750cAC                   eval      zmflag  = *off
750cAC                   exsr      zzzdricop
750cAC                   if        error
750cAC                   leavesr
750cAC                   endif

750cA*    License must be a RCV or STG slot.

750cAC                   if        $liToAisl <> 'RCV'
750cAC                             and $liToAisl <> 'RTN'
750cAC                             and $liToAisl <> 'RWO'
750cAC                             and $liToAisl <> 'STG'
750cAC                             and $liToAisl <> 'OSS'
750cAC                   eval      error = *on
750cAC                   leavesr
750cAC                   endif

750cA*    Verify license slot.

750cAC                   exsr      clr$slot
750cAC                   eval      $slwhseu = *on
750cAC                   eval      $slwhse  = $liToWhse
750cAC                   eval      $slwhdpu = *on
750cAC                   eval      $slwhdp  = $liToWhdp
750cAC                   eval      $sldispu = *on
750cAC                   eval      $sldisp  = $liToDisp
750cAC                   eval      $sldesgu = *on
750cAc                   eval      $sldesg  = $litodesg
750cAC                   eval      $saitemu = *on
750cAC                   eval      $saitem  = $liToSItem

750cAC                   eval      $dricommand = '*SLOT'
750cAC                   eval      $drisubcmd  = '%VFYLICSLT'
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *on
750cAC                   eval      zmflag = *off
750cAC                   exsr      zzzdricop
750cAC                   if        error
750cAC                   leavesr
750cAC                   endif

750cA*    Get transaction number for license.

750cAC                   exsr      clr$licinfo

750cAC                   eval      $lnlcns  = w1lcns
750cAC                   eval      $lntype  = 'P'

750cAC                   eval      $lncodeu(1) = *on
750cAC                   eval      $lncode(1) = '*RCVTRN#'
750cAC                   eval      $lncseq(1) = 1
750cAC                   eval      $lnvaltyp(1) = 'N'
750cAC                   eval      $lnvalchr(1) = ' '
750cAC                   eval      $lnvalnum(1) = 0

750cAC                   eval      $dricommand = '*LICINFO'
750cAC                   eval      $drisubcmd  = '%GET'
750cAC                   eval      $drisys2upd = 'D'
750cAC                   eval      chk4err = *on
750cAC                   eval      zmflag  = *off
750cAC                   exsr      zzzdricop
750cAC                   if        error
750cAC                   leavesr
750cAC                   endif

750cA*    Get transaction record for license.

750cAC                   eval      gttrn#  = $lnvalnum(1)
750cAC                   exsr      zzgett
750cAC                   if        not trnFound
750cAC                   eval      error = *on
750cAC                   leavesr
750cAC                   endif

750cA*    Transaction must be a putaway tranaction.

750cAC                   if        $pttask <> 'PUTEMP'  and
750cAC                             $pttask <> 'PUTRTN'  and
750cAC                             $pttask <> 'PUTPD '
750cAC                   eval      error = *on
750cAC                   leavesr
750cAC                   endif

750cA*    Transaction must be open

750cAC                   if        $ptstat <> '1'
750cAC                   eval      error = *on
750cAC                   leavesr
750cAC                   endif

750cA*    Check to see if license is deleted and display error if it is.

750cAC     $pttrn#       setgt     porcv1
750cAC     $pttrn#       readpe    porcv1                                 79
750cAC                   if        %found and poract = 'D'
750cAC                             and porlic = w1lcns
750cAC                   eval      error = *on
750cAC                   leavesr
750cAC                   endif

750cA*  Congrats, we have a good license plate

750cAC                   eval      goodli = *on

750cAC                   endsr
     *----------------------------------------------------------------
     *
412dA*  ZZWHSE   Update warehouse quantities.
     *
412dAC     zzwhse        begsr
     *
     C                   move      $aitem        svitem
     *
     *    If Alias item or Same Slot Breakdown item
     *      Then DO NOT update quantity of label item.
     *
     C                   if        ittype <> 'A'  and
     C                             ittype <> 'S'
     C                   call      'ADJQTY'
     C                   parm                    $acmd             8
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
413eMC                   if        $artn = '*PGMQ   '
     C                   move      *on           error
413eMC                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  If Alias or SSB item
     *   Then update Base item warehouse quantity.
     *
     C                   if        ittype = 'A'  or
     C                             ittype = 'S'
417tMC                   move      #sitem        $aitem
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
413eMC                   if        $artn = '*PGMQ   '
     C                   move      *on           error
413eMC                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
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
417tMC                   move      #sitem        $aitem
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
413eMC                   if        $artn = '*PGMQ   '
     C                   move      *on           error
413eMC                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
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
417tMC                   move      #sitem        $aitem
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
413eMC                   if        $artn = '*PGMQ   '
     C                   move      *on           error
413eMC                   eval      #msgk = $amsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C                   endif
     *
     C                   move      svitem        $aitem
412qAC                   endsr

500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------
500hA*                     DRI SUBROUTINES
500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------

500hA*----------------------------------------------------------------
500hA*  clr$item  Clear $item data structure fields
500hA*----------------------------------------------------------------
500hA
500hAC     clr$item      begsr
     C                   eval      savever# = $itver#
     C                   clear                   $item
600dAC                   clear                   $item2
     C                   eval      $itver# = savever#
     C                   endsr

600dA*----------------------------------------------------------------
600dA*  clr$license  Clear $license data structure fields
600dA*----------------------------------------------------------------
600dA
600dAC     clr$license   begsr
     C                   eval      savever# = $liver#
     C                   clear                   $license
     C                   eval      $liver# = savever#
     C                   eval      $liemp# = e$emp#
600dMC                   eval      $liuser = #curruser
     C                   eval      $lipgm  = #pgm
     C                   eval      $lijob  = #job
     C                   eval      $lijobn = #jobnbr
     C                   eval      $liTowhse = w1whse
     C                   eval      $liTowhseu = *on
     C                   endsr

600aA*----------------------------------------------------------------
600aA*  clr$lichist  Clear $lichist data structure fields
600aA*----------------------------------------------------------------
600aA
600aAC     clr$lichist   begsr
     C                   eval      savever# = $lrver#
     C                   clear                   $lichist
     C                   eval      $lrver# = savever#
     C                   eval      $lremp# = w1emp#
600dMC                   eval      $lruser = #curruser
     C                   eval      $lrpgm  = #prog
     C                   eval      $lrjob  = #job
     C                   eval      $lrjobn = #jobn
     C                   eval      $lrwhse = w1whse
     C                   eval      $lrwhseu = *on
     C                   endsr

600cA*----------------------------------------------------------------
600cA*  clr$licinfo  Clear $licinfo data structure fields
600cA*----------------------------------------------------------------
600cA
600cAC     clr$licinfo   begsr
     C                   eval      savever# = $lnver#
     C                   clear                   $licinfo
     C                   eval      $lnver# = savever#

     C                   eval      $lnemp# = e$emp#
600dMC                   eval      $lnuser = #curruser
     C                   eval      $lnpgm  = #prog
     C                   eval      $lnjob  = #job
     C                   eval      $lnjobnbr = #jobn
     C                   eval      $lnwhse  = w1whse
     C                   endsr

600cA*----------------------------------------------------------------
600cA*  clr$pirtran  Clear $pirtran data structure fields
600cA*----------------------------------------------------------------
600cA
600cAC     clr$pirtran   begsr
     C                   eval      savever# = $ptver#
     C                   clear                   $pirtran
     C                   eval      $ptver# = savever#
     C                   endsr

500hA*----------------------------------------------------------------
500hA*  clr$slot  Clear $slot data structure fields
500hA*----------------------------------------------------------------
500hA
500hAC     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600dAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600dAC                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
     C                   endsr

500hA*----------------------------------------------------------------
500hA*  clr$slotw  Clear $slot data structure fields saving warnings
500hA*----------------------------------------------------------------
500hA
500hAC     clr$slotw     begsr
500hA
     C                   eval      savepicke = $slpicke
710hAC                   eval      savedispe = $sldispe
500hA
     C                   eval      savever# = $slver#
     C                   clear                   $slot
600dAC                   clear                   $slot2
     C                   eval      $slver# = savever#
600dAC                   eval      $saemp#U = *on
     C                   eval      $saemp# = e$emp#
500hA
     C                   eval      $slpicke = savepicke
710hAC                   eval      $sldispe = savedispe
500hA
     C                   endsr

500hA*----------------------------------------------------------------
500hA*  clr$slotdef  Clear $slotdef data structure fields
500hA*----------------------------------------------------------------
500hA
500hAC     clr$slotdef   begsr
     C                   eval      savever# = $sdver#
     C                   clear                   $slotdef
     C                   eval      $sdver# = savever#
     C                   endsr

600dA*----------------------------------------------------------------
600dA*  ZZZDTE   Get date.
600dA*----------------------------------------------------------------
600dA
600dAC     zzzdte        begsr
     *
     C                   eval      $cvcmd = '*CURCMD '
     C                   call      @cvtdt
     C                   parm                    $cvtdt
     C                   eval      today = $cvd8o
     C                   time                    lsttim
     *
     C                   endsr
500hA
500hA*----------------------------------------------------------------
500hA*  zzzdriclose   Close any open files or programs.
500hA*----------------------------------------------------------------
500hA
500hAC     zzzdriclose   begsr

     *  Close interfaces

     C                   eval      $dricommand = '*ITEM'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

600aAC                   eval      $dricommand = '*LICHIST'
600aAC                   eval      $drisubcmd  = '%CLOSE'
600aAC                   eval      $drisys2upd = 'D'
600aAC                   eval      chk4err = *off
600aAC                   exsr      zzzdricop

600dAC                   eval      $dricommand = '*LICENSE'
600dAC                   eval      $drisubcmd  = '%CLOSE'
600dAC                   eval      $drisys2upd = 'D'
600dAC                   eval      chk4err = *off
600dAC                   exsr      zzzdricop

600cAC                   eval      $dricommand = '*LICINFO'
600cAC                   eval      $drisubcmd  = '%CLOSE'
600cAC                   eval      $drisys2upd = 'D'
600cAC                   eval      chk4err = *off
600cAC                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOT'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      $drisys2upd = 'D'
     C                   eval      chk4err = *off
     C                   exsr      zzzdricop

     C                   eval      $dricommand = '*SLOTDEF'
     C                   eval      $drisubcmd  = '%CLOSE'
     C                   eval      chk4err = *off
     C                   eval      $drisys2upd = 'D'
     C                   exsr      zzzdricop

600cAC                   eval      $dricommand = '*PIRTRAN'
600cAC                   eval      $drisubcmd  = '%CLOSE'
600cAC                   eval      chk4err = *off
600cAC                   eval      $drisys2upd = 'D'
600cAC                   exsr      zzzdricop

     C                   endsr
500xA
500hA*----------------------------------------------------------------
500hA*  zzzdricop  Call DRICOP
500hA*----------------------------------------------------------------
500hA
500hAC     zzzdricop     begsr
     C                   eval      error = *off

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
600dAC                   eval      $dridata2 = $slot2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $dridata = $slotdef
     C                   when      $dricommand = '*ITEM'
     C                   eval      $dridata = $item
     C                   eval      $dridata2 = $item2
600aAC                   when      $dricommand = '*LICHIST'
600aAC                   eval      $dridata = $lichist
600dAC                   when      $dricommand = '*LICENSE'
600dAC                   eval      $dridata = $license
600dAC                   eval      $dridata2 = $license2
600cAC                   when      $dricommand = '*LICINFO'
600cAC                   eval      $dridata = $licinfo
600cAC                   when      $dricommand = '*PIRTRAN'
600cAC                   eval      $dridata = $pirtran
     C                   endsl

     C                   if        $dricommand = '*ITEM'
600dAC                             or $dricommand = '*SLOT'
600dAC                             or $dricommand = '*LICENSE'
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
600dAC                   select
600dAC                   when      zmsflag
     C**                 exsr      zm0105s
600dAC                   when      zmflag
     C                   exsr      zm0105
600dAC                   endsl

     C                   when      chk4err and $drireturn <> '*OK'
     C                   eval      error = *on
600dAC                   select
600dAC                   when      zmsflag
     C**                 exsr      zm0001s
600dAC                   when      zmflag
710eAC                   if        $drireturn = 'INVLDSLOT'
710eAC                   eval      *in26 = *on
710eAC                   eval      *in06 = *on
710eAC                   endif
     C                   exsr      zm0001
     C**                 exsr      zzerrind
600dAC                   endsl

     C                   endsl

     C                   select
     C                   when      $dricommand = '*SLOT'
     C                   eval      $slot = $dridata
600dAC                   eval      $slot2 = $dridata2
     C                   when      $dricommand = '*SLOTDEF'
     C                   eval      $slotdef = $dridata
     C                   when      $dricommand = '*ITEM'
     C                   eval      $item = $dridata
     C                   eval      $item2 = $dridata2
600aAC                   when      $dricommand = '*LICHIST'
600aAC                   eval      $lichist = $dridata
600dAC                   when      $dricommand = '*LICENSE'
600dAC                   eval      $license = $dridata
600dAC                   eval      $license2 = $dridata2
600cAC                   when      $dricommand = '*LICINFO'
600cAC                   eval      $licinfo = $dridata
600cAC                   when      $dricommand = '*PIRTRAN'
600cAC                   eval      $pirtran = $dridata
     C                   endsl

600dAC                   eval      zmflag = *off
     C                   eval      zmsflag = *off
     C                   eval      chk4err = *off
     C     enddricop     endsr

500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------
500hA*  License Plate Tracking Routines
500hA*----------------------------------------------------------------
500hA*----------------------------------------------------------------

417qA*----------------------------------------------------------------
417qA*  ZZZCLR$LT210  -  Clear LT210 parameters.
417qA*----------------------------------------------------------------

417qAC     ZZZCLR$LT210  begsr

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
500 AC                   clear                   $tnewlic#
     C                   clear                   $tqty1
     C                   clear                   $tqty2
     C                   clear                   $tqty3
500kAC                   clear                   $tnorm1
500kAC                   clear                   $tnorm2
500kAC                   clear                   $tnorm3
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

417qA*----------------------------------------------------------------
417qA*  ZZZCALL$LT210  -  Call LT210 program.
417qA*----------------------------------------------------------------

417qAC     ZZZCALL$LT210 begsr

     C                   call      'LT210'
     C                   parm                    $tcmd
     C                   parm      #prog         $tprogram
     C                   parm      'PUT'         $ttype
     C                   parm      'RF Putawy'   $thead
     C                   parm      w1whse        $twhse
     C                   parm                    $titem
     C                   parm                    $titemdsc
     C                   parm                    $twhdp
     C                   parm                    $tslot
     C                   parm                    $tslotpos
     C                   parm      w1emp#        $templ#
     C                   parm                    $ttran#
     C                   parm                    $tlic#
500 AC                   parm                    $tnewlic#
     C                   parm                    $tqty1
     C                   parm                    $tqty2
     C                   parm                    $tqty3
500kAC                   parm                    $tnorm1
500kAC                   parm                    $tnorm2
500kAC                   parm                    $tnorm3
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
         pEmp# = e$emp#;
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

     *----------------------------------------------------------------
     *
     *  COMPILE TIME TABLES
     *
**
Transaction
Label
License
Wrong zone scanned
Invalid Label#
Dock Door
Locaton
Type

Item being processed is not slotted
**
 ABCDEFGHIJKLMNOPQRSTUVWXYZ
** descsp
Transaccion
Rotulo
Licencia
Zona escandida incorrecta
#Rotulo no encontrado.
puerta del muelle
ubicacion
el tipo
